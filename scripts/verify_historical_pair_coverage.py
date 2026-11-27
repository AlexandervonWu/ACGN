#!/usr/bin/env python3
"""Check historical natural-corpus equality claims against a fresh run or a release export."""
import argparse
import csv
import gzip
import itertools
import json
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

CORPUS_SHA256 = "d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689"

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "docs/experimental-results"
FLOORS = ROOT / "docs/historical-pair-coverage"
FAST = "canonical"
CERT = "typed-slotted-port-egraph"
METRICS = ("astIdentical", "pairedCohort", "pairedStructural", "pairedFixedCommand",
           "poolCohort", "poolStructural", "poolFixedCommand", "poolCommandContexts")


def require(condition, message):
    if not condition:
        raise ValueError(message)


def open_text(path):
    return gzip.open(path, "rt", newline="") if path.suffix == ".gz" else path.open(newline="")


def table(path):
    with open_text(path) as stream:
        yield from csv.DictReader(stream)


def records(path):
    with open_text(path) as stream:
        for line in stream:
            yield json.loads(line)


def batch_rows(path, section="results"):
    # The producer pretty-prints one complete result object at a time. Stream
    # those objects, including their nested command decisions, without loading
    # the several-hundred-megabyte batch and reward data into memory.
    with path.open() as stream:
        for line in stream:
            if line.strip() == f'"{section}": [':
                break
        else:
            raise ValueError(f"Missing {section} array in {path}")
        for line in stream:
            if line.strip() in ("]", "],"):
                return
            require(line.strip() == "{", f"Unexpected result in {path}: {line[:80]}")
            fields = [line]
            for field in stream:
                fields.append(field)
                if field.startswith("    }"):
                    break
            yield json.loads("".join(fields).strip().rstrip(","))
        raise ValueError(f"Unterminated result array in {path}")


def source_endpoint(invariant, endpoint):
    path, name = endpoint
    if name == invariant + "_oracle":
        return (path, invariant + "c")
    if name.startswith(invariant + "_correct_") and name[len(invariant + "_correct_"):].isdigit():
        return (path, invariant)
    raise ValueError(f"Unknown reference name for {invariant} in {path}: {name}")


def pair(group, left, right):
    left, right = [source_endpoint(group[1], endpoint) for endpoint in (left, right)]
    require(left != right, f"Repeated endpoint {group} {left}")
    a, b = sorted((left, right))
    return (*group, *a, *b)


def context(decision):
    bounds = {k: decision[k] for k in ("bitwidth", "carrierBounds", "traceMin", "traceMax")}
    return json.dumps(bounds, sort_keys=True, separators=(",", ":"))


def unique(bucket, key):
    require(key not in bucket, f"Duplicate observation: {key}")
    bucket.add(key)


def read_decisions(rows, compact):
    coverage = defaultdict(set)
    for r in rows:
        if compact:
            key = (r["path"], r["left"], r["right"])
            status, decisions = r["status"], r["decisions"]
        else:
            key = (r["relativePath"], r["leftPredicate"], r["rightPredicate"])
            require(r["success"] and r["legacyCanonicalDistance"] == r["distance"], f"Batch parity: {key}")
            status, decisions = r["statusFolder"], r["commandComparisons"]
        unique(coverage["pairedCohort"], key)
        require(type(r["distance"]) is int and r["distance"] >= 0, f"Invalid distance: {key}")
        if r["distance"] == 0:
            require(status == "CORRECT", f"Incorrect structural zero: {key}")
            coverage["pairedStructural"].add(key)
        for d in decisions:
            if d["basis"] == "FIXED_COMMAND_RULE":
                require(status == "CORRECT" and d["native"] == "UNSAT" and d["rules"]
                        and d["equivalent"] is True and d["comparisonDistance"] == 0,
                        f"Unsupported fixed-command claim: {key}")
                unique(coverage["pairedFixedCommand"], (*key, d["check"], d["ordinal"], context(d)))
    return coverage


