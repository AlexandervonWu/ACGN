"""Validate the source, build, run, native-program, historical and publication identities."""
import gzip
import hashlib
import json
import re
from pathlib import Path

ROWS=1_894_168
OLD_FAILURES=386
FLOOR=469
INPUT="074fbe5573ccf33de100f85cc14a7d0f33c297271b933401ee061d066da99ff5"
ORIG="a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02"
ORIGINAL_AUDITOR="e9cc9add2b3f242c7ac84ad4803dbf5c525cc528c856500cd402a37fda2a3554"
DIGEST=re.compile(r"[0-9a-f]{64}")


def read(p):
    return json.loads(p.read_bytes())


def sha(p):
    h=hashlib.sha256()
    with p.open("rb") as f:
        for x in iter(lambda:f.read(2**20),b""):
            h.update(x)
    return h.hexdigest()


def require(ok,msg):
    if not ok:
        raise ValueError(msg)


def regular(root,name):
    rel=Path(name)
    require(not rel.is_absolute() and rel.as_posix()==name and ".." not in rel.parts and name not in ("","."),"Invalid relative release path "+name)
    dest=root/rel
    require(dest.is_file() and not any(p.is_symlink() for p in (dest,*dest.parents) if p!=root and root in p.parents),"Nonregular or linked release path "+name)
    return dest


def inventory(root):
    files={}
    for p in sorted(root.rglob("*")):
        require(not p.is_symlink(),"Unexpected symbolic link "+str(p))
        if p.is_file() and p!=root/"SHA256SUMS":
            files[p.relative_to(root).as_posix()]=sha(p)
    return files


def verify_inventory(root):
    known={}
    for line in (root/"SHA256SUMS").read_text().splitlines():
        h,sep,name=line.partition("  ")
        require(sep and DIGEST.fullmatch(h) and name not in known and name!="SHA256SUMS","Malformed or duplicated SHA256SUMS record")
        regular(root,name)
        known[name]=h
    require(known and known==inventory(root),"Release inventory is incomplete or differs from recorded files")


def check_hashes(root,mapping):
    for name,h in mapping.items():
        require(DIGEST.fullmatch(h) and sha(regular(root,name))==h,"Hash mismatch for "+name)


