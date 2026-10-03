# Proof-First Alloy Repair Environment

This is the first implementation slice of [the RL proposal](../egraph-rl-proposal.md),
not a trained learner or a replacement for the publication experiments. Work order:
Lean model and proofs first, this contract second, Java implementation and bounded
correspondence checks third. No new semantic rewrite or theory authority is added.

The subsequent [RL-2/RL-3 implementation](RL2-RL3.md) adds a profile-bound Alloy
evaluator and a CUDA structured-graph actor/critic over these same actions.
This page describes the standalone RL-0/RL-1 explorer and its original contract.
The [application assurance ledger](APPLICATION-ASSURANCE.md) separates external
TCB components, proved contracts, executable Lean admission, and open
implementation-refinement obligations for the learning extension.
The [graph encoder comparison](GRAPH-ENCODERS.md) describes MPNN/GCN/GAT/GIN
selection and its bounded CUDA experiment launcher.

## Initial Executable Scope

Self-contained modules, an explicitly selected parameterless predicate, and an
explicitly selected parser-owned command independent of that predicate. The first
action menu contains formula-operator replacement, relational union/intersection/
difference replacement, relation-cardinality replacement, formula negation wrap/
unwrap, and a stop request. Binding-quantifier replacement is included only when
its original source token is unambiguous. All are source-occurrence edits.

The first slice does not implement reference replacement, operand insertion/
deletion, arbitrary binding-tuple changes, temporal edits, imports, callable
signature changes, synthesis, a rewarder, learning, or global e-class mutation.
Feedback and learning are available through the separate RL-2/RL-3 runner;
the other excluded actions remain follow-up work. The explorer rejects temporal models,
recursive candidate dependencies, and commands/facts whose meaning depends on
the edited predicate. A neutral `run {}` with the desired bounds is appropriate.
It must not silently generate a replacement profile for a dependent command.

Example input:

```alloy
sig S { r: set S }
pred candidate { all x: S | some x.r }
pred oracle { all x: S | no x.r }
run {} for 3
```

The oracle remains outside the action vocabulary. This slice explores candidate
programs but does not claim that a candidate repairs the specification. `Stop`
is a request to finish exploration, not evidence of equivalence.

## Lean Contract

[RepairKernel.lean](formal/RepairKernel.lean) defines a small intrinsically typed
term language and one-hole contexts. A hole records both its sort and lexical
environment, separately from the enclosing term. Bound variables require a valid
indexed lookup. The type-indexed `plug` function constructs the replacement in
that environment without modifying a sibling or enclosing binder domain.

The source model is `before ++ replacement ++ after`. Its prefix and suffix
theorems state precisely which source material must stay unchanged. They do not
establish that an Alloy parser's positions denote the intended source occurrence.
Java must check source-span ownership, the target-body boundary, expected old
text, and fresh action identity, and must reparse the resulting module.

The controller model has revision, remaining attempts, applied-edit count,
stopped flag, context identity, and theory identity. Every attempt against an
active state consumes one unit, including stale or rejected proposals. Neither
kind changes the candidate revision. Accepted transitions increment it once.
Closed/exhausted states do not change. Context and theory identities are invariant.
Stop, stale, and unadmitted transitions cannot be reported as applied.

Failure atomicity means no candidate/module mutation: rejected attempts still
consume budget. This prevents the old recursive retry behavior from defeating
the episode bound. The controller deliberately has no `SOLVED` outcome.

Fifteen theorem declarations are checked without `sorry`, new `axiom`, or
`unsafe` declarations. The model contains no theorem that a repair preserves
meaning: it instead includes a concrete Boolean counterexample to that premise.

## Java Correspondence Contract

`RepairKernel.step` must match the Lean controller's ordering of guards. A finite
matrix varies remaining attempts in `{0,1,2,5}`, revision in `{0,3}`, and all four
Boolean flags: stopped, fresh, stop, admitted. The 128 output rows from Java and
Lean must agree exactly. This is bounded executable correspondence, not a proof
that all Java states refine Lean natural numbers. Java constructor bounds and
checked arithmetic must separately prevent overflow on supported paths.

`RepairTask` owns fixed surrounding source and a source-derived semantic profile.
The parser and `CanonicalAlloyPipeline.prepare(graph, profile)` are acceptance
gates. No compatible-profile fallback or hand-constructed `RepairView` is allowed.
Preparing a fresh candidate must preserve the task profile, surrounding bytes,
target signature, and context checks. It must not mutate a preceding candidate.

`RepairAction` carries the task/candidate/revision identity, expected source text,
offsets, lexical occurrence path, and action payload. Production steps accept only
actions minted by the current candidate's enumerator. Local relational type masks
are conservative; complete reparsing and certificate-integrated preparation are
still mandatory. Ambiguous spans or unsupported families are not editable.

The action menu is source-backed. This slice does not claim a bijection to
normalized e-nodes or an inverse of normalization. The canonical observation and
repair view describe the complete resulting candidate. Ambiguous graph-to-source
edits are deferred instead of guessing at an inverse mapping.

