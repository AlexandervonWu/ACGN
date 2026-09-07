#!/usr/bin/env python3
"""Compiler-resolved Java/Lean smart-construction correspondence and trace replay."""

from __future__ import annotations

import argparse
import gzip
import itertools
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
from run_submission_container_closure import (
    Blocked, audit_assumptions, canonical_bytes, digest, scan_proof, unique_object, write_json,
)
import hashlib

CONFIG = Path("docs/java-lean-refinement/closure-config.json")
FORMAL = Path("docs/section3-repair-audit/formal")
JAVA_SOURCE = Path("src/is/fivefivefive/CanDis/theory/TypedENode.java")
EXTRACTOR = Path("scripts/java/SmartConstructionSourceExtractor.java")
PROBE = "is.fivefivefive.CanDis.theory.BooleanConstructionReplayProbe"
REFINEMENT_THEOREMS = [
    "extracted_program_refines_nonempty_carrier", "nonset_does_not_evaluate_the_set_cast",
    "wrongly_typed_singleton_rejects", "nonempty_target_shape_preserves_construction_denotation",
    "same_head_flattening_preserves_denotation", "observation_preserves_source_support",
    "observation_preserves_boolean_denotation", "observation_mints_no_unit",
    "observation_target_matches_extracted_program",
]


def hash_value(value: object) -> str:
    return hashlib.sha256(canonical_bytes(value)).hexdigest()


def number_expr(value: dict) -> str:
    if value == {"kind": "size"}:
        return ".size"
    if set(value) == {"kind", "value"} and value["kind"] == "nat" and type(value["value"]) is int:
        if 0 <= value["value"] <= 2147483647:
            return f"(.literal {value['value']})"
    raise Blocked("unsupported extracted number expression")


def condition_expr(value: dict) -> str:
    if not isinstance(value, dict):
        raise Blocked("condition is not a structured compiler expression")
    kind = value.get("kind")
    if kind in ("isSet", "isOne") and set(value) == {"kind"}:
        return "." + kind
    if kind == "not" and set(value) == {"kind", "condition"}:
        return "(.not " + condition_expr(value["condition"]) + ")"
    if kind in ("and", "or", "eq") and set(value) == {"kind", "left", "right"}:
        encode = number_expr if kind == "eq" else condition_expr
        op = "equal" if kind == "eq" else kind
        return f"(.{op} {encode(value['left'])} {encode(value['right'])})"
    raise Blocked("unsupported extracted condition")


def render_program(extraction: dict) -> str:
    outcome = {"SINGLETON": ".singleton", "NODE": ".node"}
    try:
        program = extraction
        expression = ("{ condition := " + condition_expr(program["condition"])
            + ", rejectionGuard := " + condition_expr(program["rejectionGuard"])
            + ", whenTrue := " + outcome[program["whenTrue"]]
            + ", whenFalse := " + outcome[program["whenFalse"]] + " }")
    except (KeyError, TypeError) as error:
        raise Blocked("incomplete compiler-resolved program") from error
    return "\n".join([
        "import SmartConstructionRefinement", "open ACGN.SmartConstructionRefinement",
        "def extractedProgram : Program := " + expression,
        "theorem compiler_program_matches : extractedProgram = expectedProgram := by decide",
        "theorem java_lean_correspondence (head : ACGN.Section3.Phase2.BooleanConnective)",
        "    (values : List Nat) (nonempty : Not (values = [])) :",
        "    execute extractedProgram (Frame.mk true values.length true) = modelOutcome head values :=",
        "  extracted_program_refines_nonempty_carrier extractedProgram compiler_program_matches head values nonempty",
        "#print axioms compiler_program_matches", "#print axioms java_lean_correspondence", "",
    ])


def source_key(source: dict) -> tuple:
    if isinstance(source, dict) and set(source) == {"leaf"}:
        if type(source["leaf"]) is int and 0 <= source["leaf"] < 3:
            return ("leaf", source["leaf"])
    if isinstance(source, dict) and set(source) == {"children"} and isinstance(source["children"], list):
        if len(source["children"]) > 4:
            raise Blocked("oversized source application")
        return ("app", tuple(source_key(c) for c in source["children"]))
    raise Blocked("invalid source tree")


