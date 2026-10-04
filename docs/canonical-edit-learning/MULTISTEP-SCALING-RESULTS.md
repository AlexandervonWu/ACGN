# Multistep Scaling Results

Study: `multistep-scaling-v1`, 2026-10-04. This is a bounded synthetic scaling
experiment and a separate natural-source coverage audit, not a corpus repair run.
The frozen protocol (`docs/canonical-edit-learning/MULTISTEP-SCALING.md`) and
runtime (`experiments/feedback_repair/multistep_scale.py`) are retained inside
the evidence archive's `frozen-sources.tar.gz`. See the
[cross-iteration analysis](../repair-search/MULTISTEP-ITERATION-ANALYSIS.md)
for the algorithm, model structure and failure-mode distinctions. This is a
documentation/evidence publication; live runtime changes remain development work.

## What Changed

The preceding pilot used 24 training tasks, two cardinality atoms, conjunction
and sixteen candidate plans. This study uses 144 training tasks, both AND and OR,
three atoms during training, and an unseen four-atom test slice. Its runtime
supports two to four atoms and 16, 64 or 256 complete executable plans. It expands
task diversity and plan length before attempting a large parameter increase.

Every candidate must satisfy **all retained public counterexamples** before the
learned policy can propose it. Exact evidence state survives the Java feedback
window; recurrent neural memory supplements it rather than enforcing this
invariant. Agreement with observed worlds is not acceptance: every proposed
repair is executed and checked by the unchanged Java/Alloy evaluator.

The learner sees the faulty/current predicate's public graph views and actual
returned feedback. Targets, oracle code, split labels, filenames and private
goal vectors are not model features. The study does not change Java semantics,
certificate rules, canonical distances or historical empirical result trees.

## Data And Exposure

- Training: 144 tasks from twelve unordered three-cardinality multisets.
- Validation: 32 tasks from four different multisets.
- Held-out three-slot test: 32 tasks from four further multisets.
- Unseen-arity test: 32 four-slot tasks; no four-slot fitting or validation.
- Renaming/commutative variants of a target multiset stay in the same split,
  including both root connectives. These are clustered synthetic tasks, not
  32 independent natural problem classes per test slice.
- All arms receive four real queries, including the initial failure query,
  hence at most three candidate checks; the controller allows 256 decisions.

Public counterexample-guided collection produced 144 freshly replayed episodes
with 299 plan choices. Seventy-two episodes begin with an evidence-consistent
random exploratory plan. That first choice receives no action-imitation loss,
but its resulting evidence and consistency supervision remain in the episode.
The planner solved 131/144 tasks, including 96 requiring multiple attempts.
All thirteen query-limited failures remain in training; none was discarded.
There were no collection errors or history-inconsistent training proposals.

Each fit visits every episode sixteen times: 2,304 updates, rather than a fixed
small update budget spread across a growing dataset. Width 48/two GIN layers
(271,637 parameters) and width 96/three layers (1,030,854 parameters) both repair
26/32 validation tasks at seed 17. The predeclared smaller-model tie-break locks
width 48 before testing. The selected model is also fitted at seeds 29 and 43.

Parameter counts above are allocated counts, as recorded in the immutable
machine report. A subsequent code inspection found 43,633 parameters in unused
heads inherited by the width-48 model's encoder. Its active training components
contain 228,004 parameters, including a 145-parameter auxiliary consistency head;
227,859 parameters affect action scores. No checkpoint or measured outcome is
changed by this accounting correction. Full details are in the iteration analysis.

## Held-Out Results

The selected learned policy repairs **25/32 (78.125%) three-slot tasks** and
**23/32 (71.875%) four-slot tasks**, at each of the three seeds. Its seven and
nine remaining tasks exhaust the query budget. Resetting the learned recurrent
memory gives the same repair counts in every seed. Each successful result is
the evaluator's closed `SOLVED_WITHIN_PROFILE`, not a filter or neural judgment.

