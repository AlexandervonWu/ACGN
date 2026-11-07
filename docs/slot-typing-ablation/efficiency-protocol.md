# Typed versus untyped slots: efficiency protocol

Status: experimental design, not measured results. The two arms already exist;
additional timing/cap instrumentation and repeated-run supervision described
below are implementation prerequisites, not available command-line features.

The November 2026 instrumentation update implements source-slot and interface-slot
censuses and separates AST-adapter CPU from comparison CPU in the natural-corpus
arms. See [the census and CPU investigation](natural-slot-census-and-cpu.md).
The finer phase timers, search-attempt counters, and repeated-run supervisor below
remain planned. Previously recorded runs are not retroactively populated.

## Synthetic execution update

The synthetic-only [five-minute runner](synthetic-runtime.md) implements the
subsequent requested policy: no permutation/symmetry/pass/term-size cutoffs,
one isolated construction per predicate and arm, a 300-second process deadline,
and success-only median/P95 with full-denominator success rates. For synthetic
runs this supersedes the finite-budget, 30-second, repeated pair-comparison plan
below. The remaining sections retain the original broader efficiency design;
their optional warm/throughput/counter studies are not implied to be implemented
by the synthetic runner. Existing non-synthetic arms retain their 8! limits.

## Question and treatment

Does retaining parser-derived slot types reduce the cost of the same bounded
slotted equality/distance computation, and where does that saving or overhead
arise?

Compare only `slotted-egraph` with `slotted-egraph-typed`. Both use
`SlottedEGraph`, identical rewrite rules, scope/declaration structure, input
pairs, arity policies, resource budgets, and distance algorithm. The treatment
is retaining exact slot type colors in identity and admissible mappings.
This is not a comparison with the Certificate-Integrated typed-port engine.
Neither experimental arm issues semantic certificates.

Do not erase source declaration domains, quantifier order, temporal boundaries,
or disjointness from the untyped treatment. Do not use `univ` for missing types.
Failures to obtain an exact type are recorded as unsupported inputs, not
silently coerced or dropped. Semantic admission is unchanged by measurement.

Hypotheses are deliberately two-sided: type checks and metadata can increase
cost, while rejecting incompatible mappings or avoiding graph work can decrease
it. A result of no improvement is valid.

## Current implementation and confounds

- `EGraphAblationStudy.processFile` already records parse and engine wall/worker
  CPU time. Its **engine** timer includes AST-to-term adaptation, saturation and
  fallback distance; it is not a pure saturation timer.
- `EGraphAblationSuite` already runs isolated arm JVMs, records process CPU/RSS,
  samples heap every 10 ms, and writes manifest-bound reports. It currently runs
  untyped first, typed second, without a warm-up or repetition protocol.
- `SlotPermutationSearch` originally enumerated declaration-local groups, often
  already homogeneous in both arms. Version `slotted-independent-binding-blocks-v3`
  first combines eligible independent scalar ALL/SOME blocks; see
  [the current contract](independent-binding-blocks.md). Other scope/dependency/
  disjointness barriers remain. `n! / product(n_t!)` is a candidate-space ratio
  for an admitted combined block, not a runtime speedup prediction.
- The declaration-candidate and e-class symmetry-group limits are now both
  **40,320 (8!)**, raised from 720. A single eight-variable declaration fits its
  candidate limit; multiple declarations share the search budget. Larger
  declarations, products of groups, and other caps can still truncate work.
- Other existing limits remain: 32 rewrite passes, a 50,000-node accepted term
  size bound, eight alpha-canonicalization passes, and 16 rebuild rounds.
  No finite-cap result should be described as unrestricted saturation.
- Existing paired reporting refuses failures or mismatched successful inputs.
  Keep that fail-closed behavior; a new diagnostic supervisor must separately
  preserve timeout/OOM/error rows instead of declaring a failed run comparable.

Freeze these limits and the new dependency versions before measurement. Never
combine the old 720-budget results with the new 40,320-budget runs.

## Populations

1. **Primary stress population:** all 250 pairs / 500 target predicates in
   `synthetic-data/slot-binding-stress/models`, joined to its manifest. Preserve
   all 25 families, ten binding sizes (8 through 256), 210 expected-equivalent
   pairs, and 40 expected-different pairs. Do not include `probes/` as timed input.
2. **Small search controls:** add a separately manifested supplement with one
   through eight bindings, homogeneous and mixed domains, ordered uses, alpha
   changes, and positive/negative controls. These distinguish complete small
   searches from truncated large searches. This supplement is planned, not
   already part of the 500-predicate corpus.
3. **External validity:** use natural-corpus AST-different paired predicates in
   a separate run. Start with a seeded sample stratified by problem, status,
   binder size and temporal/non-temporal syntax; then optionally run the full
   eligible corpus. Freeze the file list before either arm runs. No sorted-prefix
   sample is presented as representative.

