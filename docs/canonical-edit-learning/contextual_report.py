#!/usr/bin/env python3
"""Audit and retain the bounded contextual pilot, including its small checkpoint."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import tarfile

ROOT = Path(__file__).resolve().parents[2]


def read(path):
    return json.loads(path.read_text())


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for part in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(part)
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('run', type=Path)
    parser.add_argument('destination', type=Path)
    args = parser.parse_args()
    run, out = args.run.resolve(), args.destination.resolve()
    if out.exists(): parser.error('Fresh destination required')
    report = read(run/'report.json')
    if report['status'] != 'PROTOTYPE_CHECKED': raise ValueError('INCOMPLETE_PILOT')
    inputs = read(run/'input-hashes.json')
    outputs = read(run/'output-hashes.json')
    for root, hashes in ((ROOT, inputs), (run, outputs)):
        for name, digest in hashes.items():
            if sha(root/name) != digest: raise ValueError('CHANGED_EVIDENCE: '+name)
    if sha(run/'policy.pt') != report['checkpointHash']: raise ValueError('CHECKPOINT_CHANGED')
    gradients = read(run/'gradients.json')
    if len(gradients) != report['updates'] or any(r['gradientNorm'] <= 0 for r in gradients):
        raise ValueError('GRADIENT_INVENTORY')
    rows = []
    for i in range(report['tasks']):
        demo, learned = read(run/f'demo-{i}.json'), read(run/f'learned-{i}.json')
        for trial in (demo, learned):
            if trial['queriesIssued'] > 4 or trial['decisionsIssued'] > 256:
                raise ValueError('EPISODE_BUDGET')
            if trial['solved'] and ('error' in trial or not trial['final']['closed'] or trial['final']['status'] != 5):
                raise ValueError('UNSUPPORTED_SUCCESS')
        rows.append({'fixture': i, 'demoSolved': demo['solved'], 'learnedSolved': learned['solved'],
                     'learnedCheckStatuses': [r['after']['status'] for r in learned['records'] if r['role']=='controller'],
                     'learnedQueries': learned['queriesIssued'], 'learnedEnd': learned['end']})
    checks = 0
    for name in ('LocalFeedbackRepairTest', 'FeedbackRepairTest', 'RepairEnvironmentTest', 'RepairLearningTest'):
        checks += int(re.search(rf'(?:{name} passed: |RESULT,{name},)(\d+)',
                                (run/'base'/(name+'.log')).read_text()).group(1))
    checks += int(re.search(r'Ran (\d+) tests', (run/'base/python-tests.log').read_text()).group(1))
    checks += int(re.search(r'Ran (\d+) tests', (run/'contextual-tests.log').read_text()).group(1))
    audit = {'status': 'AUDIT_PASSED', 'inputs': len(inputs), 'outputs': len(outputs),
             'runtimeCheckExecutions': checks, 'newLeanDeclarations': report['proofDeclarations'],
             'fixtureOutcomes': rows, 'reporterHash': sha(Path(__file__)),
             'scope': 'Finite prototype evidence, not generalization or universal implementation refinement'}
    out.mkdir(parents=True)
    for name in ('report.json', 'commands.json', 'input-hashes.json', 'output-hashes.json',
                 'contextual-tests.log', 'proof-1.log', 'proof-2.log', 'gradients.json'):
        shutil.copy2(run/name, out/name)
    (out/'audit.json').write_text(json.dumps(audit, indent=2)+'\n')
    proof_sources = read(run/'base/proofs/report.json')['source_sha256']
    archive_inputs = {**inputs, **proof_sources}
    with tarfile.open(out/'evidence.tar.gz', 'w:gz') as archive:
        for path in sorted(run.rglob('*')):
            if path.is_file() and path.suffix in ('.json', '.log', '.als', '.args', '.pt'):
                archive.add(path, arcname=str(Path('run')/path.relative_to(run)), recursive=False)
        for name, digest in sorted(archive_inputs.items()):
            if sha(ROOT/name) != digest: raise ValueError('PROOF_SOURCE_CHANGED: '+name)
            if Path(name).suffix != '.jar':
                archive.add(ROOT/name, arcname=str(Path('inputs')/name), recursive=False)
        archive.add(Path(__file__), arcname='contextual_report.py', recursive=False)
    (out/'hashes.json').write_text(json.dumps({p.name: sha(p) for p in sorted(out.iterdir()) if p.is_file()}, indent=2)+'\n')
    print(json.dumps(audit, indent=2))


if __name__ == '__main__':
    main()
