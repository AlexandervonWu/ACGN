"""Launch one independently approved exhaustive repair against the closed original ranking corpus."""
import argparse
import contextlib
import datetime
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time
import uuid

D = Path(__file__).resolve().parent
W = D.parent
ORIG = "a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02"
COHORT = "074fbe5573ccf33de100f85cc14a7d0f33c297271b933401ee061d066da99ff5"
OLD_FLOOR = W/"frozen/docs/experimental-results/historical-retention/paid-rank-witnesses-floor.jsonl"
FLOOR_RELATIVE = "docs/historical-pair-coverage/paid-ranking-witnesses.jsonl"
FLOOR = D/"required-paid-ranking-witnesses.jsonl"
ATT = W/"cohort/closure-attestation.json"


class GateFailure(ValueError):
    pass


def require(ok, reason):
    if not ok:
        raise GateFailure(reason)


def sha(path):
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(2**20), b""):
            h.update(chunk)
    return h.hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def write_once(path, value):
    """A crash can leave an unreferenced temp file, never a partial published receipt."""
    with tempfile.NamedTemporaryFile(dir=path.parent, mode="w") as tmp:
        json.dump(value,tmp,indent=2,sort_keys=True)
        tmp.write("\n")
        tmp.flush()
        os.fsync(tmp.fileno())
        os.link(tmp.name,path)
    fd=os.open(path.parent,os.O_DIRECTORY)
    try: os.fsync(fd)
    finally: os.close(fd)


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def run(cmd, log=None, codes=(0,)):
    if log is None:
        result=subprocess.run(cmd,capture_output=True,text=True)
        if result.returncode not in codes:
            raise RuntimeError(f"{Path(str(cmd[0])).name} exited {result.returncode}: {result.stderr[-350:]}")
        return result.stdout
    with log.open("a") as stream:
        result=subprocess.run(cmd,stdout=stream,stderr=subprocess.STDOUT)
    if result.returncode not in codes:
        raise RuntimeError(f"Command returned {result.returncode}, see {log}")
    return result.returncode


def verify_registration(reg_sha):
    contract=D/"contract.json"
    require(sha(contract)==reg_sha,"Handoff program registration changed")
    for name,expected in read(contract)["files"].items():
        require(sha(W/name)==expected,"Registered handoff input changed: "+name)
    require(sha(W/"runner-identity.json")==ORIG and sha(W/"cohort/manifest.json")==COHORT,"Original run identity changed")


def check_original():
    if not ATT.exists():
        return None
    cert=read(ATT);verdict=W/"cohort/closure-verdict.json";producer=W/"producer-complete.json"
    v=read(verdict);p=read(producer)
    require(cert["verifierRegistration"]=="VERIFIED" and cert["complete"] is True and
            cert["producerIdentitySha256"]==ORIG and cert["auditorSha256"]==sha(W/"cohort/auditor-identity.json") and
            cert["closureVerdictSha256"]==sha(verdict),"Original independent attestation is incomplete or off-contract")
    require(v["receipt"]==sha(producer) and p["identitySha256"]==ORIG and p["completedShards"]==1059 and
            p["attemptedRows"]==v["rows"]==cert["rows"]==1894168 and v["complete"] is True and
            v["status"]==cert["nativeClaimStatus"] and v["status"] in ("VERIFIED","BLOCKED") and
            v["nonconforming"]==cert["nonconforming"],"Original census is incomplete or did not resolve its infrastructure")
    require(v["summary"]==sha(W/"cohort/final-verification/summary.json") and
            v["rawRecount"]==sha(W/"cohort/final-raw-recount.log") and
            v["portableRecount"]==sha(W/"cohort/final-compact-recount.log"),"Original independent closure artifacts drifted")
    if not (D/"original-ready.json").is_file():
        if not FLOOR.exists():
            run([sys.executable,"-B",str(W/"preflight/freeze-ranking-floor.py"),str(W),str(OLD_FLOOR),str(FLOOR)],D/"floor.log")
        with tempfile.TemporaryDirectory(dir=D) as tmp:
            expected=Path(tmp)/"expanded.jsonl"
            details=json.loads(run([sys.executable,"-B",str(W/"preflight/freeze-ranking-floor.py"),str(W),str(OLD_FLOOR),str(expected)]))
            require(sha(FLOOR)==sha(expected)==details["sha256"] and details["originalFailures"]==cert["nonconforming"],"Expanded floor does not cover the final original failures")
        write_once(D/"original-ready.json",dict(attestationSha256=sha(ATT),closureVerdictSha256=sha(verdict),
                   producerCompleteSha256=sha(producer),expandedFloor=details,at=now()))
    ready=read(D/"original-ready.json")
    require(ready["attestationSha256"]==sha(ATT) and ready["closureVerdictSha256"]==sha(verdict) and
            ready["expandedFloor"]["sha256"]==sha(FLOOR) and ready["expandedFloor"]["originalFailures"]==cert["nonconforming"],"Original post-closure floor drifted")
    return ready


