#!/usr/bin/env python3
"""Finite new-mode CLI checks only; no corpus run or certification grant."""
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
    fixtures = args.output / "fixtures" / "both"
    fixtures.mkdir(parents=True)
    reduced = fixtures / "actions_inv.als"
    reduced.write_text("sig A { r,s:set A } pred inv { some r and some s } pred invc { no r and no s }\n")
    cases = [
        ("sase", root / "classified-data/classroom_fol/both/SASEHD8jPo2HgsuoJ_inv14.als", "MATCHED"),
        ("jonx", root / "classified-data/classroom_fol/both/JoNXaXfKNJzGh3BFa_inv12.als", "MATCHED"),
        ("wdi", root / "classified-data/classroom_fol/both/wdiLn4gC6q3bbYBad_inv3.als", "MATCHED"),
        ("d3n2", root / "classified-data/classroom_rl/both/D3n2EfPhBboewRm7z_inv14.als", "MATCHED"),
        ("ae26", root / "classified-data/classroom_rl/over/AE26k3aCggeBrqCrh_inv8.als", "MATCHED"),
        ("5xc5", root / "classified-data/classroom_rl/under/5xC5nGeD2S6zDjCCo_inv14.als", "MATCHED"),
        ("2cc", root / "classified-data/coursesNew/both/2CCEGTS6iiHpRqvCu_inv14.als", "MATCHED"),
        ("5tvx", root / "classified-data/coursesNew/both/5TvX7MDJN22SSvqyR_inv13.als", "MATCHED"),
        ("5vxy", root / "classified-data/coursesNew/both/5vxYh7NCpEPMmC47p_inv14.als", "UNCHECKABLE"),
        ("ljrf", root / "classified-data/coursesNew/both/LJrfWwJdKiTdyytci_inv14.als", "MATCHED"),
        ("wnq", root / "classified-data/coursesNew/correct/wnqMPtpNxnPYzru3g_inv14.als", "MATCHED"),
        ("pvub", root / "classified-data/coursesNew/over/PvuBZf9iKQbBARbsj_inv14.als", "MATCHED"),
        ("temporal", root / "classified-data/classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als", "UNCHECKABLE"),
        ("reduced", reduced, None),
    ]
    checks = []
    for label, source, expected in cases:
        available = next(int(line.split()[1]) * 1024 for line in Path("/proc/meminfo").read_text().splitlines()
                         if line.startswith("MemAvailable:"))
        if available < 7 * 1024**3:
            raise RuntimeError("Need 1 GiB probe plus 6 GiB reserve")
        output = args.output / label
        command = ["java", "-Xmx1g", "-XX:+ExitOnOutOfMemoryError", "-Djava.io.tmpdir=" + str(args.output),
                   "-cp", args.classpath, "is.fivefivefive.CanDis.CanonicalBatchTest", str(source), str(output),
                   "--threads", "1", "--skip-rewards", "--diagnostic-operations"]
        with (args.output / (label + ".log")).open("w") as log:
            result = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, timeout=300)
        stopped = result.returncode != 0
        report = json.loads((output / ("diagnostic-operations-distances.partial.json" if stopped
                                     else "diagnostic-operations-distances.json")).read_text())
        assert report["parityPolicy"] == "diagnostic-native-operations-v1"
        assert report["certificationStatus"] == "BLOCKED" and not report["publicationAllowed"]
        coverage = report["summary"]["nativeOperationReplay"]
        assert coverage["attempted"] == sum(coverage[k] for k in ("matched", "unchecked", "mismatches", "invalidReplay")) == 1
        if stopped:
            incident = json.loads((output / "parity-incident.json").read_text())
            assert expected is None and incident["reason"] == "NATIVE_OPERATION_MISMATCH", (label, incident)
            assert incident["scanMode"] == "DIAGNOSTIC_OPERATIONS"
            assert incident["sourceSha256"] == hashlib.sha256(source.read_bytes()).hexdigest()
            sidecar = json.loads((output / "parity-native-replay.json").read_text())["diagnostic"]
            assert sidecar["status"] == "MISMATCH" and sidecar["scanCostBindingChecked"]
            assert isinstance(sidecar["firstDifference"], int) and sidecar["fastFirst"] != sidecar["certifiedFirst"]
            assert coverage["mismatches"] == 1 and not coverage["matched"]
        else:
            observed = report["results"][0]["nativeOperationStatus"]
            assert observed == (expected or "MATCHED"), (label, observed)
            assert coverage["matched" if observed == "MATCHED" else "unchecked"] == 1
            assert not (output / "parity-incident.json").exists()
        inventory = {p: hashlib.sha256(p.read_bytes()).hexdigest() for p in output.iterdir() if p.is_file()}
        with (args.output / (label + "-no-overwrite.log")).open("w") as log:
            rerun = subprocess.run(command, cwd=root, stdout=log, stderr=subprocess.STDOUT, timeout=300)
        assert rerun.returncode != 0
        assert all(hashlib.sha256(p.read_bytes()).hexdigest() == digest for p, digest in inventory.items())
        checks.append(dict(case=label, stopped=stopped, coverage=coverage))
    (args.output / "checks.json").write_text(json.dumps(checks, indent=2) + "\n")
    print("PASS: native operation CLI match/unchecked/first-incident and no-overwrite; certification BLOCKED")


if __name__ == "__main__":
    main()