`RepairSearch` is bounded exploration, with deterministic beam and seeded random
modes over the same action menu. Beam ordering uses edit depth/source size, not
oracle bodies. It reports candidates and costs, not successful repairs. Search
deduplication uses complete candidate source within one task; it does not collapse
different action neighborhoods based only on an equality hash.

## Gates and Evidence

From the repository root (JDK 17, the bundled `lib/*.jar`, Python 3, and Lean
4.33.0 must already be available; no network access is needed):

```bash
./scripts/run_rl_repair_tests.sh /tmp/acgn-rl-check-01
./scripts/run_repair_explorer.sh docs/rl-repair/fixtures/basic.als \
  candidate 0 oracle BEAM 42 12 /tmp/acgn-repair-candidates.json
```

Use a new output location for each command. The first writes `report.json`, its
Markdown rendering, input/verifier manifests, logs, and two independent builds.
The second compiles the Lean model before Java and explores at most 12 attempts.
Change `BEAM` to `RANDOM` for the seeded baseline. It writes candidate bodies,
theory/profile identifiers, canonical observations, and distances from the
original, with semantic validation explicitly `NOT_RUN`. `sourceHash` denotes
the package's length-prefixed SHA-256 content identifier, not raw `sha256sum`.

The explorer launcher uses a 2 GiB heap and a whole-process timeout (120 seconds
by default, configurable with `REPAIR_TIMEOUT_SECONDS`). The environment itself
does not implement killable per-action workers. The RL-2/RL-3 supervisor adds a
killable Java worker, recorded trajectories, semantic feedback, and training;
multi-worker throughput evaluation remains future work.
Source/menu/attempt bounds are not a guarantee of constant preparation cost.

The finite gate inventory is in [claims.json](claims.json). The dedicated runner
must compile the proof before compiling Java, compare the controller matrix,
execute real-source regression fixtures and selected existing metric tests,
and repeat from two fresh build directories. It must hash the relevant source,
proof, dependency, verifier, and contract inputs before and after execution.
Logs and a machine-readable report go to a separate output root, never a
publication-results directory. A changed input invalidates the result.

Registered evidence is: Lean kernel checking, exact matrix comparison, bounded
Java source-to-result assertions, existing metric regression tests, and byte
comparison of the two clean builds. Documentation and model-generated opinions
are not verifiers. No full-corpus or learning experiment is part of this slice.

Trusted dependencies are Lean/Std, the JDK/JVM, Alloy and the existing parser/
normalizer/certificate pipeline, Python and shell tooling, SHA-256, the OS and
hardware. Their versions and input hashes are recorded by the runner. Model
theorems and bounded Java evidence do not discharge whole-parser, whole-Java,
whole-certificate-system, or unbounded Alloy soundness obligations.

The claim IDs refer to this document's corresponding Lean, Java correspondence,
source-fixture, regression, clean-build, and evidence statements. The runner
registers those bindings mechanically. A run ID combines the inventory version
and input-root hash; changed inputs cannot inherit a previous result. Exit codes
are 0 for `VERIFIED`, 1 for `BLOCKED`, and 2 for `INFRASTRUCTURE_FAILURE`. A timeout
does not pass a claim. No manual override or result from an earlier root is used.

## Failure and Review Ledger

- Pre-implementation: a command that calls the editable predicate can change its
  source semantic profile when the body changes. Decision: explicitly reject that
  scope in this slice; require an independent source command, not synthetic authority.
- Pre-implementation: read-only canonical observations do not carry an executable
  inverse edit mapping. Decision: source-backed occurrence actions with a complete
  reparse/prepare gate; no direct mutation of frozen e-classes or repair views.
- Pre-implementation: unchanged state on invalid attempts can permit unbounded
  retries. Decision: preserve candidate bytes but decrement the attempt budget.
- Proof development: Lean reserved identifiers `Sort`/`prefix` were replaced with
  ordinary identifiers; initial failed compilations produced no accepted evidence.
- Source test: Alloy reports the span of `not (some x.r)` as `not (some x.r`,
  omitting the closing parenthesis. Reconstructing an unwrap from that fragment
  produced invalid Alloy. The source-splice proofs still apply, but do not certify
  parser spans. Repair: unwrap only the parser-owned negation token, and omit
  whole-fragment edits whose delimiters are incomplete or whose comments/strings
  would require lexical reconstruction. Keep the actual parenthesized regression.
- Context test: `run candidate` is resolved by Alloy to an inlined body, so a
  call-node-only dependency scan missed it. Repair: also reject context expressions
  whose parser-owned source span lies in the editable body. Retain the direct-run
  fixture alongside transitive call and fact checks; no broader profile fallback.
- Occurrence review: replacing only a binary token can regroup its children when
  operator precedence changes (`A implies B implies C` to `A and B implies C`).
  The new `relabel_binary_keeps_children` Lean theorem fixes the intended abstract
  operation. Realization must parenthesize both unchanged operands and the whole
  replacement, or omit an incomplete source span. Keep a bounded Alloy witness
  distinguishing the intended tree from the precedence-changing token edit.

The later result report must distinguish proved abstract contracts, tested Java
behavior, and excluded functionality. Discovery of additional rewrites is not a
reason to expand the fixed theory or this implementation slice.
