# Local, Feedback-Guided Repair With Recovery

Version: `local-feedback-repair-v1`, 2026-10-03.
Status: **FORMAL MODEL CHECKED; RUNTIME MIGRATION AND TRAINING NOT IMPLEMENTED**.

This is an additive refinement of [the predicate-only input and structured-action
contract](INTENT-PATH-SPECIFICATION.md). It preserves the existing canonical
metric, certified equivalence boundaries, inference information restriction and
historical experiments. It changes the proposed supervision and recovery loop,
not the meaning of repair success. The Lean model was compiled before writing
this specification. See [all claims and outstanding correspondence obligations](LOCAL-REPAIR-OBLIGATIONS.md).

## 1. Motivation And Scope

The [expanded GNN study](FEEDBACK-SCALING-RESULTS.md) produced nonzero gradients
and strong teacher-action fitting, but no held-out repairs. The current
[`FeedbackTeacherMain.compile`](../../src/is/fivefivefive/ACGN/repair/FeedbackTeacherMain.java)
queries the original, begins a root replacement, constructs the oracle body,
commits and stops. Its training paths contain no rejected-state or abort labels.
The learned test episodes instead produced 23,231 rejected commits across three
seeds. This motivates a testable change in supervision; it does not establish
that exposure mismatch is the sole cause, or that the new design will succeed.

The proposed task is **choose a localized source edit, reuse existing structure,
observe its consequences, and recover when necessary**. A repair may change
meaning. It is never an equality admission into the certified e-graph. Graph
sharing is a representation convenience, not permission to edit every occurrence
of an e-class simultaneously. No new semantic rewrite family is introduced.

## 2. State And Information Boundary

Let the fixed private task contract be `K`, and let

```text
s_t = (p_0, p_t, draft_t, revision_t, history_t, receipts_t,
       failedAttempts_t, decisionsLeft_t, queriesLeft_t, closed_t).
o_t = PublicViews(p_0, p_t, draft_t, history_t, receipts_t).
a_t ~ policy_theta(. | o_t).
```

`K` binds the actual module context, editable callable/region, reference behavior,
parser, type/certificate theory generation, and Alloy solving profile. Facts,
imports, helper declarations and solver scope remain fixed. The controller can
use them for checking without exposing them as extra model inputs.

The public observation contains only the faulty predicate and its allowed
derived structures, the learner's candidate/actions, and feedback actually
returned by its own prior queries. Keep the numeric graph, type DAG, binder,
source-occurrence and witness tables. Operator categories remain bounded;
signature/relation/variable identities use typed pointers, not arbitrary strings
or a target-derived vocabulary. Do not serialize the proof sidecar into prompts.

Oracle bodies, correct-pool graphs, task IDs, classification labels, hidden
requirements, unused module symbols, target-distance values, teacher suffixes
and future feedback are not inference features. Local masks cannot consult them.
Only source-derived diagnostic codes and public occurrence pointers may be
added. Raw private exceptions, module filenames and hidden helper text stay out.

For fixed public observation, weights and random seed, changing private teacher
annotations or target data must not change the chosen action. Future genuine
query responses may differ. The Lean projection lemma proves this for the
abstract record; exporter and neural-consumer correspondence remain separate.

## 3. Occurrence-Local Repair Transactions

Write the current source occurrence tree as `p_t = C[u]`, with one hole in `C`.
A local transaction constructs `v`, proposes `C[v]`, and leaves the source frame
outside the occurrence unchanged. The model proves

```text
size(C[v]) + size(u) = size(C[u]) + size(v).
```

It also proves preservation of the surrounding sibling lists. Two identical
occurrences remain separately editable. Normalization of the resulting program
can change its entire canonical view; the frame property concerns source editing,
not stability of canonical node IDs.

Use the existing nine temporal/binding/matrix edit families. Build with
`BEGIN`, typed operator/operand choices, `COPY`, binder declarations, `COMMIT`,
`DELETE` and `ABORT_DRAFT`; use explicit `VALIDATE`, `STOP` and `ABSTAIN` controls.
An operator replacement should retain compatible existing operands through reuse.
Copied open terms must pass exact destination type, binder and phase checks.
SEQ order, BAG multiplicity, certified SET semantics, CALL boundaries and
dependent JOIN/ARROW typing remain intact. No generic `univ` fallback is added.

Locality is a footprint/reuse property, not `site != 0`: changing the root
operator while keeping its operands is a local structural change. Whole-body
reconstruction can remain an explicitly tagged, bounded fallback, but must not
silently supply every training label. Report edit footprint and reuse separately
from repair success. Do not claim a hard footprint bound that was not configured.

Every semantic construction choice consumes a decision. Structural bookkeeping
does not. COPY is one checked pointer choice; construction of a fresh large
subtree still costs its operator and operand decisions. The abstract Lean draft
stores a completed candidate; it does not authorize an uncharged arbitrary
program-generation action in the implementation.

