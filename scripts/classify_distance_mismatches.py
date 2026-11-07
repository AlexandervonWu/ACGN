#!/usr/bin/env python3
"""Classify frozen mismatch inventories without inferring unproved root causes."""
import argparse
from collections import Counter, defaultdict
import csv
import json
from pathlib import Path

from audit_fast_certified_distances import sha256

COMPONENTS = ("Temporal", "Quantifier", "Matrix")
KNOWN_WITNESSES = {
    "coursesOld/both/xJnitBpFv9K74WNvf_inv14.als": "P08-order-sensitive-certified-duplicate",
    "productionLine_v1/correct/Nc6rBGbJRWcFSpGY8_inv2.als": "P05-binary-versus-flat-chain",
    "classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als": "P06-live-temporal-projection",
    "trash_ltl/over/C8fwykgcniKQBrybn_inv12.als": "P06-live-temporal-projection",
    "trash_ltl/both/oivT9pBECZFsYCGWq_inv18.als": "P06-live-temporal-projection",
}


def inventory(path):
    result = {}
    with path.open(newline="") as stream:
        for row in csv.DictReader(stream):
            name = row["relativePath"]
            if name in result:
                raise ValueError("Duplicate path: " + name)
            for key in ("distance", "legacyCanonicalDistance", *(
                    prefix + component + "Distance"
                    for prefix in ("quotient", "legacy") for component in COMPONENTS)):
                row[key] = int(row[key])
                if row[key] < 0:
                    raise ValueError("Negative distance: " + name)
            for total, prefix in (("distance", "quotient"), ("legacyCanonicalDistance", "legacy")):
                if row[total] != sum(row[prefix + c + "Distance"] for c in COMPONENTS):
                    raise ValueError("Component sum disagrees: " + name)
            if row["distance"] == row["legacyCanonicalDistance"]:
                raise ValueError("Equal row in mismatch inventory: " + name)
            result[name] = row
    return result


def classify(row, previous):
    delta = row["legacyCanonicalDistance"] - row["distance"]
    old_delta = 0 if previous is None else previous["legacyCanonicalDistance"] - previous["distance"]
    components = "+".join(c.lower() for c in COMPONENTS
                          if row["legacy" + c + "Distance"] != row["quotient" + c + "Distance"])
    change = ("introduced" if previous is None else
              "improved" if abs(delta) < abs(old_delta) else
              "worsened" if abs(delta) > abs(old_delta) else "same-absolute-gap")
    return dict(row, componentClass=components,
                direction="fast-greater" if delta > 0 else "certified-greater",
                fastMinusCertified=delta, previousFastMinusCertified=old_delta,
                absoluteGapChange=abs(delta) - abs(old_delta), change=change,
                signFlipped=delta * old_delta < 0,
                confirmedWitnessCause=KNOWN_WITNESSES.get(row["relativePath"], "UNCLASSIFIED"))


def classify_all(current, previous):
    classified = [classify(current[p], previous.get(p)) for p in sorted(current)]
    groups = defaultdict(list)
    for row in classified:
        groups[(row["componentClass"], row["direction"])].append(row)
    classes = []
    representatives = {}
    for (component, direction), members in sorted(groups.items()):
        ranked = sorted(members, key=lambda r: (-abs(r["fastMinusCertified"]), r["relativePath"]))
        classes.append(dict(components=component, direction=direction, count=len(members),
                            absoluteGapSum=sum(abs(r["fastMinusCertified"]) for r in members),
                            changes=dict(sorted(Counter(r["change"] for r in members).items())),
                            largestWitnesses=[r["relativePath"] for r in ranked[:3]]))
        for row in ranked[:3]:
            representatives[row["relativePath"]] = row
    # Cover each problem's largest matrix residual and every non-matrix case.
    for problem in sorted({r["relativePath"].split("/", 1)[0] for r in classified}):
        members = [r for r in classified if r["relativePath"].startswith(problem + "/")]
        row = min(members, key=lambda r: (-abs(r["fastMinusCertified"]), r["relativePath"]))
        representatives[row["relativePath"]] = row
    for row in classified:
        if row["componentClass"] != "matrix" or row["confirmedWitnessCause"] != "UNCLASSIFIED":
            representatives[row["relativePath"]] = row
    for row in sorted(classified, key=lambda r: (-r["absoluteGapChange"], r["relativePath"]))[:10]:
        representatives[row["relativePath"]] = row
    summary = dict(schema="acgn-distance-mismatch-classification-v1", currentMismatches=len(current),
                   previousMismatches=len(previous), resolved=len(previous.keys() - current.keys()),
                   introduced=len(current.keys() - previous.keys()), classes=classes,
                   confirmedWitnessCauses=dict(sorted(Counter(r["confirmedWitnessCause"] for r in classified).items())),
                   operationSequenceStatus="NOT_MEASURED: neither archived arm exported replayable plans",
                   interpretation="Component classes are symptoms, not inferred semantic root causes.")
    return classified, summary, [representatives[p] for p in sorted(representatives)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--current", type=Path, required=True)
    parser.add_argument("--previous", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    current, previous = inventory(args.current), inventory(args.previous)
    classified, summary, representatives = classify_all(current, previous)
    summary["inputSha256"] = {str(p.resolve()): sha256(p) for p in (args.current, args.previous)}
    args.output.mkdir(parents=True, exist_ok=False)
    with (args.output / "classified-mismatches.csv").open("w", newline="") as stream:
        fields = list(classified[0]) if classified else ["relativePath"]
        writer = csv.DictWriter(stream, fields)
        writer.writeheader()
        writer.writerows(classified)
    (args.output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    (args.output / "representatives.json").write_text(json.dumps(representatives, indent=2) + "\n")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
