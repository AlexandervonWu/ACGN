"""Exercise the full and descriptive natural-ablation gates through --report-only."""
import csv
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
FROZEN = ROOT / "egraph_ablation"
ENGINES = (
    "raw-egraph", "raw-egraph-debruijn", "java-egglog", "java-egglog-debruijn",
    "slotted-egraph", "canonical", "typed-slotted-port-egraph",
)
BASELINE, FAST, CERT = ENGINES[-3:]


def write_arm(output, engine, rows, zeros, input_path, dataset_hash, limit):
    arm = output / engine
    arm.mkdir(parents=True, exist_ok=True)
    with (arm / "pairs.csv").open("w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(("relativePath", "problemClass", "status", "leftPredicate", "rightPredicate",
                         "success", "equivalent", "distance"))
        for path, status, left, right in rows:
            zero = path in zeros
            writer.writerow((path, path.partition("/")[0], status, left, right, "true",
                             "true" if zero else "false", 0 if zero else 1))
    (arm / "summary.json").write_text('{"overall":{}}')
    (arm / "run.log").write_text("")
    (arm / "process.time").write_text("")
    (arm / "metrics.properties").write_text(
        f"engine={engine}\nthreads=2\nfiles=66080\nsuccesses={len(rows)}\n"
        f"skippedIdenticalRawAstPairs={66080 - len(rows)}\nfailures=0\n"
        f"equivalentPairs={len(zeros)}\n")
    manifest = json.loads((FROZEN / engine / "manifest.json").read_text())
    manifest.update(datasetRoot=str(input_path), datasetSha256=dataset_hash,
                    datasetFileCount=66080, limit=limit, workers=2)
    for entry in manifest["outputs"]:
        data = (arm / entry["path"]).read_bytes()
        entry.update(sha256=hashlib.sha256(data).hexdigest(), sizeBytes=len(data))
    (arm / "manifest.json").write_text(json.dumps(manifest))


def report(output, input_path, classes, expected):
    command = ["java", "-Xmx1g", "-cp", classes + os.pathsep + str(ROOT / "lib/*"),
               "is.fivefivefive.CanDis.EGraphAblationSuite",
               "--report-only", "--input", str(input_path), "--output", str(output)]
    run = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    if (run.returncode == 0) != (expected != "FAILED"):
        raise AssertionError(run.stderr)
    coverage = json.loads((output / "comparison.json").read_text())["slottedZeroCoverage"]
    assert coverage["status"] == expected and expected in (output / "summary.md").read_text()
    return coverage, run.stderr


