"""Larger local-repair GNNs, on-policy aggregation and locked held-out evaluation."""
import argparse
from collections import Counter, defaultdict
from concurrent.futures import ThreadPoolExecutor
import gc
import json
from pathlib import Path
import platform
import random
import resource
import subprocess
import time

import torch
from .run_gates import ROOT, sha, write
from .gnn_study import validate_hashes
from .gnn_variants import make_policy
from .local_runtime import CONTRACT, collect_label, joint_loss
from .local_scale_data import absolute_task
from .local_scale_bank import training_index, rollin_tasks, LocalBank
from .tables import encode
from .train_local import rollout, summarize
from .train_scaled import select_config
from acgn_repair.corpus_protocol import paired_cluster_interval

CONFIGS = (
    {'name': 'gin-256x4', 'variant': 'gin', 'width': 256, 'layers': 4},
    {'name': 'gin-512x6', 'variant': 'gin', 'width': 512, 'layers': 6},
    {'name': 'gat-256x4', 'variant': 'gat', 'width': 256, 'layers': 4},
    {'name': 'mlp-256x4', 'variant': 'mlp', 'width': 256, 'layers': 4},
)
INITIAL_UPDATES, ROUND_UPDATES, BATCH = 3000, 1000, 8


def evaluate(tasks, dataset, classes, directory, operators, model, device, mode, seed, workers,
             snapshots=False):
    directory.mkdir()
    if snapshots and any(t['split'] != 'train' for t in tasks):
        raise ValueError('TRAIN_ONLY_ROLLIN')
    if model is not None:
        model.eval()

    def run(pair):
        index, task = pair
        if task['status'] != 'SOURCE_READY':
            return {'id': task['id'], 'mode': mode, 'solved': False, 'queries': 0, 'queriesIssued': 0,
                    'decisionsIssued': 0, 'actions': [], 'snapshots': [], 'rejected': 0,
                    'error': 'SOURCE_UNAVAILABLE: '+task.get('error', task['status'])}
        return rollout(absolute_task(task, dataset), classes, directory, operators, model, device,
                       mode, seed+index, retain_snapshots=snapshots)

    rows = []
    concurrency = 1 if model is not None else workers
    with ThreadPoolExecutor(max_workers=concurrency) as pool:
        for offset in range(0, len(tasks), concurrency):
            rows.extend(pool.map(run, list(enumerate(tasks))[offset:offset+concurrency]))
            write(directory/'rollouts.json', rows)
            if len(rows) % 16 == 0 or len(rows) == len(tasks):
                print(f'{directory}: {len(rows)}/{len(tasks)}, repairs={sum(r["solved"] for r in rows)}, '
                      f'errors={sum("error" in r for r in rows)}', flush=True)
    stats = summarize(rows)
    stats.update(queriesIssued=sum(t['queriesIssued'] for t in rows),
                 decisionsIssued=sum(t['decisionsIssued'] for t in rows),
                 errorKinds=dict(Counter(t['error'] for t in rows if 'error' in t)))
    return stats, rows


