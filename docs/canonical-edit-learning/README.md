# Canonical Edit Learning

## Current Design

The [scaled multistep study](MULTISTEP-SCALING-RESULTS.md) increases training to
144 episodes, adds AND/OR and three-slot compositions, and evaluates unseen
four-slot plans. Exact cumulative counterexample filtering excludes known-bad
candidates before a shared-slot GNN/GRU ranks them. Matched sixteen-pass exposure
includes unsuccessful episodes. The selected 272K model repairs 25/32 held-out
three-slot and 23/32 four-slot tasks in each of three seeds; resetting learned
memory gives the same counts. A 1.03M model ties the smaller model on validation.
The learned policy beats filtered random search in all three seeds but ties
deterministic evidence-consistent minimum-edit search; no neural advantage over
that stronger baseline is established.
These are synthetic results: the separate 104-input natural-source audit finds
zero grammar-supported tasks, including nine observation-adapter load refusals.
The [protocol](MULTISTEP-SCALING.md) distinguishes public feedback, private
evaluation, exact filter obligations, neural ranking and bounded solver success.
Broader source-local action coverage is needed before natural-corpus transfer.

The [multistep contextual plan model](MULTISTEP-REPAIR.md) extends the prototype
with attempt-level graph/GRU memory, complete executable edit paths and
counterexample-dependent search demonstrations. A bounded 40-task synthetic
composition split compares persistent, reset-memory and feedback-blinded models
against deterministic feedback search and uniform search. Its 15 new Lean model
theorems precede the runtime; source-backed tests cover all sixteen plan forms.
This is a deliberately restricted two-site cardinality grammar, not arbitrary
Alloy repair. See [the measured results](MULTISTEP-REPAIR-RESULTS.md) for the
separate feedback and memory findings.

The earlier [contextual repair prototype](CONTEXTUAL-REPAIR.md) models whole
failure/attempt/feedback episodes with recurrent graph memory. Real validation
is controller-scheduled after commits, unsuccessful attempts remain in context,
and only the existing evaluator can accept a repair. The
[bounded results](CONTEXTUAL-REPAIR-RESULTS.md) record 16 new Lean model lemmas,
ten new tests and a 119k-parameter pilot that reproduces two successful
multi-attempt repairs and one budget-limited failure on three training fixtures.
It matches its public enumerator; neither contextual reasoning nor held-out
advantage has been established. Context-dependent branching and memory/feedback
ablations are required before another scaling run.

The new [local, feedback-guided repair refinement](LOCAL-REPAIR-SPECIFICATION.md)
formalizes occurrence-local edits with structural reuse, checked commits,
counterexample-guided revision and training on actual visited/recovery states.
Its [42 general Lean theorems](formal/LocalRepair.lean) and
[20 concrete model checks](formal/LocalRepairChecks.lean) compile; the
[claim and correspondence ledger](LOCAL-REPAIR-OBLIGATIONS.md) separates these
proofs from implementation correspondence and learning claims. The subsequent
[bounded runtime migration](LOCAL-REPAIR-RUNTIME.md) adds local COPY teachers,
replay-admitted on-policy continuations, narrow stable-failure caching, explicit
query budgets and historical public-graph transport with six additional Lean
model lemmas. Full refinement and expanded source coverage remain open.

The [new training report](LOCAL-REPAIR-RESULTS.md) records five model families,
three seeds and 30,000 finite nonzero-gradient updates. On the same eight training
tasks, final GIN repairs are 6/8, 5/8 and 5/8; attention repairs are 5/8, 5/8 and
6/8. Both average 5.33/8, with GIN smaller. Uniform and no-op controls remain
0/8 in every seed. All 15 final checkpoints reload and all 960 aggregated
continuations have fresh replay evidence. These are training-set diagnostics,
not held-out performance or proof of effective counterexample reasoning. No
model meets 8/8, so Qwen and roughly 500M training remain gated. Historical
results and the original corpus are unchanged.

The subsequent user-authorized [larger local-repair study](LOCAL-SCALING-RESULTS.md)
uses 474 training tasks, 62 validation tasks and 89 test tasks, with question-level
separation. It admits 309 initial teacher paths and 480 replayed on-policy
continuations, screens GIN, larger GIN, attention and a no-message MLP up to
28.24M parameters, and completes 30,000 finite nonzero-gradient updates.
Every configuration repairs 0/62 validation tasks. The parameter-count tie-break
selects the 6.01M MLP, which repairs 0/89 test tasks in each of three seeds,
tied with uniform/no-op controls. All 61 executable test tasks also fail in
each seed; the 28 coverage failures alone do not explain the result. Policies
stop with counterexamples or spend their decision budget without using the four
available queries. This is descriptive evidence, not a demonstrated sole cause.
The [protocol](LOCAL-SCALING-STUDY.md) and [runtime incident ledger](LOCAL-SCALING-RUNTIME.md)
retain the failed small gate, exact benchmark reuse, scope limits and reproduction
commands. The preflight passed 78 Lean model/fixture theorems and 342 runtime
check executions; six final checkpoints and the frozen manifests pass audit.
Neither increased scale nor successful replay establishes useful held-out repair.

