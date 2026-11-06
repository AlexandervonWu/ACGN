"""Attempt-level graph memory, public feedback search and executable repair plans."""
import copy
from dataclasses import dataclass
from itertools import product
import random

import torch
from torch import nn
from torch.nn import functional as F

from .contextual import ReplayedEpisode, run_episode, replay_for_training
from .gnn_variants import VariantPolicy
from .local_runtime import queries
from .tables import encode, WORLD

CONTRACT = 'multistep-contextual-repair-v1'
CARDS = ('U:NO', 'U:ONE', 'U:LONE', 'U:SOME')
PLANS = tuple(product(range(4), repeat=2))
MODES = ('persistent', 'reset', 'blind')


def holds(card, n):
    if card not in range(4) or n < 0:
        raise ValueError('CARDINALITY_SCOPE')
    return (n == 0, n == 1, n <= 1, n > 0)[card]


def evaluate(plan, counts):
    return all(holds(c, n) for c, n in zip(plan, counts, strict=True))


def shape(obs, operators):
    """Two syntactic roles, not signature spellings or hidden goal identities."""
    source = obs['current']
    nodes, ports = source['nodes'], source['ports']
    def children(i):
        return [p[1] for p in sorted(ports, key=lambda p: p[2]) if p[0] == i]
    if len(nodes) != 5 or operators[nodes[0][0]] not in ('L:AND', 'B:AND'):
        raise ValueError('TWO_CARDINALITY_CONJUNCTION_REQUIRED')
    roots = children(0)
    if len(roots) != 2:
        raise ValueError('TWO_CARDINALITY_CONJUNCTION_REQUIRED')
    cards, leaves, symbols = [], [], []
    for root in roots:
        kids = children(root)
        if operators[nodes[root][0]] not in CARDS or len(kids) != 1 or operators[nodes[kids[0]][0]] != 'SIG':
            raise ValueError('SIGNATURE_CARDINALITY_REQUIRED')
        cards.append(CARDS.index(operators[nodes[root][0]]))
        leaves.append(kids[0]); symbols.append(nodes[kids[0]][2])
    if len(set(symbols)) != 2 or len(set((0, *roots, *leaves))) != 5:
        raise ValueError('DISTINCT_SIGNATURE_ROLES_REQUIRED')
    return tuple(cards), tuple(leaves), tuple(symbols)


def evidence(obs, operators, latest=True):
    current, _, source_ids = shape(obs, operators)
    feedback = obs['feedback']
    worlds = feedback['worlds']
    if not worlds:
        return ()
    feedback_ids = []
    for source_id in source_ids:
        matches = [i for i, r in enumerate(feedback['symbols']) if r[1] == source_id and r[0] == 0]
        if len(matches) != 1:
            raise ValueError('INCOMPLETE_WITNESS_SYMBOL_MAPPING')
        feedback_ids.append(matches[0])
    last = max(r[0] for r in worlds)
    results = []
    for w, row in enumerate(worlds):
        if latest and row[0] != last:
            continue
        if row[4:] != [1, 0] or row[2] not in (0, 1) or row[3] not in (0, 1) or row[2] == row[3]:
            raise ValueError('NONSTATIC_OR_NONCOUNTEREXAMPLE_WORLD')
        counts = []
        for symbol in feedback_ids:
            tuples = [t for t in feedback['tuples'] if t[0] == w and t[2] == symbol]
            if any(t[1] != 0 or t[4] != 0 for t in tuples):
                raise ValueError('NONUNARY_WITNESS')
            counts.append(min(2, len({t[5] for t in tuples})))
        if latest and (row[1] != obs['revision'] or evaluate(current, counts) != bool(row[3])):
            raise ValueError('WITNESS_SOURCE_CORRESPONDENCE')
        results.append((*counts, row[2], row[3]))
    return tuple(sorted(set(results)))


def consistent(plan, events):
    return all(evaluate(plan, e[:2]) == bool(e[2]) for e in events)


def survivors(events):
    return tuple(i for i, p in enumerate(PLANS) if consistent(p, events))


