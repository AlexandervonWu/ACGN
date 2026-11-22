#!/usr/bin/env python3
"""Qualify the eighth batch in two fresh snapshots of the same frozen inputs."""

import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from tempfile import TemporaryDirectory

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "scripts"))
import verify_sixth_obligation_repair as common
from run_next_obligation_repairs import contained, require
from run_submission_container_closure import Blocked, digest, unique_object, write_json

PACKAGE = Path("docs/obligation-repair/eighth-five")
CONFIG = PACKAGE / "qualification.json"
PROFILE = "eighth-public-certification-v1"
CONFIG_SHA256 = "6e0102e06bdd37b36e0afff46e5ad3090425f507dcc126ab07c5ef73fbfa7108"
DISTRIBUTION = Path("certificate-verifier/build/acgn-certificate-verifier.jar")
PARENTS = {
    "P6-11": "e7ebd891d005c44dbaa58c5b4684fc9862849738159688111f38f8c1a7c09f8d",
    "P1-15": "54d4d2121c0f1d04cc4fbfda65748f845b226da5cb8b89efc18491de910af381",
    "P4-11": "4d40daa73cffd3cc30363c0ddb3f0a5467907489b67460490c28157b37b52fe6",
    "P6-09": "6a274f121f2919d837dbc11d0f4e7aa20981d1512883b4ef1baa8a963e87e48a",
    "A2-23": "88cd036c148f8baf6ed019c18205184021f9e037772881eb81e1c081ee9c7a2a",
}
PROBE_HELPERS = (Path("docs/obligation-repair/sixth-five/java/RawCallSourceAuthority.java"),
                 Path("docs/obligation-repair/seventh-five/java/P613SourcePair.java"))
MUTATION_FIXTURES = ("flat-and", "flat-and-alt", "container-equals", "bind-block-symmetric",
                     "bind-block-dual", "bind-block-nested-same-descriptor", "relation-columns",
                     "call-occurrence", "repeated-same-type-slot")


def file_inventory(directory):
    paths = sorted(directory.rglob("*"))
    require(directory.is_dir() and not directory.is_symlink() and not any(p.is_symlink() for p in paths),
            "missing directory or symlink in witness output", "WITNESS_INVALID")
    return {p.relative_to(directory).as_posix(): digest(p) for p in paths if p.is_file()}


def freeze():
    files = common.freeze()
    for package in (PACKAGE, Path("docs/obligation-repair/seventh-five")):
        for p in (ROOT / package).rglob("*"):
            if p.is_file():
                rel = p.relative_to(ROOT)
                files[str(rel)] = digest(contained(ROOT, rel))
    files[str(DISTRIBUTION)] = digest(contained(ROOT, DISTRIBUTION))
    for name in ("classes", "test-classes"):
        tree = DISTRIBUTION.parent / name
        for relative, h in file_inventory(ROOT / tree).items():
            files[str(tree / relative)] = h
    return dict(sorted(files.items()))


def read_json(path):
    return json.loads(path.read_bytes(), object_pairs_hook=unique_object)


