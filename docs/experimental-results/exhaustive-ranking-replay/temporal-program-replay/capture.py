"""Recheck original predicates in fresh JVMs on both frozen JARs."""
import argparse
import csv
import gzip
import hashlib
import json
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def dump(path, data):
    path.write_bytes(gzip.compress(data, compresslevel=4, mtime=0))

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("release",type=Path)
    ap.add_argument("corpus",type=Path)
    ap.add_argument("libraries",type=Path)
    ap.add_argument("original_jar",type=Path)
    ap.add_argument("repaired_jar",type=Path)
    ap.add_argument("output",type=Path,help="Fresh capture directory")
    ap.add_argument("--workers",type=int,default=8)
    ap.add_argument("--repeats",type=int,default=2)
    ap.add_argument("--warm",action="store_true",help="Run the original selection once in the same JVM before emitting it")
    a=ap.parse_args()
    if a.repeats<(1 if a.warm else 2):ap.error("At least two fresh JVMs per pair and JAR are required")
    out=a.output;out.mkdir()
    jars={"original":a.original_jar.resolve(),"repaired":a.repaired_jar.resolve()}
    identities={name:json.loads((a.release/"receipts"/name/"runner-identity.json").read_bytes()) for name in jars}
    for label,j in jars.items():
        expected=identities[label]["jarSha256"] if label=="original" else identities[label]["engine"]["jarSha256"]
        if sha(j)!=expected:raise ValueError("Unregistered engine")
    allowed={Path(k).name:v for k,v in identities["original"]["files"].items() if k.startswith("frozen/lib/")}
    if {p.name:sha(p) for p in a.libraries.glob("*.jar")}!=allowed:raise ValueError("Unexpected dependency")
    src=a.release/"reproduce/original-audit/EmitNativePrograms.java"
    reg=json.loads((a.release/"receipts/original/auditor-identity.json").read_bytes())
    if sha(src)!=reg["files"]["EmitNativePrograms.java"]:raise ValueError("Wrong emitter")
    table=a.release/"previously-matched-program-changes.csv"
    with table.open(newline="") as f: rows=list(csv.DictReader(f))
    with tempfile.TemporaryDirectory(dir=out) as temp:
        compiled={}
        for label,j in jars.items():
            c=Path(temp)/label;c.mkdir()
            sources=[str(src)]
            if a.warm:sources.append(str(Path(__file__).with_name("WarmNativePrograms.java")))
            subprocess.run(["javac","--release","17","-encoding","UTF-8","-cp",f"{j}:{a.libraries}/*","-d",str(c),*sources],check=True)
            compiled[label]=c
        def capture(job):
            ordinal,label,run=job;r=rows[ordinal]
            args=[r[k] for k in ("submission","sourcePredicate","sourceSha256","reference","referencePredicate","referenceSha256")]
            cmd=["java","-Xms160m","-Xmx400m","-XX:+UseParallelGC","-XX:ParallelGCThreads=1","-XX:ActiveProcessorCount=1",
                 "-cp",f"{compiled[label]}:{jars[label]}:{a.libraries}/*","is.fivefivefive.CanDis."+("WarmNativePrograms" if a.warm else "EmitNativePrograms"),str(a.corpus),*args]
            got=subprocess.run(cmd,capture_output=True,check=True,timeout=180)
            dump(out/f"{ordinal:03d}-{label}-{run}.json.gz",got.stdout)
        jobs=[(i,label,r) for i in range(len(rows)) for r in range(a.repeats) for label in jars]
        with ThreadPoolExecutor(max_workers=a.workers) as pool:
            list(pool.map(capture,jobs))
    print(f"{len(jobs)} fresh JVM measurements",flush=True)
    receipt=dict(rows=len(rows),repeats=a.repeats,warmed=a.warm,freshJVMs=len(jobs),jarSha256={k:sha(v) for k,v in jars.items()},
                 sourceTableSha256=sha(table),emitterSha256=sha(src),libraries=allowed)
    (out/"capture-receipt.json").write_text(json.dumps(receipt,indent=2,sort_keys=True)+"\n")
if __name__=="__main__":main()
