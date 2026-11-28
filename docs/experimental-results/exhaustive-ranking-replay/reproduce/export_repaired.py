"""Stage or seal the final original/repaired native evidence package after independent closure."""
import argparse
import gzip
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
sys.dont_write_bytecode=True
from native_release import DIGEST,FLOOR,ROWS,inventory,read,regular,require,sha


def put(src,dst):
    if dst.exists():
        require(dst.is_file() and sha(src)==sha(dst),"Published file has different bytes: "+str(dst))
        return
    dst.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=dst.parent) as f,src.open("rb") as inp:
        shutil.copyfileobj(inp,f);f.flush();os.fsync(f.fileno());os.link(f.name,dst)
    dst.chmod(0o644)


def by_name(src,dst,names):
    for n in names: put(regular(src,n),dst/n)


def tree(src,dst):
    require(src.is_dir(),"Missing source directory "+str(src))
    for p in sorted(src.rglob("*")):
        require(not p.is_symlink(),"Unexpected link in portable results "+str(p))
        if p.is_file():put(p,dst/p.relative_to(src))
        if p.is_dir(): (dst/p.relative_to(src)).mkdir(parents=True,exist_ok=True)


def gz_files(srcs,dst):
    dst.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(dir=dst.parent) as temp:
        out=Path(temp)/"bytes.gz"
        with out.open("wb") as raw,gzip.GzipFile(filename="",mode="wb",fileobj=raw,mtime=0,compresslevel=6) as z:
            for p in srcs:
                with p.open("rb") as f:shutil.copyfileobj(f,z)
        put(out,dst)


def base_inputs(w,d):
    """Safe before the repaired execution; it only stages historical data and registered source."""
    reg=read(w/"cohort/auditor-identity.json");o=d/"receipts/original";audit=d/"reproduce/original-audit"
    obligation=read(o/"obligation-manifest.json")
    for n,h in obligation["inputs"].items():
        source=regular(w,n)
        require(sha(source)==h,"Original obligation source changed: "+n)
        put(source,o/"registration"/n)
    for mapping in (reg["files"],reg["calibration"]):
        for n,expected in mapping.items():
            p=regular(w/"cohort",n);require(sha(p)==expected,"Original registered code/calibration differs: "+n)
            put(p,audit/n)
    put(w/"cohort/final-raw-recount.log",o/"final-raw-recount.log")
    p=w/"previously-covered";man=read(p/"manifest.json")
    put(p/"manifest.json",d/"receipts/retention/manifest.json")
    jobs=[]
    for s in man["shards"]:
        j=regular(p,s["path"]);require(sha(j)==s["sha256"],"Changed historical input shard");jobs.append(j)
    gz_files(jobs,d/"receipts/retention/source-jobs.jsonl.gz")
    by_name(p,d/"reproduce/retention",["prepare.py","recount.py","run.py","artifact.py","CoveredReplay.java","archived-commands/check.py","archived-commands/CheckCommands.java"])
    put(w/"preflight/build-revision.py",d/"reproduce/build-revision.py")
    by_name(w/"regression-audit",d/"reproduce/preflight",["verify_checkpoint.py","native_commitment.py","pack_checkpoint.py"])
    put(w/"packaging/replay_regressions.py",d/"reproduce/preflight/replay_regressions.py")
    # The frozen marker/contract validator is published with its registered source.
    put(w/"final-handoff/contract.json",d/"receipts/final-admission-contract.json")
    put(w/"final-handoff/handoff.py",d/"reproduce/final-handoff/handoff.py")


