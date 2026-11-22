#!/usr/bin/env python3
"""Qualify the five registered ninth-batch originals and their finite witnesses."""

import argparse
from collections import Counter
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
from tempfile import TemporaryDirectory
from types import SimpleNamespace

sys.dont_write_bytecode = True
PACKAGE = Path("docs/obligation-repair/ninth-five")
EIGHTH = Path("docs/obligation-repair/eighth-five")
PROFILE = "ninth-public-certification-v1"
ENGINE_SHA256 = "9620c1d5d45be4677d631dbb47c6237d02473af239db1232ebd4f02eacaf816b"
CONFIG_SHA256 = "d7cd09092a883932a9b81c74787d61c819cbfbad2c349353cfb6e8bbe194199c"
PARENTS = {
    "A2-21": "4bf2b29d09a49228b6013a04ae6d04576b2e092719bf27e3b9a9d320d0fdd6d3",
    "A2-22": "c4c3d3558acdd3162344346a38cf3f320b80486d1626ebdc8d7558cebf129a98",
    "A2-24": "b8a2af71393a0d31b4a39ecaa99be26a9e24b47701ff53b7370fff22db8749c7",
    "A2-25": "a216882498a514d63ccf4a77326d4b68e46ca2296012892d295bb0ec23687c0a",
    "P5-06": "44498c99ed4894a86433afcd0d0262fe25e136bb0da4574bebf4a2a4fd4ab25e",
}


def engine(root):
    path = root / EIGHTH / "verify_eighth.py"
    if hashlib.sha256(path.read_bytes()).hexdigest() != ENGINE_SHA256:
        raise ValueError("UNDECLARED_DEPENDENCY: unregistered qualification engine")
    spec = importlib.util.spec_from_file_location("_acgn_ninth_engine", path)
    base = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(base)
    return base


def ordered_modules(library, requested, require):
    ordered, active = [], set()
    def visit(name):
        require(name in library, "undeclared Lean module " + name, "UNDECLARED_DEPENDENCY")
        require(name not in active, "cyclic Lean imports at " + name, "UNDECLARED_DEPENDENCY")
        if name in ordered:
            return
        active.add(name)
        for imported in library[name]["imports"]:
            visit(imported)
        active.remove(name)
        ordered.append(name)
    for name in requested:
        visit(name)
    return ordered


def module_inventory(base, source, name, item):
    require = base.require
    from run_submission_container_closure import scan_proof, strip_lean_comments
    clean = strip_lean_comments(source.read_text())
    tokens = [token for line in re.findall(r"(?m)^\s*(?:(?:public|meta)\s+)?import\s+([^\n]+)", clean)
              for token in line.split()]
    local = [t for t in tokens if t.split(".")[0] not in {"Init", "Std", "Lean"}]
    require(Counter(local) == Counter(item["imports"]), "undeclared or stale imports in " + name,
            "UNDECLARED_DEPENDENCY")
    mode = item["audit"]
    if mode == "local":
        names = base.common.mutual_aware_runner().proof_inventory(source)
    else:
        names = scan_proof(source)
        if mode == "legacy":
            # This historic module uses top-level theorem names and has no local axiom printouts.
            require(not re.search(r"(?m)^\s*namespace\b", clean) and names and
                    len(names) == len(re.findall(r"(?m)^\s*(?:(?:private|protected|noncomputable)\s+)?(?:theorem|lemma)\s+", clean)),
                    "unsupported historic theorem inventory " + name, "VERIFIER_NOT_RUN")
        elif mode == "executable":
            require(not names and not re.search(r"(?m)^\s*(?:(?:private|protected|noncomputable)\s+)?(?:theorem|lemma)\s+", clean)
                    and re.search(r"(?m)^\s*def main\b", clean),
                    "pure replay registration contains unaudited declarations: " + name, "VERIFIER_NOT_RUN")
        else:
            raise base.Blocked("VERIFIER_NOT_RUN: unknown Lean audit mode")
    require(Counter(names) == Counter(item["theorems"]), "changed named declarations in " + name, "VERIFIER_NOT_RUN")
    return names


