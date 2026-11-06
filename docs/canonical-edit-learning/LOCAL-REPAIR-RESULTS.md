# Local Feedback Repair: Training Results

**Bounded training-set diagnostic, not held-out performance.**

Contract: `local-feedback-repair-v1`. Device: `NVIDIA GeForce RTX 5080`; PyTorch `2.14.1+cu130`.

The fixed 8 training tasks supplied 94 initial teacher decisions.
All arms use four semantic queries, 256 decisions, 128-wide three-layer models,
1,000 initial updates and two 500-update aggregation rounds. Model and dataflow
changes are bundled; this is not an isolated causal comparison with old Q=2 results.

## Repairs By Round

| Model | Seed | Parameters | Initial | After round 1 | After round 2 | Final errors |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| gin | 17 | 1,541,252 | 5/8 | 6/8 | 6/8 | 0 |
| gcn | 17 | 1,541,249 | 4/8 | 5/8 | 5/8 | 0 |
| sage | 17 | 1,541,249 | 5/8 | 4/8 | 5/8 | 0 |
| gat | 17 | 1,639,553 | 2/8 | 4/8 | 5/8 | 0 |
| mlp | 17 | 1,479,809 | 0/8 | 0/8 | 1/8 | 0 |
| gin | 29 | 1,541,252 | 5/8 | 6/8 | 5/8 | 0 |
| gcn | 29 | 1,541,249 | 3/8 | 4/8 | 4/8 | 0 |
| sage | 29 | 1,541,249 | 3/8 | 6/8 | 4/8 | 0 |
| gat | 29 | 1,639,553 | 5/8 | 5/8 | 5/8 | 0 |
| mlp | 29 | 1,479,809 | 1/8 | 0/8 | 1/8 | 0 |
| gin | 43 | 1,541,252 | 3/8 | 6/8 | 5/8 | 0 |
| gcn | 43 | 1,541,249 | 3/8 | 5/8 | 6/8 | 0 |
| sage | 43 | 1,541,249 | 5/8 | 6/8 | 5/8 | 0 |
| gat | 43 | 1,639,553 | 1/8 | 4/8 | 6/8 | 0 |
| mlp | 43 | 1,479,809 | 0/8 | 0/8 | 0/8 | 0 |

Final-round totals across the repeated training tasks (not independent test samples):

- gin: 16/24 repairs; 5.33/8 mean per seed.
- gcn: 15/24 repairs; 5.00/8 mean per seed.
- sage: 14/24 repairs; 4.67/8 mean per seed.
- gat: 16/24 repairs; 5.33/8 mean per seed.
- mlp: 2/24 repairs; 0.67/8 mean per seed.

## Matched Controls

- uniform, seed 17: 0/8 repairs, 0 errors.
- noop, seed 17: 0/8 repairs, 0 errors.
- uniform, seed 29: 0/8 repairs, 0 errors.
- noop, seed 29: 0/8 repairs, 0 errors.
- uniform, seed 43: 0/8 repairs, 0 errors.
- noop, seed 43: 0/8 repairs, 0 errors.

## Final-Round Task Coverage

Counts across all model/seed arms; this diagnoses concentration of success,
not independent replications or a held-out success rate.

- `graphs:inv5` (`be563a3a9ebe9062107c`): 14/15.
- `socialMedia:inv7` (`841b47d7a6530bdcdc29`): 0/15.
- `trash_fol:inv1` (`e925b59446448a4c679a`): 12/15.
- `socialMedia:inv5` (`45e3b214d8e2c259bcdf`): 11/15.
- `socialMedia:inv1` (`880a7087b92b5ece2a43`): 12/15.
- `classroom_fol:inv11` (`763d065c3ac245b08ec5`): 2/15.
- `cv_v1:inv4` (`7b838a83e9b3d3f81c3b`): 2/15.
- `socialMedia:inv5` (`35612179cdee5ab833b1`): 10/15.

## Learning And Coverage

- Optimizer updates: 30,000; finite nonzero-gradient updates: 30,000.
- On-policy label admission outcomes: `{'REPLAY_ADMITTED': 960}`.
- Admitted decision classes: `{'continuation': 11231}`.
- Supervised rejected/stale states: 70; after-commit states: 960.
- Peak PyTorch allocated GPU memory: 135.2 MiB (excludes desktop/process-wide GPU usage).
- Study time: 2767.6 seconds; excludes preflight/collection.
- Final checkpoints strictly reloaded with finite tensors: 15/15.
- Gate status: `EIGHT_TASK_GATE_NOT_PASSED`.

These are the same eight tasks across seeds, not 24 independent examples. The
initial source-realized teachers and all admitted continuations are freshly
replayed. Actual on-policy data differ across models, despite equal budgets.
The expert currently aborts an open draft before planning a continuation;
it does not yet optimally continue an already-useful partial draft. Recovery
labels are separated from semantic success. Initial seed trajectories all
replace the root while reusing operands; non-root support is regression-tested
but that is not evidence of broad local-edit diversity in this eight-task set.

Training uses supervised joint-action imitation with on-policy data aggregation,
not reward-based policy gradients. Nonzero gradients are not a semantic-repair
proof or evidence that the model learned an effective counterexample strategy.

Canonical-observation coverage refusals are not covered by the syntax/type-only
retry cache. See the separately recorded repeated-COMMIT incident in the runtime
document, which is tied to its named rollout. Rejection keeps the committed
source unchanged; the model must recover or exhaust its budget. No worker error
does not mean every proposed candidate was representable or successful.

## Trust And Reproduction

68 Lean model/fixture theorems and 332 Java/Python check executions passed
before training. This is bounded correspondence evidence, not a universal
refinement proof. See [runtime details](LOCAL-REPAIR-RUNTIME.md) and
[protocol](LOCAL-REPAIR-STUDY.md). Input/output hashes and complete JSON/log
evidence are retained in `results/local_repair_20261004/`; model checkpoints
remain in `/tmp/acgn-local-study-20261004-v1`. Source HEAD is `67cb5f3dfe226b15e2647fe6d18534fa03995cbc` with a dirty worktree;
the input hashes identify the implementation. Historical experiments and the
original corpus were not changed. The archive excludes binary checkpoints/classes.

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.local_preflight /tmp/local-preflight-new
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_local /tmp/local-preflight-new /tmp/local-study-new
```

Qwen, roughly 500M scratch training and held-out evaluation have not been run
under this refinement. They remain behind the full 1/8/64 learnability gates.