def read_pool(coverage, path):
    for r in records(path):
        group = r["questionSet"], r["invariantId"]
        k = pair(group, (r["leftSource"], r["left"]), (r["rightSource"], r["right"]))
        unique(coverage["poolCohort"], k)
        require(r["scopeStatus"] in {"FIXED_COMMAND_RULE", "NO_RULE_MATCH", "NO_COMMON_COMMAND"},
                f"Unknown command outcome: {k}")
        matched = r["scopeStatus"] == "FIXED_COMMAND_RULE"
        require(type(r["structuralZero"]) is bool and r["equivalent"] is (r["structuralZero"] or matched),
                f"Invalid structural/scoped decision: {k}")
        if r["structuralZero"]:
            coverage["poolStructural"].add(k)
        if matched:
            require(r["native"] == "UNSAT" and r["rules"], f"Unchecked fixed-command link: {k}")
            coverage["poolFixedCommand"].add(k)
            coverage["poolCommandContexts"].add((*k, context(r)))


def ablation(coverage, rows, names, arm):
    seen, zeros = set(), set()
    for row in rows:
        if "success" in row:
            require(row["success"] == "true", f"Failed ablation row: {row[names[0]]}")
        key = tuple(row[n] for n in names)
        unique(seen, key)
        if int(row.get("distance", row.get(arm))) == 0:
            zeros.add(key)
    require(seen == coverage["pairedCohort"], f"Batch and {arm} ablation cohorts differ")
    if arm == "slotted-egraph":
        require(zeros < coverage["pairedStructural"], "Canonical zeros must strictly include live Slotted zeros")
    else:
        require(zeros == coverage["pairedStructural"], f"Batch and {arm} zero sets differ")


def positive_pool(path, field):
    data = json.loads(path.read_bytes())
    edges = set()
    for r in data["pairs"]:
        require(r[field] == 0 and r["rawAstDistance"] > 0, f"Invalid zero in {path}")
        endpoints = [(r[side]["source"], r[side]["name"]) for side in ("left", "right")]
        unique(edges, pair((r["questionSet"], r["invariantId"]), *endpoints))
    require(len(edges) == data["pairCount"], f"Zero-pair census mismatch in {path}")
    return edges


def ranking_scores(path, entries):
    result = {}
    for entry in entries:
        endpoint = (entry["referenceSource"], entry["referenceName"])
        value = entry["distance"]
        require(endpoint not in result and type(value) is int and value > 0,
                f"Invalid reference ranking on {path} against {endpoint}: {value}")
        result[endpoint] = value
    return result


def check_rankings(rows, incorrect_paths):
    """Check every paid score by reference identity, including references beyond the nearest."""
    seen = set()
    comparisons = 0
    for row in rows:
        path = row["relativePath"]
        unique(seen, path)
        fast = ranking_scores(path, row["legacyCanonicalRanking"])
        certified = ranking_scores(path, row["canonicalRanking"])
        require(fast and fast.keys() == certified.keys(), f"Different ranked reference cohorts on {path}")
        for endpoint, score in fast.items():
            require(score == certified[endpoint], f"Ranking differs on {path} against {endpoint}: "
                    f"Fast {score}, Certificate-Integrated {certified[endpoint]}")
        comparisons += len(fast)
    require(seen == incorrect_paths, "Ranked submissions differ from the measured incorrect cohort")
    return comparisons