### Commit And Rejection

1. Bind the proposed source, task/context, source revision and checker versions.
2. Realize the occurrence edit; parse, type-check, prepare and check provenance.
3. Check public-table representability and refresh pointer maps before publication.
4. On success, atomically replace the committed source, clear the draft, advance
   the revision and charge one commit decision.
5. On failure, retain the committed source, record a structured local rejection,
   and charge the attempted decision. Permit abort or a genuinely changed draft.

A valid commit is not semantic success and does not create a solver receipt.
No equation asserting old/new equivalence is inserted into the e-graph. The
existing repair-distance edit units remain unchanged: transaction count,
construction length and metric distance are distinct quantities. A repair path
need not monotonically decrease a hidden distance, and that distance is not a
policy feature.

### Stable Retry Suppression

Use an exact controller key

```text
(task, fixed context, solving/type profile, theory generation, parser version,
 source revision, complete proposed candidate).
```

If checking also depends on an action family, occurrence or provenance transport,
include those dependencies in the context component. Do not key only by opcode,
site, a lossy hash, or a step nonce. Deterministic local typing/source/provenance
failures may suppress an identical attempt under the same context. A changed
candidate or relevant checker context gets a fresh check. Abort does not erase
the failure record. The cache never authorizes a candidate or asserts equivalence.

Timeout, UNKNOWN, memory/resource failures and other transient outcomes are not
stable semantic facts and must not enter this cache. Any uncertain classification
is transient. A suppressed attempt returns a public local status and consumes
its decision without calling the checker again. Recovery remains available;
retry suppression alone is not a theorem that a policy will choose it.

## 4. Counterexamples And Final Validation

A query operates only on the committed source with no active draft and positive
query/decision budgets. Charge the attempt, including timeout or inconclusive
outcomes. Authenticate the resulting receipt against the exact task/context,
profile, theory, parser, revision and candidate before accepting it. Only its
actual returned worlds enter the public transcript. A stale successful receipt
cannot certify a later edit.

For an explicitly fixed set of admissible worlds/traces `Omega_K`, success
requires source validity, a feasible fixed context, and both checks:

```text
no w in Omega_K satisfies candidate(w) and not target(w)
no w in Omega_K satisfies target(w) and not candidate(w).
```

These conditions imply agreement throughout `Omega_K`. A bounded Alloy result
does not establish equivalence outside the recorded solving profile. UNKNOWN,
timeout, infeasible context, exhausted budget, STOP, and agreement on a finite
example bank are not success. A failed STOP may close an unsuccessful episode.

For returned labelled examples `H_t`, define the diagnostic version space

```text
V(H_t) = { p | for every (w, b) in H_t, p(w) = b }.
```

An authentic distinguishing counterexample excludes the current candidate;
adding examples cannot restore an excluded candidate. A fixed target remains
consistent if all labels are faithful to it. These are model theorems, not a
complete symbolic search algorithm. Example consistency can guide proposals,
but cannot replace the final two-direction check. Hidden intent may remain
ambiguous after any finite transcript; querying or abstaining is legitimate.

## 5. Train On Actual Visited States

Freeze the question-group split before teacher generation. Use training tasks
only for expert-labelled rollouts and gradient updates. Selection remains on
validation; held-out results must not tune the expert, model or action policy.

At aggregation round `k`, freeze `theta_k`, then execute bounded learner rollouts
with the production public observation contract. Record pre-action snapshots,
source revisions, actions, actual query responses and controller provenance.
Include rejected drafts and semantically wrong but structurally valid candidates.
These states must not be replaced with the corresponding original faulty source.

At selected training snapshots, a bounded offline expert may consult the private
reference to search for source-realized local continuations. This privilege
provides labels only. It does not expose the oracle or a target graph as an input.
Metric edit traces can seed proposals but are not executable teacher paths until
realized and replay-checked. No shortest-path or expert-optimality claim is made.

Two label classes are admitted separately:

- **Semantic continuation:** replay from the actual visited snapshot establishes
  the first action and a suffix ending in source-bound, two-direction acceptance.
- **Structural recovery:** replay establishes an abort/rollback or other specified
  recovery postcondition. This can be useful without a validated repair suffix,
  but it is not a semantic-success certificate or a positive value target.

Bind each label to its exact pre-action observation and prefix. Independently
replay the prefix through the executor. If regenerated solver witnesses or row
addresses differ, require checked transport of the full state and labels;
otherwise record `REPLAY_DIVERGED` and do not admit that label. Never splice
future teacher counterexamples into an earlier observation or fabricate a query
response to make replay match. Offline search calls are logged separately from
the learner episode; only actually replayed episode responses are public.

