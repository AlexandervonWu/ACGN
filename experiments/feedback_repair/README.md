# Feedback Repair Migration

This directory implements bounded structured-feedback training for the new
predicate-only repair contract. Large-model training is gated on learnability.

## Scaled Multistep Plans

`multistep_scale.py` extends the contextual model to homogeneous AND/OR trees
with two to four signature-cardinality leaves and 16 to 256 complete plans.
A shared per-slot GIN encoder handles variable arity. Exact cumulative
counterexample filtering excludes previously refuted candidates; the learned
scorer ranks survivors, and the existing Java evaluator alone accepts repairs.

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_multistep_scaled /tmp/multistep-scale-new
```

The [fixed protocol](../../docs/canonical-edit-learning/MULTISTEP-SCALING.md)
first rebuilds Lean/Java checks and audits 104 natural-source inputs. It then
collects and freshly replays 144 synthetic training episodes, screens two model
sizes with sixteen complete passes per episode, locks on 32 validation tasks,
and evaluates three seeds on 32 held-out three-slot and 32 unseen-arity tasks.
It retains unsuccessful episodes and compares exact-filtered random search,
unfiltered random search and deterministic consistent search. Memory-reset and
filter-disabled controls use the same weights, not separate training runs.
All arms have four real queries. The runner uses two CPU threads and at most
two Java workers; no GPU or network is required. Use a fresh external directory
and do not change frozen inputs during the run. Natural-source coverage and
synthetic repair performance are separate results, not interchangeable scores.
See the [measured results and limitations](../../docs/canonical-edit-learning/MULTISTEP-SCALING-RESULTS.md).

## Multistep Contextual Plans

`multistep.py` adds an attempt-level GNN/GRU plan scorer. Seven public edit
decisions execute each two-site plan, followed by a genuine Alloy check. The
next plan can depend on the new counterexample and retained attempt context.
Targets and correct code are never model inputs. The public search teacher uses
only actual counterexamples, and every training episode requires fresh replay.

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_multistep /tmp/multistep-new
```

The fixed CPU study rebuilds Lean/Java checks, trains matched persistent-memory,
reset-memory and blinded models for seeds 17/29/43, then runs each on train,
validation and held-out compositions with the same four-query budget. All
checkpoints, full trial logs and hashes are retained. The sixteen-plan grammar
is restricted to conjunctions of two signature-cardinality formulas.
See the [specification](../../docs/canonical-edit-learning/MULTISTEP-REPAIR.md)
and [results](../../docs/canonical-edit-learning/MULTISTEP-REPAIR-RESULTS.md).
A completed study is not a generalization or scaling authorization.

## Contextual Episode Prototype

`contextual.py` adds persistent graph/GRU context across attempts, pre-query
outcome prediction, checked whole-episode replay and controller-scheduled real
validation after every committed candidate. It does not change the Java executor
or the old trainers. The bootstrap proposer uses only public observations; its
small cardinality enumeration is not a general repair planner.

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.contextual_preflight /tmp/contextual-new --updates 120
```

The runner compiles the new Lean model twice, runs the base preflight and ten
new tests, replays positive and negative episodes, then runs a tiny CPU pilot.
The [measured result](../../docs/canonical-edit-learning/CONTEXTUAL-REPAIR-RESULTS.md)
is two of three **training fixtures**, matching the public enumerator. It is
not a held-out improvement or proof that feedback context is necessary.
See the [contract and next gate](../../docs/canonical-edit-learning/CONTEXTUAL-REPAIR.md)
before using it for broader training. Results include all attempts and failures;
`contextual_report.py` in the documentation directory retains auditable evidence.

## Larger Local-Repair Study

The [scaled local-repair report](../../docs/canonical-edit-learning/LOCAL-SCALING-RESULTS.md)
records 474 training tasks (309 replay-admitted initial paths), 62 validation
tasks and 89 test tasks. Four configurations up to 28.24M parameters each score
0/62 on validation. The smaller-model tie-break selects the 6.01M no-message MLP;
its three test seeds each score 0/89, tied with uniform/no-op controls. Coverage
failures remain in the denominator, and the 61 executable test tasks also produce
no repair in each seed. Thirty thousand finite updates and successful teacher
replay are not evidence of held-out repair ability.

This was an explicitly authorized scaling diagnostic despite the failed small
gate, not a declaration that the gate passed or permission for the Qwen/500M
stages. No held-out teachers or gradients are used. The benchmark is the same
question-disjoint benchmark used by the earlier scaling study, not a new blind
test. Run these commands consecutively, requiring exit 0 from each stage:

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.local_preflight /tmp/local-scale-preflight-new
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.local_scale_data /tmp/local-scale-preflight-new /tmp/local-scale-data-new --workers 4
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_local_scaled /tmp/local-scale-data-new /tmp/local-scale-study-new --workers 4
```

