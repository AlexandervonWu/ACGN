# Predicate-Only, Counterexample-Conditioned Repair Paths

Version: `feedback-intent-path-v1`, 2026-10-03.
Status: **SPECIFICATION AND LEAN MODEL COMPLETE; RUNTIME MIGRATION PARTIAL**.
See [the implemented boundary, source executor and remaining gates](FEEDBACK-RUNTIME.md).

This is the next experiment's design. It replaces generic graph-token generation,
the four-template menu and model-size-first training. It preserves the metric,
certificate boundary, historical results and the user's predicate-only inference
invariant. The [27-theorem Lean model](formal/IntentRepair.lean) compiled before
this specification; [the ledger](INTENT-PATH-OBLIGATIONS.md) lists its boundaries.

## 1. Task And Information Invariant

Learn a multi-step repair from the faulty predicate and counterexamples actually
returned during the episode. The evaluator has a clear, fixed target behavior.
**That target intent is private.** The learner estimates intended behavior from
the permitted evidence; it does not receive a requirement or a target graph.

```text
faulty predicate and its derived code/canonical/graph views
    -> predicate tables + counterexamples already returned
    -> edit family, source occurrence and typed operand pointers
    -> deterministic draft construction and checked source transaction
    -> refreshed candidate views and budgeted counterexample feedback
    -> final validation against the evaluator's private task contract
```

At step zero, the feedback history is empty. The model may request a run and
then consume its response. No teacher-selected witness bank is prefetched.

After a decision, the model may also see its own proposed/committed candidate,
that candidate's derived views and its own action history. Those are consequences
of permitted inputs and interaction, not an additional task-description channel.

Never expose external exercise statements, intent graphs, oracle code, correct
pool bodies/graphs, target-distance scores, metric alignments, teacher paths,
dataset correctness classes, question IDs or file paths as inference features.
No external intent paraphrase or reference-assisted variant is allowed in this
version. A private oracle cannot become public merely by changing its encoding.

Names, types and scopes attached to occurrences in the permitted predicate views
remain available. The exporter must not add unrelated declarations, an unused
field inventory, helper bodies or the whole module schema. The controller may
need the real module to parse and validate; that does not make it model input.
Audit normalization/export dependencies as well as the final serialized fields.

For fixed weights/seed, permitted predicate views, action history and returned
feedback, private-target changes must leave model inputs and outputs unchanged.
Different targets can legitimately produce different *future* feedback. This is
conditional dataflow separation, not a claim that changing a module cannot change
a predicate's resolved type or meaning. The Lean record-projection theorems do
not prove the actual exporter or model implementation satisfies this contract.

## 2. Clear Intent Without Privileged Input

### Private Evaluator Contract

Before the episode, bind the actual module context, selected callable/signature,
editable region, theory/profile versions and reference behavior. Keep facts,
imports, helpers, declarations and commands immutable unless a separately declared
task explicitly edits them. Existing validated oracle predicates can supply the
private target; original natural-language exercise statements are not required.

The private contract supplies offline teacher labels and the final behavioral
check. It is never concatenated to the neural observation. Target/context
disputes are curation incidents, not permission to change the target until a
generated repair succeeds.

### Evidence-Derived Intent

An optional intent/belief representation must be computed only from the permitted
predicate views, already returned feedback and the model's history. It cannot be
filled from hidden requirements, oracle-derived explanations or teacher annotations.
It is a revisable hypothesis, not a certificate or an additional input modality.

The same faulty predicate may require different repairs under different private
targets. A finite counterexample history may not distinguish them. The model can
request further budgeted runs or ABSTAIN; it cannot claim a uniquely recovered
intent from insufficient evidence. Do not exclude those hard tasks just because
intent is hidden, or silently supply their exercise descriptions.

### Counterexample Protocol

Return context-valid concrete worlds/traces with expected and candidate Boolean
outcomes, typed atoms, ordered relation tuples and temporal positions when
supported. A new symbol may become visible through an actual returned example
or an allowed predicate occurrence, not an unsolicited hidden-module inventory.
Record the allowed origin of every visible symbol.

Use a fixed, versioned solver/query policy. Log query candidate revision, profile,
cost and response. Only the chronological response prefix is model-visible.
Future counterexamples from a teacher trajectory cannot enter an earlier state.
Feedback contains no oracle source, hidden source spans, target-derived edit
instructions, distance-to-truth or reward-score channel.