def path(obs, operators, index):
    if not 0 <= index < len(PLANS):
        raise ValueError('PLAN_INDEX_INVALID')
    _, leaves, _ = shape(obs, operators)
    return [{'control': 0, 'site': 0, 'family': 8},
            {'control': 6, 'operator': operators.index('B:AND')},
            {'control': 6, 'operator': operators.index(CARDS[PLANS[index][0]])},
            {'control': 1, 'pointer': leaves[0]},
            {'control': 6, 'operator': operators.index(CARDS[PLANS[index][1]])},
            {'control': 1, 'pointer': leaves[1]}, {'control': 8}]


@dataclass
class Frame:
    graph: object
    event: torch.Tensor
    candidates: torch.Tensor
    available: torch.Tensor

    def to(self, device):
        return Frame(self.graph.to(device), self.event.to(device),
                     self.candidates.to(device), self.available.to(device))


def frame(obs, operators, tried, blind=False):
    current, _, _ = shape(obs, operators)
    latest = () if blind else evidence(obs, operators)
    # All arms use the same source-only graph. In particular, reset/blind cannot
    # recover earlier counterexamples through the executor's cumulative tables.
    public = copy.deepcopy(obs)
    public['feedback'] = {**{name: [] for name in WORLD}, 'omittedWorlds': 0}
    public['history'] = []
    if public['draft'] or public['draftDeclarations'] or public['actions']['holes']:
        raise ValueError('ATTEMPT_REQUIRES_NO_DRAFT')
    graph = encode(public, operators)
    event = torch.zeros(28)
    for a, b, expected, actual in latest:
        offset = (3 * a + b) * 3
        event[offset:offset+3] += torch.tensor([1, expected, actual], dtype=torch.float32)
    event[-1] = queries(obs) / 4
    features = []
    for plan in PLANS:
        onehot = [int(plan[i] == c) for i in range(2) for c in range(4)]
        conflicts = sum(evaluate(plan, e[:2]) != bool(e[2]) for e in latest)
        features.append(onehot + [int(plan[i] != current[i]) for i in range(2)]
                        + [conflicts / 2, len(latest) / 2])
    available = torch.tensor([i not in tried and p != current for i, p in enumerate(PLANS)])
    return Frame(graph, event, torch.tensor(features, dtype=torch.float32), available)


class MultistepPolicy(nn.Module):
    """Shared plan scorer with one memory transition per observed failed attempt."""
    def __init__(self, mode='persistent', width=48, layers=2):
        super().__init__()
        if mode not in MODES:
            raise ValueError('UNKNOWN_CONTEXT_MODE')
        self.mode = mode
        self.encoder = VariantPolicy('gin', width, layers)
        self.event = nn.Sequential(nn.Linear(width + 28, width), nn.GELU(), nn.LayerNorm(width))
        self.memory = nn.GRUCell(width, width)
        self.context = nn.Sequential(nn.Linear(2 * width, width), nn.GELU(), nn.LayerNorm(width))
        self.plan = nn.Sequential(nn.Linear(12, width), nn.GELU(), nn.LayerNorm(width))
        self.score = nn.Sequential(nn.Linear(3 * width, width), nn.GELU(), nn.Linear(width, 1))
        self.agreement = nn.Sequential(nn.Linear(3 * width, width), nn.GELU(), nn.Linear(width, 1))

    def forward(self, x, memory=None):
        _, graph_query = self.encoder.encode(x.graph)
        event = self.event(torch.cat((graph_query, x.event)))
        if memory is None or self.mode == 'reset':
            memory = torch.zeros_like(event)
        memory = self.memory(event, memory)
        query = self.context(torch.cat((event, memory)))
        candidates = self.plan(x.candidates)
        mixed = torch.cat((query.expand_as(candidates), candidates, candidates * query), dim=-1)
        logits = self.score(mixed).squeeze(-1).masked_fill(~x.available, -torch.inf)
        return logits, self.agreement(mixed).squeeze(-1), memory