def audit_modules(base, build, lean, manifest, parent, requested, library):
    cache = build.path / (parent + "-lean-imports")
    cache.mkdir()
    env = {"LEAN_PATH": str(cache)}
    records = {}
    for name in ordered_modules(library, requested, base.require):
        item = library[name]
        path = base.contained(build.source, item["source"])
        names = module_inventory(base, path, name, item)
        target = cache / (name + ".olean")
        # Lean may serialize independently elaborated declarations in different orders.
        log = build.run(parent + "-lean-" + name, [lean, "-j1", "-M4096", "-o", target, path.name],
                        cwd=path.parent, extra=env)
        base.require(target.is_file() and target.stat().st_size and not re.search(r"(?i)\bwarning:", log.read_text()),
                     "incomplete compilation " + name, "VERIFIER_FAILURE")
        if item["audit"] == "legacy":
            audit = build.tmp / (parent.replace("-", "") + name + "Audit.lean")
            audit.write_text("import " + name + "\n" + "".join("#print axioms " + n + "\n" for n in names))
            log = build.run(parent + "-axioms-" + name, [lean, "-M4096", audit.name], cwd=audit.parent, extra=env)
        if names:
            base.common.engine.check_proof_log(log, names)
        records[name] = {"source": item["source"], "sourceSha256": manifest[item["source"]], "theorems": names,
                         "audit": item["audit"], "imports": item["imports"], "compiledSha256": base.digest(target),
                         "proofAuditSha256": base.digest(log)}
    return records, env


def check_live(base, root, manifest, phase, record, primary, assessment):
    if assessment["status"] != "VERIFIED":
        return
    row = record["traceability"]
    names = set(primary) | {n.split(".")[-1] for n in primary}
    base.require(row["formal_status"] == "PROVED" and row["conformance_status"] == "DIRECT"
                 and record["ledgerStatus"] == "PROVED/DIRECT" and row["formal_file"] == phase["proof"]
                 and row["formal_declarations"] and set(row["formal_declarations"].split(";")) <= names,
                 "live original does not cover the registered theorem set", "ORPHAN_CLAIM")
    base.require(phase["witness"] + "#main" in row["test_refs"].split(";") and row["implementation_refs"],
                 "unmapped original witness", "UNMAPPED_IMPLEMENTATION_OBJECT")
    for ref in (row["implementation_refs"] + ";" + row["test_refs"]).split(";"):
        src, sep, symbol = ref.partition("#")
        base.require(sep and src in manifest and symbol and re.search(r"\b" + re.escape(symbol) + r"\b",
                     base.contained(root, src).read_text()), "unresolved implementation or test " + ref,
                     "UNMAPPED_IMPLEMENTATION_OBJECT")


def check_phase(base, build, phase, manifest, parent_record, lean, _auditor, cp, values, provenance):
    parent = phase["parent"]
    cfg, _ = base.read_registration(build.source)
    modules, env = audit_modules(base, build, lean, manifest, parent, phase["modules"], cfg["leanModules"])
    primary = Path(phase["proof"]).stem
    proof = modules[primary]
    target = build.path / parent
    target.mkdir()
    values = dict(values, results=str(target), lean=str(lean), package=str(build.source / PACKAGE))
    values["proof"] = str(build.source / modules[phase["executableProof"]]["source"])
    env.update(ACGN_NINTH_LEAN=str(lean), ACGN_NINTH_PROOF=values["proof"])
    args = [a.format_map(values) for a in phase["args"]]
    log = build.run(parent + "-witness", ["java", "-ea", "-Xmx1g", *provenance,
                    "-cp", cp, phase["class"], *args], extra=env)
    lines = log.read_text().splitlines()
    base.require(all(lines.count(s) == 1 for s in phase["requiredLines"]), "missing registered main observation " + parent,
                 "MISSING_WITNESS")
    replay_records = []
    for replay in phase.get("replays", []):
        m = replay["module"]
        base.require(m in modules, "unregistered replay module " + m, "UNDECLARED_DEPENDENCY")
        args = [a.format_map(values) for a in replay["args"]]
        out = build.run(parent + "-replay-" + replay["id"], [lean, "-M4096", "--run", build.source / modules[m]["source"], *args],
                        extra=env, expected=replay["exit"])
        observed = out.read_text().splitlines()
        base.require(all(observed.count(s) == 1 for s in replay["requiredLines"]) and
                     not re.search(r"(?i)\bwarning:", out.read_text()), "wrong replay result " + m, "VERIFIER_FAILURE")
        replay_records.append({"id": replay["id"], "module": m, "exit": replay["exit"], "observations": replay["requiredLines"]})
    outputs = base.file_inventory(target)
    base.require(outputs == phase["outputPins"], "unregistered, absent or changed result files " + parent,
                 "WITNESS_INVALID")
    names = [n for spec in modules.values() for n in spec["theorems"]]
    own = {n for module in phase["modules"] for n in modules[module]["theorems"]}
    for clause in phase["originalRowAssessment"]["clauses"]:
        base.require(own.intersection(clause["theorems"]), "original clause lacks a phase-owned theorem",
                     "UNMAPPED_IMPLEMENTATION_OBJECT")
    assessment = base.original_assessment(phase["originalRowAssessment"], target, names, outputs)
    check_live(base, build.source, manifest, phase, parent_record, proof["theorems"], assessment)
    claim = {"scope": phase["scope"], "proof": phase["proof"], "proofSha256": proof["sourceSha256"],
             "theorems": proof["theorems"], "proofAuditSha256": proof["proofAuditSha256"], "leanImports": modules,
             "leanImportFiles": base.file_inventory(Path(env["LEAN_PATH"])), "primaryModules": phase["modules"],
             "witness": phase["witness"], "sourceSha256": manifest[phase["witness"]],
             "observations": phase["requiredLines"], "replays": replay_records, "outputSha256": outputs,
             "originalRow": parent_record, "originalRowAssessment": assessment}
    build.record["claims"][parent] = claim
    return claim


