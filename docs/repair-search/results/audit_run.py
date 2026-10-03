"""Post-run evidence audit; does not train, search, or select new repairs."""
import json
from pathlib import Path
import subprocess

from acgn_repair.experiment import sha, write_json
from acgn_repair.language_study import api, BASE_MODEL, BASE
from acgn_repair.search_study import ROOT, PROOF, tasks, worker, load, admit


folder = Path(__file__).resolve().parent
classes = folder / 'check-classes'
snapshot = json.loads((folder / 'source-snapshot-checkpointed.json').read_text())
original = json.loads((folder / 'source-snapshot.json').read_text())
assert snapshot['previousSnapshotHash'] == sha(folder / 'source-snapshot.json')
assert {p for p, h in original['files'].items() if snapshot['files'][p] != h} == {
    str(ROOT / 'scripts/train_repair_lora.py')}
changed = {p for p, h in snapshot['files'].items() if sha(p) != h}
assert changed == {str(ROOT / 'rl/acgn_repair/report_search.py'),
                   str(ROOT / 'rl/tests/test_search_study.py')}
selected = tasks()
assert selected == snapshot['tasks']
assert all(sha(ROOT / t['corpusSource']) == t['corpusHash'] for t in selected)
by_id = {t['id']: t for t in selected}
assert not {t['group'] for t in selected if t['split'] == 'train'} & {
    t['group'] for t in selected if t['split'] == 'evaluation'}
data = json.loads((folder / 'data/manifest.json').read_text())
training = {}
for mode in ('sft', 'ce'):
    path = folder / 'data' / (mode + '.jsonl')
    assert sha(path) == data['datasetHashes'][mode]
    rows = [json.loads(line) for line in path.read_text().splitlines()]
    assert all(by_id[r['id'].removesuffix('-ce')]['split'] == 'train' for r in rows)
    adapter = folder / (mode + '-adapter')
    manifest = json.loads((adapter / 'manifest.json').read_text())
    assert manifest['status'] == 'probe_complete'
    assert manifest['steps'] == len(rows) == manifest['selected_rows']
    assert set(manifest['trained_row_ids']) == {r['id'] for r in rows}
    assert manifest['dataset_sha256'] == sha(path)
    assert manifest['adapter_reload_max_abs_error'] == 0
    assert all(delta > 0 for delta in manifest['parameter_max_abs_delta'].values())
    assert all(sha(adapter / 'adapter' / p) == h for p, h in manifest['adapter_files'].items())
    steps = [json.loads(line) for line in (adapter / 'steps.jsonl').read_text().splitlines()]
    allocated = max(s['cuda_peak_allocated'] for s in steps)
    reserved = max(s['cuda_peak_reserved'] for s in steps)
    assert allocated < 13 * 2**30 and reserved < 13 * 2**30
    training[mode] = dict(steps=len(steps),peakAllocated=allocated,peakReserved=reserved)
tag = next(t for t in api('/api/tags')['models'] if t['name'] == BASE_MODEL)
assert tag['digest'] == data['model']['digest']
weight_hash = sha(BASE / 'model.safetensors')
assert weight_hash == 'd5ced71fee428687bca87ed1b62a1518e936e8698b180fbba35431ebd31e1a25'

checks = []
for mode in ('tar', 'base', 'sft', 'ce'):
    for result in json.loads((folder / mode / 'runs.json').read_text()):
        if not result['solved']:
            continue
        task = by_id[result['task']]
        body = (result['reported']['solution'][task['target']] if mode == 'tar' else
                next(a['validation']['body'] for a in result['attempts'] if a['status'] == 'SOLVED_WITHIN_PROFILE'))
        with worker(classes, folder / f'audit-{mode}-{task["id"]}.log') as w:
            root = load(w, task, budget=1)
            checked = w.request('propose', body=body, force=True)
            checks.append(dict(method=mode, task=task['id'], receipt=admit(checked, root, 'evaluation')))
for row in [json.loads(line) for line in (folder / 'data/sft.jsonl').read_text().splitlines()]:
    task = by_id[row['id']]
    body = json.loads(row['messages'][-1]['content'])['body']
    with worker(classes, folder / f'audit-training-{task["id"]}.log') as w:
        root = load(w, task, budget=1)
        assert body == root['teacher']
        checked = w.request('propose', body=body, force=True)
        checks.append(dict(method='training-target', task=task['id'], receipt=admit(checked, root, 'train', 'training')))
assert len(checks) == 21
assert not subprocess.check_output(['git', 'diff', '--name-only'], cwd=ROOT).strip()
write_json(folder / 'audit.json', dict(status='PASS_BOUNDED_EVIDENCE_AUDIT',
    sourceFiles=len(snapshot['files']), sourceExceptions={p:sha(p) for p in sorted(changed)},
    exceptionReason='Reporting-only generation diagnostics and their unit test',
    sourceTasks=len(selected), boundedRepairAndTargetRechecks=checks, training=training,
    baseDigest=tag['digest'], trainingWeightsHash=weight_hash, proofHash=sha(PROOF),
    trackedDiffEmpty=True, wholeApplicationRefinement='BLOCKED', auditScriptHash=sha(__file__)))
print('PASS: 24 task sources, 394 snapshot files (2 documented report/test changes), 21 fresh-source repair/target rechecks, both adapters and base provenance')
