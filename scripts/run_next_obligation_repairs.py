#!/usr/bin/env python3
"""Run the frozen v2.13 next-five package in exactly two clean builds.

Config (JSON, duplicate keys forbidden): schemaVersion=1, leanVersion="4.33.0",
requiredCleanBuilds=2, timeoutSeconds, trusted/excluded/permittedNondeterminism
string lists, networkDuringVerification=false, and statusPolicy containing
unresolvedIsBlocking=true and manualOverrideAllowed=false. Exactly five phases
have id, parent, claimSha256, scope, proof (a basename in FORMAL), tests, replays.
Tests are class names or {"class": name, "output": "trace.tsv", "args": []}; an
output path is appended after args. Repeated classes must have identical specs.
Each phase lists nonempty replay basenames. Repeated proofs/replays run once.
Extractors are {"id", "source", "class", "output"} objects; optional sources
lists extra javac helpers and javaOutputs lists generated Java files to compile.
An extractor receives snapshot-root and build/output as its two arguments.

Optional replayPlugin defaults to scripts/next_obligation_replays.py. Its
generate(build, formal) returns [("Replay.lean", source, positive_theorem_count)],
and negatives(build, formal) returns [(label, "Reject.lean", source)]. Both lists
must be nonempty; replay filenames and negative labels must be unique. Negative
filenames may repeat in their isolated control directories. Negative Lean
commands must exit exactly 1. The plugin may
read build/*.tsv, extracted maps, and build/source; it may raise Blocked.
Source controls are config sourceMutations objects {label, source, old, new,
extractor} or plugin source_mutations() tuples
(label, sourceRelative, old, new, extractorClass). The extractor class (or config
ID) must reject each source control with exit 1. Targets must be
unique literal replacements in snapshots, which are restored even on failure.
Additional frozen files can be listed in inputs. Config defaults to
docs/obligation-repair/next-five/closure-config.json; --config overrides it.
"""

from __future__ import annotations

import argparse
from collections import Counter
from contextlib import contextmanager, redirect_stderr, redirect_stdout
import csv
import hashlib
import importlib.util
import inspect
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess
import sys
import traceback

sys.dont_write_bytecode = True
from run_bounded_obligation_repairs import pinned_lean_environment
from run_submission_container_closure import (
    Blocked, audit_assumptions, canonical_bytes, digest, scan_proof,
    unique_object, write_json,
)
from check_rewrite_dispatch_parity import ParityError, strip_lean_comments

PACKAGE = Path("docs/obligation-repair/next-five")
CONFIG = PACKAGE / "closure-config.json"
FORMAL = Path("docs/section3-repair-audit/formal")
MATRIX = Path("docs/section3-repair-audit/requirements-traceability.tsv")
PARENTS = frozenset({"P2-06", "A2-01", "A2-02", "P1-08", "P1-05"})
PLUGIN = "scripts/next_obligation_replays.py"
IDENTIFIER = r"[A-Za-z_][A-Za-z0-9_.-]*"
JAVA_CLASS = r"[A-Za-z_$][\w$]*(?:\.[A-Za-z_$][\w$]*)*"
STATES = {"VERIFIED": 0, "BLOCKED": 1, "INFRASTRUCTURE_FAILURE": 2}


def require(condition, message, code="INVALID_CONFIG"):
    if not condition:
        raise Blocked(code + ": " + message)


def relative_path(value):
    require(isinstance(value, str) and value and "\\" not in value
            and not any(ord(c) < 32 for c in value), "invalid relative path")
    path = Path(value)
    require(not path.is_absolute() and ".." not in path.parts
            and path.as_posix() == value and value != ".", "noncanonical relative path: " + value)
    return path


def contained(root, relative):
    path = root / relative_path(str(relative))
    require(path.resolve().is_relative_to(root.resolve()), "path escapes input root: " + str(relative))
    require(not any(p.is_symlink() for p in (path, *path.parents) if p != root and p.is_relative_to(root)),
            "symlink in frozen path: " + str(relative))
    return path


def strings(value, label, nonempty=True):
    require(isinstance(value, list) and (value or not nonempty)
            and all(isinstance(s, str) and s.strip() for s in value), label + " must be a string list")
    require(len(set(value)) == len(value), "duplicate " + label)
    return value


def lean_filename(value):
    require(isinstance(value, str) and re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*\.lean", value),
            "proof/replay must be a Lean module basename")
    return value


def test_spec(value):
    spec = {"class": value} if isinstance(value, str) else value
    require(isinstance(spec, dict) and set(spec) <= {"class", "output", "args"}, "invalid test spec")
    require(isinstance(spec.get("class"), str) and re.fullmatch(JAVA_CLASS, spec["class"]),
            "invalid test class")
    args = spec.get("args", [])
    require(isinstance(args, list) and all(isinstance(s, str) and "\x00" not in s for s in args),
            "test args must be strings")
    result = {"class": spec["class"], "args": args}
    if "output" in spec:
        result["output"] = output_path(spec["output"]).as_posix()
    return result


def output_path(value):
    path = relative_path(value)
    require(path.parts[0] not in {"source", "classes", "formal", "extractor", "controls"}
            and path.name not in {"artifacts.json", "build-evidence.json"}, "reserved output path")
    return path