[Predicate-Only, Counterexample-Conditioned Repair Paths](INTENT-PATH-SPECIFICATION.md)
remains the base input/action contract. Model input is restricted to the faulty predicate's
derived views, its own candidate history and actual returned counterexamples.
The evaluator's task intent, oracle and truth pool stay private. Numeric graph
and feedback tables support multi-step family/site/operand decisions.
The executor constructs graph syntax, derived types and source mappings;
the learner does not serialize proof metadata or numeric node addresses.
The [27-theorem Lean model](formal/IntentRepair.lean) compiles; the
[implementation ledger](INTENT-PATH-OBLIGATIONS.md) remains explicitly open.
The [runtime migration](FEEDBACK-RUNTIME.md) adds a causal feedback boundary,
numeric source/type/world tables and a compositional source executor. Its
21 additional [Lean model lemmas](formal/FeedbackSession.lean), public action
heads and replay-checked offline teachers establish the executor boundary.
The [bounded learning extension](FEEDBACK-LEARNING.md) adds ten Lean boundary
lemmas, structured canonical tables, address-transport tests and a small graph
policy connected to the same executor. Canonical local-binder coverage and large
model consumers remain open. The [report](FEEDBACK-TRAINING-REPORT.md) separates
historical source-only preflight, new representation coverage and learned repairs.
The [earlier expanded GNN study](FEEDBACK-SCALING-RESULTS.md) trained on 313 validated
paths and screens models up to 24.54M parameters. Gradients and teacher imitation
are measurable, but every validation arm is 0/62 and the selected GIN is 0/89
held-out repairs across three seeds, tied with both controls. Its frozen split,
replay data and executor are reusable by the later LLM/Transformer consumers;
those consumers have not yet been trained under this contract.

## Earlier Designs And Results

The proposed **Hybrid Edit Transformer** combines typed e-graph incidence,
a nine-family repair vocabulary, and concrete counterexamples. It learns to
choose executable source edits; it never learns authority to merge e-classes.

Read [the specification](SPECIFICATION.md) and
[standalone Lean contracts](formal/HybridRepair.lean), followed by the
[proof/implementation ledger](OBLIGATIONS.md) and
[bounded prototype results](PROTOTYPE-RESULTS.md). The design preserves the
existing canonical metric, including pairwise alpha minimization and unordered
minimum-cost assignment. It does not reuse readable edit strings as ground-truth
programs. Earlier results and failures are archived in
[the failure ledger](../repair-search/FAILURE-MODES.md).

The initial study is now **508M/710M/911M from scratch**, each with BF16/W8/W4
variants. [Pilot scope](PILOT-SCOPE.md) restricts the source language and actions
to keep the vocabulary at 128 IDs, with 97 assigned tokens and four replacement
templates. Larger 1.64-4.86B configurations remain an optional later scale study.
The [pilot preflight](PILOT-RESULTS.md) records actual 508M-911M GPU steps,
the bounded checks and the retained learning-rate failure.
The [effective-batch study](BATCH-RESULTS.md) records the requested 508M/128
and 710M/96 batch trials, weighted gradient accumulation, adaptive-optimizer
memory, and the retained numerical failures. Further 911M trials are deferred.
The v2 compact banks use eight signatures, eight alpha slots and eight named
relations, plus shared built-ins and literals 0-4. See the
[historical symbol census](VOCABULARY-CENSUS.md) for the comparison with `node_id.csv`.
QAT fake quantization is not packed low-memory training. Model fit,
source-backed labels, full-graph export and executable
action coverage must pass before long training. None is inferred from a parameter
count or from the earlier failed graph-policy pilots.

```bash
lean -o /tmp/HybridRepair.olean docs/canonical-edit-learning/formal/HybridRepair.lean
```

Theorems establish model-level container behavior, scoped occurrence separation,
finite-menu minimization, guarded commits, counterexample rejection and parameter
accounting. Actual serializer round trips, certified renaming transport,
Java-to-Lean correspondence, CUDA/optimizer numerics and learning effectiveness
are separate proof/test obligations. Full implementation refinement remains open.

A [self-contained PyTorch implementation](../../experiments/hybrid_edit/README.md)
provides nine pilot and eight later candidate configurations, resident INT4/INT8
QAT, bounded scope/token/menu gates, numeric and INT4 codecs, synthetic training
probes, effective-batch accumulation and parameter-count tests. The
[source-backed corpus pilot](CORPUS-STUDY.md) connects the Java repair projection,
typed source graph, schema and concrete counterexamples to metric-grounded labels
and two-direction solver evaluation. Its separate corpus codec uses 102 of 128
IDs. The four edit templates and bounded input scope are not a complete repair
language or a full proof-graph exporter. See the
[development incident record](CORPUS-INCIDENTS.md) and
[13 additional Lean contracts](formal/CorpusTraining.lean).

The [first source-backed 508M training result](CORPUS-RESULTS.md) is negative:
0/192 held-out repairs at top 1 and 1/192 with three independent attempts.
Only 2/192 are repairable by any admitted single edit. Eight epochs fit the GPU,
but neither loss reduction nor memory fit establishes useful repair performance.

The [graph-to-complete-program study](GRAPH-PATH-STUDY.md) removes that action
menu. It pairs the faulty repair DAG and module schema with a replay-checked
COPY/BUILD program producing the entire target graph, using a lossless 128-ID
codec and a 503.6M-parameter autoregressive backbone. Its eight new
[Lean contracts](formal/GraphRepair.lean) precede the implementation. See the
[runner](../../experiments/graph_repair/README.md). Graph reconstruction is
reported separately from solver-verified behavioral repair.
The [first complete-program result](GRAPH-PATH-RESULTS.md) is also negative:
0/652 held-out exact graphs and 0/64 on a training-sample diagnostic after eight
epochs. All admitted teacher paths are expressible and replay correctly, but
the learned outputs fail basic graph structure. The one-step ceiling is removed;
useful repair performance is not established.

The [cross-study failure analysis](../repair-search/LEARNING-FAILURE-ANALYSIS.md)
explains the different bottlenecks across these scratch models, graph policies
and LLM adapters, with primary research sources and bounded diagnostic proposals.