def load_candidate(directory, compact):
    receipt = directory / ("run-receipt.json" if compact else "run-manifest.json")
    dataset = json.loads(receipt.read_bytes())["dataset"]
    require(dataset["sha256"] == CORPUS_SHA256, f"Historical corpus bytes differ: {directory}")
    if compact:
        c = read_decisions(records(directory / "paired-comparisons.jsonl.gz"), True)
        for arm in (FAST, CERT, "slotted-egraph"):
            ablation(c, table(directory / "ablation-distances.csv.gz"), ("path", "left", "right"), arm)
        c["astIdentical"] = {(s,) for s in (directory / "ast-identical-paths.txt").read_text().splitlines()}
        read_pool(c, directory / "correct-pool-pairs.jsonl.gz")
    else:
        batch = list((directory / "distance_results").glob("*distances.json"))
        require(len(batch) == 1, f"Expected exactly one fresh batch, found {batch}")
        c = read_decisions(batch_rows(batch[0]), False)
        for arm in (FAST, CERT, "slotted-egraph"):
            ablation(c, table(directory / "egraph_ablation" / arm / "pairs.csv"),
                     ("relativePath", "leftPredicate", "rightPredicate"), arm)
        aug = directory / "alloy4fun-augmented"
        c["astIdentical"] = {(r["relativePath"],) for r in table(aug / "ast_identical_predicate_pairs.csv")}
        read_pool(c, aug / "default_correct_pool_equivalences.jsonl")
        incorrect = {r["relativePath"] for r in table(directory / "egraph_ablation" / CERT / "pairs.csv")
                     if r["status"] != "CORRECT"}
        comparisons = check_rankings(batch_rows(aug / "index.json", "incorrectNearest"), incorrect)
        require(comparisons == 1894168, f"Expected 1,894,168 ranked reference scores, found {comparisons}")
        for name, field in (("canonical", "certificateIntegratedDistance"), ("fast_rewrite", "fastRewriteCanonicalDistance")):
            zeros = positive_pool(aug / f"correct_ast_diff_{name}_equiv.json", field)
            require(zeros == c["poolStructural"], f"Direct pool {name} zero set disagrees with pool decisions")
    return c


def snapshot(path):
    with open_text(path) as stream:
        data = json.load(stream)
    require(data["schema"] == "acgn-historical-pairs-v1", f"Unknown historical floor: {path}")
    return {k: {tuple(r) for r in rows} for k, rows in data["claims"].items()}


def historical_floors():
    yield "artifact-freeze-v1", snapshot(FLOORS / "artifact-freeze-v1.json.gz")
    yield "artifact-freeze-v2 and v2.1-v2.17", snapshot(FLOORS / "v2-coverage.json.gz")
    v31 = RESULTS / "2026-11-21-studies/measurements/natural-ablation"
    old = defaultdict(set)
    for row in table(v31 / "pair-distances.csv.gz"):
        key = row["relativePath"], row["leftPredicate"], row["rightPredicate"]
        old["pairedCohort"].add(key)
        if any(row[k] == "0" for k in (FAST, CERT, "slotted-egraph")):
            old["pairedStructural"].add(key)
    yield "v3 and v3.1 paired", old
    v32 = RESULTS / "2026-11-25"
    refs = {r["id"]: r for r in records(v32 / "references.jsonl.gz")}
    for ref in refs.values():
        endpoint = source_endpoint(ref["group"][1], (ref["source"], ref["name"]))
        require(endpoint[1] == ref["operator"], f"Wrong selected predicate: {endpoint}")
    old = defaultdict(set)
    for r in table(v32 / "pairs.csv.gz"):
        a, b = [refs[int(r[s])] for s in ("left", "right")]
        k = pair(a["group"], (a["source"], a["name"]), (b["source"], b["name"]))
        old["poolCohort"].add(k)
        if r["baseline_zero"] == "1":
            old["poolStructural"].add(k)
        if r["forward"]:
            require(r["forward"] == r["reverse"] and r["native"] == "UNSAT", f"Unsupported v3.2 edge: {k}")
            old["poolFixedCommand"].add(k)
        if r["native"] == "SAT":
            old["satControls"].add(k)
    yield "v3.1 structural and v3.2 fixed-command pools", old
    # New full release exports automatically join the floor, independently of
    # their version numbers. Explicitly require the first complete modern export.
    exports = sorted(p.parent for p in RESULTS.glob("*/paired-comparisons.jsonl.gz"))
    require(RESULTS / "v3.3" in exports, "Missing v3.3 release export")
    for directory in exports:
        yield directory.name, load_candidate(directory, True)
    for p in sorted(RESULTS.glob("*/historical-pairs.json.gz")):
        yield p.parent.name + " ratchet", snapshot(p)