def validate_config(config):
    require(isinstance(config, dict), "config must be an object")
    require(type(config.get("schemaVersion")) is int and config["schemaVersion"] == 1,
            "unsupported schemaVersion")
    require(config.get("leanVersion") == "4.33.0", "Lean must be explicitly pinned to 4.33.0")
    require(type(config.get("requiredCleanBuilds")) is int and config["requiredCleanBuilds"] == 2,
            "exactly two clean builds required")
    require(type(config.get("timeoutSeconds")) is int and 0 < config["timeoutSeconds"] <= 3600,
            "timeoutSeconds must be in 1..3600")
    require(config.get("networkDuringVerification") is False, "verification must be offline")
    policy = config.get("statusPolicy")
    require(isinstance(policy, dict) and policy.get("unresolvedIsBlocking") is True
            and policy.get("manualOverrideAllowed") is False
            and policy.get("warningIsBlocking", True) is True, "unsupported status policy")
    for key in ("trusted", "excluded", "permittedNondeterminism"):
        strings(config.get(key), key, nonempty=key != "permittedNondeterminism")
    relative_path(config.get("replayPlugin", PLUGIN))
    for path in strings(config.get("inputs", []), "inputs", nonempty=False):
        relative_path(path)
    phases = config.get("phases")
    require(isinstance(phases, list) and len(phases) == 5 and all(isinstance(p, dict) for p in phases),
            "exactly five phases required")
    parents, ids, tests, outputs = set(), set(), {}, set()
    proofs, replays = [], set()
    for phase in phases:
        ident, parent = phase.get("id"), phase.get("parent")
        require(isinstance(ident, str) and re.fullmatch(IDENTIFIER, ident) and ident not in ids,
                "invalid/duplicate phase ID")
        require(isinstance(parent, str) and parent in PARENTS and parent not in parents,
                "unexpected/duplicate parent")
        ids.add(ident)
        parents.add(parent)
        require(isinstance(phase.get("scope"), str) and phase["scope"].strip(), "empty phase scope")
        require(isinstance(phase.get("claimSha256"), str)
                and re.fullmatch(r"[0-9a-f]{64}", phase["claimSha256"]), "invalid frozen claim SHA")
        proof = lean_filename(phase.get("proof"))
        if proof not in proofs:
            proofs.append(proof)
        for replay in strings(phase.get("replays"), "phase replays"):
            replays.add(lean_filename(replay))
        require(isinstance(phase.get("tests"), list) and phase["tests"], "empty phase tests")
        seen = set()
        for entry in phase["tests"]:
            spec = test_spec(entry)
            name = spec["class"]
            require(name not in seen, "duplicate test within phase")
            seen.add(name)
            require(name not in tests or tests[name] == spec, "inconsistent shared test: " + name)
            if name not in tests and "output" in spec:
                require(spec["output"] not in outputs, "duplicate output path")
                outputs.add(spec["output"])
            tests[name] = spec
    require(parents == PARENTS and not set(proofs) & replays, "invalid proof/replay mapping")
    extractors = config.get("extractors")
    require(isinstance(extractors, list) and extractors, "nonempty extractors required")
    extractor_ids, extractor_classes = set(), set()
    for extractor in extractors:
        require(isinstance(extractor, dict), "invalid extractor")
        ident = extractor.get("id")
        require(isinstance(ident, str) and re.fullmatch(IDENTIFIER, ident) and ident not in extractor_ids,
                "invalid/duplicate extractor ID")
        extractor_ids.add(ident)
        name = extractor.get("class")
        require(isinstance(name, str) and re.fullmatch(JAVA_CLASS, name) and name not in extractor_classes,
                "invalid/duplicate extractor class")
        extractor_classes.add(name)
        for path in [extractor.get("source"), *strings(extractor.get("sources", []), "extractor sources", False)]:
            require(relative_path(path).suffix == ".java", "extractor source must be Java")
        for path in [extractor.get("output"), *strings(extractor.get("javaOutputs", []), "Java outputs", False)]:
            output_path(path)
            require(path not in outputs, "duplicate output path: " + path)
            outputs.add(path)
        require(all(p.endswith(".java") for p in extractor.get("javaOutputs", [])), "non-Java output")
    aliases = {}
    for extractor in extractors:
        for alias in (extractor["id"], extractor["class"]):
            require(alias not in aliases or aliases[alias] == extractor["id"], "ambiguous extractor ID/class")
            aliases[alias] = extractor["id"]
    require(not any(Path(a) in Path(b).parents for a in outputs for b in outputs if a != b),
            "overlapping output paths")
    mutations = config.get("sourceMutations", [])
    require(isinstance(mutations, list), "sourceMutations must be a list")
    for mutation in mutations:
        require(isinstance(mutation, dict) and set(mutation) == {"label", "source", "old", "new", "extractor"},
                "invalid source mutation")
        mutation_spec(tuple(mutation[k] for k in ("label", "source", "old", "new", "extractor")),
                      extractor_ids | extractor_classes)
    return {"proofs": proofs, "tests": list(tests.values()), "replays": sorted(replays)}


def read_config(path):
    require(path.is_file(), "missing frozen config: " + str(path), "MISSING_INPUT")
    try:
        config = json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
    except (ValueError, UnicodeError) as error:
        raise Blocked("INVALID_CONFIG: " + str(error)) from error
    validate_config(config)
    return config