def read_registration(root):
    registry = root / CONFIG
    require(digest(registry) == CONFIG_SHA256, "eighth registry digest changed", "CLAIM_MUTATION")
    cfg = read_json(registry)
    require(cfg["profile"] == PROFILE and [p["parent"] for p in cfg["phases"]] == list(PARENTS),
            "wrong eighth parent registration", "CLAIM_MUTATION")
    live = {}
    for path in (common.SCOPE, common.engine.MATRIX):
        table = common.engine.read_tsv(root / path, keys=["requirement_id"])
        matched = {r["requirement_id"]: r["claim_sha256"] for r in table if r["requirement_id"] in PARENTS}
        require(matched == PARENTS, "original parent hash mismatch in " + str(path), "CLAIM_MUTATION")
        if path == common.engine.MATRIX:
            live = {r["requirement_id"]: r for r in table if r["requirement_id"] in PARENTS}
    parents = {}
    for line in (root / common.LEDGER).read_text().splitlines():
        if line.startswith("|"):
            cells = [x.strip() for x in line.strip("|").split("|")]
            if cells[0] in PARENTS:
                parent = cells[0]
                require(len(cells) == 6 and parent not in parents
                        and hashlib.sha256(cells[2].encode()).hexdigest() == PARENTS[parent],
                        "ambiguous or altered original claim " + parent, "CLAIM_MUTATION")
                parents[parent] = {"statement": cells[2], "sha256": PARENTS[parent],
                                   "ledgerStatus": cells[5].strip("`"), "traceability": live[parent]}
    require(set(parents) == set(PARENTS), "incomplete original parent census", "CLAIM_MUTATION")
    for p in cfg["phases"]:
        require(p["theorems"] and p["scope"] and p["originalRowAssessment"]["boundary"]
                and p["originalRowAssessment"]["status"] in {"PARTIAL", "BLOCKED", "VERIFIED"}
                and p["requiredLines"] and p["outputPins"], "incomplete registration " + p["parent"],
                "VERIFIER_NOT_RUN")
        for name in ("proof", "witness"):
            path = contained(root, p[name])
            allowed = path.is_relative_to(root / PACKAGE)
            if name == "proof":
                allowed = allowed or path.is_relative_to(root / common.engine.FORMAL)
            require(allowed and path.is_file(), "unregistered location or absent " + p[name], "MISSING_INPUT")
        require(Path(p["witness"]).stem == p["class"].split(".")[-1], "mismatched registered witness",
                "UNMAPPED_IMPLEMENTATION_OBJECT")
        require(all(re.fullmatch(r"[a-f0-9]{64}", value) for value in p["outputPins"].values()),
                "invalid witness fingerprint", "WITNESS_INVALID")
    return cfg, parents


def original_assessment(assessment, target, inventory, outputs):
    clauses = assessment["clauses"]
    require(bool(clauses) and len({c["claim"] for c in clauses}) == len(clauses),
            "missing or repeated original clause", "ORPHAN_CLAIM")
    states = set()
    evidence = []
    for clause in clauses:
        state = clause["status"]
        require(state in {"DISCHARGED", "OPEN", "COUNTEREXAMPLE"} and clause["boundary"]
                and clause["theorems"] and set(clause["theorems"]) <= set(inventory) and clause["rows"],
                "unbound theory or observation for " + clause["claim"], "UNMAPPED_IMPLEMENTATION_OBJECT")
        for row in clause["rows"]:
            name = row["file"]
            require(name in outputs and row["line"] and
                    contained(target, name).read_text().splitlines().count(row["line"]) == 1,
                    "missing or ambiguous original-clause evidence for " + clause["claim"], "MISSING_WITNESS")
        states.add(state)
        evidence.append(clause)
    decision = "BLOCKED" if "COUNTEREXAMPLE" in states else "PARTIAL" if "OPEN" in states else "VERIFIED"
    require(decision == assessment["status"], "original assessment disagrees with clause evidence", "SCOPE_LEAK")
    return {"status": decision, "boundary": assessment["boundary"], "clauses": evidence}


