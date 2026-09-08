"""Profile/aggregator tests, synthetic two-build lifecycles, real Git/Lean smoke.

Synthetic compiler results test orchestration only, never discharge repair
claims. Real Git runs only in temporary TEST_ONLY snapshots, not the workspace.
"""

from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import run_next_obligation_repairs as previous
import run_third_obligation_repairs as profile
import third_obligation_replays as replay
from test_next_obligation_repairs import repository, write, VERSION, PIN

ROOT = Path(__file__).resolve().parents[1]
REAL_RUN = subprocess.run


def configuration():
    return json.loads((ROOT / profile.CONFIG).read_text(encoding="utf-8"))


def theorem(namespace):
    return (f"namespace {namespace}\ntheorem valid : True := by trivial\n"
            f"#print axioms valid\nend {namespace}\n")


def area_plugin(area):
    return SimpleNamespace(
        generate=lambda build, formal: [(area["replay"], theorem("Fixture." + area["id"]), 1)],
        negatives=lambda build, formal: [("wrong", "Reject.lean", "example : False := by decide\n")],
        source_mutations=lambda: [("guard", "src/Example.java", "original", "mutated", area["extractor"])],
    )


class ProfileTests(unittest.TestCase):
    def test_rejection_requires_target_diagnostic(self):
        good = 'Reject.lean:3:20: error: Tactic `decide` proved that the proposition\n  False\nis false\n'
        profile.check_rejection("build1-reject-call-wrong", good)
        profile.check_rejection("build1-reject-call-wrong", good + good)
        profile.check_rejection("build1-source-reject-call-wrong",
                                'Exception in thread "main" java.lang.IllegalArgumentException: UNMODELED_SOURCE:\n')
        for label, text in (
                ("build1-reject-call-wrong", "error: unexpected token end"),
                ("build1-reject-call-wrong", good + "Other.lean:1:2: error: unknown identifier x\n"),
                ("build1-source-reject-call-wrong", "JAVAC_ERROR: invalid declaration"),
                ("build1-source-reject-call-wrong",
                 'Exception in thread "main" java.lang.IllegalArgumentException: UNMODELED_SOURCE:\nExample.java:1: error: cannot find symbol\n'),
                ("build1-source-reject-registry-wrong",
                 'Exception in thread "main" java.lang.IllegalArgumentException: UNMODELED_SOURCE:\n'),
                ("build1-reject-foreign-wrong", good)):
            with self.subTest(label=label, text=text), self.assertRaises(previous.Blocked):
                profile.check_rejection(label, text)
        for text in (good + 'PANIC at review runtime failure\n',
                     'Error: Could not find or load main class CallAuthorityTransitionsExtractor',
                     "error: unknown module prefix 'MissingDependency'"):
            with self.assertRaises(OSError):
                profile.check_rejection("build1-reject-call-wrong", text)

    def test_actual_private_dependency_inventory_is_complete(self):
        runner = profile.load_runner()
        with tempfile.TemporaryDirectory() as directory:
            build = Path(directory)
            relative = runner.FORMAL / "PhaseA2DependentChains.lean"
            original = (ROOT / relative).read_text()
            write(build / "source" / relative, original)
            path = build / "formal" / relative.name
            write(path, original)
            names = runner.proof_inventory(path)
            self.assertEqual(len(names), 132)
            self.assertEqual({name for name in names if name.startswith("_private.")}, {
                "_private.PhaseA2DependentChains.0.ACGN.Section3.PhaseA2.productionParserCapability",
                "_private.PhaseA2DependentChains.0.ACGN.Section3.PhaseA2.foreignParserCapability"})
            self.assertTrue(path.read_text().startswith(original))
            self.assertEqual((build / "source" / relative).read_text(), original)
            self.assertEqual(runner.proof_inventory(path), names)
            write(path, path.read_text().replace("#print axioms ACGN.Section3.PhaseA2.foreignParserCapability\n", ""))
            with self.assertRaises(previous.Blocked):
                runner.proof_inventory(path)

    def test_mutual_blocks_preserve_qualified_proof_inventory(self):
        runner = profile.load_runner()
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "MutualInventory.lean"
            source = """namespace Outer
mutual
  def left : Nat := 0
  def right : Nat := 1
end
theorem first : True := by trivial
section Inner
mutual
  theorem second : True := by trivial
  theorem third : True := by trivial
end
end Inner
#print axioms first
#print axioms second
#print axioms third
end Outer
"""
            path.write_text(source)
            self.assertEqual(runner.proof_inventory(path), ["Outer.first", "Outer.second", "Outer.third"])
            with self.assertRaises(previous.Blocked):
                previous.proof_inventory(path)
            path.write_text(source.replace("#print axioms second\n", ""))
            with self.assertRaises(previous.Blocked):
                runner.proof_inventory(path)

    def test_private_profile_leaves_imported_runner_unchanged_in_process(self):
        before = dict(previous.__dict__)
        first, second = profile.load_runner(), profile.load_runner()
        self.assertIsNot(first, second)
        self.assertIsNot(first.execute, second.execute)
        self.assertIs(first.execute.__globals__, first.__dict__)
        self.assertIs(previous.execute.__globals__, previous.__dict__)
        for runner in (first, second):
            self.assertEqual(runner.CONFIG, profile.CONFIG)
            self.assertEqual(runner.execute.__defaults__, (profile.CONFIG,))
            self.assertEqual(runner.inputs.__defaults__, (profile.CONFIG,))
            self.assertEqual(runner.PLUGIN, profile.PLUGIN)
            self.assertEqual(runner.PARENTS, profile.PARENTS)
            runner.validate_config(configuration())
        with tempfile.TemporaryDirectory() as directory, redirect_stdout(io.StringIO()):
            self.assertEqual(first.execute(Path(directory) / "missing", Path(directory) / "evidence"), 1)
        self.assertEqual(set(before), set(previous.__dict__))
        for key, value in before.items():
            self.assertIs(previous.__dict__[key], value, key)
        self.assertFalse(profile.PARENTS & previous.PARENTS)
        self.assertNotEqual(first.PACKAGE, previous.PACKAGE)
        self.assertEqual(previous.digest(ROOT / "scripts/run_next_obligation_repairs.py"), profile.BASE_SHA256)

    def test_adapter_rejects_engine_and_literal_site_drift(self):
        with patch.object(profile, "BASE_SHA256", "0" * 64), self.assertRaises(previous.Blocked):
            profile.load_runner()
        source = (ROOT / "scripts/run_next_obligation_repairs.py").read_text()
        for altered in (source.replace('"next-five-v2.13-"', '"new-family-"'),
                        source + '\nextra = "next-five-v2.13-"\n'):
            with self.assertRaises(previous.Blocked):
                profile.adapted_tree(altered, "candidate.py")

    def test_exact_parent_hashes_match_original_matrix(self):
        runner, config = profile.load_runner(), configuration()
        rows = runner.check_matrix(ROOT, config)
        self.assertEqual({key: row["claim_sha256"] for key, row in rows.items()}, profile.PARENT_HASHES)
        self.assertEqual({phase["id"] for phase in config["phases"]}, {"TF-" + p for p in profile.PARENTS})
        with self.assertRaises(previous.Blocked):
            previous.validate_config(config)

    def test_required_predicates_and_mappings_cannot_be_weakened(self):
        runner = profile.load_runner()
        edits = [lambda c: c.update(requiredCleanBuilds=1), lambda c: c.update(networkDuringVerification=True),
                 lambda c: c.update(replayPlugin=previous.PLUGIN), lambda c: c.update(inputs=[]),
                 lambda c: c.update(proofDependencies=[]), lambda c: c.update(generatedDependencyAudits={}),
                 lambda c: c["phases"][0].update(claimSha256="a" * 64),
                 lambda c: c["phases"][0].update(passCondition={}),
                 lambda c: c["phases"][0].update(blockConditions=[]),
                 lambda c: c["phases"][0].update(proof="Other.lean"),
                 lambda c: c["phases"][0].update(tests=["example.Test"]),
                 lambda c: c["extractors"].pop()]
        for edit in edits:
            config = configuration()
            edit(config)
            with self.subTest(edit=edit), self.assertRaises(previous.Blocked):
                runner.validate_config(config)

    def test_plan_is_exact_and_shared_call_work_runs_once(self):
        plan = profile.load_runner().validate_config(configuration())
        self.assertEqual(plan["proofs"][:3], list(profile.PROOF_DEPENDENCIES))
        self.assertEqual(set(plan["proofs"][3:]), {area["proof"] for area in replay.AREAS})
        self.assertEqual(set(plan["replays"]), {area["replay"] for area in replay.AREAS})
        for area in replay.AREAS:
            self.assertEqual(sum(test["class"] == area["test"] for test in plan["tests"]), 1)

    def test_pinned_lean_works_without_an_elan_default_and_missing_pin_is_offline(self):
        runner = profile.load_runner()
        home = Path(os.environ.get("ELAN_HOME", str(Path.home() / ".elan")))
        installed = home / "toolchains/leanprover--lean4---v4.33.0/bin/lean"
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            shim = temp / "elan"
            shim.touch()
            link = temp / "lean"
            link.symlink_to(shim)
            env = runner.pinned_lean_environment(dict(os.environ, ELAN_HOME=str(temp), LEAN_BIN=str(link),
                                                    ELAN_TOOLCHAIN="wrong-default"), PIN + "\n", "4.33.0")
            self.assertEqual(env["ELAN_TOOLCHAIN"], PIN)
            with self.assertRaises(FileNotFoundError):
                runner.lean_executable(env)
            if not installed.is_file():
                self.skipTest("real Lean smoke requires the offline installed 4.33.0 toolchain")
            env["LEAN_BIN"] = str(installed)
            lean = runner.lean_executable(env)
            version = REAL_RUN([lean, "--version"], cwd=temp, env=env, capture_output=True, text=True, check=True)
            self.assertTrue(version.stdout.startswith("Lean (version 4.33.0,"))
            for number in (1, 2):
                build = temp / str(number)
                write(build / "Smoke.lean", theorem("Smoke"))
                result = REAL_RUN([lean, "-o", "Smoke.olean", "Smoke.lean"], cwd=build, env=env,
                                  capture_output=True, text=True, check=True)
                write(build / "proof.log", result.stdout + result.stderr)
                runner.check_proof_log(build / "proof.log", runner.proof_inventory(build / "Smoke.lean"))
                write(build / "Reject.lean", "example : False := by decide\n")
                rejected = REAL_RUN([lean, "Reject.lean"], cwd=build, env=env, capture_output=True, check=False)
                self.assertEqual(rejected.returncode, 1)
            self.assertEqual(runner.digest(temp / "1/Smoke.olean"), runner.digest(temp / "2/Smoke.olean"))
            self.assertFalse((temp / "settings.toml").exists())