def binary_trees(word: tuple) -> list[tuple]:
    if len(word) == 1:
        return [("leaf", word[0])]
    return [("app", (left, right)) for split in range(1, len(word))
            for left in binary_trees(word[:split]) for right in binary_trees(word[split:])]


def expected_sources() -> set[tuple]:
    result = set()
    for length in range(5):
        for word in itertools.product(range(3), repeat=length):
            result.add(("flat", ("app", tuple(("leaf", x) for x in word))))
            if length >= 2:
                result.update(("binary", tree) for tree in binary_trees(word))
    return result


def leaves(source: tuple) -> list[int]:
    return [source[1]] if source[0] == "leaf" else [x for c in source[1] for x in leaves(c)]


def lean_source(source: tuple) -> str:
    if source[0] == "leaf":
        return f"(.flat [{source[1]}])"
    children = source[1]
    if all(child[0] == "leaf" for child in children):
        return "(.flat " + str([c[1] for c in children]) + ")"
    if len(children) != 2:
        raise Blocked("nested source is outside the binary association family")
    return "(.binary " + lean_source(children[0]) + " " + lean_source(children[1]) + ")"


def check_rows(payload: dict, config: dict) -> list[dict]:
    if any(type(payload.get(name)) is not int or payload[name] != value
           for name, value in (("schemaVersion", 1), ("alphabetSize", 3), ("maxLength", 4))):
        raise Blocked("incorrect certified probe schema or bounds")
    expected = {(head, profile, shape, source) for head in config["bounds"]["heads"]
                for profile in config["bounds"]["profiles"] for shape, source in expected_sources()}
    seen = set()
    rows = payload["rows"]
    rejected = 0
    for index, row in enumerate(rows):
        source = source_key(row["source"])
        key = (row["head"], row["profile"], row["shape"], source)
        if key not in expected or key in seen or type(row["id"]) is not int or row["id"] != index:
            raise Blocked("duplicate, missing, or reordered input identity")
        seen.add(key)
        word = leaves(source)
        # Python's bool/int equality must not erase a malformed certificate identity.
        for name in ("output", "traceInput", "traceOutput"):
            if not isinstance(row[name], list) or len(row[name]) > 4 or any(
                    type(x) is not int or not 0 <= x < 3 for x in row[name]):
                raise Blocked("invalid returned typed identity")
        if row["traceInput"] != word:
            raise Blocked("actual source-to-certificate occurrence transition disagrees")
        fibers = row["fibers"]
        if not isinstance(fibers, list) or len(fibers) > 4 or any(
                not isinstance(f, list) or len(f) > 4
                or any(type(i) is not int or not 0 <= i < len(word) for i in f) for f in fibers):
            raise Blocked("invalid source fiber data")
        if row["hasUnit"] is not False:
            raise Blocked("Boolean construction minted a unit premise")
        if not word:
            if (row["outcome"] != "REJECTED_EMPTY" or row["output"] or row["traceOutput"] or fibers
                    or row["certificatePresent"] is not False or row["tracePresent"] is not False
                    or row["certificateSource"] is not None):
                raise Blocked("empty production source received a target or certificate")
            rejected += 1
            continue
        if row["outcome"] not in ("SINGLETON", "NODE"):
            raise Blocked("nonempty source did not produce a certified target")
        if source_key(row["certificateSource"]) != source or row["traceOutput"] != row["output"]:
            raise Blocked("certificate endpoints differ from the observed construction")
        if any(row[name] is not True for name in (
                "certificatePresent", "tracePresent", "certificateVerified", "sourceBound", "targetBound")):
            raise Blocked("production certificate verification or endpoint binding is missing")
    if seen != expected or len(rows) != config["bounds"]["expectedRows"]:
        raise Blocked(f"incomplete source census: {len(seen)}/{len(expected)}")
    if rejected != config["bounds"]["expectedEmptyRejections"]:
        raise Blocked("missing expected empty-source rejection")
    return rows


