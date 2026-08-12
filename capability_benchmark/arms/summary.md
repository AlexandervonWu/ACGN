# Alloy E-Graph Ablation

- Generated at: `2026-08-11T23:58:22.873343394Z`
- Run ID: `ae363ef2-b0f2-40e9-b86c-348488d2630f`
- Git SHA: `9953c5d2161d23d557d2a00cb02ef1b4bef95809` (dirty: true)
- Dataset SHA-256: `e9901ba9e63a8090e0beb9d04d19bd66da3a7f49ca681ef6adf164e8ca6265f0`
- Input root: `capability_benchmark/models`
- Predicate-pair limit: full corpus
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
6. **Canonical:** the current method, adding temporal-phase partitioning, connective elimination, strict per-phase prenexing, primitive binding tuples, and canonical variadic matrices.

## Shared Rule Program

The first five arms use the same `canonical-equivalences-v1` rule set; only their term/eclass representation differs. The rules are: operator aliases, NOOP elimination, capture-avoiding let beta reduction, implication elimination, iff elimination, formula ITE elimination, boolean constant negation and double negation, De Morgan, atomic negation duals, temporal negation duals, quantifier negation duals, no-to-all-not quantifier expansion, empty quantifier domains, safe existential-conjunction prenex, safe universal-disjunction prenex, associativity, commutativity, idempotence, boolean identities and annihilators, boolean complements, membership in none/univ, relational union with none, relational intersection with none.

## Runtime And Memory

Each arm ran in a fresh JVM. Wall time, process CPU, and maximum RSS come from `/usr/bin/time -v`; peak used heap is sampled every 10 ms. Engine CPU uses worker-thread CPU counters around representation construction, saturation, and comparison, excluding parsing. Aggregate task time is summed worker latency and may exceed wall time under parallelism.

| Arm | Successful / eligible | AST-same skipped | Equivalent pairs | Process wall s | Dataset wall s | Pairs/s | Process CPU s | Engine CPU s | Aggregate task s | Avg engine ms | P50 ms | P95 ms | Peak heap MiB | Max RSS MiB | Avg structural KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 5500 / 5500 | 0 | 2479 | 2.430 | 2.315 | 2375.733 | 36.780 | 4.138 | 4.623 | 0.841 | 0.098 | 6.766 | 315.938 | 745.508 | 11.412 |
| raw-egraph-debruijn | 5500 / 5500 | 0 | 3505 | 2.380 | 2.264 | 2429.563 | 39.730 | 3.865 | 4.534 | 0.824 | 0.097 | 6.565 | 371.795 | 798.824 | 10.686 |
| java-egglog | 5500 / 5500 | 0 | 2500 | 2.370 | 2.257 | 2437.386 | 34.980 | 1.061 | 1.398 | 0.254 | 0.087 | 0.668 | 351.388 | 775.195 | 10.044 |
| java-egglog-debruijn | 5500 / 5500 | 0 | 3500 | 2.280 | 2.163 | 2542.833 | 35.440 | 1.223 | 1.572 | 0.286 | 0.096 | 0.703 | 349.627 | 807.918 | 9.326 |
| slotted-egraph | 5500 / 5500 | 0 | 5500 | 2.450 | 2.331 | 2359.045 | 38.520 | 2.057 | 2.764 | 0.503 | 0.207 | 0.900 | 365.345 | 816.773 | 13.150 |
| canonical | 5500 / 5500 | 0 | 5500 | 2.630 | 2.489 | 2209.677 | 45.600 | 3.846 | 5.300 | 0.964 | 0.355 | 3.382 | 846.264 | 1389.438 | 2.851 |

## Observations