def registered_audits(root):
    rec=root/"receipts";repro=root/"reproduce";original=rec/"original";final=rec/"repaired"
    meta=read(original/"manifest.json");base=read(original/"runner-identity.json")
    require(sha(original/"manifest.json")==INPUT and sha(original/"runner-identity.json")==ORIG and base["inputManifestSha256"]==INPUT and meta["rows"]==ROWS and len(meta["shards"])==1059,"Original inputs or registered runner changed")
    obligation=read(original/"obligation-manifest.json")
    check_hashes(original/"registration",obligation["inputs"])
    require(obligation["cohortEdges"]==ROWS and obligation["sourceRunId"]==meta["measuredRunId"] and
            obligation["buildReproduction"]==read(original/"registration/preflight/rebuild/build-replay.json")["sortedClassfileManifestSha256"],
            "Original build or proof-obligation registration changed")
    a=read(original/"auditor-identity.json")
    require(sha(original/"auditor-identity.json")==ORIGINAL_AUDITOR and a["runnerIdentitySha256"]==ORIG,"Wrong original independent auditor")
    for section in ("files","calibration"):check_hashes(repro/"original-audit",a[section])
    o=read(original/"closure-verdict.json");at=read(original/"closure-attestation.json");raw=read(original/"producer-complete.json")
    require(raw["identitySha256"]==ORIG and raw["attemptedRows"]==ROWS and raw["completedShards"]==1059,"Incomplete original producer")
    require(o["complete"] is True and o["status"]=="BLOCKED" and o["checkedOrderedNativeWitnesses"]==ROWS-OLD_FAILURES and o["nonconforming"]==OLD_FAILURES and o["rows"]==ROWS,"Wrong original ordered replay totals")
    require(o["receipt"]==sha(original/"producer-complete.json") and o["rawRecount"]==sha(original/"final-raw-recount.log") and o["portableRecount"]==sha(original/"final-compact-recount.log") and o["summary"]==sha(root/"original/summary.json") and at["closureVerdictSha256"]==sha(original/"closure-verdict.json"),"Original independent results lost a provenance binding")
    ri=read(final/"runner-identity.json"); eng=ri["engine"];idsha=sha(final/"runner-identity.json");build=read(final/"build-receipt.json")
    uid=ri["candidateRunId"];jar=eng["jarSha256"];commit=eng["commit"]
    require(ri["scoreAuthority"]=="originalProducer" and ri["originalProducer"]["baselineNativeRunnerIdentitySha256"]==ORIG and ri["originalProducer"]["runId"]==meta["measuredRunId"] and ri["originalProducer"]["commit"]==meta["measuredCommit"] and ri["originalProducer"]["jarSha256"]==meta["jarSha256"] and ri["inputManifestSha256"]==INPUT,"Final engine is not paired to the original ranking denominator")
    require(eng["buildReceiptSha256"]==sha(final/"build-receipt.json") and build["git"]["commit"]==commit and build["buildsByteIdentical"] is True and build["experimentJar"]["sha256"]==jar and jar!=meta["jarSha256"],"Final build identity differs")
    for name,h in ri["files"].items():
        if name.startswith("runner/"):check_hashes(repro/"repaired-runner",{name.removeprefix("runner/"):h})
    au=read(final/"independent-auditor.json");check_hashes(repro/"repaired-audit",au["files"])
    require(au["candidateIdentitySha256"]==idsha and au["candidateCommit"]==commit and au["candidateJarSha256"]==jar and au["inputManifestSha256"]==INPUT and au["originalAuditorSha256"]==ORIGINAL_AUDITOR,"Final auditor belongs to another run")
    require(au["qualificationSha256"]==sha(final/"qualification.json") and au["tiledCalibrationSha256"]==sha(final/"order-calibration.json"),"Execution-order qualification receipt changed")
    q=read(final/"producer-complete.json");v=read(final/"independent-closure.json");p=read(final/"independent-portable-recount.json")
    require(q["candidateRunId"]==uid and q["identitySha256"]==idsha and q["attemptedRows"]==ROWS and q["completedShards"]==1059 and q["completedShardStatusCounts"]=={"MATCHED":ROWS},"Incomplete repaired producer")
    require(v["status"]=="VERIFIED" and v["nonconforming"]==0 and v["rows"]==ROWS and v["experimentUuid"]==uid and v["candidateJarSha256"]==jar and v["candidateCommit"]==commit and v["candidateRunnerSha256"]==idsha and v["producerCompletionSha256"]==sha(final/"producer-complete.json") and v["auditorRegistrationSha256"]==sha(final/"independent-auditor.json"),"Repaired independently verified verdict differs")
    require(v["originalScoreProducer"]==ri["originalProducer"] and v["executionPlansSha256"]==sha(root/"repaired/execution-plan-hashes.json")==ri["files"]["plans/manifest.json"],"Final execution plan/score producer mismatch")
    require(v["candidateNativeRanking"]==p and p["status"]=="VERIFIED" and p["checked"]==p["rows"]==ROWS and p["nonconforming"]==0 and p["summarySha256"]==sha(root/"repaired/summary.json"),"Portable result disagrees with closed candidate")
    return {"uuid":uid,"identity":idsha,"jar":jar,"commit":commit,"verdict":v}


