# Width 2048/4096 Policy Results

Date: 2026-10-03. Status: **COMPLETE** for this bounded fixture experiment.

## Main Result

The validation-selected winner is **GAT, width 64, two layers, eight heads,
learning rate 0.0003**: 305,154 parameters, 3/12 validation repairs and
9/27 fresh-seed test repairs (33.3%). Selection maximized validation repairs,
then minimized parameter count, with remaining ties resolved by input order.
The selection was frozen before the test runs and checked by executable Lean.

**MPNN-2048 did improve over its matched small control:** 9/27 test repairs
versus 3/27, at 96,681,986 versus 354,818 parameters. It did not outperform
the small GCN, GAT or GIN controls. No width-4096 candidate won validation.

Five tested configurations tied at 9/27 final repairs. The smallest of those
is GCN-64 (304,770 parameters), but this is a **post-hoc test observation**,
not the validation-selected winner. GCN had 0/12 validation repairs versus
GAT's 3/12. These different rankings are retained, not retroactively reconciled
by selecting on the test set. No default model was changed.

## Protocol

- Encoders: MPNN, GCN, GAT and GIN.
- Widths: 64, 1024, 2048 and 4096. Depth: two layers throughout.
- GAT heads: eight. Learning rate: 0.0003 throughout.
- Each child: 12 training episodes per task across two tasks, 24 optimizer updates.
- Validation: two tasks, three episodes per task, seeds 242 and 243.
- Final tests: three tasks, three episodes per task, seeds 301, 302 and 303.
- Horizon: four actions. Instance bank capacity: 100 per class.
- Serial GPU children with a 10 GiB PyTorch allocator cap on the RTX 5080.
- Each family's selected configuration and width-64 control receive final tests;
  when these are the same configuration they are executed only once.

These are the existing related fixture tasks, reused from earlier experiments,
with fresh seeds. They are not a new untouched benchmark or a full-corpus run.
Success means solver-checked repair within the existing bounded Alloy profile.

## Validation And Test Results

Validation counts below use width order **64, 1024, 2048, 4096**, each out of 12:

- MPNN: **0, 0, 3, 0**. Selected 2048. Test: 9/27; control: 3/27.
- GCN: **0, 0, 0, 0**. Selected 64 by size tie-break. Test: 9/27.
- GAT: **3, 0, 0, 0**. Selected 64. Test: 9/27.
- GIN: **0, 3, 0, 0**. Selected 1024. Test: 9/27; control: 9/27.

Matched random control: **8/27** final repairs. Repeated random runs are checked
for identical episode records; they do not provide additional independent trials.
Episodes share evolving instance banks. The one-repair aggregate advantage of
9/27 over 8/27 is not evidence of statistically established superiority.
Configurations not selected for final tests have validation results only.

## Memory And Runtime

Largest width-4096 models and maximum observed reserved allocator memory:

- MPNN: 369,524,738 parameters; **8.646 GiB** reserved, 8.325 GiB allocated.
- GCN: 168,140,802 parameters; **4.117 GiB** reserved.
- GAT: 168,165,378 parameters; **4.170 GiB** reserved.
- GIN: 268,828,676 parameters; **6.377 GiB** reserved.

All runs stayed below the 10 GiB allocator cap, with no OOM or aborted episodes.
A live `nvidia-smi` sample during MPNN-4096 measured 9,238 MiB for the process;
that is a sample, not a measured process-memory maximum. CUDA/driver memory and
other processes are outside PyTorch's allocator accounting.

Widths 8192 and 16384 were not trained: the fixed FP32 training/audit planning
estimate exceeds this run's budget. This does not claim those widths are
impossible under every optimizer, precision, or memory strategy.

Completed **50 child runs, 1,200 proof-gated updates, 1,908 episode executions,
zero aborts**. Sweep elapsed time: **878.04 seconds (14.63 minutes)**, excluding
the final aggregate output-hash pass. Validation and tests do not justify a
general increase in model width; the task diversity and training budget remain
small relative to these large models.

## Verification And Provenance

- Corrected verification: **11/11 registered claims**, two clean builds.
- Each build: **45 Python/CUDA tests**, 38 additional Java checks, plus existing
  RL-1 and canonical pipeline/metric regression gates.
- Nine new Lean resource/selection theorems; 129 Lean/Python budget and selection
  cases; 220 Lean/actual-PyTorch parameter-layout cases using the meta device.
- Proof objects, pilot episode records and learned tensors agree across builds.
- Frozen input root: `3460f0c3178f8f1d6bcde5372b2da70c88b86248a4b43359b1da3ce36264dafb`.
- Post-run audit: **693 output hashes verified**, **426 frozen inputs unchanged**,
  **362 Java/library hashes unchanged** from the preceding large-policy trial.
- Selection hash: `32dbf98ef32dd130964ca0209add23362bf0f7adc758dde71be7c4b857aa72c6`.
- Comparison hash: `b36ec0e1be23447093038977474bf847fcde2d08f8fd23597a10a47877c56683`.

The first verification attempt stopped on an allocator API device-index mismatch,
before its pilot executed. The fix and live regression are documented in
[WIDE-POLICIES.md](rl-repair/WIDE-POLICIES.md). Failed evidence remains in
`/tmp/acgn-rl-wide-check-01`; successful evidence is in
`/tmp/acgn-rl-wide-check-02`. No failed run was silently included as a success.

The proofs establish the stated mathematical contracts, with bounded executable
correspondence tests. Full Java/Python-to-Lean refinement remains **BLOCKED**.
PyTorch, CUDA, numerical kernels, allocator enforcement and the solver remain
explicit TCB; this experiment does not discharge their correctness obligations.
Java semantic rules, published result trees and model defaults were not changed.

## Evidence And Reproduction

- [Machine-readable comparison](rl-wide-policy-comparison.json)
- [Generated comparison summary](rl-wide-policy-comparison.md)
- [Frozen selection](rl-wide-policy-selection.json)
- [Verification report](rl-wide-policy-verification.json)
- [Output hashes](rl-wide-policy-output-hashes.json)
- Raw logs, traces, checkpoints and manifests: `/tmp/acgn-rl-wide-tuning-01` (34 GiB).

Use a fresh output directory:

```bash
bash scripts/run_rl_depth_tuning.sh \
  --manifest docs/rl-repair/fixtures/depth_tuning.json \
  --plan docs/rl-repair/wide-tuning-grid.json \
  --encoders mpnn gcn gat gin --seeds 242 243 --test-seeds 301 302 303 \
  --cuda-memory-gib 10 --episodes 12 --eval-episodes 3 \
  --output /tmp/acgn-rl-wide-rerun --device cuda
```
