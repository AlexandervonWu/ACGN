# E-Graph Guided Reinforcement Learning for Alloy Repair

Status: bounded RL-0/RL-1 and RL-2/RL-3 implementations are documented in
[the proof-first repair package](rl-repair/README.md) and
[the structured CUDA learner](rl-repair/RL2-RL3.md). The remaining
milestones below are a specification, not completed functionality. Inspected at commit
`1e2667351532b0c632166fa21ae5fbc7308a8fe7`. No learning run or new performance
measurement accompanies this specification.

## 1. Recommendation

Rebuild the learning loop around **typed, occurrence-addressed program repairs**,
using CanDis as the semantic representation and comparison layer. Preserve the
original ACGN objective of generating Alloy code, but start with repairing a
complete faulty predicate. Generation from an empty, typed sketch is a later
extension of the same action environment.

The learner chooses a repair; it does not decide which equations are true.
Equality saturation normalizes a candidate using the existing immutable theory
R0. A meaning-changing repair creates another candidate, never an equality union
between the old candidate and the desired answer.

This is a proposed experiment, not a claim that adding e-graphs will make RL
effective. A typed non-learning search using exactly the same actions and budgets
must establish the baseline first.

## 2. What the Existing Code Provides

The original path is `RLTest -> CodeGenAgent -> Generator -> Rewarder ->
backpropagate`. The following are source observations, not a new execution audit.

- [RLAgentFrame](../src/is/fivefivefive/ACGN/learn/RLAgentFrame.java) explicitly
  identifies itself as non-functional. It is not the foundation to revive.
- [CodeGenAgent](../src/is/fivefivefive/ACGN/learn/CodeGenAgent.java) generates a
  fresh `Multigraph` for each attempt. Its distributions are primarily indexed
  by parent symbol and child position, with scope-local distributions. These
  keys do not describe the complete candidate or remaining repair problem.
  `updateQTable` smooths immediate reward into probabilities and applies a
  softmax; it is not a state-action Bellman update. `generateNextPred` recursively
  restarts on its step bound, so a local bound is not an episode bound.
- [RLTest](../src/is/fivefivefive/ACGN/test/RLTest.java) obtains the student graph
  but starts generation afresh; it also uses fixed forest indices and stops at
  scalar reward 1. Its process-wide output redirection is unsuitable for a new
  concurrent runner.
- [Rewarder](../src/is/fivefivefive/ACGN/learn/Rewarder.java) provides useful
  positive/negative examples and counterexample-query ideas. However, it uses
  `Hyperparams.SCOPE`, generates its own commands, returns a scalar, and walks
  `A4Solution.next()` from the pool head rather than explicitly enumerating the
  retained LFU entries. Reusing it unchanged would not establish the new pool,
  source-context, or evidence-status contracts. Preserve it for existing reports.
- [InstancePool](../src/is/fivefivefive/ACGN/util/InstancePool.java) motivates a
  bounded counterexample store. The new evaluator needs explicit snapshot
  iteration and tested insertion/eviction semantics, not reliance on solver
  enumeration order.
- `MASGVisitor`, symbol/type/call resolution, and dataset conventions are useful
  input infrastructure. `EdgeCounter`/`Probability` may supply a train-only
  grammar prior, not semantic authority or mandatory old serialized state.

The new reusable boundary is
[CanonicalAlloyPipeline](../src/is/fivefivefive/CanDis/CanonicalAlloyPipeline.java):

- `prepare(graph, semanticProfile)` creates the certificate-integrated
  representation; do not silently use its fixed-profile compatibility overload.
- `Prepared.repairView()` exposes immutable phases, binding roles, declaration
  tuples, and certified container/scope metadata.
- `distanceEvaluation` evaluates the established repair metric, retaining
  temporal, quantifier, and matrix components. `CanonicalDistance` remains the
  metric specification, not a heuristic to replace with representative TED.
- `compactForComparison()` drops construction-heavy state while retaining
  observations and repair views. Proof export must occur before compaction, or
  the candidate must be re-prepared through the proof-retaining entry point.