def aggregate(tasks, trials, dataset, classes, operators, directory, workers):
    directory.mkdir()
    if any(t['split'] != 'train' for t in tasks):
        raise ValueError('TRAIN_ONLY_AGGREGATION')
    if [t['id'] for t in tasks] != [t['id'] for t in trials]:
        raise ValueError('ROLLIN_TASK_MISMATCH')
    jobs = [(task, snapshot, index) for task, trial in zip(tasks, trials)
            for index, snapshot in enumerate(trial['snapshots'][:2])]

    def collect(job):
        task, snapshot, index = job
        name = f'{task["id"]}-{index}'
        actual = absolute_task(task, dataset)
        record, items = collect_label(classes, actual, directory, name, snapshot['prefix'], snapshot['snapshot'])
        records = []
        if not items and (snapshot['snapshot']['draft'] or snapshot['snapshot']['actions']['holes']):
            records.append({**record, 'split': 'train'})
            record, items = collect_label(classes, actual, directory, name+'-recovery',
                                          snapshot['prefix'], snapshot['snapshot'], recovery=True)
        entry = None
        if items:
            try:
                for item in items:
                    encode(item['observation'], operators, {int(k): v for k, v in item['archive'].items()})
                entry = {'id': task['id'], 'path': str(directory/record['trajectory']), 'count': len(items)}
            except (ValueError, KeyError) as error:
                record.update(status='ENCODING_NOT_ADMITTED', error=str(error))
        records.append({**record, 'split': 'train'})
        return records, entry

    coverage, entries = [], []
    with ThreadPoolExecutor(max_workers=workers) as pool:
        for offset in range(0, len(jobs), workers):
            for records, entry in pool.map(collect, jobs[offset:offset+workers]):
                coverage.extend(records)
                if entry is not None:
                    entries.append(entry)
            write(directory/'coverage.json', coverage)
            print(f'Aggregation {directory.name} {min(offset+workers, len(jobs))}/{len(jobs)}: '
                  f'{dict(Counter(r["status"] for r in coverage))}', flush=True)
    write(directory/'coverage.json', coverage)
    return entries, dict(Counter(r['status'] for r in coverage))