class PlanAgent:
    """Receives public observations only. Paths are plans, not privileged labels."""
    def __init__(self, operators, mode='search', model=None, seed=17):
        if mode not in (*MODES, 'search', 'random') or (mode in MODES) != (model is not None):
            raise ValueError('INVALID_PLAN_AGENT')
        if model is not None and model.mode != mode:
            raise ValueError('MODE_MODEL_MISMATCH')
        self.operators, self.mode, self.model = operators, mode, model
        self.pending, self.tried, self.events, self.attempts = [], set(), set(), []
        self.memory, self.rng = None, random.Random(seed)

    def __call__(self, obs):
        if obs['status'] in (2, 3, 6, 7, 8, 9, 10):
            raise ValueError('PLAN_EXECUTION_FAILED')
        if self.pending:
            return self.pending.pop(0)
        if obs['status'] != 4:
            raise ValueError('PLAN_WITHOUT_REAL_FAILURE')
        current, _, _ = shape(obs, self.operators)
        self.tried.add(PLANS.index(current))
        self.events.update(evidence(obs, self.operators))
        x = frame(obs, self.operators, self.tried, blind=self.mode == 'blind')
        choices = x.available.nonzero().flatten().tolist()
        if self.mode == 'search':
            choices = [i for i in choices if consistent(PLANS[i], self.events)]
            choices.sort(key=lambda i: (sum(a != b for a, b in zip(current, PLANS[i])), i))
        if not choices:
            return {'control': 13}
        if self.mode == 'random':
            selected = self.rng.choice(choices)
        elif self.model is None:
            selected = choices[0]
        else:
            self.model.eval()
            with torch.no_grad():
                logits, _, self.memory = self.model(x, self.memory)
                if not torch.isfinite(logits[x.available]).all():
                    raise ValueError('NONFINITE_POLICY')
                selected = int(logits.argmax())
        self.attempts.append({'plan': selected, 'revision': obs['revision'],
                              'tried': sorted(self.tried), 'latest': evidence(obs, self.operators),
                              'survivors': list(survivors(self.events))})
        self.tried.add(selected)
        self.pending = path(obs, self.operators, selected)
        return self.pending.pop(0)


def rollout(task, classes, log, operators, mode='search', model=None, seed=17):
    agent = PlanAgent(operators, mode, model, seed)
    trial = run_episode(task, classes, log, proposer=agent)
    trial.update(planContract=CONTRACT, mode=mode, seed=seed, attempts=agent.attempts)
    return trial


@dataclass
class Example:
    observation: dict
    tried: set
    plan: int
    consistent: list


def training_examples(task, trial, classes, log, operators):
    replay = replay_for_training(task, trial, classes, log)
    return examples_from_replay(replay, operators)


def examples_from_replay(replay, operators):
    if not isinstance(replay, ReplayedEpisode):
        raise ValueError('FRESH_REPLAY_REQUIRED')
    examples, tried, events = [], set(), set()
    i = 0
    while i < len(replay.records):
        record = replay.records[i]
        if record['role'] == 'controller':
            i += 1
            continue
        obs = record['observation']
        if record['action'] == {'control': 13}:
            i += 1
            continue
        if obs['status'] != 4:
            raise ValueError('TRAINING_PLAN_WITHOUT_FAILURE')
        current, _, _ = shape(obs, operators)
        tried.add(PLANS.index(current))
        events.update(evidence(obs, operators))
        labels = [r['action'] for r in replay.records[i:i+7]]
        matches = [p for p in range(16) if path(obs, operators, p) == labels]
        if len(matches) != 1 or matches[0] in tried:
            raise ValueError('INVALID_OR_REPEATED_PLAN_PATH')
        plan = matches[0]
        examples.append(Example(copy.deepcopy(obs), set(tried), plan,
                                [consistent(p, events) for p in PLANS]))
        tried.add(plan)
        i += 7
    if not examples:
        raise ValueError('NO_MULTISTEP_TRAINING_EXAMPLE')
    return examples


def prepare_examples(examples, operators, mode):
    return [(frame(e.observation, operators, e.tried, blind=mode == 'blind'), e.plan,
             torch.tensor(e.consistent, dtype=torch.float32)) for e in examples]


def episode_loss(model, examples):
    memory, losses = None, []
    for x, target, agreement in examples:
        logits, predicted_agreement, memory = model(x, memory)
        if not x.available[target]:
            raise ValueError('TEACHER_OUTSIDE_MASK')
        losses.append(F.cross_entropy(logits[None], torch.tensor([target]))
                      + 0.2 * F.binary_cross_entropy_with_logits(predicted_agreement, agreement))
    if not losses:
        raise ValueError('EMPTY_EPISODE')
    return torch.stack(losses).mean()
