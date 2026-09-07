#!/usr/bin/env python3
"""Reproduce the five finite correspondence checks, never the corpus experiments."""

import argparse
import csv
import hashlib
import json
import os
import platform
from pathlib import Path
import re
import shutil
import subprocess
import sys

sys.dont_write_bytecode = True
from run_submission_container_closure import (
    Blocked, audit_assumptions, canonical_bytes, digest, scan_proof, write_json,
)

PACKAGE = Path("docs/obligation-repair/bounded-five")
FORMAL = Path("docs/section3-repair-audit/formal")
POLICY = Path("src/is/fivefivefive/CanDis/core/AlloyOperatorPolicy.java")
JOIN_SOURCE = Path("src/is/fivefivefive/CanDis/theory/DependentChainTheory.java")


def pinned_lean_environment(environment, repository_pin, version):
    expected = "leanprover/lean4:v" + version
    if repository_pin.strip() != expected:
        raise Blocked("repository Lean pin differs from frozen config")
    # Every isolated working directory must use the same toolchain, even when
    # elan has no default or the caller's default differs from the repository.
    return dict(environment, ELAN_TOOLCHAIN=expected)


def policy_mapping(path):
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        if reader.fieldnames != ["field", "nominalType", "constructorParameter", "getterField"]:
            raise Blocked("unexpected policy extraction schema")
        rows = list(reader)
    names = ["arityPolicy", "siblingQuotient", "flatLicense", "unitLicense"]
    types = ["ArityPolicy", "SiblingQuotient", "FlatLicense", "UnitLicense"]
    if len(rows) != 4:
        raise Blocked("incomplete policy field census")
    for i, row in enumerate(rows):
        if (set(row) != set(reader.fieldnames) or row["field"] != names[i]
                or row["nominalType"] != "is.fivefivefive.CanDis.theory." + types[i]):
            raise Blocked("policy nominal mapping changed")
        for field in ("constructorParameter", "getterField"):
            if row[field] not in ("0", "1", "2", "3"):
                raise Blocked("noncanonical policy coordinate")
    return {field: [int(row[field]) for row in rows]
            for field in ("constructorParameter", "getterField")}


def join_mapping(path):
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        if reader.fieldnames != ["guard", "minimumInteriorArity", "start", "endOffset"]:
            raise Blocked("unexpected JOIN extraction schema")
        rows = list(reader)
    if len(rows) != 2 or [r["guard"] for r in rows] != ["producer", "verifier"]:
        raise Blocked("incomplete independent guard census")
    result = {}
    for row in rows:
        if row["start"] != "1" or row["endOffset"] != "1":
            raise Blocked("guard interval mismatch")
        value = row["minimumInteriorArity"]
        if not re.fullmatch(r"0|[1-9][0-9]{0,9}", value) or int(value) > 2147483647:
            raise Blocked("unsupported guard threshold")
        result[row["guard"]] = int(value)
    return result


def flat_mapping(path):
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        if reader.fieldnames != ["requiredPortCount", "rootPortIndex"]:
            raise Blocked("unexpected flat admission schema")
        rows = list(reader)
    if len(rows) != 1 or set(rows[0]) != {"requiredPortCount", "rootPortIndex"}:
        raise Blocked("incomplete flat admission census")
    for value in rows[0].values():
        if not re.fullmatch(r"0|[1-9][0-9]{0,9}", value) or int(value) > 2147483647:
            raise Blocked("unsupported root guard literal")
    return {key: int(value) for key, value in rows[0].items()}


ZERO_CENSUS = {
    "local-calls": {"zlocal/zero": 1, "zlocal/value": 1},
    "ordering": {"util/ordering<A>/first": 1, "util/ordering<A>/last": 1},
    "integer-next": {"util/integer/next": 1},
    "repeated-local": {"zrepeat/zero": 2, "zrepeat/value": 2},
    "repeated-import": {"util/ordering<A>/first": 2, "util/ordering<A>/last": 2},
}
ZERO_FIELDS = ("fixture parser_path graph parser_source parser_kind parser_args occurrence owner visit "
    "source callee kind arity authority edge_count e1_owner e1_visit e1_position e1_is_end "
    "target_source target_callee target_kind target_arity target_authority callee_match "
    "e2_owner e2_visit e2_position e2_is_end ir_occurrence ir_source ir_callee ir_kind ir_arity "
    "ir_authority ir_args ir_max_arity ir_end_children cert_occurrence cert_source cert_callee "
    "cert_kind cert_arity cert_authority cert_args cert_ports cert_path cert_operator normalized_occurrences").split()


