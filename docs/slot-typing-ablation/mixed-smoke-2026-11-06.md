# Mixed Natural and Synthetic Smoke: 2026-11-06

## Scope and Provenance

Completed in 30.27 seconds including compilation, Lean checks, Java regression
gates, and timed trials. This is preliminary smoke data, not a full-corpus result
or a statistical speedup claim. Production Java/Lean semantics were not changed
for this run.

Base commit: `2e32a2313172741b002a8388b2f57f85dd529800`, with uncommitted repairs.
The external `manifest.json` identifies the actual source, library, proof, and
compiled-class hashes; HEAD alone does not identify this experiment.

On this workstation, evidence is stored at:
`/media/augustus/8618-0ED0/ACGN/intermediate/mixed-smoke-20261106/`.
The directory includes `summary.json`, `summary.md`, `preliminary.csv`,
`observations.jsonl`, frozen inputs/source/libraries, the supervisor, and logs.
Its `SHA256SUMS` check passed. Machine-local storage choices do not change the
default output directories on other machines.

One JVM at a time, 1 GiB Java heap, one logical processor per trial, and a
15-second process deadline. The supervisor ran inside a 3 GiB memory-limited
systemd scope with swap disabled and a two-core CPU quota; host free-memory and
external-space guards were also active. No full experiment service was started.

## Coverage and Gates

Natural selection: nine pairs, including the prior social-media regression and
seeded hash-minimum selections from CORRECT/BOTH strata of `classroom_fol`,
`socialMedia`, `trash_ltl`, and `trainStationNew`. Two were AST-identical and
skipped by both arms. The seven eligible pairs each completed in both arms.

Synthetic selection: eight pairs, all with eight outer bindings, covering
homogeneous/heterogeneous alpha renaming, same-type permutation, Boolean ACI,
past unary and future binary temporals, negative cross-type, and negative
temporal-endpoint cases. Each pair was compared in both arms; each of its two
predicates was additionally constructed independently in both arms.

- `Model.lean`, `TypedPass.lean`, and `TimedOutcome.lean`: passed.
- `SlotTypingAblationTest`: 40 checks passed.
- `SlotRewriteOrderTest`: 66 checks passed, including reduced Alloy solver controls.
- `EGraphAblationTest`: passed.
- `SlotTypingSyntheticTest`: 18 checks passed.

The six typed-pass lemmas and eight model lemmas report no axioms. Three
deadline lemmas also report no axioms; `success_count_bounded` uses Lean's
standard `propext` and `Quot.sound`. These results establish the stated Lean
schemas, not a whole-program Java refinement theorem.

## Preliminary Measurements

Engine time includes AST-to-term adaptation. P95 is nearest-rank and uses only
successful trials. All comparisons retain production search caps. Independent
synthetic construction removes the synthetic search caps but retains the
shorter, explicitly smoke-only deadline.

| Measurement | Untyped successes | Typed successes | Untyped median / P95 engine ms | Typed median / P95 engine ms |
| --- | ---: | ---: | ---: | ---: |
| Natural pair comparison | 7/7 eligible | 7/7 eligible | 7.846 / 9.567 | 9.420 / 11.024 |
| Synthetic pair comparison | 8/8 | 8/8 | 13.919 / 223.497 | 18.156 / 222.350 |
| Uncapped synthetic construction | 16/16 | 16/16 | 13.391 / 178.477 | 17.028 / 171.720 |

There were zero exceptions, timeouts, OOMs, or observed synthetic
expected-relation mismatches. Typed/untyped distances agree on all 15 eligible
pairs. The two synthetic negative cases retain positive distances: cross-type
is 2, temporal-endpoint is 1. The six synthetic positive cases have distance 0.
Construction completion by itself is not a semantic-equivalence certificate.

All successful bounded comparisons took one or two rewrite iterations. In
particular, `socialMedia/under/x9CXb8pLEAhJgTSFk_inv5.als` took one iteration in
each arm, with distance 14. The earlier conflicting operand-order cycle did not
reappear on this witness.

## CPU Breakdown and Remaining Limits

| Corpus | Arm | Median adapter CPU ms | Median comparison CPU ms |
| --- | --- | ---: | ---: |
| Natural | Untyped | 1.437 | 6.255 |
| Natural | Typed | 2.880 | 6.320 |
| Synthetic | Untyped | 0.894 | 12.581 |
| Synthetic | Typed | 4.772 | 12.309 |

These observations are consistent with extra exact-type extraction cost, not
the former repeated-ordering cycle. They do not demonstrate a typed speedup:
the natural cases have at most two source bindings per predicate, the synthetic
cases have eight, and there is only one cold trial per input/arm. Independent
component medians must not be added as if they were a single paired measurement.
P95 is the sample maximum at these small sample sizes.

Process wall observations include polling/wait overhead: comparisons poll every
100 ms, and construction uses the existing Python supervisor's timed waits.
Use Java engine timers for subsecond comparisons, not the coarsely observed
process wall figures.

Two nonidentical natural CORRECT pairs still have distance 13 in both arms:
`classroom_fol/correct/z639op94MrSLAaMMb_inv3.als` and
`trash_ltl/correct/um8Bk6dQ9dcQPMnPc_inv9.als`. Thus equivalence recognition is
incomplete on this sample. These are the experimental slotted arms, not the
Certificate-Integrated engine; no certificate or reward claim is made here.
The natural incorrect selections all retain positive distance, but this smoke
does not independently solver-check every sampled natural pair. Large binding
blocks, full-corpus resource behavior, and repeated latency estimates remain
outside this completed check.
