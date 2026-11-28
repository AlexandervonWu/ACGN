"""Join the published ranking scores with native program commitments from both measured engines."""
import argparse
import csv
import gzip
import itertools
import json
from array import array
from collections import Counter
from pathlib import Path

from compare_censuses import REQUIRED, comparisons, open_archive, program, require, sha

SOURCES = {
    "scores": ("docs/experimental-results/historical-retention/ranking-scores.jsonl.gz", "5ca73249a44b97f9290a4bd12923802c808fddbf168564daaf8c04d373b14778"),
    "paired": ("docs/experimental-results/historical-retention/paired-comparisons.jsonl.gz", "dc99a6ef526998e865c3c1bddd274088aa30faad86e165deaa528f602184bf0c"),
    "references": ("docs/experimental-results/2026-11-25/references.jsonl.gz", "a135caa38f3c6720fb5c00581fe4a72808068081c6e2a2d7b4f4e44ed3e51524"),
}
MODES = {"F": "FLAT_ACTIONS", "T": "TEMPORAL_BLOCK_EFFECTS"}
TABLE = "previously-matched-program-changes.csv"
SUMMARY = "ranking-program-changes.json"

def published(repo, key):
    relative, expected = SOURCES[key]
    source = repo / relative
    require(sha(source) == expected, "Changed published input " + relative)
    with gzip.open(source, "rt") as stream:
        yield from map(json.loads, stream)

def rebuild(release, repo, out):
    previous, incidents = open_archive(release / "original")
    current, failed = open_archive(release / "repaired")
    require(not failed and current["status"] == "VERIFIED", "Incomplete repaired census")
    references = {r["id"]: (r["source"], r["operator"], r["sha"]) for r in published(repo, "references")}
    selectors = {r["path"]: r["left"] for r in published(repo, "paired") if r["status"] != "CORRECT"}
    scores = {}
    for source, ids, fast, certified in published(repo, "scores"):
        require(source not in scores and fast == certified and ids == sorted(set(ids)) and len(ids) == len(fast)
                and all(type(s) is int and s > 0 for s in fast), "Incorrect published scores for " + source)
        scores[source] = array("H", ids), array("I", fast)
    require(selectors.keys() == scores.keys() and len(references) == 4496 and len(scores) == 42386, "Wrong input universe")
    previous_matches = Counter()
    repaired_to = Counter()
    changed_pools = Counter()
    changed_modes = Counter()
    before_mode = Counter()
    after_mode = Counter()
    seen = Counter()
    aggregate = 0
    incident_rows = 0
    equal_lengths = 0
    source_hashes = {}
    fields = ("submission", "sourcePredicate", "sourceSha256", "referenceId", "reference", "referencePredicate",
              "referenceSha256", "distance", "originalProgramKind", "originalCount", "originalProgramSha256",
              "repairedProgramKind", "repairedCount", "repairedProgramSha256")
    with (out / TABLE).open("x", newline="") as stream:
        writer = csv.DictWriter(stream, fields, lineterminator="\n")
        writer.writeheader()
        for left, right in itertools.zip_longest(comparisons(release / "original", previous), comparisons(release / "repaired", current)):
            require(left and right and left[0] == right[0], "Different source or reference")
            key, old = left
            source, ref = key
            ids, distances = scores[source]
            index = seen[source]
            require(index < len(ids) and ids[index] == ref, "Different reference/order from published per-source ranking")
            distance = distances[index]
            aggregate += distance
            seen[source] += 1
            new = program(right[1], None, "certified")
            after_mode[MODES[new[0]]] += 1
            incident = incidents.get(key)
            if incident:
                row = incident["observation"]
                require(row["expected"] == row["fastDistance"] == row["certifiedDistance"] == distance, "Historical scalar changed")
                original_fast, original_cert = (program(old, incident, a) for a in ("fast", "certified"))
                require(original_fast and original_cert and original_fast != original_cert, "Incomplete historical difference")
                which = "originalFast" if new == original_fast else "originalCertified" if new == original_cert else "neither"
                repaired_to[which] += 1
                incident_rows += 1
                continue
            common = program(old, None, "fast")
            before_mode[MODES[common[0]]] += 1
            if common == new:
                previous_matches["sameOrderedProgram"] += 1
                continue
            previous_matches["changedOrderedProgram"] += 1
            ref_source, ref_selector, ref_hash = references[ref]
            for path in (source, ref_source):
                if path not in source_hashes:
                    source_hashes[path] = sha(repo / "classified-data" / path)
            require(source_hashes[ref_source] == ref_hash, "Wrong reference source")
            writer.writerow(dict(zip(fields, (source, selectors[source], source_hashes[source], ref, ref_source, ref_selector,
                                              ref_hash, distance, MODES[common[0]], common[1], common[2],
                                              MODES[new[0]], new[1], new[2]))))
            changed_pools[(source.split("/")[0],selectors[source])] += 1
            changed_modes[(MODES[common[0]], MODES[new[0]])] += 1
            equal_lengths += common[:2] == new[:2]
    require(sum(seen.values()) == REQUIRED and all(seen[k] == len(v[0]) for k,v in scores.items()), "Incomplete score binding")
    require(incident_rows == len(incidents) == previous["nonconforming"], "Incomplete historical incident binding")
    report = {
        "rows": REQUIRED, "originalScoreRunId": current["sourceRunId"], "cohortManifestSha256": current["inputManifestSha256"],
        "publishedRankingScoresSha256": SOURCES["scores"][1], "joinedPositiveScores": sum(seen.values()),
        "sumOfJoinedPositiveDistances": aggregate, "originalMatched": sum(previous_matches.values()), "repairedMatched": REQUIRED,
        "previouslyMatched": dict(previous_matches), "changedPreviousMatchesWithEqualKindAndCount": equal_lengths,
        "changedPreviousMatchesByProgramKind": [{"original": a, "repaired": b, "pairs": n} for (a,b),n in sorted(changed_modes.items())],
        "changedPreviousMatchesByPool": [{"question": q, "predicate": p, "pairs": n} for (q,p),n in sorted(changed_pools.items())],
        "originalDivergencesResolvedTo": dict(repaired_to), "originalMatchedModes": dict(before_mode), "repairedMatchedModes": dict(after_mode),
        "originalSummarySha256": sha(release / "original/summary.json"), "repairedSummarySha256": sha(release / "repaired/summary.json"),
        "changedPairsSha256": sha(out / TABLE),
    }
    (out / SUMMARY).write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    return report

if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("release", type=Path)
    p.add_argument("repo", type=Path)
    p.add_argument("output", type=Path, help="Existing directory for new, previously absent outputs")
    a = p.parse_args()
    print(json.dumps(rebuild(a.release, a.repo, a.output), sort_keys=True))
