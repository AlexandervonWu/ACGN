# Expanded Feedback GNN Study Results

Date: 2026-10-03. Contract: `feedback-intent-path-v1`.

**Completed, with a negative repair result.** Five configurations up to 24.54M
parameters trained on 313 validated paths. All five achieved 0/62 validation
repairs. The selected smallest GIN achieved 0/89 held-out repairs for each of
three seeds, as did the matched random and no-op controls. All 21,000 optimizer
updates had finite, nonzero gradient norms. This demonstrates optimization and
teacher-path fitting, not a held-out repair advantage.

## Scope And Data

This is the requested larger-data, larger-model follow-up to the
[eight-task diagnostic](FEEDBACK-GNN-RESULTS.md), not a claim that its failed
learnability gates were passed. The [protocol](FEEDBACK-SCALING-STUDY.md) was
frozen before model evaluation. Source selection preceded parsing, teacher
construction and teacher outcomes. Question groups use the existing `corpus-v1`
split; there is no question overlap across train, validation and evaluation.

- Selected: 672 source files, with quotas 512 train, 64 validation, 96 evaluation.
- Prepared: 672/672 source copies; 47 duplicate AST pairs within questions removed.
- Eligible: 625 tasks, comprising 474 train, 62 validation and 89 evaluation.
- Question groups: 39 train, eight validation and nine evaluation.
- Training labels: 313 freshly replay-validated paths and 4,677 decisions.
- Unavailable training paths: 161, retained in coverage rather than replaced.
  These are 124 explicit-import exclusions, 32 unsupported `GENERICRELDECL`
  observations and five unsupported call-table cases.

Eligible tasks and admitted teachers by problem:

| Problem | Train | Admitted teachers | Validation | Evaluation |
| --- | ---: | ---: | ---: | ---: |
| classroom_fol | 83 | 61 | 12 | 32 |
| graphs | 55 | 52 | 3 | 0 |
| socialMedia | 162 | 152 | 18 | 32 |
| coursesNew | 124 | 0 | 23 | 14 |
| cv_v1 | 33 | 33 | 0 | 0 |
| trash_fol | 17 | 15 | 6 | 11 |

Thus the effective supervised corpus is a supported subset of the attempted
training corpus, not all 474 tasks. In particular, `coursesNew` contributes no
admitted teachers. Held-out unsupported cases remain in the primary denominator.
The eight-task training-set results and these question-held-out results are not
directly comparable repair-rate estimates.

## Screening Results

Every arm used seed 17, 3,000 updates, effective batch 16 decisions and the same
hashed task/decision sampling schedule. The reported loss and exact joint-action
accuracy use a fixed 128-decision **training probe**, sampled with replacement;
they are neither full-training-set accuracy nor free-running repair success.

| Model | Parameters | Final probe loss | Exact probe action | Validation repairs | Training seconds | Peak allocated CUDA MiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| GIN 128x3 | 1,541,252 | 0.0770 | 95.31% | 0/62 | 215.9 | 126.1 |
| GIN 256x4 | 6,303,749 | 0.0530 | 97.66% | 0/62 | 251.3 | 384.9 |
| GIN 512x4 | 24,535,045 | 0.0812 | 95.31% | 0/62 | 330.9 | 794.5 |
| GraphSAGE 256x4 | 6,303,745 | 0.0920 | 93.75% | 0/62 | 249.2 | 381.0 |
| No-message MLP 256x4 | 6,008,833 | 0.4175 | 75.78% | 0/62 | 207.8 | 341.2 |

All arms had the same 29 validation coverage failures: 23 explicit imports and
six `GENERICRELDECL` observations. The other 33 cases executed without worker
errors; none repaired. The supported-only supplemental rate is therefore 0/33,
not an alternative primary denominator.

Validation repair counts tied, so the preregistered smaller-model tie-break
selected **GIN 128x3**, not the model with the smallest probe loss. The selection
was written before test evaluation. Its hash is
`52045403c9e2c66ed1652ccbd6e1122f9b3afae10195d9dfe1fea62699b6cc99`.

