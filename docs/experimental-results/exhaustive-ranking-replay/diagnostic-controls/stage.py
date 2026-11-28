"""Install standalone control evidence after each one-time completion. All writes stay inside this package."""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parent
MEASURED = "177500afd23b74d3d3695b9c38fb6ad0c0709838"
CONTROLS = "2ab010c639e1ac1adca595d8fa33a1f499512aad"


def read(path):
    return json.loads(path.read_bytes())


def digest(data):
    return hashlib.sha256(data).hexdigest()


def blob(name, data):
    dest = ROOT / name
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists():
        if dest.read_bytes() != data:
            raise ValueError("Installed evidence differs: " + name)
        return
    with tempfile.NamedTemporaryFile(dir=dest.parent) as tmp:
        tmp.write(data)
        tmp.flush()
        os.fsync(tmp.fileno())
        os.link(tmp.name, dest)
    dest.chmod(0o644)


def put(source, name, expected=None):
    data = source.read_bytes()
    if expected and digest(data) != expected:
        raise ValueError("Unbound source file: " + str(source))
    blob(name,data)


def compressed(source, name):
    blob(name, gzip.compress(source.read_bytes(),compresslevel=6,mtime=0))


def zip_entries(prefix, names):
    import io
    stream = io.BytesIO()
    with zipfile.ZipFile(stream,"w",compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for name in sorted(set(names)):
            entry=zipfile.ZipInfo(name, date_time=(1980,1,1,0,0,0))
            entry.external_attr=0o644 << 16
            z.writestr(entry,(prefix/name).read_bytes(),compress_type=zipfile.ZIP_DEFLATED,compresslevel=6)
    return stream.getvalue()


def stage(w,repo,require_ci):
    dis=w/"diagnosis/local-disjoint-guard-audit"
    paid=w/"diagnosis/retained-sase-sWhtAlED"
    for path,h in read(dis/"receipt.json")["paths"].items():
        put(dis/path, "disjoint/"+path,h)
    put(dis/"receipt.json","disjoint/receipt.json")
    history=read(paid/"history-receipt.json")
    put(paid/"history-receipt.json","retained/history-receipt.json")
    native=set()
    for rev in history["revisions"]:
        native.update(r["path"] for r in rev["results"])
    native.update(r["receipt"] for r in history["sase"])
    native.add(history["old20CrossReplay"]["path"])
    blob("retained/native-receipts.zip",zip_entries(paid,native))
    for name in history["normalizedMatrixDigests"] | history["freshAlloy"]:
        put(paid/name,"retained/"+name)
    put(paid/"anchored.log","retained/anchored.log",history["harnessLogSha256"])
    compressed(paid/"complete-anchored.json","retained/complete-anchored.json.gz")
    for name in ("UnusedDomains.java","ExceptionProjection.java","SaseWitness.java","ArchivedCoordinates.java","NormalizedTrees.java","CrossRevisionReplays.java"):
        put(paid/name,"retained/probes/"+name)
    for name in ("FastLocalPaidScopeTest","RetainedPaidCompletionTest"):
        source="src/is/fivefivefive/CanDis/core/"+name+".java"
        code=subprocess.check_output(["git","-C",repo,"show",CONTROLS+":"+source])
        blob("sources/"+name+".java",code)
    fixture="docs/distance-parity-20261107/retained-domain-maps.als"
    blob("sources/retained-domain-maps.als",subprocess.check_output(["git","-C",repo,"show",CONTROLS+":"+fixture]))
    put(w/"diagnosis/standalone-control-repair/check_test_artifact.py","build/check_test_artifact.py")
    measured=w/"builds/final-05-registered";control=w/"builds/replay-controls-2ab010c6"
    comparison=w/"diagnosis/standalone-control-repair/classfiles.json"
    if comparison.is_file():
        put(comparison,"build/classfiles.json")
        for name,build,commit in (("measured",measured,MEASURED),("control",control,CONTROLS)):
            reg=read(build/"build-receipt.json")
            if reg["git"]["commit"]!=commit:
                raise ValueError("Incorrect registered build")
            put(build/"build-receipt.json","build/"+name+"-build.json")
            for what in ("classes","sources"):
                compressed(build/(what+".sha256"),"build/"+name+"-"+what+".sha256.gz")
    elif require_ci:
        raise ValueError("Test-only build/class census is pending")
    ci=w/"diagnosis/control-2ab010c6-bounded"
    if (ci/"receipt.json").is_file():
        receipt=read(ci/"receipt.json")
        if receipt["gitCommit"]!=CONTROLS or not receipt["cleanBefore"] or receipt["exit"]!=0:
            raise ValueError("Test-only exact-source bounded CI has not passed")
        put(ci/"receipt.json","bounded-ci/receipt.json")
        compressed(ci/"bounded.log","bounded-ci/bounded.log.gz")
        put(ci/"usage.txt","bounded-ci/usage.txt",receipt["resourceReceiptSha256"])
    elif require_ci:
        raise ValueError("Test-only bounded CI is pending")


if __name__=="__main__":
    arg=argparse.ArgumentParser(description=__doc__)
    arg.add_argument("--experiment",type=Path,required=True)
    arg.add_argument("--repo",type=Path,required=True)
    arg.add_argument("--require-ci",action="store_true")
    args=arg.parse_args()
    stage(args.experiment.resolve(),args.repo.resolve(),args.require_ci)
    command=[sys.executable,"-B",str(ROOT/"verify.py"),"--repo",str(args.repo.resolve())]
    if not args.require_ci:
        command.append("--staged")
    subprocess.run(command,check=True)
