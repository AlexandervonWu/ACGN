"""Compile proofs/runtime, test the local contract, collect training-only teachers."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import time

from .run_gates import ROOT, sha, write
from .local_runtime import collect_label
from .train_gates import worker


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('output', type=Path)
    p.add_argument('--tasks', type=int, default=8, choices=(1, 8, 64))
    args = p.parse_args()
    out = args.output.resolve()
    if out.exists() or ROOT in out.parents:
        p.error('Fresh external output directory required')
    out.mkdir(parents=True)
    start = time.monotonic()
    classes = out/'classes'; classes.mkdir()
    tasks = [t for t in json.loads((ROOT/'docs/rl-corpus-data/tasks.json').read_text())['tasks'] if t['split'] == 'train'][:args.tasks]
    sources = sorted((ROOT/'src').rglob('*.java'))
    inputs = [*sources, *(ROOT/'lib').glob('*.jar'), *(Path(__file__).parent).glob('*.py'),
              *(ROOT/'docs/canonical-edit-learning/formal').glob('*.lean'),
              ROOT/'docs/canonical-edit-learning/formal/check_local_repair.py',
              ROOT/'docs/canonical-edit-learning/LOCAL-REPAIR-STUDY.md', ROOT/'rl/acgn_repair/worker.py',
              ROOT/'docs/canonical-edit-learning/LOCAL-SCALING-STUDY.md', *(ROOT/'rl/acgn_repair').glob('*.py'),
              ROOT/'docs/rl-corpus-data/tasks.json', *(ROOT/'docs/rl-corpus-data'/t['path'] for t in tasks)]
    hashes = {str(path.relative_to(ROOT)): sha(path) for path in sorted(set(inputs))}
    write(out/'input-hashes.json', hashes); write(out/'tasks.json', tasks)
    commands = []

    def run(command, name, env=None):
        with (out/(name+'.log')).open('w') as log:
            r = subprocess.run(list(map(str, command)), cwd=ROOT, stdout=log, stderr=subprocess.STDOUT,
                               timeout=240, env=env)
        commands.append({'name': name, 'exit': r.returncode})
        write(out/'commands.json', commands)
        r.check_returncode()

    run([sys.executable, ROOT/'docs/canonical-edit-learning/formal/check_local_repair.py',
         '--output', out/'proofs'], 'local-proof')
    run(['lean', ROOT/'docs/canonical-edit-learning/formal/LocalRepairArchive.lean'], 'archive-proof')
    run(['lean', ROOT/'docs/canonical-edit-learning/formal/FeedbackScaling.lean'], 'scaling-proof')
    (out/'sources.args').write_text('\n'.join(json.dumps(str(s)) for s in sources)+'\n')
    run(['javac', '--release', '17', '-encoding', 'UTF-8', '-cp', ROOT/'lib/*', '-d', classes,
         '@'+str(out/'sources.args')], 'compile')
    cp = str(classes)+os.pathsep+str(ROOT/'lib/*')
    for name in ('LocalFeedbackRepairTest', 'FeedbackRepairTest', 'RepairEnvironmentTest', 'RepairLearningTest'):
        run(['java', '-ea', '-Xmx2g', '-cp', cp, 'is.fivefivefive.ACGN.repair.'+name], name)
    run([sys.executable, '-m', 'unittest', 'experiments.feedback_repair.test_local',
         'experiments.feedback_repair.test_learning', 'experiments.feedback_repair.test_gnn',
         'experiments.feedback_repair.test_replay', 'experiments.feedback_repair.test_scaling',
         'experiments.feedback_repair.test_local_scaling', '-v'],
        'python-tests', {**os.environ, 'FEEDBACK_TEST_CLASSES': str(classes), 'OMP_NUM_THREADS': '2'})
    with worker(classes, out/'catalog.log') as process:
        write(out/'catalog.json', process.request('catalog'))
    teachers = out/'teachers'; teachers.mkdir()
    coverage = []
    for task in tasks:
        if sha(ROOT/'docs/rl-corpus-data'/task['path']) != task['sourceHash']:
            raise ValueError('SOURCE_HASH_MISMATCH')
        record, _ = collect_label(classes, task, teachers, task['id'])
        coverage.append(record); write(out/'coverage.json', coverage)
        print(f'Local teacher {len(coverage)}/{len(tasks)}: {record["status"]}', flush=True)
    if any(sha(ROOT/name) != digest for name, digest in hashes.items()):
        raise ValueError('INPUTS_CHANGED_DURING_PREFLIGHT')
    write(out/'report.json', {'status': 'PREFLIGHT_COMPLETE', 'commands': commands,
                             'tasks': len(tasks), 'admitted': sum(r['status'] == 'REPLAY_ADMITTED' for r in coverage),
                             'seconds': time.monotonic()-start})
    write(out/'output-hashes.json', {str(p.relative_to(out)): sha(p) for p in sorted(out.rglob('*')) if p.is_file()})


if __name__ == '__main__':
    main()
