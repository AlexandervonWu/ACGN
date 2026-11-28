"""Look up an executable temporal witness and preserve the distinction between direct raw identity and source-checked relabelling."""
import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from occurrences import archived_label_reconstruction, digest, offset_between, project, require
from verify import EDITIONS, HERE, RELEASE, load_control, sha

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("edition",choices=EDITIONS)
    ap.add_argument("repo",type=Path)
    ap.add_argument("submission")
    ap.add_argument("reference",help="Original reference ID or path#predicate")
    ap.add_argument("--jar",type=Path,required=True)
    ap.add_argument("--warm",action="store_true",help="Compare after one prior preparation of the same original selection")
    ap.add_argument("--full-receipt",type=Path)
    a=ap.parse_args();repo=a.repo.resolve();jar=a.jar.resolve();audit=RELEASE/"reproduce"/(a.edition+"-audit")
    rows,witnesses,obs,offsets=load_control()
    options=[(n,r) for n,r in enumerate(rows) if r["submission"]==a.submission and
             a.reference in (r["referenceId"],r["reference"]+"#"+r["referencePredicate"])]
    if not options:
        require(not a.warm,"This controlled warm-up experiment covers only its registered 196 pairs")
        cmd=[sys.executable,"-B",str(audit/"replay_lookup.py"),str(RELEASE/a.edition),str(repo),a.submission,a.reference,"--jar",str(jar)]
        if a.full_receipt:cmd+=["--full-receipt",str(a.full_receipt)]
        return subprocess.run(cmd).returncode
    require(len(options)==1,"Ambiguous source or reference selector; use the original reference ID")
    n,r=options[0]
    selected=json.loads(subprocess.check_output([sys.executable,"-B",str(audit/"lookup_native.py"),str(RELEASE/a.edition),str(repo),a.submission,a.reference]))
    require(sha(jar)==selected["measuredJarSha256"] and selected["expected"]==int(r["distance"])
            and (selected["submission"]["predicate"],selected["submission"]["sha256"],selected["reference"]["sha256"])
            ==(r["sourcePredicate"],r["sourceSha256"],r["referenceSha256"]),"Inputs do not match measured endpoints")
    raw_hash=r[a.edition+"ProgramSha256"]
    require(selected["native"]["sharedOrderedSequenceSha256"]==raw_hash,"Changed archive commitment")
    capture=json.loads((HERE/"cold-capture.json").read_bytes())
    require(capture["libraries"]=={p.name:sha(p) for p in (repo/"lib").glob("*.jar")},"Dependencies differ")
    src=audit/"EmitNativePrograms.java"
    require(sha(src)==capture["emitterSha256"],"Native source emitter changed")
    with tempfile.TemporaryDirectory() as td:
        temp=Path(td);cp=str(jar)+":"+str(repo/"lib/*")
        subprocess.run(["javac","--release","17","-encoding","UTF-8","-cp",cp,"-d",td,src,HERE/"WarmNativePrograms.java"],check=True)
        args=[r[k] for k in ("submission","sourcePredicate","sourceSha256","reference","referencePredicate","referenceSha256")]
        cmd=["java","-Xms160m","-Xmx400m","-XX:ActiveProcessorCount=1","-XX:+UseParallelGC","-XX:ParallelGCThreads=1","-cp",td+":"+cp,
             "is.fivefivefive.CanDis."+("WarmNativePrograms" if a.warm else "EmitNativePrograms"),str(repo/"classified-data"),*args]
        raw=subprocess.run(cmd,check=True,capture_output=True).stdout
    actual=project(raw,int(r["distance"]),int(r[a.edition+"Count"]))
    if a.full_receipt:
        with a.full_receipt.open("xb") as dest:dest.write(raw)
    expected=witnesses[obs[n,a.edition,"cold",0][1]]
    translated=offset_between(expected,actual)
    direct=digest(actual["program"])
    verified=(direct==raw_hash)
    mode="RAW_DIGEST_MATCH" if verified else "FRESH_SOURCE_MATCH_ONLY"
    if not verified and (n,a.edition) in offsets:
        change=offsets[n,a.edition]-translated
        require(digest(archived_label_reconstruction(actual["program"],change))==raw_hash,
                "Fresh source program cannot reproduce the archived hash")
        verified=True;mode="ARCHIVE_RECONSTRUCTED_WITH_SOURCE_LABEL_OFFSET"
    print(json.dumps(dict(status=mode,withinRunFastCertifiedEqual=True,distance=int(r["distance"]),
                          freshRawSha256=direct,originalArchiveRawSha256=raw_hash,rawDigestsIdentical=direct==raw_hash,
                          archiveReconstructionVerified=verified,freshOwnerAndUseOffsetFromCold=translated,
                          archivalUseOffsetFromCold=offsets.get((n,a.edition))),sort_keys=True))
    return 0 if verified else 2
if __name__=="__main__":sys.exit(main())
