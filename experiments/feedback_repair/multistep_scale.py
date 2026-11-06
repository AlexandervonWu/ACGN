"""Variable-arity repair plans with exact public evidence memory."""
import copy
from dataclasses import dataclass
from functools import lru_cache
from itertools import product
import random

import torch
from torch import nn
from torch.nn import functional as F

from .contextual import ReplayedEpisode, run_episode, replay_for_training
from .gnn_variants import VariantPolicy
from .local_runtime import queries
from .multistep import CARDS, holds
from .tables import WORLD, encode

CONTRACT = 'multistep-scaling-v1'


@dataclass(frozen=True)
class Shape:
    op: str
    current: tuple
    leaves: tuple
    symbols: tuple


@lru_cache(maxsize=3)
def plans(arity):
    if not 2 <= arity <= 4:
        raise ValueError('ARITY_OUTSIDE_2_4')
    return tuple(product(range(4), repeat=arity))


def shape(obs, operators):
    nodes, ports = obs['current']['nodes'], obs['current']['ports']
    if not nodes or operators[nodes[0][0]] not in ('L:AND', 'B:AND', 'L:OR', 'B:OR'):
        raise ValueError('HOMOGENEOUS_CARDINALITY_TREE_REQUIRED')
    connective = operators[nodes[0][0]].split(':')[1]
    cards, leaves, symbols, visited = [], [], [], set()
    children = {}
    for p in sorted(ports, key=lambda p: p[2]):
        children.setdefault(p[0], []).append(p[1])
    def walk(index):
        if index in visited:
            raise ValueError('NON_TREE_SOURCE')
        visited.add(index)
        op = operators[nodes[index][0]]
        kids = children.get(index, [])
        if op in ('L:'+connective, 'B:'+connective) and len(kids) >= 2:
            for child in kids:
                walk(child)
        elif op in CARDS and len(kids) == 1 and operators[nodes[kids[0]][0]] == 'SIG':
            leaf = kids[0]
            if leaf in visited or children.get(leaf):
                raise ValueError('NON_LEAF_SIGNATURE')
            visited.add(leaf)
            cards.append(CARDS.index(op)); leaves.append(leaf); symbols.append(nodes[leaf][2])
        else:
            raise ValueError('HOMOGENEOUS_SIGNATURE_CARDINALITIES_REQUIRED')
    walk(0)
    plans(len(cards))
    if len(visited) != len(nodes) or len(set(symbols)) != len(symbols):
        raise ValueError('DISTINCT_COMPLETE_SOURCE_ROLES_REQUIRED')
    return Shape(connective, tuple(cards), tuple(leaves), tuple(symbols))


def evaluate(op, plan, counts):
    if op not in ('AND', 'OR') or len(plan) != len(counts):
        raise ValueError('EVALUATION_ARITY_OR_OPERATOR')
    values = [holds(c, n) for c, n in zip(plan, counts)]
    return all(values) if op == 'AND' else any(values)


def evidence(obs, operators):
    s = shape(obs, operators)
    feedback, result = obs['feedback'], []
    if not feedback['worlds']:
        return ()
    mapped = []
    for source_id in s.symbols:
        matches = [i for i, row in enumerate(feedback['symbols']) if row[0] == 0 and row[1] == source_id]
        if len(matches) != 1:
            raise ValueError('INCOMPLETE_WITNESS_SYMBOL_MAPPING')
        mapped.append(matches[0])
    latest = max(r[0] for r in feedback['worlds'])
    for index, row in enumerate(feedback['worlds']):
        if row[0] != latest:
            continue
        if row[1] != obs['revision'] or row[4:] != [1, 0] or row[2] not in (0, 1) or row[3] != 1-row[2]:
            raise ValueError('NONSTATIC_OR_UNBOUND_COUNTEREXAMPLE')
        counts = []
        for symbol in mapped:
            tuples = [t for t in feedback['tuples'] if t[0] == index and t[2] == symbol]
            if any(t[1] != 0 or t[4] != 0 for t in tuples):
                raise ValueError('NONUNARY_WITNESS')
            counts.append(min(2, len({t[5] for t in tuples})))
        if evaluate(s.op, s.current, counts) != bool(row[3]):
            raise ValueError('WITNESS_SOURCE_CORRESPONDENCE')
        result.append((tuple(counts), row[2]))
    return tuple(sorted(set(result)))


def consistent(op, plan, events):
    return all(evaluate(op, plan, counts) == bool(label) for counts, label in events)


