"""Paired held-out repair rates with an explicit, predeclared stability criterion."""

import argparse
import collections
import json
from pathlib import Path

from .corpus_protocol import check_protocol, paired_cluster_interval, stable_counts
from .experiment import sha, write_json


def paired_outcomes(episodes, tasks, count):
    expected = {(t["id"], n) for t in tasks for n in range(count)}
    modes = {mode: {} for mode in ("random", "learned")}
    for e in episodes:
        if e["mode"] not in modes:
            continue
        key = (e["task"], e["episode"])
        if key not in expected or key in modes[e["mode"]]:
            raise ValueError("Duplicate/unexpected paired trial")
        if e["status"] not in ("SOLVED_WITHIN_PROFILE", "EXHAUSTED", "BANK_CHANGED"):
            raise ValueError("Censored or initially solved trial")
        modes[e["mode"]][key] = e
    if any(set(records) != expected for records in modes.values()):
        raise ValueError("Incomplete paired trials")
    groups = {t["id"]: t["group"] for t in tasks}
    differences = collections.defaultdict(list)
    for key in sorted(expected):
        left, right = modes["learned"][key], modes["random"][key]
        if key[1] == 0 and left["initialBank"] != right["initialBank"]:
            raise ValueError("Different initial evaluation banks")
        if left["group"] != groups[key[0]] or right["group"] != groups[key[0]]:
            raise ValueError("Question group mismatch")
        differences[groups[key[0]]].append(int(left["status"] == "SOLVED_WITHIN_PROFILE")
                                         - int(right["status"] == "SOLVED_WITHIN_PROFILE"))
    counts = {mode: sum(e["status"] == "SOLVED_WITHIN_PROFILE" for e in records.values())
              for mode, records in modes.items()}
    return {**counts, "budget": len(expected), "aborted": 0}, dict(differences)


def report(run, output):
    if output.exists():
        raise ValueError("Use a fresh report directory")
    tuning = json.loads((run / "tuning.json").read_text())
    if tuning["status"] != "COMPLETE" or sha(run / "selection.json") != tuning["selectionHash"]:
        raise ValueError("Incomplete or changed experiment")
    cfg = tuning["protocol"]["config"]
    if len(cfg["test_seeds"]) != 5 or len(set(cfg["test_seeds"])) != 5:
        raise ValueError("Five distinct fresh test seeds required")
    output.mkdir(parents=True)
    results = []
    for final in tuning["final"]:
        rows, differences = [], collections.defaultdict(list)
        trials = [r for r in tuning["runs"] if r["stage"] == "evaluation"
                  and r["encoder"] == final["encoder"] and r["configuration"] == final["configuration"]["id"]]
        if len(trials) != 5 or {r["seed"] for r in trials} != set(cfg["test_seeds"]):
            raise ValueError("Final seed mismatch")
        for trial in trials:
            folder = run / trial["directory"]
            manifest = json.loads((folder / "run-manifest.json").read_text())
            if sha(folder / "run-manifest.json") != trial["manifestHash"]:
                raise ValueError("Changed child manifest")
            for path, expected in manifest["outputHashes"].items():
                if sha(folder / path) != expected:
                    raise ValueError("Changed child output")
            tasks = [t for t in manifest["tasks"] if t["split"] == "evaluation"]
            episodes = json.loads((folder / "episodes.json").read_text())
            counts, paired = paired_outcomes(episodes, tasks, cfg["eval_episodes"])
            for group, values in paired.items():
                differences[group].extend(values)
            rows.append({"seed": trial["seed"], **counts})
        counts = [{k: v for k, v in r.items() if k != "seed"} for r in rows]
        receipt = check_protocol(1, 1, [(0, [0])], counts)
        interval = paired_cluster_interval(differences)
        results.append({"encoder": final["encoder"], "configuration": final["configuration"],
                        "seeds": rows, "interval": interval, "leanAdmission": receipt,
                        "stableOnThisSubset": stable_counts(counts) and interval["lower"] > 0,
                        "byQuestion": {g: {"pairedTrials": len(v), "netRepairs": sum(v)} for g, v in sorted(differences.items())}})
    value = {"status": "COMPLETE", "comparisonHash": sha(run / "tuning.json"), "results": results,
             "interpretation": "Exploratory group-held-out bounded corpus comparison, not a universal superiority proof"}
    write_json(output / "comparison.json", value)
    lines = ["# Corpus Repair Versus Random Walk", "", value["interpretation"], ""]
    for r in results:
        learned, random, budget = [sum(s[k] for s in r["seeds"]) for k in ("learned", "random", "budget")]
        lines.extend([f"## {r['encoder']}", "", f"Learned: {learned}/{budget}; random: {random}/{budget}.",
                      f"Per-seed learned: {[s['learned'] for s in r['seeds']]}; random: {[s['random'] for s in r['seeds']]}.",
                      f"Paired question-cluster bootstrap interval: [{r['interval']['lower']:.6f}, {r['interval']['upper']:.6f}].",
                      f"Predeclared stability criterion: {r['stableOnThisSubset']}.", ""])
    (output / "summary.md").write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    report(args.run, args.output)