- [QuotientRepairDistance.Result](../src/is/fivefivefive/CanDis/metric/QuotientRepairDistance.java)
  currently exposes costs, authority, and alignment statistics, not an executable
  edit script. Fast Rewrite `Canonical.edits` returns readable strings, not a
  certified patch language.
- [CanonicalBacktranslator](../src/is/fivefivefive/CanDis/CanonicalBacktranslator.java)
  emits Alloy from `NormalForm`; it is not an arbitrary typed-port graph or
  `RepairView` extractor. Its predicate helpers emit parameterless predicates.

The existing three layers remain intact: semantic admissibility, deterministic
equality observation, and the established repair geometry on that quotient.

## 3. Scope and Research Question

Primary question: under an equal candidate, solver, and time budget, does a
learned policy over typed repairs solve more faulty predicates, or reach equally
small repairs sooner, than typed enumeration or beam search?

MVP: complete parameterless, non-temporal predicates; existing signatures,
fields, imports, and non-recursive supported calls; Boolean/relational operators
and source-bound quantifiers already handled by CanDis. Fix the model context,
target signature, command, and existing theory. Enumerate a finite action set
from the model vocabulary and explicitly bounded templates.

Subsequent milestones add declaration insertion/deletion, temporal-phase edits,
parameterized predicates, functions, then typed-sketch synthesis. Unsupported
inputs receive explicit coverage results; the MVP does not claim a corpus-wide
repair capability. Existing analyzer support is not automatically editable
support. No new rewrite families or adaptive theory admissions are part of this
proposal; missing equivalences are logged as evaluation data.

Assumed deployment: the student predicate and model are visible to the policy;
an oracle/checker service supplies examples and evaluations. Oracle bodies are
hidden from the policy and action generator. If correct bodies are made visible,
report a separate oracle-assisted experiment with a direct-copy baseline.

The learner receives a filtered `PolicyTaskView`, not the entire paired dataset
module. Exclude oracle and correct-reference callable names as action targets,
including aliases and transitive helper calls that reach them. The evaluator
retains the full module privately and rejects such dependencies in a generated
candidate. Otherwise a single `invXC[]` call would bypass the repair task even
without exposing the oracle body.

## 4. Task and State Contracts

`RepairTask` contains original module bytes and resolved import hashes, a
qualified target identity, original candidate body, allowed model vocabulary,
selected parser-owned source command, solver options, semantic-profile digest,
oracle handle, train/evaluation split identity, seed, and budgets. Keep facts,
signature declarations, field declarations, other callable bodies, and target
parameters fixed. The task is rejected if the command is ambiguous.

`RepairState` contains a complete current candidate AST/source, source hash,
occurrence-to-normal-form mapping, compact prepared representation, remaining
budgets, accumulated action cost, immutable evidence-bank version, and theory
version. Representation failures remain typed failures, never empty formulas
or zero distances.

Policy features include operator signatures and result types, Seq/Bag/Set
semantics, binder roles and exchange/dependency classes, temporal paths, typed
neighborhoods, edit history, and candidate outcomes on permitted examples.
Raw source spellings and arbitrary e-class IDs are not variable identity.
Parameter position, scope, binder owner, and phase-local imports remain visible.

Distinguish the **semantic key** from the **execution-state key**. Equal canonical
observations permit caching compatible semantic results; they do not alone
justify merging RL states with different editable occurrences, costs, budgets,
or evidence banks. Prune equivalent states only when their action interfaces
match and cost/budget dominance is established. Hash keys are indices; confirm
the corresponding full identity on collision.

## 5. Action Algebra

New `RepairAction` values are data, with a schema version, action family, typed
payload, candidate hash, occurrence path, phase path, binder context, and checked
preconditions. Never address a repair by a globally shared e-class ID alone.

Initial action families:

1. `ReplaceOperator`: change an operator at one occurrence, retaining compatible
   children and checking the exact operator signature, not just arity.
2. `ReplaceReference`: select an in-scope compatible field, signature, constant,
   or binder coordinate; do not capture a variable or use an unrelated lineage.
