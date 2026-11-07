#!/usr/bin/env python3
"""Bounded CLI regression: each invocation must stop at its only eligible pair."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--classpath", required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    args.output.mkdir(parents=True, exist_ok=False)
    results = []
    for label, relative, reason in (
            ("distance", "classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als", "DISTANCE_MISMATCH"),
            ("missing-replay", "classroom_rl/over/Se6vis3cGzgX7GkN3_inv5.als", "REPLAY_WITNESS_UNAVAILABLE")):
        source = root / "classified-data" / relative
        target = args.output / label
        memory = Path("/proc/meminfo")
        if memory.exists():
            available = next(int(line.split()[1]) * 1024 for line in memory.read_text().splitlines()
                             if line.startswith("MemAvailable:"))
            if available < 7 * 1024**3:
                raise RuntimeError("Insufficient memory for 1 GiB probe plus 6 GiB host reserve")
        command = ["java", "-Xmx1g", "-XX:+ExitOnOutOfMemoryError", "-cp", args.classpath,
                   "is.fivefivefive.CanDis.CanonicalBatchTest", str(source), str(target),
                   "--threads", "2", "--skip-rewards"]
        with (args.output / (label + ".log")).open("w") as log:
            result = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, timeout=45)
        if result.returncode == 0:
            raise AssertionError("Parity violation exited successfully")
        incident = json.loads((target / "parity-incident.json").read_text())
        assert incident["reason"] == reason, incident
        assert incident["sourceSha256"] == hashlib.sha256(source.read_bytes()).hexdigest()
        assert incident["sourceText"] == source.read_text()
        native = json.loads((target / incident["nativeReplayFile"]).read_text())
        assert native["sourceSha256"] == incident["sourceSha256"]
        assert native["captureStatus"] == "CAPTURED", native
        assert not native["complete"] and not native["parityAuthority"]
        diagnostic = native["diagnostic"]
        assert diagnostic["status"] == "BLOCKED" and not diagnostic["parityAuthority"]
        for arm in ("fast", "certified"):
            assert diagnostic[arm]["distance"] == incident[arm][0]
            assert diagnostic[arm]["numericalCostCoverage"]
            assert diagnostic[arm]["orderedDiagnosticActions"]
        partial = json.loads((target / "distances.partial.json").read_text())
        assert partial["summary"]["successes"] == 0
        assert not (target / "distances.json").exists()
        assert not (target / "summary.md").exists()
        results.append(dict(case=label, exitCode=result.returncode, reason=reason, command=command))
    (args.output / "checks.json").write_text(json.dumps(results, indent=2) + "\n")
    print("PASS: both one-pair CLI checks stopped, retained witnesses, and published no complete results")


if __name__ == "__main__":
    main()
