# Alloy E-Graph Ablation

- Generated at: `2026-08-17T23:26:01.507238382Z`
- Run ID: `cfe55f5d-daf6-4ae1-808e-3eaa863015a8`
- Git SHA: `cc53042333fa3a1c820eb5715aa3b124e03d0ff1` (dirty: true)
- Dataset SHA-256: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Input root: `/home/augustus/ACGN/classified-data`
- Predicate-pair limit: full corpus
- Deterministic seed: `55520260811`
- Worker threads per arm: 32
- Logical processors: 32
- Thread policy: `min(requested, logical processors, 32)`
- JVM heap cap per arm: `3g`
- Java: `17.0.19`

## Arms

1. **Conventional e-graph:** fixed-arity Alloy constructors, the shared rule program, union-find, hash-consing, and congruence rebuilding.
2. **Conventional e-graph + De Bruijn:** the same fixed-arity engine, with bound variables stored as nameless nearest-binder indices.
3. **Java egglog core:** variadic Alloy constructors plus union facts, semi-naive rule rounds, and congruence rebuilding. This is a Java replica of the egglog execution core used here, not a textual-language-compatible port of every egglog feature.
4. **Java egglog + De Bruijn:** the same variadic engine and rules, with nameless bound-variable storage.
5. **Slotted e-graph:** the same raw terms and rules represented as shape-hash-consed renamed eclass invocations with exposed slots, slot redundancy, and finite permutation groups.
6. **Legacy canonical:** the retained temporal/prenex/slotted implementation, with bounded rewrite saturation and the reference repair metric.
7. **Typed slotted-port exact pipeline:** the complete `CanonicalAlloyPipeline`, using certified insertion, exact-support typed slots, strict invariant checks, congruence rebuild, and finite-unfolding observation.

## Shared Rule Program

The first five arms use the same `canonical-equivalences-v2` rule set; only their term/eclass representation differs. The rules are: operator aliases, NOOP elimination, capture-avoiding let beta reduction, implication elimination, iff elimination, formula ITE elimination, boolean constant negation and double negation, De Morgan, atomic negation duals, temporal negation duals, quantifier negation duals, no-to-all-not quantifier expansion, empty quantifier domains, constant quantifier bodies, safe existential-conjunction prenex, safe universal-disjunction prenex, associativity, commutativity, idempotence, boolean identities and annihilators, boolean complements, membership in none/univ, relational union with none, relational intersection with none.

## Runtime And Memory

Each arm ran in a fresh JVM. Wall time, process CPU, and maximum RSS come from `/usr/bin/time -v`; peak used heap is sampled every 10 ms. Engine CPU uses worker-thread CPU counters around representation construction, saturation, and comparison, excluding parsing. Aggregate task time is summed worker latency and may exceed wall time under parallelism.

| Arm | Successful / eligible | AST-same skipped | Equivalent pairs | Process wall s | Dataset wall s | Pairs/s | Process CPU s | Engine CPU s | Aggregate task s | Avg engine ms | P50 ms | P95 ms | Peak heap MiB | Max RSS MiB | Avg structural KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 / 61598 | 4482 | 823 | 18.260 | 17.827 | 3455.354 | 188.420 | 4.517 | 5.017 | 0.081 | 0.050 | 0.172 | 448.983 | 933.320 | 9.353 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2163 | 16.580 | 16.160 | 3811.698 | 183.210 | 5.289 | 5.846 | 0.095 | 0.055 | 0.207 | 405.418 | 864.070 | 9.303 |
| java-egglog | 61598 / 61598 | 4482 | 823 | 16.400 | 15.974 | 3856.057 | 180.340 | 4.094 | 4.623 | 0.075 | 0.046 | 0.140 | 413.062 | 874.352 | 9.125 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2163 | 16.630 | 16.208 | 3800.371 | 185.490 | 4.997 | 5.644 | 0.092 | 0.055 | 0.183 | 435.580 | 915.074 | 9.074 |
| slotted-egraph | 61598 / 61598 | 4482 | 2162 | 17.390 | 16.947 | 3634.738 | 202.220 | 14.642 | 16.324 | 0.265 | 0.118 | 0.970 | 450.074 | 936.621 | 14.017 |
| canonical | 61598 / 61598 | 4482 | 2316 | 18.470 | 17.844 | 3452.098 | 246.510 | 13.255 | 15.842 | 0.257 | 0.168 | 0.491 | 2853.299 | 3529.023 | 1.865 |
| typed-slotted-port-egraph | 61598 / 61598 | 4482 | 2317 | 2303.890 | 2303.327 | 26.743 | 62827.700 | 47451.149 | 73225.507 | 1188.764 | 555.391 | 4394.306 | 3063.953 | 3603.680 | 3.743 |

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 2 pairs over the De Bruijn egglog arm, with 3 losses.
- The legacy canonical arm adds 154 zeroes over slotted storage and loses 0.
- The exact `CanonicalAlloyPipeline` adds 1 zeroes over the legacy canonical arm and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.031% of engine CPU time and 25.991% of maximum RSS. End-to-end wall time is parser-dominated.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 823 / 19212 | 4.284% | 0 / 42386 | 0.000% |
| raw-egraph-debruijn | 2163 / 19212 | 11.259% | 0 / 42386 | 0.000% |
| java-egglog | 823 / 19212 | 4.284% | 0 / 42386 | 0.000% |
| java-egglog-debruijn | 2163 / 19212 | 11.259% | 0 / 42386 | 0.000% |
| slotted-egraph | 2162 / 19212 | 11.253% | 0 / 42386 | 0.000% |
| canonical | 2316 / 19212 | 12.055% | 0 / 42386 | 0.000% |
| typed-slotted-port-egraph | 2317 / 19212 | 12.060% | 0 / 42386 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 823 | 4.284% | 45.071 | 4.368 | 182.182 | 902.961 |
| raw-egraph-debruijn | 2163 | 11.259% | 130.458 | 11.806 | 408.970 | 2563.347 |
| java-egglog | 823 | 4.284% | 50.183 | 4.564 | 201.003 | 963.859 |
| java-egglog-debruijn | 2163 | 11.259% | 130.066 | 11.661 | 432.854 | 2420.473 |
| slotted-egraph | 2162 | 11.253% | 124.324 | 10.691 | 147.655 | 2363.696 |
| canonical | 2316 | 12.055% | 125.393 | 9.395 | 174.729 | 672.023 |
| typed-slotted-port-egraph | 2317 | 12.060% | 1.006 | 0.037 | 0.049 | 658.385 |

