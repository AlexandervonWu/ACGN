#!/usr/bin/env python3
"""Make an offline checkpoint, retaining every byte needed to rerun the independent recount."""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from collections import defaultdict
from pathlib import Path

from verify_checkpoint import HFILE, digest, ident, lines, read, require


def install(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dst)


def write_index(base):
    listing = {p.relative_to(base).as_posix():digest(p) for p in sorted(base.rglob("*")) if p.is_file() and "__pycache__" not in p.parts}
    (base/"file-manifest.json").write_text(json.dumps(listing,sort_keys=True,indent=2)+"\n")


def main():
    p=argparse.ArgumentParser(description=__doc__)
    for k in ("workspace","jar","build-receipt","target","snapshot","output"):
        p.add_argument("--"+k,type=Path,required=True)
    p.add_argument("--snapshot-sha256",required=True)
    a=p.parse_args()
    w=a.workspace
    require(not a.output.exists() and digest(a.snapshot)==a.snapshot_sha256,"Changed selection or output exists")
    reg=read(a.snapshot)
    ordinal_shards=defaultdict(set)
    for rel in reg["originalIncidentFiles"]:
        m=re.fullmatch(r"incidents/(shard-\d{4})-(\d+)-[0-9a-f-]+\.json\.gz",rel)
        require(m and int(m[2]) not in ordinal_shards[m[1]],"Bad original archive identity")
        ordinal_shards[m[1]].add(int(m[2]))
    with tempfile.TemporaryDirectory(dir=a.output.parent) as temp:
        root=Path(temp)/"evidence"
        root.mkdir()
        orig=root/"original"
        for name in ("verify_checkpoint.py","native_commitment.py","README.md"):
            install(Path(__file__).with_name(name),root/name)
        if "observedProducerSha256" in reg:
            install(w/"packaging/replay_regressions.py",orig/"packaging/replay_regressions.py")
        for rel in ("runner-identity.json","cohort/manifest.json"):
            install(w/rel,orig/rel)
        for path in read(w/"runner-identity.json")["files"]:
            if path.startswith(("runner-classes/","frozen/lib/","runner/ExhaustiveNativeReplay.java")):
                install(w/path,orig/path)
        install(a.jar,root/"engine/candidate.jar")
        install(a.build_receipt,root/"engine/build-receipt.json")
        install(a.snapshot,root/"snapshot.json")
        source_paths=set()
        for file in reg["originalIncidentFiles"]:
            install(w/"results"/file,orig/"results"/file)
        for shard, ordinals in ordinal_shards.items():
            rel="results/"+shard+".jsonl"
            (orig/rel).parent.mkdir(parents=True,exist_ok=True)
            with (orig/rel).open("xb") as out,(w/rel).open("rb") as incoming:
                for line in incoming:
                    r=json.loads(line)
                    if r["ordinal"] in ordinals:
                        ordinals.remove(r["ordinal"])
                        out.write(line)
                        source_paths.update((r["left"],r["right"]))
                    if not ordinals:
                        break
            require(not ordinals,"Original observation not available")
        extra_pools=set()
        if reg["includeHistory"]:
            install(w/HFILE,orig/HFILE)
            for hist in lines(w/HFILE):
                source_paths.update((hist["submission"],hist["reference"]))
                extra_pools.add((hist["submission"].split("/")[0],hist["predicate"]))
        for meta in read(w/"cohort/manifest.json")["shards"]:
            if meta["id"] in ordinal_shards or tuple(meta["pool"]) in extra_pools:
                install(w/"cohort"/meta["path"],orig/"cohort"/meta["path"])
        for path in source_paths:
            install(w/"frozen/classified-data"/path,orig/"frozen/classified-data"/path)
        shutil.copytree(a.target,root/"checkpoint")
        cmd=[sys.executable,"-B","verify_checkpoint.py","audit","--workspace","original","--jar","engine/candidate.jar","--build-receipt","engine/build-receipt.json","--snapshot","snapshot.json","--snapshot-sha256",a.snapshot_sha256,"--target","checkpoint","--output","independent-recount.json"]
        verdict=subprocess.run(cmd,cwd=root)
        require(verdict.returncode in (0,2) and (root/"independent-recount.json").is_file(),"Offline checkpoint is incomplete")
        result=read(root/"independent-recount.json")
        require(verdict.returncode==(2 if result["nativeCheckpointStatus"]=="BLOCKED" else 0),"Offline native status differs")
        (root/"recheck.sh").write_text("#!/bin/sh\nset -eu\ncd \"$(dirname \"$0\")\"\nexec python3 -B verify_checkpoint.py audit --workspace original --jar engine/candidate.jar --build-receipt engine/build-receipt.json --snapshot snapshot.json --snapshot-sha256 "+a.snapshot_sha256+" --target checkpoint --output \"\u0024{1:?Supply a fresh result filename}\"\n")
        os.chmod(root/"recheck.sh",0o755)
        write_index(root)
        root.rename(a.output)
    print(digest(a.output/"file-manifest.json"),a.output)


if __name__=="__main__":
    main()
