# Predicate-Only Repair Proof And Implementation Ledger

Version: `feedback-intent-path-v1`, 2026-10-03.

## Scaling Correspondence

The [scaling protocol](FEEDBACK-SCALING-STUDY.md) adds ten model theorems in
`formal/FeedbackScaling.lean`, compiled before the corresponding implementation,
and nine runtime regression methods in `experiments/feedback_repair/test_scaling.py`.
They preserve the same bounded proof/implementation distinction as the ledger below.

- **FS01:** `no_validation_gradient`, `no_evaluation_gradient` and
  `same_question_same_split` model training admission and group separation.
  `training_index` rejects held-out teachers; `teacher_task` rejects a held-out
  task before IO. Tests exercise both boundaries. The runner uses the existing
  question hash split, checks disjointness and never creates held-out teachers.
- **FS02:** `selection_ignores_teacher` and `selection_bound` specify a fixed
  teacher-independent quota. `select_sources` hashes source paths before parsing
  or replay; order-independence and split quotas have direct tests. The actual
  corpus, parser and cryptographic implementation remain trusted dependencies.
- **FS03:** `unsupported_not_repaired` and `failure_retained` keep failed attempts
  in denominators. `eligible` removes only AST-identical and duplicate AST pairs;
  other preparation failures remain. `evaluate` emits an unsuccessful record
  for unavailable sources, and the existing rollout retains unsupported/errors.
  The regression injects failed preparation records, not semantic successes.
- **FS04:** `smaller_wins_validation_tie` and `test_does_not_select` model the
  frozen selection order. `select_config` reads validation repairs, parameter
  count and fixed arm order only; a regression changes test fields without
  changing selection. The runner writes and hashes the selection before testing.
  This does not claim validation selection is statistically unbiased.
- **FS05:** `cache_preserves_example` proves lookup transparency conditional on
  exact key/value correspondence. `TeacherBank` keeps task/decision keys and
  lazily encodes the requested public observation. A real replay regression
  compares cold/cached graph tensors, addresses, labels and query counts, and
  checks that unrelated decisions have not been encoded. The one-GiB cache size
  is an estimate, not a formal bound on Python or CUDA allocation.

The suite also checks paired sampling schedules and external derived-source
roots. Proofs have no `sorry`, newly declared `axiom` or `unsafe`; their printed
dependencies are Lean's standard foundations where needed. These models and
bounded tests do not close universal Java/Python refinement, autodiff correctness,
Alloy solver completeness, action-language completeness or learning effectiveness.
PyTorch/CUDA remain TCB. The expanded run is explicitly a new bounded study, not
a retrospective pass of the earlier failed eight-task gate.

## GNN Follow-Up Correspondence

The [bounded GNN study](FEEDBACK-GNN-RESULTS.md) adds eleven theorems in
`formal/FeedbackGNN.lean` and seven runtime tests with per-variant subtests.
These are bounded correspondence checks, not universal implementation proofs.

- **FG01:** `aggregate_permutation` models sum invariance. Message aggregation
  in `gnn_variants.MessageLayer` and public address transport are checked by
  `test_row_and_edge_order_transport` for all six variants. The theorem itself
  does not prove floating-point attention or every possible input graph.
- **FG02:** `channel_ignores_other` and `channel_retains_member` specify table
  membership. `channel_means` is checked by `test_channel_isolation`; the
  isolation claim is before contextual message updates, not independence from
  legitimately connected nodes.
- **FG03:** the three `score_*`/`context_sensitive_witness` lemmas model bilinear
  scalar algebra. The actual normalized vector scorer is checked for relative
  query sensitivity, finite-difference agreement and nonzero gradients through
  encoder, context and pointer modules. Autodiff remains TCB; this is not a Lean
  differentiation theorem or a guarantee of nonzero gradients for every input.
- **FG04:** `variant_private_independence` specifies an exclusively public policy
  argument. `test_private_oracle_prediction_independence` checks actual Java
  observations and predictions under a changed hidden oracle, with fixed weights.
