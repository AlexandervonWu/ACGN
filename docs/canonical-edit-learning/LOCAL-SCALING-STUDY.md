# Local Feedback Repair: Larger-Data Study

Contract: `local-feedback-repair-v1`; study: `local-feedback-scaling-v1`.
Frozen before new teacher collection, training or validation. The user's explicit
request authorizes this diagnostic scaling study despite the failed eight-task
gate. It does not mark that gate passed or authorize Qwen/500M training.

## Proof And Correspondence Boundary

Before runtime edits, the 42 general `LocalRepair` theorems and 20 concrete
fixtures were rebuilt twice; the six `LocalRepairArchive` and ten
`FeedbackScaling` theorems also compiled. These existing models cover the public
input boundary, query/decision budgets, replay admission, train-only gradients,
question-disjoint assignment, validation-only selection, failure denominators
and transparent caching. They do not prove Java/Python refinement, floating-point
learning, solver correctness, optimization convergence or generalization.

The new implementation must use the same public structured observations, local
executor, COPY operands, complete-action loss and fresh replay admission. Private
truths may supply offline training labels, never inference features. PyTorch,
CUDA, Lean, JVM/parser and bounded Alloy solving retain their trusted roles.
Source-backed tests check external source routing, historical views, train-only
indexing, cache transparency, accounting and selection; their evidence is bounded.

## Data And Evaluation

Reuse `scaling_data.select_sources`: six existing non-temporal problem sets,
fixed hash order, at most 32 sources per question and quotas 512/64/96 for
train/validation/evaluation. Freeze the selection before preparing any source or
asking a teacher. Exclude only the existing AST-identical and duplicate-AST-pair
categories. All other unsupported/failed sources remain in evaluation denominators.
Do not backfill by teacher success. Collect teachers for training sources only.

This reuses the earlier question-disjoint benchmark. Earlier aggregate results
are already known; it is not a newly untouched test set. For this study, choose
one configuration using validation repairs only, then parameter count, then fixed
configuration order. Persist its selection and checkpoint hash before reading
new evaluation outcomes. Do not tune any setting after evaluation exposure.

## Frozen Training Schedule

Screen seed 17 for four configurations, in order:

- GIN: width 256, four message layers.
- GIN: width 512, six message layers.
- Edge-aware attention: width 256, four message layers.
- No-message MLP: width 256, four layers.

Use AdamW, learning rate 0.0003, weight decay 0.001, gradient clipping at 1,
and eight complete decisions per update. Initial imitation receives 3,000
updates, followed by two 1,000-update on-policy aggregation rounds. This is
supervised imitation plus dataset aggregation, not policy-gradient RL. No
checkpoint is selected by an interim validation score: validate only the final
5,000-update checkpoint. Save gradients, sampling schedules and checkpoints.

Before collection, choose up to 32 training roll-in tasks by round-robin over
question groups in frozen order. Do not use teacher success or model performance
to choose them. After each of the first two training rounds, run those tasks and
request at most two snapshots per task, using the existing public rejection/draft
priority. Admit freshly replayed semantic continuations or separately checked
ABORT recovery; retain all failures. Sample initial and aggregated categories
equally when both are nonempty, then a trajectory and decision uniformly within
the selected category. Trajectories are not claimed to be equally distributed
across question groups. On-policy data necessarily differ by arm.

Train two additional seeds (29, 43) for the locked configuration, using the same
schedule and training-only roll-ins. Evaluate all three seeds on all eligible
test tasks and compare no-op/uniform controls under identical maximum budgets.
Report a question-cluster bootstrap of the paired repair advantage, not an
independent-sample interval over repeated seeds. No data is dropped due to
nonrepair, coverage refusal, resource exhaustion or timeout.

## Resources And Evidence

Keep Q=4 genuine semantic-query requests, 256 decisions, 30-second worker
requests and 120-second episodes. Use at most four Java workers, each with a
2 GiB heap. Use one GPU, sequential optimizer steps, and sequential learned
evaluation to keep observation encoding and GPU behavior comparable; independent
teacher collection and no-model controls may use four workers. Cap the estimated
host example cache at 1 GiB and public encoded graphs at 8,192 rows. Keep GPU
allocation under 14 GiB, leaving room for the desktop. No truncation or silent
sample dropping is permitted. A training OOM/nonfinite loss stops the run; a new
protocol/run is required to change settings.

Store the run outside the repository; freeze relevant source, rules, split,
library and protocol hashes and verify them again at completion. Retain teacher
requests/replays, failures, complete rollouts, aggregation admissions, schedules,
checkpoints, validation selection and resource measurements. Record source HEAD
and the dirty-tree flag. Preserve all old experiments and the original corpus.
Publish an honest summary including remaining limits and explicit later-stage
status, whether results improve or not.

JSON-producing JVM subprocesses use `-XX:-UsePerfData`: shared `/tmp/hsperfdata`
instrumentation must not inject startup warnings into the JSON stream. This is
a process-instrumentation setting, not a new Alloy rule or learned feature.
The initial collection attempt was stopped before training after such a warning
spoiled one valid source's metadata. Its files are retained separately; a new
preflight and full collection are required, with unchanged selection/training
settings. No result from the stopped attempt is admitted into the final run.
