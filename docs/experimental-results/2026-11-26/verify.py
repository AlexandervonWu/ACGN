"""Reconstruct both measured distance streams and the slotted inclusion check."""
import csv
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = HERE.parent / "2026-11-21-studies/measurements/natural-ablation/pair-distances.csv.gz"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    receipt = json.loads((HERE / "comparison.json").read_text())
    delta = HERE / "changed-distances.tsv.gz"
    require(sha(BASE.read_bytes()) == receipt["matrixSha256"], "Wrong baseline matrix")
    require(sha(gzip.decompress(delta.read_bytes())) == receipt["deltaTableSha256"], "Wrong delta")
    with gzip.open(delta, "rt", newline="") as stream:
        changes = {}
        for row in csv.DictReader(stream, delimiter="\t"):
            path = row["relativePath"]
            require(path not in changes, f"Duplicate changed pair {path}")
            changes[path] = row

    digest = hashlib.sha256()
    required, old, new, regained = set(), set(), set(), set()
    count = incorrect = 0
    distances = dict(smaller=0, equal=0, larger=0)
    with gzip.open(BASE, "rt", newline="") as stream:
        for row in csv.DictReader(stream):
            path = row["relativePath"]
            count += 1
            slotted = int(row["slotted-egraph"])
            before = int(row["canonical"])
            require(before == int(row["typed-slotted-port-egraph"]), path)
            if slotted == 0:
                required.add(path)
            if before == 0:
                old.add(path)
            after = before
            change = changes.pop(path, None)
            if change:
                require(all(row[k] == change[k] for k in ("status", "leftPredicate", "rightPredicate")), path)
                require((slotted, before) == (int(change["slottedDistance"]), int(change["v31Distance"])), path)
                require(sha((ROOT / "classified-data" / path).read_bytes()) == change["modelSha256"], path)
                after = int(change["repairedDistance"])
                require(after >= 0 and after != before, path)
                require(change["nativeCheckCorrect"] == ("UNSAT" if after == 0 else ""), path)
            order = "smaller" if after < slotted else "larger" if after > slotted else "equal"
            distances[order] += 1
            if after == 0:
                new.add(path)
                require(row["status"] == "CORRECT", f"Incorrect zero: {path}")
                if slotted == 0 and before > 0:
                    regained.add(path)
            incorrect += row["status"] != "CORRECT"
            digest.update(f"{path}\t{after}\n".encode())

    require(distances == receipt["numericComparisonWithSlotted"], "Numerical distance totals disagree")
    require(not changes and count == receipt["measured"] and incorrect == receipt["incorrect"], "Cohort mismatch")
    require(required < new and old <= new, "A required zero was lost or there was no strict gain")
    require(len(required) == receipt["priorSlottedZeros"] and len(old) == receipt["priorCanonicalZeros"], "Baseline counts")
    require(regained == {row["path"] for row in receipt["historicalLosses"]} and len(regained) == 10,
            "Mismatch in the ten recovered pairs")
    require(len(new - old) == receipt["nativeUNSAT"], "Bounded Alloy check count mismatch")
    for name in ("fast", "certified"):
        arm = receipt[name]
        require(arm["distanceRowsSha256"] == digest.hexdigest(), f"{name} measured distances disagree")
        require(len(new) == arm["correctZeros"] and len(new - old) == arm["zeroGains"], name)
        require(arm["errors"] == arm["incorrectZeros"] == arm["slottedZeroLosses"] == arm["canonicalZeroLosses"] == 0, name)
    print(f"Verified {count:,} distances per arm, {len(required):,} original slotted zeros retained, "
          f"{len(new - required):,} additional correct zeros and {len(new - old)} new bounded UNSAT checks.")


if __name__ == "__main__":
    main()
