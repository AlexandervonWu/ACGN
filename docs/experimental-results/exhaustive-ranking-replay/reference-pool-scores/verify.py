"""Check every within-pool reference score, compare original and final programs' scalar results, and build the zero graph."""

import argparse
import collections
import csv
import gzip
import hashlib
import itertools
import io
import json
from pathlib import Path

ORIGINAL_JAR = "a4c30092d064b8fa39011d888b2a9898a8b5060588e3356bb98e8ba34543217e"
ORIGINAL_SCORES = "da470f79361d72e8a9e1e6feb8e68a4658c0b6152b8f89cb8ec61c49f48fccb4"
CATALOG = "d2ffb181e2921e8536db9d2836f22f50a2faf9a22edebf83552ce68bb44bf5b1"


def need(ok, message):
    if not ok:
        raise ValueError(message)


def sha(p):
    h = hashlib.sha256()
    with p.open("rb") as f:
        for b in iter(lambda: f.read(1024 * 1024), b""):
            h.update(b)
    return h.hexdigest()


def digest(b):
    return hashlib.sha256(b).hexdigest()


def encoded(v):
    return (json.dumps(v, indent=2, sort_keys=True) + "\n").encode()


def read(p):
    return json.loads(p.read_bytes())


def source_sets(root, repo):
    path = root / "reference-catalog.tsv"
    need(sha(path) == CATALOG, "Wrong published reference identities")
    with path.open() as f:
        refs = list(csv.DictReader(f, delimiter="\t"))
    sources = {r["source"]: r["sourceSha256"] for r in refs}
    refids = {}
    by_group = collections.defaultdict(set)
    for name, h in sources.items():
        need(sha(repo / "classified-data" / name) == h, "Changed original reference source " + name)
    names = {}
    for r in refs:
        rid = int(r["referenceId"])
        group = r["questionSet"], r["invariantId"]
        k = (r["source"], r["name"])
        need(
            rid not in refids and k not in names and r["sourceSha256"] == sources[r["source"]],
            "Repeated reference or invalid source",
        )
        by_group[group].add(rid)
        refids[rid] = r
        names[k] = rid
    pool_decisions = (
        repo / "docs/experimental-results/historical-retention/correct-pool-pairs.jsonl.gz"
    )
    need(sha(pool_decisions) == ORIGINAL_SCORES, "Wrong historical decisions")
    positive = set()
    zero = set()
    all_pairs = {
        tuple(sorted(c)) for ids in by_group.values() for c in itertools.combinations(ids, 2)
    }
    with gzip.open(pool_decisions, "rt") as f:
        for line in f:
            r = json.loads(line)
            a, b = (names[r[n + "Source"], r[n]] for n in ("left", "right"))
            group = r["questionSet"], r["invariantId"]
            need(
                type(r["structuralZero"]) is bool
                and a in by_group[group]
                and b in by_group[group]
                and (a, b) not in positive
                and (a, b) not in zero,
                "Invalid historical pair",
            )
            (zero if r["structuralZero"] else positive).add((a, b))
    need(
        len(refids) == 4496
        and len(by_group) == 181
        and len(positive) == 112761
        and len(zero) == 19271
        and len(all_pairs) == 132032
        and {tuple(sorted(k)) for k in positive | zero} == all_pairs,
        "Invalid pool partition",
    )
    return refids, by_group, positive, zero


