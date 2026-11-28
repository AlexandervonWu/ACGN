"""Verify all fresh-JVM native observations, original source bindings, and explicitly reconstructed archival labels."""
import argparse
from collections import Counter
import csv
import gzip
import hashlib
import json
import lzma
import subprocess
from pathlib import Path
from occurrences import SerializedNumber, archived_label_reconstruction, canonical, digest, offset_between, project, require

HERE=Path(__file__).resolve().parent
RELEASE=HERE.parent
TABLE_SHA="cdc7c01f352b9ee15ac29d1d43eefc92f287f12d5ff7ef7d1f35cfcbe3b087bb"
EDITIONS=("original","repaired")

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def readgz(path):
    with gzip.open(path,"rt") as stream:
        yield from (json.loads(line,parse_float=SerializedNumber) for line in stream)

def load_control():
    table=RELEASE/"previously-matched-program-changes.csv"
    require(sha(table)==TABLE_SHA,"Unexpected original/final program comparison table")
    with table.open(newline="") as stream: rows=list(csv.DictReader(stream))
    witnesses={}
    for key,data in readgz(HERE/"witnesses.jsonl.gz"):
        require(key not in witnesses and digest(data)==key,"Different or duplicated source authority or ordered effects")
        witnesses[key]=data
    observations={}
    for n,e,p,r,raw,wit in readgz(HERE/"observations.jsonl.gz"):
        key=(n,e,p,r)
        require(key not in observations and wit in witnesses,"Duplicated or dangling projection")
        observations[key]=(raw,wit)
    jobs={(n,e,p,r) for n in range(len(rows)) for e in EDITIONS for p,r in (("cold",0),("cold",1),("warm",0))}
    require(len(rows)==196 and set(observations)==jobs,"Incomplete native replay")
    offsets={}
    path=HERE/"archived-offsets.jsonl"
    if path.is_file():
        for line in path.read_bytes().splitlines():
            d=json.loads(line)
            key=(d["row"],d["edition"])
            require(key not in offsets and key[0] in range(len(rows)) and key[1] in EDITIONS and type(d["offset"]) is int,"Bad archived offset")
            offsets[key]=d["offset"]
    return rows,witnesses,observations,offsets

