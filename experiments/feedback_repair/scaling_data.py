"""Frozen, question-disjoint source selection and training-only causal teachers."""
import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

from .run_gates import ROOT, sha, write, JavaWorker
from .gnn_study import validate_hashes
from .replay import replay
from .tables import encode
from .train_gates import worker
from acgn_repair.corpus_protocol import split_for

PROBLEMS = ('classroom_fol', 'graphs', 'socialMedia', 'coursesNew', 'cv_v1', 'trash_fol')
QUOTAS = {'train': 512, 'validation': 64, 'evaluation': 96}


def select_sources(paths, quotas=None, per_question=32):
    quotas = QUOTAS if quotas is None else quotas
    counts, groups, selected = Counter(), Counter(), []
    for path in sorted(paths, key=lambda p: hashlib.sha256(('feedback-scale-v1:'+p.as_posix()).encode()).digest()):
        preferred = path.stem.rsplit('_', 1)[-1]
        group = path.parts[-3] + ':' + preferred.lower()
        split = split_for(group)
        if counts[split] >= quotas[split] or groups[group] >= per_question: continue
        selected.append({'source': path.as_posix(), 'group': group, 'split': split, 'preferred': preferred,
                         'id': hashlib.sha256(path.as_posix().encode()).hexdigest()[:20]})
        counts[split] += 1; groups[group] += 1
    return selected


def prepare_source(row, out, classes):
    result = dict(row)
    source, derived = ROOT/row['source'], out/'sources'/(row['id']+'.als')
    try:
        process = subprocess.run(['java', '-XX:-UsePerfData', '-Xmx1g', '-cp', str(classes)+os.pathsep+str(ROOT/'lib/*'),
            'is.fivefivefive.CanDis.RepairCorpusSource', str(source), str(derived), row['preferred']],
            capture_output=True, text=True, timeout=30, cwd=ROOT)
        (out/'logs'/(row['id']+'-source.log')).write_text(process.stdout+process.stderr)
        if process.returncode:
            result['status'] = 'AST_IDENTICAL' if 'IllegalArgumentException: AST_IDENTICAL' in process.stderr else 'SOURCE_FAILED'
            result['error'] = process.stderr[-1500:]
        else:
            meta = json.loads(process.stdout)
            if meta['originalHash'] != row['corpusHash'] or meta['target'].lower() != row['preferred'].lower():
                raise ValueError('Source identity mismatch')
            result.update(status='SOURCE_READY', metadata=meta, path='sources/'+derived.name,
                          target=meta['target'], oracle=meta['oracle'], command=meta['command'],
                          sourceHash=meta['derivedHash'])
    except Exception as e:
        result.update(status='SOURCE_FAILED', error=type(e).__name__+': '+str(e))
    return result


def teacher_task(task, out, classes, catalog):
    if task['split'] != 'train': raise ValueError('Held-out teacher prohibited')
    record = {'id': task['id'], 'split': task['split'], 'group': task['group']}
    if task['status'] != 'SOURCE_READY':
        return {**record, 'status': 'SOURCE_UNAVAILABLE', 'error': task.get('error', task['status'])}
    try:
        with (out/'logs'/(task['id']+'-teacher.log')).open('w') as log:
            p = subprocess.run(['java', '-Xmx2g', '-cp', str(classes)+os.pathsep+str(ROOT/'lib/*'),
                'is.fivefivefive.ACGN.repair.FeedbackTeacherMain', str(out/task['path']),
                task['target'], task['oracle'], str(task['command']), '256'],
                cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=log, timeout=30)
        if p.returncode: raise ValueError('Teacher process exit '+str(p.returncode))
        proposal = json.loads(p.stdout)
        if proposal['status'] != 'VALIDATED_LABEL_PATH':
            return {**record, 'status': 'NO_ADMITTED_PATH', 'error': proposal.get('reason')}
        with worker(classes, out/'logs'/(task['id']+'-replay.log')) as w:
            obs = w.request('load', path=str(out/task['path']), target=task['target'], oracle=task['oracle'],
                            command=task['command'], budget=256)['observation']
            trajectory = replay(w, obs, proposal['labels'])
        # Full trajectory must encode before any of its labels are admitted.
        sizes = [len(encode(item['observation'], catalog['operators']).kinds) for item in trajectory['decisions']]
        if not sizes: raise ValueError('Empty teacher')
        write(out/'teachers'/(task['id']+'.json'), trajectory)
        record.update(status='REPLAY_VALIDATED_TEACHER', decisions=len(sizes), maxGraphRows=max(sizes),
                      queries=sum(item['action']['control'] in (11,12) for item in trajectory['decisions']))
    except Exception as e:
        record.update(status='TEACHER_UNAVAILABLE', error=type(e).__name__+': '+str(e))
    return record