def check_parent(build, phase, manifest, parent_record, lean, auditor, cp, values, provenance):
    parent = phase["parent"]
    proof = build.source / phase["proof"]
    inventory = auditor.proof_inventory(proof)
    require(Counter(inventory) == Counter(phase["theorems"]), "named theorem census changed: " + parent,
            "VERIFIER_NOT_RUN")
    dependencies = {}
    proof_env = {}
    import_cache = build.path / (parent + "-lean-imports")
    for item in phase.get("leanImports", []):
        name = item["module"]
        dependency = contained(build.source, item["source"])
        require(re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", name) and dependency.stem == name
                and item["source"] in manifest and name not in dependencies,
                "unregistered Lean import", "UNDECLARED_DEPENDENCY")
        import_cache.mkdir(exist_ok=True)
        target_module = import_cache / (name + ".olean")
        names = auditor.proof_inventory(dependency)
        require(Counter(names) == Counter(item["theorems"]), "dependency theorem census changed", "VERIFIER_NOT_RUN")
        log = build.run(parent + "-lean-import-" + name,
                        [lean, "-M4096", "-o", target_module, dependency.name], cwd=dependency.parent)
        common.engine.check_proof_log(log, names)
        require(target_module.is_file() and target_module.stat().st_size, "missing compiled Lean import", "MISSING_INPUT")
        dependencies[name] = {"source": item["source"], "sourceSha256": manifest[item["source"]],
                              "theorems": names, "proofAuditSha256": digest(log), "compiledSha256": digest(target_module)}
        proof_env["LEAN_PATH"] = str(import_cache)
    leanlog = build.run(parent + "-lean", [lean, "-M4096", proof.name], cwd=proof.parent, extra=proof_env)
    common.engine.check_proof_log(leanlog, inventory)
    target = build.path / parent
    target.mkdir()
    build.env["ACGN_EIGHTH_PROOF"] = str(proof)
    args = [a.format_map(dict(values, results=str(target))) for a in phase["args"]]
    log = build.run(parent + "-witness", ["java", "-ea", "-Xmx1g", *provenance, "-cp", cp, phase["class"], *args])
    lines = log.read_text().splitlines()
    for expected in phase["requiredLines"]:
        require(lines.count(expected) == 1, "wrong witness observation: " + expected, "MISSING_WITNESS")
    # Some production tests print caller diagnostics in variable order. When a
    # witness registers raw case lines, preserve and validate their exact order.
    if "observationPrefix" in phase:
        rows = [line for line in lines if line.startswith(phase["observationPrefix"])]
        (target / "observations.tsv").write_text("\n".join(rows) + "\n")
    outputs = file_inventory(target)
    for name, pin in phase["outputPins"].items():
        require(outputs.get(name) == pin, f"wrong witness {parent}/{name}", "WITNESS_INVALID")
    assessment = original_assessment(phase["originalRowAssessment"], target, inventory, outputs)
    if assessment["status"] == "VERIFIED":
        mapping = parent_record["traceability"]
        names = {n.split(".")[-1] for n in inventory} | set(inventory)
        require(mapping["formal_status"] == "PROVED" and mapping["conformance_status"] == "DIRECT"
                and parent_record["ledgerStatus"] == "PROVED/DIRECT" and mapping["formal_file"] == phase["proof"]
                and bool(mapping["formal_declarations"]) and set(mapping["formal_declarations"].split(";")) <= names,
                "live proof or status does not support original admission " + parent, "ORPHAN_CLAIM")
        require(phase["witness"] + "#main" in mapping["test_refs"].split(";") and mapping["implementation_refs"],
                "live route does not link the executed witness " + parent, "UNMAPPED_IMPLEMENTATION_OBJECT")
        for ref in (mapping["implementation_refs"] + ";" + mapping["test_refs"]).split(";"):
            source, sep, symbol = ref.partition("#")
            require(sep and symbol and source in manifest and re.search(r"\b" + re.escape(symbol) + r"\b",
                    contained(build.source, source).read_text()) is not None,
                    "live symbol missing from frozen source " + ref, "UNMAPPED_IMPLEMENTATION_OBJECT")
    claim = {"scope": phase["scope"], "proof": phase["proof"], "proofSha256": manifest[phase["proof"]],
             "theorems": inventory, "leanImports": dependencies,
             "leanImportFiles": file_inventory(import_cache) if dependencies else {},
             "proofAuditSha256": digest(leanlog), "witness": phase["witness"],
             "sourceSha256": manifest[phase["witness"]], "observations": phase["requiredLines"],
             "outputSha256": outputs, "originalRow": parent_record,
             "originalRowAssessment": assessment}
    build.record["claims"][parent] = claim
    return claim