def verify(repo):
    rows,witnesses,obs,offsets=load_control()
    lineage_file=HERE/"archived-lineages.jsonl.gz"
    lineage_records={(r["index"],r["edition"]):r for r in readgz(lineage_file)}
    require(len(lineage_records)==len(offsets)==392 and {k:v["offset"] for k,v in lineage_records.items()}==offsets,
            "Incomplete or inconsistent historical lineage registry")
    source_bindings=json.loads((HERE/"source-bindings.json").read_bytes())
    for label, specification in source_bindings.items():
        commit=json.loads((RELEASE/label/"summary.json").read_bytes())["measuredCommit"]
        require(specification["commit"]==commit,"Source bindings belong to a different JAR")
        for name,expected_sha in specification["fileSha256"].items():
            require(hashlib.sha256(subprocess.check_output(["git","-C",repo,"show",commit+":"+name])).hexdigest()==expected_sha,
                    "Production lineage/owner code differs from its measured Git source")
    checks=Counter(); expected_flags={}
    for profile,number in (("cold",784),("warm",392)):
        capture=json.loads((HERE/(profile+"-capture.json")).read_bytes())
        require(capture["freshJVMs"]==number and capture["sourceTableSha256"]==TABLE_SHA and capture["rows"]==196
                and capture["emitterSha256"]==sha(RELEASE/"reproduce/original-audit/EmitNativePrograms.java"),"Invalid fresh-JVM provenance")
        for e in EDITIONS:
            require(capture["jarSha256"][e]==json.loads((RELEASE/e/"summary.json").read_bytes())["measuredJarSha256"],"Engine identity changed")
        lib={p.name:sha(p) for p in (repo/"lib").glob("*.jar")}
        require(capture["libraries"]==lib,"Changed measured native dependencies")
    for (n,e,p,r),(raw,wid) in obs.items():
        key=(int(rows[n]["distance"]),int(rows[n][e+"Count"]),wid)
        if raw in expected_flags:require(expected_flags[raw]==key,"One raw receipt attached to conflicting scores")
        expected_flags[raw]=key
    seen=set()
    with lzma.open(HERE/"native-receipts.jsonl.xz","rb") as inp:
        for data in inp:
            raw=hashlib.sha256(data).hexdigest()
            require(raw in expected_flags and raw not in seen,"Unrecognized or duplicate native emission")
            expected,size,wid=expected_flags[raw]
            require(digest(project(data,expected,size))==wid,"Raw Fast/Certified evidence differs from retained projection")
            seen.add(raw)
    require(seen==set(expected_flags),"Missing native emission")
    deltas=[];unique_sources={}
    for n,row in enumerate(rows):
        for pfield,sfield in (("submission","sourceSha256"),("reference","referenceSha256")):
            path=row[pfield]
            if path not in unique_sources:unique_sources[path]=sha(repo/"classified-data"/path)
            require(unique_sources[path]==row[sfield],"Changed original source")
        def lookup(e,p,r=0):return witnesses[obs[n,e,p,r][1]]
        for prof in ("cold","warm"):
            checks[prof+"SameAcrossEngines"]+=digest(lookup("original",prof))==digest(lookup("repaired",prof))
        for e in EDITIONS:
            cold=lookup(e,"cold");warm=lookup(e,"warm")
            require(digest(cold)==digest(lookup(e,"cold",1)),"Distinct identical-condition fresh-JVM snapshots")
            checks["coldRepeatsIdentical"]+=1
            delta=offset_between(cold,warm);deltas.append(delta)
            require(delta>0,"No successful warmed-counter intervention")
            checks["warmOnlyConsistentOccurrenceOffset"]+=1
            for prof in ("cold","warm"):
                checks[prof+"ExactArchivedRawPrograms"]+=digest(lookup(e,prof)["program"])==row[e+"ProgramSha256"]
            if (n,e) in offsets:
                reconstructed=archived_label_reconstruction(cold["program"],offsets[n,e])
                require(digest(reconstructed)==row[e+"ProgramSha256"],"Archived program hash cannot be reconstructed "+str((n,e)))
                checks["exactArchivedReconstructions"]+=1
        if all((n,e) in offsets for e in EDITIONS):checks["bothArchivedProgramsReconstructed"]+=1
    for prof in ("cold","warm"):
        require(checks[prof+"SameAcrossEngines"]==196,"An engine changed more than the fresh label representation")
    require(checks["exactArchivedReconstructions"]==392 and checks["bothArchivedProgramsReconstructed"]==196,"Some archived raw programs were not recovered")
    ids={}
    for name in ("cold","warm"):ids[name]=sha(HERE/(name+"-capture.json"))
    return dict(status="VERIFIED",rows=len(rows),freshJvmObservations=len(obs),distinctNativeReceipts=len(seen),distinctWitnesses=len(witnesses),
                smallestWarmOffset=min(deltas),largestWarmOffset=max(deltas),smallestArchiveOffset=min(offsets.values()),largestArchiveOffset=max(offsets.values()),
                archivedLineageRegistrySha256=sha(lineage_file),sourceBindingsSha256=sha(HERE/"source-bindings.json"),sourceFiles=len(unique_sources),checks=dict(checks),
                receiptsFileSha256=sha(HERE/"native-receipts.jsonl.xz"),measurementsSha256=sha(HERE/"observations.jsonl.gz"),
                witnessFileSha256=sha(HERE/"witnesses.jsonl.gz"),sourceComparisonSha256=TABLE_SHA,captureReceiptSha256=ids)

if __name__=="__main__":
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument("--repo",required=True,type=Path)
    ap.add_argument("--write-summary",action="store_true")
    a=ap.parse_args();result=verify(a.repo)
    p=HERE/"summary.json"
    if a.write_summary:p.write_text(json.dumps(result,indent=2,sort_keys=True)+"\n")
    else:require(result==json.loads(p.read_bytes()),"Stored cross-run scope disagrees with the recount")
    print(json.dumps(result,sort_keys=True))
