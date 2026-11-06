"""Deterministic bounded corpus subset, with every eligibility decision retained."""

import argparse
import collections
import hashlib
import json
from pathlib import Path
import subprocess

from .corpus_protocol import split_for
from .experiment import ROOT, sha, write_json, load_tasks
from .worker import JavaWorker

PROBLEMS = ("classroom_fol", "graphs", "socialMedia", "coursesNew", "cv_v1", "trash_fol")


def prepare(args):
    if args.output.exists():
        raise ValueError("Use a fresh corpus directory")
    args.output.mkdir(parents=True)
    (args.output / "sources").mkdir()
    (args.output / "logs").mkdir()
    candidates = [p for problem in PROBLEMS for p in (ROOT / "classified-data" / problem).rglob("*.als")
                  if p.parent.name.lower() in ("both", "over", "under", "overconstrained", "underconstrained")]
    candidates.sort(key=lambda p: hashlib.sha256(("corpus-v1:" + str(p.relative_to(ROOT))).encode()).digest())
    quotas = dict(zip(("train", "validation", "evaluation"), (args.train, args.validation, args.evaluation)))
    accepted, groups, seen = collections.Counter(), collections.Counter(), set()
    tasks, ledger = [], []
    write_json(args.output / "selection-policy.json", {"schemaVersion": 1, "problems": PROBLEMS,
               "quotas": quotas, "perQuestion": args.per_question, "maxAttempts": args.max_attempts,
               "ordering": "SHA256(corpus-v1:repository-relative-path)", "scope": 3,
               "selectionUsesRepairSuccess": False})
    for source in candidates:
        if all(accepted[s] >= n for s, n in quotas.items()) or len(ledger) >= args.max_attempts:
            break
        problem, status = source.parts[-3:-1]
        preferred = source.stem.rsplit("_", 1)[-1]
        group = problem + ":" + preferred.lower()
        split = split_for(group)
        if groups[group] >= args.per_question or accepted[split] >= quotas[split]:
            continue
        row = {"source": str(source.relative_to(ROOT)), "group": group, "split": split,
               "sourceHash": sha(source), "status": "EXCLUDED"}
        identifier = hashlib.sha256(row["source"].encode()).hexdigest()[:20]
        derived = args.output / "sources" / (identifier + ".als")
        try:
            result = subprocess.run(["java", "-Xmx1g", "-cp", str(args.classes) + ":" + str(ROOT / "lib/*"),
                                     "is.fivefivefive.CanDis.RepairCorpusSource", str(source), str(derived), preferred],
                                    cwd=ROOT, capture_output=True, text=True, timeout=30)
            (args.output / "logs" / (identifier + "-source.log")).write_text(result.stdout + result.stderr)
            if result.returncode:
                raise ValueError("SOURCE: " + result.stderr[-1500:])
            metadata = json.loads(result.stdout)
            if metadata["target"].lower() != preferred.lower() or metadata["originalHash"] != row["sourceHash"]:
                raise ValueError("Source/predicate identity mismatch")
            identity = (group, metadata["studentAstHash"], metadata["oracleAstHash"])
            if identity in seen:
                raise ValueError("DUPLICATE_AST_PAIR_IN_QUESTION")
            with JavaWorker(ROOT, args.classes, args.output / "logs" / (identifier + "-worker.log"),
                            timeout=20, heap="1g") as worker:
                loaded = worker.request("load", path=str(derived), target=metadata["target"],
                                        oracle=metadata["oracle"], command=metadata["command"],
                                        horizon=4, capacity=100, seedsPerClass=2)
                state = worker.request("reset")
                if state["terminal"]:
                    raise ValueError("INITIAL_" + state["status"])
                if not state["observation"]["actions"]:
                    raise ValueError("EMPTY_MENU")
            seen.add(identity)
            row.update(status="ACCEPTED", metadata=metadata, profile=loaded["profile"],
                       menuSize=len(state["observation"]["actions"]), nodes=len(state["observation"]["nodes"]))
            tasks.append({"id": identifier, "group": group, "split": split,
                          "path": "sources/" + derived.name, "target": metadata["target"],
                          "oracle": metadata["oracle"], "command": metadata["command"],
                          "corpusSource": row["source"], "corpusHash": row["sourceHash"],
                          "sourceHash": metadata["derivedHash"], "classification": status})
            accepted[split] += 1
            groups[group] += 1
        except Exception as failure:
            row["error"] = type(failure).__name__ + ": " + str(failure)
        ledger.append(row)
        write_json(args.output / "preflight.json", ledger)
        print(f"Preflight {len(ledger)}: {dict(accepted)}; {row['status']} {row['source']}", flush=True)
    write_json(args.output / "tasks.json", {"schemaVersion": 1, "tasks": tasks})
    load_tasks(args.output / "tasks.json")
    report = {"status": "COMPLETE" if all(accepted[s] == n for s, n in quotas.items()) else "INSUFFICIENT",
              "accepted": dict(accepted), "questionGroups": dict(groups), "attempts": len(ledger),
              "exclusions": sum(r["status"] == "EXCLUDED" for r in ledger),
              "manifestHash": sha(args.output / "tasks.json"), "sourcesUnchanged": all(
                  sha(ROOT / r["source"]) == r["sourceHash"] for r in ledger)}
    write_json(args.output / "summary.json", report)
    if report["status"] != "COMPLETE" or not report["sourcesUnchanged"]:
        raise RuntimeError("Incomplete corpus preparation; inspect retained ledger")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--classes", required=True, type=Path)
    for flag, default in (("train", 64), ("validation", 16), ("evaluation", 24), ("per-question", 4), ("max-attempts", 600)):
        parser.add_argument("--" + flag, type=int, default=default)
    args = parser.parse_args()
    args.output = args.output.resolve()
    prepare(args)


if __name__ == "__main__":
    main()