def render_observations(rows: list[dict]) -> tuple[str, int]:
    lines = ["import ExtractedProgram", "open ACGN.SmartConstructionRefinement",
             "set_option maxRecDepth 4096", "set_option maxHeartbeats 1000000"]
    names = []
    for row in rows:
        if row["outcome"] == "REJECTED_EMPTY":
            continue
        name = f"witness_{row['id']:04d}"
        shape = ".singleton" if row["outcome"] == "SINGLETON" else ".node"
        trace = "{ kind := .set, input := " + str(row["traceInput"]) + ", output := " + str(row["output"]) + ", fibers := " + str(row["fibers"]) + " }"
        lines += [f"def {name} : Observation := {{ source := " + lean_source(source_key(row["source"]))
                  + f", outcome := {shape}, trace := {trace}, hasUnit := false }}",
                  f"theorem {name}_accepted : observationValid {name} = true := by decide",
                  f"theorem {name}_semantics (interpret : Nat -> Bool) :",
                  f"  {name}.source.denote .{row['head'].lower()} interpret =",
                  f"    (ACGN.Section3.Phase2.BooleanConnective.{row['head'].lower()}).evaluate interpret {name}.trace.output :=",
                  f"  observation_preserves_boolean_denotation {name} {name}_accepted _ interpret",
                  f"theorem {name}_java_target : {name}.outcome =",
                  f"    execute extractedProgram (Frame.mk true {name}.trace.output.length true) :=",
                  f"  observation_target_matches_extracted_program extractedProgram compiler_program_matches {name} {name}_accepted"]
        names += [name + "_accepted", name + "_semantics", name + "_java_target"]
    for theorem in REFINEMENT_THEOREMS:
        lines.append("#print axioms ACGN.SmartConstructionRefinement." + theorem)
    lines += ["#print axioms " + name for name in names]
    return "\n".join(lines) + "\n", len(names) + len(REFINEMENT_THEOREMS)


def manifest(root: Path) -> dict:
    files = set(root.glob("src/**/*.java")) | set(root.glob("lib/**/*.jar"))
    files.update(root / file for file in [CONFIG, EXTRACTOR, "lean-toolchain",
        "scripts/run_java_lean_refinement.py", "scripts/test_java_lean_refinement.py",
        "scripts/run_submission_container_closure.py", "scripts/check_rewrite_dispatch_parity.py",
        "docs/java-lean-refinement/README.md", ".github/workflows/bounded-ci.yml"])
    files.update(root / FORMAL / (name + ".lean") for name in (
        "ContainerReplay", "Phase2VariadicLaws", "SmartConstructionRefinement"))
    return {"schemaVersion": 1, "files": [{"path": f.relative_to(root).as_posix(), "sha256": digest(f)}
                                          for f in sorted(files)]}


