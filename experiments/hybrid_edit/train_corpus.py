"""508M source-backed training and held-out, solver-checked one-step evaluation."""
import argparse
from dataclasses import asdict
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import random
import platform
import subprocess
import time

import torch
from .batching import BatchPlan, update_batch, objective
from .model import Config, HybridEditTransformer, candidates
from .corpus import write, digest, ROOT


def load_records(directory):
    ledger = json.loads((directory / "ledger.json").read_text())
    rows = []
    groups = {}
    for item in ledger:
        if item["status"] != "ACCEPTED":
            continue
        path = directory / "records" / (item["id"] + ".json")
        row = json.loads(path.read_text())["packet"]
        if hashlib.sha256(json.dumps(row, sort_keys=True).encode()).hexdigest() != item["packetHash"]:
            raise ValueError("Dataset packet hash mismatch")
        if groups.setdefault(row["group"], row["split"]) != row["split"]:
            raise ValueError("Question crosses split boundary")
        if len(row["outcomes"]) != len(row["actions"]) or not any(row["optimal"]):
            raise ValueError("Incomplete or empty labels")
        if row["initialDistance"] == 0:
            raise ValueError("Initial semantic counterexample has zero teacher distance")
        for action, outcome in zip(row["actions"], row["outcomes"]):
            if action["index"] != outcome["index"]:
                raise ValueError("Action/outcome mismatch")
            if outcome.get("valid") and outcome["distance"] == 0 and not outcome.get("solved", False):
                raise ValueError("Zero teacher distance conflicts with semantic validation")
            if outcome.get("solved", False):
                v = outcome["validation"]
                if v["extra"] != "UNSAT" or v["missing"] != "UNSAT" or v["verdict"] != "SOLVED_WITHIN_PROFILE":
                    raise ValueError("Success lacks two-direction solver verdict")
        rows.append(row)
    return rows


def features(rows, device):
    length, actions = max(len(r["tokens"]) for r in rows), max(len(r["positions"]) for r in rows)
    tokens = torch.zeros(len(rows), length, dtype=torch.long, device=device)
    positions = torch.zeros(len(rows), actions, dtype=torch.long, device=device)
    legal = torch.zeros(len(rows), actions, dtype=torch.bool, device=device)
    for i, row in enumerate(rows):
        n, a = len(row["tokens"]), len(row["positions"])
        tokens[i, :n] = torch.tensor(row["tokens"], device=device)
        positions[i, :a] = torch.tensor(row["positions"], device=device)
        legal[i, :a] = True
    return {"tokens": tokens, "positions": positions, "legal": legal}


def training_batch(rows, device):
    batch = features(rows, device)
    optimal = torch.zeros_like(batch["legal"])
    families = torch.zeros(len(rows), 9, device=device)
    for i, row in enumerate(rows):
        optimal[i, :len(row["optimal"])] = torch.tensor(row["optimal"], device=device)
        for action, chosen in zip(row["actions"], row["optimal"]):
            if chosen:
                families[i, action["family"]] += 1 / sum(row["optimal"])
    batch.update(optimal=optimal, family=families,
                 witness=torch.tensor([r["witness"] for r in rows], device=device),
                 value=torch.tensor([r["value"] for r in rows], device=device))
    return batch


def repaired(row, order, budget):
    return any(row["outcomes"][i].get("solved", False) for i in order[:budget])


def summarize(rows, rankings):
    report = {"count": len(rows), "questions": len({r["group"] for r in rows}), "budgets": {}}
    for budget in (1, 3):
        learned = sum(repaired(r, order, budget) for r, order in zip(rows, rankings))
        score = sum(repaired(r, sorted(range(len(r["actions"])),
                           key=lambda i: (-r["outcomes"][i].get("score", -1), i)), budget) for r in rows)
        expected = 0.0
        for row in rows:
            n = len(row["actions"])
            good = sum(o.get("solved", False) for o in row["outcomes"])
            k = min(budget, n)
            expected += 1 - (math.comb(n-good, k) / math.comb(n, k) if n-good >= k else 0)
        report["budgets"][str(budget)] = {"learned_solved": learned, "learned_rate": learned / len(rows),
                    "random_expected_solved": expected, "random_expected_rate": expected / len(rows),
                    "counterexample_score_solved": score, "counterexample_score_rate": score / len(rows)}
    report["counterexample_score_cost"] = "All menu candidates scored before ranking; not a matched-attempt baseline"
    report["one_step_upper_bound"] = sum(any(o.get("solved", False) for o in r["outcomes"]) for r in rows)
    return report


