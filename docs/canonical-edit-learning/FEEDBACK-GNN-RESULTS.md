# GNN Gradient And Repair Comparison

Date: 2026-10-03. **There is now a repeatable training-set repair gain, not just
nonzero gradients. GIN is the strongest of the six tested arms.** No arm passes
the eight-task gate; these results do not establish held-out generalization.

## Experiment

The [preregistered bounded protocol](FEEDBACK-GNN-STUDY.md) retains
`feedback-intent-path-v1` and the unchanged Java/Alloy executor. Each policy sees
only the faulty predicate's public tables, its own edits, and actually returned
counterexamples. Teacher actions are loss targets, never observation features.

All six arms train from scratch on the same first eight training tasks, comprising
107 teacher decisions and 210 conditional heads. Seeds are 17, 29 and 43. Each
run has 1,000 AdamW updates, eight sampled decisions per update, width 128 and
three layers. Sampling schedule hashes match across all arms within each seed.
The final checkpoint, not the best intermediate checkpoint, is the primary result.

Each free-running episode has at most 256 decisions and two explicit feedback
queries. Only the unchanged executor's final bounded semantic acceptance counts
as repair. Prediction of STOP, imitation accuracy, and gradients do not count.

## Final Repairs

Numbers below are repairs out of eight for seeds 17, 29 and 43 respectively:

- **GIN:** **3, 5, 4**; **12/24 episodes (50.0%)**; 1,541,252 parameters.
- **GraphSAGE:** 2, 4, 2; 8/24 (33.3%); 1,541,249 parameters.
- **Edge-aware attention:** 3, 2, 2; 7/24 (29.2%); 1,639,553 parameters.
- **GCN:** 1, 4, 1; 6/24 (25.0%); 1,541,249 parameters.
- **No-message MLP:** 1, 1, 0; 2/24 (8.3%); 1,479,809 parameters.
- **Original relational GNN:** 0, 1, 0; 1/24 (4.2%); 482,049 parameters.
- **Uniform masked actions:** 0, 0, 0; 0/24. No-op also gives 0/24.

The 24 episodes repeat the **same eight training tasks across three seeds**;
they are not 24 distinct held-out problems. GIN beats the matched random control
in each seed, but this is not evidence of stable corpus-wide superiority.
Best single-run repair is 5/8 for GIN seed 29. No arm achieves 8/8 in any seed.
The original 1/8/64 gate report remains historical evidence, not overwritten.

## What Changed

The new arms share normalized residual updates, one readout channel per public
table kind, explicit public root/draft/hole/history/state anchors, and a bilinear
query-candidate scorer. This avoids direct dilution of one table by the number
of rows in unrelated tables. It replaces the original global mean and tanh
scorer without changing observations, masks, types or semantic acceptance.

GCN uses symmetric degree-normalized messages; GraphSAGE uses a neighbor mean;
GIN uses a sum and learned self coefficient. The `gat` arm is multihead,
edge-aware **dot-product graph attention**, not an exact replica of the original
additive-attention GAT architecture. All are typed-incidence-graph variants with
the same conditional semantic pointer interface. MLP disables graph messages.

The shared new decoder/readout and increased capacity confound a direct causal
comparison against the original model. The much closer-size MLP comparison is
evidence that messages help on this diagnostic, not a parameter-matched proof
or an ablation isolating every architectural component.

## Actual Gradients

All **18,000 optimizer updates** have finite, nonzero pre-clipping gradient norm.
The original model also had working backpropagation: its poor repair score was
not caused by a completely disconnected loss. Across the logged checkpoints,
gradient norms range from 0.178662 to 62.162556; the smallest logged scalar-encoder
parameter-step norm is 0.012437. Module norms and actual parameter deltas are saved.

GIN's mean full-teacher loss falls from **2.136543 to 0.221454**; final joint
decision accuracy averages **83.18%**, versus **40.50%** for the original model.
Its scalar-encoder total update norms are 7.9093, 7.8945 and 8.0066. Gradient
clipping occurs on 902, 891 and 917 of its 1,000 updates, so substantial clipping
and imperfect conditioning remain visible rather than hidden.

