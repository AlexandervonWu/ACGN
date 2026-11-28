"""Read the producer's full JSON action/block programs and independently recompute their ordered commitments."""
import hashlib
import json
import re


class SerializedNumber(float):
    """JSON-java already writes numbers through numberToString when it archives the diagnostic."""
    def __new__(cls, token):
        result = super().__new__(cls, token)
        result.token = token
        return result


def quote(value):
    escaped = json.dumps(value, ensure_ascii=False).replace('</', '<\\/')
    return re.sub(r'[\u0080-\u009f\u2000-\u20ff]', lambda m: '\\u%04x' % ord(m[0]), escaped)


def canonical(value):
    if isinstance(value, dict):
        keys = sorted(value, key=lambda k: k.encode('utf-16-be', errors='surrogatepass'))
        return '{' + ','.join(quote(k) + ':' + canonical(value[k]) for k in keys) + '}'
    if isinstance(value, list):
        return '[' + ','.join(map(canonical, value)) + ']'
    if isinstance(value, str):
        return quote(value)
    if isinstance(value, SerializedNumber):
        return value.token
    if value is None or type(value) in (bool, int):
        return json.dumps(value)
    raise ValueError('Unsupported numeric notation in the native program')


def check_programs(evidence, row):
    temporal = 'fastBlocks' in evidence or 'certifiedBlocks' in evidence
    plural = 'Blocks' if temporal else 'Actions'
    available = all(arm + plural in evidence for arm in ('fast', 'certified'))
    if not available:
        if any(k in row for k in ('sequenceKind','nativeSequencesEqual','fastSequenceSha256','certifiedSequenceSha256')):
            raise ValueError('Sequence commitment exposed without both native arrays')
        return
    expected_kind = 'TEMPORAL_BLOCK_EFFECTS' if temporal else 'FLAT_ACTIONS'
    if row.get('sequenceKind') != expected_kind:
        raise ValueError('Native sequence representation disagrees with original evidence')
    text = []
    programs = []
    for arm in ('fast','certified'):
        seq = evidence[arm + plural]
        if not isinstance(seq,list) or len(seq) != row.get(arm + ('BlockCount' if temporal else 'ActionCount')):
            raise ValueError('Invalid original native sequence length')
        program = [[block['component'], block['effect']] for block in seq] if temporal else seq
        program_text = canonical(program)
        actual = hashlib.sha256(program_text.encode('utf-8', errors='replace')).hexdigest()
        if actual != row.get(arm + 'SequenceSha256'):
            raise ValueError('Original ordered native program is not bound to its commitment')
        text.append(program_text)
        programs.append(program)
    equal = text[0] == text[1]
    if row.get('nativeSequencesEqual') is not equal:
        raise ValueError('Original native sequences disagree with published comparison')
    if temporal and row.get('orderedBlockEffectsEqual') is not equal:
        raise ValueError('Temporal native evidence disagrees with ordered block result')
    if row['status']=='MISMATCH':
        first = next((i for i,(left,right) in enumerate(zip(*programs)) if canonical(left) != canonical(right)),
                     min(map(len,programs)))
        if equal or evidence.get('firstDifference') != first:
            raise ValueError('Recorded first divergence does not match original ordered native programs')
