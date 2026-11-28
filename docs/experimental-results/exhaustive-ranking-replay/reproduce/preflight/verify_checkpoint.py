#!/usr/bin/env python3
"""Independent exact-engine checkpoint recount. No producer imports or Java execution."""
import argparse
import collections
import csv
import datetime
import gzip
import hashlib
import json
import re
import sys
from pathlib import Path

from native_commitment import SerializedNumber, canonical, check_programs

RUNNER = "a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02"
COHORT = "074fbe5573ccf33de100f85cc14a7d0f33c297271b933401ee061d066da99ff5"
HISTORY = "5af1b5fe83317ddeadea6ca2e2c108ff1c361002588d4896a69185427749a010"
HFILE = "frozen/docs/experimental-results/historical-retention/paid-rank-witnesses-measured.jsonl"
CODEC = "7e1b99c660cdd98ffa5b294eb7338f81685419949246d930dfe69588766cbc6d"
HASH = re.compile("[0-9a-f]{64}")
UUID = r"[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}"
FLAGS = ("endpointCorrespondenceChecked", "fixedChoiceReplaysChecked", "sourceCertificatesChecked")
NATIVE_STATUS = {"MATCHED", "MISMATCH", "INVALID_REPLAY", "UNCHECKABLE", "ERROR", "WORKER_ERROR"}
FIELDS = ("left", "leftPredicate", "right", "rightPredicate")


def require(test, message):
    if not test:
        raise ValueError(message)


def unique(entries):
    obj = {}
    for key, val in entries:
        require(key not in obj, "Duplicate JSON key " + key)
        obj[key] = val
    return obj


def decode(data):
    return json.loads(data, object_pairs_hook=unique, parse_float=SerializedNumber)


def digest(path):
    with path.open("rb") as f:
        h = hashlib.sha256()
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
        return h.hexdigest()


def read(path):
    return decode(path.read_bytes())


def lines(path):
    with path.open("rb") as stream:
        for line in stream:
            require(line.endswith(b"\n"), "Truncated JSON record in " + str(path))
            yield decode(line)


def ident(row):
    return tuple(row[f] for f in FIELDS)


def tkey(job):
    return tuple(job[i] for i in (1, 2, 4, 5))


def reverse(job):
    return (job[0], *job[4:7], *job[1:4], job[7])


def strict_int(x):
    return type(x) is int and x >= 0


def object_same(a, b):
    return canonical(a) == canonical(b)


def validated_file(base, name, hash_value):
    rel = Path(name)
    require(isinstance(hash_value, str) and HASH.fullmatch(hash_value), "Malformed SHA-256")
    require(not rel.is_absolute() and ".." not in rel.parts and str(rel) == name, "Invalid path " + name)
    path = base / rel
    require(digest(path) == hash_value, "File hash differs " + str(path))
    return path


def native_ok(row, cost):
    if row.get("status") != "MATCHED" or row.get("reason") != "CHECKED_NATIVE_ACTIONS_EQUAL":
        return False
    if any(row.get(k) is not True for k in (*FLAGS, "nativeSequencesEqual")):
        return False
    if any(not strict_int(row.get(k)) or row[k] != cost for k in ("fastDistance", "certifiedDistance")):
        return False
    h = row.get("fastSequenceSha256")
    if not isinstance(h, str) or not HASH.fullmatch(h) or row.get("certifiedSequenceSha256") != h or "firstDifference" in row:
        return False
    if row.get("sequenceKind") == "FLAT_ACTIONS":
        if any(k in row for k in ("orderedBlockEffectsEqual", "fastBlockCount", "certifiedBlockCount")):
            return False
        suffix = "ActionCount"
    elif row.get("sequenceKind") == "TEMPORAL_BLOCK_EFFECTS" and row.get("orderedBlockEffectsEqual") is True:
        suffix = "BlockCount"
    else:
        return False
    fast, cert = (row.get(a + suffix) for a in ("fast", "certified"))
    return strict_int(fast) and strict_int(cert) and fast == cert