These are **supervised imitation gradients**, not reward-based policy-gradient
RL. Finite gradients and decreasing loss alone do not demonstrate repair.

## Remaining Failures

GIN repairs the `graphs:inv5` and `socialMedia:inv1` examples in all three seeds.
It repairs `trash_fol:inv1` in two seeds, and both selected `socialMedia:inv5`
examples in two seeds. Successful paths include 6-, 8-, 10- and 13-decision
constructions with two queries, rather than only single-token substitutions.

`socialMedia:inv7`, `classroom_fol:inv11` and `cv_v1:inv4` never succeed under GIN.
Some generated terms are accepted structurally but receive a counterexample;
others loop on rejected commits or incomplete drafts until the decision budget
is exhausted. Final GIN episodes contain 495, 464 and 745 rejected actions by
seed. There are **zero worker/encoding/deadline exceptions** in all 288 learned
and 48 control episodes; structurally valid action records can still propose
ill-typed terms, correctly rejected at commit.

The evidence supports imperfect teacher-state fitting plus error accumulation
outside the teacher path. It does not establish that either is the sole cause.
On-policy recovery examples and conditioning/step-size ablations are appropriate
next experiments. No extra rewrite, oracle feature, acceptance relaxation,
larger-model run or hidden retry was introduced to improve these scores.

## Verification And Resources

- **69 Lean boundary-model theorems compile:** 27 IntentRepair, 21 FeedbackSession,
  10 FeedbackLearning and 11 FeedbackGNN. The new file has no `sorry`, declared
  axiom or unsafe proof. Logs expose standard foundational dependencies.
- **262 runtime checks pass:** 132 executor, 64 environment, 38 prior learning,
  14 replay, seven existing learning-boundary and seven new GNN tests. The new
  tests cover all variants through subtests, including float64 central finite
  differences of encoder gradients, nonzero encoder/pointer/context gradients,
  row/edge transport, channel isolation and private-oracle independence.
- Source/query coverage remains **95/104**, teacher replay **62/64**. The nine
  unsupported local-binder observations and two unavailable teachers remain
  explicit. All eight selected tasks have validated teachers.
- Preflight: **152.138 seconds**. Training plus all evaluations/controls:
  **764.767 seconds (12.75 minutes)** on RTX 5080, PyTorch 2.14.1+cu130.
- Maximum PyTorch allocation **140.145 MiB**, reservation **178 MiB**. These
  exclude CUDA context/desktop allocations; no OOM occurred.
- Rechecked **500 source/input hashes**, **1,283 preflight output hashes** and
  **422 study output hashes**, with zero mismatches; all paired schedules match.

Lean proves the specified algebra/dataflow models, not full Python/Java
refinement, floating-point/autodiff correctness or learning performance.
PyTorch/CUDA and the existing Java/Alloy/Lean/OS trust boundaries remain explicit.
No Java production code or protected empirical-result tree changed in this study.

## Evidence And Reproduction

The [machine report](results/feedback_gnn_20261003/report.json), per-arm gradient
traces, all checkpoint/control rollouts, schedules, preflight checks and full
run hash inventories are retained in `results/feedback_gnn_20261003/`.
Binary checkpoints and verbose worker logs are intentionally not copied into
the repository. The full hash inventories include those omitted files; they
describe the complete external runs, not a standalone checksum list of the
curated subset.

Full runs remain at `/tmp/acgn-feedback-gnn-preflight-20261003` and
`/tmp/acgn-feedback-gnn-study-20261003`. Checkpoints use
`<arm>-<seed>/policy.pt`; GIN seed 29 is the highest-scoring individual run.
The [runner README](../../experiments/feedback_repair/README.md) gives fresh-run
commands. Larger models and held-out learned evaluation remain unrun.
