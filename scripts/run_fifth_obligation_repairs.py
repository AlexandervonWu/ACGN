#!/usr/bin/env python3
"""Frozen v2.17 profile of the unchanged two-clean-build closure engine.

The counted AST adaptation affects only package literals and Lean mutual-scope
inventory. All previous runners remain byte-identical. Finite observation
replays supplement general Lean contracts; neither is whole-JVM refinement.
"""

import ast
from collections import Counter
import hashlib
from pathlib import Path
import re
import sys
from types import ModuleType

sys.dont_write_bytecode = True
from run_submission_container_closure import Blocked
from fifth_obligation_replays import AREAS

PACKAGE = Path("docs/obligation-repair/fifth-five")
CONFIG = PACKAGE / "closure-config.json"
PLUGIN = "scripts/fifth_obligation_replays.py"
BASE_SHA256 = "d3006d1b0e093cd7fc5e9c277c19a36e0828329dc6c4f3cacff7201ef8c48f55"
PARENT_HASHES = {
    "P3-04": "3991aa4c4db10ffcd0bcc1bc0197fda0b30377e422d4804b44dd05fd89bdab89",
    "P3-05": "55424471ff9ad348d3c3603257809bba4b768fcf53a389c5cb7c799e490ab620",
    "P3-06": "fa0ab4cd0e16850dd0ec8bdb39c2043837ae3c20ead8ea771b5daafe002a1c67",
    "P3-12": "981e681a6eac0f86c48a4aa9a4c95d01b6dafea2492683b66f22eb05f7fe0313",
    "A2-12": "7238742b9ecea6ad607bbb6fc152d0226175bb229caa2ed5a69352dd5f5aafae"
}
SCOPES = {
    "P3-04": "General structural law-record codec and exact registry reconstruction contract, connected to a fixed independent census of producer and public verifier observations and compiler-resolved source controls. Whole-JVM and general parser refinement are excluded; hash collision resistance remains trusted.",
    "P3-05": "General complete flat-record source, splice and application-trace reconstruction contract, connected to finite producer and independent verifier observations. Exact source-tree order and typed flattening barriers are retained. No new flattening law or whole-Java refinement is claimed.",
    "P3-06": "General complete container-record input, output and quotient-fiber reconstruction contract, with independent finite producer/verifier observations distinguishing Seq order, Bag multiplicity and Set quotienting. Container law admission remains independently required.",
    "P3-12": "General canonical wire-table grammar, ordering and content-ID preimage contract, connected to finite writer and independent decoder observations and compiler-resolved source controls. SHA-256 and its collision resistance are trusted; hash injectivity and whole-codec refinement are not claimed.",
    "A2-12": "General deterministic phase/child occurrence-path and retained dependent-source structural commitment contract, connected to finite adapter observations and source controls. The certified retained source tree is the boundary; P1-19 raw-source authority and whole-parser reconstruction remain separate obligations."
}
PARENTS = frozenset(PARENT_HASHES)
PROOF_DEPENDENCIES = ()
NOTES = ("law-record-notes.md", "flat-container-notes.md", "wire-tables-notes.md",
         "source-bindings-notes.md", "harness-notes.md")
AREA_TESTS = tuple("scripts/test_" + area["plugin"] for area in AREAS)
REQUIRED_INPUTS = frozenset({
    "scripts/run_fifth_obligation_repairs.py", "scripts/test_fifth_obligation_repairs.py",
    "scripts/third_obligation_replays.py", PLUGIN,
    *(str(PACKAGE / name) for name in NOTES), *AREA_TESTS,
    *("scripts/" + area["plugin"] for area in AREAS),
})
PASS_CONDITION = {
    "type": "all",
    "checks": ["original-parent-hash", "frozen-inputs-and-verifiers", "audited-lean-proofs",
               "all-configured-java-tests", "strict-area-censuses", "kernel-checked-replays",
               "negative-and-source-controls-exit-1", "two-fresh-builds",
               "deterministic-artifacts-and-provenance", "bound-machine-evidence"],
}
BLOCK_CONDITIONS = [
    "CLAIM_MUTATION", "INPUT_MUTATION", "UNDECLARED_DEPENDENCY", "VERIFIER_FAILURE",
    "VERIFIER_NOT_RUN", "STALE_OR_UNBOUND_EVIDENCE", "UNMAPPED_IMPLEMENTATION_OBJECT",
    "AMBIGUOUS_CORRESPONDENCE", "MISSING_WITNESS", "WITNESS_INVALID", "CLEAN_BUILD_FAILURE",
    "NONDETERMINISM", "ORPHAN_CLAIM", "SCOPE_LEAK",
]


