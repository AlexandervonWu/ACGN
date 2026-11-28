"""Rebuild the headline results and the source-indexed repair classification."""
import argparse
import collections
import csv
import hashlib
import io
import json
from pathlib import Path

# Stage names are those bound to the per-direction native replay table.
STAGES = {
    "candidate-01": ("Counting-binder positions", "229cf5da"),
    "candidate-02": ("Declaration permutation order", "0157d270"),
    "candidate-03": ("Linked temporal declaration tie", "7bda8c50"),
    "candidate-04": ("Target binder group selection", "3fa9d25d"),
    "final": ("Coalesced source declaration slots", "7d24ea60"),
}
KEY = ("submission", "predicate", "reference", "referencePredicate")

def identity(row):
    return tuple(row[k] for k in KEY)

def rebuild(root):
    bindings = {}
    def read(name):
        raw = (root / name).read_bytes()
        bindings[name] = hashlib.sha256(raw).hexdigest()
        return raw
    def data(name):
        return json.loads(read(name))
    def table(name):
        return csv.DictReader(io.StringIO(read(name).decode("utf-8")))

    original = data("original/summary.json")
    final = data("repaired/summary.json")
    closure = data("receipts/repaired/independent-closure.json")
    changes = data("ranking-program-changes.json")
    portable = data("temporal-program-replay/summary.json")
    preflight = data("receipts/repaired/historical-preflight-summary.json")
    pool = data("reference-pool-scores/summary.json")
    scoped = data("reference-pool-scores/command-components/summary.json")
    timeline = list(table("stage-attribution/tables/final-timeline.csv"))
    forward = {identity(r):r for r in timeline if r["direction"] == "forward"}
    reverse = {identity(r):r for r in timeline if r["direction"] == "reverse"}
    if len(timeline) != 2*len(forward) or forward.keys() != reverse.keys():
        raise ValueError("Incomplete or duplicated repair timeline")
    if changes["previouslyMatched"]["changedOrderedProgram"] != portable["checks"]["bothArchivedProgramsReconstructed"]:
        raise ValueError("Some changed temporal commitments lack their archived occurrence evidence")
    columns = (*KEY, "referenceId", "sourceSha256", "referenceSha256", "distance", "repair",
               "stage", "engineCommitPrefix", "originalReverse", "originalFastSha256",
               "originalCertifiedSha256", "repairedForwardSha256", "originalIncident")
    output = io.StringIO(newline="")
    writer = csv.DictWriter(output, fieldnames=columns, lineterminator="\n")
    writer.writeheader()
    stages = collections.Counter()
    seen = set()
    for inc in table("repaired-ranking-pairs.csv"):
        key = identity(inc)
        f, r = forward[key], reverse[key]
        if key in seen or inc["oldStatus"] != "MISMATCH" or (f["final"],r["final"]) != ("MATCHED","MATCHED") or inc["expected"] != f["expected"]:
            raise ValueError(f"Unverified or duplicated repaired pair {key}")
        seen.add(key)
        stage = f["firstDurableWithinObservedSeries"]
        reason, commit = STAGES[stage]
        stages[stage] += 1
        writer.writerow({**dict(zip(KEY,key)), "referenceId":f["referenceId"],
                         "sourceSha256":inc["sourceSha256"], "referenceSha256":inc["referenceSha256"],
                         "distance":inc["expected"], "repair":reason, "stage":stage, "engineCommitPrefix":commit,
                         "originalReverse":r["original-replay"], "originalFastSha256":inc["oldFastSha256"],
                         "originalCertifiedSha256":inc["oldCertifiedSha256"], "repairedForwardSha256":inc["newSha256"],
                         "originalIncident":"original/" + inc["originalIncident"]})
    if seen != forward.keys() or len(seen) != original["nonconforming"] or final["rows"] != closure["rows"] or closure["status"]!="VERIFIED":
        raise ValueError("Publication inputs disagree about the native cohort")
    result = {
        "measuredCommit": final["measuredCommit"], "rankingRun":closure["experimentUuid"],
        "rankingPairs": final["rows"], "submissions": final["submissions"], "references": final["references"],
        "originalMatched":original["checkedOrderedNativeWitnesses"], "originalDifferent":len(seen),
        "repairedMatched":final["checkedOrderedNativeWitnesses"], "repairedDifferent":final["nonconforming"],
        "repairedModes":final["matchedModes"], "historicalRankingScoresReproduced":changes["joinedPositiveScores"],
        "previouslyMatchingPrograms": {
            "rawDigestUnchanged":changes["previouslyMatched"]["sameOrderedProgram"],
            "rawDigestChanged":changes["previouslyMatched"]["changedOrderedProgram"],
            "sameEditsWithDifferentProcessLocalNumbers":portable["checks"]["bothArchivedProgramsReconstructed"],
            "archivedDigestsReproducedAfterRestoringNumbers":portable["checks"]["exactArchivedReconstructions"],
        },
        "repairs":[{"stage":s,"cause":name,"firstDurableForwardPairs":stages[s],"engineCommitPrefix":rev}
                   for s,(name,rev) in STAGES.items()],
        "historicalBidirectionalPairs":preflight["pairs"], "historicalDirections":preflight["directions"],
        "historicalDirectionFailures":preflight["failures"], "paired":scoped["paired"],
        "withinPoolPairs":pool["allPairs"], "referencePools":pool["referencePools"],
        "allPositiveWithinPoolPairs":pool["recordedPositiveInputs"],"structuralZeros":pool["structuralZeros"],
        "structuralForms":pool["structuralForms"],"originalSlottedReferenceZeros":pool["originalSlottedZeros"],
        "fixedCommandComponents":scoped["commandComponents"],
        "referenceGraph":{key: scoped[key] for key in (
            "directNativeZeros", "directFixedLinks", "fixedLinksAlsoStructural",
            "additionalDirectScopedLinks", "disconnectedSatControls", "structuralComponentPairs",
            "commandComponentPairs")},
        "sourceAndScopeRetention":closure["sourceAndScopeRetention"]["sourceScopes"],
        "archivedSolverOutcomes":closure["sourceAndScopeRetention"]["archivedSolver"],
        "replayBoundary":"FROZEN_NORMALIZED_IR", "evidenceSha256":bindings,
    }
    return {"headlines.json":(json.dumps(result,indent=2,sort_keys=True)+"\n").encode(),
            "repairs-by-pair.csv":output.getvalue().encode()}

if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write",action="store_true",help="regenerate the two derived reports")
    root=Path(__file__).resolve().parents[1]
    write = parser.parse_args().write
    for name, payload in rebuild(root).items():
        if write:
            (root/name).write_bytes(payload)
        elif payload != (root/name).read_bytes():
            raise ValueError("Derived report differs: "+name)
