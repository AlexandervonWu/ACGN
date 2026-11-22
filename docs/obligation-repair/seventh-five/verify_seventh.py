#!/usr/bin/env python3
"""Qualify the five registered seventh-batch finite surfaces in two clean builds."""

import ast
from collections import Counter
import hashlib
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
from types import ModuleType
import shutil

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts"))
from run_next_obligation_repairs import contained, require

PACKAGE = Path("docs/obligation-repair/seventh-five")
SIXTH = Path("docs/obligation-repair/sixth-five")
ENGINE = ROOT / "scripts/verify_sixth_obligation_repair.py"
ENGINE_SHA256 = "80b3c82538e1ef0b094ba48050451358cf8e7380edc956c445838af38399b351"
CONFIG_SHA256 = "105a745daa153fe87b905574eaca13cb5dc6078e79ba8b50820467d73d527ad3"
CALL_HELPER = SIXTH / "java/RawCallSourceAuthority.java"
CALL_HELPER_SHA256 = "d775d10b0330c92a6b30324915035de06a8ea533edd620313eeb839cffea74b0"
PARENTS = {
    "A2-15": "b862e84d7ff5369124ec35570dd1c4eec6878b31c213210ffd13fb553e75b81c",
    "G-08": "cbb5463a905bc30a1f410de31a1c22accca867e38ca185545b8e547d22ac7f10",
    "A2-17": "1424fff8c9cd0a2b823fe7b322e13dee255ff94422964be6992567a63b6b842b",
    "P6-13": "8a84a56322463d2907cad93c9d40a45df948b23fbdb49071c19c3de9a52bb849",
    "G-07": "a000debcc2bee801aeed70d648ed615c822c199c59be0ee05685a249532edf66",
}

# Only package names, report/diagnostic labels and the verifier-hash extensions
# are adapted. Neither the clean-build engine nor its governed predicates change.
LITERALS = {
    str(SIXTH): (str(PACKAGE), 1),
    "sixth registry digest changed": ("seventh registry digest changed", 1),
    "unexpected sixth-batch parent census": ("unexpected seventh-batch parent census", 1),
    "sixth-public-certification-v1": ("seventh-public-certification-v1", 2),
    "sixth-public-certification-v1-": ("seventh-public-certification-v1-", 1),
    "[sixth] ": ("[seventh] ", 1),
    "Run the finite sixth-batch qualification on two independent input snapshots.": (__doc__, 1),
}


CROSS_PARENT = "G-07-P6-13"
CROSS_PARENTS = ["G-07", "P6-13"]


def supplement(config):
    supplements = config.get("supplements", [])
    require(len(supplements) == 1 and supplements[0]["id"] == CROSS_PARENT
            and supplements[0]["parents"] == CROSS_PARENTS, "unregistered cross-parent control", "CLAIM_MUTATION")
    return supplements[0]