def collect(w,d,repo):
    require((w/"final-handoff/final-started.json").is_file(),"Final launch is pending")
    m=read(w/"final-handoff/final-started.json")
    uid=m["candidateRunId"];root=Path(m["candidateRoot"]).resolve();ident=read(root/"runner-identity.json")
    require(root.parent==w/"candidates" and not (root/"retirement").exists() and uid==ident["candidateRunId"],"Wrong or retired candidate")
    state=w/"final-audit-handoff-v2"/("run-"+uid)
    require((state/"complete.json").is_file() and (root/"independent-closure.json").is_file(),"Independent final ranking and retention closure is pending")
    done=read(state/"complete.json");scope=read(root/"independent-closure.json")
    require(done["status"]==scope["status"]=="VERIFIED" and done["rows"]==scope["rows"]==ROWS and done["markerSha256"]==sha(w/"final-handoff/final-started.json") and done["closureSha256"]==sha(root/"independent-closure.json") and done["candidateIdentitySha256"]==sha(root/"runner-identity.json")==m["identitySha256"],"Full independent final-closure chain is incomplete")
    launch=read(state/"launch.json");retention=Path(launch["sidecar"]).resolve();tools=Path(launch["tools"]).resolve()
    require(retention.parent==w/"previously-covered/runs" and tools.is_relative_to(w) and done["retentionVerdictSha256"]==sha(retention/"compact/combined-verdict.json"),"Wrong final retention receipt")
    subprocess.run([sys.executable,"-B",str(d/"diagnostic-controls/stage.py"),"--experiment",str(w),"--repo",str(repo),"--require-ci"],check=True)
    base_inputs(w,d)
    ro=d/"receipts/repaired";repro=d/"reproduce";areg=read(root/"independent-auditor.json")
    tree(root/"independent-final",d/"repaired")
    for n,h in areg["files"].items():
        src=regular(tools,n);require(sha(src)==h,"Registered candidate verifier drift: "+n);put(src,repro/"repaired-audit"/n)
    for name,h in ident["files"].items():
        if name.startswith("runner/"):
            src=regular(root,name);require(sha(src)==h,"Registered candidate runner drift: "+name)
            put(src,repro/"repaired-runner"/name.removeprefix("runner/"))
    by_name(root,ro,["runner-identity.json","producer-complete.json","independent-auditor.json","independent-closure.json","independent-raw-recount.log","independent-portable-recount.json","independent-forward-retention.json","independent-retention-source-native.log","independent-retention-archived-native.log"])
    put(root/"engine/build-receipt.json",ro/"build-receipt.json")
    put(tools/"qa/qualification.json",ro/"qualification.json")
    put(root/"independent-order-calibration/comparison.json",ro/"order-calibration.json")
    put(state/"complete.json",ro/"final-consumer-complete.json")
    put(w/"final-audit-handoff-v2/final-consumer-registration.json",ro/"final-consumer-registration.json")
    put(w/"final-handoff/final-started.json",ro/"final-started.json")
    for field,digest,target in [("rootFreeze","rootFreezeSha256","root-freeze.json"),("rootFreezeAuthority","rootFreezeAuthoritySha256","root-freeze-authority.json"),("originalInputRecount","originalInputRecountSha256","original-inputs-rechecked.json"),("preflightAudit","preflightAuditSha256","independent-preflight.json")]:
        p=Path(m[field]).resolve();require(p.is_relative_to(w) and sha(p)==m[digest],"Changed actual launch input "+field);put(p,ro/target)
    attempt=Path(m["preflightAudit"]).parent
    by_name(attempt,ro,["independent-snapshot.json"])
    put(attempt/"exact-preflight/summary.json",ro/"historical-preflight-summary.json")
    put(attempt/"exact-preflight/native-observations.jsonl",ro/"historical-native-observations.jsonl")
    rev=root/"independent-reverse";by_name(rev,ro/"reverse",["receipt.json","contract.json","jobs.tsv"])
    put(rev/"results/inflight/historical-reverse.jsonl",ro/"reverse/native.jsonl")
    tree(retention/"compact",d/"retention")
    gz_files([retention/"archived-commands/input.jsonl"],d/"receipts/retention/archived-command-inputs.jsonl.gz")
    freeze=read(ro/"root-freeze.json")
    for n,h in freeze["prerequisiteFiles"].items():
        artifact=Path(n).resolve()
        require(artifact.is_relative_to(w) and sha(artifact)==h,"Corrupt registered prerequisite "+str(artifact))
        put(artifact,ro/"prerequisites"/h)
    kernel=w/"diagnosis/final-05-kernel"
    bounded=w/"diagnosis/final-05-bounded"
    inventory=read(kernel/"receipt.json")
    require(inventory["status"]=="VERIFIED" and inventory["commit"]==m["commit"],"Wrong final proof inventory")
    put(kernel/"receipt.json",ro/"kernel/receipt.json")
    for mod in inventory["modules"]:
        name=Path(mod["path"]).stem+".log"
        require(sha(regular(kernel,name))==mod["logSha256"],"Changed compiler output")
        put(kernel/name,ro/"kernel"/name)
    by_name(bounded,ro/"bounded-ci",["receipt.json","usage.txt","bounded.log"])
    by_name(w/"preflight/final-ci",repro/"ci",["kernel_receipt.py","run_bounded.py"])
    put(w/"preflight/build-registered-revision.py",repro/"build-registered-revision.py")
    put(w/"packaging/capture_examples.py",repro/"capture_examples.py")
    diag=w/"diagnosis/completed-original"
    put(diag/"verified5/neighbors/source-bound-receipt.json",ro/"diagnostic-controls/pre-budget-neighbors.json")
    put(diag/"archival-05/comparison.json",ro/"diagnostic-controls/archival-controls.json")
    for control in read(diag/"archival-05/comparison.json")["runs"]:
        log=Path(control["log"]).resolve()
        require(log.parent==diag/"archival-05" and sha(log)==control["logSHA"],"Changed archival control output")
        put(log,ro/"diagnostic-controls"/log.name)
    build=Path(freeze["buildRoot"]).resolve()
    require(build.parent==w/"builds" and sha(build/"a.jar")==sha(root/"engine/candidate.jar")==sha(build/"b.jar")==m["jarSha256"],"Wrong built engine for release")
    by_name(build,ro/"build-inventories",["a.log","b.log","classes.sha256","sources.sha256"])
    asm=w/"packaging/jar-assembly";rdir=repro/"jar-assembly"
    by_name(asm,rdir,["repaired-entries.tsv.gz","ReassembleJar.java","reproduce_engine.py"])
    # This registry is the one intentionally expanded document. Preserve every prior entry.
    old=read(rdir/"engines.json");new=read(asm/"engines.json")
    require(set(old)<=set(new) and all(new[k]==v for k,v in old.items()) and new["repaired"]["sha256"]==m["jarSha256"],"JAR registry changed an earlier engine")
    for label,spec in new.items():
        name=spec["zipEntries"]
        source=regular(asm,name)
        require(name==label+"-entries.tsv.gz" and sha(source)==spec["zipEntriesSha256"],"Incorrect ZIP-entry metadata: "+label)
        put(source,rdir/name)
    tmp=rdir/"engines.json.pending";shutil.copyfile(asm/"engines.json",tmp);os.replace(tmp,rdir/"engines.json")
    with tempfile.TemporaryDirectory(dir=d) as temp:
        jar=Path(temp)/"repaired.jar"
        subprocess.run([sys.executable,"-B",str(rdir/"reproduce_engine.py"),"repaired",str(jar),"--repo",str(repo)],check=True)
        require(sha(jar)==m["jarSha256"],"Registered Git source and ZIP layout cannot reproduce the measured JAR")
    from compare_censuses import rebuild
    with tempfile.TemporaryDirectory(dir=d) as temp:
        output=Path(temp)
        result=rebuild(d/"original",d/"repaired",repo/"docs/experimental-results/historical-retention/paid-rank-witnesses-floor.jsonl",output)
        require(result["newFloor"]==FLOOR and result["newFloorSha256"]==m["expandedFloorSha256"],"Final source floor differs from completed before/after")
        by_name(output,d,["paid-rank-witnesses-floor.jsonl","before-after.json","repaired-ranking-pairs.csv"])
        from compare_programs import rebuild as rebuild_programs, SUMMARY, TABLE
        rebuild_programs(d,repo,output)
        by_name(output,d,[TABLE,SUMMARY])
    print("Staged native evidence for",uid,flush=True)


