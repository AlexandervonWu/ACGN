# Local Repair: Claims, Proof Process And Implementation Obligations

Version: `local-feedback-repair-v1`, 2026-10-03.
Companion: [specification](LOCAL-REPAIR-SPECIFICATION.md).

This ledger distinguishes **MODEL-PROVED**, **MODEL-EXAMPLE-CHECKED**, and
**RUNTIME-OPEN**. Compilation of a Lean abstraction is not universal Java/Python
refinement or whole-artifact verification. No historical open obligation is
closed merely by adding this model. No learning-effectiveness claim is made.

## Proof Process And Trust

The new [model](formal/LocalRepair.lean) was developed and compiled before the
natural-language specification. The [separate concrete checks](formal/LocalRepairChecks.lean)
instantiate positive and negative cases, including a stale semantic receipt
after an admitted commit. Both use Lean 4.33.0 with only `import Lean` and the
local model; no external theory was consulted or imported. Proofs use
definitions, induction, rewriting, simplification, arithmetic tactics and
kernel-checked decidable propositions. Their printed dependencies are limited
to `propext` and `Quot.sound`; no `sorry`, declared axiom or unsafe/native shortcut
is used. Initial fixture reduction failures were repaired using explicit
model lemmas and simplification, not bypassed with executable proof oracles.

The [reproduction script](formal/check_local_repair.py) rejects incomplete theorem
logs, unexpected dependencies, proof placeholders and nonzero compiler exits.
It compiles model then checks in two fresh temporary directories. The retained
[proof-check report](results/local_repair_formal_20261003/report.json) binds source
hashes and compiler identity to logs. This is an ordinary proof-build report,
not a registered whole-artifact closure certificate. The script itself, host,
Lean executable/kernel and its standard foundations remain trusted components.

## Model Claims

All 42 declarations below are **MODEL-PROVED**. The listed limits are part of
each claim, not qualifications to be removed in later reporting.

### LR-P01: Local Occurrence Frame (5)

`plug_size`, `repair_size_delta`, `unchanged_prefix`, `unchanged_suffix`,
`equal_occurrences_are_not_global_edits`.

Process: induct on the single-hole context; use list append/take/drop identities
and natural-number arithmetic. Replacing one occurrence preserves its frame and
has the stated additive size change. The `Tree` is an abstract operator/leaf
tree, not Alloy semantics, a source-span parser or the certified e-graph. It
does not prove implementation span selection, exact typing or global ID stability.

### LR-P02: Exact Stable-Failure Cache (4)

`stable_failure_blocks_identical_retry`, `blocked_retry_does_not_request_check`,
`different_attempt_remains_permitted`, `transient_failure_not_cached`.

Process: reduce exact list membership and the checker guard. A recorded stable
key prevents that identical checker application; an unseen distinct key remains
permitted. Transient outcomes leave the cache untouched. The caller must prove
that classification is deterministic under the complete key. The model uses
exact identities, not hash collision resistance or authority from numeric IDs.

### LR-P03: Semantic Acceptance Gates (3)

`acceptance_needs_all_checks`, `unknown_cannot_accept`, `infeasible_cannot_accept`.

Process: simplify the conjunction defining acceptance. Valid source, feasible
context and two UNSAT results are necessary. The model does not produce those
results or authenticate a Boolean flag; the runtime checker must do so.

### LR-P04: Atomic Structural Commit (5)

`unchecked_commit_is_unchanged`, `admitted_commit_has_checked_origin`,
`admitted_commit_is_atomic`, `commit_adds_no_acceptance_or_feedback`,
`no_fuel_no_commit`.

Process: case-split the commit guard and project the record update. Admission
requires a checked, permitted key matching identity, revision and complete draft;
success changes source/draft/revision atomically and consumes one decision.
It creates no semantic receipt. A denied commit is unchanged; the controller
dispatches the separate charged rejection transition for an attempted failure.
Connecting the completed draft to charged primitive construction remains open.

### LR-P05: Rejection And Recovery (5)

`rejection_preserves_committed`, `rejection_has_no_semantic_feedback`,
`rejection_spends_decision`, `abort_clears_draft`,
`abort_preserves_source_and_failure_cache`.

