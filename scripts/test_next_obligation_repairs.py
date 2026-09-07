"""Cheap parser/lifecycle tests; the lifecycle uses simulated compilers only."""

from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import run_next_obligation_repairs as runner


HERE = Path(__file__).resolve().parent
PIN = "leanprover/lean4:v4.33.0"
VERSION = "Lean (version 4.33.0, x86_64-unknown-linux-gnu, Release)\n"
PROOF = "namespace Example\ntheorem valid : True := by trivial\n#print axioms valid\nend Example\n"
REPLAY = "theorem replay : True := by trivial\n#print axioms replay\n"


def configuration():
    return {
        "schemaVersion": 1, "leanVersion": "4.33.0", "requiredCleanBuilds": 2, "timeoutSeconds": 30,
        "networkDuringVerification": False,
        "statusPolicy": {"unresolvedIsBlocking": True, "manualOverrideAllowed": False},
        "trusted": ["Lean kernel", "javac/JVM 17", "Python, SHA-256, OS, hardware"],
        "excluded": ["Unlisted claims"], "permittedNondeterminism": ["Diagnostic paths"],
        "phases": [{"id": "NF-" + p, "parent": p, "claimSha256": "a" * 64, "scope": "Finite example",
                    "proof": "Example.lean", "tests": [{"class": "example.Test", "output": "observed.tsv"}],
                    "replays": ["Replay.lean"]} for p in sorted(runner.PARENTS)],
        "extractors": [{"id": "example", "source": "scripts/java/ExampleExtractor.java",
                        "class": "ExampleExtractor", "output": "extracted.tsv"}],
    }


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def repository(root, config):
    for relative in ("src/Example.java", "certificate-verifier/src/Verifier.java",
                     "certificate-verifier/test/VerifierTest.java", "lib/example.jar",
                     "docs/section3-repair-audit/claim-ledger.md", "docs/section3-repair-audit/assurance-scope.tsv",
                     ".github/workflows/bounded-ci.yml", "scripts/run_bounded_ci_java_tests.sh",
                     "scripts/java/ExampleExtractor.java"):
        write(root / relative, "original\n")
    for source in HERE.glob("*.py"):
        target = root / "scripts" / source.name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
    write(root / runner.PLUGIN, "def generate(build, formal):\n    return []\n")
    write(root / "scripts/test_next_obligation_replays.py", "# Simulated test entry point.\n")
    write(root / "lean-toolchain", PIN + "\n")
    write(root / runner.FORMAL / "Example.lean", PROOF)
    write(root / runner.CONFIG, json.dumps(config))
    write(root / runner.MATRIX, "requirement_id\tclaim_sha256\timplementation_refs\n" + "".join(
        p + "\t" + "a" * 64 + "\tsrc/Example.java#main\n" for p in sorted(runner.PARENTS)))


