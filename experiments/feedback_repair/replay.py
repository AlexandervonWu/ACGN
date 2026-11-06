"""Replay offline semantic labels through the same causal public worker interface.

This is neither a policy nor a target/path generator. Labels are separate from
observation keys and cannot supply their own revision or a source-text payload.
"""
from copy import deepcopy

CONTROLS = ('BEGIN', 'COPY', 'SYMBOL', 'VARIABLE', 'DRAFT_VARIABLE', 'CONSTANT',
            'OPERATOR', 'QUANTIFIER', 'COMMIT', 'DELETE', 'ABORT_DRAFT',
            'VALIDATE', 'STOP', 'ABSTAIN', 'DECLARATION', 'FEEDBACK_SYMBOL')
FIELDS = {
    'BEGIN': {'site', 'family'}, 'DELETE': {'site', 'family', 'pointer'},
    'COPY': {'pointer'}, 'SYMBOL': {'pointer'}, 'VARIABLE': {'pointer'},
    'DRAFT_VARIABLE': {'pointer'}, 'CONSTANT': {'operator', 'value'},
    'FEEDBACK_SYMBOL': {'pointer'},
    'OPERATOR': {'operator'},
    'QUANTIFIER': {'operator', 'count', 'disjoint', 'cardinality'},
    'DECLARATION': {'count', 'disjoint', 'cardinality'},
    **{name: set() for name in ('COMMIT', 'ABORT_DRAFT', 'VALIDATE', 'STOP', 'ABSTAIN')},
}
STATUS_SOLVED = 5
BAD_STATUSES = {2, 3, 7, 8, 9, 10}


class ReplayRejected(ValueError):
    """A teacher is not an executable admitted example; keep it in coverage."""


def decision(observation, label):
    """Bind a single label to the current public head; no hidden state required."""
    if type(label) is not dict or any(type(v) is not int or not -(2**31) <= v < 2**31
                                     for v in label.values()):
        raise ReplayRejected('Action values must be exact signed 32-bit integers')
    code = label.get('control', -1)
    if not 0 <= code < len(CONTROLS):
        raise ReplayRejected('Unknown control')
    name = CONTROLS[code]
    if set(label) != FIELDS[name] | {'control'}:
        raise ReplayRejected('Missing/extra semantic arguments, source text, or stale revision')
    heads = observation['actions']
    if [code] not in heads['controls']:
        raise ReplayRejected('Control is unavailable')
    if name == 'BEGIN' and [label['family'], label['site']] not in heads['sites']:
        raise ReplayRejected('Site/family is unavailable')
    if name == 'DELETE' and [label['family'], label['site'], label['pointer']] not in heads['deletions']:
        raise ReplayRejected('Deletion tuple is unavailable')
    tables = {'COPY': 'copies', 'SYMBOL': 'symbols', 'VARIABLE': 'variables',
              'DRAFT_VARIABLE': 'draftVariables', 'FEEDBACK_SYMBOL': 'feedbackSymbols',
              'OPERATOR': 'operators', 'QUANTIFIER': 'quantifiers'}
    if name in tables:
        pointer = label['operator' if name in ('OPERATOR', 'QUANTIFIER') else 'pointer']
        if [pointer] not in heads[tables[name]]:
            raise ReplayRejected('Operand/operator is unavailable')
    if name == 'CONSTANT' and not any(kind == label['operator'] and lo <= label['value'] <= hi
                                      for kind, lo, hi in heads['constants']):
        raise ReplayRejected('Constant choice is unavailable')
    if name in ('QUANTIFIER', 'DECLARATION'):
        for field, table in (('count', 'counts'), ('disjoint', 'disjointness'), ('cardinality', 'cardinalities')):
            if not any(lo <= label[field] <= hi for lo, hi in heads[table]):
                raise ReplayRejected('Quantifier argument is unavailable')
    return {**label, 'revision': observation['revision'], 'turn': observation['turn']}


def replay(worker, initial, labels):
    """Returns only pre-action input keys, labels and controller outcomes.

    ``labels`` may be an online generator; it is deliberately consumed one at a
    time. The next observation is obtained exclusively from the actual worker.
    """
    observation = deepcopy(initial)
    if observation['history'] or observation['feedback']['worlds'] or observation['turn'] != 0:
        raise ReplayRejected('Replay must start before feedback/actions')
    records = []
    for label in labels:
        if observation['closed'] or observation['remaining'] <= 0:
            raise ReplayRejected('Teacher continues after terminal state or budget')
        action = decision(observation, label)
        key = deepcopy(observation)
        reply = worker.request('decide', decision=action)
        observation = reply['observation']
        if observation['turn'] != key['turn'] + 1 or observation['remaining'] != key['remaining'] - 1:
            raise ReplayRejected('Executor failed decision/fuel accounting')
        if observation['status'] in BAD_STATUSES:
            raise ReplayRejected(f'Executor rejected/inconclusive at decision {key["turn"]}')
        records.append({'observation': key, 'action': deepcopy(label),
                        'outcome': observation['status']})
    if not records or records[-1]['action']['control'] not in (CONTROLS.index('STOP'), CONTROLS.index('VALIDATE')):
        raise ReplayRejected('Teacher did not explicitly validate its final candidate')
    if observation['status'] != STATUS_SOLVED or not observation['closed']:
        raise ReplayRejected('No bounded-valid final repair')
    return {'schema': 'causal-feedback-replay-v1', 'decisions': records,
            'finalObservation': deepcopy(observation)}
