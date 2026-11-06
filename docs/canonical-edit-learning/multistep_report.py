"""Audit and retain bounded multistep-study evidence, without rerunning solvers."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import shutil
import tarfile


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('run', type=Path)
    p.add_argument('destination', type=Path)
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
            if base not in path.parents or digest(path) != expected:
                raise ValueError('EVIDENCE_HASH_MISMATCH: '+name)
    report = json.loads((run/'report.json').read_text())
    if report['status'] != 'STUDY_COMPLETE' or len(report['models']) != 9:
        raise ValueError('INCOMPLETE_STUDY')
    combinations = {(row['mode'], row['seed']) for row in report['models']}
    if combinations != {(m, s) for m in ('persistent', 'reset', 'blind') for s in report['seeds']}:
        raise ValueError('MISSING_MATCHED_ARM')
    for row in report['models']:
        name = f'{row["mode"]}-{row["seed"]}'
        gradients = json.loads((run/(name+'-gradients.json')).read_text())
        if len(gradients) != report['updates'] or any(not math.isfinite(g['loss']) or
                not math.isfinite(g['norm']) or g['norm'] <= 0 for g in gradients):
            raise ValueError('GRADIENT_INVENTORY')
        if digest(run/(name+'.pt')) != row['checkpointHash']:
            raise ValueError('CHECKPOINT_HASH')
        for split, summary in row['results'].items():
            trials = [json.loads(path.read_text()) for path in sorted(run.glob(name+'-case-*.json'))]
            trials = [t for t in trials if t['split'] == split]
            if len(trials) != summary['tasks'] or sum(t['solved'] for t in trials) != summary['solved']:
                raise ValueError('TRIAL_DENOMINATOR_MISMATCH')
            for trial in trials:
                if trial['queriesIssued'] > 4 or trial['decisionsIssued'] > 256:
                    raise ValueError('BUDGET_MISMATCH')
                if trial['solved'] and not (trial['final']['closed'] and trial['final']['status'] == 5):
                    raise ValueError('FALSE_SUCCESS')
    checks = report['additionalRuntimeTests']
    for name in ('LocalFeedbackRepairTest', 'FeedbackRepairTest', 'RepairEnvironmentTest', 'RepairLearningTest'):
        log = (run/'base'/(name+'.log')).read_text()
        values = re.findall(r'passed: (\d+) checks|RESULT,'+name+r',(\d+)', log)
        if len(values) != 1:
            raise ValueError('TEST_INVENTORY: '+name)
        checks += int(next(v for v in values[0] if v))
    checks += int(re.search(r'Ran (\d+) tests', (run/'base/python-tests.log').read_text()).group(1))
    destination.mkdir(parents=True)
    names = ['report.json', 'input-hashes.json', 'output-hashes.json', 'commands.json',
             'proof-1.log', 'proof-2.log', 'contextual-proof.log', 'contextual-multistep-tests.log', 'tasks.json']
    for name in names:
        shutil.copyfile(run/name, destination/name)
    with tarfile.open(destination/'evidence.tar.gz', 'w:gz') as archive:
        for path in sorted(run.rglob('*')):
            if path.is_file() and path.suffix in ('.json', '.als', '.log', '.pt', '.gz'):
                archive.add(path, arcname=str(path.relative_to(run)))
        archive.add(__file__, arcname='curator/multistep_report.py')
    audit = dict(status='AUDIT_PASSED', inputs=len(inputs), outputs=len(outputs),
                 runtimeCheckExecutions=checks, newLeanDeclarations=15,
                 limitation='Finite model proofs, tests and synthetic experiment; not universal refinement or corpus repair',
                 producerManifestHash=digest(run/'output-hashes.json'), reporterHash=digest(Path(__file__)))
    (destination/'audit.json').write_text(json.dumps(audit, indent=2)+'\n')
    hashes = {path.name: digest(path) for path in sorted(destination.iterdir()) if path.is_file()}
    (destination/'hashes.json').write_text(json.dumps(hashes, indent=2)+'\n')
    print(json.dumps(audit, indent=2))


if __name__ == '__main__':
    main()