def zero_trace_program(path):
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        if reader.fieldnames != ZERO_FIELDS:
            raise Blocked("unexpected zero-call observation schema")
        rows = list(reader)
    census, occurrences, parser_paths = {}, set(), set()
    output = ["import ZeroArgumentCall", "open ACGN.BoundedFive.ZeroArgumentCall"]
    for i, row in enumerate(rows):
        if None in row or any(v is None for v in row.values()):
            raise Blocked("malformed zero-call row")
        if any(any(ord(c) < 32 for c in v) for v in row.values()):
            raise Blocked("control character in zero-call primitive")
        def natural(name):
            value = row[name]
            if not re.fullmatch(r"0|[1-9][0-9]{0,18}", value):
                raise Blocked("noncanonical observed natural: " + name)
            return value
        def boolean(name):
            if row[name] not in ("true", "false"):
                raise Blocked("noncanonical observed Boolean: " + name)
            return row[name]
        def text(name):
            return json.dumps(row[name], ensure_ascii=False)
        def kind(name):
            try:
                return {"call/formula": ".formula", "call/expression": ".expression"}[row[name]]
            except KeyError:
                raise Blocked("unknown CALL kind")
        def key(prefix):
            try:
                authority = {"DECLARATION": ".declaration", "TYPECHECKED_IMPORT": ".typecheckedImport"}[row[prefix + "authority"]]
            except KeyError:
                raise Blocked("unknown CALL authority")
            return "(Key.mk " + " ".join([text(prefix + "source"), text(prefix + "callee"),
                   kind(prefix + "kind"), natural(prefix + "arity"), authority]) + ")"
        def boundary(prefix, end):
            return "(BoundaryCall.mk " + natural(prefix + "occurrence") + " " + key(prefix) + " " \
                + natural(prefix + "args") + " " + natural(end) + ")"
        fixture, occurrence = row["fixture"], natural("occurrence")
        occurrence_key = (fixture, occurrence)
        path_key = (fixture, row["parser_path"])
        if occurrence_key in occurrences or path_key in parser_paths:
            raise Blocked("duplicate source CALL occurrence")
        occurrences.add(occurrence_key)
        parser_paths.add(path_key)
        counts = census.setdefault(fixture, {})
        counts[row["callee"]] = counts.get(row["callee"], 0) + 1
        capture = "(Capture.mk " + occurrence + " " + natural("owner") + " " + natural("visit") + " " + key("") + ")"
        first_target = ".endMarker" if boolean("e1_is_end") == "true" else "(.callee " + key("target_") + ")"
        second_target = ".endMarker" if boolean("e2_is_end") == "true" else ".other"
        edges = "[(Edge.mk " + " ".join([natural("e1_owner"), natural("e1_visit"), natural("e1_position"), first_target]) \
            + "), (Edge.mk " + " ".join([natural("e2_owner"), natural("e2_visit"), natural("e2_position"), second_target]) + ")]"
        observation = "(Observation.mk " + " ".join([capture, edges, natural("edge_count"), text("parser_source"),
            kind("parser_kind"), natural("parser_args"), boolean("callee_match"), boundary("ir_", "ir_end_children"),
            natural("ir_max_arity"), boundary("cert_", "cert_ports"), natural("cert_ports")]) + ")"
        output.extend([f"def observation{i} : Observation := {observation}",
                       f"theorem replay{i} : replay observation{i} = true := by decide",
                       f"#print axioms replay{i}"])
    if census != ZERO_CENSUS:
        raise Blocked("zero-call trace census differs from frozen fixtures")
    return "\n".join(output) + "\n", len(rows)


BUILTIN_FIELDS = ("fixture source_expr reference_expr parser_term reference_term parser_operator "
    "source_kind source_name semantic_identity scope_index scope fast_equivalent certified_equivalent "
    "raw_equivalent raw_debruijn_equivalent java_egglog_equivalent java_egglog_debruijn_equivalent "
    "slotted_equivalent normalized_source normalized_reference source_sat reference_sat "
    "normalized_source_sat normalized_reference_sat source_preservation_sat reference_preservation_sat "
    "pair_counterexample_sat").split()