def qualify(build, manifest, lean):
    cfg, parents = read_registration(build.source)
    producer, verifier, tests, pjar, vjar, fixtures, provenance, public = common.build_tools_and_fixtures(build, lean)
    distribution = build.source / DISTRIBUTION
    require(digest(vjar) == manifest[str(DISTRIBUTION)], "distributed verifier differs from source build",
            "STALE_OR_UNBOUND_EVIDENCE")
    distributions = {}
    for directory, compiled in (("classes", verifier), ("test-classes", tests)):
        archived = file_inventory(distribution.parent / directory)
        require(archived == file_inventory(compiled), "distributed class map differs: " + directory,
                "STALE_OR_UNBOUND_EVIDENCE")
        distributions[directory] = {"classes": len(archived), "mapSha256": common.sha_json(archived)}
    nullary = fixtures / "nullary-a.acgncert"
    trust = common.engine.read_tsv(build.source / "certificate-verifier/trusted/theory-pins.tsv", keys=["pin_id"])
    theory = next(row["theory_digest"] for row in trust if row["pin_id"] == "fixture-empty-theory-v1")
    fixture_args = ["--profile", "full", "--theory-digest", theory]
    inspect = build.run("distribution-fixture-inspect", ["java", "-Xmx1g", "-jar", distribution,
                                                       "--inspect-call-occurrences", nullary]).read_text().strip()
    require(inspect == (build.logs / "fixture-inspect.log").read_text().strip(),
            "distribution inspection changed", "VERIFIER_FAILURE")
    distributed = {
        "accepted": build.public("distribution-accepted", distribution,
                                 [*fixture_args, "--call-occurrence-commitment", inspect, nullary], "VERIFIED", "NONE"),
        "no-authority": build.public("distribution-no-authority", distribution, [*fixture_args, nullary],
                                     "UNCHECKABLE", "MISSING_EVIDENCE"),
        "foreign-theory": build.public("distribution-foreign-theory", distribution,
                                       ["--profile", "full", "--theory-digest", "0" * 64, nullary],
                                       "REJECTED", "UNTRUSTED_THEORY"),
    }
    require(distributed == public, "distribution differs on a governed public decision", "VERIFIER_FAILURE")
    mutation = build.run("public-byte-mutations", ["java", "-ea", "-Xmx1g", "-cp", f"{verifier}:{tests}",
                         "org.acgn.cert.ProducerSemanticEvidenceMutationTest",
                         *(fixtures / "schema-v8-coverage" / (name + "-a.acgncert") for name in MUTATION_FIXTURES),
                         fixtures / "parent-path-a.acgncert"])
    require(mutation.read_text().strip() == "ProducerSemanticEvidenceMutationTest: 135 checks passed",
            "public byte-mutation census changed", "MISSING_WITNESS")
    cp = f"{producer}:{build.source / 'lib/*'}:{verifier}:{tests}"
    sources = [*(build.source / PACKAGE / "java").rglob("*.java"), *(build.source / p for p in PROBE_HELPERS)]
    probes = build.compile("eighth-witnesses", sources, cp)
    build.env["ACGN_EIGHTH_LEAN"] = str(lean)
    cp += ":" + str(probes)
    values = {"source": str(build.source), "fixtures": str(fixtures),
              "coverage": str(fixtures / "schema-v8-coverage"), "verifierJar": str(vjar),
              "producerJar": str(pjar), "distributionJar": str(build.source / DISTRIBUTION)}
    claims = {}
    auditor = common.mutual_aware_runner()
    for phase in cfg["phases"]:
        parent = phase["parent"]
        claims[parent] = check_parent(build, phase, manifest, parents[parent], lean, auditor, cp, values, provenance)
    common.engine.check_snapshot(build.source, manifest, fixture_git=True)
    common.engine.check_imports(ROOT, build.source, manifest)
    return {"claims": claims, "distributionClasses": distributions, "tools": build.record["tools"], "publicFixtureControls": public,
            "publicByteMutationCount": 135, "publicDistributionControls": distributed,
            "producerJar": digest(pjar), "verifierJar": digest(vjar),
            "distributionJar": manifest[str(DISTRIBUTION)], "verifierTests": common.hashes(tests),
            "fixtureFiles": common.hashes(fixtures)}


