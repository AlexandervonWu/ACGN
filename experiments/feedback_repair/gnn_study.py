"""Paired, bounded architecture/gradient experiment on eight training tasks."""
import argparse
from collections import defaultdict
import json
import math
from pathlib import Path
import platform
import random
import subprocess
import time
import torch

from .run_gates import ROOT, sha, write
from .tables import encode
from .policy import choose
from .gnn_variants import VARIANTS, make_policy
from .train_gates import rollout, worker


def validate_hashes(root, hashes):
    for name, digest in hashes.items():
        if sha(root/name) != digest: raise ValueError('Changed frozen input: ' + name)


def gradient_norms(model):
    sums = defaultdict(float)
    for name, p in model.named_parameters():
        if p.grad is None: continue
        value = float(p.grad.detach().double().square().sum())
        if not math.isfinite(value): raise ValueError('NONFINITE_GRADIENT: ' + name)
        sums[name.split('.')[0]] += value
    return {key: math.sqrt(value) for key, value in sums.items()}


def teacher_metrics(model, data):
    total = heads = correct = joint = count = 0
    model.eval()
    with torch.no_grad():
        for examples in data:
            for graph, obs, label, queries in examples:
                _, loss, matches = choose(model, graph, obs, queries, label)
                total += float(loss); heads += len(matches); correct += sum(matches)
                joint += all(matches); count += 1
    return {'loss': total/count, 'headAccuracy': correct/heads, 'jointAccuracy': joint/count,
            'decisions': count, 'heads': heads}