def check_observation(root, prefix, ordinal, job, row):
    require(row["kind"] == job[0] == "paid" and ident(row) == tkey(job), "Native source/predicate substitution")
    require(strict_int(row["ordinal"]) and row["ordinal"] == ordinal and strict_int(row["expected"]) and row["expected"] == int(job[7]), "Native ordinal/expected score drift")
    require(row["status"] in NATIVE_STATUS and isinstance(row.get("reason"), str) and row["reason"], "Unknown native outcome")
    passed = native_ok(row, int(job[7]))
    require(row.get("checked") is passed, "Native acceptance disagrees with strict independent verifier")
    if passed:
        require(not {"incidentPath", "incidentSha256"}.intersection(row), "Unexpected successful incident")
        return False
    name = row["incidentPath"]
    require(re.fullmatch(r"incidents/" + re.escape(prefix) + "-" + str(ordinal) + "-" + UUID + r"\.json\.gz", name), "Incident ordinal/path mismatch")
    archive = decode(gzip.decompress(validated_file(root, name, row["incidentSha256"]).read_bytes()))
    identity = {k:v for k,v in row.items() if k not in ("incidentPath", "incidentSha256")}
    require(object_same(archive["identity"], identity) and (archive["leftSha256"], archive["rightSha256"]) == (job[3], job[6]), "Capsule identity or selected source hashes differ")
    evidence = archive["nativeComparatorEvidence"]
    if row["status"] == "WORKER_ERROR":
        return False
    require(isinstance(evidence, dict) and evidence.get("status") == row["status"] and evidence.get("reason") == row["reason"], "Original native failure evidence missing")
    for key in (*FLAGS, "orderedBlockEffectsEqual", "firstDifference", "fastFirst", "certifiedFirst"):
        if key in evidence or key in row:
            require(key in row and key in evidence and object_same(evidence[key], row[key]), "Comparator field mismatch " + key)
    diag = evidence.get("diagnostic") or {}
    for arm in ("fast", "certified"):
        branch = diag.get(arm) or {}
        if "distance" in branch or arm + "Distance" in row:
            require("distance" in branch and arm + "Distance" in row and object_same(branch["distance"], row[arm + "Distance"]), "Native diagnostic score differs")
    check_programs(evidence, row)
    if row["status"] == "MISMATCH":
        require(all(evidence.get(k) is True for k in FLAGS) and row.get("nativeSequencesEqual") is False and strict_int(row.get("firstDifference")), "Mismatch lacks checked ordered divergence")
        suffix = "Blocks" if row["sequenceKind"] == "TEMPORAL_BLOCK_EFFECTS" else "Actions"
        index = row["firstDifference"]
        for arm in ("fast", "certified"):
            seq = evidence[arm + suffix]
            first = seq[index] if index < len(seq) else None
            # Native flat mismatch reports the action and temporal mismatch the full block.
            require(object_same(evidence.get(arm + "First"), first), "First differing native action/block is not the archived one")
    return "fastSequenceSha256" in row


def observe(args):
    core = args.workspace
    require(digest(core / "runner-identity.json") == RUNNER and digest(core / "cohort/manifest.json") == COHORT, "Wrong original")
    build = read(args.build_receipt)
    files = sorted((core / "results/incidents").glob("shard-*.json.gz"))
    inventory = {"incidents/"+p.name: digest(p) for p in files}
    if args.producer_snapshot:
        require(args.producer_snapshot_sha256 and digest(args.producer_snapshot) == args.producer_snapshot_sha256, "Producer selection digest differs")
        snap = read(args.producer_snapshot)
        require(snap["runnerSha256"] == RUNNER, "Unregistered producer cutoff")
        captured = {r["incidentPath"]:r["incidentSha256"] for r in snap["incidents"]}
        require(len(captured) == len(snap["incidents"]) and all(inventory.get(p)==h for p,h in captured.items()), "Frozen producer cutoff contains an unbound or duplicate incident")
        inventory = captured
    result = dict(schema="acgn-checkpoint-registration-v1", observedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(), engineCommit=build["git"]["commit"], engineSha256=digest(args.jar), buildReceiptSha256=digest(args.build_receipt), inputManifestSha256=COHORT, originalRunnerSha256=RUNNER, includeHistory=args.include_history, originalIncidentFiles=inventory)
    require(build["experimentJar"]["sha256"] == result["engineSha256"] and build["buildsByteIdentical"] is True, "Candidate reproducible build differs")
    if args.producer_snapshot:
        result["scopeSource"] = "Pinned producer cutoff rechecked against original committed incidents during audit"
        result["producerSnapshotSha256"] = args.producer_snapshot_sha256
    else:
        result["scopeSource"] = "Independent listing of original incident files"
    return result


