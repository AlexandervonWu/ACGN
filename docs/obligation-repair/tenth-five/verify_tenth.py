#!/usr/bin/env python3
"""Check the tenth original registration and run its two clean builds after sealing."""

import argparse
import copy
import csv
import hashlib
import importlib.util
import json
import re
import sys
from collections import Counter
from pathlib import Path
from tempfile import TemporaryDirectory

sys.dont_write_bytecode = True
PACKAGE = Path("docs/obligation-repair/tenth-five")
NINTH = Path("docs/obligation-repair/ninth-five")
ENGINE_SHA256 = "f7f25095c537aa1900e419985fd4872f24c75c79ce3fb7e7a3e1c89e07a255e6"
CONFIG_SHA256 = "a36a0e3e272c0d7f238cd9fbe7ef72d4db723deff6aade0d7d260df38808b5b9"
PROFILE = "tenth-public-certification-v1"
PARENTS = {
    "P5-05": "4252bf755653e6ab1d7954ae66372c23a5df58520d532a0dfef38b7d46ec0652",
    "P5-07": "da74ebe0acd1ce6b63daadf6b3b6d1abd901208b31d3e9381134dc2b5130be83",
    "P5-11": "d47927aa3fbf53685a9009de72bf8e38a3aa860736c74f22d75ebea29e9e7050",
    "A2-26": "2383859cecf4dbfa79f149e0308fde456c5fcb367993b813221961fbd99da6ad",
    "P4-08": "9e9ffde2a03d7ad605388bba45460064d6106d4be38dbbafeff2fc2a049af8fe",
}
REQUIRED_PRIOR = {
    "P5-05": {"P5-06"}, "P5-07": {"P5-06"}, "P5-11": {"P5-06"},
    "A2-26": {"A2-21", "A2-22"}, "P4-08": set(),
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def check_proof_workers(argv):
    options = [str(arg) for arg in argv[1:] if str(arg).startswith(("-j", "--threads"))]
    require(options == ["-j1"], "UNDECLARED_DEPENDENCY: retained Lean modules require one compiler worker")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_ninth(root):
    path = root / NINTH / "verify_ninth.py"
    require(sha(path) == ENGINE_SHA256, "UNDECLARED_DEPENDENCY: changed ninth proof driver")
    spec = importlib.util.spec_from_file_location("acgn_tenth_ninth", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def check_plan(root, cfg):
    audit = root / "docs/section3-repair-audit"
    require(cfg["profile"] == PROFILE and [p["parent"] for p in cfg["phases"]] == list(PARENTS),
            "CLAIM_MUTATION: wrong original parent set or rank")
    with (audit / "assurance-scope.tsv").open(encoding="utf-8") as stream:
        scope = {r["requirement_id"]: r for r in csv.DictReader(stream, delimiter="\t")}
    ledger = {}
    for line in (audit / "claim-ledger.md").read_text().splitlines():
        if line.startswith("|"):
            cells = [s.strip() for s in line.strip("|").split("|")]
            if cells[0] in PARENTS:
                require(len(cells) == 6 and cells[0] not in ledger, "CLAIM_MUTATION: ambiguous original")
                ledger[cells[0]] = cells
    for phase in cfg["phases"]:
        parent = phase["parent"]
        claim = phase["original"]
        require(ledger[parent][2] == claim["statement"] and
                ledger[parent][1] == scope[parent]["claim_class"] == claim["class"] and
                hashlib.sha256(claim["statement"].encode()).hexdigest() ==
                scope[parent]["claim_sha256"] == PARENTS[parent] == claim["sha256"],
                "CLAIM_MUTATION: stale English, class, or digest " + parent)
        required = phase["predecessorOriginals"]
        require(len(required) == len(set(required)) and REQUIRED_PRIOR[parent] <= set(required),
                "UNDECLARED_DEPENDENCY: missing predecessor original " + parent)


def configure_with_driver(root):
    # Imported into a private module namespace. The predecessor remains independently
    # loadable, with its authentic package, parent set, and registry seal.
    driver = load_ninth(root)
    actual = driver.engine(root).common.Build
    driver.PACKAGE, driver.PROFILE = PACKAGE, PROFILE
    driver.PARENTS, driver.CONFIG_SHA256 = PARENTS, CONFIG_SHA256
    base = driver.configure(root)
    old_freeze, old_registration = base.freeze, base.read_registration

    def freeze():
        files = old_freeze()
        for rel, pin in base.file_inventory(root / NINTH).items():
            files[(NINTH / rel).as_posix()] = pin
        base.require(all(Path(p).suffix not in {".olean", ".ilean", ".ir"} for p in files),
                     "generated Lean cache under frozen inputs", "INPUT_MUTATION")
        return dict(sorted(files.items()))

    def registration(source):
        cfg, parents = old_registration(source)
        check_plan(source, cfg)
        supports = {m["source"] for m in cfg["leanModules"].values() if Path(m["source"]).is_relative_to(PACKAGE)}
        present = {p.relative_to(source).as_posix() for p in (source / PACKAGE).rglob("*.lean")}
        base.require(supports == present, "unregistered or missing package proof", "UNDECLARED_DEPENDENCY")
        predecessor_cfg, _ = load_ninth(source).configure(source).read_registration(source)
        owned = {mod: p["parent"] for p in predecessor_cfg["phases"] for mod in p["modules"]}
        for phase in cfg["phases"]:
            used = driver.ordered_modules(cfg["leanModules"], phase["modules"], base.require)
            for mod in sorted(owned.keys() & set(used)):
                base.require(owned[mod] in phase["predecessorOriginals"] and
                             cfg["leanModules"][mod] == predecessor_cfg["leanModules"][mod],
                             "unbound precursor module " + mod, "UNDECLARED_DEPENDENCY")
        return cfg, parents

    class TenthBuild(base.common.Build):
        def compile(self, name, sources, cp=None):
            return super().compile("tenth-witnesses" if name == "eighth-witnesses" else name, sources, cp)

        def run(self, name, args, cwd=None, *, expected=0, extra=None):
            if any(name.startswith(parent + "-lean-") for parent in PARENTS):
                check_proof_workers(args)
            if name == "qualification-guard-controls":
                return actual.run(self, name, [sys.executable, "-B", self.source / PACKAGE / "verify_tenth.py",
                                              "--check-controls"], cwd, expected=expected, extra=extra)
            if extra and "ACGN_NINTH_PROOF" in extra:
                extra = dict(extra, ACGN_TENTH_PROOF=extra["ACGN_NINTH_PROOF"], ACGN_TENTH_LEAN=extra["ACGN_NINTH_LEAN"])
            return super().run(name, args, cwd, expected=expected, extra=extra)

    base.freeze, base.read_registration, base.common.Build = freeze, registration, TenthBuild
    return driver, base


def configure(root):
    """Return the sealed phase interface also used by normal assurance."""
    return configure_with_driver(root)[1]


def predecessor(root, ninth_dir, eighth_dir, frozen, required_parents):
    ninth = load_ninth(root)
    prior = ninth.configure(root)
    cfg, _ = prior.read_registration(root)
    phases = {p["parent"]: p for p in cfg["phases"]}
    require(required_parents <= phases.keys(), "UNDECLARED_DEPENDENCY: unknown prior parent")
    report = prior.read_json(ninth_dir / "report.json")
    manifest_file = ninth_dir / "input-manifest.json"
    manifest = prior.read_json(manifest_file)
    require(report["profile"] == ninth.PROFILE and report["status"] == "VERIFIED" and report["deterministic"]
            and not report["errors"] and report["qualifiedSurfaces"] == list(prior.PARENTS)
            and [b["number"] for b in report["builds"]] == [1, 2],
            "STALE_OR_UNBOUND_EVIDENCE: incomplete ninth two-build decision")
    verify_set = {p:h for p,h in manifest.items() if p.startswith("scripts/") or p.endswith((".java",".lean",".py",".jar"))}
    require(prior.digest(manifest_file) == report["inputManifestSha256"] and manifest == prior.freeze()
            and prior.common.sha_json(manifest) == report["inputRootHash"]
            and prior.common.sha_json(verify_set) == report["verifierSetHash"]
            and all(frozen.get(p) == h for p,h in manifest.items()),
            "STALE_OR_UNBOUND_EVIDENCE: different source, engine, or inventory in predecessor")
    eighth = ninth.eighth_receipt(root, eighth_dir, manifest)
    artifacts, results = {}, []
    for record in report["builds"]:
        folder = ninth_dir / ("build" + str(record["number"]))
        evidence = prior.read_json(folder / "evidence.json")
        require(record["status"] == "PASS" and record["inputRootHash"] == report["inputRootHash"]
                and record["verifierSetHash"] == report["verifierSetHash"] and evidence["requiredEighthRegression"] == eighth,
                "STALE_OR_UNBOUND_EVIDENCE: predecessor chain is incomplete")
        prior.recheck(folder, record, evidence, manifest)
        completed = {c["id"] for c in record["commands"] if c["exit"] == c["expectedExit"]}
        require({"writer","verifier","verifier-jar","public-accepted","distribution-accepted","public-byte-mutations"} <= completed,
                "MISSING_WITNESS: predecessor public checks")
        for parent in sorted(required_parents):
            p, claim = phases[parent], evidence["claims"][parent]
            primary = Path(p["proof"]).stem
            require(claim["originalRowAssessment"]["status"] == "VERIFIED"
                    and claim["originalRowAssessment"] == report["originalRowAssessments"][parent]
                    and claim["proofSha256"] == manifest[p["proof"]] and claim["sourceSha256"] == manifest[p["witness"]]
                    and claim["outputSha256"] == p["outputPins"] and Counter(claim["theorems"]) == Counter(p["theorems"])
                    and {parent+"-lean-"+primary,parent+"-witness"} <= completed,
                    "MISSING_WITNESS: incomplete original " + parent)
            witness_log = folder / "logs" / (parent + "-witness.log")
            require(all(witness_log.read_text().splitlines().count(line) == 1 for line in p["requiredLines"]),
                    "MISSING_WITNESS: missing predecessor witness " + parent)
            expected_modules = ninth.ordered_modules(cfg["leanModules"], p["modules"], prior.require)
            require(set(claim["leanImports"]) == set(expected_modules), "MISSING_WITNESS: incomplete precursor module DAG")
            for replay in p.get("replays", []):
                step = parent + "-replay-" + replay["id"]
                require(step in completed, "MISSING_WITNESS: missing precursor replay " + step)
                lines = (folder / "logs" / (step + ".log")).read_text().splitlines()
                require(all(lines.count(line) == 1 for line in replay["requiredLines"]),
                        "MISSING_WITNESS: precursor replay observations " + step)
            for name, item in claim["leanImports"].items():
                command_id = parent + "-lean-" + name
                require(command_id in completed, "MISSING_WITNESS: missing precursor compilation " + name)
                check_proof_workers(prior.read_json(folder / "logs" / (command_id + ".argv.json")))
                registered = cfg["leanModules"][name]
                require(item["source"] == registered["source"] and item["sourceSha256"] == manifest[registered["source"]]
                        and item["audit"] == registered["audit"] and item["imports"] == registered["imports"]
                        and Counter(item["theorems"]) == Counter(registered["theorems"]),
                        "UNDECLARED_DEPENDENCY: altered precursor module " + name)
                if item["theorems"]:
                    step = parent + ("-axioms-" if item["audit"] == "legacy" else "-lean-") + name
                    require(step in completed, "MISSING_WITNESS: missing precursor proof " + name)
                    log = folder / "logs" / (step + ".log")
                    require(sha(log) == item["proofAuditSha256"], "STALE_OR_UNBOUND_EVIDENCE: prior proof log")
                    prior.common.engine.check_proof_log(log, item["theorems"])
            artifacts[parent] = {"proofSha256": claim["proofSha256"], "proofAuditSha256": claim["proofAuditSha256"],
                                 "outputSha256": claim["outputSha256"]}
        results.append(evidence)
    require(results[0] == results[1], "NONDETERMINISM: different prior build evidence")
    return {"profile": ninth.PROFILE, "reportSha256": sha(ninth_dir / "report.json"), "inputRootHash": report["inputRootHash"],
            "verifierSetHash": report["verifierSetHash"], "commonEvidenceSha256": report["builds"][0]["evidenceFileSha256"],
            "requiredOriginals": artifacts, "requiredEighth": eighth}


def guards(root, base):
    cfg, _ = base.read_registration(root)
    def reject(code, operation):
        try: operation()
        except (ValueError, base.Blocked) as exc:
            require(str(exc).startswith(code + ":"), "wrong control result " + str(exc))
        else: raise ValueError("VERIFIER_FAILURE: control admitted " + code)
    for edit in ("rank", "meaning", "dependency"):
        mutant = copy.deepcopy(cfg)
        if edit == "rank": mutant["phases"].reverse()
        elif edit == "meaning": mutant["phases"][0]["original"]["statement"] += "."
        else: mutant["phases"][0]["predecessorOriginals"].clear()
        reject("UNDECLARED_DEPENDENCY" if edit == "dependency" else "CLAIM_MUTATION", lambda: check_plan(root, mutant))
    reject("UNDECLARED_DEPENDENCY", lambda: check_proof_workers(["lean", "-o", "T.olean", "T.lean"]))
    reject("UNDECLARED_DEPENDENCY", lambda: check_proof_workers(["lean", "-j1", "--threads=8", "T.lean"]))
    with TemporaryDirectory(prefix="tenth-registration-controls-") as temp:
        directory = Path(temp)
        file = directory / base.CONFIG
        file.parent.mkdir(parents=True)
        proposed = copy.deepcopy(cfg)
        proposed["phases"][0]["requiredLines"] = []
        base.write_json(file, proposed)
        reject("CLAIM_MUTATION", lambda: base.read_registration(directory))
        receipt = directory / "observed.tsv"
        receipt.write_text("measured\n", encoding="utf-8")
        clause = {"claim":"original", "status":"OPEN", "boundary":"fixture",
                  "theorems":["test.declaration"], "rows":[{"file":receipt.name,"line":"absent"}]}
        assessment = {"status":"VERIFIED", "boundary":"fixture", "clauses":[clause]}
        def assess():
            return base.original_assessment(assessment, directory, ["test.declaration"], {receipt.name:sha(receipt)})
        reject("MISSING_WITNESS", assess)
        clause["rows"][0]["line"] = "measured"
        reject("SCOPE_LEAK", assess)
    print("Eight controls rejected rank, English, dependency, two worker substitutions, registry changes, "
          "absent original-clause observations, and promotion of an open clause.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check-plan", action="store_true")
    mode.add_argument("--check-registration", action="store_true")
    mode.add_argument("--check-controls", action="store_true")
    mode.add_argument("--output", type=Path)
    parser.add_argument("--source", type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument("--ninth-run", type=Path)
    parser.add_argument("--eighth-run", type=Path)
    parser.add_argument("--external-volume", nargs=2, metavar=("MOUNT", "UUID"))
    args = parser.parse_args()
    root = args.source.resolve()
    here = Path(__file__).resolve()
    if args.check_plan:
        registry = json.loads(here.with_name("qualification.json").read_text())
        check_plan(root, registry)
        prior = load_ninth(root).configure(root)
        _, parents = prior.read_registration(root)
        required = {p for phase in registry["phases"] for p in phase["predecessorOriginals"]}
        require(required <= parents.keys(), "UNDECLARED_DEPENDENCY: unknown original in the pinned ninth registry")
        print("Five ordered original English claims, classes, hashes and required precursor IDs match the pinned source.")
        return 0
    require(CONFIG_SHA256 != "UNSEALED", "CLAIM_MUTATION: tenth registration is an unsealed draft")
    require(here == root / PACKAGE / "verify_tenth.py", "UNDECLARED_DEPENDENCY: driver must be in the candidate checkout")
    driver, base = configure_with_driver(root)
    cfg, _ = base.read_registration(root)
    if args.check_controls:
        guards(root, base)
        return 0
    if args.check_registration:
        driver.check_registration(root)
        return 0
    output = args.output.resolve()
    require(not output.exists() and not output.is_relative_to(root), "fresh output outside candidate is required")
    require(args.ninth_run and args.eighth_run, "MISSING_INPUT: supply retained complete ninth and eighth two-build directories")
    required = {k for p in cfg["phases"] for k in p["predecessorOriginals"]}
    def get_receipt(frozen):
        return predecessor(root, args.ninth_run.resolve(), args.eighth_run.resolve(), frozen, required)
    try:
        receipt = get_receipt(base.freeze())
    except (OSError, ValueError, RuntimeError, KeyError) as exc:
        status = "INFRASTRUCTURE_FAILURE" if isinstance(exc, OSError) else "BLOCKED"
        output.mkdir(parents=True, exist_ok=False)
        base.write_json(output / "report.json", {"profile": PROFILE, "status": status,
                        "errors": [str(exc) or type(exc).__name__], "builds": [], "qualifiedSurfaces": []})
        print(str(exc), file=sys.stderr)
        return base.common.STATES[status]
    qualify, recheck = base.qualify, base.recheck
    def run_phase(*params):
        return dict(qualify(*params), requiredNinthRegression=receipt)
    def check_result(build, record, result, manifest):
        recheck(build, record, result, manifest)
        require(get_receipt(manifest) == result["requiredNinthRegression"], "STALE_OR_UNBOUND_EVIDENCE: changed predecessor receipt")
    base.qualify, base.recheck = run_phase, check_result
    sys.argv = [str(here), str(output)] + (["--external-volume", *args.external_volume] if args.external_volume else [])
    return base.main()


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, RuntimeError, KeyError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        sys.exit(2 if isinstance(exc, OSError) else 1)
