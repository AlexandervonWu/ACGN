"""Recheck the full working evidence and regenerate the descriptive audit."""
import collections
import hashlib
import json
from pathlib import Path
import sys
import tarfile


def read(path):
    return json.loads(path.read_text())


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check(root, manifest):
    values = read(manifest)
    for name, expected in values.items():
        assert digest(root / name) == expected, name
    return len(values)


def archive_check(path, manifest, prefixes):
    expected = {name: value for name, value in manifest.items()
                if any(name.startswith(prefix) for prefix in prefixes)}
    seen = set()
    with tarfile.open(path, 'r:gz') as archive:
        for member in archive:
            if member.isdir():
                continue
            assert member.isfile() and member.name in expected, member.name
            assert member.name not in seen, member.name
            assert hashlib.sha256(archive.extractfile(member).read()).hexdigest() == expected[member.name]
            seen.add(member.name)
    assert seen == set(expected), 'Incomplete archive'
    return len(seen)


def trials(rows):
    return {
        'tasks': len(rows), 'repairs': sum(row['solved'] for row in rows),
        'budgetExhausted': sum(len(row['decisions']) == 256 for row in rows),
        'queries': sum(row['queries'] for row in rows),
        'rejections': sum(row.get('rejected', 0) for row in rows),
        'errors': dict(collections.Counter(row['error'] for row in rows if 'error' in row)),
        'rejectedControls': dict(collections.Counter(
            step['action']['control'] for row in rows for step in row['decisions']
            if step['status'] in (2, 3))),
    }


def main():
    root, pre, data, study = map(Path, sys.argv[1:])
    local = Path(__file__).resolve().parent
    report = read(study / 'report.json')
    assert report['status'] == 'COMPLETE'
    hashes = {
        'inputs': check(root, data / 'input-hashes.json'),
        'preflightOutputs': check(pre, pre / 'output-hashes.json'),
        'datasetOutputs': check(data, data / 'output-hashes.json'),
        'studyOutputs': check(study, study / 'output-hashes.json'),
    }
    assert digest(pre / 'output-hashes.json') == report['data']['preflightHash']
    assert digest(data / 'output-hashes.json') == report['datasetHash']
    assert digest(study / 'locked-selection.json') == report['selectionHash']
    selected = min(report['screening'], key=lambda a: (
        -a['validation']['repairs'], a['parameters'], a['order']))
    assert selected['config'] == report['selection']['config']
    assert digest(study / selected['directory'] / 'policy.pt') == report['selection']['seed17CheckpointHash']
    schedules = {a['scheduleHash'] for a in report['screening']}
    assert len(schedules) == 1
    tasks = read(data / 'tasks.json')['tasks']
    groups = collections.defaultdict(set)
    for task in tasks:
        groups[task['group']].add(task['split'])
    assert all(len(splits) == 1 for splits in groups.values())
    ids = {split: {t['id'] for t in tasks if t['split'] == split}
           for split in ('train', 'validation', 'evaluation')}
    coverage = read(data / 'teachers/coverage.json')
    assert all(row['split'] == 'train' and row['id'] in ids['train'] for row in coverage)
    evaluation = {}
    for path in sorted(study.rglob('rollouts.json')):
        rows = read(path)
        split = 'validation' if path.parent.name == 'validation' else 'evaluation'
        assert len(rows) == len(ids[split]) and {row['id'] for row in rows} == ids[split]
        assert all(row['queries'] <= 2 and len(row['decisions']) <= 256 for row in rows)
        evaluation[str(path.relative_to(study))] = trials(rows)
    statuses, controls = collections.Counter(), collections.Counter()
    for row in coverage:
        if row['status'] != 'REPLAY_VALIDATED_TEACHER':
            continue
        teacher = read(data / 'teachers' / (row['id'] + '.json'))
        assert teacher['finalObservation']['closed'] and teacher['finalObservation']['status'] == 5
        for step in teacher['decisions']:
            statuses[step['observation']['status']] += 1
            controls[step['action']['control']] += 1
    fits = report['screening'] + report['replicateTraining']
    output = {
        'hashChecks': hashes, 'selectionHash': report['selectionHash'],
        'pairedScreeningScheduleHash': next(iter(schedules)),
        'teacherObservationStatuses': dict(statuses), 'teacherControls': dict(controls),
        'updates': sum(f['updates'] for f in fits),
        'finiteNonzeroGradientUpdates': sum(f['finiteNonzeroGradientUpdates'] for f in fits),
        'clippedUpdates': sum(f['clippedUpdates'] for f in fits),
        'trainingSeconds': sum(f['seconds'] for f in fits),
        'studySeconds': report['seconds'],
        'pipelineSeconds': report['seconds'] + report['data']['seconds'] + read(pre / 'report.json')['seconds'],
        'peakTrainingCudaAllocatedBytes': max(f['peakCudaAllocatedBytes'] for f in fits),
        'peakTrainingCudaReservedBytes': max(f['peakCudaReservedBytes'] for f in fits),
        'hostProcessMaxRssKiB': max(f['hostMaxRssKiB'] for f in fits),
        'trials': evaluation,
        'archivedReplayFiles': archive_check(local / 'dataset/replay-data.tar.gz',
                                             read(data / 'output-hashes.json'), ('sources/', 'teachers/')),
    }
    schedule_manifest = {name: value for name, value in read(study / 'output-hashes.json').items()
                         if name.endswith('/schedule.json')}
    output['archivedSchedules'] = archive_check(local / 'study/sampling-schedules.tar.gz',
                                                schedule_manifest, tuple(schedule_manifest))
    (local / 'audit.json').write_text(json.dumps(output, indent=2, sort_keys=True) + '\n')
    print(json.dumps(output, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
