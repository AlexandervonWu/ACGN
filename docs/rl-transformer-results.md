# Lean-Gated EGraph2Graph Transformer Results

Date: 2026-10-03. Status: **COMPLETE** for the bounded implementation and fixture
experiment below. Full application refinement remains **BLOCKED**.

## What Was Built

The new `egraph_transformer` family performs iterative graph-edit transduction:

```text
e-graph-derived repair view
  -> executable Lean structural admission
  -> typed/port-aware local processing + latent-global attention
  -> action-query cross-attention
  -> source edit proposal
  -> existing Java reparse / exact preparation / bounded solver checks
  -> next repair view
```

The design combines the local/global separation of GraphGPS with a Perceiver-style
latent bottleneck. The [specification and primary research links](rl-repair/EGRAPH2EGRAPH.md)
also explain the relevant Graphormer, TokenGT, Exphormer and PPGT work and which
mechanisms are not reproduced here. This is not a claim of state-of-the-art repair
performance.

Each transformer block has an occurrence-preserving local sum, eight latent
queries, node-to-latent read/write attention, residual connections and a
four-times-width feed-forward network. The decoder cross-attends from existing
source edit actions to graph nodes. BAG occurrences and SEQUENCE ports are retained
by the structural input; feature hashing and clipped numeric features remain
limitations of the existing observation contract.

The input is a repair projection derived from the e-graph, not the complete internal
e-class/member incidence graph. The output is a checked edit transition, not an
unconstrained decoder of certified e-graphs. The network does not generate equality
certificates or directly modify the semantic kernel. Java semantic rules, model
defaults and published experimental result trees were not changed.

## Lean First, Then Implementation

[EGraph2Graph.lean](rl-repair/formal/EGraph2Graph.lean) was compiled before the
natural-language specification and Python implementation. It contains **23 new
theorems**, with no `sorry`, declared `axiom`, `unsafe` or `native_decide`:

- Structural admission and node/edge/action/attention-dimension bounds.
- Port labels, ordered positions, duplicate occurrences and pointer relabeling.
- Exact weighted-moment permutation algebra and query-order equivariance.
- Mask exclusion and conditional checked-output commit properties.
- Parameter accounting and the fixed-latent attention pair count.

The executable gate checks actual structural requests, echoes them exactly and
binds a receipt to each model-driven transition. An exact-request cache avoids
recompiling or rechecking identical shapes; code/proof contract changes invalidate
reuse. Existing rollout/return admission remains required before optimizer updates.

The compiled theorems concern the stated mathematical models. In particular,
weighted-moment algebra is not a universal proof about floating-point softmax,
and the conditional commit theorem is not a proof of the Java semantic checker.
CUDA value/gradient and permutation tests supply bounded correspondence evidence.

## Verification Results

Candidate r2 passed **12/12 registered claims**, **two clean builds**, and the
required determinism comparison. Each build passed **53 Python/CUDA tests** and
38 additional Java checks, alongside the existing RL-1 and canonical pipeline
regressions. Verification took 272.93 seconds.

The frozen suite includes a **640-row** Lean/Python structural-admission matrix,
a **275-row** Lean/actual-PyTorch parameter-count matrix, double-precision CUDA
dense-reference attention values and gradients, reindexing tests, duplicate/port
sensitivity, receipt/cache rejection, checkpoint binding, a live solver-checked
graph-edit transition and deterministic transformer training pilots. Pilot learned
tensors and episode records agree across builds; checkpoint archive bytes are not
claimed identical.

Candidate r1 stopped because the verifier counted task-load records as model
transitions. The repair restricts the count to actual steps and recomputes every
receipt from the recorded observation. Regression coverage includes load/random
records and modified ports/hashes. Failed evidence remains at
`/tmp/acgn-rl-transformer-check-01`; successful fresh evidence is at
`/tmp/acgn-rl-transformer-check-02`. No failed run was counted as successful.

The declared TCB includes Lean's kernel/compiler/runtime, PyTorch/CUDA and numerical
kernels, the driver, the Alloy/SAT dependencies, hashing and the host platform.
Full Java/Python-to-Lean refinement, solver-query/source correspondence and independent
certificate replay are not established by this experiment. The full application
refinement status remains **BLOCKED**, not silently discharged by the test suite.

## Training Protocol

- Families: EGraph Transformer and a newly trained GAT comparator.
- Width/depth configurations: 64x2, 128x2, 256x4 and 512x4.
- Eight attention heads; learning rate 0.0003; FP32 and the existing Adam update.
- Each child: 24 training episodes per task across two tasks, 48 optimizer updates.
- Validation: two tasks, three episodes each, seeds 342 and 343.
- Final tests: three tasks, three episodes each, fresh seeds 401, 402 and 403.
- Horizon: four actions. Instance bank capacity: 100 per class.
- Serial GPU children, 10 GiB allocator cap, RTX 5080 with 16 GB VRAM.

