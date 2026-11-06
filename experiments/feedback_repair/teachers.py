"""Offline training-only label construction followed by fresh causal replay."""
import json
import os
import subprocess

from .replay import ReplayRejected, replay


def collect(root, classes, tasks, task_root, output, worker_class):
    records = []
    output.mkdir()
    cp = str(classes) + os.pathsep + str(root / 'lib/*')
    for task in tasks:
        # Eligibility is the frozen question split, not teacher success or labels.
        if task['split'] != 'train':
            continue
        record = {key: task[key] for key in ('id', 'group', 'split')}
        path = task_root / task['path']
        with (output / (task['id'] + '.log')).open('w') as log:
            command = ['java', '-ea', '-Xmx2g', '-cp', cp,
                       'is.fivefivefive.ACGN.repair.FeedbackTeacherMain', str(path),
                       task['target'], task['oracle'], str(task['command']), '256']
            try:
                result = subprocess.run(command, cwd=root, text=True, stdout=subprocess.PIPE, stderr=log, timeout=30)
                if result.returncode:
                    raise RuntimeError(f'Teacher process exit {result.returncode}')
                proposal = json.loads(result.stdout)
                if proposal['status'] != 'VALIDATED_LABEL_PATH':
                    record.update(status='NO_ADMITTED_PATH', reason=proposal['reason'])
                else:
                    worker_command = ['java', '-ea', '-Xmx2g', '-cp', cp,
                                      'is.fivefivefive.ACGN.repair.FeedbackRepairWorker']
                    with worker_class(root, classes, output / (task['id'] + '-replay.log'), timeout=30,
                                      command=worker_command) as worker:
                        initial = worker.request('load', path=str(path), target=task['target'], oracle=task['oracle'],
                                                 command=task['command'], budget=256)['observation']
                        trajectory = replay(worker, initial, proposal['labels'])
                    (output / (task['id'] + '.json')).write_text(json.dumps(trajectory) + '\n', encoding='utf-8')
                    record.update(status='REPLAY_VALIDATED_TEACHER', decisions=len(trajectory['decisions']),
                                  queries=sum(item['action']['control'] in (11, 12) for item in trajectory['decisions']))
            except subprocess.TimeoutExpired:
                record.update(status='TIMEOUT', reason='Teacher exceeded 30 seconds')
            except ReplayRejected as error:
                record.update(status='REPLAY_REJECTED', reason=str(error))
            except (RuntimeError, ValueError, KeyError) as error:
                record.update(status='ERROR', reason=str(error))
        records.append(record)
        (output / 'coverage.json').write_text(json.dumps(records, indent=2) + '\n', encoding='utf-8')
        print(f'Teacher coverage {len(records)}: {record["status"]}', flush=True)
    return records