def validate_build(spec):
    build=Path(spec["buildRoot"]);a=build/"a.jar";b=build/"b.jar";receipt=build/"build-receipt.json"
    require(build.parent==W/"builds" and spec["buildReceiptSha256"]==sha(receipt),"Wrong exact-build receipt")
    r=read(receipt)
    require(r["git"]["commit"]==spec["commit"] and r["buildsByteIdentical"] is True and
            sha(a)==sha(b)==spec["jarSha256"]==r["experimentJar"]["sha256"],"Two registered builds or JAR identity disagree")
    old=read(W/"runner-identity.json")
    deps={k.rsplit("/",1)[-1]:v for k,v in old["files"].items() if k.startswith("frozen/lib/")}
    require(r["dependencies"]==deps,"Candidate dependencies differ from the measured original")
    retired={read(p)["engine"]["jarSha256"] if "engine" in read(p) else
             read(p.parent.parent/"runner-identity.json")["engine"]["jarSha256"] for p in (W/"candidates").glob("*/retirement/disposition.json")}
    require(spec["jarSha256"] not in retired and spec["jarSha256"]!=old["jarSha256"],"Retired or original engine cannot be launched as the final repair")
    for path,checksum in spec["prerequisiteFiles"].items():
        require(sha(Path(path))==checksum,"Root-registered prerequisite changed: "+path)
    return a,receipt


def freeze(args):
    verify_registration(sha(D/"contract.json"))
    require((D/"original-ready.json").is_file() and check_original(),"Freeze is available only after the complete independently checked original census and floor")
    require(not (D/"final-started.json").exists(),"Final census already issued")
    repo=args.repo.resolve();build=args.build.resolve()
    commit=run(["git","-C",str(repo),"rev-parse","HEAD"]).strip()
    require(not run(["git","-C",str(repo),"status","--porcelain=v1","--untracked-files=all"]).strip(),"Final source checkout must be clean")
    require(re.fullmatch(r"[0-9a-f]{40}",commit) and commit==args.commit,"Final commit differs from checkout")
    data=subprocess.check_output(["git","-C",str(repo),"show",commit+":"+FLOOR_RELATIVE])
    require(data==FLOOR.read_bytes(),"Final source must contain the complete, byte-identical expanded historical floor")
    require(1<=args.workers<=len(os.sched_getaffinity(0)) and 320<=args.max_heap_mib<=1900 and 16<=args.initial_heap_mib<=args.max_heap_mib and
            0<=args.min_heap_free_ratio<=args.max_heap_free_ratio<=100,"Invalid final resource envelope")
    for previous in (D/"registrations").glob("*.authorized"):
        require((D/"attempts"/previous.stem/"blocked.json").is_file(),"An issued registration is still pending")
    registration=str(uuid.uuid4())
    spec=dict(schema="acgn-final-ranking-freeze-v1",registrationId=registration,issuedAt=now(),repo=str(repo),
              commit=commit,jarSha256=sha(build/"a.jar"),buildRoot=str(build),buildReceiptSha256=sha(build/"build-receipt.json"),
              finalRoot=str(W/"candidates"/("final-"+commit[:12]+"-"+registration[:8])),
              originalAttestationSha256=sha(ATT),originalReadySha256=sha(D/"original-ready.json"),expandedFloorSha256=sha(FLOOR),
              prerequisiteFiles={str(p.resolve()):sha(p.resolve()) for p in args.prerequisite},
              collector=args.collector,initialHeapMiB=args.initial_heap_mib,maximumHeapMiB=args.max_heap_mib,minFreeRatio=args.min_heap_free_ratio,maxFreeRatio=args.max_heap_free_ratio,
              workers=args.workers,handoffContractSha256=sha(D/"contract.json"))
    validate_build(spec)
    path=D/"registrations"/(registration+".json");write_once(path,spec)
    authority=path.with_suffix(".authorized")
    write_once(authority,dict(issuedAt=spec["issuedAt"],freezeSha256=sha(path),commit=commit,jarSha256=spec["jarSha256"],registrationId=registration))
    print(path,sha(path),flush=True)