Selection maximized validation repairs, then minimized parameter count, before
running final tests. Each family's selected model and its 64x2 control were tested.
The grid changes both width and depth and is not parameter-matched across families.
These are reused related fixtures, not a new untouched benchmark or full-corpus run.

## Results

Validation counts, in configuration order 64x2, 128x2, 256x4, 512x4:

- Transformer: **0, 0, 3, 6 out of 12**. Selected 512x4, 23,953,922 parameters.
- GAT: **3, 0, 0, 9 out of 12**. Selected 512x4, 5,559,298 parameters.

The frozen overall validation winner was GAT-512x4. Fresh-seed test results:

- Transformer-64x2: **9/27 (33.3%)**, per seed [0, 6, 3]; 463,810 parameters.
- Transformer-512x4: **6/27 (22.2%)**, per seed [0, 3, 3]; 23,953,922 parameters.
- GAT-64x2: **12/27 (44.4%)**, per seed [3, 6, 3]; 305,154 parameters.
- GAT-512x4: **6/27 (22.2%)**, per seed [0, 3, 3]; 5,559,298 parameters.
- Matched random control: **8/27 (29.6%)**.

The transformer did **not** outperform GAT in this bounded experiment. Both
validation-selected larger models performed worse on the final tests than their
small controls. GAT-64x2 is the best observed final-test result, not the model
selected by validation. The selection has not been rewritten after seeing tests.

Repeated random-control executions were checked for equal episode records and do
not count as extra independent trials. Episodes share evolving instance banks.
These small counts do not establish statistical superiority, and the present
evidence does not justify increasing model size or changing the default model.
The small number of training tasks and updates is a plausible limitation, not a
causally demonstrated explanation for the ranking reversal.

Completed **28 runs, 1,344 proof-gated optimizer updates, 1,752 episode executions,
zero aborts**, in **856.18 seconds (14.27 minutes)** excluding the final aggregate
hash pass. Maximum PyTorch reserved memory was **0.637 GiB** (652 MiB), below the
10 GiB cap. This is allocator memory, not total process/driver memory.

## Evidence And Integrity

- Frozen verification input root:
  `5265319a0deaeafa6420eb9a536553c6700908af31d450c85760763f1726d0a5`.
- Selection hash:
  `c195da8ee96e37fdb5f4f5c6e6a073cf7d71480a2500e8b7991d2bffd0bb3d12`.
- Comparison hash:
  `8ec3ba58a9a0648671430076109cffdbea8cbda342e1f7d332d05818bbe4d587`.
- Post-run audit: **395 output hashes**, **434 frozen inputs**, and **362 unchanged
  Java/library hashes** compared with the preceding wide-policy run.
- **2,181** actual model-driven transformer steps have matching structural receipts;
  **278** executable Lean graph checks were needed after exact-request cache reuse.
- No remaining experiment/repair-worker processes; protected empirical trees unchanged.

The temporary audit initially used `hashlib.file_digest`, unavailable in the pinned
Python 3.10 runtime. Replacing it with streaming SHA-256 allowed the complete audit
to pass. This changed only the temporary audit script, not frozen experiment inputs.

Adding an encoder changes the shared graph-contract hash. Historical checkpoint
contract mismatches fail closed; old checkpoints are not silently migrated.

- [Machine-readable comparison](rl-transformer-comparison.json)
- [Generated comparison summary](rl-transformer-comparison.md)
- [Frozen selection](rl-transformer-selection.json)
- [Verification report](rl-transformer-verification.json)
- [Output hashes](rl-transformer-output-hashes.json)
- Raw checkpoints, traces and manifests: `/tmp/acgn-rl-transformer-tuning-01` (2.0 GiB).
- Post-run audit script: `/tmp/audit_rl_transformer.py`.

## Reproduction

Use fresh output directories and the pinned CUDA environment:

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python \
  scripts/verify_rl_learning.py /tmp/acgn-rl-transformer-verification-rerun

bash scripts/run_rl_depth_tuning.sh \
  --manifest docs/rl-repair/fixtures/depth_tuning.json \
  --plan docs/rl-repair/transformer-tuning-grid.json \
  --encoders egraph_transformer gat \
  --seeds 342 343 --test-seeds 401 402 403 \
  --cuda-memory-gib 10 --episodes 24 --eval-episodes 3 \
  --output /tmp/acgn-rl-transformer-rerun --device cuda
```
