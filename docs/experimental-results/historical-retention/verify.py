#!/usr/bin/env python3
"""Recount the historical retention release export from its published ledgers."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

OUT = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--repo", type=Path, default=OUT.parents[2], help="repository with the frozen corpus and historical floors")
ROOT = parser.parse_args().repo.resolve()
sys.path.insert(0, str(ROOT / "scripts"))
from verify_historical_pair_coverage import audit, historical_floors, load_candidate, require, records
from verify_slotted_reference_pools import check as recount_slotted
from verify_historical_rank_traces import identity, inspect_results, read_jsonl, require_historical_floor


def read(name):
    return json.loads((OUT / name).read_bytes())


def main():
    for line in (OUT / "SHA256SUMS").read_text().splitlines():
        digest, name = line.split("  ", 1)
        require(hashlib.sha256((OUT / name).read_bytes()).hexdigest() == digest, f"Changed export: {name}")
    h = read("headlines.json")
    receipt = read("run-receipt.json")
    require(receipt["status"] == "complete" and receipt["fullManifestVerified"]
            and receipt["runId"] == h["runId"] and not receipt["git"]["dirty"], "Unverified experiment")
    c = load_candidate(OUT, True)
    check = audit(c, historical_floors())
    require(check["status"] == "PASS", "One or more historical pair identities were lost")
    pairs = h["pairedSummary"]["nativeOperationReplay"]
    require(pairs["matched"] == pairs["attempted"] == h["measured"] == len(c["pairedCohort"])
            and not any(pairs[k] for k in ("unchecked","invalidReplay","errors","mismatches")), "Paired native replay failed")
    require(len(c["pairedStructural"]) == h["structuralZeros"] and
            len(c["poolStructural"]) == h["correctPools"]["structuralZeros"], "Headline differs from the raw cohort")
    slotted = read("slotted-reference-pools.json")
    counts = recount_slotted(ROOT / "docs/experimental-results/2026-11-25/references.jsonl.gz",
                             ROOT / "docs/historical-pair-coverage/v33-original-slotted-pool-zeros.csv.gz",
                             OUT / "slotted-reference-pairs.csv.gz", OUT / "correct-pool-pairs.jsonl.gz")
    require(slotted["passed"] and all(slotted[k] == v for k,v in counts.items()) and
            counts["gainsOverLive"] > 0 and not counts["missingLive"] and not counts["missingHistorical"],
            "Original Slotted inclusion failed")
    native = read("native-reference-summary.json")
    observed = {}
    for row in records(OUT / "native-reference-traces.jsonl.gz"):
        key = (row["kind"], row["status"])
        observed[key] = observed.get(key, 0) + 1
    reported = {}
    for r in native.get("statusCounts", native.get("counts", [])):
        key = (r["cohort"], r["status"])
        reported[key] = reported.get(key, 0) + r.get("observations", r.get("n"))
    require(observed == reported and sum(observed.values()) == native.get("measured", native.get("allComparisons")), "Trace census differs")
    require(native.get("jarSha256", native.get("measuredJarSha256")) == receipt["experimentJar"]["sha256"], "Trace diagnostics used another JAR")
    if (OUT / "paid-rank-witnesses.json").is_file():
        paid = read("paid-rank-witnesses.json")
        floor = read_jsonl(OUT / "paid-rank-witnesses-floor.jsonl")
        jobs = read_jsonl(OUT / "paid-rank-witnesses-measured.jsonl")
        require_historical_floor(floor, sorted((ROOT / "docs/experimental-results").glob("*/paid-rank-witnesses-floor.jsonl")))
        require({identity(r) for r in floor} == {identity(r) for r in jobs} and
                paid["status"] == "PASS" and paid["pairs"] == len(jobs) and paid["matched"] == 2*len(jobs) and
                not inspect_results(jobs, read_jsonl(OUT / "paid-rank-witnesses-replays.jsonl")),
                "Paid witnesses failed to replay in both directions")
    sample = list(records(OUT / "stratified-native-traces.jsonl.gz"))
    require(len(sample) == len({tuple(r["pool"]) for r in sample}) == 181 and
            all(r["verifiedStatus"] == "MATCHED" for r in sample), "Stratified trace ledger differs")
    if (OUT / "native-reference-inputs.tsv.gz").exists():
        from verify_native_reference_replays import verify
        verify(OUT, ROOT)
    os.chdir(ROOT)
    subprocess.run([sys.executable, "-B", OUT / "ranking_ledger.py", OUT / "ranking-scores.jsonl.gz",
                    OUT / "nearest-distances.csv.gz"], check=True)
    subprocess.run([sys.executable, "-B", OUT / "verify_recoveries.py", OUT], check=True)
    print(f"{len(c['pairedStructural']):,} student–oracle and {len(c['poolStructural']):,} direct reference zeros. "
          f"{pairs['matched']:,} matched student–oracle replays. Native ranking subset counts: {reported}.")


if __name__ == "__main__":
    main()
