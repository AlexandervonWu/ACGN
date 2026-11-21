"""Recompute the counts and matched runtime medians from the published v3.1 rows."""
import csv
import gzip
import hashlib
import json
from collections import Counter, defaultdict
from pathlib import Path
from statistics import median


def main(root):
    def read(name):
        return json.loads((root/name).read_text())

    index=read("execution-index.json")
    assert len({s["stage"] for s in index["accepted"]})==len(index["accepted"])==20
    complete=read("supervisor/complete.json")
    assert complete["status"]=="MEASURED" and complete["tag"]==index["releaseCommit"]
    decision=read("supervisor/terra-v4b.json")
    assert decision["decision"]=="ACCEPT" and decision["authorizedStages"]==[s["stage"] for s in index["accepted"]]
    for name,wanted in (("approval.json",complete["review"]["sha256"]),("request-v4b.json",decision["submissionSha256"]),("terra-v4b.json",index["reviewDecisionSha256"])):
        assert hashlib.sha256((root/"supervisor"/name).read_bytes()).hexdigest()==wanted
    for s,pin in zip(index["accepted"],complete["accepted"],strict=True):
        stage=s["stage"]
        plan=(root/"supervisor/plans"/(stage+".json")).read_bytes()
        assert hashlib.sha256(plan).hexdigest()==pin["plan"]["sha256"]==s["planSha256"]
        with gzip.open(root/"supervisor/receipts"/(stage+".json.gz")) as f: data=f.read()
        assert hashlib.sha256(data).hexdigest()==pin["receipt"]["sha256"]==s["receiptSha256"]
        r=json.loads(data)
        assert r["descendantsExited"] and r["exit"]==r["guardedExit"]==r["terminal"]["commandExit"]==0
        assert r["plan"]==pin["plan"] and r["review"]==complete["review"] and r["witness"]==pin["witness"]
    for ref in index["copied"]:
        assert hashlib.sha256((root/ref["path"]).read_bytes()).hexdigest()==ref["sha256"],ref["path"]
    groups=defaultdict(list)
    for arm in read("arm-results.json"):
        groups[arm["study"]].append(arm)
    assert {k:len(v) for k,v in groups.items()}=={"capability/arms":7,"natural-ablation":7,"natural-slot-typing":2}
    skipped=(root/"natural-ablation/ast-identical-files.txt").read_text().splitlines()
    assert len(set(skipped))==len(skipped)==4482
    natural=None
    for study, arms in groups.items():
        folder="capability" if study=="capability/arms" else study
        seen=set()
        zeros=Counter()
        with gzip.open(root/folder/"pair-distances.csv.gz","rt",newline="") as f:
            rows=csv.DictReader(f)
            assert rows.fieldnames[4:]==[a["engine"] for a in arms]
            for row in rows:
                key=tuple(row[k] for k in rows.fieldnames[:4])
                assert key not in seen
                seen.add(key)
                for engine in rows.fieldnames[4:]:
                    d=int(row[engine])
                    assert d>=0
                    zeros[engine]+=d==0
        for a in arms:
            assert a["status"]=="PASS" and a["failures"]==0
            assert a["eligible"]==len(seen) and a["zeroDistancePairs"]==zeros[a["engine"]]
            assert a["processed"]==len(seen)+a["identicalPairedRows"]
        if folder!="capability":
            assert len(seen)==61598 and not set(skipped).intersection(k[0] for k in seen)
            assert all(a["processed"]==66080 for a in arms)
            if natural is None: natural=seen
            else: assert seen==natural
        else: assert len(seen)==5500
    audit=read("synthetic/audit.json")
    summary=read("synthetic/summary.json")
    assert audit["status"]=="PASS" and summary["complete"] and summary["timeoutSeconds"]==300
    by_arm=defaultdict(dict)
    with (root/"synthetic/trials.jsonl").open() as f:
        for line in f:
            t=json.loads(line)
            assert t["arm"] in ("typed","untyped") and t["status"] in ("SUCCESS","TIMEOUT")
            key=t["predicateKey"]
            assert key not in by_arm[t["arm"]]
            by_arm[t["arm"]][key]=t
    a,b=by_arm["typed"],by_arm["untyped"]
    assert a.keys()==b.keys() and len(a)==audit["predicates"]==540 and audit["trials"]==1080
    assert all(a[k]["sourceSha256"]==b[k]["sourceSha256"] for k in a)
    jointly=[k for k in a if a[k]["status"]==b[k]["status"]=="SUCCESS"]
    for arm,trials in by_arm.items():
        assert Counter(t["status"] for t in trials.values())==audit["outcomes"][arm]==summary["all"][arm]["statuses"]
        m=summary["matchedSuccessful"][arm]
        assert m["predicates"]==len(jointly)
        assert median(trials[k]["runtimeSeconds"] for k in jointly)==m["runtimeSecondsSuccessful"]["median"]
    print("Verified: 20 stages, 16 arm totals, paired-file accounting and 1,080 synthetic trials.")


if __name__=="__main__":
    main(Path(__file__).resolve().parent)
