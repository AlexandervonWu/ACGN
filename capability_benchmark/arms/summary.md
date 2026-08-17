# Alloy E-Graph Ablation

- Generated at: `2026-08-17T23:33:13.329783591Z`
- Run ID: `dfd614b7-661d-4be6-8b46-6459e00809ad`
- Git SHA: `cc53042333fa3a1c820eb5715aa3b124e03d0ff1` (dirty: true)
- Dataset SHA-256: `e9901ba9e63a8090e0beb9d04d19bd66da3a7f49ca681ef6adf164e8ca6265f0`
- Input root: `/home/augustus/ACGN/capability_benchmark/models`
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
| raw-egraph | 5500 / 5500 | 0 | 2585 | 2.300 | 2.167 | 2538.607 | 35.020 | 2.356 | 2.901 | 0.527 | 0.098 | 3.767 | 338.719 | 769.367 | 10.841 |
| raw-egraph-debruijn | 5500 / 5500 | 0 | 3628 | 2.510 | 2.390 | 2301.072 | 35.190 | 1.452 | 1.926 | 0.350 | 0.108 | 1.137 | 341.758 | 770.102 | 10.131 |
| java-egglog | 5500 / 5500 | 0 | 2585 | 2.530 | 2.409 | 2282.852 | 40.240 | 0.882 | 1.313 | 0.239 | 0.089 | 0.470 | 327.403 | 747.598 | 9.677 |
| java-egglog-debruijn | 5500 / 5500 | 0 | 3628 | 2.290 | 2.149 | 2559.169 | 36.880 | 1.297 | 1.647 | 0.299 | 0.105 | 0.906 | 393.542 | 894.883 | 8.972 |
| slotted-egraph | 5500 / 5500 | 0 | 5500 | 2.290 | 2.164 | 2541.620 | 38.730 | 1.981 | 2.616 | 0.476 | 0.219 | 0.926 | 392.787 | 842.246 | 12.610 |
| canonical | 5500 / 5500 | 0 | 5500 | 2.600 | 2.443 | 2250.916 | 45.110 | 3.540 | 4.936 | 0.897 | 0.391 | 1.824 | 893.174 | 1351.707 | 2.739 |
| typed-slotted-port-egraph | 5500 / 5500 | 0 | 5500 | 338.610 | 338.365 | 16.255 | 9405.460 | 8559.030 | 10759.412 | 1956.257 | 1643.692 | 4679.413 | 2694.938 | 3591.383 | 5.864 |

## Observations

- De Bruijn storage adds 1043 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1043 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 1872 pairs over the De Bruijn egglog arm, with 0 losses.
- The legacy canonical arm adds 0 zeroes over slotted storage and loses 0.
- The exact `CanonicalAlloyPipeline` adds 0 zeroes over the legacy canonical arm and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.023% of engine CPU time and 23.452% of maximum RSS. End-to-end wall time is parser-dominated.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 2585 / 5500 | 47.000% | 0 / 0 | 0.000% |
| raw-egraph-debruijn | 3628 / 5500 | 65.964% | 0 / 0 | 0.000% |
| java-egglog | 2585 / 5500 | 47.000% | 0 / 0 | 0.000% |
| java-egglog-debruijn | 3628 / 5500 | 65.964% | 0 / 0 | 0.000% |
| slotted-egraph | 5500 / 5500 | 100.000% | 0 / 0 | 0.000% |
| canonical | 5500 / 5500 | 100.000% | 0 / 0 | 0.000% |
| typed-slotted-port-egraph | 5500 / 5500 | 100.000% | 0 / 0 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 2585 | 47.000% | 1123.913 | 73.815 | 1097.030 | 3440.542 |
| raw-egraph-debruijn | 3628 | 65.964% | 1445.418 | 103.097 | 2498.824 | 4824.133 |
| java-egglog | 2585 | 47.000% | 1021.739 | 64.240 | 2931.713 | 3540.728 |
| java-egglog-debruijn | 3628 | 65.964% | 1584.279 | 98.373 | 2798.042 | 4151.462 |
| slotted-egraph | 5500 | 100.000% | 2401.747 | 142.009 | 2775.752 | 6686.882 |
| canonical | 5500 | 100.000% | 2115.385 | 121.924 | 1553.642 | 4166.583 |
| typed-slotted-port-egraph | 5500 | 100.000% | 16.243 | 0.585 | 0.643 | 1568.198 |

## Minimum Edit Distance

For the five legacy e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The exact arm obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 5500 | 2.115 | 2.115 | 0.000 | 3 | 4 |
| raw-egraph-debruijn | 5500 | 0.681 | 0.681 | 0.000 | 0 | 2 |
| java-egglog | 5500 | 2.115 | 2.115 | 0.000 | 3 | 4 |
| java-egglog-debruijn | 5500 | 0.681 | 0.681 | 0.000 | 0 | 2 |
| slotted-egraph | 5500 | 0.000 | 0.000 | 0.000 | 0 | 0 |
| canonical | 5500 | 0.000 | 0.000 | 0.000 | 0 | 0 |
| typed-slotted-port-egraph | 5500 | 0.000 | 0.000 | 0.000 | 0 | 0 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the exact typed slotted-port arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.000 | 0.214 | 1.553 |
| raw-egraph-debruijn | 0.000 | 0.214 | 1.458 |
| java-egglog | 0.000 | 0.208 | 1.382 |
| java-egglog-debruijn | 0.000 | 0.249 | 1.288 |
| slotted-egraph | 0.000 | 0.235 | 1.110 |
| canonical | 0.000 | 0.376 | 1.000 |
| typed-slotted-port-egraph | 1.000 | 1.000 | 1.000 |

## Pair-Level Transitions

These edges isolate variable encoding, variadic representation, slots, and the full method.

| Transition | Retained zeroes | Newly zero | No longer zero |
| --- | ---: | ---: | ---: |
| raw-egraph -> raw-egraph-debruijn | 2585 | 1043 | 0 |
| raw-egraph -> java-egglog | 2585 | 0 | 0 |
| raw-egraph-debruijn -> java-egglog-debruijn | 3628 | 0 | 0 |
| java-egglog -> java-egglog-debruijn | 2585 | 1043 | 0 |
| java-egglog-debruijn -> slotted-egraph | 3628 | 1872 | 0 |
| slotted-egraph -> canonical | 5500 | 0 | 0 |
| canonical -> typed-slotted-port-egraph | 5500 | 0 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 68.071 | 64.165 | 68.071 | 11101.373 | 31088 |
| raw-egraph-debruijn | 63.899 | 60.084 | 63.899 | 10373.684 | 30526 |
| java-egglog | 60.581 | 57.202 | 60.581 | 9908.905 | 23040 |
| java-egglog-debruijn | 56.452 | 53.164 | 56.452 | 9187.121 | 22478 |
| slotted-egraph | 48.659 | 45.920 | 48.659 | 12912.484 | 32990 |
| canonical | 43.822 | 43.648 | 45.282 | 2804.596 | 7424 |
| typed-slotted-port-egraph | 43.820 | 38.068 | 29.201 | 6005.120 | 13440 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Legacy canonical units retain the historical canonical-form size; exact units count its normalized finite-unfolding key. E-class and e-node columns for the exact arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input /home/augustus/ACGN/capability_benchmark/models --output /home/augustus/ACGN/capability_benchmark/arms --threads 32 --max-heap 3g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