def compare_historical(root,bound,repo):
    f=root/"receipts/repaired";m=read(f/"final-started.json");auth=read(f/"root-freeze-authority.json");reg=read(f/"root-freeze.json");p=read(f/"independent-preflight.json")
    require(m["uuid"]==bound["uuid"] and m["identitySha256"]==bound["identity"] and m["jarSha256"]==bound["jar"] and m["commit"]==bound["commit"],"Final startup identity changed")
    require(m["rootFreezeSha256"]==auth["freezeSha256"]==sha(f/"root-freeze.json") and m["rootFreezeAuthoritySha256"]==sha(f/"root-freeze-authority.json") and (auth["commit"],auth["jarSha256"])==(reg["commit"],reg["jarSha256"])==(bound["commit"],bound["jar"]),"Missing or incorrect root freeze")
    require(m["originalAttestationSha256"]==sha(root/"receipts/original/closure-attestation.json") and m["originalInputRecountSha256"]==sha(f/"original-inputs-rechecked.json") and m["expandedFloorSha256"]==sha(root/"paid-rank-witnesses-floor.jsonl") and m["preflightAuditSha256"]==sha(f/"independent-preflight.json"),"Final admission no longer binds the original and post-closure preflight")
    require(p["recountStatus"]==p["nativeCheckpointStatus"]=="VERIFIED" and p["candidateCommit"]==bound["commit"] and p["candidateJarSha256"]==bound["jar"] and p["originalIncidents"]==OLD_FAILURES and p["historyFloorRows"]==83 and p["originalPairs"]==FLOOR and p["verifiedDirections"]==p["directions"]==2*FLOOR and p["failedDirections"]==0,"Historical preflight did not check every repaired and historical orientation")
    completed=read(f/"final-consumer-complete.json")
    require(completed["status"]=="VERIFIED" and completed["rows"]==ROWS and completed["candidateIdentitySha256"]==bound["identity"] and completed["markerSha256"]==sha(f/"final-started.json") and completed["closureSha256"]==sha(f/"independent-closure.json") and completed["retentionVerdictSha256"]==sha(root/"retention/combined-verdict.json"),"Wrong final consumer closure")
    require(reg["buildReceiptSha256"]==m["buildReceiptSha256"]==sha(f/"build-receipt.json") and reg["handoffContractSha256"]==sha(root/"receipts/final-admission-contract.json") and p["snapshotSha256"]==sha(f/"independent-snapshot.json") and p["producerSummarySha256"]==sha(f/"historical-preflight-summary.json"),"Historical preflight checker, build, snapshot or producer receipt differs")
    floor={(r["submission"],r["predicate"],r["reference"],r["referencePredicate"]): (r["sourceSha256"],r["referenceSha256"]) for r in map(json.loads,(root/"paid-rank-witnesses-floor.jsonl").read_text().splitlines())}
    require(len(floor)==FLOOR,"Incomplete expanded historical floor")
    for (source,_,reference,_),(leftsha,rightsha) in floor.items():
        for path,h in ((source,leftsha),(reference,rightsha)):
            require(sha(regular(repo/"classified-data",path))==h, "Source bytes changed for historical selection "+path)
    # The registered native auditor enforces distinct static and temporal proof obligations.
    import sys
    sys.path.insert(0,str(root/"reproduce/original-audit"))
    from verify_results import check_native
    ledger=f/"historical-native-observations.jsonl"
    require(sha(ledger)==p["observationsSha256"],"Preflight ledger differs from independent recount")
    return_floor={"forward":set(),"reverse":set()}
    for x in map(json.loads,ledger.read_text().splitlines()):
        side=x["direction"];k=(x["left"],x["leftPredicate"],x["right"],x["rightPredicate"])
        if side=="reverse":k=k[2:]+k[:2]
        require(side in return_floor and k in floor and k not in return_floor[side] and x["checked"] is True and check_native(x,x["expected"]) and x["status"]=="MATCHED" and x["nativeSequencesEqual"] is True and x["fastDistance"]==x["certifiedDistance"]==x["expected"] and x["fastSequenceSha256"]==x["certifiedSequenceSha256"] and DIGEST.fullmatch(x["fastSequenceSha256"]),"Unbound historical witness in orientation "+side)
        return_floor[side].add(k)
    require(all(s==set(floor) for s in return_floor.values()),"Missing oriented historical comparison")
    retention=root/"retention";files=read(retention/"SHA256.json");check_hashes(retention,files)
    verdict=read(retention/"combined-verdict.json");native=read(retention/"verification.json");cmd=read(retention/"archived-original-command-receipt.json");coverage=bound["verdict"]["sourceAndScopeRetention"]
    require(coverage["status"]==verdict["status"]=="VERIFIED" and coverage["releaseSha256"]==sha(retention/"SHA256.json") and coverage["sourceLedgerSha256"]==sha(retention/"verification.json") and coverage["commandLedgerSha256"]==sha(retention/"archived-original-command-receipt.json"),"Source and command retention differs from independently verified closure")
    require(verdict["candidateSha256"]==cmd["candidateJarSha256"]==bound["jar"] and verdict["candidateCommit"]==bound["commit"] and verdict["nonconformingNativeOrCommandJobs"]==0 and verdict["connectedHistoricalSatControls"]==verdict["originalCommandsWithUnexpectedResult"]==[] and native["cohorts"]=={"paired":61598,"zero":19271,"fixed":1234,"sat-control":105} and cmd["total"]==1339,"Historical source/command cohort or outcome changed")
    rev=read(f/"reverse/receipt.json")
    require(bound["verdict"]["archivedForward"]==read(f/"independent-forward-retention.json") and bound["verdict"]["archivedReverse"]==rev and rev["directions"]==86 and rev["native"]=={"MATCHED":86} and rev["commitmentReceiptSha256"]==sha(f/"reverse/native.jsonl") and rev["inputRegistrationSha256"]==sha(f/"reverse/contract.json") and read(f/"reverse/contract.json")["expandedInputsSha256"]==sha(f/"reverse/jobs.tsv"),"Historical reverse controls changed")
    import csv,itertools
    pairs=set()
    with (f/"reverse/jobs.tsv").open() as jobs,(f/"reverse/native.jsonl").open() as outcomes:
        for pos,(j,res) in enumerate(itertools.zip_longest(csv.reader(jobs,delimiter="\t"),outcomes)):
            require(j and len(j)==9 and j[8]==str(pos) and res,"Incomplete archived reverse witness")
            r=json.loads(res);key=tuple(j[1:7])
            require(key not in pairs and (r["left"],r["leftPredicate"],r["right"],r["rightPredicate"])==(j[1],j[2],j[4],j[5])
                    and r["ordinal"]==pos and r["expected"]==int(j[7]) and r["checked"] is True and check_native(r,int(j[7])),
                    "Unbound archived reverse witness")
            pairs.add(key)
    require(len(pairs)==86,"Missing archived reverse witness")
    return verdict