def configure(root):
    base = engine(root)
    base.PACKAGE, base.CONFIG, base.PROFILE = PACKAGE, PACKAGE / "qualification.json", PROFILE
    base.CONFIG_SHA256, base.PARENTS = CONFIG_SHA256, PARENTS
    shared = base.common
    # Construct an isolated namespace so the historical module and its callers keep their original settings.
    base.common = SimpleNamespace(**vars(shared))
    original_registration, original_freeze = base.read_registration, base.freeze

    def registration(source):
        base.require(CONFIG_SHA256 != "UNSEALED", "ninth registry is a staging draft", "CLAIM_MUTATION")
        base.require(base.digest(source / base.CONFIG) == CONFIG_SHA256, "ninth registry digest changed", "CLAIM_MUTATION")
        cfg, parents = original_registration(source)
        base.require(cfg["registrationState"] == "SEALED", "ninth registry is a staging draft", "CLAIM_MUTATION")
        library = cfg["leanModules"]
        requested = []
        for p in cfg["phases"]:
            requested.extend(p["modules"])
            primary = Path(p["proof"]).stem
            closure = ordered_modules(library, p["modules"], base.require)
            base.require(primary in p["modules"] and p["executableProof"] in closure
                         and library[primary]["source"] == p["proof"] and p["theorems"] == library[primary]["theorems"],
                         "primary/executable proof registration disagrees", "UNMAPPED_IMPLEMENTATION_OBJECT")
            for replay in p.get("replays", []):
                base.require(replay["module"] in closure and replay["requiredLines"] and replay["exit"] in (0,1,2,3),
                             "unregistered replay or empty observation", "MISSING_WITNESS")
        base.require(set(ordered_modules(library, requested, base.require)) == set(library), "orphan Lean module",
                     "UNUSED_EVIDENCE")
        expected = {item["source"] for item in library.values()} | set(cfg["javaSupport"]) | set(cfg["witnessInputs"])
        expected.update(str(p.relative_to(source)) for p in (source / PACKAGE / "java").rglob("*.java"))
        base.require(set(cfg["verifierInputs"]) == expected, "missing or surplus verifier source pin",
                     "UNDECLARED_DEPENDENCY")
        for rel, pin in cfg["verifierInputs"].items():
            path = base.contained(source, rel)
            base.require(path.is_file() and base.digest(path) == pin, "changed registered verifier " + rel,
                         "STALE_OR_UNBOUND_EVIDENCE")
        for name, item in library.items():
            path = base.contained(source, item["source"])
            base.require(re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", name) and path.stem == name and path.is_file()
                         and path.suffix == ".lean", "invalid Lean module " + name, "MISSING_INPUT")
        return cfg, parents

    def freeze():
        files = original_freeze()
        for p in (root / EIGHTH).rglob("*"):
            if p.is_file():
                rel = p.relative_to(root)
                files[str(rel)] = base.digest(base.contained(root, rel))
        base.require(not any(Path(p).suffix in {".olean", ".ilean", ".ir"} for p in files),
                     "generated Lean cache in source snapshot", "INPUT_MUTATION")
        return dict(sorted(files.items()))

    class Build(shared.Build):
        def run(self, name, args, cwd=None, *, expected=0, extra=None):
            if name == "qualification-guard-controls":
                args = [sys.executable, "-B", self.source / PACKAGE / "verify_ninth.py", "--check-controls"]
            return super().run(name, args, cwd, expected=expected, extra=extra)

        def compile(self, name, sources, cp=None):
            return super().compile("ninth-witnesses" if name == "eighth-witnesses" else name, sources, cp)

    cfg = base.read_json(root / base.CONFIG)
    base.PROBE_HELPERS = tuple(Path(src) for src in cfg["javaSupport"])
    base.common.Build = Build
    base.freeze, base.read_registration = freeze, registration
    base.check_parent = lambda *args: check_phase(base, *args)
    return base