Process: simplify guarded record updates. Rejection preserves committed source
and semantic feedback; active rejection consumes a decision. Abort clears a
draft without erasing source or the retry cache. This proves available recovery
transitions, not that a trained policy will select them or repair the predicate.

### LR-P06: Bound, Budgeted Queries (6)

`query_spends_both_budgets`, `query_appends_only_its_receipt`,
`exhausted_queries_cannot_succeed`, `mismatched_receipt_cannot_succeed`,
`successful_query_is_source_bound`, `stop_is_not_acceptance`.

Process: extract guard conjunctions, use subtraction under positive budgets,
and inspect query record updates. Queries bind identity/revision/candidate;
STOP is not acceptance. Receipts are assumed authenticated before this function.
Authentication, solver invocation and arbitrary runtime exception handling are
not proved by a record field or these lemmas.

### LR-P07: Charged Trace Bound (2)

`trace_conserves_fuel`, `trace_is_bounded`.

Process: induction on `FuelTrace`. Charged transitions cannot outnumber initial
fuel. Every runtime primitive must refine a charged transition; the theorem
does not bound an uninterruptible solver call, GPU memory or wall-clock time.

### LR-P08: Feedback And Scoped Meaning (4)

`counterexample_excludes_candidate`,
`feedback_extension_cannot_restore_eliminated_candidate`,
`fixed_target_stays_compatible`, `two_directions_establish_scoped_agreement`.

Process: list membership, contradiction from a distinguishing labelled world,
and exhaustive Boolean cases for both implications. Meanings are functions on
an abstract world type. Authentic labels and correctly established implication
premises are assumptions. No finite-world bank is treated as full equivalence;
the agreement theorem is restricted to its explicit scope predicate.

### LR-P09: Public Input Projection (2)

`private_goal_and_future_hidden`, `fixed_policy_noninterference`.

Process: record projection and equality congruence. With the same public state,
private annotations/future receipts cannot influence this abstract observation
or a function of it. Actual graph tables, local diagnostics, query masks and
randomized PyTorch consumers need independent runtime correspondence checks.

### LR-P10: Training Admission And Joint Alternatives (6)

`heldout_has_no_training_labels`, `unreplayed_label_not_admitted`,
`unbound_rollin_not_admitted`, `recovery_label_is_not_semantic_success`,
`fieldwise_label_mixing_is_unsound`, `expert_search_bound`.

Process: simplify the training admission predicate, evaluate a concrete pair
of incompatible joint labels, and bound list `take`. No held-out, unreplayed or
unbound label is admitted. Recovery is not semantic success. The evidence flags
must be computed by real replay, not set by a teacher claim. The proposal bound
counts checked entries; it proves neither search completeness nor termination
of each entry's checker. The proposed loss and optimization are not Lean-proved.

## Concrete Model Regressions

The 20 declarations in `LocalRepairChecks.lean` are **MODEL-EXAMPLE-CHECKED**:

```text
stable_retry_is_blocked                  changed_candidate_is_allowed
transient_retry_is_allowed               checked_draft_commits
stale_commit_fails                       wrong_draft_commit_fails
old_success_cannot_certify_new_revision  rejected_source_is_unchanged
abort_does_not_forget_failure            successful_receipt_is_inhabited
wrong_revision_fails                    wrong_candidate_fails
wrong_context_fails                     unknown_fails
empty_query_budget_fails                active_draft_fails
recovery_is_admitted_but_not_semantic_success
both_heldout_splits_fail                 unbound_snapshot_fails
occurrence_edit_retains_equal_sibling
```

These are executable-model proof fixtures, not tests of actual Alloy source.
They supplement, rather than substitute for, the general theorems.

## Runtime Correspondence And Next Implementation

All entries below are **RUNTIME-OPEN for this refinement**. Existing runtime
checks and earlier formal models remain useful evidence; they are not assumed
to establish these newly proposed behavior/data-generation requirements.

### LR-R01: Occurrence And Reuse