Retain the AST-identical exclusion invariant and report excluded counts. In the
stress corpus, all pairs should pass this gate. The synthetic `NEGATIVE` label
means expected non-equivalence, not an Alloy4Fun correctness classification.

The current stress profiles are not a full factorial crossing of size and type
diversity. Paired arm differences on each input are valid; cross-input trends
cannot alone establish a causal effect of the number of types. A separate
matched-template supplement should cross fixed binding size with 1/2/4/8 type
colors before making that stronger claim, recording all changed declarations.

## Pipeline

```text
Freeze source + dependencies + corpus + budgets
  -> Lean/regression/parser/reduced-solver preflight
  -> deterministic eligibility and trial manifest
  -> small balanced pilot, then freeze final schedule
  -> serial isolated paired latency trials
  -> separate matched throughput runs
  -> semantic-outcome and completion audit
  -> paired statistical analysis + plots + hashed report
```

**Preflight.** Run the slot-typing Lean/Java tests and synthetic validator. Compile
once outside timing and hash the actual class/JAR bytes. Record Git SHA and dirty
flag plus changed-source hashes; HEAD alone does not identify this worktree.
Do not use a previously packaged experiment JAR with unknown dependency versions.
The reduced solver probes validate their bounded instances only. In particular,
do not call an undersized long disjoint prefix semantically validated by vacuity.

**Pilot.** Use 25 manifest-selected pairs, one per family, covering small and
large sizes with a fixed selection seed. Observe time, memory and cap incidence.
Do not use pilot outcomes to remove hard families or choose a favorable arm.
Exclude pilot timing from the final estimates. A dependency or implementation
repair starts a new run ID and requires repeating both arms.

**Primary latency trials.** Use one application worker per JVM and run only one
child JVM at a time. Use three paired repetitions per input. Randomize input
order with a recorded seed and balance U/T versus T/U execution across pairs
and repetitions. Each arm/input/repetition gets a fresh JVM and fresh graph.
Measure one comparison: report this explicitly as cold-JVM engine latency, even
though process startup is outside the engine timer. Process wall time includes
startup. Three repetitions are a baseline; use the pilot to preregister more if
noise requires it, rather than stopping when a preferred result becomes significant.

Default primary resources: `-Xms256m -Xmx4g -Xss16m`, G1 GC,
`-XX:ActiveProcessorCount=1`, one worker, and the same CPU affinity on both arms
where supported. Record the physical-core/SMT topology and actual flags. Keep
desktop/background workloads low. CPU clocks, GC and JIT remain measured runtime
effects; worker-thread CPU alone does not capture their complete cost.

**Warm sensitivity check.** On a separately preregistered balanced subset, use
two untimed comparison calls followed by three timed calls in each fresh arm
JVM, rebuilding the graph for every call. Retain individual samples and report
them separately from cold latency. Do not claim two calls guarantee steady-state
JIT behavior, reuse a saturated graph, or warm only the arm that appears slower.

**Throughput.** Run the same full eligible list with 1 and 16 workers (16 bounded
by available logical CPUs), 8 GiB heap, identical GC/stack flags, and three paired
process repetitions per worker setting. Run arms serially, balancing their order.
Report corpus wall time and completed comparisons/second. Do not interpret
summed concurrent task latencies as elapsed time or total process RSS as
per-predicate memory. Keep throughput and isolated-latency estimates separate.

## Timeouts and observation contract

For isolated cold trials, default to a 30-second process deadline and a 4 GiB
heap cap. The deadline includes startup and parsing; record progress markers to
identify the last phase. A supervisor terminates the entire child process group
on timeout, waits for exit, and then records its status. Do not rely on a Java
Future cancellation to stop CPU-bound work. Warm trials use an independently
declared 120-second process deadline. Throughput trials use a declared whole-run
deadline and persist per-input completion records incrementally.

Use a six-hour default total supervision budget. At 250 pairs, two arms and
three repetitions, the primary schedule has 1,500 child trials; its theoretical
30-second-per-child ceiling is 12.5 hours, not a promised runtime. On the total
deadline, report remaining trials as `NOT_RUN_BUDGET` and the experiment as
partial. Do not selectively extend deadlines for one arm or hide an incomplete
schedule. The pilot provides the actual completion-time estimate.

Keep execution status separate from search completeness:

- Execution: `OK`, `TIMEOUT`, `OOM`, `STACK_OVERFLOW`, `UNSUPPORTED`, `ERROR`,
  `SKIPPED_AST_IDENTICAL`, or `NOT_RUN_BUDGET`.
- Search: booleans/counts for candidate truncation, symmetry-closure truncation,
  alpha-pass exhaustion, rewrite-pass exhaustion, rebuild exhaustion, and
  rejected oversized terms. A cap flag means unfinished work actually remained,
  not merely that a counter equaled its limit.
- Outcome: distance, equality observed, graph-root equality versus fallback
  zero, expected relation and label basis. Absence of equality at a finite
  budget is not a proof of inequivalence.

