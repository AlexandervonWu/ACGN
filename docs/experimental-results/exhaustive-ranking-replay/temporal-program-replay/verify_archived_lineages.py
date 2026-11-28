"""Reconstruct the historical temporal effect commitment from each checked source replay."""
import argparse
import csv
import copy
import gzip
import hashlib
import json
import lzma
from collections import Counter, defaultdict
from pathlib import Path

from occurrences import SerializedNumber, canonical, project, require
from native_commitment import check_programs

HERE = Path(__file__).resolve().parent
RELEASE = HERE.parent
TABLE_SHA = "cdc7c01f352b9ee15ac29d1d43eefc92f287f12d5ff7ef7d1f35cfcbe3b087bb"
SUMMARIES = {
    "original": "5dc1545c3ed3bc061ee889fa4dd238e81c1e162687303452a739f604777cfd06",
    "repaired": "257e07ff3657328ad05a93410b0a6f921fc11cd4652a5d94ee955aa904d64b38",
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def source_occurrences(witness):
    addresses = []
    for block, (component, actions) in enumerate(witness["program"]):
        if not isinstance(actions, list):
            continue
        for index, action in enumerate(actions):
            if not isinstance(action, dict):
                continue
            for side in ("source", "target"):
                node = action.get(side)
                if not isinstance(node, dict) or "localBinding" not in node:
                    continue
                token, phase = node["localBinding"], node["phase"]
                label = token["sourceOccurrence"]
                phases = [p for p in witness[side + "Owners"] if p["phase"] == phase]
                require(len(phases) == 1 and phases[0]["correspondence"]["sourceOccurrenceTransportChecked"] is True, "Missing original phase correspondence")
                slots = []
                for owner in phases[0]["correspondence"]["owners"]:
                    for group in owner["orderedDeclarations"]:
                        for slot in group["slots"]:
                            if slot["ownerPath"] != token["bindingPath"]:
                                continue
                            if all(slot[k] == token[k] for k in ("lexicalCoordinate", "type", "kind", "cardinality", "disjointness")):
                                slots.append((owner, group, slot))
                require(len(slots) == 1 and type(label) is int and label > 0, "Ambiguous source occurrence or owner")
                owner, group, slot = slots[0]
                addresses.append(dict(block=block, component=component, action=index, side=side,
                                      phase=phase, path=node["path"], owner=token["bindingPath"],
                                      lexicalCoordinate=token["lexicalCoordinate"],
                                      ownerTuple=[owner["opcode"], group["opcode"], slot["declaration"], slot["tuple"]],
                                      type=token["type"], kind=token["kind"], cardinality=token["cardinality"],
                                      disjointness=token["disjointness"], coldSourceOccurrence=label))
    require(len({(a["side"], a["phase"]["sourcePath"]) for a in addresses}) == 1, "Expected exactly one authenticated endpoint and phase")
    return addresses


def check_preimage(raw, row, rec):
    edition = rec["edition"]
    count = int(row[edition + "Count"])
    checked = project(raw, int(row["distance"]), count)
    address = source_occurrences(checked)
    require(canonical(address) == canonical(rec["checkedOccurrences"]), "Recorded occurrence, owner, type, tree path or tuple changed")
    side, phase = address[0]["side"], address[0]["phase"]["sourcePath"]
    require(rec["side"] == side and rec["phase"] == phase, "Wrong binding endpoint")
    path, predicate, source_hash = (("submission", "sourcePredicate", "sourceSha256") if side == "source" else
                                    ("reference", "referencePredicate", "referenceSha256"))
    require(rec["endpoint"] == {"path": row[path], "predicate": row[predicate], "sha256": row[source_hash]}, "Wrong original source")
    require(sha(canonical(checked["program"]).encode()) == rec["coldProgramSha256"], "Changed fresh program")
    delta = rec["offset"]
    minimum = min(a["coldSourceOccurrence"] for a in address)
    require(type(delta) is int and type(rec["archivedMinimumLineage"]) is int and
            rec["coldMinimumLineage"] == minimum and rec["archivedMinimumLineage"] == minimum + delta > 0,
            "Invalid allocator offset")
    expected = row[edition + "ProgramSha256"]
    require(rec["archivedProgramSha256"] == expected and rec["sourceCaptureSha256"] == sha(raw), "Raw identity disagreement")
    evidence = json.loads(raw, parse_float=SerializedNumber)
    # Retain the original arm-specific object and action order. Only these exact label fields can change.
    for arm in ("fast", "certified"):
        for a in address:
            token = evidence[arm + "Blocks"][a["block"]]["effect"][a["action"]][side]["localBinding"]
            require(token["sourceOccurrence"] == a["coldSourceOccurrence"], "The two native variable reads differ")
            token["sourceOccurrence"] += delta
    check_programs(evidence, dict(sequenceKind="TEMPORAL_BLOCK_EFFECTS", fastBlockCount=count, certifiedBlockCount=count,
                                  fastSequenceSha256=expected, certifiedSequenceSha256=expected, nativeSequencesEqual=True,
                                  orderedBlockEffectsEqual=True, status="MATCHED"))


def archive_commitments(rows, edition):
    directory = RELEASE / edition
    raw = (directory / "summary.json").read_bytes()
    require(sha(raw) == SUMMARIES[edition], "Ranking archive was replaced")
    summary = json.loads(raw)
    wanted = defaultdict(dict)
    for row in rows:
        wanted[row["submission"]][int(row["referenceId"])] = ["T", int(row[edition + "Count"]), row[edition + "ProgramSha256"]]
    index = directory / "source-index.tsv.gz"
    require(sha(index.read_bytes()) == summary["sourceIndexSha256"], "Ranking source index changed")
    selected = defaultdict(dict)
    chunks = {c["path"]: c["sha256"] for c in summary["chunks"]}
    with gzip.open(index, "rt") as stream:
        for r in csv.DictReader(stream, delimiter="\t"):
            if r["source"] in wanted:
                selected[r["chunk"]][r["source"]] = (int(r["uncompressedOffset"]), int(r["comparisons"]))
    seen = 0
    for name, subset in selected.items():
        path = directory / name
        require(sha(path.read_bytes()) == chunks[name], "Ranking chunk changed")
        with gzip.open(path, "rb") as stream:
            for source, (position, size) in sorted(subset.items(), key=lambda p: p[1][0]):
                stream.seek(position)
                label, entries = json.loads(stream.readline())
                require(label == source and len(entries) == size, "Wrong archived submission")
                group = {entry[0]: entry[1:] for entry in entries}
                for reference, expected in wanted[source].items():
                    require(group.get(reference) == expected, "Changed archived native temporal commitment")
                    seen += 1
    require(seen == len(rows), "Missing original commitment")


def tamper_controls(raw, row, rec):
    def reject(label, changed):
        try:
            check_preimage(raw, row, changed)
        except ValueError:
            return label
        raise ValueError("Uncaught invalid historical evidence " + label)

    results = []
    for name, field, value in (("wrong allocation base", "offset", rec["offset"] + 1),
                               ("wrong source phase", "phase", "unrelated phase"),
                               ("wrong archival hash", "archivedProgramSha256", "0" * 64)):
        invalid = copy.deepcopy(rec)
        invalid[field] = value
        results.append(reject(name, invalid))
    invalid = copy.deepcopy(rec)
    invalid["offset"] += 1
    invalid["archivedMinimumLineage"] += 1
    results.append(reject("self-consistent but incorrect offset", invalid))
    invalid = copy.deepcopy(rec)
    invalid["checkedOccurrences"][0]["coldSourceOccurrence"] = invalid["checkedOccurrences"][1]["coldSourceOccurrence"]
    results.append(reject("two distinct uses of one declaration conflated", invalid))
    invalid = copy.deepcopy(rec)
    invalid["checkedOccurrences"][0]["path"] = invalid["checkedOccurrences"][1]["path"]
    results.append(reject("different live tree path", invalid))
    invalid = copy.deepcopy(rec)
    invalid["checkedOccurrences"][0]["ownerTuple"][3] += 1
    results.append(reject("different declaration tuple", invalid))
    invalid = copy.deepcopy(rec)
    invalid["endpoint"]["predicate"] = "another"
    results.append(reject("foreign predicate", invalid))
    return results


def verify(repo):
    table = RELEASE / "previously-matched-program-changes.csv"
    require(sha(table.read_bytes()) == TABLE_SHA, "Changed comparison table")
    with table.open(newline="") as stream:
        rows = list(csv.DictReader(stream))
    for edition in SUMMARIES:
        archive_commitments(rows, edition)
    with gzip.open(HERE / "observations.jsonl.gz", "rt") as stream:
        cold = {(n, e): raw for n, e, profile, repeat, raw, witness in map(json.loads, stream) if profile == "cold" and repeat == 0}
    with gzip.open(HERE / "archived-lineages.jsonl.gz", "rt") as stream:
        registry = list(map(json.loads, stream))
    expected_order = [(n, e) for n in range(196) for e in sorted(SUMMARIES)]
    require(expected_order == [(p["index"], p["edition"]) for p in registry] and set(cold) == set(expected_order),
            "Duplicate or missing original reconstruction")
    wanted = defaultdict(list)
    for p in registry:
        key = p["index"], p["edition"]
        require(p["sourceCaptureSha256"] == cold[key], "Wrong source receipt for this ranking")
        wanted[cold[key]].append(p)
    paths = {}
    for row in rows:
        for field, identity in (("submission", "sourceSha256"), ("reference", "referenceSha256")):
            paths.setdefault(row[field], row[identity])
            require(paths[row[field]] == row[identity], "Conflicting source bytes")
    require(all(sha((repo / "classified-data" / name).read_bytes()) == identity for name, identity in paths.items()), "Original source bytes changed")
    checked = 0
    controls = None
    with lzma.open(HERE / "native-receipts.jsonl.xz", "rb") as stream:
        for raw in stream:
            for rec in wanted.pop(sha(raw), []):
                row = rows[rec["index"]]
                check_preimage(raw, row, rec)
                if rec["index"] == 0 and rec["edition"] == "original":
                    controls = tamper_controls(raw, row, rec)
                checked += 1
    require(not wanted and checked == 392 and controls is not None, "Incomplete original preimage evidence")
    return dict(schema="archived-temporal-occurrence-preimages-v1", status="VERIFIED", pairs=len(rows), historicalProgramHashes=checked,
                editions=sorted(SUMMARIES), sourceFiles=len(paths), offsetRange=[min(p["offset"] for p in registry), max(p["offset"] for p in registry)],
                casesByEndpointSide=dict(Counter(p["side"] for p in registry)), rejectedControls=controls,
                registrySha256=sha((HERE / "archived-lineages.jsonl.gz").read_bytes()), sourceTableSha256=TABLE_SHA,
                archivedSummarySha256=SUMMARIES)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(verify(args.repo), indent=2, sort_keys=True))