def read_tsv(path, fields=None, keys=None, expected_keys=None):
    """Strict nonempty TSV reader available to plugins; census is never inferred."""
    require(path.is_file(), "missing TSV: " + str(path), "MISSING_WITNESS")
    try:
        with path.open(encoding="utf-8", newline="") as stream:
            reader = csv.DictReader(stream, delimiter="\t", strict=True)
            header = reader.fieldnames
            require(header and len(header) == len(set(header)) and all(header)
                    and (fields is None or header == list(fields)), "unexpected TSV schema", "WITNESS_INVALID")
            rows = list(reader)
    except (csv.Error, UnicodeError) as error:
        raise Blocked("WITNESS_INVALID: " + str(error)) from error
    require(rows, "empty TSV census", "MISSING_WITNESS")
    for row in rows:
        require(set(row) == set(header) and all(isinstance(v, str)
                and not any(ord(c) < 32 or ord(c) == 127 for c in v) for v in row.values()),
                "malformed TSV row", "WITNESS_INVALID")
    if keys is not None:
        require(keys and set(keys) <= set(header), "invalid TSV key columns", "WITNESS_INVALID")
        observed = [tuple(row[k] for k in keys) for row in rows]
        require(all(all(key) for key in observed) and len(set(observed)) == len(observed),
                "empty/duplicate TSV key", "AMBIGUOUS_CORRESPONDENCE")
        if expected_keys is not None:
            require(set(observed) == set(expected_keys), "incomplete/unexpected TSV census", "MISSING_WITNESS")
    else:
        require(expected_keys is None, "expected TSV census requires key columns")
    return rows


def check_matrix(root, config):
    rows = read_tsv(root / MATRIX, keys=["requirement_id"])
    by_parent = {row["requirement_id"]: row for row in rows}
    result = {}
    for phase in config["phases"]:
        row = by_parent.get(phase["parent"])
        require(row is not None, "missing matrix parent " + phase["parent"], "ORPHAN_CLAIM")
        require(row.get("claim_sha256") == phase["claimSha256"],
                "frozen parent SHA differs: " + phase["parent"], "CLAIM_MUTATION")
        refs = row.get("implementation_refs", "").split(";")
        require(all(refs), "empty parent source mapping", "UNMAPPED_IMPLEMENTATION_OBJECT")
        for ref in refs:
            require(contained(root, ref.split("#", 1)[0]).is_file(),
                    "missing parent source reference: " + ref, "UNMAPPED_IMPLEMENTATION_OBJECT")
        result[phase["parent"]] = row
    return result


def inputs(root, config, config_path=CONFIG):
    paths = set()
    for directory in ("src", "certificate-verifier", "lib"):
        require((root / directory).is_dir(), "missing input directory " + directory, "MISSING_INPUT")
        paths.update(p for p in (root / directory).rglob("*") if p.is_file()
                     and "__pycache__" not in p.parts)
    for pattern in (str(FORMAL / "**/*.lean"), "scripts/**/*.py", "scripts/**/*.sh",
                    "scripts/java/**/*.java", ".github/workflows/*",
                    str(PACKAGE / "*.json"), str(PACKAGE / "*.tsv")):
        paths.update(p for p in root.glob(pattern) if p.is_file())
    required = [config_path, "lean-toolchain", MATRIX,
                "docs/section3-repair-audit/claim-ledger.md", "docs/section3-repair-audit/assurance-scope.tsv",
                ".github/workflows/bounded-ci.yml", "scripts/run_bounded_ci_java_tests.sh",
                "scripts/run_next_obligation_repairs.py", "scripts/test_next_obligation_repairs.py",
                "scripts/test_next_obligation_replays.py",
                "scripts/run_bounded_obligation_repairs.py", "scripts/run_submission_container_closure.py",
                "scripts/check_rewrite_dispatch_parity.py", config.get("replayPlugin", PLUGIN),
                *config.get("inputs", []), *(FORMAL / p["proof"] for p in config["phases"])]
    for extractor in config["extractors"]:
        required.extend([extractor["source"], *extractor.get("sources", [])])
    for relative in required:
        path = contained(root, relative)
        require(path.is_file(), "missing frozen input: " + str(relative), "MISSING_INPUT")
        paths.add(path)
    return {p.relative_to(root).as_posix(): digest(contained(root, p.relative_to(root))) for p in sorted(paths)}


def check_snapshot(snapshot, manifest, fixture_git=False):
    if fixture_git:
        require((snapshot / ".git").is_dir() and not (snapshot / ".git").is_symlink(),
                "missing local fixture Git metadata", "INPUT_MUTATION")
    actual = {p.relative_to(snapshot).as_posix(): digest(contained(snapshot, p.relative_to(snapshot)))
              for p in snapshot.rglob("*") if p.is_file()
              and not (fixture_git and p.relative_to(snapshot).parts[0] == ".git")}
    require(actual == manifest, "snapshot differs from frozen inputs", "INPUT_MUTATION")


def make_snapshot(root, snapshot, manifest):
    snapshot.mkdir(parents=True, exist_ok=False)
    for relative, expected in manifest.items():
        source = contained(root, relative)
        require(source.is_file() and digest(source) == expected, "input changed: " + relative, "INPUT_MUTATION")
        target = snapshot / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
    check_snapshot(snapshot, manifest)