Execution validity and final success/timeout are controller outcomes, not hidden
semantic hints. Any local diagnostic exposed to the model must be derived from
its own attempted predicate, not reveal private helper or oracle bodies. UNKNOWN,
timeout and missing counterexamples never constitute successful validation.

Finite-bank agreement is supporting evidence, not final equivalence. The Lean
model proves a concrete counterexample to treating bank agreement as success
and shows how a returned labelled world can rule out a hypothesis.

## 3. Structured Tables Instead Of Long Serialization

The public packet has explicit numeric/enum tables:

- `nodes`: operator, result-type reference, phase and binding-context handles.
- `ports`: source/destination, role, ordered position or BAG multiplicity.
- `types`: structured exact type DAG nodes/edges shared across uses.
- `bindings`: quantifier, type, cardinality, disjointness class and scope/imports.
- `occurrences`: editable predicate source occurrences and graph/context links.
- `worlds`: returned labels, memberships and ordered tuples with world-local atoms.
- `draft`: proposed typed nodes and unresolved holes in the current transaction.

There is **no external intent table**. The source occurrence graph realizes
edits; the certified repair projection provides normalized structure. A full
proof-heavy saturation graph is not a prerequisite. Additional e-class members,
if exported, are a separately measured input variant, not something the existing
`RepairView` exporter is assumed already to provide.

Rows have at most 16 scalar fields. Variable arity uses port rows rather than
nested records. Shared types/subgraphs appear once; cycles use explicit edges.
Preserve checked exact integers/enums in the adapter; no identity is a rounded
float, hash bucket or clipped count. Concrete dtypes and overflow rejection are
implementation obligations, not consequences of the abstract Lean `Int` model.

Proof objects, original display names, source maps, hashes and verbose derived
type strings stay in a controller sidecar. Only administrative or derivable
information is removed: supported semantic type/domain/operator values must
have structured representations. Unrepresentable semantic payloads yield
`OBSERVATION_UNSUPPORTED`, not byte escapes or a generic `univ` fallback.
Private validation/module material is in a separate sidecar that is never a
policy input.

Signature, field and binder references are typed pointer namespaces, not reserved
token banks capped at eight names. Row IDs are addresses, not learned identities:
transport all pointers consistently under row reindexing and test equivariance.
Keep at most 128 versioned categorical operator/control entries per dictionary;
audit the real inventory. Pointers and exact numeric values are separate heads
and tensor columns, not a way to pretend all data fits 128 text tokens.

Preserve SEQ order, BAG multiplicity and only certified SET deduplication. Preserve
dependent JOIN/ARROW types, CALL boundaries and phase-local imported binders.
Binder identity includes owner phase/context/coordinate and use/import context.
Copied open terms are checked in the destination scope; a pointer is not a proof
of alpha-equivalence.

### Explicit Resource Bounds

Initial configurable bounds: 8,192 total rows per decision, at most 16 fields
per row, 8 returned worlds/traces and 256 model decisions per episode. Drafts
and witness tuples count toward the same row budget. This bounds the uniform
table abstraction by 131,072 scalar cells, not GPU bytes or attention memory.

Do not truncate required predicate data. Excess mandatory data gives
`INPUT_BUDGET_EXCEEDED`. Optional returned worlds can be selected from the
already observed transcript by a fixed public policy with omitted counts logged.
That selection cannot consult target distance or unseen future feedback.

Report attempted/admitted coverage, rows/edges by channel, tensor and sidecar
bytes, device/host peaks and decision counts. These bounds do not establish
full-corpus coverage or hardware fit. Use sparse/local processing and bounded
cross-attention initially; do not presume dense attention over every row fits.

## 4. Multi-Step, Factorized Semantic Actions

At each step select a control outcome or an edit frame:

1. One of the existing nine temporal/binding/matrix insert/delete/update families.
2. An allowed source-occurrence or draft-hole pointer.
3. An operator or tuple-field choice when required.
4. Typed node/binder/type/constant/draft operand pointers.

Pointer heads select actual rows; the model does not spell numbers or count
postorder records. Constants use exact value tables appropriate to the integer
profile. New literals need a bounded numeric head with range tests. New signature
or relation declarations outside the editable predicate are not invented.