3. `InsertOperand` / `DeleteOperand`: modify one variadic container occurrence
   with its permitted identity and cardinality rules. Set insertion of a duplicate
   can be a semantic no-op; Bag multiplicities and Seq positions remain distinct.
4. `Wrap` / `Unwrap`: apply a bounded, typed unary template. Boolean negation is
   permitted only on formulas; it is not relational complement.
5. `ModifyBindingTuple`: change quantifier/type/cardinality/disjointness-class
   membership atomically, then recheck the body and normalize. Existing tuples
   remain the metric's one-unit declaration repairs; legality metadata is not a
   learnable field.
6. `Stop`: request terminal validation, not assert success.

Later actions introduce/remove a binder with explicit use-site handling, and
modify temporal operators without relocating declarations across phase barriers.
An action never patches a sealed `RepairView` or constructs its own authority.

Exact signature guards distinguish integer addition from relational union,
ordered dependent JOIN/ARROW chains from arbitrary associative operators, and
subtype compatibility from equality of printed type names. Reuse current law and
type machinery; do not introduce a permissive `univ` fallback.

Action identifiers use rooted occurrences plus verified binding mappings.
When an e-class has several uses, changing one use clones that candidate path;
it must not silently change every use. A stale candidate hash invalidates the
action. Scope/type masks reduce invalid proposals, but the parser and pipeline
remain the authoritative acceptance gate.

## 6. Transition and Source Realization

```text
current source + normalized observation
  -> enumerate bounded typed actions
  -> policy selects an occurrence-specific action
  -> apply to a fresh candidate draft
  -> emit source in the unchanged model context
  -> parse and type-check the complete candidate
  -> derive/confirm source-bound profile and context identity
  -> normalize with R0 and build the certificate-integrated representation
  -> freeze/compact, evaluate, and record the transition
```

Start with an AST/source occurrence editor linked to normalized locations.
Normalization may expand, duplicate, reorder, or remove source nodes, so that
link is not presumed bijective. Ambiguous inverse mappings are rejected by the
MVP action compiler, not guessed. A later normalized-draft emitter may use the
backtranslator, with explicit parameter/function extensions and round-trip gates.

Every accepted candidate is reparsed from emitted source. Test unchanged regions,
binding references, imported declarations, and source-to-normalized correspondence.
Bounded solver checks of round trips provide separate evidence, not an unbounded
Java-to-Alloy theorem. Repair transitions are deliberately not equality proofs;
normalization within each candidate still uses the existing equality boundary.

The distance is not assumed to equal the shortest *executable* repair episode:
typed intermediates and finite action templates may restrict that search space.
Log action count, accumulated edit cost, and original-to-final metric distance
separately. Do not claim global minimal repair from a bounded search.

## 7. Semantic Evaluation and Evidence

Implement a new `RepairEvaluator`; leave historical `Rewarder` and its published
measurements unchanged. Use explicit result fields instead of one success float:

```text
parse/type: VALID | INVALID | UNSUPPORTED
construction: READY | REJECTED | RESOURCE_LIMIT | ERROR
solver: COUNTEREXAMPLE | NO_COUNTEREXAMPLE_WITHIN_PROFILE | UNKNOWN | ERROR
certificate: NOT_REQUESTED | VERIFIED | UNCHECKABLE | REJECTED
episode: RUNNING | SOLVED_WITHIN_PROFILE | EXHAUSTED | ABORTED
```

Report in-process observation equality separately from independent replay.
Source hashes bind provenance; they do not by themselves prove normalization.
Retain the current limits of independent certificate coverage. Certificate
`UNCHECKABLE` is not `VERIFIED`, nor proof that a candidate is semantically wrong.

For Boolean candidates C, oracle O, and fixed model facts F, query
`F and (C and not O)` and `F and (O and not C)` under the same selected profile.
The first supplies underconstraint witnesses; the second supplies overconstraint
witnesses. Both must return actual UNSAT results before reporting bounded success.
Nulls, cancellation, and timeouts are not UNSAT. Separately check that F admits
instances and report vacuous contexts. Handle tautological/unsatisfiable oracles
with an explicit absent-positive/absent-negative class, not division by zero.