class ConfigAndParserTests(unittest.TestCase):
    def test_shared_work_is_deduplicated(self):
        plan = runner.validate_config(configuration())
        self.assertEqual(plan["proofs"], ["Example.lean"])
        self.assertEqual(plan["tests"], [{"class": "example.Test", "args": [], "output": "observed.tsv"}])
        self.assertEqual(plan["replays"], ["Replay.lean"])

    def test_invalid_configs_fail_closed(self):
        cases = []
        for key, value in (("schemaVersion", True), ("requiredCleanBuilds", 0), ("requiredCleanBuilds", 1),
                           ("requiredCleanBuilds", 3), ("leanVersion", "4.33.1"), ("timeoutSeconds", True),
                           ("timeoutSeconds", 0), ("networkDuringVerification", True), ("trusted", []),
                           ("excluded", []), ("extractors", []), ("phases", [])):
            config = configuration()
            config[key] = value
            cases.append(config)
        for key, value in (("proof", ""), ("proof", "../Example.lean"), ("tests", []), ("replays", []),
                           ("claimSha256", "a" * 63), ("scope", ""), ("parent", "P2-02")):
            config = configuration()
            config["phases"][0][key] = value
            cases.append(config)
        for key in ("id", "parent"):
            config = configuration()
            config["phases"][1][key] = config["phases"][0][key]
            cases.append(config)
        config = configuration()
        config["phases"][1]["tests"][0]["output"] = "other.tsv"
        cases.append(config)
        config = configuration()
        config["phases"][0]["tests"] *= 2
        cases.append(config)
        config = configuration()
        config["extractors"] *= 2
        cases.append(config)
        config = configuration()
        config["extractors"][0]["output"] = "observed.tsv"
        cases.append(config)
        for config in cases:
            with self.subTest(config=config), self.assertRaises(runner.Blocked):
                runner.validate_config(config)

    def test_test_arguments_and_optional_output(self):
        self.assertEqual(runner.test_spec("example.Test"), {"class": "example.Test", "args": []})
        spec = {"class": "example.Test", "args": ["--finite", "3"], "output": "data/trace.tsv"}
        self.assertEqual(runner.test_spec(spec), spec)
        for output in ("/tmp/file", "../file", "a/../file", "source/F.java", "formal/F.lean", "a//b", "x\\y"):
            with self.subTest(output=output), self.assertRaises(runner.Blocked):
                runner.test_spec(dict(spec, output=output))

    def test_duplicate_json_keys_and_missing_config(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "config.json"
            for text in ('{"schemaVersion":1,"schemaVersion":1}', '{"phases":[{"id":"a","id":"b"}]}', '{'):
                write(path, text)
                with self.assertRaises(runner.Blocked):
                    runner.read_config(path)
            path.unlink()
            with self.assertRaises(runner.Blocked):
                runner.read_config(path)

    def test_tsv_exact_census(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / "trace.tsv"
            valid = "id\tvalue\na\t1\nb\t2\n"
            write(path, valid)
            self.assertEqual(len(runner.read_tsv(path, ["id", "value"], ["id"], {("a",), ("b",)})), 2)
            for bad in ("", "id\tvalue\n", "id\tid\na\tb\n", "id\tvalue\na\t1\n",
                        valid + "a\t1\n", "id\tvalue\na\t1\textra\nb\t2\n",
                        "id\tvalue\na\nb\t2\n", 'id\tvalue\na\t"line\nbreak"\nb\t2\n'):
                write(path, bad)
                with self.subTest(bad=bad), self.assertRaises(runner.Blocked):
                    runner.read_tsv(path, ["id", "value"], ["id"], {("a",), ("b",)})

    def test_replay_and_negative_contracts(self):
        self.assertEqual(runner.replay_specs([("R.lean", REPLAY, 1)], ["R.lean"])[0][2], 1)
        for values in ([], [("R.lean", REPLAY, 0)], [("R.lean", REPLAY, True)],
                       [("R.lean", "", 1)], [("R.lean", REPLAY, 1)] * 2,
                       [("Unknown.lean", REPLAY, 1)]):
            with self.subTest(values=values), self.assertRaises(runner.Blocked):
                runner.replay_specs(values, ["R.lean"])
        repeated_name = [("one", "Reject.lean", "example : False := by decide"),
                         ("two", "Reject.lean", "example : False := by decide")]
        self.assertEqual(runner.negative_specs(repeated_name, ["R.lean"]), repeated_name)
        for values in ([], repeated_name[:1] * 2, [("one", "R.lean", REPLAY)]):
            with self.assertRaises(runner.Blocked):
                runner.negative_specs(values, ["R.lean"])

    def test_all_theorem_axioms_are_named(self):
        with tempfile.TemporaryDirectory() as temp:
            proof, log = Path(temp) / "P.lean", Path(temp) / "lean.log"
            write(proof, PROOF)
            names = runner.proof_inventory(proof)
            self.assertEqual(names, ["Example.valid"])
            write(log, "'Example.valid' does not depend on any axioms\n")
            runner.check_proof_log(log, names)
            for text in ("'Other.valid' does not depend on any axioms\n",
                         "'Example.valid' depends on axioms: [sorryAx]\n",
                         "'Example.valid' does not depend on any axioms\nwarning: broken\n", ""):
                write(log, text)
                with self.assertRaises(runner.Blocked):
                    runner.check_proof_log(log, names)
            for source in ("def value := 1\n", "namespace Example\n/- unclosed", PROOF.replace("#print axioms valid\n", ""),
                           PROOF.replace("#print axioms valid", "#print axioms Example.other"),
                           PROOF.replace("by trivial", "by sorry"),
                           PROOF.replace("theorem valid", "private theorem valid"),
                           PROOF.replace("#print axioms valid", "#print axioms valid\n#print axioms valid")):
                write(proof, source)
                with self.subTest(source=source), self.assertRaises(runner.Blocked):
                    runner.proof_inventory(proof)


class SnapshotTests(unittest.TestCase):
    def test_unhashed_import_is_blocked(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            path = root / "helper.py"
            write(path, "# New verifier dependency.\n")
            with patch.dict(sys.modules, {"unregistered_verifier": SimpleNamespace(__file__=str(path))}):
                with self.assertRaises(runner.Blocked):
                    runner.check_imports(root, root / "snapshot", {})

    def test_manifest_covers_all_verifier_and_source_inputs(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            config = configuration()
            repository(root, config)
            manifest = runner.inputs(root, config)
            for path in (runner.PLUGIN, "scripts/test_next_obligation_replays.py",
                         "scripts/run_bounded_obligation_repairs.py", "scripts/run_submission_container_closure.py",
                         "scripts/check_rewrite_dispatch_parity.py", "certificate-verifier/src/Verifier.java",
                         "certificate-verifier/test/VerifierTest.java", "lib/example.jar", str(runner.CONFIG),
                         str(runner.MATRIX), ".github/workflows/bounded-ci.yml"):
                self.assertIn(path, manifest)
                original = (root / path).read_bytes()
                (root / path).write_bytes(original + b"\n")
                self.assertNotEqual(runner.inputs(root, config), manifest)
                (root / path).write_bytes(original)

    def test_matrix_parent_hash_missing_and_duplicate_rows(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            config = configuration()
            repository(root, config)
            self.assertEqual(set(runner.check_matrix(root, config)), runner.PARENTS)
            path = root / runner.MATRIX
            original = path.read_text()
            for text in (original.replace("a" * 64, "b" * 64, 1),
                         "\n".join(original.splitlines()[:-1]) + "\n",
                         original + original.splitlines()[1] + "\n"):
                write(path, text)
                with self.assertRaises(runner.Blocked):
                    runner.check_matrix(root, config)

    def test_source_restoration_even_after_failure(self):
        with tempfile.TemporaryDirectory() as temp:
            snapshot = Path(temp)
            path = snapshot / "src/Example.java"
            write(path, "original\r\n")
            manifest = {"src/Example.java": runner.digest(path)}
            spec = ("guard", "src/Example.java", "original", "mutant", "Extractor")
            with self.assertRaisesRegex(RuntimeError, "failed"):
                with runner.mutated_source(snapshot, spec, manifest):
                    self.assertEqual(path.read_text(), "mutant\n")
                    raise RuntimeError("failed")
            self.assertEqual(path.read_bytes(), b"original\r\n")
            for old in ("missing", "i"):
                bad = ("guard", spec[1], old, "changed", "Extractor")
                with self.assertRaises(runner.Blocked):
                    with runner.mutated_source(snapshot, bad, manifest):
                        self.fail("ambiguous anchor accepted")

    def test_snapshot_detects_stale_extra_and_symlink_inputs(self):
        with tempfile.TemporaryDirectory() as temp:
            root, snapshot = Path(temp) / "root", Path(temp) / "snapshot"
            write(root / "src/F.java", "frozen")
            manifest = {"src/F.java": runner.digest(root / "src/F.java")}
            runner.make_snapshot(root, snapshot, manifest)
            write(snapshot / "extra", "unregistered")
            with self.assertRaises(runner.Blocked):
                runner.check_snapshot(snapshot, manifest)
            write(root / "src/F.java", "changed")
            with self.assertRaises(runner.Blocked):
                runner.make_snapshot(root, Path(temp) / "second", manifest)
            (root / "link").symlink_to(root / "src/F.java")
            with self.assertRaises(runner.Blocked):
                runner.contained(root, "link")


class PinAndCommandTests(unittest.TestCase):
    def test_missing_elan_toolchain_is_not_downloaded(self):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp)
            write(home / "bin/elan", "not executed")
            (home / "bin/lean").symlink_to(home / "bin/elan")
            env = {"ELAN_HOME": str(home), "LEAN_BIN": str(home / "bin/lean")}
            with self.assertRaises(FileNotFoundError):
                runner.lean_executable(env)
            write(home / "toolchains/leanprover--lean4---v4.33.0/bin/lean", "installed")
            self.assertEqual(runner.lean_executable(env), str(home / "bin/lean"))

    def test_explicit_pin_overrides_absent_or_conflicting_default(self):
        for environment in ({}, {"ELAN_TOOLCHAIN": "stable"}, {"ELAN_TOOLCHAIN": "leanprover/lean4:v4.33.1"}):
            original = dict(environment)
            self.assertEqual(runner.pinned_lean_environment(environment, PIN + "\n", "4.33.0")["ELAN_TOOLCHAIN"], PIN)
            self.assertEqual(environment, original)
        for pin in ("", "stable", "leanprover/lean4:v4.33.1"):
            with self.assertRaises(runner.Blocked):
                runner.pinned_lean_environment({}, pin, "4.33.0")

    def test_real_elan_with_no_default_in_isolated_directory(self):
        home = Path(os.environ.get("ELAN_HOME", str(Path.home() / ".elan")))
        installed = home / "toolchains/leanprover--lean4---v4.33.0"
        shim = home / "bin/lean"
        if not installed.is_dir() or not shim.is_file():
            self.skipTest("installed pinned elan toolchain unavailable; never download during tests")
        with tempfile.TemporaryDirectory() as temp:
            elan_home, formal = Path(temp) / "elan", Path(temp) / "formal"
            (elan_home / "toolchains").mkdir(parents=True)
            (elan_home / "toolchains" / installed.name).symlink_to(installed, target_is_directory=True)
            formal.mkdir()
            env = dict(os.environ, ELAN_HOME=str(elan_home))
            env.pop("ELAN_TOOLCHAIN", None)
            env.pop("LEAN_PATH", None)
            absent = subprocess.run([str(shim), "--version"], cwd=formal, env=env, capture_output=True, timeout=15)
            self.assertNotEqual(absent.returncode, 0)
            env = runner.pinned_lean_environment(env, PIN, "4.33.0")
            pinned = subprocess.run([str(shim), "--version"], cwd=formal, env=env, capture_output=True,
                                    text=True, timeout=15)
            self.assertEqual(pinned.returncode, 0, pinned.stderr)
            self.assertIn("version 4.33.0,", pinned.stdout)
            self.assertFalse((formal / "lean-toolchain").exists())

    def test_command_rejections_and_infrastructure_logs(self):
        with tempfile.TemporaryDirectory() as temp:
            output = Path(temp)
            report = {"closureId": "test", "inputRootHash": "root", "verifierSetHash": "verifier",
                      "commands": [], "environment": {"ELAN_TOOLCHAIN": PIN}}
            command = runner.Commands(output, report, {}, 3)
            for index, (code, reject, error) in enumerate(((0, False, None), (1, True, None),
                                                         (0, True, runner.Blocked), (1, False, runner.Blocked),
                                                         (2, True, OSError), (-9, False, OSError))):
                with patch.object(runner.subprocess, "run", return_value=SimpleNamespace(returncode=code)):
                    if error:
                        with self.assertRaises(error):
                            command.run("c" + str(index), ["tool"], output, reject=reject)
                    else:
                        command.run("c" + str(index), ["tool"], output, reject=reject)
                self.assertEqual(report["commands"][-1]["exitCode"], code)
                self.assertTrue(report["commands"][-1]["sha256"])
            for index, error in enumerate((FileNotFoundError("tool absent"), subprocess.TimeoutExpired("tool", 3))):
                with patch.object(runner.subprocess, "run", side_effect=error), self.assertRaises(type(error)):
                    command.run("failure" + str(index), ["tool"], output)
                self.assertEqual(report["commands"][-1]["status"], "INFRASTRUCTURE_FAILURE")
                self.assertIn(str(error), (output / report["commands"][-1]["log"]).read_text())
            with self.assertRaises(runner.Blocked):
                command.run("c0", ["tool"], output)


class LifecycleTests(unittest.TestCase):
    def test_real_fixture_git_is_deterministic_and_local(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            commits = []
            for number in (1, 2):
                root = base / f"source{number}"
                root.mkdir()
                write(root / "src/Example.java", "class Example {}\n")
                manifest = {"src/Example.java": runner.digest(root / "src/Example.java")}
                runner.check_snapshot(root, manifest)
                def run(label, argv, extra):
                    environment = {key: value for key, value in os.environ.items() if not key.startswith("GIT_")}
                    environment.update(extra)
                    result = subprocess.run(argv, cwd=root, env=environment, capture_output=True, text=True, check=True)
                    path = base / f"{number}-{label}.log"
                    path.write_text(result.stdout)
                    return path
                commits.append(runner.initialize_fixture_git(run))
                self.assertEqual(subprocess.check_output(["git", "status", "--porcelain"], cwd=root), b"")
                runner.check_snapshot(root, manifest, fixture_git=True)
                write(root / "src/Example.java", "class Changed {}\n")
                with self.assertRaises(runner.Blocked):
                    runner.check_snapshot(root, manifest, fixture_git=True)
                write(root / "src/Example.java", "class Example {}\n")
                write(root / "extra.txt", "not a frozen input")
                with self.assertRaises(runner.Blocked):
                    runner.check_snapshot(root, manifest, fixture_git=True)
                (root / "extra.txt").unlink()
                runner.check_snapshot(root, manifest, fixture_git=True)
            self.assertEqual(commits[0], commits[1])
            self.assertFalse((base / ".git").exists())

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root, self.output = Path(self.temp.name) / "repo", Path(self.temp.name) / "evidence"
        self.config = configuration()
        repository(self.root, self.config)
        self.calls = []
        self.plugin = SimpleNamespace(
            generate=lambda build, formal: [("Replay.lean", REPLAY, 1)],
            negatives=lambda build, formal: [("wrong", "Reject.lean", "example : False := by decide\n")],
            source_mutations=lambda: [("guard", "src/Example.java", "original", "mutated", "ExampleExtractor")])

    def fake_command(self, argv, cwd, env, stdout, stderr, timeout, check):
        self.calls.append((argv, Path(cwd), dict(env)))
        self.assertEqual(env["ELAN_TOOLCHAIN"], PIN)
        code = 0
        if argv[-1] == "--version":
            stdout.write(VERSION)
        elif argv[-1] == "-version":
            stdout.write("javac 17.0.1\n" if argv[0] == "javac" else 'openjdk version "17.0.1"\n')
        elif argv[0] == "javac":
            target = Path(argv[argv.index("-d") + 1])
            write(target / "Compiled.class", "deterministic class")
        elif argv[0] == "git":
            if "init" in argv:
                (Path(cwd) / ".git").mkdir()
                write(Path(cwd) / ".git/HEAD", "ref: refs/heads/closure-fixture\n")
            if "rev-parse" in argv:
                stdout.write("c" * 40 + "\n")
        elif argv[0] == "java":
            if "ExampleExtractor" in argv:
                code = int("mutated" in (Path(cwd) / "src/Example.java").read_text())
                if code == 0:
                    write(Path(argv[-1]), "site\tfield\none\toriginal\n")
            elif "example.Test" in argv:
                write(Path(argv[-1]), "id\tvalue\n0\ttrue\n")
        elif argv[-1].endswith(".lean"):
            if "controls" in Path(cwd).parts:
                code = 1
                stdout.write("error: expected rejection\n")
            else:
                path = Path(cwd) / argv[-1]
                names = runner.proof_inventory(path)
                for name in names:
                    stdout.write(f"'{name}' does not depend on any axioms\n")
                write(Path(cwd) / argv[argv.index("-o") + 1], path.read_text())
        return SimpleNamespace(returncode=code)

    def execute(self, side_effect=None):
        with patch.object(runner.subprocess, "run", side_effect=side_effect or self.fake_command), \
                patch.object(runner, "load_plugin", return_value=self.plugin), \
                patch.object(runner.platform, "platform", return_value="test-platform"), redirect_stdout(io.StringIO()):
            status = runner.execute(self.root, self.output)
        return status, json.loads((self.output / "report.json").read_text())

    def test_two_clean_builds_shared_work_and_bound_evidence(self):
        status, report = self.execute()
        self.assertEqual(status, 0, report["errors"])
        self.assertEqual(report["status"], "VERIFIED")
        self.assertEqual(report["claimCounts"], {"total": 5, "passed": 5, "unresolved": 0})
        self.assertEqual(report["determinism"]["passedBuilds"], 2)
        for number in (1, 2):
            commands = [c for c in report["commands"] if c["id"].startswith(f"build{number}-")]
            self.assertEqual(sum("-test-" in c["id"] for c in commands), 1)
            self.assertEqual(sum(c["id"].endswith("proof-Example") for c in commands), 1)
            self.assertEqual((self.output / f"build{number}/source/src/Example.java").read_text(), "original\n")
            compile_command = next(c for c in commands if c["id"] == f"build{number}-compile")
            self.assertTrue(any("certificate-verifier/src/Verifier.java" in a for a in compile_command["argv"]))
            self.assertFalse(any("certificate-verifier/test/" in a for a in compile_command["argv"]))
        self.assertIn("plugin-tests", {c["id"] for c in report["commands"]})
        self.assertTrue(all(c["inputRootHash"] == report["inputRootHash"] for c in report["commands"]))

    def test_missing_replays_cannot_verify(self):
        self.plugin.generate = lambda build, formal: []
        status, report = self.execute()
        self.assertEqual(status, 1)
        self.assertEqual(report["claimCounts"]["passed"], 0)
        self.assertIn("empty replay", report["errors"][0])

    def test_wrong_theorem_count_cannot_verify(self):
        self.plugin.generate = lambda build, formal: [("Replay.lean", REPLAY, 2)]
        status, report = self.execute()
        self.assertEqual(status, 1)
        self.assertIn("theorem count", report["errors"][0])

    def test_missing_source_controls_cannot_verify(self):
        self.plugin.source_mutations = lambda: []
        status, report = self.execute()
        self.assertEqual(status, 1)
        self.assertIn("source-level", report["errors"][0])

    def test_plugin_crash_is_infrastructure_failure(self):
        self.plugin.generate = lambda build, formal: 1 / 0
        status, report = self.execute()
        self.assertEqual(status, 2)
        self.assertEqual(report["status"], "INFRASTRUCTURE_FAILURE")
        self.assertIn("ZeroDivisionError", (self.output / "build1-plugin-generate.log").read_text())

    def test_plugin_system_exit_cannot_return_success(self):
        def generate(build, formal):
            raise SystemExit(0)
        self.plugin.generate = generate
        status, report = self.execute()
        self.assertEqual(status, 2)
        self.assertEqual(report["status"], "INFRASTRUCTURE_FAILURE")

    def test_plugin_missing_census_is_blocked_not_a_crash(self):
        def generate(build, formal):
            raise runner.Blocked("missing census rows")
        self.plugin.generate = generate
        status, report = self.execute()
        self.assertEqual(status, 1)
        self.assertEqual(report["status"], "BLOCKED")
        self.assertIn("missing census rows", (self.output / "build1-plugin-generate.log").read_text())

    def test_plugin_cannot_change_observations_before_replay(self):
        def generate(build, formal):
            write(build / "observed.tsv", "id\tvalue\n0\tfalse\n")
            return [("Replay.lean", REPLAY, 1)]
        self.plugin.generate = generate
        status, report = self.execute()
        self.assertEqual(status, 1)
        self.assertIn("INPUT_MUTATION", report["errors"][0])

    def test_negative_acceptance_is_blocked(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if "controls" in Path(kwargs["cwd"]).parts and argv[-1].endswith(".lean"):
                result.returncode = 0
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("reject-wrong", report["errors"][0])

    def test_missing_trace_cannot_verify(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if "example.Test" in argv:
                Path(argv[-1]).unlink()
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("MISSING_WITNESS", report["errors"][0])

    def test_configured_test_args_precede_output(self):
        for phase in self.config["phases"]:
            phase["tests"][0]["args"] = ["--finite", "3"]
        write(self.root / runner.CONFIG, json.dumps(self.config))
        status, report = self.execute()
        self.assertEqual(status, 0, report["errors"])
        command = next(c for c in report["commands"] if c["id"] == "build1-test-00")
        self.assertEqual(command["argv"][-3:-1], ["--finite", "3"])

    def test_root_mutation_is_blocked(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if "ExampleExtractor" in argv and "build2" in Path(kwargs["cwd"]).parts:
                write(self.root / "src/Example.java", "new source revision\n")
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("INPUT_MUTATION", report["errors"][0])

    def test_source_mutation_acceptance_blocks_and_restores(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if "ExampleExtractor" in argv:
                result.returncode = 0
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("source-reject-guard", report["errors"][0])
        self.assertEqual((self.output / "build1/source/src/Example.java").read_text(), "original\n")

    def test_build_two_artifact_drift_blocks(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if "example.Test" in argv and "build2" in Path(kwargs["cwd"]).parts:
                write(Path(argv[-1]), "id\tvalue\n0\tfalse\n")
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("NONDETERMINISM", report["errors"][0])

    def test_missing_config_reports_block_without_commands(self):
        (self.root / runner.CONFIG).unlink()
        status, report = self.execute()
        self.assertEqual(status, 1)
        self.assertEqual(report["commands"], [])

    def test_no_existing_output_is_overwritten(self):
        write(self.output / "report.json", "preserve me")
        with redirect_stdout(io.StringIO()):
            status = runner.execute(self.root, self.output)
        self.assertEqual(status, 2)
        self.assertEqual((self.output / "report.json").read_text(), "preserve me")


if __name__ == "__main__":
    unittest.main()
