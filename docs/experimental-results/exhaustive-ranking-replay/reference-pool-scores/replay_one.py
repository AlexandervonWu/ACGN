"""Replay one published within-reference pair with the two original scalar entry points."""

import argparse
import csv
import gzip
import json
from pathlib import Path
import subprocess
import tempfile
from verify import sha, read, need, CATALOG


def run(archive, repo, side, jar, libs, ids):
    ref = archive / "reference-catalog.tsv"
    need(sha(ref) == CATALOG, "Wrong original reference catalog")
    identity = read(archive / (side + "-identity.json"))
    need(sha(jar) == identity["jarSha256"], "Unregistered " + side + " engine JAR")
    deps = {p.name: sha(p) for p in libs.glob("*.jar")}
    need(deps == identity["runtime"], "Wrong runtime dependencies")
    order = read(archive / ("runtime-order-" + side + ".json"))["jarOrder"]
    need(
        len(order) == len(set(order)) and set(order) == set(deps),
        "Unbound measured dependency order",
    )
    classes = archive / (side + "-classes")
    need(
        {p.relative_to(classes).as_posix(): sha(p) for p in classes.rglob("*.class")}
        == identity["classes"],
        "Wrong compiled scalar driver",
    )
    with ref.open() as f:
        catalog = {int(r["referenceId"]): r for r in csv.DictReader(f, delimiter="\t")}
    selected = set(ids)
    need(
        len(selected) == 2 and all(i in catalog for i in ids),
        "Select two distinct original references",
    )
    rows = []
    with gzip.open(archive / "positive-scores.tsv.gz", "rt") as f:
        for line in f:
            a, b, of, oc, nf, nc = map(int, line.split())
            if {a, b} == selected:
                rows.append(((a, b), (of, oc) if side == "original" else (nf, nc)))
    with gzip.open(archive / "zero.jsonl.gz", "rt") as f:
        for line in f:
            row = json.loads(line)
            if set(row["referenceIds"]) == selected:
                rows.append((tuple(row["referenceIds"]), (0, 0)))
    need(len(rows) == 1, "Pair missing from this invariant pool")
    pair, expected = rows[0]
    with tempfile.TemporaryDirectory() as tmp:
        t = Path(tmp)
        jobs = t / "jobs.tsv"
        result = t / "scores.tsv"
        jobs.write_text("\t".join(map(str, pair)) + "\n")
        command = [
            "java",
            "-Xmx2100m",
            "-Dacgn.pool.cache=2",
            "-XX:ActiveProcessorCount=1",
            "-cp",
            ":".join(map(str, [classes, jar, *[libs / name for name in order]])),
            "is.fivefivefive.CanDis.PoolScalars",
            str(repo / "classified-data"),
            str(ref),
        ]
        observed = subprocess.run(
            command, input=f"{jobs}\t{result}\n", capture_output=True, text=True
        )
        need(
            observed.returncode == 0 and observed.stdout.strip() == "1",
            observed.stderr or observed.stdout,
        )
        data = tuple(map(int, result.read_text().split()))
        need(
            data[:2] == pair and data[2:] == expected, "Live engine scalar differs from the archive"
        )
        return dict(
            engine=side,
            sha256=identity["jarSha256"],
            selected=[catalog[i] for i in pair],
            fast=data[2],
            certified=data[3],
        )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("archive", type=Path)
    p.add_argument("--repo", required=True, type=Path)
    p.add_argument("--jar", required=True, type=Path)
    p.add_argument("--lib-dir", required=True, type=Path)
    p.add_argument("--side", choices=("original", "final"), required=True)
    p.add_argument("referenceIds", type=int, nargs=2)
    a = p.parse_args()
    print(
        json.dumps(
            run(
                a.archive.resolve(),
                a.repo.resolve(),
                a.side,
                a.jar.resolve(),
                a.lib_dir.resolve(),
                a.referenceIds,
            ),
            sort_keys=True,
        )
    )
