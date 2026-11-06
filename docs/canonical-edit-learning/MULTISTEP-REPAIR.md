# Multistep Contextual Plan Model

Contract: `multistep-contextual-repair-v1`. Opt-in, bounded synthetic experiment.
No changes to the Java repair executor, certification, metrics or corpus.

## Model And Scope

An attempt-level graph/GRU policy selects a structured repair path, executes that
path through the existing public Java controls, receives a real Alloy check and
selects another path if necessary. Memory resets between episodes, not attempts.
Only a closed `SOLVED_WITHIN_PROFILE` response is success. Budget exhaustion,
construction errors and consistency with observed worlds are not success.

The first learnability task is explicitly small: a conjunction of two unary
cardinality tests over distinct signature leaves. Each cardinality is one of
`no`, `one`, `lone`, `some`. Sixteen two-site plans are generated from the faulty
source, not from a correct-answer pool. A plan replaces the root with the chosen
conjunction using seven public construction decisions, followed by VALIDATE.
This is a bounded plan grammar, not arbitrary Alloy synthesis. Other shapes are
refused. Both signatures remain present in every plan; no correspondence by
oracle names or invented symbol identity is required.

The graph encoder receives the public source/canonical graphs. The attempt
encoder additionally receives the latest real query's worlds projected to the
two signature cardinalities (0, 1, or at least 2), expected/actual Boolean values,
and each plan's disagreement on those worlds. These are deterministic features
of returned counterexamples, not future outcomes or oracle bodies. No task ID,
path, split label, target operator pair or source spelling is a model feature.
Incomplete mappings and temporal worlds are refused, not interpreted as empty.

The candidate scoring head shares parameters across plans and conditions on the
current graph, latest counterexamples and recurrent attempt context. There is
also an auxiliary head learning each candidate's consistency with evidence so
far. This target is calculated from public feedback, not semantic acceptance.
Previously attempted plans are excluded for all arms, including blinded and
random controls. This public search-state mask supplies minimal shared memory;
the reset-memory arm therefore tests the GRU's incremental value, not total
absence of history.

## Supervision And Information Boundary

A deterministic baseline maintains the subset of sixteen plans consistent with
all observed counterexamples, then picks a surviving untried plan with minimum
operator-change count from the current expression. Ties have a fixed public
ordering. It reads exactly the same public packets as the learned policy and
does not see private goals. Training imitates these branching search episodes,
including unsuccessful budget-limited episodes. Fresh Java replay must reproduce
every packet and decision before training admission. Only train-split episodes
may supply gradients.

Training uses episode-level cross entropy for plan choice plus binary consistency
classification. This is imitation learning, not reinforcement learning. The
teacher is an explicit finite semantic learner; the neural policy need not
outperform it. Its full-history evidence filter is not imposed on neural choices:
neural models may choose witness-inconsistent plans and those failures are counted.

For matched ablations the graph view excludes feedback and action-history tables
for every model. Real logs retain them in full. Persistent and reset policies
receive latest-query evidence only; the blinded policy receives none. Blinding
also omits the derived disagreement features. It still receives the current
source, query count and tried-plan mask. Thus recurrent memory is not bypassed
by feeding the executor's cumulative feedback back into a supposedly reset arm.

## Frozen Pilot Design

Use synthetic two-signature Alloy modules at scope three. Split by target
operator-pair composition, not files: eight training compositions with three
initial pairs each (24 tasks), four validation compositions with two initial
pairs (8), four test compositions with two initial pairs (8). No target pair is
shared between splits. Use renamed signatures across splits. This is synthetic
compositional holdout, not question-disjoint or natural-corpus generalization.

All policies have four real queries including the initial check, 256 construction
decisions and a 120-second episode deadline. Train three matched policies
(`persistent`, `reset`, `blind`) with identical graph/scoring architecture and
training episodes. Use seeds 17, 29, 43, width 48, two GIN message layers, 400
updates, AdamW at 0.001, gradient clipping at 1. Final fixed-update checkpoints
are evaluated; do not select on test results. Also evaluate full-history
deterministic search and seeded uniform untried-plan search. Retain every episode
and denominator, error, attempt count, solver query count and failure outcome.

Required interpretation checks: training includes failed intermediate attempts;
same source can branch after different returned counterexamples; actual learned
rollouts use multiple checks; report policy success per seed and paired controls.
Finishing tests or improving training accuracy does not prove useful memory,
counterexample reasoning, stable superiority or corpus repair. Do not start
Qwen/large-transformer runs from this gate alone.

## Proof And Runtime Correspondence

`formal/MultistepRepair.lean` was compiled before this specification and runtime.
Fifteen model theorems establish cardinality clipping for this exact grammar,
two-site evaluation preservation, survivor origin/consistency, retention of an
authentic representable target across evidence, elimination of contradicted
candidates, non-growth of the version space, prefix causality, no-repeat selection,
strict fuel decrease, recurrent context extension and public-only policy inputs.
Concrete theorems distinguish consistency from equivalence and demonstrate
opposite required responses to two different counterexamples.

Correspondence targets: `multistep.py` implements the finite semantics, feedback
projection, planner, attempt encoder, episode controller and replay; tests compare
bounded semantic cases and actual Java/Alloy transitions. `train_multistep.py`
performs fresh proof/runtime builds, split checks, replay, fixed-budget training
and matched rollouts. No newly handwritten Alloy rewrite is introduced.

The Lean model assumes authentic Boolean feedback for complete worlds. Its
foundations are `propext` and `Quot.sound`, with no new axiom, sorry or unsafe.
Finite tests, not a universal refinement proof, connect world extraction, Java
source execution and PyTorch. Lean does not prove numerical training correctness,
generalization, Alloy parser/solver correctness or this implementation's behavior
on every possible input. The existing revision/receipt proof remains applicable
as a model; the production Java acceptance path is unchanged.

## Reproduction

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_multistep /tmp/acgn-multistep-new
```

Fresh external output only. CPU is sufficient; all evidence and small checkpoints
are stored there. The report separates passed bounded checks from empirical model
results. Frozen input/output hashes identify the dirty-worktree build.