BUILTIN_CENSUS = {
    "some-none": ("none", "000", "000", True),
    "no-none": ("none", "111", "111", True),
    "one-none": ("none", "000", "000", True),
    "lone-none": ("none", "111", "111", True),
    "none-union": ("none", "011", "011", True),
    "univ-membership": ("univ", "111", "111", True),
    "some-univ": ("univ", "011", "011", True),
    "no-univ": ("univ", "100", "100", True),
    "user-None": ("None", "001", "000", False),
    "user-Univ": ("Univ", "001", "011", False),
    "near-None": ("NoneNear", "001", "000", False),
    "near-Univ": ("UnivNear", "001", "011", False),
}


def builtin_trace_program(path):
    """Replay nominal identities and bounded solver bits, not an Alloy parser."""
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        if reader.fieldnames != BUILTIN_FIELDS:
            raise Blocked("unexpected built-in observation schema")
        rows = list(reader)
    seen = set()
    output = ["import BuiltinIdentity", "open ACGN.BoundedFive.BuiltinIdentity"]
    for i, row in enumerate(rows):
        if None in row or any(v is None or any(ord(c) < 32 for c in v) for v in row.values()):
            raise Blocked("malformed built-in observation")
        fixture, scope = row["fixture"], row["scope_index"]
        if fixture not in BUILTIN_CENSUS or scope not in ("0", "1", "2") or (fixture, scope) in seen:
            raise Blocked("unexpected or duplicated built-in fixture/scope")
        seen.add((fixture, scope))
        name, left, right, equivalent = BUILTIN_CENSUS[fixture]
        # Nominal kind is observed independently of the display name.
        kinds = {"BUILTIN_NONE": "(.builtin .noneSet)", "BUILTIN_UNIV": "(.builtin .univSet)", "USER": ".user"}
        if row["source_kind"] not in kinds:
            raise Blocked("unsupported observed signature kind")
        actual_kind = kinds[row["source_kind"]]
        expected_kind = "(.builtin .noneSet)" if name == "none" else "(.builtin .univSet)" if name == "univ" else ".user"
        def literal(value):
            return json.dumps(value, ensure_ascii=False)
        identity = "alloy/builtin/" + name if name in ("none", "univ") else "alloy/signature/" + name
        output.extend([
            f"theorem identity{i} : ({actual_kind} : SignatureKind) = {expected_kind} /\\",
            f"    {literal(row['source_name'])} = {literal(name)} /\\",
            f"    signatureIdentity {actual_kind} {literal(row['source_name'])} = {literal(row['semantic_identity'])} /\\",
            f"    {literal(row['semantic_identity'])} = {literal(identity)} := by decide",
            f"#print axioms identity{i}",
        ])
        boolean_fields = BUILTIN_FIELDS[11:18] + BUILTIN_FIELDS[20:27]
        actual = []
        for field in boolean_fields:
            if row[field] not in ("true", "false"):
                raise Blocked("noncanonical observed Boolean: " + field)
            actual.append(row[field])
        l, r = left[int(scope)] == "1", right[int(scope)] == "1"
        expected = [equivalent] * 7 + [l, r, l, r, False, False, l != r]
        # This theorem checks the observed finite census. General relational
        # semantics are proved separately in BuiltinIdentity, not by these bits.
        output.extend([
            f"theorem solverRow{i} : ([{', '.join(actual)}] : List Bool) = "
            + "[" + ", ".join(str(v).lower() for v in expected) + "] := by decide",
            f"#print axioms solverRow{i}",
        ])
    if seen != {(fixture, str(scope)) for fixture in BUILTIN_CENSUS for scope in range(3)}:
        raise Blocked("incomplete built-in fixture/scope census")
    return "\n".join(output) + "\n", 2 * len(rows)


def inputs(root):
    paths = set(root.glob("src/**/*.java")) | set(root.glob("certificate-verifier/**/*.java"))
    paths |= set(root.glob("lib/*.jar")) | set((root / FORMAL).glob("*.lean"))
    paths |= set(root.glob("scripts/java/*.java"))
    for name in ("scripts/run_bounded_obligation_repairs.py", "scripts/test_bounded_obligation_repairs.py",
                 "scripts/run_submission_container_closure.py", "scripts/check_rewrite_dispatch_parity.py",
                 "docs/section3-repair-audit/claim-ledger.md",
                 "docs/section3-repair-audit/assurance-scope.tsv",
                 "docs/section3-repair-audit/requirements-traceability.tsv",
                 "scripts/run_bounded_ci_java_tests.sh", ".github/workflows/bounded-ci.yml",
                 "lean-toolchain", str(PACKAGE / "closure-config.json")):
        paths.add(root / name)
    return {str(p.relative_to(root)): digest(p) for p in sorted(paths)}


