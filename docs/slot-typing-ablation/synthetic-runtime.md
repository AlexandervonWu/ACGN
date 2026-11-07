# Synthetic representation runtime

## Contract

The population is 500 individual target predicates, not 250 pair comparisons.
Each predicate is evaluated once through `typed` and once through `untyped`:
1,000 independent child JVM trials. No fallback edit distance or oracle
comparison is included in the timed construction. A successful trial means
the existing slotted rewrite procedure produced a stable frontier and completed
its graph rebuild and representation output. It is not a semantic certificate,
a successful repair, or a proof that two predicates are equivalent.

Only this synthetic entry point removes the following finite search limits:

- Declaration permutation count (formerly 8!); permutations are streamed rather
  than allocating the factorial-sized list before searching.
- Stored e-class symmetry-group size (formerly 8!).
- Alpha-canonicalization passes, rewrite passes, accepted term size, and rebuild
  rounds. A still-changing computation must finish or fail; a capped partial
  frontier is never reported as successful construction.

`SlottedEGraph.compare` and existing corpus/ablation programs retain their bounded
behavior. No rewrite law, scope rule, type admission, or certificate authority
was added. Finite machine resources still apply: heap exhaustion and stack
overflow are failures, not reasons to accept a partial result.

Each child receives **at most 300 seconds**, measured by the parent monotonic
clock from launch through process completion, including parsing, construction
and output. At the deadline the supervisor kills and reaps the process group,
records `TIMEOUT`, and continues. Late payloads are not accepted. A separate JVM
per predicate contains an OOM or non-interruptible loop; the parent does not rely
on thread interruption. Ctrl-C or SIGTERM during trials stops active children
and records unfinished work.
Operating-system scheduling can delay delivery of SIGKILL; such a late child
still counts as failure, never as success after 300 seconds.

The worker uses `SlottedEGraph.representUnbounded`. It has no internal watchdog
and must not be called in a long-lived production service. Run it through the
supervisor below. `SlotCanonicalizer` keeps lexical candidate order while
enumerating lazily in both modes; bounded regression tests check its old behavior.

## Run

From the repository root, first run the bounded tests:

Requirements: a POSIX host with process-group signaling, Python 3.9+, a JDK 17+
on PATH and the repository dependencies. Lean is needed for the test gate.

```sh
bash scripts/run_slot_typing_synthetic_tests.sh
```

Then select a new output directory and execute the full synthetic experiment:

```sh
python3 scripts/run_slot_typing_synthetic.py \
  --dataset synthetic-data/slot-binding-stress \
  --output /tmp/acgn-synthetic-typed-untyped-full \
  --workers 1 --heap 4g
```

The default deadline is 300 seconds. Values above 300 are rejected.
`--timeout-seconds` can reduce it for smoke tests, but the changed deadline is
recorded and those runs are not the requested five-minute experiment.
`--limit-pairs N` selects a deterministic seeded subset and still tests both
predicates in each selected pair, in both arms. Omit it for all 500 predicates.
There is no global time cutoff in this dedicated runner.

Default concurrency is one isolated JVM for minimally contended latency. To
increase throughput, use e.g. `--workers 4`, budgeting at least four times the
4 GiB heap plus native JVM memory and OS headroom. Each child uses one active JVM
processor, G1, `-Xms256m`, `-Xss16m`; it is not CPU-affinity pinned. Do not pool
latencies collected at different worker/heap settings. At four workers, the
all-timeout ceiling is approximately 20.8 hours plus validation/build overhead;
at one worker it is 83.3 hours. These are worst-case ceilings, not predictions.

Input order is shuffled with a recorded seed and arm launch order is alternated
across pairs. Separate children do not share warmed graphs. Higher concurrency
can overlap arms, so it is explicitly recorded rather than presented as isolated
single-worker timing. No rewarded runs or full-corpus experiments are launched
by the test script.

## Reporting

`summary.md` and `summary.json` contain typed/untyped figures overall, by family,
and by outer binding count:

- Number scheduled, successful constructions, failures and incomplete trials.
- Success rate = successful constructions / scheduled predicates for that arm.
- Median and P95 process runtime **over successful constructions only**.
- Median and P95 engine runtime **over successful constructions only**; engine
  time includes adaptation and construction, but excludes parsing/startup.
- Failure status counts and a separate timing table for predicates that succeeded
  in **both** arms, to expose differing successful subsets.

P95 is the nearest-rank order statistic `ceil(0.95 * N)`. Median uses the average
of the two middle values for even N. Zero successes produces JSON `null` and
Markdown `unavailable`, not zero seconds. Timeouts/OOM/errors are never inserted
as successful timing samples or removed from the success-rate denominator.
Incomplete runs retain `NOT_RUN`/`INTERRUPTED` rows and are explicitly labeled
partial. A smaller success-only median does not alone establish a faster engine:
the success rate and outcome-matched subset must be considered too.

The supervisor's exit code 0 means the measurement schedule was fully collected,
even if some/all predicates failed. Per-predicate failures are in the rows and
summary. Exit 2 indicates interruption/partial collection. Build, validation or
infrastructure exceptions abort rather than publish a valid-looking experiment.

`predicates.csv` and flushed `trials.jsonl` retain individual observations.
Each child directory has its process log, structured result if completed, and
the successful normalized frontier text/hash. Timed-out rows identify the last
reported phase. The text is a representation artifact, not an Alloy-runnable
backtranslation or an exported semantic certificate.

The runner freezes selected source files and runtime JARs in its output tree,
compiles once before timing, validates the synthetic manifest through the Alloy
parser/AST adapter (including rejection of AST-identical pairs), and records
source/dependency/class hashes, JVM, host, resources, schedule and timestamps.
`SHA256SUMS` covers the finalized outputs. It refuses existing output directories
or an output inside the source dataset. The original corpus and published
empirical directories are not modified.

## Proof and validation boundary

`TimedOutcome.lean` proves: timeout prevents success; incomplete computation
prevents success; success entails completion; successful counts cannot exceed
the number of observations. The counting lemma uses Lean's standard `propext`
and `Quot.sound`; the deadline lemmas require no axioms. There are no proof
placeholders or newly declared axioms. These are policy-level results, not a
proof of Python/JVM/OS timer refinement or the rewrite engine's semantic soundness.

Correspondence tests exercise real process-group termination (including a child
descendant), late result rejection, hash/identity checks, zero-success reporting,
nearest-rank P95 and full denominators. Java tests compare small uncapped outputs
with the bounded procedure and use a nine-binding reversal that the 8! prefix
does not identify but uncapped enumeration does. Existing slot typing and
e-graph ablation regressions remain part of the test gate.

The full experiment has intentionally not been launched. Bounded smoke runs
use separately recorded reduced timeouts; they establish runner functionality,
not 500-predicate performance or semantic completeness.

Validation on 2026-11-06: four Lean policy theorems, twelve supervisor/report tests,
18 synthetic Java checks, 31 existing slot-typing checks, and the e-graph ablation
suite passed. The seed-28 one-pair/10-second smoke had 2/2 successes in each arm;
the seed-214 one-pair/2-second smoke had 2/2 representation-phase timeouts in each
arm and correctly emitted unavailable successful-runtime statistics. Reports are
in `/tmp/acgn-synthetic-success-20261106` and
`/tmp/acgn-synthetic-deadline-20261106`, respectively. These reduced-deadline
checks are not results for the full five-minute experiment.
