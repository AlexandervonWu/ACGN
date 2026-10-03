# Width 2048/4096 Comparison

The user narrowed the requested search to practical wider models on the local
16 GB GPU. This is a focused width comparison, not a Cartesian search over every
hyperparameter or a claim of a globally optimal architecture.

## Frozen Protocol

Compare MPNN, GCN, GAT and GIN at widths 64, 1024, 2048 and 4096, with two layers,
eight GAT heads, and learning rate 0.0003 throughout. The small control uses the
same depth/rate/head setting. Keep 12 training episodes per task, three evaluation
episodes per task, horizon 4, bank capacity 100, and all existing reward, action,
solver and proof-gate semantics. This isolates width within each family instead
of changing learning rate/depth at the same time.

Validation seeds: 242 and 243. Test seeds: 301, 302, 303. Rank by validation repairs
first and exact parameter count second. Remaining exact ties retain input order.
Both each family's selection and the overall validation winner are frozen before
testing. Test all family winners against their small controls without selecting
again from test results. These are reused fixture tasks with fresh seeds, not a
new independent benchmark. Do not claim corpus-level superiority.

## Memory Boundary

For this run, set an explicit **10 GiB PyTorch allocator limit**, below device
capacity, leaving space for the desktop, driver, libraries and other processes.
The default for older runs remains uncapped. Also require at least 1 GiB of
currently free device headroom beyond that cap before starting a child.

The preflight planning estimate is `24 * parameterCount + 1 GiB`: six FP32-sized
banks plus workspace allowance. It includes the current full initial-weight
audit copy and optimizer temporaries, but is **not a proof of peak memory** for
arbitrary graphs. Candidates exceeding this estimate's budget are rejected before
allocation. Width 8192 requires about 15.3 GiB by this estimate even for the
two-layer GCN/GAT, and is outside this run's budget. Width 16384 is further outside
it. They are not trained or assigned a repair score.

Actual allocator enforcement comes from PyTorch/CUDA, part of the declared TCB.
CUDA context or other processes' allocation is outside that per-process limit.
A caught CUDA OOM records a resource-limited, censored run and exits immediately;
it does not retry every remaining episode or count OOM as a semantic negative.
Workers are closed before exit. Any failed child blocks publication of a complete
sweep rather than silently dropping failures from averages.

Preflight incident: the first verification attempt stopped before its pilot at
PyTorch's allocator API, which requires an explicit device index rather than
the string `cuda`. Resolve indexless devices through `current_device()` and
regress this with a real allocator-limit set/get/allocation/restore check, not
only a mock. The failed evidence is retained at
`/tmp/acgn-rl-wide-check-01`; the corrected clean-build check uses a new output.

## Proof Before Implementation

`formal/ResourceBudget.lean` was compiled before this document and code. Its nine
theorems cover the integer admission predicate, nominal-storage consequence,
over-budget rejection, and maximum-repair/minimum-parameter selection. No theorem
equates the estimate with true CUDA usage. An executable 129-row matrix checks
48 budget cases and 81 score/size selection cases against Python. Real selections
invoke the Lean selector. Capacity accounting is extended to widths through
16384 on PyTorch's `meta` device; those counts do not allocate dense GPU weights.

The pre-existing full Java/Python refinement gaps remain open. Numerical kernels,
allocator enforcement, driver, runtime and solver remain explicit TCB. Learned
outputs still cannot certify semantic equivalences.

## Reproduction

```bash
bash scripts/run_rl_depth_tuning.sh \
  --manifest docs/rl-repair/fixtures/depth_tuning.json \
  --plan docs/rl-repair/wide-tuning-grid.json \
  --encoders mpnn gcn gat gin --seeds 242 243 --test-seeds 301 302 303 \
  --cuda-memory-gib 10 --episodes 12 --eval-episodes 3 \
  --output /tmp/acgn-rl-wide-tuning --device cuda
```

Use a fresh destination. The largest admitted configuration is MPNN-4096x2 at
369,524,738 parameters; its planning estimate is about 9.26 GiB. Reports retain
the preflight decisions, allocator telemetry, source hashes, raw episodes,
checkpoints, selection proof reference and every failure. Defaults and published
semantic/canonical experimental trees remain unchanged.