def recover_original(workspace, registration, chosen_shards):
    expected, details, original_rows = {}, {}, {}
    by_shard = collections.defaultdict(dict)
    for path, checksum in registration["originalIncidentFiles"].items():
        m = re.fullmatch(r"incidents/(shard-\d{4})-(\d+)-" + UUID + r"\.json\.gz", path)
        require(m, "Invalid original incident path")
        shard, ordinal = m[1], int(m[2])
        require(ordinal not in by_shard[shard], "Duplicate original shard ordinal")
        by_shard[shard][ordinal] = (path, checksum)
    manifests = {s["id"]: s for s in chosen_shards}
    require(by_shard.keys() <= manifests.keys(), "Unknown original shard")
    for shard, pending in by_shard.items():
        s = manifests[shard]
        file = validated_file(workspace / "cohort", s["path"], s["sha256"])
        jobs = list(csv.reader(file.open(), delimiter="\t"))
        require(len(jobs) == s["rows"], "Bad source shard extent")
        for row in lines(workspace / "results" / (shard + ".jsonl")):
            ordinal = row["ordinal"]
            if ordinal not in pending:
                continue
            path, checksum = pending.pop(ordinal)
            job = tuple(jobs[ordinal])
            require(row["checked"] is False and (row["incidentPath"], row["incidentSha256"]) == (path, checksum), "Wrong original negative row")
            payload = check_observation(workspace / "results", shard, ordinal, job, row)
            key = tkey(job)
            require(key not in expected and len(job) == 8, "Duplicate original source pair")
            expected[key] = (job, {"baselineFailure"})
            details[key] = dict(shard=shard, ordinal=ordinal, incidentPath=path, incidentSha256=checksum, left=key[0], leftPredicate=key[1], right=key[2], rightPredicate=key[3], leftSha256=job[3], rightSha256=job[6], expected=int(job[7]), nativeStatus=row["status"])
            original_rows[key] = dict(reason=row["reason"], mode=row.get("sequenceKind"), payloadRehashed=payload)
            if not pending:
                break
        require(not pending, "Missing original committed observation " + shard)
    return expected, details, original_rows


def include_history(workspace, shards, expected):
    historical = {}
    for row in lines(validated_file(workspace, HFILE, HISTORY)):
        key = tuple(row[k] for k in ("submission", "predicate", "reference", "referencePredicate"))
        require(key not in historical and strict_int(row["expected"]) and row["expected"] > 0, "Invalid archived paid floor")
        historical[key] = (row["sourceSha256"], row["referenceSha256"], row["expected"])
    require(len(historical) == 83, "Archived witness floor is incomplete")
    pools = {(k[0].split("/")[0], k[1]) for k in historical}
    for s in shards:
        if tuple(s["pool"]) not in pools:
            continue
        file = validated_file(workspace / "cohort", s["path"], s["sha256"])
        with file.open() as f:
            for cells in csv.reader(f, delimiter="\t"):
                job = tuple(cells)
                key = tkey(job)
                if key not in historical:
                    continue
                confirmed = (job[3], job[6], int(job[7]))
                require(job[0] == "paid" and confirmed == historical[key], "Archived floor source bytes/score differ")
                if key not in expected:
                    expected[key] = (job, set())
                original, groups = expected[key]
                require(original == job and "historical83" not in groups, "Duplicate or substituted historical pair")
                groups.add("historical83")
    require(all(k in expected and "historical83" in expected[k][1] for k in historical), "Missing historical ranking job")