def guard_controls(base):
    def reject(code, operation):
        try:
            operation()
        except base.Blocked as exc:
            base.require(str(exc).startswith(code + ":"), "incorrect control rejection: " + str(exc))
        else:
            raise base.Blocked("VERIFIER_FAILURE: expected " + code)
    cfg, _ = base.read_registration(base.ROOT)
    with TemporaryDirectory(prefix="ninth-controls-") as d:
        out = Path(d)
        for p in (base.CONFIG, base.common.SCOPE, base.common.engine.MATRIX, base.common.LEDGER):
            path = out / p
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes((base.ROOT / p).read_bytes())
        cfg_bad = copy.deepcopy(cfg)
        cfg_bad["phases"][0] = dict(cfg_bad["phases"][1], parent=cfg["phases"][0]["parent"])
        base.write_json(out / base.CONFIG, cfg_bad)
        reject("CLAIM_MUTATION", lambda: base.read_registration(out))
        (out / base.CONFIG).write_bytes((base.ROOT / base.CONFIG).read_bytes())
        ledger = out / base.common.LEDGER
        original = ledger.read_text()
        phrase = "finite normalized union of correlated ordered products"
        base.require(original.count(phrase) == 1, "missing original English control anchor")
        ledger.write_text(original.replace(phrase, "altered unregistered meaning"))
        reject("CLAIM_MUTATION", lambda: base.read_registration(out))
        evidence = out / "evidence.json"
        base.write_json(evidence, {})
        recorded = base.digest(evidence)
        base.write_json(evidence, {"tampered": True})
        reject("STALE_OR_UNBOUND_EVIDENCE", lambda: base.recheck(out, {"evidenceFileSha256":recorded}, {}, {}))
        (out / "w.tsv").write_text("real\n")
        clause = {"claim":"original","status":"OPEN","boundary":"unproved","theorems":["checked"],
                  "rows":[{"file":"w.tsv","line":"missing"}]}
        assessment = {"status":"VERIFIED","boundary":"registered","clauses":[clause]}
        reject("MISSING_WITNESS", lambda: base.original_assessment(assessment,out,["checked"],{"w.tsv":1}))
        clause["rows"][0]["line"] = "real"
        reject("SCOPE_LEAK", lambda: base.original_assessment(assessment,out,["checked"],{"w.tsv":1}))
        reject("UNDECLARED_DEPENDENCY", lambda: ordered_modules({"A":{"imports":["B"]}},["A"],base.require))
        reject("UNDECLARED_DEPENDENCY", lambda: ordered_modules({"A":{"imports":["B"]},"B":{"imports":["A"]}},["A"],base.require))
    print("Seven controls rejected substitution, original mutation, stale evidence, missing row, promotion, undeclared import and cycle.")


