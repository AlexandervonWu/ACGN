"""Frozen question-disjoint larger corpus with replayed local-repair teachers."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import json
from pathlib import Path
import time

from .run_gates import ROOT, sha, write
from .gnn_study import validate_hashes
from .scaling_data import PROBLEMS, QUOTAS, select_sources, prepare_source, eligible
from .local_runtime import CONTRACT, collect_label
from .tables import encode


def absolute_task(task, root):
    path = (root/task['path']).resolve()
    if not path.is_relative_to(root.resolve()) or sha(path) != task['sourceHash']:
        raise ValueError('SOURCE_IDENTITY_MISMATCH')
    return {**task, 'path': str(path)}


def teacher_task(task, out, classes, operators):
    if task['split'] != 'train':
        raise ValueError('TRAIN_ONLY')
    if task['status'] != 'SOURCE_READY':
        return {'id': task['id'], 'split': 'train', 'status': 'SOURCE_UNAVAILABLE'}
    record, items = collect_label(classes, absolute_task(task, out), out/'teachers', task['id'])
    record.update(split='train', group=task['group'])
    if items:
        try:
            sizes = [len(encode(i['observation'], operators,
                                {int(k): v for k, v in i['archive'].items()}).kinds) for i in items]
            record['maxGraphRows'] = max(sizes)
        except (ValueError, KeyError) as error:
            record.update(status='ENCODING_NOT_ADMITTED', error=str(error))
    return record


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('preflight', type=Path)
    p.add_argument('output', type=Path)
    p.add_argument('--workers', type=int, default=4)
    args = p.parse_args()
    pre, out = args.preflight.resolve(), args.output.resolve()
    if out.exists() or out == ROOT or ROOT in out.parents or not 1 <= args.workers <= 4:
        p.error('Fresh external output and 1..4 workers required')
    frozen = json.loads((pre/'input-hashes.json').read_text())
    validate_hashes(ROOT, frozen)
    validate_hashes(pre, json.loads((pre/'output-hashes.json').read_text()))
    checks = json.loads((pre/'report.json').read_text())
    if checks['status'] != 'PREFLIGHT_COMPLETE' or not (pre/'scaling-proof.log').exists():
        raise ValueError('CURRENT_LOCAL_SCALING_PREFLIGHT_REQUIRED')
    out.mkdir()
    for name in ('sources', 'logs', 'teachers'):
        (out/name).mkdir()
    start = time.monotonic()
    candidates = [path.relative_to(ROOT) for problem in PROBLEMS
                  for path in (ROOT/'classified-data'/problem).rglob('*.als')
                  if path.parent.name.lower() in ('both', 'over', 'under', 'overconstrained', 'underconstrained')]
    selected = select_sources(candidates)
    for row in selected:
        row['corpusHash'] = sha(ROOT/row['source'])
    if Counter(r['split'] for r in selected) != Counter(QUOTAS):
        raise ValueError('SELECTION_QUOTAS_UNAVAILABLE')
    write(out/'selection.json', {'schema': 'local-feedback-scale-data-v1', 'quotas': QUOTAS,
          'perQuestion': 32, 'problems': PROBLEMS, 'rows': selected, 'selectionUsesTeacherSuccess': False})
    write(out/'input-hashes.json', {**frozen, **{r['source']: r['corpusHash'] for r in selected}})
    catalog = json.loads((pre/'catalog.json').read_text())
    write(out/'catalog.json', catalog)
    rows = []
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        for offset in range(0, len(selected), args.workers):
            rows.extend(pool.map(lambda r: prepare_source(r, out, pre/'classes'), selected[offset:offset+args.workers]))
            write(out/'preparation.json', rows)
            if len(rows) % 32 == 0 or len(rows) == len(selected):
                print(f'Prepare {len(rows)}/{len(selected)}: {dict(Counter(r["status"] for r in rows))}', flush=True)
    tasks = eligible(rows)
    write(out/'preparation.json', rows)
    write(out/'tasks.json', {'tasks': tasks})
    groups = {}
    for task in tasks:
        if groups.setdefault(task['group'], task['split']) != task['split']:
            raise ValueError('QUESTION_SPLIT_OVERLAP')
    training = [t for t in tasks if t['split'] == 'train']
    coverage = []
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        for offset in range(0, len(training), args.workers):
            coverage.extend(pool.map(lambda t: teacher_task(t, out, pre/'classes', catalog['operators']),
                                     training[offset:offset+args.workers]))
            write(out/'teachers/coverage.json', coverage)
            print(f'Local teachers {len(coverage)}/{len(training)}: '
                  f'{dict(Counter(r["status"] for r in coverage))}', flush=True)
    validate_hashes(ROOT, json.loads((out/'input-hashes.json').read_text()))
    validate_hashes(out, {t['path']: t['sourceHash'] for t in tasks if t['status'] == 'SOURCE_READY'})
    write(out/'report.json', {'schema': 'local-feedback-scale-data-v1', 'contract': CONTRACT, 'status': 'FROZEN',
          'seconds': time.monotonic()-start, 'preflight': str(pre), 'preflightHash': sha(pre/'output-hashes.json'),
          'workers': args.workers, 'selected': dict(Counter(r['split'] for r in rows)),
          'eligible': dict(Counter(t['split'] for t in tasks)), 'preparation': dict(Counter(r['status'] for r in rows)),
          'questionGroups': dict(Counter(groups.values())), 'teachers': dict(Counter(r['status'] for r in coverage)),
          'trainingDecisions': sum(r.get('decisions', 0) for r in coverage if r['status'] == 'REPLAY_ADMITTED')})
    write(out/'output-hashes.json', {str(f.relative_to(out)): sha(f) for f in sorted(out.rglob('*')) if f.is_file()})
    print((out/'report.json').read_text(), flush=True)


if __name__ == '__main__':
    main()
