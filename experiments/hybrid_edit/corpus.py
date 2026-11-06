"""Deterministic scope-first export; no repair-success-based sample selection."""
import argparse
import collections
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

from .corpus_codec import encode
from .scope import ScopeExclusion

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "rl"))
from acgn_repair.worker import JavaWorker
from acgn_repair.corpus_protocol import split_for


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, value):
    Path(path).write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def process(source, output, classes):
    relative = source.relative_to(ROOT).as_posix()
    key = hashlib.sha256(relative.encode()).hexdigest()[:20]
    preferred = source.stem.rsplit("_", 1)[-1]
    group = source.parts[-3] + ":" + preferred.lower()
    row = {"id": key, "source": relative, "sourceHash": digest(source), "group": group,
           "split": split_for(group), "status": "EXCLUDED"}
    derived = output / "sources" / (key + ".als")
    try:
        result = subprocess.run(["java", "-Xmx768m", "-cp", str(classes) + ":lib/*",
            "is.fivefivefive.CanDis.RepairCorpusSource", str(source), str(derived), preferred],
            cwd=ROOT, capture_output=True, text=True, timeout=20)
        (output / "logs" / (key + "-source.stdout")).write_text(result.stdout, encoding="utf-8")
        (output / "logs" / (key + "-source.stderr")).write_text(result.stderr, encoding="utf-8")
        if result.returncode:
            raise ScopeExclusion("SOURCE:" + result.stderr[-250:])
        metadata = json.loads(result.stdout)
        if metadata["originalHash"] != row["sourceHash"] or metadata["target"].lower() != preferred.lower():
            raise RuntimeError("Source/predicate identity mismatch")
        row["metadata"] = metadata
        command = ["java", "-Xmx768m", "-cp", str(classes) + ":lib/*", "is.fivefivefive.ACGN.repair.HybridCorpusWorker"]
        with JavaWorker(ROOT, classes, output / "logs" / (key + ".log"), timeout=60, command=command) as worker:
            raw = worker.request("load", path=str(derived), target=metadata["target"],
                                 oracle=metadata["oracle"], command=metadata["command"])
            packet = encode(raw)
            labels = worker.request("labels", indices=[a["index"] for a in packet["actions"]])
        if digest(source) != row["sourceHash"]:
            raise RuntimeError("Source changed during export")
        valid = [o for o in labels["outcomes"] if o["valid"]]
        if not valid:
            raise ScopeExclusion("NO_VALID_TRANSITION")
        best = min(o["distance"] for o in valid)
        packet["optimal"] = [o["valid"] and o["distance"] == best for o in labels["outcomes"]]
        packet["outcomes"] = labels["outcomes"]
        packet["initialDistance"] = labels["initialDistance"]
        packet.update({k: row[k] for k in ("id", "source", "group", "split")})
        row.update(status="ACCEPTED", tokens=len(packet["tokens"]), actions=len(packet["actions"]),
                   packetHash=hashlib.sha256(json.dumps(packet, sort_keys=True).encode()).hexdigest())
        write(output / "records" / (key + ".json"), {"packet": packet, "export": raw, "provenance": row})
    except Exception as error:
        row["reason"] = type(error).__name__ + ": " + str(error)
        if not isinstance(error, ScopeExclusion) and "RepairTask$UnsupportedInput" not in str(error):
            row["status"] = "FAILED"
    return row


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--classes", type=Path, required=True)
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--max-attempts", type=int, default=4000)
    p.add_argument("--workers", type=int, default=8)
    p.add_argument("--per-question", type=int, default=160)
    args = p.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir()
    for name in ("sources", "logs", "records"):
        (args.output / name).mkdir()
    problems = ("graphs", "socialMedia", "coursesNew", "classroom_fol", "cv_v1", "trash_fol")
    candidates = [path for problem in problems for path in (ROOT / "classified-data" / problem).rglob("*.als")
                  if path.parent.name.lower() in ("both", "under", "over", "underconstrained", "overconstrained")]
    candidates.sort(key=lambda path: hashlib.sha256(("hybrid-v1:" + path.relative_to(ROOT).as_posix()).encode()).digest())
    counts = collections.Counter()
    selected = []
    for path in candidates:
        group = path.parts[-3] + ":" + path.stem.rsplit("_", 1)[-1].lower()
        if counts[group] < args.per_question:
            selected.append(path)
            counts[group] += 1
        if len(selected) == args.max_attempts:
            break
    write(args.output / "selection.json", {"problems": problems, "attempts": len(selected),
          "perQuestion": args.per_question, "workers": args.workers, "selectionUsesRepairSuccess": False,
          "sourceHashes": {str(path.relative_to(ROOT)): digest(path) for path in selected},
          "implementationHashes": {str(path.relative_to(ROOT)): digest(path) for path in [
              *ROOT.joinpath("src").rglob("*.java"),
              *ROOT.joinpath("experiments/hybrid_edit").glob("*.py"),
              *ROOT.joinpath("docs/canonical-edit-learning/formal").glob("*.lean"),
              ROOT / "rl/acgn_repair/worker.py", ROOT / "rl/acgn_repair/corpus_protocol.py"]}})
    ledger, seen = [], set()
    started = time.monotonic()
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        # Ordered batches bound retained futures and make dedup independent of completion order.
        for start in range(0, len(selected), args.workers):
            futures = [pool.submit(process, source, args.output, args.classes) for source in selected[start:start+args.workers]]
            for future in futures:
                row = future.result()
                if row["status"] == "ACCEPTED":
                    m = row["metadata"]
                    identity = row["group"], m["studentAstHash"], m["oracleAstHash"]
                    if identity in seen:
                        row.update(status="EXCLUDED", reason="DUPLICATE_AST_PAIR")
                    seen.add(identity)
                ledger.append(row)
            write(args.output / "ledger.json", ledger)
            accepted = collections.Counter(r["split"] for r in ledger if r["status"] == "ACCEPTED")
            print(json.dumps({"done": len(ledger), "total": len(selected), "accepted": accepted,
                              "seconds": time.monotonic()-started}), flush=True)
    write(args.output / "summary.json", {"attempted": len(ledger), "accepted": accepted,
          "exclusions": collections.Counter(r.get("reason", "").split(":")[0] for r in ledger if r["status"] != "ACCEPTED"),
          "seconds": time.monotonic()-started})


if __name__ == "__main__":
    main()