def check_retained_rows(root,repo,verdict):
    from collections import Counter
    src=root/"retention";cache={};states=Counter()
    metric=Counter();guarded=[];parents=[{},{}]
    def find(group,x):
        while x in group and group[x]!=x:
            group[x]=group[group[x]];x=group[x]
        return x
    def link(group,a,b):
        group.setdefault(a,a);group.setdefault(b,b)
        group[find(group,b)]=find(group,a)
    def count_pairs(group):
        return sum(n*(n-1)//2 for n in Counter(find(group,x) for x in group).values())
    def confirm(endpoint):
        path,predicate,digest=endpoint
        require(predicate and DIGEST.fullmatch(digest),"Missing retained source selector/hash")
        if path not in cache:cache[path]=sha(regular(repo/"classified-data",path))
        require(cache[path]==digest,"Changed retained source bytes "+path)
    import contextlib
    import itertools
    records=root/"receipts/retention"
    manifest=read(records/"manifest.json")
    require(sha(records/"manifest.json")==verdict["originalInputSha256"] and manifest["totals"]=={"paired":61598,"zero":19271,"fixed":1234,"sat-control":105},"Unbound retention input manifest")
    seen={kind:set() for kind in manifest["totals"]}
    with contextlib.ExitStack() as stack:
        jobs=stack.enter_context(gzip.open(records/"source-jobs.jsonl.gz","rb"))
        streams={k:stack.enter_context(gzip.open(src/(k+".jsonl.gz"),"rt")) for k in seen}
        for shard in manifest["shards"]:
            k=shard["kind"]; checksum=hashlib.sha256()
            for _ in range(shard["rows"]):
                line=next(jobs,b"");require(line.endswith(b"\n"),"Truncated original retention input");checksum.update(line);j=json.loads(line)
                r=json.loads(next(streams[k]));a=r["a"];b=r["b"];confirm(a);confirm(b);key=tuple(a)+tuple(b)
                require(j["kind"]==k and key not in seen[k] and (j["a"][:3],j["b"][:3])==(a,b),"Duplicate or substituted retention comparison");seen[k].add(key);states[r["state"]]+=1
                if k in ("paired","zero"):
                    require(r["state"]=="MATCHED" and r["observedFast"]==r["observedCertified"]==r["expected"]==j["expected"] and r["slotted"]==j["slotted"] and r["sequenceKind"] in ("FLAT_ACTIONS","TEMPORAL_BLOCK_EFFECTS") and type(r["orderedLength"]) is int and r["orderedLength"]>=0 and DIGEST.fullmatch(r["sharedSha256"]),"Incomplete retained native comparison")
                    if k=="zero":require(r["expected"]==0,"Structural reference pair lost")
                if k=="paired":
                    parts=r["components"]
                    require(r["scanCostBindingChecked"] is True and len(parts)==4 and
                            all(type(n) is int and n>=0 for n in parts) and parts[0]==sum(parts[1:])==j["expected"]
                            and r["commands"]==j["commands"], "Fast/Certified scan or original fixed-command tags changed")
                if k in ("fixed","sat-control"):
                    scope=dict(r["scope"]); native=scope.pop("native",None)
                    expected_scope={name:v for name,v in j["scoped"].items() if v is not None}
                    fixed=scope.get("scopeStatus")=="FIXED_COMMAND_RULE"
                    require(r["state"]=="SCOPE_RETAINED" and scope==expected_scope and
                            (native=="UNSAT" and fixed and scope.get("rules") if k=="fixed" else
                             (not fixed and native==(None if scope.get("scopeStatus")=="NO_COMMON_COMMAND" else "NOT_RUN"))),
                            "Direct reference-command scope or basis changed")
                if k in ("paired","zero"):
                    if r["slotted"]:metric["originalSlotted"+k.capitalize()]+=1
                    if r["expected"]==0:metric[k+"StructuralZero"]+=1
                if k=="paired":
                    metric["pairedFixedCommand"]+=sum(c["basis"]=="FIXED_COMMAND_RULE" for c in r["commands"])
                else:
                    a,b=r["referenceIds"]
                    require([a,b]==[j["a"][5],j["b"][5]],"Retained reference selectors changed")
                    if k=="zero":link(parents[0],a,b)
                    if k in ("fixed","zero"):link(parents[1],a,b)
                    if k=="fixed":metric["poolFixedCommand"]+=1
                    if k=="sat-control":guarded.append((a,b))
            require(checksum.hexdigest()==shard["sha256"],"Original retention input shard differs")
        require(next(jobs,None) is None and all(next(f,None) is None for f in streams.values()) and {k:len(v) for k,v in seen.items()}==manifest["totals"],"Missing or extra retained rows")
    require(dict(states)==verdict["nativeCheckedStates"],"Retained native states differ")
    metric.update(poolStructuralComponentPairs=count_pairs(parents[0]),poolCommandComponentPairs=count_pairs(parents[1]),previousSatControls=len(guarded))
    require(not any(find(parents[1],a)==find(parents[1],b) for a,b in guarded) and
            dict(metric)==verdict["sourceHistory"]==dict(originalSlottedPaired=2228,originalSlottedZero=8952,pairedStructuralZero=5137,zeroStructuralZero=19271,pairedFixedCommand=347,poolFixedCommand=1234,poolStructuralComponentPairs=19271,poolCommandComponentPairs=20629,previousSatControls=105),
            "The released fixed-command or structural graphs differ from fresh protected source rows")
    verify_archived_commands(src,records,verdict)


def verify_archived_commands(src,records,verdict):
    import itertools
    from collections import Counter
    commands=read(src/"archived-original-command-receipt.json");registered=read(src/"archived-original-command-registration.json");asserted=Counter();seen=set()
    require(commands["originalRegistrationSha256"]==sha(src/"archived-original-command-registration.json") and registered["candidateJarSha256"]==verdict["candidateSha256"],"Archived commands lack the candidate registration")
    out=hashlib.sha256();inp=hashlib.sha256()
    with gzip.open(src/"archived-original-command-results.jsonl.gz","rb") as f,gzip.open(records/"archived-command-inputs.jsonl.gz","rb") as specs:
        for line,original in itertools.zip_longest(f,specs):
            require(line and original,"Missing archived command");out.update(line);inp.update(original)
            r=json.loads(line);expected=json.loads(original);key=tuple(r["pair"]);decision=r["decision"]
            require(key not in seen and list(key)==expected["pair"] and r["parsedSourceSha256"]==r["sha256"]==expected["sha256"]==hashlib.sha256(expected["source"].encode()).hexdigest() and decision["native"]==expected["native"] and sorted(decision.get("rules",[]))==sorted(expected["rules"]),"Changed archived command, source or result")
            asserted[decision["native"]]+=1;seen.add(key)
    require(inp.hexdigest()==registered["inputSha256"] and out.hexdigest()==commands["rawSha256"] and dict(asserted)=={"SAT":105,"UNSAT":1234} and dict(asserted)==commands["native"],"Archived-command ledger differs")
