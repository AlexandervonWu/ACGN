"""Bind the independently checked stage, pool, proof, CI, and worked-example evidence to the repaired build."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

from native_release import DIGEST, FLOOR, read, regular, require, sha


def independent(script, *args):
    response = subprocess.run([sys.executable, "-B", str(script), *map(str, args)],
                              capture_output=True, text=True)
    require(response.returncode == 0, response.stderr or response.stdout)
    return json.loads(response.stdout.splitlines()[-1])


def assess_extra_cohorts(root, bound, repo):
    for kind,name,rows in (("stages","stage-attribution/manifest.json",938),("pools","reference-pool-scores/summary.json",132032)):
        receipt = read(root/"receipts/repaired"/(kind+"-export.json"))
        require(receipt == dict(status="VERIFIED",file=name,sha256=sha(regular(root,name)),jarSha256=bound["jar"],uuid=bound["uuid"],rows=rows),
                "Independent export receipt does not match its installed data: "+kind)
    stages = root / "stage-attribution"
    stage = independent(regular(stages, "verify.py"), stages, "--full-archive", root / "repaired")
    full = stage.get("final") or {}
    require(full.get("fullForwardProgramsMatched") == FLOOR and full.get("forwardAndReverseMatched") == 2*FLOOR
            and full.get("jarSha256") == bound["jar"] and full.get("identitySha256") == bound["identity"],
            "Repaired historical-stage evidence is missing or describes another run")
    pool = root / "reference-pool-scores"
    ps = independent(regular(pool, "verify.py"), pool, "--repo", repo)
    require(ps.get("status") == "VERIFIED" and ps.get("allPairs") == 132032
            and ps.get("structuralZeros") == 19271 and ps.get("recordedPositiveInputs") == 112761
            and ps.get("originalScalarDifferences") == ps.get("newScalarDifferences") == 0
            and ps.get("finalCommit") == bound["commit"] and ps.get("finalRunId") == bound["uuid"]
            and ps.get("finalJarSha256") == bound["jar"] and ps.get("markerSha256") == sha(root / "receipts/repaired/final-started.json"),
            "Within-reference pool comparison is incomplete or describes a different engine")
    return ps


def check_build_and_proofs(root, bound, repo):
    rec = root / "receipts/repaired"
    proof = rec / "kernel"
    kr = read(proof / "receipt.json")
    gate = rec / "bounded-ci"
    ci = read(gate / "receipt.json")
    build = read(rec / "build-receipt.json")
    commit = bound["commit"]
    require(build["git"]["tree"] == ci["gitTree"] ==
            subprocess.check_output(["git", "-C", repo, "rev-parse", commit + "^{tree}"], text=True).strip()
            and ci["gitCommit"] == kr["commit"] == commit, "Kernel, build or bounded suite belongs to another source")
    require(ci["cleanBefore"] is True and ci["exit"] == 0 and ci["command"] == "bash scripts/run_bounded_ci_java_tests.sh"
            and ci["logSha256"] == sha(gate / "bounded.log") and ci["resourceReceiptSha256"] == sha(gate / "usage.txt"),
            "Missing bounded suite success or changed logs")
    require(kr["status"] == "VERIFIED" and kr["compilerScriptSha256"] == sha(root / "reproduce/ci/kernel_receipt.py"),
            "Lean kernel/compiler registration mismatch")
    builds = rec / "build-inventories"
    require(sha(builds / "classes.sha256") == build["classfileManifestSha256"]
            and sha(builds / "sources.sha256") == build["sourceManifestSha256"] and
            {m["build"] for m in build["builds"]} == {"a","b"} and
            all(sha(regular(builds, m["build"] + ".log")) == m["logSha256"] for m in build["builds"]),
            "Changed source/class census or clean build logs")
    names = set()
    for module in kr["modules"]:
        path = module["path"]
        name = Path(path).stem
        require(name not in names and sha(regular(proof, name + ".log")) == module["logSha256"]
                and hashlib.sha256(subprocess.check_output(["git", "-C", repo, "show", commit + ":" + path])).hexdigest() == module["sourceSha256"],
                "Lean source/log mismatch in " + path)
        names.add(name)
    require(names == {"SurvivorWitnessOrder", "DeclarationReplay", "CrossedDeclarationReplay", "OriginalOccurrenceOrder",
                      "TemporalDeclarationTie", "CoursesPaidData", "CoursesPaidAlignmentTie", "CoursesRepairedNative",
                      "SingleSourceClassMinimum", "CoalescedDeclarationFrames"}, "Missing frozen Lean modules")
    freeze = read(rec / "root-freeze.json")
    expected = freeze["prerequisiteFiles"]
    for path, digest in expected.items():
        require(DIGEST.fullmatch(digest) and sha(regular(rec / "prerequisites", digest)) == digest,
                "Missing prelaunch evidence " + path)
    require(sha(proof / "receipt.json") in expected.values() and sha(root/"reproduce/build-registered-revision.py") in expected.values(),
            "Build script or proof census is absent from the launch prerequisites")


def worked(root, jar):
    # The original registered codec preserves lexical JSON number identity on both arms.
    sys.path.insert(0, str(root / "reproduce/original-audit"))
    from native_commitment import SerializedNumber, canonical, check_programs
    examples = root / "worked-examples"
    rows = list(examples.glob("*-example.json"))
    require(len(rows) == 5, "The five native worked examples were not supplied")
    for path in rows:
        r = read(path)
        src = regular(root / "original/incidents", r["originalIncident"])
        dst = regular(examples, r["afterEvidence"])
        require(r["originalIncidentSha256"] == sha(src) and r["afterEvidenceSha256"] == sha(dst) and r["candidateJarSha256"] == jar,
                "Worked example is bound to another input or JAR")
        with gzip.open(src, "rt") as f:
            orig = json.load(f, parse_float=SerializedNumber)
        with gzip.open(dst, "rt") as f:
            new = json.load(f, parse_float=SerializedNumber)
        old, obs = orig["nativeComparatorEvidence"], orig["identity"]
        check_programs(old, obs)
        require(obs["status"] == old["status"] == "MISMATCH" and
                new["status"] == "MATCHED" and new["reason"] == "CHECKED_NATIVE_ACTIONS_EQUAL" and
                all(new.get(k) is True for k in ("sourceCertificatesChecked", "endpointCorrespondenceChecked", "fixedChoiceReplaysChecked"))
                and obs["expected"] == r["cost"] and r["left"] == [obs["left"],obs["leftPredicate"],orig["leftSha256"]]
                and r["right"] == [obs["right"],obs["rightPredicate"],orig["rightSha256"]],
                "Worked example endpoint, cost, or native verdict changed")
        def sequence(prog, arm):
            if r["kind"] == "FLAT_ACTIONS":
                return prog[arm + "Actions"]
            require(r["kind"] == "TEMPORAL_BLOCK_EFFECTS", "Unknown representation")
            return [[b["component"], b["effect"]] for b in prog[arm + "Blocks"]]
        a,b,c,d = [sequence(p, arm) for p in (old,new) for arm in ("fast","certified")]
        digest = lambda x: hashlib.sha256(canonical(x).encode()).hexdigest()
        require(all(p["diagnostic"][arm]["distance"] == r["cost"] for p in (old,new) for arm in ("fast","certified"))
                and r["kind"] == obs["sequenceKind"] and (r["kind"] != "TEMPORAL_BLOCK_EFFECTS" or new.get("orderedBlockEffectsEqual") is True)
                and canonical(c) == canonical(d) and [digest(a),digest(b),digest(c)] ==
                [r["oldFastSequenceSha256"],r["oldCertifiedSequenceSha256"],r["newSequenceSha256"]]
                and r["certifiedProgramPreserved"] == (canonical(b) == canonical(d)) and
                [len(a),len(b)] == r["oldCounts"] and len(c) == r["newCount"], "Native worked-example programs changed")


def diagnostic_controls(root, bound, repo):
    folder = root / "receipts/repaired/diagnostic-controls"
    near = read(folder / "pre-budget-neighbors.json")
    assembly = read(root / "reproduce/jar-assembly/engines.json")
    require(near["status"] == "VERIFIED" and near["scope"].startswith("Pre-budget-handling Java overlay")
            and near["baseJarSha256"] == assembly["candidate-04"]["sha256"] and near["baseJarSha256"] != bound["jar"]
            and near["byStatus"] == {"MATCHED":432} and near["totalDirections"] == 2*near["cohortForward"] == 432,
            "Changed earlier-overlay neighbor control receipt")
    for path, digest in near["sourceFiles"].items():
        require(sha(regular(repo / "classified-data", path)) == digest, "Changed neighbor control source")
    archival = read(folder / "archival-controls.json")
    require(archival["candidateCommit"] == bound["commit"] and archival["baselineCommit"] == assembly["candidate-04"]["git"],
            "Archival harness comparison belongs to other revisions")
    runs = {(r["test"],r["stage"]):r for r in archival["runs"]}
    require(len(runs) == len(archival["runs"]) == 6, "Incomplete archival harness results")
    for name, status in (("FastLocalPaidScopeTest",1), ("RetainedPaidCompletionTest",1), ("ArchiveFacts",0)):
        before,after = (runs[name, stage] for stage in ("candidate-04", "final-05"))
        require(before["exit"] == after["exit"] == status and before["assertion"] == after["assertion"]
                and before["facts"] == after["facts"] and before["jarSHA"] == assembly["candidate-04"]["sha256"]
                and after["jarSHA"] == bound["jar"], "Archival harness results changed")
        for r in (before,after):
            require(sha(regular(folder, Path(r["log"]).name)) == r["logSHA"], "Changed archival harness logs")