Legal masks depend on the public family/site/operator/context and prior choices.
They enforce locally known structural constraints, not whether the edit already
repairs the task. The private target must not affect masks. Declaration choices
come only from the permitted visible namespaces. Further type/source checks
remain executor duties; they do not silently expand the model's schema inventory.
Record any search pruning separately from the legal action language.

### Deterministic Construction

The executor creates root wrappers, arity records, indexes, delimiters, derived
types, fresh IDs, alpha-safe display names and provenance. The network never
predicts a constant `ROOT` header, JSON shape or certificate fields.

Insertions/replacements use typed draft holes. The model reuses existing
subgraphs or builds new operators/operands through additional semantic decisions.
A draft may introduce a binder and its uses together before an atomic source
commit. This preserves compositional, multi-step construction instead of
restoring the four-template action ceiling.

No action payload hides a whole oracle body or arbitrary JSON. Each constructed
operator/operand choice is counted; large arity uses repeated port choices.
Administrative structure costs no prediction decisions. Actual semantic choices
do. Expressibility of this source-realized language must be measured; the old
abstract COPY/BUILD theorem is not a completeness proof for the new executor.

### Replay And Safety

Transactions bind task/context/profile/theory identity and source revision.
After commit, reparse, type-check, prepare and refresh all source/pointer maps.
Reject stale pointers. Teacher traces must rebind their next step after
normalization rather than assuming old indices survive.

Intermediate committed candidates may still be wrong or increase distance, but
must have valid source, scope and provenance. Incomplete drafts are not Alloy
candidates. Rejected edits leave committed source unchanged and consume budget.
ABORT_DRAFT, VALIDATE, STOP and ABSTAIN also consume budget. STOP requests
validation; it is never a success certificate. Use deadlines in addition to fuel.

A meaning-changing repair is not an e-graph equality. Keep existing quotient
certification, alpha/assignment minimization, quantifier charge units and metric
decomposition unchanged. Source transactions may bundle several charged edits;
transaction count is not asserted equal to canonical edit distance.

## 5. Illustrative Feedback Path

The controller's hidden target might be "Nobody follows themselves." The model
does not receive that sentence or its formalization:

```text
initial source: some u: User | u in u.follows
returned world: one User a, follows = {(a,a)}
returned outcome: candidate=true, expected=false
possible proposal: change that binder's quantifier to NO
then: VALIDATE the resulting predicate
```

The example does not uniquely determine `NO`; other wrong hypotheses may agree
on this world. Subsequent validation distinguishes them. The proposed source
path is illustrative, not a measured corpus repair or an already implemented
action. The source realizer must respect whichever ALL/NOT representation the
existing canonicalizer uses for NO rather than matching displayed spelling.

This makes learning the pathway a feedback-conditioned planning problem. It
does not turn the private intended behavior into a public goal specification.

## 6. Dataset And Teacher Paths

Split by question before selecting targets, synthetic corruptions, retrieval
motifs, counterexamples or trajectories. Offline teachers may use validated
oracle and co-equal correct-student pools, but the observation encoder receives
neither. Targets must be validated in each task's actual context/profile.

Save executable paths rather than locally optimal one-step labels or readable
distance strings. Prefer nearby validated targets without changing the metric.
A metric-plan trace needs exact alignment, charge correspondence and source
replay before being called optimal. Search-found paths are labelled as such;
shortest found is not a proof of shortest executable source repair.

Replay each path from source. Save the public observation, chosen action,
argument tables, revision, query history, actual returned counterexamples and
final private validation receipt. At every teacher step, input is precisely what
the deployed model could have seen by then. Paths can contain temporary distance
increases. The teacher's future feedback is not part of the current key.

Keep successful alternatives; avoid making arbitrary alpha names or SET operand
order the only label. Group alternatives only with checked action transport and
replay, not merely a zero distance between results. Joint site/operand alternatives
must stay joint rather than training incompatible combinations through marginals.

Report `NO_PATH_WITHIN_BUDGET`, `ACTION_UNSUPPORTED`, `SOURCE_UNREALIZABLE`,
`VALIDATION_INCONCLUSIVE` and resource failures separately. Replay every admitted
path, but keep pathless tasks in overall coverage and repair denominators.
Include STOP/no-change teachers only after actual validation of the unchanged
predicate. No held-out target enters training, retrieval or model selection.

## 7. Model And Objective

