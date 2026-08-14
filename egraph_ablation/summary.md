# Alloy E-Graph Ablation

- Generated at: `2026-08-14T14:29:13.187934200Z`
- Run ID: `b6878ce2-b791-4a64-ad2f-1c2e3ff93893`
- Git SHA: `67c94e2ddf4bdee34ecf3f9c21c393f438f4e0ef` (dirty: true)
- Dataset SHA-256: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Input root: `classified-data`
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
| raw-egraph | 61598 / 61598 | 4482 | 823 | 18.860 | 18.429 | 3342.462 | 190.420 | 4.574 | 5.259 | 0.085 | 0.051 | 0.177 | 447.862 | 940.730 | 9.353 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2163 | 16.820 | 16.404 | 3755.120 | 187.080 | 5.666 | 6.379 | 0.104 | 0.058 | 0.223 | 441.905 | 937.262 | 9.303 |
| java-egglog | 61598 / 61598 | 4482 | 823 | 17.300 | 16.886 | 3647.846 | 186.130 | 4.263 | 4.810 | 0.078 | 0.049 | 0.154 | 450.909 | 930.586 | 9.125 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2163 | 19.030 | 18.608 | 3310.363 | 194.710 | 5.200 | 5.908 | 0.096 | 0.058 | 0.191 | 437.953 | 943.770 | 9.074 |
| slotted-egraph | 61598 / 61598 | 4482 | 2162 | 18.150 | 17.738 | 3472.727 | 208.170 | 15.723 | 17.125 | 0.278 | 0.121 | 1.009 | 512.678 | 1077.098 | 14.017 |
| canonical | 61598 / 61598 | 4482 | 2235 | 18.490 | 18.009 | 3420.308 | 246.260 | 12.889 | 16.371 | 0.266 | 0.163 | 0.464 | 2855.390 | 3592.613 | 1.794 |

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 2 pairs over the De Bruijn egglog arm, with 3 losses.
- The current canonical method is a strict superset of the slotted arm on this corpus: it adds 73 zeroes and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 121.988% of engine CPU time and 29.981% of maximum RSS. End-to-end wall time is parser-dominated.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 823 / 19212 | 4.284% | 0 / 42386 | 0.000% |
| raw-egraph-debruijn | 2163 / 19212 | 11.259% | 0 / 42386 | 0.000% |
| java-egglog | 823 / 19212 | 4.284% | 0 / 42386 | 0.000% |
| java-egglog-debruijn | 2163 / 19212 | 11.259% | 0 / 42386 | 0.000% |
| slotted-egraph | 2162 / 19212 | 11.253% | 0 / 42386 | 0.000% |
| canonical | 2235 / 19212 | 11.633% | 0 / 42386 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 823 | 4.284% | 43.637 | 4.322 | 179.943 | 895.849 |
| raw-egraph-debruijn | 2163 | 11.259% | 128.597 | 11.562 | 381.733 | 2363.173 |
| java-egglog | 823 | 4.284% | 47.572 | 4.422 | 193.040 | 905.614 |
| java-egglog-debruijn | 2163 | 11.259% | 113.663 | 11.109 | 415.956 | 2346.878 |
| slotted-egraph | 2162 | 11.253% | 119.118 | 10.386 | 137.506 | 2055.420 |
| canonical | 2235 | 11.633% | 120.876 | 9.076 | 173.405 | 637.040 |

## Minimum Edit Distance

For the five e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. The canonical arm uses the production canonical edit distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 18.390 | 14.173 | 20.302 | 16 | 42 |
| raw-egraph-debruijn | 61598 | 17.923 | 13.771 | 19.805 | 15 | 42 |
| java-egglog | 61598 | 17.996 | 13.975 | 19.819 | 15 | 41 |
| java-egglog-debruijn | 61598 | 17.530 | 13.576 | 19.322 | 15 | 40 |
| slotted-egraph | 61598 | 17.694 | 13.709 | 19.500 | 15 | 40 |
| canonical | 61598 | 13.540 | 9.322 | 15.452 | 11 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the current full canonical arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.355 | 0.262 | 2.027 |
| raw-egraph-debruijn | 0.440 | 0.261 | 2.016 |
| java-egglog | 0.331 | 0.259 | 1.977 |
| java-egglog-debruijn | 0.403 | 0.263 | 1.965 |
| slotted-egraph | 1.220 | 0.300 | 1.845 |
| canonical | 1.000 | 1.000 | 1.000 |

## Pair-Level Transitions

These edges isolate variable encoding, variadic representation, slots, and the full method.

| Transition | Retained zeroes | Newly zero | No longer zero |
| --- | ---: | ---: | ---: |
| raw-egraph -> raw-egraph-debruijn | 823 | 1340 | 0 |
| raw-egraph -> java-egglog | 823 | 0 | 0 |
| raw-egraph-debruijn -> java-egglog-debruijn | 2163 | 0 | 0 |
| java-egglog -> java-egglog-debruijn | 823 | 1340 | 0 |
| java-egglog-debruijn -> slotted-egraph | 2160 | 2 | 3 |
| slotted-egraph -> canonical | 2162 | 73 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 58.184 | 55.445 | 58.184 | 9577.116 | 49152 |
| raw-egraph-debruijn | 57.865 | 55.145 | 57.865 | 9526.746 | 50728 |
| java-egglog | 56.740 | 54.051 | 56.740 | 9344.246 | 39830 |
| java-egglog-debruijn | 56.410 | 53.740 | 56.410 | 9291.928 | 40902 |
| slotted-egraph | 52.952 | 50.294 | 52.952 | 14353.400 | 60310 |
| canonical | 28.700 | 23.803 | 23.940 | 1836.798 | 10240 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Canonical representation units are the existing canonical-form size, while the five baseline units are retained e-nodes. E-class and e-node columns are reachable saturated-graph counts for every arm; canonical e-nodes include retained alternatives across all temporal matrices.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input classified-data --output egraph_ablation --threads 32 --max-heap 3g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