Use fresh external directories and do not edit frozen inputs during a run.
The measured study took about 86.5 minutes, plus five minutes of collection and
preflight, on the RTX 5080. It uses sequential GPU training/evaluation, up to
four independent Java workers, and a one-GiB estimated example cache. The
largest fit peaked at 870.4 MiB of allocated CUDA memory, excluding the desktop
and non-PyTorch allocations. `local_scaling_report.py` in the documentation
directory audits manifests, denominators, selection and six final checkpoints,
and curates the JSON/log/source evidence without retraining.

## Eight-Task Local-Repair Runner

The [local refinement](../../docs/canonical-edit-learning/LOCAL-REPAIR-RUNTIME.md)
adds source-local expert proposals with COPY reuse, replay from actual learner
snapshots, separate recovery admission, narrow syntax/type retry caching, a
Java-enforced query budget and revision-qualified public history transport.
The initial local study trains GIN, GCN, GraphSAGE, attention and no-message MLP models
on the fixed first eight training tasks with two on-policy aggregation rounds.

Run these consecutively, using fresh external directories:

```bash
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.local_preflight /tmp/local-preflight-new
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_local /tmp/local-preflight-new /tmp/local-study-new
```

`local_preflight` must exit 0 before training. It compiles the Lean model checks,
Java and source-backed regressions, then collects/replays the training teachers.
`train_local` exit 0 means the fixed comparison completed; inspect `gateStatus`
in `report.json` separately. Do not edit frozen producer inputs during a run.
The checkpoints, full rollouts, aggregation evidence and hashes stay in the
external output directory. Existing default worker behavior is preserved; the
new Java behavior requires the `local-feedback-repair-v1` load contract.

The [completed report](../../docs/canonical-edit-learning/LOCAL-REPAIR-RESULTS.md)
records 15 runs, 30,000 updates and zero worker errors. GIN and attention tie
at 5.33/8 final training-task repairs averaged across three seeds; uniform and
no-op controls are 0/8. No run meets the 8/8 gate. That study contains no held-out
evaluation; the later scaling diagnostic is reported above. Qwen and roughly
500M scratch training have not run under this refinement.
This is imitation with on-policy data aggregation, not policy-gradient RL.

## Earlier Executor And Learning Gates

```bash
python3 -m experiments.feedback_repair.run_gates /tmp/acgn-feedback-preflight-new
# The coverage runner deliberately exits 2; inspect its report, then:
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_gates \
  /tmp/acgn-feedback-preflight-new /tmp/acgn-feedback-learning-new
```

Use a fresh output directory. Python 3.10+, Java 17, Lean and the repository's
existing `lib/` dependencies are required. The boundary tests and training use
the installed PyTorch environment (`ACGN_RL_PYTHON` overrides its local path).
The default training device is CUDA; `--device cpu` is available. No network is needed.
The runner compiles proofs and Java, runs source regressions, and checks the
frozen 104-task pilot through explicit, deadline-bound feedback requests. It also
attempts offline semantic teachers for training tasks only and replays each
admitted path through a fresh worker. Failed/unsupported paths remain in coverage;
teacher success is not learned repair performance.
`--task-limit N` provides a smaller bounded coverage check.

The coverage preflight ends with exit code **2** and an explicit
`BOUNDED_LEARNING_PREFLIGHT` report because it is not a large-run authorization.
An exception or failed functional check exits 1. Do not treat exit 2 as a model
failure, repair-success measurement, or permission to invoke historical trainers.
`train_gates` checks all preflight input/output hashes, trains a small relational
GNN on the fixed 1/8/64 training subsets, and executes predictions in fresh Java
workers. It stops on the first failed gate, compares no-op/uniform controls, and
writes checkpoints, rollouts, losses, a report and output hashes. Gate failure
exits 2; all small gates passing exits 0, still not a final generalization claim.

