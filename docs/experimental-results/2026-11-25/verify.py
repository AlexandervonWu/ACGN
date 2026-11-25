"""Recount the release evidence. --emit LEFT RIGHT writes the exact checked Alloy module to stdout."""
import argparse
import csv
import gzip
import hashlib
import itertools
import json
import os
import subprocess
import sys
import tempfile
from collections import Counter, defaultdict
from pathlib import Path

data = Path(__file__).resolve().parent
corpus = data.parents[2] / "classified-data"
rules = {"classifier", "difference", "fiber", "mixedRole", "role"}


def need(test, message):
    if not test:
        raise ValueError(message)


def sha(blob):
    return hashlib.sha256(blob).hexdigest()


class Components:
    def __init__(self, n):
        self.parent = list(range(n))

    def root(self, a):
        while a != self.parent[a]:
            self.parent[a] = self.parent[self.parent[a]]
            a = self.parent[a]
        return a

    def join(self, a, b):
        self.parent[self.root(a)] = self.root(b)

    def count(self, members):
        return len({self.root(i) for i in members})


def verify(emit, live):
    seal = {name: h for h, name in (line.split("  ", 1) for line in (data / "SHA256SUMS").read_text().splitlines())}
    need(set(seal) == {"summary.json","references.jsonl.gz","pairs.csv.gz","question-pools.csv"}, "incomplete archive")
    for name, h in seal.items():
        need(sha((data / name).read_bytes()) == h, name)
    summary = json.loads((data / "summary.json").read_bytes())
    with gzip.open(data / "references.jsonl.gz", "rt", encoding="utf8") as f:
        refs = list(map(json.loads, f))
    groups = defaultdict(list)
    for i, r in enumerate(refs):
        p = (corpus / r["source"]).resolve()
        need(p.is_relative_to(corpus) and sha(p.read_bytes()) == r["sha"] and i == r["id"], "foreign source")
        groups[tuple(r["group"])].append(i)
    expected = {pair for g in groups.values() for pair in itertools.combinations(g,2)}
    before, after = Components(len(refs)), Components(len(refs))
    sat, observed = [], set()
    hits = Counter()
    matches = new = zeros = 0
    module = None
    challenges = []
    with gzip.open(data / "pairs.csv.gz","rt",encoding="utf8",newline="") as f:
        for row in csv.DictReader(f):
            a,b = int(row["left"]),int(row["right"])
            need((a,b) in expected and (a,b) not in observed, "foreign or duplicate pair")
            observed.add((a,b))
            x,y = refs[a],refs[b]
            root = (x["base"]+"\n"+x["code"]+y["code"]+"\ncheck correct { "+
                    x["selected"]+" iff "+y["selected"]+" }\n").encode("utf8")
            need(sha(root) == row["root_sha256"], f"wrong command bytes: {a},{b}")
            if emit == [a,b]:
                module = root
            need(row["baseline_zero"] in {"0","1"} and row["native"] in {"SAT","UNSAT"}, "unknown status")
            zero = row["baseline_zero"] == "1"
            if zero:
                before.join(a,b)
                after.join(a,b)
                zeros += 1
            if row["native"] == "SAT":
                sat.append((a,b))
            applied = row["forward"].split("|") if row["forward"] else []
            need(row["forward"] == row["reverse"] and sorted(set(applied)) == applied
                 and set(applied) <= rules, "asymmetric or unknown reader")
            if applied:
                need(row["native"] == "UNSAT","rule accepted a native counterexample")
                after.join(a,b)
                hits.update(applied)
                matches += 1
                new += not zero
            if live and (applied or row["native"] == "SAT"):
                challenges.append(dict(pair=[a,b], source=root.decode("utf8"), native=row["native"],rules=applied))
    need(observed == expected and zeros == 11882, "incomplete pair population")
    need(all(after.root(a) != after.root(b) for a,b in sat), "counterexample inside component")
    pools = [dict(group=list(k),before=before.count(g),after=after.count(g)) for k,g in groups.items()]
    with (data / "question-pools.csv").open(newline="") as f:
        need([(p["question_set"],p["invariant"],int(p["v3_1_components"]),int(p["v3_2_scoped_components"]))
              for p in csv.DictReader(f)] == [(*p["group"],p["before"],p["after"]) for p in pools], "pool table")
    counts = dict(refs=len(refs),pairs=len(observed),directions=2*len(observed),before=sum(p["before"] for p in pools),
                  after=sum(p["after"] for p in pools),nativeSAT=len(sat),newEdges=new,matches=matches)
    need(all(summary[k] == v for k,v in counts.items()) and summary["pools"] == pools
         and summary["readerPairs"] == hits, "summary disagrees with receipts")
    if emit:
        need(module is not None, "choose an ordered pair from the same pool")
        sys.stdout.buffer.write(module)
    else:
        print(f"Verified {len(groups)} pools; {counts}; {sum(p['before'] != p['after'] for p in pools)} pools changed.")
    if live:
        root = corpus.parent
        with tempfile.TemporaryDirectory() as directory:
            tmp = Path(directory)
            classes = tmp / "classes"
            requests = tmp / "challenges.jsonl"
            with requests.open("w") as stream:
                for item in challenges:
                    print(json.dumps(item),file=stream)
            cp = os.pathsep.join([str(classes),str(root / "lib" / "*")])
            subprocess.run(["bash","scripts/proven-rules/build.sh",classes],cwd=root,check=True)
            subprocess.run(["javac","--release","17","-cp",cp,"-d",classes,
                            "scripts/proven-rules/tests/PooledReplay.java"],cwd=root,check=True)
            subprocess.run(["java","-ea","-Xmx512m","-XX:ActiveProcessorCount=1",
                            "-Dorg.slf4j.simpleLogger.defaultLogLevel=warn","-cp",cp,
                            "is.fivefivefive.CanDis.augmentation.PooledReplay",requests,tmp / "pair.als"],cwd=root,check=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group()
    action.add_argument("--emit", nargs=2, type=int, metavar=("LEFT","RIGHT"))
    action.add_argument("--live", action="store_true", help="also rerun all reader matches and SAT controls with JDK 17")
    args = parser.parse_args()
    verify(args.emit, args.live)