def check_registration(root):
    base = configure(root)
    cfg, parents = base.read_registration(root)
    library = cfg["leanModules"]
    for name, item in library.items():
        module_inventory(base, base.contained(root, item["source"]), name, item)
    manifest = base.freeze()
    for phase in cfg["phases"]:
        record = parents[phase["parent"]]
        assessment = phase["originalRowAssessment"]
        owned = {n for name in phase["modules"] for n in library[name]["theorems"]}
        graph = ordered_modules(library, phase["modules"], base.require)
        eligible = {n for name in graph for n in library[name]["theorems"]}
        for clause in assessment["clauses"]:
            names = set(clause["theorems"])
            base.require(names <= eligible and names & owned and clause["rows"] and
                         all(row["file"] in phase["outputPins"] for row in clause["rows"]),
                         "invalid original proof or witness registration: " + phase["parent"], "MISSING_WITNESS")
        check_live(base, root, manifest, phase, record, phase["theorems"], assessment)
    print(f"Registered {len(parents)} original rows, {len(library)} Lean modules and "
          f"{len(cfg['verifierInputs'])} source inputs. Runtime evidence requires two clean builds.")


def eighth_receipt(root, directory, frozen):
    prior = engine(root)
    report = prior.read_json(directory / "report.json")
    manifest_path = directory / "input-manifest.json"
    manifest = prior.read_json(manifest_path)
    prior.require(report["profile"] == prior.PROFILE and report["status"] == "VERIFIED" and report["deterministic"]
                  and report["qualifiedSurfaces"] == list(prior.PARENTS)
                  and [b["number"] for b in report["builds"]] == [1, 2] and not report["errors"],
                  "incomplete eighth prerequisite", "STALE_OR_UNBOUND_EVIDENCE")
    prior.require(prior.digest(manifest_path) == report["inputManifestSha256"] and
                  prior.common.sha_json(manifest) == report["inputRootHash"] and manifest == prior.freeze() and
                  all(frozen.get(p) == h for p, h in manifest.items()),
                  "eighth prerequisite is from another source or verifier root", "STALE_OR_UNBOUND_EVIDENCE")
    registry, _ = prior.read_registration(root)
    a223 = next(p for p in registry["phases"] if p["parent"] == "A2-23")
    computed_set = prior.common.sha_json({p:h for p,h in manifest.items()
                             if p.startswith("scripts/") or p.endswith((".java", ".lean", ".py", ".jar"))})
    prior.require(computed_set == report["verifierSetHash"], "wrong eighth verifier set", "STALE_OR_UNBOUND_EVIDENCE")
    results = []
    for record in report["builds"]:
        build = directory / ("build" + str(record["number"]))
        result = prior.read_json(build / "evidence.json")
        prior.require(record["status"] == "PASS" and record["inputRootHash"] == report["inputRootHash"]
                      and record["verifierSetHash"] == report["verifierSetHash"]
                      and result["claims"]["A2-23"]["originalRowAssessment"]["status"] == "VERIFIED",
                      "missing original A2-23 runtime result", "MISSING_WITNESS")
        prior.recheck(build, record, result, manifest)
        witness = result["claims"]["A2-23"]
        prior.require(witness["outputSha256"] == a223["outputPins"] and
                      Counter(witness["theorems"]) == Counter(a223["theorems"]) and
                      witness["sourceSha256"] == manifest[a223["witness"]] and
                      witness["proofSha256"] == manifest[a223["proof"]],
                      "unbound A2-23 evidence", "STALE_OR_UNBOUND_EVIDENCE")
        logs = build / "logs"
        required = {"A2-23-lean", "A2-23-witness", "writer", "verifier", "verifier-jar",
                    "public-accepted", "distribution-accepted", "public-byte-mutations"}
        completed = {c["id"] for c in record["commands"] if c["exit"] == c["expectedExit"]}
        prior.require(required <= completed and all((logs/"A2-23-witness.log").read_text().splitlines().count(l) == 1
                          for l in a223["requiredLines"]), "missing real eighth runtime or public evidence", "MISSING_WITNESS")
        prior.common.engine.check_proof_log(logs/"A2-23-lean.log", a223["theorems"])
        results.append(result)
    prior.require(results[0] == results[1], "different eighth clean-build evidence", "NONDETERMINISM")
    return {"profile": prior.PROFILE, "status": "VERIFIED", "inputRootHash": report["inputRootHash"],
            "verifierSetHash": report["verifierSetHash"], "reportSha256": prior.digest(directory / "report.json"),
            "inputManifestSha256": report["inputManifestSha256"], "builds": 2,
            "commonEvidenceSha256": report["builds"][0]["evidenceFileSha256"],
            "a223OutputSha256": results[0]["claims"]["A2-23"]["outputSha256"],
            "a223ProofAuditSha256": results[0]["claims"]["A2-23"]["proofAuditSha256"]}