Runtime code is in `src/is/fivefivefive/ACGN/repair/Feedback*.java`.
The worker's `observation` is the candidate model boundary; worker diagnostics,
task paths, oracle names, controller hashes and report records are not inputs.
Administrative revision/turn values must be stamped by the controller, not
predicted as semantic edits. All action fields are exact bounded integers.

See [the runtime ledger](../../docs/canonical-edit-learning/FEEDBACK-RUNTIME.md)
and [the full contract](../../docs/canonical-edit-learning/INTENT-PATH-SPECIFICATION.md).
The [measured report](../../docs/canonical-edit-learning/FEEDBACK-TRAINING-REPORT.md)
separates successful teacher replay from neural learning gates.
The intended training order remains GNNs, Qwen adaptation, then roughly 500M
scratch transformer, after shared executor and learning gates pass.

## GNN Gradient Comparison

The renewed bounded comparison includes the original policy, a no-message MLP,
GCN-style, GraphSAGE-style, GIN-style and edge-aware dot-product attention models.
It does not silently override a failed gate to start a large-model run.

```bash
python3 -m experiments.feedback_repair.run_gates /tmp/acgn-gnn-preflight-new
# Inspect the expected exit-2 preflight report; actual failed checks exit 1.
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.gnn_study \
  /tmp/acgn-gnn-preflight-new /tmp/acgn-gnn-study-new
```

The runner freezes six arms, seeds 17/29/43 and eight training tasks. Each arm
gets 1,000 updates with an identical sampling schedule per seed. It records
gradient norms and parameter deltas, teacher-forced metrics, real free-running
rollouts, checkpoints, controls and hashes. Exit 0 means the comparison completed,
not that the eight-task repair gate passed. The new numerical/contract tests and
`FeedbackGNN.lean` are included in the shared preflight.

The [measured study](../../docs/canonical-edit-learning/FEEDBACK-GNN-RESULTS.md)
finds GIN strongest at 3/8, 5/8 and 4/8 repairs; every seed's uniform control is
0/8. These are training-set diagnostics, not held-out performance. Keep PyTorch
and CUDA in the TCB; boundary lemmas do not prove floating-point learning.

## Expanded Dataset And Model Screening

The separate [scaling protocol](../../docs/canonical-edit-learning/FEEDBACK-SCALING-STUDY.md)
expands the bounded experiment without declaring the earlier learnability gates
passed. It freezes source selection before teacher construction, preserves the
question-level split, and never constructs held-out teacher paths.

```bash
python3 -m experiments.feedback_repair.run_gates /tmp/acgn-scale-preflight-new
# Inspect the expected exit-2 report, including all proof/runtime checks.
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.scaling_data \
  /tmp/acgn-scale-preflight-new /tmp/acgn-scale-data-new
/home/augustus/.venvs/acgn-rl-cu130/bin/python -m experiments.feedback_repair.train_scaled \
  /tmp/acgn-scale-data-new /tmp/acgn-scale-study-new
```

Run each command only after the preceding stage completes successfully (the
documented preflight exit 2 is expected). Use fresh external output directories.
Source, proof, test and protocol files are hash-frozen: do not edit them while
collecting data or training. Four bounded Java workers are used by default;
`--workers 1` through `--workers 4` is supported by both scaling commands.

Five arms screen three GIN sizes, GraphSAGE and a no-message control. Validation
repair count selects the final configuration, with smaller models breaking ties.
`locked-selection.json` is written before testing; three training seeds of that
configuration are tested with matched random/no-op controls. Unsupported tasks
remain in held-out denominators. Reports include losses, finite gradient counts,
checkpoints, free-running actions, memory measurements and file hashes. Neither
teacher accuracy nor a completed run certifies repair success or authorizes the
later LLM/Transformer stages. Acceptance still belongs to the Java/Alloy executor.

The [completed scaling report](../../docs/canonical-edit-learning/FEEDBACK-SCALING-RESULTS.md)
records 313 validated training paths, five configurations up to 24.54M parameters,
and 21,000 finite nonzero-gradient updates. All arms repaired 0/62 validation tasks;
the smallest selected GIN and its matched controls each repaired 0/89 held-out
tasks in all three seeds. The report separates coverage failures, rejected-commit
loops and teacher imitation from actual repair performance.
