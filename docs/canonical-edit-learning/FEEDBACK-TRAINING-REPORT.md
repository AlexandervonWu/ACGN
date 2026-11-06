# Structured Feedback Training Report

Latest follow-up: the [larger-data/model study](FEEDBACK-SCALING-RESULTS.md)
uses 313 training paths and screens up to 24.54M parameters, but obtains no
validation or held-out repairs. Its selected model and both controls each score
0/89 in three test seeds. These are question-held-out results, unlike the earlier
eight-task training diagnostic below. The historical measurements remain intact.

Earlier follow-up: the [three-seed GNN gradient comparison](FEEDBACK-GNN-RESULTS.md)
improves training-set repairs with GIN to 3/8, 5/8 and 4/8. It still does not pass
the eight-task gate. The initial run below is retained unchanged as evidence.

## Initial Learning Run

Date: 2026-10-03. Contract: `feedback-intent-path-v1`.
Executor: `feedback-executor-canonical-v4`. Seed: 17.

**Actual GPU training and free-running evaluation have now run. The one-task
gate passed; the eight-task gate failed. Larger-model escalation stopped.**
These are training-set learnability diagnostics, not held-out repair results.

The runtime now exports numeric source, certified repair-projection, type,
binding/phase and returned-counterexample tables. Structured metadata survives
projection without changing distance charge units, comparisons or certificate
authority. Names/display keys stay private; row addresses become graph edges
and pointer choices, not learned identities. Literal integers retain all 32 bits.

The policy is a three-layer relational GNN, width 128, with **482,049 parameters**,
trained from scratch. Conditional heads select controls, joint family/site tuples,
operators and operands. AdamW uses learning rate 0.001, weight decay 0.001,
gradient norm bound 1 and eight sampled decisions per update, sampling episodes
uniformly first. Each gate trains a fresh model. Evaluation uses greedy predictions
through fresh Java workers, with no teacher answers or future feedback.

### Results

- **1-task gate:** 1/1 bounded-validated repair after 1,000 updates. No-op: 0/1;
  uniform masked actions: 0/1. The learned repair used eight decisions and two
  explicit queries. Checkpoints at updates 100, 250 and 500 failed.
- **8-task gate:** 0/8 repairs after 1,000 updates, below the required 8/8.
  No-op: 0/8; uniform masked actions: 0/8. Every generated action record was
  structurally well formed; that does not imply every proposed term typed.
- **64-task gate, held-out GNN comparison, Qwen adaptation and roughly 500M
  scratch training:** not run, following the contract's stop-on-failed-gate rule.
  No extra optimizer budget, enlarged model or weaker validator was used.

Rollouts allow at most 256 decisions and two explicit feedback queries, matching
the teacher caps. A query may contain multiple SAT checks. Final success requires
feasible context and both behavioral-difference checks UNSAT under the fixed
bounded Alloy profile; neither STOP nor imitation accuracy establishes success.

Training plus controls took **90.387 seconds**, on the RTX 5080 with PyTorch
`2.14.1+cu130`. Peak PyTorch allocation was **92,027,392 bytes**, reservation
**113,246,208 bytes**. These exclude CUDA-context/desktop memory and are not RSS.
There was no OOM. This is not a larger-model throughput benchmark.

### Failure Analysis

At the final eight-task checkpoint, six episodes committed type-valid candidates
and received final COUNTEREXAMPLE responses. Two repeatedly attempted a rejected
commit 251 times, exhausting the decision budget after their initial query.
Their chosen equality compared a unary signature with a binary relation:
coarse REL masks admitted the operands, while the mandatory exact type check
correctly rejected the term. The policy did not revise or abort its rejected draft.

Predictions clustered around relational equality and cardinality comparison
(`#R <= #S`), including tasks requiring different structure. Earlier checkpoints
also repeated draft/abort loops. For example, the one-task model repaired
`all n: Node | no n.*adj` to the behavior of `no (adj & iden)` through construction,
commit and validation. The eight-task model instead chose a cardinality comparison
for that same task, which failed behavioral validation.

All eight tasks have replay-validated teachers under the same executor and
budgets. This failure is not demonstrated to be an action-language ceiling,
missing teacher, certificate exception or insufficient VRAM. Mode concentration
and loss fluctuations suggest an optimization/conditioning problem. Global pooling
of heterogeneous tables and teacher-state imitation without on-policy recovery
are plausible contributors, not independently established causes. The result is
**failed free-running learnability**, not impossibility of repair ML. One seed and
one successful memorized example do not establish stable superiority over random.

### Coverage And Checks

- Frozen pilot: 104 tasks, 36 question groups; 64 train, 16 validation, 24 evaluation.
  Held-out tasks received coverage checks, not teacher construction/model selection.