Pool size 100 means a cap of 100 actual retained instances per available class,
not 100 calls to `next()` from one cached head. Inserted counterexamples must be
iterated in later evaluations. Record sample counts, errors in each direction,
and bank hashes. Never infer success from sample accuracy 1 alone.

Freeze the evidence bank during an on-policy rollout. On a new counterexample,
end/segment the rollout, version the bank, and rescore before further comparisons.
Do not compare cached rewards across bank versions or mix changed rewards into
old replay targets. Treat solver failures as censored infrastructure outcomes,
not as ordinary semantic negative examples.

Temporal support must reuse the *validated command-preparation behavior* from
`CapabilitySoundnessCheck`, with a separately tested adapter: its mode-detection
workaround is currently local, not automatically present in `Rewarder` or
`AlloyEquivalenceValidator`. Record and check actual trace bounds, including
temporal operators inside calls. Extend this evaluator before enabling temporal
repair episodes.

## 8. Objective and Reward

Prioritize bounded semantic success. Among validated solutions, rank by the
existing distance from the original faulty predicate, then source edit size and
search cost. Distance to an oracle is guidance toward a solution, not the final
minimal-change objective.

Proposed finite-horizon training reward, with all coefficients in the manifest:

```text
r(s,a,s') = R(s,a,s') + lambda * (gamma * Phi(s') - Phi(s))

R = successBonus * newlyValidatedSuccess - editPenalty * actionCost

Phi(s) = -[wE * sampledError(s) + wD * normalizedDistanceToTrainingTruth(s)]
normalizedDistanceToTrainingTruth(s)
  = min over compatible training truths t of D(candidate(s), t)
    / max(1, originalCandidateRepairSize)
```

Use a fixed original-size denominator to prevent a candidate from improving its
ratio merely by inflating its size. Ratios may exceed one. Hold truths, weights,
profile, and bank fixed within a rollout; set Phi to zero at genuine terminal
states. If a resource interruption is only a truncation, retain/bootstrap its
value or censor it explicitly instead of treating it as semantic failure.

The discounted shaping sum telescopes to `-Phi(s0) + gamma^T * Phi(sT)`.
This explains the intended shaping contract for the fixed environment; it is
not a guarantee under changed pools, adaptive coefficients, or selective failures.
The actor-critic uses that same discount and terminal convention.

Use gamma = 1 as the initial finite-horizon configuration, and choose the
success bonus above the configured maximum episode edit penalty. A terminal
original-to-final distance penalty is an explicit ablation, not an unnoticed
replacement of the action cost. Training reward is a search incentive; final
solution ranking still uses the semantic-success-then-repair-distance ordering.

Train with and without the distance term. The archived nearest-distance/reward
correlation is weak (see the current README), so distance must not replace the
semantic evaluator. Sample scores and shaping never issue equality certificates.

The default actor receives no oracle bodies, truth distances, or reference-derived
action templates. Training can use those distances internally for reward/teacher
construction. At held-out inference the checker may answer allowed queries but
the learned policy remains target-body blind. Log any privileged oracle-assisted
variant separately; include its direct-copy baseline.

## 9. Learning and Search

First implement deterministic bounded beam search and seeded random typed search.
They share action enumeration, validation, caching, and budgets with the learner.
Canonical merging of search nodes uses the execution-state contract above, not
equality hashes alone.

The initial learned policy should be a small masked linear/MLP action scorer with
a value baseline and a specified on-policy policy-gradient update. A Java linear
softmax policy is sufficient for the first experiment and avoids introducing a
GPU/framework dependency. Separate value estimates, logits, and normalized action
probabilities; record masks and actual sampling probabilities for credit assignment.

Use finite, executed repair trajectories for optional supervised warm-starting.
Generate them by bounded search on training questions. Existing nearest-truth
rankings select possible goals, not guaranteed action sequences. If exposing
structured metric alignments later, derive them from the same distance recurrence
and test cost agreement; readable Fast Rewrite edit strings are not gold patches.

Only add a graph neural encoder or an external trainer if the simpler policy
improves on non-learning search. Any such adapter receives immutable typed graph
features, never write access to certificates, law registries, or trust pins.