Control repair counts, with seeds ordered 17, 29, 43:

- Filtered random search: three-slot **21, 21, 20 / 32**; four-slot
  **17, 13, 16 / 32**.
- Unfiltered random search: three-slot **0, 0, 0 / 32**; four-slot
  **1, 0, 0 / 32**.
- Same model with filter disabled: three-slot **0, 1, 14 / 32**; four-slot
  **1, 0, 11 / 32**.
- Deterministic evidence-consistent minimum-edit search: **25/32** and **23/32**,
  tying the learned repair counts. It uses 3.375 versus the model's 3.40625 mean
  queries on three-slot tasks, and both use 3.46875 on four-slot tasks.

Thus the learned scorer consistently beats filtered random search in this
bounded study, but **does not outperform deterministic search**. All 468 primary
model proposals respect the retained evidence. The filter-disabled model proposes
441 history-inconsistent candidates out of 555, with strong seed sensitivity.
There are zero execution errors across the 64 validation rollouts and 1,024
held-out model/control/baseline rollouts. Query-limit failures remain in every
denominator; the nine natural-source loading refusals are reported separately.

The memory-reset and filter-disabled controls use the same fitted weights.
They are inference interventions, not independently retrained model families.
In particular, masked-out candidates receive no direct action-ranking loss
during training. Removing that mask tests dependence on the deployed controller;
it does not prove that a differently trained neural model cannot learn consistency.

The trajectory audit finds identical complete plan-index sequences between
primary and reset-memory policies on 63/64, 57/64 and 59/64 tasks, respectively.
The learned policy and deterministic search match sequences on 49/64, 50/64 and
49/64 tasks. Thus memory does affect some decisions, and the learned policy is
not simply identical to search. Neither difference improves aggregate repair
success here; equal counts alone would not have established identical policies.

## Natural-Source Boundary

The separate audit retains all 104 tasks in the existing benchmark denominator:

- 93 loaded inputs do not have a homogeneous cardinality connective root.
- Two more loaded inputs contain other operand shapes.
- Nine loads fail with
  `CANONICAL_OBSERVATION_UNSUPPORTED:NODE:GENERICRELDECL`.
- **Zero of 104 inputs are supported by this whole-predicate plan grammar.**

Those nine load failures are observation-adapter coverage refusals, not evidence
that the source is invalid Alloy. No natural repair evaluation or target-based
reachability filtering was performed. This is a reused benchmark coverage audit,
not a newly unseen test set. Synthetic success cannot be substituted for a
natural-corpus repair score.

The 25/32 result is therefore not an accuracy improvement on the older 0/89
natural-task benchmark. Both the task language and the action-generation problem
are different. Complete-plan construction removes many invalid-action failure
modes by design; it does not demonstrate that the learner mastered arbitrary
source reconstruction.

## Lessons From Prior Failures

1. **More parameters do not repair an action-coverage gap.** The larger model
   ties the small model on validation, and this grammar covers none of the
   audited natural predicates. Increasing neural width cannot create missing
   source edit operations or observation support.
2. **Scale training exposure with data.** Sixteen full passes avoid the earlier
   study's shrinking per-example exposure. This addresses a plausible failure
   mechanism; this experiment does not isolate exposure as the sole cause of
   any earlier negative result.
3. **Keep exact feedback obligations outside learned memory.** The old pilot
   proposed seven candidates already contradicted by its history. The new
   filter makes that exclusion explicit while still requiring genuine solver
   acceptance. Reset-memory results show no additional recurrent-memory benefit
   on the new benchmark.
4. **Keep failures in context, but identify the teacher's ceiling.** The model
   imitates an evidence-consistent minimum-edit planner, not an optimal
   information-gathering policy. Retaining unsuccessful episodes broadens visited
   states; it does not make their next action optimal or their last repair valid.
