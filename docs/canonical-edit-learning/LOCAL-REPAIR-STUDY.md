# Local Repair Learning: Bounded Protocol

Contract: `local-feedback-repair-v1`. Frozen before model evaluation.

The 42 general and 20 concrete Lean model checks were recompiled in two fresh
directories before runtime edits. This study implements the source-local
teacher, stable rejection suppression, exact visited-state replay and recovery
admission specified in `LOCAL-REPAIR-SPECIFICATION.md`. Java/Python correspondence
is supported by finite source-level regressions, not a universal refinement proof.

Use the existing 64 training tasks in `docs/rl-corpus-data/tasks.json`, in their
frozen order; do not select tasks by teacher success. Begin with the first eight
as a learnability diagnostic, retaining unavailable teachers in coverage. The
1/8/64 thresholds remain 1/1, 8/8 and 60/64. Larger-data, Qwen and roughly 500M
scratch runs remain gated if these fail. No held-out claim follows from this run.

Compare GIN, GCN, GraphSAGE, edge-aware attention and a no-message MLP, width 128,
three layers, seeds 17/29/43. Use AdamW (learning rate 0.001, weight decay 0.001),
gradient clipping at 1, eight decisions per update, 1,000 initial updates and
two aggregation rounds of 500 updates each. Use fixed-seed sampling, report
actual losses/gradient norms and checkpoints. All arms share initial teachers;
on-policy states necessarily differ by arm. Do not claim paired identical
training data after aggregation.

Every method uses four genuine semantic queries, 256 decisions, 30-second
worker requests and 120-second rollout deadlines. This is the explicitly new
Q=4 arm, not a direct causal comparison with the earlier Q=2 study. Match no-op
and uniform controls. Count internal solver calls separately where available.

The offline expert proposes occurrence-local mismatches, uses public COPY
choices for reusable operands, and validates its complete continuation. It may
fall back to a labelled root reconstruction when local realization fails; log
this rather than count it as a local plan. Search is bounded to eight committed
edits and at most 128 proposals, with external process deadlines. Structural
matching only proposes candidates; it never issues semantic authority.

After each learner rollout, retain at most four distinct open snapshots, preferring
actual rejected/draft states and then valid committed states. Reconstruct each
snapshot from the original source and its exact chronological action prefix in
an offline worker. Require equality of the public packet; divergence rejects
the label. No teacher future feedback or oracle source enters the observation.
Admit either a freshly replayed successful continuation or a separately checked
ABORT_DRAFT recovery label. Unlabelled states remain in the coverage report.

Train with complete joint action probabilities. Deduplicate alternatives before
log-sum-exp; do not cross-combine pointer/operator fields. Sample initial and
aggregated examples with equal category probability when both exist. Preserve
the recovery/continuation class and report their counts; recovery is not success.

Retain inputs, source hashes, proof/test logs, teachers, exact rollout prefixes,
admission failures, checkpoints, sampling schedules, resource measurements and
reports in fresh external directories. Never overwrite historical results or
the original corpus. No network or installation is needed.

## Historical Public Views

The encoder also needs earlier committed public revisions for multi-edit paths.
`LocalRepairArchive.lean` proves current/historical lookup separation, missing
history rejection, distinct revision addresses, a public-only projection and
the combined row-budget implication. Runtime archives are populated solely from
actual observations. Historical rows use the same semantic feature channels but
revision-qualified addresses, never current-row aliases or learned IDs. Count
all retained encoded rows against the 8,192-row cap; reject overflow rather than
truncate history. These model lemmas do not prove the Python transport code;
source-backed two-commit tests check that correspondence separately.
