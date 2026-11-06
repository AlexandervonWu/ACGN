"""Local-repair controller/replay. Private expert output never enters policy input."""
import copy
import json
import os
from pathlib import Path
import subprocess

import torch
from .run_gates import ROOT, write, check_tables
from .train_gates import worker
from .replay import decision, ReplayRejected
from .policy import options, fields

CONTRACT = 'local-feedback-repair-v1'


def load(process, task, query_budget=4):
    return process.request('load', path=str(ROOT/'docs/rl-corpus-data'/task['path']),
                           target=task['target'], oracle=task['oracle'], command=task['command'],
                           budget=256, queryBudget=query_budget, contract=CONTRACT)['observation']


def queries(observation):
    return sum(row[1] in (11, 12) for row in observation['history'])


def snapshot_equal(expected, actual):
    if expected != actual:
        raise ReplayRejected('REPLAY_DIVERGED')


def execute(process, observation, label):
    before = observation
    observation = process.request('decide', decision=decision(observation, label))['observation']
    check_tables(observation)
    if observation['turn'] != before['turn'] + 1 or observation['remaining'] != before['remaining'] - 1:
        raise ReplayRejected('DECISION_ACCOUNTING')
    return observation


def replay_local(classes, task, path, prefix, labels, expected=None, kind='continuation', query_budget=4):
    """Fresh real replay; rejected roll-in states are allowed, rejected labels are not."""
    archive, records = {}, []
    with worker(classes, path) as process:
        obs = load(process, task, query_budget)
        for action in prefix:
            archive[obs['revision']] = copy.deepcopy(obs)
            obs = execute(process, obs, action)
        if expected is not None:
            snapshot_equal(expected, obs)
        start = copy.deepcopy(obs)
        for label in labels:
            if obs['closed'] or obs['remaining'] <= 0:
                raise ReplayRejected('LABEL_AFTER_TERMINATION')
            if label['control'] in (11, 12) and queries(obs) >= query_budget:
                raise ReplayRejected('QUERY_BUDGET_EXCEEDED')
            history_revisions = {r[0] for r in obs['history']} - {0, obs['revision']}
            record = {'observation': copy.deepcopy(obs), 'alternatives': [label], 'kind': kind,
                      'archive': {str(r): archive[r] for r in history_revisions}}
            archive[obs['revision']] = copy.deepcopy(obs)
            obs = execute(process, obs, label)
            if obs['status'] in (2, 3, 7, 8, 9, 10):
                raise ReplayRejected('LABEL_REJECTED_OR_INCONCLUSIVE')
            record['outcome'] = obs['status']; records.append(record)
        if not records:
            raise ReplayRejected('NO_LABEL')
        if kind == 'recovery':
            if labels != [{'control': 10}] or obs['draft'] or obs['current'] != start['current']:
                raise ReplayRejected('RECOVERY_POSTCONDITION')
        elif kind != 'continuation' or not obs['closed'] or obs['status'] != 5 or labels[-1]['control'] not in (11, 12):
            raise ReplayRejected('NO_BOUND_SEMANTIC_ACCEPTANCE')
    return {'decisions': records, 'final': obs, 'prefix': prefix, 'kind': kind}


def collect_label(classes, task, directory, name, prefix=None, snapshot=None, recovery=False, query_budget=4):
    if task['split'] != 'train':
        raise ValueError('TRAIN_ONLY')
    request = {**task, 'path': str(ROOT/'docs/rl-corpus-data'/task['path']), 'budget': 256,
               'queryBudget': query_budget, 'prefix': prefix or [], 'recoveryOnly': recovery}
    if snapshot is not None:
        request['snapshot'] = snapshot
    request_path = directory/(name+'-request.json')
    write(request_path, request)
    record = {'id': task['id'], 'kind': 'recovery' if recovery else 'continuation'}
    try:
        with (directory/(name+'-expert.log')).open('w') as log:
            result = subprocess.run(['java', '-XX:-UsePerfData', '-ea', '-Xmx2g', '-Dfile.encoding=UTF-8', '-cp',
                                     str(classes)+os.pathsep+str(ROOT/'lib/*'),
                                     'is.fivefivefive.ACGN.repair.LocalFeedbackTeacherMain', str(request_path)],
                                    cwd=ROOT, stdout=subprocess.PIPE, stderr=log, text=True, timeout=30, check=True)
        proposal = json.loads(result.stdout)
        write(directory/(name+'-proposal.json'), proposal)
        if proposal['status'] not in ('VALIDATED_LOCAL_CONTINUATION', 'CHECKED_RECOVERY'):
            raise ReplayRejected(proposal.get('reason', 'NO_ADMITTED_LABEL'))
        trajectory = replay_local(classes, task, directory/(name+'-replay.log'), request['prefix'],
                                  proposal['labels'], expected=proposal['snapshot'], kind=record['kind'],
                                  query_budget=query_budget)
        if snapshot is not None:
            snapshot_equal(snapshot, proposal['snapshot'])
        write(directory/(name+'-trajectory.json'), trajectory)
        record.update(status='REPLAY_ADMITTED', decisions=len(trajectory['decisions']),
                      edits=proposal.get('edits', []), trajectory=name+'-trajectory.json')
        return record, trajectory['decisions']
    except (RuntimeError, ValueError, KeyError, subprocess.SubprocessError) as error:
        record.update(status='NOT_ADMITTED', error=type(error).__name__+': '+str(error))
        return record, []


def joint_loss(model, graph, observation, alternatives, query_budget=4):
    """Negative log probability of a set of complete, deduplicated action frames."""
    unique = {json.dumps(action, sort_keys=True): action for action in alternatives}
    if not unique:
        raise ValueError('EMPTY_LABEL_SET')
    h, initial = model.encode(graph)
    probabilities = []
    for label in unique.values():
        decision(observation, label)
        query, partial, scores = initial, {}, []
        heads = ['control']
        for field in heads:
            candidates = options(observation, field, partial, queries(observation), query_budget)
            matches = [i for i, c in enumerate(candidates) if all(label.get(k) == v for k, v in c.fields.items())]
            if len(matches) != 1:
                raise ValueError('LABEL_OUTSIDE_PUBLIC_MASK')
            logits, vectors = model.logits(h, query, candidates, graph.addresses)
            index = matches[0]
            scores.append(torch.log_softmax(logits, 0)[index])
            partial.update(candidates[index].fields)
            query = model.next_head(vectors[index], query)
            if field == 'control':
                heads.extend(fields(partial['control']))
        probabilities.append(torch.stack(scores).sum())
    return -torch.logsumexp(torch.stack(probabilities), 0)
