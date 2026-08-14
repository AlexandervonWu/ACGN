# Alloy E-Graph Ablation

- Generated at: `2026-08-14T14:26:58.569594651Z`
- Run ID: `75ce4485-9444-403c-991d-2609b7e77f08`
- Git SHA: `67c94e2ddf4bdee34ecf3f9c21c393f438f4e0ef` (dirty: true)
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

The first five arms use the same `canonical-equivalences-v2` rule set; only their term/eclass representation differs. The rules are: operator aliases, NOOP elimination, capture-avoiding let beta reduction, implication elimination, iff elimination, formula ITE elimination, boolean constant negation and double negation, De Morgan, atomic negation duals, temporal negation duals, quantifier negation duals, no-to-all-not quantifier expansion, empty quantifier domains, constant quantifier bodies, safe existential-conjunction prenex, safe universal-disjunction prenex, associativity, commutativity, idempotence, boolean identities and annihilators, boolean complements, membership in none/univ, relational union with none, relational intersection with none.

## Runtime And Memory

Each arm ran in a fresh JVM. Wall time, process CPU, and maximum RSS come from `/usr/bin/time -v`; peak used heap is sampled every 10 ms. Engine CPU uses worker-thread CPU counters around representation construction, saturation, and comparison, excluding parsing. Aggregate task time is summed worker latency and may exceed wall time under parallelism.

| Arm | Successful / eligible | AST-same skipped | Equivalent pairs | Process wall s | Dataset wall s | Pairs/s | Process CPU s | Engine CPU s | Aggregate task s | Avg engine ms | P50 ms | P95 ms | Peak heap MiB | Max RSS MiB | Avg structural KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 5500 / 5500 | 0 | 2585 | 2.420 | 2.299 | 2392.411 | 35.820 | 3.527 | 4.036 | 0.734 | 0.102 | 5.757 | 327.458 | 766.043 | 10.841 |
| raw-egraph-debruijn | 5500 / 5500 | 0 | 3628 | 2.390 | 2.272 | 2420.968 | 38.170 | 3.728 | 4.340 | 0.789 | 0.106 | 6.413 | 360.963 | 819.363 | 10.131 |
| java-egglog | 5500 / 5500 | 0 | 2585 | 2.440 | 2.312 | 2378.812 | 35.370 | 0.942 | 1.262 | 0.230 | 0.085 | 0.551 | 317.590 | 766.625 | 9.677 |
| java-egglog-debruijn | 5500 / 5500 | 0 | 3628 | 2.430 | 2.307 | 2384.403 | 36.250 | 1.117 | 1.421 | 0.258 | 0.093 | 0.644 | 374.295 | 815.383 | 8.972 |
| slotted-egraph | 5500 / 5500 | 0 | 5500 | 2.390 | 2.263 | 2430.485 | 38.170 | 2.022 | 2.689 | 0.489 | 0.220 | 0.915 | 352.388 | 829.074 | 12.610 |
| canonical | 5500 / 5500 | 0 | 5500 | 2.440 | 2.295 | 2396.963 | 46.910 | 4.117 | 6.270 | 1.140 | 0.484 | 2.506 | 1000.906 | 1523.039 | 2.851 |

## Observations

- De Bruijn storage adds 1043 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1043 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 1872 pairs over the De Bruijn egglog arm, with 0 losses.
- The current canonical method has the same zero set as the slotted arm on this corpus: it adds 0 zeroes and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 49.121% of engine CPU time and 54.436% of maximum RSS. End-to-end wall time is parser-dominated.

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

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 2585 | 47.000% | 1068.182 | 72.166 | 732.844 | 3455.472 |
| raw-egraph-debruijn | 3628 | 65.964% | 1517.992 | 95.048 | 973.127 | 4534.096 |
| java-egglog | 2585 | 47.000% | 1059.426 | 73.085 | 2745.237 | 3452.849 |
| java-egglog-debruijn | 3628 | 65.964% | 1493.004 | 100.083 | 3249.418 | 4556.230 |
| slotted-egraph | 5500 | 100.000% | 2301.255 | 144.092 | 2719.434 | 6793.119 |
| canonical | 5500 | 100.000% | 2254.098 | 117.246 | 1335.820 | 3697.870 |

## Minimum Edit Distance

For the five e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. The canonical arm uses the production canonical edit distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 5500 | 2.115 | 2.115 | 0.000 | 3 | 4 |
| raw-egraph-debruijn | 5500 | 0.681 | 0.681 | 0.000 | 0 | 2 |
| java-egglog | 5500 | 2.115 | 2.115 | 0.000 | 3 | 4 |
| java-egglog-debruijn | 5500 | 0.681 | 0.681 | 0.000 | 0 | 2 |
| slotted-egraph | 5500 | 0.000 | 0.000 | 0.000 | 0 | 0 |
| canonical | 5500 | 0.000 | 0.000 | 0.000 | 0 | 0 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the current full canonical arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.857 | 0.503 | 1.492 |
| raw-egraph-debruijn | 0.905 | 0.538 | 1.401 |
| java-egglog | 0.229 | 0.503 | 1.328 |
| java-egglog-debruijn | 0.271 | 0.535 | 1.237 |
| slotted-egraph | 0.491 | 0.544 | 1.067 |
| canonical | 1.000 | 1.000 | 1.000 |

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

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 68.071 | 64.165 | 68.071 | 11101.373 | 31088 |
| raw-egraph-debruijn | 63.899 | 60.084 | 63.899 | 10373.684 | 30526 |
| java-egglog | 60.581 | 57.202 | 60.581 | 9908.905 | 23040 |
| java-egglog-debruijn | 56.452 | 53.164 | 56.452 | 9187.121 | 22478 |
| slotted-egraph | 48.659 | 45.920 | 48.659 | 12912.484 | 32990 |
| canonical | 45.620 | 43.648 | 45.161 | 2919.703 | 7424 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Canonical representation units are the existing canonical-form size, while the five baseline units are retained e-nodes. E-class and e-node columns are reachable saturated-graph counts for every arm; canonical e-nodes include retained alternatives across all temporal matrices.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input capability_benchmark/models --output capability_benchmark/arms --threads 32 --max-heap 3g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
