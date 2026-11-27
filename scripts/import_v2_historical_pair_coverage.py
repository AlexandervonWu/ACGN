"""Rebuild the v2 structural floor from the identity-bearing ledgers in the release tags."""
import csv
import gzip
import hashlib
import io
import json
import subprocess
from pathlib import Path
from verify_historical_pair_coverage import FLOORS, ROOT, batch_rows, pair
TAGS = ("v2.1", "v2.11", "v2.12", "v2.13", "v2.14", "v2.15", "v2.16", "v2.17")


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def write_floor(tags_to_read, filename):
    paired, pool = set(), set()
    tags, seen = {}, set()
    for tag in tags_to_read:
        sources = tags[tag] = {}
        file = "distance_results/distances.json"
        oid = git("show", f"{tag}:{file}").decode().split("oid sha256:")[1].splitlines()[0]
        sources[file] = "sha256:" + oid
        if oid not in seen:
            seen.add(oid)
            git_dir = Path(git("rev-parse", "--path-format=absolute", "--git-common-dir").decode().strip())
            raw = git_dir / "lfs/objects" / oid[:2] / oid[2:4] / oid
            digest = hashlib.sha256()
            with raw.open("rb") as stream:
                for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                    digest.update(chunk)
            if digest.hexdigest() != oid:
                raise ValueError(f"Damaged Git LFS object {oid}")
            for row in batch_rows(raw):
                if row["success"] and (row["distance"] == 0 or row["legacyCanonicalDistance"] == 0):
                    if row["statusFolder"] != "CORRECT":
                        raise ValueError(f"Historical incorrect zero: {row['relativePath']}")
                    paired.add((row["relativePath"], row["leftPredicate"], row["rightPredicate"]))
        for arm in ("canonical", "typed-slotted-port-egraph", "slotted-egraph"):
            file = f"egraph_ablation/{arm}/pairs.csv"
            blob = git("rev-parse", f"{tag}:{file}").decode().strip()
            sources[file] = blob
            if blob not in seen:
                seen.add(blob)
                for r in csv.DictReader(io.StringIO(git("cat-file", "blob", blob).decode())):
                    if r["success"] == "true" and r["distance"] == "0":
                        if r["status"] != "CORRECT":
                            raise ValueError(f"Historical incorrect zero: {r['relativePath']}")
                        paired.add((r["relativePath"], r["leftPredicate"], r["rightPredicate"]))
        for arm, field in (("canonical", "certificateIntegratedDistance"), ("fast_rewrite", "fastRewriteCanonicalDistance")):
            file = f"alloy4fun-augmented/correct_ast_diff_{arm}_equiv.json"
            blob = git("rev-parse", f"{tag}:{file}").decode().strip()
            sources[file] = blob
            if blob not in seen:
                seen.add(blob)
                data = json.loads(git("cat-file", "blob", blob))
                if len(data["pairs"]) != data["pairCount"]:
                    raise ValueError(blob)
                for row in data["pairs"]:
                    if row[field] != 0 or row["rawAstDistance"] <= 0:
                        raise ValueError(blob)
                    endpoints = [(row[s]["source"], row[s]["name"]) for s in ("left", "right")]
                    pool.add(pair((row["questionSet"], row["invariantId"]), *endpoints))
    claims = dict(pairedStructural=sorted(paired), poolStructural=sorted(pool))
    floor = dict(schema="acgn-historical-pairs-v1", gitBlobs=tags, claims=claims)
    with (FLOORS / filename).open("wb") as stream:
        with gzip.GzipFile(filename="", mode="wb", fileobj=stream, mtime=0) as out:
            out.write(json.dumps(floor, separators=(",", ":")).encode())
    print(f"{len(paired)} paired and {len(pool)} reference-pool structural zeros.")


if __name__ == "__main__":
    write_floor(("artifact-freeze-v2", *TAGS), "v2-coverage.json.gz")
    write_floor(("artifact-freeze-v1",), "artifact-freeze-v1.json.gz")
