# Iterative Repair Learning: Findings And Failure Analysis

2026-10-04. Documentation and frozen-evidence publication, not a new artifact
release or a claim of natural-corpus repair success. No new training is performed
for this publication. The measured producers were dirty-tree development
snapshots; content hashes, not the publication commit, identify those producers.
Live training-code and Java edits are not incorporated by this documentation push.

## Conclusions

The latest small graph model beats evidence-filtered random search in each of
three seeds, but ties deterministic evidence-consistent minimum-change search.
Larger width gives no validation improvement. Resetting learned recurrent memory
changes some paths but not repair counts. Exact evidence retention is useful;
a benefit from learned memory or neural ranking over the strongest implemented
search baseline has not been established.

The natural-source coverage audit is **0/104** for the latest plan grammar.
This is not a measured 0/104 learned-repair rate: repair evaluation was not run
on those inputs. Synthetic successes do not overturn the earlier natural-task
failures or demonstrate a generally applicable Alloy repair learner.

## The Iterations

### 1. Larger Natural-Task Local Repair

The question-disjoint study retained 474 eligible training tasks, admitted 309
initial teacher trajectories, and evaluated 62 validation and 89 test tasks.
It screened GIN, larger GIN, attention and an MLP, up to 28.24M allocated
parameters. Every screen repaired 0/62. The smaller-model tie-break selected the
6.01M MLP; it repaired 0/89 in each of three seeds, tied with uniform/no-op
controls. There were 28 initial test coverage errors per seed, but all 61
executable episodes also failed. Coverage alone therefore does not explain zero
repairs. Many episodes stopped with counterexamples or consumed construction
decisions without using their full query budget.

This benchmark had already been used in an earlier study; it is not a newly
unseen evaluation. Source eligibility and failed episodes remain in the reported
denominators. [Machine report](../canonical-edit-learning/results/local_scaling_20261004/report.json),
[data report](../canonical-edit-learning/results/local_scaling_20261004/data-report.json),
[retained audit](../canonical-edit-learning/results/local_scaling_20261004/audit.json).

### 2. Small Contextual Multistep Plans

The next bounded study made entire executable plans the unit of choice, with
real checks after commits. It used 24 training, eight validation and eight test
tasks in a sixteen-plan, two-signature conjunction grammar. Training came from
public counterexample-guided search with fresh replay, rather than access to
the private target during inference.

Persistent-memory test repairs were 6/8, 7/8 and 8/8; reset-memory repairs were
7/8, 7/8 and 8/8. Feedback-blinded repairs were 1/8, 2/8 and 1/8; untried-plan
random search gave 2/8, 2/8 and 1/8. Deterministic full-history search gave 8/8.
Persistent policies proposed seven candidates already contradicted by earlier
counterexamples. These were rejected proposals, not falsely accepted repairs.
All training episodes eventually succeeded, despite containing intermediate
failures; terminal failures were absent from that particular training set.
[Machine report](../canonical-edit-learning/results/multistep_repair_20261004/report.json),
[retained audit](../canonical-edit-learning/results/multistep_repair_20261004/audit.json).

### 3. Variable-Arity Plans With Exact Evidence Memory

The latest study expanded to 144 training episodes, AND/OR, three-slot training,
32 held-out three-slot tasks and 32 unseen four-slot tasks. It retained all
thirteen query-limited teacher failures and included 72 exploratory prefixes.
Every episode received sixteen passes. The exact evidence filter excludes known
contradictions before the network ranks candidates. Validation selected the
smaller model: both sizes repaired 26/32.

In seed order 17, 29, 43, each slice has 32 tasks:

- Learned filtered policy: three-slot 25, 25, 25; four-slot 23, 23, 23.
- Same weights with memory reset: the same repair counts.
- Filtered random search: three-slot 21, 21, 20; four-slot 17, 13, 16.
- Same weights with the evidence filter disabled: three-slot 0, 1, 14;
  four-slot 1, 0, 11.
- Unfiltered random search: three-slot 0, 0, 0; four-slot 1, 0, 0.
- Deterministic search, one run: three-slot 25; four-slot 23.

The filtered model never contradicts retained evidence in its 468 proposals.
Its unfiltered intervention does so in 441/555 proposals. Those controls use the
same checkpoints, not separately retrained models. Masked-out plans receive no
direct ranking loss during training; this intervention establishes controller
dependence, not an impossibility result for learned consistency.

The three-slot test comprises four target-multiset groups with source variants,
not 32 independent problem classes. Repeated seeds are not new test tasks.
No significance claim or across-benchmark accuracy trend is made.
[Detailed results](../canonical-edit-learning/MULTISTEP-SCALING-RESULTS.md),
[machine report](../canonical-edit-learning/results/multistep_scaling_20261004/report.json),
[retained audit](../canonical-edit-learning/results/multistep_scaling_20261004/audit.json).