@torch.no_grad()
def evaluate(model, rows, device, microbatch=8, labels=False):
    if not rows:
        raise ValueError("Empty evaluation split")
    model.eval()
    rankings, loss = [], 0.0
    for start in range(0, len(rows), microbatch):
        chunk = rows[start:start+microbatch]
        batch = features(chunk, device)
        with torch.autocast("cuda", dtype=torch.bfloat16, enabled=device.type == "cuda"):
            out = model(batch["tokens"], batch["positions"], batch["legal"])
            if labels:
                value = objective(model, training_batch(chunk, device))
                if not bool(torch.isfinite(value)):
                    raise ValueError("Nonfinite validation objective")
                loss += float(value) * len(chunk)
        for row, logits in zip(chunk, out["action_logits"].cpu().tolist()):
            rankings.append(sorted(range(len(row["actions"])), key=lambda i: (-logits[i], i)))
    model.train()
    return summarize(rows, rankings), rankings, loss / len(rows) if labels else None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--epochs", type=int, default=8)
    parser.add_argument("--seed", type=int, default=19)
    parser.add_argument("--lr", type=float, default=0.00003)
    parser.add_argument("--effective-batch", type=int, default=128)
    parser.add_argument("--microbatch", type=int, default=8)
    parser.add_argument("--tiny-test", action="store_true")
    parser.add_argument("--development-test-groups", nargs="*", default=[])
    args = parser.parse_args()
    args.output.mkdir()
    rows = load_records(args.data)
    parts = {s: [r for r in rows if r["split"] == s] for s in ("train", "validation", "evaluation")}
    development_excluded = [r["id"] for r in parts["evaluation"] if r["group"] in args.development_test_groups]
    parts["evaluation"] = [r for r in parts["evaluation"] if r["group"] not in args.development_test_groups]
    if any(not value for value in parts.values()):
        raise ValueError("All three question-disjoint splits are required")
    random.seed(args.seed)
    torch.manual_seed(args.seed)
    torch.set_num_threads(2)
    device = torch.device("cuda")
    torch.cuda.set_per_process_memory_fraction(.8)
    config = (Config(width=64, layers=2, heads=4, kv_heads=2, head_dim=16, ff=128, group_size=64)
              if args.tiny_test else candidates()["508m-w16a16"])
    sources = [*Path("experiments/hybrid_edit").glob("*.py"),
               *Path("docs/canonical-edit-learning/formal").glob("*.lean"),
               *Path("src/is/fivefivefive/ACGN/repair").glob("*.java")]
    manifest = {"protocol": "hybrid-corpus-one-step-v2", "config": asdict(config), "parameters": config.parameters(),
                "seed": args.seed, "epochs": args.epochs, "rate": args.lr,
                "effectiveBatch": args.effective_batch, "microbatch": args.microbatch,
                "counts": {s: len(value) for s, value in parts.items()},
                "groups": {s: sorted({r["group"] for r in value}) for s, value in parts.items()},
                "developmentTestGroupsExcluded": args.development_test_groups,
                "developmentTestIdsExcluded": development_excluded,
                "datasetLedgerHash": digest(args.data / "ledger.json"),
                "datasetSelectionHash": digest(args.data / "selection.json"),
                "sourceHashes": {str(p): digest(p) for p in sources},
                "startedAt": datetime.now(timezone.utc).isoformat(),
                "gitHead": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
                "dirtyTree": bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT)),
                "python": platform.python_version(), "host": platform.node(),
                "torch": torch.__version__, "cuda": torch.version.cuda,
                "device": torch.cuda.get_device_name(), "scope": "one-step, independent run scope 3",
                "certificateReplay": "NOT_REQUESTED", "training": "from-scratch-full-parameter"}
    write(args.output / "manifest.json", manifest)
    with torch.device(device):
        model = HybridEditTransformer(config, checkpoint_blocks=True)
    optimizer = torch.optim.Adafactor(model.parameters(), lr=args.lr, foreach=False)
    best_key = (-1, -math.inf)
    history = []
    started = time.monotonic()
    initial_validation, _, initial_loss = evaluate(model, parts["validation"], device, args.microbatch, labels=True)
    write(args.output / "initial-validation.json", dict(initial_validation, loss=initial_loss))
    for epoch in range(args.epochs):
        order = list(parts["train"])
        random.Random(args.seed + epoch).shuffle(order)
        total = 0.0
        for start in range(0, len(order), args.effective_batch):
            chunk = order[start:start+args.effective_batch]
            # Fixed rate is deliberately conservative; tuning never sees test outcomes.
            batch = training_batch(chunk, device)
            step = update_batch(model, optimizer, batch, BatchPlan(len(chunk), min(args.microbatch, len(chunk))), amp=True)
            total += step["loss"] * len(chunk)
            print(json.dumps({"epoch": epoch+1, "examples": start+len(chunk), "total": len(order),
                              "loss": step["loss"], "seconds": time.monotonic()-started}), flush=True)
        validation, _, val_loss = evaluate(model, parts["validation"], device, args.microbatch, labels=True)
        key = validation["budgets"]["1"]["learned_solved"], -val_loss
        improved = key > best_key
        if improved:
            best_key = key
            torch.save({"config": asdict(config), "state_dict": {k: v.detach().cpu() for k, v in model.state_dict().items()},
                        "epoch": epoch+1, "manifest": manifest}, args.output / "best.pt")
        history.append({"epoch": epoch+1, "train_loss": total/len(order), "validation_loss": val_loss,
                        "validation": validation, "selected": improved})
        write(args.output / "history.json", history)
        print(json.dumps({"epoch_completed": epoch+1, "validation": validation, "validation_loss": val_loss,
                          "selected": improved}), flush=True)
    del optimizer
    model.load_state_dict(torch.load(args.output / "best.pt", map_location="cpu", weights_only=False)["state_dict"])
    test, rankings, _ = evaluate(model, parts["evaluation"], device, args.microbatch)
    del model
    torch.cuda.empty_cache()
    torch.manual_seed(args.seed)
    with torch.device(device):
        untrained = HybridEditTransformer(config)
    test["untrained_same_seed"], _, _ = evaluate(untrained, parts["evaluation"], device, args.microbatch)
    del untrained
    test.update(elapsed_seconds=time.monotonic()-started, peak_allocated_bytes=torch.cuda.max_memory_allocated(),
                peak_reserved_bytes=torch.cuda.max_memory_reserved(), checkpointHash=digest(args.output / "best.pt"))
    write(args.output / "test.json", test)
    write(args.output / "test-predictions.json", [{"id": r["id"], "group": r["group"], "ranking": order,
          "solved": [o.get("solved", False) for o in r["outcomes"]]} for r, order in zip(parts["evaluation"], rankings)])
    print(json.dumps({"test": test}), flush=True)


if __name__ == "__main__":
    main()