def available(s, tried, events, filtered=True):
    return tuple(i for i, p in enumerate(plans(len(s.current))) if i not in tried and p != s.current
                 and (not filtered or consistent(s.op, p, events)))


def path(obs, operators, index):
    s = shape(obs, operators)
    pool = plans(len(s.current))
    if not 0 <= index < len(pool):
        raise ValueError('PLAN_INDEX_INVALID')
    result = [{'control': 0, 'site': 0, 'family': 8}]
    for i, (card, leaf) in enumerate(zip(pool[index], s.leaves)):
        if i < len(s.leaves)-1:
            result.append({'control': 6, 'operator': operators.index('B:'+s.op)})
        result.extend(({'control': 6, 'operator': operators.index(CARDS[card])},
                       {'control': 1, 'pointer': leaf}))
    return result + [{'control': 8}]


@dataclass
class Frame:
    graph: object
    leaves: torch.Tensor
    slots: torch.Tensor
    candidate: torch.Tensor
    event: torch.Tensor
    available: torch.Tensor


def frame(obs, operators, tried, events, filtered=True):
    s = shape(obs, operators)
    latest = evidence(obs, operators)
    public = copy.deepcopy(obs)
    public['feedback'] = {**{name: [] for name in WORLD}, 'omittedWorlds': 0}
    public['history'] = []
    if public['draft'] or public['draftDeclarations'] or public['actions']['holes']:
        raise ValueError('ATTEMPT_REQUIRES_NO_DRAFT')
    graph = encode(public, operators)
    slots, features = [], []
    pool = plans(len(s.current))
    for p in pool:
        slots.append([[int(card == j) for j in range(4)] + [int(current == j) for j in range(4)]
                      for card, current in zip(p, s.current)])
        conflicts = [sum(evaluate(s.op, p, counts) != bool(label) for counts, label in es)
                     / max(1, len(es)) for es in (latest, events)]
        features.append([sum(a != b for a, b in zip(p, s.current))/len(p), *conflicts,
                         int(s.op == 'OR'), len(p)/4])
    mask = set(available(s, tried, events, filtered))
    return Frame(graph, torch.tensor([graph.addresses['current.nodes', i] for i in s.leaves]),
                 torch.tensor(slots, dtype=torch.float32), torch.tensor(features, dtype=torch.float32),
                 torch.tensor([queries(obs)/4, len(latest)/2, len(events)/8, len(s.current)/4, int(s.op == 'OR')]),
                 torch.tensor([i in mask for i in range(len(pool))]))


class ScalePolicy(nn.Module):
    def __init__(self, width=48, layers=2):
        super().__init__()
        self.encoder = VariantPolicy('gin', width, layers)
        self.slot = nn.Sequential(nn.Linear(width+8, width), nn.GELU(), nn.LayerNorm(width))
        self.plan = nn.Sequential(nn.Linear(width+5, width), nn.GELU(), nn.LayerNorm(width))
        self.event = nn.Sequential(nn.Linear(width+5, width), nn.GELU(), nn.LayerNorm(width))
        self.memory = nn.GRUCell(width, width)
        self.context = nn.Sequential(nn.Linear(2*width, width), nn.GELU(), nn.LayerNorm(width))
        self.score = nn.Sequential(nn.Linear(3*width, width), nn.GELU(), nn.Linear(width, 1))
        self.agreement = nn.Linear(3*width, 1)

    def forward(self, x, memory=None, reset=False):
        h, query = self.encoder.encode(x.graph)
        event = self.event(torch.cat((query, x.event)))
        if memory is None or reset:
            memory = torch.zeros_like(event)
        memory = self.memory(event, memory)
        query = self.context(torch.cat((event, memory)))
        leaf = h[x.leaves].expand(len(x.slots), -1, -1)
        slots = self.slot(torch.cat((leaf, x.slots), -1)).mean(1)
        candidates = self.plan(torch.cat((slots, x.candidate), -1))
        joint = torch.cat((query.expand_as(candidates), candidates, candidates*query), -1)
        return self.score(joint).squeeze(-1).masked_fill(~x.available, -torch.inf), self.agreement(joint).squeeze(-1), memory


