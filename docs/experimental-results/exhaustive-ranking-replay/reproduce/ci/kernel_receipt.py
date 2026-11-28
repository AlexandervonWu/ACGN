"""Compile the frozen, proof-linked replay modules and inventory their printed axioms."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

def sha(value):
    return hashlib.sha256(value).hexdigest()

p = argparse.ArgumentParser(description=__doc__)
p.add_argument("repo", type=Path)
p.add_argument("commit")
p.add_argument("output", type=Path)
args = p.parse_args()
repo, dest = args.repo.resolve(), args.output.resolve()
commit = subprocess.check_output(["git","-C",str(repo),"rev-parse","--verify",args.commit+"^{commit}"],text=True).strip()
lean = Path("/home/augustus/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean")
formal = "docs/section3-repair-audit/formal/"
paths = [formal + "SurvivorWitnessOrder.lean","docs/distance-parity-20261107/DeclarationReplay.lean"] + [
    formal + model + ".lean" for model in ("CrossedDeclarationReplay", "OriginalOccurrenceOrder","TemporalDeclarationTie",
                                          "CoursesPaidData", "CoursesPaidAlignmentTie", "CoursesRepairedNative",
                                          "SingleSourceClassMinimum", "CoalescedDeclarationFrames")]
dest.mkdir(parents=True,exist_ok=False)
batch = dest/"lean"
batch.mkdir()
modules = []
for path in paths:
    code = subprocess.check_output(["git","-C",str(repo),"show",commit+":"+path])
    name = Path(path).stem
    (batch/(name+".lean")).write_bytes(code)
    result = subprocess.run([str(lean),"-o",name+".olean",name+".lean"],env={**os.environ,"LEAN_PATH":str(batch)},
                            cwd=batch,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    (dest/(name+".log")).write_bytes(result.stdout)
    result.check_returncode()
    log = result.stdout.decode()
    if "sorryAx" in log or "declaration uses 'sorry'" in log:
        raise ValueError("Incomplete proof in "+path)
    rows=[]
    for theorem, axioms in re.findall(r"'([^']+)' (?:does not depend on any axioms|depends on axioms: \[([^\]]*)\])",log):
        rows.append({"name":theorem,"axioms":[a.strip() for a in axioms.split(",") if a.strip()]})
    modules.append({"path":path,"sourceSha256":sha(code),"logSha256":sha(result.stdout),"printedTheorems":rows})
receipt = {"schema":"acgn-ranking-replay-kernel-inventory-v1","status":"VERIFIED","commit":commit,
           "leanVersion":subprocess.check_output([str(lean),"--version"],text=True).strip(),"leanBinarySha256":sha(lean.read_bytes()),
           "compilerScriptSha256":sha(Path(__file__).read_bytes()),"modules":modules,
           "scope":"Finite source-frame, order, replay and selection models. Source association is checked by the native corpus tests. Java-to-Lean refinement and public source-to-edit certification remain open."}
(dest/"receipt.json").write_text(json.dumps(receipt,sort_keys=True,indent=2)+"\n")
print(commit,len(modules),"modules",sum(len(m["printedTheorems"]) for m in modules),"printed theorem inventories")
