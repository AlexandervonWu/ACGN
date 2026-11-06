#!/usr/bin/env python3
"""Audit and curate a completed local-feedback scaling study without retraining."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys
import tarfile

ROOT = Path(__file__).resolve().parents[2]


def read(path):
    return json.loads(path.read_text())


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''):
            digest.update(block)
    return digest.hexdigest()


def verify(root, hashes):
    for name, digest in hashes.items():
        if sha(root/name) != digest:
            raise ValueError('Changed evidence: '+str(root/name))


def audit_trials(path, stats, tasks):
    rows = read(path)
    if [r['id'] for r in rows] != [t['id'] for t in tasks] or stats['tasks'] != len(tasks):
        raise ValueError('DENOMINATOR_MISMATCH')
    if stats['repairs'] != sum(r['solved'] for r in rows) or stats['errors'] != sum('error' in r for r in rows):
        raise ValueError('OUTCOME_MISMATCH')
    for row in rows:
        if row['queriesIssued'] > 4 or row['decisionsIssued'] > 256:
            raise ValueError('BUDGET_VIOLATION')
        if len(row['actions']) > row['decisionsIssued']:
            raise ValueError('ACTION_ACCOUNTING')
        if row['solved'] and ('error' in row or row.get('status') != 5):
            raise ValueError('UNSUPPORTED_SUCCESS')
    return rows


def behavior(rows):
    supported = [r for r in rows if 'error' not in r]
    return {'executed': len(supported),
            'noCommittedEdit': sum(r.get('committed') == 0 for r in supported),
            'counterexampleStop': sum(bool(r['actions']) and r['actions'][-1]['action']['control'] == 12
                                      and r.get('status') == 4 for r in supported),
            'usedFullQueryBudget': sum(r['queriesIssued'] == 4 for r in supported),
            'decisionExhausted': sum(r['decisionsIssued'] == 256 for r in supported),
            'issuedQueries': dict(Counter(r['queriesIssued'] for r in supported))}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('study', type=Path)
    p.add_argument('destination', type=Path)
    p.add_argument('markdown', type=Path)
    args = p.parse_args()
    study, out = args.study.resolve(), args.destination.resolve()
    if out.exists():
        p.error('Fresh evidence destination required')
    report = read(study/'report.json')
    if report['status'] != 'COMPLETE' or report['schema'] != 'local-feedback-scaling-v1':
        raise ValueError('INCOMPLETE_STUDY')
    dataset = Path(report['dataset'])
    data = read(dataset/'report.json')
    pre = Path(data['preflight'])
    for root in (pre, dataset, study):
        verify(root, read(root/'output-hashes.json'))
    verify(ROOT, read(study/'input-hashes.json'))
    if sha(dataset/'output-hashes.json') != report['datasetHash'] or sha(pre/'output-hashes.json') != data['preflightHash']:
        raise ValueError('PARENT_MANIFEST_MISMATCH')
    if sha(study/'locked-selection.json') != report['selectionHash']:
        raise ValueError('SELECTION_LOCK_MISMATCH')
    sys.path.insert(0, str(ROOT))
    import torch
    from experiments.feedback_repair.gnn_variants import make_policy
    from experiments.feedback_repair.train_scaled import select_config
    from experiments.feedback_repair.train_local_scaled import CONFIGS
    torch.set_num_threads(2)
    tasks = read(dataset/'tasks.json')['tasks']
    teacher_errors = Counter(r.get('error', r['status']) for r in read(dataset/'teachers/coverage.json')
                             if r['status'] != 'REPLAY_ADMITTED')
    previous = ROOT/'docs/canonical-edit-learning/results/feedback_scaling_20261003'
    old_tasks = read(previous/'dataset/tasks.json')['tasks']
    identity = lambda t: (t['id'], t['split'], t['group'], t.get('sourceHash'))
    same_tasks = [identity(t) for t in tasks] == [identity(t) for t in old_tasks]
    old_report = read(previous/'study/report.json')
    validation = [t for t in tasks if t['split'] == 'validation']
    testing = [t for t in tasks if t['split'] == 'evaluation']
    rollins = read(study/'rollin-tasks.json')
    if any(t['split'] != 'train' for t in rollins):
        raise ValueError('HELDOUT_ROLLIN')
    if [r['config'] for r in report['screening']] != list(CONFIGS):
        raise ValueError('CONFIGURATION_MISMATCH')
    best = select_config(report['screening'])
    if best['config'] != report['selection']['config']:
        raise ValueError('VALIDATION_SELECTION_MISMATCH')
    if sha(study/best['directory']/'policy-2.pt') != report['selection']['seed17CheckpointHash']:
        raise ValueError('LOCKED_CHECKPOINT_MISMATCH')
    behaviors = {}
    for record in report['screening']:
        rows = audit_trials(study/record['directory']/'validation/rollouts.json', record['validation'], validation)
        behaviors[record['directory']+'/validation'] = behavior(rows)
    if [r['seed'] for r in report['testing']] != [17, 29, 43]:
        raise ValueError('TEST_SEEDS_MISMATCH')
    for record in report['testing']:
        directory = f'{best["config"]["name"]}-{record["seed"]}'
        rows = audit_trials(study/directory/'evaluation/rollouts.json', record, testing)
        behaviors[directory+'/evaluation'] = behavior(rows)
    if {(r['mode'], r['seed']) for r in report['controls']} != {(m, s) for m in ('noop', 'uniform') for s in (17, 29, 43)}:
        raise ValueError('CONTROLS_MISSING')
    for record in report['controls']:
        audit_trials(study/f'{record["mode"]}-{record["seed"]}'/'rollouts.json', record, testing)
    checkpoints, admissions, decision_kinds = [], Counter(), Counter()
    fits = report['screening']+report['replicateTraining']
    if len(fits) != 6:
        raise ValueError('TRAINING_RUNS_MISSING')
    for fit in fits:
        directory = study/f'{fit["config"]["name"]}-{fit["seed"]}'
        if fit['updates'] != 5000 or fit['finiteNonzeroGradientUpdates'] != 5000:
            raise ValueError('INCOMPLETE_FINITE_TRAINING')
        for round_record in fit['rounds']:
            rn = round_record['round']
            audit_trials(directory/f'rollin-{rn}/rollouts.json', round_record['rollin'], rollins)
            for row in read(directory/f'aggregation-{rn}/coverage.json'):
                admissions[row['status']] += 1
                if row['status'] == 'REPLAY_ADMITTED':
                    record = read(directory/f'aggregation-{rn}'/row['trajectory'])
                    if record['kind'] == 'continuation' and (not record['final']['closed'] or record['final']['status'] != 5):
                        raise ValueError('UNACCEPTED_CONTINUATION')
                    if record['kind'] == 'recovery' and (len(record['decisions']) != 1 or record['decisions'][0]['alternatives'] != [{'control': 10}]):
                        raise ValueError('RECOVERY_MISMATCH')
                    decision_kinds.update(item['kind'] for item in record['decisions'])
        path = directory/'policy-2.pt'
        checkpoint = torch.load(path, map_location='cpu', weights_only=True)
        if checkpoint['config'] != fit['config'] or checkpoint['seed'] != fit['seed'] or checkpoint['contract'] != report['contract']:
            raise ValueError('CHECKPOINT_METADATA_MISMATCH')
        model = make_policy(fit['config']['variant'], fit['config']['width'], fit['config']['layers'])
        model.load_state_dict(checkpoint['state_dict'], strict=True)
        if any(not torch.isfinite(t).all() for t in model.state_dict().values()):
            raise ValueError('NONFINITE_CHECKPOINT')
        if sum(p.numel() for p in model.parameters()) != fit['parameters']:
            raise ValueError('PARAMETER_COUNT_MISMATCH')
        checkpoints.append({'path': str(path.relative_to(study)), 'sha256': sha(path), 'status': 'STRICT_LOAD_FINITE'})
    proof = read(pre/'proofs/report.json')
    proofs = proof['general_theorems']+proof['concrete_model_checks']
    proofs += sum(len(re.findall(r"^'(LocalRepairArchive|FeedbackScaling)\.", (pre/name).read_text(), re.M))
                  for name in ('archive-proof.log', 'scaling-proof.log'))
    checks = 0
    for name in ('LocalFeedbackRepairTest', 'FeedbackRepairTest', 'RepairEnvironmentTest', 'RepairLearningTest'):
        matches = re.findall(rf'(?:{name} passed: |RESULT,{name},)(\d+)', (pre/(name+'.log')).read_text())
        if len(matches) != 1: raise ValueError('MISSING_TEST_COUNT')
        checks += int(matches[0])
    checks += int(re.search(r'Ran (\d+) tests', (pre/'python-tests.log').read_text()).group(1))
    audit = {'status': 'AUDIT_PASSED', 'sourceHashes': len(read(study/'input-hashes.json')),
             'preflightOutputHashes': len(read(pre/'output-hashes.json')),
             'datasetOutputHashes': len(read(dataset/'output-hashes.json')),
             'studyOutputHashes': len(read(study/'output-hashes.json')),
             'checkpointChecks': checkpoints, 'aggregationAdmissions': dict(admissions),
             'aggregatedDecisionKinds': dict(decision_kinds), 'proofTheorems': proofs,
             'runtimeCheckExecutions': checks, 'reporterHash': sha(Path(__file__)),
             'initialTeacherErrors': dict(teacher_errors),
             'rolloutBehavior': behaviors,
             'previousBenchmark': {'identicalOrderedTasksAndSourceHashes': same_tasks,
                                   'reportHash': sha(previous/'study/report.json'),
                                   'taskHash': sha(previous/'dataset/tasks.json')},
             'scope': 'Bounded source/dataflow/accounting evidence, not universal refinement or learning proof'}
    out.mkdir(parents=True)
    for source, name in ((study/'report.json', 'report.json'), (dataset/'report.json', 'data-report.json'),
                         (study/'locked-selection.json', 'locked-selection.json'),
                         (study/'input-hashes.json', 'input-hashes.json'),
                         (study/'output-hashes.json', 'original-study-output-hashes.json'),
                         (dataset/'output-hashes.json', 'original-dataset-output-hashes.json'),
                         (pre/'output-hashes.json', 'original-preflight-output-hashes.json')):
        shutil.copy2(source, out/name)
    (out/'audit.json').write_text(json.dumps(audit, indent=2)+'\n')
    with tarfile.open(out/'evidence.tar.gz', 'w:gz') as archive:
        for root, prefix in ((pre, 'preflight'), (dataset, 'data'), (study, 'study')):
            for path in sorted(root.rglob('*')):
                if path.is_file() and path.suffix in ('.json', '.log', '.args', '.als'):
                    archive.add(path, arcname=str(Path(prefix)/path.relative_to(root)), recursive=False)
        inputs = {**read(study/'input-hashes.json'), **proof['source_sha256']}
        verify(ROOT, inputs)
        for name in sorted(inputs):
            if Path(name).suffix != '.jar':
                archive.add(ROOT/name, arcname=str(Path('inputs')/name), recursive=False)
        archive.add(Path(__file__), arcname='reporter.py', recursive=False)
        for name in ('study/report.json', 'dataset/tasks.json'):
            archive.add(previous/name, arcname=str(Path('previous-benchmark')/name), recursive=False)
    lines = ['# Larger Local Feedback Repair: Results', '',
             '**Question-disjoint benchmark evaluation, following an explicitly authorized scaling diagnostic.**', '',
             'The earlier eight-task gate remains failed; it is not retrospectively marked passed.',
             'This reuses the earlier benchmark, whose aggregate outcomes were already known.',
             'New configuration selection uses validation only, with the choice locked before',
             'new test evaluation. No held-out teachers or gradients are used.', '',
             '## Headline Result', '',
             f'Screened {len(report["screening"])} configurations up to '
             f'{max(a["parameters"] for a in report["screening"]):,} parameters. '
             f'The best validation score was {best["validation"]["repairs"]}/{len(validation)}.',
             'Locked-model test repairs by seed: '+', '.join(
                 f'{r["seed"]}: {r["repairs"]}/{r["tasks"]}' for r in report['testing'])+'.',
             'Executable test episodes, after separating but not excluding recorded errors: '+', '.join(
                 f'{r["seed"]}: {r["tasks"]-r["errors"]}' for r in report['testing'])+'.',
             'A tied configuration selected by parameter count is not evidence of superior repair ability.', '',
             '## Data', '', f'- Selected: `{data["selected"]}`.', f'- Eligible: `{data["eligible"]}`.',
             f'- Preparation: `{data["preparation"]}`.', f'- Question groups: `{data["questionGroups"]}`.',
             f'- Initial teacher coverage: `{data["teachers"]}`.',
             f'- Admitted training trajectories: {report["teacherTasks"]}; decisions: {report["teacherDecisions"]}.',
             f'- Aggregation admission outcomes: `{dict(admissions)}`.',
             f'- Aggregated decision kinds: `{dict(decision_kinds)}`.', '',
             'Unsupported sources and failed episodes remain in the primary denominators.',
             'Only AST-identical and duplicate AST pairs are excluded under the frozen rule.', '',
             'Training-teacher failures (not model test outcomes):', '']
    for reason, count in teacher_errors.most_common():
        lines.append(f'- {count}: `'+reason.replace('\n', ' ')+'`.')
    lines += ['',
             '## Validation Screen', '',
             '| Model | Parameters | Validation repairs | Episode errors | Training seconds | Peak CUDA MiB |',
             '| --- | ---: | ---: | ---: | ---: | ---: |']
    for a in report['screening']:
        v = a['validation']
        lines.append(f'| {a["config"]["name"]} | {a["parameters"]:,} | {v["repairs"]}/{v["tasks"]} | '
                     f'{v["errors"]} | {a["seconds"]:.1f} | {a["peakCudaAllocatedBytes"]/1024**2:.1f} |')
    lines += ['', 'Episode errors include initial coverage refusals and later encoder/worker failures.',
              'See the runtime incident record for the attention rollout that exceeded its history bound.',
              '', f'Locked configuration: **{best["config"]["name"]}**. Ties use smaller parameter count,',
              'then fixed configuration order, never training loss or test results.', '', '## Test Evaluation', '',
              '| Seed | Learned repairs | Uniform | No-op | Learned errors | Learned rejected actions |',
              '| --- | ---: | ---: | ---: | ---: | ---: |']
    for a in report['testing']:
        controls = {c['mode']: c for c in report['controls'] if c['seed'] == a['seed']}
        lines.append(f'| {a["seed"]} | {a["repairs"]}/{a["tasks"]} | '
                     f'{controls["uniform"]["repairs"]}/{a["tasks"]} | '
                     f'{controls["noop"]["repairs"]}/{a["tasks"]} | {a["errors"]} | {a["rejected"]} |')
    ci = report['pairedQuestionBootstrap']
    lines += ['', f'There are {len(testing)} unique test tasks in {ci["clusters"]} question groups, repeated across seeds.',
              'Repeated seeds are not independent test tasks. The paired learned-minus-uniform',
              f'repair-rate difference is {ci["difference"]:.6f}; the question-cluster bootstrap',
              f'interval is [{ci["lower"]:.6f}, {ci["upper"]:.6f}] ({ci["resamples"]:,} resamples).',
              'A degenerate zero interval, if present, is not proof that the algorithms are equivalent.', '',
              '## Training Roll-ins', '',
              'These are the fixed training tasks used to acquire on-policy labels, not held-out',
              'results. Scores are after 3,000 and 4,000 updates; the final 5,000-update',
              'checkpoint is evaluated on validation or test, not on this roll-in set.', '']
    for fit in fits:
        scores = ', '.join(f'{r["rollin"]["repairs"]}/{r["rollin"]["tasks"]}' for r in fit['rounds'])
        lines.append(f'- {fit["config"]["name"]}, seed {fit["seed"]}: {scores}.')
    lines += ['', '## Post-Hoc Rollout Diagnostics', '',
              'These descriptive counts use error-free worker episodes only; they do not',
              'replace the primary denominator or prove why learning failed. STOP closes an',
              'episode even if its query returns a counterexample; VALIDATE need not.', '',
              '| Run | Executed | No committed edit | STOP with counterexample | Used all four queries | Decision budget exhausted |',
              '| --- | ---: | ---: | ---: | ---: | ---: |']
    for name, row in behaviors.items():
        lines.append(f'| {name} | {row["executed"]} | {row["noCommittedEdit"]} | '
                     f'{row["counterexampleStop"]} | {row["usedFullQueryBudget"]} | {row["decisionExhausted"]} |')
    lines += ['',
              '## Comparison With The Earlier Study', '',
              f'Identical ordered task identities, question splits and derived source hashes: **{same_tasks}**.',
              'Earlier test repairs by seed: '+', '.join(f'{r["seed"]}: {r["repairs"]}/{r["tasks"]}' for r in old_report['testing'])+'.',
              'The new run changes teacher construction, replay aggregation, query budget (Q=2 to Q=4),',
              'model/update configuration and sampling. Differences are pipeline-level evidence,',
              'not an isolated causal effect of model size or recovery supervision.', '',
              '## Scope And Resources', '',
              'Each fit uses 3,000 initial updates and two 1,000-update aggregation rounds,',
              'batch eight, Q=4, and 256 decisions per episode. Up to 32 frozen training',
              'tasks supply roll-ins, with at most two snapshots each per round. This is',
              'supervised imitation plus on-policy aggregation, not policy-gradient RL.',
              'On-policy data differ across models; this is not an isolated model-size ablation.', '',
              f'- Fits: {len(fits)}; optimizer updates: {sum(a["updates"] for a in fits):,}; all finite/nonzero.',
              f'- Device: {report["gpu"]}; PyTorch {report["torch"]}.',
              f'- Study time: {report["seconds"]:.1f}s; data collection: {data["seconds"]:.1f}s, plus preflight.',
              '- Training timings include roll-ins and offline expert calls, not just GPU updates.',
              f'- Final checkpoint reloads: {len(checkpoints)}/{len(fits)}.',
              f'- Lean model/fixture theorems compiled: {proofs}; runtime check executions: {checks}.',
              f'- HEAD: `{report["git"]}`; dirty worktree: `{report["dirty"]}`.',
              '- Finite tests and model proofs are not universal Java/Python/Lean refinement.',
              '- Qwen and roughly 500M scratch training were not run.', '',
              'The local expert still emits singleton alternatives and may abort a useful partial',
              'draft before constructing a continuation. Import/CALL/local-declaration coverage',
              'limits are unchanged. Query-attempt counters now retain attempts whose worker',
              'requests fail; numerical fitting does not establish effective counterexample use.', '',
              'The first collection was stopped before training because a JVM shared-perfdata',
              'startup warning prefixed valid JSON metadata. The current subprocesses disable',
              'those counters, retain strict JSON parsing, and use a fresh complete preflight',
              'and collection. No interrupted-run labels enter this study.', '',
              '## Evidence And Reproduction', '',
              'See [the frozen protocol](LOCAL-SCALING-STUDY.md) and [runtime correspondence](LOCAL-SCALING-RUNTIME.md). Curated JSON/log/source evidence',
              'is in `results/local_scaling_20261004/`; its archive excludes binary checkpoints,',
              f'classes and JARs. Checkpoints remain in `{study}`. Producer hashes, not HEAD',
              'alone, identify the dirty-tree implementation. Original data and historical',
              'experiment outputs were not changed.', '', '```bash',
              '/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.local_preflight /tmp/local-scale-preflight-new',
              '/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.local_scale_data /tmp/local-scale-preflight-new /tmp/local-scale-data-new --workers 4',
              '/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_local_scaled /tmp/local-scale-data-new /tmp/local-scale-study-new --workers 4',
              '```', '', 'Run each command only after the preceding command exits successfully.', '']
    args.markdown.write_text('\n'.join(lines), encoding='utf-8')
    (out/'hashes.json').write_text(json.dumps({f.name: sha(f) for f in sorted(out.iterdir()) if f.is_file()}, indent=2)+'\n')
    print(json.dumps(audit, indent=2))


if __name__ == '__main__':
    main()