def proof_inventory(path):
    try:
        names = scan_proof(path)
        source = strip_lean_comments(path.read_text(encoding="utf-8"))
    except (ParityError, UnicodeError) as error:
        raise Blocked("WITNESS_INVALID: " + str(error)) from error
    scopes, declarations, requests = [], [], []
    for line in source.splitlines():
        namespace = ".".join(name for kind, name in scopes if kind == "namespace")
        scope = re.fullmatch(r"\s*(namespace|section)(?:\s+([\w'.]+))?\s*", line)
        end = re.fullmatch(r"\s*end(?:\s+[\w'.]+)?\s*", line)
        declaration = re.match(r"\s*(?:theorem|lemma)\s+([A-Za-z_][\w'.]*)", line)
        audit = re.fullmatch(r"\s*#print\s+axioms\s+([A-Za-z_][\w'.]*)\s*", line)
        if scope:
            scopes.append((scope[1], scope[2] or ""))
        elif end:
            require(scopes, "unmatched Lean scope end", "VERIFIER_NOT_RUN")
            scopes.pop()
        elif declaration:
            name = declaration[1]
            declarations.append(name.removeprefix("_root_.") if name.startswith("_root_.")
                                else ".".join(filter(None, (namespace, name))))
        elif audit:
            requests.append((namespace, audit[1]))
    require(names and len(declarations) == len(names) and len(declarations) == len(set(declarations)),
            "empty/ambiguous theorem inventory: " + path.name, "VERIFIER_NOT_RUN")
    prints = []
    for namespace, name in requests:
        candidates = [name.removeprefix("_root_.")] if name.startswith("_root_.") else [
            ".".join(filter(None, (".".join(namespace.split(".")[:i]), name)))
            for i in range(len(namespace.split(".")), -1, -1)]
        matched = next((candidate for candidate in candidates if candidate in declarations), None)
        require(matched is not None, "axiom audit does not name a local theorem", "VERIFIER_NOT_RUN")
        prints.append(matched)
    require(Counter(prints) == Counter(declarations), "each theorem needs exactly one axiom audit: " + path.name,
            "VERIFIER_NOT_RUN")
    # Reject declaration forms the shared scanner cannot inventory.
    forms = re.findall(r"(?m)^\s*(?:@\[[^\n]*\]\s*)?(?:(?:private|protected|noncomputable)\s+)?"
                       r"(?:theorem|lemma)\s+", source)
    require(len(forms) == len(names), "unsupported theorem declaration syntax", "VERIFIER_NOT_RUN")
    return prints


def check_proof_log(path, names):
    audit_assumptions(path, len(names))
    text = path.read_text(encoding="utf-8")
    observed = re.findall(r"'([^']+)' (?:does not depend on any axioms|depends on axioms:)", text)
    require(Counter(observed) == Counter(names), "axiom audit named the wrong declarations", "VERIFIER_FAILURE")
    require(not re.search(r"\bwarning:", text, re.IGNORECASE), "Lean warning in " + path.name, "VERIFIER_FAILURE")


def replay_specs(values, expected):
    require(isinstance(values, list) and values, "empty replay program mapping", "UNMAPPED_IMPLEMENTATION_OBJECT")
    seen = set()
    for value in values:
        require(isinstance(value, (tuple, list)) and len(value) == 3, "invalid replay plugin result")
        name, source, count = value
        lean_filename(name)
        require(name not in seen and isinstance(source, str) and source.strip()
                and type(count) is int and count > 0, "duplicate/empty replay program")
        seen.add(name)
    require(seen == set(expected), "plugin replay names differ from frozen phase mappings", "UNMAPPED_IMPLEMENTATION_OBJECT")
    return values


def negative_specs(values, positive_names):
    require(isinstance(values, list) and values, "empty negative control census", "VERIFIER_NOT_RUN")
    labels = set()
    for value in values:
        require(isinstance(value, (tuple, list)) and len(value) == 3, "invalid negative plugin result")
        label, name, source = value
        lean_filename(name)
        require(isinstance(label, str) and re.fullmatch(IDENTIFIER, label) and label not in labels
                and name not in positive_names and isinstance(source, str) and source.strip(),
                "duplicate/invalid negative control")
        labels.add(label)
    return values


def mutation_spec(value, extractors):
    require(isinstance(value, (tuple, list)) and len(value) == 5, "invalid source mutation tuple")
    label, source, old, new, extractor = value
    require(isinstance(label, str) and re.fullmatch(IDENTIFIER, label)
            and relative_path(source).suffix == ".java" and isinstance(old, str) and old
            and isinstance(new, str) and old != new and isinstance(extractor, str) and extractor in extractors,
            "invalid source mutation target/extractor")
    return value


@contextmanager
def mutated_source(snapshot, spec, manifest):
    _, source, old, new, _ = spec
    path = contained(snapshot, source)
    require(source in manifest and digest(path) == manifest[source], "mutation target is not frozen", "INPUT_MUTATION")
    original = path.read_bytes()
    text = original.decode("utf-8")
    require(text.count(old) == 1, "missing/ambiguous source mutation anchor", "VERIFIER_NOT_RUN")
    try:
        path.write_text(text.replace(old, new), encoding="utf-8")
        yield
    finally:
        path.write_bytes(original)
        require(digest(path) == manifest[source], "source restoration failed", "INPUT_MUTATION")


class Commands:
    def __init__(self, output, report, environment, timeout):
        self.output, self.report, self.environment, self.timeout = output, report, environment, timeout
        self.labels = set()

    def run(self, label, argv, cwd, extra=None, reject=False):
        require(re.fullmatch(IDENTIFIER, label) and label not in self.labels, "duplicate/invalid command label")
        self.labels.add(label)
        log = self.output / (label + ".log")
        record = {"id": label, "argv": [str(x) for x in argv], "cwd": str(cwd), "exitCode": None,
                  "log": log.name, "expectedRejection": reject, "status": "BLOCKED",
                  "closureId": self.report["closureId"], "inputRootHash": self.report["inputRootHash"],
                  "verifierHash": self.report["verifierSetHash"], "environment": self.report["environment"],
                  "environmentOverrides": extra or {}}
        print("[next-five] " + label, flush=True)
        try:
            with log.open("w", encoding="utf-8") as stream:
                try:
                    result = subprocess.run(record["argv"], cwd=cwd,
                                            env=dict(self.environment, **(extra or {})), stdout=stream,
                                            stderr=subprocess.STDOUT, timeout=self.timeout, check=False)
                    record["exitCode"] = result.returncode
                except (OSError, subprocess.TimeoutExpired) as error:
                    stream.write("\n" + str(error) + "\n")
                    record["status"] = "INFRASTRUCTURE_FAILURE"
                    raise
            code = record["exitCode"]
            if code not in (0, 1):
                record["status"] = "INFRASTRUCTURE_FAILURE"
                raise OSError(f"unregistered exit {code}: {label}")
            require(code == (1 if reject else 0), "unexpected command outcome: " + label, "VERIFIER_FAILURE")
            record["status"] = "PASS"
            return log
        finally:
            if log.is_file():
                record["sha256"] = digest(log)
            self.report["commands"].append(record)


