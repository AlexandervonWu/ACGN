"""Replay identified original failures and optional historical witnesses on a separately pinned engine, both ways."""
import argparse
import csv
import datetime
import gzip
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

DRIVER_SHA = "a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02"
INPUT_SHA = "074fbe5573ccf33de100f85cc14a7d0f33c297271b933401ee061d066da99ff5"


def sha(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def require(v, why):
    if not v:
        raise ValueError(why)


def jsonl(path):
    with path.open() as stream:
        yield from map(json.loads, stream)


def source_key(row):
    return row["left"], row["leftPredicate"], row["right"], row["rightPredicate"]


def marked(original, include_history):
    by_shard = {}
    marked = {}
    captured = []
    since = datetime.datetime.now(datetime.timezone.utc).isoformat()
    files_at_start = sorted((original / "results/incidents").glob("shard-*.json.gz"))
    until = datetime.datetime.now(datetime.timezone.utc).isoformat()
    for file in files_at_start:
        match = re.fullmatch(r"(shard-\d{4})-(\d+)-[0-9a-f-]{36}\.json\.gz", file.name)
        require(match, f"Unexpected original incident path {file}")
        shard, raw_ordinal = match.groups()
        group = by_shard.setdefault(shard, {})
        require(int(raw_ordinal) not in group, f"Duplicate incident object for {shard}/{raw_ordinal}")
        group[int(raw_ordinal)] = file
    for shard, files in by_shard.items():
        ledger = original / "results" / (shard + ".jsonl")
        for row in jsonl(ledger):
            file = files.pop(row["ordinal"], None)
            if file is None:
                continue
            require(row["checked"] is False and row["incidentPath"] == "incidents/" + file.name
                    and row["incidentSha256"] == sha(file), "Original native incident drift")
            with gzip.open(file, "rt") as stream:
                archive = json.load(stream)
            require(archive["identity"] == {k: v for k,v in row.items() if k not in ("incidentPath", "incidentSha256")},
                    "Original native action identity differs from its ledger")
            key = source_key(row)
            floor = (archive["leftSha256"], archive["rightSha256"])
            require(key not in marked, f"Duplicate old incident at {key}")
            marked[key] = (floor, {"baselineFailure"}, row["expected"])
            captured.append(dict(shard=shard, ordinal=row["ordinal"], incidentPath=row["incidentPath"],
                                 incidentSha256=row["incidentSha256"], left=row["left"], right=row["right"],
                                 leftPredicate=row["leftPredicate"], rightPredicate=row["rightPredicate"],
                                 leftSha256=floor[0], rightSha256=floor[1], expected=row["expected"], nativeStatus=row["status"]))
            if not files:
                break
        require(not files, f"Original incident index is not fully flushed in {shard}; retry after the writer flushes")
    if include_history:
        history = original / "frozen/docs/experimental-results/historical-retention/paid-rank-witnesses-measured.jsonl"
        for row in jsonl(history):
            key = (row["submission"], row["predicate"], row["reference"], row["referencePredicate"])
            floor = (row["sourceSha256"], row["referenceSha256"])
            existing = marked.setdefault(key, (floor, set(), row["expected"]))
            require(existing[0] == floor and existing[2] == row["expected"], "Archived witness drift")
            existing[1].add("historical83")
    captured.sort(key=lambda entry: (entry["shard"], entry["ordinal"]))
    return marked, dict(listingStartedUtc=since, listingFinishedUtc=until, runnerSha256=DRIVER_SHA, incidents=captured)


def select_jobs(original, marked):
    cohort = original / "cohort"
    require(sha(cohort / "manifest.json") == INPUT_SHA, "Wrong ranked cohort")
    manifest = json.loads((cohort / "manifest.json").read_bytes())
    pools = {(k[0].split("/")[0], k[1]) for k in marked}
    jobs = []
    seen = set()
    for shard in manifest["shards"]:
        if tuple(shard["pool"]) not in pools:
            continue
        path = cohort / shard["path"]
        require(sha(path) == shard["sha256"], f"Changed original ranked input at {path}")
        with path.open() as stream:
            for row in csv.reader(stream, delimiter="\t"):
                key = (row[1], row[2], row[4], row[5])
                if key in marked:
                    endpoint_sha, groups, cost = marked[key]
                    require(key not in seen and row[0] == "paid" and (row[3], row[6]) == endpoint_sha and int(row[7]) == cost,
                            "Historical endpoint selection or cost changed")
                    seen.add(key)
                    jobs.append((row, sorted(groups)))
    require(bool(jobs) and seen == marked.keys(), "Incomplete original-forward selection recovery")
    return jobs


def run_slice(original, jar, output, name, jobs):
    output.mkdir()
    (output / "incidents").mkdir()
    spec = []
    for row, groups in jobs:
        spec.append((row, groups, "forward"))
        spec.append(([row[0], *row[4:7], *row[1:4], row[7]], groups, "reverse"))
    inputs = output / "inputs.tsv"
    with inputs.open("x") as stream:
        for row, _, _ in spec:
            stream.write("\t".join(row) + "\n")
    lib = original / "frozen/lib/*"
    cmd = ["java", "-Xmx650m", "-XX:+UseSerialGC", "-XX:ActiveProcessorCount=1", "-cp",
           f"{original}/runner-classes:{jar}:{lib}", "is.fivefivefive.CanDis.ExhaustiveNativeReplay",
           original / "frozen/classified-data", output, "3"]
    with (output / "worker.log").open("x") as log:
        subprocess.run(cmd, input=f"{name}\t{inputs}\t0\n", text=True, stdout=log, stderr=subprocess.STDOUT, check=True)
    rows = list(jsonl(output / (name + ".jsonl")))
    require(len(rows) == len(spec), "Incomplete candidate native measurements")
    results = []
    for i, ((job, groups, direction), row) in enumerate(zip(spec, rows)):
        require(source_key(row) == (job[1], job[2], job[4], job[5]) and row["ordinal"] == i and row["expected"] == int(job[7]),
                "Returned observation belongs to another original selection")
        matched = (row["status"] == "MATCHED" and row["reason"] == "CHECKED_NATIVE_ACTIONS_EQUAL"
                   and row.get("fastDistance") == row["expected"] == row.get("certifiedDistance")
                   and all(row.get(x) is True for x in ("nativeSequencesEqual", "endpointCorrespondenceChecked",
                                                         "fixedChoiceReplaysChecked", "sourceCertificatesChecked"))
                   and re.fullmatch("[a-f0-9]{64}", row.get("fastSequenceSha256", ""))
                   and row["fastSequenceSha256"] == row["certifiedSequenceSha256"])
        temporal = row.get("sequenceKind") == "TEMPORAL_BLOCK_EFFECTS"
        count = "BlockCount" if temporal else "ActionCount"
        matched = bool(matched and (row.get("orderedBlockEffectsEqual") is True if temporal else row.get("sequenceKind") == "FLAT_ACTIONS")
                       and all(type(row.get(a + count)) is int and row[a + count] >= 0 for a in ("fast", "certified"))
                       and row["fast" + count] == row["certified" + count] and "firstDifference" not in row)
        require(row["checked"] is matched, "Independent verifier disagrees with observed native checks")
        if not matched:
            require(sha(output / row["incidentPath"]) == row["incidentSha256"], "Corrupt candidate native incident")
        results.append(dict(groups=groups, direction=direction, **row))
    return results


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("workspace", type=Path); p.add_argument("jar", type=Path)
    p.add_argument("expected_jar_sha256"); p.add_argument("output", type=Path)
    p.add_argument("--workers", type=int, default=2); p.add_argument("--include-history", action="store_true")
    args = p.parse_args()
    if args.output.exists() or not 1 <= args.workers <= len(os.sched_getaffinity(0)):
        p.error("expected a fresh output and positive available worker count")
    original = args.workspace.resolve()
    require(sha(args.jar) == args.expected_jar_sha256 and sha(original / "runner-identity.json") == DRIVER_SHA,
            "Unregistered native engine or changed original adapter")
    identity = json.loads((original / "runner-identity.json").read_bytes())
    for path, h in identity["files"].items():
        if path.startswith(("runner-classes/", "frozen/lib/")):
            require(sha(original / path) == h, "Unregistered driver or dependency: " + path)
    selection, snapshot = marked(original, args.include_history)
    jobs = select_jobs(original, selection)
    with tempfile.TemporaryDirectory(dir=args.output.parent) as temp:
        root = Path(temp) / "evidence"
        root.mkdir()
        (root / "original-incident-snapshot.json").write_text(json.dumps(snapshot, sort_keys=True, indent=2) + "\n")
        with ThreadPoolExecutor(max_workers=args.workers) as pool:
            pending = []
            for i in range(min(len(jobs), args.workers)):
                name = f"part-{i:03d}"
                pending.append(pool.submit(run_slice, original, args.jar.resolve(), root / name, name, jobs[i::args.workers]))
            rows = [r for t in pending for r in t.result()]
        with (root / "native-observations.jsonl").open("x") as stream:
            for row in rows:
                stream.write(json.dumps(row, sort_keys=True, separators=(",", ":")) + "\n")
        errors = [r for r in rows if not r["checked"]]
        summary = dict(status="BLOCKED" if errors else "VERIFIED", pairs=len(jobs), directions=len(rows),
                       failures=len(errors), firstFailure=errors[0] if errors else None,
                       cohorts=dict(Counter(g for _, gs in jobs for g in gs)), engineSha256=args.expected_jar_sha256,
                       inputManifestSha256=INPUT_SHA, adapterIdentitySha256=DRIVER_SHA,
                       originalIncidentSnapshotSha256=sha(root / "original-incident-snapshot.json"),
                       verifierSha256=sha(Path(__file__)), ledgerSha256=sha(root / "native-observations.jsonl"),
                       partInputSha256={path.parent.name: sha(path) for path in sorted(root.glob("part-*/inputs.tsv"))},
                       partOutputSha256={path.parent.name: sha(path) for path in sorted(root.glob("part-*/*.jsonl"))})
        (root / "summary.json").write_text(json.dumps(summary, sort_keys=True, indent=2) + "\n")
        root.rename(args.output)
    print(json.dumps({k:v for k,v in summary.items() if k!="firstFailure"}, sort_keys=True))
    return 2 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