def gate(st,attempt,engine,receipt,original):
    target=attempt/"exact-preflight";snapshot=attempt/"independent-snapshot.json";audit=attempt/"independent-preflight.json"
    verifier=W/"regression-audit/verify_checkpoint.py"
    base=["--workspace",str(W),"--jar",str(engine),"--build-receipt",str(receipt)]
    if not snapshot.is_file():
        with tempfile.TemporaryDirectory(dir=attempt) as temp:
            p=Path(temp)/"scope.json"
            run([sys.executable,"-B",str(verifier),"snapshot",*base,"--include-history","--output",str(p)],attempt/"preflight.log")
            os.link(p,snapshot)
    snap=read(snapshot)
    require(len(snap["originalIncidentFiles"])==original["expandedFloor"]["originalFailures"] and
            snap["includeHistory"] is True and snap["engineSha256"]==st["jarSha256"],"Precandidate snapshot lacks complete historical failure inventory")
    if not target.is_dir():
        rc=run([sys.executable,"-B",str(W/"packaging/replay_regressions.py"),str(W),str(engine),st["jarSha256"],
                str(target),"--workers",str(min(8,st["workers"])),"--include-history"],attempt/"preflight.log",(0,2))
        require(target.is_dir(),"Native failure preflight produced no outcome")
    with tempfile.TemporaryDirectory(dir=attempt) as temp:
        p=Path(temp)/"report.json"
        rc=run([sys.executable,"-B",str(verifier),"audit",*base,"--target",str(target),"--snapshot",str(snapshot),
                "--snapshot-sha256",sha(snapshot),"--output",str(p)],attempt/"preflight.log",(0,2))
        if audit.is_file(): require(sha(audit)==sha(p),"Independent known-failure recount changed")
        else: os.link(p,audit)
    verdict=read(audit)
    require(rc==0 and verdict["recountStatus"]==verdict["nativeCheckpointStatus"]=="VERIFIED" and
            verdict["candidateCommit"]==st["commit"] and verdict["candidateJarSha256"]==st["jarSha256"] and
            verdict["originalIncidents"]==original["expandedFloor"]["originalFailures"] and verdict["historyFloorRows"]==83 and
            verdict["originalPairs"]==original["expandedFloor"]["rows"] and
            verdict["directions"]==verdict["verifiedDirections"]==2*verdict["originalPairs"] and verdict["failedDirections"]==0,
            "Exact candidate failed a known/historical direction or misses the closed original floor")
    return audit


def confirmed_inputs(attempt):
    # Import the independently registered recount as a function to preserve the original receipt.
    src=W/"cohort/verify_inputs.py"
    module=importlib.util.spec_from_file_location("final_handoff_verified_inputs",src)
    validator=importlib.util.module_from_spec(module);module.loader.exec_module(validator)
    actual=validator.verify(W,W/"cohort")
    require(actual==read(W/"cohort/input-recount.json") and actual["status"]=="VERIFIED" and actual["rows"]==1894168,
            "Fresh original source/hash/selector/score/ordinal recount disagrees")
    path=attempt/"original-inputs-rechecked.json"
    if path.exists(): require(read(path)==actual,"Registered final input recount changed")
    else: write_once(path,actual)
    return path