## What Deterministic Search Actually Does

The candidate pool is the Cartesian product of `no`, `one`, `lone`, `some`
over the current expression's two to four distinct signature leaves. It keeps
their source roles and the AND/OR connective, giving 16, 64 or 256 full plans.
Each returned static counterexample is mapped to signature cardinalities
clipped to 0, 1 or at least 2, plus its expected whole-predicate truth value.
Clipping is exact for this grammar, not for arbitrary Alloy expressions.

```text
current := faulty predicate
tried := empty; evidence := empty
repeat while a real-query budget remains:
    result := check current against the private oracle
    if the evaluator returns bounded success: return current
    if result has no usable counterexample: stop without claiming repair
    add returned counterexamples to evidence
    add current plan to tried
    if the query budget is exhausted: stop without claiming repair
    eligible := untried plans satisfying every retained counterexample
    if eligible is empty: stop without claiming repair
    choose the eligible plan minimizing:
        (number of cardinality slots changed from current, enumeration index)
    construct and commit that full plan through the actual executor
```

The tie order follows the declared operator order `no`, `one`, `lone`, `some`.
This is bounded counterexample-guided enumeration with greedy Hamming-change
ranking, not BFS, best-first proof search or canonical-distance minimization.
It is not guaranteed to find a globally minimum repair. The four-query budget
includes the initial check, leaving at most three candidate checks. The oracle
body is private to the evaluator; the planner only receives public feedback.

## What The Model Learns

The network uses exactly the same pool, evidence filter, source executor and
acceptance checker as search. It replaces the eligible-plan ranking, not the
definition of legal syntax, counterexample semantics or repair acceptance.

- A width-48, two-layer GIN-style encoder reads typed incidence graphs derived
  from initial/current source and canonical tables. Addresses are graph
  references, not learned source-name or task-ID features.
- Per slot, a 48-dimensional leaf embedding plus current/proposed cardinality
  one-hots pass through a shared `56 -> 48` layer with GELU and LayerNorm.
- Mean pooling supports variable arity. Five plan features are added: edit
  fraction, latest/cumulative evidence disagreement, connective and arity.
  A `53 -> 48` plan encoder embeds that vector.
- Graph context plus five episode features pass through `53 -> 48`; a
  48-dimensional GRU carries attempt context. Context and memory combine through
  `96 -> 48`.
- Context, plan embedding and their elementwise product form a 144-dimensional
  vector. The action head is `144 -> 48 -> 1`; the auxiliary consistency head
  is `144 -> 1`. Ineligible scores are masked to negative infinity.
- The loss is teacher-plan cross-entropy plus `0.2 *` consistency BCE. An
  exploratory first plan has no action-imitation loss. This is supervised
  imitation with public-feedback-derived supervision, not policy-gradient RL.

Raw counterexample graphs and historical rows are removed from this model's
graph input. It instead receives deterministic counterexample-derived features,
with an exact external evidence set. It does not learn Alloy cardinality
semantics from scratch, and it does not generate arbitrary token sequences.

**Parameter accounting correction:** the advertised 271,637 parameters count
all allocated modules. The reused `VariantPolicy` retains 43,633 parameters in
unused `choice`, `pointer`, `query_score`, `candidate_score`, `prior` and
`next_head` components. Active training components contain 228,004 parameters;
excluding the 145-parameter auxiliary head leaves 227,859 affecting action scores.
The original machine reports retain their allocated-count convention. This
clarification changes neither checkpoint bytes nor experimental outcomes.

The relevant frozen source paths are
`experiments/feedback_repair/multistep_scale.py`, `gnn_variants.py`, `tables.py`
and `contextual.py`. They are in the latest archive's `frozen-sources.tar.gz`.

## Failure Modes And Their Status

**F1: Coverage before learning.** The latest natural audit contains 95 loaded
but grammar-unsupported predicates and nine `GENERICRELDECL` observation-load
refusals. A larger network cannot create missing adapter or candidate-language
support. This is an open transfer blocker, not evidence that those sources are
invalid Alloy or that every possible repair learner must fail.

**F2: Numerically learning the wrong task.** Finite gradients, lower loss and
successful teacher replay do not establish useful closed-loop repair. The older
natural-task study completed 30,000 updates yet repaired no held-out task.
Premature STOP and exhausted construction budgets are observed symptoms.
Exposure dilution and long action sequences are plausible contributors, not
isolated causal explanations established by these studies.