```text
D_0 := replay-admitted local teacher and recovery examples from training tasks
for k in 0 .. K-1:
    freeze theta_k
    S_k := bounded_rollouts(theta_k, training tasks, genuine query interface)
    for pre_action_state s in S_k:
        proposals := bounded_expert_search(s, private training target)
        A(s) := joint first actions of replay-validated continuations
        R(s) := replay-checked structural recovery actions
        record failures, divergences and unavailable labels as coverage
        admit (PublicViews(s), A(s), R(s), provenance) only if all gates pass
    theta_(k+1) := train(D_0 plus admitted on-policy examples)
```

For each homogeneous label class with a nonempty set of complete alternatives,
use the proposed set-valued imitation objective

```text
L(theta; s, A) = -log sum_{a in unique(A)} policy_theta(a | PublicViews(s)).
```

Compute joint action probability using the factorized conditional heads and their
own prefix-dependent masks. Do not combine independently valid field marginals:
valid alternatives `(site0, op1)` and `(site1, op0)` do not license `(site0, op0)`.
Keep recovery/continuation sampling weights explicit and fixed before evaluation.
An empty validated label set is a coverage outcome, not an invented gold action.
Retain unresolved tasks in evaluation denominators and report supervision bias.

Numerical loss evaluation, gradient optimization and generalization are outside
these Lean proofs. PyTorch/CUDA remain numerical trusted dependencies. The
objective is a proposal to test, not a convergence or repair-success theorem.

## 6. Bounded Migration And Evaluation Plan

Start with a local-expert/recovery dataset and the existing small graph policy;
do not immediately increase model size. GNN, Qwen and scratch Transformer
consumers must eventually share the same public tables, action executor, query
budgets and success criterion. Changing model family cannot relax the contract.

Proposed initial bounds are 256 decisions, 8,192 public rows, eight retained
returned worlds, at most three aggregation rounds, 128 expert proposal checks
per labelled snapshot, beam width eight, and eight committed edits per searched
continuation. Count all construction choices and replay work, not just commits.
Each proposal/replay has a deadline; a finite proposal cap alone is not a runtime
bound. Record actual costs and censored search outcomes. These are prospective
study settings, not changes to the existing runner.

Run separately preregistered, matched query-budget arms: `Q=2` for compatibility
with the completed study, and `Q=4` for iterative feedback. Querying the original,
querying a failed candidate, then validating its revision requires at least three
queries. Do not compare a four-query learned policy against two-query controls.
Keep the existing 30-second response/120-second episode limits unless a new
manifest explicitly changes them. Timeout is never semantic acceptance.

Before scaling, require the existing 1/8/64-task free-running learnability gates
(1/1, 8/8, at least 60/64 repairs) alongside the following runtime fixtures:

- Local operator/quantifier changes with retained operands, without root rebuild.
- A rejected candidate followed by abort, changed draft and successful commit.
- A valid but wrong candidate followed by authentic feedback and a repaired query.
- An identical stable failure checked once, while a changed candidate is checked.
- Transient failure retry, stale pointers/receipts, and post-commit address refresh.
- COPY across incompatible type, binder, temporal and CALL contexts is rejected.
- Joint alternative labels reject invalid cross-products; private-input mutation
  leaves public tensors, masks and fixed-seed decisions unchanged.

The recorded `classroom_fol/both/civYseZNDBZGucmiX_inv4.als` rollout (seed 17)
is a concrete recovery regression seed: it spent 250 decisions on rejected
COMMITs after one draft. Reproduce its executor rejection before assigning a
diagnostic cause; the stored REJECTED status alone is not a type-error proof.

Report full and supported-only repair rates, admission failures, local reuse,
valid commit rate, duplicate rejected attempts, recovery success, real solver
calls, decisions and end-to-end resources. Compare matched no-op, uniform and
bounded-search controls; use three seeds and question-cluster uncertainty.
Teacher-forced loss/action accuracy remain diagnostics, never substitutes for
free-running repairs. Failed gates remain reported failures, not dropped tasks.

## 7. Proof Status And Reproduction

[LocalRepair.lean](formal/LocalRepair.lean) contains 42 general theorems;
[LocalRepairChecks.lean](formal/LocalRepairChecks.lean) contains 20 concrete
model regression theorems. Only Lean's standard `propext` and `Quot.sound`
occur in the printed dependencies; there are no admitted proof placeholders.
The [check runner](formal/check_local_repair.py) recompiles in two fresh
directories and writes source hashes, compiler identity, logs and theorem names:

```bash
python3 docs/canonical-edit-learning/formal/check_local_repair.py \
  --output /tmp/acgn-local-repair-proof-check
```

These checks are not a proof of the Java/Python implementation or Alloy solver,
nor a whole-artifact closure claim. Receipt authenticity, exact types/provenance,
replay admission, retry classification, exporters and runtime accounting have
explicit obligations in the ledger. No production runner, trainer, rewarder,
dataset, canonical metric or historical experimental output was changed here.