- **FG05:** `schedule_length` and `paired_schedule` specify fixed paired draws.
  `gnn_study` precomputes one schedule per seed and reuses it for every arm.
  All six schedule hashes per seed were compared after the run and match.
- **FG06:** `gradients_not_authority` and `nonzero_gradient_cannot_certify` keep
  success separate from optimization. Existing `rollout` delegates success to
  the unchanged executor's closed/REPAIRED result. There are no Java changes in
  this follow-up. 18,000 finite nonzero updates are empirical measurements;
  they do not certify a single repair or discharge the failed 8/8 gate.

The detailed results retain all failures, unsupported coverage and explicit
trust assumptions. No existing open obligation is closed merely by improved
training accuracy or positive repair counts on eight training tasks.

The [specification](INTENT-PATH-SPECIFICATION.md) follows the standalone
[IntentRepair.lean](formal/IntentRepair.lean) model. All 27 theorem declarations
compile under Lean 4.33.0. There are no `sorry`, newly declared `axiom`, `unsafe`
or `native_decide` constructs in this file. Lean and its imported library remain
trusted. **This is not whole-application refinement or a proof of learning
effectiveness.** A [partial runtime migration](FEEDBACK-RUNTIME.md) now implements
the source executor and causal query boundary. It has a further 21-theorem
[controller model](formal/FeedbackSession.lean); the open obligations below are
not discharged merely by those model proofs or bounded source checks.

## Proved Model Contracts

- **IP01, initial/private input boundary:** `initial_has_no_feedback`,
  `initial_uses_only_faulty_view`, `private_contract_change_preserves_input`,
  `fixed_policy_cannot_read_private_contract`. Initial state has the faulty view
  and no feedback; private fields do not affect projected input or a fixed policy
  over that input. This assumes the supplied public view is already permitted.
  Actual export dependencies and model dataflow remain open, not proved by records.
- **IP02, teacher and feedback separation:** `teacher_change_preserves_input`,
  `different_feedback_is_retained`, `unseen_future_feedback_hidden`. Teacher
  fields do not enter the projected observation; distinct transcripts remain
  distinct records; appended future responses do not change the observed prefix.
  This does not prove actual query causality, neural injectivity or train/test
  separation. Fixed weights and randomness are required for output comparisons.
- **IP03, bounded representation:** `scalar_budget`,
  `sidecar_does_not_expand_packet`. The 16-cell-row model is linear in row count;
  sidecar changes do not affect its cell count. Semantic completeness, actual
  dtype bounds, compression ratio and device memory are separate obligations.
- **IP04, scope and pointers:** `phase_sites_distinct`,
  `context_sites_distinct`, `node_pointer_in_range`. Coordinates retain phase
  and context distinctions; Fin pointers are range-bounded. Type compatibility,
  imported binding provenance, source lineage and revision freshness need checks.
- **IP05, prediction size:** `frame_field_bound`, `path_field_bound`. Frames
  with at most a operands have at most 3+a abstract fields; a fixed-table list
  has at most length*(3+a). This does not count every controller/draft step,
  prove action completeness or model refreshed dynamic pointer namespaces.
- **IP06, transition control:** `attempt_keeps_intent`,
  `attempt_keeps_profile`, `every_attempt_consumes_fuel`,
  `rejected_attempt_keeps_graph`. Intent/profile belong to the private controller,
  not the Observation. An attempt preserves them, consumes positive fuel and
  keeps the committed graph after rejection. Correctness and termination of the
  supplied partial checked transition are not proved; runtime deadlines remain.
- **IP07, replay:** `replay_first_transition`, `replay_deterministic`. A
  successful nonempty replay has a successful first step and suffix; one path
  has at most one result. No optimality, source realizability or final behavioral
  success follows merely from this abstract replay.
- **IP08, intent and evidence:** `same_intent_allows_alternative_targets`,
  `finite_bank_is_not_success`,
  `incompatible_intents_need_distinguishing_evidence`,
  `returned_counterexample_excludes_hypothesis`,
  `two_direction_obligations_establish_intent`. Explicit Boolean interpretations
  over a chosen world domain admit alternative targets, distinguish bank evidence
  from universal agreement, and establish agreement from both difference
  obligations. Incompatible private goals cannot both be met by one candidate on
  a distinguishing world. None of these claims makes the intent a public feature
  or identifies the mathematical domain with the actual Alloy source semantics.
