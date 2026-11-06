# Larger Local Feedback Repair: Results

**Question-disjoint benchmark evaluation, following an explicitly authorized scaling diagnostic.**

The earlier eight-task gate remains failed; it is not retrospectively marked passed.
This reuses the earlier benchmark, whose aggregate outcomes were already known.
New configuration selection uses validation only, with the choice locked before
new test evaluation. No held-out teachers or gradients are used.

## Headline Result

Screened 4 configurations up to 28,244,999 parameters. The best validation score was 0/62.
Locked-model test repairs by seed: 17: 0/89, 29: 0/89, 43: 0/89.
Executable test episodes, after separating but not excluding recorded errors: 17: 61, 29: 61, 43: 61.
A tied configuration selected by parameter count is not evidence of superior repair ability.

## Data

- Selected: `{'evaluation': 96, 'train': 512, 'validation': 64}`.
- Eligible: `{'evaluation': 89, 'train': 474, 'validation': 62}`.
- Preparation: `{'DUPLICATE_AST_PAIR': 47, 'SOURCE_READY': 625}`.
- Question groups: `{'evaluation': 9, 'train': 39, 'validation': 8}`.
- Initial teacher coverage: `{'NOT_ADMITTED': 165, 'REPLAY_ADMITTED': 309}`.
- Admitted training trajectories: 309; decisions: 4397.
- Aggregation admission outcomes: `{'REPLAY_ADMITTED': 480}`.
- Aggregated decision kinds: `{'continuation': 6120}`.

Unsupported sources and failed episodes remain in the primary denominators.
Only AST-identical and duplicate AST pairs are excluded under the frozen rule.

Training-teacher failures (not model test outcomes):

- 124: `ReplayRejected: is.fivefivefive.ACGN.repair.RepairTask$UnsupportedInput: Explicit imports are not editable in repair slice v1`.
- 32: `ReplayRejected: is.fivefivefive.ACGN.repair.RepairTask$UnsupportedInput: CANONICAL_OBSERVATION_UNSUPPORTED:NODE:GENERICRELDECL`.
- 5: `ReplayRejected: is.fivefivefive.ACGN.repair.RepairTask$UnsupportedInput: CALL_TABLE_UNSUPPORTED`.
- 3: `ReplayRejected: java.lang.IllegalArgumentException: SOURCE_UNREALIZABLE:COMMIT:is.fivefivefive.ACGN.repair.RepairTask$UnsupportedInput: CANONICAL_OBSERVATION_UNSUPPORTED:NODE:GENERICRELDECL`.
- 1: `ReplayRejected: java.lang.IllegalArgumentException: SOURCE_UNREALIZABLE:COMMIT:Type error in /tmp/acgn-repair-virtual.als at line 16 column 13: This cannot be a legal relational join where left hand side is this/Teacher (type = {this/Person}) right hand side is this/Class (type = {this/Class}) `.

## Validation Screen

| Model | Parameters | Validation repairs | Episode errors | Training seconds | Peak CUDA MiB |
| --- | ---: | ---: | ---: | ---: | ---: |
| gin-256x4 | 6,303,749 | 0/62 | 29 | 743.0 | 301.8 |
| gin-512x6 | 28,244,999 | 0/62 | 29 | 847.3 | 870.4 |
| gat-256x4 | 6,828,033 | 0/62 | 30 | 791.6 | 374.5 |
| mlp-256x4 | 6,008,833 | 0/62 | 29 | 732.4 | 254.9 |

Episode errors include initial coverage refusals and later encoder/worker failures.
See the runtime incident record for the attention rollout that exceeded its history bound.

Locked configuration: **mlp-256x4**. Ties use smaller parameter count,
then fixed configuration order, never training loss or test results.

## Test Evaluation

| Seed | Learned repairs | Uniform | No-op | Learned errors | Learned rejected actions |
| --- | ---: | ---: | ---: | ---: | ---: |
| 17 | 0/89 | 0/89 | 0/89 | 28 | 309 |
| 29 | 0/89 | 0/89 | 0/89 | 28 | 265 |
| 43 | 0/89 | 0/89 | 0/89 | 28 | 55 |

There are 89 unique test tasks in 9 question groups, repeated across seeds.
Repeated seeds are not independent test tasks. The paired learned-minus-uniform
repair-rate difference is 0.000000; the question-cluster bootstrap
interval is [0.000000, 0.000000] (10,000 resamples).
A degenerate zero interval, if present, is not proof that the algorithms are equivalent.