**F3: Approximate memory does not enforce past evidence.** The small pilot's
seven contradictory test proposals motivated explicit filtering. The new guarded
path has zero such proposals. Lean proves the abstract filter's properties under
authentic-evidence and representable-target assumptions; bounded tests check the
Python/Java connection. This is not a universal implementation-refinement proof.

**F4: Teacher objective and baseline strength.** The model imitates a
minimum-change consistent planner, including continuations that ultimately hit
the query limit. These labels are executable choices, not optimal actions.
Matching the teacher/search baseline is meaningful bounded behavior, but does
not establish a learned advantage in information gathering or repair cost.

**F5: Recurrent context is not yet necessary for the measured score.** Resetting
memory changes plan sequences on 1/64, 7/64 and 5/64 tasks, but not repair counts.
Exact retained evidence, current source and the tried-plan mask already provide
much of the search state. The evidence supports no measured GRU benefit here,
not the stronger claim that recurrence is always unnecessary.

**F6: Synthetic generalization is not natural transfer.** Shared-slot pooling
handles unseen arity inside the same tiny language. That does not cover joins,
quantified formulas, mixed connectives, temporal formulas or general source-local
edits. The reported natural 0/89 and synthetic 25/32 measure different problems;
they cannot be plotted as one accuracy-improvement curve.

**F7: Reporting can overstate capacity and certainty.** Allocated parameters
included unused heads; model-level lemmas are not proofs of neural effectiveness;
same-checkpoint interventions are not matched retraining; repeated seeds are
not independent tasks. These distinctions are now explicit rather than silently
changing historical result files.

## Next Iteration, With Explicit Gates

1. Freeze a source-local repair grammar and inference contract first. Model input
   remains the faulty/current predicate's derived structures, its own attempts
   and actual counterexample feedback. No oracle body or truth-pool-derived
   proposal may enter inference. Prove the new semantic projection/guard claims
   in Lean, state their assumptions in prose, then implement and test them.
2. Audit source and candidate coverage before training. Report adapter failures,
   unsupported shapes and executable tasks separately while retaining primary
   denominators. Demonstrate source-backed repair paths for newly supported
   shapes; a larger task-file count alone is not a passed coverage gate.
3. Evaluate local edits in the complete predicate on each retained world. Do not
   assign a whole-predicate counterexample label directly to a subexpression.
   Keep exact checks outside the neural model and final acceptance with Alloy.
4. Collect and freshly replay both successful and budget-limited episodes.
   Separate chosen actions from proven repairs and exploratory choices from
   expert labels. Retain explicit update exposure per admitted episode.
5. Compare deterministic consistent search, equally filtered random search and
   learned ranking with the same grammar and query/decision budget. A possible
   later objective is choosing informative attempts, not merely imitating small
   edits; that requires a new specification and experiment, not a claim from
   the current results.
6. Lock architecture on validation, then evaluate question-group holdouts and
   source-backed out-of-grammar extensions separately. Increase capacity only
   after showing executable coverage and a reproducible benefit on the intended
   task. Do not launch Qwen/500M training solely because synthetic search works.

## Evidence And Reproduction Boundary

The latest run passed fifteen new Lean model declarations, 373 runtime check
executions and 9,216 finite nonzero-gradient updates. Its curator verified 549
frozen input hashes and 4,018 output hashes. These are bounded evidence and
integrity checks, not whole-artifact closure or a proof of learning effectiveness.

The three retained result directories contain machine reports, manifests and
evidence archives. Run `git lfs pull` to obtain the archives. The latest archive
includes checkpoints, full trajectories, tests, generated sources and a nested
source snapshot. Older local-scaling archives explicitly omit binary checkpoints;
their report records that limitation. Historical hashes and measured JSON are
preserved, including their original allocated-parameter counts.

To reproduce the latest training run, use a separate checkout with the existing
`lib/` dependencies, unpack its evidence archive outside the checkout, and overlay
the nested `frozen-sources.tar.gz` into that separate checkout. Verify the included
`input-hashes.json` before running the archived command. Python/PyTorch, Java 17,
Lean and system libraries remain external dependencies; this documentation push
is not a new self-contained Docker release. The measured run used PyTorch
2.14.1+cu130 on CPU, two PyTorch threads and at most two Java workers, taking
748.42 seconds excluding later evidence packaging. GPU training is not required.

Original source HEAD was `67cb5f3dfe226b15e2647fe6d18534fa03995cbc`, with a
dirty worktree. The publication commit packages the findings; it must not be
misidentified as the source that produced the measurements. No protected corpus,
canonical-distance, ablation or capability results are updated by this push.
