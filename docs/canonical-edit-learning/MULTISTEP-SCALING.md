# Scaling The Multistep Repair Model

Contract: `multistep-scaling-v1`. Proof-first bounded study, not a corpus release.

## Lessons Applied

The earlier [large local-repair study](LOCAL-SCALING-RESULTS.md) increased task
count far more than training exposure, had substantial executor coverage failures,
and often stopped before using its real-query budget. The
[multistep pilot](MULTISTEP-REPAIR-RESULTS.md) showed a feedback benefit on a small
grammar, but no benefit from recurrent memory and seven history-inconsistent
test proposals. These observations motivate the following changes; they do not
establish a single cause for every previous failure.

1. Preserve complete executable paths and controller-scheduled validation.
2. Scale arity and task diversity before large neural width. Shared per-slot
   candidate encoding must handle an unseen number of slots without a new head.
3. Retain every returned counterexample in exact controller state. Filter out
   candidates contradicted by any past witness; do not ask a GRU to approximate
   that invariant. Learned scores rank the remaining candidates, not certify them.
4. Match training exposure: sixteen complete passes over the admitted episode
   set, with every episode visited exactly once per epoch. This is comparable to
   the small pilot's roughly seventeen random-sampling passes, not a fixed update
   count spread over many more examples.
5. Include exploratory prefixes and query-limit failures in retained training
   data. Do not imitate an arbitrary exploratory choice as an expert target.
6. Audit natural-source coverage separately, without silently replacing failed
   inputs or presenting synthetic repairs as corpus repairs.

## Scope And Inference Boundary

The source grammar is a homogeneous AND or OR tree of two to four cardinality
atoms over distinct signature leaves. Nested occurrences of the same connective
are read in source-port order. Each candidate chooses `no`, `one`, `lone` or
`some` independently for each leaf, keeping the connective and source symbols.
Pool sizes are 16, 64 and 256. Root replacement uses 3n+1 construction actions
and one real check. Other shapes, mixed connectives, non-signature leaves,
ambiguous mappings and temporal feedback are refused explicitly.

World projection uses only real returned worlds and source-bound signature
addresses. Cardinalities are clipped to 0, 1 or at least 2, which is exact for
this grammar. Each latest-query packet is added to a persistent evidence set;
the set survives the executor's rolling feedback-window truncation. Semantic
agreement with this set is a necessary filter, not a sufficient repair test.
Only the unchanged Java/Alloy evaluator can return bounded success.

The model sees public source/canonical graph structure, current candidate, latest
counterexample-derived features, per-plan cumulative consistency and tried-plan
state. No target body, target operator vector, task ID, filename or split is a
feature. A shared slot encoder combines source-leaf graph embeddings and proposed
cardinality choices, pools over slots, then scores full plans with graph/GRU
context. Stored numeric addresses are used only as graph references.

All arms use four real queries, 256 construction decisions and a 120-second
episode deadline. Generated candidates always require the same actual executor
and check; no additional hidden equivalence queries are used for ranking.

## Fixed Study

Generate three-slot tasks from the twenty unordered cardinality multisets.
Assign twelve multisets to train, four to validation and four to test before
data collection. Both AND and OR use the same assignment. This groups renaming
and commutative permutations together rather than splitting near-duplicates by
filename. Six distinct initial operator vectors per training group produce
144 training tasks. Four per held-out group produce 32 validation and 32 test
tasks. Add 32 four-slot test tasks, with arity four never present during fitting
or validation. The four-slot slice is reported separately.

Half of the training tasks use one uniformly chosen evidence-consistent initial
repair, then the public minimum-edit consistent planner. Other tasks use the
planner throughout. Only freshly replayed paths are admitted. Exploratory first
choices have no action-imitation loss, but retain evidence/consistency supervision
and remain in the causal memory prefix. Unsuccessful complete episodes are kept.

Screen widths 48/two GIN layers and 96/three layers at seed 17 for sixteen epochs
each, then lock the configuration by validation success with fewer parameters
breaking ties. Evaluate the locked configuration at seeds 17, 29 and 43; never
select on test. Shared inference controls include the same locked weights with
memory reset and with the cumulative evidence filter disabled (the latter still
sees public evidence features). These are intervention controls, not independently
retrained ablations. Also run deterministic minimum-edit consistent search,
uniform surviving-plan search and uniform untried-plan search. Report all task
denominators, errors, query counts and evidence-inconsistent attempts.

The same 104 existing natural-source benchmark tasks are inspected for Java load,
source-grammar and initial-feedback support before training. This is a coverage
audit, not a repair evaluation and not a new untouched benchmark. No natural
oracle body is inspected for candidate construction or reachability labels.
Unsupported natural tasks remain in the audit denominator. Zero coverage is a
documented obstacle to transferring this grammar, not a reason to hide the audit.

## Proof, Checks And Trust

`formal/MultistepScaling.lean` compiled before this document and runtime. Fifteen
model declarations prove variadic AND/OR cardinality clipping, arity refusal,
retention of authentic representable targets, no repeat, consistency with every
stored witness, monotone exclusion, prefix causality, train/replay guards,
deterministic group splits, the 256-plan cap and 43-decision four-query bound.
Finite evidence consistency is explicitly distinguished from equivalence.
Only `propext` and `Quot.sound` occur in the new proof dependencies.

Runtime correspondence targets are `multistep_scale.py` (grammar, projection,
filter, variable-arity model and replay) and `train_multistep_scaled.py` (splits,
coverage audit, collection, train/selection/evaluation). Tests compare finite
semantics, real source execution, replay and filter behavior. This is not a
universal implementation-refinement proof or whole-artifact closure. Lean,
Java/Alloy/SAT, PyTorch, filesystem/hashes and hardware remain explicit trusted
components. Optimization, generalization and numerical kernels are empirical or
trusted, not theorem conclusions. No Java semantics or rewrite rules change.

## Reproduction

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_multistep_scaled /tmp/multistep-scale-fresh
```

Use a fresh external directory. CPU is sufficient, Java work is bounded to two
workers, training uses two CPU threads, and all sources, splits, outcomes,
checkpoints and hashes are retained. No large-transformer or full-corpus run is
implicitly authorized by completion of this bounded study.