def components(edges):
    parent = {}
    def root(v):
        while parent[v] != v:
            parent[v] = parent[parent[v]]
            v = parent[v]
        return v

    def endpoints(k):
        return (*k[:2], *k[2:4]), (*k[:2], *k[4:6])

    for k in edges:
        a, b = endpoints(k)
        parent.setdefault(a, a)
        parent.setdefault(b, b)
        parent[root(a)] = root(b)
    members = defaultdict(list)
    for vertex in parent:
        members[root(vertex)].append(vertex)
    return {(*a, *b[2:]) for vs in members.values() for a,b in itertools.combinations(sorted(vs), 2)}


def measure(c):
    c["poolStructuralComponents"] = components(c["poolStructural"])
    c["poolFixedComponents"] = components(c["poolStructural"] | c["poolFixedCommand"])


def audit(candidate, floors):
    measure(candidate)
    union = defaultdict(set)
    sources = {}
    for label, historical in floors:
        old = defaultdict(set, historical)
        measure(old)
        for k, values in old.items():
            union[k].update(values)
        sources[label] = {k: len(v) for k,v in sorted(old.items()) if v}
    conflicts = sorted(union["satControls"] & candidate["poolFixedComponents"])
    metrics = {}
    for k in (*METRICS, "poolStructuralComponents", "poolFixedComponents"):
        lost = sorted(union[k] - candidate[k])
        metrics[k] = dict(historical=len(union[k]), observed=len(candidate[k]), lost=lost,
                          gained=len(candidate[k] - union[k]))
    passed = not conflicts and all(not m["lost"] for m in metrics.values())
    return dict(status="PASS" if passed else "FAIL", metrics=metrics, sources=sources,
                historicalSatControls=len(union["satControls"]), connectedSatControls=conflicts)


def historical_dataset(manifest):
    return json.loads(manifest.read_bytes())["dataset"]["sha256"] == CORPUS_SHA256


def latest_export():
    dated = {}
    for directory in sorted(p.parent for p in RESULTS.glob("*/paired-comparisons.jsonl.gz")):
        receipt = json.loads((directory / "run-receipt.json").read_bytes())
        require(receipt["status"] == "complete", f"Release has an incomplete run receipt: {directory}")
        instant = datetime.fromisoformat(receipt["completedAt"].replace("Z", "+00:00"))
        require(instant.tzinfo is not None and instant not in dated, f"Ambiguous release time: {directory}")
        dated[instant] = directory
    require(dated, "No complete release ledgers")
    return dated[max(dated)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--artifacts", type=Path, help="full publication run output")
    source.add_argument("--candidate", type=Path, help="compact v3.3-format release tables")
    source.add_argument("--latest", action="store_true", help="check the most recent published full-run ledger")
    parser.add_argument("--output", type=Path, help="write counts and every lost identity as JSON")
    parser.add_argument("--write-floor", type=Path, help="save new positive claims for the next edition after passing")
    args = parser.parse_args()
    if args.latest:
        args.candidate = latest_export()
        print(f"Checking latest release export {args.candidate.name}")
    candidate = load_candidate(args.candidate or args.artifacts, args.candidate is not None)
    report = audit(candidate, historical_floors())
    if args.output:
        args.output.write_text(json.dumps(report, indent=2) + "\n")
    for k,m in report["metrics"].items():
        print(f"{k}: {m['historical']} historical, {m['observed']} observed, {len(m['lost'])} lost")
    if report["status"] != "PASS":
        print(f"Failed historical retention; {len(report['connectedSatControls'])} connected SAT controls", file=sys.stderr)
        return 1
    if args.write_floor:
        claims = {k: sorted(candidate[k]) for k in METRICS if k not in ("pairedCohort", "poolCohort")}
        with args.write_floor.open("xb") as out, gzip.GzipFile(fileobj=out, mode="wb", mtime=0) as compressed:
            compressed.write(json.dumps(dict(schema="acgn-historical-pairs-v1", claims=claims),
                                        separators=(",", ":")).encode())
    return 0


if __name__ == "__main__":
    sys.exit(main())
