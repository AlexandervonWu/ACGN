#!/usr/bin/env python3
"""Finite empirical release gates; never promotes results or creates a tag."""
import argparse
from collections import Counter
import csv
import json
import math
from pathlib import Path
import sys
from audit_fast_certified_distances import rows, sha256

ARMS = ("raw-egraph", "raw-egraph-debruijn", "java-egglog", "java-egglog-debruijn",
        "slotted-egraph", "canonical", "typed-slotted-port-egraph")


def summary(path, tail=False):
    with path.open("rb") as stream:
        if tail:
            stream.seek(max(0, path.stat().st_size - 4 * 1024**2))
        text = stream.read(4 * 1024**2).decode("utf-8")
    return json.JSONDecoder().raw_decode(text.split('\n  "summary": ', 1)[1])[0]


def load(path):
    if path.stat().st_size > 64 * 1024**2:
        raise ValueError("Refusing oversized JSON: " + str(path))
    return json.loads(path.read_text())


def csv_rows(path):
    with path.open(newline="") as stream:
        return list(csv.DictReader(stream))


def pair_keys(data, field):
    keys = set()
    for row in data["pairs"]:
        if row["rawAstDistance"] <= 0 or row[field] != 0:
            raise ValueError("Invalid zero-pair evidence")
        endpoints = tuple(sorted((r["kind"], r["source"], r["name"]) for r in (row["left"], row["right"])))
        key = (row["questionSet"], row["invariantId"], endpoints)
        if key in keys:
            raise ValueError("Duplicate zero-pair evidence")
        keys.add(key)
    if data["pairCount"] != len(keys):
        raise ValueError("Zero-pair census mismatch")
    return keys


def near_fourteen(value):
    return math.isfinite(value) and 13 <= value <= 15


def synthetic_checks(manifest, observations):
    ids = [r["id"] for r in observations]
    scheduled = manifest["trials"]
    if not (manifest["complete"] and manifest["timeoutSeconds"] == 60
            and manifest["workers"] == 8 and manifest["heap"] == "768m"
            and len(ids) == len(set(ids)) == len(scheduled) == 1080
            and set(ids) == {r["id"] for r in scheduled}):
        return False
    expected = {r["id"]: r for r in scheduled}
    coverage = Counter()
    for row in observations:
        original = expected[row["id"]]
        if any(row[k] != original[k] for k in
               ("arm", "predicateKey", "sourceSha256", "bindings", "types")):
            return False
        if row["status"] not in ("SUCCESS", "TIMEOUT"):
            return False
        if not (2 <= row["bindings"] <= 10 and 1 <= row["types"] <= row["bindings"]):
            return False
        coverage[row["bindings"], row["types"], row["arm"]] += 1
    return coverage == Counter({(n, m, a): 10 for n in range(2, 11)
                                for m in range(1, n + 1) for a in ("typed", "untyped")})


