"""Materialize the registered original ranking inputs and measured run adapter in a fresh directory."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ORIGINAL_RUNNER = "a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02"


def sha(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(data)
    return h.hexdigest()


def verified(path, expected):
    if sha(path) != expected:
        raise ValueError(f"SHA-256 mismatch for {path}")


def build(args, root):
    frozen = root / "frozen"
    frozen.mkdir()
    original = HERE / "identities/original-runner.json"
    verified(original, ORIGINAL_RUNNER)
    identity = json.loads(original.read_bytes())
    contract = HERE / "identities/closure-contract.json"
    spec = json.loads(contract.read_bytes())
    release = spec["inputEdition"]
    paths = ("classified-data", "lib", "docs/experimental-results/historical-retention",
             "docs/experimental-results/2026-11-25/references.jsonl.gz")
    with subprocess.Popen(["git", "-C", args.repo, "archive", release, *paths], stdout=subprocess.PIPE) as archive:
        subprocess.run(["tar", "-xf", "-", "-C", frozen], stdin=archive.stdout, check=True)
        archive.stdout.close()
        if archive.wait():
            raise RuntimeError("materializing the original source and score inputs failed")
    jar = frozen / "measured.jar"
    if args.original_jar:
        verified(args.original_jar, identity["jarSha256"])
        shutil.copyfile(args.original_jar, jar)
    else:
        subprocess.run([sys.executable, "-B", HERE / "jar-assembly/reproduce_engine.py", "original", jar,
                        "--repo", args.repo], check=True)
    shutil.copyfile(contract, root / "closure-contract.json")
    shutil.copyfile(original, root / "runner-identity.json")
    audit = root / "cohort"
    shutil.copytree(HERE / "original-audit", audit)
    subprocess.run([sys.executable, "-B", audit / "build_inputs.py", "--repo", args.repo, "--frozen", frozen,
                    "--output", audit, "--producer-ast-exclusions", HERE / "ast_identical_cross_file_comparisons.csv"], check=True)
    verified(audit / "manifest.json", identity["inputManifestSha256"])
    subprocess.run([sys.executable, "-B", audit / "verify_inputs.py", "--workspace", root], check=True)
    runner = root / "runner"
    shutil.copytree(HERE / "original-runner", runner)
    classes = root / "runner-classes"
    classes.mkdir()
    subprocess.run(["javac", "--release", "17", "-encoding", "UTF-8", "-cp", f"{jar}:{frozen}/lib/*",
                    "-d", classes, runner / "ExhaustiveNativeReplay.java"], check=True)
    for path, h in identity["files"].items():
        verified(root / path, h)
    control = dict(identity["initialControl"])
    control.update(workers=args.workers, referenceCache=4)
    (root / "runner-control.json").write_text(json.dumps(control) + "\n")
    (root / "results/incidents").mkdir(parents=True)
    (root / "logs").mkdir()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="fresh directory on the experiment filesystem")
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    parser.add_argument("--original-jar", type=Path, help="already built original JAR; its exact SHA-256 is checked")
    parser.add_argument("--workers", type=int, default=1, help="initial baseline worker count")
    args = parser.parse_args()
    if args.output.exists() or not 1 <= args.workers <= len(os.sched_getaffinity(0)):
        parser.error("expected an unused output path and positive available worker count")
    args.repo = args.repo.resolve()
    with tempfile.TemporaryDirectory(dir=args.output.parent) as tmp:
        root = Path(tmp) / "materialized"
        root.mkdir()
        build(args, root)
        root.rename(args.output)
    print(f"Restored all 1,894,168 inputs at {args.output.resolve()}")


if __name__ == "__main__":
    main()
