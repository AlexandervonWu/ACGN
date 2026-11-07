#!/usr/bin/env python3
"""Bounded diagnostic CLI checks; never a publication or corpus completion gate."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--classpath", required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    args.output.mkdir(parents=True, exist_ok=False)
    fixture = args.output / "fixtures" / "both"
    fixture.mkdir(parents=True)
    identical = fixture / "identical_inv.als"
    identical.write_text("sig A {}\npred inv { some A }\npred invc { some A }\n")
    false_zero = fixture / "zero_inv.als"
    false_zero.write_text("sig A {}\npred inv { some A and some A }\npred invc { some A }\n")
    cases = [
        ("equal", root / "classified-data/classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als", None),
        ("equal-product", root / "classified-data/classroom_fol/both/2S5sD2BA5mvLdj46b_inv12.als", None),
        ("equal-scoped-temporal", root / "classified-data/trash_ltl/both/oivT9pBECZFsYCGWq_inv18.als", None),
        ("identical", identical, None),
        ("false-zero", false_zero, "INCORRECT_ZERO"),
    ]
    checks = []
    for label, source, reason in cases:
        available = next(int(line.split()[1]) * 1024 for line in Path("/proc/meminfo").read_text().splitlines()
                         if line.startswith("MemAvailable:"))
        if available < 7 * 1024**3:
            raise RuntimeError("Need 1 GiB probe plus 6 GiB host reserve")
        output = args.output / label
        command = ["java", "-Xmx1g", "-XX:+ExitOnOutOfMemoryError", "-cp", args.classpath,
                   "is.fivefivefive.CanDis.CanonicalBatchTest", str(source), str(output),
                   "--threads", "2", "--skip-rewards", "--diagnostic-components"]
        with (args.output / (label + ".log")).open("w") as log:
            result = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, timeout=60)
        assert (result.returncode != 0) == (reason is not None), (label, result.returncode)
        assert not (output / "distances.json").exists()
        assert not (output / "distances.partial.json").exists()
        assert not (output / "summary.md").exists()
        suffix = "partial.json" if reason else "json"
        report = json.loads((output / ("diagnostic-distances." + suffix)).read_text())
        assert report["diagnosticOnly"] and not report["publicationAllowed"]
        assert report["certificationStatus"] == "BLOCKED"
        assert report["replayWitnessStatus"] == "UNIMPLEMENTED"
        if reason:
            incident = json.loads((output / "parity-incident.json").read_text())
            assert incident["reason"] == reason and incident["scanMode"] == "DIAGNOSTIC_COMPONENTS"
            assert incident["sourceSha256"] == hashlib.sha256(source.read_bytes()).hexdigest()
            assert report["summary"]["successes"] == 0
            assert not (output / "diagnostic-summary.md").exists()
        else:
            assert not (output / "parity-incident.json").exists()
            expected_distance = {"equal": 11, "equal-product": 14, "equal-scoped-temporal": 21}.get(label)
            assert report["summary"]["successes"] == (1 if expected_distance is not None else 0)
            assert report["summary"]["skippedIdenticalRawAstPairs"] == (1 if label == "identical" else 0)
            if expected_distance is not None:
                assert report["results"][0]["distance"] == report["results"][0]["legacyCanonicalDistance"] == expected_distance
            assert "BLOCKED" in (output / "diagnostic-summary.md").read_text()
        checks.append(dict(case=label, reason=reason, exitCode=result.returncode))
    (args.output / "checks.json").write_text(json.dumps(checks, indent=2) + "\n")
    print("PASS: diagnostic continuation, AST exclusion, incorrect-zero stop; certification blocked")


if __name__ == "__main__":
    main()
