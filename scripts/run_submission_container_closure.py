#!/usr/bin/env python3
"""Execute the frozen, finite submission container-replay obligations offline."""

from __future__ import annotations

import argparse
import gzip
import hashlib
import itertools
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
from check_rewrite_dispatch_parity import strip_lean_comments

CONFIG = Path("docs/submission-closure/closure-config.json")
FORMAL = Path("docs/section3-repair-audit/formal")
PROBE = "is.fivefivefive.CanDis.theory.ContainerReplayProbe"
THEOREMS = [
    "valid_parts", "sameSupport_iff", "sequence_preserves_order",
    "bag_preserves_multiplicity", "set_preserves_support", "set_has_no_duplicates",
    "fibers_partition_input", "set_preserves_any_denotation", "set_preserves_all_denotation",
    "fibers_have_one_entry_per_output", "fiber_members_preserve_identity", "nonset_fibers_are_singletons",
]
BOOLEAN_THEOREMS = {
    "boolean_and_empty_collapses_by_smart_constructor", "boolean_or_empty_collapses_by_smart_constructor",
    "boolean_and_singleton_collapses_by_smart_constructor", "boolean_or_singleton_collapses_by_smart_constructor",
    "boolean_smart_constructor_preserves_denotation", "boolean_smart_constructor_returns_operand_iff_singleton",
    "boolean_smart_constructor_stores_iff", "boolean_stored_policy_is_nonempty_and_has_no_unit",
    "boolean_smart_constructor_stored_carrier_invariant", "boolean_construction_never_mints_unit_evidence",
    "boolean_certified_carrier_rejects_empty", "boolean_certified_carrier_collapses_singleton",
    "boolean_certified_carrier_agrees_with_smart_constructor",
}
NEGATIVES = [
    ("sequence-order", "SEQ", [0, 1], [1, 0], [[1], [0]]),
    ("sequence-duplicate-loss", "SEQ", [0, 0], [0], [[0, 1]]),
    ("bag-duplicate-loss", "BAG", [0, 0, 1], [0, 1], [[0, 1], [2]]),
    ("bag-duplicate-invention", "BAG", [0, 1], [0, 0, 1], [[0], [0], [1]]),
    ("set-distinct-loss", "SET", [0, 1], [0], [[0, 1]]),
    ("set-new-member", "SET", [0], [1], [[0]]),
    ("set-duplicate-output", "SET", [0, 0], [0, 0], [[0], [1]]),
    ("fiber-overlap", "SET", [0, 0], [0], [[0, 0]]),
    ("fiber-uncovered", "SET", [0, 0], [0], [[0]]),
    ("fiber-out-of-range", "SET", [0], [0], [[1]]),
    ("fiber-wrong-identity", "BAG", [0, 1], [0, 1], [[1], [0]]),
    ("fiber-empty", "SET", [0], [0], [[]]),
    ("fiber-extra", "SET", [0], [0], [[0], []]),
    ("sequence-fiber-swap", "SEQ", [0, 0], [0, 0], [[1], [0]]),
]


class Blocked(RuntimeError):
    pass


def digest(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def canonical_bytes(value: object) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n").encode()


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, sort_keys=True, indent=2) + "\n", encoding="utf-8")