def prepare_final(st,attempt,engine,receipt):
    final=Path(st["finalRoot"])
    require(final.parent==W/"candidates" and final.name=="final-"+st["commit"][:12]+"-"+st["registrationId"][:8],
            "Wrong or reused final run path")
    registered=attempt/"prepared.json"
    if not final.exists():
        require(not registered.exists(),"Previously frozen final directory disappeared")
        # Incomplete staging generations remain separate. No observer can ever consume them as a final measurement.
        stage=W/"candidates"/(".preparing-"+st["registrationId"]+"-"+str(uuid.uuid4()))
        run([sys.executable,"-B",str(W/"portable-tiled/prepare.py"),"--baseline-root",str(W),"--run-root",str(stage),
             "--engine-commit",st["commit"],"--engine-jar",str(engine),"--build-receipt",str(receipt),
             "--workers",str(st["workers"]),"--collector",st["collector"],"--max-heap-mib",str(st["maximumHeapMiB"]),"--initial-heap-mib",str(st["initialHeapMiB"]),
             "--min-heap-free-ratio",str(st["minFreeRatio"]),"--max-heap-free-ratio",str(st["maxFreeRatio"])],attempt/"prepare.log")
        stage.rename(final)
    identity=final/"runner-identity.json";spec=read(identity)
    require(not (final/"retirement/disposition.json").exists() and not (final/"capacity/disabled").exists(),"Final run was explicitly retired")
    require(spec["engine"]["commit"]==st["commit"] and spec["engine"]["jarSha256"]==st["jarSha256"] and
            spec["engine"]["buildReceiptSha256"]==st["buildReceiptSha256"] and spec["inputManifestSha256"]==COHORT and
            spec["originalProducer"]["baselineNativeRunnerIdentitySha256"]==ORIG and spec["rows"]==1894168 and
            spec["initialControl"]["workers"]==st["workers"] and spec["initialControl"]["heapMiB"]==st["maximumHeapMiB"] and
            spec["registeredHeapPolicy"]==dict(collector=st["collector"],initialMiB=st["initialHeapMiB"],maximumMiB=st["maximumHeapMiB"],minFreeRatio=st["minFreeRatio"],maxFreeRatio=st["maxFreeRatio"]),
            "Prepared frozen candidate does not match the approved registration")
    for p,h in spec["files"].items():
        require(sha(final/p)==h,"Prepared driver, engine, plans, or dependencies have changed: "+p)
    uid=spec["candidateRunId"];require(str(uuid.UUID(uid))==uid,"Invalid final candidate run ID")
    for i in (W/"candidates").glob("*/runner-identity.json"):
        if i.parent!=final and not i.parent.name.startswith("."):
            require(read(i)["candidateRunId"]!=uid,"A previous execution already owns this candidate UUID")
    data=dict(candidateRunId=uid,candidateRoot=str(final),identitySha256=sha(identity),commit=st["commit"],jarSha256=st["jarSha256"])
    if registered.exists(): require(read(registered)==data,"Prepared final runner identity changed")
    else: write_once(registered,data)
    return data


def execute(path,contract_sha,original):
    st=read(path);attempt=D/"attempts"/path.stem;attempt.mkdir(exist_ok=True)
    auth=read(path.with_suffix(".authorized"))
    require(auth==dict(issuedAt=st["issuedAt"],freezeSha256=sha(path),commit=st["commit"],jarSha256=st["jarSha256"],registrationId=path.stem),"Root-issued registration hash, source commit, or engine identity is inconsistent")
    require(st["registrationId"]==path.stem and st["handoffContractSha256"]==contract_sha,"Invalid launch authority registration")
    require(st["originalAttestationSha256"]==sha(ATT) and st["originalReadySha256"]==sha(D/"original-ready.json") and
            st["expandedFloorSha256"]==sha(FLOOR),"Final source freeze predates the closed original/floor")
    engine,receipt=validate_build(st)
    authorized_floor=subprocess.check_output(["git","-C",st["repo"],"show",st["commit"]+":"+FLOOR_RELATIVE])
    require(read(receipt)["git"]["tree"]==run(["git","-C",st["repo"],"rev-parse",st["commit"]+"^{tree}"]).strip(),"Build receipt Git tree does not match the registered source commit")
    require(authorized_floor==FLOOR.read_bytes(),"Registered source commit differs from expanded floor")
    verified_inputs=confirmed_inputs(attempt)
    audit=gate(st,attempt,engine,receipt,original)
    data=prepare_final(st,attempt,engine,receipt)
    final=Path(data["candidateRoot"]);unit="acgn-ranking-candidate-"+data["candidateRunId"]+".service"
    done=final/"producer-complete.json"
    activating=attempt/"activation-intent.json"
    if not activating.exists():
        write_once(activating,dict(unit=unit,identitySha256=data["identitySha256"],intendedAt=now()))
    require(read(activating)["identitySha256"]==data["identitySha256"],"Activation record references a different engine")
    if (final/"retirement/disposition.json").exists() or (final/"capacity/disabled").exists():
        raise GateFailure("Candidate deliberately retired before launch")
    cmd=["systemctl","--user","show",unit,"-p","ActiveState","--value"]
    active=subprocess.run(cmd,stdout=subprocess.PIPE,text=True).stdout.strip()
    if active!="active" and not done.exists():
        # The only possible replay of enable --now is in the window after a durable launch intent.
        # Retirements always have a durable cancellation/disposition marker, checked both here and above.
        run([str(final/"runner/launch.sh")],attempt/"launch.log")
        active=run(cmd).strip()
    require(active=="active" or (done.is_file() and read(done)["identitySha256"]==data["identitySha256"]),
            "Final service did not start on the registered engine")
    unit_info=run(["systemctl","--user","show",unit,"-p","InvocationID","-p","ActiveEnterTimestamp","-p","UnitFileState"]).strip()
    marker=dict(schema="acgn-attested-final-ranking-start-v1",startedAt=now(),**data,uuid=data["candidateRunId"],
                engineJar=str(final/"engine/candidate.jar"),candidateBuildReceipt=str(final/"engine/build-receipt.json"),
                buildReceiptSha256=sha(final/"engine/build-receipt.json"),candidateIdentity=str(final/"runner-identity.json"),
                originalAttestation=str(ATT),originalAttestationSha256=sha(ATT),originalInputRecount=str(verified_inputs),
                originalInputRecountSha256=sha(verified_inputs),expandedHistoricalFloor=str(FLOOR),expandedFloorSha256=sha(FLOOR),
                rootFreeze=str(path),rootFreezeSha256=sha(path),rootFreezeAuthority=str(path.with_suffix(".authorized")),rootFreezeAuthoritySha256=sha(path.with_suffix(".authorized")),preflightAudit=str(audit),preflightAuditSha256=sha(audit),
                systemdUnit=unit,unitStartEvidence=unit_info,originalScoreRunId=read(W/"runner-identity.json")["sourceRunId"])
    write_once(D/"final-started.json",marker)
    print("Final started",data["candidateRunId"],sha(D/"final-started.json"),flush=True)