def verify(art, baseline):
    checks, inputs = [], {}
    def pin(path):
        inputs[str(path)] = sha256(path)
        return path
    def check(name, passed, details):
        checks.append(dict(id=name, status="PASS" if passed else "BLOCKED", evidence=details))
    batch = pin(art / "distance_results/distances.json")
    previous = pin(baseline / "distance_results/distances.json")
    census = summary(batch, True)
    expected = dict(total=66080, successes=61598, skippedIdenticalRawAstPairs=4482,
                    failures=0, rewardFailures=0, incorrectCanonicalZero=0, inexactAlphaSearches=0)
    check("G01-census", all(census.get(k) == v for k, v in expected.items()),
          {k: census.get(k) for k in expected})
    identity_fields = ("statusFolder", "leftPredicate", "rightPredicate", "rawAstTreeDistance")
    old = {r["relativePath"]: tuple(r[k] for k in identity_fields)
           for r in rows(previous) if r.get("success") is True}
    seen, zeros = {}, [set(), set()]
    sums = [0, 0]
    incorrect, differences, inexact, invalid = [], [], [], []
    distances = {}
    for row in rows(batch):
        if row.get("success") is not True:
            continue
        path = row["relativePath"]
        if path in seen:
            raise ValueError("Duplicate batch path: " + path)
        seen[path] = tuple(row[k] for k in identity_fields)
        values = (row["legacyCanonicalDistance"], row["distance"])
        distances[path] = values
        if any(type(v) is not int or v < 0 for v in values):
            invalid.append(path)
        if row.get("quotientDistanceExactForStoredOrbits") is not True:
            inexact.append(path)
        if values[0] != values[1]:
            differences.append(path)
        for arm, value in enumerate(values):
            sums[arm] += value
            if value == 0:
                zeros[arm].add(path)
                if row["statusFolder"] != "CORRECT":
                    incorrect.append(path)
    check("G02-ast-population", len(seen) == 61598 and seen == old, dict(current=len(seen), baseline=len(old)))
    means = [s / len(seen) if seen else float("nan") for s in sums]
    check("G03-means", all(near_fourteen(v) for v in means),
          dict(fast=means[0], certified=means[1], inclusiveRange=[13, 15],
               denominator=len(seen), population="full eligible natural corpus",
               totalFiles=66080, astIdenticalExcluded=4482,
               allFilesMeansIncludingAstIdenticalZeroes=[s / 66080 for s in sums]))
    check("G04-no-incorrect-paired-zero", not incorrect and not invalid and not inexact,
          dict(incorrect=incorrect, invalid=invalid, inexact=inexact))
    check("G05-identical-paired-zero-subset", zeros[0] == zeros[1],
          dict(fast=len(zeros[0]), certified=len(zeros[1]), symmetricDifference=sorted(zeros[0] ^ zeros[1])))
    check("G06-equal-paired-distances", not differences, dict(count=len(differences), paths=differences))
    aug = summary(pin(art / "alloy4fun-augmented/index.json"))
    required = dict(parsedModels=61598, parseFailures=0, incorrectModels=42386,
                    incorrectModelsWithNearestDistances=42386, rewardSuccesses=42386,
                    rewardFailures=0, incorrectNearestCertificateIntegratedZeroes=0,
                    incorrectNearestFastRewriteZeroes=0, referencePoolFailures=0,
                    incorrectRankingFailures=0, incorrectModelsWithoutCorrectReference=0,
                    groups=181, oracleReferences=181, uniqueCorrectStudentReferences=4315)
    check("G07-augmenter-census", all(aug.get(k) == v for k, v in required.items()),
          {k: aug.get(k) for k in required})
    truth = []
    for suffix, field in (("fast_rewrite", "fastRewriteCanonicalDistance"), ("canonical", "canonicalDistance")):
        truth.append(pair_keys(load(pin(art / f"alloy4fun-augmented/correct_ast_diff_{suffix}_equiv.json")), field))
    check("G08-identical-correct-pool-subset", truth[0] == truth[1],
          dict(fast=len(truth[0]), certified=len(truth[1]), symmetricDifference=sorted(truth[0] ^ truth[1])))
    nearest = csv_rows(pin(art / "alloy4fun-augmented/canonical_reward_points.csv"))
    check("G09-nearest-truth", len(nearest) == 42386 and len({r["relativePath"] for r in nearest}) == 42386
          and all(int(r["canonicalDistance"]) > 0 and int(r["legacyCanonicalDistance"]) > 0
                  and r["statusFolder"] != "CORRECT" for r in nearest), dict(rows=len(nearest)))
    nearest_diff = [r["relativePath"] for r in nearest if r["canonicalDistance"] != r["legacyCanonicalDistance"]]
    check("G10-equal-nearest-distances", not nearest_diff, dict(count=len(nearest_diff), paths=nearest_diff))
    for arm in ARMS:
        results = csv_rows(pin(art / "egraph_ablation" / arm / "pairs.csv"))
        check("G11-ablation-" + arm, len(results) == 61598
              and {r["relativePath"] for r in results} == set(seen)
              and all(r["success"] == "true" and (r["status"] == "CORRECT" or r["equivalent"] == "false") for r in results),
              dict(rows=len(results)))
        if arm in ("canonical", "typed-slotted-port-egraph"):
            i = 0 if arm == "canonical" else 1
            bad = [r["relativePath"] for r in results if int(r["distance"]) != distances[r["relativePath"]][i]]
            check("G12-batch-ablation-" + arm, not bad, dict(disagreements=bad))
    capability = load(pin(art / "capability_benchmark/results.json"))
    check("G13-capability", capability["pairCount"] == 5500 and len(capability["families"]) == 11
          and all(set(f["arms"]) == set(ARMS) for f in capability["families"])
          and all(r["errors"] == 0 and r["unexpectedFailures"] == 0
                  and (a not in ("canonical", "typed-slotted-port-egraph")
                       or (r["evaluated"] == 500 and r["zero"] == 500 and r["falseNegatives"] == 0))
                  for f in capability["families"] for a, r in f["arms"].items()), dict(pairCount=capability["pairCount"]))
    for rel in ("egraph_ablation/semantic_soundness.json", "capability_benchmark/soundness.json"):
        results = load(pin(art / rel))["checks"]
        bad = [r for r in results if r.get("error") or
               (r.get("outcome") != "NO_COUNTEREXAMPLE" if rel.startswith("egraph_ablation/")
                else r.get("inconclusive") is not False or r.get("solverReportedCounterexample") is not False)]
        check("G14-" + rel, bool(results) and not bad, dict(count=len(results), unresolved=bad))
    slot_zeros = []
    for arm in ("slotted-egraph", "slotted-egraph-typed"):
        results = csv_rows(pin(art / "slot-typing-natural" / arm / "pairs.csv"))
        check("G15-" + arm, len(results) == 61598 and {r["relativePath"] for r in results} == set(seen)
              and all(r["success"] == "true" and (r["status"] == "CORRECT" or r["equivalent"] == "false") for r in results), dict(rows=len(results)))
        slot_zeros.append({r["relativePath"] for r in results if r["equivalent"] == "true"})
    check("G16-slot-zero-subset", slot_zeros[0] == slot_zeros[1], dict(counts=list(map(len, slot_zeros))))
    synthetic = art / "slot-typing-synthetic"
    manifest = load(pin(synthetic / "manifest.json"))
    observations = [json.loads(line) for line in pin(synthetic / "trials.jsonl").read_text().splitlines()]
    check("G17-synthetic", synthetic_checks(manifest, observations),
          dict(rows=len(observations), statuses=dict(Counter(r["status"] for r in observations))))
    return dict(schema="acgn-v3-empirical-gates-v1", status="VERIFIED" if all(c["status"] == "PASS" for c in checks) else "BLOCKED",
                checks=checks, inputSha256=inputs, verifierSha256=sha256(Path(__file__)),
                trusted=["Python", "jq", "JVM/Alloy results", "OS/hardware", "SHA-256"],
                excluded=["unbounded semantic soundness", "full Java-Lean refinement", "global minimum over all Alloy-equivalent programs"],
                releaseRequires="complete manifest verification, clean build/proof evidence, exact-commit CI, immutable unused tag")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--artifacts", required=True, type=Path)
    parser.add_argument("--baseline", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--record-only", action="store_true", help="Record BLOCKED without aborting an otherwise complete measurement schedule")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    try:
        report = verify(args.artifacts, args.baseline)
    except Exception as error:
        report = dict(status="INFRASTRUCTURE_FAILURE", error=type(error).__name__ + ": " + str(error))
    (args.output / "release-gates.json").write_text(json.dumps(report, indent=2, allow_nan=False) + "\n")
    print(report["status"])
    return 2 if report["status"] == "INFRASTRUCTURE_FAILURE" else int(report["status"] != "VERIFIED" and not args.record_only)


if __name__ == "__main__":
    sys.exit(main())
