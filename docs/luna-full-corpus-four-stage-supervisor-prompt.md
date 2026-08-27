# Luna Max Full-Corpus Four-Stage Supervisor Prompt

Use the following prompt verbatim for the supervised experimental run.

---

Work in `/home/augustus/ACGN`. Supervise one complete full-corpus experiment
run over `classified-data` using the current source tree. Do not consult the
internet. Do not modify `classified-data` or any checked-in result snapshot.
Write all generated artifacts and logs to one new directory outside the Git
worktree.

## Fixed Run Configuration

- Stages, strictly serial:
  1. `CanonicalBatchTest`
  2. `Alloy4FunAugmenter`
  3. seven-arm e-graph ablation and its semantic checker
  4. capability study
- Reward pool: exactly `100` for stages 1 and 2.
- Dataset limit: none; use all `66,080` Alloy files.
- Workers: exactly `16` requested workers.
- JVM heap cap: `8g`, unless a measured heap failure justifies a documented
  change on a restarted run.
- Build: compile once with Java 17 and UTF-8 through the serial runner.
- Never start a stage until the prior stage and its validation gate complete.

The requested worker count scales with logical processors, but memory-heavy
certificate and Rewarder phases use the shared admission rule:

```text
min(requested workers,
    16,
    max(1, floor(max(384 MiB, max heap - 512 MiB) / 384 MiB)))
```

At the fixed 8 GiB heap and 16 requested workers, the effective limit is 16.
The same policy would admit nine workers at 4 GiB, four at 2 GiB, and fourteen
at 6 GiB. Do not override the effective limit merely to match a larger
logical-core count; the fixed run configuration is intentionally bounded at
16 workers for every stage.

Create an external run root and launch the existing serial workflow:

```bash
cd /home/augustus/ACGN
RUN_ID="acgn-luna-full-$(date -u +%Y%m%dT%H%M%SZ)"
RUN_ROOT="/home/augustus/$RUN_ID"
mkdir -p "$RUN_ROOT"

DATASET="$PWD/classified-data" \
DISTANCE_OUTPUT="$RUN_ROOT/distance_results" \
AUGMENTED_OUTPUT="$RUN_ROOT/alloy4fun-augmented" \
ABLATION_OUTPUT="$RUN_ROOT/egraph_ablation" \
CAPABILITY_OUTPUT="$RUN_ROOT/capability_benchmark" \
SERIAL_SUMMARY="$RUN_ROOT/experiment_results_summary.md" \
REWARD_POOL=100 \
THREADS=16 \
MAX_HEAP=8g \
./scripts/run_experiments_serial.sh \
  > >(tee "$RUN_ROOT/stdout.log") \
  2> >(tee "$RUN_ROOT/stderr.log" >&2)
```

Record before launch:

```bash
git rev-parse HEAD > "$RUN_ROOT/source-head.txt"
git status --porcelain=v1 --untracked-files=all > "$RUN_ROOT/source-status.txt"
find src certificate-verifier scripts docs documentation -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum > "$RUN_ROOT/source-files.sha256"
find classified-data -type f -name '*.als' -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum > "$RUN_ROOT/dataset-files.sha256"
```

The source manifest, not a claim about repository cleanliness, identifies the
exact supervised snapshot.

## Progress Supervision

Observe progress at least once per minute. Continuous progress may be slow in
known complex corpus regions and is not itself a failure. If progress does not
advance for 15 minutes:

1. record the last completed/total count and in-flight task count;
2. capture `jcmd <pid> GC.heap_info`, `jstat -gcutil <pid> 1000 5`, and
   `jcmd <pid> Thread.print` under `$RUN_ROOT/diagnostics/`;
3. distinguish CPU-bound work from GC pressure, deadlock, one-task tail, and
   retained-task growth;
4. terminate only a genuinely stuck or failed process, retaining its complete
   log and diagnostics.

Treat the run as GC-collapsed and stop it when two diagnostic windows show old
generation remaining above 98%, full-GC time consuming more than half of wall
time, and no material recovery in completion rate. High aggregate CPU does not
override that condition because parallel full GC can consume many cores. The
Stage-1 startup line must report finite `memory-intensive concurrency`; for
`-Xmx8g` and 16 requested workers the expected limit is 16. Preserve all
diagnostics and the incomplete output, mark the attempt failed, and escalate
before restarting Stage 1 in a new run root.

Never silently skip a source, retry indefinitely, downgrade an exception to a
successful row, or proceed with a partial stage.

## Stage Gates

### Stage 1: CanonicalBatchTest

Require:

- total files: `66,080`;
- successful distances: `61,598`;
- AST-identical skips: `4,482`;
- failures: `0`;
- reward pool size: `100`;
- memory-intensive worker limit: `16` under `-Xmx8g` with 16 requested
  workers;
- reward failures: `0`;
- incorrect zero-distance merges: `0`;
- no certificate-kernel contradiction, unbound variable, unreachable phase,
  dependent-type mismatch, or unchecked equality exception;
