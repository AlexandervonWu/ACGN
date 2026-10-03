# Canonical Edit Learning

The proposed **Hybrid Edit Transformer** combines typed e-graph incidence,
a nine-family repair vocabulary, and concrete counterexamples. It learns to
choose executable source edits; it never learns authority to merge e-classes.

Read [the specification](SPECIFICATION.md) and
[standalone Lean contracts](formal/HybridRepair.lean), followed by the
[proof/implementation ledger](OBLIGATIONS.md) and
[bounded prototype results](PROTOTYPE-RESULTS.md). The design preserves the
existing canonical metric, including pairwise alpha minimization and unordered
minimum-cost assignment. It does not reuse readable edit strings as ground-truth
programs. Earlier results and failures are archived in
[the failure ledger](../repair-search/FAILURE-MODES.md).

The user selected training **from scratch**, approximately 4B parameters subject
to actual hardware limits. The precision/capacity study includes 1.64-3.25B BF16,
3.25-4.06B W8A16 and 3.25-4.86B W4A16 candidates, not a mandate to fill VRAM.
QAT fake quantization is not packed low-memory training. Model fit,
source-backed labels, full-graph export and executable
action coverage must pass before long training. None is inferred from a parameter
count or from the earlier failed graph-policy pilots.

```bash
lean -o /tmp/HybridRepair.olean docs/canonical-edit-learning/formal/HybridRepair.lean
```

Theorems establish model-level container behavior, scoped occurrence separation,
finite-menu minimization, guarded commits, counterexample rejection and parameter
accounting. Actual serializer round trips, certified renaming transport,
Java-to-Lean correspondence, CUDA/optimizer numerics and learning effectiveness
are separate proof/test obligations. Full implementation refinement remains open.

A [self-contained PyTorch prototype](../../experiments/hybrid_edit/README.md)
provides the eight candidate configurations, resident INT4/INT8 QAT reference,
INT4 storage codec, tiny training probes and parameter-count tests. It does not
yet connect the canonical graph exporter or construct real repair labels.
