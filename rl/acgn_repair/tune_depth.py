"""Bounded validation-only architecture selection followed by fresh-seed testing."""

import argparse
import json
import math
from pathlib import Path
import re
import subprocess
import sys
import time

from .encoders import ENCODERS
from .experiment import ROOT, load_tasks, sha, write_json
from .capacity import GIB, expected_parameters, fits_budget, training_estimate
from .transformer import verify_graph_trace


PROOF = ROOT / "docs/rl-repair/formal/TuningProtocol.lean"
RESOURCE_PROOF = ROOT / "docs/rl-repair/formal/ResourceBudget.lean"
SHARED = ("manifest", "classes", "device", "episodes", "eval_episodes", "horizon",
          "capacity", "seeds_per_class", "timeout", "heap", "cuda_memory_gib", "task_chunk")
HYPERPARAMETERS = ("hidden", "layers", "heads", "lr")


def load_plan(path):
    plan = json.loads(Path(path).read_text())
    candidates = plan.get("configurations", [])
    if plan.get("schemaVersion") != 1 or not 1 <= len(candidates) <= 8:
        raise ValueError("Expected a bounded grid of 1..8 configurations")
    ids, settings = set(), set()
    for c in candidates:
        if set(c) != {"id", *HYPERPARAMETERS} or not re.fullmatch(r"[a-z0-9-]+", c["id"]):
            raise ValueError("Invalid configuration fields/id")
        key = tuple(c[k] for k in HYPERPARAMETERS)
        if c["id"] in ids or key in settings:
            raise ValueError("Duplicate configuration")
        if any(type(c[k]) is not int for k in ("hidden", "layers", "heads")):
            raise ValueError("Integer architecture dimensions required")
        if not (8 <= c["hidden"] <= 16384 and 1 <= c["layers"] <= 8 and 1 <= c["heads"] <= 16):
            raise ValueError("Architecture exceeds tuning bounds")
        if c["hidden"] % c["heads"] or not math.isfinite(c["lr"]) or not 0 < c["lr"] <= 0.01:
            raise ValueError("Invalid heads/learning rate")
        ids.add(c["id"])
        settings.add(key)
    return candidates


def validate_seeds(seeds, test_seeds):
    for values in (seeds, test_seeds):
        if not 1 <= len(values) <= 5 or len(set(values)) != len(values):
            raise ValueError("Use 1..5 unique seeds per stage")
        if any(type(s) is not int or not 0 <= s < 2**31 for s in values):
            raise ValueError("Invalid seed")
    if set(seeds) & set(test_seeds):
        raise ValueError("Final seeds must be fresh")


def select_index(scores):
    if not scores or any(type(s) is not int or s < 0 for s in scores):
        raise ValueError("Nonempty integer validation counts required")
    return max(range(len(scores)), key=lambda i: scores[i])


def lean_select(scores):
    expected = select_index(scores)
    actual = int(subprocess.check_output(["lean", "--run", str(PROOF), *map(str, scores)],
                                         cwd=ROOT, text=True, timeout=30).strip())
    if actual != expected:
        raise ValueError("Lean/Python selection disagreement")
    return actual


def smallest_best(scores, parameters):
    select_index(scores)
    if len(scores) != len(parameters) or any(type(p) is not int or p < 0 for p in parameters):
        raise ValueError("Matching nonnegative integer parameter counts required")
    return max(range(len(scores)), key=lambda i: (scores[i], -parameters[i]))


def lean_smallest_best(scores, parameters):
    expected = smallest_best(scores, parameters)
    actual = int(subprocess.check_output(["lean", "--run", str(RESOURCE_PROOF),
                                         *[f"{s}:{p}" for s, p in zip(scores, parameters)]],
                                        cwd=ROOT, text=True, timeout=30).strip())
    if actual != expected:
        raise ValueError("Lean/Python score-size selection disagreement")
    return actual


def validation_scores(rows, encoder, candidates, seeds, episodes):
    scores = []
    for c in candidates:
        selected = [r for r in rows if r["stage"] == "validation" and r["encoder"] == encoder
                    and r["configuration"] == c["id"]]
        if len(selected) != len(seeds) or {r["seed"] for r in selected} != set(seeds):
            raise ValueError("Incomplete or duplicate validation runs")
        for r in selected:
            g = r["summary"]["groups"]["learned"]
            if r["status"] != "COMPLETE" or g["episodes"] != episodes or g["aborted"] or g["initialSolved"]:
                raise ValueError("Invalid validation denominator/status")
        scores.append(sum(r["summary"]["groups"]["learned"]["solved"] for r in selected))
    return scores


