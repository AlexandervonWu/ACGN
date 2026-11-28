"""Run the repository gates for one immutable revision in a separate clean checkout."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

def git(repo, *args):
    return subprocess.check_output(["git", "-C", str(repo), *args], text=True).strip()

def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

p = argparse.ArgumentParser(description=__doc__)
p.add_argument("repo", type=Path)
p.add_argument("commit")
p.add_argument("output", type=Path)
args = p.parse_args()
repo, dest = args.repo.resolve(), args.output.resolve()
commit = git(repo, "rev-parse", "--verify", args.commit+"^{commit}")
dest.mkdir(parents=True, exist_ok=False)
tree = dest / "checkout"
subprocess.run(["git", "clone", "--shared", "--no-checkout", "--quiet", str(repo), str(tree)], check=True)
subprocess.run(["git", "-C", str(tree), "-c", "advice.detachedHead=false", "checkout", "--quiet", "--detach", commit], check=True)
if git(tree, "rev-parse", "HEAD") != commit or git(tree, "status", "--porcelain"):
    raise RuntimeError("Failed to isolate clean candidate")
tmp = dest / "tmp"
tmp.mkdir()
lean = Path("/home/augustus/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean")
env = {**os.environ, "TMPDIR":str(tmp), "LEAN_BIN":str(lean), "PYTHONDONTWRITEBYTECODE":"1",
       "JAVA_TOOL_OPTIONS":"-XX:ActiveProcessorCount=2 -XX:+UseSerialGC -Xmx900m","OMP_NUM_THREADS":"1"}
started = datetime.datetime.now(datetime.timezone.utc).isoformat()
start = time.monotonic()
with (dest / "bounded.log").open("wb") as stream:
    run = subprocess.run(["/usr/bin/time", "-v", "-o", str(dest/"usage.txt"), "bash", "scripts/run_bounded_ci_java_tests.sh"],
                         env=env, cwd=tree, stdout=stream, stderr=subprocess.STDOUT)
status = git(tree, "status", "--porcelain")
receipt = {"schema":"acgn-clean-revision-bounded-ci-v1", "gitCommit":commit, "gitTree":git(tree, "rev-parse", "HEAD^{tree}"),
           "cleanBefore":True, "checkoutChangesAfter":status.splitlines(), "command":"bash scripts/run_bounded_ci_java_tests.sh",
           "exit":run.returncode, "startedUtc":started, "finishedUtc":datetime.datetime.now(datetime.timezone.utc).isoformat(),
           "elapsedSeconds":time.monotonic()-start, "lean":subprocess.check_output([str(lean), "--version"],text=True).strip(),
           "javac":subprocess.check_output(["javac","-version"],text=True).strip(), "logSha256":digest(dest/"bounded.log"),
           "resourceReceiptSha256":digest(dest/"usage.txt")}
(dest/"receipt.json").write_text(json.dumps(receipt,sort_keys=True,indent=2)+"\n")
print(json.dumps(receipt),flush=True)
raise SystemExit(run.returncode)
