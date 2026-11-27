#!/usr/bin/env python3
"""Replay historical paid ranking witnesses against this run's own scalar measurements."""
import argparse
from collections import defaultdict
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def sha(path):
    with path.open("rb") as stream:
        digest = hashlib.sha256()
        for block in iter(lambda: stream.read(8 * 1024 * 1024), b""):
            digest.update(block)
        return digest.hexdigest()


def require(ok, message):
    if not ok:
        raise ValueError(message)


def read_jsonl(path):
    return [json.loads(line) for line in path.read_text().splitlines()]


def identity(row):
    return tuple(row[k] for k in ("submission", "predicate", "reference", "referencePredicate"))


def write_jsonl(path, rows):
    with path.open("x") as stream:
        for row in rows:
            stream.write(json.dumps(row, sort_keys=True, separators=(",", ":")) + "\n")


def require_historical_floor(current, archives):
    identities = {identity(r): (r["sourceSha256"], r["referenceSha256"]) for r in current}
    for archive in archives:
        for row in read_jsonl(archive):
            pair = identity(row)
            require(identities.get(pair) == (row["sourceSha256"], row["referenceSha256"]),
                    f"Lost archived native witness {pair} from {archive}")


def jobs_for_run(floor, rows, dataset, source_endpoint, ranking_scores):
    selected = defaultdict(list)
    unique = set()
    expected = {}
    for row in floor:
        key = identity(row)
        require(key not in unique, f"Repeated floor endpoint pair {key}")
        unique.add(key)
        for name, digest in (("submission", "sourceSha256"), ("reference", "referenceSha256")):
            path = (dataset / row[name]).resolve()
            require(path.is_relative_to(dataset) and sha(path) == row[digest], f"Changed source on {key}")
        selected[key[:2]].append(row)
    require(unique, "Empty paid witness floor")
    for row in rows:
        key = row["relativePath"], row["leftPredicate"]
        if key not in selected:
            continue
        require(row["statusFolder"].upper() in {"BOTH", "OVERCONSTRAINED", "UNDERCONSTRAINED"}, f"Not a measured incorrect submission {key}")
        def scores(field):
            table = {}
            for endpoint, score in ranking_scores(key, row[field]).items():
                original = source_endpoint(row["invariantId"], endpoint)
                require(original not in table, f"Repeated original reference endpoint {original} for {key}")
                table[original] = score
            return table
        fast = scores("legacyCanonicalRanking")
        cert = scores("canonicalRanking")
        for target in selected[key]:
            pair = identity(target)
            ref = pair[2:]
            require(pair not in expected, f"Repeated producer observation on {pair}")
            require(ref in fast and ref in cert and fast[ref] == cert[ref], f"Missing or unequal measured scores on {pair}")
            expected[pair] = {**target, "expected": fast[ref]}
    require(expected.keys() == unique, f"Missing measured ranking pairs: {sorted(unique - expected.keys())}")
    return [expected[k] for k in sorted(expected)]