## Minimum Edit Distance

For the five legacy e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The exact arm obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 18.390 | 14.173 | 20.302 | 16 | 42 |
| raw-egraph-debruijn | 61598 | 17.923 | 13.771 | 19.805 | 15 | 42 |
| java-egglog | 61598 | 17.996 | 13.975 | 19.819 | 15 | 41 |
| java-egglog-debruijn | 61598 | 17.530 | 13.576 | 19.322 | 15 | 40 |
| slotted-egraph | 61598 | 17.694 | 13.709 | 19.500 | 15 | 40 |
| canonical | 61598 | 14.029 | 9.361 | 16.145 | 12 | 34 |
| typed-slotted-port-egraph | 61598 | 14.042 | 9.363 | 16.163 | 12 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the exact typed slotted-port arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.000 | 0.259 | 1.950 |
| raw-egraph-debruijn | 0.000 | 0.240 | 1.940 |
| java-egglog | 0.000 | 0.243 | 1.902 |
| java-egglog-debruijn | 0.000 | 0.254 | 1.891 |
| slotted-egraph | 0.000 | 0.260 | 1.775 |
| canonical | 0.000 | 0.979 | 1.000 |
| typed-slotted-port-egraph | 1.000 | 1.000 | 1.000 |

## Pair-Level Transitions

These edges isolate variable encoding, variadic representation, slots, and the full method.

| Transition | Retained zeroes | Newly zero | No longer zero |
| --- | ---: | ---: | ---: |
| raw-egraph -> raw-egraph-debruijn | 823 | 1340 | 0 |
| raw-egraph -> java-egglog | 823 | 0 | 0 |
| raw-egraph-debruijn -> java-egglog-debruijn | 2163 | 0 | 0 |
| java-egglog -> java-egglog-debruijn | 823 | 1340 | 0 |
| java-egglog-debruijn -> slotted-egraph | 2160 | 2 | 3 |
| slotted-egraph -> canonical | 2162 | 154 | 0 |
| canonical -> typed-slotted-port-egraph | 2316 | 1 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 58.184 | 55.445 | 58.184 | 9577.116 | 49152 |
| raw-egraph-debruijn | 57.865 | 55.145 | 57.865 | 9526.746 | 50728 |
| java-egglog | 56.740 | 54.051 | 56.740 | 9344.246 | 39830 |
| java-egglog-debruijn | 56.410 | 53.740 | 56.410 | 9291.928 | 40902 |
| slotted-egraph | 52.952 | 50.294 | 52.952 | 14353.400 | 60310 |
| canonical | 29.843 | 25.022 | 25.173 | 1909.958 | 10112 |
| typed-slotted-port-egraph | 29.830 | 20.935 | 18.059 | 3832.735 | 16336 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Legacy canonical units retain the historical canonical-form size; exact units count its normalized finite-unfolding key. E-class and e-node columns for the exact arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input /home/augustus/ACGN/classified-data --output /home/augustus/ACGN/egraph_ablation --threads 32 --max-heap 3g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