- Source plus canonical export and query: **95/104** pass. Nine initial observations
  explicitly reject local canonical declaration nodes (`GENERICRELDECL`); there is
  no silent source-only fallback.
- Training teachers: **62/64** replay, and all 62 encode successfully. The two
  uncovered tasks are `468435d3183d2fa36e6e` (socialMedia:inv6) and
  `8d6349d73f380a96a488` (classroom_fol:inv14). Both have the same local-declaration
  coverage gap and remain in the denominator. Neither is in the first eight.
- **58 Lean model theorems** compile: 27 IntentRepair, 21 FeedbackSession,
  10 FeedbackLearning. No added axioms, `sorry` or unsafe proof; standard
  foundational dependencies are printed in the archived logs.
- **255 runtime checks** pass: 132 executor, 64 environment, 38 prior learning,
  14 causal replay, seven learning-boundary tests. The separate metric regression
  passes **2,266 checks**.
- New tests cover exact int32 values, private-target mutation with identical
  tensors/predictions, graph address transport, alpha-renamed source, certified
  ACI/phase imports, causal teacher keys and query-budget masks.

Lean proves the stated pure boundary models, not universal Java/Python refinement,
floating-point correctness, solver completeness or learning effectiveness.
PyTorch/CUDA remain TCB. See [the ledger](INTENT-PATH-OBLIGATIONS.md) and
[implementation notes](FEEDBACK-LEARNING.md).

### Evidence

Full runs: `/tmp/acgn-feedback-learning-preflight-20261003` and
`/tmp/acgn-feedback-learning-20261003`. The repository retains the
[machine report](results/feedback_learning_20261003/report.json),
[coverage](results/feedback_learning_20261003/preflight/coverage.json),
[teacher coverage](results/feedback_learning_20261003/preflight/teacher-coverage.json),
loss histories, final learned/control rollouts, proof/test logs and hash maps in
[the evidence directory](results/feedback_learning_20261003/).
Full external outputs also retain intermediate rollout checkpoints and weights.

HEAD was `67cb5f3dfe226b15e2647fe6d18534fa03995cbc`, with a dirty tree.
**495 input hashes, 1,280 preflight output hashes and 75 learning output hashes**
were rechecked after training with zero mismatches. Content hashes identify this
uncommitted implementation; HEAD alone does not. Existing empirical directories
remain unchanged. No commit, push or release was performed.

Run sequentially with fresh external directories:

```bash
python3 -m experiments.feedback_repair.run_gates /tmp/acgn-feedback-preflight-new
# Coverage-only exit code 2 is expected; inspect its report before continuing.
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_gates \
  /tmp/acgn-feedback-preflight-new /tmp/acgn-feedback-learning-new
```

The trainer checks preflight hashes. It exits 2 on gate failure, 0 only when all
small gates pass. Neither authorizes calling these a final generalization study.
Local canonical binders/domains, older source-history snapshots, matched bounded
search, on-policy recovery and larger-model consumers remain open. Address the
small learnability failure before increasing model size.

## Historical V3 Preflight

Everything below records the earlier **source-only** migration, before canonical
tables or a trainer were connected. Its 104/104 and 64/64 results are not neural
repair scores and should not be substituted for the current coverage above.

Date: 2026-10-03. Contract: `feedback-intent-path-v1`.
Executor: `feedback-executor-migration-v3`.

**The migration is not complete, and no models were trained in this run.**
The user's choice was to finish the shared executor and gates before repeating
GNN, Qwen adaptation and roughly 500M scratch-transformer training. Historical
trainers were not rerun under the new contract's name.

## Implemented

- A separate public worker with initially empty feedback and explicit, budgeted
  VALIDATE/STOP calls. No reward bank, target distance, oracle text or initial
  module-wide declaration inventory is exported to the policy.
- Numeric source/type/scope/phase tables and concrete returned world/trace tables.
  Built-in memberships, exact integer values and returned-symbol provenance are
  retained. Display names, source offsets and private validation data stay outside
  the observation.
- Compositional temporal, binding and matrix transactions, public factorized
  action masks and coarse typed draft holes. Revision/turn binding, scope checks,
  type/canonical preparation and atomic source commit protect transitions.
- Joint multi-domain quantifiers, including ONE/LONE, with preceding-group scope
  for dependent domains. New bindings and uses are introduced in one transaction.
- Feedback-only symbol operands become available after actual returned examples,
  never through a prefetched hidden-schema menu.
- A separate offline teacher compiler and fresh-worker causal replay. Teacher
  labels do not appear in public observations, and each observation is captured
  before executing its associated decision.

See [the runtime and incident ledger](FEEDBACK-RUNTIME.md) and
[the numeric interface](../../experiments/feedback_repair/TABLES.md).

## Measured Preflight

The final frozen run was `/tmp/acgn-feedback-gates-20261003-v3`.
It took **151.996 seconds**, used no GPU and made no optimizer updates.