- **IP09, final gate:** `success_requires_every_check`,
  `infeasible_never_success`. Reparse, unchanged profile, feasibility and both
  direction checks are required by the Boolean gate. The real checker, query
  construction and bounded UNSAT trust are not proved by these Boolean fields.

## Open Implementation Obligations

The additional `FeedbackSession.lean` model has these Java/Python correspondence
targets. Every statement below is a model theorem plus bounded runtime evidence,
not a universal refinement claim:

- `initial_feedback_empty`, `private_change_hidden`: the session's initial
  projection and lazy evaluator; private mutation tests cover the public packet.
- `query_consumes_budget`, `query_appends_exact_response`,
  `query_preserves_private_contract`, `exhausted_query_unchanged`: explicit
  VALIDATE/STOP, fixed task ownership and chronological response retention.
- `rejected_attempt_no_feedback`, `rejected_attempt_keeps_view`,
  `rejected_attempt_consumes_budget`: rejected source transactions and stale
  revision/turn requests preserve committed source while consuming a decision.
- `response_prefix_preserved`, `query_same_public_response`: append-only query
  history; public last-eight selection is a separately versioned observation rule.
- `no_empty_is_true`, `some_empty_is_false`: Alloy surface realizations of Boolean
  constants. Parser/solver correspondence is tested, not assumed from the lemma.
- `enclosing_span_keeps_core`: delimiter completion contains the parser interval;
  Java comment/string scanning remains a bounded regression obligation.
- `masks_ignore_private`, `masked_choice_from_public`: `FeedbackActions` and the
  draft's factorized masks select from public namespaces without oracle ranking.
- `replay_key_excludes_future`, `exhausted_replay_does_not_query`: `replay.py`
  snapshots each key before executing its label and enforces finite decisions.
- `first_domain_has_no_draft_bindings`, `domain_scope_is_preceding_groups`:
  `FeedbackDraft.childScope` exposes preceding declaration groups to each domain,
  and all groups to the body, retaining joint ONE/LONE instead of nesting them.
- `returned_signature_member_retained`: concrete world atom membership includes
  returned built-in signatures; a 4-bit Int check verifies the Java export case.

Each item below remains **OPEN for full contract compliance**. IPC01/IPC02/IPC04
and IPC05/IPC08 now have partial implementation and bounded tests, recorded in the
runtime report. Historical prototypes do not silently discharge any item.

- **IPC01:** predicate-only export allowlist and dependency audit. Fixed permitted
  views/transcripts must not change when private oracle, truth pool, requirement
  text, dataset label or future teacher responses change. Do not assume the old
  module-wide symbol table complies. Reject hidden inventory or target-derived
  diagnostics as features; keep context/profile/provenance in the controller.
- **IPC02:** causal run interface and concrete world/trace feedback, with visible
  symbol origins, fixed query policy, revision binding and no prefetched examples.
  Inference starts with no witnesses; future feedback is unavailable. Unknown
  target intent is not a reason to supply external requirements or remove tasks.
- **IPC03:** exact typed table exporter/importer, fixed-field schema, numerical
  bounds and cross-table transport. Preserve semantic payloads without strings,
  clipping, guessing or a generic univ fallback; distinguish semantic type data
  from verbose derived formatting.
- **IPC04:** family/site/operand heads and public masks, deterministic drafts,
  source realization, atomic binder changes, pointer refresh, charge accounting
  and rollback. Private target fields must not affect legal action masks.
- **IPC05:** causal, multi-step source teachers; replay every admitted trajectory,
  retain pathless/censored tasks, and distinguish metric witnesses, found paths
  and proven optimal plans. Preserve all existing metric semantics.
- **IPC06:** observation/teacher isolation during training, grouping before derived
  data, no held-out retrieval/gradient leakage and correct joint alternative-action
  labels. The offline teacher may see targets; the observation encoder may not.
