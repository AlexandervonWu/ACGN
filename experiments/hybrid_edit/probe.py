"""Tiny functionality only. Never automatically allocates a full-sized candidate."""

import argparse
from contextlib import nullcontext
from dataclasses import asdict
import hashlib
import json
from pathlib import Path
import platform
import resource
import time

import torch
from torch.nn import functional as F

from experiments.hybrid_edit.model import Config, HybridEditTransformer, candidates, optimal_set_loss


def plan():
    rows = []
    for name, config in candidates().items():
        rows.append({"id": name, "config": asdict(config), "parameters": config.parameters(),
                     "mixed_packed_weights_bytes": config.packed_weight_bytes(),
                     "fp32_master_and_gradient_bytes": 8 * config.parameters(),
                     "nominal_full_adam_bytes": 16 * config.parameters(),
                     "large_training_status": "NOT_RUN_BACKEND_AND_DATA_GATES_OPEN"})
    return rows


def smoke(device, bits):
    torch.manual_seed(19)
    config = Config(vocab=64, width=64, layers=2, heads=4, kv_heads=2,
                    head_dim=16, ff=128, weight_bits=bits, group_size=16, max_tokens=32)
    if device.type == "cuda":
        torch.cuda.empty_cache()
        torch.cuda.reset_peak_memory_stats()
    start = time.monotonic()
    model = HybridEditTransformer(config, checkpoint_blocks=True).to(device)
    optimizer = torch.optim.SGD(model.parameters(), lr=0.03)
    tokens = torch.randint(0, config.vocab, (2, 12), device=device)
    positions = torch.tensor([[3, 6, 9], [3, 6, 9]], device=device)
    legal = torch.tensor([[True, True, False], [True, True, True]], device=device)
    targets = torch.tensor([[False, True, False], [False, True, True]], device=device)
    losses = []
    for _ in range(8):
        optimizer.zero_grad(set_to_none=True)
        context = torch.autocast("cuda", dtype=torch.bfloat16) if device.type == "cuda" else nullcontext()
        with context:
            output = model(tokens, positions, legal)
            loss = (optimal_set_loss(output["action_logits"], targets)
                    + F.cross_entropy(output["family_logits"], torch.tensor([1, 2], device=device))
                    + F.cross_entropy(output["witness_logits"], torch.tensor([0, 1], device=device))
                    + (output["value"] - 1).square().mean())
        loss.backward()
        if not all(p.grad is not None and bool(torch.isfinite(p.grad).all())
                   and float(p.grad.abs().sum()) > 0 for p in model.parameters()):
            raise RuntimeError("Missing, nonfinite or identically zero parameter gradient")
        torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0, error_if_nonfinite=True)
        optimizer.step()
        losses.append(float(loss.detach()))
    if not losses[-1] < losses[0]:
        raise RuntimeError("Tiny fixed-fixture loss did not decrease")
    if device.type == "cuda":
        torch.cuda.synchronize()
    return {"weight_bits": bits, "config": asdict(config), "parameters": config.parameters(),
            "master_dtype": "float32", "activation_autocast": "bfloat16" if device.type == "cuda" else "none",
            "steps": 8, "losses": losses, "elapsed_seconds": time.monotonic() - start,
            "peak_torch_allocated_bytes": torch.cuda.max_memory_allocated() if device.type == "cuda" else None,
            "peak_torch_reserved_bytes": torch.cuda.max_memory_reserved() if device.type == "cuda" else None,
            "status": "TINY_FIXTURE_FUNCTIONAL_ONLY"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--device", choices=("cpu", "cuda"), default="cpu")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    device = torch.device(args.device)
    if device.type == "cuda":
        if not torch.cuda.is_available():
            raise RuntimeError("CUDA requested but unavailable; no silent CPU fallback")
        torch.cuda.set_per_process_memory_fraction(0.8)
    torch.set_num_threads(2)
    files = [*Path("experiments/hybrid_edit").glob("*.py"),
             Path("docs/canonical-edit-learning/formal/HybridRepair.lean")]
    report = {"scope": "synthetic small-model functionality; no corpus or large-model fit claim",
              "python": platform.python_version(), "torch": torch.__version__, "cuda": torch.version.cuda,
              "device": torch.cuda.get_device_name() if device.type == "cuda" else "cpu",
              "input_hashes": {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)},
              "candidates": plan(), "smoke": [smoke(device, b) for b in (16, 8, 4)],
              "maximum_host_rss_kib": resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,
              "open_gates": ["certified_export", "source_edit_coverage", "checked_real_data_labels",
                             "whole_codec_correspondence", "packed_training_backend", "large_training_fit"]}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"output": str(args.output), "smoke": report["smoke"]}, indent=2))


if __name__ == "__main__":
    main()