Sites: `FeedbackSourceGraph`, `FeedbackDraft`, `RepairEnvironment`,
`FeedbackRepairSession.commit`. Implement/verify source-backed local teacher
plans and COPY transport without changing all occurrences of an e-class. Check
type DAG, binder ownership/imports, disjointness, temporal phases and CALL barriers.
Test unchanged source context and complete pointer refresh after actual commits.
Do not change metric charges or treat metric explanations as executable scripts.

### LR-R02: Retry Suppression And Diagnostics

Site: `FeedbackRepairSession`. Add complete-key deterministic local-failure
memoization; retain it across abort. Current session has no such suppression.
Expose only sanitized source-derived diagnostic enums/pointers, not private
`lastFailure` text. Replay the recorded repeated-COMMIT incident, test changed
candidate/context invalidation, resource-failure retry and recovery availability.
Ensure hash equality alone is not sufficient for candidate identity.

### LR-R03: Receipt And Query Accounting

Sites: `RepairEvaluator`, `FeedbackRepairSession`, worker/replay wrappers.
Bind real candidate/context/profile/revision, prove/test no stale acceptance,
charge every issued query including inconclusive results, and separate local
rejections from semantic feedback. Preserve feasible-context/two-direction
acceptance. Verify these properties on supported Alloy source, not just flags.

### LR-R04: Visited-State Expert And Replay

Sites: `FeedbackTeacherMain`, `experiments/feedback_repair/replay.py`, dataset
collection. Replace root-oracle-only supervision with bounded local continuations
and recovery from actual learner snapshots. Bind prefix and snapshot; handle
solver witness variation by checked transport or explicit replay divergence.
Separate offline expert calls from public episode feedback. Every admitted
continuation must replay its suffix; every recovery must check its postcondition.

### LR-R05: Public Observation And Split

Sites: feedback table exporters, collection, policy/consumer adapters. Verify
private-target/annotation mutation does not affect fixed public tensors, masks or
seeded decisions. Diagnostics must not add a covert oracle channel. Keep question
splits fixed, training-only aggregation, and uncovered tasks in denominators.
Keep every task's history chronological and expose no teacher future witnesses.

### LR-R06: Joint Alternatives And Optimizer

Sites: `experiments/feedback_repair/policy.py` and training drivers. Replace the
single teacher-prefix loss where appropriate with complete alternative action
probabilities; deduplicate alternatives and forbid marginal cross-products.
Implement explicit continuation/recovery weighting and real on-policy collection.
Check finite losses/gradients and small-example learnability. PyTorch/CUDA remain
TCB; no optimizer convergence, reward advantage or generalization is proved.

### LR-R07: Matched Budgeted Evaluation

Sites: future study manifest, learned/control rollout drivers and reports. Count
every construction choice; separately report semantic queries and internal solver
calls. Use matched Q=2/Q=4 arms, deadlines, three seeds, full denominators and
question-cluster uncertainty. Keep previous failed results immutable. Gate larger
models on actual free-running repair/recovery, not teacher-forced accuracy.

## What The Original Formalization Pass Did Not Claim

No production transition, dataset, optimizer, rewarder, canonical distance,
certificate rule or old experiment was modified. No new training was run.
No universal Alloy/Java/Lean refinement, identified private intent, optimal
expert, convergent learner or achieved repair improvement is asserted. The next
step is implementing LR-R01 through LR-R07 with source-level regression evidence,
then running the bounded learnability gates before another scaling study.

## Runtime Evidence Update: 2026-10-04

The preceding runtime requirements and no-training statement record the original
2026-10-03 formalization, not the status of the later implementation. The
[runtime correspondence record](LOCAL-REPAIR-RUNTIME.md) and
[training report](LOCAL-REPAIR-RESULTS.md) now provide the following bounded
evidence. They do not close universal refinement obligations.

- **LR-R01, partially implemented/tested:** source-local proposals and public
  COPY reuse, with a source-backed non-root fixture. The eight initial training
  paths all replace roots while reusing operands. Arbitrary binder-context
  alignment and every repair-family label are not established.
- **LR-R02, partially implemented/tested:** exact session-local syntax/type
  failure caching, charged retries and persistence across abort. Other coverage,
  resource and UNKNOWN failures remain uncached. The reproduced canonical local
  declaration refusal is documented, not mislabeled as a repaired cache case.
