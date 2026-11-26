"""Run both production canonical distance engines on every original slotted zero."""
import csv
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
GAIN = "classroom_fol/correct/22c33R4ECiCdiSyMg_inv1.als"
# Sorted path, status, left and right predicate (each NUL-terminated), source bytes, then 0xff.
COHORT_SHA256 = "35e6b00f4eb8e32eb0f98f6f65b1bf974c78df1859e9466fba3eb47a7fa90bac"


def prepare_cohort(work):
    paths = (ROOT / "scripts/testdata/natural-slotted-zero-paths.txt").read_text().splitlines()
    if len(paths) != 2228 or len(set(paths)) != 2228 or GAIN in paths:
        raise ValueError("Expected 2,228 distinct original slotted zero paths plus one gain")
    selected = set(paths) | {GAIN}
    expected = {}
    # The archived arm records ordered predicate names for every measured path.
    with (ROOT / "egraph_ablation/slotted-egraph/pairs.csv").open() as stream:
        for row in csv.DictReader(stream):
            path = row["relativePath"]
            if path in selected:
                if path in expected or row["success"] != "true" or row["status"] != "CORRECT":
                    raise ValueError(f"Historical endpoint identity is invalid for {path}")
                expected[path] = (row["status"], row["leftPredicate"], row["rightPredicate"])

    digest = hashlib.sha256()
    for path in sorted(selected):
        identity = expected[path]
        source = (ROOT / "classified-data" / path).read_bytes()
        digest.update(("\0".join((path, *identity)) + "\0").encode())
        digest.update(source)
        digest.update(b"\xff")
        for cohort in (("canonical-cohort", "gain-cohort") if path == GAIN else ("canonical-cohort",)):
            dest = work / cohort / path
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(source)
    if digest.hexdigest() != COHORT_SHA256:
        raise ValueError("The selected predicates or original Alloy source bytes changed")
    return expected


def compare(work, classes, engine, expected, expect_zero):
    cohort = "canonical-cohort" if expect_zero else "gain-cohort"
    out = work / engine
    command = ["java", "-Xmx1g", "-cp", classes + os.pathsep + str(ROOT / "lib/*"),
               "is.fivefivefive.CanDis.EGraphAblationStudy", "--engine", engine,
               "--input", str(work / cohort), "--output", str(out), "--threads", "4"]
    run = subprocess.run(command, cwd=ROOT)
    if run.returncode:
        return [f"{engine} failed with exit code {run.returncode}"]

    failures = []
    seen = set()
    with (out / "pairs.csv").open() as stream:
        for row in csv.DictReader(stream):
            path = row["relativePath"]
            identity = (row["status"], row["leftPredicate"], row["rightPredicate"])
            if path in seen or expected.get(path) != identity:
                failures.append(f"{engine} {path}: duplicate or unexpected {identity}")
            seen.add(path)
            if row["success"] != "true":
                failures.append(f'{engine} {path}: {row["error"]}')
                continue
            distance = int(row["distance"])
            if distance < 0 or (distance == 0) != expect_zero or (row["equivalent"] == "true") != expect_zero:
                failures.append(f'{engine} {path}: distance={distance}, equivalent={row["equivalent"]}')
            if path == GAIN:
                print(f"{engine} strict-gain witness {path}: {distance}", flush=True)
    failures.extend(f"{engine} {path}: missing comparison" for path in sorted(expected.keys() - seen))
    return failures


def main(classes):
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        expected = prepare_cohort(work)
        failures = compare(work, classes, "slotted-egraph", {GAIN: expected[GAIN]}, False)
        for engine in ("canonical", "typed-slotted-port-egraph"):
            failures.extend(compare(work, classes, engine, expected, True))
    if failures:
        raise SystemExit("\n".join(failures))
    print("Both canonical arms retained all 2,228 original slotted zeros and recovered the strict-gain pair.")


if __name__ == "__main__":
    main(sys.argv[1])
