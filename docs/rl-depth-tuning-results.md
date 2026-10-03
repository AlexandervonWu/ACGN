# Deeper Graph Policies: Tuning and Retest

## Outcome

Completed 50 CUDA runs, 1,200 proof-gated optimizer updates and 1,908 episodes,
with zero aborted episodes. The sweep took 847.39 seconds (about 14.1 minutes),
excluding its initial Java compilation and the separate verification suite.

Fresh-seed test results, each over the same 27 episodes:

- MPNN: the selected two-layer baseline repaired 3/27 (11.1%).
- GCN: four layers repaired 9/27 (33.3%), versus the baseline's 6/27 (22.2%).
- GAT: the selected two-layer baseline repaired 3/27 (11.1%).
- GIN: the selected four-layer, width-96, learning-rate-0.001 model repaired
  6/27 (22.2%), the same total as its two-layer baseline.
- The matched random policy repaired 11/27 (40.7%). These repeated controls
  are identical across arms, not additional independent samples.

There is a bounded GCN improvement, but **none of the selected learned policies
outperformed random** on this test. GIN's validation improvement did not improve
its test total. No six-layer configuration won validation. The global default
remains the original two-layer MPNN; these data do not justify promoting a
configuration to a general-purpose repair policy.

Task-level outcomes help interpret the totals. Selected GCN repaired 3/9
episodes on each of the three test tasks. Wider GIN repaired 6/9 on bound
relational overlap and zero on the other two tasks; its baseline repaired
3/9 each on nested Boolean and bound-overlap tasks. Equal totals can therefore
hide different specialization. These are observations, not a causal explanation
of optimization or generalization performance.

## Experiment

All four encoder families use this fixed grid:

- `baseline-2`: 2 layers, width 64, learning rate 0.003.
- `depth-4`: 4 layers, width 64, learning rate 0.003.
- `wide-4-slow`: 4 layers, width 96, learning rate 0.001.
- `depth-6-slow`: 6 layers, width 64, learning rate 0.0003.

GAT has four heads. Every child run trains for 12 episodes on each of two
training tasks, with horizon 4 and capacity 100 per instance class. Optimizer,
loss, reward, action vocabulary, bank semantics and proof gate are unchanged.
The same task-block training order is retained. Width/depth vary, so parameter
counts are not matched.

Validation used seeds 42 and 43 on two separate tasks. The executable Lean
selector maximized solved counts and broke ties by grid order. Results, in grid
order and out of 12 validation episodes:

- MPNN: `[3, 3, 3, 3]`; selected `baseline-2`.
- GCN: `[0, 3, 3, 0]`; selected `depth-4`.
- GAT: `[3, 3, 3, 0]`; selected `baseline-2`.
- GIN: `[0, 3, 6, 0]`; selected `wide-4-slow`.

Selection was persisted and hashed before launching any final evaluation.
The selected models and baselines were retrained using fresh seeds 101, 102,
and 103 and evaluated on three new tasks. Each had three episodes per task.
When selection chose the baseline, one run served both labels. No test-time
optimizer update or reselection was permitted.

These are tiny, related, hand-authored fixtures, not a corpus benchmark or a
near-clone-isolated generalization study. Episodes share evolving witness banks;
they are not independent Bernoulli samples. Success means solver-checked
`SOLVED_WITHIN_PROFILE`, not unbounded Alloy equivalence. No independent semantic
certificate replay was requested. More task coverage and larger training budgets
need a separately frozen experiment; the present results do not establish which
factor limits learning.

## Verification and Boundaries

The eight new Lean model theorems were compiled before documentation and code.
They cover selection membership/maximality/ties and conditional finite-layer
invariant preservation. Actual selections invoke the executable Lean selector.
The 84-row bounded score matrix matches Python exactly.

The updated finite verification suite passed 9/9 claims in two clean builds:

- 34 Python/CUDA tests per build, including all encoders at depths 4 and 6,
  finite nonzero per-layer gradients, proof-gated updates, and exact checkpoint
  reloads; all new fixtures have a reachable source edit that solves the profile.
- 38 Java feedback assertions per build and the 155-row Lean/Java reward matrix.
- Existing gates: 2,041 canonical pipeline checks, 2,266 quotient repair distance
  checks and 44 source-command checks per build.
- Proof objects, registered metadata, deterministic pilot episodes, and learned
  pilot tensors match across builds. Timing and allocator statistics are explicitly
  excluded from bitwise comparisons.

Input root:
`ebd6987e5abb96e47e1f8f434f1b3ca54f6beaa2cb787313d8cb7d6329a2dd07`.

Lean model proofs and bounded correspondence tests do not establish complete
Java/Python refinement, numerical/autograd correctness, or policy convergence.
Whole-application refinement remains **BLOCKED** by its separately recorded open
bridges. PyTorch/CUDA, Lean's runtime/kernel, JDK, Alloy/SAT and the platform
remain the declared TCB. Learned scores acquire no semantic authority.

All 362 Java/dependency files retain their previous comparison-run hashes.
The existing certificate/metric implementation and published experimental trees
were not modified. The 692 generated sweep-file hashes were checked with zero
mismatches.

## Evidence and Reproduction

- [Generated comparison](rl-depth-tuning-comparison.md)
- [Machine-readable runs and summaries](rl-depth-tuning-comparison.json)
- [Frozen selection](rl-depth-tuning-selection.json)
- [Two-build verification report](rl-depth-tuning-verification.json)
- [Protocol, proof correspondence and reproduction command](rl-repair/DEPTH-TUNING.md)

Complete traces, checkpoints, manifests, worker logs and output hashes remain in
`/tmp/acgn-rl-depth-tuning-01`; verification evidence is in
`/tmp/acgn-rl-depth-check-01`. These are local temporary evidence locations, not
archival publication storage.

```bash
bash scripts/run_rl_depth_tuning.sh \
  --manifest docs/rl-repair/fixtures/depth_tuning.json \
  --plan docs/rl-repair/tuning-grid.json \
  --output /tmp/acgn-rl-depth-tuning-02 \
  --episodes 12 --eval-episodes 3 --device cuda
```

Use a fresh output directory. Defaults reproduce the declared seed sets. Raw
outputs record child hashes and the immutable selection; an incomplete child
run blocks the sweep rather than silently disappearing from reported averages.
