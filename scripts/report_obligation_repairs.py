#!/usr/bin/env python3
"""Recompute the ordered Section 3 repair queue without changing claim statuses."""

import argparse
import csv
import hashlib
import json
from pathlib import Path
import os
import subprocess
import sys
import time

sys.dont_write_bytecode = True
from run_submission_container_closure import audit_assumptions, scan_proof

AUDIT = Path("docs/section3-repair-audit")
BASELINE = Path("docs/obligation-repair/baseline.json")
SOURCES = [Path("src/is/fivefivefive/CanDis") / (name + ".java") for name in (
    "Section3AssuranceTraceability", "Section3AssuranceTraceabilityTest")]
SOURCES += [Path("src/is/fivefivefive/CanDis/assurance") / (name + ".java") for name in (
    "ContractDecomposition", "ContractDecompositionTest")]
PROOFS = [Path("docs/obligation-repair") / (name + ".lean") for name in (
    "A01Admission", "ContractDecomposition")]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def parse_report(text):
    counts, diagnostics = {}, []
    for line in text.splitlines():
        if line.startswith("FAIL\t"):
            diagnostics.append(line[5:])
        elif "=" in line and not line.startswith("Section"):
            name, value = line.split("=", 1)
            if name in ("requirements", "matrixRows", "ready", "failures"):
                if name in counts or not value.isascii() or not value.isdecimal():
                    raise ValueError("invalid or duplicate assessment count")
                counts[name] = int(value)
    if set(counts) != {"requirements", "matrixRows", "ready", "failures"}:
        raise ValueError("incomplete assessment")
    if counts["failures"] != len(diagnostics) or len(set(diagnostics)) != len(diagnostics):
        raise ValueError("assessment diagnostic census mismatch")
    if not 0 <= counts["ready"] <= counts["requirements"]:
        raise ValueError("invalid readiness count")
    return counts, diagnostics


def matrix(root):
    with (root / AUDIT / "requirements-traceability.tsv").open(encoding="utf-8", newline="") as stream:
        return {row["requirement_id"]: row for row in csv.DictReader(stream, delimiter="\t")}


def initialize(root, report_file, checker_source):
    target = root / BASELINE
    if target.exists():
        raise ValueError("the original diagnostic baseline is immutable")
    counts, diagnostics = parse_report(report_file.read_text(encoding="utf-8"))
    rows = matrix(root)
    if counts != {"requirements": 191, "matrixRows": 191, "ready": 87, "failures": 132}:
        raise ValueError("not the original 132-diagnostic assessment")
    entries = []
    for index, diagnostic in enumerate(diagnostics, 1):
        parent = diagnostic.split(" ", 1)[0]
        if parent not in rows:
            raise ValueError("baseline diagnostic is not a scoped requirement")
        row = rows[parent]
        entries.append({"sequence": index, "diagnostic": diagnostic, "requirementId": parent,
                        "claimSha256": row["claim_sha256"], "initialEvidence": row})
    write_json(target, {"schemaVersion": 1, "counts": counts, "diagnostics": entries,
        "assessmentSha256": sha(report_file), "checkerSourceSha256": sha(checker_source),
        "scopeSha256": sha(root / AUDIT / "assurance-scope.tsv"),
        "interpretation": "Original diagnostics only; absence in a later report is not proof closure."})


def snapshot(root):
    paths = set(root.glob("src/**/*.java")) | set(root.glob("certificate-verifier/**/*.java"))
    paths |= set((root / AUDIT / "formal").glob("*.lean"))
    paths.update(root / path for path in (
        BASELINE, AUDIT / "claim-ledger.md", AUDIT / "assurance-scope.tsv",
        AUDIT / "requirements-traceability.tsv", "scripts/report_obligation_repairs.py",
        "scripts/run_submission_container_closure.py", "scripts/check_rewrite_dispatch_parity.py",
        "scripts/test_obligation_repair_reporting.py", "lean-toolchain"))
    paths.update(root / path for path in PROOFS)
    registry = root / AUDIT / "low-level-requirements.tsv"
    if registry.exists():
        paths.add(registry)
    return {str(path.relative_to(root)): sha(path) for path in sorted(paths)}


