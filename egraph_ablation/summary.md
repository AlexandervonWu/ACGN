# Alloy E-Graph Ablation

- Generated at: `2026-08-11T17:55:51.330098760Z`
- Run ID: `7a38c97e-1c10-4a84-9648-19e679129d5d`
- Git SHA: `556940083db6c54893a436e9aa880ec0e5850cea` (dirty: true)
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

The first five arms use the same `canonical-equivalences-v1` rule set; only their term/eclass representation differs. The rules are: operator aliases, NOOP elimination, capture-avoiding let beta reduction, implication elimination, iff elimination, formula ITE elimination, boolean constant negation and double negation, De Morgan, atomic negation duals, temporal negation duals, quantifier negation duals, no-to-all-not quantifier expansion, empty quantifier domains, safe existential-conjunction prenex, safe universal-disjunction prenex, associativity, commutativity, idempotence, boolean identities and annihilators, boolean complements, membership in none/univ, relational union with none, relational intersection with none.

## Runtime And Memory

Each arm ran in a fresh JVM. Wall time, process CPU, and maximum RSS come from `/usr/bin/time -v`; peak used heap is sampled every 10 ms. Engine CPU uses worker-thread CPU counters around representation construction, saturation, and comparison, excluding parsing. Aggregate task time is summed worker latency and may exceed wall time under parallelism.

| Arm | Successful / eligible | AST-same skipped | Equivalent pairs | Process wall s | Dataset wall s | Pairs/s | Process CPU s | Engine CPU s | Aggregate task s | Avg engine ms | P50 ms | P95 ms | Peak heap MiB | Max RSS MiB | Avg structural KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 / 61598 | 4482 | 823 | 16.730 | 16.308 | 3777.200 | 181.270 | 4.375 | 4.999 | 0.081 | 0.048 | 0.163 | 444.413 | 919.203 | 9.356 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2163 | 18.490 | 18.084 | 3406.234 | 188.770 | 5.127 | 5.725 | 0.093 | 0.055 | 0.197 | 423.002 | 933.465 | 9.307 |
| java-egglog | 61598 / 61598 | 4482 | 823 | 18.500 | 18.076 | 3407.753 | 185.740 | 3.988 | 4.421 | 0.072 | 0.045 | 0.136 | 405.958 | 875.520 | 9.128 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2163 | 18.300 | 17.884 | 3444.310 | 187.860 | 5.018 | 5.561 | 0.090 | 0.055 | 0.179 | 414.628 | 876.754 | 9.077 |
| slotted-egraph | 61598 / 61598 | 4482 | 2162 | 19.340 | 18.895 | 3260.036 | 210.340 | 18.185 | 19.736 | 0.320 | 0.147 | 1.111 | 437.300 | 946.063 | 14.023 |
| canonical | 61598 / 61598 | 4482 | 2235 | 20.160 | 19.527 | 3154.523 | 250.380 | 12.762 | 15.355 | 0.249 | 0.161 | 0.446 | 2846.031 | 3629.090 | 1.794 |

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 2 pairs over the De Bruijn egglog arm, with 3 losses.
- The current canonical method is a strict superset of the slotted arm on this corpus: it adds 73 zeroes and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 142.492% of engine CPU time and 26.069% of maximum RSS. End-to-end wall time is parser-dominated.

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
| raw-egraph | 823 | 4.284% | 49.193 | 4.540 | 188.118 | 916.829 |
| raw-egraph-debruijn | 2163 | 11.259% | 116.982 | 11.458 | 421.856 | 2372.786 |
| java-egglog | 823 | 4.284% | 44.486 | 4.431 | 206.355 | 962.574 |
| java-egglog-debruijn | 2163 | 11.259% | 118.197 | 11.514 | 431.055 | 2526.264 |
| slotted-egraph | 2162 | 11.253% | 111.789 | 10.279 | 118.888 | 2340.108 |
| canonical | 2235 | 11.633% | 110.863 | 8.926 | 175.125 | 630.637 |

## Minimum Edit Distance

For the five e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. The canonical arm uses the production canonical edit distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 18.416 | 14.173 | 20.338 | 16 | 42 |
| raw-egraph-debruijn | 61598 | 17.948 | 13.771 | 19.841 | 15 | 42 |
| java-egglog | 61598 | 18.020 | 13.975 | 19.853 | 15 | 41 |
| java-egglog-debruijn | 61598 | 17.553 | 13.576 | 19.355 | 15 | 40 |
| slotted-egraph | 61598 | 17.717 | 13.709 | 19.533 | 15 | 40 |
| canonical | 61598 | 13.540 | 9.322 | 15.452 | 11 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the current full canonical arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.343 | 0.253 | 2.028 |
| raw-egraph-debruijn | 0.402 | 0.257 | 2.017 |
| java-egglog | 0.313 | 0.241 | 1.978 |
| java-egglog-debruijn | 0.393 | 0.242 | 1.966 |
| slotted-egraph | 1.425 | 0.261 | 1.846 |
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
| raw-egraph | 58.208 | 55.468 | 58.208 | 9581.037 | 49152 |
| raw-egraph-debruijn | 57.888 | 55.168 | 57.888 | 9530.602 | 50728 |
| java-egglog | 56.760 | 54.070 | 56.760 | 9347.546 | 39830 |
| java-egglog-debruijn | 56.429 | 53.759 | 56.429 | 9295.162 | 40902 |
| slotted-egraph | 52.971 | 50.313 | 52.971 | 14359.114 | 60310 |
| canonical | 28.700 | 23.803 | 23.940 | 1836.798 | 10240 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Canonical representation units are the existing canonical-form size, while the five baseline units are retained e-nodes. E-class and e-node columns are reachable saturated-graph counts for every arm; canonical e-nodes include retained alternatives across all temporal matrices.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input classified-data --output egraph_ablation --threads 32 --max-heap 3g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