## Instrumentation to add

Keep observer counters local to each comparison, with no effect on iteration
order, pruning, admission or resource budgets. Emit summaries after timed work;
avoid per-candidate logging, global locks and forced GC inside timed intervals.

Required non-overlapping wall and worker-CPU phase timers:

1. Parse/type-check and repository AST creation/selection.
2. AST-to-term conversion, including exact-type extraction where applicable.
3. Slot erasure/preparation, alpha canonicalization and initial graph insertion.
4. Rewrite loop, graph insertion/union and rebuild.
5. Root equality check and fallback edit-distance matching.

Instrument subphases as nested measurements only if explicitly labeled; never
sum overlapping timers. Report adapter+engine cost as well as engine-only cost
so exact-type extraction is not made artificially free.

Count candidate mappings visited, color checks/rejections, shape/hashcons hits,
union attempts/successes, symmetry compositions/members, rebuild rounds,
rewrite applications, and fallback-distance comparisons. Record graph sizes,
slot counts and cap events. Existing `slotMappings` counts stored mapping entries,
not search attempts; do not rename it into a pruning counter.

Use `/usr/bin/time -v` for process wall/CPU/max RSS and JVM GC counters/logs for
collection count/time. Heap samples are approximate observed peaks; structural
byte estimates are not measured allocation or retained heap. Missing CPU/RSS
instrumentation is `unavailable`, never zero. Any optional allocation profiler
runs separately from headline latency trials.

Regression obligations for this instrumentation: on/off yields identical
distance/outcome and graph statistics; deliberately small test budgets expose
each truncation status; timeout/OOM children cannot stall supervision; treatment
metadata and input hashes agree; generated reports retain every scheduled row.

## Analysis and deliverables

For each pair and arm, take the median measured engine latency across its
repetitions. Define speedup as `median(untyped) / median(typed)`: above one favors
typed slots. Report its geometric mean and median on matched completed inputs,
with 95% paired bootstrap intervals resampling input pairs (not individual
repetitions). For pooled synthetic results also give equal-family-weighted
summaries and a family-cluster sensitivity interval; ten sizes of one generated
template are not ten independent real-world programs.

Publish results by family, binder size, type diversity, temporal presence,
positive/negative expectation and cap status. The main speed comparison must
also show correctness/completion rates on the full eligible denominator. Give
an outcome-matched subset and an uncapped subset separately: a false merge or
early shortcut is not an efficiency win. Preserve valid measured timings from
failed cases only as diagnostics, not completed-comparison latency estimates.

Do not substitute timeout thresholds for completed times in the geometric mean.
Report censored counts and completion-by-deadline curves; where one arm finishes
and the other times out, provide only the applicable process-time ratio bound.
Engine-time bounds require an engine-specific timer/deadline. If there are no
matched samples, report the estimate as unavailable. A false merge blocks an
unqualified semantic-preserving-speedup claim and must have its witness retained.

Expected outputs in a new run directory:

- `manifest.json`: source/build/dependency/dataset hashes, run ID, JVM/OS/CPU,
  flags, workers, seeds, ordered trial list, warm-up policy, limits and timestamps.
- `trials.jsonl`: append-only observations including incomplete/failed trials.
- `pairs.csv` and `summary.json`: matched estimates, dispersion, completion,
  correctness and cap incidence; no fabricated rows for missing work.
- `summary.md`: protocol, frozen configuration, results, limitations and failures.
- Plots: engine latency versus bindings; paired speedup versus bindings; time
  breakdown; mapping attempts/rejections; completion and cap incidence; RSS; and
  1-versus-16-worker throughput. Mark log axes and failure denominators explicitly.
- Input witnesses, process logs, and `SHA256SUMS` covering generated outputs.

The report reader rejects mixed build/data/rule/budget/resource schemas, duplicate
trial IDs and missing scheduled observations. Repeated arms need separate run
directories; do not overwrite existing publication outputs or their manifests.

## Available commands versus next implementation

Available now, for preflight and one exploratory pair of arm runs:

```sh
./scripts/run_slot_typing_ablation_tests.sh
./scripts/validate_slot_binding_stress.sh synthetic-data/slot-binding-stress /tmp/slot-preflight
./scripts/run_egraph_ablation.sh --slot-typing \
  --input synthetic-data/slot-binding-stress/models \
  --output /tmp/slot-efficiency-exploratory --threads 1 --max-heap 4g
```

The last command is **not** the full protocol: it has fixed arm order, no
repetitions, no new phase/cap counters, no per-case watchdog, and its current
child JVM flags differ from the planned latency profile. It may be slow under
the new 8! limit. Do not present its output as the controlled final experiment.

Implementation order: add observational timers/cap reporting; add the isolated
trial supervisor and manifest checks; add the small controls and report reducer;
run regression/preflight; run the pilot; then execute the frozen measurement plan.
No new rewrite family or semantic rule is needed for this experiment.
