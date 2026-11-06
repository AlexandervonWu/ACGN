# Local Scaling: Correspondence And Incidents

Study: `local-feedback-scaling-v1`, 2026-10-04.
See [the frozen protocol](LOCAL-SCALING-STUDY.md).

## Implementation Map

`local_scale_data.py` reuses the previous deterministic question-disjoint source
selection and AST-pair exclusions, before teacher collection. It verifies each
prepared source's hash when resolving its external path, and obtains teachers
only through `local_runtime.collect_label`. Every accepted path is freshly
replayed and fully encodable. Teacher failures are coverage records, not a reason
to backfill the corpus or remove held-out tasks.

`local_scale_bank.py` builds an index only from admitted training rows. The bank
is a lazy CPU cache of exact observations, historical public views and complete
action alternatives. Its one-GiB estimate includes JSON object expansion and
encoded tensors. Eviction changes caching, not the sampled example. The existing
8,192-row encoder limit remains fail-closed; training never silently skips a
sample that fails loss construction or encoding.

`train_local_scaled.py` uses the same `train_local.rollout`, `joint_loss`,
`make_policy` and Java executor as the smaller local-repair run. It increases
data/model/update scale and collects up to two on-policy snapshots from each of
32 fixed training roll-in tasks per round. Roll-in selection is round-robin by
question, independent of teacher availability and model outcomes. A semantic
continuation requires replay; ABORT recovery has a separate checked admission.
Private teacher records remain outside policy inputs. The model sees only public
graph/history/draft/feedback packets and the public structured action masks.

All screening fits finish before validation-only selection is written. The
selected configuration and seed-17 checkpoint hash are locked before test
evaluation. Seeds 29/43 are trained from new weights with the locked settings.
No-op/uniform controls share maximum query/decision budgets, not necessarily the
same number of queries actually spent. Reported query attempts are requests to
the semantic worker, not counts of every internal SAT call or offline expert call.

Learned rollouts are sequential on one GPU. Independent source/teacher/control
jobs may use four JVMs. Recorded training time includes roll-ins and expert
collection, not just GPU optimization. The reported host maximum RSS is a
process-lifetime high-water mark, not an isolated per-model allocation.

## Proof And Runtime Evidence

Before implementation changes, 42 general local-repair theorems and 20 concrete
fixtures compiled in two fresh builds, followed by six public-history and ten
scaling lemmas. The current preflight recompiles them. They establish properties
of explicit mathematical models under Lean's standard foundations; the archive
budget lemma uses `Classical.choice`. No new semantic rewrite or axiom was added.
These 78 model/fixture theorems do not prove Python/Java implementation refinement.

The new ten-test scaling suite checks external-source hash binding, held-out
teacher/index rejection, teacher-independent roll-in selection, cache-transparent
encoding, invalid terminal-label rejection, attempted-request accounting,
failure-denominator retention, JVM JSON-channel configuration, and an actual
four-update training/two-aggregation-round fixture using real Java workers.

Fresh preflight v2 passed 15 local Java checks, 132 feedback checks, 64 environment
checks, 38 learning checks and 93 Python test executions: 342 executions total.
The existing tests cover historical pointers, private-target isolation and fresh
replay. This is finite correspondence evidence, not a proof of every possible
source, exceptional path, optimizer behavior or semantic repair.

## Infrastructure Incident

The first data attempt prepared a valid source but received a JVM instrumentation
warning before its JSON metadata:

```text
Cannot use file /tmp/hsperfdata_augustus/2084413 because it is locked by another process
```

The affected source was
`classified-data/socialMedia/under/LCAXyakjHLrHZDwQK_inv7.als`, task
`7de0f1d9e1b132b14181`. Strict JSON parsing correctly rejected the mixed stream,
but this was not a source-language or model defect. Collection was stopped before
any scaled training. The incomplete run remains in
`/tmp/acgn-local-scale-data-20261004-v1`; it supplies no final-run labels.

The source preparer, offline local expert and feedback-worker launch now use
`-XX:-UsePerfData`. This disables shared JVM performance instrumentation rather
than ignoring arbitrary output or weakening JSON parsing. The selection,
semantics, model configuration and training budgets are unchanged. A fresh v2
preflight passed and a full v2 source preparation succeeded for all 672 files.
The process flag is part of the recorded JVM/runtime trust boundary, not a Lean
claim about the Java virtual machine.

The larger-run wrapper also records issued decisions/queries before waiting for
a response, including an exception or timeout. Completed-action counts and
attempt counts stay distinct. Optional held-out snapshot retention is disabled
to avoid retaining unused teacher-label candidates; actual public history needed
by model inference is still encoded. Neither bookkeeping change grants semantic
acceptance or changes the action-selection interface.

## Remaining Limits

This scaling exercise is explicitly authorized despite the failed eight-task
gate. It does not retrospectively pass that gate. Qwen and roughly 500M scratch
training are not part of this run. The benchmark was used earlier; this is not a
new blind test set. Import, CALL and some local canonical-declaration coverage
limits remain, and unsuccessful tasks stay in the denominators. The expert
still restarts active drafts and emits singleton alternatives. No optimizer
convergence, complete repair search or effective counterexample reasoning follows
from a finite nonzero gradient or from teacher replay alone.

The completed initial v2 collection admitted 309 paths (4,397 decisions), compared
with 313 old root-teacher paths on the identical benchmark. The existing 161
coverage failures remain: 124 imports, 32 initial local-declaration observations
and five CALL tables. Four additional local proposals failed at COMMIT: three
unsupported intermediate declaration observations and one ill-typed relational
join. These are proposal/coverage failures, not admitted invalid labels or model
test outcomes. Their requests, failed proposals and source identities remain in
the collection evidence; no source was substituted to hide them.

## Observed Rollout Limit

The attention model's seed-17 validation episode
`3447e9a4d3b634f8757a`, sourced from
`classified-data/classroom_fol/both/fAciRcHWJGwBWPkbJ_inv12.als`, reached
`HISTORY_ROW_BUDGET_EXCEEDED`. Its recorded trace issued one semantic query and
58 decisions, reaching revision 19 through repeated committed edits before the
next encoding exceeded the frozen 8,192-row public-history bound. This is an
unsuccessful learned rollout, separate from initial import/declaration coverage
failures and from GPU memory exhaustion. It remains in the 62-task validation
denominator; no history truncation, larger limit or replacement task was used.
