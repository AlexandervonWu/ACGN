"""Train and actually execute bounded 1/8/64 learnability gates, stopping on failure."""
import argparse
import json
import os
from pathlib import Path
import random
import platform
import subprocess
import sys
import time
import torch

from .run_gates import ROOT, sha, write, JavaWorker
from .tables import encode
from .policy import GraphPolicy, choose
from .replay import decision


def worker(classes, log):
    return JavaWorker(ROOT, classes, log, timeout=30, command=[
        'java', '-XX:-UsePerfData', '-ea', '-Xmx2g', '-Dfile.encoding=UTF-8', '-cp', str(classes) + os.pathsep + str(ROOT/'lib/*'),
        'is.fivefivefive.ACGN.repair.FeedbackRepairWorker'])


def rollout(task, classes, directory, operators, model, device, mode, seed, task_root=None):
    rng = random.Random(seed)
    record = {'id': task['id'], 'mode': mode, 'decisions': [], 'queries': 0, 'solved': False, 'wellFormed': True}
    start = time.monotonic()
    try:
        with worker(classes, directory / (task['id'] + '-' + mode + '.log')) as process:
            observation = process.request('load', path=str((task_root or ROOT/'docs/rl-corpus-data')/task['path']),
                                          target=task['target'], oracle=task['oracle'], command=task['command'], budget=256)['observation']
            for _ in range(256):
                if time.monotonic() - start > 120:
                    record['error'] = 'EPISODE_DEADLINE'; break
                if observation['closed'] or observation['remaining'] == 0: break
                if mode == 'noop': label = {'control': 12}
                else:
                    graph = encode(observation, operators).to(device) if model is not None else None
                    with torch.no_grad():
                        label, _, _ = choose(model, graph, observation, record['queries'], rng=rng)
                stamped = decision(observation, label)
                if label['control'] in (11, 12): record['queries'] += 1
                if record['queries'] > 2: raise ValueError('QUERY_BUDGET_EXCEEDED')
                next_observation = process.request('decide', decision=stamped)['observation']
                record['decisions'].append({'action': label, 'status': next_observation['status']})
                observation = next_observation
            record['solved'] = observation['closed'] and observation['status'] == 5
            record['status'] = observation['status']
            record['rejected'] = sum(item['status'] in (2, 3) for item in record['decisions'])
    except Exception as error:
        record['error'] = type(error).__name__ + ': ' + str(error)
        record['wellFormed'] = False
    record['seconds'] = time.monotonic() - start
    return record


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('preflight', type=Path, help='completed current-schema run_gates directory')
    parser.add_argument('output', type=Path, help='fresh external output directory')
    parser.add_argument('--device', default='cuda')
    parser.add_argument('--seed', type=int, default=17)
    args = parser.parse_args()
    out, preflight = args.output.resolve(), args.preflight.resolve()
    if out.exists() or ROOT in out.parents: parser.error('Use a fresh external output directory')
    # Bind to the exact checked source, libraries, teachers, and split. No stale preflight accepted.
    for name, digest in json.loads((preflight/'input-hashes.json').read_text()).items():
        if sha(ROOT/name) != digest: raise ValueError('Stale preflight input: ' + name)
    for name, digest in json.loads((preflight/'output-hashes.json').read_text()).items():
        if sha(preflight/name) != digest: raise ValueError('Modified preflight evidence: ' + name)
    pre_report = json.loads((preflight/'report.json').read_text())
    if pre_report['taskCount'] != 104 or pre_report['tests'].get('LearningBoundaryTest') != 7:
        raise ValueError('Full pilot and learning-boundary preflight required')
    out.mkdir(parents=True)
    start = time.monotonic()
    torch.set_num_threads(2)
    torch.manual_seed(args.seed); random.seed(args.seed)
    torch.backends.cuda.matmul.allow_tf32 = False
    if args.device == 'cuda': torch.cuda.reset_peak_memory_stats()
    classes = preflight/'classes'
    with worker(classes, out/'catalog.log') as process: catalog = process.request('catalog')
    write(out/'catalog.json', catalog)
    tasks = [t for t in json.loads((ROOT/'docs/rl-corpus-data/tasks.json').read_text())['tasks'] if t['split'] == 'train']
    if len(tasks) != 64: raise ValueError('Frozen train split changed')
    coverage = json.loads((preflight/'teachers/coverage.json').read_text())
    admitted = {r['id'] for r in coverage if r['status'] == 'REPLAY_VALIDATED_TEACHER'}
    data = {}
    encoding_failures = []
    for task in tasks:
        if task['id'] not in admitted: continue
        try:
            trajectory = json.loads((preflight/'teachers'/(task['id']+'.json')).read_text())
            examples = []
            for item in trajectory['decisions']:
                obs = item['observation']
                graph = encode(obs, catalog['operators'])
                queries = sum(row[1] in (11, 12) for row in obs['history'])
                examples.append((graph, obs, item['action'], queries))
            data[task['id']] = examples
        except Exception as error:
            encoding_failures.append({'id': task['id'], 'error': str(error)})
    write(out/'encoding-failures.json', encoding_failures)
    report = {'schema': 'feedback-learnability-v1', 'contract': 'feedback-intent-path-v1',
              'seed': args.seed, 'device': args.device, 'torch': torch.__version__,
              'host': platform.platform(), 'gpu': torch.cuda.get_device_name() if args.device == 'cuda' else None,
              'git': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
              'dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT)),
              'preflight': str(preflight), 'preflightHash': sha(preflight/'output-hashes.json'),
              'eligibleTrainTasks': len(tasks), 'encodedTeachers': len(data),
              'queryBudget': 2, 'decisionBudget': 256,
              'gates': [], 'status': 'RUNNING', 'laterStages': {
                  'GNN held-out comparison': 'NOT_RUN', 'Qwen adaptation': 'NOT_RUN', '~500M scratch': 'NOT_RUN'}}
    for size, cap, threshold in ((1, 1000, 1), (8, 1000, 8), (64, 5000, 60)):
        directory = out/f'gate-{size}'; directory.mkdir()
        group = tasks[:size]
        gate = {'tasks': size, 'updateCap': cap, 'requiredRepairs': threshold, 'updates': 0, 'passed': False}
        report['gates'].append(gate)
        if any(t['id'] not in data for t in group):
            gate['failure'] = 'TEACHER_OR_REPRESENTATION_COVERAGE'; break
        torch.manual_seed(args.seed)
        model = GraphPolicy().to(args.device)
        gate['parameters'] = sum(p.numel() for p in model.parameters())
        optimizer = torch.optim.AdamW(model.parameters(), lr=0.001, weight_decay=0.001)
        rng = random.Random(args.seed)
        losses = []
        for update in range(1, cap+1):
            model.train(); optimizer.zero_grad(set_to_none=True)
            # Uniform episodes, then decisions: longer teachers do not get higher weight.
            batch = []
            for _ in range(8):
                task = rng.choice(group); item = rng.choice(data[task['id']])
                batch.append(item)
            total = 0.0
            for graph, obs, label, queries in batch:
                _, loss, _ = choose(model, graph.to(args.device), obs, queries, label=label)
                (loss/len(batch)).backward(); total += float(loss.detach())/len(batch)
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0); optimizer.step()
            gate['updates'] = update
            if update % 25 == 0:
                losses.append({'update': update, 'loss': total})
                print(f'Gate {size}, update {update}/{cap}, imitation loss {total:.6f}', flush=True)
                write(directory/'losses.json', losses)
            if update in (100, 250, 500, 1000, 2000, 3500, 5000):
                model.eval()
                trials = [rollout(task, classes, directory, catalog['operators'], model, args.device,
                                  f'learned-{update}', args.seed) for task in group]
                write(directory/f'rollouts-{update}.json', trials)
                gate['repairs'] = sum(t['solved'] for t in trials)
                gate['wellFormedEpisodes'] = sum(t['wellFormed'] for t in trials)
                print(f'Gate {size} free-running: {gate["repairs"]}/{size}; structurally valid {gate["wellFormedEpisodes"]}/{size}', flush=True)
                if gate['repairs'] >= threshold and gate['wellFormedEpisodes'] == size:
                    gate['passed'] = True; break
        torch.save({'state_dict': model.state_dict(), 'width': 128, 'layers': 3, 'gate': size}, directory/'policy.pt')
        baselines = {}
        for mode in ('noop', 'uniform'):
            trials = [rollout(task, classes, directory, catalog['operators'], None, 'cpu', mode,
                              args.seed+i) for i, task in enumerate(group)]
            write(directory/(mode+'.json'), trials)
            baselines[mode] = {'repairs': sum(t['solved'] for t in trials), 'tasks': size,
                               'queries': sum(t['queries'] for t in trials)}
        gate['baselines'] = baselines
        write(out/'report.json', report)
        if not gate['passed']:
            gate['failure'] = 'FREE_RUNNING_LEARNABILITY'; break
    report.update(status='SMALL_GATES_PASS' if len(report['gates']) == 3 and all(g['passed'] for g in report['gates'])
                  else 'STOPPED_AT_FAILED_GATE', seconds=time.monotonic()-start,
                  peakCudaAllocatedBytes=torch.cuda.max_memory_allocated() if args.device == 'cuda' else 0,
                  peakCudaReservedBytes=torch.cuda.max_memory_reserved() if args.device == 'cuda' else 0)
    report['limitations'] = ['Training-set diagnostic, not held-out or three-seed evidence.',
                            'Draft masks use coarse sorts; exact dependent types are mandatory at commit.',
                            'Local canonical binders/unrepresentable domains and old revision histories fail explicitly.',
                            'Bounded search control and larger model consumers are not yet migrated.']
    write(out/'report.json', report)
    lines = ['# Structured Feedback Learnability', '', f'Status: **{report["status"]}**.', '',
             f'- Seed: {args.seed}; encoded teachers: {len(data)}/64 training tasks.',
             '- Real Java execution and final two-direction bounded Alloy checks; two-query maximum.', '']
    for gate in report['gates']:
        lines += [f'## Gate {gate["tasks"]}', '',
                  f'- Updates: {gate["updates"]}; repairs: {gate.get("repairs",0)}/{gate["tasks"]}; pass: {gate["passed"]}.',
                  f'- Controls: {gate.get("baselines", {})}.', '']
    lines += ['## Boundaries', ''] + ['- '+item for item in report['limitations']]
    lines += ['', 'Qwen adaptation and roughly 500M scratch training were not started by this diagnostic runner.', '']
    (out/'report.md').write_text('\n'.join(lines))
    write(out/'output-hashes.json', {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file()})
    print(json.dumps(report, indent=2), flush=True)
    return 0 if report['status'] == 'SMALL_GATES_PASS' else 2


if __name__ == '__main__':
    raise SystemExit(main())
