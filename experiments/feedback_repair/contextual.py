"""Causal graph memory and real, repeatedly checked repair episodes."""
import copy
from dataclasses import dataclass
from pathlib import Path
import time

import torch
from torch import nn
from torch.nn import functional as F

from .gnn_variants import VariantPolicy
from .local_runtime import execute, load, joint_loss, queries, snapshot_equal
from .policy import choose
from .replay import decision, ReplayRejected
from .run_gates import ROOT, sha
from .tables import encode
from .train_gates import worker

CONTRACT = 'contextual-feedback-repair-v1'


def phase(obs, query_budget=4):
    """The controller owns verification; the policy owns construction/recovery."""
    if obs['closed']:
        return 'TERMINAL'
    if obs['remaining'] <= 0:
        return 'DECISION_LIMIT'
    if obs['status'] in (6, 7):
        return 'INCONCLUSIVE'
    if queries(obs) >= query_budget:
        return 'QUERY_LIMIT'
    if not obs['history'] or (obs['status'] == 1 and obs['history'][-1][1] in (8, 9)):
        return 'VALIDATE'
    return 'PROPOSE'


class DecisionView:
    """One context update per public packet, not once per decoder head."""
    def __init__(self, owner, graph, hidden, query):
        self.owner, self.graph, self.hidden, self.query = owner, graph, hidden, query
        self.next_head = owner.encoder.next_head

    def encode(self, graph):
        if graph is not self.graph:
            raise ValueError('CONTEXT_GRAPH_MISMATCH')
        return self.hidden, self.query

    def logits(self, h, query, candidates, addresses):
        logits, vectors = self.owner.encoder.logits(h, query, candidates, addresses)
        forbidden = torch.tensor([c.fields.get('control') in (11, 12) for c in candidates],
                                 dtype=torch.bool, device=logits.device)
        return logits.masked_fill(forbidden, -torch.inf), vectors


class ContextualPolicy(nn.Module):
    def __init__(self, width=64, layers=2, variant='gin'):
        super().__init__()
        self.encoder = VariantPolicy(variant, width, layers)
        self.memory = nn.GRUCell(width, width)
        self.context = nn.Sequential(nn.Linear(2 * width, width), nn.GELU(), nn.LayerNorm(width))
        self.outcome = nn.Linear(width, 11)

    def step(self, graph, memory=None):
        hidden, query = self.encoder.encode(graph)
        if memory is None:
            memory = torch.zeros_like(query)
        memory = self.memory(query, memory)
        view = DecisionView(self, graph, hidden, self.context(torch.cat((query, memory))))
        return view, memory, self.outcome(memory)


class PublicUnarySearch:
    """Diagnostic enumerator. It receives no task metadata, oracle or gold path."""
    def __init__(self, operators):
        self.operators, self.pending, self.tried = operators, [], set()

    def __call__(self, obs):
        if self.pending:
            return self.pending.pop(0)
        if obs['draft'] or obs['actions']['holes']:
            return {'control': 10}
        nodes, ports = obs['current']['nodes'], obs['current']['ports']
        children = [r[1] for r in ports if r[0] == 0]
        names = ('U:NO', 'U:ONE', 'U:LONE', 'U:SOME')
        if (not nodes or self.operators[nodes[0][0]] not in names or len(children) != 1
                or self.operators[nodes[children[0]][0]] != 'SIG'):
            raise ValueError('PUBLIC_PROPOSER_SCOPE_UNSUPPORTED')
        self.tried.add(self.operators[nodes[0][0]])
        selected = next((n for n in names if n not in self.tried), None)
        if selected is None:
            return {'control': 13}
        self.tried.add(selected)
        self.pending = [{'control': 6, 'operator': self.operators.index(selected)},
                        {'control': 1, 'pointer': children[0]}, {'control': 8}]
        return {'control': 0, 'site': 0, 'family': 8}


def task_hash(task):
    return sha(ROOT / 'docs/rl-corpus-data' / task['path'])