def load_plugin(snapshot, config):
    path = snapshot / config.get("replayPlugin", PLUGIN)
    name = "_next_obligation_replays_" + hashlib.sha256(str(path).encode()).hexdigest()[:16]
    spec = importlib.util.spec_from_file_location(name, path)
    require(spec is not None and spec.loader is not None, "plugin cannot be loaded", "UNDECLARED_DEPENDENCY")
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    sys.path.insert(0, str(snapshot / "scripts"))
    try:
        spec.loader.exec_module(module)
    finally:
        sys.path.pop(0)
        sys.modules.pop(name, None)
    require(callable(getattr(module, "generate", None)) and callable(getattr(module, "negatives", None)),
            "plugin must implement generate and negatives", "VERIFIER_NOT_RUN")
    return module


def clear_snapshot_modules(snapshot):
    for name, module in list(sys.modules.items()):
        filename = getattr(module, "__file__", None)
        if filename and Path(filename).resolve().is_relative_to(snapshot):
            sys.modules.pop(name, None)


def lean_executable(environment):
    home = Path(environment.get("ELAN_HOME", str(Path.home() / ".elan")))
    selected = environment.get("LEAN_BIN") or shutil.which("lean") or str(home / "bin/lean")
    path = Path(shutil.which(selected) or selected).absolute()
    # Elan otherwise attempts a network installation when a pin is unavailable.
    if path.resolve().name == "elan":
        installed = home / "toolchains/leanprover--lean4---v4.33.0/bin/lean"
        if not installed.is_file():
            raise FileNotFoundError("offline pinned Lean 4.33.0 toolchain is not installed")
    return str(path)


def check_imports(root, snapshot, manifest):
    for module in list(sys.modules.values()):
        filename = getattr(module, "__file__", None)
        if not filename:
            continue
        path = Path(filename).resolve()
        for base in (snapshot, root, Path(__file__).resolve().parents[1]):
            if path.is_relative_to(base):
                relative = path.relative_to(base).as_posix()
                require(relative in manifest and digest(path) == manifest[relative],
                        "unhashed/changed imported verifier: " + relative, "UNDECLARED_DEPENDENCY")
                break


def artifacts(build):
    return {p.relative_to(build).as_posix(): digest(contained(build, p.relative_to(build)))
            for p in sorted(build.rglob("*"))
            if p.is_file() and p.relative_to(build).parts[0] not in {"source", "controls"}
            and p.name not in {"artifacts.json", "build-evidence.json"}}


def initialize_fixture_git(run):
    """Supply real, deterministic Git provenance solely for TEST_ONLY bundles."""
    environment = {"GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": os.devnull,
                   "GIT_AUTHOR_DATE": "2000-01-01T00:00:00+0000",
                   "GIT_COMMITTER_DATE": "2000-01-01T00:00:00+0000"}
    git = ["git", "-c", "core.hooksPath=" + os.devnull,
           "-c", "user.name=ACGN Bounded Fixture", "-c", "user.email=fixture@invalid",
           "-c", "commit.gpgsign=false"]
    run("fixture-git-init", [*git, "init", "--quiet", "--template=", "--initial-branch=closure-fixture"],
        extra=environment)
    run("fixture-git-add", [*git, "add", "--", "."], extra=environment)
    run("fixture-git-commit", [*git, "commit", "--quiet", "-m", "TEST_ONLY frozen closure inputs"],
        extra=environment)
    commit = run("fixture-git-sha", [*git, "rev-parse", "HEAD"], extra=environment).read_text().strip()
    require(re.fullmatch(r"[0-9a-f]{40}", commit), "invalid fixture Git commit", "CLEAN_BUILD_FAILURE")
    return commit


