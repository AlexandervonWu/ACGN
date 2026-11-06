"""Bounded RL-2/3 pilot, with explicit held-out tasks and no oracle policy inputs."""

import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import random
import subprocess
import sys
import time
import torch
from .model import SCHEMA, StructuredPolicy, update_policy
from .worker import JavaWorker
from .proof_gate import ProofGate, contract_hash, step_record
from .encoders import ENCODERS, graph_contract_hash
from .capacity import GIB, ResourceLimitError, apply_cuda_budget, capacity_statistics, cuda_memory_snapshot
from .corpus_protocol import task_schedule, check_protocol


ROOT = Path(__file__).resolve().parents[2]


def sha(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def write_json(path, value):
    Path(path).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def load_tasks(path):
    path = Path(path).resolve()
    manifest = json.loads(path.read_text(encoding="utf-8"))
    if manifest.get("schemaVersion") != 1 or not manifest.get("tasks"):
        raise ValueError("Expected task manifest schemaVersion 1")
    groups, sources, ids = {}, {}, set()
    tasks = []
    for raw in manifest["tasks"]:
        task = dict(raw)
        if task["id"] in ids or task["split"] not in ("train", "validation", "evaluation") or not task["group"]:
            raise ValueError("Invalid task identity/split/group")
        ids.add(task["id"])
        task["path"] = str((path.parent / task["path"]).resolve())
        task["sourceHash"] = sha(task["path"])
        for seen, key in ((groups, task["group"]), (sources, task["sourceHash"])):
            if key in seen and seen[key] != task["split"]:
                raise ValueError("Cross-split leakage: repeated group or source")
            seen[key] = task["split"]
        tasks.append(task)
    if not {"train", "evaluation"}.issubset({t["split"] for t in tasks}):
        raise ValueError("Declare both train and held-out evaluation tasks")
    return tasks


def seed_all(seed):
    random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(seed)
    torch.set_num_threads(1)
    torch.use_deterministic_algorithms(True)
    torch.backends.cudnn.benchmark = False
    torch.backends.cuda.matmul.allow_tf32 = False


def save_checkpoint(path, policy, optimizer, config, updates):
    if updates != policy.generation:
        raise ValueError("Checkpoint update count differs from policy generation")
    torch.save({"schema": SCHEMA, "state": policy.state_dict(), "optimizer": optimizer.state_dict(),
                "architecture": policy.architecture(),
                "config": config, "updates": updates, "rng": torch.get_rng_state(),
                "cudaRng": torch.cuda.get_rng_state_all() if torch.cuda.is_available() else [],
                "pythonRng": random.getstate()}, path)


def load_policy(path, device):
    checkpoint = torch.load(path, map_location=device, weights_only=True)
    if checkpoint["schema"] != SCHEMA:
        raise ValueError("Incompatible policy checkpoint schema")
    architecture = checkpoint.get("architecture", {})
    if architecture.get("schema") != SCHEMA or architecture.get("contractHash") != contract_hash():
        raise ValueError("Incompatible or missing checkpoint proof contract")
    if architecture.get("architectureVersion") not in (2, 3) or architecture.get("graphContractHash") != graph_contract_hash():
        raise ValueError("Incompatible or missing graph encoder contract")
    policy = StructuredPolicy(architecture["hidden"], architecture["layers"],
                              architecture["encoder"], architecture["heads"]).to(device)
    if policy.architecture() != architecture:
        raise ValueError("Incompatible checkpoint architecture")
    policy.load_state_dict(checkpoint["state"], strict=True)
    policy.generation = checkpoint["updates"]
    policy.eval()
    return policy


def run(args):
    tasks = load_tasks(args.manifest)
    if not any(t["split"] == args.eval_split for t in tasks):
        raise ValueError("Requested evaluation split is empty")
    if not math.isfinite(args.lr) or args.lr <= 0:
        raise ValueError("Learning rate must be finite and positive")
    if args.output.exists():
        raise ValueError("Output directory already exists")
    if args.device == "cuda" and not torch.cuda.is_available():
        raise RuntimeError("CUDA requested; no CPU fallback")
    if args.episodes < 1 or args.eval_episodes < 1 or not 1 <= args.horizon <= 32:
        raise ValueError("Invalid episode/horizon bounds")
    if args.episodes > 10000 or args.eval_episodes > 10000:
        raise ValueError("Episode count exceeds pilot bound")
    if not 0 <= getattr(args, "task_chunk", 0) <= args.episodes:
        raise ValueError("Task chunk must lie within the episode budget")
    if not math.isfinite(args.cuda_memory_gib) or args.cuda_memory_gib < 0:
        raise ValueError("CUDA memory limit must be finite and nonnegative")
    args.output.mkdir(parents=True)
    seed_all(args.seed)
    if args.device == "cuda":
        torch.cuda.reset_peak_memory_stats()
    start_memory = cuda_memory_snapshot(args.device)
    memory_limit = apply_cuda_budget(args.device, args.encoder, args.hidden, args.layers,
                                    int(args.cuda_memory_gib * GIB)) if args.cuda_memory_gib else None
    policy = StructuredPolicy(args.hidden, args.layers, args.encoder, args.heads).to(args.device)
    capacity = capacity_statistics(policy)
    optimizer = torch.optim.Adam(policy.parameters(), lr=args.lr)
    config = {key: str(value) if isinstance(value, Path) else value for key, value in vars(args).items()}
    code_paths = sorted((ROOT / "rl/acgn_repair").glob("*.py")) + sorted((ROOT / "src").rglob("*.java"))
    code_paths += sorted((ROOT / "lib").glob("*.jar")) + sorted((ROOT / "docs/rl-repair/formal").glob("*.lean"))
    source_hashes = {str(p.relative_to(ROOT)): sha(p) for p in code_paths}
    initial_weights = {k: v.detach().clone() for k, v in policy.state_dict().items()}
    manifest = {"schemaVersion": 1, "kind": "bounded-learning-pilot-not-corpus-evaluation",
                "config": config, "tasks": tasks, "inputManifestHash": sha(args.manifest),
                "codeAndDependencyHashes": source_hashes, "compiledClasses": {
                    str(p.relative_to(args.classes)): sha(p) for p in sorted(args.classes.rglob("*.class"))},
                "python": sys.version, "torch": torch.__version__, "cuda": torch.version.cuda,
                "gpu": torch.cuda.get_device_name(0) if args.device == "cuda" else "CPU",
                "gitSha": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
                "dirty": bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT)),
                "startedUnix": time.time(), "gamma": 1, "certificateReplay": "NOT_REQUESTED",
                "architecture": policy.architecture(),
                **capacity, "cudaMemoryAtStart": start_memory, "cudaMemoryLimit": memory_limit,
                "memoryAccounting": "Allocated/reserved are PyTorch allocator bytes, not process/driver VRAM; nominal Adam bytes exclude activations, audit copies and workspaces"}
    write_json(args.output / "run-manifest.json", manifest)
    episodes, updates = [], []
    forward_seconds = update_seconds = 0.0
    solver_calls = 0

    def model_clock():
        if args.device == "cuda":
            torch.cuda.synchronize()
        return time.monotonic()

    started = time.monotonic()
    with ProofGate() as gate, (args.output / "transitions.jsonl").open("w", encoding="utf-8") as trace:
        manifest["applicationGate"] = {"contractHash": gate.contract, "lean": gate.lean_version}
        write_json(args.output / "run-manifest.json", manifest)
        for mode in ("train", "random", "learned"):
            selected = [t for t in tasks if t["split"] == ("train" if mode == "train" else args.eval_split)]
            count = args.episodes if mode == "train" else args.eval_episodes
            schedule = task_schedule(len(selected), count, getattr(args, "task_chunk", 0) if mode == "train" else 0,
                                     args.seed)
            if mode == "train" and getattr(args, "task_chunk", 0):
                write_json(args.output / "schedule-admission.json", check_protocol(len(selected), count, schedule))
            for task_index, numbers in schedule:
                task = selected[task_index]
                worker = None
                worker_calls = 0
                for number in numbers:
                    resource_failure = False
                    trajectory = []
                    checked_steps = []
                    generation = policy.generation
                    episode_calls_before = solver_calls
                    result = {"mode": mode, "task": task["id"], "group": task["group"], "episode": number,
                              "steps": 0, "return": 0, "status": "ABORTED"}
                    sampling_seed = args.seed + number + task_index * 100003
                    rng = random.Random(sampling_seed)
                    try:
                        if worker is None:
                            worker = JavaWorker(ROOT, args.classes, args.output / f"worker-{mode}-{task_index}-{number}.log",
                                                timeout=args.timeout, heap=args.heap)
                            loaded = worker.request("load", path=task["path"], target=task["target"],
                                                    oracle=task["oracle"], command=task["command"],
                                                    forbidden=task.get("forbidden", []), horizon=args.horizon,
                                                    capacity=args.capacity, seedsPerClass=args.seeds_per_class)
                            worker_calls = loaded["bank"]["solverCalls"]
                            solver_calls += worker_calls
                            trace.write(json.dumps({"load": loaded, "task": task["id"], "mode": mode}) + "\n")
                        state = worker.request("reset")
                        solver_calls += state["bank"]["solverCalls"] - worker_calls
                        worker_calls = state["bank"]["solverCalls"]
                        result["initialBank"] = state["bank"]
                        if state["terminal"]:
                            result["status"] = "INITIAL_" + state["status"]
                        else:
                            policy.train(mode == "train")
                            for step in range(args.horizon):
                                graph_admission = None
                                observation = state["observation"]
                                if mode == "random":
                                    action = rng.randrange(len(observation["actions"]))
                                    probability = 1.0 / len(observation["actions"])
                                else:
                                    if args.encoder == "egraph_transformer":
                                        graph_admission = gate.check_graph(observation, policy.architecture())
                                    model_started = model_clock()
                                    with torch.set_grad_enabled(mode == "train"):
                                        logits, value = policy(observation)
                                        distribution = torch.distributions.Categorical(logits=logits)
                                        chosen = distribution.sample() if mode == "train" else logits.argmax()
                                        action = int(chosen)
                                        probability = float(distribution.probs[action].detach())
                                        log_probability = distribution.log_prob(chosen)
                                        entropy = distribution.entropy()
                                    forward_seconds += model_clock() - model_started
                                reply = worker.request("step", token=state["token"], action=action)
                                solver_calls += reply["bank"]["solverCalls"] - worker_calls
                                worker_calls = reply["bank"]["solverCalls"]
                                if mode == "train":
                                    checked_steps.append(step_record(state, action, reply))
                                    trajectory.append((log_probability, value, entropy, reply["reward"]))
                                trace.write(json.dumps({"mode": mode, "task": task["id"], "episode": number,
                                                        "step": step, "observation": observation, "action": action,
                                                        "graphAdmission": graph_admission,
                                                        "samplingProbability": probability, "reply": reply}) + "\n")
                                trace.flush()
                                result["steps"] += 1
                                result["return"] += reply["reward"]
                                state = reply
                                if reply["terminal"]:
                                    break
                            if not state["terminal"]:
                                raise RuntimeError("Horizon ended without terminal feedback")
                            result["status"] = state["status"]
                            result["finalBank"] = state["bank"]
                            result["distanceFromOriginal"] = state.get("distanceFromOriginal")
                            result["candidateBody"] = state.get("candidateBody")
                            result["edits"] = state["edits"]
                            if mode == "train":
                                checked = gate.check(checked_steps, train=True, uncensored=True,
                                                     policy_before=generation, policy_after=policy.generation,
                                                     profile=loaded["profile"])
                                model_started = model_clock()
                                update = update_policy(policy, optimizer, trajectory, checked)
                                update_seconds += model_clock() - model_started
                                if update is not None:
                                    updates.append(update)
                                    result["update"] = update
                    except Exception as failure:
                        resource_failure = isinstance(failure, torch.cuda.OutOfMemoryError)
                        # Censored trajectories do not become semantic negative training examples.
                        result["status"] = "ABORTED"
                        result["error"] = type(failure).__name__ + ": " + str(failure)
                        if worker is not None:
                            worker.close()
                            worker = None
                    result["observedSolverCalls"] = solver_calls - episode_calls_before
                    episodes.append(result)
                    write_json(args.output / "episodes.json", episodes)
                    print(f"{mode} {task['id']} {number + 1}/{count}: {result['status']}", flush=True)
                    if resource_failure:
                        raise ResourceLimitError("CUDA OOM: retained censored episode; no further updates")
                if worker is not None:
                    worker.close()
            if mode == "train":
                save_checkpoint(args.output / "policy.pt", policy, optimizer, config, len(updates))
    require_unchanged = all(sha(ROOT / path) == value for path, value in source_hashes.items())
    require_unchanged &= all(sha(t["path"]) == t["sourceHash"] for t in tasks)
    groups = {}
    for mode in ("train", "random", "learned"):
        subset = [e for e in episodes if e["mode"] == mode]
        groups[mode] = {"episodes": len(subset), "solved": sum(e["status"] == "SOLVED_WITHIN_PROFILE" for e in subset),
                        "aborted": sum(e["status"] == "ABORTED" for e in subset),
                        "initialSolved": sum(e["status"] == "INITIAL_SOLVED_WITHIN_PROFILE" for e in subset),
                        "meanSteps": sum(e["steps"] for e in subset) / len(subset),
                        "meanEdits": None if any(e["status"] == "ABORTED" for e in subset)
                                     else sum(e.get("edits", 0) for e in subset) / len(subset),
                        "meanReturn": sum(e["return"] for e in subset) / len(subset),
                        "observedSolverCalls": sum(e["observedSolverCalls"] for e in subset)}
    changed = [k for k, value in policy.state_dict().items() if not torch.equal(value, initial_weights[k])]
    summary = {"groups": groups, "updates": len(updates), "changedParameters": changed,
               "graphAdmissions": gate.graph_checks, "graphGateExecutions": gate.graph_executions,
               "device": args.device, "elapsedSeconds": time.monotonic() - started,
               "architecture": policy.architecture(), **capacity,
               "modelForwardSeconds": forward_seconds, "modelUpdateSeconds": update_seconds,
               "peakCudaAllocatedBytes": torch.cuda.max_memory_allocated() if args.device == "cuda" else None,
               "peakCudaReservedBytes": torch.cuda.max_memory_reserved() if args.device == "cuda" else None,
               "cudaMemory": {"start": start_memory, "finish": cuda_memory_snapshot(args.device)},
               "observedSolverCalls": solver_calls,
               "inputsUnchanged": require_unchanged, "certificateReplay": "NOT_REQUESTED",
               "interpretation": "Fixture/pilot evidence only; no claim of corpus generalization or policy superiority."}
    write_json(args.output / "summary.json", summary)
    lines = ["# Structured Alloy Repair Pilot", "", summary["interpretation"], "",
             f"Device: {args.device}; updates: {len(updates)}; elapsed seconds: {summary['elapsedSeconds']:.2f}."]
    lines.extend(f"- {mode}: {counts['solved']}/{counts['episodes']} solved within profile; "
                 f"{counts['aborted']} aborted; {counts['initialSolved']} initially solved."
                 for mode, counts in groups.items())
    lines += ["", "Learned parameters: " + str(len(changed)), "",
              "Independent certificate replay was not requested. Errors remain in episode counts."]
    (args.output / "summary.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    manifest["outputHashes"] = {str(p.relative_to(args.output)): sha(p) for p in sorted(args.output.iterdir())
                               if p.is_file() and p.name != "run-manifest.json"}
    write_json(args.output / "run-manifest.json", manifest)
    if not require_unchanged or not updates or any(g["aborted"] for g in groups.values()):
        raise RuntimeError("Pilot incomplete: see retained failure/update/input evidence")
    return summary