- Lean: **48 model theorems** compiled: 27 in `IntentRepair.lean` and 21 in
  `FeedbackSession.lean`. No added axioms, `sorry` or unsafe proofs; standard Lean
  logical dependencies are printed in the archived logs.
- New executor: **114 Java checks passed**.
- Historical regression suites: **64 + 38 Java checks passed**. These verify
  compatibility, not compliance of the historical trainers with the new contract.
- Causal replay and teacher integration: **14 Python tests passed**, using real
  Java workers and Alloy validation. Total: **230 bounded runtime checks**.
- Frozen pilot: **104/104 observation plus explicit-query checks passed**.
  All initial query outcomes were COUNTEREXAMPLE, not successful repairs.
- The pilot retains 36 question groups and its existing 64 training, 16 validation
  and 24 evaluation split. It is not a full-corpus evaluation.
- Training-only teachers: **64/64 compiled and replayed successfully** in fresh
  workers, each ending in bounded behavioral validation against its private target.
- Teacher paths use 6-26 semantic decisions, median 15, with two explicit queries
  each. These paths currently reconstruct the target through one whole-root
  transaction. They demonstrate compositional execution, not optimal local edit
  plans, adaptive multi-transaction planning or learned generalization.
- Largest initial public packet: **1,002 rows**. Largest packet after the pilot's
  first query: **1,235 rows**, below the 8,192-row bound. These maxima do not claim
  bounds for arbitrary future trajectories or GPU memory usage.

**64/64 teacher replays are not 64/64 neural repairs.** No free-running learned
policy was evaluated, and no performance improvement over random walks is claimed.

## Training Readiness

GNNs, Qwen local adaptation and the roughly 500M scratch transformer each have
**zero optimizer updates** in this run. The runner exits **2** with
`BLOCKED_BEFORE_TRAINING`, despite passing its implemented functional checks.

The remaining work is substantive:

1. Export the certified canonical repair view as exact numeric typed tables, with
   inverse and row/alpha/phase transport checks. The current compact `RepairView`
   retains some type/domain identities as diagnostic strings. Parsing those into
   guessed categories or hash buckets would violate the contract; typed metadata
   must survive the projection boundary instead. Current source tables are not
   relabelled as canonical graph tables.
2. Finish representation coverage and exact incremental draft-type handling.
   Current masks encode coarse sorts and scope; exact relational/dependent types
   are enforced on commit. CALL and some constructors remain unsupported.
3. Connect the actual model table encoders and structured action heads, audit
   tensor/prediction independence from private metadata, and run the prescribed
   1/8/64 free-running learnability gates and matched controls. A replayed teacher
   does not discharge any of those learning gates.
4. Only after those gates pass, repeat the requested GNN -> Qwen -> scratch-model
   comparison with the same public information and executable action language.

The Lean files prove abstract controller/representation contracts. They do not
establish universal Java/Python refinement, solver correctness, neural numerical
correctness or learning effectiveness. Final behavioral checks remain bounded
Alloy validation, not independent certificate replay or a new equality authority.

## Evidence And Reproduction

The saved [machine report](results/feedback_preflight_20261003/report.json),
[104-task coverage](results/feedback_preflight_20261003/coverage.json) and
[64-task teacher coverage](results/feedback_preflight_20261003/teacher-coverage.json)
retain all attempted tasks. The
[teacher archive](results/feedback_preflight_20261003/teacher-trajectories.tar.gz)
contains the replayed training-only observations, semantic labels and outcomes.
Its SHA-256 is:

```text
553575a49cba69d54cb60d91de1fad3b7ff8b9d4a00108eb6d2e9a8338ff9d7a
```

The run used HEAD `67cb5f3dfe226b15e2647fe6d18534fa03995cbc` with a dirty worktree.
The [489 input hashes](results/feedback_preflight_20261003/input-hashes.json), not
HEAD alone, bind its actual source/data/proof inputs. All inputs were checked
again after execution. The [1,280 output hashes](results/feedback_preflight_20261003/output-hashes.json)
cover the original full run, including compiled classes and per-task logs; this
repository snapshot retains selected reports/logs plus compressed trajectories.
Both complete hash maps were rechecked with zero mismatches before publication
of this report. Exploratory earlier preflights are superseded by this final run.

From the repository root, using a fresh external output directory:

```bash
python3 -m experiments.feedback_repair.run_gates /tmp/acgn-feedback-preflight-new
```

This needs Python 3.10+, Java 17, Lean and the existing `lib/` dependencies. It
does not start a trainer or require network access. Functional errors exit 1;
the currently unimplemented readiness gates produce exit 2.

The core canonicalizer, certificate authority and existing empirical result
directories were not changed by this migration. Existing unrelated worktree
changes were retained. No commit, push or model release was performed.
