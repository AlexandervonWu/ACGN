# Depth and Hyperparameter Tuning

## Protocol Frozen Before Execution

The four encoder families remain MPNN, GCN, GAT, and GIN. A bounded grid
compares 2, 4, and 6 message-passing layers, widths 64 and 96, and Adam
learning rates 0.003, 0.001, and 0.0003. The original two-layer configuration
is first in the grid. Training budgets, task order, action menus, rewards,
instance banks, horizon, critic loss, entropy coefficient and clipping stay
fixed. No semantic/certificate rule changes are involved.

Each configuration uses the same two training tasks and two validation tasks
at seeds 42 and 43. Selection maximizes total validation solved episodes;
ties retain the earlier grid entry (the baseline wins an all-way tie).
All candidates must finish without aborts and with the same evaluation
denominator. Failed runs block selection; they are not discarded from an
average. Lean independently computes the selected index from the recorded
integer counts. The chosen configurations and evidence hashes are written
before any final evaluation is launched.

Final evaluation retrains both the selected configuration and the baseline
on fresh seeds 101, 102 and 103, then evaluates on three new test fixtures.
If the baseline is selected, one run serves both labels: duplicated evidence
is never counted as two independent samples. Test counts cannot change the
selection. Neither validation nor evaluation produces optimizer updates.
An explicit evaluation-split argument keeps the original runner behavior as
the default. Manifests reject repeated source hashes or groups across splits.

The fixture selection is illustrative, with related repair patterns across
splits. This is not a corpus-level/near-clone leakage audit or an independent
benchmark. Repeated episodes share an evolving witness bank. Seed/task-level
results are retained; episode counts are not independent Bernoulli trials.
No global architecture default is changed based on these data.

## Proof and Implementation Correspondence

`formal/TuningProtocol.lean` precedes implementation. Its eight theorems prove
selection membership, domination of both inputs, deterministic left ties,
maximality of the fold, and preservation of a supplied layer invariant under
any finite number of layers. The last theorem is conditional on the layer
preserving that invariant; it does not prove CUDA/autograd or convergence.

The executable Lean selector is called for each actual selection. An 84-row
exhaustive bounded score matrix also compares Python and Lean. CUDA tests
exercise all four encoders at depths 4 and 6, require nonzero finite gradients
in every layer, proof-gated parameter updates, and exact checkpoint reloads.
Split isolation, fixed denominators, tie behavior, rejected partial sweeps,
and fresh final seeds are checked separately. The existing learning verifier
runs two clean builds and retains the established semantic regression gates.

TCB: Lean kernel/compiler/runtime, Python/PyTorch/CUDA floating-point kernels,
GPU/driver, JDK, bundled Alloy/SAT solver, OS/filesystem and hashes. The existing
Java/Python-to-Lean application refinement gaps remain open. These new proofs
and tests do not close them or certify learned predictions as equivalences.

## Reproduction

```bash
bash scripts/run_rl_depth_tuning.sh \
  --manifest docs/rl-repair/fixtures/depth_tuning.json \
  --plan docs/rl-repair/tuning-grid.json \
  --output /tmp/acgn-rl-depth-tuning \
  --episodes 12 --eval-episodes 3 --device cuda
```

The run is serial and bounded to at most 56 child runs for the default plan.
The launcher compiles Java once. Each child has a fresh optimizer and fresh
workers, proof-gated updates, source/dependency hashes, per-step traces,
checkpoints and timing/memory evidence. `selection.json` is immutable after
validation; `tuning.json` and `summary.md` contain validation and final results.
All outputs require a fresh destination. No full-corpus results are replaced.
