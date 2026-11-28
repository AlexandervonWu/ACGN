"""Identify the first durable repair of every original divergent ranking pair from exact-binary checkpoint replays."""
import argparse
import csv
import hashlib
import json
from pathlib import Path

FIELDS = ("submission", "predicate", "reference", "referencePredicate")


def sha(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def require(v, reason):
    if not v:
        raise ValueError(reason)


def load_edition(directory, spec, expected, reported):
    summary = json.loads((directory / "summary.json").read_bytes())
    ledger = directory / "native-observations.jsonl"
    require(sha(ledger) == summary["ledgerSha256"] and summary["engineSha256"] == spec["sha256"],
            f"Wrong exact-binary checkpoint for {directory}")
    observations = {}
    with ledger.open() as stream:
        for row in map(json.loads, stream):
            if "baselineFailure" not in row["groups"]:
                continue
            key = (row["left"], row["leftPredicate"], row["right"], row["rightPredicate"])
            if row["direction"] == "reverse":
                key = (*key[2:], *key[:2])
            require(row["direction"] in ("forward", "reverse") and key in expected and row["expected"] == expected[key],
                    "Selection or original ranking cost differs")
            ix = key, row["direction"]
            require(ix not in observations, "Duplicate native observation")
            if row["checked"]:
                require(row["status"] == "MATCHED" and row["nativeSequencesEqual"]
                        and row["fastDistance"] == row["certifiedDistance"] == expected[key]
                        and row["fastSequenceSha256"] == row["certifiedSequenceSha256"]
                        and all(row[k] for k in ("sourceCertificatesChecked","fixedChoiceReplaysChecked","endpointCorrespondenceChecked")),
                        "Malformed success in native checkpoint")
            observations[ix] = row
    require(len(observations) == len(expected) * 2, f"Unmeasured source/direction in {directory}")
    if reported:
        for key in expected:
            row = observations[key, "forward"]
            require(row["checked"] and row["fastSequenceSha256"] == reported[key], "Changed final repaired program")
    return observations


def classify(row):
    if row["checked"]:
        return "MATCHED"
    return row["status"] if row["status"] != "MATCHED" else "UNBOUND_MATCH"


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("repaired_ranking_pairs", type=Path)
    p.add_argument("editions", type=Path, help="JSON list in commit order with name, checkpoint, commit and sha256")
    p.add_argument("output", type=Path)
    a = p.parse_args()
    with a.repaired_ranking_pairs.open(newline="") as stream:
        repair = list(csv.DictReader(stream))
    expected = {tuple(row[f] for f in FIELDS): int(row["expected"]) for row in repair}
    require(len(expected) == len(repair), "Repeated before/after source pair")
    digests = {tuple(row[f] for f in FIELDS): row["newSha256"] for row in repair}
    editions = json.loads(a.editions.read_bytes())
    require(bool(editions) and len({e["name"] for e in editions}) == len(editions), "Repeated edition")
    replays = [load_edition(a.editions.parent / s["checkpoint"], s, expected,
                            digests if i + 1 == len(editions) else None) for i,s in enumerate(editions)]
    columns = [*FIELDS, "originalCost", "firstDurableForwardRepair", "firstDurableBidirectionalRepair",
               *[s["name"] + sfx for s in editions for sfx in ("Forward", "Reverse")]]
    counts = {}
    with a.output.open("x", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=columns, lineterminator="\n")
        writer.writeheader()
        for key, cost in sorted(expected.items()):
            row = dict(zip(FIELDS, key))
            row["originalCost"] = cost
            last_bad_forward = last_bad_either = -1
            for i, (spec, observation) in enumerate(zip(editions, replays)):
                f, r = (classify(observation[key, d]) for d in ("forward", "reverse"))
                if f != "MATCHED": last_bad_forward = i
                if f != "MATCHED" or r != "MATCHED": last_bad_either = i
                row[spec["name"] + "Forward"] = f
                row[spec["name"] + "Reverse"] = r
            require(last_bad_either + 1 < len(editions), f"Final version still diverges for {key}")
            row["firstDurableForwardRepair"] = editions[last_bad_forward + 1]["commit"]
            row["firstDurableBidirectionalRepair"] = editions[last_bad_either + 1]["commit"]
            counts[row["firstDurableForwardRepair"]] = counts.get(row["firstDurableForwardRepair"], 0) + 1
            writer.writerow(row)
    print(json.dumps({"pairs":len(expected), "firstDurableForwardRepair":counts, "outputSha256":sha(a.output)}, sort_keys=True))


if __name__ == "__main__":
    main()