def iteration(contract_sha):
    verify_registration(contract_sha)
    marker=D/"final-started.json"
    if marker.exists():
        m=read(marker)
        require(sha(Path(m["candidateIdentity"]))==m["identitySha256"] and sha(Path(m["rootFreeze"]))==m["rootFreezeSha256"],
                "Final marker drifted")
        return "FINAL_STARTED"
    original=check_original()
    if original is None: return "WAIT_COMPLETE_ORIGINAL"
    for path in sorted((D/"registrations").glob("*.json")):
        attempt=D/"attempts"/path.stem
        if not path.with_suffix(".authorized").is_file():continue
        if (attempt/"blocked.json").exists():continue
        try:
            execute(path,contract_sha,original)
        except GateFailure as error:
            attempt.mkdir(exist_ok=True)
            write_once(attempt/"blocked.json",dict(at=now(),reason=str(error),rootFreezeSha256=sha(path)))
            print("Final candidate blocked",path,str(error),flush=True)
            return "REGISTRATION_BLOCKED"
        return "FINAL_STARTED"
    return "WAIT_FINAL_FROZEN_SOURCE"


def runner(args):
    lock=(D/"supervisor.lock").open("a+")
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    last=None
    while True:
        state=iteration(args.registration)
        if last!=state:
            print(now(),state,flush=True);last=state
        if state=="FINAL_STARTED" or args.once:return
        time.sleep(25)


if __name__=="__main__":
    p=argparse.ArgumentParser(description=__doc__);sub=p.add_subparsers(dest="mode",required=True)
    ready=sub.add_parser("freeze")
    ready.add_argument("--repo",type=Path,required=True)
    ready.add_argument("--build",type=Path,required=True)
    ready.add_argument("--commit",required=True)
    ready.add_argument("--workers",type=int,default=29)
    ready.add_argument("--collector",choices=("serial","parallel-one"),default="parallel-one")
    ready.add_argument("--initial-heap-mib",type=int,default=160)
    ready.add_argument("--max-heap-mib",type=int,default=400)
    ready.add_argument("--min-heap-free-ratio",type=int,default=40)
    ready.add_argument("--max-heap-free-ratio",type=int,default=70)
    ready.add_argument("--prerequisite",type=Path,action="append",default=[])
    check=sub.add_parser("run");check.add_argument("--registration",required=True);check.add_argument("--once",action="store_true")
    args=p.parse_args()
    if args.mode=="freeze":freeze(args)
    else:runner(args)