def stage_auxiliary_receipts(w,d):
    marker=read(w/"final-handoff/final-started.json")
    for kind,name,rows in (("stages","stage-attribution/manifest.json",938),("pools","reference-pool-scores/summary.json",132032),("components","reference-pool-scores/command-components/summary.json",132032)):
        record=w/"reference-pool-scalars/exports"/marker["uuid"]/(kind+"-export.json")
        require(record.is_file(),"Independent export is pending: "+kind)
        receipt=read(record)
        require(receipt==dict(status="VERIFIED",file=name,sha256=sha(regular(d,name)),jarSha256=marker["jarSha256"],uuid=marker["uuid"],rows=rows),"Independent export digest or measured identity differs: "+kind)
        put(record,d/"receipts/repaired"/record.name)
    record=w/"temporal-26673/published.json";r=read(record)
    name="temporal-program-replay/full-temporal-scope";t=d/name
    require(r["status"]=="VERIFIED" and r["jar"]==marker["jarSha256"] and r["folder"]==name and r["rows"]==26673
            and r["inventorySha256"]==sha(t/"inventory.json") and r["summarySha256"]==sha(t/"summary.json")
            and r["portableCheckerSha256"]==sha(t/"verify.py") and r["latestVerifiedResult"]==read(t/"summary.json"),
            "Full-temporal scope release disagrees with its frozen measured engine or registered checker")
    put(record,d/"receipts/repaired/full-temporal-export.json")


def seal(w,d,repo):
    stage_auxiliary_receipts(w,d)
    manifest=d/"SHA256SUMS"
    with tempfile.TemporaryDirectory(dir=d.parent) as temp:
        output=Path(temp)/"SHA256SUMS";output.write_text("".join(f"{h}  {n}\n" for n,h in inventory(d).items()))
        existing=manifest.read_bytes() if manifest.exists() else None
        pending=d/".SHA256SUMS.pending";shutil.copyfile(output,pending);os.replace(pending,manifest)
        try:subprocess.run([sys.executable,"-B",str(d/"verify.py"),"--repo",str(repo)],check=True)
        except BaseException:
            if existing is None:manifest.unlink(missing_ok=True)
            else:manifest.write_bytes(existing)
            raise
    print("Verified release inventory",sha(manifest),flush=True)


if __name__=="__main__":
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument("stage",choices=["historical","collect","seal"])
    ap.add_argument("--experiment",type=Path,required=True);ap.add_argument("--output",type=Path,required=True);ap.add_argument("--repo",type=Path,required=True)
    args=ap.parse_args();w=args.experiment.resolve();d=args.output.resolve();repo=args.repo.resolve()
    require(d.is_dir() and (d/"verify.py").is_file() and not d.is_relative_to(repo),"Use the prepared external release directory")
    if args.stage=="historical":base_inputs(w,d)
    elif args.stage=="collect":collect(w,d,repo)
    else:seal(w,d,repo)