def recheck(build_path, record, result, manifest):
    common.recheck_evidence(build_path, record, result, manifest)
    for parent, claim in result["claims"].items():
        if claim["leanImports"]:
            require(file_inventory(build_path / (parent + "-lean-imports")) == claim["leanImportFiles"],
                    "changed compiled Lean dependency files", "STALE_OR_UNBOUND_EVIDENCE")
        for name, item in claim["leanImports"].items():
            module_file = build_path / (parent + "-lean-imports") / (name + ".olean")
            require(module_file.is_file() and not module_file.is_symlink() and digest(module_file) == item["compiledSha256"],
                    "changed compiled Lean import " + name, "STALE_OR_UNBOUND_EVIDENCE")
        require(file_inventory(build_path / parent) == claim["outputSha256"],
                "added, deleted or changed witness output for " + parent, "STALE_OR_UNBOUND_EVIDENCE")


def guard_controls():
    # Challenge actual registration and persisted evidence parsing before Java.
    def rejects(code, action):
        try:
            action()
        except Blocked as error:
            require(str(error).startswith(code + ":"), "wrong negative-control outcome")
        else:
            raise Blocked("VERIFIER_FAILURE: expected " + code)
    cfg, _ = read_registration(ROOT)
    with TemporaryDirectory(prefix="eighth-guards-") as tmp:
        base = Path(tmp)
        for rel in (CONFIG, common.SCOPE, common.engine.MATRIX, common.LEDGER):
            dst = base / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes((ROOT / rel).read_bytes())
        registry = base / CONFIG
        changed = dict(cfg, phases=cfg["phases"].copy())
        changed["phases"][0] = dict(changed["phases"][1], parent=cfg["phases"][0]["parent"])
        write_json(registry, changed)
        rejects("CLAIM_MUTATION", lambda: read_registration(base))
        registry.write_bytes((ROOT / CONFIG).read_bytes())
        ledger = base / common.LEDGER
        lines = ledger.read_text().splitlines()
        idx = next(i for i, line in enumerate(lines) if line.startswith("| P6-11 |"))
        lines[idx] = lines[idx].replace("only under schema v10", "under any schema", 1)
        ledger.write_text("\n".join(lines) + "\n")
        rejects("CLAIM_MUTATION", lambda: read_registration(base))
        evidence = base / "evidence.json"
        write_json(evidence, {})
        sealed = digest(evidence)
        write_json(evidence, {"altered": True})
        rejects("STALE_OR_UNBOUND_EVIDENCE", lambda: recheck(
            base, {"evidenceFileSha256": sealed, "evidenceHash": common.sha_json({})}, {}, {}))
        clause = {"claim": "registered observation", "status": "DISCHARGED", "boundary": "test premise",
                  "theorems": ["checked"], "rows": [{"file": "probe.tsv", "line": "counterfeit"}]}
        (base / "probe.tsv").write_text("real\n")
        assessment = {"clauses": [clause], "boundary": "test boundary", "status": "VERIFIED"}
        rejects("MISSING_WITNESS", lambda: original_assessment(assessment, base, ["checked"], {"probe.tsv": "test"}))
        clause["status"] = "OPEN"
        clause["rows"][0]["line"] = "real"
        rejects("SCOPE_LEAK", lambda: original_assessment(assessment, base, ["checked"], {"probe.tsv": "test"}))
    print("Five controls rejected substituted registration, altered English, altered evidence, absent row, and promotion.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--external-volume", nargs=2, metavar=("MOUNT", "UUID"))
    args = parser.parse_args()
    output = args.output.resolve()
    if output.is_relative_to(ROOT):
        parser.error("use a fresh output directory outside the checkout")
    output.mkdir(parents=True, exist_ok=False)
    report = {"profile": PROFILE, "builds": [], "status": "BLOCKED", "errors": [],
              "decisionScope": "five registered finite proof and observation surfaces; original rows assessed separately"}
    try:
        common.resource_check(output, args.external_volume)
        if args.external_volume:
            report.update(workstationLimits=common.workstation_limits(), guardedVolume=args.external_volume)
        cfg, _ = read_registration(ROOT)
        manifest = freeze()
        root_hash = common.sha_json(manifest)
        write_json(output / "input-manifest.json", manifest)
        report.update(closureId=PROFILE + "-" + root_hash[:16], inputRootHash=root_hash,
                      inputManifestSha256=digest(output / "input-manifest.json"), trusted=cfg["trusted"],
                      excluded=cfg["excluded"], parentClaimHashes=PARENTS,
                      verifierSetHash=common.sha_json({p: h for p, h in manifest.items()
                          if p.startswith("scripts/") or p.endswith((".java", ".lean", ".py", ".jar"))}))
        env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_") and k not in
               {"JAVA_TOOL_OPTIONS", "JDK_JAVA_OPTIONS", "_JAVA_OPTIONS", "CLASSPATH", "LEAN_PATH", "PYTHONPATH"}}
        env.update(LC_ALL="C", TZ="UTC", PYTHONDONTWRITEBYTECODE="1")
        env = common.engine.pinned_lean_environment(env, (ROOT / "lean-toolchain").read_text(), "4.35.0")
        lean = common.engine.lean_executable(env)
        results = []
        for number in (1, 2):
            b = common.Build(output, number, manifest, env, args.external_volume, report)
            b.record.update(inputRootHash=root_hash, verifierSetHash=report["verifierSetHash"])
            b.run("qualification-guard-controls", [sys.executable, "-B", b.source / PACKAGE / "verify_eighth.py",
                                                  "--check-controls"])
            result = qualify(b, manifest, lean)
            require(freeze() == manifest, "candidate changed since freeze", "INPUT_MUTATION")
            evidence = b.path / "evidence.json"
            write_json(evidence, result)
            b.record.update(status="PASS", evidenceHash=common.sha_json(result), evidenceFileSha256=digest(evidence))
            results.append(result)
        saved = output / "input-manifest.json"
        require(digest(saved) == report["inputManifestSha256"] and read_json(saved) == manifest,
                "stored input manifest changed", "STALE_OR_UNBOUND_EVIDENCE")
        for record, result in zip(report["builds"], results):
            recheck(output / f"build{record['number']}", record, result, manifest)
        require(results[0] == results[1], "two clean build observations differ", "NONDETERMINISM")
        assessments = {p: rec["originalRowAssessment"] for p, rec in results[0]["claims"].items()}
        report.update(status="VERIFIED", deterministic=True, qualifiedSurfaces=list(PARENTS),
                      originalRowAssessments=assessments)
    except (Blocked, ValueError, KeyError, StopIteration) as error:
        report["errors"].append(str(error) or type(error).__name__)
    except (OSError, subprocess.SubprocessError) as error:
        report["status"] = "INFRASTRUCTURE_FAILURE"
        report["errors"].append(str(error))
    finally:
        for record in report["builds"]:
            if record["status"] == "RUNNING":
                record["status"] = report["status"]
        report["claimCounts"] = {"total": len(PARENTS), "qualified": len(report.get("qualifiedSurfaces", [])),
                                 "unresolved": len(PARENTS) - len(report.get("qualifiedSurfaces", []))}
        write_json(output / "report.json", report)
    print(json.dumps({"status": report["status"], "errors": report["errors"], "report": str(output / "report.json")}))
    return common.STATES[report["status"]]


if __name__ == "__main__":
    if sys.argv[1:] == ["--check-controls"]:
        guard_controls()
    else:
        sys.exit(main())