def run(root, output):
    output.mkdir(parents=True, exist_ok=False)
    baseline = json.loads((root / BASELINE).read_text(encoding="utf-8"))
    inputs = snapshot(root)
    write_json(output / "inputs.json", inputs)
    classes = output / "classes"
    classes.mkdir()
    env = dict(os.environ, LC_ALL="C", TZ="UTC")
    for key in ("JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS", "_JAVA_OPTIONS", "CLASSPATH"):
        env.pop(key, None)
    commands = []

    def command(name, argv):
        started = time.monotonic()
        log = output / (name + ".log")
        with log.open("w") as stream:
            result = subprocess.run(argv, cwd=root, env=env, stdout=stream,
                                    stderr=subprocess.STDOUT, timeout=60)
        commands.append({"name": name, "argv": argv, "exitCode": result.returncode,
                         "seconds": time.monotonic() - started, "sha256": sha(log)})
        if result.returncode:
            raise ValueError(f"{name} failed; see {log}")
        return log

    command("reporting-tests", [sys.executable, "-B", "scripts/test_obligation_repair_reporting.py"])
    lean = command("lean-version", ["lean", "--version"]).read_text()
    if not lean.startswith("Lean (version 4.33.0,"):
        raise ValueError("the pinned Lean toolchain is required")
    command("compile", ["javac", "-J-Xmx256m", "--release", "17", "-encoding", "UTF-8",
                        "-d", str(classes), *map(str, SOURCES)])
    java = ["java", "-ea", "-Xmx256m", "-cp", str(classes)]
    report = command("assessment", java + ["is.fivefivefive.CanDis.Section3AssuranceTraceability", str(root)])
    counts, diagnostics = parse_report(report.read_text(encoding="utf-8"))
    command("regressions", java + ["is.fivefivefive.CanDis.Section3AssuranceTraceabilityTest", str(root)])
    command("decomposition-tests", java + ["is.fivefivefive.CanDis.assurance.ContractDecompositionTest"])
    for proof in PROOFS:
        count = len(scan_proof(root / proof))
        proof_object = output / (proof.stem + ".olean")
        log = command(proof.stem, ["lean", "-o", str(proof_object), str(proof)])
        audit_assumptions(log, count)
    if inputs != snapshot(root):
        raise ValueError("verification inputs changed during the status run")
    rows = matrix(root)
    states = []
    original = {entry["diagnostic"] for entry in baseline["diagnostics"]}
    for entry in baseline["diagnostics"]:
        parent = rows.get(entry["requirementId"])
        unchanged = parent is not None and parent["claim_sha256"] == entry["claimSha256"]
        states.append({"sequence": entry["sequence"], "requirementId": entry["requirementId"],
                       "diagnostic": entry["diagnostic"],
                       "state": "CLAIM_CHANGED" if not unchanged else
                           "OPEN" if entry["diagnostic"] in diagnostics else "ABSENT_REQUIRES_EVIDENCE"})
    new = [d for d in diagnostics if d not in original]
    result = {"schemaVersion": 1, "status": "INCOMPLETE" if diagnostics else "NO_DIAGNOSTICS",
              "counts": counts, "baseline": states, "newDiagnostics": new, "commands": commands,
              "inputManifestSha256": sha(output / "inputs.json"),
              "warning": "This is a diagnostic comparison, not a proof-closure decision."}
    write_json(output / "current.json", result)
    artifacts = {str(p.relative_to(output)): sha(p) for p in sorted(classes.rglob("*.class"))}
    artifacts.update({p.name: sha(p) for p in sorted(output.glob("*.olean"))})
    write_json(output / "artifacts.json", artifacts)
    lines = ["# Ordered Obligation Repair Status", "",
             f"Current diagnostics: **{counts['failures']}**. Original diagnostics: **132**.", "",
             "Absence of a diagnostic is not proof of repair; verified evidence is required.", "",
             "| Order | Requirement | Original diagnostic | Current state |",
             "| ---: | --- | --- | --- |"]
    lines += [f"| {s['sequence']} | {s['requirementId']} | {s['diagnostic']} | {s['state']} |" for s in states]
    lines += ["", "## Newly Exposed Diagnostics", ""] + ["- " + d for d in new]
    (output / "current.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps({"status": result["status"], "counts": counts, "report": str(output / "current.json")}))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--output", type=Path)
    parser.add_argument("--initialize-from", type=Path)
    parser.add_argument("--baseline-checker-source", type=Path)
    args = parser.parse_args()
    if args.initialize_from is not None and args.baseline_checker_source is not None and args.output is None:
        initialize(args.root.resolve(), args.initialize_from, args.baseline_checker_source)
    elif args.output is not None and args.initialize_from is None and args.baseline_checker_source is None:
        run(args.root.resolve(), args.output.resolve())
    else:
        parser.error("choose a fresh --output or both baseline initialization inputs")