## Training Roll-ins

These are the fixed training tasks used to acquire on-policy labels, not held-out
results. Scores are after 3,000 and 4,000 updates; the final 5,000-update
checkpoint is evaluated on validation or test, not on this roll-in set.

- gin-256x4, seed 17: 1/32, 3/32.
- gin-512x6, seed 17: 0/32, 1/32.
- gat-256x4, seed 17: 2/32, 5/32.
- mlp-256x4, seed 17: 1/32, 1/32.
- mlp-256x4, seed 29: 1/32, 1/32.
- mlp-256x4, seed 43: 0/32, 1/32.

## Post-Hoc Rollout Diagnostics

These descriptive counts use error-free worker episodes only; they do not
replace the primary denominator or prove why learning failed. STOP closes an
episode even if its query returns a counterexample; VALIDATE need not.

| Run | Executed | No committed edit | STOP with counterexample | Used all four queries | Decision budget exhausted |
| --- | ---: | ---: | ---: | ---: | ---: |
| gin-256x4-17/validation | 33 | 21 | 33 | 0 | 0 |
| gin-512x6-17/validation | 33 | 15 | 30 | 0 | 3 |
| gat-256x4-17/validation | 32 | 15 | 30 | 0 | 0 |
| mlp-256x4-17/validation | 33 | 13 | 21 | 0 | 12 |
| mlp-256x4-17/evaluation | 61 | 17 | 45 | 0 | 16 |
| mlp-256x4-29/evaluation | 61 | 5 | 58 | 0 | 3 |
| mlp-256x4-43/evaluation | 61 | 44 | 21 | 0 | 40 |

## Comparison With The Earlier Study

Identical ordered task identities, question splits and derived source hashes: **True**.
Earlier test repairs by seed: 17: 0/89, 29: 0/89, 43: 0/89.
The new run changes teacher construction, replay aggregation, query budget (Q=2 to Q=4),
model/update configuration and sampling. Differences are pipeline-level evidence,
not an isolated causal effect of model size or recovery supervision.

## Scope And Resources

Each fit uses 3,000 initial updates and two 1,000-update aggregation rounds,
batch eight, Q=4, and 256 decisions per episode. Up to 32 frozen training
tasks supply roll-ins, with at most two snapshots each per round. This is
supervised imitation plus on-policy aggregation, not policy-gradient RL.
On-policy data differ across models; this is not an isolated model-size ablation.

- Fits: 6; optimizer updates: 30,000; all finite/nonzero.
- Device: NVIDIA GeForce RTX 5080; PyTorch 2.14.1+cu130.
- Study time: 5188.8s; data collection: 297.0s, plus preflight.
- Training timings include roll-ins and offline expert calls, not just GPU updates.
- Final checkpoint reloads: 6/6.
- Lean model/fixture theorems compiled: 78; runtime check executions: 342.
- HEAD: `67cb5f3dfe226b15e2647fe6d18534fa03995cbc`; dirty worktree: `True`.
- Finite tests and model proofs are not universal Java/Python/Lean refinement.
- Qwen and roughly 500M scratch training were not run.

The local expert still emits singleton alternatives and may abort a useful partial
draft before constructing a continuation. Import/CALL/local-declaration coverage
limits are unchanged. Query-attempt counters now retain attempts whose worker
requests fail; numerical fitting does not establish effective counterexample use.

The first collection was stopped before training because a JVM shared-perfdata
startup warning prefixed valid JSON metadata. The current subprocesses disable
those counters, retain strict JSON parsing, and use a fresh complete preflight
and collection. No interrupted-run labels enter this study.

## Evidence And Reproduction

See [the frozen protocol](LOCAL-SCALING-STUDY.md) and [runtime correspondence](LOCAL-SCALING-RUNTIME.md). Curated JSON/log/source evidence
is in `results/local_scaling_20261004/`; its archive excludes binary checkpoints,
classes and JARs. Checkpoints remain in `/tmp/acgn-local-scale-study-20261004-v2`. Producer hashes, not HEAD
alone, identify the dirty-tree implementation. Original data and historical
experiment outputs were not changed.

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.local_preflight /tmp/local-scale-preflight-new
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.local_scale_data /tmp/local-scale-preflight-new /tmp/local-scale-data-new --workers 4
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_local_scaled /tmp/local-scale-data-new /tmp/local-scale-study-new --workers 4
```

Run each command only after the preceding command exits successfully.