class Agent:
    def __init__(self, operators, mode='search', model=None, seed=17, explore=False):
        if mode not in ('search', 'filtered_random', 'random', 'model', 'reset', 'unfiltered'):
            raise ValueError('UNKNOWN_MODE')
        if (model is not None) != (mode in ('model', 'reset', 'unfiltered')):
            raise ValueError('MODEL_MODE_MISMATCH')
        self.operators, self.mode, self.model = operators, mode, model
        self.pending, self.tried, self.events, self.attempts = [], set(), set(), []
        self.memory, self.rng, self.explore = None, random.Random(seed), explore

    def __call__(self, obs):
        if obs['status'] in (2, 3, 6, 7, 8, 9, 10):
            raise ValueError('PLAN_EXECUTION_FAILED')
        if self.pending:
            return self.pending.pop(0)
        if obs['status'] != 4:
            raise ValueError('PLAN_WITHOUT_REAL_FAILURE')
        s = shape(obs, self.operators)
        pool = plans(len(s.current))
        self.tried.add(pool.index(s.current))
        self.events.update(evidence(obs, self.operators))
        filtered = self.mode not in ('random', 'unfiltered')
        choices = list(available(s, self.tried, self.events, filtered))
        if not choices:
            return {'control': 13}
        exploratory = self.explore and not self.attempts
        if self.mode in ('random', 'filtered_random') or exploratory:
            selected = self.rng.choice(choices)
        elif self.model is None:
            selected = min(choices, key=lambda i: (sum(a != b for a, b in zip(pool[i], s.current)), i))
        else:
            with torch.no_grad():
                x = frame(obs, self.operators, self.tried, self.events, filtered)
                logits, _, self.memory = self.model(x, self.memory, reset=self.mode == 'reset')
                if not torch.isfinite(logits[x.available]).all():
                    raise ValueError('NONFINITE_POLICY')
                selected = int(logits.argmax())
        self.attempts.append(dict(plan=selected, revision=obs['revision'], exploratory=exploratory,
                                  consistent=consistent(s.op, pool[selected], self.events),
                                  survivors=len(available(s, self.tried, self.events))))
        self.tried.add(selected)
        self.pending = path(obs, self.operators, selected)
        return self.pending.pop(0)


def rollout(task, classes, log, operators, mode='search', model=None, seed=17, explore=False):
    agent = Agent(operators, mode, model, seed, explore)
    if model is not None:
        model.eval()
    trial = run_episode(task, classes, log, proposer=agent)
    trial.update(planContract=CONTRACT, mode=mode, seed=seed, explore=explore, attempts=agent.attempts)
    return trial


def training_examples(task, trial, classes, log, operators):
    replay = replay_for_training(task, trial, classes, log)
    return examples_from_replay(replay, operators, trial['explore'])


def examples_from_replay(replay, operators, explore=False):
    if not isinstance(replay, ReplayedEpisode):
        raise ValueError('FRESH_REPLAY_REQUIRED')
    samples, tried, events, i = [], set(), set(), 0
    while i < len(replay.records):
        record = replay.records[i]
        if record['role'] == 'controller' or record['action'] == {'control': 13}:
            i += 1
            continue
        obs = record['observation']
        if obs['status'] != 4:
            raise ValueError('TRAINING_PLAN_WITHOUT_FAILURE')
        s = shape(obs, operators)
        pool = plans(len(s.current)); length = 3*len(s.current)+1
        tried.add(pool.index(s.current)); events.update(evidence(obs, operators))
        labels = [r['action'] for r in replay.records[i:i+length]]
        matches = [j for j in available(s, tried, events) if path(obs, operators, j) == labels]
        if len(matches) != 1:
            raise ValueError('UNREALIZED_OR_INCONSISTENT_TRAINING_PLAN')
        selected = matches[0]
        samples.append((frame(obs, operators, tried, events),
                        -1 if explore and not samples else selected,
                        torch.tensor([consistent(s.op, p, events) for p in pool], dtype=torch.float32)))
        tried.add(selected)
        i += length
    if not samples:
        raise ValueError('NO_REPLAYED_PLANS')
    return samples


def loss(model, examples):
    memory, losses = None, []
    for x, target, agreement in examples:
        logits, predicted, memory = model(x, memory)
        value = 0.2 * F.binary_cross_entropy_with_logits(predicted, agreement)
        if target >= 0:
            if not x.available[target]:
                raise ValueError('TEACHER_OUTSIDE_FILTER')
            value = value + F.cross_entropy(logits[None], torch.tensor([target]))
        losses.append(value)
    if not losses:
        raise ValueError('EMPTY_EPISODE')
    return torch.stack(losses).mean()
