# Contextual Repair Episodes

Contract: `contextual-feedback-repair-v1`, 2026-10-04. This opt-in prototype uses
the existing `local-feedback-repair-v1` Java executor without changing its
certificate, metric, acceptance or query semantics. It does not replace any
historical trainer or establish a new corpus result.

## Learning Target

An episode is an ordered sequence:

```text
faulty predicate -> real validation -> public failure
-> proposed edit path -> committed candidate -> real validation
-> new failure or bounded success -> another attempt if budget remains
```

The model retains context across decisions and attempts. Its inputs are only
the current public graph, past public graphs/actions, draft state and returned
feedback. Oracle code, task identifiers, private goal annotations, future
observations and future outcomes are not features. The evaluator retains its
private oracle solely to provide genuine checks. Administrative task metadata
stays outside the policy boundary.

## Model And Controller

A typed graph encoder feeds a recurrent GRU memory across public observation
packets. The resulting context conditions the existing structured action/pointer
heads. Memory starts at zero for each episode; the GRU is not reset between
attempts. Existing address transport, container and type representations remain
unchanged. A separate outcome head predicts the next check's public status from
the pre-query candidate/context. A prediction never authorizes acceptance.

The controller, not the model, schedules initial VALIDATE and VALIDATE immediately
after a successful COMMIT or DELETE. STOP and VALIDATE are excluded from learned
action heads; ABSTAIN remains available. Failed constructions leave public
diagnostics in context and permit recovery. Every forced action is recorded and
charged by the same executor. A committed but unvalidated candidate is never
success. Only an actual closed executor state with SOLVED_WITHIN_PROFILE counts.
No remaining query, no decision fuel, deadline, encoding refusal or worker error
ends a run as success. Query exhaustion stops further construction.

This deliberately changes the control policy: it is not a drop-in comparison
with the old learned STOP policy. Report forced verification separately from
learned actions, and retain all failures and unsuccessful episodes.

## Demonstrations And Objective

The bounded bootstrap proposer enumerates legal unary cardinality changes to a
signature expression in a fixed public order. It cannot inspect an oracle or
construct a gold target difference. It observes checks only through the same
public episode API. Its narrow grammar is a diagnostic data source, not the
model's full action space or a claimed general repair algorithm.

Retain failed attempts and their outcomes, not only successful suffixes. Fresh
replay must reproduce every public pre/post packet before an episode can supply
training labels. Only training-split episodes may supply gradients. The first
objective is whole-episode action imitation plus pre-query outcome prediction.
Failed candidate proposals in public-search demonstrations are exploration
examples, not individually certified improvements. This is a bounded bootstrap,
not reinforcement learning, an optimal planner, or proof that the model reasons
about counterexamples. Successful and unsuccessful replayed episodes are eligible;
their observed success labels must not be fabricated from a proposed repair.

## Proof Process And Correspondence

`formal/ContextualRepair.lean` was written and compiled before this document and
the runtime implementation. Sixteen declarations cover these model claims:

- Commit invalidates a prior success receipt.
- A matching query consumes one query and one decision; exhausted budgets and
  stale receipts do not update the model state.
- Success requires a matching solved receipt; counterexample/unknown receipts
  cannot create it. Rejected constructions create no semantic receipt.
- Recurrent context at a prefix depends only on that prefix. Reset discards
  earlier context; a private annotation outside the public projection cannot
  affect a fixed policy. A concrete order-sensitive memory example is checked.
- Non-training or unreplayed examples are not admitted by the abstract guard.

The receipt model assumes one fixed task/session and authenticated checker
responses. It does not implement source/profile authentication. Proofs use Lean's
standard foundations (`propext`, `Quot.sound`, and `Classical.choice` for budget
arithmetic), with no new axiom, sorry or unsafe proof shortcut. They do not prove
floating-point recurrence, optimization, parser/solver correctness, universal
Java/Python refinement or repair effectiveness.

Runtime correspondence targets are `contextual.py` (scheduler, replay admission,
prefix context, structured policy and sequence loss), `test_contextual.py`
(source-backed causal/replay/budget/gradient fixtures), and
`contextual_preflight.py` (fresh proof/Java builds, checks and bounded training).
The runner must retain hashed inputs, failed outputs, checkpoint and actual
rollouts. Runtime tests are finite evidence, not whole-artifact mechanical closure.

## Limits And Next Gate

The first gate is an actual multi-attempt source episode, such as
`some S -> no S -> one S`, with each step evaluated against an oracle that only
the evaluator may access. The first wrong repair must produce a fresh failure
and leave the episode open; the final success must come from the real checker.
Also check unresolved outcomes, budget exhaustion, split isolation, fresh memory,
future-label exclusion and historical pointer transport.

The pilot is small and training-set-only. No large-model sweep, held-out advantage,
complete source coverage, learned search optimality or full corpus claim follows
from it. Broader demonstrations and matched-budget held-out evaluation are the
next experimental requirements, not results of this prototype.

The public enumerator is deliberately simple: an open-loop sequence of
cardinality candidates plus checker-controlled stopping can solve the two
positive fixtures. Therefore learning those sequences does not demonstrate that
recurrent memory or counterexample content is necessary for the repairs. Before
scaling, use context-dependent branching tasks and compare full context against
reset memory and counterexample-blinded inputs under the same query schedule.

## Reproduction

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.contextual_preflight /tmp/contextual-repair-new --updates 120
```

Use a fresh external output directory. The runner compiles the 16 model lemmas
twice, runs the unchanged base preflight and ten contextual tests, freshly
replays three synthetic training episodes (including an unsuccessful one), then
fits a 119,277-parameter graph/GRU model for the requested bounded updates.
CPU is sufficient; `--device cuda` is optional. It records free-running model
episodes, actual counterexamples, pre/post-action packets, gradient measurements,
checkpoint, logs and input/output hashes. `PROTOTYPE_CHECKED` means the finite
checks and pilot completed, not that a learnability or generalization gate passed.
