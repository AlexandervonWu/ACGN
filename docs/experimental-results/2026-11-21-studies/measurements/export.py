"""Export completed v3.1 supplemental stages without reading a running or failed arm as a result."""
import argparse
import csv
import gzip
import hashlib
import io
import json
import shutil
from contextlib import ExitStack
from pathlib import Path


def digest(f):
    with Path(f).open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def read(ref):
    p = Path(ref["file"])
    data = p.read_bytes()
    assert hashlib.sha256(data).hexdigest() == ref["sha256"], p
    return json.loads(data)


def dump(p, v):
    with p.open("x") as f:
        json.dump(v, f, indent=2)
        f.write("\n")


def compare(old, new):
    cols = ("relativePath", "leftPredicate", "rightPredicate", "status")
    both = gained = lost = count = 0
    with old.open(newline="") as f, new.open(newline="") as g:
        for a, b in zip(csv.DictReader(f), csv.DictReader(g), strict=True):
            assert all(a[k] == b[k] for k in cols)
            assert a["success"] == b["success"] == "true"
            z, w = int(a["distance"]) == 0, int(b["distance"]) == 0
            both += z and w
            gained += w and not z
            lost += z and not w
            count += 1
    return dict(rows=count, zeroInBoth=both, newlyZero=gained, noLongerZero=lost)


def publish_distances(dest, arms):
    """Join measured rows by checked identities, with engine IDs as column names."""
    keys=("relativePath","status","leftPredicate","rightPredicate")
    counts=[0]*len(arms)
    with ExitStack() as files:
        readers=[csv.DictReader(files.enter_context((path/"pairs.csv").open(newline=""))) for _,path,_ in arms]
        raw=files.enter_context(dest.open("xb"))
        gz=files.enter_context(gzip.GzipFile(filename="",fileobj=raw,mode="wb",mtime=0))
        writer=csv.writer(files.enter_context(io.TextIOWrapper(gz,encoding="utf-8",newline="")))
        writer.writerow([*keys,*(engine for engine,_,_ in arms)])
        n=0
        for rows in zip(*readers,strict=True):
            identity=[rows[0][k] for k in keys]
            values=[]
            for i,row in enumerate(rows):
                assert [row[k] for k in keys]==identity and row["success"]=="true"
                d=int(row["distance"])
                assert d>=0 and (row["equivalent"]=="true") == (d==0)
                values.append(d)
                counts[i]+=d==0
            writer.writerow(identity+values)
            n+=1
        assert all(a["zeroDistancePairs"]==counts[i] and a["eligible"]==n for i,(_,_,a) in enumerate(arms))


