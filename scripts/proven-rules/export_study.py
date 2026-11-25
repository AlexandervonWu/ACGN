"""Export portable observations from the accepted five-reader pooled experiment."""
import csv
import gzip
import hashlib
import io
import json
import sys
from contextlib import contextmanager
from pathlib import Path


def need(ok, message):
    if not ok:
        raise ValueError(message)


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def rows(path):
    with path.open() as stream:
        yield from map(json.loads, stream)


@contextmanager
def compressed(path):
    with path.open("xb") as raw, gzip.GzipFile(filename="", mode="wb", fileobj=raw, mtime=0) as gz:
        with io.TextIOWrapper(gz, encoding="utf8", newline="") as stream:
            yield stream


def export(run, dest):
    full = run / "full"
    result_sha = "9f27ebb20e43663a97c59919a22d22ad7d2bc4f3d255b1d78bf6100ae066ef1f"
    need(digest(full / "result.json") == result_sha, "unexpected terminal result")
    result = json.loads((full / "result.json").read_bytes())
    need(digest(run / "inputs.sha256") == result["inputSeal"], "input seal changed")
    sealed = {Path(name): sha for sha, name in (line.split("  ", 1)
              for line in (run / "inputs.sha256").read_text().splitlines())}
    for name in ("references.jsonl", "endpoint-bundles.jsonl"):
        need(digest(run / name) == sealed[run / name], name)
    refs = list(rows(run / "references.jsonl"))
    index = {(*r["group"], r["name"]): r for r in refs}
    output_index = run.parent / "02-augmenter-v31-control/outputs.json"
    need(digest(output_index) == sealed[output_index], "baseline output inventory")
    outs = json.loads(output_index.read_bytes())
    baseline = []
    for kind in ("canonical", "fast_rewrite"):
        path = run.parent / "results-augmenter-control" / ("correct_ast_diff_" + kind + "_equiv.json")
        need(digest(path) == outs[path.name], "baseline " + kind)
        edges = set()
        for p in json.loads(path.read_bytes())["pairs"]:
            ab = []
            for endpoint in (p["left"], p["right"]):
                r = index[p["questionSet"], p["invariantId"], endpoint["name"]]
                need((r["kind"], r["source"]) == (endpoint["kind"], endpoint["source"]), "endpoint")
                ab.append(r["id"])
            need(p["canonicalDistance"] == p["fastRewriteCanonicalDistance"] == 0 < p["rawAstDistance"], "distance")
            edges.add(tuple(sorted(ab)))
        baseline.append(edges)
    need(len(baseline[0]) == 11882 and baseline[0] == baseline[1], "baseline mismatch")
    dest.mkdir(parents=True, exist_ok=True)
    bundles = list(rows(run / "endpoint-bundles.jsonl"))
    need(len(bundles) == len(refs) == len(index) == result["refs"], "endpoint inventory")
    with compressed(dest / "references.jsonl.gz") as out:
        for i, (b, r) in enumerate(zip(bundles, refs)):
            need(b["id"] == r["id"] == i and b["sourceSHA"] == r["sha"] and b["group"] == r["group"], "binding")
            print(json.dumps({k: r[k] for k in ("id","name","source","sha","group","kind","operator")}
                  | {k: b[k] for k in ("base","code","selected")}, ensure_ascii=False, separators=(",",":")), file=out)
    with compressed(dest / "pairs.csv.gz") as out:
        w = csv.writer(out, lineterminator="\n")
        w.writerow(("left","right","baseline_zero","native","forward","reverse","root_sha256"))
        for shard, expected in sorted(result["ledgers"].items()):
            path = full / shard / "output.jsonl"
            need(digest(path) == expected, "shard " + shard)
            for p in rows(path):
                a,b = p["pair"]
                need(p["sourceSHA"] == [refs[a]["sha"],refs[b]["sha"]], "source identity")
                w.writerow((a,b,int((a,b) in baseline[0]),p["native"],"|".join(sorted(p["ab"])),
                            "|".join(sorted(p["ba"])),p["root"]))
    with (dest / "summary.json").open("x") as out:
        del result["guard"]
        print(json.dumps(result | {"originalResultSHA256":result_sha}, indent=2, sort_keys=True),file=out)
    with (dest / "question-pools.csv").open("x", newline="") as out:
        w = csv.writer(out, lineterminator="\n")
        w.writerow(("question_set","invariant","v3_1_components","v3_2_scoped_components"))
        w.writerows((*p["group"],p["before"],p["after"]) for p in result["pools"])
    with (dest / "SHA256SUMS").open("x") as out:
        for name in ("references.jsonl.gz", "pairs.csv.gz", "summary.json", "question-pools.csv"):
            print(digest(dest / name), name, sep="  ", file=out)


if __name__ == "__main__":
    export(Path(sys.argv[1]).resolve(), Path(sys.argv[2]))