## Held-Out Evaluation

Seeds 29 and 43 were trained from fresh weights with the locked configuration.
No checkpoint, configuration or hyperparameter was selected using test results.

| Seed | Learned repairs | Uniform repairs | No-op repairs | Learned budget-exhausted episodes | Learned rejected commits |
| --- | ---: | ---: | ---: | ---: | ---: |
| 17 | 0/89 | 0/89 | 0/89 | 31 | 7,551 |
| 29 | 0/89 | 0/89 | 0/89 | 32 | 7,399 |
| 43 | 0/89 | 0/89 | 0/89 | 34 | 8,281 |

These are **89 unique tasks in nine questions**, repeated across seeds, not 267
independent test cases. Every method/seed has the same 28 initial coverage
failures: 14 imports and 14 `GENERICRELDECL` observations. The other 61 tasks
execute; all learned and control supported-only repair rates are 0/61. No
deadline, nonfinite-training or out-of-memory failure was recorded in this run.

The paired learned-minus-uniform rate is 0. The 10,000-resample question-cluster
bootstrap interval is [0, 0] because every observed paired difference is zero.
This degenerate empirical interval is **not** proof of equal algorithms or a
population-wide zero effect. There is no demonstrated advantage on this sample.

## Interpretation And Next Stage

1. **The optimization signal is real.** All 21,000 updates had finite, nonzero
   norms; 19,698 were clipped, and encoder parameters changed in every fit.
   Graph models fit teacher actions substantially better than the no-message
   control. This does not establish successful complete paths on training tasks.
2. **Scaling did not establish transfer.** The larger models still fail every
   validation task; the selected model fails the held-out test across three
   seeds. The experiment jointly changes data volume, optimizer settings and
   update budget relative to the earlier eight-task diagnostic, so it does not
   isolate a causal effect of data size alone.
3. **Recovery is missing from the demonstrated teacher coverage.** The 4,677
   supervised observations comprise 4,051 READY, 313 APPLIED and 313
   COUNTEREXAMPLE states. There are no REJECTED/STALE observations, and no
   ABORT_DRAFT labels. Yet the learned test runs contain 23,231 rejected commits
   and 97 budget-exhausted episodes. This is consistent with exposure to states
   absent from teacher training and ineffective recovery, rather than absent
   gradients. It is not a proof that this explains every failure.
4. **Representation limits are independent of model capacity.** Scaling weights
   cannot admit unsupported imports, local declaration forms or call tables.
   These failures remain visible and do not become successful model examples.

The next Qwen/local-Transformer comparison can reuse this frozen task selection,
causal teacher packets, graph tables, action language and executor. Their input
adapters and training consumers still need migration; neither was trained here.
In particular, do not feed entire derived Alloy modules, private oracle bodies,
unused module inventory or future teacher feedback into those models. Any later
recovery-data extension must obtain new feedback through actual candidate runs,
retain the question split and get its own preregistered experiment. It must not
silently relabel this failed held-out comparison or the earlier failed gates.

## Resources

Hardware/software: RTX 5080, PyTorch `2.14.1+cu130`, Java 17, Lean 4.33.0;
two PyTorch CPU threads and at most four concurrent Java workers. Seven fits
total 1,702.9 training seconds (28.4 minutes); training plus validation/testing
and controls took 2,243.7 seconds (37.4 minutes). Fresh preflight and collection
bring the measured completed pipeline to 2,692.7 seconds (44.9 minutes), excluding
the superseded attempt and post-run packaging.

Largest measured training CUDA allocation: 794.5 MiB; largest reservation:
846.0 MiB. These are PyTorch training counters, not the desktop-inclusive device
total or evaluation peaks. The Python process high-water RSS was 3,095,584 KiB
(about 2.95 GiB), cumulative across arms and excluding JVM worker memory.

## Verification And Trust

