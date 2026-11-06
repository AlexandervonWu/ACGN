#!/usr/bin/env python3
"""Finite proof/model/fixture gates, not a verifier of all Java semantics."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[1]
PACKAGE = ROOT / "docs/rl-repair"
SCRIPTS = ("run_rl_repair_tests.sh", "run_repair_explorer.sh", "verify_rl_repair.py")
TEST = "is.fivefivefive.ACGN.repair.RepairEnvironmentTest"


class Blocked(Exception):
    pass


def require(condition, message):
    if not condition:
        raise Blocked(message)


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":")).encode("utf-8")


def digest(path):
    sha = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            sha.update(block)
    return sha.hexdigest()


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def inputs():
    paths = set((ROOT / "src").rglob("*.java"))
    paths.update((ROOT / "lib").glob("*.jar"))
    paths.update(p for p in PACKAGE.rglob("*") if p.is_file())
    paths.update(ROOT / "scripts" / name for name in SCRIPTS)
    paths.add(ROOT / "docs/egraph-rl-proposal.md")
    return {"schemaVersion": 1, "files": [
        {"path": str(p.relative_to(ROOT)), "sha256": digest(p)} for p in sorted(paths)]}


def inventory(directory, suffix):
    return {str(p.relative_to(directory)): digest(p) for p in sorted(directory.rglob(suffix))}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="new output directory outside the repository")
    args = parser.parse_args()
    output = args.output.resolve()
    if output == ROOT or ROOT in output.parents or output.exists():
        parser.error("use a new output directory outside the repository")
    output.mkdir(parents=True)
    started = time.monotonic()
    claims = json.loads((PACKAGE / "claims.json").read_text(encoding="utf-8"))
    config = claims["configuration"]
    manifest = inputs()
    root_hash = hashlib.sha256(canonical(manifest)).hexdigest()
    closure_id = claims["closureId"] + "-" + root_hash
    write_json(output / "input-manifest.json", manifest)
    tools = {}
    commands = []
    builds = []
    completed = {}
    active_claim = "RL-C01"
    state = "BLOCKED"
    errors = []
    script_hash = digest(Path(__file__).resolve())
    registry = {claim["verifier"]: {
        "implementation": "scripts/verify_rl_repair.py", "sha256": script_hash,
        "exitCodes": {"0": "PASS", "1": "BLOCK", "2": "INFRASTRUCTURE_FAILURE"},
        "claim": claim["id"], "passPredicate": claim["pass"],
    } for claim in claims["claims"]}
    write_json(output / "verifier-registry.json", registry)

    def run(command, log):
        print(f"Checking {log.relative_to(output)}", flush=True)
        with log.open("w", encoding="utf-8") as handle:
            try:
                result = subprocess.run([str(a) for a in command], cwd=ROOT, stdout=handle,
                                        stderr=subprocess.STDOUT, timeout=config["timeoutSeconds"],
                                        env={**os.environ, "LC_ALL": "C.UTF-8"})
            except subprocess.TimeoutExpired:
                commands.append({"log": str(log.relative_to(output)), "exitCode": "TIMEOUT"})
                raise Blocked(f"VERIFIER_TIMEOUT: {log.name}") from None
        commands.append({"log": str(log.relative_to(output)), "exitCode": result.returncode})
        require(result.returncode == 0, f"VERIFIER_FAILURE: {log.name} exit={result.returncode}")
        return log.read_text(encoding="utf-8")

    try:
        for name, version_arg in (("lean", "--version"), ("java", "-version"), ("javac", "-version")):
            path = shutil.which(name)
            if not path:
                raise FileNotFoundError(f"Required tool unavailable: {name}")
            tools[name] = {"path": path, "executableHash": digest(Path(path).resolve()),
                           "version": run([path, version_arg], output / f"{name}-version.log").strip()}
        tools["python"] = {"path": sys.executable, "version": sys.version,
                           "executableHash": digest(Path(sys.executable).resolve())}
        tools["os"] = platform.platform()
        require("4.35.0" in tools["lean"]["version"], "UNDECLARED_DEPENDENCY: Lean version")
        require(re.search(r'\b17[.\s]', tools["javac"]["version"]), "UNDECLARED_DEPENDENCY: javac version")
        require(re.search(r'version "17[.\"]', tools["java"]["version"]), "UNDECLARED_DEPENDENCY: JVM version")
        require(len(registry) == len(claims["claims"]) == 6, "Ambiguous verifier/claim registry")
        source = (PACKAGE / "formal/RepairKernel.lean").read_text(encoding="utf-8")
        theorem_names = re.findall(r"^theorem\s+(\w+)\b", source, re.MULTILINE)
        require(theorem_names == claims["theorems"], "PROOF_INVENTORY_MISMATCH")
        require(not re.search(r"\b(sorry|axiom|unsafe|admit|native_decide)\b", source), "PROOF_PLACEHOLDER")
        for index in range(config["requiredCleanBuilds"]):
            build = output / f"build-{index + 1}"
            classes = build / "classes"
            classes.mkdir(parents=True)
            cp = str(classes) + os.pathsep + str(ROOT / "lib/*")
            java = ["java", "-ea", f'-Xmx{config["javaHeap"]}', "-cp", cp]
            active_claim = "RL-C01"
            run(["lean", "-o", build / "RepairKernel.olean", PACKAGE / "formal/RepairKernel.lean"],
                build / "proof.log")
            lean_rows = run(["lean", "--run", PACKAGE / "formal/RepairKernel.lean"], build / "lean-control.log")
            sources = build / "sources.args"
            sources.write_text("\n".join(json.dumps(str(p)) for p in sorted((ROOT / "src").rglob("*.java")))
                               + "\n", encoding="utf-8")
            active_claim = "RL-C03"
            run(["javac", "--release", "17", "-encoding", "UTF-8", "-cp", ROOT / "lib/*",
                 "-d", classes, "@" + str(sources)], build / "compile.log")
            active_claim = "RL-C02"
            java_rows = run(java + [TEST, "--control"], build / "java-control.log")
            require(lean_rows == java_rows, "MATRIX_MISMATCH")
            rows = lean_rows.splitlines()
            require(len(rows) == len(set(rows)) == config["controlRows"]
                    and all(r.startswith("CONTROL,") for r in rows), "MATRIX_COVERAGE")
            active_claim = "RL-C03"
            tested = run(java + [TEST], build / "source-tests.log")
            results = re.findall(r"^RESULT,RepairEnvironmentTest,(\d+),([a-f0-9]{64})$", tested, re.MULTILINE)
            require(len(results) == 1 and int(results[0][0]) >= config["minimumSourceChecks"], "SOURCE_RESULT_MISSING")
            run(java + ["is.fivefivefive.ACGN.repair.RepairExplorer", PACKAGE / "fixtures/basic.als",
                        "candidate", "0", "oracle", "BEAM", "42", str(config["cliAttempts"]),
                        build / "candidates.json"], build / "explorer.log")
            candidates = json.loads((build / "candidates.json").read_text(encoding="utf-8"))
            require(candidates["attempts"] == config["cliAttempts"] and candidates["aborted"] == ""
                    and candidates["semanticValidation"] == "NOT_RUN"
                    and candidates["certificateReplay"] == "NOT_REQUESTED"
                    and len(candidates["candidates"]) > 0, "CLI_CONTRACT_MISMATCH")
            require(all(c["appliedEdits"] >= 1 and c["distanceFromOriginal"] >= 0
                        for c in candidates["candidates"]), "CLI_CANDIDATE_MISMATCH")
            active_claim = "RL-C04"
            regressions = {}
            for test in claims["regressions"]:
                name = test.rsplit(".", 1)[1]
                logged = run(java + [test], build / f"{name}.log")
                matches = re.findall(re.escape(name) + r" passed: (\d+) checks", logged)
                require(len(matches) == 1 and int(matches[0]) > 0, "REGRESSION_RESULT_MISSING: " + name)
                regressions[name] = int(matches[0])
            record = {"classHashes": inventory(classes, "*.class"),
                      "leanObjectHash": digest(build / "RepairKernel.olean"),
                      "theorems": theorem_names, "controlHash": hashlib.sha256(java_rows.encode()).hexdigest(),
                      "sourceResult": results[0], "candidates": candidates, "regressions": regressions,
                      "inputRootHash": root_hash}
            write_json(build / "deterministic-output.json", record)
            builds.append(record)
        for claim in claims["claims"][:4]:
            completed[claim["id"]] = "PASS"
        active_claim = "RL-C05"
        require(len(builds) == 2 and builds[0] == builds[1], "NONDETERMINISM")
        completed[active_claim] = "PASS"
        active_claim = "RL-C06"
        require(inputs() == manifest, "INPUT_MUTATION")
        completed[active_claim] = "PASS"
        state = "VERIFIED"
    except Blocked as failure:
        errors.append({"claim": active_claim, "code": str(failure)})
    except (OSError, subprocess.SubprocessError) as failure:
        state = "INFRASTRUCTURE_FAILURE"
        errors.append({"claim": active_claim, "code": "INFRASTRUCTURE_ERROR", "detail": str(failure)})
    except Exception as failure:
        state = "INFRASTRUCTURE_FAILURE"
        errors.append({"claim": active_claim, "code": "VERIFIER_CRASH", "detail": repr(failure)})

    evidence_dir = output / "evidence"
    evidence_dir.mkdir()
    environment = {"tools": tools, "configuration": config}
    provenance = []
    for claim in claims["claims"]:
        status = completed.get(claim["id"], "BLOCK" if any(e["claim"] == claim["id"] for e in errors) else "NOT_RUN")
        evidence = {"closureId": closure_id, "claimId": claim["id"], "inputRootHash": root_hash,
                    "verifierId": claim["verifier"], "verifierHash": script_hash,
                    "environment": environment, "status": status,
                    "exitCode": 0 if status == "PASS" else (2 if state == "INFRASTRUCTURE_FAILURE" else 1),
                    "rawResult": {"buildsCompleted": len(builds), "commands": commands, "errors": errors}}
        path = evidence_dir / (claim["id"] + ".json")
        write_json(path, evidence)
        provenance.append({"publicClaim": claim["statement"], "document": "docs/rl-repair/README.md",
                           "claimId": claim["id"], "evidence": str(path.relative_to(output)),
                           "evidenceHash": digest(path), "verifier": claim["verifier"],
                           "inputRootHash": root_hash, "trust": claims["trust"]})
    write_json(output / "provenance.json", provenance)
    report = {"schemaVersion": 1, "closureId": closure_id, "status": state,
              "inputRootHash": root_hash, "elapsedSeconds": round(time.monotonic() - started, 3),
              "claims": {"total": len(claims["claims"]), "passed": len(completed),
                         "unresolved": len(claims["claims"]) - len(completed)},
              "builds": {"required": 2, "passed": len(builds)}, "environment": environment,
              "determinism": completed.get("RL-C05", "NOT_RUN"),
              "provenance": completed.get("RL-C06", "NOT_RUN"),
              "correspondence": {"kind": "bounded control matrix", "requiredRows": 128,
                                 "passed": completed.get("RL-C02", "NOT_RUN")},
              "results": [{"sourceResult": b["sourceResult"], "regressions": b["regressions"],
                           "theoremCount": len(b["theorems"]), "compiledClasses": len(b["classHashes"])}
                          for b in builds],
              "blockingReasons": errors, "trusted": claims["trust"], "excluded": claims["excluded"],
              "interpretation": "Finite frozen claims under the declared TCB, not full Java-Lean refinement.",
              "evidenceHashes": inventory(output, "*.log") | inventory(output, "*.json")}
    write_json(output / "report.json", report)
    lines = ["# RL Repair Verification", "", f"Status: **{state}**", "",
             f"Input root: `{root_hash}`", f"\nPassed claims: {len(completed)}/{len(claims['claims'])}",
             f"Clean builds: {len(builds)}/2", "", report["interpretation"], "", "## Results"]
    lines.extend(f"- Build {i + 1}: {b['sourceResult'][0]} source checks; {len(b['theorems'])} Lean theorems; "
                 + ", ".join(f"{name}: {count}" for name, count in b["regressions"].items())
                 for i, b in enumerate(builds))
    lines += ["", "## Exclusions"] + ["- " + x for x in claims["excluded"]]
    lines += ["", "## Errors"] + ["- " + json.dumps(e) for e in errors]
    (output / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"{state}: {output / 'report.json'}")
    return {"VERIFIED": 0, "BLOCKED": 1, "INFRASTRUCTURE_FAILURE": 2}[state]


if __name__ == "__main__":
    sys.exit(main())