def run_candidate(root, args):
    base = configure(root)
    base.read_registration(root)  # Never launch a prerequisite for an unsealed registry.
    output = args.output.resolve()
    if output.exists() or output.is_relative_to(root):
        raise ValueError("use a fresh output directory outside the checkout")
    volume = ["--external-volume", *args.external_volume] if args.external_volume else []
    frozen = base.freeze()
    if args.eighth_run:
        eighth_dir = args.eighth_run.resolve()
    else:
        eighth_dir = output.with_name(output.name + "-eighth-regression")
        if eighth_dir.exists():
            raise ValueError("eighth prerequisite output already exists; choose a fresh path or use --eighth-run")
        finished = subprocess.run([sys.executable, "-B", str(root / EIGHTH / "verify_eighth.py"),
                                   str(eighth_dir), *volume], cwd=root, check=False)
        if finished.returncode:
            output.mkdir(parents=True, exist_ok=False)
            prior = base.read_json(eighth_dir / "report.json") if (eighth_dir / "report.json").is_file() else {}
            status = "BLOCKED" if prior.get("status") == "BLOCKED" else "INFRASTRUCTURE_FAILURE"
            base.write_json(output / "report.json", {"profile": PROFILE, "status": status,
                            "errors": ["eighth prerequisite failed"], "prerequisiteStatus": prior.get("status"),
                            "prerequisiteErrors": prior.get("errors"), "builds": [], "qualifiedSurfaces": []})
            return base.common.STATES[status]
    receipt = eighth_receipt(root, eighth_dir, frozen)
    qualify, recheck = base.qualify, base.recheck
    def with_eighth(*params):
        result = qualify(*params)
        result["requiredEighthRegression"] = receipt
        return result
    def recheck_all(path, record, result, manifest):
        recheck(path, record, result, manifest)
        base.require(eighth_receipt(root, eighth_dir, manifest) == result["requiredEighthRegression"],
                     "eighth evidence changed after the ninth freeze", "STALE_OR_UNBOUND_EVIDENCE")
    base.qualify, base.recheck = with_eighth, recheck_all
    sys.argv = [str(root / PACKAGE / "verify_ninth.py"), str(output), *volume]
    return base.main()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, nargs="?")
    parser.add_argument("--external-volume", nargs=2, metavar=("MOUNT", "UUID"))
    parser.add_argument("--check-registration", action="store_true", help="check frozen sources, proof declarations and original row links")
    parser.add_argument("--eighth-run", type=Path,
                        help="complete retained eighth two-build output from the exact same inputs; otherwise run it fresh")
    parser.add_argument("--check-controls", action="store_true")
    args = parser.parse_args()
    if args.check_registration:
        check_registration(Path(__file__).resolve().parents[3])
    elif args.check_controls:
        guard_controls(configure(Path(__file__).resolve().parents[3]))
    elif args.output:
        root = Path(__file__).resolve().parents[3]
        output = args.output.resolve()
        if output.exists() or output.is_relative_to(root):
            parser.error("use a fresh output directory outside the checkout")
        try:
            sys.exit(run_candidate(root, args))
        except (RuntimeError, ValueError, KeyError, StopIteration, OSError, subprocess.SubprocessError) as exc:
            status = "INFRASTRUCTURE_FAILURE" if isinstance(exc, (OSError, subprocess.SubprocessError)) else "BLOCKED"
            output.mkdir(parents=True, exist_ok=False)
            result = {"profile": PROFILE, "status": status, "errors": [str(exc) or type(exc).__name__],
                      "builds": [], "qualifiedSurfaces": []}
            (output / "report.json").write_text(json.dumps(result, indent=2) + "\n")
            print(json.dumps(result))
            sys.exit(2 if status == "INFRASTRUCTURE_FAILURE" else 1)
    else:
        parser.error("supply an output directory, --check-controls, or --check-registration")