def run_build(root, output, config, manifest, report, commands, lean, version, number):
    plan = validate_config(config)
    build = output / ("build" + str(number))
    snapshot, formal = build / "source", build / "formal"
    make_snapshot(root, snapshot, manifest)
    classes, extractor_dir = build / "classes", build / "extractor"
    for directory in (formal, classes, extractor_dir):
        directory.mkdir()
    shutil.copyfile(snapshot / "lean-toolchain", formal / "lean-toolchain")
    prefix = "build" + str(number) + "-"
    command_start = len(report["commands"])

    def run(label, argv, cwd=snapshot, **kwargs):
        return commands.run(prefix + label, argv, cwd, **kwargs)

    fixture_commit = initialize_fixture_git(run)
    observed = run("lean-version", [lean, "--version"], formal).read_text(encoding="utf-8")
    require(observed == version, "isolated Lean toolchain differs", "CLEAN_BUILD_FAILURE")
    sources = sorted(str(p) for directory in ("src", "certificate-verifier/src")
                     for p in (snapshot / directory).rglob("*.java"))
    require(sources, "no Java sources", "CLEAN_BUILD_FAILURE")
    classpath = str(classes) + os.pathsep + str(snapshot / "lib/*")
    javac = ["javac", "-J-Xmx1g", "--release", "17", "-proc:none", "-encoding", "UTF-8"]
    run("compile", [*javac, "-cp", str(snapshot / "lib/*"), "-d", classes, *sources])
    # All extractor helpers are frozen, and javac resolves them together.
    extractor_sources = {str(p) for p in (snapshot / "scripts/java").rglob("*.java")}
    for extractor in config["extractors"]:
        extractor_sources.update(str(snapshot / p) for p in [extractor["source"], *extractor.get("sources", [])])
    run("extractor-compile", [*javac, "-cp", classpath, "-d", extractor_dir, *sorted(extractor_sources)])

    def extract(spec, target, label, reject=False):
        target.parent.mkdir(parents=True, exist_ok=True)
        return run(label, ["java", "-Xmx1g", "-cp", str(extractor_dir) + os.pathsep + classpath,
                           spec["class"], snapshot, target], reject=reject)

    for spec in config["extractors"]:
        target = build / spec["output"]
        extract(spec, target, "extract-" + spec["id"])
        require(target.is_file() and target.stat().st_size, "extractor produced no output", "MISSING_WITNESS")
        generated = [build / p for p in spec.get("javaOutputs", [])]
        if generated:
            require(all(p.is_file() and p.stat().st_size for p in generated), "missing generated Java", "MISSING_WITNESS")
            run("extract-javac-" + spec["id"], [*javac, "-cp", classpath, "-d", classes, *generated])

    inventory = {}
    for name in plan["proofs"]:
        shutil.copyfile(snapshot / FORMAL / name, formal / name)

    def prove(name, count=None):
        names = proof_inventory(formal / name)
        require(count is None or len(names) == count, "plugin theorem count differs from source", "VERIFIER_NOT_RUN")
        log = run("proof-" + Path(name).stem, [lean, "-o", Path(name).with_suffix(".olean"), name], formal,
                  extra={"LEAN_PATH": str(formal)})
        check_proof_log(log, names)
        require((formal / Path(name).with_suffix(".olean")).is_file(), "missing compiled proof", "MISSING_WITNESS")
        inventory[name] = names

    for name in plan["proofs"]:
        prove(name)
    for index, spec in enumerate(plan["tests"]):
        args = list(spec["args"])
        if "output" in spec:
            target = build / spec["output"]
            target.parent.mkdir(parents=True, exist_ok=True)
            args.append(str(target))
        run(f"test-{index:02d}", ["java", "-ea", "-Xmx1g", "-cp", classpath, spec["class"], *args])
        if "output" in spec:
            read_tsv(build / spec["output"])

    plugin = load_plugin(snapshot, config)
    check_imports(root, snapshot, manifest)

    def invoke(method):
        log = output / (prefix + "plugin-" + method + ".log")
        record = {"id": prefix + "plugin-" + method, "log": log.name, "exitCode": None,
                  "status": "BLOCKED", "inputRootHash": report["inputRootHash"],
                  "closureId": report["closureId"], "verifierHash": report["verifierSetHash"],
                  "environment": report["environment"], "plugin": config.get("replayPlugin", PLUGIN)}
        sys.path.insert(0, str(snapshot / "scripts"))
        try:
            with log.open("w", encoding="utf-8") as stream, redirect_stdout(stream), redirect_stderr(stream):
                try:
                    function = getattr(plugin, method)
                    args = (build, formal)
                    if method == "source_mutations":
                        try:
                            inspect.signature(function).bind(*args)
                        except TypeError:
                            inspect.signature(function).bind()
                            args = ()
                    result = function(*args)
                    check_imports(root, snapshot, manifest)
                    print("returned records:", len(result) if isinstance(result, list) else "invalid")
                    record.update(exitCode=0, status="PASS")
                    return result
                except (Exception, SystemExit) as error:
                    traceback.print_exc()
                    record.update(exitCode=1 if isinstance(error, Blocked) else 2,
                                  status="BLOCKED" if isinstance(error, Blocked) else "INFRASTRUCTURE_FAILURE")
                    raise
        finally:
            sys.path.pop(0)
            record["sha256"] = digest(log)
            report["commands"].append(record)

    before_replay = artifacts(build)
    generated = replay_specs(invoke("generate"), plan["replays"])
    after_replay = artifacts(build)
    require(all(after_replay.get(p) == h for p, h in before_replay.items()),
            "plugin changed positive inputs", "INPUT_MUTATION")
    for name, source, count in generated:
        require(not (formal / name).exists(), "plugin overwrote a proof", "INPUT_MUTATION")
        (formal / name).write_text(source, encoding="utf-8")
        prove(name, count)
    positive = artifacts(build)
    controls = negative_specs(invoke("negatives"), inventory)
    control_dir = build / "controls"
    control_dir.mkdir()
    for label, name, source in controls:
        directory = control_dir / label
        directory.mkdir()
        (directory / name).write_text(source, encoding="utf-8")
        run("reject-" + label, [lean, name], directory, extra={"LEAN_PATH": str(formal)}, reject=True)
    extractors = {key: e for e in config["extractors"] for key in (e["id"], e["class"])}
    mutations = [tuple(m[k] for k in ("label", "source", "old", "new", "extractor"))
                 for m in config.get("sourceMutations", [])]
    if callable(getattr(plugin, "source_mutations", None)):
        values = invoke("source_mutations")
        require(isinstance(values, list), "source_mutations must return a list")
        mutations.extend(values)
    require(mutations, "no source-level rejection controls", "VERIFIER_NOT_RUN")
    seen_mutations = set()
    for index, value in enumerate(mutations):
        spec = tuple(mutation_spec(value, extractors))
        require(spec[0] not in seen_mutations, "duplicate source mutation label")
        seen_mutations.add(spec[0])
        with mutated_source(snapshot, spec, manifest):
            extract(extractors[spec[4]], control_dir / f"mutation-{index:02d}.tsv",
                    "source-reject-" + spec[0], reject=True)
    check_snapshot(snapshot, manifest, fixture_git=True)
    final_commit = run("fixture-git-final-sha", ["git", "rev-parse", "HEAD"]).read_text().strip()
    final_status = run("fixture-git-final-status", ["git", "status", "--porcelain", "--untracked-files=all"]).read_text()
    require(final_commit == fixture_commit and not final_status,
            "fixture Git provenance changed", "INPUT_MUTATION")
    require(artifacts(build) == positive, "controls changed positive evidence", "INPUT_MUTATION")
    for label, name, source in controls:
        require((control_dir / label / name).read_text(encoding="utf-8") == source,
                "negative program changed after verification", "STALE_OR_UNBOUND_EVIDENCE")
    provenance = [{"id": p["id"], "parent": p["parent"], "claimSha256": p["claimSha256"],
                   "proof": p["proof"], "replays": p["replays"],
                   "tests": [test_spec(t) for t in p["tests"]], "status": "PASS"} for p in config["phases"]]
    record = {"number": number, "inputRootHash": report["inputRootHash"], "status": "PASS",
              "fixtureGitCommit": fixture_commit, "fixtureGitScope": "TEST_ONLY frozen verification inputs",
              "proofInventory": inventory, "provenance": provenance, "artifacts": positive,
              "negativeControls": [{"label": label, "filename": name,
                                     "sourceSha256": hashlib.sha256(source.encode()).hexdigest()}
                                    for label, name, source in controls],
              "controlArtifacts": {p.relative_to(control_dir).as_posix(): digest(p)
                                   for p in sorted(control_dir.rglob("*")) if p.is_file()},
              "sourceMutations": [list(s) for s in mutations],
              "commands": [c["id"] for c in report["commands"][command_start:]]}
    write_json(build / "artifacts.json", positive)
    record["artifactsFileSha256"] = digest(build / "artifacts.json")
    write_json(build / "build-evidence.json", record)
    record["evidenceSha256"] = digest(build / "build-evidence.json")
    return record


