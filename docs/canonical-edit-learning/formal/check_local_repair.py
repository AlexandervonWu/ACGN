#!/usr/bin/env python3
"""Compile the local-repair model twice; this is not whole-artifact closure."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[3]
DOCS = ROOT / "docs/canonical-edit-learning"
MODULES = {"LocalRepair": 42, "LocalRepairChecks": 20}
ALLOWED_AXIOMS = {"propext", "Quot.sound"}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def audit_log(module, source, output):
    expected = {f"{module}.{name}" for name in re.findall(r"^theorem (\w+)", source, re.M)}
    if len(expected) != MODULES[module]:
        raise ValueError(f"Unexpected theorem inventory: {module}")
    rows = re.findall(
        r"^'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)$",
        output, re.M,
    )
    if len(rows) != len(expected) or {name for name, _ in rows} != expected:
        raise ValueError(f"Missing, duplicate or unexpected theorem evidence: {module}")
    dependencies = {}
    for name, axioms in rows:
        used = sorted(a.strip() for a in axioms.split(",") if a.strip())
        if not set(used) <= ALLOWED_AXIOMS:
            raise ValueError(f"Unexpected axiom dependency: {name}: {used}")
        dependencies[name] = used
    return dependencies


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True, help="New proof-report directory")
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    lean = shutil.which("lean")
    if lean is None:
        raise RuntimeError("Lean must be installed and available on PATH")
    inputs = [DOCS / "formal" / f"{name}.lean" for name in MODULES]
    inputs += [DOCS / "LOCAL-REPAIR-SPECIFICATION.md", DOCS / "LOCAL-REPAIR-OBLIGATIONS.md",
               DOCS / "README.md", Path(__file__).resolve()]
    hashes = {str(p.relative_to(ROOT)): digest(p) for p in inputs}
    version = subprocess.run([lean, "--version"], text=True, capture_output=True,
                             check=True, timeout=30).stdout.strip()
    report = {
        "schema": "local-repair-proof-build-v1", "status": "INCOMPLETE",
        "scope": "Lean abstract model and concrete model fixtures; runtime refinement remains open",
        "compiler": version, "lean_command": lean, "source_sha256": hashes,
        "builds": [],
    }
    try:
        for index in (1, 2):
            build = {"index": index, "modules": {}}
            report["builds"].append(build)
            with tempfile.TemporaryDirectory(prefix="acgn-local-repair-") as fresh:
                env = dict(os.environ, LEAN_PATH=fresh)
                for name in MODULES:
                    source = DOCS / "formal" / f"{name}.lean"
                    contents = source.read_text(encoding="utf-8")
                    if re.search(r"\b(?:sorry|unsafe|native_decide)\b|(?m:^\s*axiom\s)", contents):
                        raise ValueError(f"Unapproved proof construct: {source}")
                    command = [lean, "-o", str(Path(fresh) / f"{name}.olean"), str(source)]
                    result = subprocess.run(command, cwd=ROOT, env=env, text=True,
                                            capture_output=True, timeout=120)
                    log = output / f"build-{index}-{name}.log"
                    log.write_text(result.stdout + result.stderr, encoding="utf-8")
                    build["modules"][name] = {
                        "exit_code": result.returncode, "log": log.name,
                        "log_sha256": digest(log),
                    }
                    result.check_returncode()
                    dependencies = audit_log(name, contents, result.stdout)
                    build["modules"][name]["theorems"] = dependencies
            if index == 2 and build["modules"] != report["builds"][0]["modules"]:
                # Log filenames differ by build; compare theorem evidence, not paths.
                for name in MODULES:
                    a = report["builds"][0]["modules"][name]
                    b = build["modules"][name]
                    if a["theorems"] != b["theorems"] or a["log_sha256"] != b["log_sha256"]:
                        raise ValueError(f"Proof evidence changed between fresh builds: {name}")
        if hashes != {str(p.relative_to(ROOT)): digest(p) for p in inputs}:
            raise ValueError("Inputs changed during proof compilation")
        report.update(status="MODEL_CHECKS_PASSED", general_theorems=42,
                      concrete_model_checks=20, fresh_builds=2)
    except Exception as error:
        report.update(status="CHECK_FAILED", error=f"{type(error).__name__}: {error}")
        raise
    finally:
        (output / "report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"42 general theorems and 20 model fixtures compiled in two fresh builds: {output}")


if __name__ == "__main__":
    main()