def load_runner():
    data = ENGINE.read_bytes()
    require(hashlib.sha256(data).hexdigest() == ENGINE_SHA256,
            "unregistered sixth qualification engine", "UNDECLARED_DEPENDENCY")
    tree = ast.parse(data, filename=str(ENGINE))
    counts = Counter()
    for node in ast.walk(tree):
        if isinstance(node, ast.Constant) and isinstance(node.value, str) and node.value in LITERALS:
            original = node.value
            counts[original] += 1
            node.value = LITERALS[original][0]
    require(counts == {old: n for old, (_, n) in LITERALS.items()}, "wrong package adaptation sites")
    extensions = [node for node in ast.walk(tree) if isinstance(node, ast.Tuple)
                  and all(isinstance(item, ast.Constant) for item in node.elts)
                  and tuple(item.value for item in node.elts) == (".java", ".lean")]
    require(len(extensions) == 1, "unexpected verifier-set hash expression")
    extensions[0].elts.append(ast.Constant(".py"))
    module = ModuleType("_seventh_qualification")
    module.__file__ = str(ENGINE)
    exec(compile(ast.fix_missing_locations(tree), str(ENGINE), "exec"), module.__dict__)
    module.CONFIG_SHA256 = CONFIG_SHA256
    module.PARENTS = PARENTS.copy()
    base_freeze = module.freeze
    base_read_config = module.read_config
    base_qualify = module.qualify
    base_recheck = module.recheck_evidence

    def read_config(root):
        config = base_read_config(root)
        for phase in config["phases"]:
            require(phase["theorems"] and (phase["outputs"] or phase["requiredLines"]),
                    "empty proof or observation registration", "MISSING_WITNESS")
            for key in ("proof", "witness"):
                require(contained(root, phase[key]).is_file(), "missing seventh " + key, "MISSING_INPUT")
        joint = supplement(config)
        require("proof" not in joint and "theorems" not in joint and joint["kind"] == "source-authority",
                "cross-parent control must retain its executable-only boundary", "SCOPE_LEAK")
        require(contained(root, joint["witness"]).is_file() and joint["outputs"] and joint["requiredLines"],
                "missing registered supplemental witness", "MISSING_WITNESS")
        for step in [*config["phases"], joint]:
            for name, expected in step.get("outputPins", {}).items():
                require(name in step["outputs"] and len(expected) == 64 and all(ch in "0123456789abcdef" for ch in expected),
                        "invalid registered witness fingerprint", "WITNESS_INVALID")
        return config

    def qualify(build, manifest, lean):
        result = base_qualify(build, manifest, lean)
        joint = supplement(read_config(build.source))
        out = build.path / CROSS_PARENT
        out.mkdir()
        values = {"results": str(out), "source": str(build.source), "fixtures": str(build.path / "fixtures")}
        args = [s.format_map(values) for s in joint["args"]]
        log = build.run(CROSS_PARENT + "-witness", [
            "java", "-ea", "-Xmx1g", *build.provenance, "-cp", build.probe_classpath, joint["class"], *args])
        for line in joint["requiredLines"]:
            require(line in log.read_text().splitlines(), "missing cross-parent observation: " + line, "MISSING_WITNESS")
        outputs = {}
        for relative in joint["outputs"]:
            path = contained(out, relative)
            require(path.is_file() and path.stat().st_size, "missing cross-parent witness " + relative, "MISSING_WITNESS")
            outputs[relative] = module.digest(path)
        require(all(outputs.get(p) == h for p, h in joint.get("outputPins", {}).items()),
                "changed cross-parent witness", "WITNESS_INVALID")
        shared = {"parents": CROSS_PARENTS, "evidenceType": "EXECUTED_JAVA", "scope": joint["scope"],
                  "witness": joint["witness"], "sourceSha256": manifest[joint["witness"]],
                  "observations": joint["requiredLines"], "outputSha256": outputs}
        build.record["supplements"] = result["supplements"] = {CROSS_PARENT: shared}
        module.engine.check_snapshot(build.source, manifest, fixture_git=True)
        result["witnessFiles"] = {key: output_inventory(build.path / key) for key in [*PARENTS, CROSS_PARENT]}
        return result

    def output_inventory(directory):
        paths = sorted(directory.rglob("*"))
        require(not any(p.is_symlink() for p in paths), "symlink in witness output", "WITNESS_INVALID")
        return {str(p.relative_to(directory)): module.digest(p) for p in paths if p.is_file()}

    def recheck(build_path, record, result, manifest):
        base_recheck(build_path, record, result, manifest)
        require(set(result["claims"]) == set(PARENTS) and set(result["supplements"]) == {CROSS_PARENT},
                "invalid primary/supplement census", "UNMAPPED_IMPLEMENTATION_OBJECT")
        require(result["witnessFiles"] == {key: output_inventory(build_path / key) for key in [*PARENTS, CROSS_PARENT]},
                "changed or missing governed witness material", "STALE_OR_UNBOUND_EVIDENCE")
        for relative, expected in result["supplements"][CROSS_PARENT]["outputSha256"].items():
            path = contained(build_path / CROSS_PARENT, relative)
            require(path.is_file() and module.digest(path) == expected,
                    "missing or changed cross-parent output " + relative, "STALE_OR_UNBOUND_EVIDENCE")


    def freeze():
        manifest = base_freeze()
        # Include the full preceding package as well as the new package. In
        # particular, the independently parsed CALL authority is a genuine
        # compiler input for PAIR controls. It is never built into the verifier.
        for source in (ROOT / SIXTH).rglob("*"):
            if source.is_file():
                relative = str(source.relative_to(ROOT))
                manifest[relative] = module.digest(contained(ROOT, relative))
        require(manifest.get(str(CALL_HELPER)) == CALL_HELPER_SHA256,
                "unregistered sixth CALL authority source", "UNDECLARED_DEPENDENCY")
        return dict(sorted(manifest.items()))

    class Build(module.Build):
        def compile(self, name, sources, cp=None):
            if name == "producer":
                self.run("qualification-guard-controls",
                         [sys.executable, "-B", self.source / PACKAGE / "verify_seventh.py", "--check-controls"])
            if name == "source-authority-probes":
                sources = [*sources, self.source / CALL_HELPER]
            output = super().compile(name, sources, cp)
            if name == "source-authority-probes":
                self.probe_classpath = str(cp) + ":" + str(output)
            return output

        def run(self, name, args, cwd=None, *, expected=0, extra=None):
            if name.endswith("-witness"):
                self.provenance = [arg for arg in args if isinstance(arg, str) and arg.startswith("-Dacgn.")]
                for key in ("PRODUCER_CLASSES", "VERIFIER_CLASSES", "VERIFIER_TEST_CLASSES", "VERIFIER_JAR"):
                    self.env["ACGN_SEVENTH_" + key] = self.env["ACGN_SIXTH_" + key]
                args = [self.path / "verifier-jar.jar" if x == "@verifierJar" else x for x in args]
            return super().run(name, args, cwd, expected=expected, extra=extra)

    module.freeze = freeze
    module.read_config = read_config
    module.qualify = qualify
    module.recheck_evidence = recheck
    module.Build = Build
    return module


