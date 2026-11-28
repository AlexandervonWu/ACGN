"""Compare every separately compiled Java class to the measured JAR at a test-only follow-up."""
from pathlib import Path
import argparse
import collections
import hashlib
import json
import re
import subprocess
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("repo",type=Path)
parser.add_argument("candidate_build",type=Path)
parser.add_argument("control_build",type=Path)
parser.add_argument("output",type=Path)
args=parser.parse_args()

def load(build):
    receipt=json.loads((build / "build-receipt.json").read_bytes())
    file=build / "a.jar"
    assert receipt["buildsByteIdentical"] and hashlib.sha256(file.read_bytes()).hexdigest()==receipt["experimentJar"]["sha256"]
    with zipfile.ZipFile(file) as z:
        manifest={key:hashlib.sha256(z.read(key)).hexdigest() for key in z.namelist() if key.endswith(".class")}
    return receipt,manifest

old,base=load(args.candidate_build)
new,current=load(args.control_build)
source_changes=subprocess.check_output(["git","-C",str(args.repo),"diff","--name-only",old["git"]["commit"],new["git"]["commit"],"--","src"],text=True).splitlines()
allowed={"src/is/fivefivefive/CanDis/core/FastLocalPaidScopeTest.java","src/is/fivefivefive/CanDis/core/RetainedPaidCompletionTest.java"}
assert set(source_changes) == allowed
changed=sorted(k for k in base.keys() | current.keys() if base.get(k) != current.get(k))
assert changed and all(re.fullmatch(r"is/fivefivefive/CanDis/core/(FastLocalPaidScopeTest|RetainedPaidCompletionTest)(\$.+)?\.class",k) for k in changed)
assert old["dependencies"]==new["dependencies"]
out={"schema":"acgn-standalone-control-classfile-comparison-v1","status":"VERIFIED",
     "measuredCommit":old["git"]["commit"],"measuredJarSha256":old["experimentJar"]["sha256"],
     "controlCommit":new["git"]["commit"],"controlJarSha256":new["experimentJar"]["sha256"],
     "sourceChanges":source_changes,"changedClassfiles":changed,"classfilesCompared":len(base.keys() | current.keys()),
     "identicalClassfiles":len(base.keys() | current.keys())-len(changed)}
args.output.write_text(json.dumps(out,sort_keys=True,indent=2)+"\n")
print(json.dumps(out,sort_keys=True))
