"""Deterministic 104-input audit; optional real full-context candidate checks.

Run from repository root: python -m experiments.source_local.run PRODUCER OUTPUT
No training, target-based candidate selection, or Python truth evaluator.
"""
import argparse
import gzip
import importlib.util
import json
import os
from pathlib import Path
import sys
from .candidates import candidates
from .prepare import EVIDENCE, sha, verify


def write(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('producer', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--check', action='store_true', help='Check every generated candidate in Java/Alloy')
    args = parser.parse_args(); root = args.producer.resolve(); out = args.output.resolve()
    verified = verify(root)
    if out.exists():
        parser.error('Use a fresh output directory')
    out.mkdir(parents=True)
    sys.path.insert(0, str(root/'rl'))
    from acgn_repair.worker import JavaWorker
    spec = importlib.util.spec_from_file_location('frozen_replay', root/'experiments/feedback_repair/replay.py')
    replay = importlib.util.module_from_spec(spec); spec.loader.exec_module(replay)
    historical = json.loads((EVIDENCE/'natural-coverage.json').read_text())
    tasks = json.loads((root/'docs/rl-corpus-data/tasks.json').read_text())['tasks']
    old = {r['id']: r for r in historical}
    if len(tasks) != 104 or len(old) != 104 or {t['id'] for t in tasks} != set(old):
        raise ValueError('FROZEN_DENOMINATOR_CHANGED')
    if any(t['split'] != old[t['id']]['split'] for t in tasks):
        raise ValueError('FROZEN_SPLIT_CHANGED')
    command = ['java', '-XX:-UsePerfData', '-ea', '-Xmx2g', '-Dfile.encoding=UTF-8', '-cp',
               str(root/'classes')+os.pathsep+str(root/'lib/*'),
               'is.fivefivefive.ACGN.repair.FeedbackRepairWorker']

    def worker(name):
        return JavaWorker(root, root/'classes', out/(name+'.log'), timeout=30, command=command)

    def load(w, task):
        return w.request('load', path=str(root/'docs/rl-corpus-data'/task['path']), target=task['target'],
                         oracle=task['oracle'], command=task['command'], budget=16, queryBudget=2,
                         contract='local-feedback-repair-v1')['observation']

    def execute(w, obs, action, records):
        after = w.request('decide', decision=replay.decision(obs, action))['observation']
        records.append({'before': obs, 'action': action, 'after': after})
        return after

    rows = []
    observations = []
    for task in tasks:
        tid = task['id']; row = {'id': tid, 'split': task['split'], 'historical': old[tid],
            'proposals': 0, 'attempts': [], 'sourceHash': sha(root/'docs/rl-corpus-data'/task['path'])}
        rows.append(row)
        try:
            with worker(tid+'-load') as w:
                catalog = w.request('catalog'); operators = catalog['operators']
                obs = load(w, task); selected = candidates(obs, operators)
                observations.append({'id': tid, 'operators': operators, 'observation': {
                    k: obs[k] for k in ('schema', 'revision', 'current', 'actions', 'draft', 'closed')}})
                row.update(status='SUPPORTED' if selected else 'SHAPE_UNSUPPORTED', proposals=len(selected))
                if selected:
                    write(out/(tid+'-initial.json'), {'observation': obs, 'catalog': catalog})
            # A previously un-loadable task is never silently removed/reclassified.
            if old[tid]['status'] == 'LOAD_FAILED':
                row['historicalLoadChanged'] = True
            if args.check:
                for candidate in selected:
                    name = tid+'-'+candidate.key
                    result = {'key': candidate.key, 'site': candidate.site, 'operand': candidate.operand,
                        'operator': operators[candidate.operator], 'applied': False,
                        'checked': False, 'solved': False}
                    row['attempts'].append(result); records = []
                    try:
                        with worker(name) as w:
                            fresh = load(w, task)
                            # Every candidate starts from the same original source, never accumulates edits.
                            path = candidate.path(fresh)
                            original = fresh
                            fresh = execute(w, fresh, {'control': 11}, records)
                            result['baselineStatus'] = fresh['status']
                            if fresh['status'] != 4 or fresh['closed']:
                                result['end'] = 'BASELINE_NOT_COUNTEREXAMPLE'
                                continue
                            for action in path:
                                fresh = execute(w, fresh, action, records)
                                if fresh['status'] not in (0, 1):
                                    raise ValueError('EDIT_NOT_APPLIED: '+str(fresh['status']))
                            if fresh['status'] != 1 or fresh['revision'] != 1 or fresh['draft']:
                                raise ValueError('COMMIT_REVISION_MISMATCH')
                            candidate.check_commit(original, fresh)
                            result['applied'] = True
                            fresh = execute(w, fresh, {'control': 11}, records)
                            result.update(checked=True, status=fresh['status'],
                                solved=fresh['closed'] and fresh['status'] == 5,
                                end='SOLVED_WITHIN_PROFILE' if fresh['closed'] and fresh['status'] == 5
                                    else 'COUNTEREXAMPLE' if fresh['status'] == 4 else 'INCONCLUSIVE')
                    except Exception as error:
                        result.update(end='ERROR', error=type(error).__name__+': '+str(error))
                    finally:
                        write(out/(name+'.json'), {'result': result, 'records': records})
        except Exception as error:
            row.update(status='LOAD_OR_GENERATION_ERROR', error=type(error).__name__+': '+str(error))
        write(out/'coverage.json', rows)
    attempts = [a for r in rows for a in r['attempts']]
    report = {'schema': 'source-local-cardinality-v1', 'verifiedProducerInputs': verified,
        'historicalCoverageSha256': sha(EVIDENCE/'natural-coverage.json'),
        'denominator': 104, 'historicalWholePredicateSupported': 0,
        'sourceShapeSupported': sum(r['status'] == 'SUPPORTED' for r in rows),
        'loadOrGenerationErrors': sum(r['status'] == 'LOAD_OR_GENERATION_ERROR' for r in rows),
        'generatedProposals': sum(r['proposals'] for r in rows),
        'legallyCommittedCandidates': sum(a['applied'] for a in attempts),
        'tasksWithLegalCandidate': sum(any(a['applied'] for a in r['attempts']) for r in rows),
        'candidateChecksIssued': sum(a['checked'] for a in attempts),
        'conclusiveCandidateChecks': sum(a.get('status') in (4, 5) for a in attempts),
        'solvedCandidates': sum(a['solved'] for a in attempts),
        'solvedTasks': sum(any(a['solved'] for a in r['attempts']) for r in rows) if args.check else None,
        'checkRequested': args.check,
        'interpretation': 'Source coverage, legal candidates, and bounded repair are separate; no learning claim.'}
    write(out/'report.json', report)
    (out/'coverage-observations.json.gz').write_bytes(gzip.compress(
        json.dumps(observations, sort_keys=True).encode(), mtime=0))
    write(out/'hashes.json', {str(p.relative_to(out)): sha(p) for p in sorted(out.iterdir()) if p.is_file()})
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
