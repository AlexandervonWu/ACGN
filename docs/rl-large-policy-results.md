# Larger Graph Policies: Capacity and Results

## What Changed

Added a larger tuning grid with widths 256, 512 and 1024 and depths 4/6/6,
alongside a width-64, four-layer control. The tuning width limit is now 1024;
the original grid and global model defaults are unchanged. Reports now separate
allocated CUDA tensor memory, reserved allocator memory, device free/total memory,
parameter-storage bytes, and nominal parameter/gradient/Adam storage.

There was no 480 MB memory cap in the RL code. The prior models were small and
processed one small graph at a time. System process-VRAM readings also include
driver/context/library overhead not fully counted by PyTorch's allocator stats.
No dummy allocations, device-memory-fraction settings, batching, mixed precision,
reward changes, or semantic rewrite changes were added to increase memory use.

The width-1024, six-layer models have these exact parameter counts:

- GCN: 22,120,450.
- GAT: 22,138,882.
- GIN: 41,013,256.
- MPNN: 59,912,194.

All four passed actual CUDA update/checkpoint tests at that size. The learning
comparison below covers GCN and GAT; it does not claim multi-seed learning results
for the 41M/60M GIN/MPNN models.

## Memory Measurements

Maximum allocated/reserved MiB over each configuration's completed runs:

- GCN 64x4: 71.68 / 74; 256x4: 108.07 / 128;
  512x6: 218.09 / 230; 1024x6: 570.41 / 628.
- GAT 64x4: 72.71 / 74; 256x4: 110.48 / 130;
  512x6: 218.30 / 238; 1024x6: 570.83 / 658.

These are measured PyTorch allocator peaks, not whole-process peaks. A separate
live `nvidia-smi` observation showed 978 MiB for a width-1024 GCN Python process;
that point sample was not a peak-monitoring experiment. The GPU is an RTX 5080
with 16,303 MiB reported device memory. There is still headroom, but occupying
more of it does not itself improve training. The current serial solver/rollout
workflow and tiny graph fixtures limit the amount of concurrent GPU work.

The memory statistics include retained activations, optimizer temporaries, audit
copies and workspaces. Parameter/gradient/two-moment accounting is not a peak
upper bound, and these fixtures do not guarantee that maximum-size graphs fit.

## Learning Retest

Completed 28 serial CUDA runs, 672 proof-gated optimizer updates, and 1,080
episodes with **zero aborts**. Elapsed sweep time was 485.35 seconds (about
8.1 minutes), excluding compilation and the separate verification suite.

Settings were frozen before execution: 12 training episodes on each of two tasks,
three evaluation episodes per task, horizon 4, instance capacity 100. Validation
seeds were 142 and 143; final retraining/test seeds were 201, 202 and 203. The
same three test fixtures from the earlier trial were reused: these are fresh
seeds, not newly untouched test tasks.

The grid order was `control-64x4`, `large-256x4`, `large-512x6`, `large-1024x6`.
Learning rates were 0.003, 0.001, 0.0003, and 0.0001 respectively. GAT used four
heads in the control and eight in larger models. Consequently this compares
capacity/training configurations, not an isolated causal effect of width.

Validation solved counts out of 12:

- GCN: `[0, 0, 0, 3]`; selected 1024x6.
- GAT: `[0, 3, 3, 0]`; selected 256x4 by the fixed tie rule.

Selections were checked by the executable Lean selector and persisted/hashed
before test runs. Final test results out of 27, with per-seed counts:

- Small GCN control: **15/27**, `[3, 3, 9]`.
- Selected large GCN: **9/27**, `[3, 0, 6]`.
- Small GAT control: **9/27**, `[3, 3, 3]`.
- Selected large GAT: **3/27**, `[3, 0, 0]`.
- Matched random control: **4/27**; repeated copies across configurations are
  the same control evidence, not independent extra samples.

Thus larger configurations run successfully but did not improve test repairs in
this trial. Both validation selections performed worse than their small controls
on the test seeds. The random result also differs from the previous seed set,
illustrating how variable this tiny pilot is. Repeated episodes share evolving
witness banks and are not independent statistical samples. This is not evidence
of corpus generalization, a universal best architecture, or a causal diagnosis
of why the larger models underperformed. No default is promoted on these data.

## Proofs and Checks

The five new `PolicyCapacity.lean` model theorems compiled before documentation
and implementation. The 140-row Lean matrix agrees exactly with the parameter
counts of actual PyTorch module definitions instantiated on the `meta` device.
Production runs also check their actual counts against the accounting formula.

The finite verification suite passed **10/10 registered claims in two clean
builds**, with 39 Python/CUDA tests per build. The large-model tests require finite,
nonzero gradients in each layer, a Lean-admitted optimizer update, and identical
outputs after checkpoint reload. Existing Java feedback, canonical pipeline,
quotient metric and source-command gates passed unchanged. Deterministic pilot
records/tensors and proof objects matched across builds; timing and allocator/
device-memory statistics are explicitly nondeterministic.

Verification input root:
`52f53a5affafaf5eb71e0c1daaa15908e938b31c3a700b664fefce4f3596b013`.

All 421 frozen verification inputs remained unchanged. All 394 generated sweep
file hashes matched; the frozen selection hash remained unchanged. All 362
Java/dependency files retain their preceding depth-run hashes. Published empirical
trees, semantic/certificate logic, and source-level repair units were not changed.

These Lean proofs concern the declared model/accounting properties, not GPU
allocation bounds, floating-point/autograd correctness or policy convergence.
Full Java/Python-to-Lean application refinement remains **BLOCKED** by the
separately documented open bridges. PyTorch/CUDA and the declared runtime/toolchain
components remain TCB. Repairs are solver-checked within the chosen Alloy profile,
not claimed as unbounded equivalence; independent certificate replay was not run.

## Evidence and Reproduction

- [Generated comparison](rl-large-policy-comparison.md)
- [Machine-readable runs](rl-large-policy-comparison.json)
- [Frozen validation selection](rl-large-policy-selection.json)
- [Two-build verification report](rl-large-policy-verification.json)
- [Protocol and reproduction command](rl-repair/LARGE-POLICIES.md)

Full local evidence is retained in `/tmp/acgn-rl-large-tuning-01` and
`/tmp/acgn-rl-large-check-01`. These temporary locations are not publication
archives. Use a fresh output directory when reproducing.