## 10. Proposed New Package Boundary

Place the new experiment under `is.fivefivefive.ACGN.repair`, not inside the metric
or certificate kernel. The following names are proposals, not existing APIs:

- `RepairTaskLoader`: dataset/callable selection and source-command identity.
- `CandidatePreparer`: source, normalized views, phase-aware occurrence mapping.
- `RepairActionEnumerator` and `RepairActionCompiler`: masks and atomic draft edits.
- `RepairEnvironment`: seeded reset/step/stop, budgets, typed outcomes.
- `RepairEvaluator` and `CounterexampleBank`: profile-bound semantic feedback.
- `RepairPolicy`: deterministic score/sample interface and policy checkpoint.
- `RepairSearch`: beam/random/policy modes over the same environment.
- `RepairWorkerMain`: killable process boundary for preparation and solver work.
- `RepairExperiment`: grouped splits, manifests, trajectories, and reports.

Future CLI (not available yet): `RepairExperiment --manifest TASKS --policy
random|beam|learned --seed N --output RUN_ROOT`. A manifest explicitly records
mode, source profile, allowed actions, budgets, pool capacity, worker settings,
theory/version hashes, training split, checkpoint hash, and enabled evidence checks.

## 11. Runtime and Isolation

Keep preparation and solver jobs bounded by wall time and memory. Begin the pilot
with two child JVMs, each capped at 2 GiB, and a small coordinator; tune concurrency
from measured peak RSS, not logical CPU count alone. Do not nest independent
full-size solver and canonicalization pools. Kill and restart a child on timeout;
thread interruption alone does not guarantee a stopped solver.

Cache compact prepared truths per compatible task context. Candidate cache keys
include source/body/import identity, command profile, engine/theory version, and
normalization version; evaluator keys also include oracle and bank identity.
Bound entries and bytes, release losing construction graphs, export only requested
proof traces, and avoid retaining a `Prepared` graph per policy replay transition.
Do not claim incremental certificate graph editing: source re-preparation is the
initial safe boundary; measured incremental rebuilding is later work.

Fast Rewrite IR remains an optional explicitly labelled proposal-ordering mode.
It does not issue certificates, replace exact distances in reports, or justify
discarding a candidate as semantically duplicate in the certified mode. Compare
fast-guided and fully certificate-integrated search under the same budgets.

Progress records include completed episodes, active files/actions, preparation,
solver and training time, queue depth, memory/cache counts, and status totals.
No mutation of `classified-data`, published results, trust pins, or experimental
runners. New experiments write into a new run root.

## 12. Dataset and Evaluation Protocol

Use the existing dataset conventions and AST-identical audit before creating
training or truth pools. Freeze a hash-addressed eligible list; do not hardcode a
historic corpus count as the new runner's discovery rule.

Split by question/model family, not random files. Detect shared original submissions,
AST clones, and known duplicate question encodings across folders before assigning
groups. Held-out student solutions and held-out correct variants cannot enter
training priors, nearest-truth teachers, or action templates. A held-out oracle
may be used only through the declared evaluation service.

Report a separate within-question, submission-disjoint setting if desired; it
answers adaptation to known questions, not transfer to unseen specifications.
Do not publish the current all-corpus correct pool as a leakage-free training split.

Within each training task, oracle and student truths are co-equal only after
context-compatible loading and the declared semantic validation gate. A corpus
`CORRECT` label or shared invariant name alone cannot authorize importing a
different model's declarations or facts into the task.

Use identical eligible tasks and action coverage for random, beam, untrained-prior,
and learned policies. Ablate canonical deduplication, distance shaping, and Fast
Rewrite proposal ordering separately. Account for preparation, failed proposals,
teacher generation, training, solver calls, inference, and timeouts rather than
reporting only successful-candidate latency.

Primary measurements: solved-within-profile fraction, time/queries to first solve,
original-to-final repair distance, emitted AST/source size, invalid/unsupported/
timeout rates, unique semantic candidates explored, peak memory, and repair
quality by problem and original correctness label. Use multiple fixed seeds;
report paired task results and uncertainty. No promised gain before measurement.

