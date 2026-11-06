"""Derive the human report from retained run results, never from console claims."""
import argparse
import collections
import json
from pathlib import Path
import random

from .corpus import write
from .train_corpus import load_records, summarize


def cluster_interval(rows, predictions, repetitions=5000):
    groups = collections.defaultdict(list)
    for row, order in zip(rows, predictions):
        solved = int(row["outcomes"][order[0]].get("solved", False))
        random_expectation = sum(o.get("solved", False) for o in row["outcomes"]) / len(row["outcomes"])
        groups[row["group"]].append(solved-random_expectation)
    clusters = [values for _, values in sorted(groups.items())]
    rng = random.Random(137)
    values = []
    for _ in range(repetitions):
        sample = [rng.choice(clusters) for _ in clusters]
        values.append(sum(map(sum, sample))/sum(map(len, sample)))
    values.sort()
    return {"questionClusters": len(clusters), "resamples": repetitions,
            "meanDifference": sum(map(sum, clusters))/sum(map(len, clusters)),
            "lower": values[int(repetitions*.025)], "upper": values[int(repetitions*.975)]}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=Path, required=True)
    parser.add_argument("--run", type=Path, required=True)
    args = parser.parse_args()
    read = lambda name: json.loads((args.run / name).read_text())
    manifest, history, test, predictions = (read(name) for name in (
        "manifest.json", "history.json", "test.json", "test-predictions.json"))
    records = {r["id"]: r for r in load_records(args.data)}
    rows = [records[r["id"]] for r in predictions]
    rankings = [r["ranking"] for r in predictions]
    ledger = json.loads((args.data / "ledger.json").read_text())
    counts = collections.Counter(row["status"] for row in ledger)
    exclusions = collections.Counter(row.get("reason", "") for row in ledger if row["status"] != "ACCEPTED")
    by_group = {}
    for group in sorted({r["group"] for r in rows}):
        indices = [i for i, r in enumerate(rows) if r["group"] == group]
        by_group[group] = summarize([rows[i] for i in indices], [rankings[i] for i in indices])
    interval = cluster_interval(rows, rankings)
    selected = [row for row in history if row["selected"]][-1]
    result = {"manifest": manifest, "dataCounts": counts, "exclusions": exclusions,
              "test": test, "byQuestion": by_group, "top1PairedQuestionBootstrap": interval,
              "selectedEpoch": selected["epoch"], "trainingHistory": history}
    write(args.run / "comparison.json", result)
    lines = ["# Source-Backed 508M Repair Pilot", "",
        "A single-seed, bounded one-step study; not a full-corpus or multi-step repair result.", "",
        "## Data And Training", "",
        f"- Inspected files: {len(ledger)}; AST-distinct accepted: {counts['ACCEPTED']}; exclusions: {counts['EXCLUDED']}; failures: {counts['FAILED']}.",
        f"- Train/validation/test records: {manifest['counts']['train']}/{manifest['counts']['validation']}/{manifest['counts']['evaluation']}.",
        f"- Train/validation/test questions: " + "/".join(str(len(manifest['groups'][s])) for s in ("train", "validation", "evaluation")) + ".",
        f"- Development-test groups excluded: {', '.join(manifest['developmentTestGroupsExcluded']) or 'none'}.",
        f"- Parameters: {manifest['parameters']:,}; random seed: {manifest['seed']}; epochs: {len(history)}; selected epoch: {selected['epoch']}.",
        f"- Effective batch: {manifest['effectiveBatch']} (except the final partial batch); microbatch: {manifest['microbatch']}; Adafactor rate cap: {manifest['rate']}.",
        "- BF16 compute, FP32 parameters/gradients, activation checkpointing. No pretrained weights or frozen layers.",
        "- Question-disjoint splits. Checkpoint selection uses validation success, then validation loss. Test outcomes do not select a checkpoint.",
        "- Teacher: minimum residual canonical distance to the paired oracle among all valid menu edits, retaining ties.", "",
        "## Held-Out Repair Performance", ""]
    for budget in ("1", "3"):
        b = test["budgets"][budget]
        lines.append(f"- Budget {budget}: learned {b['learned_solved']}/{test['count']} ({100*b['learned_rate']:.2f}%); uniform-random expected {b['random_expected_solved']:.3f}/{test['count']} ({100*b['random_expected_rate']:.2f}%).")
    lines += [f"- Exhaustive one-step upper bound: {test['one_step_upper_bound']}/{test['count']}.",
        f"- Same-seed untrained model, top 1: {test['untrained_same_seed']['budgets']['1']['learned_solved']}/{test['count']}.",
        f"- Learned minus random top-1 difference: {100*interval['meanDifference']:.2f} percentage points; paired question-bootstrap 95% interval [{100*interval['lower']:.2f}, {100*interval['upper']:.2f}], {interval['questionClusters']} question clusters.",
        "- Random is the exact expectation for uniformly sampling distinct menu edits without replacement, not a favorable random seed.",
        "- Every success has feasible context and UNSAT in both semantic-difference directions at independent run scope 3. This is not unbounded equivalence or standalone certificate replay.",
        "- Candidate-score lookahead results are in JSON. They score every candidate first and are not equal-attempt-cost comparisons.", "", "## By Question", ""]
    for group, data in by_group.items():
        b = data["budgets"]["1"]
        lines.append(f"- `{group}`: learned {b['learned_solved']}/{data['count']}; random expected {b['random_expected_solved']:.3f}; one-step upper bound {data['one_step_upper_bound']}.")
    lines += ["", "## Resource Use And Limits", "",
        f"- Training/validation/final evaluation elapsed: {test['elapsed_seconds']/60:.2f} minutes.",
        f"- Peak allocated/reserved CUDA memory: {test['peak_allocated_bytes']/2**30:.3f}/{test['peak_reserved_bytes']/2**30:.3f} GiB, excluding external desktop usage.",
        "- Only four source-replacement templates are tested. Unreachable repairs cannot be solved regardless of policy quality.",
        "- The model sees a certificate-derived repair projection, source graph, schema and labelled user-domain tuples, not the entire proof-heavy e-graph or oracle syntax.",
        "- The corpus slice excludes unsupported inputs, imports, oversized packets and unresolved cases. Reported success rates apply to retained held-out records, not all original files.",
        "- One seed and a small number of question clusters do not establish stable superiority or trained-from-scratch convergence.",
        "- Lean proves 13 abstract corpus contracts plus the prior model contracts; end-to-end Java/Python refinement and numerical backend correctness remain outside these proofs.",
        "", "## Evidence", "",
        f"- Run directory: `{args.run.resolve()}`.",
        f"- Data directory: `{args.data.resolve()}`.",
        f"- Checkpoint SHA-256: `{test['checkpointHash']}`.",
        "- See manifest.json, history.json, test-predictions.json, comparison.json, and the data ledger plus per-record source/solver sidecars.", ""]
    (args.run / "summary.md").write_text("\n".join(lines), encoding="utf-8")


if __name__ == "__main__":
    main()