- both Certificate-Integrated IR and Fast Rewrite IR fields in JSON and
  Markdown.

### Stage 2: Alloy4FunAugmenter

Require:

- all `66,080` files audited before pool construction;
- exactly `4,482` AST-identical files excluded before truth pools;
- exactly `61,598` files considered;
- reward pool size: `100`;
- reward worker limit: `16` under `-Xmx8g` with 16 requested workers;
- zero terminal parse, preparation, ranking, correct-pool, reward, or
  certificate-kernel failures;
- oracle solutions co-equal with AST-distinct correct student solutions;
- no AST-identical duplicate inside a truth pool;
- every incorrect predicate ranked against every admissible correct reference;
- both canonical implementations and all three baseline distances retained;
- retry paths and first/final errors persisted in `parse_retries.csv`.

### Stage 3: Ablation And Semantic Check

Require:

- all seven configured arms complete from the same dataset and source build;
- compatible manifests, worker counts, seeds, schema versions, and pair
  universes;
- AST-identical pairs excluded consistently in every arm;
- `comparison.json`, `minimum_distances.csv`,
  `equivalence_disagreements.csv`, all arm summaries, and semantic-soundness
  reports present;
- no rejected or unchecked claimed equality on a supported execution path;
- every reported zero has the authority required by that arm's stated model.

### Stage 4: Capability Study

Require:

- capability results consume the completed stage-3 run rather than silently
  regenerating another natural-corpus sample;
- every configured arm appears in `results.json`, `REPORT.md`, and the arm
  summary;
- no exception, missing matrix cell, incompatible manifest, false capability
  claim, or conclusive semantic-soundness failure;
- counts and labels agree across JSON, CSV, and Markdown.

## Mandatory Sol Max Escalation

Any exception, nonzero failure count, certificate contradiction, behaviorally
different zero, backtranslation mismatch, unsupported-path rejection reached
from valid source, missing output, or cross-report contradiction blocks the
current run. In particular, do not ignore a problem merely because it appears
in stage 2, 3, or 4 after earlier stages consumed hours.

For each distinct root-cause class, create a Sol Max repair agent. Give it the
exact source witness, stage command, source manifest, complete exception, and
relevant generated rows. Ask a second Sol Max agent to review the proposed
repair independently when the change touches semantic authority or the zero
kernel.

Each Sol repair must:

1. reproduce the defect on a valid supported source-to-result path;
2. minimize the witness without replacing its semantic feature;
3. identify the violated invariant and the narrow production transition;
4. repair the general sound invariant, not only the filename or spelling;
5. preserve temporal-phase separation, exact binder provenance, dependent
   typing, source authority, and fail-closed certificate boundaries;
6. add a parser-backed Java regression that fails before and passes after;
7. add or extend a standalone Lean proof for every changed semantic claim,
   with guards corresponding exactly to production type, arity, operator,
   scope, and provenance checks;
8. use no `sorry`, `axiom`, or `unsafe`, and do not substitute a weaker toy
   theorem for the Java invariant;
9. avoid inventing a semantic Lean theorem for a purely operational scheduling
   change; operational changes instead need deterministic concurrency and
   failure-path regressions;
10. update an incident report under `docs/section3-repair-audit/`, the global
    fault register, the relevant formal-proof inventory, and
    `docs/full-corpus-preflight.md` so code, proof, version labels, tests, and
    status all agree;
11. keep discoveries outside core soundness logged as future work rather than
    expanding the immutable static rewrite inventory during this run;
12. run the focused Java/Lean checks and `git diff --check` before returning the
    repair to Luna.

No repair may broaden authority from spelling, synthetic metadata, `univ`, or
an observed equality. Do not weaken a gate to make the experiment continue.

## Restart Rule After Repair

A source change invalidates every result produced by the prior build. After
accepting any Sol repair:

1. stop the current run;
2. preserve its root as a failed attempt and write `BLOCKED.md` with the exact
   cause and repair commit/source digest;
3. create a new external run root;
4. regenerate source and dataset manifests;
5. restart at stage 1 and run all four stages again.

Never combine pre-repair stage-1 data with post-repair stage-2, stage-3, or
stage-4 data.

## Final Report

Return only after all four gates pass on one unchanged source manifest. Report:

- run root and source/dataset manifest hashes;
- source HEAD and dirty-tree record;
- exact commands, workers, heap, reward pool, and wall time per stage;
- stage success/skip/failure and reward counts;
- ablation and capability completion counts;
- every escalation, minimized witness, Sol repair, regression, Lean file, and
  documentation update;
- hashes of all generated JSON, CSV, Markdown, SVG, PNG, manifest, and log
  outputs;
- explicit confirmation that `classified-data` and checked-in empirical
  snapshots were not modified.

If a blocker remains unresolved, return `BLOCKED` with the exact run root and
evidence. Do not claim a partial run as complete.

---