Outputs: `run-manifest.json`, `tasks.jsonl`, `episodes.jsonl`, `transitions.jsonl`,
`counterexamples/`, `repairs/`, `evidence/`, checkpoint files, and `summary.md`.
Keep proof/replay outcomes separate from bounded solver outcomes in every report.

## 13. Implementation Gates

1. **RL-0, environment contract:** deterministic task loader, context fingerprints,
   candidate round trips, explicit statuses, and a scalar-free evaluator API.
2. **RL-1, executable repairs:** initial action families, occurrence/scope checking,
   trajectory replay, and bounded random/beam search. No learning dependency.
3. **RL-2, semantics and feedback:** real retained-instance iteration, profile-bound
   two-direction checks, bank versioning, resource isolation, and reward tests.
4. **RL-3, learner:** train-only trajectories, masked policy/value updates,
   deterministic checkpoints, and an equal-budget pilot against RL-1.
5. **RL-4, coverage:** binding insertion/deletion and temporal repairs, then callable
   parameters/functions. Each family has independent source-to-result regressions.
6. **RL-5, synthesis:** bounded typed holes and grammar completion. Incomplete terms
   never enter CanDis as valid Alloy formulas. Only closed, well-typed candidates
   enter normalization, distance, and semantic validation.

Go/no-go after RL-3: continue neural/large-corpus work only if the learned policy
offers a measured benefit or a clearly diagnosed reason for another bounded pilot.
Otherwise retain the useful typed repair engine without calling it successful RL.

## 14. Acceptance and Proof Obligations

Required deterministic regressions include seeded replay; atomic failed actions;
alpha-renamed inputs with correspondingly renamed actions; shared-node one-use
edits; Set idempotence versus Bag multiplicity; non-associative JOIN barriers;
integer/relational overloads; disjointness classes; capture/shadowing; declaration
changes that invalidate uses; inherited binders under sibling ONCE/ALWAYS phases;
type-changing calls; and stale source/phase handles.

Evaluator regressions include a candidate that fits samples but has a new solver
counterexample, that counterexample being evaluated next time, empty instance
classes, inconsistent facts, different bitwidths/overflow/scopes/imports, temporal
operators hidden in calls, and solver null/error/timeout. An inconsistent-context
or timeout result must never produce `SOLVED_WITHIN_PROFILE`.

Preserve the existing metric/kernel regression suites. Check that observing a
repair or training a policy cannot mutate R0 or authority. New source realization
and context bridges receive an explicit claims ledger with Lean contracts where
applicable and bounded Java correspondence tests. Prove the finite reward-shaping
telescoping identity and action invariants in the abstract model; do not relabel
those proofs as full Java refinement, policy optimality, or unbounded Alloy
equivalence. Learned scores themselves are never certificate evidence.

For each claimed supported family, retain an executable positive fixture and a
negative boundary fixture. Any action advertised as executable must replay to
the recorded candidate; any runtime failure is a typed outcome and remains in
the denominator. Coverage exclusions and remaining assurance gaps are published,
not hidden behind skipped episodes.

## 15. Illustrative Transition

Given `sig S { r: set S }`, an initial predicate may be
`all x: S | some x.r`, while the evaluation target is
`all y: S | no y.r`. Alpha alignment already handles x/y. A local formula action
changes `some x.r` to `no x.r`; the resulting complete source is reparsed and
normalized, then tested against the target.

The original and edited predicates must remain separate semantic candidates.
No union certificate is invented for the meaning-changing step. Count the
selected action and compute the resulting repair distance separately, without
assuming that every macro action costs one metric unit. An accepted bounded
solver result records its command domain, not an unbounded theorem.

## 16. Decisions Proposed for Approval

Start with repair rather than empty-sketch synthesis; keep Java as the semantic
runtime; use the immutable existing rewrite theory; require typed candidate
transitions and bounded semantic validation; establish non-learning baselines
before policy learning; and keep oracle source hidden from the default actor.

The first implementation would therefore be RL-0 and RL-1, not a rewrite of
`CodeGenAgent.backpropagate` or a change to `CanonicalDistance`.
