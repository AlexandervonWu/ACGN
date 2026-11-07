#!/usr/bin/env python3
"""Read archived measurements; never rerun or mutate an experiment."""
import argparse
from collections import Counter
import csv
import hashlib
import json
from pathlib import Path
import subprocess


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def rows(path):
    # jq supplies a structural JSON stream, avoiding a corpus-sized object graph.
    query = 'select(length == 2 and (.[0]|length) == 3 and .[0][0] == "results")'
    process = subprocess.Popen(["jq", "-c", "--stream", query, str(path)],
                               stdout=subprocess.PIPE, text=True)
    index, row = None, {}
    for line in process.stdout:
        key, value = json.loads(line)
        if key[1] != index:
            if row:
                yield row
            index, row = key[1], {}
        row[key[2]] = value
    if row:
        yield row
    if process.wait() != 0:
        raise RuntimeError("jq could not read the complete distance archive")


def direction(fast, certified):
    return "equal" if fast == certified else "certifiedGreater" if certified > fast else "fastGreater"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("artifacts", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    inputs = [args.artifacts / "distance_results/distances.json"]
    fields = ["relativePath", "statusFolder", "distance", "legacyCanonicalDistance",
              "quotientTemporalDistance", "legacyTemporalDistance",
              "quotientQuantifierDistance", "legacyQuantifierDistance",
              "quotientMatrixDistance", "legacyMatrixDistance"]
    totals, components, classes, deltas = Counter(), Counter(), {}, Counter()
    mismatches = {}
    with (args.output / "paired-mismatches.csv").open("w", newline="") as stream:
        writer = csv.DictWriter(stream, fields)
        writer.writeheader()
        for row in rows(inputs[0]):
            if not row.get("success"):
                continue
            fast, certified = row["legacyCanonicalDistance"], row["distance"]
            totals["successful"] += 1
            totals[direction(fast, certified)] += 1
            totals["zeroDisagreements"] += (fast == 0) != (certified == 0)
            totals["fastSum"] += fast
            totals["certifiedSum"] += certified
            deltas[certified - fast] += 1
            classes.setdefault(row["problemClass"], Counter())[direction(fast, certified)] += 1
            for name in ("Temporal", "Quantifier", "Matrix"):
                components[name] += row["quotient" + name + "Distance"] != row["legacy" + name + "Distance"]
            if fast != certified:
                item = {key: row[key] for key in fields}
                writer.writerow(item)
                mismatches[row["relativePath"]] = item
    # Cross-check every successful paired row against the separate ablation stage.
    ablation = {}
    for arm in ("canonical", "typed-slotted-port-egraph"):
        path = args.artifacts / "egraph_ablation" / arm / "pairs.csv"
        inputs.append(path)
        with path.open() as stream:
            ablation[arm] = {r["relativePath"]: int(r["distance"]) for r in csv.DictReader(stream)
                             if r["success"] == "true"}
    ablation_mismatches = {p: (v, ablation["typed-slotted-port-egraph"][p])
                          for p, v in ablation["canonical"].items()
                          if v != ablation["typed-slotted-port-egraph"][p]}
    assert ablation_mismatches == {p: (r["legacyCanonicalDistance"], r["distance"])
                                   for p, r in mismatches.items()}
    nearest = Counter()
    path = args.artifacts / "alloy4fun-augmented/canonical_reward_points.csv"
    inputs.append(path)
    with path.open() as stream:
        for row in csv.DictReader(stream):
            fast, certified = int(row["legacyCanonicalDistance"]), int(row["canonicalDistance"])
            nearest["rows"] += 1
            nearest[direction(fast, certified)] += 1
            nearest["fastZeroes"] += fast == 0
            nearest["certifiedZeroes"] += certified == 0
    zero_misses = {}
    for suffix in ("canonical", "fast_rewrite"):
        path = args.artifacts / f"alloy4fun-augmented/correct_ast_diff_{suffix}_equiv.json"
        inputs.append(path)
        with path.open() as stream:
            pairs = json.load(stream)["pairs"]
        for row in pairs:
            if row["canonicalDistance"] != row["fastRewriteCanonicalDistance"]:
                key = (row["augmentedFile"], row["left"]["name"], row["right"]["name"])
                zero_misses[key] = row
    zero_rows = list(zero_misses.values())
    (args.output / "correct-pool-zero-disagreements.json").write_text(json.dumps(zero_rows, indent=2) + "\n")
    summary = {"sourceArtifacts": str(args.artifacts), "paired": totals,
               "components": components, "byClass": classes,
               "signedDeltaCertifiedMinusFast": dict(sorted(deltas.items())),
               "ablationMismatchInventoryAgrees": True,
               "incorrectIndependentNearestTruth": nearest,
               "correctPool": {"certifiedOnlyZero": sum(r["canonicalDistance"] == 0 for r in zero_rows),
                               "fastOnlyZero": sum(r["fastRewriteCanonicalDistance"] == 0 for r in zero_rows)},
               "inputSha256": {str(p.relative_to(args.artifacts)): sha256(p) for p in inputs}}
    (args.output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(json.dumps({k: summary[k] for k in ("paired", "components", "incorrectIndependentNearestTruth", "correctPool")}, indent=2))


if __name__ == "__main__":
    main()