- De Bruijn storage adds 1026 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 21 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1000 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 21 pairs over the fixed-arity arm, with 26 losses.
- Slot-aware shapes add 2000 pairs over the De Bruijn egglog arm, with 0 losses.
- The current canonical method has the same zero set as the slotted arm on this corpus: it adds 0 zeroes and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 53.478% of engine CPU time and 58.784% of maximum RSS. End-to-end wall time is parser-dominated.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 2479 / 5500 | 45.073% | 0 / 0 | 0.000% |
| raw-egraph-debruijn | 3505 / 5500 | 63.727% | 0 / 0 | 0.000% |
| java-egglog | 2500 / 5500 | 45.455% | 0 / 0 | 0.000% |
| java-egglog-debruijn | 3500 / 5500 | 63.636% | 0 / 0 | 0.000% |
| slotted-egraph | 5500 / 5500 | 100.000% | 0 / 0 | 0.000% |
| canonical | 5500 / 5500 | 100.000% | 0 / 0 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 2479 | 45.073% | 1020.165 | 67.401 | 599.077 | 3405.056 |
| raw-egraph-debruijn | 3505 | 63.727% | 1472.689 | 88.220 | 906.785 | 4493.003 |
| java-egglog | 2500 | 45.455% | 1054.852 | 71.469 | 2356.424 | 3302.394 |
| java-egglog-debruijn | 3500 | 63.636% | 1535.088 | 98.758 | 2861.812 | 4436.094 |
| slotted-egraph | 5500 | 100.000% | 2244.898 | 142.783 | 2674.390 | 6895.425 |
| canonical | 5500 | 100.000% | 2091.255 | 120.614 | 1430.220 | 4053.439 |

## Minimum Edit Distance

For the five e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. The canonical arm uses the production canonical edit distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 5500 | 2.315 | 2.315 | 0.000 | 3 | 7 |
| raw-egraph-debruijn | 5500 | 0.815 | 0.815 | 0.000 | 0 | 2 |
| java-egglog | 5500 | 2.227 | 2.227 | 0.000 | 3 | 4 |
| java-egglog-debruijn | 5500 | 0.727 | 0.727 | 0.000 | 0 | 2 |
| slotted-egraph | 5500 | 0.000 | 0.000 | 0.000 | 0 | 0 |
| canonical | 5500 | 0.000 | 0.000 | 0.000 | 0 | 0 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the current full canonical arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 1.076 | 0.537 | 1.571 |
| raw-egraph-debruijn | 1.005 | 0.575 | 1.478 |
| java-egglog | 0.276 | 0.558 | 1.378 |
| java-egglog-debruijn | 0.318 | 0.581 | 1.286 |
| slotted-egraph | 0.535 | 0.588 | 1.110 |
| canonical | 1.000 | 1.000 | 1.000 |

## Pair-Level Transitions

These edges isolate variable encoding, variadic representation, slots, and the full method.

| Transition | Retained zeroes | Newly zero | No longer zero |
| --- | ---: | ---: | ---: |
| raw-egraph -> raw-egraph-debruijn | 2479 | 1026 | 0 |
| raw-egraph -> java-egglog | 2479 | 21 | 0 |
| raw-egraph-debruijn -> java-egglog-debruijn | 3479 | 21 | 26 |
| java-egglog -> java-egglog-debruijn | 2500 | 1000 | 0 |
| java-egglog-debruijn -> slotted-egraph | 3500 | 2000 | 0 |
| slotted-egraph -> canonical | 5500 | 0 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 71.685 | 67.541 | 71.685 | 11686.107 | 31088 |
| raw-egraph-debruijn | 67.425 | 63.371 | 67.425 | 10942.632 | 30526 |
| java-egglog | 62.879 | 59.351 | 62.879 | 10284.556 | 23040 |
| java-egglog-debruijn | 58.682 | 55.245 | 58.682 | 9549.867 | 22478 |
| slotted-egraph | 50.642 | 47.771 | 50.642 | 13466.038 | 32990 |
| canonical | 45.620 | 43.648 | 45.161 | 2919.703 | 7424 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Canonical representation units are the existing canonical-form size, while the five baseline units are retained e-nodes. E-class and e-node columns are reachable saturated-graph counts for every arm; canonical e-nodes include retained alternatives across all temporal matrices.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input capability_benchmark/models --output capability_benchmark/arms --threads 32 --max-heap 3g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