def verify(root, repo, require_report=True):
    m = read(root / "files.json")
    for f, h in m.items():
        need(sha(root / f) == h, "Changed pool evidence " + f)
    refs, pools, positive, zero = source_sets(root, repo)
    ids = {n: read(root / (n + "-identity.json")) for n in ("original", "final")}
    ends = {n: read(root / (n + "-completion.json")) for n in ids}
    schedule = read(root / "inputs.json")
    sides = read(root / "shard-receipts.json")
    marker = read(root / "final-started.json")
    zero_reg = read(root / "zero-verdict.json")
    z_files = read(root / "zero-checksums.json")
    need(
        ids["original"]["jarSha256"] == ORIGINAL_JAR
        and ids["original"]["authorizationSha256"]
        == "a2cf64f0889624b0dc675b73d80f5b34caca2d73c9448b788713463b8abc3f02",
        "Wrong original JAR",
    )
    need(
        ids["final"]["execution"] == "final-" + marker["uuid"]
        and ids["final"]["authorizationSha256"] == sha(root / "final-started.json")
        and ids["final"]["jarSha256"] == marker["jarSha256"] == zero_reg["candidateSha256"]
        and ids["final"]["sourceCommit"] == marker["commit"] == zero_reg["candidateCommit"],
        "Supplemental engines differ",
    )
    need(
        zero_reg["status"] == "VERIFIED"
        and zero_reg["sourceNativeCommands"]["zero"] == 19271
        and z_files["zero.jsonl.gz"] == sha(root / "zero.jsonl.gz")
        and z_files["combined-verdict.json"] == sha(root / "zero-verdict.json"),
        "Zero jobs lack audited retention outcomes",
    )
    need(
        schedule["positiveRows"] == 112761
        and schedule["nativeZeroRows"] == 19271
        and schedule["catalogSha256"] == CATALOG
        and schedule["originalZeroDecisionsSha256"] == ORIGINAL_SCORES,
        "Wrong input scope",
    )
    reg = read(root / "registration.json")
    for f, h in reg["files"].items():
        need(sha(root / f) == h, "Changed registered scalar adapter " + f)
    names = {s["name"] for s in schedule["shards"]}
    for n, i in ids.items():
        c = ends[n]
        need(
            sha(root / (n + "-identity.json")) == c["identity"]
            and i["driverRegistrationSha256"] == sha(root / "registration.json")
            and c["inputs"] == i["inputManifestSha256"] == sha(root / "inputs.json")
            and c["rows"] == 112761
            and names == set(c["shards"]) == set(sides[n]),
            "Shard/engine scope differs",
        )
        need(
            {p: sha(root / (n + "-classes") / p) for p in i["classes"]} == i["classes"],
            "Scalar driver bytecode differs",
        )
    orders = [read(root / ("runtime-order-" + n + ".json"))["jarOrder"] for n in ids]
    need(
        orders[0] == orders[1]
        and len(orders[0]) == len(set(orders[0]))
        and all(set(order) == set(i["runtime"]) for order, i in zip(orders, ids.values())),
        "Runtime dependency order differs",
    )
    cal = read(root / "cache-repeat.json")
    trial = read(root / "initial-trial-identity.json")
    need(
        cal["status"] == "VERIFIED"
        and trial["jarSha256"] == ORIGINAL_JAR
        and trial["inputManifestSha256"] == ids["original"]["inputManifestSha256"]
        and cal["trialRunnerIdentitySha256"] == sha(root / "initial-trial-identity.json")
        and cal["originalRunnerIdentitySha256"] == ends["original"]["identity"],
        "Wrong original cache calibration",
    )
    repeated = set()
    repeat_rows = 0
    for sh in cal["shards"]:
        n = sh["shard"]
        need(n not in repeated and n in sides["original"], "Duplicate or unknown trial comparison")
        repeated.add(n)
        raw = sides["original"][n]
        repeat_rows += raw["rows"]
        old = dict(raw, identity=cal["trialRunnerIdentitySha256"])
        need(
            raw["input"] == sh["input"]
            and raw["output"] == sh["output"]
            and sh["newReceipt"] == ends["original"]["shards"][n]
            and sh["trialReceipt"] == digest(encoded(old)),
            "Calibration score/input authority differs",
        )
    need(
        len(repeated) == cal["earlierCompleteShards"] == cal["checkedShards"] == 121
        and repeat_rows == cal["observedTwice"] == 46464,
        "Incomplete cache replay calibration",
    )
    negatives = set()
    score_changes = collections.Counter()
    categories = collections.Counter()
    zero_ids = {
        "originalFast": set(),
        "originalCertified": set(),
        "finalFast": set(),
        "finalCertified": set(),
    }
    cost_changed = []
    example_observation = None
    with gzip.open(root / "positive-scores.tsv.gz", "rt", newline="") as f:
        for s in schedule["shards"]:
            name = s["name"]
            inputs = hashlib.sha256()
            result = {n: hashlib.sha256() for n in ids}
            tally = {n: collections.Counter() for n in ids}
            for k in range(s["rows"]):
                cells = f.readline().rstrip("\n").split("\t")
                need(
                    len(cells) == 6
                    and all(t.isascii() and t.isdecimal() and str(int(t)) == t for t in cells),
                    "Malformed score row",
                )
                a, b, of, oc, nf, nc = map(int, cells)
                key = a, b
                need(
                    key in positive and key not in negatives,
                    "Foreign, duplicate or substituted positive score",
                )
                negatives.add(key)
                job = f"{a}\t{b}"
                inputs.update((job + "\n").encode())
                for n, fast, cert in [("original", of, oc), ("final", nf, nc)]:
                    result[n].update(f"{job}\t{fast}\t{cert}\n".encode())
                    d = tally[n]
                    d["unmatchedArms"] += fast != cert
                    d["fastZeros"] += fast == 0
                    d["certifiedZeros"] += cert == 0
                    categories[n + "ArmDisagreements"] += fast != cert
                    if fast == 0:
                        zero_ids[n + "Fast"].add(key)
                    if cert == 0:
                        zero_ids[n + "Certified"].add(key)
                if (a, b) == (192, 193):
                    example_observation = (of, oc, nf, nc)
                score_changes["Fast"] += of != nf
                score_changes["Certified"] += oc != nc
                score_changes["either"] += (of, oc) != (nf, nc)
                if of != oc or nf != nc or min(of, oc, nf, nc) == 0 or (of, oc) != (nf, nc):
                    cost_changed.append([a, b, of, oc, nf, nc])
            need(inputs.hexdigest() == s["sha256"], "Scalar shard inputs differ")
            for n in ids:
                rec = dict(
                    rows=s["rows"],
                    input=s["sha256"],
                    output=result[n].hexdigest(),
                    identity=ends[n]["identity"],
                    **tally[n],
                )
                need(
                    rec == sides[n][name] and ends[n]["shards"][name] == digest(encoded(rec)),
                    "Scalar receipts differ " + n + " " + name,
                )
        need(not f.readline() and negatives == positive, "Missing/extra positive pairs")
    example_record = read(root / "example-command-outcome.json")
    decision = example_record["decision"]
    batch = read(root / "example-command-batch.json")
    need(
        example_observation == (7, 7, 7, 7)
        and example_record["pair"] == [192, 193]
        and sha(root / "example.als")
        == example_record["sha256"]
        == example_record["parsedSourceSha256"]
        == "424f90357dc04ce0be157dda044e7d1717148772163f1af38fdba32791459faa"
        and decision["native"] == "UNSAT"
        and decision["bitwidth"] == 4
        and decision["rules"] == ["fiber"]
        and batch["candidateJarSha256"] == marker["jarSha256"]
        and batch["status"] == "VERIFIED"
        and batch["total"] == 1339,
        "Worked scope and structural example differs from recorded measurements",
    )
    seen = set()
    with gzip.open(root / "zero.jsonl.gz", "rt") as f:
        for line in f:
            r = json.loads(line)
            key = tuple(r["referenceIds"])
            need(
                key in zero
                and key not in seen
                and r["state"] == "MATCHED"
                and r["observedFast"] == r["observedCertified"] == r["expected"] == 0,
                "Incorrect final native zero",
            )
            for n, refid in zip(("a", "b"), key):
                selected = refs[refid]
                need(
                    r[n] == [selected["source"], selected["predicate"], selected["sourceSha256"]],
                    "Native zero selected different endpoint",
                )
            seen.add(key)
    need(seen == zero, "Missing original/candidate zero comparison")
    slotted_path = (
        repo / "docs/experimental-results/historical-retention/slotted-reference-pairs.csv.gz"
    )
    need(
        sha(slotted_path) == "372e5e26ddda280573308f54c3dafd1ec05a4f671d7365f7d1f9ba677bd33a71",
        "Historical Slotted measurements changed",
    )
    slotted = set()
    slotted_inventory = set()
    with gzip.open(slotted_path, "rt") as f:
        for r in csv.DictReader(f):
            key = tuple(sorted((int(r["left"]), int(r["right"]))))
            value = int(r["distance"])
            need(
                key not in slotted_inventory and value >= 0,
                "Invalid original Slotted reference comparison",
            )
            slotted_inventory.add(key)
            if value == 0:
                slotted.add(key)
    need(
        len(slotted) == 8952 and slotted_inventory == {tuple(sorted(k)) for k in (positive | zero)},
        "Different original Slotted reference cohort",
    )
    counts = {}
    per_pool = {
        key: dict(
            questionSet=key[0],
            invariantId=key[1],
            references=len(ids),
            pairs=len(ids) * (len(ids) - 1) // 2,
        )
        for key, ids in sorted(pools.items())
    }
    group_by_ref = {i: k for k, ids in pools.items() for i in ids}
    stored_slotted_counts = collections.Counter(group_by_ref[a] for a, b in slotted)
    for k in per_pool:
        per_pool[k]["originalSlottedZeros"] = stored_slotted_counts[k]
    for method, z in zero_ids.items():
        z |= zero
        parent = {i: i for i in refs}

        def leader(i):
            while parent[i] != i:
                parent[i] = parent[parent[i]]
                i = parent[i]
            return i

        for a, b in z:
            parent[leader(a)] = leader(b)
        counter = collections.Counter(leader(i) for i in refs)
        counts[method] = dict(
            zeros=len(z),
            structuralForms=len(counter),
            componentPairs=sum(n * (n - 1) // 2 for n in counter.values()),
        )
        zkeys = {tuple(sorted(k)) for k in z}
        missing = slotted - zkeys
        extra = zkeys - slotted
        counts[method].update(missingSlotted=len(missing), additionalZerosBeyondSlotted=len(extra))
        frequencies = collections.Counter(group_by_ref[a] for a, b in z)
        lost = collections.Counter(group_by_ref[a] for a, b in missing)
        gain = collections.Counter(group_by_ref[a] for a, b in extra)
        for k, ids in pools.items():
            components = collections.Counter(leader(i) for i in ids)
            per_pool[k][method + "Zeros"] = frequencies[k]
            if method.startswith("final"):
                per_pool[k][method + "MissingSlotted"] = lost[k]
                per_pool[k][method + "AdditionalBeyondSlotted"] = gain[k]
            per_pool[k][method + "StructuralForms"] = len(components)
            per_pool[k][method + "ZeroComponentPairs"] = sum(
                n * (n - 1) // 2 for n in components.values()
            )
    csv_text = io.StringIO(newline="")
    writer = csv.DictWriter(csv_text, fieldnames=list(next(iter(per_pool.values()))))
    writer.writeheader()
    writer.writerows(per_pool.values())
    pool_data = csv_text.getvalue().encode()
    if require_report:
        need(
            (root / "pools.csv").read_bytes() == pool_data,
            "Published per-pool structural forms differ",
        )
    else:
        (root / "pools.csv").write_bytes(pool_data)

    stable = (
        not cost_changed
        and all(c["zeros"] == c["componentPairs"] == 19271 for c in counts.values())
        and all(
            c["missingSlotted"] == 0 and c["additionalZerosBeyondSlotted"] > 0
            for c in counts.values()
        )
    )
    s = dict(
        status="VERIFIED" if stable else "SCALAR_OR_COVERAGE_CHANGED",
        allPairs=132032,
        referencePools=len(pools),
        referenceNodes=len(refs),
        recordedPositiveInputs=len(positive),
        originalScalarDifferences=categories["originalArmDisagreements"],
        newScalarDifferences=categories["finalArmDisagreements"],
        crossVersionScoreChanges=dict(score_changes),
        observedChanges=cost_changed,
        zeroNativeSelections=len(zero),
        structuralZeros=counts["finalCertified"]["zeros"],
        structuralForms=counts["finalCertified"]["structuralForms"],
        components=counts,
        originalJarSha256=ORIGINAL_JAR,
        finalJarSha256=marker["jarSha256"],
        finalCommit=marker["commit"],
        markerSha256=sha(root / "final-started.json"),
        finalRunId=marker["uuid"],
        scalarPositiveSha256=sha(root / "positive-scores.tsv.gz"),
        sourceCatalogSha256=CATALOG,
        perPoolSha256=digest(pool_data),
        originalSlottedZeros=len(slotted),
        originalSlottedDistancesSha256=sha(slotted_path),
        zeroNativeSha256=z_files["zero.jsonl.gz"],
    )
    if require_report:
        need(
            s == read(root / "summary.json"), "Portable pool recount differs from recorded summary"
        )
    return s


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("archive", type=Path)
    p.add_argument("--repo", type=Path, required=True)
    a = p.parse_args()
    out = verify(a.archive, a.repo)
    print(json.dumps(out, sort_keys=True))
    raise SystemExit(0 if out["status"] == "VERIFIED" else 2)