def check_rejection(label, content):
    """Require the registered rejection, not just an unsuccessful process."""
    if re.search(r"Could not find or load main class|ClassNotFoundException|unknown module prefix|"
                 r"object file .* does not exist|no such file or directory|\bPANIC\b|"
                 r"OutOfMemoryError|StackOverflowError|Segmentation fault", content, re.I):
        raise OSError("Control infrastructure failure: " + label)
    source = re.search(r"(?:^|-)source-reject-(law|records|wire|source)-", label)
    if source:
        first, *tail = content.splitlines() or [""]
        prefix = 'Exception in thread "main" java.lang.IllegalArgumentException: UNMODELED_SOURCE:'
        valid = first.startswith(prefix) and all(re.fullmatch(
            r"[A-Za-z_][\w.-]* observed [0-9a-f]{64} [0-9a-f]{64}|\tat [^\n]+|", line)
            for line in tail)
    else:
        valid = bool(re.search(r"(?:^|-)reject-(law|records|wire|source)-", label))
        in_proposition, errors = False, 0
        for line in content.splitlines():
            if in_proposition:
                if line == "is false":
                    in_proposition = False
                elif not line.startswith((" ", "\t")):
                    valid = False
            elif re.fullmatch(r"[^\n]+\.lean:\d+:\d+: error: Tactic `decide` proved that the proposition", line):
                in_proposition = True
                errors += 1
            elif line and not re.fullmatch(r"'[^']+' (?:does not depend on any axioms|depends on axioms: \[[^\n]*\])", line):
                valid = False
        valid = valid and errors > 0 and not in_proposition
    if not valid:
        raise Blocked("VERIFIER_FAILURE: unrelated rejection diagnostic: " + label)


def check_java_version(label, content):
    patterns = {"java-version": r'(?:openjdk|java) version "17(?:[.\-+\"]|$)',
                "javac-version": r'javac 17(?:[.\-+\s]|$)'}
    if label in patterns and not re.match(patterns[label], content):
        raise Blocked("UNDECLARED_DEPENDENCY: JDK 17 required: " + label)


LITERALS = {
    "docs/obligation-repair/next-five": (str(PACKAGE), 1),
    "scripts/next_obligation_replays.py": (PLUGIN, 1),
    "scripts/test_next_obligation_repairs.py": ("scripts/test_fifth_obligation_repairs.py", 2),
    "[next-five] ": ("[fifth-five] ", 1),
    "_next_obligation_replays_": ("_fifth_obligation_replays_", 1),
    "next-five-v2.13-": ("fifth-five-v1-", 1),
    "*.json": ("closure-config.json", 1),
    "*.tsv": ("closure-config.json", 1),
    r"\s*(namespace|section)(?:\s+([\w'.]+))?\s*":
        (r"\s*(namespace|section|mutual)(?:\s+([\w'.]+))?\s*", 1),
}


def adapted_tree(source, filename):
    tree = ast.parse(source, filename=filename)
    counts = Counter()
    for node in ast.walk(tree):
        if isinstance(node, ast.Constant) and isinstance(node.value, str) and node.value in LITERALS:
            old = node.value
            node.value = LITERALS[old][0]
            counts[old] += 1
    if counts != Counter({old: count for old, (_, count) in LITERALS.items()}):
        raise Blocked("UNDECLARED_DEPENDENCY: v2.13 adaptation sites changed")
    return tree


