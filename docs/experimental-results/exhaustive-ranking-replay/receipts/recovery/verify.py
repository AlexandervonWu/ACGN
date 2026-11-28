"""Verify the outage audit offline, optionally binding it to the final archive or raw run."""
import argparse
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
PRODUCER = "f12eef8c25654879468d8a7d2f32e62990041ab70c661f4ba93fe6e4cb2ac8df"
ANCILLARY = "8fb7bfd1f6426f78eff3f3075350e966669cc683b055589da4e2337ae65bae87"

def require(ok, message):
    if not ok:
        raise ValueError(message)

def sha(path):
    state = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1048576), b""):
            state.update(block)
    return state.hexdigest()

def read(path):
    return json.loads(path.read_bytes())

def records(path):
    return [json.loads(line) for line in path.read_bytes().splitlines()]

def references(obj):
    if isinstance(obj, dict):
        if {"path", "sha256"} <= obj.keys():
            yield obj
        else:
            for value in obj.values():
                yield from references(value)
    if isinstance(obj, list):
        for value in obj:
            yield from references(value)

def rehash_raw(run, seals, prefixes, identity):
    require(sha(run / "runner-identity.json") == identity, "Wrong raw run")
    results = run / "results"
    for sid, rows, receipt, raw in seals:
        require(sha(results / (sid + ".receipt.json")) == receipt and
                sha(results / (sid + ".jsonl")) == raw, "Changed closed shard " + sid)
    for row in prefixes:
        sid = row["shard"]
        length = row["checkedCompleteLines"]
        partial = results / "inflight" / (sid + ".jsonl")
        state = hashlib.sha256()
        try:
            with partial.open("rb") as stream:
                for _ in range(length):
                    line = stream.readline()
                    require(line.endswith(b"\n"), "Truncated prefix " + sid)
                    state.update(line)
        except FileNotFoundError:
            final = (results / (sid + ".jsonl")).read_bytes().splitlines(keepends=True)
            with (run / "plans" / (sid + ".tsv")).open() as stream:
                for _ in range(length):
                    fields = stream.readline().rstrip("\n").split("\t")
                    require(len(fields) == 9, "Missing original plan for " + sid)
                    state.update(final[int(fields[-1])])
        require(state.hexdigest() == row["prefixSha256"], "Recovered prefix no longer matches " + sid)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--final-bindings", type=Path, help="Final repaired compact shard-bindings.json")
    parser.add_argument("--raw-run", type=Path, help="Optional original measured output directory for direct raw rehash")
    args = parser.parse_args()
    listing = (HERE / "SHA256SUMS").read_text().splitlines()
    inventory = {entry.split("  ", 1)[1]: entry.split("  ", 1)[0] for entry in listing}
    paths = {f.relative_to(HERE).as_posix(): f for f in HERE.rglob("*")
             if f.is_file() and f != HERE / "SHA256SUMS"}
    require(len(inventory) == len(listing) and paths.keys() == inventory.keys() and
            all(sha(f) == inventory[name] for name, f in paths.items()), "Recovery package inventory differs")
    p = HERE / "producer"
    a = HERE / "ancillary"
    require(sha(p / "receipt.json") == PRODUCER and sha(a / "receipt.json") == ANCILLARY, "Changed recovery record")
    report = read(p / "receipt.json")
    ancillary = read(a / "receipt.json")
    require(report["status"] == "VERIFIED_PRODUCER_RECOVERY", "Unverified recovery")
    for key, path in (("auditSourceSha256", "audit_producer.py"), ("sealsSha256", "verified-seals.jsonl"),
                      ("recoveredPrefixesSha256", "verified-recovered-prefixes.json")):
        require(sha(p / path) == report[key], "Changed audit evidence " + path)
    seals = records(p / "verified-seals.jsonl")
    pre_ids = {r[0] for r in seals}
    prefixes = read(p / "verified-recovered-prefixes.json")
    recovered = {r["shard"]: r for r in prefixes}
    require(len(pre_ids) == len(seals) == report["sealedPrebootShards"] == 860 and
            sum(r[1] for r in seals) == report["sealedPrebootRows"] == 1512232, "Wrong preboot seals")
    require(len(recovered) == len(prefixes) == report["affectedInflightShards"] == 29 and
            not (pre_ids & recovered.keys()) and all(r["checkedCompleteLines"] >= r["before"] for r in prefixes) and
            sum(r["checkedCompleteLines"] for r in prefixes) == report["recoveredInflightCheckedCompleteLines"] == 34645,
            "Wrong recovered prefixes")
    aliases = read(HERE / "ancillary-paths.json")
    for ref in references(ancillary):
        path = (HERE / aliases[ref["path"]]).resolve()
        require(path.is_relative_to(HERE) and sha(path) == ref["sha256"], "Unbound ancillary file " + ref["path"])
    require(ancillary["candidateUuid"] == report["run"] and ancillary["candidateJarSha256"] == report["jarSha256"]
            and ancillary["candidateIdentitySha256"] == report["runnerIdentitySha256"]
            and ancillary["bootId"] == report["bootId"], "Different measured run")
    damage = read(a / "damage.json")
    rebuilt = read(a / "shard-0506.revalidated.json")
    producer = read(p / "shard-0506.receipt.json")
    require((a / "shard-0506.derived.torn.json").stat().st_size == damage["damagedBytes"] == 0 and
            damage["producerReceiptSha256"] == sha(p / "shard-0506.receipt.json") == rebuilt["receiptSha256"] and
            damage["rawOutputSha256"] == rebuilt["outputSha256"] == producer["outputSha256"] and
            rebuilt["rows"] == ancillary["allReconstructedRows"] == producer["rows"] == 1914 and
            producer["statusCounts"] == rebuilt["status"] == {"MATCHED": 1914} and
            ["shard-0506", 1914, rebuilt["receiptSha256"], rebuilt["outputSha256"]] in seals, "Bad auxiliary reconstruction")
    require(sha(p / "last-before-boot.json") == "df09dafb0bfd9006ec956a3dddb6b16e5f3322b391e92dc097b9343102374e58" and
            sha(p / "first-after-boot.jsonl") == "81f3441c7673e405efec4de67b0554dc305b792332bd7db5bc48005f086527f2", "Changed telemetry")
    before = read(p / "last-before-boot.json")
    after = records(p / "first-after-boot.jsonl")
    require(before["at"] == report["lastPrebootTelemetryTime"] and
            {r["shard"]: r["rows"] for r in before["running"]} == {k:v["before"] for k,v in recovered.items()}
            and before["attemptedRows"] == report["lastPrebootReportedRows"]
            and after[0]["attemptedRows"] == report["sealedPrebootRows"]
            and all(r["candidateRunId"] == report["run"] and r["completedShards"] == len(seals) for r in [before, *after])
            and all(dt1 < dt2 for dt1, dt2 in zip([before["at"], report["bootTime"], *[r["at"] for r in after[:-1]]],
                                                  [report["bootTime"], *[r["at"] for r in after]])), "Wrong recovery timeline")
    if args.final_bindings:
        final = {r["shard"]: r for r in read(args.final_bindings)}
        require(len(final) == 1059, "Incomplete final shard archive")
        for sid,rows,receipt,raw in seals:
            f = final[sid]
            require((f["rows"],f["receiptSha256"],f["resultSha256"]) == (rows,receipt,raw), "Final archive changed seal " + sid)
    if args.raw_run:
        rehash_raw(args.raw_run, seals, prefixes, report["runnerIdentitySha256"])
    print(json.dumps(dict(status="VERIFIED", sealedShards=len(seals), sealedRows=report["sealedPrebootRows"],
                          recoveredPrefixes=len(prefixes), recoveredRows=report["recoveredInflightCheckedCompleteLines"],
                          rebuiltShard="shard-0506", rebuiltRows=1914, verifiedFinalArchive=bool(args.final_bindings),
                          rehashedRaw=bool(args.raw_run)), sort_keys=True))

if __name__ == "__main__":
    main()
