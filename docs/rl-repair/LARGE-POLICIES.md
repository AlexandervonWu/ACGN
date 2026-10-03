# Larger Structured Graph Policies

## Scope and Protocol

The earlier policies contain only about 0.3--0.6 million parameters. The runner
processes one small graph/rollout at a time and waits on Java/Alloy between
policy calls. Low VRAM use is therefore not evidence of an imposed memory cap,
nor proof that model capacity is the learning bottleneck. Increasing width uses
quadratically more learned matrix parameters but does not increase training data
or solver throughput. This change keeps single-rollout, proof-gated on-policy
updates; it does not introduce stale rollouts, batching, AMP, or altered rewards.

The large grid compares a width-64, four-layer control against widths 256/512/1024
at depths 4/6/6 and learning rates 0.001/0.0003/0.0001. GAT uses eight heads for
the larger models. The first grid item remains the tie-preferred comparator.
The tuning width bound increases from 256 to 1024; depth remains bounded at 8.
The previous grid and global model defaults remain unchanged.

A bounded GCN/GAT comparison uses two validation seeds (142,143), three fresh
test seeds (201,202,203), 12 training episodes per task, three evaluation episodes
per task, horizon 4 and instance capacity 100. Configurations are selected solely
on validation counts by the existing executable Lean selector. The fixture test
tasks were observed in the previous experiment: this is a fresh-seed retest on
reused tasks, **not** a newly untouched benchmark. All four encoder families
also receive width-1024 CUDA update/checkpoint tests. No claim of larger-model
superiority is a passing condition.

## Proof Before Code

`formal/PolicyCapacity.lean` is independently compiled first. It models the
current shared modules as `5*w*w + 4182*w + 2` scalar parameters and each layer as:

- MPNN: `8*w*w + 9*w`.
- GCN: `2*w*w + 2*w`.
- GAT: `2*w*w + 5*w` (fixed total width, independent of valid head count).
- GIN: `5*w*w + 5*w + 1`.

Five theorems prove the shared-parameter contribution, exact per-layer increment,
depth monotonicity, the nominal bytes for four FP32-sized tensor banks, and
conditional invariant preservation through a list of distinct layers. The last
proof allows different learned parameters per layer; numerical correctness and
the required single-layer invariant are not inferred from tensor size.

A 140-row matrix checks these counts against actual PyTorch module construction
on the `meta` device for every family, seven widths and five depths. Production
runs also check their actual parameter count against the accounting formula.
This is bounded implementation correspondence, not a complete Python refinement.
Actual CUDA tests at width 1024 exercise finite per-layer gradients, proof-gated
updates and exact checkpoint reloads. Lean does not prove GPU allocation or
training convergence. Whole-application refinement remains open.

## Memory Accounting

Reports distinguish:

- Exact scalar parameter count and actual parameter-storage bytes.
- Nominal parameters + gradients + two Adam-moment banks, assuming full FP32
  tensors; this is accounting, **not a peak-memory bound**.
- Peak/current CUDA **allocated** tensor memory.
- Peak/current CUDA **reserved** allocator memory.
- Device total/free memory at start and finish (includes other processes).

Allocated/reserved values do not include all CUDA driver/context/library overhead
reported by system tools. Device-free snapshots are not per-process peaks.
Retained rollout activations, optimizer temporaries, initial-weight audit copies,
and workspaces can exceed the nominal tensor-bank estimate. This experiment does
not reserve dummy tensors to inflate utilization or set a device memory fraction.
Large source graphs can require much more memory than these fixtures; width 1024
is not a guarantee of fitting every supported graph.

## Reproduction

```bash
bash scripts/run_rl_depth_tuning.sh \
  --manifest docs/rl-repair/fixtures/depth_tuning.json \
  --plan docs/rl-repair/large-tuning-grid.json \
  --encoders gcn gat --seeds 142 143 --test-seeds 201 202 203 \
  --output /tmp/acgn-rl-large-tuning \
  --episodes 12 --eval-episodes 3 --device cuda
```

At most 28 serial child runs; matched training budgets, not matched parameter
counts. Use a fresh destination. MPNN and GIN can be included explicitly through
`--encoders`; their larger six-layer policies have substantially more parameters.
Keep the failed-run evidence and fail-closed admission behavior on resource or
numerical errors. Publication results and certificate/metric semantics are not
modified.