def aggregate(rows):
    groups = {}
    for mode in ("train", "random", "learned"):
        summaries = [r["summary"]["groups"][mode] for r in rows]
        g = {k: sum(s[k] for s in summaries) for k in ("episodes", "solved", "aborted")}
        g["perSeedSolved"] = [s["solved"] for s in summaries]
        g["meanSteps"] = sum(s["meanSteps"] * s["episodes"] for s in summaries) / g["episodes"]
        groups[mode] = g
    return {"groups": groups, "parameterCount": rows[0]["summary"]["parameterCount"],
            "updates": sum(r["summary"]["updates"] for r in rows),
            "elapsedSeconds": sum(r["summary"]["elapsedSeconds"] for r in rows),
            "peakCudaAllocatedBytes": max(r["summary"]["peakCudaAllocatedBytes"] or 0 for r in rows),
            "peakCudaReservedBytes": max(r["summary"]["peakCudaReservedBytes"] or 0 for r in rows)}


def tune(args):
    for name in ("manifest", "plan", "classes", "output"):
        setattr(args, name, getattr(args, name).resolve())
    tasks, candidates = load_tasks(args.manifest), load_plan(args.plan)
    validate_seeds(args.seeds, args.test_seeds)
    if {t["split"] for t in tasks} != {"train", "validation", "evaluation"}:
        raise ValueError("Tuning requires three separate splits")
    if len(set(args.encoders)) != len(args.encoders):
        raise ValueError("Duplicate encoder")
    if not 0 <= getattr(args, "final_families", 0) <= len(args.encoders):
        raise ValueError("Final-family count exceeds candidate families")
    if args.output.exists():
        raise ValueError("Use a fresh tuning output directory")
    if not math.isfinite(args.cuda_memory_gib) or args.cuda_memory_gib < 0:
        raise ValueError("Invalid CUDA memory budget")
    args.output.mkdir(parents=True)
    started = time.monotonic()
    frozen = {str(args.plan): sha(args.plan), str(args.manifest): sha(args.manifest),
              str(PROOF): sha(PROOF), str(RESOURCE_PROOF): sha(RESOURCE_PROOF)}
    preflight = [{"encoder": e, "configuration": c["id"],
                  "parameterCount": expected_parameters(e, c["hidden"], c["layers"]),
                  "estimatedBytes": training_estimate(expected_parameters(e, c["hidden"], c["layers"])),
                  "withinBudget": not args.cuda_memory_gib or fits_budget(expected_parameters(e, c["hidden"], c["layers"]),
                                                                        GIB, int(args.cuda_memory_gib * GIB))}
                 for e in args.encoders for c in candidates]
    write_json(args.output / "preflight.json", preflight)
    if any(not row["withinBudget"] for row in preflight):
        raise ValueError("Grid exceeds memory planning budget; see preflight.json; no training launched")
    protocol = {"schemaVersion": 1, "configurations": candidates, "validationSeeds": args.seeds,
                "testSeeds": args.test_seeds, "encoders": args.encoders, "inputHashes": frozen,
                "selection": "Maximum validation solved count, then minimum parameters, then grid order; Lean checked",
                "config": {k: str(v) if isinstance(v, Path) else v for k, v in vars(args).items()}}
    write_json(args.output / "protocol.json", protocol)
    rows, random_records = [], {}
    reference_inputs = None
    selection_hash = None

    def run_child(stage, encoder, candidate, seed):
        nonlocal reference_inputs
        name = f"{stage}-{encoder}-{candidate['id']}-{seed}"
        output = args.output / name
        expected = {k: str(getattr(args, k)) if isinstance(getattr(args, k), Path) else getattr(args, k) for k in SHARED}
        expected.update({k: candidate[k] for k in HYPERPARAMETERS})
        expected.update(encoder=encoder, seed=seed, eval_split=stage, output=str(output))
        command = [sys.executable, "-m", "acgn_repair.experiment"]
        for key, value in expected.items():
            command += ["--" + key.replace("_", "-"), str(value)]
        print(f"Tuning run {len(rows) + 1}: {name}", flush=True)
        row = {"stage": stage, "encoder": encoder, "configuration": candidate["id"], "seed": seed,
               "directory": name, "status": "FAILED"}
        try:
            with (args.output / (name + ".log")).open("w") as log:
                result = subprocess.run(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT,
                                        stdin=subprocess.DEVNULL)
            row["exitCode"] = result.returncode
            if result.returncode:
                raise ValueError("Child run failed; see retained log")
            summary = json.loads((output / "summary.json").read_text())
            manifest = json.loads((output / "run-manifest.json").read_text())
            episodes = json.loads((output / "episodes.json").read_text())
            if any(manifest["config"][k] != v for k, v in expected.items()):
                raise ValueError("Child configuration mismatch")
            inputs = [manifest[k] for k in ("inputManifestHash", "tasks", "codeAndDependencyHashes", "compiledClasses")]
            if reference_inputs is None:
                reference_inputs = inputs
            if inputs != reference_inputs or not summary["inputsUnchanged"]:
                raise ValueError("Input/class drift across candidates")
            if any(sha(path) != value for path, value in frozen.items()):
                raise ValueError("Tuning input mutation")
            if selection_hash is not None and sha(args.output / "selection.json") != selection_hash:
                raise ValueError("Frozen selection changed")
            training_count = args.episodes * sum(t["split"] == "train" for t in tasks)
            eval_count = args.eval_episodes * sum(t["split"] == stage for t in tasks)
            if summary["updates"] != training_count or len(episodes) != training_count + 2 * eval_count:
                raise ValueError("Unmatched training/evaluation budget")
            for mode, g in summary["groups"].items():
                if g["episodes"] != (training_count if mode == "train" else eval_count) or g["aborted"] or g["initialSolved"]:
                    raise ValueError("Censored or initially solved task")
            for episode in episodes:
                split = "train" if episode["mode"] == "train" else stage
                if episode["task"] not in {t["id"] for t in tasks if t["split"] == split}:
                    raise ValueError("Wrong split executed")
                if episode["mode"] == "train":
                    if episode.get("update", {}).get("proofContract") != manifest["applicationGate"]["contractHash"]:
                        raise ValueError("Training admission missing")
                elif "update" in episode:
                    raise ValueError("Evaluation modified policy")
            if encoder == "egraph_transformer":
                traces = [json.loads(line) for line in (output / "transitions.jsonl").read_text().splitlines()]
                model_steps = verify_graph_trace(traces, summary["architecture"])
                if (model_steps != summary["graphAdmissions"]
                        or model_steps != sum(e["steps"] for e in episodes if e["mode"] != "random")
                        or not 0 < summary["graphGateExecutions"] <= summary["graphAdmissions"]):
                    raise ValueError("Transformer structural admissions missing")
            random = [e for e in episodes if e["mode"] == "random"]
            key = (stage, seed)
            if key in random_records and random_records[key] != random:
                raise ValueError("Random controls differ across matched runs")
            random_records[key] = random
            row.update(status="COMPLETE", summary=summary, manifestHash=sha(output / "run-manifest.json"))
        except Exception as error:
            row["error"] = repr(error)
            raise
        finally:
            rows.append(row)
            write_json(args.output / "runs.json", rows)
        return row

    report = {"schemaVersion": 1, "status": "FAILED", "protocol": protocol}
    try:
        selections = {}
        for encoder in args.encoders:
            for candidate in candidates:
                for seed in args.seeds:
                    run_child("validation", encoder, candidate, seed)
            scores = validation_scores(rows, encoder, candidates, args.seeds,
                                       args.eval_episodes * sum(t["split"] == "validation" for t in tasks))
            parameters = [expected_parameters(encoder, c["hidden"], c["layers"]) for c in candidates]
            index = lean_smallest_best(scores, parameters)
            selections[encoder] = {"configuration": candidates[index]["id"], "validationScores": scores,
                                   "selectedScore": scores[index], "parameterCount": parameters[index]}
        overall = args.encoders[lean_smallest_best([selections[e]["selectedScore"] for e in args.encoders],
                                                 [selections[e]["parameterCount"] for e in args.encoders])]
        best = {"encoder": overall, **selections[overall]}
        remaining, finalists = list(args.encoders), []
        for _ in range(getattr(args, "final_families", 0) or len(remaining)):
            index = lean_smallest_best([selections[e]["selectedScore"] for e in remaining],
                                      [selections[e]["parameterCount"] for e in remaining])
            finalists.append(remaining.pop(index))
        selection = {"selections": selections, "bestValidation": best, "protocolHash": sha(args.output / "protocol.json"),
                     "finalFamilies": finalists,
                     "validationRunsHash": sha(args.output / "runs.json"),
                     "validationRuns": [{k: r[k] for k in ("directory", "manifestHash")} for r in rows],
                     "proofHash": sha(RESOURCE_PROOF)}
        write_json(args.output / "validation-runs.json", rows)
        write_json(args.output / "selection.json", selection)
        selection_hash = sha(args.output / "selection.json")
        final = []
        for encoder in finalists:
            chosen = next(c for c in candidates if c["id"] == selections[encoder]["configuration"])
            for candidate in candidates:
                if candidate["id"] not in {candidates[0]["id"], chosen["id"]}:
                    continue
                trials = [run_child("evaluation", encoder, candidate, seed) for seed in args.test_seeds]
                final.append({"encoder": encoder, "configuration": candidate,
                              "roles": [role for role, c in (("baseline", candidates[0]), ("selected", chosen)) if c == candidate],
                              **aggregate(trials)})
        report.update(status="COMPLETE", selections=selections, bestValidation=best, final=final, selectionHash=selection_hash)
    except Exception as error:
        report["error"] = repr(error)
    report.update(runs=rows, elapsedSeconds=time.monotonic() - started,
                  scope="Bounded related-fixture tuning only; no corpus generalization claim; application refinement remains open")
    write_json(args.output / "tuning.json", report)
    lines = ["# RL Depth and Hyperparameter Sweep", "", "Status: " + report["status"], "", report["scope"], "",
             "Validation seeds: " + str(args.seeds) + "; fresh test seeds: " + str(args.test_seeds) + ".",
             "Selection maximizes validation solved counts, then minimizes parameter count; remaining ties use grid order. Test results do not select configurations.",
             "Settings are recorded in the protocol; this is not a parameter-matched comparison.", "",
             "## Validation", "", "Configuration order: " + ", ".join(c["id"] for c in candidates)]
    for encoder, s in report.get("selections", {}).items():
        denominator = args.eval_episodes * len(args.seeds) * sum(t["split"] == "validation" for t in tasks)
        lines.append(f"- {encoder}: solved counts {s['validationScores']} / {denominator}; selected {s['configuration']}.")
    lines += ["", "## Fresh-Seed Test"]
    if "bestValidation" in report:
        best = report["bestValidation"]
        lines += [f"Overall validation selection: {best['encoder']} {best['configuration']} "
                  f"({best['parameterCount']} parameters).", ""]
    for r in report.get("final", []):
        g, random = r["groups"]["learned"], r["groups"]["random"]
        lines += [f"- {r['encoder']} {r['configuration']['id']} ({', '.join(r['roles'])}): "
                  f"{g['solved']}/{g['episodes']} solved; per seed {g['perSeedSolved']}; "
                  f"random {random['solved']}/{random['episodes']}; parameters {r['parameterCount']}; "
                  f"wall {r['elapsedSeconds']:.2f}s; peak CUDA allocated {r['peakCudaAllocatedBytes']} bytes; "
                  f"peak CUDA reserved {r['peakCudaReservedBytes']} bytes."]
    lines += ["", "Repeated random controls are the same evidence, not extra independent trials. "
              "Episodes share evolving instance banks. No global model default has been changed.",
              f"Unique child runs: {len(rows)}; optimizer updates: {sum(r.get('summary', {}).get('updates', 0) for r in rows)}; "
              f"total elapsed seconds: {report['elapsedSeconds']:.2f}."]
    if "error" in report:
        lines += ["", "Failure: " + report["error"]]
    (args.output / "summary.md").write_text("\n".join(lines) + "\n")
    write_json(args.output / "output-hashes.json", {str(p.relative_to(args.output)): sha(p)
               for p in sorted(args.output.rglob("*")) if p.is_file() and p.name != "output-hashes.json"})
    return 0 if report["status"] == "COMPLETE" else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("manifest", "plan", "classes", "output"):
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--encoders", nargs="+", choices=ENCODERS, default=list(ENCODERS))
    parser.add_argument("--final-families", type=int, default=0, help="0 tests all; otherwise test only the top validation families")
    parser.add_argument("--seeds", nargs="+", type=int, default=[42, 43])
    parser.add_argument("--test-seeds", nargs="+", type=int, default=[101, 102, 103])
    parser.add_argument("--device", choices=("cuda", "cpu"), default="cuda")
    for name, default in (("episodes", 12), ("eval-episodes", 3), ("horizon", 4), ("capacity", 100), ("seeds-per-class", 2), ("task-chunk", 0)):
        parser.add_argument("--" + name, type=int, default=default)
    parser.add_argument("--timeout", type=float, default=30)
    parser.add_argument("--heap", default="2g")
    parser.add_argument("--cuda-memory-gib", type=float, default=0)
    sys.exit(tune(parser.parse_args()))


if __name__ == "__main__":
    main()