def unique_object(pairs: list[tuple[str, object]]) -> dict:
    result = {}
    for key, value in pairs:
        if key in result:
            raise Blocked(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def check_census(payload: dict, config: dict) -> list[dict]:
    bounds = config["bounds"]
    if (type(payload.get("schemaVersion")) is not int or payload["schemaVersion"] != 1
            or payload.get("alphabetSize") != bounds["alphabetSize"]
            or payload.get("maxLength") != bounds["maxLength"]):
        raise Blocked("probe schema/bounds differ from frozen claim scope")
    expected = {
        (carrier, kind, word)
        for carrier in bounds["carriers"] for kind in bounds["kinds"]
        for length in range(bounds["maxLength"] + 1)
        for word in itertools.product(range(bounds["alphabetSize"]), repeat=length)
    }
    rows = payload.get("rows")
    if not isinstance(rows, list):
        raise Blocked("trace rows must be a list")
    seen = set()
    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            raise Blocked("each trace must be an object")
        if type(row.get("rowId")) is not int or row["rowId"] != index:
            raise Blocked("trace row identity/order changed")
        atoms = row.get("atoms")
        if (not isinstance(atoms, list) or len(atoms) != bounds["alphabetSize"]
                or any(not isinstance(atom, dict) or type(atom.get("id")) is not int
                       or atom["id"] != i for i, atom in enumerate(atoms))):
            raise Blocked("invalid typed atom table")
        for encoding in ("portEncoding", "slotEncoding"):
            values = [atom.get(encoding) for atom in atoms]
            if (any(not isinstance(value, str) or not value for value in values)
                    or len(set(values)) != len(values)):
                raise Blocked("noninjective typed atom encoding")
        for field in ("input", "output"):
            values = row.get(field)
            if (not isinstance(values, list) or len(values) > bounds["maxLength"]
                    or any(type(x) is not int or not 0 <= x < bounds["alphabetSize"]
                           for x in values)):
                raise Blocked(f"invalid {field} identities")
        fibers = row.get("fibers")
        if (not isinstance(fibers, list) or len(fibers) > bounds["maxLength"]
                or any(not isinstance(fiber, list) or len(fiber) > bounds["maxLength"]
                       or any(type(i) is not int or not 0 <= i < len(row["input"])
                              for i in fiber) for fiber in fibers)):
            raise Blocked("invalid occurrence-fiber encoding")
        key = (row.get("carrier"), row.get("kind"), tuple(row["input"]))
        if key not in expected or key in seen:
            raise Blocked("duplicate or unexpected constructor input")
        seen.add(key)
    if seen != expected:
        raise Blocked(f"incomplete constructor census: {len(seen)}/{len(expected)}")
    return rows


def lean_trace(kind: str, source: list, output: list, fibers: list) -> str:
    return ("{ kind := ." + kind.lower() + ", input := " + str(source)
            + ", output := " + str(output) + ", fibers := " + str(fibers) + " }")


def render_replay(rows: list[dict]) -> str:
    lines = ["import ContainerReplay", "open ACGN.ContainerReplay",
             "set_option maxRecDepth 4096", "set_option maxHeartbeats 1000000"]
    for index, row in enumerate(rows):
        term = lean_trace(row["kind"], row["input"], row["output"], row["fibers"])
        lines.append(f"theorem observed_{index:04d} : valid {term} = true := by decide")
    for index, (_, kind, source, output, fibers) in enumerate(NEGATIVES):
        lines.append(f"theorem rejected_{index:02d} : valid "
                     + lean_trace(kind, source, output, fibers) + " = false := by decide")
    for theorem in THEOREMS:
        lines.append(f"#print axioms ACGN.ContainerReplay.{theorem}")
    for index in range(len(rows)):
        lines.append(f"#print axioms observed_{index:04d}")
    for index in range(len(NEGATIVES)):
        lines.append(f"#print axioms rejected_{index:02d}")
    return "\n".join(lines) + "\n"


def source_manifest(root: Path) -> dict:
    paths = set(root.glob("src/**/*.java")) | set(root.glob("lib/**/*.jar"))
    paths.update(root / p for p in [CONFIG, "docs/submission-closure/README.md", "lean-toolchain",
        ".github/workflows/bounded-ci.yml", "scripts/run_bounded_ci_java_tests.sh",
        "scripts/run_submission_container_closure.py",
        "scripts/test_submission_container_closure.py", "scripts/check_rewrite_dispatch_parity.py",
        FORMAL / "ContainerReplay.lean", FORMAL / "Phase2VariadicLaws.lean"])
    return {"schemaVersion": "1", "files": [
        {"path": p.relative_to(root).as_posix(), "sha256": digest(p)}
        for p in sorted(paths)
    ]}


def scan_proof(path: Path) -> list[str]:
    source = strip_lean_comments(path.read_text(encoding="utf-8"))
    forbidden = re.search(r"\b(sorry|sorryAx|admit|axiom|unsafe|native_decide|extern|partial|implemented_by)\b"
                          r"|\bLean\.ofReduceBool\b", source)
    if forbidden:
        raise Blocked(f"unregistered proof escape in {path}: {forbidden.group()}")
    return re.findall(r"(?m)^\s*(?:theorem|lemma)\s+([A-Za-z_][\w'.]*)", source)


def audit_assumptions(log: Path, expected: int) -> None:
    text = log.read_text(encoding="utf-8")
    blocks = re.findall(r"'[^']+' (?:does not depend on any axioms|depends on axioms: \[(.*?)\])",
                        text, re.DOTALL)
    if len(blocks) != expected:
        raise Blocked(f"incomplete Lean assumption inventory in {log}: {len(blocks)}/{expected}")
    allowed = {"propext", "Quot.sound", "Classical.choice"}
    for block in blocks:
        if {item.strip() for item in block.split(",") if item.strip()} - allowed:
            raise Blocked(f"undeclared Lean assumptions in {log}: {block}")


def execute(root: Path, output: Path) -> int:
    config = json.loads((root / CONFIG).read_text(encoding="utf-8"))
    output.mkdir(parents=True, exist_ok=False)
    inputs = source_manifest(root)
    input_hash = hashlib.sha256(canonical_bytes(inputs)).hexdigest()
    closure_id = config["closureFamily"] + "-" + input_hash[:16]
    write_json(output / "input-manifest.json", inputs)
    verifier_hashes = {item["path"]: item["sha256"] for item in inputs["files"]
                       if item["path"].startswith("scripts/") or item["path"].endswith(
                           ("ContainerReplay.lean", "Phase2VariadicLaws.lean", "ContainerReplayProbe.java"))}
    report = {"schemaVersion": "1", "closureId": closure_id, "inputRootHash": input_hash,
              "status": "BLOCKED", "claims": [], "builds": [], "commands": [],
              "trusted": config["trusted"], "excluded": config["excluded"], "errors": [],
              "verifierImplementationHashes": verifier_hashes,
              "permittedNondeterminism": config["permittedNondeterminism"]}
    env = dict(os.environ, LC_ALL="C", TZ="UTC", PYTHONDONTWRITEBYTECODE="1")
    # Inputs controlling compiler behavior are explicit, not inherited overrides.
    for name in ("JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS", "_JAVA_OPTIONS", "CLASSPATH", "LEAN_PATH"):
        env.pop(name, None)

    def command(label: str, args: list[str], cwd: Path, extra_env: dict | None = None) -> Path:
        log = output / (label + ".log")
        print(f"[submission-closure] {label}", flush=True)
        started = time.monotonic()
        with log.open("w", encoding="utf-8") as stream:
            result = subprocess.run(args, cwd=cwd, env=env | (extra_env or {}),
                                    stdout=stream, stderr=subprocess.STDOUT,
                                    timeout=config["commandTimeoutSeconds"], check=False)
        report["commands"].append({"label": label, "argv": args, "exitCode": result.returncode,
                                   "seconds": time.monotonic() - started,
                                   "log": log.name, "sha256": digest(log)})
        if result.returncode:
            raise Blocked(f"{label} exited {result.returncode}; see {log}")
        return log

    try:
        lean = shutil.which("lean")
        if lean is None:
            raise OSError("Lean executable unavailable")
        if config["requiredCleanBuilds"] != 2 or {c["id"] for c in config["claims"]} != {
                f"SCR-{index:02d}" for index in range(1, 9)} or len(config["claims"]) != 8:
            raise Blocked("unsupported closure claim/build configuration")
        version_log = command("lean-version", [lean, "--version"], root)
        if not version_log.read_text().startswith("Lean (version " + config["leanVersion"] + ","):
            raise Blocked("installed Lean version differs from frozen pin")
        if (root / "lean-toolchain").read_text().strip() != "leanprover/lean4:v" + config["leanVersion"]:
            raise Blocked("repository Lean pin differs from frozen config")
        java_log = command("java-version", ["java", "-version"], root)
        javac_log = command("javac-version", ["javac", "-version"], root)
        report["environment"] = {"lean": version_log.read_text().strip(),
            "java": java_log.read_text().strip(), "javac": javac_log.read_text().strip(),
            "python": sys.version, "host": os.uname().nodename, "platform": os.uname().sysname,
            "heap": config["javaHeap"], "timeoutSeconds": config["commandTimeoutSeconds"]}
        git_head = command("git-head", ["git", "rev-parse", "HEAD"], root)
        git_dirty = command("git-status", ["git", "status", "--porcelain", "--untracked-files=normal"], root)
        report["environment"].update({"gitHead": git_head.read_text().strip(),
                                       "dirtyTree": bool(git_dirty.read_text().strip())})
        command("census-tests", [sys.executable, "scripts/test_submission_container_closure.py"], root)
        for label in ("A", "B"):
            build = output / ("build-" + label)
            build.mkdir()
            for item in inputs["files"]:
                target = build / item["path"]
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(root / item["path"], target)
                if digest(target) != item["sha256"]:
                    raise Blocked("INPUT_MUTATION during clean snapshot")
            classes = build / "classes"
            classes.mkdir()
            java_sources = sorted(str(p.relative_to(build)) for p in build.glob("src/**/*.java"))
            command(label + "-javac", ["javac", "--release", "17", "-encoding", "UTF-8",
                    "-cp", "lib/*", "-d", "classes", *java_sources], build)
            classpath = "classes" + os.pathsep + "lib/*"
            trace_log = command(label + "-probe", ["java", "-Xmx" + config["javaHeap"],
                                "-cp", classpath, PROBE], build)
            payload = json.loads(trace_log.read_text(), object_pairs_hook=unique_object)
            rows = check_census(payload, config)
            proofs = build / "proofs"
            proofs.mkdir()
            for module in ("ContainerReplay", "Phase2VariadicLaws"):
                shutil.copyfile(build / FORMAL / (module + ".lean"), proofs / (module + ".lean"))
                theorem_names = scan_proof(proofs / (module + ".lean"))
                if module == "ContainerReplay" and set(theorem_names) != set(THEOREMS):
                    raise Blocked("container theorem inventory differs from registered verifier")
                if module == "Phase2VariadicLaws" and (
                        len(theorem_names) != 55 or len(set(theorem_names)) != 55
                        or not BOOLEAN_THEOREMS.issubset(theorem_names)):
                    raise Blocked("Boolean construction proof inventory is incomplete")
                command(label + "-" + module, [lean, "-o", module + ".olean", module + ".lean"], proofs)
                if module == "Phase2VariadicLaws":
                    audit = "import Phase2VariadicLaws\n" + "\n".join(
                        "#print axioms ACGN.Section3.Phase2." + name for name in theorem_names) + "\n"
                    (proofs / "BooleanAssumptions.lean").write_text(audit, encoding="utf-8")
                    assumption_log = command(label + "-boolean-assumptions", [lean, "BooleanAssumptions.lean"],
                                             proofs, {"LEAN_PATH": str(proofs)})
                    audit_assumptions(assumption_log, len(theorem_names))
            (proofs / "ObservedReplay.lean").write_text(render_replay(rows), encoding="utf-8")
            replay_log = command(label + "-lean-replay", [lean, "-o", "ObservedReplay.olean", "ObservedReplay.lean"],
                                 proofs, {"LEAN_PATH": str(proofs)})
            audit_assumptions(replay_log, len(rows) + len(NEGATIVES) + len(THEOREMS))
            for test in ("is.fivefivefive.CanDis.theory.BooleanSmartConstructionTest",
                         "is.fivefivefive.CanDis.TheoryLawPolicyRegressionTest",
                         "is.fivefivefive.CanDis.theory.TheoryPortsTest",
                         "is.fivefivefive.CanDis.theory.TheoryCertificatesTest"):
                command(label + "-" + test.rsplit(".", 1)[1], ["java", "-ea", "-Xmx" + config["javaHeap"],
                        "-cp", classpath, test], build)
            artifacts = {str(p.relative_to(build)): digest(p)
                         for p in sorted(classes.rglob("*.class"))}
            artifacts.update({str(p.relative_to(build)): digest(p)
                              for p in sorted(proofs.iterdir()) if p.suffix in {".lean", ".olean"}})
            artifacts["trace-payload"] = hashlib.sha256(canonical_bytes(payload)).hexdigest()
            write_json(output / ("artifacts-" + label + ".json"), artifacts)
            report["builds"].append({"label": label, "rows": len(rows),
                "negativeControls": len(NEGATIVES),
                "rowsByKind": {kind: sum(row["kind"] == kind for row in rows)
                               for kind in config["bounds"]["kinds"]},
                "claimOutcomes": {claim["id"]: "PASS" for claim in config["claims"] if claim["id"] != "SCR-08"},
                "artifactsHash": hashlib.sha256(canonical_bytes(artifacts)).hexdigest()})
        if report["builds"][0]["artifactsHash"] != report["builds"][1]["artifactsHash"]:
            raise Blocked("NONDETERMINISM: isolated artifact manifests differ")
        if report["builds"][0]["claimOutcomes"] != report["builds"][1]["claimOutcomes"]:
            raise Blocked("NONDETERMINISM: isolated claim outcomes differ")
        if source_manifest(root) != inputs:
            raise Blocked("INPUT_MUTATION: source snapshot changed during verification")
        report["claims"] = [dict(claim, status="PASS", closureId=closure_id, inputRootHash=input_hash,
            verifierHash=digest(root / "scripts/run_submission_container_closure.py"),
            evidence=[entry["log"] for entry in report["commands"]],
            rawResult={"builds": 2, "rowsPerBuild": 726, "negativeControlsPerBuild": len(NEGATIVES),
                       "allExitCodesZero": True, "deterministicArtifacts": True})
            for claim in config["claims"]]
        report["status"] = "VERIFIED"
    except (Blocked, ValueError, KeyError, TypeError) as error:
        report["errors"].append(str(error))
    except (OSError, subprocess.TimeoutExpired) as error:
        report["status"] = "INFRASTRUCTURE_FAILURE"
        report["errors"].append(str(error))
    if report["status"] != "VERIFIED":
        report["claims"] = [dict(claim, status="UNRESOLVED", inputRootHash=input_hash)
                            for claim in config["claims"]]
    write_json(output / "closure-report.json", report)
    markdown = ["# Submission Container Replay Closure", "", f"Status: **{report['status']}**", "",
                f"- Closure ID: `{closure_id}`", f"- Input root: `{input_hash}`",
                f"- Isolated builds completed: {len(report['builds'])}", "",
                "This result applies only to the frozen finite scope under the declared trusted components.",
                "Whole-Java refinement, parser semantics, production theory authority, and corpus soundness remain outside it.",
                "", "| Claim | Status | Evidence |", "| --- | --- | --- |"]
    markdown += [f"| {claim['id']} | {claim['status']} | {claim['evidenceClass']} |" for claim in report["claims"]]
    for error in report["errors"]:
        markdown += ["", "Blocking reason: " + error]
    markdown += ["", "The JSON report is authoritative and binds the input manifest, command logs, and artifact digests.", ""]
    (output / "closure-report.md").write_text("\n".join(markdown), encoding="utf-8")
    output_hashes = {p.relative_to(output).as_posix(): digest(p)
                     for p in sorted(output.glob("*")) if p.is_file()}
    write_json(output / "output-hashes.json", output_hashes)
    # Preserve compact reviewable evidence without archiving duplicate JDK builds.
    evidence = sorted(p for p in output.iterdir() if p.is_file())
    evidence += sorted(output.glob("build-*/proofs/*.lean"))
    with (output / "evidence.tar.gz").open("wb") as stream:
        with gzip.GzipFile(filename="", fileobj=stream, mode="wb", mtime=0) as compressed:
            with tarfile.open(fileobj=compressed, mode="w") as archive:
                for path in evidence:
                    info = archive.gettarinfo(str(path), arcname=path.relative_to(output).as_posix())
                    info.mtime = info.uid = info.gid = 0
                    info.uname = info.gname = ""
                    info.mode = 0o644
                    with path.open("rb") as contents:
                        archive.addfile(info, contents)
    write_json(output / "archive-hash.json", {"evidence.tar.gz": digest(output / "evidence.tar.gz")})
    print(json.dumps({"status": report["status"], "claims": len(report["claims"]),
                      "report": str(output / "closure-report.json"), "errors": report["errors"]}))
    return {"VERIFIED": 0, "BLOCKED": 1, "INFRASTRUCTURE_FAILURE": 2}[report["status"]]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="new evidence directory, normally under /tmp")
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    return execute(args.root.resolve(), args.output.resolve())


if __name__ == "__main__":
    raise SystemExit(main())
