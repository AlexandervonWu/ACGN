"""Matched, serial, multi-seed encoder comparison; never select an evaluation winner."""

import json
from pathlib import Path
import subprocess
import sys
import time
from .encoders import ENCODERS
from .experiment import ROOT, argument_parser, sha, write_json


OPTIONS = ("manifest", "classes", "device", "episodes", "eval_episodes", "eval_split", "horizon", "capacity",
           "seeds_per_class", "hidden", "layers", "heads", "lr", "timeout", "heap", "cuda_memory_gib")


def require_matched_settings(args, config):
    for name in OPTIONS:
        value = getattr(args, name)
        expected = str(value) if isinstance(value, Path) else value
        if name not in config or config[name] != expected:
            raise ValueError(f"Comparison setting mismatch for {name}: expected {expected!r}, got {config.get(name)!r}")


def compare(args):
    for name in ("manifest", "classes", "output"):
        setattr(args, name, getattr(args, name).resolve())
    if args.output.exists():
        raise ValueError("Use a fresh comparison output directory")
    if len(set(args.encoders)) != len(args.encoders) or len(set(args.seeds)) != len(args.seeds):
        raise ValueError("Duplicate encoder or seed would bias the comparison")
    args.output.mkdir(parents=True)
    rows, failures = [], []
    reference_inputs, reference_classes = None, None
    random_by_seed = {}
    started = time.monotonic()
    for encoder in args.encoders:
        for seed in args.seeds:
            name = f"{encoder}-seed-{seed}"
            output = args.output / name
            command = [sys.executable, "-m", "acgn_repair.experiment", "--output", str(output),
                       "--encoder", encoder, "--seed", str(seed)]
            for option in OPTIONS:
                command += ["--" + option.replace("_", "-"), str(getattr(args, option))]
            print(f"Encoder comparison {len(rows) + 1}/{len(args.encoders) * len(args.seeds)}: {name}", flush=True)
            with (args.output / (name + ".log")).open("w", encoding="utf-8") as log:
                result = subprocess.run(command, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL)
            row = {"encoder": encoder, "seed": seed, "directory": name, "exitCode": result.returncode}
            try:
                summary = json.loads((output / "summary.json").read_text())
                manifest = json.loads((output / "run-manifest.json").read_text())
                row["summary"] = summary
                row["manifestHash"] = sha(output / "run-manifest.json")
                if result.returncode or not summary["inputsUnchanged"]:
                    raise ValueError("Child run incomplete or inputs changed")
                require_matched_settings(args, manifest["config"])
                inputs = (manifest["inputManifestHash"], manifest["tasks"], manifest["codeAndDependencyHashes"])
                if reference_inputs is None:
                    reference_inputs, reference_classes = inputs, manifest["compiledClasses"]
                elif inputs != reference_inputs or manifest["compiledClasses"] != reference_classes:
                    raise ValueError("Input/class mismatch across encoder arms")
                episodes = json.loads((output / "episodes.json").read_text())
                random = [e for e in episodes if e["mode"] == "random"]
                if seed in random_by_seed and random != random_by_seed[seed]:
                    raise ValueError("Random baseline differs across encoders at a matched seed")
                random_by_seed[seed] = random
                row["status"] = "COMPLETE"
            except (ValueError, KeyError, OSError) as failure:
                row["status"] = "FAILED"
                row["error"] = str(failure)
                failures.append(name + ": " + str(failure))
            rows.append(row)
            write_json(args.output / "runs.json", rows)
    aggregate = []
    for encoder in args.encoders:
        selected = [r for r in rows if r["encoder"] == encoder]
        completed = [r["summary"] for r in selected if r["status"] == "COMPLETE"]
        record = {"encoder": encoder, "requestedSeeds": args.seeds, "completedRuns": len(completed),
                  "failedRuns": len(selected) - len(completed)}
        # Incomplete arms retain their failures, not a selectively averaged success rate.
        if len(completed) == len(args.seeds):
            record["groups"] = {}
            for mode in ("train", "random", "learned"):
                counts = {key: sum(s["groups"][mode][key] for s in completed)
                          for key in ("episodes", "solved", "aborted", "initialSolved", "observedSolverCalls")}
                counts["successRate"] = counts["solved"] / counts["episodes"]
                counts["perSeedSuccessRate"] = [s["groups"][mode]["solved"] / s["groups"][mode]["episodes"] for s in completed]
                for key in ("meanSteps", "meanEdits", "meanReturn"):
                    counts[key] = sum(s["groups"][mode][key] * s["groups"][mode]["episodes"] for s in completed) / counts["episodes"]
                record["groups"][mode] = counts
            record["parameterCount"] = completed[0]["parameterCount"]
            for key in ("elapsedSeconds", "modelForwardSeconds", "modelUpdateSeconds", "observedSolverCalls"):
                record[key] = sum(s[key] for s in completed)
            peaks = [s["peakCudaAllocatedBytes"] for s in completed if s["peakCudaAllocatedBytes"] is not None]
            record["peakCudaAllocatedBytes"] = max(peaks) if peaks else None
            reserved = [s["peakCudaReservedBytes"] for s in completed if s["peakCudaReservedBytes"] is not None]
            record["peakCudaReservedBytes"] = max(reserved) if reserved else None
            record["updates"] = sum(s["updates"] for s in completed)
        aggregate.append(record)
    report = {"schemaVersion": 1, "status": "COMPLETE" if not failures else "FAILED",
              "scope": "Bounded encoder experiment; not whole-application proof or a generalization benchmark",
              "matchedWidthNotMatchedParameters": True, "runs": rows, "aggregate": aggregate,
              "elapsedSeconds": time.monotonic() - started, "failures": failures}
    write_json(args.output / "comparison.json", report)
    lines = ["# RL Graph Encoder Comparison", "", report["scope"], "", "Status: " + report["status"],
             "", "Matched settings: " + ", ".join(f"{key}={getattr(args, key)}" for key in OPTIONS),
             "", "Seeds: " + ", ".join(map(str, args.seeds)), "",
             "Width/depth are matched; parameter counts are not. Times sum all seeds; peak memory is the maximum per process."]
    for record in aggregate:
        lines += ["", "## " + record["encoder"].upper(),
                  f"Completed runs: {record['completedRuns']}; failed runs: {record['failedRuns']}."]
        if "groups" in record:
            for mode, counts in record["groups"].items():
                lines.append(f"- {mode}: {counts['solved']}/{counts['episodes']} solved within profile; "
                             f"{counts['aborted']} aborted; mean steps {counts['meanSteps']:.3f}; "
                             f"mean edits {counts['meanEdits']:.3f}; mean return {counts['meanReturn']:.3f}; "
                             f"per-seed rates {counts['perSeedSuccessRate']}.")
            lines += [f"- Parameters: {record['parameterCount']}; updates: {record['updates']}.",
                      f"- Wall: {record['elapsedSeconds']:.3f}s; model forward: {record['modelForwardSeconds']:.3f}s; "
                      f"model update: {record['modelUpdateSeconds']:.3f}s.",
                      f"- Observed solver calls: {record['observedSolverCalls']}; "
                      f"peak CUDA allocated bytes: {record['peakCudaAllocatedBytes']}; "
                      f"peak CUDA reserved bytes: {record['peakCudaReservedBytes']}."]
    lines += ["", "No winner is selected from this held-out pilot. Small samples are not evidence of superiority.",
              "Whole-application refinement remains open. Numerical kernels are external TCB; semantic authority is unchanged."]
    lines += ["- " + failure for failure in failures]
    (args.output / "summary.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    return 1 if failures else 0


def main():
    parser = argument_parser(__doc__, comparison=True)
    parser.add_argument("--encoders", choices=ENCODERS, nargs="+", default=list(ENCODERS))
    parser.add_argument("--seeds", type=int, nargs="+", default=[42, 43, 44])
    sys.exit(compare(parser.parse_args()))


if __name__ == "__main__":
    main()