def guard_controls(runner):
    """Challenge the governance and evidence checks in a disposable witness."""
    def expect_block(code, action):
        try:
            action()
        except runner.Blocked as err:
            require(str(err).startswith(code + ":"), f"wrong control outcome: {err}", "VERIFIER_FAILURE")
        else:
            raise runner.Blocked("VERIFIER_FAILURE: expected " + code)

    config = runner.read_config(ROOT)
    with TemporaryDirectory(prefix="seventh-guards-") as temporary:
        fake = Path(temporary)
        registry = fake / runner.CONFIG
        registry.parent.mkdir(parents=True)
        swapped = dict(config, phases=config["phases"].copy())
        swapped["phases"][0] = dict(swapped["phases"][1], parent=config["phases"][0]["parent"])
        runner.write_json(registry, swapped)
        expect_block("CLAIM_MUTATION", lambda: runner.read_config(fake))
        for path in (runner.CONFIG, runner.SCOPE, runner.engine.MATRIX, runner.LEDGER):
            (fake / path).parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / path, fake / path)
        ledger = fake / runner.LEDGER
        source = ledger.read_text()
        phrase = "Construction occurs only for a concrete source application already recorded"
        require(source.count(phrase) == 1, "missing ledger control anchor")
        ledger.write_text(source.replace(phrase, "A changed unregistered statement"))
        expect_block("CLAIM_MUTATION", lambda: runner.read_config(fake))
        # An altered retained evidence file must block even if the in-memory
        # build result and recorded canonical hash are internally consistent.
        evidence = fake / "evidence.json"
        runner.write_json(evidence, {})
        sealed = runner.digest(evidence)
        runner.write_json(evidence, {"altered": True})
        expect_block("STALE_OR_UNBOUND_EVIDENCE", lambda: runner.recheck_evidence(
            fake, {"evidenceFileSha256": sealed, "evidenceHash": runner.sha_json({})}, {}, {}))
    print("Three qualification controls rejected: substituted registration, changed parent text, altered evidence.")


if __name__ == "__main__":
    runner = load_runner()
    if sys.argv[1:] == ["--check-controls"]:
        guard_controls(runner)
    else:
        sys.exit(runner.main())