def describe_trials(trials):
    return {'repairs': sum(t['solved'] for t in trials), 'tasks': len(trials),
            'wellFormed': sum(t['wellFormed'] for t in trials),
            'errors': sum('error' in t for t in trials),
            'queries': sum(t['queries'] for t in trials),
            'rejections': sum(t.get('rejected', 0) for t in trials)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('preflight', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--device', default='cuda')
    args = parser.parse_args()
    out, preflight = args.output.resolve(), args.preflight.resolve()
    if out.exists() or out == ROOT or ROOT in out.parents: parser.error('Fresh external output required')
    frozen = json.loads((preflight/'input-hashes.json').read_text())
    evidence = json.loads((preflight/'output-hashes.json').read_text())
    validate_hashes(ROOT, frozen); validate_hashes(preflight, evidence)
    checked = json.loads((preflight/'report.json').read_text())
    if checked['taskCount'] != 104 or checked['tests'].get('GNNTest') != 7:
        raise ValueError('Current full pilot + GNN gradient preflight required')
    out.mkdir(parents=True)
    write(out/'input-hashes.json', frozen)
    torch.set_num_threads(2)
    torch.backends.cuda.matmul.allow_tf32 = False
    started = time.monotonic()
    with worker(preflight/'classes', out/'catalog.log') as process: catalog = process.request('catalog')
    write(out/'catalog.json', catalog)
    tasks = [t for t in json.loads((ROOT/'docs/rl-corpus-data/tasks.json').read_text())['tasks'] if t['split'] == 'train'][:8]
    if len(tasks) != 8: raise ValueError('Frozen task split changed')
    teachers = []
    admitted = {row['id'] for row in json.loads((preflight/'teachers/coverage.json').read_text())
                if row['status'] == 'REPLAY_VALIDATED_TEACHER'}
    for task in tasks:
        if task['id'] not in admitted: raise ValueError('Unvalidated teacher: ' + task['id'])
        record = json.loads((preflight/'teachers'/(task['id']+'.json')).read_text())
        if not record['finalObservation']['closed'] or record['finalObservation']['status'] != 5:
            raise ValueError('Teacher lacks final semantic acceptance')
        examples = []
        for item in record['decisions']:
            obs = item['observation']
            examples.append((encode(obs, catalog['operators']).to(args.device), obs, item['action'],
                             sum(row[1] in (11, 12) for row in obs['history'])))
        teachers.append(examples)
    seeds = (17, 29, 43)
    report = {'schema': 'feedback-gnn-gradient-v1', 'contract': 'feedback-intent-path-v1',
              'status': 'RUNNING', 'preflight': str(preflight), 'preflightHash': sha(preflight/'output-hashes.json'),
              'git': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
              'dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT)),
              'torch': torch.__version__, 'host': platform.platform(), 'device': args.device,
              'gpu': torch.cuda.get_device_name() if args.device == 'cuda' else None,
              'taskIds': [t['id'] for t in tasks], 'teacherDecisions': sum(map(len, teachers)),
              'seeds': list(seeds), 'arms': [], 'controls': [],
              'updateCap': 1000, 'batchDecisions': 8, 'queryBudget': 2, 'decisionBudget': 256,
              'laterStages': {'heldout': 'NOT_RUN', 'Qwen': 'NOT_RUN', '500M': 'NOT_RUN'}}
    write(out/'report.json', report)
    for seed in seeds:
        rng = random.Random(seed)
        schedule = []
        for _ in range(1000):
            batch = []
            for _ in range(8):
                task_index = rng.randrange(8)
                batch.append((task_index, rng.randrange(len(teachers[task_index]))))
            schedule.append(batch)
        write(out/f'schedule-{seed}.json', schedule)
        for variant in VARIANTS:
            directory = out/f'{variant}-{seed}'; directory.mkdir()
            torch.manual_seed(seed)
            model = make_policy(variant).to(args.device)
            optimizer = torch.optim.AdamW(model.parameters(), lr=0.001, weight_decay=0.001)
            if args.device == 'cuda': torch.cuda.reset_peak_memory_stats()
            start = time.monotonic()
            arm = {'variant': variant, 'seed': seed, 'parameters': sum(p.numel() for p in model.parameters()),
                   'scheduleHash': sha(out/f'schedule-{seed}.json'), 'before': teacher_metrics(model, teachers),
                   'rollouts': [], 'clippedUpdates': 0, 'nonzeroFiniteGradientUpdates': 0}
            report['arms'].append(arm)
            trace = []
            initial = model.scalar.weight.detach().clone()
            for update, batch in enumerate(schedule, 1):
                model.train(); optimizer.zero_grad(set_to_none=True)
                total = 0.0
                for ti, di in batch:
                    graph, obs, label, queries = teachers[ti][di]
                    _, loss, _ = choose(model, graph, obs, queries, label)
                    if not torch.isfinite(loss): raise ValueError('NONFINITE_LOSS')
                    (loss/8).backward(); total += float(loss.detach())/8
                modules = gradient_norms(model) if update == 1 or update % 25 == 0 else None
                norm = float(torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0, error_if_nonfinite=True))
                arm['clippedUpdates'] += norm > 1
                arm['nonzeroFiniteGradientUpdates'] += norm > 0
                before = model.scalar.weight.detach().clone() if modules is not None else None
                optimizer.step()
                if modules is not None:
                    trace.append({'update': update, 'loss': total, 'preClipNorm': norm,
                                  'moduleNorms': modules, 'encoderStepNorm': float((model.scalar.weight-before).norm())})
                    write(directory/'gradients.json', trace)
                if update % 250 == 0:
                    print(f'{variant} seed {seed} update {update}/1000 loss={total:.5f} grad={norm:.5f}', flush=True)
                if update in (250, 1000):
                    model.eval()
                    trials = [rollout(task, preflight/'classes', directory, catalog['operators'], model,
                                      args.device, f'learned-{update}', seed) for task in tasks]
                    write(directory/f'rollouts-{update}.json', trials)
                    result = {'update': update, **describe_trials(trials)}
                    arm['rollouts'].append(result)
                    print(f'  Actual repairs {result["repairs"]}/8; errors {result["errors"]}', flush=True)
                    write(out/'report.json', report)
            arm.update(after=teacher_metrics(model, teachers), seconds=time.monotonic()-start,
                       encoderTotalUpdateNorm=float((model.scalar.weight-initial).norm()),
                       peakCudaAllocatedBytes=torch.cuda.max_memory_allocated() if args.device == 'cuda' else 0,
                       peakCudaReservedBytes=torch.cuda.max_memory_reserved() if args.device == 'cuda' else 0)
            torch.save({'variant': variant, 'seed': seed, 'width': 128, 'layers': 3,
                        'state_dict': model.state_dict()}, directory/'policy.pt')
            write(out/'report.json', report)
            del optimizer, model
            if args.device == 'cuda': torch.cuda.empty_cache()
        for mode in ('noop', 'uniform'):
            directory = out/f'{mode}-{seed}'; directory.mkdir()
            trials = [rollout(task, preflight/'classes', directory, catalog['operators'], None, 'cpu',
                              mode, seed+i) for i, task in enumerate(tasks)]
            write(directory/'rollouts.json', trials)
            report['controls'].append({'mode': mode, 'seed': seed, **describe_trials(trials)})
    summary = []
    for variant in VARIANTS:
        arms = [a for a in report['arms'] if a['variant'] == variant]
        summary.append({'variant': variant, 'parameters': arms[0]['parameters'],
                        'finalRepairs': [a['rollouts'][-1]['repairs'] for a in arms],
                        'totalRepairs': sum(a['rollouts'][-1]['repairs'] for a in arms),
                        'meanTeacherJointAccuracy': sum(a['after']['jointAccuracy'] for a in arms)/len(arms),
                        'eightTaskGatePasses': sum(a['rollouts'][-1]['repairs'] == 8 and
                                                  a['rollouts'][-1]['wellFormed'] == 8 for a in arms)})
    report['summary'] = sorted(summary, key=lambda s: (-s['totalRepairs'], s['parameters']))
    report['status'] = 'BOUNDED_COMPARISON_COMPLETE'
    report['seconds'] = time.monotonic()-started
    report['limitations'] = ['Eight training tasks, not held-out generalization.',
                            'New readout and decoder are shared interventions, not isolated single-factor ablations.',
                            'Gradients and imitation scores cannot certify semantic repair.',
                            'No large-model escalation; original 1/8/64 gate outcome preserved.']
    validate_hashes(ROOT, frozen); validate_hashes(preflight, evidence)
    write(out/'report.json', report)
    lines = ['# Bounded GNN Comparison', '', 'Final repairs on eight training tasks for seeds 17, 29, 43:', '']
    for row in report['summary']:
        lines.append(f'- {row["variant"]}: {row["finalRepairs"]}; {row["parameters"]:,} parameters; '
                     f'teacher joint accuracy {row["meanTeacherJointAccuracy"]:.3f}.')
    lines += ['', '## Limitations', ''] + ['- '+x for x in report['limitations']]
    (out/'report.md').write_text('\n'.join(lines)+'\n')
    write(out/'output-hashes.json', {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file()})
    print(json.dumps(report['summary'], indent=2), flush=True)


if __name__ == '__main__': main()