The fresh preflight compiled 79 Lean model theorems and passed 271 runtime
checks: 132 feedback-executor, 64 environment, 38 existing learning, 14 causal
replay, seven learning-boundary, seven GNN and nine scaling checks. Its expected
exit code is 2 (`BOUNDED_LEARNING_PREFLIGHT`), not an exception. Five proof logs
include printed axiom dependencies. No `sorry`, newly declared `axiom` or
`unsafe` was introduced.

The ten new `FeedbackScaling.lean` theorems cover model-level split/admission,
quota and denominator behavior, validation-only selection, parameter-count tie
breaking and conditional cache transparency. The
[correspondence ledger](INTENT-PATH-OBLIGATIONS.md#scaling-correspondence)
names implementation sites and regression checks. These are not universal
Java/Python refinement proofs or proofs of numerical learning. PyTorch, CUDA,
Lean, Java, the parser and bounded Alloy solving retain their stated trust roles.

All model inputs use faulty-predicate-derived public tables and feedback returned
after explicit queries. Private task paths, oracle identities, labels, teacher
future states and ground-truth graphs do not enter policy inputs. Offline labels
exist only for training tasks. The controller permits two explicit queries and
256 decisions, with 30-second worker-response and 120-second episode deadlines.
Success requires the unchanged executor's feasible-context and two-direction
bounded Alloy acceptance, not a predicted STOP or low imitation loss.

## Performance Incident

The first scaling attempt was interrupted before validation or test evaluation.
Its eager teacher cache encoded an entire trajectory when one decision was
requested, and estimated raw-record memory from pretty-printed JSON bytes.
That caused avoidable encoding/eviction work: its first 100 updates took 49.6
seconds, and 200 updates took 103.1 seconds, with low GPU utilization.

The repair added a Lean cache-transparency model, documented the invariant, and
tested cached/cold graph tensors, addresses, labels and query counts using an
actual replay. Encoding is now lazy per task/decision, with raw storage estimated
from compact JSON. A separate 100-batch data-only probe took 5.55 seconds; this
is not a full-training benchmark. The final run restarted with fresh weights,
fresh preflight, recollected teachers and fresh hash manifests. Its first GIN
100 updates took 12.0 seconds. The interrupted attempt is not a result or a
checkpoint-selection candidate.

The superseded collection also had one malformed teacher JSON response for
`coursesNew/both/QsnTfu6CTzdTbckis_inv1.als`; its worker log reports the existing
explicit-import exclusion. No labels were admitted. The final collection records
that task as `NO_ADMITTED_PATH` and has no `TEACHER_UNAVAILABLE` entries. This
does not claim the intermittent response-format issue has been repaired.

## Evidence

The [curated evidence](results/feedback_scaling_20261003/README.md) records source
selection, split assignments, teacher coverage, proofs, tests and manifests.
The checked source HEAD is `67cb5f3dfe226b15e2647fe6d18534fa03995cbc` with a dirty
worktree; the input hashes, not HEAD alone, identify the checked implementation.
Full generated classes, teacher packets, worker logs and checkpoints remain in
the three `/tmp/acgn-feedback-scale-*-20261003-v2` working directories. Curated
evidence additionally archives all 672 derived sources, 313 teacher trajectories,
teacher coverage and seven sampling schedules; it retains every rollout, report,
training trace, proof/regression log and full original output manifest.

The [post-run audit](results/feedback_scaling_20261003/audit.json) verified 1,178
input, 1,286 preflight-output, 2,452 dataset-output and 1,157 study-output hashes.
It checked paired schedules, selection identity, question separation, training-only
teachers, held-out denominators, query/decision budgets and archive content hashes.
The original corpus, `distance_results/`, `alloy4fun-augmented/`,
`egraph_ablation/` and `capability_benchmark/` have no tracked diff.

Reproduction commands are in the
[runner README](../../experiments/feedback_repair/README.md#expanded-dataset-and-model-screening).
The original source corpus and historical publication result trees are not
inputs to be overwritten. The LLM and local Transformer consumers are separate
next stages; this study does not train them.