def train(config, seed, base, dataset, classes, operators, rollins, directory, device, workers):
    directory.mkdir()
    torch.manual_seed(seed)
    rng = random.Random(seed)
    model = make_policy(config['variant'], config['width'], config['layers']).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=0.0003, weight_decay=0.001)
    bank = LocalBank(operators)
    bank.admit(base)
    initial = model.scalar.weight.detach().clone()
    if device == 'cuda':
        torch.cuda.reset_peak_memory_stats()
    started = time.monotonic()
    record = {'config': config, 'seed': seed, 'parameters': sum(p.numel() for p in model.parameters()),
              'updates': 0, 'finiteNonzeroGradientUpdates': 0, 'clippedUpdates': 0, 'rounds': []}
    added, logs = [], []
    for round_number, cap in enumerate((INITIAL_UPDATES, ROUND_UPDATES, ROUND_UPDATES)):
        write(directory/f'indices-{round_number}.json', {'initial': base, 'aggregated': added})
        schedule, running = [], 0.0
        for update in range(cap):
            optimizer.zero_grad(set_to_none=True)
            model.train()
            batch, value = [], 0.0
            for _ in range(BATCH):
                category = int(bool(added) and rng.randrange(2))
                pool = added if category else base
                ti = rng.randrange(len(pool))
                di = rng.randrange(pool[ti]['count'])
                graph, obs, labels = bank.get(pool[ti], di)
                loss = joint_loss(model, graph.to(device), obs, labels)
                if not torch.isfinite(loss):
                    raise ValueError('NONFINITE_LOSS')
                (loss/BATCH).backward()
                value += float(loss.detach())/BATCH
                batch.append([category, ti, di])
            norm = float(torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0, error_if_nonfinite=True))
            optimizer.step()
            if device == 'cuda' and torch.cuda.max_memory_allocated() > 14*1024**3:
                raise RuntimeError('GPU_ALLOCATION_BUDGET_EXCEEDED')
            record['updates'] += 1
            record['finiteNonzeroGradientUpdates'] += norm > 0
            record['clippedUpdates'] += norm > 1
            schedule.append(batch)
            running += value
            if (update+1) % 100 == 0:
                logs.append({'round': round_number, 'update': record['updates'], 'meanLoss100': running/100,
                             'gradientNorm': norm, 'cacheEstimatedBytes': bank.used,
                             'seconds': time.monotonic()-started})
                running = 0.0
                write(directory/'gradients.json', logs)
                write(directory/'training-report.json', record)
                print(f'{directory.name} {record["updates"]}/5000 loss={logs[-1]["meanLoss100"]:.5f}', flush=True)
        write(directory/f'schedule-{round_number}.json', schedule)
        torch.save({'config': config, 'seed': seed, 'round': round_number, 'contract': CONTRACT,
                    'state_dict': model.state_dict()}, directory/f'policy-{round_number}.pt')
        if round_number < 2:
            stats, trials = evaluate(rollins, dataset, classes, directory/f'rollin-{round_number}', operators,
                                     model, device, 'learned', seed, workers, snapshots=True)
            entries, statuses = aggregate(rollins, trials, dataset, classes, operators,
                                          directory/f'aggregation-{round_number}', workers)
            bank.admit(entries)
            added.extend(entries)
            record['rounds'].append({'round': round_number, 'rollin': stats, 'admission': statuses,
                                    'newTrajectories': len(entries), 'newDecisions': sum(e['count'] for e in entries)})
            write(directory/'training-report.json', record)
    record.update(seconds=time.monotonic()-started, encoderDelta=float((model.scalar.weight.detach()-initial).norm()),
                  peakCudaAllocatedBytes=torch.cuda.max_memory_allocated() if device == 'cuda' else 0,
                  peakCudaReservedBytes=torch.cuda.max_memory_reserved() if device == 'cuda' else 0,
                  hostMaxRssKiB=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss)
    write(directory/'training-report.json', record)
    del optimizer, bank, added
    return model, record


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('dataset', type=Path)
    p.add_argument('output', type=Path)
    p.add_argument('--device', default='cuda')
    p.add_argument('--workers', type=int, default=4)
    args = p.parse_args()
    dataset, out = args.dataset.resolve(), args.output.resolve()
    if out.exists() or out == ROOT or ROOT in out.parents or not 1 <= args.workers <= 4:
        p.error('Fresh external output and 1..4 workers required')
    frozen = json.loads((dataset/'input-hashes.json').read_text())
    evidence = json.loads((dataset/'output-hashes.json').read_text())
    validate_hashes(ROOT, frozen)
    validate_hashes(dataset, evidence)
    data_report = json.loads((dataset/'report.json').read_text())
    if data_report['schema'] != 'local-feedback-scale-data-v1' or data_report['status'] != 'FROZEN':
        raise ValueError('CURRENT_LOCAL_DATA_REQUIRED')
    pre = Path(data_report['preflight'])
    validate_hashes(pre, json.loads((pre/'output-hashes.json').read_text()))
    if sha(pre/'output-hashes.json') != data_report['preflightHash']:
        raise ValueError('PREFLIGHT_IDENTITY_MISMATCH')
    tasks = json.loads((dataset/'tasks.json').read_text())['tasks']
    operators = json.loads((dataset/'catalog.json').read_text())['operators']
    coverage = json.loads((dataset/'teachers/coverage.json').read_text())
    base = training_index(tasks, coverage, dataset/'teachers')
    validation = [t for t in tasks if t['split'] == 'validation']
    testing = [t for t in tasks if t['split'] == 'evaluation']
    if not validation or not testing:
        raise ValueError('HELDOUT_SPLITS_MISSING')
    groups = {}
    for task in tasks:
        if groups.setdefault(task['group'], task['split']) != task['split']:
            raise ValueError('QUESTION_SPLIT_OVERLAP')
    rollins = rollin_tasks(tasks)
    out.mkdir()
    write(out/'rollin-tasks.json', rollins)
    write(out/'input-hashes.json', frozen)
    write(out/'initial-training-index.json', base)
    torch.set_num_threads(2)
    torch.backends.cuda.matmul.allow_tf32 = False
    started = time.monotonic()
    report = {'schema': 'local-feedback-scaling-v1', 'contract': CONTRACT, 'status': 'SCREENING',
              'dataset': str(dataset), 'datasetHash': sha(dataset/'output-hashes.json'), 'data': data_report,
              'git': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
              'dirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT)),
              'host': platform.platform(), 'torch': torch.__version__,
              'gpu': torch.cuda.get_device_name() if args.device == 'cuda' else None,
              'workers': args.workers, 'initialUpdates': INITIAL_UPDATES, 'roundUpdates': ROUND_UPDATES,
              'aggregationRounds': 2, 'batchDecisions': BATCH, 'queryBudget': 4, 'decisionBudget': 256,
              'teacherTasks': len(base), 'teacherDecisions': sum(e['count'] for e in base),
              'smallGatePassed': False, 'scalingAuthorization': 'explicit user-requested diagnostic',
              'screening': [], 'testing': [], 'controls': [], 'replicateTraining': [],
              'laterStages': {'Qwen': 'NOT_RUN', '500M': 'NOT_RUN'}}
    write(out/'report.json', report)
    for order, config in enumerate(CONFIGS):
        directory = out/(config['name']+'-17')
        model, record = train(config, 17, base, dataset, pre/'classes', operators, rollins,
                              directory, args.device, args.workers)
        stats, _ = evaluate(validation, dataset, pre/'classes', directory/'validation', operators,
                             model, args.device, 'learned', 17, args.workers)
        record.update(validation=stats, order=order, directory=directory.name)
        report['screening'].append(record)
        write(out/'report.json', report)
        del model
        gc.collect()
        if args.device == 'cuda': torch.cuda.empty_cache()
    best = select_config(report['screening'])
    config = best['config']
    lock = {'config': config, 'selection': 'validation repairs, parameter count, fixed order',
            'validation': best['validation'], 'parameters': best['parameters'], 'datasetHash': report['datasetHash'],
            'seed17CheckpointHash': sha(out/best['directory']/'policy-2.pt')}
    write(out/'locked-selection.json', lock)
    lock_hash = sha(out/'locked-selection.json')
    report.update(status='LOCKED_TESTING', selection=lock, selectionHash=lock_hash)
    write(out/'report.json', report)
    paired = defaultdict(list)
    for seed in (17, 29, 43):
        directory = out/(config['name']+'-'+str(seed))
        if seed == 17:
            checkpoint = torch.load(directory/'policy-2.pt', map_location=args.device, weights_only=True)
            model = make_policy(config['variant'], config['width'], config['layers']).to(args.device)
            model.load_state_dict(checkpoint['state_dict'], strict=True)
            del checkpoint
        else:
            model, record = train(config, seed, base, dataset, pre/'classes', operators, rollins,
                                  directory, args.device, args.workers)
            report['replicateTraining'].append(record)
        stats, trials = evaluate(testing, dataset, pre/'classes', directory/'evaluation', operators,
                                  model, args.device, 'learned', seed, args.workers)
        report['testing'].append({'seed': seed, **stats})
        write(out/'report.json', report)
        del model
        gc.collect()
        if args.device == 'cuda': torch.cuda.empty_cache()
        for mode in ('noop', 'uniform'):
            stats, controls = evaluate(testing, dataset, pre/'classes', out/(mode+'-'+str(seed)), operators,
                                        None, 'cpu', mode, seed, args.workers)
            report['controls'].append({'seed': seed, 'mode': mode, **stats})
            if mode == 'uniform':
                for task, learned, control in zip(testing, trials, controls):
                    if task['id'] != learned['id'] or task['id'] != control['id']:
                        raise ValueError('PAIRED_IDENTITY_MISMATCH')
                    paired[task['group']].append(int(learned['solved'])-int(control['solved']))
        write(out/'report.json', report)
    if sha(out/'locked-selection.json') != lock_hash:
        raise ValueError('SELECTION_CHANGED_AFTER_TEST_EXPOSURE')
    validate_hashes(ROOT, frozen)
    validate_hashes(dataset, evidence)
    report.update(status='COMPLETE', seconds=time.monotonic()-started,
                  pairedQuestionBootstrap=paired_cluster_interval(paired))
    write(out/'report.json', report)
    write(out/'output-hashes.json', {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file()})
    print(json.dumps(report, indent=2), flush=True)


if __name__ == '__main__':
    main()
