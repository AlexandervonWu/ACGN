"""Verify the v3.3 export from its checksums and published comparison rows."""
import csv
import gzip
import hashlib
import json
from pathlib import Path
from collections import defaultdict

HERE = Path(__file__).resolve().parent

def insist(condition, message):
    if not condition:
        raise ValueError(message)


def components(vertices, edges):
    parent={v:v for v in vertices}
    def root(v):
        while parent[v]!=v:
            v=parent[v]
        return v
    for a,b in edges:
        parent[root(a)]=root(b)
    return len({root(v) for v in vertices})


def verify_pools(pools):
    groups=defaultdict(dict)
    with gzip.open(HERE/"correct-pool-pairs.jsonl.gz","rt") as source:
        for line in source:
            r=json.loads(line)
            k=(r["questionSet"],r["invariantId"])
            pair=tuple(sorted((r[b+"Source"],r[b]) for b in ("left","right")))
            insist(pair[0]!=pair[1] and pair not in groups[k], f"Duplicate comparison: {k} {pair}")
            matched=r["scopeStatus"]=="FIXED_COMMAND_RULE"
            insist(r["equivalent"]==(r["structuralZero"] or matched),f"Equality basis: {k}")
            if matched:
                insist(r["native"]=="UNSAT" and r["rules"],f"No native check: {k}")
            groups[k][pair]=r
    for pool in pools:
        key=pool["questionSet"],pool["invariantId"]
        rows=groups.pop(key,{})
        n=int(pool["references"])
        insist(len(rows)==int(pool["pairs"])==n*(n-1)//2,f"Incomplete pool: {key}")
        vertices={e for pair in rows for e in pair}
        raw=[pair for pair,r in rows.items() if r["structuralZero"]]
        joint=[pair for pair,r in rows.items() if r["equivalent"]]
        missing=sum(r["scopeStatus"]=="NO_COMMON_COMMAND" for r in rows.values())
        cases=sum(r["scopeStatus"]=="FIXED_COMMAND_RULE" for r in rows.values())
        insist(missing==int(pool["noCommonCommand"]) and cases==int(pool["ruleMatches"]),f"Scope counts: {key}")
        insist(n<=1 or len(vertices)==n,f"Missing references: {key}")
        structural=components(vertices,raw) if rows else n
        scoped=components(vertices,joint) if rows else n
        insist(structural==int(pool["structuralClasses"]),f"Structural classes: {key}")
        insist(pool["commandScopedComponents"]==("" if missing else str(scoped)),f"Fixed-command classes: {key}")
    insist(not groups,"Unknown comparison groups")


def main():
    for line in (HERE / "SHA256SUMS").read_text().splitlines():
        digest, name = line.split("  ", 1)
        insist(hashlib.sha256((HERE/name).read_bytes()).hexdigest() == digest, name)
    h=json.loads((HERE/"headlines.json").read_text())
    receipt=json.loads((HERE/"run-receipt.json").read_text())
    f="canonical"
    c="typed-slotted-port-egraph"
    s="slotted-egraph"
    n=h["measured"]
    by_arm={arm:set() for arm in h["armZeroCounts"]}
    pairs={}
    with gzip.open(HERE/"ablation-distances.csv.gz","rt",newline="") as stream:
        for row in csv.DictReader(stream):
            path=row["path"]
            insist(path not in pairs and row[f]==row[c],path)
            for a in by_arm:
                d=int(row[a])
                insist(d >= 0 and (d != 0 or row["status"]=="CORRECT"), f"{a}: {path}")
                if d==0:
                    by_arm[a].add(path)
            pairs[path]=row
    original=set((HERE/"original-slotted-zero-paths.txt").read_text().splitlines())
    insist(len(original)==2228 and original <= by_arm[s],"Original slotted retention")
    insist(len(pairs)==n and by_arm[f]==by_arm[c] and by_arm[s] < by_arm[f],
           "Ablation coverage or parity failed")
    insist({k:len(v) for k,v in by_arm.items()}==h["armZeroCounts"],"Ablation counts")
    matched=0
    seen=set()
    with gzip.open(HERE/"paired-comparisons.jsonl.gz","rt") as stream:
        for line in stream:
            row=json.loads(line)
            path=row["path"]
            p=pairs[path]
            insist(path not in seen and (row["distance"],row["status"],row["left"],row["right"])==
                (int(p[f]),p["status"],p["left"],p["right"]),path)
            seen.add(path)
            hits=[v for v in row["decisions"] if v["basis"]=="FIXED_COMMAND_RULE"]
            if hits:
                insist(row["status"]=="CORRECT" and all(v["native"]=="UNSAT" and v["rules"] for v in hits),path)
                matched+=row["distance"]>0
    insist(seen==pairs.keys() and matched==h["command"]["additionalCorrectPairs"],"Paired counts")
    correct=h["correctPools"]
    with (HERE/"correct-pools.csv").open(newline="") as stream:
        pools=list(csv.DictReader(stream))
    insist(len(pools)==181 and len({(r["questionSet"],r["invariantId"]) for r in pools})==181,
           "Pool key inventory")
    insist(sum(int(r["references"]) for r in pools)==correct["references"] and
           sum(int(r["pairs"]) for r in pools)==correct["pairs"] and
           sum(int(r["structuralClasses"]) for r in pools)==correct["structuralClasses"],
           "Pool totals")
    verify_pools(pools)
    scoped_total=correct["commandScopedComponents"]
    if scoped_total is not None:
        insist(sum(int(r["commandScopedComponents"]) for r in pools)==scoped_total,"Scoped total")
    insist(receipt["status"]=="complete" and receipt["git"]==h["source"] and
           receipt["nativeOperationCounts"]["matched"]==n,"Run identity")
    print(f"Verified {n:,} paired distances and all 181 pools. "
          f"Retained {len(by_arm[s]):,} slotted zeros with {len(by_arm[f]-by_arm[s]):,} structural gains.")


if __name__=="__main__":
    main()