5. **Count semantic groups, not just files.** Grouped splits and the unseen-arity
   slice test more than source-name memorization, but both remain inside a small
   cardinality language. They do not establish relational or temporal transfer.

The next useful expansion is source-local candidate coverage with structural
reuse, followed by another explicit natural-source audit. A candidate inside a
larger predicate must be evaluated in its enclosing context on each returned
world. A whole-predicate counterexample label must not be assigned directly to
the edited subexpression. Only after these interfaces cover useful tasks would
larger models or training for information-gathering choices address the actual
bottleneck. Neither Qwen nor a 500M scratch run is authorized by this study's
synthetic results.

## Proof And Reproduction

The [standalone Lean model](formal/MultistepScaling.lean) was compiled before
the natural-language protocol and runtime were written. Its fifteen declarations
cover cardinality clipping, variadic evaluation, strict arity, exact evidence
filter properties, causal prefixes, training/replay guards, split grouping,
finite pool/decision bounds and the insufficiency of finite evidence for
acceptance. Two clean builds have identical theorem dependency inventories;
only `propext` and `Quot.sound` occur as dependencies.

The preflight passes 373 runtime check executions: 342 existing base checks and
31 contextual/multistep tests, including ten new scaling tests. All four fitted
checkpoints reload. Across them, 9,216 optimizer updates have finite losses and
finite, nonzero measured gradient norms. These counts measure checked executions,
not 373 independent semantic theorems. The complete study took 748.42 seconds
(12.47 minutes), including compilation, checks, collection, training and trials,
but excluding the subsequent evidence packaging.

The new finite/source-backed tests cover all abstract plan/count combinations
for arities two through four, 24 real source executions across arities and
connectives, retained evidence, fresh replay, held-out refusal, gradient flow,
model masks and grouping. These are bounded correspondence checks, not a
universal Python/Java refinement theorem. Authentic returned worlds and an
expressible target are assumptions of the target-retention lemma. Lean,
Java/Alloy/SAT, PyTorch, hashes/filesystem and hardware remain trusted components;
learning effectiveness is measured, not proven.

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_multistep_scaled /tmp/multistep-scale-new
python3 docs/canonical-edit-learning/multistep_scaling_report.py /tmp/multistep-scale-new /tmp/multistep-scale-evidence-new
```

These commands apply to the archived producer snapshot, not a bare checkout of
this documentation-only publication. In a separate checkout, first overlay the
nested frozen source archive and verify its input hashes; retain the matching
`lib/` dependencies. Use fresh output directories. The runner uses CPU with two
PyTorch threads and
at most two Java workers; it does not require a GPU or network. It recompiles
proofs and Java, validates the old and new bounded checks, then collects, trains
and evaluates. Checkpoints, full trajectories, frozen sources and input/output
hashes are retained for inspection.

## Retained Evidence

The [machine report](results/multistep_scaling_20261004/report.json) and
[audit](results/multistep_scaling_20261004/audit.json) retain exact counts and
paired trajectory comparisons. The curator verified 549 frozen input hashes
and 4,018 generated output hashes, validation-only selection, four checkpoints,
exact per-episode exposure, every evaluation denominator, query limits and
the filtered modes' evidence-consistency invariant.

The [evidence archive](results/multistep_scaling_20261004/evidence.tar.gz)
contains full trials, logs, checkpoints, generated Alloy sources and a nested
frozen-source archive. [File hashes](results/multistep_scaling_20261004/hashes.json)
cover the curated artifacts. The original working run is
`/tmp/acgn-multistep-scale-20261004-v1`. Its repository HEAD was
`67cb5f3dfe226b15e2647fe6d18534fa03995cbc` with a dirty worktree; the recorded
content hashes, rather than HEAD alone, identify the actual producer inputs.
The large evidence archive is stored using Git LFS; run `git lfs pull` after cloning.
This bounded audit is not whole-artifact mechanical closure or a release.
