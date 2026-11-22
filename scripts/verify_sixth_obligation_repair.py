#!/usr/bin/env python3
"""Run the finite sixth-batch qualification on two independent input snapshots."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import time

sys.dont_write_bytecode = True
import run_next_obligation_repairs as engine
from run_fifth_obligation_repairs import load_runner as mutual_aware_runner
from run_submission_container_closure import Blocked, canonical_bytes, digest, unique_object, write_json

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = Path("docs/obligation-repair/sixth-five")
CONFIG = PACKAGE / "qualification.json"
CONFIG_SHA256 = "1704e97be1ee661ff5c9b40bb1d448010e6c496771efa88998b641ed486dd38d"
LEDGER = Path("docs/section3-repair-audit/claim-ledger.md")
SCOPE = Path("docs/section3-repair-audit/assurance-scope.tsv")
PARENTS = {
    "P1-19": "fc135df69d2642ebac2bb48cee47019d8e89cf71cde69dd6da898916a11876bb",
    "A2-14": "155ae3d4bcacf2992bc8fe1294c8ee5f6f5a550e0f246617a3a284c6e66c39c3",
    "P3-10": "413413515277fe133dc56fc4d80e10585618bf045eccafe5ffdd45349fb56ba2",
    "P3-13": "e5f35d45c5799f10455454071df3c72cc22b76b1a6893073126fcfc3f9382ced",
    "P3-14": "d5fc74313d3b13382e223a4b64dd36ed2b4ef0c1ea7eeebb8acad34a58731b0c",
}
STATES = {"VERIFIED": 0, "BLOCKED": 1, "INFRASTRUCTURE_FAILURE": 2}
GIB = 1024**3


def sha_json(value):
    return hashlib.sha256(canonical_bytes(value)).hexdigest()


def hashes(directory):
    return {str(p.relative_to(directory)): digest(p) for p in sorted(directory.rglob("*")) if p.is_file()}


def freeze():
    roots = ["src/**/*.java", "certificate-verifier/src/**/*.java", "certificate-verifier/test/**/*.java",
             "certificate-verifier/trusted/*", "lib/*", "scripts/**/*.py", "scripts/**/*.sh",
             "scripts/java/**/*.java", str(PACKAGE / "**/*"), "docs/section3-repair-audit/formal/*.lean"]
    paths = {p.relative_to(ROOT) for pattern in roots for p in ROOT.glob(pattern) if p.is_file()}
    paths.update([SCOPE, engine.MATRIX, CONFIG, LEDGER, Path("lean-toolchain")])
    return {str(rel): digest(engine.contained(ROOT, rel)) for rel in sorted(paths)}


def read_config(root):
    data = (root / CONFIG).read_bytes()
    engine.require(hashlib.sha256(data).hexdigest() == CONFIG_SHA256, "sixth registry digest changed", "CLAIM_MUTATION")
    config = json.loads(data, object_pairs_hook=unique_object)
    phases = config["phases"]
    engine.require([p["parent"] for p in phases] == list(PARENTS), "unexpected sixth-batch parent census")
    engine.require(config["profile"] == "sixth-public-certification-v1", "wrong qualification profile")
    for path in (SCOPE, engine.MATRIX):
        rows = engine.read_tsv(root / path, keys=["requirement_id"])
        mapped = {r["requirement_id"]: r["claim_sha256"] for r in rows if r["requirement_id"] in PARENTS}
        engine.require(mapped == PARENTS, "original parent hash mismatch in " + str(path), "CLAIM_MUTATION")
    ledger_hashes = {}
    for line in (root / LEDGER).read_text().splitlines():
        if line.startswith("|"):
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            if cells[0] in PARENTS:
                engine.require(len(cells) == 6 and cells[0] not in ledger_hashes, "ambiguous ledger row")
                ledger_hashes[cells[0]] = hashlib.sha256(cells[2].encode()).hexdigest()
    engine.require(ledger_hashes == PARENTS, "English parent statement mismatch", "CLAIM_MUTATION")
    for phase in phases:
        for key in ("proof", "scope", "witness"):
            engine.require(phase.get(key), "missing " + key + " for " + phase["parent"], "VERIFIER_NOT_RUN")
        engine.require(phase["kind"] in {"producer", "verifier", "source-authority", "python"},
                       "invalid witness boundary")
        engine.require(phase["requiredLines"] or phase["outputs"], "unregistered witness output", "MISSING_WITNESS")
        engine.require(phase.get("theorems"), "unregistered named theorem census", "VERIFIER_NOT_RUN")
        for key in ("proof", "witness"):
            p = engine.contained(root, phase[key])
            engine.require(p.is_file(), "missing " + str(p), "MISSING_INPUT")
    return config


def workstation_limits():
    groups = Path("/proc/self/cgroup").read_text().splitlines()
    group = next((line[3:] for line in groups if line.startswith("0::")), None)
    if group is None:
        raise OSError("workstation closure requires governed cgroup v2 service")
    directory = Path("/sys/fs/cgroup") / group.lstrip("/")
    limits = {name: (directory / name).read_text().strip()
              for name in ("memory.max", "memory.high", "memory.swap.max", "memory.oom.group")}
    for name, ceiling in (("memory.max", 12 * GIB), ("memory.high", 10 * GIB)):
        if not limits[name].isdigit() or int(limits[name]) > ceiling:
            raise OSError(f"workstation {name} exceeds {ceiling}")
    if limits["memory.swap.max"] != "0" or limits["memory.oom.group"] != "1":
        raise OSError("workstation closure requires zero service swap and group OOM stops")
    return limits


def resource_check(output, volume):
    mounts = [(Path("/"), 10)]
    if volume:
        mount, uuid = volume
        identity = subprocess.check_output(["findmnt", "-nro", "UUID", "--mountpoint", str(mount)], text=True)
        if identity.strip() != uuid:
            raise OSError("external storage identity changed")
        mounts.append((mount, 32))
    for mount, floor in mounts:
        if shutil.disk_usage(mount).free < floor * GIB:
            raise OSError(f"disk reserve below {floor} GiB on {mount}")
    available = re.search(r"^MemAvailable:\s+(\d+) kB$", Path("/proc/meminfo").read_text(), re.M)
    if not available or int(available[1]) * 1024 < 6 * GIB:
        raise OSError("host memory reserve below 6 GiB or unavailable")
    if shutil.disk_usage(output).free < 16 * 1024**2:
        raise OSError("qualification output volume exhausted")


class Build:
    def __init__(self, output, number, manifest, env, volume, report):
        self.path = output / f"build{number}"
        self.path.mkdir()
        self.source = self.path / "source"
        engine.make_snapshot(ROOT, self.source, manifest)
        self.env = env.copy()
        self.volume = volume
        self.record = {"number": number, "status": "RUNNING", "commands": [], "claims": {}}
        report["builds"].append(self.record)
        self.logs = self.path / "logs"
        self.logs.mkdir()
        self.tmp = self.path / "tmp"
        self.tmp.mkdir()
        self.env["TMPDIR"] = str(self.tmp)

    def run(self, name, args, cwd=None, *, expected=0, extra=None):
        log = self.logs / (name + ".log")
        command = [str(x) for x in args]
        if command[0] in ("java", "javac"):
            option = "-J-D" if command[0] == "javac" else "-D"
            command.insert(1, option + "java.io.tmpdir=" + str(self.tmp))
        record = {"id": name, "executable": command[0], "argvSha256": sha_json(command),
                  "cwd": str((cwd or self.source).relative_to(self.path)), "log": str(log.relative_to(self.path)),
                  "expectedExit": expected}
        write_json(self.logs / (name + ".argv.json"), command)
        self.record["commands"].append(record)
        print(f"[sixth] {self.path.name} {name}", flush=True)
        resource_check(self.path, self.volume)
        with log.open("x") as stream:
            proc = subprocess.Popen(command, cwd=cwd or self.source, env=dict(self.env, **(extra or {})),
                                    stdout=stream, stderr=subprocess.STDOUT, start_new_session=True)
            deadline = time.monotonic() + 900
            try:
                while proc.poll() is None:
                    if time.monotonic() >= deadline:
                        raise TimeoutError(f"{name} exceeded 900 seconds")
                    try:
                        proc.wait(timeout=1)
                    except subprocess.TimeoutExpired:
                        resource_check(self.path, self.volume)
            finally:
                if proc.poll() is None:
                    os.killpg(proc.pid, signal.SIGKILL)
                    proc.wait()
                record["exit"] = proc.returncode
        record["logSha256"] = digest(log)
        if proc.returncode < 0 or proc.returncode >= 126:
            raise OSError(f"{name} infrastructure exit {proc.returncode}: {log}")
        engine.require(proc.returncode == expected, f"{name} exit {proc.returncode}, expected {expected}: {log}",
                       "VERIFIER_FAILURE")
        return log

    def compile(self, name, sources, cp=None):
        output = self.path / name
        output.mkdir()
        files = sorted(sources)
        engine.require(bool(files), "empty Java input: " + name, "MISSING_INPUT")
        args = ["javac", "-J-Xmx1g", "--release", "17", "-encoding", "UTF-8", "-proc:none", "-d", output]
        # No implicit source lookup or access to previously compiled classes.
        self.run(name, [*args, "-classpath", cp or output, "-sourcepath", "", *files])
        return output

    def jar(self, name, classes, main=None):
        target = self.path / (name + ".jar")
        args = ["jar", "--create", "--file", target, "--date=2000-01-01T00:00:00Z"]
        if main:
            args.extend(["--main-class", main])
        members = sorted(p.relative_to(classes) for p in classes.rglob("*.class"))
        self.run(name, [*args, *members], cwd=classes)
        return target

    def public(self, name, jar, arguments, outcome, code):
        status = {"VERIFIED": 0, "REJECTED": 2, "UNCHECKABLE": 3}[outcome]
        log = self.run(name, ["java", "-Xmx1g", "-jar", jar, *arguments], expected=status)
        result = json.loads(log.read_text(), object_pairs_hook=unique_object)
        engine.require(result.get("outcome") == outcome and result.get("code") == code,
                       f"{name} unexpected public diagnostic: {result}", "VERIFIER_FAILURE")
        return result


def build_tools_and_fixtures(build, lean):
    root = build.source
    javac = build.run("javac-version", ["javac", "-version"]).read_text().strip()
    java = build.run("java-version", ["java", "-version"]).read_text().splitlines()[0]
    lean_version = build.run("lean-version", [lean, "--version"]).read_text().strip()
    engine.require(re.match(r"javac 17\b", javac) and re.search(r'version "17\b', java), "JDK 17 required")
    engine.require(re.search(r"version 4\.35\.0\b", lean_version), "pinned Lean 4.35.0 required")
    build.record["tools"] = {"javac": javac, "java": java, "lean": lean_version}
    engine.initialize_fixture_git(build.run)
    lib = str(root / "lib/*")
    producer = build.compile("producer", (root / "src").rglob("*.java"), lib)
    verifier = build.compile("verifier", (root / "certificate-verifier/src").rglob("*.java"))
    tests = build.compile("verifier-tests", (root / "certificate-verifier/test").rglob("*.java"), str(verifier))
    producer_jar = build.jar("producer-jar", producer)
    verifier_jar = build.jar("verifier-jar", verifier, "org.acgn.cert.Main")
    fixtures = build.path / "fixtures"
    provenance = [f"-Dacgn.repo.root={root}", "-Dacgn.provenance.testOverride=true",
                  f"-Dacgn.provenance.producerJar={producer_jar}", f"-Dacgn.provenance.verifierJar={verifier_jar}",
                  "-Dacgn.provenance.createdAt=1970-01-01T00:00:00Z"]
    build.run("writer", ["java", "-ea", "-Xmx1g", *provenance, "-cp", f"{producer}:{lib}",
                         "is.fivefivefive.CanDis.theory.CertificateBundleWriterTest", fixtures])
    # These frozen writer fixtures test the public CLI only. Their inspected
    # commitment has TEST_ONLY authority and cannot establish raw-source coverage.
    pins = engine.read_tsv(root / "certificate-verifier/trusted/theory-pins.tsv", keys=["pin_id"])
    pin = next(r["theory_digest"] for r in pins if r["pin_id"] == "fixture-empty-theory-v1")
    bundle = fixtures / "nullary-a.acgncert"
    base = ["--profile", "full", "--theory-digest", pin]
    inspected = build.run("fixture-inspect", ["java", "-Xmx1g", "-jar", verifier_jar,
                                               "--inspect-call-occurrences", bundle]).read_text().strip()
    engine.require(re.fullmatch(r"[0-9a-f]{64}=[0-9a-f]{64}", inspected), "invalid fixture commitment")
    public = {
        "accepted": build.public("public-accepted", verifier_jar,
                                 [*base, "--call-occurrence-commitment", inspected, bundle], "VERIFIED", "NONE"),
        "no-authority": build.public("public-no-authority", verifier_jar, [*base, bundle],
                                     "UNCHECKABLE", "MISSING_EVIDENCE"),
        "foreign-theory": build.public("public-foreign-theory", verifier_jar,
                                       ["--profile", "full", "--theory-digest", "0" * 64, bundle],
                                       "REJECTED", "UNTRUSTED_THEORY"),
    }
    return producer, verifier, tests, producer_jar, verifier_jar, fixtures, provenance, public


def qualify(build, manifest, lean):
    root = build.source
    config = read_config(root)
    producer, verifier, tests, producer_jar, verifier_jar, fixtures, provenance, public = build_tools_and_fixtures(build, lean)
    lib = str(root / "lib/*")
    coverage = fixtures / "schema-v8-coverage"
    mutation_inputs = [
        "flat-and", "flat-and-alt", "container-equals", "bind-block-symmetric", "bind-block-dual",
        "bind-block-nested-same-descriptor", "relation-columns", "call-occurrence", "repeated-same-type-slot",
    ]
    mutation = build.run("public-byte-mutations", ["java", "-ea", "-Xmx1g", "-cp", f"{verifier}:{tests}",
                         "org.acgn.cert.ProducerSemanticEvidenceMutationTest",
                         *(coverage / (name + "-a.acgncert") for name in mutation_inputs),
                         fixtures / "parent-path-a.acgncert"])
    engine.require(mutation.read_text().strip() == "ProducerSemanticEvidenceMutationTest: 135 checks passed",
                   "public byte-mutation observation census changed", "MISSING_WITNESS")
    classpaths = {"producer": f"{producer}:{lib}", "verifier": f"{verifier}:{tests}"}
    supplementary = sorted((root / PACKAGE).glob("*.java"))
    if supplementary:
        # These are producer-side probes only. Verifier witnesses use their own classpath.
        probes = build.compile("producer-probes", supplementary, classpaths["producer"])
        classpaths["producer"] += ":" + str(probes)
    external_probes = sorted((root / PACKAGE / "java").glob("*.java"))
    if external_probes:
        mixed = f"{classpaths['producer']}:{verifier}:{tests}"
        probe_classes = build.compile("source-authority-probes", external_probes, mixed)
        classpaths["source-authority"] = f"{mixed}:{probe_classes}"
    build.env.update(ACGN_SIXTH_PRODUCER_CLASSES=str(producer), ACGN_SIXTH_VERIFIER_CLASSES=str(verifier),
                     ACGN_SIXTH_VERIFIER_TEST_CLASSES=str(tests), ACGN_SIXTH_VERIFIER_JAR=str(verifier_jar))
    claims = {}
    auditor = mutual_aware_runner()
    for phase in config["phases"]:
        parent = phase["parent"]
        proof = root / phase["proof"]
        inventory = auditor.proof_inventory(proof)
        engine.require(set(inventory) == set(phase["theorems"]), f"{parent} named theorem census changed", "VERIFIER_NOT_RUN")
        # Run from the frozen source directory so imports resolve against this build.
        proof_log = build.run(parent + "-lean", [lean, "-M4096", proof.name], cwd=proof.parent)
        engine.check_proof_log(proof_log, inventory)
        kind = phase["kind"]
        results = build.path / parent
        if kind != "python":
            results.mkdir()
        values = {"results": str(results), "source": str(root), "fixtures": str(fixtures),
                  "coverage": str(fixtures / "schema-v8-coverage")}
        arguments = [s.format_map(values) for s in phase["args"]]
        if kind == "python":
            command = [sys.executable, "-B", root / phase["witness"], *arguments]
        else:
            command = ["java", "-ea", "-Xmx1g", *provenance, "-cp", classpaths[kind], phase["class"], *arguments]
        log = build.run(parent + "-witness", command)
        for expected in phase["requiredLines"]:
            engine.require(expected in log.read_text().splitlines(), f"{parent} missing witness: {expected}",
                           "MISSING_WITNESS")
        outputs = {}
        for relative in phase["outputs"]:
            file = engine.contained(results, relative)
            engine.require(file.is_file() and file.stat().st_size, f"missing witness output {parent}/{relative}",
                           "MISSING_WITNESS")
            outputs[relative] = digest(file)
        for relative, pin in phase.get("outputPins", {}).items():
            engine.require(outputs.get(relative) == pin, f"{parent} changed expected witness {relative}", "WITNESS_INVALID")
        engine.require(phase["requiredLines"] or outputs, f"{parent} lacks a registered witness result")
        claims[parent] = {"scope": phase["scope"], "proof": phase["proof"], "theorems": inventory,
                          "witness": phase["witness"], "sourceSha256": manifest[phase["witness"]],
                          "outputSha256": outputs, "observations": phase["requiredLines"], "proofAuditSha256": digest(proof_log)}
        build.record["claims"][parent] = claims[parent]
    engine.check_snapshot(root, manifest, fixture_git=True)
    return {"claims": claims, "publicFixtureControls": public, "publicByteMutationCount": 135, "tools": build.record["tools"],
            "producerJar": digest(producer_jar), "verifierJar": digest(verifier_jar),
            "verifierTests": hashes(tests), "fixtureFiles": hashes(fixtures)}


def recheck_evidence(build_path, record, result, manifest):
    """Validate the retained evidence after the other build has completed."""
    def require_equal(observed, expected, artifact):
        engine.require(observed == expected, f"changed or missing evidence: {artifact}", "STALE_OR_UNBOUND_EVIDENCE")

    def sealed_file(path, expected):
        require_equal(digest(path) if path.is_file() and not path.is_symlink() else None, expected, path)

    evidence = build_path / "evidence.json"
    sealed_file(evidence, record["evidenceFileSha256"])
    require_equal(json.loads(evidence.read_bytes(), object_pairs_hook=unique_object), result, evidence)
    require_equal(sha_json(result), record["evidenceHash"], evidence)
    engine.check_snapshot(build_path / "source", manifest, fixture_git=True)
    for command in record["commands"]:
        sealed_file(engine.contained(build_path, command["log"]), command["logSha256"])
        arg_file = build_path / "logs" / (command["id"] + ".argv.json")
        require_equal(arg_file.is_file(), True, arg_file)
        require_equal(sha_json(json.loads(arg_file.read_bytes())), command["argvSha256"], arg_file)
    sealed_file(build_path / "producer-jar.jar", result["producerJar"])
    sealed_file(build_path / "verifier-jar.jar", result["verifierJar"])
    for directory, key in (("verifier-tests", "verifierTests"), ("fixtures", "fixtureFiles")):
        require_equal(hashes(build_path / directory), result[key], directory)
    for parent, claim in result["claims"].items():
        for relative, expected in claim["outputSha256"].items():
            sealed_file(engine.contained(build_path / parent, relative), expected)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="fresh output directory outside checkout")
    parser.add_argument("--external-volume", nargs=2, metavar=("MOUNT", "UUID"),
                        help="also enforce the workstation's mounted-volume identity and 32 GiB reserve")
    args = parser.parse_args()
    output = args.output.resolve()
    if output.is_relative_to(ROOT):
        parser.error("output must be outside the checkout")
    output.mkdir(parents=True, exist_ok=False)
    report = {"profile": "sixth-public-certification-v1", "builds": [], "status": "BLOCKED",
              "errors": [], "decisionScope": "five registered finite proof and observation surfaces"}
    try:
        resource_check(output, args.external_volume)
        if args.external_volume:
            report["workstationLimits"] = workstation_limits()
            report["guardedVolume"] = args.external_volume
        manifest = freeze()
        root_hash = sha_json(manifest)
        report.update(closureId="sixth-public-certification-v1-" + root_hash[:16], inputRootHash=root_hash)
        write_json(output / "input-manifest.json", manifest)
        report["inputManifestSha256"] = digest(output / "input-manifest.json")
        config = read_config(ROOT)
        report.update(trusted=config["trusted"], excluded=config["excluded"], parentClaimHashes=PARENTS,
                      verifierSetHash=sha_json({p: h for p, h in manifest.items() if p.startswith("scripts/") or p.endswith((".java", ".lean"))}))
        env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_") and k not in
               {"JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS", "_JAVA_OPTIONS", "CLASSPATH", "LEAN_PATH", "PYTHONPATH"}}
        env.update(LC_ALL="C", TZ="UTC", PYTHONDONTWRITEBYTECODE="1")
        env = engine.pinned_lean_environment(env, (ROOT / "lean-toolchain").read_text(), "4.35.0")
        lean = engine.lean_executable(env)
        evidence = []
        for number in (1, 2):
            build = Build(output, number, manifest, env, args.external_volume, report)
            build.record.update(inputRootHash=root_hash, verifierSetHash=report["verifierSetHash"])
            result = qualify(build, manifest, lean)
            engine.require(freeze() == manifest, "candidate mutated", "INPUT_MUTATION")
            write_json(build.path / "evidence.json", result)
            build.record.update(status="PASS", evidenceHash=sha_json(result),
                                evidenceFileSha256=digest(build.path / "evidence.json"))
            evidence.append(result)
        saved = output / "input-manifest.json"
        engine.require(saved.is_file() and digest(saved) == report["inputManifestSha256"],
                       "stored input manifest missing or changed", "STALE_OR_UNBOUND_EVIDENCE")
        stored_manifest = json.loads(saved.read_bytes(), object_pairs_hook=unique_object)
        engine.require(sha_json(stored_manifest) == root_hash, "stored manifest changed", "STALE_OR_UNBOUND_EVIDENCE")
        for record, result in zip(report["builds"], evidence):
            recheck_evidence(output / f"build{record['number']}", record, result, manifest)
        engine.require(evidence[0] == evidence[1], "clean-build evidence differs", "NONDETERMINISM")
        report.update(status="VERIFIED", deterministic=True, qualifiedSurfaces=list(PARENTS))
    except (Blocked, ValueError, KeyError, StopIteration) as error:
        report["errors"].append(str(error) or type(error).__name__)
    except (OSError, subprocess.SubprocessError) as error:
        report["status"] = "INFRASTRUCTURE_FAILURE"
        report["errors"].append(str(error))
    finally:
        for record in report["builds"]:
            if record["status"] == "RUNNING":
                record["status"] = report["status"]
        report["claimCounts"] = {"total": 5, "qualified": len(report.get("qualifiedSurfaces", [])),
                                 "unresolved": 5 - len(report.get("qualifiedSurfaces", []))}
        write_json(output / "report.json", report)
    print(json.dumps({"status": report["status"], "errors": report["errors"], "report": str(output / "report.json")}))
    return STATES[report["status"]]


if __name__ == "__main__":
    sys.exit(main())