def inspect_results(jobs, rows):
    expected = {(*identity(r), direction): r["expected"] for r in jobs for direction in ("forward", "reverse")}
    observed = set()
    failures = []
    for row in rows:
        key = (*identity(row), row["direction"])
        require(key in expected and key not in observed, f"Unexpected or repeated witness {key}")
        observed.add(key)
        complete = all(row.get(field) is True for field in (
            "sourceCertificatesChecked", "fixedChoiceReplaysChecked", "endpointCorrespondenceChecked", "nativeSequencesEqual"))
        temporal = row.get("sequenceKind") == "TEMPORAL_BLOCK_EFFECTS"
        count = "BlockCount" if temporal else "ActionCount"
        sequence = (row.get("orderedBlockEffectsEqual") is True if temporal else row.get("sequenceKind") == "FLAT_ACTIONS")
        valid = (complete and sequence and "firstDifference" not in row
                 and all(type(row.get(arm + count)) is int for arm in ("fast", "certified"))
                 and row["fast" + count] >= 0 and row["fast" + count] == row.get("certified" + count)
                 and row["passed"] is True and row["status"] == "MATCHED" and row.get("reason") == "CHECKED_NATIVE_ACTIONS_EQUAL"
                 and row["expected"] == row["fastDistance"] == row["certifiedDistance"] == expected[key])
        if not valid:
            failures.append({"pair": key, "status": row["status"], "reason": row.get("reason")})
    require(observed == expected.keys(), f"Missing native replays: {sorted(expected.keys() - observed)}")
    return failures


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for key in ("repo", "dataset", "artifacts", "output", "floor", "jar"):
        parser.add_argument("--" + key, type=Path, required=key in ("repo", "dataset", "artifacts", "output"))
    args = parser.parse_args()
    repo, dataset, artifacts = (x.resolve() for x in (args.repo, args.dataset, args.artifacts))
    sys.path.insert(0, str(repo / "scripts"))
    from verify_historical_pair_coverage import batch_rows, historical_dataset, source_endpoint, ranking_scores
    output = args.output.resolve()
    output.mkdir()
    summary = {"status": "FAIL"}
    try:
        manifest_path = artifacts / "run-manifest.json"
        manifest = json.loads(manifest_path.read_bytes())
        require(historical_dataset(manifest_path), "Different corpus from the historical evidence")
        jar = (args.jar or Path(manifest["experimentJar"]["path"])).resolve()
        summary.update(runId=manifest["runId"], manifestIdentity=manifest["identitySha256"], jarSha256=sha(jar))
        require(summary["jarSha256"] == manifest["experimentJar"]["sha256"], "Experiment JAR differs from the run manifest")
        floor = args.floor or repo / "docs/historical-pair-coverage/paid-ranking-witnesses.jsonl"
        frozen_floor = output / "floor.jsonl"
        shutil.copyfile(floor, frozen_floor)
        index = artifacts / "alloy4fun-augmented/index.json"
        driver = Path(__file__).resolve().parent / "java/HistoricalRankTraceReplay.java"
        summary.update(floorSha256=sha(frozen_floor), indexSha256=sha(index), driverSha256=sha(driver))
        cohort = read_jsonl(frozen_floor)
        archives = sorted((repo / "docs/experimental-results").glob("*/paid-rank-witnesses-floor.jsonl"))
        require_historical_floor(cohort, archives)
        summary.update(verifierSha256=sha(Path(__file__)),
                       archiveSha256={a.parent.name: sha(a) for a in archives})
        jobs = jobs_for_run(cohort, batch_rows(index, "incorrectNearest"), dataset, source_endpoint, ranking_scores)
        jobs_path = output / "measured-witnesses.jsonl"
        write_jsonl(jobs_path, jobs)
        rows_path = output / "native-replays.jsonl"
        with tempfile.TemporaryDirectory() as temp:
            classpath = f"{jar}:{repo / 'lib'}/*"
            subprocess.run(["javac", "--release", "17", "-cp", classpath, "-d", temp, driver], check=True)
            subprocess.run(["java", "-ea", "-Xmx700m", "-XX:+UseSerialGC", "-XX:ActiveProcessorCount=2",
                            "-cp", f"{temp}:{classpath}", "is.fivefivefive.CanDis.HistoricalRankTraceReplay",
                            dataset, jobs_path, rows_path], check=True, stdout=subprocess.DEVNULL)
        rows = read_jsonl(rows_path)
        failures = inspect_results(jobs, rows)
        summary.update(pairs=len(jobs), directions=len(rows), matched=len(rows) - len(failures), failures=failures,
                       measuredSha256=sha(jobs_path), replaysSha256=sha(rows_path), status="FAIL" if failures else "PASS")
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError) as error:
        summary["error"] = str(error)
    (output / "paid-rank-witnesses.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
    print(json.dumps({k: v for k, v in summary.items() if k != "failures"}, sort_keys=True))
    return int(summary["status"] != "PASS")


if __name__ == "__main__":
    sys.exit(main())