def eligible(rows):
    seen, output = set(), []
    for row in rows:
        if row['status'] == 'AST_IDENTICAL': continue
        if row['status'] == 'SOURCE_READY':
            m = row['metadata']; key = (row['group'], m['studentAstHash'], m['oracleAstHash'])
            if key in seen:
                row['status'] = 'DUPLICATE_AST_PAIR'; continue
            seen.add(key)
        output.append(row)
    return output


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('preflight', type=Path); p.add_argument('output', type=Path)
    p.add_argument('--workers', type=int, default=4)
    args = p.parse_args(); pre, out = args.preflight.resolve(), args.output.resolve()
    if out.exists() or out == ROOT or ROOT in out.parents or not 1 <= args.workers <= 4:
        p.error('Fresh external output and 1..4 workers required')
    frozen = json.loads((pre/'input-hashes.json').read_text())
    validate_hashes(ROOT, frozen); validate_hashes(pre, json.loads((pre/'output-hashes.json').read_text()))
    checks = json.loads((pre/'report.json').read_text())
    if checks['tests'].get('ScalingTest') != 9: raise ValueError('Scaling preflight required')
    out.mkdir(); [(out/name).mkdir() for name in ('sources','logs','teachers')]
    started = time.monotonic()
    candidates = [path.relative_to(ROOT) for problem in PROBLEMS for path in (ROOT/'classified-data'/problem).rglob('*.als')
                  if path.parent.name.lower() in ('both','over','under','overconstrained','underconstrained')]
    selected = select_sources(candidates)
    for row in selected: row['corpusHash'] = sha(ROOT/row['source'])
    if Counter(row['split'] for row in selected) != Counter(QUOTAS): raise ValueError('Selection quotas unavailable')
    write(out/'selection.json', {'schema':'feedback-scale-data-v1', 'quotas':QUOTAS, 'perQuestion':32,
                                'problems':PROBLEMS, 'rows':selected, 'selectionUsesTeacherSuccess':False})
    write(out/'input-hashes.json', {**frozen, **{r['source']:r['corpusHash'] for r in selected}})
    with worker(pre/'classes', out/'catalog.log') as w: catalog = w.request('catalog')
    write(out/'catalog.json', catalog)
    rows = []
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        for start in range(0,len(selected),args.workers):
            rows.extend(pool.map(lambda r: prepare_source(r,out,pre/'classes'), selected[start:start+args.workers]))
            write(out/'preparation.json',rows)
            print(f'Source preparation {len(rows)}/{len(selected)}: {dict(Counter(r["status"] for r in rows))}',flush=True)
    tasks = eligible(rows)
    write(out/'preparation.json', rows); write(out/'tasks.json',{'tasks':tasks})
    groups = {}
    for task in tasks:
        if groups.setdefault(task['group'],task['split']) != task['split']: raise ValueError('Question split overlap')
    training = [t for t in tasks if t['split']=='train']; coverage = []
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        for start in range(0,len(training),args.workers):
            coverage.extend(pool.map(lambda t: teacher_task(t,out,pre/'classes',catalog),training[start:start+args.workers]))
            write(out/'teachers/coverage.json',coverage)
            print(f'Teacher collection {len(coverage)}/{len(training)}: {dict(Counter(r["status"] for r in coverage))}',flush=True)
    validate_hashes(ROOT,json.loads((out/'input-hashes.json').read_text()))
    validate_hashes(out,{r['path']:r['sourceHash'] for r in tasks if r['status']=='SOURCE_READY'})
    report={'schema':'feedback-scale-data-v1','status':'FROZEN','seconds':time.monotonic()-started,
            'preflight':str(pre),'preflightHash':sha(pre/'output-hashes.json'),'workers':args.workers,
            'selected':dict(Counter(r['split'] for r in rows)), 'eligible':dict(Counter(t['split'] for t in tasks)),
            'preparation':dict(Counter(r['status'] for r in rows)),
            'questionGroups':dict(Counter(groups.values())), 'teachers':dict(Counter(r['status'] for r in coverage)),
            'trainingDecisions':sum(r.get('decisions',0) for r in coverage)}
    write(out/'report.json',report)
    write(out/'output-hashes.json',{str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file()})
    print(json.dumps(report,indent=2),flush=True)


if __name__=='__main__': main()
