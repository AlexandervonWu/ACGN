#!/usr/bin/env python3
"""Replay original Slotted on the frozen reference pools and compare structural zero sets."""
import argparse
import csv
import gzip
import hashlib
import json
import subprocess
from collections import defaultdict
from itertools import combinations
from pathlib import Path

from verify_historical_pair_coverage import pair, records, require, source_endpoint

INVENTORY_DIGEST = "a135caa38f3c6720fb5c00581fe4a72808068081c6e2a2d7b4f4e44ed3e51524"
BASELINE_DIGEST = "fac1eedf015c1f75d2d6166c8a4157910b3d4633f9266b72fff68a33240fecdd"


def check(inventory, baseline, replay, decisions):
    require(hashlib.sha256(inventory.read_bytes()).hexdigest() == INVENTORY_DIGEST, "Reference inventory changed")
    require(hashlib.sha256(baseline.read_bytes()).hexdigest() == BASELINE_DIGEST, "Original Slotted floor changed")
    ids = {}
    pools = defaultdict(list)
    for ref in records(inventory):
        group = tuple(ref["group"])
        endpoint = source_endpoint(group[1], (ref["source"], ref["name"]))
        name = (*group, *endpoint)
        require(endpoint[1] == ref["operator"] and name not in ids, f"Invalid reference {name}")
        ids[name] = ref["id"]
        pools[group].append(ref["id"])
    require(len(ids) == len(set(ids.values())) == 4496 and len(pools) == 181, "Incomplete inventory")
    expected = {p for group in pools.values() for p in combinations(sorted(group), 2)}
    require(len(expected) == 132032, "Incomplete pair inventory")
    with gzip.open(baseline, "rt") as stream:
        original = {(int(row["left"]), int(row["right"])) for row in csv.DictReader(stream)}
    require(len(original) == 8952 and original <= expected, "Invalid v3.3 baseline")
    observed, live = set(), set()
    with gzip.open(replay, "rt") as stream:
        for row in csv.DictReader(stream):
            key = tuple(sorted((int(row["left"]), int(row["right"]))))
            distance = int(row["distance"])
            require(key not in observed and distance >= 0, f"Invalid Slotted decision {key}")
            observed.add(key)
            if distance == 0:
                live.add(key)
    require(observed == expected, "Original Slotted comparison cohort differs")
    observed.clear()
    canonical = set()
    for row in records(decisions):
        group = row["questionSet"], row["invariantId"]
        entry = pair(group, (row["leftSource"], row["left"]), (row["rightSource"], row["right"]))
        key = tuple(sorted((ids[entry[:4]], ids[(*group, *entry[4:])])))
        require(key not in observed and type(row["structuralZero"]) is bool, f"Invalid canonical decision {key}")
        observed.add(key)
        if row["structuralZero"]:
            canonical.add(key)
    require(observed == expected, "Canonical comparison cohort differs")
    return dict(cohort=len(expected), historicalSlottedZeros=len(original), liveSlottedZeros=len(live),
                canonicalZeros=len(canonical), gainsOverLive=len(canonical - live),
                missingHistorical=sorted(original - canonical), missingLive=sorted(live - canonical))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for option in ("repo", "artifacts", "dataset"):
        parser.add_argument("--" + option, required=True, type=Path)
    args = parser.parse_args()
    inventory = args.repo / "docs/experimental-results/2026-11-25/references.jsonl.gz"
    baseline = args.repo / "docs/historical-pair-coverage/v33-original-slotted-pool-zeros.csv.gz"
    comparison = args.artifacts / "slotted-reference-pairs.csv.gz"
    command = ["java", "-Xmx1g", "-XX:ActiveProcessorCount=3", "-cp",
               f"{args.artifacts}/build/acgn-experiments.jar:{args.repo}/lib/*",
               "is.fivefivefive.CanDis.ablation.SlottedReferencePoolReplay",
               str(args.dataset), str(inventory), str(comparison)]
    version = subprocess.run(command, check=True, text=True, stdout=subprocess.PIPE).stdout.strip().splitlines()[-1]
    report = check(inventory, baseline, comparison,
                   args.artifacts / "alloy4fun-augmented/default_correct_pool_equivalences.jsonl")
    report.update(slottedVersion=version, inventorySha256=INVENTORY_DIGEST,
                  replaySha256=hashlib.sha256(comparison.read_bytes()).hexdigest())
    passed = not report["missingHistorical"] and not report["missingLive"] and report["gainsOverLive"] > 0
    report["passed"] = passed
    (args.artifacts / "slotted-reference-pools.json").write_text(json.dumps(report, indent=2) + "\n")
    require(passed, "Original Slotted reference coverage failed; see slotted-reference-pools.json")


if __name__ == "__main__":
    main()