def run_episode(task, classes, log, proposer=None, model=None, device='cpu', query_budget=4):
    if (proposer is None) == (model is None):
        raise ValueError('EXACTLY_ONE_POLICY_REQUIRED')
    if not 1 <= query_budget <= 4:
        raise ValueError('QUERY_BUDGET_INVALID')
    trial = {'contract': CONTRACT, 'id': task['id'], 'split': task['split'],
             'sourceHash': task_hash(task), 'queryBudget': query_budget, 'records': [],
             'solved': False, 'queriesIssued': 0, 'decisionsIssued': 0}
    memory, archive = None, {}
    start = time.monotonic()
    if model is not None:
        model.eval()
    try:
        with worker(classes, log) as process:
            obs = load(process, task, query_budget)
            operators = process.request('catalog')['operators']
            while True:
                stage = phase(obs, query_budget)
                if stage not in ('VALIDATE', 'PROPOSE'):
                    trial['end'] = stage
                    break
                if time.monotonic() - start > 120:
                    raise TimeoutError('EPISODE_DEADLINE')
                before = copy.deepcopy(obs)
                with torch.no_grad():
                    if model is not None:
                        graph = encode(obs, operators, archive).to(device)
                        view, memory, prediction = model.step(graph, memory)
                    if stage == 'VALIDATE':
                        action = {'control': 11}
                    elif model is not None:
                        action, _, _ = choose(view, graph, obs, queries(obs), query_limit=query_budget)
                    else:
                        action = proposer(copy.deepcopy(obs))
                if stage == 'PROPOSE' and action['control'] in (11, 12):
                    raise ValueError('VERIFICATION_IS_CONTROLLER_OWNED')
                decision(obs, action)
                archive[obs['revision']] = before
                trial['decisionsIssued'] += 1
                trial['queriesIssued'] += action['control'] == 11
                obs = execute(process, obs, action)
                trial['records'].append({'observation': before, 'action': dict(action),
                                         'role': 'controller' if stage == 'VALIDATE' else 'policy',
                                         'after': copy.deepcopy(obs)})
            trial['final'] = copy.deepcopy(obs)
            trial['solved'] = obs['closed'] and obs['status'] == 5
    except (RuntimeError, ValueError, KeyError, TimeoutError) as error:
        trial.update(error=type(error).__name__ + ': ' + str(error), end='ERROR')
    trial['seconds'] = time.monotonic() - start
    return trial


@dataclass(frozen=True)
class ReplayedEpisode:
    records: list
    final: dict


def replay_for_training(task, trial, classes, log):
    """Only fresh real replay, not a producer-supplied accepted flag, admits data."""
    if task['split'] != 'train' or trial['split'] != 'train':
        raise ValueError('TRAIN_ONLY')
    if trial['contract'] != CONTRACT or trial['id'] != task['id'] or trial['sourceHash'] != task_hash(task):
        raise ReplayRejected('EPISODE_ORIGIN_MISMATCH')
    if 'error' in trial or not trial['records']:
        raise ReplayRejected('INCOMPLETE_EPISODE')
    budget = trial['queryBudget']
    if not 1 <= budget <= 4:
        raise ReplayRejected('QUERY_BUDGET_INVALID')
    with worker(classes, log) as process:
        obs = load(process, task, budget)
        for record in trial['records']:
            snapshot_equal(record['observation'], obs)
            stage = phase(obs, budget)
            if stage not in ('VALIDATE', 'PROPOSE'):
                raise ReplayRejected('REPLAY_AFTER_END')
            if stage == 'VALIDATE':
                if record['role'] != 'controller' or record['action'] != {'control': 11}:
                    raise ReplayRejected('MISSING_REAL_VERIFICATION')
            elif record['role'] != 'policy' or record['action']['control'] in (11, 12):
                raise ReplayRejected('WRONG_POLICY_ROLE')
            obs = execute(process, obs, record['action'])
            snapshot_equal(record['after'], obs)
        snapshot_equal(trial['final'], obs)
        if phase(obs, budget) != trial['end'] or trial['end'] in ('VALIDATE', 'PROPOSE'):
            raise ReplayRejected('TRUNCATED_EPISODE')
        if trial['solved'] != (obs['closed'] and obs['status'] == 5):
            raise ReplayRejected('FALSE_EPISODE_SUCCESS')
        if (trial['decisionsIssued'] != len(trial['records'])
                or trial['queriesIssued'] != queries(obs)):
            raise ReplayRejected('EPISODE_ACCOUNTING')
    return ReplayedEpisode(copy.deepcopy(trial['records']), copy.deepcopy(obs))


def sequence_loss(model, episode, operators, device='cpu', outcome_weight=0.2):
    """Imitate public search and predict actual checks; no outcome is an input."""
    if not isinstance(episode, ReplayedEpisode):
        raise ValueError('REPLAY_REQUIRED')
    memory, archive, actions, outcomes = None, {}, [], []
    for record in episode.records:
        obs = record['observation']
        graph = encode(obs, operators, archive).to(device)
        view, memory, prediction = model.step(graph, memory)
        if record['role'] == 'policy':
            actions.append(joint_loss(view, graph, obs, [record['action']]))
        else:
            target = torch.tensor([record['after']['status']], device=device)
            outcomes.append(F.cross_entropy(prediction.unsqueeze(0), target))
        archive[obs['revision']] = obs
    if not outcomes:
        raise ValueError('NO_REAL_CHECK_LABEL')
    outcome = torch.stack(outcomes).mean()
    action = torch.stack(actions).mean() if actions else outcome * 0
    return action + outcome_weight * outcome