def run(root: Path, output: Path) -> int:
    output.mkdir(parents=True, exist_ok=False)
    config = json.loads((root / CONFIG).read_text())
    inputs = manifest(root)
    input_root = hash_value(inputs)
    report = {"schemaVersion": 1, "closureId": config["closureFamily"] + "-" + input_root[:16],
              "inputRootHash": input_root, "status": "BLOCKED", "builds": [], "commands": [], "errors": [],
              "trusted": config["trusted"], "excluded": config["excluded"], "claims": []}
    write_json(output / "input-manifest.json", inputs)
    env = dict(os.environ, LC_ALL="C", TZ="UTC", PYTHONDONTWRITEBYTECODE="1")
    for key in ("JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS", "_JAVA_OPTIONS", "CLASSPATH", "LEAN_PATH"):
        env.pop(key, None)

    def command(label: str, args: list[str], cwd: Path, extra: dict | None = None, reject: bool = False) -> Path:
        print("[java-lean-refinement] " + label, flush=True)
        log = output / (label + ".log")
        started = time.monotonic()
        with log.open("w") as stream:
            result = subprocess.run(args, cwd=cwd, env=env | (extra or {}), stdout=stream,
                                    stderr=subprocess.STDOUT, timeout=config["timeoutSeconds"])
        report["commands"].append({"id": label, "argv": args, "exitCode": result.returncode,
            "expectedRejection": reject, "seconds": time.monotonic() - started,
            "log": log.name, "sha256": digest(log)})
        if (not reject and result.returncode != 0) or (reject and result.returncode != 1):
            raise Blocked(f"{label}: unexpected exit {result.returncode}, see {log}")
        return log

    try:
        lean = shutil.which("lean")
        if lean is None:
            raise OSError("Lean is not installed")
        lean_version = command("lean-version", [lean, "--version"], root).read_text().strip()
        if not lean_version.startswith("Lean (version 4.33.0,") or (root / "lean-toolchain").read_text().strip() != "leanprover/lean4:v4.33.0":
            raise Blocked("Lean toolchain mismatch")
        report["environment"] = {"lean": lean_version, "python": sys.version,
            "java": command("java-version", ["java", "-version"], root).read_text().strip(),
            "javac": command("javac-version", ["javac", "-version"], root).read_text().strip(),
            "gitHead": command("git-head", ["git", "rev-parse", "HEAD"], root).read_text().strip(),
            "dirtyTree": bool(command("git-status", ["git", "status", "--porcelain"], root).read_text()),
            "host": os.uname().nodename, "heap": config["heap"]}
        command("boundary-tests", [sys.executable, "-B", "scripts/test_java_lean_refinement.py"], root)
        for label in ("A", "B"):
            build = output / ("build-" + label)
            build.mkdir()
            for file in inputs["files"]:
                target = build / file["path"]
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(root / file["path"], target)
                if digest(target) != file["sha256"]:
                    raise Blocked("INPUT_MUTATION during snapshot")
            (build / "classes").mkdir()
            sources = sorted(str(p.relative_to(build)) for p in build.glob("src/**/*.java")) + [str(EXTRACTOR)]
            command(label + "-compile", ["javac", "--release", "17", "-encoding", "UTF-8", "-cp", "lib/*", "-d", "classes", *sources], build)
            extraction_file = build / "extracted-program.json"
            command(label + "-extract", ["java", "-Xmx1g", "-cp", "classes", "SmartConstructionSourceExtractor", str(build), str(extraction_file)], build)
            extraction = json.loads(extraction_file.read_text(), object_pairs_hook=unique_object)
            if extraction["sourceSha256"] != digest(build / JAVA_SOURCE):
                raise Blocked("compiler extraction does not bind the frozen Java source")
            payload_log = command(label + "-probe", ["java", "-ea", "-Xmx1g", "-cp", "classes" + os.pathsep + "lib/*", PROBE], build)
            rows = check_rows(json.loads(payload_log.read_text(), object_pairs_hook=unique_object), config)
            proofs = build / "proofs"
            proofs.mkdir()
            penv = {"LEAN_PATH": str(proofs)}
            for module in ("ContainerReplay", "Phase2VariadicLaws", "SmartConstructionRefinement"):
                source = build / FORMAL / (module + ".lean")
                names = scan_proof(source)
                if module == "SmartConstructionRefinement" and set(names) != set(REFINEMENT_THEOREMS):
                    raise Blocked("unregistered refinement theorem inventory")
                shutil.copyfile(source, proofs / source.name)
                command(label + "-" + module, [lean, "-o", module + ".olean", module + ".lean"], proofs, penv)
            (proofs / "ExtractedProgram.lean").write_text(render_program(extraction))
            program_log = command(label + "-symbolic-refinement", [lean, "-o", "ExtractedProgram.olean", "ExtractedProgram.lean"], proofs, penv)
            audit_assumptions(program_log, 2)
            replay, theorem_count = render_observations(rows)
            (proofs / "CertifiedReplay.lean").write_text(replay)
            replay_log = command(label + "-certified-replay", [lean, "-o", "CertifiedReplay.olean", "CertifiedReplay.lean"], proofs, penv)
            audit_assumptions(replay_log, theorem_count)
            for mutation, old, new in (
                ("wrong-threshold", "&& ((SetPort) container).elements().size() == 1", "&& ((SetPort) container).elements().size() == 2"),
                ("unknown-effect", "TypedENode node = flattenVisible(source, sealer);", "System.nanoTime();\n        TypedENode node = flattenVisible(source, sealer);"),
            ):
                mutant = output / (label + "-" + mutation)
                shutil.copytree(build / "src", mutant / "src")
                shutil.copytree(build / "lib", mutant / "lib")
                target = mutant / JAVA_SOURCE
                text = target.read_text()
                if text.count(old) != 1:
                    raise Blocked("source mutation witness is ambiguous")
                target.write_text(text.replace(old, new))
                extracted = mutant / "extracted-program.json"
                command(label + "-" + mutation + "-extract", ["java", "-Xmx1g", "-cp", str(build / "classes"),
                        "SmartConstructionSourceExtractor", str(mutant), str(extracted)], mutant, reject=mutation == "unknown-effect")
                if mutation == "wrong-threshold":
                    mutated_program = json.loads(extracted.read_text(), object_pairs_hook=unique_object)
                    (proofs / "WrongThreshold.lean").write_text(render_program(mutated_program))
                    log = command(label + "-wrong-threshold-proof", [lean, "WrongThreshold.lean"], proofs, penv, reject=True)
                    if "compiler_program_matches" not in log.read_text() and "decide" not in log.read_text():
                        raise Blocked("negative Lean control failed for an unrelated reason")
            command(label + "-boolean-tests", ["java", "-ea", "-Xmx1g", "-cp", "classes" + os.pathsep + "lib/*",
                    "is.fivefivefive.CanDis.theory.BooleanSmartConstructionTest"], build)
            deterministic = {str(p.relative_to(build)): digest(p) for p in sorted((build / "classes").rglob("*.class"))}
            deterministic.update({str(p.relative_to(build)): digest(p) for p in sorted(proofs.iterdir()) if p.suffix in (".olean", ".lean")})
            deterministic["extracted-program"] = hash_value(extraction)
            deterministic["probe"] = digest(payload_log)
            write_json(output / ("artifacts-" + label + ".json"), deterministic)
            report["builds"].append({"id": label, "rows": len(rows), "successful": len(rows) - 4,
                "emptyRejected": 4, "theoremCount": theorem_count, "artifactHash": hash_value(deterministic)})
        if report["builds"][0]["artifactHash"] != report["builds"][1]["artifactHash"]:
            raise Blocked("NONDETERMINISM between clean builds")
        if manifest(root) != inputs:
            raise Blocked("INPUT_MUTATION during verification")
        report["status"] = "VERIFIED"
    except (Blocked, ValueError, KeyError, TypeError, RecursionError) as error:
        report["errors"].append(str(error))
    except (OSError, subprocess.TimeoutExpired) as error:
        report["status"] = "INFRASTRUCTURE_FAILURE"
        report["errors"].append(str(error))
    for claim in config["claims"]:
        report["claims"].append(dict(claim, status="PASS" if report["status"] == "VERIFIED" else "UNRESOLVED",
            inputRootHash=input_root, verifierHash=digest(root / "scripts/run_java_lean_refinement.py"),
            evidence=[c["log"] for c in report["commands"]]))
    write_json(output / "closure-report.json", report)
    text = ["# Java-Lean Smart-Construction Refinement", "", f"Status: **{report['status']}**", "",
            f"Input root: `{input_root}`", "", "This result applies to the declared source fragment and finite execution family under the listed trusted components.",
            "", "| Claim | Status | Evidence |", "| --- | --- | --- |"]
    text += [f"| {c['id']} | {c['status']} | {c['evidenceClass']} |" for c in report["claims"]]
    text += ["", *report["errors"], ""]
    (output / "closure-report.md").write_text("\n".join(text))
    evidence = sorted(p for p in output.iterdir() if p.is_file())
    evidence += sorted(output.glob("build-*/proofs/*.lean")) + sorted(output.glob("build-*/extracted-program.json"))
    write_json(output / "output-hashes.json", {p.relative_to(output).as_posix(): digest(p) for p in evidence})
    evidence.append(output / "output-hashes.json")
    with (output / "evidence.tar.gz").open("wb") as stream, gzip.GzipFile(filename="", fileobj=stream, mode="wb", mtime=0) as compressed:
        with tarfile.open(fileobj=compressed, mode="w") as archive:
            for path in evidence:
                info = archive.gettarinfo(str(path), arcname=path.relative_to(output).as_posix())
                info.mtime = info.uid = info.gid = 0
                info.uname = info.gname = ""
                info.mode = 0o644
                with path.open("rb") as contents:
                    archive.addfile(info, contents)
    write_json(output / "archive-hash.json", {"evidence.tar.gz": digest(output / "evidence.tar.gz")})
    print(json.dumps({"status": report["status"], "errors": report["errors"], "report": str(output / "closure-report.json")}))
    return {"VERIFIED": 0, "BLOCKED": 1, "INFRASTRUCTURE_FAILURE": 2}[report["status"]]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    raise SystemExit(run(args.root.resolve(), args.output.resolve()))
