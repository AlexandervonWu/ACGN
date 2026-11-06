#!/usr/bin/env python3
"""Frozen finite RL-2/3 verification, extending (not replacing) the RL-1 gate."""

import argparse
import importlib.metadata
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import sys
import time
import hashlib
import torch
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "rl"))
from acgn_repair.transformer import verify_graph_trace
from verify_rl_repair import ROOT, PACKAGE, inputs, digest, write_json, canonical, Blocked, require


SCRIPTS = ("setup_rl_cuda.sh", "run_rl_learning.sh", "run_rl_learning_tests.sh", "verify_rl_learning.py", "run_rl_encoder_comparison.sh", "run_rl_depth_tuning.sh")


def expanded_inputs():
    entries = {f["path"]: f["sha256"] for f in inputs()["files"]}
    paths = list((ROOT / "rl").rglob("*.py")) + [ROOT / "rl/requirements-cuda.txt"]
    paths += [ROOT / "scripts" / name for name in SCRIPTS]
    for path in paths:
        entries[str(path.relative_to(ROOT))] = digest(path)
    return {"schemaVersion": 1, "files": [{"path": p, "sha256": h} for p, h in sorted(entries.items())]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    output = args.output.resolve()
    if output.exists() or output == ROOT or ROOT in output.parents:
        parser.error("Use a new output directory outside the repository")
    output.mkdir(parents=True)
    started = time.monotonic()
    claims = json.loads((PACKAGE / "learning-claims.json").read_text())
    application = json.loads((PACKAGE / "application-claims.json").read_text())
    graph = json.loads((PACKAGE / "encoder-claims.json").read_text())
    tuning = json.loads((PACKAGE / "tuning-claims.json").read_text())
    capacity = json.loads((PACKAGE / "capacity-claims.json").read_text())
    resources = json.loads((PACKAGE / "resource-claims.json").read_text())
    transformer = json.loads((PACKAGE / "transformer-claims.json").read_text())
    corpus = json.loads((PACKAGE / "corpus-claims.json").read_text())
    config = claims["configuration"]
    manifest = expanded_inputs()
    root_hash = hashlib.sha256(canonical(manifest)).hexdigest()
    closure_id = claims["closureId"] + "-" + root_hash
    write_json(output / "input-manifest.json", manifest)
    verifier_hash = digest(Path(__file__).resolve())
    registry = {c["verifier"]: {"implementation": "scripts/verify_rl_learning.py", "hash": verifier_hash,
                                "claim": c["id"], "passPredicate": c["pass"],
                                "exitCodes": {"0": "PASS", "1": "BLOCK", "2": "INFRASTRUCTURE_FAILURE"}}
                for c in claims["claims"]}
    write_json(output / "verifier-registry.json", registry)
    environment = {"python": sys.version, "pythonHash": digest(Path(sys.executable).resolve()),
                   "os": platform.platform(), "torch": str(torch.__version__), "cuda": torch.version.cuda,
                   "gpu": torch.cuda.get_device_name(0) if torch.cuda.is_available() else None,
                   "dependencies": {d.metadata["Name"]: d.version for d in importlib.metadata.distributions()}}
    commands, builds, errors, passed = [], [], [], []
    active = "RLL-C01"
    status = "BLOCKED"

    def run(command, log, env=None):
        print(f"Checking {log.relative_to(output)}", flush=True)
        with log.open("w", encoding="utf-8") as stream:
            try:
                result = subprocess.run([str(x) for x in command], cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT,
                                        timeout=config["timeoutSeconds"], env=env)
            except subprocess.TimeoutExpired:
                raise Blocked("VERIFIER_TIMEOUT: " + log.name) from None
        commands.append({"log": str(log.relative_to(output)), "exitCode": result.returncode})
        require(result.returncode == 0, f"VERIFIER_FAILURE: {log.name} exit={result.returncode}")
        return log.read_text(encoding="utf-8")

    try:
        require(torch.cuda.is_available(), "CUDA_UNAVAILABLE")
        for line in (ROOT / "rl/requirements-cuda.txt").read_text().splitlines():
            if "==" in line:
                name, version = line.split("==")
                require(importlib.metadata.version(name) == version, "DEPENDENCY_PIN_MISMATCH: " + name)
        proof = PACKAGE / "formal/FeedbackLearning.lean"
        text = proof.read_text()
        inventory = re.findall(r"^theorem\s+(\w+)\b", text, re.MULTILINE)
        require(inventory == claims["theorems"], "PROOF_INVENTORY_MISMATCH")
        require(not re.search(r"\b(sorry|axiom|unsafe|admit|native_decide)\b", text), "PROOF_PLACEHOLDER")
        run(["lean", "-o", output / "FeedbackLearning.olean", proof], output / "proof-first.log")
        active = "RLL-C07"
        application_source = (PACKAGE / "formal/ApplicationCore.lean").read_text()
        application_inventory = re.findall(r"^theorem\s+(\w+)\b", application_source, re.MULTILINE)
        require(application_inventory == application["theorems"], "APPLICATION_PROOF_INVENTORY")
        require(application["wholeApplicationRefinement"] == "BLOCKED", "UNSUPPORTED_REFINEMENT_CLAIM")
        for name in application["runtimeFiles"]:
            require(not re.search(r"\b(sorry|axiom|unsafe|native_decide)\b", (PACKAGE / "formal" / name).read_text()),
                    "APPLICATION_PROOF_PLACEHOLDER")
        run(["lean", "-o", output / "ApplicationCore.olean", PACKAGE / "formal/ApplicationCore.lean"],
            output / "application-proof-first.log")
        active = "RLL-C08"
        graph_proof = PACKAGE / "formal/GraphEncoders.lean"
        graph_inventory = re.findall(r"^theorem\s+(\w+)\b", graph_proof.read_text(), re.MULTILINE)
        require(graph_inventory == graph["theorems"], "GRAPH_PROOF_INVENTORY")
        require(not re.search(r"\b(sorry|axiom|unsafe|native_decide)\b", graph_proof.read_text()), "GRAPH_PROOF_PLACEHOLDER")
        run(["lean", "-o", output / "GraphEncoders.olean", graph_proof], output / "graph-proof-first.log")
        active = "RLL-C09"
        tuning_proof = PACKAGE / "formal/TuningProtocol.lean"
        tuning_inventory = re.findall(r"^theorem\s+(\w+)\b", tuning_proof.read_text(), re.MULTILINE)
        require(tuning_inventory == tuning["theorems"], "TUNING_PROOF_INVENTORY")
        require(not re.search(r"\b(sorry|axiom|unsafe|native_decide)\b", tuning_proof.read_text()), "TUNING_PROOF_PLACEHOLDER")
        run(["lean", "-o", output / "TuningProtocol.olean", tuning_proof], output / "tuning-proof-first.log")
        active = "RLL-C10"
        capacity_proof = PACKAGE / "formal/PolicyCapacity.lean"
        capacity_inventory = re.findall(r"^theorem\s+(\w+)\b", capacity_proof.read_text(), re.MULTILINE)
        require(capacity_inventory == capacity["theorems"], "CAPACITY_PROOF_INVENTORY")
        require(not re.search(r"\b(sorry|axiom|unsafe|native_decide)\b", capacity_proof.read_text()), "CAPACITY_PROOF_PLACEHOLDER")
        run(["lean", "-o", output / "PolicyCapacity.olean", capacity_proof], output / "capacity-proof-first.log")
        active = "RLL-C11"
        resource_proof = PACKAGE / "formal/ResourceBudget.lean"
        resource_inventory = re.findall(r"^theorem\s+(\w+)\b", resource_proof.read_text(), re.MULTILINE)
        require(resource_inventory == resources["theorems"], "RESOURCE_PROOF_INVENTORY")
        require(not re.search(r"\b(sorry|axiom|unsafe|native_decide)\b", resource_proof.read_text()), "RESOURCE_PROOF_PLACEHOLDER")
        run(["lean", "-o", output / "ResourceBudget.olean", resource_proof], output / "resource-proof-first.log")
        active = "RLL-C12"
        transformer_proof = PACKAGE / "formal/EGraph2Graph.lean"
        transformer_inventory = re.findall(r"^theorem\s+(\w+)\b", transformer_proof.read_text(), re.MULTILINE)
        require(transformer_inventory == transformer["theorems"], "TRANSFORMER_PROOF_INVENTORY")
        for name in transformer["runtimeFiles"]:
            source = PACKAGE / "formal" / name
            require(not re.search(r"\b(sorry|axiom|unsafe|native_decide)\b", source.read_text()), "TRANSFORMER_PROOF_PLACEHOLDER")
            run(["lean", "-o", output / Path(name).with_suffix(".olean"), source],
                output / (Path(name).stem + "-first.log"), {**os.environ, "LEAN_PATH": str(output)})
        active = "RLL-C13"
        corpus_proof = PACKAGE / "formal" / corpus["runtimeFile"]
        corpus_inventory = re.findall(r"^theorem\s+(\w+)\b", corpus_proof.read_text(), re.MULTILINE)
        require(corpus_inventory == corpus["theorems"], "CORPUS_PROOF_INVENTORY")
        require(not re.search(r"\b(sorry|axiom|unsafe|native_decide)\b", corpus_proof.read_text()), "CORPUS_PROOF_PLACEHOLDER")
        run(["lean", "-o", output / "CorpusProtocol.olean", corpus_proof], output / "corpus-proof-first.log")
        active = "RLL-C06"
        run([sys.executable, ROOT / "scripts/verify_rl_repair.py", output / "base"], output / "base-gate.log")
        base = json.loads((output / "base/report.json").read_text())
        require(base["status"] == "VERIFIED" and base["builds"]["passed"] == 2, "BASE_GATE_FAILED")
        environment["baseToolchain"] = base["environment"]
        for index in (1, 2):
            build = output / f"learning-{index}"
            build.mkdir()
            classes = output / f"base/build-{index}/classes"
            active = "RLL-C13"
            run(["lean", "-o", build / "CorpusProtocol.olean", corpus_proof], build / "corpus-proof.log")
            active = "RLL-C12"
            for name in transformer["runtimeFiles"]:
                run(["lean", "-o", build / Path(name).with_suffix(".olean"), PACKAGE / "formal" / name],
                    build / (Path(name).stem + ".log"), {**os.environ, "LEAN_PATH": str(build)})
            active = "RLL-C11"
            run(["lean", "-o", build / "ResourceBudget.olean", resource_proof], build / "resource-proof.log")
            active = "RLL-C10"
            run(["lean", "-o", build / "PolicyCapacity.olean", capacity_proof], build / "capacity-proof.log")
            active = "RLL-C09"
            run(["lean", "-o", build / "TuningProtocol.olean", tuning_proof], build / "tuning-proof.log")
            active = "RLL-C08"
            run(["lean", "-o", build / "GraphEncoders.olean", graph_proof], build / "graph-proof.log")
            active = "RLL-C01"
            run(["lean", "-o", build / "FeedbackLearning.olean", proof], build / "proof.log")
            lean = run(["lean", "--run", proof], build / "lean-matrix.log")
            active = "RLL-C07"
            proof_env = {**os.environ, "LEAN_PATH": str(build)}
            for name in application["runtimeFiles"]:
                run(["lean", "-o", build / Path(name).with_suffix(".olean"), PACKAGE / "formal" / name],
                    build / (Path(name).stem + ".log"), proof_env)
            active = "RLL-C03"
            java = ["java", "-ea", "-Xmx2g", "-cp", str(classes) + os.pathsep + str(ROOT / "lib/*"),
                    "is.fivefivefive.ACGN.repair.RepairLearningTest"]
            matrix = run(java + ["--matrix"], build / "java-matrix.log")
            require(matrix == lean and len(matrix.splitlines()) == config["matrixRows"], "MATRIX_MISMATCH")
            active = "RLL-C02"
            logged = run(java, build / "java-tests.log")
            counts = re.findall(r"^RESULT,RepairLearningTest,(\d+)$", logged, re.MULTILINE)
            require(len(counts) == 1 and int(counts[0]) >= config["minimumJavaChecks"], "JAVA_FIXTURES_FAILED")
            active = "RLL-C04"
            env = {**os.environ, "PYTHONPATH": str(ROOT / "rl"), "PYTHONDONTWRITEBYTECODE": "1",
                   "ACGN_RL_CLASSES": str(classes), "ACGN_RL_DEVICE": "cuda", "CUBLAS_WORKSPACE_CONFIG": ":4096:8"}
            tests = run([sys.executable, "-m", "unittest", "discover", "-s", ROOT / "rl/tests", "-v"],
                        build / "python-tests.log", env)
            match = re.search(r"Ran (\d+) tests", tests)
            require(match is not None and int(match[1]) >= config["pythonTests"]
                    and "\nOK\n" in tests and "skipped=" not in tests, "PYTHON_TEST_COVERAGE")
            active = "RLL-C05"
            pilot = build / "pilot"
            run([sys.executable, "-m", "acgn_repair.experiment", "--manifest", PACKAGE / "fixtures/pilot.json",
                 "--output", pilot, "--classes", classes, "--device", "cuda", "--episodes",
                 config["pilotTrainEpisodes"], "--eval-episodes", config["pilotEvaluationEpisodes"],
                 "--horizon", config["horizon"], "--capacity", config["capacity"], "--seed", config["seed"],
                 "--task-chunk", 4,
                 "--cuda-memory-gib", resources["cudaBudgetGiB"]],
                build / "pilot.log", env)
            summary = json.loads((pilot / "summary.json").read_text())
            require(summary["updates"] == 20 and "symbols.weight" in summary["changedParameters"]
                    and summary["inputsUnchanged"] and not any(g["aborted"] for g in summary["groups"].values()), "PILOT_FAILED")
            active = "RLL-C07"
            pilot_manifest = json.loads((pilot / "run-manifest.json").read_text())
            require(pilot_manifest["cudaMemoryLimit"]["limitBytes"] == resources["cudaBudgetGiB"] * 1024**3
                    and summary["peakCudaReservedBytes"] <= pilot_manifest["cudaMemoryLimit"]["limitBytes"],
                    "PILOT_CUDA_BUDGET")
            episodes = json.loads((pilot / "episodes.json").read_text())
            active = "RLL-C13"
            schedule = json.loads((pilot / "schedule-admission.json").read_text())
            require(schedule["reply"]["accepted"] and schedule["reply"]["request"] == schedule["request"]
                    and schedule["proofHash"] == digest(corpus_proof)
                    and schedule["request"]["jobs"] == [e["episode"] for e in episodes if e["mode"] == "train"],
                    "CORPUS_SCHEDULE_ADMISSION")
            updates = [e["update"] for e in episodes if "update" in e]
            require(len(updates) == 20 and all(u.get("proofContract") == pilot_manifest["applicationGate"]["contractHash"]
                    and len(u.get("checkedRequest", "")) == 64 for u in updates), "MISSING_APPLICATION_ADMISSION")
            active = "RLL-C08"
            graph_pilots = {}
            for encoder in graph["additionalPilotEncoders"]:
                destination = build / ("encoder-" + encoder)
                run([sys.executable, "-m", "acgn_repair.experiment", "--manifest", PACKAGE / "fixtures/pilot.json",
                     "--output", destination, "--classes", classes, "--device", "cuda", "--encoder", encoder,
                     "--episodes", graph["pilotTrainEpisodes"], "--eval-episodes", graph["pilotEvaluationEpisodes"],
                     "--horizon", config["horizon"], "--capacity", config["capacity"], "--seed", config["seed"]],
                    build / ("encoder-" + encoder + ".log"), env)
                result = json.loads((destination / "summary.json").read_text())
                trials = json.loads((destination / "episodes.json").read_text())
                require(result["updates"] == graph["pilotTrainEpisodes"] and result["inputsUnchanged"]
                        and result["architecture"]["encoder"] == encoder
                        and any(k.startswith("encoder.") for k in result["changedParameters"])
                        and not any(g["aborted"] for g in result["groups"].values()), "GRAPH_PILOT_FAILED")
                admissions = [e["update"] for e in trials if "update" in e]
                require(len(admissions) == graph["pilotTrainEpisodes"]
                        and all(u.get("proofContract") == pilot_manifest["applicationGate"]["contractHash"]
                                and len(u.get("checkedRequest", "")) == 64 for u in admissions), "GRAPH_ADMISSION_MISSING")
                if encoder == "egraph_transformer":
                    active = "RLL-C12"
                    traces = [json.loads(line) for line in (destination / "transitions.jsonl").read_text().splitlines()]
                    model_steps = verify_graph_trace(traces, result["architecture"])
                    require(model_steps == result["graphAdmissions"] > 0
                            and model_steps == sum(t["steps"] for t in trials if t["mode"] != "random")
                            and 0 < result["graphGateExecutions"] <= result["graphAdmissions"],
                            "TRANSFORMER_ADMISSION_MISSING")
                graph_pilots[encoder] = {"summary": {k: v for k, v in result.items() if k not in graph["nondeterministicSummaryFields"]},
                                         "episodes": trials}
            record = {"proofHash": digest(build / "FeedbackLearning.olean"), "theorems": inventory,
                      "corpusProofHash": digest(build / "CorpusProtocol.olean"), "corpusTheorems": corpus_inventory,
                      "corpusScheduleAdmission": schedule,
                      "transformerProofHashes": {name: digest(build / Path(name).with_suffix(".olean")) for name in transformer["runtimeFiles"]},
                      "transformerTheorems": transformer_inventory,
                      "resourceProofHash": digest(build / "ResourceBudget.olean"), "resourceTheorems": resource_inventory,
                      "capacityProofHash": digest(build / "PolicyCapacity.olean"), "capacityTheorems": capacity_inventory,
                      "tuningProofHash": digest(build / "TuningProtocol.olean"), "tuningTheorems": tuning_inventory,
                      "graphProofHash": digest(build / "GraphEncoders.olean"), "graphTheorems": graph_inventory,
                      "graphPilots": graph_pilots,
                      "applicationProofHashes": {name: digest(build / Path(name).with_suffix(".olean"))
                                                 for name in application["runtimeFiles"]},
                      "applicationTheorems": application_inventory,
                      "matrixHash": hashlib.sha256(matrix.encode()).hexdigest(), "javaChecks": int(counts[0]),
                      "pythonTests": int(match[1]), "pilot": {k: v for k, v in summary.items() if k not in graph["nondeterministicSummaryFields"]},
                      "episodes": episodes, "inputRootHash": root_hash}
            write_json(build / "deterministic-output.json", record)
            builds.append(record)
        require(builds[0] == builds[1], "NONDETERMINISM: proof/matrix/tests/pilot episodes")
        for subdirectory in ["pilot"] + ["encoder-" + name for name in graph["additionalPilotEncoders"]]:
            checkpoints = [torch.load(output / f"learning-{i}" / subdirectory / "policy.pt", map_location="cpu", weights_only=True) for i in (1, 2)]
            require(checkpoints[0]["state"].keys() == checkpoints[1]["state"].keys()
                    and all(torch.equal(v, checkpoints[1]["state"][k]) for k, v in checkpoints[0]["state"].items()),
                    "NONDETERMINISM: learned tensors " + subdirectory)
        active = "RLL-C06"
        require(expanded_inputs() == manifest, "INPUT_MUTATION")
        passed = [c["id"] for c in claims["claims"]]
        status = "VERIFIED"
    except Blocked as failure:
        errors.append({"claim": active, "code": str(failure)})
    except Exception as failure:
        status = "INFRASTRUCTURE_FAILURE"
        errors.append({"claim": active, "code": "INFRASTRUCTURE_ERROR", "detail": repr(failure)})
    evidence = output / "evidence"
    evidence.mkdir()
    provenance = []
    for claim in claims["claims"]:
        path = evidence / (claim["id"] + ".json")
        write_json(path, {"closureId": closure_id, "claimId": claim["id"], "inputRootHash": root_hash,
                          "verifierId": claim["verifier"], "verifierHash": verifier_hash, "environment": environment,
                          "status": "PASS" if claim["id"] in passed else "BLOCK", "commands": commands,
                          "rawResult": {"builds": len(builds), "errors": errors},
                          "exitCode": 0 if claim["id"] in passed else 2 if status == "INFRASTRUCTURE_FAILURE" else 1})
        provenance.append({"publicClaim": claim["statement"], "claimId": claim["id"],
                           "document": "docs/rl-repair/RL2-RL3.md", "inputRootHash": root_hash,
                           "evidence": str(path.relative_to(output)), "evidenceHash": digest(path),
                           "verifierId": claim["verifier"], "verifierHash": verifier_hash, "trust": claims["trusted"]})
    write_json(output / "provenance.json", provenance)
    report = {"schemaVersion": 1, "closureId": closure_id, "status": status, "inputRootHash": root_hash,
              "claims": {"total": len(claims["claims"]), "passed": len(passed), "unresolved": len(claims["claims"]) - len(passed)},
              "wholeApplicationRefinement": application["wholeApplicationRefinement"],
              "openApplicationBridges": application["openBridges"],
              "builds": {"required": 2, "passed": len(builds)}, "environment": environment,
              "determinism": "PASS" if status == "VERIFIED" else "UNRESOLVED", "provenance": provenance,
              "results": [{"theorems": len(b["theorems"]), "applicationTheorems": len(b["applicationTheorems"]),
                           "graphTheorems": len(b["graphTheorems"]), "graphPilots": {k: v["summary"] for k, v in b["graphPilots"].items()},
                           "javaChecks": b["javaChecks"],
                           "pythonTests": b["pythonTests"], "pilot": b["pilot"]} for b in builds],
              "elapsedSeconds": time.monotonic() - started, "blockingReasons": errors,
              "trusted": claims["trusted"], "excluded": claims["excluded"],
              "interpretation": "Finite registered obligations only, not full refinement or proof of learning effectiveness.",
              "evidenceHashes": {str(p.relative_to(output)): digest(p) for p in sorted(output.rglob("*"))
                                 if p.is_file() and p.suffix in (".json", ".log", ".pt", ".olean")}}
    write_json(output / "report.json", report)
    lines = ["# RL-2/RL-3 Verification", "", f"Status: **{status}**", "", f"Input root: `{root_hash}`", "",
             report["interpretation"], "", f"Claims: {len(passed)}/{len(claims['claims'])}; clean builds: {len(builds)}/2.",
             "", "Whole-application refinement: **BLOCKED**; see APPLICATION-ASSURANCE.md for the open bridges."]
    for i, build in enumerate(builds):
        lines += ["", f"## Build {i + 1}", f"- Additional Lean theorems: {len(build['theorems'])}",
                  f"- Application-contract Lean theorems: {len(build['applicationTheorems'])}",
                  f"- Graph-encoder Lean theorems: {len(build['graphTheorems'])}; schedule matrix rows: {graph['matrixRows']}",
                  f"- Additional Java checks: {build['javaChecks']}; Python/CUDA tests: {build['pythonTests']}",
                  f"- Feedback/reward matrix rows: {config['matrixRows']}",
                  f"- Actual policy updates: {build['pilot']['updates']}"]
        lines.extend(f"- {mode}: {counts['solved']}/{counts['episodes']} solved; {counts['aborted']} aborted."
                     for mode, counts in build["pilot"]["groups"].items())
        lines.extend(f"- {encoder}: {data['summary']['updates']} additional proof-gated CUDA updates, zero aborts."
                     for encoder, data in build["graphPilots"].items())
    lines += ["", "## Remaining Limits"] + ["- " + x for x in claims["excluded"]]
    lines += ["", "## Errors"] + ["- " + json.dumps(e) for e in errors]
    (output / "report.md").write_text("\n".join(lines) + "\n")
    print(status + ": " + str(output / "report.json"))
    return {"VERIFIED": 0, "BLOCKED": 1, "INFRASTRUCTURE_FAILURE": 2}[status]


if __name__ == "__main__":
    sys.exit(main())
