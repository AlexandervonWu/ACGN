"""Bounded full-parameter adaptive-optimizer batch fit, not Alloy training."""

import argparse
from dataclasses import asdict
import hashlib
import inspect
import json
import math
import os
from pathlib import Path
import platform
import resource
import subprocess
import threading
import time
import traceback

import torch

from experiments.hybrid_edit.batching import BatchPlan, evaluate_batch, update_batch
from experiments.hybrid_edit.model import HybridEditTransformer, candidates
from experiments.hybrid_edit.scope import ASSIGNED, PROFILE, TOKENS


def synthetic_batch(count, length, seed, device):
    generator = torch.Generator().manual_seed(seed)
    alphabet = torch.tensor(sorted(ASSIGNED - {TOKENS["PAD"]}))
    tokens = alphabet[torch.randint(len(alphabet), (count, length), generator=generator)]
    tokens[:, 0] = TOKENS["BOS"]
    tokens[:, -1] = TOKENS["QUERY"]
    positions = torch.tensor([length // 4, length // 2, 3 * length // 4]).expand(count, -1).clone()
    legal = torch.ones(count, 3, dtype=torch.bool)
    legal[::2, 2] = False
    optimal = torch.zeros_like(legal)
    optimal[:, 1] = True
    optimal[1::2, 2] = True
    parity = torch.arange(count) % 2
    batch = {"tokens": tokens, "positions": positions, "legal": legal, "optimal": optimal,
             "family": torch.where(parity.bool(), 5, 8), "witness": parity,
             "value": parity.float()}
    identity = hashlib.sha256()
    for key, value in sorted(batch.items()):
        identity.update(key.encode() + str(value.dtype).encode() + str(tuple(value.shape)).encode())
        identity.update(value.contiguous().numpy().tobytes())
    metadata = {"kind": "SYNTHETIC_FIXED_BATCH_NOT_EXPORTED_ALLOY",
                "unique_token_packets": int(torch.unique(tokens, dim=0).shape[0]),
                "sha256": identity.hexdigest(), "seed": seed,
                "warning": "Alphabet-valid tensors and synthetic targets, not a full packet parser or teacher"}
    return {key: value.to(device) for key, value in batch.items()}, metadata


class MemorySampler:
    def __init__(self):
        self.stop = threading.Event()
        self.samples = []
        self.errors = []
        self.thread = threading.Thread(target=self._run, daemon=True)

    def _run(self):
        while not self.stop.is_set():
            try:
                output = subprocess.check_output(
                    ["nvidia-smi", "--query-compute-apps=pid,used_memory", "--format=csv,noheader,nounits"],
                    text=True, timeout=3)
                process_mib = sum(int(row.split(",")[1].strip()) for row in output.splitlines()
                                  if row.split(",")[0].strip() == str(os.getpid()))
                output = subprocess.check_output(
                    ["nvidia-smi", "--query-gpu=memory.used", "--format=csv,noheader,nounits"],
                    text=True, timeout=3)
                self.samples.append({"process_mib": process_mib, "device_mib": int(output.splitlines()[0])})
            except (OSError, ValueError, subprocess.SubprocessError) as error:
                self.errors.append(str(error))
                return
            self.stop.wait(0.5)

    def finish(self):
        self.stop.set()
        self.thread.join(timeout=7)
        return {"sample_count": len(self.samples),
                "sampled_peak_process_mib": max((s["process_mib"] for s in self.samples), default=None),
                "sampled_peak_device_mib": max((s["device_mib"] for s in self.samples), default=None),
                "errors": self.errors}


def optimizer_bytes(optimizer):
    return sum(value.numel() * value.element_size() for state in optimizer.state.values()
               for value in state.values() if isinstance(value, torch.Tensor))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--candidate", choices=tuple(candidates()), required=True)
    parser.add_argument("--effective-batch", type=int, required=True)
    parser.add_argument("--microbatch", type=int, required=True)
    parser.add_argument("--tokens", type=int, default=512)
    parser.add_argument("--updates", type=int, default=2)
    parser.add_argument("--learning-rate", type=float, default=0.001)
    parser.add_argument("--seed", type=int, default=19)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    plan = BatchPlan(args.effective_batch, args.microbatch)
    config = candidates()[args.candidate]
    if not 8 <= args.tokens <= config.max_tokens or not 2 <= args.updates <= 8:
        parser.error("Bounded run requires 8-2048 tokens and 2-8 updates")
    if not math.isfinite(args.learning_rate) or not 0 < args.learning_rate <= 0.01:
        parser.error("Expected finite learning rate in (0, 0.01]")
    if args.output.exists():
        parser.error("Refusing to overwrite a previous attempt")
    # The public class's __module__ names torch.optim's re-export, not its code.
    optimizer_sources = {Path(inspect.getfile(torch.optim.Adafactor.__init__)),
                         Path(inspect.getfile(inspect.unwrap(torch.optim.Adafactor.step)))}
    files = [*Path("experiments/hybrid_edit").glob("*.py"),
             Path("docs/canonical-edit-learning/formal/HybridRepair.lean"),
             Path("docs/canonical-edit-learning/BATCH-STUDY.md"),
             *optimizer_sources]
    report = {"protocol": "hybrid-batch-fit-v1", "profile": PROFILE,
              "status": "RUNNING", "config": asdict(config), "parameters": config.parameters(),
              "candidate": args.candidate, "effective_batch": args.effective_batch,
              "microbatch": args.microbatch, "accumulation_steps": len(plan.slices()),
              "tokens": args.tokens, "requested_updates": args.updates,
              "master_dtype": "float32", "autocast": "bfloat16", "allocator_fraction": 0.8,
              "optimizer": "torch.optim.Adafactor", "learning_rate": args.learning_rate,
              "optimizer_sources": sorted(str(p) for p in optimizer_sources),
              "python": platform.python_version(), "torch": torch.__version__, "cuda": torch.version.cuda,
              "input_hashes": {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)},
              "updates": [], "open_gates": ["source_exporter", "real_teacher_labels", "repair_efficacy"]}
    start = time.monotonic()
    sampler = MemorySampler()
    exit_code = 0
    try:
        if not torch.cuda.is_available():
            raise RuntimeError("CUDA unavailable; no CPU fallback")
        device = torch.device("cuda:0")
        torch.cuda.set_device(device)
        torch.cuda.set_per_process_memory_fraction(0.8)
        torch.set_num_threads(2)
        torch.manual_seed(args.seed)
        torch.cuda.reset_peak_memory_stats()
        report["device"] = torch.cuda.get_device_name()
        sampler.thread.start()
        with torch.device(device):
            model = HybridEditTransformer(config, checkpoint_blocks=True)
        optimizer = torch.optim.Adafactor(model.parameters(), lr=args.learning_rate, foreach=False)
        report["optimizer_defaults"] = optimizer.defaults
        batch, report["fixture"] = synthetic_batch(plan.effective_batch, args.tokens, args.seed + 1, device)
        print(json.dumps({"stage": "prepared", "candidate": args.candidate,
                          "effective_batch": args.effective_batch, "microbatch": args.microbatch}), flush=True)
        for step in range(args.updates):
            torch.cuda.synchronize()
            step_start = time.monotonic()
            row = update_batch(model, optimizer, batch, plan, amp=True)
            torch.cuda.synchronize()
            row.update(index=step + 1, seconds=time.monotonic() - step_start,
                       optimizer_state_bytes=optimizer_bytes(optimizer))
            report["updates"].append(row)
            print(json.dumps({"stage": "updated", **row}), flush=True)
        report["post_update_fixed_batch_loss"] = evaluate_batch(model, batch, plan, amp=True)
        report["loss_decreased"] = report["post_update_fixed_batch_loss"] < report["updates"][0]["loss"]
        report["status"] = "PASS_FUNCTIONAL_NOT_REPAIR_EVIDENCE"
    except BaseException as error:
        exit_code = 1
        report.update(status="OOM" if isinstance(error, torch.OutOfMemoryError) else "FAILED",
                      error_type=type(error).__name__, error=str(error), traceback=traceback.format_exc())
    finally:
        report["memory_sampler"] = sampler.finish() if sampler.thread.ident is not None else None
        report["elapsed_seconds"] = time.monotonic() - start
        report["host_max_rss_kib"] = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
        if torch.cuda.is_initialized():
            report["peak_allocated_bytes"] = torch.cuda.max_memory_allocated()
            report["peak_reserved_bytes"] = torch.cuda.max_memory_reserved()
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"output": str(args.output), "status": report["status"]}), flush=True)
    raise SystemExit(exit_code)


if __name__ == "__main__":
    main()
