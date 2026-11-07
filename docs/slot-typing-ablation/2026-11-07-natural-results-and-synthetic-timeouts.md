# Retained Natural Results and Synthetic Timeout Diagnosis

## Preservation and Run Identity

The user stopped this run during synthetic trials. No experiment was restarted,
no output was deleted, and no result was promoted into published directories.
All natural results, bulk JSONs, pair CSVs, generated models, manifests, logs,
build artifacts, and synthetic negative evidence remain in place.

- Source commit: `3ef7d93bcab87ecd30ffba4c02e01c690981a137`.
- Publication-run ID: `03817f3e-1542-4ce1-98b2-753bd2b320d1`.
- Workstation run root: `/media/augustus/8618-0ED0/ACGN/intermediate/full-corpus-8g-20261107T062202Z`.
- Natural dataset digest: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`.
- Natural settings: 16 workers, 8 GiB JVM heap, reward pool 100.
- Retention inventory: `/media/augustus/8618-0ED0/ACGN/supervision/terra-monitor-20261106/preserved-run-20261107T062202Z.sha256`.

The new inventory covers 7,164 regular files across the entire stopped run;
`sha256sum -c --quiet` passed. Separately, all 5,826 output entries already
recorded in `artifacts/run-manifest.json` passed their original SHA-256 checks.
These checks establish retained-byte integrity, not semantic correctness.
The paths above are workstation-local records, not portable runner defaults.

Supervision state is `USER_STOPPED`; the service has `MainPID=0`, and the
heartbeat automation was deleted. The original run manifest still says
`running`: that is stale producer metadata, not process liveness or full-run
completion. It is preserved unchanged. The complete experiment was not finished.

## Completed Natural-Corpus Results

Sources below are relative to the run root's `artifacts/` directory.

### Canonical Batch

`distance_results/summary.md` records 66,080 files: 61,598 successful eligible
comparisons, 4,482 AST-identical skips, and zero failures. There are zero
incorrect zero-distance merges and zero inexact alpha searches. The certified
path finds 4,088 AST-distinct CORRECT paired-oracle zeroes.

Mean distances are 14.021721 for Certificate-Integrated IR, 13.970096 for Fast
Rewrite IR, and 17.086902 for raw AST distance. These are different metrics,
not runtime values. All 61,598 reward evaluations succeeded; the pool is 100.
The certified-distance/candidate-reward Pearson coefficient on 42,386 incorrect
predicates is -0.063966: this run does not establish a strong linear relation.

### Augmenter

`alloy4fun-augmented/summary.md` records 181 question groups, 19,212 CORRECT
models, and 42,386 incorrect models. All incorrect models received rankings and
rewards. Parsing, reference preparation, ranking, and reward failures are zero.
Both IRs have zero incorrect-to-any-truth zero-distance matches.

Across 4,496 AST-distinct truths, Fast Rewrite IR finds 11,102 unordered zero
pairs and Certificate-Integrated IR finds 11,382 (280 more in aggregate).
These are truth-pool comparisons, not the paired-oracle experiment. Mean nearest
distances are 11.460813 and 11.562709 respectively. Mean candidate reward is
0.352766. Reward-error Pearson correlations are 0.068209 (Fast) and 0.067416
(Certificate-Integrated), again weak linear associations.

### Seven-Arm Ablation

`egraph_ablation/summary.md` records 61,598/61,598 eligible successes in each
arm. Zero-pair counts are 820 for raw and Java egglog, 2,160 for their De Bruijn
variants, 2,228 for slotted, and 4,088 for both Fast Rewrite and
Certificate-Integrated IR. All arms have zero incorrect-labelled zero pairs.
Fast and certified paired-oracle zero sets agree in this run, but that does not
imply that all positive distances or truth-pool comparisons agree.

Fast Rewrite wall time is 23.850 seconds; Certificate-Integrated wall time is
2,706.990 seconds. Their engine CPU totals are 71.196 and 40,805.295 seconds.
The exact certificate path remains substantially more expensive. It must not
be conflated with the lightweight typed-slot treatment below.

### Capability Suite

This is a separate generated benchmark, retained alongside the natural results.
`capability_benchmark/arms/summary.md` records 5,500/5,500 execution successes
for every arm. Slotted, Fast Rewrite, and Certificate-Integrated arms each
detect all 5,500 equalities. Raw/egglog detect 2,585; their De Bruijn variants
detect 3,628. Thus execution success is not equality coverage for every baseline.
The soundness log records 29 bounded checks and zero failures; this is not an
unbounded semantic proof of every corpus result.

### Matched Typed/Untyped Natural Slots

`slot-typing-natural/summary.md` records 61,598 successes and zero failures in
both arms, with the identical set of 2,228 zero pairs. Source-slot census counts
170,112 binding occurrences across both sides of eligible pairs.

- Untyped: wall 20.160 s; engine CPU 18.210 s; adapter CPU 0.262 s;
  comparison CPU 17.910 s; mean distance 16.324.
- Typed: wall 19.560 s; engine CPU 10.391 s; adapter CPU 0.881 s;
  comparison CPU 9.471 s; mean distance 16.421.

Typed engine CPU is approximately 42.9% lower; wall time is approximately 3.0%
lower. Type extraction costs more, while comparison costs less. Nested CPU
components must not be added to engine totals. These are single-run observations,
not replicated estimates. Positive distances differ, and neither slot arm is
certificate-bearing. Natural slot enumeration is bounded; the synthetic arm
explicitly uses the unbounded construction API.

## Synthetic Failure Mode

The retained `slot-typing-synthetic/trials.jsonl` contains 29 TIMEOUT, four
SUCCESS, one ERROR, and 966 NOT_RUN records out of 1,000 planned arm trials.
Every timeout's last logged phase is `representation`, after parsing/adaptation.
The ERROR is typed `stress0112`, exit 143 after 28.776 seconds, with a missing
result file at user cancellation. This is consistent with termination during
the stop operation, not evidence of a semantic counterexample. Preserve the raw
record and annotate it rather than silently counting it as a semantic failure.

The four successes are the two predicates `stress0210` and `stress0210C`, each
in both arms, with eight bindings over two types. Typed wall times are about
0.314 s each; untyped times are 2.233 and 2.608 s. This small paired observation
shows a benefit, not general scalability.

### Mechanism

In `src/is/fivefivefive/CanDis/core/egraph/`:

1. `SlottedEGraph.representUnbounded` calls unbounded slot canonicalization
   before graph insertion and the first rewrite.
2. `SlotCanonicalizer.canonicalizeOnce` renames the whole term, sorts its
   commutative children, and compares representatives for every candidate.
3. `SlotPermutationSearch.collect` partitions admissible exchange blocks by
   exact type before enumeration. The old all-slots-then-filter bug is not the
   mechanism here.
4. `SlotPermutationSearch.visit` exhaustively forms the Cartesian product of
   block permutations. The 40,320-candidate bound does not apply in uncapped mode.

For one admissible independent block of n variables with type counts n_t,
the untyped candidate count is n!, while typed enumeration is the product of
n_t!. Type partitioning reduces the space but does not remove factorial growth.
Eight bindings split 4+4 require 576 typed versus 40,320 untyped candidates;
16 split 8+8 already require 1,625,702,400 typed candidates. The ordinary
128-binding/four-type profile requires (32!)^4, approximately 4.8e141 typed
candidates, versus approximately 3.9e215 untyped candidates. Restrictions such
as alternating scopes and disjoint declarations require their own block counts;
these equations are not claims about every generated family.

This is a code-derived combinatorial bottleneck, not a captured stack profile.
The phase logs alone cannot distinguish initial enumeration from later
canonicalization/rebuilding. The final pre-stop telemetry showed about 2.27 GiB
cgroup memory, 14.39 GiB host available memory, zero cgroup OOM kills, and no new
memory-pressure events. It does not support diagnosing this as another heap
exhaustion incident; allocation/GC overhead is not ruled out without profiling.

### Experimental Design Problems

`scripts/generate_slot_binding_stress.py` uses sizes 8, 16, 32, 64, 96, 128,
160, 192, 224, and 256. Type counts are tied to size rather than independently
varied. Its directed cycle and joint n-way relational intersection keep every
binder coupled, so many grammar families share the same overwhelming alpha
search before family-specific rewriting starts. This is useful extreme stress
evidence, but a poor standalone efficiency curve for the current algorithm.

`scripts/run_slot_typing_synthetic.py` shuffles pairs with a fixed seed instead
of stratifying by search difficulty. The observed prefix is heavy on large
blocks. At one worker and 300 seconds per predicate/arm, the timeout budget alone
can reach 83 hours 20 minutes for 1,000 trials, excluding overhead.

Timeouts are right-censored observations, not equal 300-second completion times.
The partial summary's 0.004 success rate per arm divides two successes by all
500 planned predicates, including 483 not run; it is not a completed-benchmark
success rate. Four successful trials from one related pair cannot provide a
meaningful full-population median/P95 comparison.

## Next Design, Not Launched

Separate a controlled slot-search scaling study from grammar/rewrite coverage.
Vary size and per-type histogram independently, include dense transition sizes
near 8-16 bindings, and retain a small explicitly labelled extreme-stress tail.
Use stratified ordering, per-subphase/candidate telemetry, and predeclared time
budgets. Report not-run and cancelled trials separately from timeout failures;
report paired successful timing alongside censored outcomes, not instead of them.

For genuinely large exact blocks, investigate structural refinement and
symmetry-aware pruning with semantic/canonical-representative correspondence
proofs. Do not restore a cap and describe the result as exhaustive, erase valid
bindings, or relax the equality contract merely to obtain successful timings.
No Java or Lean semantics changed in this inspection, and no experiment or
proof suite was rerun. Monitoring previously established process health, not
scientific yield; a preflight search-space check should have flagged this design
before prolonged timeout sampling.