- **IPC07:** model table consumption, action-record generation, gradients,
  checkpoint/cache behavior and measured hardware bounds. PyTorch/CUDA and the
  numerical backend remain explicit TCB, not newly proved primitives.
- **IPC08:** final task/source/profile-bound validation receipts, actual solver
  correspondence, UNKNOWN/timeout handling and unchanged certificate authority.
- **IPE01:** bounded 1/8/64 learnability gates, then matched-information controls,
  independent training seeds, held-out repair evaluation and coverage accounting.
  No effectiveness, identifiability or optimality claim is currently made.

## Verification And Revision Record

```bash
lean -o /tmp/IntentRepair.olean \
  docs/canonical-edit-learning/formal/IntentRepair.lean
```

The initial draft used an explicit public requirement channel. The user's
clarification forbids it. It was replaced before runtime implementation with
a private task contract, predicate-only public observations and causal returned
counterexamples. The old public-intent admission theorems were removed rather
than being cited for the opposite information policy. The final model contains
27 theorems and compiled before this revised specification was written.

Final checks also audited every theorem with `#print axioms`: dependencies are
limited to the standard Lean foundations `propext` and `Quot.sound` where needed,
with no `sorryAx`. All 27 declarations are named in this ledger; 31 local links
across the five current/historical specification entry points resolve, and
`git diff --check` passes. Protected empirical result trees have no tracked diff.

The first proof compilation, before that clarification, exposed two proof-script
issues: a fuel case split left a projection equation unsimplified, and replay
pattern matching had already rewritten a witness equality. Explicit simplification
and the reduced equality repaired them; no semantic assumption was introduced.

Existing contracts and measurements retain their historical meaning. Neither
the prior generic graph-program trainer nor a full-module schema input is claimed
to satisfy this new specification. The source-only migration ran bounded source,
query and teacher-replay checks without training. The subsequent learning
extension and its measurements are recorded separately below and in the report.

## Bounded Learning Correspondence

`formal/FeedbackLearning.lean` compiled before the extension's Java/Python code.
Its ten theorem declarations and concrete correspondence targets are:

- `metadata_preserves_metric`: `RepairView` observation metadata is separate
  from metric fields; `RepairProjection` copies carry it without changing
  equality/assignment/charge operations. The existing 2,266-check metric suite
  passes. This product-projection theorem is not a universal proof of that Java diff.
- `edge_roundtrip`, `role_retained`, `position_retained`,
  `multiplicity_retained`: `tables.Graph.permute` transports all graph endpoints
  and policy address handles. Tests recover every tensor after inverse transport
  and compare GNN outputs within floating-point tolerance. They do not establish
  universal Alloy table round-trip completeness.
- `label_private_noninterference`, `prediction_noninterference`: public
  observations alone enter `tables.encode`; labels are separate supervised
  decoder targets. A real-worker test changes the hidden oracle and verifies
  identical initial tensors and fixed-seed predictions. Explicit future feedback
  may differ, as intended. No theorem claims indistinguishable tasks identifiable.
- `query_limit`: the rollout controller and masks enforce the same two explicit
  query maximum as teachers. JVM subprocesses also have 30-second response and
  120-second episode deadlines; those OS behaviors are tested TCB, not Lean proofs.
- `failed_gate_stops`, `below_threshold_not_pass`: `train_gates` implements the
  fixed 1/8/64 thresholds, bounded updates and stop-on-failure policy. Final repair
  status comes from the real private evaluator, not from the learned classifier.

The new proof log prints only standard foundational dependencies (`propext`,
`Quot.sound`) where used; no new axioms, `sorry` or unsafe declaration was added.
Seven dedicated Python tests cover exact int32 retention, information mutation,
graph transport, source alpha names, ACI/phase imports, causal teacher inputs and
query-budget masks. PyTorch/CUDA and floating-point training remain TCB.

Still open: local canonical binder/domain export, full source-history snapshot
transport across multiple revisions, universal Java/Python refinement, the
matched bounded-search control, larger-model consumers and held-out three-seed
effectiveness. Unsupported observations remain in coverage; no theorem or test
listed here is offered as evidence that those missing paths are supported.