def main(classes):
    with (FROZEN / BASELINE / "pairs.csv").open() as f:
        rows = [(r["relativePath"], r["status"], r["leftPredicate"], r["rightPredicate"])
                for r in csv.DictReader(f) if r["success"] == "true"]
    original = set((ROOT / "scripts/testdata/natural-slotted-zero-paths.txt").read_text().splitlines())
    lost_original = min(original)
    new_slotted, gain, second, third = [p for p, s, _, _ in rows if s == "CORRECT" and p not in original][:4]
    incorrect = next(p for p, s, _, _ in rows if s != "CORRECT")
    live = (original - {lost_original}) | {new_slotted}
    required = original | live
    sealed = json.loads((FROZEN / BASELINE / "manifest.json").read_text())["datasetSha256"]

    with tempfile.TemporaryDirectory() as tmp:
        output = Path(tmp) / "report"
        relocated = Path(tmp) / "corpus"
        arms = {BASELINE: live, FAST: required | {gain}, CERT: required | {gain}}
        for engine in ENGINES:
            write_arm(output, engine, rows, arms.get(engine, set()), relocated, sealed, 0)
        coverage, _ = report(output, relocated, classes, "PASSED")
        assert coverage["requiredZeros"] == len(required)
        assert all(a["additionalCorrectZeros"] == 1 for a in coverage["arms"])

        # An arm with swapped endpoints has identical paths, labels, distances, and totals.
        path, status, left, right = rows[0]
        swapped = [(path, status, right, left), *rows[1:]]
        write_arm(output, FAST, swapped, arms[FAST], relocated, sealed, 0)
        coverage, _ = report(output, relocated, classes, "FAILED")
        assert any(FAST in issue and "selected predicates" in issue for issue in coverage["issues"])
        write_arm(output, FAST, rows, arms[FAST], relocated, sealed, 0)

        write_arm(output, CERT, [*rows, rows[0]], arms[CERT], relocated, sealed, 0)
        coverage, _ = report(output, relocated, classes, "FAILED")
        assert any(CERT in issue and "duplicate" in issue and path in issue for issue in coverage["issues"])
        write_arm(output, CERT, rows, arms[CERT], relocated, sealed, 0)

        # A strictly larger count can still lose members of either required path set.
        larger = (required - {lost_original, new_slotted}) | {gain, second, third}
        write_arm(output, FAST, rows, larger, relocated, sealed, 0)
        coverage, diagnostic = report(output, relocated, classes, "FAILED")
        fast = coverage["arms"][0]
        assert set(fast["lostPaths"]) == {lost_original, new_slotted}
        assert fast["additionalCorrectZeros"] == 3 and not fast["incorrectZeroPaths"]
        assert all(p in diagnostic for p in (lost_original, new_slotted))
        write_arm(output, FAST, rows, arms[FAST], relocated, sealed, 0)

        # Fail each independent gate even when the other arm passes.
        write_arm(output, CERT, rows, required, relocated, sealed, 0)
        coverage, _ = report(output, relocated, classes, "FAILED")
        assert coverage["arms"][1]["additionalCorrectZeros"] == 0
        write_arm(output, CERT, rows, required | {gain, incorrect}, relocated, sealed, 0)
        coverage, diagnostic = report(output, relocated, classes, "FAILED")
        assert coverage["arms"][1]["incorrectZeroPaths"] == [incorrect] and incorrect in diagnostic

        # A custom corpus enforces its observed zeros. Equality on this small set needs no gain.
        partial = [r for r in rows if r[0] in {lost_original, new_slotted}]
        custom_hash = "1" * 64
        for engine in ENGINES:
            zeros = {new_slotted} if engine in (BASELINE, FAST, CERT) else set()
            write_arm(output, engine, partial, zeros, relocated, custom_hash, 0)
        coverage, _ = report(output, relocated, classes, "DESCRIPTIVE")
        assert coverage["requiredZeros"] == 1
        assert all(a["additionalCorrectZeros"] == 0 for a in coverage["arms"])
        write_arm(output, FAST, partial, set(), relocated, custom_hash, 0)
        coverage, diagnostic = report(output, relocated, classes, "FAILED")
        assert coverage["arms"][0]["lostPaths"] == [new_slotted] and new_slotted in diagnostic

        # A limited run on the original corpus also protects historical zeros it measured.
        for engine in ENGINES:
            zeros = {lost_original, new_slotted} if engine in (FAST, CERT) else set()
            if engine == BASELINE:
                zeros = {new_slotted}
            write_arm(output, engine, partial, zeros, relocated, sealed, 2)
        coverage, _ = report(output, relocated, classes, "DESCRIPTIVE")
        assert coverage["requiredZeros"] == 2
        write_arm(output, CERT, partial, {new_slotted}, relocated, sealed, 2)
        coverage, diagnostic = report(output, relocated, classes, "FAILED")
        assert coverage["arms"][1]["lostPaths"] == [lost_original] and lost_original in diagnostic

        negatives = [next(r for r in rows if r[1] == label)
                     for label in ("BOTH", "OVERCONSTRAINED", "UNDERCONSTRAINED")]
        negative_paths = {r[0] for r in negatives}
        # Both natural and custom comparisons reject known incorrect zeros, independently of gains.
        for source_hash in (sealed, custom_hash):
            for engine in ENGINES:
                zeros = negative_paths if engine == FAST else set()
                write_arm(output, engine, negatives, zeros, relocated, source_hash, len(negatives))
            coverage, diagnostic = report(output, relocated, classes, "FAILED")
            assert set(coverage["arms"][0]["incorrectZeroPaths"]) == negative_paths
            assert all(p in diagnostic for p in negative_paths)

        # A custom folder can carry no correctness label at all.
        unclassified = [("fixture/examples/local.als", "EXAMPLES", "p", "pc")]
        for engine in ENGINES:
            zeros = {unclassified[0][0]} if engine in (FAST, CERT) else set()
            write_arm(output, engine, unclassified, zeros, relocated, custom_hash, 0)
        coverage, _ = report(output, relocated, classes, "DESCRIPTIVE")
        assert all(not a["incorrectZeroPaths"] and a["additionalCorrectZeros"] == 0 for a in coverage["arms"])
        runs = json.loads((output / "comparison.json").read_text())["runs"]
        assert all(r["incorrectEquivalentPairs"] == 0 and r["incorrectPairs"] == 0 for r in runs)

        default_input = ROOT / "classified-data"
        for engine in ENGINES:
            write_arm(output, engine, rows[:4], set(), default_input, "0" * 64, 0)
        coverage, _ = report(output, default_input, classes, "FAILED")
        assert any("fingerprint" in issue for issue in coverage["issues"])
    print("Natural slotted-zero coverage report checks passed")


if __name__ == "__main__":
    main(sys.argv[1])
