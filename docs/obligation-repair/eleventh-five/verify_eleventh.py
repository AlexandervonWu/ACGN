#!/usr/bin/env python3
"""Qualify the eleventh original rows against freshly verified predecessor evidence."""

import argparse
from collections import Counter
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
from tempfile import TemporaryDirectory


sys.dont_write_bytecode = True
PACKAGE = Path("docs/obligation-repair/eleventh-five")
TENTH = Path("docs/obligation-repair/tenth-five")
PROFILE = "eleventh-public-certification-v1"
ENGINE_SHA256 = "e6bc285fafb978e4e620a2862cd2e4a1277b17cdb2ea5274a0a50184cf1bb99a"
CONFIG_SHA256 = "f24a9c11218964e39b013492cfc35a0a8f896bedd71011fa747d3460780a1693"
PARENTS = {
    "P5-08": "7b2c8c1094ecd7448db125f0a836fbd21a155b902aee0750477deb109113262f",
    "A2-16": "71a9d475059d53bdac10e484990b7e089460598f1f8ad9ceb043117f8b06e968",
    "P4-07": "0bd822921ae2c9f39329fd0cc21480548965c0e02e22a6470e479b1d93ed0a99",
    "P4-04": "ab47c5a21bf9acba434c49c0796b183d63d1a40b8d08fb61c120d67e948d4624",
    "P4-06": "f2cfca69464ef3a1113b9efa31d2eaa5d82f65d4221e5ea1c920cb2c17791f2a"
}
# These dependencies are identified by the claim owners. Formal import links
# provide an additional check against the independently loaded predecessor registries.
REQUIRED_PRIOR = {"P5-08": {"P5-06"}, "A2-16": {"A2-26"}, "P4-07": {"P4-11", "P4-08"},
                  "P4-04": set(), "P4-06": set()}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def load_tenth(root):
    path = root / TENTH / "verify_tenth.py"
    require(hashlib.sha256(path.read_bytes()).hexdigest() == ENGINE_SHA256,
            "UNDECLARED_DEPENDENCY: tenth qualification driver does not match")
    spec = importlib.util.spec_from_file_location("_acgn_eleventh_predecessor", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def prior_registries(root, tenth):
    ninth = tenth.load_ninth(root)
    # Each interface retains its original module globals and registration seal.
    return [ninth.engine(root), ninth.configure(root), tenth.configure(root)]


def check_plan(root, cfg, previous):
    shared = previous[0].common
    require(cfg["profile"] == PROFILE and [p["parent"] for p in cfg["phases"]] == list(PARENTS),
            "CLAIM_MUTATION: wrong eleventh ranking")
    scope = {r["requirement_id"]: r for r in shared.engine.read_tsv(root / shared.SCOPE, keys=["requirement_id"])}
    matrix = {r["requirement_id"]: r for r in shared.engine.read_tsv(root / shared.engine.MATRIX, keys=["requirement_id"])}
    english = {}
    for line in (root / shared.LEDGER).read_text().splitlines():
        if not line.startswith("|"):
            continue
        cells = [s.strip() for s in line.strip("|").split("|")]
        if cells[0] in PARENTS:
            require(len(cells) == 6 and cells[0] not in english, "CLAIM_MUTATION: ambiguous original")
            english[cells[0]] = cells
    known = set().union(*(set(v.PARENTS) for v in previous))
    for phase in cfg["phases"]:
        parent = phase["parent"]
        original = phase["original"]
        require(english[parent][2] == original["statement"] and
                english[parent][1] == scope[parent]["claim_class"] == original["class"] and
                hashlib.sha256(original["statement"].encode()).hexdigest() == scope[parent]["claim_sha256"]
                == matrix[parent]["claim_sha256"] == original["sha256"] == PARENTS[parent],
                "CLAIM_MUTATION: changed original " + parent)
        priors = phase["predecessorOriginals"]
        require(len(priors) == len(set(priors)) and REQUIRED_PRIOR[parent] <= set(priors) <= known,
                "UNDECLARED_DEPENDENCY: missing, repeated or unknown predecessor " + parent)


def configure_with_driver(root):
    tenth = load_tenth(root)
    driver = tenth.load_ninth(root)
    common_build = driver.engine(root).common.Build
    driver.PACKAGE, driver.PROFILE = PACKAGE, PROFILE
    driver.PARENTS, driver.CONFIG_SHA256 = PARENTS, CONFIG_SHA256
    base = driver.configure(root)
    freeze_before, registered_before = base.freeze, base.read_registration

    def freeze():
        files = freeze_before()
        for package in (tenth.NINTH, TENTH):
            for rel, pin in base.file_inventory(root / package).items():
                files[(package / rel).as_posix()] = pin
        base.require(not any(Path(p).suffix in {".olean", ".ilean", ".ir"} for p in files),
                     "generated Lean cache under frozen inputs", "INPUT_MUTATION")
        return dict(sorted(files.items()))

    def registration(source):
        cfg, parents = registered_before(source)
        earlier = prior_registries(source, load_tenth(source))
        check_plan(source, cfg, earlier)
        supports = {m["source"] for m in cfg["leanModules"].values() if Path(m["source"]).is_relative_to(PACKAGE)}
        actual = {p.relative_to(source).as_posix() for p in (source / PACKAGE).rglob("*.lean")}
        base.require(supports == actual, "unregistered or missing package proof", "UNDECLARED_DEPENDENCY")
        owners = {}
        for predecessor in earlier:
            reg, _ = predecessor.read_registration(source)
            for ph in reg["phases"]:
                owners.setdefault(ph["proof"], set()).add(ph["parent"])
        for phase in cfg["phases"]:
            used = driver.ordered_modules(cfg["leanModules"], phase["modules"], base.require)
            for name in used:
                src = cfg["leanModules"][name]["source"]
                if src in owners:
                    base.require(owners[src].intersection(phase["predecessorOriginals"]),
                                 "unbound governing precursor proof " + src, "UNDECLARED_DEPENDENCY")
        return cfg, parents

    class EleventhBuild(base.common.Build):
        def compile(self, name, sources, cp=None):
            return super().compile("eleventh-witnesses" if name == "eighth-witnesses" else name, sources, cp)

        def run(self, name, args, cwd=None, *, expected=0, extra=None):
            if any(name.startswith(p + "-lean-") for p in PARENTS):
                tenth.check_proof_workers(args)
            if name == "qualification-guard-controls":
                cmd = [sys.executable, "-B", self.source / PACKAGE / "verify_eleventh.py", "--check-controls"]
                return common_build.run(self, name, cmd, cwd, expected=expected, extra=extra)
            if extra and "ACGN_NINTH_PROOF" in extra:
                extra = dict(extra, ACGN_ELEVENTH_PROOF=extra["ACGN_NINTH_PROOF"],
                             ACGN_ELEVENTH_LEAN=extra["ACGN_NINTH_LEAN"])
            return super().run(name, args, cwd, expected=expected, extra=extra)

    base.read_registration, base.freeze, base.common.Build = registration, freeze, EleventhBuild
    return driver, base


def configure(root):
    return configure_with_driver(root)[1]


def confirm_archive(root, verifier, directory, frozen, earlier, prior_field):
    """Recompute each original decision and both saved build artifacts on this checkout."""
    cfg, _ = verifier.read_registration(root)
    tenth = load_tenth(root)
    ninth = tenth.load_ninth(root)
    manifest_file = directory / "input-manifest.json"
    manifest = verifier.read_json(manifest_file)
    report = verifier.read_json(directory / "report.json")
    require(report["profile"] == verifier.PROFILE and report["status"] == "VERIFIED" and report["deterministic"]
            and not report["errors"] and report["qualifiedSurfaces"] == list(verifier.PARENTS)
            and [b["number"] for b in report["builds"]] == [1, 2], "STALE_OR_UNBOUND_EVIDENCE: missing clean pair")
    observed_verifiers = {k:v for k,v in manifest.items() if k.startswith("scripts/") or
                          k.endswith((".java", ".lean", ".py", ".jar"))}
    require(manifest == verifier.freeze() and all(frozen.get(k) == v for k,v in manifest.items()) and
            verifier.digest(manifest_file) == report["inputManifestSha256"] and
            verifier.common.sha_json(manifest) == report["inputRootHash"] and
            verifier.common.sha_json(observed_verifiers) == report["verifierSetHash"],
            "STALE_OR_UNBOUND_EVIDENCE: predecessor source set")
    results = []
    for record in report["builds"]:
        folder = directory / ("build" + str(record["number"]))
        evidence = verifier.read_json(folder / "evidence.json")
        require(record["status"] == "PASS" and record["inputRootHash"] == report["inputRootHash"] and
                record["verifierSetHash"] == report["verifierSetHash"] and
                (not prior_field or evidence[prior_field] == earlier),
                "STALE_OR_UNBOUND_EVIDENCE: predecessor receipt chain")
        verifier.recheck(folder, record, evidence, manifest)
        complete = {c["id"]: c for c in record["commands"] if c["exit"] == c["expectedExit"]}
        require({"writer", "public-accepted", "distribution-accepted", "public-byte-mutations"} <= complete.keys() and
                evidence["distributionJar"] == evidence["verifierJar"] == manifest[str(verifier.DISTRIBUTION)],
                "MISSING_WITNESS: deployed artifact or public controls")
        for phase in cfg["phases"]:
            parent = phase["parent"]
            claim = evidence["claims"][parent]
            names = set(claim["theorems"])
            for entry in claim["leanImports"].values():
                names.update(entry["theorems"])
            obs = verifier.file_inventory(folder / parent)
            assessed = verifier.original_assessment(phase["originalRowAssessment"], folder / parent, names, obs)
            require(obs == phase["outputPins"] and claim["proofSha256"] == manifest[phase["proof"]] and
                    claim["sourceSha256"] == manifest[phase["witness"]] and
                    Counter(claim["theorems"]) == Counter(phase["theorems"]) and
                    assessed == claim["originalRowAssessment"] == report["originalRowAssessments"][parent],
                    "MISSING_WITNESS: precursor proof, witness or original assessment " + parent)
            witness = parent + "-witness"
            require(witness in complete and all((folder/"logs"/(witness+".log")).read_text().splitlines().count(line) == 1
                                               for line in phase["requiredLines"]), "MISSING_WITNESS: " + witness)
            if "leanModules" in cfg:
                modules = ninth.ordered_modules(cfg["leanModules"], phase["modules"], verifier.require)
                require(set(modules) == set(claim["leanImports"]), "MISSING_WITNESS: incomplete precursor module DAG")
                for name in modules:
                    step = parent + "-lean-" + name
                    reg, item = cfg["leanModules"][name], claim["leanImports"][name]
                    require(step in complete and all(item[k] == reg[k] for k in ("source","imports","audit"))
                            and Counter(item["theorems"]) == Counter(reg["theorems"])
                            and item["sourceSha256"] == manifest[reg["source"]], "MISSING_WITNESS: " + step)
                    tenth.check_proof_workers(verifier.read_json(folder/"logs"/(step+".argv.json")))
                    if item["theorems"]:
                        check = parent + "-axioms-" + name if item["audit"] == "legacy" else step
                        log = folder/"logs"/(check+".log")
                        require(check in complete and verifier.digest(log) == item["proofAuditSha256"],
                                "STALE_OR_UNBOUND_EVIDENCE: " + check)
                        verifier.common.engine.check_proof_log(log,item["theorems"])
            else:
                check = parent+"-lean"
                require(check in complete, "MISSING_WITNESS: " + check)
                verifier.common.engine.check_proof_log(folder/"logs"/(check+".log"),phase["theorems"])
            for replay in phase.get("replays", []):
                step = parent + "-replay-" + replay["id"]
                lines = (folder/"logs"/(step+".log")).read_text().splitlines()
                require(step in complete and all(lines.count(s)==1 for s in replay["requiredLines"]),
                        "MISSING_WITNESS: " + step)
        results.append(evidence)
    require(results[0] == results[1], "NONDETERMINISM: different predecessor observations")
    return {"profile": verifier.PROFILE, "reportSha256": verifier.digest(directory/"report.json"),
            "inputManifestSha256": report["inputManifestSha256"], "inputRootHash": report["inputRootHash"],
            "verifierSetHash": report["verifierSetHash"], "commonEvidenceSha256": report["builds"][0]["evidenceFileSha256"],
            "originals": {p:c["originalRowAssessment"]["status"] for p,c in results[0]["claims"].items()}}


def predecessors(root, folders, frozen, required):
    tenth = load_tenth(root)
    ninth = tenth.load_ninth(root)
    e, n, t = prior_registries(root, tenth)
    e_dir, n_dir, t_dir = folders
    e_receipt = ninth.eighth_receipt(root,e_dir,frozen)
    tenth_cfg, _ = t.read_registration(root)
    used_by_tenth = {x for p in tenth_cfg["phases"] for x in p["predecessorOriginals"]}
    n_receipt = tenth.predecessor(root,n_dir,e_dir,frozen,used_by_tenth)
    records = [confirm_archive(root, e, e_dir, frozen, None, None),
               confirm_archive(root, n, n_dir, frozen, e_receipt, "requiredEighthRegression"),
               confirm_archive(root, t, t_dir, frozen, n_receipt, "requiredNinthRegression")]
    actual = {p:dict(profile=record["profile"], status=status) for record in records
              for p,status in record["originals"].items() if p in required}
    require(set(actual) == set(required) and all(row["status"] == "VERIFIED" for row in actual.values()),
            "MISSING_WITNESS: precursor original did not qualify on these inputs")
    return {"qualifications": records, "requiredOriginals": actual}


def guards(root, cfg, previous):
    def reject(code, operation):
        try:
            operation()
        except (ValueError, RuntimeError) as error:
            require(str(error).startswith(code+":"), "wrong negative-control result for "+code+": "+str(error))
        else:
            raise ValueError("VERIFIER_FAILURE: negative control accepted " + code)
    for field in ("rank","english","prerequisite"):
        altered = copy.deepcopy(cfg)
        if field == "rank":
            altered["phases"].reverse()
        elif field == "english":
            altered["phases"][0]["original"]["statement"] += "?"
        else:
            altered["phases"][1]["predecessorOriginals"] = []
        reject("UNDECLARED_DEPENDENCY" if field=="prerequisite" else "CLAIM_MUTATION",
               lambda: check_plan(root,altered,previous))
    reject("UNDECLARED_DEPENDENCY", lambda: load_tenth(root).check_proof_workers(["lean","-j2","-o","T.olean"]))
    if CONFIG_SHA256 == "UNSEALED":
        print("Four controls rejected changed rank, English text, required original and compiler worker count.")
        return
    base=configure(root)
    with TemporaryDirectory(prefix="eleventh-guards-") as tmp:
        probe=Path(tmp)
        changed=copy.deepcopy(cfg)
        changed["phases"][0]["witness"]=cfg["phases"][1]["witness"]
        path=probe/base.CONFIG
        path.parent.mkdir(parents=True)
        base.write_json(path,changed)
        reject("CLAIM_MUTATION",lambda:base.read_registration(probe))
        evidence=probe/"evidence.json"
        base.write_json(evidence,{"recorded":True})
        bound=base.digest(evidence)
        base.write_json(evidence,{"recorded":False})
        reject("STALE_OR_UNBOUND_EVIDENCE",lambda:base.recheck(probe,{"evidenceFileSha256":bound},{},{}))
        file=probe/"observed.tsv"
        file.write_text("real row")
        clause={"claim":"original clause","status":"OPEN","boundary":"registered",
                "theorems":["measured"],"rows":[{"file":"observed.tsv","line":"missing row"}]}
        assessment={"status":"VERIFIED","boundary":"registered","clauses":[clause]}
        def assess():
            return base.original_assessment(assessment,probe,["measured"],{"observed.tsv":base.digest(file)})
        reject("MISSING_WITNESS",assess)
        clause["rows"][0]["line"]="real row"
        reject("SCOPE_LEAK",assess)
    print("Eight controls rejected changed rank, English text, required original, compiler worker count, "
          "witness substitution, tampered evidence, missing observation and open-clause promotion.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check-plan", action="store_true")
    mode.add_argument("--check-registration", action="store_true")
    mode.add_argument("--check-controls", action="store_true")
    mode.add_argument("--output", type=Path)
    parser.add_argument("--source", type=Path, default=Path(__file__).resolve().parents[3])
    for phase in ("eighth","ninth","tenth"):
        parser.add_argument("--"+phase+"-run",type=Path)
    parser.add_argument("--external-volume",nargs=2,metavar=("MOUNT","UUID"))
    args = parser.parse_args()
    here, root = Path(__file__).resolve(), args.source.resolve()
    registry = json.loads(here.with_name("qualification.json").read_bytes())
    prior = prior_registries(root, load_tenth(root))
    check_plan(root, registry, prior)
    if args.check_plan:
        print("Five original English rows, classes, scope and matrix digests, ordered selection and stated prerequisites match.")
        return 0
    if args.check_controls and CONFIG_SHA256=="UNSEALED":
        guards(root,registry,prior)
        return 0
    require(CONFIG_SHA256 != "UNSEALED" and registry["registrationState"]=="SEALED",
            "CLAIM_MUTATION: eleventh registration is an unsealed draft")
    require(here==root/PACKAGE/"verify_eleventh.py", "UNDECLARED_DEPENDENCY: use the candidate entry point")
    driver, base = configure_with_driver(root)
    cfg, _ = base.read_registration(root)
    if args.check_registration:
        driver.check_registration(root)
        return 0
    if args.check_controls:
        guards(root,cfg,prior)
        return 0
    out=args.output.resolve()
    require(not out.exists() and not out.is_relative_to(root),"a fresh output directory outside the checkout is required")
    folders=[args.eighth_run,args.ninth_run,args.tenth_run]
    require(all(folders),"MISSING_INPUT: three complete retained eighth, ninth and tenth two-build directories are required")
    folders=[p.resolve() for p in folders]
    required={s for p in cfg["phases"] for s in p["predecessorOriginals"]}
    try:
        bound=predecessors(root,folders,base.freeze(),required)
    except (OSError,ValueError,RuntimeError,KeyError) as exc:
        status="INFRASTRUCTURE_FAILURE" if isinstance(exc,OSError) else "BLOCKED"
        out.mkdir(parents=True,exist_ok=False)
        base.write_json(out/"report.json",{"profile":PROFILE,"status":status,"builds":[],"qualifiedSurfaces":[],
                                           "errors":[str(exc) or type(exc).__name__]})
        return base.common.STATES[status]
    run, recheck = base.qualify, base.recheck
    def execute(*params):
        return dict(run(*params),requiredPredecessors=bound)
    def checked(path, record, evidence, manifest):
        recheck(path,record,evidence,manifest)
        require(predecessors(root,folders,manifest,required)==evidence["requiredPredecessors"],
                "STALE_OR_UNBOUND_EVIDENCE: prior clean-build results changed")
    base.qualify,base.recheck=execute,checked
    sys.argv=[str(here),str(out)]+(["--external-volume",*args.external_volume] if args.external_volume else [])
    return base.main()


if __name__=="__main__":
    try:
        sys.exit(main())
    except (OSError,ValueError,RuntimeError,KeyError) as error:
        print(str(error),file=sys.stderr)
        sys.exit(2 if isinstance(error,OSError) else 1)