def audit(args):
    w, target = args.workspace, args.target
    reg = read(args.snapshot)
    require(digest(args.snapshot) == args.snapshot_sha256, "Independent frozen selection digest differs")
    require(digest(Path(__file__).with_name("native_commitment.py")) == CODEC, "Unregistered ordered sequence encoder")
    require(reg["originalRunnerSha256"] == digest(w / "runner-identity.json") == RUNNER, "Original runner differs")
    require(reg["inputManifestSha256"] == digest(w / "cohort/manifest.json") == COHORT, "Original scores/cohort differ")
    runner, cohort, build = read(w/"runner-identity.json"), read(w/"cohort/manifest.json"), read(args.build_receipt)
    require(runner["inputManifestSha256"] == COHORT and cohort["rows"] == runner["rows"] == 1894168 and runner["sourceCommit"] == cohort["measuredCommit"] and runner["sourceRunId"] == cohort["measuredRunId"], "Original measurement identity differs")
    require(digest(args.jar) == reg["engineSha256"] == build["experimentJar"]["sha256"] and digest(args.build_receipt) == reg["buildReceiptSha256"] and build["git"]["commit"] == reg["engineCommit"] and build["buildsByteIdentical"] is True, "Wrong candidate binary/build")
    for path, h in runner["files"].items():
        if path.startswith(("runner-classes/", "frozen/lib/", "runner/ExhaustiveNativeReplay.java")):
            validated_file(w, path, h)
    for directory, pattern in (("frozen/lib", "*.jar"), ("runner-classes", "*.class")):
        actual = {p.relative_to(w).as_posix() for p in (w/directory).rglob(pattern)}
        require(actual == {p for p in runner["files"] if p.startswith(directory + "/")}, "Unbound runtime class/dependency")
    require({p.split("/")[-1]:h for p,h in runner["files"].items() if p.startswith("frozen/lib/")} == build["dependencies"], "Candidate build dependencies differ")
    expected, original, original_rows = recover_original(w, reg, cohort["shards"])
    require(type(reg["includeHistory"]) is bool, "Malformed historical selection")
    if reg["includeHistory"]:
        include_history(w, cohort["shards"], expected)
    require(expected, "Empty checkpoint")
    stable_sources = {}
    spec = {}
    for key, (job, groups) in expected.items():
        for p,h in ((job[1], job[3]), (job[4], job[6])):
            require(stable_sources.setdefault(p,h) == h, "Conflicting selected input hashes")
        for direction, oriented in (("forward",job), ("reverse",reverse(job))):
            require(oriented not in spec, "Directional identity collision")
            spec[oriented] = (direction, sorted(groups), key)
    for path,h in stable_sources.items():
        validated_file(w / "frozen/classified-data", path, h)
    summary = read(target / "summary.json")
    if "observedProducerSha256" in reg:
        observed = reg["observedProducerSha256"]
        require(summary.get("verifierSha256") == observed, "Checkpoint producer changed between registration and completion")
        validated_file(w, "packaging/replay_regressions.py", observed)
    new_snap = target / "original-incident-snapshot.json"
    if "producerSnapshotSha256" in reg:
        require(digest(new_snap) == reg["producerSnapshotSha256"], "Wrong producer selection snapshot")
    if new_snap.exists() or "originalIncidentSnapshotSha256" in summary:
        require(summary["originalIncidentSnapshotSha256"] == digest(new_snap), "Producer original snapshot digest differs")
        snap = read(new_snap)
        require(snap["runnerSha256"] == RUNNER and datetime.datetime.fromisoformat(snap["listingStartedUtc"]) <= datetime.datetime.fromisoformat(snap["listingFinishedUtc"]), "Invalid producer snapshot interval")
        actual = sorted(snap["incidents"], key=lambda r:(r["shard"], r["ordinal"]))
        recorded = sorted(original.values(), key=lambda r:(r["shard"], r["ordinal"]))
        require(object_same(actual, recorded), "Producer's cutoff differs from independent registration")
    expected_counts = collections.Counter(g for job,groups in expected.values() for g in groups)
    parts = sorted(target.glob("part-*"))
    require(parts and [p.name for p in parts] == [f"part-{i:03d}" for i in range(len(parts))], "Missing or extra candidate part")
    scope, outcomes, scores, modes, group_results = set(), {}, collections.Counter(), collections.Counter(), collections.Counter()
    first_error = None
    input_hashes, raw_hashes, pcounts, failed_hashes, residuals = {}, {}, {}, [], []
    allrows = iter(lines(target / "native-observations.jsonl"))
    for part in parts:
        name = part.name
        inp = part / "inputs.tsv"
        ledger = part / (name + ".jsonl")
        input_hashes[name], raw_hashes[name] = digest(inp), digest(ledger)
        with inp.open() as f:
            jobs = [tuple(r) for r in csv.reader(f, delimiter="\t")]
        native_rows = list(lines(ledger))
        require(len(native_rows) == len(jobs) and jobs, "Native output incomplete")
        progress = decode((part/"worker.log").read_bytes().splitlines()[-1])
        require(progress["shard"] == name and strict_int(progress["rows"]) and strict_int(progress["newRows"]) and progress["rows"] == progress["newRows"] == len(jobs), "Worker execution extent differs")
        linked = set()
        first_part_failure = None
        pcounts[name] = {"rows":len(jobs), "sha256":input_hashes[name]}
        for ordinal,(job,row) in enumerate(zip(jobs,native_rows)):
            require(job in spec and job not in scope, "Unselected, duplicate, or substituted direction/input hash/score")
            scope.add(job)
            direction, groups, key = spec[job]
            full = next(allrows, None)
            require(object_same(full, dict(groups=groups, direction=direction, **row)), "Combined ledger alters raw observation, direction or cohort")
            rehashed = check_observation(part, name, ordinal, job, row)
            passed = row["checked"]
            outcomes.setdefault(key, {})[direction] = passed
            scores["agreeWithOriginal" if all(strict_int(row.get(k)) and row[k] == int(job[7]) for k in ("fastDistance", "certifiedDistance")) else "missingOrDifferent"] += 1
            modes[(direction,row.get("sequenceKind","NONE"),row["status"])] += 1
            for group in groups:
                group_results[(group,direction,"checked" if passed else "failed")] += 1
            if not passed:
                linked.add(row["incidentPath"])
                if first_part_failure is None:
                    first_part_failure = row
                if rehashed:
                    failed_hashes.append(row["incidentSha256"])
                if first_error is None:
                    first_error = full
                residuals.append(dict(source=key[0], sourcePredicate=key[1], reference=key[2], referencePredicate=key[3], direction=direction, expected=int(job[7]), groups=groups, nativeStatus=row["status"], reason=row["reason"], sequenceKind=row.get("sequenceKind"), firstDifference=row.get("firstDifference"), fastDistance=row.get("fastDistance"), certifiedDistance=row.get("certifiedDistance"), fastSequenceSha256=row.get("fastSequenceSha256"), certifiedSequenceSha256=row.get("certifiedSequenceSha256"), originalIncident=original.get(key,{}).get("incidentPath"), candidateIncident=name+"/"+row["incidentPath"], candidateIncidentSha256=row["incidentSha256"]))
        marker = part/"first-incident.json"
        if first_part_failure is None:
            require(not marker.exists(), "Unexpected first incident marker")
        else:
            require(object_same(read(marker),dict(shard=name, **first_part_failure)), "First incident marker disagrees with raw part ledger")
        require(linked == {p.relative_to(part).as_posix() for p in (part/"incidents").iterdir()}, "Unreferenced/missing candidate incident artifacts")
    require(scope == spec.keys() and next(allrows,None) is None, "Combined observation ledger or native directions incomplete")
    if "observedCandidatePartInputs" in reg:
        require(object_same(reg["observedCandidatePartInputs"],pcounts), "Input files differ from independently observed selection")
    for k, actual in (("partInputSha256",input_hashes),("partOutputSha256",raw_hashes)):
        if new_snap.exists() or k in summary:
            require(summary.get(k) == actual, "Returned part hash manifest differs")
    status = "BLOCKED" if residuals else "VERIFIED"
    expected_summary = dict(status=status,pairs=len(expected),directions=len(scope),failures=len(residuals),firstFailure=first_error,cohorts=dict(expected_counts),engineSha256=reg["engineSha256"],inputManifestSha256=COHORT,adapterIdentitySha256=RUNNER,ledgerSha256=digest(target/"native-observations.jsonl"))
    require(all(k in summary and object_same(summary[k],v) for k,v in expected_summary.items()), "Producer headline differs from recomputed observations")
    patterns = collections.Counter((v["forward"],v["reverse"]) for v in outcomes.values())
    return dict(schema="acgn-independent-exact-jar-checkpoint-recount-v1", recountStatus="VERIFIED",nativeCheckpointStatus=status, candidateCommit=reg["engineCommit"],candidateJarSha256=reg["engineSha256"],buildReceiptSha256=reg["buildReceiptSha256"],originalRunnerSha256=RUNNER,originalInputManifestSha256=COHORT,snapshotSha256=args.snapshot_sha256,originalIncidents=len(original),originalFailureProgramsRehashed=sum(v["payloadRehashed"] for v in original_rows.values()),historyFloorRows=83 if reg["includeHistory"] else 0,historyFloorSha256=HISTORY if reg["includeHistory"] else None,originalPairs=len(expected),uniqueSourceFiles=len(stable_sources),directions=len(scope),verifiedDirections=len(scope)-len(residuals),failedDirections=len(residuals),candidateFailureProgramsRehashed=len(failed_hashes),scalarChecks=dict(scores),nativeCounts=[dict(direction=k[0],mode=k[1],status=k[2],count=n) for k,n in sorted(modes.items())],cohortCounts=[dict(cohort=k[0],direction=k[1],status=k[2],count=n) for k,n in sorted(group_results.items())],pairOutcomes=[dict(forward=f,reverse=r,count=n) for (f,r),n in sorted(patterns.items())],partInputSha256=input_hashes,partOutputSha256=raw_hashes,observationsSha256=expected_summary["ledgerSha256"],producerSummarySha256=digest(target/"summary.json"),producerScriptSha256=reg.get("observedProducerSha256"),checkerSha256=digest(Path(__file__)),orderedCommitmentCodecSha256=CODEC,failures=residuals)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    sub=parser.add_subparsers(dest="action",required=True)
    for action in ("snapshot","audit"):
        p=sub.add_parser(action)
        for name in ("workspace","jar","build-receipt","output"):
            p.add_argument("--"+name,type=Path,required=True)
        if action=="snapshot":
            p.add_argument("--include-history",action="store_true")
            p.add_argument("--producer-snapshot",type=Path)
            p.add_argument("--producer-snapshot-sha256")
        else:
            for name in ("snapshot","target"):
                p.add_argument("--"+name,type=Path,required=True)
            p.add_argument("--snapshot-sha256",required=True)
    args=parser.parse_args()
    result = observe(args) if args.action=="snapshot" else audit(args)
    with args.output.open("x") as f:
        json.dump(result,f,indent=2,sort_keys=True)
        f.write("\n")
    print(digest(args.output),args.output,result.get("nativeCheckpointStatus","REGISTERED"))
    return 2 if result.get("nativeCheckpointStatus")=="BLOCKED" else 0


if __name__=="__main__":
    sys.exit(main())
