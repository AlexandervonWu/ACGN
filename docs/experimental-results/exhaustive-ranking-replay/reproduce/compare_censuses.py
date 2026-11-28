"""Compare two independently verified archives and attach every repaired witness to its source."""
import argparse
import csv
import gzip
import hashlib
import itertools
import json
import re
import tempfile
from collections import Counter
from pathlib import Path

COHORT_SHA = "074fbe5573ccf33de100f85cc14a7d0f33c297271b933401ee061d066da99ff5"
REQUIRED = 1_894_168
SOURCE_FIELDS = ("submission", "predicate", "reference", "referencePredicate")
FLOOR_FIELDS = (*SOURCE_FIELDS, "sourceSha256", "referenceSha256")


def sha(path):
    with path.open("rb") as stream:
        digest = hashlib.sha256()
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
        return digest.hexdigest()


def require(value, message):
    if not value:
        raise ValueError(message)


def open_archive(path):
    summary = json.loads((path / "summary.json").read_bytes())
    require(summary["complete"] and summary["inputManifestSha256"] == COHORT_SHA
            and summary["rows"] == REQUIRED, f"Incomplete or foreign census at {path}")
    records = {}
    pending = path / "nonmatching.jsonl.gz"
    require(sha(pending) == summary["nonmatchingSha256"], f"Changed failure records at {path}")
    with gzip.open(pending, "rt") as stream:
        for record in map(json.loads, stream):
            row = record["observation"]
            key = (row["left"], record["referenceId"])
            require(key not in records and row["checked"] is False, f"Invalid native failure at {key}")
            records[key] = record
    require(len(records) == summary["nonconforming"], "Incomplete failure list")
    return summary, records


def comparisons(path, summary):
    for expected_name, chunk in enumerate(summary["chunks"]):
        name = chunk["path"]
        require(name == f"native-ranking-{expected_name:03d}.jsonl.gz"
                and sha(path / name) == chunk["sha256"], f"Changed archive chunk {path / name}")
        with gzip.open(path / name, "rt") as stream:
            for source, group in map(json.loads, stream):
                for entry in group:
                    yield (source, entry[0]), entry


def program(entry, incident, arm):
    if entry[1] in ("F", "T"):
        require(incident is None and len(entry) == 4 and type(entry[2]) is int
                and re.fullmatch("[a-f0-9]{64}", entry[3]), "Malformed successful entry")
        return (entry[1], entry[2], entry[3])
    require(entry[1] == "!" and incident and entry[2] == incident["observation"]["incidentSha256"],
            "Missing genuine incident for nonconforming comparison")
    row = incident["observation"]
    if arm + "SequenceSha256" in row:
        temporal = row["sequenceKind"] == "TEMPORAL_BLOCK_EFFECTS"
        return ("T" if temporal else "F", row[arm + ("BlockCount" if temporal else "ActionCount")],
                row[arm + "SequenceSha256"])
    return None


def source_identity(record):
    row = record["observation"]
    return dict(submission=row["left"], predicate=row["leftPredicate"], sourceSha256=record["leftSha256"],
                reference=row["right"], referencePredicate=row["rightPredicate"], referenceSha256=record["rightSha256"])


def text_row(data):
    return json.dumps(data, sort_keys=True, separators=(",", ":")) + "\n"


def rebuild(before, after, existing_floor, output):
    old, incidents = open_archive(before)
    new, outstanding = open_archive(after)
    require(new["status"] == "VERIFIED" and not outstanding, "Candidate still has failures")
    require(old["producerIdentitySha256"] != new["producerIdentitySha256"]
            and old["measuredJarSha256"] != new["measuredJarSha256"], "Expected two independently measured engines")
    floor = {}
    for record in map(json.loads, existing_floor.read_text().splitlines()):
        key = tuple(record[k] for k in SOURCE_FIELDS)
        require(key not in floor, "Duplicate historical pair")
        floor[key] = {k: record[k] for k in FLOOR_FIELDS}
    size = len(floor)
    rows = 0
    cert = Counter()
    fast = Counter()
    pools = Counter()
    fields = (*FLOOR_FIELDS, "expected", "oldStatus", "oldReason", "firstDifference",
              "oldFastCount", "oldFastSha256", "oldCertifiedCount", "oldCertifiedSha256",
              "newCount", "newSha256", "originalIncident")
    with (output / "repaired-ranking-pairs.csv").open("x", newline="") as stream:
        table = csv.DictWriter(stream, fieldnames=fields, lineterminator="\n")
        table.writeheader()
        for left, right in itertools.zip_longest(comparisons(before, old), comparisons(after, new)):
            require(left and right and left[0] == right[0], "Censuses selected different endpoints or order")
            key, previous = left
            record = incidents.get(key)
            current = program(right[1], None, "certified")
            old_fast = program(previous, record, "fast")
            old_cert = program(previous, record, "certified")
            for original, counts in ((old_fast, fast), (old_cert, cert)):
                counts["unavailable" if original is None else "same" if original == current else "changed"] += 1
            rows += 1
            if record:
                src = source_identity(record)
                pair = tuple(src[k] for k in SOURCE_FIELDS)
                require(pair not in floor or floor[pair] == src, f"Source hash drift at {pair}")
                floor[pair] = src
                observation = record["observation"]
                pools[(src["submission"].split("/")[0], src["predicate"])] += 1
                table.writerow(dict(**src, expected=observation["expected"], oldStatus=observation["status"],
                                    oldReason=observation["reason"], firstDifference=observation.get("firstDifference", ""),
                                    oldFastCount=old_fast[1] if old_fast else "", oldFastSha256=old_fast[2] if old_fast else "",
                                    oldCertifiedCount=old_cert[1] if old_cert else "", oldCertifiedSha256=old_cert[2] if old_cert else "",
                                    newCount=current[1], newSha256=current[2], originalIncident=observation["incidentPath"]))
    require(rows == REQUIRED and sum(pools.values()) == old["nonconforming"], "Incomplete before/after comparison")
    with (output / "paid-rank-witnesses-floor.jsonl").open("x") as stream:
        for key in sorted(floor):
            stream.write(text_row(floor[key]))
    report = dict(rows=rows, originalJar=old["measuredJarSha256"], repairedJar=new["measuredJarSha256"],
                  originalSummarySha256=sha(before / "summary.json"), repairedSummarySha256=sha(after / "summary.json"),
                  originalFastVersusRepairedProgram=dict(fast), originalCertifiedVersusRepairedProgram=dict(cert),
                  originalNonconforming=old["nonconforming"], repairedNonconforming=new["nonconforming"],
                  oldFloor=size, newFloor=len(floor), originalFloorSha256=sha(existing_floor),
                  newFloorSha256=sha(output / "paid-rank-witnesses-floor.jsonl"),
                  repairedPairsCsvSha256=sha(output / "repaired-ranking-pairs.csv"),
                  incidentPools=[dict(question=q, predicate=p, pairs=n) for (q, p), n in sorted(pools.items())])
    (output / "before-after.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("before", "after", "historical_floor", "output"):
        parser.add_argument(name, type=Path)
    args = parser.parse_args()
    if args.output.exists():
        parser.error("output already exists")
    with tempfile.TemporaryDirectory(dir=args.output.parent) as temp:
        root = Path(temp) / "results"
        root.mkdir()
        report = rebuild(args.before, args.after, args.historical_floor, root)
        root.rename(args.output)
    print(json.dumps(report, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
