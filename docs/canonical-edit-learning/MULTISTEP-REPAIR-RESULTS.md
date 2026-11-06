# Multistep Contextual Repair: Bounded Results

2026-10-04. **Synthetic composition holdout only; no natural-corpus result.**
See [the frozen design and proof correspondence](MULTISTEP-REPAIR.md) and
the [machine-readable results](results/multistep_repair_20261004/report.json).

## What Was Built

A 274,805-parameter two-layer GIN/GRU model selects complete structured edit
paths from a bounded grammar, executes them through the existing Java interface,
and receives a fresh Alloy check before another attempt. Recurrent memory is
carried between attempts, not reset after each failed candidate. No oracle
body, goal operator pair, task ID, source path or future result is a feature.

Each plan is seven construction decisions plus a real validation. The grammar
contains sixteen conjunctions of two signature-cardinality formulas, using
`no`, `one`, `lone`, and `some`. Plans come from the faulty expression's two
signature leaves, not a truth pool. This is a functioning, narrowly scoped
neural plan selector, not a general Alloy repair system.

Counterexample projection and per-plan disagreement are deterministic semantic
features. The neural network learns ranking and recurrent context; it does not
learn the cardinality interpreter from scratch. Only the unchanged Java/Alloy
evaluator can accept a repair. Evidence consistency alone never counts as success.

## Design And Results

There are 24 training tasks, 8 validation tasks and 8 test tasks. The target
operator-pair compositions are disjoint across those splits. Signature spellings
are renamed, but these remain synthetic tasks within one small grammar, not
held-out natural problem classes. All arms receive four queries, including the
initial check, and at most 256 construction decisions.

Public counterexample-guided search provided 24 freshly replayed training
episodes and 43 plan choices. Seventeen episodes include a failed intermediate
repair. All demonstrations eventually succeed; therefore this particular
training set does **not** add terminal budget-failure examples, although the
underlying contextual replay supports them and its regression tests cover them.

Nine models were trained for 400 updates each, with fixed seeds 17, 29 and 43.
There was no checkpoint, hyperparameter or seed selection based on held-out
results. Every update had finite loss and finite nonzero gradient norm.

Test repairs, in seed order:

- Persistent-memory model: **6/8, 7/8, 8/8**.
- Reset-memory model: **7/8, 7/8, 8/8**.
- Feedback-blinded model: **1/8, 2/8, 1/8**.
- Uniform untried-plan search: **2/8, 2/8, 1/8**.
- Deterministic full-history feedback search: **8/8**, one deterministic run.

Validation repairs in the same order are 6/8, 8/8, 7/8 for persistent memory;
6/8, 7/8, 8/8 for reset memory; 2/8, 2/8, 4/8 for blinded models; and
2/8, 0/8, 3/8 for random search. Deterministic feedback search achieves 8/8.
Training repairs are respectively 24/24, 23/24, 24/24; 24/24, 23/24, 23/24;
and 6/24, 6/24, 4/24 for the three learned arms.

The same eight test tasks recur across seeds; these are not 24 independent test
problems. No statistical-significance claim is made. All 424 evaluation rollouts
completed without worker errors, including 360 learned-policy and 64 baseline
episodes. Unsolved episodes remain in the denominators and end at the query
limit. Test mean queries are 2.625, 2.750, 2.625 for persistent memory and
2.625, 2.625, 2.250 for reset memory, compared with 2.500 for full-history search.

## Actual Learned Multistep Repair

Seed 17, held-out `case-039`, produced this sequence (signature names shortened
only for readability):

```alloy
one A and one B
-- Counterexample: #A = 0, #B = 1; expected true, actual false.
no A and one B
-- New counterexample: #A = 1, #B = 1; expected true, actual false.
lone A and one B
-- Real evaluator: SOLVED_WITHIN_PROFILE.
```

This uses three real queries and seventeen charged decisions. The second edit
is selected after the first repair has actually failed, not by replaying a
known target's edit path. The private goal `lone A and one B` is used only by the
evaluator. The trace, full numeric observations and checkpoint are archived.
Across test seeds, persistent-memory models have 1, 3 and 4 successful episodes
requiring at least two proposed repairs.

## Interpretation And Remaining Limits

The learned feedback-informed models outperform uniform search in all three
observed seeds, and blinding the counterexamples substantially reduces success.
This is positive bounded evidence for feedback-conditioned plan selection.
The reset-memory control matches or exceeds persistent memory: **the study does
not establish that the GRU improves repair**. Current source state, latest
feedback and the shared tried-plan mask can already convey much of the needed
context. The reset arm removes the learned recurrent state, not all search state.

On the eight test tasks, persistent models select 4/13, 2/14 and 1/13 plans
inconsistent with some already-observed counterexample. Reset models select
2/13, 3/13 and 0/10 such plans. These are unsuccessful proposals, not falsely
accepted repairs. They show that learned memory/auxiliary consistency prediction
does not reliably enforce accumulated evidence. Full-history deterministic
filtering, proved in the abstract finite model, avoids those choices and is
the stronger baseline here.

No comparison with the earlier failed 89-task natural-corpus benchmark is valid:
the data, plan grammar, controller and semantic feature engineering have changed.
No Qwen or roughly 500M training was launched. Extend the source-local plan
grammar and test genuinely history-dependent cases before claiming a reusable
repair learner. Keep exact evidence filtering as a baseline and separate it from
learned ranking in any subsequent hybrid.

## Verification, Incidents And Reproduction

Fifteen new Lean model declarations compiled before the implementation and again
in two fresh matching builds. They use only `propext` and `Quot.sound`, with no
new axiom, sorry or unsafe. Existing contextual/receipt models and the base
preflight were rebuilt. There are **363 passing Java/Python check executions**:
342 base checks, ten contextual tests and eleven new multistep tests. The latter
include actual Alloy execution of all sixteen plans, fresh replay, branching,
held-out refusal, missing-world-mapping refusal, blinding and finite gradients.
These are model proofs plus finite correspondence tests, not universal
Java/Python/Lean refinement or a proof of learning effectiveness.

Two preliminary test assumptions were corrected before the frozen study: a
blind arm intentionally retains query-count information, so changing that count
is not an invariance test; and different goals can yield the same first solver
counterexample. The branching regression now uses source-backed goals whose
returned evidence actually differs. No Java semantics were changed to make the
tests pass.

The run `/tmp/acgn-multistep-20261004-v1` completed in about 308 seconds on CPU,
including fresh proof/runtime builds, training and evaluation. Source HEAD is
`67cb5f3dfe226b15e2647fe6d18534fa03995cbc` with a dirty worktree; frozen content
hashes identify the implementation. The evidence directory retains manifests,
test/proof logs, all checkpoints, full trials, generated sources and a frozen
source archive. Historical corpus, result directories and Java implementation
were not changed in this task.

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_multistep /tmp/multistep-fresh
python3 docs/canonical-edit-learning/multistep_report.py /tmp/multistep-fresh /tmp/multistep-evidence-fresh
```

Both destinations must be fresh. The curator checks hashes, gradients,
checkpoint identity, rollout denominators, budgets and recorded acceptance,
then retains the evidence. `STUDY_COMPLETE` and `AUDIT_PASSED` are completion and
integrity statuses, not whole-artifact semantic closure.
