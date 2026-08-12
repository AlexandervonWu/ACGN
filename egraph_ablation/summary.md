# Alloy E-Graph Ablation

- Generated at: `2026-08-12T14:12:02.686915174Z`
- Run ID: `2610bc86-0acc-4b20-a001-6055ee36a081`
- Git SHA: `01d1e3134671d9f1ef9278021aa18a3d12afa408` (dirty: true)
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
| raw-egraph | 61598 / 61598 | 4482 | 823 | 17.470 | 17.055 | 3611.626 | 187.270 | 4.466 | 5.033 | 0.082 | 0.048 | 0.167 | 476.156 | 997.504 | 9.353 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2163 | 17.360 | 16.971 | 3629.540 | 191.580 | 5.738 | 6.458 | 0.105 | 0.061 | 0.228 | 429.728 | 905.094 | 9.303 |
| java-egglog | 61598 / 61598 | 4482 | 823 | 17.120 | 16.718 | 3684.580 | 187.220 | 4.628 | 5.201 | 0.084 | 0.049 | 0.157 | 469.627 | 980.988 | 9.125 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2163 | 17.450 | 17.037 | 3615.500 | 190.680 | 5.274 | 6.092 | 0.099 | 0.056 | 0.186 | 449.075 | 948.785 | 9.074 |
| slotted-egraph | 61598 / 61598 | 4482 | 2162 | 18.000 | 17.569 | 3506.157 | 206.130 | 15.312 | 16.991 | 0.276 | 0.119 | 0.981 | 523.712 | 1075.449 | 14.017 |
| canonical | 61598 / 61598 | 4482 | 2235 | 19.050 | 18.588 | 3313.784 | 248.850 | 13.607 | 16.563 | 0.269 | 0.171 | 0.484 | 2888.389 | 3566.262 | 1.794 |

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 2 pairs over the De Bruijn egglog arm, with 3 losses.
- The current canonical method is a strict superset of the slotted arm on this corpus: it adds 73 zeroes and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 112.536% of engine CPU time and 30.156% of maximum RSS. End-to-end wall time is parser-dominated.

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
| raw-egraph | 823 | 4.284% | 47.109 | 4.395 | 184.266 | 844.861 |
| raw-egraph-debruijn | 2163 | 11.259% | 124.597 | 11.290 | 376.936 | 2447.163 |
| java-egglog | 823 | 4.284% | 48.072 | 4.396 | 177.842 | 859.085 |
| java-egglog-debruijn | 2163 | 11.259% | 123.954 | 11.344 | 410.138 | 2334.472 |
| slotted-egraph | 2162 | 11.253% | 120.111 | 10.489 | 141.193 | 2058.570 |
| canonical | 2235 | 11.633% | 117.323 | 8.981 | 164.258 | 641.748 |

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
| raw-egraph | 0.328 | 0.280 | 2.027 |
| raw-egraph-debruijn | 0.422 | 0.254 | 2.016 |
| java-egglog | 0.340 | 0.275 | 1.977 |
| java-egglog-debruijn | 0.388 | 0.266 | 1.965 |
| slotted-egraph | 1.125 | 0.302 | 1.845 |
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