def run(supervisor, previous, dest):
    state = json.loads((supervisor/"complete.json").read_text())
    pins = state["accepted"]
    assert state["status"] == "MEASURED" and len(pins) == 20
    approval = read(state["review"])
    answer = read(approval["answer"])
    request = read(approval["request"])
    assert answer["decision"] == "ACCEPT" and answer["submissionSha256"] == approval["request"]["sha256"]
    assert [pin["plan"] for pin in pins] == [s["plan"] for s in request["stages"]]
    dest.mkdir()
    measured, proofs, copied, groups = [], [], [], {}
    def copy(src, rel):
        f = dest/rel
        f.parent.mkdir(parents=True, exist_ok=True)
        with Path(src).open("rb") as i, f.open("xb") as o:
            shutil.copyfileobj(i,o)
        assert digest(f) == digest(src)
        copied.append({"path": str(rel), "sha256": digest(f)})

    for i, pin in enumerate(pins):
        p, r = read(pin["plan"]), read(pin["receipt"])
        assert r["plan"] == pin["plan"] and r["review"] == state["review"]
        assert r["exit"] == r["guardedExit"] == r["terminal"]["commandExit"] == 0 and r["descendantsExited"]
        assert r["validationError"] is None
        a = read(r["authority"])
        assert a["priors"] == pins[:i] and a["review"] == state["review"]
        witness = pin["witness"]
        assert witness == r["witness"] and witness["unit"] == r["terminal"]["unit"] and witness["authority"] == r["authority"]["sha256"]
        child = read({"file":str(Path(p["runDir"])/"child.json"),"sha256":witness["child"]})
        assert child == r["child"] and child["status"] == child["exit"] == 0 and child["identityVerified"]
        output=Path(p["output"])
        assert {str(f) for f in output.rglob("*") if f.is_file()} == {f["file"] for f in child["outputHashes"]}
        for f in child["outputHashes"]:
            assert digest(f["file"]) == f["sha256"], f
        stage=p["stage"]
        proofs.append(dict(stage=stage, planSha256=pin["plan"]["sha256"], receiptSha256=pin["receipt"]["sha256"],
                           guardedChildSha256=witness["child"], serviceUnit=witness["unit"], descendantsExited=True))
        if p["job"] == "arm":
            audit=json.loads((output/"audit.json").read_text())
            group = ("capability/arms" if stage.startswith("capability-") else
                     "natural-slot-typing" if stage.startswith("slot-typing-") else "natural-ablation")
            old = previous/group/p["engine"]
            oldaudit = json.loads((old/"audit.json").read_text())
            assert digest(old/"pairs.csv") == oldaudit["evidence"]["pairs.csv"]
            assert audit["status"] == "PASS" and audit["failures"] == 0
            delta=compare(old/"pairs.csv",output/"pairs.csv")
            assert delta["rows"] == audit["eligible"] and delta["zeroInBoth"]+delta["newlyZero"] == audit["zeroDistancePairs"]
            measured.append(dict(study=group,engine=p["engine"],deltaFromV3=delta,**audit))
            groups.setdefault(group,[]).append((p["engine"],output,audit))
        elif stage == "synthetic-slot-runtime":
            for name in ("summary.json","audit.json","predicates.csv","trials.jsonl","summary.md","validation.json"):
                copy(output/"grid"/name,Path("synthetic")/name)
            for f in sorted((output/"plots").rglob("*")):
                if f.is_file(): copy(f,Path("synthetic/plots")/f.relative_to(output/"plots"))
        else:
            names={
                "natural-report-and-soundness":("natural-ablation",["comparison.json","summary.md","semantic_soundness.md","semantic_counterexamples.csv"]),
                "capability-report":("capability",["REPORT.md","results.json","results.csv","transitions.csv","unexpected_failures.csv"]),
                "slot-typing-report":("natural-slot-typing",["comparison.json","summary.md"])}
            folder, files=names[stage]
            for name in files:copy(output/"work"/name,Path(folder)/name)
            if stage == "capability-report":
                assert "boundedSoundness" not in json.loads((output/"work/results.json").read_text())
            elif stage == "natural-report-and-soundness":
                s=json.loads((output/"work/semantic_soundness.json").read_text())
                assert all(not (r["counterexamples"] or r["errors"]) for r in s["arms"])
                assert all(p["alloyCounterexample"] and not p["error"] and not any(p["mergedByEngine"].values()) for p in s["targetedProbes"])
                dump(dest/"natural-ablation"/"bounded-checks.json",{k:s[k] for k in ("checkedUniquePairs","arms","targetedProbes","claimSourceGitSha")})
    for group, arms in groups.items():
        folder=dest/("capability" if group=="capability/arms" else group)
        publish_distances(folder/"pair-distances.csv.gz", arms)
    _,path,audit=groups["natural-ablation"][0]
    with (path/"first-attempts.jsonl").open() as f:
        skipped=sorted(row["file"] for line in f if (row:=json.loads(line))["skipped"])
    assert len(skipped)==len(set(skipped))==audit["identicalPairedRows"]
    with (dest/"natural-ablation"/"ast-identical-files.txt").open("x") as f:
        f.writelines(s+"\n" for s in skipped)
    dump(dest/"arm-results.json",measured)
    dump(dest/"execution-index.json",dict(releaseCommit=request["releaseTag"],compiledAt=request["build"],
         approvalSha256=state["review"]["sha256"],reviewDecisionSha256=approval["answer"]["sha256"],
         requestSha256=approval["request"]["sha256"],accepted=proofs,copied=copied,publicCertification="BLOCKED"))
    for f in ("service.mjs","receipts.mjs","report-job.mjs","CheckedClaims.java","coordinate-v4b.mjs","prepare.mjs",
              "capability-correction.mjs","report-controls.mjs","seal-controls.mjs","terra-v4b.json",
              "approval.json","request-v4b.json","complete.json","terra-answer.json","seal-fixture/result.json","report-fixture/result.json"):
        copy(supervisor/f,Path("supervisor")/f)
    for pin in pins:
        plan=read(pin["plan"])
        copy(pin["plan"]["file"],Path("supervisor/plans")/(plan["stage"]+".json"))
        f=dest/"supervisor"/"receipts"/(plan["stage"]+".json.gz")
        f.parent.mkdir(exist_ok=True)
        with f.open("xb") as raw, gzip.GzipFile(filename="",fileobj=raw,mode="wb",mtime=0) as out, Path(pin["receipt"]["file"]).open("rb") as src:
            shutil.copyfileobj(src,out)
        with gzip.open(f) as inp:
            assert hashlib.file_digest(inp,"sha256").hexdigest()==pin["receipt"]["sha256"]


if __name__ == "__main__":
    ap=argparse.ArgumentParser(description=__doc__)
    for name in ("supervisor","previous","destination"):ap.add_argument(name,type=Path)
    args=ap.parse_args()
    run(args.supervisor,args.previous,args.destination)
