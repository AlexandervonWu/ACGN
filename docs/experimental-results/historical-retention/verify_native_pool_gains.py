"""Replay the original Alloy check for each structural pool gain over v3.3."""
import argparse
from concurrent.futures import ThreadPoolExecutor
from contextlib import ExitStack
import csv
import gzip
import hashlib
import json
from pathlib import Path
import subprocess


def require(condition, message):
    if not condition:
        raise ValueError(message)


def records(path):
    opener = gzip.open if path.suffix == ".gz" else open
    with opener(path, "rt") as stream:
        for line in stream:
            yield json.loads(line)


def structural_zeros(path, identities):
    zeros = set()
    for row in records(path):
        if row["structuralZero"]:
            key = tuple(sorted(identities[row[side + "Source"], row[side]] for side in ("left", "right")))
            require(key not in zeros, f"Duplicated structural pair {key}")
            zeros.add(key)
    return zeros


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("jar", type=Path)
    parser.add_argument("candidate", type=Path, help="Raw or compressed pool decision ledger")
    parser.add_argument("output", type=Path, help="New directory for receipts and native challenges")
    parser.add_argument("--workers", type=int, default=4)
    args = parser.parse_args()
    require(args.workers > 0, "Choose a positive worker count")
    repo = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip())
    archive = repo / "docs/experimental-results/2026-11-25"
    work = args.output.resolve()
    work.mkdir()
    refs = {r["id"]: r for r in records(archive / "references.jsonl.gz")}
    identities = {(r["source"], r["name"]): r["id"] for r in refs.values()}
    require(len(identities) == len(refs) == 4496, "Incomplete frozen reference inventory")
    baseline = structural_zeros(archive.parent / "v3.3/correct-pool-pairs.jsonl.gz", identities)
    candidate = structural_zeros(args.candidate, identities)
    gains = candidate - baseline
    require(baseline <= candidate, "Candidate dropped a v3.3 structural pair")
    generated = set()
    partitions = [work / f"challenges-{i}.jsonl" for i in range(args.workers)]
    for ref in refs.values():
        actual = hashlib.sha256((repo / "classified-data" / ref["source"]).read_bytes()).hexdigest()
        require(actual == ref["sha"], f"Changed original source for reference {ref['id']}")
    with ExitStack() as inputs, gzip.open(archive / "pairs.csv.gz", "rt") as stream:
        writers = [inputs.enter_context(p.open("x")) for p in partitions]
        for row in csv.DictReader(stream):
            pair = int(row["left"]), int(row["right"])
            if pair not in gains:
                continue
            left, right = (refs[i] for i in pair)
            command = (left["base"] + "\n" + left["code"] + right["code"] + "\ncheck correct { "
                       + left["selected"] + " iff " + right["selected"] + " }\n")
            digest = hashlib.sha256(command.encode()).hexdigest()
            require(row["native"] == "UNSAT" and digest == row["root_sha256"], f"Wrong archived command for {pair}")
            require(pair not in generated, f"Duplicated archived command {pair}")
            print(json.dumps(dict(ids=pair, source=command, sha256=digest)), file=writers[len(generated) % len(writers)])
            generated.add(pair)
    require(generated == gains, "A gained reference has no archived command")
    classpath = f"{work}:{args.jar.resolve()}:{repo}/lib/*"
    driver = Path(__file__).with_name("ReplayGains.java")
    subprocess.run(["javac", "--release", "17", "-cp", classpath, "-d", str(work), str(driver)], check=True)

    def replay(i):
        with (work / f"worker-{i}.log").open("x") as log:
            subprocess.run(["java", "-Xmx512m", "-XX:ActiveProcessorCount=1",
                            "-Dorg.slf4j.simpleLogger.defaultLogLevel=warn", "-cp", classpath, "ReplayGains",
                            str(partitions[i]), str(work / f"pair-{i}.als"), str(work / f"checked-{i}.jsonl")],
                           stdout=log, stderr=subprocess.STDOUT, check=True)

    with ThreadPoolExecutor(args.workers) as pool:
        list(pool.map(replay, range(args.workers)))
    results = sorted((r for i in range(args.workers) for r in records(work / f"checked-{i}.jsonl")),
                     key=lambda r: r["ids"])
    require(len(results) == len(gains) and {tuple(r["ids"]) for r in results} == gains
            and all(r["native"] == "UNSAT" for r in results), "Incomplete or disputed native replay")
    with (work / "native-pool-gains.jsonl.gz").open("xb") as raw, gzip.GzipFile(filename="", fileobj=raw, mode="wb", mtime=0) as out:
        for result in results:
            out.write((json.dumps(result, separators=(",", ":"), sort_keys=True) + "\n").encode())
    print(f"{len(results)} of {len(gains)} gained reference pairs returned UNSAT at the archived Alloy command.")


if __name__ == "__main__":
    main()