Use a joint structured encoder for predicate and returned-world tables, preserving
edge roles and cross-table references. The decoder attends to those tables and
its semantic decision history, with factorized family/site/argument heads.
An optional inferred-intent state is internal memory derived from those inputs,
not a privileged annotation.

Train from scratch. Start with a small functional model; approximately 508M is a
later scale point after the gates below. All architecture comparisons must share
the information boundary and executable action language.

Primary loss is imitation of replay-checked semantic decisions, normalized per
decision/episode, with separate family/site/operator/operand metrics. Aggregate
probability over checked alternative continuations. Optional auxiliaries predict
candidate behavior on returned worlds or evaluate source subexpressions under
explicit binder environments. Do not train an input channel carrying hidden
intent-clause annotations.

No loss for generic serialization, proof objects or derived type strings.
Distance change is an auxiliary diagnostic, not a requirement of monotone
progress. Follow successful imitation with bounded training-only rollouts and
teacher continuations on visited states; do not start with sparse-reward RL as
the only teacher. Preserve natural student errors in held-out evaluation even
if synthetic short-path curricula are used for training.

## 8. Finite Gates And Evaluation

Final success requires reparsed source, unchanged context/profile, feasible
context and both behavioral-difference checks UNSAT against the private target
under the declared profile. UNKNOWN/timeout is not success. Bank agreement,
distance zero, one graph match or low loss cannot replace this gate. Independent
certificate replay retains its existing authority; bounded checks remain bounded.

Execute these gates before a large run:

1. **Information gate:** mutate private target, pool, statement, labels and future
   witnesses while holding allowed views/transcript fixed. Model tensors and
   fixed-seed predictions must remain identical. Check names/types originate in
   permitted occurrences or actual returned examples. Initial transcript is empty.
2. **Representation gate:** table round trips, row/alpha/phase transport, exact
   type/domain retention, no string fallback and no hidden sidecar reads. Vary
   administrative string lengths without changing packet shape. Measure resource
   bounds and corpus coverage rather than claiming compression from unlike units.
3. **Execution gate:** source replay, rollback, stale-pointer rejection, scoped
   reuse, insertion/deletion, variadic changes, atomic binder edits, multi-step
   repair, STOP validation and finite budgets. Root/reference construction must
   no longer depend on learned record formatting.
4. **Learnability gate:** fixed real sets of 1, 8 and 64 tasks with checked
   teacher paths. Require 1/1, 8/8 and at least 60/64 bounded-validated repairs
   under free-running decoding and the same public-feedback query budget as the
   teacher, plus 100% well-formed action records. Cap the first two diagnostics
   at 1,000 optimizer updates each and the third at 5,000. On failure, classify
   it and stop; do not enlarge the model or weaken validation. These thresholds
   are engineering gates, not generalization or task-identifiability theorems.
5. **Comparison gate:** select on validation behavioral repair, smaller model
   breaking ties. Compare no-op, uniform legal actions and bounded search under
   matched observations, query/proposal budgets and executors. TAR remains a
   separately labelled external comparator if it consumes a richer specification;
   its results cannot be called a predicate-only matched baseline.

Use at least three independent training seeds and question-group-aware intervals
for a final study. Report success@budget, per-question outcomes, all coverage and
exclusions, solver calls, time, memory, source changes and existing raw/relative
canonical distances. Distinguish initial zero-feedback performance from adaptive
feedback performance. Repeated episodes are not independent questions.

## 9. Implementation Order And Status

1. Implement the predicate-only allowlist, private contract and causal query log.
2. Export numeric predicate/type/world tables with sidecar separation and round trips.
3. Implement deterministic typed drafts, checked source transactions and refresh.
4. Generate causal, replay-checked teachers and measure coverage.
5. Run small learnability gates and matched-information baselines.
6. Only then train larger feedback-conditioned models.

The existing codec, exporter and trainers are historical implementations, not
automatically compliant. In particular, the old full-module symbol table and
source-only whole-graph token decoder must not be relabelled with this version.
The new [runtime migration](FEEDBACK-RUNTIME.md) implements a bounded source
executor, causal feedback boundary, factorized coarse-sort action heads and
training-only teacher replay; canonical tables, exact incremental draft types
and learning gates remain open. No trainer is yet connected to it.
New manifests bind public-view/feedback schemas, private evaluator hashes, splits,
teacher/executor versions, profiles, budgets, models and outputs; those manifest
fields themselves are not model input. Runtime migration and whole-program
Lean correspondence remain open.