def execute(root, output):
    config = json.loads((root / PACKAGE / "closure-config.json").read_text(encoding="utf-8"))
    output.mkdir(parents=True, exist_ok=False)
    manifest = inputs(root)
    root_hash = hashlib.sha256(canonical_bytes(manifest)).hexdigest()
    write_json(output / "input-manifest.json", manifest)
    report = {"schemaVersion": 1, "closureId": "bounded-five-v1-" + root_hash[:16],
              "inputRootHash": root_hash, "status": "BLOCKED", "commands": [], "builds": [],
              "claims": [], "errors": [], "trusted": config["trusted"], "excluded": config["excluded"],
              "verifierHashes": {p: h for p, h in manifest.items() if p.startswith("scripts/")}}
    report["environment"] = {"platform": platform.platform(), "python": sys.version}
    report["claims"] = [{"id": p["id"], "parent": p["parent"], "status": "BLOCKED",
                         "scope": p["scope"], "proof": str(FORMAL / p["proof"]), "tests": p["tests"]}
                        for p in config["phases"]]
    env = dict(os.environ, LC_ALL="C", TZ="UTC", PYTHONDONTWRITEBYTECODE="1")
    for name in ("JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS", "_JAVA_OPTIONS", "CLASSPATH", "LEAN_PATH"):
        env.pop(name, None)
    lean = os.environ.get("LEAN_BIN") or shutil.which("lean") or str(
        Path(os.environ.get("ELAN_HOME", str(Path.home() / ".elan"))) / "bin/lean")

    def command(label, argv, cwd, extra=None, reject=False):
        print("[bounded-five] " + label, flush=True)
        log = output / (label + ".log")
        with log.open("w", encoding="utf-8") as stream:
            result = subprocess.run(argv, cwd=cwd, env=dict(env, **(extra or {})),
                                    stdout=stream, stderr=subprocess.STDOUT, timeout=config["timeoutSeconds"])
        report["commands"].append({"id": label, "argv": argv, "exitCode": result.returncode,
                                   "log": log.name, "sha256": digest(log), "expectedRejection": reject})
        if (reject and result.returncode != 1) or (not reject and result.returncode != 0):
            print(log.read_text(encoding="utf-8", errors="replace")[-4000:], flush=True)
            raise Blocked("unexpected command outcome: " + label)
        return log

    try:
        env = pinned_lean_environment(env, (root / "lean-toolchain").read_text(encoding="utf-8"),
                                      config["leanVersion"])
        report["environment"]["ELAN_TOOLCHAIN"] = env["ELAN_TOOLCHAIN"]
        version = command("lean-version", [lean, "--version"], root).read_text()
        if "version " + config["leanVersion"] + "," not in version:
            raise Blocked("Lean differs from pinned toolchain")
        command("java-version", ["java", "-version"], root)
        command("javac-version", ["javac", "-version"], root)
        command("driver-tests", [sys.executable, "scripts/test_bounded_obligation_repairs.py"], root)
        for number in (1, 2):
            build = output / ("build" + str(number))
            snapshot = build / "source"
            for relative, expected in manifest.items():
                target = snapshot / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(root / relative, target)
                if digest(target) != expected:
                    raise Blocked("snapshot input changed: " + relative)
            classes, formal, extractor = build / "classes", build / "formal", build / "extractor"
            for directory in (classes, formal, extractor):
                directory.mkdir(parents=True)
            prefix = "build" + str(number) + "-"
            shutil.copyfile(snapshot / "lean-toolchain", formal / "lean-toolchain")
            isolated_version = command(prefix + "lean-version", [lean, "--version"], formal).read_text()
            if isolated_version != version:
                raise Blocked("isolated proof directory changed the Lean toolchain")
            sources = sorted(str(p) for p in (snapshot / "src").rglob("*.java"))
            command(prefix + "compile", ["javac", "-J-Xmx1g", "--release", "17", "-encoding", "UTF-8",
                    "-cp", str(snapshot / "lib/*"), "-d", str(classes), *sources], snapshot)
            command(prefix + "extractor-compile", ["javac", "--release", "17", "-encoding", "UTF-8",
                    "-d", str(extractor), str(snapshot / "scripts/java/PolicyRepresentationExtractor.java"),
                    str(snapshot / "scripts/java/JoinGuardExtractor.java"),
                    str(snapshot / "scripts/java/FlatRootPortExtractor.java")], snapshot)
            mapping_file = build / "policy.tsv"
            command(prefix + "policy-extract", ["java", "-Xmx1g", "-cp", str(extractor),
                    "PolicyRepresentationExtractor", str(snapshot), str(mapping_file)], snapshot)
            mapping = policy_mapping(mapping_file)
            write_json(build / "policy-mapping.json", mapping)
            if any(p["parent"] == "A2-06" for p in config["phases"]):
                guard_file = build / "join.tsv"
                command(prefix + "join-extract", ["java", "-Xmx1g", "-cp", str(extractor),
                        "JoinGuardExtractor", str(snapshot), str(guard_file)], snapshot)
                guard_mapping = join_mapping(guard_file)
                write_json(build / "join-mapping.json", guard_mapping)
            if any(p["parent"] == "P2-05" for p in config["phases"]):
                root_file = build / "flat.tsv"
                command(prefix + "flat-extract", ["java", "-Xmx1g", "-cp", str(extractor),
                        "FlatRootPortExtractor", str(snapshot), str(root_file)], snapshot)
                root_mapping = flat_mapping(root_file)
                write_json(build / "flat-mapping.json", root_mapping)
            for phase in config["phases"]:
                source = snapshot / FORMAL / phase["proof"]
                names = scan_proof(source)
                copied = formal / source.name
                shutil.copyfile(source, copied)
                log = command(prefix + phase["id"] + "-lean", [lean, "-o", str(copied.with_suffix(".olean")),
                              copied.name], formal)
                audit_assumptions(log, len(names))
                for test in phase["tests"]:
                    trace_names = {"ZeroArgumentCallRegressionTest": "zero-calls.tsv",
                                   "BuiltinIdentityRegressionTest": "builtin-identities.tsv"}
                    trace_name = trace_names.get(test.rsplit(".", 1)[-1])
                    test_args = [str(build / trace_name)] if trace_name else []
                    command(prefix + phase["id"] + "-" + test.rsplit(".", 1)[-1],
                            ["java", "-ea", "-Xmx1g", "-cp", str(classes) + os.pathsep + str(snapshot / "lib/*"),
                             test, *test_args], snapshot)
            if any(p["parent"] == "P5-15" for p in config["phases"]):
                source, count = builtin_trace_program(build / "builtin-identities.tsv")
                trace_proof = formal / "BuiltinReplay.lean"
                trace_proof.write_text(source, encoding="utf-8")
                log = command(prefix + "builtin-replay", [lean, "-o", "BuiltinReplay.olean", trace_proof.name],
                              formal, {"LEAN_PATH": str(formal)})
                audit_assumptions(log, count)
                with (build / "builtin-identities.tsv").open(encoding="utf-8", newline="") as stream:
                    original_rows = list(csv.DictReader(stream, delimiter="\t"))
                for field, value in (("source_kind", "USER"), ("semantic_identity", "alloy/builtin/univ"),
                                     ("source_preservation_sat", "true")):
                    changed = [dict(row) for row in original_rows]
                    changed[0][field] = value
                    bad_trace = build / ("builtin-mutant-" + field + ".tsv")
                    with bad_trace.open("w", encoding="utf-8", newline="") as stream:
                        writer = csv.DictWriter(stream, fieldnames=BUILTIN_FIELDS, delimiter="\t")
                        writer.writeheader()
                        writer.writerows(changed)
                    negative = formal / "RejectBuiltin.lean"
                    negative.write_text(builtin_trace_program(bad_trace)[0], encoding="utf-8")
                    command(prefix + "builtin-reject-" + field, [lean, negative.name], formal,
                            {"LEAN_PATH": str(formal)}, reject=True)
                    negative.unlink()
            if any(p["parent"] == "P1-10" for p in config["phases"]):
                source, count = zero_trace_program(build / "zero-calls.tsv")
                trace_proof = formal / "ZeroCallReplay.lean"
                trace_proof.write_text(source, encoding="utf-8")
                log = command(prefix + "zero-call-replay", [lean, "-o", "ZeroCallReplay.olean", trace_proof.name],
                              formal, {"LEAN_PATH": str(formal)})
                audit_assumptions(log, count)
                with (build / "zero-calls.tsv").open(encoding="utf-8", newline="") as stream:
                    original_rows = list(csv.DictReader(stream, delimiter="\t"))
                for field, value in (("e2_is_end", "false"), ("e1_owner", "999999"),
                                     ("cert_callee", "wrong/callee")):
                    changed = [dict(row) for row in original_rows]
                    changed[0][field] = value
                    bad_trace = build / ("zero-mutant-" + field + ".tsv")
                    with bad_trace.open("w", encoding="utf-8", newline="") as stream:
                        writer = csv.DictWriter(stream, fieldnames=ZERO_FIELDS, delimiter="\t")
                        writer.writeheader()
                        writer.writerows(changed)
                    negative = formal / "RejectZeroCall.lean"
                    negative.write_text(zero_trace_program(bad_trace)[0], encoding="utf-8")
                    command(prefix + "zero-reject-" + field, [lean, negative.name], formal,
                            {"LEAN_PATH": str(formal)}, reject=True)
                    negative.unlink()
            # The generated theorem consumes actual javac-extracted indices.
            generated = formal / "ExtractedPolicy.lean"
            generated.write_text("import PolicyRepresentation\n"
                + "open ACGN.BoundedFive.PolicyRepresentation\n"
                + "def assignments : List Nat := " + str(mapping["constructorParameter"]) + "\n"
                + "def getters : List Nat := " + str(mapping["getterField"]) + "\n"
                + "theorem assignments_exact : assignments = [0,1,2,3] := by decide\n"
                + "theorem getters_exact : getters = [0,1,2,3] := by decide\n"
                + "theorem extracted_nominal_product {A S F U : Type} (a : ArityPolicy A)\n"
                + "    (s : SiblingQuotient S) (f : FlatLicense F) (u : UnitLicense U) :\n"
                + "    runSourceProgram (SourceProgram.mk assignments getters) (nominalArguments a s f u) =\n"
                + "    (nominalGetters (construct a s f u)).map some :=\n"
                + "  extracted_program_preserves_nominal_product _ assignments_exact getters_exact a s f u\n"
                + "#print axioms assignments_exact\n#print axioms getters_exact\n"
                + "#print axioms extracted_nominal_product\n", encoding="utf-8")
            log = command(prefix + "extracted-policy-proof", [lean, "-o", "ExtractedPolicy.olean",
                          "ExtractedPolicy.lean"], formal, {"LEAN_PATH": str(formal)})
            audit_assumptions(log, 3)
            if any(p["parent"] == "A2-06" for p in config["phases"]):
                generated_guard = formal / "ExtractedJoin.lean"
                generated_guard.write_text("import DependentJoinGuard\n"
                    + "open ACGN.BoundedFive.DependentJoinGuard\n"
                    + "def producerMinimum : Nat := " + str(guard_mapping["producer"]) + "\n"
                    + "def verifierMinimum : Nat := " + str(guard_mapping["verifier"]) + "\n"
                    + "theorem guards_exact : producerMinimum = 2 /\\ verifierMinimum = 2 := by decide\n"
                    + "theorem producer_scan_correct (kind : ChainKind) (xs : List Nat) :\n"
                    + "    guardWithMinimum producerMinimum kind xs = true <->\n"
                    + "    2 <= xs.length /\\ (kind = .JOIN -> AllFrom 2 xs 1) :=\n"
                    + "  extracted_guard_iff producerMinimum guards_exact.1 kind xs\n"
                    + "theorem verifier_scan_correct (kind : ChainKind) (xs : List Nat) :\n"
                    + "    guardWithMinimum verifierMinimum kind xs = true <->\n"
                    + "    2 <= xs.length /\\ (kind = .JOIN -> AllFrom 2 xs 1) :=\n"
                    + "  extracted_guard_iff verifierMinimum guards_exact.2 kind xs\n"
                    + "#print axioms guards_exact\n#print axioms producer_scan_correct\n"
                    + "#print axioms verifier_scan_correct\n", encoding="utf-8")
                log = command(prefix + "extracted-join-proof", [lean, "-o", "ExtractedJoin.olean",
                              "ExtractedJoin.lean"], formal, {"LEAN_PATH": str(formal)})
                audit_assumptions(log, 3)
                guard_source = snapshot / JOIN_SOURCE
                original_guard = guard_source.read_text(encoding="utf-8")
                old = "operandTypes.get(index)) < 2"
                if original_guard.count(old) != 1:
                    raise Blocked("ambiguous JOIN threshold mutation")
                guard_source.write_text(original_guard.replace(old, "operandTypes.get(index)) < 3"), encoding="utf-8")
                mutated_file = build / "join-threshold.tsv"
                command(prefix + "join-threshold-extract", ["java", "-Xmx1g", "-cp", str(extractor),
                        "JoinGuardExtractor", str(snapshot), str(mutated_file)], snapshot)
                mutant = join_mapping(mutated_file)
                negative = formal / "RejectJoinThreshold.lean"
                negative.write_text("example : " + str(mutant["producer"]) + " = (2 : Nat) := by decide\n", encoding="utf-8")
                command(prefix + "join-threshold-reject", [lean, negative.name], formal, reject=True)
                negative.unlink()
                guard_source.write_text(original_guard.replace("int index = 1;", "int index = 2;"), encoding="utf-8")
                command(prefix + "join-omitted-interior", ["java", "-Xmx1g", "-cp", str(extractor),
                        "JoinGuardExtractor", str(snapshot), str(build / "join-omitted.tsv")], snapshot, reject=True)
                enum_type = "is.fivefivefive.CanDis.theory.DependentChainKind"
                shadow = "\n    private static final class KindNames {\n" \
                         "        final " + enum_type + " JOIN = " + enum_type + ".ARROW;\n" \
                         "        final " + enum_type + " ARROW = " + enum_type + ".ARROW;\n" \
                         "    }\n    private static final KindNames DependentChainKind = new KindNames();\n"
                position = original_guard.rfind("}")
                guard_source.write_text(original_guard[:position] + shadow + original_guard[position:], encoding="utf-8")
                command(prefix + "join-shadowed-enum", ["java", "-Xmx1g", "-cp", str(extractor),
                        "JoinGuardExtractor", str(snapshot), str(build / "join-shadowed.tsv")], snapshot, reject=True)
                guard_source.write_text(original_guard, encoding="utf-8")
            if any(p["parent"] == "P2-05" for p in config["phases"]):
                generated_root = formal / "ExtractedFlatRoot.lean"
                generated_root.write_text("import FlatRootPort\n"
                    + "open ACGN.BoundedFive.FlatRootPort\n"
                    + "def requiredPortCount : Nat := " + str(root_mapping["requiredPortCount"]) + "\n"
                    + "def rootPortIndex : Int := " + str(root_mapping["rootPortIndex"]) + "\n"
                    + "theorem flat_root_exact : requiredPortCount = 1 /\\ rootPortIndex = 0 := by decide\n"
                    + "theorem extracted_root_correct (count : Nat) (index : Option Int) :\n"
                    + "    runSourceProgram (SourceProgram.mk requiredPortCount rootPortIndex) count index = true <->\n"
                    + "    index = none \\/ (count = 1 /\\ index = some 0) :=\n"
                    + "  extracted_guard_iff _ flat_root_exact.1 flat_root_exact.2 count index\n"
                    + "#print axioms flat_root_exact\n#print axioms extracted_root_correct\n", encoding="utf-8")
                log = command(prefix + "extracted-flat-proof", [lean, "-o", "ExtractedFlatRoot.olean",
                              generated_root.name], formal, {"LEAN_PATH": str(formal)})
                audit_assumptions(log, 2)
                declaration = snapshot / "src/is/fivefivefive/CanDis/theory/OperatorDeclaration.java"
                original_declaration = declaration.read_text(encoding="utf-8")
                target = "portSchemas.size() != 1"
                if original_declaration.count(target) != 1:
                    raise Blocked("ambiguous flat count mutation")
                declaration.write_text(original_declaration.replace(target, "portSchemas.size() != 2"), encoding="utf-8")
                mutated_file = build / "flat-two.tsv"
                command(prefix + "flat-two-extract", ["java", "-Xmx1g", "-cp", str(extractor),
                        "FlatRootPortExtractor", str(snapshot), str(mutated_file)], snapshot)
                mutant = flat_mapping(mutated_file)
                negative = formal / "RejectFlatTwo.lean"
                negative.write_text("example : " + str(mutant["requiredPortCount"]) + " = (1 : Nat) := by decide\n", encoding="utf-8")
                command(prefix + "flat-two-reject", [lean, negative.name], formal, reject=True)
                negative.unlink()
                declaration.write_text(original_declaration.replace("        validateFlatPort();\n", ""), encoding="utf-8")
                command(prefix + "flat-omitted-validation", ["java", "-Xmx1g", "-cp", str(extractor),
                        "FlatRootPortExtractor", str(snapshot), str(build / "flat-omitted.tsv")], snapshot, reject=True)
                license_type = "is.fivefivefive.CanDis.theory.FlatLicense"
                shadow = "\n    private static final class LicenseNames {\n" \
                         "        " + license_type + " none() { return " + license_type + ".none(); }\n" \
                         "        " + license_type + " atRootPort(int i) { return " + license_type + ".none(); }\n" \
                         "    }\n    private final LicenseNames FlatLicense = new LicenseNames();\n"
                position = original_declaration.rfind("}")
                declaration.write_text(original_declaration[:position] + shadow + original_declaration[position:], encoding="utf-8")
                command(prefix + "flat-shadowed-factory", ["java", "-Xmx1g", "-cp", str(extractor),
                        "FlatRootPortExtractor", str(snapshot), str(build / "flat-shadowed.tsv")], snapshot, reject=True)
                declaration.write_text(original_declaration, encoding="utf-8")
            source = snapshot / POLICY
            original = source.read_text(encoding="utf-8")
            for mutation, old, new in (
                ("policy-getter", "return arityPolicy;", "return ArityPolicy.exact(0);"),
                ("policy-receiver", "return arityPolicy;", "return ((AlloyOperatorPolicy) null).arityPolicy;"),
                ("policy-null", 'Objects.requireNonNull(arityPolicy, "arityPolicy")', "arityPolicy"),
                ("policy-mutability", "private final FlatLicense flatLicense;", "private FlatLicense flatLicense;")):
                if original.count(old) != 1:
                    raise Blocked("ambiguous mutation target " + mutation)
                source.write_text(original.replace(old, new), encoding="utf-8")
                command(prefix + mutation, ["java", "-Xmx1g", "-cp", str(extractor),
                        "PolicyRepresentationExtractor", str(snapshot), str(build / (mutation + ".tsv"))],
                        snapshot, reject=True)
                source.write_text(original, encoding="utf-8")
            helper = "\n    private static Objects guardReceiver(ArityPolicy p) {\n" \
                     "        if (p.equals(ArityPolicy.exact(4))) throw new IllegalStateException();\n" \
                     "        return null;\n    }\n"
            qualified = original.replace('Objects.requireNonNull(arityPolicy, "arityPolicy")',
                                         'guardReceiver(arityPolicy).requireNonNull(arityPolicy, "arityPolicy")')
            position = qualified.rfind("}")
            source.write_text(qualified[:position] + helper + qualified[position:], encoding="utf-8")
            command(prefix + "policy-effectful-qualifier", ["java", "-Xmx1g", "-cp", str(extractor),
                    "PolicyRepresentationExtractor", str(snapshot), str(build / "policy-qualifier.tsv")],
                    snapshot, reject=True)
            source.write_text(original, encoding="utf-8")
            artifacts = {str(p.relative_to(build)): digest(p)
                         for directory in (classes, formal, extractor) for p in sorted(directory.rglob("*"))
                         if p.is_file()}
            artifacts["policy.tsv"] = digest(mapping_file)
            for trace in ("zero-calls.tsv", "join.tsv", "flat.tsv", "builtin-identities.tsv"):
                if (build / trace).exists():
                    artifacts[trace] = digest(build / trace)
            write_json(build / "artifacts.json", artifacts)
            report["builds"].append({"number": number, "artifacts": artifacts})
        if report["builds"][0]["artifacts"] != report["builds"][1]["artifacts"]:
            raise Blocked("fresh build artifacts differ")
        if inputs(root) != manifest:
            raise Blocked("verification inputs changed")
        with (root / "docs/section3-repair-audit/requirements-traceability.tsv").open(encoding="utf-8") as stream:
            parents = {r["requirement_id"]: r for r in csv.DictReader(stream, delimiter="\t")}
        for claim in report["claims"]:
            claim.update(status="VERIFIED", inputRootHash=root_hash,
                         claimSha256=parents[claim["parent"]]["claim_sha256"],
                         sourceRefs=parents[claim["parent"]]["implementation_refs"].split(";"),
                         proofSha256=manifest[claim["proof"]])
        report["determinism"] = {"requiredBuilds": 2, "passedBuilds": 2, "identicalArtifacts": True}
        report["interpretation"] = ("VERIFIED applies to the five configured finite surfaces under the declared "
                                    "trusted dependencies, not universal Java or parser refinement.")
        report["status"] = "VERIFIED"
    except (Blocked, subprocess.TimeoutExpired) as error:
        report["errors"].append(str(error))
    except OSError as error:
        report["status"] = "INFRASTRUCTURE_FAILURE"
        report["errors"].append(str(error))
    finally:
        write_json(output / "report.json", report)
    print(json.dumps({k: report[k] for k in ("closureId", "status", "errors")}))
    return {"VERIFIED": 0, "BLOCKED": 1, "INFRASTRUCTURE_FAILURE": 2}[report["status"]]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()
    sys.exit(execute(args.root.resolve(), args.output.resolve()))
