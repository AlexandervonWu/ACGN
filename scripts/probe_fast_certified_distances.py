#!/usr/bin/env python3
"""Bounded, sequential replays of archived disagreements, with no engine edits."""
import argparse
import json
import os
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("artifacts", type=Path)
    parser.add_argument("inventory", type=Path)
    parser.add_argument("classes", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--expect-fast-coverage", action="store_true")
    parser.add_argument("--baseline", type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    baseline = {} if args.baseline is None else {
        row["probe"]: row for row in map(json.loads, args.baseline.read_text().splitlines())}
    tasks = []
    for name in ("partial-join", "duplicate-atoms", "type-cost", "chain-cost"):
        tasks.append((name, Path("docs/distance-parity-20261107") / (name + ".als"),
                      "lhs", "rhs", name in ("partial-join", "duplicate-atoms"), None, None, None))
    groups = set()
    pairs = json.loads((args.inventory / "correct-pool-zero-disagreements.json").read_text())
    for i, row in enumerate(pairs):
        group = (row["questionSet"], row["invariantId"], row["canonicalDistance"] == 0)
        tasks.append((f"pool-{i:03d}", Path("classified-data") / row["left"]["source"],
                      row["invariantId"], row["invariantId"], group not in groups,
                      (row["fastRewriteCanonicalDistance"], row["canonicalDistance"]),
                      Path("classified-data") / row["right"]["source"], row["right"]["body"]))
        groups.add(group)
    for name, path in (
            ("temporal", "classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als"),
            ("quantifier", "trash_ltl/over/C8fwykgcniKQBrybn_inv12.als"),
            ("binary-temporal", "trash_ltl/both/oivT9pBECZFsYCGWq_inv18.als"),
            ("typed-natural", "classroom_rl/over/Se6vis3cGzgX7GkN3_inv5.als"),
            ("chain-natural", "productionLine_v1/correct/Nc6rBGbJRWcFSpGY8_inv2.als")):
        pred = Path(path).stem.rsplit("_", 1)[1]
        tasks.append((name, Path("classified-data") / path, pred, pred + "c", False, None, None, None))
    with (args.output / "replays.jsonl").open("w") as stream:
        for index, (name, path, left, right, solve, expected, other, body) in enumerate(tasks):
            available = next(int(line.split()[1]) * 1024 for line in Path("/proc/meminfo").read_text().splitlines()
                             if line.startswith("MemAvailable:"))
            if available < 6 * 1024 ** 3:
                raise RuntimeError("Host memory reserve reached; no next probe launched")
            command = ["java", "-Xmx1g", "-XX:+ExitOnOutOfMemoryError", "-cp",
                       str(args.classes) + os.pathsep + "lib/*",
                       "is.fivefivefive.CanDis.DistanceParityProbe", str(path), left, right]
            command.append("solve" if solve else "skip")
            if other is not None:
                command.extend([str(other), body])
            with (args.output / (name + ".log")).open("w") as log:
                result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=90)
            if result.returncode:
                raise RuntimeError(f"Probe {name} exited {result.returncode}; see retained log")
            lines = (args.output / (name + ".log")).read_text().splitlines()
            row = json.loads(next(line.removeprefix("AUDIT_JSON ") for line in lines if line.startswith("AUDIT_JSON ")))
            row["probe"] = name
            assert row["fast"][0] == row["fastReverse"]
            assert row["certified"][0] == row["certifiedReverse"]
            if expected is not None:
                target = (0, expected[1]) if args.expect_fast_coverage else expected
                assert (row["fast"][0], row["certified"][0]) == target, name
            if baseline:
                for field in ("leftRetained", "rightRetained", "leftProjection", "rightProjection", "certified"):
                    assert row[field] == baseline[name][field], (name, field)
            if solve:
                assert row["counterexampleAtScope4"] is False, name
            stream.write(json.dumps(row, separators=(",", ":")) + "\n")
            stream.flush()
            print(f"{index + 1}/{len(tasks)} {name}: fast={row['fast'][0]} certified={row['certified'][0]} solve={solve}", flush=True)


if __name__ == "__main__":
    main()
