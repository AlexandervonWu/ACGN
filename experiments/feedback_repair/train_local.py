"""Bounded local-repair GNN training with replay-admitted on-policy recovery."""
import argparse
from collections import Counter, OrderedDict
import copy
import json
import platform
from pathlib import Path
import random
import subprocess
import time

import torch
from .run_gates import ROOT, sha, write
from .train_gates import worker
from .local_runtime import CONTRACT, collect_label, execute, joint_loss, load, queries
from .gnn_variants import make_policy
from .policy import choose
from .tables import encode


def verify(root, hashes):
    for name, digest in hashes.items():
        if sha(root/name) != digest:
            raise ValueError('FROZEN_INPUT_CHANGED: '+name)


def rollout(task, classes, directory, operators, model, device, mode, seed, retain_snapshots=True):
    rng, archive, prefix = random.Random(seed), {}, []
    retained = OrderedDict()
    record = {'id': task['id'], 'mode': mode, 'solved': False, 'queries': 0, 'queriesIssued': 0,
              'decisionsIssued': 0, 'actions': [], 'snapshots': []}
    start = time.monotonic()
    try:
        with worker(classes, directory/(task['id']+'-'+mode+'.log')) as process:
            obs = load(process, task)
            for _ in range(256):
                if obs['closed'] or obs['remaining'] <= 0:
                    break
                if time.monotonic() - start > 120:
                    raise TimeoutError('EPISODE_DEADLINE')
                # Snapshot selection uses public construction state only, not teacher success.
                if retain_snapshots and prefix and obs['remaining'] >= 16 and queries(obs) < 4:
                    key = json.dumps([obs['revision'], obs['status'], obs['draft'], obs['draftDeclarations']], sort_keys=True)
                    if key not in retained:
                        retained[key] = {'prefix': copy.deepcopy(prefix), 'snapshot': copy.deepcopy(obs)}
                        if len(retained) > 16:
                            retained.popitem(last=False)
                archive[obs['revision']] = copy.deepcopy(obs)
                if mode == 'noop':
                    action = {'control': 12}
                else:
                    graph = encode(obs, operators, archive).to(device) if model is not None else None
                    with torch.no_grad():
                        action, _, _ = choose(model, graph, obs, queries(obs), rng=rng, query_limit=4)
                record['decisionsIssued'] += 1
                record['queriesIssued'] += action['control'] in (11, 12)
                obs = execute(process, obs, action)
                record['queries'] = queries(obs)
                prefix.append(action)
                record['actions'].append({'action': action, 'status': obs['status'], 'revision': obs['revision']})
            record.update(solved=obs['closed'] and obs['status'] == 5, queries=queries(obs),
                          status=obs['status'], committed=obs['revision'], remaining=obs['remaining'])
    except (RuntimeError, ValueError, KeyError, TimeoutError) as error:
        record['error'] = type(error).__name__+': '+str(error)
    # Prefer real failure/recovery states, then committed states. Never use oracle ranking.
    snapshots = list(retained.values())
    snapshots.sort(key=lambda x: (x['snapshot']['status'] not in (2, 3),
                                  not bool(x['snapshot']['draft'] or x['snapshot']['actions']['holes'])))
    record['snapshots'] = snapshots[:4]
    record['rejected'] = sum(a['status'] in (2, 3) for a in record['actions'])
    record['seconds'] = time.monotonic()-start
    return record