- **LR-R03, bounded tests:** Java-enforced query limits, actual final solving,
  rejected commits and unchanged committed states. This is not a proof of every
  solver/exception path or every receipt implementation.
- **LR-R04, implemented/tested in this slice:** actual roll-in/snapshot binding,
  fresh continuation replay and separately tested ABORT recovery admission.
  Training admitted 960 continuations and 11,231 continuation decisions; no
  separate recovery-only labels were needed in the measured aggregation.
  The expert restarts active drafts, so optimal partial-draft continuation is open.
- **LR-R05, bounded tests:** private-target initial-packet isolation, held-out
  label refusal, snapshot mismatch rejection and chronological public history.
  Six `LocalRepairArchive` lemmas establish lookup/address/budget properties of
  its model. They use standard Lean foundations, including `Classical.choice`
  for the arithmetic lemma; implementation-wide noninterference remains open.
- **LR-R06, implemented/tested in this slice:** joint alternative probabilities,
  duplicate elimination, initial/aggregated category sampling, actual visited
  states and 30,000 finite nonzero-gradient updates. The present expert emits
  singleton alternatives. No convergence or loss implementation proof is claimed.
- **LR-R07, partial experiment:** fixed Q=4/256-decision budgets, five models,
  three seeds, all eight training tasks, uniform/no-op controls and hashed
  evidence. Checkpoint reloads and accounting pass. A matched Q=2 arm, held-out
  uncertainty analysis and 64-task gate remain unrun. Larger models stay gated
  because no arm achieved 8/8 final repairs.

The preflight passed 68 Lean model/fixture theorems and 332 Java/Python check
executions. Exact producer inputs, including the original ledger version, are
retained in `results/local_repair_20261004/evidence.tar.gz`. The original proof
report remains historical evidence rather than being silently rebound to this
updated document.

## Larger-Data Evidence Update: 2026-10-04

The [local scaling report](LOCAL-SCALING-RESULTS.md) adds bounded runtime and
experimental evidence without closing universal implementation-refinement claims.
The user's explicit diagnostic scaling request overrides the small-gate stop for
this one study; the eight-task gate remains failed and later large-model stages
remain unrun.

- **LR-R03:** issued-decision/query counters now retain attempts whose worker
  response fails. A focused regression checks failed-request accounting. Counts
  are public worker requests, not every internal SAT call or offline expert call.
- **LR-R04/LR-R06:** 309 initial paths contain 4,397 decisions; 480 freshly
  replayed on-policy continuations contain 6,120 more decisions across six fits.
  Thirty thousand optimizer updates have finite nonzero gradients. No separate
  recovery-only labels were admitted in this measured aggregation. The teacher
  still emits singleton alternatives and may restart an active draft.
- **LR-R05:** all 625 eligible ordered source identities, question splits and
  derived source hashes match the earlier benchmark. Teachers/roll-ins are
  training-only; failed tasks are not replaced. New bounded checks cover hash
  routing, split refusal, teacher-independent roll-ins and cache transparency.
  Ten existing `FeedbackScaling` Lean model lemmas were rebuilt before runtime
  changes; they are not a proof of the Python implementation.
- **LR-R07:** four final-checkpoint validation arms, a persisted validation-only
  selection lock, three test seeds, matched maximum-budget controls and a
  question-cluster bootstrap now run at Q=4/256 decisions. All validation arms
  are 0/62; the locked model and controls are 0/89 in every test seed. A matched
  current-pipeline Q=2 arm and the 64-task gate remain unrun. Benchmark reuse is
  explicit, and a zero bootstrap interval is not proof of algorithm equivalence.

Fresh preflight passed 78 Lean model/fixture theorems and 342 Java/Python check
executions. The post-run audit verifies 1,112 frozen producer inputs, all recorded
preflight/data/study output hashes, and six finite, strictly reloadable final
checkpoints. `results/local_scaling_20261004/evidence.tar.gz` retains the original
proof-bound documents and producer sources before this evidence update.
The [runtime ledger](LOCAL-SCALING-RUNTIME.md) documents the stopped JVM perfdata
collection attempt, retained teacher coverage failures and attention history-limit
failure. No historic experiment or source corpus was changed.