class ReplayTests(unittest.TestCase):
    def setUp(self):
        self.plugins = {area["id"]: area_plugin(area) for area in replay.AREAS}
        self.loader = patch.object(replay, "load_area", side_effect=lambda area: self.plugins[area["id"]])
        self.loader.start()
        self.addCleanup(self.loader.stop)

    def test_every_area_delegates_and_control_namespaces_are_disjoint(self):
        generated = replay.generate(Path("build"), Path("formal"))
        self.assertEqual([row[0] for row in generated], [area["replay"] for area in replay.AREAS])
        negatives = replay.negatives(Path("build"), Path("formal"))
        self.assertEqual([row[0] for row in negatives], [area["id"] + "-wrong" for area in replay.AREAS])
        self.assertEqual([row[0] for row in replay.source_mutations()],
                         [area["id"] + "-guard" for area in replay.AREAS])

    def test_no_area_can_omit_a_census_or_control_family(self):
        for area in replay.AREAS:
            for method in ("generate", "negatives", "source_mutations"):
                plugin = self.plugins[area["id"]]
                with patch.object(plugin, method, return_value=[]), self.subTest(area=area, method=method), \
                        self.assertRaises(previous.Blocked):
                    getattr(replay, method)(Path("build"), Path("formal"))

    def test_plugin_census_errors_and_crashes_propagate(self):
        for error in (previous.Blocked("MISSING_WITNESS: exact census changed"), TypeError("plugin bug"), SystemExit(0)):
            with patch.object(self.plugins["call"], "generate", side_effect=error), self.assertRaises(type(error)):
                replay.generate(Path("build"), Path("formal"))

    def test_namespaces_counts_and_replay_names_are_strict(self):
        area = replay.AREAS[1]
        for record in [(area["replay"], theorem("Fixture.call"), 1),
                       (area["replay"], "theorem valid : True := by trivial\n#print axioms valid\n", 1),
                       (area["replay"], theorem("Fixture.join"), 2),
                       ("Foreign.lean", theorem("Fixture.join"), 1)]:
            with patch.object(self.plugins["join"], "generate", return_value=[record]), \
                    self.assertRaises(previous.Blocked):
                replay.generate(Path("build"), Path("formal"))

    def test_source_control_signature_duplicates_and_area_ownership(self):
        plugin = self.plugins["call"]
        original = plugin.source_mutations()
        plugin.source_mutations = lambda build, formal: original
        self.assertEqual(len(replay.source_mutations(Path("build"), Path("formal"))), 3)
        for values in (original * 2, [(*original[0][:4], "RegistryAdmissionExtractor")]):
            with patch.object(plugin, "source_mutations", return_value=values), self.assertRaises(previous.Blocked):
                replay.source_mutations(Path("build"), Path("formal"))

    def test_strict_tsv_rejects_missing_extra_and_duplicate_rows(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "trace.tsv"
            for rows in ("", "0\ttrue\n0\ttrue\n", "0\ttrue\n1\ttrue\n", "0\ttrue\textra\n"):
                write(path, "id\tvalue\n" + rows)
                with self.assertRaises(previous.Blocked):
                    previous.read_tsv(path, ["id", "value"], ["id"], {("0",)})


class AreaLoadingTests(unittest.TestCase):
    def test_missing_area_is_blocking_not_skipped(self):
        with tempfile.TemporaryDirectory() as directory:
            scripts = Path(directory)
            with patch.object(replay, "__file__", str(scripts / "third_obligation_replays.py")):
                for area in replay.AREAS:
                    with self.subTest(area=area["id"]), self.assertRaisesRegex(previous.Blocked, "MISSING_INPUT"):
                        replay.load_area(area)
                with self.assertRaisesRegex(previous.Blocked, "MISSING_INPUT"):
                    replay.generate(Path("build"), Path("formal"))

    def test_local_loader_preserves_module_state_and_requires_all_apis(self):
        with tempfile.TemporaryDirectory() as directory:
            scripts, area = Path(directory), replay.AREAS[0]
            path = scripts / area["plugin"]
            name = "_third_five_area_" + area["id"]
            sentinel = SimpleNamespace(marker="existing module must survive")
            with patch.object(replay, "__file__", str(scripts / "third_obligation_replays.py")), \
                    patch.dict(sys.modules, {name: sentinel}):
                write(path, "def generate(build, formal):\n    return []\n")
                with self.assertRaisesRegex(previous.Blocked, "VERIFIER_NOT_RUN"):
                    replay.load_area(area)
                self.assertIs(sys.modules[name], sentinel)
                write(path, "raise RuntimeError('broken area import')\n")
                with self.assertRaisesRegex(RuntimeError, "broken area import"):
                    replay.load_area(area)
                self.assertIs(sys.modules[name], sentinel)
                write(path, "def generate(build, formal):\n    return []\n"
                            "def negatives(build, formal):\n    return []\n"
                            "def source_mutations():\n    return []\n")
                loaded = replay.load_area(area)
                self.assertEqual(Path(loaded.__file__), path)
                self.assertIs(sys.modules[name], sentinel)


class LifecycleTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "repo"
        self.output = Path(self.temp.name) / "evidence"
        self.runner = profile.load_runner()
        self.config = configuration()
        repository(self.root, self.config)
        write(self.root / profile.CONFIG, json.dumps(self.config))
        for name in profile.NOTES:
            write(self.root / profile.PACKAGE / name, "Synthetic fixture boundary only.\n")
        for relative in profile.AREA_TESTS:
            write(self.root / relative, "# Synthetic subprocess test entry point.\n")
        for name in profile.PROOF_DEPENDENCIES:
            namespace = profile.GENERATED_AUDITS.get(name, "Fixture.Dependency." + Path(name).stem)
            code = theorem(namespace)
            if name in profile.GENERATED_AUDITS:
                code = code.replace("#print axioms valid\n", "")
            write(self.root / self.runner.FORMAL / name, code)
        write(self.root / self.runner.MATRIX, "requirement_id\tclaim_sha256\timplementation_refs\n" + "".join(
            parent + "\t" + sha + "\tsrc/Example.java#main\n" for parent, sha in profile.PARENT_HASHES.items()))
        for area in replay.AREAS:
            write(self.root / self.runner.FORMAL / area["proof"], theorem("Fixture.Proof." + area["id"]))
            write(self.root / "scripts/java" / (area["extractor"] + ".java"), "// simulated extractor\n")
            code = (
                "from run_next_obligation_repairs import read_tsv\n"
                "def generate(build, formal):\n"
                f"    read_tsv(build / {area['trace']!r}, ['id', 'value'], ['id'], {{('0',)}})\n"
                f"    read_tsv(build / {area['sourceTrace']!r}, ['id', 'value'], ['id'], {{('0',)}})\n"
                f"    return [({area['replay']!r}, {theorem('Fixture.Replay.' + area['id'])!r}, 1)]\n"
                "def negatives(build, formal):\n"
                "    return [('wrong', 'Reject.lean', 'example : False := by decide\\n')]\n"
                "def source_mutations():\n"
                f"    return [('guard', 'src/Example.java', 'original', 'mutated', {area['extractor']!r})]\n"
            )
            write(self.root / "scripts" / area["plugin"], code)
        self.calls = []

    def fake_command(self, argv, cwd, env, stdout, stderr, timeout, check):
        self.calls.append((argv, Path(cwd), dict(env)))
        self.assertEqual(env["ELAN_TOOLCHAIN"], PIN)
        self.assertFalse(any(key.startswith("GIT_") for key in env) and argv[0] != "git")
        if argv[0] == "git":
            return REAL_RUN(argv, cwd=cwd, env=env, stdout=stdout, stderr=stderr, timeout=timeout, check=check)
        code = 0
        if argv[-1] == "--version":
            stdout.write(VERSION)
        elif argv[-1] == "-version":
            stdout.write("javac 17.0.1\n" if argv[0] == "javac" else 'openjdk version "17.0.1"\n')
        elif argv[0] == "javac":
            write(Path(argv[argv.index("-d") + 1]) / "Compiled.class", "deterministic synthetic compiler output")
        elif argv[0] == "java":
            for area in replay.AREAS:
                if area["test"] in argv:
                    write(Path(argv[-1]), "id\tvalue\n0\ttrue\n")
                if area["extractor"] in argv:
                    code = int("mutated" in (Path(cwd) / "src/Example.java").read_text())
                    if not code:
                        write(Path(argv[-1]), "id\tvalue\n0\ttrue\n")
                    else:
                        message = {"call": "UNMODELED_SOURCE:", "join": "Unmodeled guard structure/effect",
                                   "registry": "Unregistered registry source shape/binding:"}[area["id"]]
                        stdout.write('Exception in thread "main" java.lang.IllegalArgumentException: ' + message + '\n')
        elif argv[-1].endswith(".lean"):
            if "controls" in Path(cwd).parts:
                code = 1
                stdout.write("Reject.lean:1:1: error: Tactic `decide` proved that the proposition\n  False\nis false\n")
            else:
                path = Path(cwd) / argv[-1]
                for name in self.runner.proof_inventory(path):
                    stdout.write(f"'{name}' does not depend on any axioms\n")
                write(Path(cwd) / argv[argv.index("-o") + 1], path.read_text())
        return SimpleNamespace(returncode=code)

    def execute(self, effect=None):
        with patch.object(self.runner.subprocess, "run", side_effect=effect or self.fake_command), \
                patch.object(self.runner.platform, "platform", return_value="synthetic-test-platform"), \
                redirect_stdout(io.StringIO()):
            status = self.runner.execute(self.root, self.output)
        return status, json.loads((self.output / "report.json").read_text())

    def test_fresh_no_git_archive_has_two_real_deterministic_fixture_commits(self):
        archive = Path(self.temp.name) / "source.tar"
        with tarfile.open(archive, "w") as stream:
            stream.add(self.root, arcname="repo")
        unpacked = Path(self.temp.name) / "unpacked"
        with tarfile.open(archive) as stream:
            # This archive was just made from this test's own regular files.
            self.assertTrue(all(member.isfile() or member.isdir() for member in stream.getmembers()))
            stream.extractall(unpacked)
        self.root = unpacked / "repo"
        self.assertFalse((self.root / ".git").exists())
        old_globals = dict(previous.__dict__)
        status, report = self.execute()
        self.assertEqual(status, 0, report["errors"])
        self.assertTrue(report["closureId"].startswith("third-five-v1-"))
        self.assertEqual(report["claimCounts"], {"total": 5, "passed": 5, "unresolved": 0})
        self.assertEqual(report["determinism"], {"requiredBuilds": 2, "passedBuilds": 2, "identicalArtifacts": True})
        self.assertEqual(report["builds"][0]["fixtureGitCommit"], report["builds"][1]["fixtureGitCommit"])
        self.assertFalse((self.root / ".git").exists())
        for key, value in old_globals.items():
            self.assertIs(previous.__dict__[key], value, key)
        for build in report["builds"]:
            source = self.output / f"build{build['number']}" / "source"
            subject = REAL_RUN(["git", "log", "-1", "--format=%s"], cwd=source, capture_output=True,
                               text=True, check=True).stdout.strip()
            self.assertEqual(subject, "TEST_ONLY frozen closure inputs")
            self.assertEqual((source / "src/Example.java").read_text(), "original\n")
            self.assertEqual(len(build["proofInventory"]), 9)
            self.assertEqual(len(build["negativeControls"]), 3)
            self.assertEqual(len(build["sourceMutations"]), 3)
        commands = report["commands"]
        driver = next(command for command in commands if command["id"] == "driver-tests")
        self.assertTrue(driver["argv"][-1].endswith("scripts/test_third_obligation_repairs.py"))
        area_commands = [command for command in commands if command["id"].startswith("area-tests-")]
        self.assertEqual({Path(command["argv"][-1]).name for command in area_commands},
                         {Path(relative).name for relative in profile.AREA_TESTS})
        self.assertTrue(all(command["inputRootHash"] == report["inputRootHash"] for command in commands))
        self.assertTrue(all(command["closureId"] == report["closureId"] for command in commands))
        self.assertTrue(all(command["exitCode"] == 1 for command in commands if command.get("expectedRejection")))

    def test_dependency_audits_are_generated_only_in_formal_copy_and_are_strict(self):
        manifest = self.runner.inputs(self.root, self.config)
        build = Path(self.temp.name) / "audit-build"
        self.runner.make_snapshot(self.root, build / "source", manifest)
        name = "PhaseA2DependentChains.lean"
        original = (build / "source" / self.runner.FORMAL / name).read_bytes()
        target = build / "formal" / name
        write(target, original.decode())
        self.assertEqual(self.runner.proof_inventory(target), ["ACGN.Section3.PhaseA2.valid"])
        self.assertIn("#print axioms ACGN.Section3.PhaseA2.valid", target.read_text())
        self.assertEqual(self.runner.proof_inventory(target), ["ACGN.Section3.PhaseA2.valid"])
        self.assertEqual((build / "source" / self.runner.FORMAL / name).read_bytes(), original)
        self.runner.check_snapshot(build / "source", manifest)
        write(target, target.read_text() + "\n-- drift\n")
        with self.assertRaisesRegex(previous.Blocked, "INPUT_MUTATION"):
            self.runner.proof_inventory(target)

    def test_manifest_covers_explicit_notes_without_publication_evidence_cycles(self):
        note = profile.PACKAGE / "join-notes.md"
        manifest = self.runner.inputs(self.root, self.config)
        self.assertTrue(profile.REQUIRED_INPUTS <= set(manifest))
        for name in profile.NOTES:
            self.assertIn(str(profile.PACKAGE / name), manifest)
        for relative in ("README.md", "reviews.md", "review-call.md", "report.json", "results.tsv",
                         "evidence/report.json", "incidents/report.json"):
            write(self.root / profile.PACKAGE / relative, "publication output, not an input\n")
        self.assertEqual(self.runner.inputs(self.root, self.config), manifest)
        for area in replay.AREAS:
            self.assertIn("scripts/" + area["plugin"], manifest)
        snapshot = Path(self.temp.name) / "snapshot"
        self.runner.make_snapshot(self.root, snapshot, manifest)
        write(snapshot / note, "changed\n")
        with self.assertRaisesRegex(previous.Blocked, "INPUT_MUTATION"):
            self.runner.check_snapshot(snapshot, manifest)
        (self.root / "scripts" / replay.AREAS[0]["plugin"]).unlink()
        with self.assertRaisesRegex(previous.Blocked, "MISSING_INPUT"):
            self.runner.inputs(self.root, self.config)

    def test_area_suite_discovery_invokes_extra_suites_but_never_this_driver(self):
        extra = self.root / "scripts/test_third_additional_encoder.py"
        write(extra, "# Another frozen area suite.\n")
        paths = profile.area_test_paths(self.root)
        self.assertIn(extra, paths)
        self.assertNotIn(self.root / "scripts/test_third_obligation_repairs.py", paths)
        commands = []
        original = previous.Commands.run

        def record(command, label, argv, cwd, extra=None, reject=False):
            commands.append((label, argv))
            return Path("synthetic.log")

        with patch.object(self.runner.Commands.__mro__[1], "run", record):
            command = self.runner.Commands(self.output, {}, {}, 30)
            command.run("plugin-tests", ["python", "old-compatibility-suite.py"], self.root)
        self.assertIs(previous.Commands.run, original)
        self.assertEqual([Path(argv[-1]) for label, argv in commands[1:]], paths)
        (self.root / profile.AREA_TESTS[0]).unlink()
        with self.assertRaisesRegex(previous.Blocked, "MISSING_INPUT"):
            profile.area_test_paths(self.root)

    def test_area_missing_or_duplicate_observation_blocks(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if replay.AREAS[0]["test"] in argv:
                write(Path(argv[-1]), "id\tvalue\n0\ttrue\n0\ttrue\n")
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertEqual(report["claimCounts"]["passed"], 0)
        self.assertIn("duplicate TSV key", report["errors"][0])

    def test_new_plugin_and_note_mutation_invalidate_evidence(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if replay.AREAS[0]["test"] in argv and "build2" in Path(kwargs["cwd"]).parts:
                write(self.root / profile.PACKAGE / "harness-notes.md", "new claim boundary\n")
                path = self.root / "scripts" / replay.AREAS[0]["plugin"]
                write(path, path.read_text() + "\n# changed verifier\n")
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("INPUT_MUTATION", report["errors"][0])

    def test_negative_acceptance_blocks(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if "controls" in Path(kwargs["cwd"]).parts and argv[-1].endswith(".lean"):
                result.returncode = 0
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("reject-call-wrong", report["errors"][0])

    def test_unregistered_negative_exit_is_infrastructure_failure(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if "controls" in Path(kwargs["cwd"]).parts and argv[-1].endswith(".lean"):
                result.returncode = 2
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 2)
        self.assertEqual(report["status"], "INFRASTRUCTURE_FAILURE")

    def test_unrelated_negative_diagnostic_blocks_the_command_record(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if "controls" in Path(kwargs["cwd"]).parts and argv[-1].endswith(".lean"):
                kwargs["stdout"].write("Reject.lean:2:1: error: unknown identifier fabricated\n")
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("unrelated rejection diagnostic", report["errors"][0])
        self.assertEqual(report["commands"][-1]["status"], "BLOCKED")

    def test_control_loader_failure_is_infrastructure_not_pass(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if "controls" in Path(kwargs["cwd"]).parts and argv[-1].endswith(".lean"):
                kwargs["stdout"].write("error: unknown module prefix 'MissingDependency'\n")
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 2)
        self.assertEqual(report["commands"][-1]["status"], "INFRASTRUCTURE_FAILURE")
        self.assertEqual(report["claimCounts"]["passed"], 0)

    def test_mixed_source_error_blocks_the_control(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if result.returncode == 1 and replay.AREAS[0]["extractor"] in argv:
                kwargs["stdout"].write("Example.java:1: error: cannot find symbol\n")
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertEqual(report["commands"][-1]["status"], "BLOCKED")

    def test_real_lean_panic_cannot_support_a_control_pass(self):
        lean = Path.home() / ".elan/toolchains/leanprover--lean4---v4.33.0/bin/lean"
        if not lean.is_file():
            self.skipTest("offline pinned Lean unavailable; closure requires it separately")
        path = self.root / "scripts" / replay.AREAS[0]["plugin"]
        old = repr("example : False := by decide\n")
        new = repr('example : False := by decide\n#eval (panic! "registered-control-runtime-failure" : Nat)\n')
        self.assertEqual(path.read_text().count(old), 1)
        write(path, path.read_text().replace(old, new))
        def command(argv, **kwargs):
            if Path(kwargs["cwd"]).name == "call-wrong" and argv[-1].endswith(".lean"):
                return REAL_RUN([str(lean), *argv[1:]], **kwargs)
            return self.fake_command(argv, **kwargs)
        status, report = self.execute(command)
        self.assertEqual(status, 2)
        self.assertEqual(report["commands"][-1]["status"], "INFRASTRUCTURE_FAILURE")
        self.assertEqual(report["claimCounts"]["passed"], 0)

    def test_wrong_jvm_or_compiler_version_blocks_before_tests(self):
        for tool, text in (("java", 'openjdk version "21.0.1"\n'),
                           ("javac", "javac 21.0.1\n"), ("java", "unknown\n")):
            with self.subTest(tool=tool, text=text):
                self.output = Path(self.temp.name) / ("version-" + tool + "-" + str(len(text)))
                def command(argv, **kwargs):
                    if argv == [tool, "-version"]:
                        kwargs["stdout"].write(text)
                        return SimpleNamespace(returncode=0)
                    return self.fake_command(argv, **kwargs)
                status, report = self.execute(command)
                self.assertEqual(status, 1)
                self.assertIn("JDK 17 required", report["errors"][0])
                self.assertEqual(report["commands"][-1]["status"], "BLOCKED")
                self.assertFalse(any(c["id"] == "driver-tests" for c in report["commands"]))

    def test_source_acceptance_blocks_and_restores(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if result.returncode == 1 and replay.AREAS[0]["extractor"] in argv:
                result.returncode = 0
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("source-reject-call-guard", report["errors"][0])
        self.assertEqual((self.output / "build1/source/src/Example.java").read_text(), "original\n")

    def test_artifact_drift_and_missing_second_build_cannot_pass(self):
        def command(argv, **kwargs):
            result = self.fake_command(argv, **kwargs)
            if argv[0] == "javac" and "build2" in Path(kwargs["cwd"]).parts:
                write(Path(argv[argv.index("-d") + 1]) / "Compiled.class", "different output\n")
            return result
        status, report = self.execute(command)
        self.assertEqual(status, 1)
        self.assertIn("NONDETERMINISM", report["errors"][0])
        with self.assertRaisesRegex(previous.Blocked, "CLEAN_BUILD_FAILURE"):
            self.runner.compare_builds(report["builds"][:1])

    def test_reports_are_generated_and_existing_evidence_is_not_overwritten(self):
        (self.root / profile.CONFIG).unlink()
        status, report = self.execute()
        self.assertEqual(status, 1)
        self.assertEqual(report["status"], "BLOCKED")
        self.assertEqual(report["commands"], [])
        before = (self.output / "report.json").read_bytes()
        with redirect_stdout(io.StringIO()):
            self.assertEqual(self.runner.execute(self.root, self.output), 2)
        self.assertEqual((self.output / "report.json").read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