def summarize(trials):
    return {'tasks': len(trials), 'repairs': sum(t['solved'] for t in trials),
            'errors': sum('error' in t for t in trials), 'queries': sum(t['queries'] for t in trials),
            'rejected': sum(t['rejected'] for t in trials),
            'decisionExhausted': sum(t.get('remaining') == 0 for t in trials)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('preflight', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--variants', nargs='+', default=['gin', 'gcn', 'sage', 'gat', 'mlp'],
                        choices=['gin', 'gcn', 'sage', 'gat', 'mlp'])
    parser.add_argument('--seeds', nargs='+', type=int, default=[17, 29, 43])
    parser.add_argument('--updates', type=int, default=1000)
    parser.add_argument('--round-updates', type=int, default=500)
    parser.add_argument('--device', default='cuda')
    args = parser.parse_args()
    out, preflight = args.output.resolve(), args.preflight.resolve()
    if out.exists() or ROOT in out.parents or args.updates < 1 or args.round_updates < 1:
        parser.error('Fresh external output and positive update caps required')
    frozen = json.loads((preflight/'input-hashes.json').read_text())
    verify(ROOT, frozen); verify(preflight, json.loads((preflight/'output-hashes.json').read_text()))
    checked = json.loads((preflight/'report.json').read_text())
    if checked['status'] != 'PREFLIGHT_COMPLETE':
        raise ValueError('CHECKED_PREFLIGHT_REQUIRED')
    out.mkdir(parents=True)
    write(out/'input-hashes.json', frozen)
    tasks = json.loads((preflight/'tasks.json').read_text())
    catalog = json.loads((preflight/'catalog.json').read_text())
    operators = catalog['operators']
    base = []
    encoded_coverage = []
    for task in tasks:
        path = preflight/'teachers'/(task['id']+'-trajectory.json')
        entry = {'id': task['id'], 'admitted': False}
        if path.exists():
            trajectory = json.loads(path.read_text())
            try:
                items = trajectory['decisions']
                for item in items:
                    encode(item['observation'], operators, {int(k): v for k, v in item['archive'].items()})
                base.append((task['id'], items)); entry.update(admitted=True, decisions=len(items))
            except (ValueError, KeyError) as error:
                entry['error'] = str(error)
        encoded_coverage.append(entry)
    write(out/'encoded-coverage.json', encoded_coverage)
    if not base:
        raise ValueError('NO_ADMITTED_TRAINING_EXAMPLES')
    report = {'schema': 'local-feedback-learning-study-v1', 'contract': CONTRACT, 'status': 'RUNNING',
              'tasks': len(tasks), 'teacherTasks': len(base), 'teacherDecisions': sum(len(x) for _, x in base),
              'taskIds': [t['id'] for t in tasks], 'queryBudget': 4, 'decisionBudget': 256,
              'variants': args.variants, 'seeds': args.seeds, 'initialUpdates': args.updates,
              'aggregationRounds': 2, 'updatesPerRound': args.round_updates, 'arms': [], 'controls': [],
              'preflight': str(preflight), 'preflightHash': sha(preflight/'output-hashes.json'),
              'torch': torch.__version__, 'host': platform.platform(),
              'gpu': torch.cuda.get_device_name() if args.device == 'cuda' else None,
              'git': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
              'dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT)),
              'laterStages': {'Qwen': 'GATED_NOT_RUN', '500M': 'GATED_NOT_RUN', 'heldout': 'NOT_RUN'}}
    write(out/'report.json', report)
    torch.set_num_threads(2); torch.backends.cuda.matmul.allow_tf32 = False
    started = time.monotonic()
    for seed in args.seeds:
        for variant in args.variants:
            directory = out/f'{variant}-{seed}'; directory.mkdir()
            torch.manual_seed(seed); rng = random.Random(seed)
            model = make_policy(variant, 128, 3).to(args.device)
            optimizer = torch.optim.AdamW(model.parameters(), lr=0.001, weight_decay=0.001)
            arm = {'variant': variant, 'seed': seed, 'parameters': sum(p.numel() for p in model.parameters()),
                   'rounds': [], 'updates': 0, 'finiteNonzeroGradientUpdates': 0, 'clippedUpdates': 0}
            report['arms'].append(arm)
            start = time.monotonic()
            initial_encoder = model.scalar.weight.detach().clone()
            if args.device == 'cuda': torch.cuda.reset_peak_memory_stats()
            added, traces, cache = [], [], OrderedDict()
            for round_number in range(3):
                cap = args.updates if round_number == 0 else args.round_updates
                schedule = []
                for update in range(cap):
                    model.train(); optimizer.zero_grad(set_to_none=True)
                    total = 0.0
                    batch_indices = []
                    for _ in range(8):
                        category = int(bool(added) and rng.randrange(2))
                        pool = added if category else base
                        ti = rng.randrange(len(pool)); di = rng.randrange(len(pool[ti][1]))
                        task_id, items = pool[ti]; item = items[di]
                        key = (category, ti, di)
                        if key not in cache:
                            cache[key] = encode(item['observation'], operators,
                                                {int(k): v for k, v in item['archive'].items()})
                            if len(cache) > 64: cache.popitem(last=False)
                        graph = cache[key]; cache.move_to_end(key)
                        loss = joint_loss(model, graph.to(args.device), item['observation'], item['alternatives'])
                        if not torch.isfinite(loss): raise ValueError('NONFINITE_LOSS')
                        (loss/8).backward(); total += float(loss.detach())/8
                        batch_indices.append([category, ti, di])
                    norm = float(torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0, error_if_nonfinite=True))
                    optimizer.step()
                    arm['updates'] += 1
                    arm['finiteNonzeroGradientUpdates'] += norm > 0
                    arm['clippedUpdates'] += norm > 1
                    schedule.append(batch_indices)
                    if update == 0 or (update+1) % 25 == 0:
                        traces.append({'round': round_number, 'update': arm['updates'], 'loss': total, 'gradientNorm': norm})
                    if (update+1) % 250 == 0:
                        print(f'{variant}/{seed} round {round_number} {update+1}/{cap} loss={total:.5f}', flush=True)
                write(directory/f'schedule-{round_number}.json', schedule)
                write(directory/'gradients.json', traces)
                model.eval()
                trials = [rollout(task, preflight/'classes', directory, operators, model, args.device,
                                  f'learned-r{round_number}', seed+i) for i, task in enumerate(tasks)]
                write(directory/f'rollouts-{round_number}.json', trials)
                measured = {'round': round_number, **summarize(trials)}
                arm['rounds'].append(measured)
                print(f'{variant}/{seed} round {round_number}: {measured}', flush=True)
                torch.save({'state_dict': model.state_dict(), 'variant': variant, 'width': 128, 'layers': 3,
                            'seed': seed, 'round': round_number, 'contract': CONTRACT}, directory/f'policy-{round_number}.pt')
                write(out/'report.json', report)
                if round_number == 2:
                    break
                admission_dir = directory/f'aggregation-{round_number}'; admission_dir.mkdir()
                admissions = []
                for task, trial in zip(tasks, trials):
                    for index, snapshot in enumerate(trial['snapshots']):
                        name = f'{task["id"]}-{index}'
                        record, items = collect_label(preflight/'classes', task, admission_dir, name,
                                                      snapshot['prefix'], snapshot['snapshot'])
                        if not items and (snapshot['snapshot']['draft'] or snapshot['snapshot']['actions']['holes']):
                            admissions.append(record)
                            record, items = collect_label(preflight/'classes', task, admission_dir, name+'-recovery',
                                                          snapshot['prefix'], snapshot['snapshot'], recovery=True)
                        if items:
                            try:
                                for item in items:
                                    encode(item['observation'], operators, {int(k): v for k, v in item['archive'].items()})
                                added.append((task['id'], items))
                            except (ValueError, KeyError) as error:
                                record.update(status='ENCODING_NOT_ADMITTED', error=str(error))
                        admissions.append(record)
                        write(admission_dir/'coverage.json', admissions)
                measured['aggregation'] = dict(Counter(r['status'] for r in admissions))
                measured['newSupervisionKinds'] = dict(Counter(i['kind'] for _, items in added for i in items))
                write(out/'report.json', report)
            arm.update(seconds=time.monotonic()-start, encoderDelta=float((model.scalar.weight-initial_encoder).norm()),
                       peakCudaAllocatedBytes=torch.cuda.max_memory_allocated() if args.device == 'cuda' else 0,
                       peakCudaReservedBytes=torch.cuda.max_memory_reserved() if args.device == 'cuda' else 0)
            final = arm['rounds'][-1]
            arm['oneTaskGate'] = bool(trials[0]['solved'])
            arm['eightTaskGate'] = len(tasks) == 8 and final['repairs'] == 8 and final['errors'] == 0
            write(out/'report.json', report)
            del optimizer, model, cache, added
            if args.device == 'cuda': torch.cuda.empty_cache()
        directory = out/f'controls-{seed}'; directory.mkdir()
        for mode in ('uniform', 'noop'):
            trials = [rollout(t, preflight/'classes', directory, operators, None, 'cpu', mode, seed+i)
                      for i, t in enumerate(tasks)]
            write(directory/(mode+'.json'), trials)
            report['controls'].append({'mode': mode, 'seed': seed, **summarize(trials)})
    verify(ROOT, frozen)
    report.update(status='BOUNDED_COMPARISON_COMPLETE', seconds=time.monotonic()-started,
                  gateStatus='EIGHT_PASSED_64_NOT_RUN' if any(a['eightTaskGate'] for a in report['arms'])
                  else 'EIGHT_TASK_GATE_NOT_PASSED')
    write(out/'report.json', report)
    write(out/'output-hashes.json', {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file()})
    print(json.dumps(report, indent=2), flush=True)


if __name__ == '__main__':
    main()
