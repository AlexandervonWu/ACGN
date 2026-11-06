"""Run proof, regression and real-input coverage gates before any large training."""
import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'rl'))
from acgn_repair.worker import JavaWorker, WorkerError
from .teachers import collect


def sha(path):
    digest = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def write(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n', encoding='utf-8')


def check_tables(observation):
    allowed = {'schema', 'initial', 'current', 'feedback', 'draft', 'draftDeclarations', 'history', 'actions',
               'revision', 'turn', 'remaining', 'status', 'closed'}
    if set(observation) != allowed or observation['schema'] != 'feedback-executor-canonical-v4':
        raise ValueError('Unknown policy observation schema')
    rows = 0
    for group in ('initial', 'current', 'feedback', 'actions', 'decisions'):
        tables = {key: observation[key] for key in ('draft', 'draftDeclarations', 'history')} if group == 'decisions' else observation[group]
        for name, table in tables.items():
            if group == 'feedback' and name == 'omittedWorlds':
                if type(table) is not int or table < 0:
                    raise ValueError('Invalid omission count')
                continue
            if not isinstance(table, list):
                raise ValueError('Non-table input')
            rows += len(table)
            for row in table:
                if not isinstance(row, list) or len(row) > 16:
                    raise ValueError('Invalid fixed-width row')
                if any(type(x) is not int or not -(2**31) <= x < 2**31 for x in row):
                    raise ValueError('Inexact scalar')
    if rows > 8192:
        raise ValueError('Row budget exceeded')
    return rows


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('output', type=Path, help='fresh external output directory')
    p.add_argument('--task-limit', type=int, default=104)
    args = p.parse_args()
    out = args.output.resolve()
    if out.exists() or out == ROOT or ROOT in out.parents:
        p.error('Use a new output directory outside the repository')
    if not 1 <= args.task_limit <= 104:
        p.error('task-limit must be between 1 and 104')
    out.mkdir(parents=True)
    started = time.monotonic()
    classes = out / 'classes'; classes.mkdir()
    commands = []
    test_results = {}
    task_file = ROOT / 'docs/rl-corpus-data/tasks.json'
    tasks = json.loads(task_file.read_text())['tasks'][:args.task_limit]
    proofs = ['IntentRepair', 'FeedbackSession', 'FeedbackLearning', 'FeedbackGNN', 'FeedbackScaling']
    sources = sorted(ROOT.joinpath('src').rglob('*.java'))
    files = [*sources, *ROOT.joinpath('lib').glob('*.jar'), task_file,
             *(ROOT / 'docs/rl-corpus-data' / t['path'] for t in tasks),
             *(ROOT / 'docs/canonical-edit-learning/formal' / (name + '.lean') for name in proofs),
             *Path(__file__).parent.glob('*.py'), ROOT / 'rl/acgn_repair/worker.py',
             ROOT / 'docs/canonical-edit-learning/INTENT-PATH-SPECIFICATION.md',
             ROOT / 'docs/canonical-edit-learning/FEEDBACK-GNN-STUDY.md',
             ROOT / 'docs/canonical-edit-learning/FEEDBACK-SCALING-STUDY.md',
             ROOT / 'rl/acgn_repair/corpus_protocol.py']
    frozen = {str(path.relative_to(ROOT)): sha(path) for path in sorted(set(files))}
    write(out / 'input-hashes.json', frozen)

    def run(command, name, timeout=180, env=None):
        with (out / name).open('w') as log:
            result = subprocess.run(list(map(str, command)), cwd=ROOT, stdout=log,
                                    stderr=subprocess.STDOUT, timeout=timeout, env=env)
        commands.append({'command': list(map(str, command)), 'log': name, 'exitCode': result.returncode})
        if result.returncode:
            write(out / 'commands.json', commands)
            raise RuntimeError(f'{name} failed, exit {result.returncode}')

    for proof in proofs:
        run(['lean', '-o', out / (proof + '.olean'), ROOT / 'docs/canonical-edit-learning/formal' / (proof + '.lean')],
            proof + '.log')
    source_args = out / 'sources.args'
    source_args.write_text('\n'.join(json.dumps(str(path)) for path in sources) + '\n')
    run(['javac', '--release', '17', '-encoding', 'UTF-8', '-cp', ROOT / 'lib/*', '-d', classes, '@' + str(source_args)], 'compile.log')
    cp = str(classes) + os.pathsep + str(ROOT / 'lib/*')
    for name in ('FeedbackRepairTest', 'RepairEnvironmentTest', 'RepairLearningTest'):
        run(['java', '-ea', '-Xmx2g', '-cp', cp, 'is.fivefivefive.ACGN.repair.' + name], name + '.log')
        log = (out / (name + '.log')).read_text()
        pattern = (rf'{name} passed: (\d+) checks' if name == 'FeedbackRepairTest'
                   else rf'RESULT,{name},(\d+)')
        matches = re.findall(pattern, log)
        minimum = {'FeedbackRepairTest': 114, 'RepairEnvironmentTest': 64, 'RepairLearningTest': 38}[name]
        if len(matches) != 1 or int(matches[0]) < minimum:
            raise ValueError('Missing or incomplete test result: ' + name)
        test_results[name] = int(matches[0])

    run([sys.executable, '-m', 'unittest', 'experiments.feedback_repair.test_replay', '-v'], 'ReplayTest.log',
        env={**os.environ, 'FEEDBACK_TEST_CLASSES': str(classes)})
    replay_result = (out / 'ReplayTest.log').read_text()
    if 'Ran 14 tests' not in replay_result or not re.search(r'^OK$', replay_result, re.M):
        raise ValueError('Replay suite did not execute all fourteen tests')
    test_results['CausalReplayTest'] = 14
    run([os.environ.get('ACGN_RL_PYTHON', '/home/augustus/.venvs/acgn-rl-cu130/bin/python'),
         '-m', 'unittest', 'experiments.feedback_repair.test_learning.LearningTest', '-v'], 'LearningBoundaryTest.log',
        env={**os.environ, 'FEEDBACK_TEST_CLASSES': str(classes), 'OMP_NUM_THREADS': '2'})
    learning_log = (out / 'LearningBoundaryTest.log').read_text()
    if 'Ran 7 tests' not in learning_log or not re.search(r'^OK$', learning_log, re.M):
        raise ValueError('Learning boundary suite did not execute all seven tests')
    test_results['LearningBoundaryTest'] = 7
    run([os.environ.get('ACGN_RL_PYTHON', '/home/augustus/.venvs/acgn-rl-cu130/bin/python'),
         '-m', 'unittest', 'experiments.feedback_repair.test_gnn.GNNTest', '-v'], 'GNNTest.log',
        env={**os.environ, 'FEEDBACK_TEST_CLASSES': str(classes), 'OMP_NUM_THREADS': '2'})
    gnn_log = (out / 'GNNTest.log').read_text()
    if 'Ran 7 tests' not in gnn_log or not re.search(r'^OK$', gnn_log, re.M):
        raise ValueError('GNN boundary suite did not execute all seven tests')
    test_results['GNNTest'] = 7
    run([os.environ.get('ACGN_RL_PYTHON', '/home/augustus/.venvs/acgn-rl-cu130/bin/python'),
         '-m', 'unittest', 'experiments.feedback_repair.test_scaling.ScalingTest', '-v'], 'ScalingTest.log',
        env={**os.environ, 'FEEDBACK_TEST_CLASSES': str(classes), 'OMP_NUM_THREADS': '2'})
    scaling_log = (out / 'ScalingTest.log').read_text()
    if 'Ran 9 tests' not in scaling_log or not re.search(r'^OK$', scaling_log, re.M):
        raise ValueError('Scaling boundary suite did not execute all nine tests')
    test_results['ScalingTest'] = 9

    rows = []
    for i, task in enumerate(tasks):
        path = task_file.parent / task['path']
        if sha(path) != task['sourceHash']:
            raise ValueError('Frozen input hash changed')
        record = {'id': task['id'], 'split': task['split'], 'group': task['group']}
        command = ['java', '-ea', '-Xmx2g', '-Djava.awt.headless=true', '-Dfile.encoding=UTF-8',
                   '-cp', cp, 'is.fivefivefive.ACGN.repair.FeedbackRepairWorker']
        try:
            with JavaWorker(ROOT, classes, out / f'task-{i}.log', timeout=30, command=command) as worker:
                obs = worker.request('load', path=str(path), target=task['target'], oracle=task['oracle'],
                                     command=task['command'], budget=256)['observation']
                record['initialRows'] = check_tables(obs)
                if obs['feedback']['worlds'] or obs['history']:
                    raise ValueError('Initial observation has prefetched feedback/history')
                catalog = worker.request('catalog')
                query = {'control': catalog['controls'].index('VALIDATE'), 'revision': 0, 'turn': 0}
                feedback = worker.request('decide', decision=query)['observation']
                record.update(status='OBSERVATION_AND_QUERY_PASS', queryRows=check_tables(feedback),
                              worlds=len(feedback['feedback']['worlds']), validatorStatus=feedback['status'])
        except (WorkerError, ValueError) as error:
            record.update(status='UNSUPPORTED_OR_FAILURE', error=str(error))
        rows.append(record)
        write(out / 'coverage.json', rows)
        print(f'Feedback coverage {i+1}/{len(tasks)}: {record["status"]}', flush=True)

    teachers = collect(ROOT, classes, tasks, task_file.parent, out / 'teachers', JavaWorker)

    # These are explicit outstanding obligations, not capability booleans supplied by a producer.
    open_gates = [
        'Canonical numeric export is bounded: local binders and unrepresentable domains explicitly fail coverage.',
        'Draft masks expose coarse sorts; exact dependent type checking remains a mandatory commit-time check.',
        'Training-only teacher coverage is measured; 1/8/64 free-running learnability and matched controls have not run.',
        'The small graph policy is available in train_gates; Qwen and large scratch consumers remain gated.',
    ]
    changed = [name for name, digest in frozen.items() if sha(ROOT / name) != digest]
    if changed:
        write(out / 'changed-inputs.json', changed)
        raise RuntimeError('Inputs changed during the gate run; results cannot be admitted')
    report = dict(schema='feedback-training-preflight-v1', contract='feedback-intent-path-v1',
                  host=platform.platform(), git=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                  dirty=bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT)),
                  status='BOUNDED_LEARNING_PREFLIGHT', seconds=time.monotonic()-started, tests=test_results,
                  coverage=dict(Counter(row['status'] for row in rows)), taskCount=len(rows),
                  teacherCoverage=dict(Counter(row['status'] for row in teachers)), teacherTasks=len(teachers),
                  stages=[{'name': name, 'status': 'NOT_STARTED_GATE_INCOMPLETE', 'optimizerUpdates': 0}
                          for name in ('GNN', 'Qwen local adaptation', '~500M scratch transformer')],
                  openGates=open_gates, commands=commands)
    write(out / 'report.json', report)
    summary = ['# Feedback Training Preflight', '',
               'Status: **BOUNDED LEARNING PREFLIGHT**. This is an executor coverage report,',
               'not a learned repair result or permission for large model runs.', '',
               f'- Frozen pilot inputs: {len(rows)}. These are not the full corpus.',
               f'- Observation plus one explicit validation query: {report["coverage"].get("OBSERVATION_AND_QUERY_PASS", 0)}/{len(rows)}.',
               f'- Training-only replay-validated teachers: {report["teacherCoverage"].get("REPLAY_VALIDATED_TEACHER", 0)}/{len(teachers)}.',
               '- Teacher validation is not a learned repair score; unavailable paths remain in coverage.',
               '- Optimizer updates: GNN 0; Qwen adaptation 0; roughly 500M transformer 0.',
               '- Java, Alloy, SAT4J, Lean and the OS remain trusted dependencies.', '',
               '## Bounded Checks', '']
    summary.extend(f'- {name}: {count} checks.' for name, count in test_results.items())
    summary += ['', '## Remaining Gates', ''] + ['- ' + item for item in open_gates]
    summary += ['', 'Historical results are unchanged. A passed source/query check is not a repaired',
                'predicate, a learnability result, or proof of complete Java/Lean correspondence.', '']
    (out / 'report.md').write_text('\n'.join(summary), encoding='utf-8')
    write(out / 'output-hashes.json', {str(path.relative_to(out)): sha(path)
          for path in sorted(out.rglob('*')) if path.is_file()})
    print(json.dumps(report, indent=2))
    return 2


if __name__ == '__main__':
    raise SystemExit(main())
