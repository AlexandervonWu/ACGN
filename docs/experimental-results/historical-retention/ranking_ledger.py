"""Archive both measured distances for every paid incorrect-submission/reference comparison."""
import argparse
import gzip
import json
import io
import sys
from pathlib import Path

SOURCE = Path.cwd()
sys.path.insert(0, str(SOURCE / "scripts"))
from verify_historical_pair_coverage import batch_rows, table, records, ranking_scores, require

REFERENCES = SOURCE / "docs/experimental-results/2026-11-25/references.jsonl.gz"


def archive(raw_index, ledger):
    ids = {(r["source"], r["name"]): r["id"] for r in records(REFERENCES)}
    require(len(ids) == 4496, "Reference archive is incomplete")
    with ledger.open("xb") as raw, gzip.GzipFile(filename="", fileobj=raw, mode="wb", mtime=0, compresslevel=6) as gz, io.TextIOWrapper(gz, encoding="utf-8") as out:
        for r in batch_rows(raw_index, "incorrectNearest"):
            path = r["relativePath"]
            fast = ranking_scores(path, r["legacyCanonicalRanking"])
            cert = ranking_scores(path, r["canonicalRanking"])
            require(fast and fast.keys() == cert.keys(), f"Ranked reference cohorts differ on {path}")
            scores = sorted((ids[key], value, cert[key]) for key, value in fast.items())
            obj = [path, [i for i, _, _ in scores], [f for _, f, _ in scores], [c for _, _, c in scores]]
            out.write(json.dumps(obj, separators=(",", ":")) + "\n")


def verify(ledger, nearest):
    known = {r["id"]: tuple(r["group"]) for r in records(REFERENCES)}
    minima = {r["path"]: (int(r["legacyCanonicalDistance"]), int(r["canonicalDistance"])) for r in table(nearest)}
    require(len(minima) == 42386 and len(known) == 4496, "Missing archived cohorts")
    seen = set()
    comparisons = 0
    for path, ids, fast, cert in records(ledger):
        require(path in minima and path not in seen, f"Unexpected submission {path}")
        seen.add(path)
        group = path.split("/")[0], Path(path).stem.split("_")[-1]
        require(all(known[i] == group for i in ids), f"Reference pool differs on {path}")
        require(ids and ids == sorted(set(ids)) and len(ids) == len(fast) == len(cert), f"Incomplete scores on {path}")
        require(all(type(value) is int and value > 0 for value in fast + cert), f"Invalid score on {path}")
        for ref, a, b in zip(ids, fast, cert):
            require(a == b, f"Ranking differs on {path} against ID {ref}: Fast {a}, Certificate-Integrated {b}")
        require((min(fast), min(cert)) == minima[path], f"Nearest score differs on {path}")
        comparisons += len(ids)
    require(seen == set(minima) and comparisons == 1894168, "Rank ledger does not cover the measured cohort")
    print(f"Recounted {comparisons:,} equal positive scores on {len(seen):,} submissions.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ledger", type=Path)
    parser.add_argument("nearest", type=Path)
    parser.add_argument("--from-index", type=Path)
    args = parser.parse_args()
    if args.from_index:
        archive(args.from_index, args.ledger)
    verify(args.ledger, args.nearest)
