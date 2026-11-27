"""Check original-file hashes, native replay receipts and their full-run distances."""
import csv
import gzip
import hashlib
import json
from functools import lru_cache
from pathlib import Path


def rows(path):
    with gzip.open(path, "rt") as stream:
        yield from map(json.loads, stream)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def endpoints(row):
    return ((row["left"], row["leftPredicate"]), (row["right"], row["rightPredicate"]))


def check_native(row, expected):
    fields = ("endpointCorrespondenceChecked", "sourceCertificatesChecked", "fixedChoiceReplaysChecked")
    require(row["status"] == "MATCHED" and row["reason"] == "CHECKED_NATIVE_ACTIONS_EQUAL"
            and all(row.get(k) is True for k in fields), f"Unverified native replay on {endpoints(row)}")
    require(row["expected"] == row["fastDistance"] == row["certifiedDistance"] == expected,
            f"Wrong native cost on {endpoints(row)}")
    actions = row.get("fastActionCount")
    blocks = row.get("fastBlockCount")
    if actions is not None:
        require(actions >= 0 and actions == row["certifiedActionCount"], "Native action counts differ")
    elif blocks is not None:
        require(blocks > 0 and blocks == row["certifiedBlockCount"] and row.get("orderedBlockEffectsEqual") is True,
                "Ordered native block effects differ")
    else:
        raise ValueError("Missing both action and block evidence")


def verify(out, repo):
    jobs = {}
    data = (repo / "classified-data").resolve()

    @lru_cache(maxsize=None)
    def source_hash(name):
        source = (data / name).resolve()
        require(source.is_relative_to(data), f"Unexpected source path: {name}")
        return hashlib.sha256(source.read_bytes()).hexdigest()

    with gzip.open(out / "native-reference-inputs.tsv.gz", "rt") as stream:
        for kind, source, pred, left_hash, ref, right_pred, right_hash, expected in csv.reader(stream, delimiter="\t"):
            key = kind, (source, pred), (ref, right_pred)
            require(key not in jobs and source_hash(source) == left_hash and source_hash(ref) == right_hash,
                    f"Duplicate comparison or changed input: {key}")
            jobs[key] = int(expected)
    require(len(jobs) == 23415, "Unexpected size for the native supplement")

    zeros, paid, extra = set(), {}, set()
    for row in rows(out / "native-reference-traces.jsonl.gz"):
        kind = row["kind"]
        left, right = endpoints(row)
        expected = jobs.pop((kind, left, right))
        check_native(row, expected)
        if kind == "zero":
            identity = frozenset((left, right))
            require(expected == 0 and len(identity) == 2 and identity not in zeros, "Repeated zero pair")
            zeros.add(identity)
        elif kind == "paid":
            require(expected > 0, "Paid pair has zero cost")
            paid[left, right] = expected
        else:
            require(kind in ("both", "reverse"), f"Unknown trace cohort: {kind}")
            extra.add((kind, left, right, expected))
    require(not jobs, "Missing native replays")
    require(len(extra) == 6 and all((left, right) in paid and paid[left, right] == cost and
            ("reverse", right, left, cost) in extra for kind, left, right, cost in extra if kind == "both")
            and sum(kind == "both" for kind, *_ in extra) == 3, "Bidirectional controls differ")

    catalog = list(rows(repo / "docs/experimental-results/2026-11-25/references.jsonl.gz"))
    actual = {(r["source"], r["name"]): (r["source"], r["operator"]) for r in catalog}
    observed = {frozenset(actual[r[side+"Source"], r[side]] for side in ("left", "right"))
                for r in rows(out / "correct-pool-pairs.jsonl.gz") if r["structuralZero"]}
    require(zeros == observed and len(zeros) == 19271, "Replayed pairs differ from the full structural-zero set")
    require(len(paid) == 4138, "Unexpected number of paid trace identities")

    selection = json.loads((out / "stratified-native-summary.json").read_bytes())
    seed = selection["seed"]
    selected = {}
    for row in rows(out / "stratified-native-traces.jsonl.gz"):
        left, right = endpoints(row)
        key = left, right
        pool = tuple(row["pool"])
        require(key not in paid and pool not in selected and endpoints(row["native"]) == key
                and source_hash(left[0]) == row["leftSourceHash"] and source_hash(right[0]) == row["rightSourceHash"]
                and row["expected"] > 0, "Stratified sample overlaps or has changed endpoints")
        check_native(row["native"], row["expected"])
        selected[pool] = (row["sampleSha256"], key)
        paid[key] = row["expected"]
    require(len(selected) == 181, "Missing sampled pool")

    paired = {(r["path"], r["left"], r["right"]): r["distance"] for r in rows(out / "paired-comparisons.jsonl.gz")}
    predicates = {path: left for path, left, right in paired}
    with gzip.open(out / "paired-native-replays.csv.gz", "rt") as stream:
        for row in csv.DictReader(stream):
            key = row["path"], row["leftPredicate"], row["rightPredicate"]
            require(paired.pop(key) == int(row["fastDistance"]) == int(row["certifiedDistance"])
                    and row["nativeOperationStatus"] == "MATCHED" and row["nativeOperationReason"] == "CHECKED_NATIVE_ACTIONS_EQUAL",
                    f"Unverified student–oracle replay: {key}")
    require(not paired and len(predicates) == 61598, "Incomplete student–oracle replay ledger")
    reference = {r["id"]: (r["source"], r["operator"]) for r in catalog}
    group = {r["id"]: tuple(r["group"]) for r in catalog}
    minima = {}
    for path, ids, fast, certified in rows(out / "ranking-scores.jsonl.gz"):
        left = path, predicates[path]
        for i, a, b in zip(ids, fast, certified, strict=True):
            key = left, reference[i]
            pool = group[i]
            digest = hashlib.sha256("\0".join((seed, *left, *reference[i])).encode()).hexdigest()
            if pool not in minima or digest < minima[pool][0]:
                minima[pool] = digest, key
            if key in paid:
                require(paid.pop(key) == a == b, f"Native replay disagrees with ranked score: {key}")
    require(not paid, "Native replay absent from the measured full ranking")
    require(minima == selected, "The per-pool native sample differs from the seeded selection on the full ranking")
    print("Bound 19,271 zero pairs, 4,138 targeted paid pairs, 181 further paid pairs, and six directional controls to original sources and measured distances.")