def argument_parser(description=__doc__, comparison=False):
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--classes", type=Path, required=True)
    parser.add_argument("--device", choices=("cuda", "cpu"), default="cuda")
    parser.add_argument("--episodes", type=int, default=20, help="training episodes per task")
    parser.add_argument("--task-chunk", type=int, default=0,
                        help="0 preserves task blocks; positive values interleave fresh-bank training chunks")
    parser.add_argument("--eval-episodes", type=int, default=3)
    parser.add_argument("--eval-split", choices=("validation", "evaluation"), default="evaluation")
    parser.add_argument("--horizon", type=int, default=4)
    parser.add_argument("--capacity", type=int, default=100)
    parser.add_argument("--seeds-per-class", type=int, default=2)
    if not comparison:
        parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--hidden", type=int, default=64)
    if not comparison:
        parser.add_argument("--encoder", choices=ENCODERS, default="mpnn")
    parser.add_argument("--layers", type=int, default=2)
    parser.add_argument("--heads", type=int, default=4, help="GAT heads; ignored by other encoders")
    parser.add_argument("--lr", type=float, default=0.003)
    parser.add_argument("--timeout", type=float, default=30)
    parser.add_argument("--heap", default="2g")
    parser.add_argument("--cuda-memory-gib", type=float, default=0,
                        help="optional per-process allocator cap; 0 leaves the existing uncapped behavior")
    return parser


def main():
    args = argument_parser().parse_args()
    try:
        run(args)
    except (ResourceLimitError, torch.cuda.OutOfMemoryError) as failure:
        if args.output.exists():
            write_json(args.output / "resource-limit.json", {"status": "RESOURCE_LIMIT", "error": str(failure),
                       "semanticNegative": False, "configuration": {k: str(v) if isinstance(v, Path) else v
                                                                    for k, v in vars(args).items()}})
        raise SystemExit(75) from failure


if __name__ == "__main__":
    main()
