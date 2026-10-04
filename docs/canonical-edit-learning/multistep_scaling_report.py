"""Audit and retain the scaled multistep study without re-running experiments."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import re
import shutil
import tarfile


def sha(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('run', type=Path); p.add_argument('destination', type=Path)
    args = p.parse_args()
    root = Path(__file__).resolve().parents[2]
    run, destination = args.run.resolve(), args.destination.resolve()
    if destination.exists():
        p.error('Fresh destination required')
    inputs = json.loads((run/'input-hashes.json').read_text())
    outputs = json.loads((run/'output-hashes.json').read_text())
    for base, records in ((root, inputs), (run, outputs)):
        for name, expected in records.items():
            path = (base/name).resolve()
            if base not in path.parents or sha(path) != expected:
                raise ValueError('HASH_MISMATCH: '+name)
    r = json.loads((run/'report.json').read_text())
    if (r['status'] != 'STUDY_COMPLETE' or len(r['screening']) != 2
            or len(r['evaluations']) != 9 or len(r['baselines']) != 7):
        raise ValueError('INCOMPLETE_STUDY')
    selected = min(range(2), key=lambda i: (-r['screening'][i]['validation']['solved'], r['screening'][i]['parameters'], i))
    lock = json.loads((run/'locked-selection.json').read_text())
    if lock != r['selection'] or selected != lock['selected'] or lock['testUsed']:
        raise ValueError('SELECTION_MISMATCH')
    fits = [json.loads(path.read_text()) for path in sorted(run.glob('*-fit.json'))]
    if len(fits) != 4:
        raise ValueError('FIT_COUNT')
    for fit in fits:
        gradients = json.loads((run/(fit['name']+'-gradients.json')).read_text())
        exposures = Counter(g['episode'] for g in gradients)
        if len(exposures) != 144 or set(exposures.values()) != {16} or len(gradients) != 2304:
            raise ValueError('TRAINING_EXPOSURE')
        if any(not math.isfinite(g['loss']) or not math.isfinite(g['norm']) or g['norm'] <= 0 for g in gradients):
            raise ValueError('GRADIENT_FAILURE')
        if sha(run/(fit['name']+'.pt')) != fit['checkpointHash']:
            raise ValueError('CHECKPOINT_HASH')
    trajectories = {}
    for entry in r['evaluations'] + r['baselines']:
        name = f'{entry["mode"]}-{entry["seed"]}'
        trials = [json.loads(path.read_text()) for path in sorted(run.glob(name+'-case-*.json'))]
        if Counter(t['split'] for t in trials) != Counter(test=32, arity4=32):
            raise ValueError('HELDOUT_INVENTORY')
        trajectories[name] = {t['id']: [a['plan'] for a in t['attempts']] for t in trials}
        if len(trajectories[name]) != 64:
            raise ValueError('DUPLICATE_TASK')
        for split, summary in entry['results'].items():
            group = [t for t in trials if t['split'] == split]
            if len(group) != summary['tasks'] or sum(t['solved'] for t in group) != summary['solved']:
                raise ValueError('EVALUATION_DENOMINATOR')
            inconsistent = sum(not a['consistent'] for t in group for a in t['attempts'])
            if inconsistent != summary['inconsistentProposals']:
                raise ValueError('CONSISTENCY_COUNT')
            if entry['mode'] in ('model', 'reset', 'search', 'filtered_random') and inconsistent:
                raise ValueError('EVIDENCE_FILTER_VIOLATION')
        for trial in trials:
            if trial['queriesIssued'] > 4 or trial['decisionsIssued'] > 256:
                raise ValueError('BUDGET')
            if trial['solved'] and not (trial['final']['closed'] and trial['final']['status'] == 5):
                raise ValueError('FALSE_SUCCESS')
    demos = [json.loads(path.read_text()) for path in sorted(run.glob('case-*-demo.json'))]
    if len(demos) != 144 or r['admittedEpisodes'] != 144:
        raise ValueError('TRAINING_DENOMINATOR')
    if any(not a['consistent'] for t in demos for a in t['attempts']):
        raise ValueError('TRAINING_EVIDENCE_FILTER_VIOLATION')
    comparisons = []
    for seed in (17, 29, 43):
        primary = trajectories[f'model-{seed}']
        for control in (f'reset-{seed}', 'search-17'):
            other = trajectories[control]
            if primary.keys() != other.keys():
                raise ValueError('PAIRED_TASK_MISMATCH')
            comparisons.append(dict(seed=seed, control=control, tasks=len(primary),
                                    identicalPlanSequences=sum(primary[k] == other[k] for k in primary)))
    coverage = json.loads((run/'natural-coverage.json').read_text())
    if len(coverage) != 104 or dict(Counter(x['status'] for x in coverage)) != r['naturalCoverage']:
        raise ValueError('COVERAGE_COUNT')
    checks = r['additionalRuntimeTests']
    for name in ('LocalFeedbackRepairTest', 'FeedbackRepairTest', 'RepairEnvironmentTest', 'RepairLearningTest'):
        values = re.findall(r'passed: (\d+) checks|RESULT,'+name+r',(\d+)', (run/'base'/(name+'.log')).read_text())
        if len(values) != 1:
            raise ValueError('TEST_COUNT')
        checks += int(next(v for v in values[0] if v))
    checks += int(re.search(r'Ran (\d+) tests', (run/'base/python-tests.log').read_text()).group(1))
    destination.mkdir(parents=True)
    for name in ('report.json', 'input-hashes.json', 'output-hashes.json', 'commands.json', 'tasks.json',
                 'natural-coverage.json', 'locked-selection.json', 'proof-1.log', 'proof-2.log', 'multistep-tests.log'):
        shutil.copyfile(run/name, destination/name)
    with tarfile.open(destination/'evidence.tar.gz', 'w:gz') as archive:
        for path in sorted(run.rglob('*')):
            if path.is_file() and path.suffix in ('.json', '.als', '.log', '.pt', '.gz'):
                archive.add(path, arcname=str(path.relative_to(run)))
        archive.add(__file__, arcname='curator/multistep_scaling_report.py')
    audit = dict(status='AUDIT_PASSED', inputs=len(inputs), outputs=len(outputs), runtimeCheckExecutions=checks,
                 newLeanDeclarations=15, fits=4, totalUpdates=9216, naturalCoverageTasks=104,
                 trajectoryComparisons=comparisons,
                 manifestHash=sha(run/'output-hashes.json'), curatorHash=sha(Path(__file__)),
                 limitation='Finite models/tests and synthetic study; no universal refinement or natural-corpus repair claim')
    (destination/'audit.json').write_text(json.dumps(audit, indent=2)+'\n')
    (destination/'hashes.json').write_text(json.dumps({p.name: sha(p) for p in sorted(destination.iterdir()) if p.is_file()}, indent=2)+'\n')
    print(json.dumps(audit, indent=2))


if __name__ == '__main__':
    main()
