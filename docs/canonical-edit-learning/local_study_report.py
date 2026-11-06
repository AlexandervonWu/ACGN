#!/usr/bin/env python3
"""Audit and summarize a completed bounded local-repair study, without training."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import shutil
import tarfile


ROOT = Path(__file__).resolve().parents[2]


def sha(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024*1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def verify(root, manifest):
    for name, digest in manifest.items():
        if sha(root/name) != digest:
            raise ValueError(f'Changed evidence: {root/name}')


def read(path):
    return json.loads(path.read_text())


def audit_rollouts(path, summary, tasks, query_budget, decision_budget):
    trials = read(path)
    if [t['id'] for t in trials] != [t['id'] for t in tasks]:
        raise ValueError('Changed task denominator/order: '+str(path))
    if summary['tasks'] != len(tasks):
        raise ValueError('Changed summary denominator: '+str(path))
    if summary['repairs'] != sum(t['solved'] for t in trials):
        raise ValueError('Repair count mismatch: '+str(path))
    if summary['errors'] != sum('error' in t for t in trials):
        raise ValueError('Error count mismatch: '+str(path))
    for trial in trials:
        actions = trial['actions']
        if len(actions) > decision_budget or sum(a['action']['control'] in (11, 12) for a in actions) > query_budget:
            raise ValueError('Budget violation: '+str(path))
        if trial['solved'] and (trial.get('status') != 5 or 'error' in trial):
            raise ValueError('Unsupported success: '+str(path))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('study', type=Path)
    p.add_argument('destination', type=Path)
    p.add_argument('markdown', type=Path)
    p.add_argument('--diagnostic', type=Path, action='append', default=[],
                   help='Retain an additional post-hoc diagnostic source or log in the evidence archive')
    args = p.parse_args()
    study, out = args.study.resolve(), args.destination.resolve()
    if out.exists(): p.error('Fresh evidence destination required')
    if len({path.name for path in args.diagnostic}) != len(args.diagnostic):
        p.error('Diagnostic filenames must be distinct')
    diagnostics = {path.name: sha(path) for path in args.diagnostic}
    report = read(study/'report.json')
    if report['status'] != 'BOUNDED_COMPARISON_COMPLETE':
        raise ValueError('Study is incomplete')
    preflight = Path(report['preflight'])
    verify(ROOT, read(study/'input-hashes.json'))
    verify(preflight, read(preflight/'output-hashes.json'))
    verify(study, read(study/'output-hashes.json'))
    if sha(preflight/'output-hashes.json') != report['preflightHash']:
        raise ValueError('Preflight binding mismatch')
    tasks = read(preflight/'tasks.json')
    runtime_checks = 0
    for name in ('LocalFeedbackRepairTest', 'FeedbackRepairTest', 'RepairEnvironmentTest', 'RepairLearningTest'):
        log = (preflight/(name+'.log')).read_text()
        matches = re.findall(rf'(?:{name} passed: |RESULT,{name},)(\d+)', log)
        if len(matches) != 1:
            raise ValueError('Missing runtime test count: '+name)
        runtime_checks += int(matches[0])
    python_matches = re.findall(r'Ran (\d+) tests', (preflight/'python-tests.log').read_text())
    if len(python_matches) != 1:
        raise ValueError('Missing Python test count')
    runtime_checks += int(python_matches[0])
    proofs = read(preflight/'proofs/report.json')
    proof_count = proofs['general_theorems'] + proofs['concrete_model_checks']
    proof_count += len(re.findall(r"^'LocalRepairArchive\.", (preflight/'archive-proof.log').read_text(), re.M))
    if any(t['split'] != 'train' for t in tasks):
        raise ValueError('Held-out data in training study')
    expected_arms = {(variant, seed) for variant in report['variants'] for seed in report['seeds']}
    actual_arms = [(a['variant'], a['seed']) for a in report['arms']]
    if len(actual_arms) != len(expected_arms) or set(actual_arms) != expected_arms:
        raise ValueError('Missing arms')
    expected_controls = {(mode, seed) for mode in ('uniform', 'noop') for seed in report['seeds']}
    actual_controls = [(c['mode'], c['seed']) for c in report['controls']]
    if len(actual_controls) != len(expected_controls) or set(actual_controls) != expected_controls:
        raise ValueError('Missing controls')
    admissions, reasons, kinds = Counter(), Counter(), Counter()
    rejected_pre_states = valid_changed_pre_states = 0
    for path in study.glob('*/aggregation-*/coverage.json'):
        for row in read(path):
            admissions[row['status']] += 1
            if 'error' in row: reasons[row['error']] += 1
            if row['status'] == 'REPLAY_ADMITTED':
                trajectory = read(path.parent/row['trajectory'])
                for item in trajectory['decisions']:
                    kinds[item['kind']] += 1
                    rejected_pre_states += item['observation']['status'] in (2, 3)
                    valid_changed_pre_states += item['observation']['revision'] > 0
                if trajectory['kind'] == 'continuation':
                    if trajectory['final']['status'] != 5 or not trajectory['final']['closed']:
                        raise ValueError('Unaccepted continuation')
                elif trajectory['kind'] == 'recovery':
                    if len(trajectory['decisions']) != 1 or trajectory['decisions'][0]['alternatives'] != [{'control': 10}]:
                        raise ValueError('Recovery label mismatch')
    # Recreate every final policy, not only the winning configuration.
    import sys
    sys.path.insert(0, str(ROOT))
    import torch
    from experiments.feedback_repair.gnn_variants import make_policy
    torch.set_num_threads(2)
    checkpoint_checks = []
    final_task_repairs = Counter({t['id']: 0 for t in tasks})
    for arm in report['arms']:
        directory = study/f'{arm["variant"]}-{arm["seed"]}'
        if arm['updates'] != report['initialUpdates'] + report['aggregationRounds']*report['updatesPerRound']:
            raise ValueError('Incomplete optimizer run')
        if [r['round'] for r in arm['rounds']] != list(range(report['aggregationRounds']+1)):
            raise ValueError('Incomplete rollout rounds')
        for r in arm['rounds']:
            audit_rollouts(directory/f'rollouts-{r["round"]}.json', r, tasks,
                           report['queryBudget'], report['decisionBudget'])
        for trial in read(directory/f'rollouts-{report["aggregationRounds"]}.json'):
            final_task_repairs[trial['id']] += trial['solved']
        checkpoint_path = directory/f'policy-{report["aggregationRounds"]}.pt'
        checkpoint = torch.load(checkpoint_path, map_location='cpu', weights_only=True)
        if any(checkpoint[key] != value for key, value in (
                ('variant', arm['variant']), ('seed', arm['seed']), ('contract', report['contract']),
                ('round', report['aggregationRounds']))):
            raise ValueError('Checkpoint metadata mismatch')
        policy = make_policy(checkpoint['variant'], checkpoint['width'], checkpoint['layers'])
        policy.load_state_dict(checkpoint['state_dict'], strict=True)
        if any(not torch.isfinite(t).all() for t in policy.state_dict().values()):
            raise ValueError('Nonfinite checkpoint tensor')
        if sum(p.numel() for p in policy.parameters()) != arm['parameters']:
            raise ValueError('Checkpoint parameter count mismatch')
        checkpoint_checks.append({'path': str(checkpoint_path.relative_to(study)),
                                  'sha256': sha(checkpoint_path), 'status': 'STRICT_LOAD_FINITE'})
    for control in report['controls']:
        audit_rollouts(study/f'controls-{control["seed"]}'/(control['mode']+'.json'), control,
                       tasks, report['queryBudget'], report['decisionBudget'])
    audit = {'status': 'AUDIT_PASSED', 'inputHashes': len(read(study/'input-hashes.json')),
             'preflightOutputHashes': len(read(preflight/'output-hashes.json')),
             'studyOutputHashes': len(read(study/'output-hashes.json')),
             'admissionStatuses': dict(admissions), 'admissionErrors': dict(reasons),
             'supervisedDecisionKinds': dict(kinds), 'rejectedSupervisedStates': rejected_pre_states,
             'supervisedStatesAfterCommit': valid_changed_pre_states,
             'checkpointChecks': checkpoint_checks,
             'finalTaskRepairs': dict(final_task_repairs),
             'diagnosticHashes': diagnostics, 'reporterHash': sha(Path(__file__)),
             'scope': 'Finite source/dataflow/accounting audit; not universal Java/Lean refinement'}
    out.mkdir(parents=True)
    shutil.copy2(study/'report.json', out/'report.json')
    shutil.copy2(study/'input-hashes.json', out/'input-hashes.json')
    shutil.copy2(study/'output-hashes.json', out/'original-study-output-hashes.json')
    shutil.copy2(preflight/'output-hashes.json', out/'original-preflight-output-hashes.json')
    shutil.copy2(preflight/'tasks.json', out/'tasks.json')
    shutil.copy2(preflight/'coverage.json', out/'teacher-coverage.json')
    (out/'audit.json').write_text(json.dumps(audit, indent=2)+'\n')
    # Retain machine-readable evidence and logs; checkpoints/classes stay external.
    with tarfile.open(out/'evidence.tar.gz', 'w:gz') as archive:
        for root, prefix in ((study, 'study'), (preflight, 'preflight')):
            for path in sorted(root.rglob('*')):
                if path.is_file() and path.suffix in ('.json', '.log', '.args'):
                    archive.add(path, arcname=str(Path(prefix)/path.relative_to(root)), recursive=False)
        # Dirty-tree source hashes must remain inspectable after later edits.
        inputs = dict(read(study/'input-hashes.json'))
        inputs.update(read(preflight/'proofs/report.json')['source_sha256'])
        verify(ROOT, inputs)
        for name in sorted(inputs):
            path = ROOT/name
            if path.suffix != '.jar':
                archive.add(path, arcname=str(Path('inputs')/name), recursive=False)
        archive.add(Path(__file__), arcname='reporter.py', recursive=False)
        for path in args.diagnostic:
            archive.add(path, arcname=str(Path('diagnostics')/path.name), recursive=False)
    lines = ['# Local Feedback Repair: Training Results', '',
             '**Bounded training-set diagnostic, not held-out performance.**', '',
             f'Contract: `{report["contract"]}`. Device: `{report["gpu"]}`; PyTorch `{report["torch"]}`.', '',
             f'The fixed {report["tasks"]} training tasks supplied {report["teacherDecisions"]} initial teacher decisions.',
             'All arms use four semantic queries, 256 decisions, 128-wide three-layer models,',
             f'{report["initialUpdates"]:,} initial updates and two {report["updatesPerRound"]:,}-update aggregation rounds. Model and dataflow',
             'changes are bundled; this is not an isolated causal comparison with old Q=2 results.', '',
             '## Repairs By Round', '',
             '| Model | Seed | Parameters | Initial | After round 1 | After round 2 | Final errors |',
             '| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
    for a in report['arms']:
        scores = ' | '.join(f'{r["repairs"]}/{report["tasks"]}' for r in a['rounds'])
        lines.append(f'| {a["variant"]} | {a["seed"]} | {a["parameters"]:,} | {scores} | {a["rounds"][-1]["errors"]} |')
    lines += ['', 'Final-round totals across the repeated training tasks (not independent test samples):', '']
    for variant in report['variants']:
        arms = [a for a in report['arms'] if a['variant'] == variant]
        successes = sum(a['rounds'][-1]['repairs'] for a in arms)
        lines.append(f'- {variant}: {successes}/{len(arms)*len(tasks)} repairs; '
                     f'{successes/len(arms):.2f}/{len(tasks)} mean per seed.')
    lines += ['', '## Matched Controls', '']
    for c in report['controls']:
        lines.append(f'- {c["mode"]}, seed {c["seed"]}: {c["repairs"]}/{c["tasks"]} repairs, {c["errors"]} errors.')
    lines += ['', '## Final-Round Task Coverage', '',
              'Counts across all model/seed arms; this diagnoses concentration of success,',
              'not independent replications or a held-out success rate.', '']
    for task in tasks:
        lines.append(f'- `{task["group"]}` (`{task["id"]}`): '
                     f'{final_task_repairs[task["id"]]}/{len(report["arms"])}.')
    total_updates = sum(a['updates'] for a in report['arms'])
    nonzero = sum(a['finiteNonzeroGradientUpdates'] for a in report['arms'])
    peak = max(a['peakCudaAllocatedBytes'] for a in report['arms'])/1024**2
    lines += ['', '## Learning And Coverage', '',
              f'- Optimizer updates: {total_updates:,}; finite nonzero-gradient updates: {nonzero:,}.',
              f'- On-policy label admission outcomes: `{dict(admissions)}`.',
              f'- Admitted decision classes: `{dict(kinds)}`.',
              f'- Supervised rejected/stale states: {rejected_pre_states}; after-commit states: {valid_changed_pre_states}.',
              f'- Peak PyTorch allocated GPU memory: {peak:.1f} MiB (excludes desktop/process-wide GPU usage).',
              f'- Study time: {report["seconds"]:.1f} seconds; excludes preflight/collection.',
              f'- Final checkpoints strictly reloaded with finite tensors: {len(checkpoint_checks)}/{len(report["arms"])}.',
              f'- Gate status: `{report["gateStatus"]}`.', '',
              'These are the same eight tasks across seeds, not 24 independent examples. The',
              'initial source-realized teachers and all admitted continuations are freshly',
              'replayed. Actual on-policy data differ across models, despite equal budgets.',
              'The expert currently aborts an open draft before planning a continuation;',
              'it does not yet optimally continue an already-useful partial draft. Recovery',
              'labels are separated from semantic success. Initial seed trajectories all',
              'replace the root while reusing operands; non-root support is regression-tested',
              'but that is not evidence of broad local-edit diversity in this eight-task set.', '',
              'Training uses supervised joint-action imitation with on-policy data aggregation,',
              'not reward-based policy gradients. Nonzero gradients are not a semantic-repair',
              'proof or evidence that the model learned an effective counterexample strategy.', '',
              'Canonical-observation coverage refusals are not covered by the syntax/type-only',
              'retry cache. See the separately recorded repeated-COMMIT incident in the runtime',
              'document, which is tied to its named rollout. Rejection keeps the committed',
              'source unchanged; the model must recover or exhaust its budget. No worker error',
              'does not mean every proposed candidate was representable or successful.', '',
              '## Trust And Reproduction', '',
              f'{proof_count} Lean model/fixture theorems and {runtime_checks} Java/Python check executions passed',
              'before training. This is bounded correspondence evidence, not a universal',
              'refinement proof. See [runtime details](LOCAL-REPAIR-RUNTIME.md) and',
              '[protocol](LOCAL-REPAIR-STUDY.md). Input/output hashes and complete JSON/log',
              'evidence are retained in `results/local_repair_20261004/`; model checkpoints',
              f'remain in `{study}`. Source HEAD is `{report["git"]}` with a dirty worktree;',
              'the input hashes identify the implementation. Historical experiments and the',
              'original corpus were not changed. The archive excludes binary checkpoints/classes.', '',
              '```bash',
              '/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.local_preflight /tmp/local-preflight-new',
              '/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_local /tmp/local-preflight-new /tmp/local-study-new',
              '```', '',
              'Qwen, roughly 500M scratch training and held-out evaluation have not been run',
              'under this refinement. They remain behind the full 1/8/64 learnability gates.', '']
    args.markdown.write_text('\n'.join(lines), encoding='utf-8')
    (out/'hashes.json').write_text(json.dumps({p.name: sha(p) for p in sorted(out.iterdir()) if p.is_file()}, indent=2)+'\n')
    print(json.dumps(audit, indent=2))


if __name__ == '__main__':
    main()
