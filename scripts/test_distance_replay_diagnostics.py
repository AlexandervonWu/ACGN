#!/usr/bin/env python3
"""Bounded native matrix replay checks; these never discharge full-plan parity."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--classpath', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    args.output.mkdir(parents=True, exist_ok=False)
    source = root / 'classified-data/coursesOld/both/xJnitBpFv9K74WNvf_inv14.als'
    source_hash = hashlib.sha256(source.read_bytes()).hexdigest()
    commands = []

    def run(left, right, output, label):
        memory = Path('/proc/meminfo')
        if memory.exists():
            available = next(int(line.split()[1]) * 1024 for line in memory.read_text().splitlines()
                             if line.startswith('MemAvailable:'))
            if available < 7 * 1024 ** 3:
                raise RuntimeError('Need 7 GiB available for bounded replay and host reserve')
        command = ['java', '-Xmx1g', '-XX:+ExitOnOutOfMemoryError', '-cp', args.classpath,
                   'is.fivefivefive.CanDis.DistanceReplayDiagnostics', str(source), left, right, str(output)]
        with (args.output / (label + '.log')).open('w') as log:
            result = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, timeout=60)
        commands.append(dict(label=label, command=command, exitCode=result.returncode))
        return result.returncode

    costs = []
    for label, left, right in [('forward', 'inv14', 'inv14c'), ('reverse', 'inv14c', 'inv14')]:
        output = args.output / (label + '.json')
        assert run(left, right, output, label) == 0
        report = json.loads(output.read_text())
        assert report['schema'] == 'acgn-matrix-replay-v1'
        assert report['status'] == 'BLOCKED'
        assert report['complete'] is False and report['parityAuthority'] is False
        assert report['sourceSha256'] == source_hash
        assert Path(report['source']).resolve() == source.resolve()
        assert report['leftPredicate'] == left and report['rightPredicate'] == right
        assert report['temporalReplayChecked'] is False
        assert report['quantifierReplayChecked'] is False
        arm_costs = []
        for name in ('fast', 'certified'):
            arm = report[name]
            assert arm['diagnosticStatus'] == 'MATRIX_REPLAY_CHECKED', arm
            assert arm['matrixReplayChecked'] is True and arm['complete'] is False
            assert arm['distance'] == arm['temporalDistance'] + arm['quantifierDistance'] + arm['matrixDistance']
            assert arm['replayedMatrixCost'] == arm['matrixDistance']
            assert sum(phase['receipt']['replayedCost'] for phase in arm['phases']) == arm['matrixDistance']
            arm_costs.append(arm['distance'])
        costs.append(arm_costs)
        before = output.read_bytes()
        assert run(left, right, output, label + '-existing') != 0
        assert output.read_bytes() == before, 'Existing diagnostic evidence overwritten'
    assert costs[0] == costs[1], 'Native residual distances changed with direction'
    assert hashlib.sha256(source.read_bytes()).hexdigest() == source_hash
    (args.output / 'checks.json').write_text(json.dumps(commands, indent=2) + '\n')
    print('PASS: forward/reverse matrix receipts match native costs; incomplete authority and existing evidence protected')


if __name__ == '__main__':
    main()