def compare_builds(builds):
    require(len(builds) == 2 and [b["number"] for b in builds] == [1, 2]
            and all(b["status"] == "PASS" for b in builds), "missing required clean build", "CLEAN_BUILD_FAILURE")
    for field in ("inputRootHash", "fixtureGitCommit", "fixtureGitScope", "proofInventory", "provenance", "artifacts", "negativeControls",
                  "controlArtifacts", "sourceMutations"):
        require(builds[0][field] and builds[0][field] == builds[1][field],
                "clean build mismatch: " + field, "NONDETERMINISM")


def execute(root, output, config_path=CONFIG):
    root, output = root.resolve(), output.resolve()
    report = {"schemaVersion": 1, "closureId": None, "inputRootHash": None, "status": "BLOCKED",
              "commands": [], "builds": [], "claims": [], "errors": [], "blockingReasons": [],
              "infrastructureErrors": [], "trusted": [], "excluded": [],
              "environment": {"platform": platform.platform(), "python": sys.version},
              "determinism": {"requiredBuilds": 2, "passedBuilds": 0, "identicalArtifacts": False},
              "interpretation": "VERIFIED applies only to the five frozen finite surfaces under the declared TCB; "
                                "not universal correctness or automatic discharge of broader parent claims.",
              "decision": {"validStates": list(STATES), "manualOverrideAllowed": False}}
    created = False
    try:
        require(not output.is_relative_to(root), "evidence output must be outside the repository")
        output.mkdir(parents=True, exist_ok=False)
        created = True
        config_file = contained(root, config_path)
        config = read_config(config_file)
        frozen_config = config_file.read_bytes()
        require(json.loads(frozen_config, object_pairs_hook=unique_object) == config,
                "config changed while being read", "INPUT_MUTATION")
        report.update(trusted=config["trusted"], excluded=config["excluded"],
                      permittedNondeterminism=config["permittedNondeterminism"])
        parents = check_matrix(root, config)
        manifest = inputs(root, config, config_path)
        require(manifest[str(config_path)] == hashlib.sha256(frozen_config).hexdigest(),
                "config changed before input freeze", "INPUT_MUTATION")
        for row in parents.values():
            require(all(ref.split("#", 1)[0] in manifest for ref in row["implementation_refs"].split(";")),
                    "parent source reference is not hashed", "UNDECLARED_DEPENDENCY")
        root_hash = hashlib.sha256(canonical_bytes(manifest)).hexdigest()
        verifiers = {p: h for p, h in manifest.items() if p.startswith("scripts/") or p.endswith((".lean", ".java"))}
        report.update(inputRootHash=root_hash, closureId="next-five-v2.13-" + root_hash[:16],
                      verifierHashes=verifiers, verifierSetHash=hashlib.sha256(canonical_bytes(verifiers)).hexdigest())
        write_json(output / "input-manifest.json", manifest)
        report["inputManifestSha256"] = digest(output / "input-manifest.json")
        report["claims"] = [dict(p, status="BLOCKED", inputRootHash=root_hash,
                                 sourceRefs=parents[p["parent"]]["implementation_refs"].split(";"),
                                 proofSha256=manifest[str(FORMAL / p["proof"])]) for p in config["phases"]]
        env = dict(os.environ, LC_ALL="C", TZ="UTC", PYTHONDONTWRITEBYTECODE="1")
        for name in list(env):
            if name.startswith("GIT_"):
                env.pop(name)
        for name in ("JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS", "_JAVA_OPTIONS", "CLASSPATH", "LEAN_PATH"):
            env.pop(name, None)
        env = pinned_lean_environment(env, (root / "lean-toolchain").read_text(encoding="utf-8"), config["leanVersion"])
        report["environment"]["ELAN_TOOLCHAIN"] = env["ELAN_TOOLCHAIN"]
        lean = lean_executable(env)
        commands = Commands(output, report, env, config["timeoutSeconds"])
        version = commands.run("lean-version", [lean, "--version"], root).read_text(encoding="utf-8")
        require(version.startswith("Lean (version 4.33.0,"), "Lean differs from frozen version", "UNDECLARED_DEPENDENCY")
        for tool in ("java", "javac"):
            log = commands.run(tool + "-version", [tool, "-version"], root)
            report["environment"][tool] = log.read_text(encoding="utf-8").strip()
        commands.run("driver-tests", [sys.executable, root / "scripts/test_next_obligation_repairs.py"], root)
        commands.run("plugin-tests", [sys.executable, root / "scripts/test_next_obligation_replays.py"], root)
        for number in (1, 2):
            try:
                record = run_build(root, output, config, manifest, report, commands, lean, version, number)
            finally:
                clear_snapshot_modules(output / f"build{number}" / "source")
            report["builds"].append(record)
            report["determinism"]["passedBuilds"] = len(report["builds"])
        compare_builds(report["builds"])
        for build in report["builds"]:
            directory = output / ("build" + str(build["number"]))
            check_snapshot(directory / "source", manifest, fixture_git=True)
            require(artifacts(directory) == build["artifacts"], "build artifacts changed after verification",
                    "STALE_OR_UNBOUND_EVIDENCE")
            for filename, key in (("artifacts.json", "artifactsFileSha256"), ("build-evidence.json", "evidenceSha256")):
                require(digest(directory / filename) == build[key], "build evidence changed",
                        "STALE_OR_UNBOUND_EVIDENCE")
            for relative, expected in build["controlArtifacts"].items():
                require(digest(contained(directory / "controls", relative)) == expected, "control evidence changed",
                        "STALE_OR_UNBOUND_EVIDENCE")
        for command in report["commands"]:
            require(digest(output / command["log"]) == command["sha256"], "command log changed",
                    "STALE_OR_UNBOUND_EVIDENCE")
        require(inputs(root, config, config_path) == manifest, "verification inputs changed", "INPUT_MUTATION")
        require(digest(output / "input-manifest.json") == report["inputManifestSha256"], "input manifest changed",
                "STALE_OR_UNBOUND_EVIDENCE")
        check_matrix(root, config)
        for claim in report["claims"]:
            claim.update(status="VERIFIED", verifierHash=report["verifierSetHash"],
                         evidence=[f"build{n}/build-evidence.json" for n in (1, 2)])
        report["determinism"]["identicalArtifacts"] = True
        report["status"] = "VERIFIED"
    except Blocked as error:
        report["errors"].append(str(error))
        code, _, message = str(error).partition(": ")
        report["blockingReasons"].append({"code": code if message and re.fullmatch(r"[A-Z_]+", code)
                                          else "VERIFIER_FAILURE",
                                          "message": message or str(error)})
    except (Exception, SystemExit) as error:
        report["status"] = "INFRASTRUCTURE_FAILURE"
        report["errors"].append(str(error))
        report["infrastructureErrors"].append({"code": "INFRASTRUCTURE_ERROR", "type": type(error).__name__,
                                              "message": str(error)})
    finally:
        report["claimCounts"] = {"total": len(report["claims"]),
                                  "passed": sum(c["status"] == "VERIFIED" for c in report["claims"])}
        report["claimCounts"]["unresolved"] = report["claimCounts"]["total"] - report["claimCounts"]["passed"]
        passed, total = report["claimCounts"]["passed"], report["claimCounts"]["total"]
        report["correspondence"] = {"requiredObjects": total, "mappedObjects": passed,
                                    "unresolvedObjects": total - passed}
        report["provenance"] = {"publicClaims": total, "fullyBound": passed, "orphanClaims": total - passed}
        witness_count = len({r for c in report["claims"] for r in c["replays"]})
        report["witnesses"] = {"required": witness_count, "valid": witness_count if passed else 0,
                               "kind": "generated replay programs checked in both builds"}
        report["dependencies"] = {"verified": [c["id"] for c in report["claims"] if c["status"] == "VERIFIED"],
                                   "trusted": report["trusted"]}
        report["closureBoundary"] = {
            "provedSurface": [str(FORMAL / c["proof"]) for c in report["claims"] if c["status"] == "VERIFIED"],
            "testedSurface": sorted({test_spec(t)["class"] for c in report["claims"]
                                     if c["status"] == "VERIFIED" for t in c["tests"]}),
            "checkedSurface": [c["scope"] for c in report["claims"] if c["status"] == "VERIFIED"],
            "trustedSurface": report["trusted"], "excludedSurface": report["excluded"],
            "interpretation": report["interpretation"]}
        if created:
            try:
                write_json(output / "report.json", report)
            except OSError as error:
                report["status"] = "INFRASTRUCTURE_FAILURE"
                report["errors"].append("cannot persist report: " + str(error))
    print(json.dumps({k: report[k] for k in ("closureId", "status", "errors")}))
    return STATES[report["status"]]


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("output", type=Path)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--config", type=Path, default=CONFIG, help="repository-relative frozen JSON config")
    args = parser.parse_args()
    return execute(args.root, args.output, args.config)


if __name__ == "__main__":
    sys.exit(main())
