"""Verify the standalone harness repair, authoritative endpoints, and the two separately registered builds."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parent
BASE="177500afd23b74d3d3695b9c38fb6ad0c0709838"
TEST="2ab010c639e1ac1adca595d8fa33a1f499512aad"
BASE_JAR="79e63cd786f7da185185a078ffd7979c036b8034abd1643b5797ae8dd1613bdd"
TEST_JAR="9fd6ae0a77a38b18edb4e14facfcdefa87cc7fd18b2b8d7bb1d974d46a1021b0"
FILES=["FastLocalPaidScopeTest","RetainedPaidCompletionTest"]


def read(path):
    return json.loads(path.read_bytes())


def sha(data):
    return hashlib.sha256(data).hexdigest()


def need(check,msg):
    if not check:
        raise ValueError(msg)


def git(repo,*args):
    return subprocess.check_output(["git","-C",str(repo),*args])


def historical(repo):
    root=ROOT/"retained";h=read(root/"history-receipt.json")
    data=gzip.decompress((root/"complete-anchored.json.gz").read_bytes())
    need(sha(data)==h["harnessReceipt"] and json.loads(data)["checks"]==h["harnessChecks"]==113
         and sha((root/"anchored.log").read_bytes())==h["harnessLogSha256"]
         and "RetainedPaidCompletionTest: 113 checks passed" in (root/"anchored.log").read_text(),
         "Changed retained harness output")
    source=ROOT/"sources/RetainedPaidCompletionTest.java"
    need(sha(source.read_bytes())==h["controlSourceSha256"],"Changed retained harness source")
    expected={}
    for rev in h["revisions"]:
        rows=rev["results"]
        need(len(rows)==4 and len({(r["source"],r["left"],r["right"]) for r in rows})==4,"Duplicate/missing historical command")
        for r in rows:
            expected[r["path"]]=r["sha256"]
    need(len(expected)==28 and len(h["revisions"])==7,"Incomplete historical native matrix")
    for r in h["sase"]: expected[r["receipt"]]=r["sha256"]
    cross=h["old20CrossReplay"];expected[cross["path"]]=cross["sha256"]
    with zipfile.ZipFile(root/"native-receipts.zip") as z:
        need(len(z.namelist())==len(expected) and set(z.namelist())==set(expected),"Unexpected native observation names")
        for name,digest in expected.items(): need(sha(z.read(name))==digest,"Changed observation "+name)
        for rev in h["revisions"]:
            for r in rev["results"]:
                value=json.loads(z.read(r["path"]));n=value["native"];a=n["diagnostic"]["fast"];b=n["diagnostic"]["certified"]
                need(value["left"]==r["left"] and value["right"]==r["right"] and
                     value["source"]==r["source"] and sha(git(repo,"show",rev["sourceCommit"]+":classified-data/"+r["source"]))==r["sourceSha256"],
                     "Historical endpoint bytes/predicate changed")
                need(n["status"]==r["native"]=="MATCHED" and n["reason"]=="CHECKED_NATIVE_ACTIONS_EQUAL"
                     and all(n[k] is True for k in ("endpointCorrespondenceChecked","sourceCertificatesChecked","fixedChoiceReplaysChecked"))
                     and n["fastActions"]==n["certifiedActions"] and len(n["fastActions"])==r["nativeLength"]
                     and all([d[k] for k in ("distance","temporalDistance","quantifierDistance","matrixDistance")]==r["components"] for d in (a,b))
                     and value["publicFast"]==value["publicCertified"]==r["components"][0]==sum(r["components"][1:])
                     and (value["sourceIr"],value["targetIr"])==(r["sourceIr"],r["targetIr"]),"Unverified historical native measurement")
        for r in h["sase"]:
            n=json.loads(z.read(r["receipt"]));a=n["diagnostic"]["fast"]
            need(n["status"]=="MATCHED" and n["fastActions"]==n["certifiedActions"] and len(n["fastActions"])==r["actions"]==24
                 and a["distance"]==r["cost"]==27 and a["phases"][0]["alphaMapping"]==r["selected"]
                 and a["selectedPaidDeclarationCorrespondence"]==r["paid"],"Changed SASE witness")
        res=json.loads(z.read(cross["path"]))
        need([(r["old"],r["status"]) for r in res]==[(True,"INVALID_REPLAY"),(False,"MATCHED")]*2 and
             all(r["evidence"]["error"]=="Selected representative missing child" for r in res if r["old"]),"Historical 20-cost program replay changed")
    for name,digest in h["normalizedMatrixDigests"].items():
        need(sha((root/name).read_bytes())==digest,"Changed normalized matrix "+name)
    for name,expected in (("domain-proof.json",[False,True,True]),("exception-proof.json",[False,True])):
        obj=(root/name).read_bytes();jobs=json.loads(obj)
        need(sha(obj)==h["freshAlloy"][name]["sha256"] and [j["satisfiable"] for j in jobs]==expected and
             [{k:r[k] for k in ("formula","overallScope","bitwidth","satisfiable")} for r in jobs]==h["freshAlloy"][name]["results"],
             "Changed Alloy guard or exception control")
    return h


def disjoint(repo):
    root=ROOT/"disjoint";v=read(root/"receipt.json")
    need(v["measuredSource"]==BASE and v["jarSha256"]==BASE_JAR and v["fullHarnessExit"]==0
         and v["registeredParserConcreteChecks"]==208 and (root/"issued.exit").read_text().strip()=="0"
         and "FastLocalPaidScopeTest: 208 checks passed" in (root/"issued.log").read_text(),"Wrong disjoint test/engine")
    for name,digest in v["paths"].items():need(sha((root/name).read_bytes())==digest,"Changed disjoint control "+name)
    need(v["testSha256"]==sha((ROOT/"sources/FastLocalPaidScopeTest.java").read_bytes())
         and v["restoredFixtureSha256"]==sha((ROOT/"sources/retained-domain-maps.als").read_bytes()),"Changed disjoint fixture or harness")
    independent=read(root/"solver.json")
    need(independent==v["solvers"] and [r["satisfiable"] for r in independent]==[True,False],"Disjoint semantics results differ")
    obs=read(root/"native-contrast.json")
    need([{k:r[k] for k in ("reason","fast","certified","order","status")} for r in obs]==v["contrast"]
         and len(obs)==2 and all(r["fast"]==r["certified"]==27 and r["status"]=="MATCHED" and r["reason"]=="CHECKED_NATIVE_ACTIONS_EQUAL" for r in obs),"Disjoint/ordinary native controls changed")


def build_census(repo):
    root=ROOT/"build";comparison=read(root/"classfiles.json");classes=[];receipts=[]
    need(comparison["status"]=="VERIFIED" and (comparison["measuredCommit"],comparison["controlCommit"],comparison["measuredJarSha256"],comparison["controlJarSha256"])==(BASE,TEST,BASE_JAR,TEST_JAR),"Wrong measured or standalone binary")
    for label,commit,wanted in (("measured",BASE,BASE_JAR),("control",TEST,TEST_JAR)):
        receipt=read(root/(label+"-build.json"));receipts.append(receipt)
        need(receipt["buildsByteIdentical"] is True and receipt["git"]["commit"]==commit
             and receipt["git"]["tree"]==git(repo,"rev-parse",commit+"^{tree}").decode().strip()
             and receipt["experimentJar"]["sha256"]==wanted,"Invalid registered build")
        for what,key,count in (("classes","classfileManifestSha256","classfiles"),("sources","sourceManifestSha256","sourceFiles")):
            content=gzip.decompress((root/(label+"-"+what+".sha256.gz")).read_bytes());records=content.decode().splitlines()
            entries={n:h for h,n in (line.split("  ",1) for line in records)}
            need(sha(content)==receipt[key] and len(entries)==len(records)==receipt[count] and all(re.fullmatch(r"[a-f0-9]{64}",h) for h in entries.values()),"Changed registered "+what+" inventory")
            if what=="classes":classes.append(entries)
    need(receipts[0]["dependencies"]==receipts[1]["dependencies"],"Runtime dependencies changed")
    allfiles=set(classes[0])|set(classes[1]);changed=sorted(n for n in allfiles if classes[0].get(n)!=classes[1].get(n))
    need(changed==comparison["changedClassfiles"] and len(changed)==3 and
         all(re.fullmatch(r"is/fivefivefive/CanDis/core/(FastLocalPaidScopeTest|RetainedPaidCompletionTest)(\$.+)?\.class",s) for s in changed)
         and len(allfiles)==comparison["classfilesCompared"]==1582 and len(allfiles)-len(changed)==comparison["identicalClassfiles"]==1579,
         "A production class changed")
    return comparison


def verify(repo,partial):
    names=["src/is/fivefivefive/CanDis/core/"+n+".java" for n in FILES]
    fixture="docs/distance-parity-20261107/retained-domain-maps.als"
    need(set(git(repo,"diff","--name-only",BASE,TEST).decode().splitlines())=={*names,fixture,"scripts/run_bounded_ci_java_tests.sh"},
         "Unexpected changes in the control revision")
    for name in [*names,fixture]:
        need((ROOT/"sources"/Path(name).name).read_bytes()==git(repo,"show",TEST+":"+name),"Changed supplementary source "+name)
    historic=historical(repo);disjoint(repo)
    builds=(ROOT/"build/classfiles.json").exists()
    if builds:build_census(repo)
    ci=ROOT/"bounded-ci/receipt.json";ci_pass=ci.is_file()
    if ci_pass:
        data=read(ci);log=gzip.decompress((ci.parent/"bounded.log.gz").read_bytes())
        need(data["gitCommit"]==TEST and data["gitTree"]==git(repo,"rev-parse",TEST+"^{tree}").decode().strip()
             and data["cleanBefore"] is True and data["exit"]==0 and sha(log)==data["logSha256"]
             and sha((ci.parent/"usage.txt").read_bytes())==data["resourceReceiptSha256"]
             and b"FastLocalPaidScopeTest: 208 checks passed" in log and b"RetainedPaidCompletionTest: 113 checks passed" in log,
             "Missing exact-source bounded CI or either integrated harness")
    need(partial or (builds and ci_pass),"Test-only class/CI evidence pending")
    return dict(status="VERIFIED" if builds and ci_pass else "STAGED",historicControlObservations=28,historicalRevisions=len(historic["revisions"]),
                disjointChecks=208,retainedPaidChecks=113,measuredCommit=BASE,measuredJarSha256=BASE_JAR,
                controlCommit=TEST,controlJarSha256=TEST_JAR,verifiedClassfiles=builds,verifiedBoundedCI=ci_pass)


if __name__=="__main__":
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo",type=Path,required=True)
    parser.add_argument("--staged",action="store_true",help="Verify available evidence while exact-source CI is in progress")
    a=parser.parse_args();print(json.dumps(verify(a.repo.resolve(),a.staged),sort_keys=True))