def load_runner():
    path = Path(__file__).with_name("run_next_obligation_repairs.py")
    source = path.read_bytes()
    if hashlib.sha256(source).hexdigest() != BASE_SHA256:
        raise Blocked("UNDECLARED_DEPENDENCY: unsupported v2.13 engine hash")
    module = ModuleType("_fifth_five_engine")
    module.__file__ = str(path)
    exec(compile(adapted_tree(source.decode("utf-8"), str(path)), str(path), "exec"), module.__dict__)
    module.PARENTS = PARENTS
    module.__doc__ = __doc__
    base_validate, base_commands = module.validate_config, module.Commands

    class Commands(base_commands):
        def run(self, label, argv, cwd, extra=None, reject=False):
            log = super().run(label, argv, cwd, extra, reject)
            try:
                if reject:
                    check_rejection(label, log.read_text(encoding="utf-8"))
                if label in ("java-version", "javac-version"):
                    check_java_version(label, log.read_text(encoding="utf-8"))
            except (Blocked, OSError) as error:
                self.report["commands"][-1]["status"] = (
                    "BLOCKED" if isinstance(error, Blocked) else "INFRASTRUCTURE_FAILURE")
                raise
            if label == "plugin-tests":
                for relative in AREA_TESTS:
                    module.require((cwd / relative).is_file(), "missing encoder tests", "MISSING_INPUT")
                    super().run("area-tests-" + Path(relative).stem, [sys.executable, cwd / relative], cwd)
            return log

    def validate_config(config):
        plan = base_validate(config)
        require = module.require
        require(config.get("profile") == "fifth-five-v1" and config.get("replayPlugin") == PLUGIN,
                "unknown fifth-five profile/plugin")
        require(REQUIRED_INPUTS <= set(config.get("inputs", [])), "missing fifth-five dependency")
        require(config.get("proofDependencies") == list(PROOF_DEPENDENCIES),
                "fifth-five proof dependencies changed", "UNDECLARED_DEPENDENCY")
        for phase in config["phases"]:
            parent = phase["parent"]
            require(phase["scope"] == SCOPES[parent], "frozen scope changed", "CLAIM_MUTATION")
            area = next(area for area in AREAS if parent in area["parents"])
            require(phase["id"] == "FV-" + parent and phase["claimSha256"] == PARENT_HASHES[parent],
                    "original parent identity changed", "CLAIM_MUTATION")
            require(phase.get("passCondition") == PASS_CONDITION and phase.get("blockConditions") == BLOCK_CONDITIONS,
                    "required predicates changed", "CLAIM_MUTATION")
            require(phase["proof"] == area["proof"] and phase["replays"] == [area["replay"]],
                    "area proof mapping changed", "UNMAPPED_IMPLEMENTATION_OBJECT")
            require({"class": area["test"], "args": [], "output": area["trace"]}
                    in [module.test_spec(t) for t in phase["tests"]], "missing area trace test", "MISSING_WITNESS")
        require({e["class"] for e in config["extractors"]} == {a["extractor"] for a in AREAS},
                "extractor census changed", "UNMAPPED_IMPLEMENTATION_OBJECT")
        for area in AREAS:
            spec = next(e for e in config["extractors"] if e["class"] == area["extractor"])
            require(spec["source"] == "scripts/java/" + area["extractor"] + ".java"
                    and spec["output"] == area["sourceTrace"], "extractor mapping changed")
        return dict(plan, proofs=[*PROOF_DEPENDENCIES, *plan["proofs"]])

    module.validate_config = validate_config
    module.Commands = Commands
    return module


def execute(root, output, config_path=CONFIG):
    return load_runner().execute(root, output, config_path)


if __name__ == "__main__":
    sys.exit(load_runner().main())
