# Alloy E-Graph Ablation

- Generated at: `2026-08-11T03:41:52.144434029Z`
- Input root: `classified-data`
- Predicate-pair limit: full corpus
- Worker threads per arm: 32
- Logical processors: 32
- Thread policy: `min(requested, logical processors, 32)`
- JVM heap cap per arm: `3g`
- Java: `17.0.19`

## Arms

1. **Conventional e-graph:** fixed-arity Alloy constructors, the shared rule program, union-find, hash-consing, and congruence rebuilding.
2. **Java egglog core:** variadic Alloy constructors plus union facts, semi-naive rule rounds, and congruence rebuilding. This is a Java replica of the egglog execution core used here, not a textual-language-compatible port of every egglog feature.
3. **Slotted e-graph:** the same raw terms and rules represented as shape-hash-consed renamed eclass invocations with exposed slots, slot redundancy, and finite permutation groups.
4. **Canonical:** the current method, adding temporal-phase partitioning, connective elimination, strict per-phase prenexing, primitive binding tuples, and canonical variadic matrices.

## Shared Rule Program

The first three arms use the same `canonical-equivalences-v1` rule set; only their term/eclass representation differs. The rules are: operator aliases, NOOP elimination, capture-avoiding let beta reduction, implication elimination, iff elimination, formula ITE elimination, boolean constant negation and double negation, De Morgan, atomic negation duals, temporal negation duals, quantifier negation duals, no-to-all-not quantifier expansion, empty quantifier domains, safe existential-conjunction prenex, safe universal-disjunction prenex, associativity, commutativity, idempotence, boolean identities and annihilators, boolean complements, membership in none/univ, relational union with none, relational intersection with none.

## Runtime And Memory

Each arm ran in a fresh JVM. Wall time, process CPU, and maximum RSS come from `/usr/bin/time -v`; peak used heap is sampled every 10 ms. Engine CPU uses worker-thread CPU counters around representation construction, saturation, and comparison, excluding parsing. Aggregate task time is summed worker latency and may exceed wall time under parallelism.

| Arm | Successful / eligible | AST-same skipped | Equivalent pairs | Process wall s | Dataset wall s | Pairs/s | Process CPU s | Engine CPU s | Aggregate task s | Avg engine ms | P50 ms | P95 ms | Peak heap MiB | Max RSS MiB | Avg structural KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 / 61598 | 4482 | 823 | 16.450 | 16.029 | 3842.821 | 179.010 | 4.226 | 4.785 | 0.078 | 0.046 | 0.160 | 488.801 | 1042.289 | 9.356 |
| java-egglog | 61598 / 61598 | 4482 | 823 | 18.000 | 17.573 | 3505.346 | 180.860 | 3.913 | 4.329 | 0.070 | 0.043 | 0.130 | 418.324 | 889.516 | 9.128 |
| slotted-egraph | 61598 / 61598 | 4482 | 2162 | 18.610 | 18.184 | 3387.522 | 201.260 | 14.425 | 15.901 | 0.258 | 0.112 | 0.939 | 460.762 | 943.707 | 14.023 |
| canonical | 61598 / 61598 | 4482 | 2235 | 18.160 | 17.745 | 3471.280 | 243.200 | 12.748 | 15.306 | 0.248 | 0.159 | 0.455 | 2880.588 | 3556.539 | 1.794 |

## Observations

- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- Slot-aware shapes add 1339 pairs over the egglog arm, with 0 losses.
- The current canonical method is a strict superset of the slotted arm on this corpus: it adds 73 zeroes and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 113.154% of engine CPU time and 26.534% of maximum RSS. End-to-end wall time is parser-dominated.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 823 / 19212 | 4.284% | 0 / 42386 | 0.000% |
| java-egglog | 823 / 19212 | 4.284% | 0 / 42386 | 0.000% |
| slotted-egraph | 2162 / 19212 | 11.253% | 0 / 42386 | 0.000% |
| canonical | 2235 / 19212 | 11.633% | 0 / 42386 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 823 | 4.284% | 50.030 | 4.598 | 194.748 | 808.559 |
| java-egglog | 823 | 4.284% | 45.722 | 4.550 | 210.304 | 947.428 |
| slotted-egraph | 2162 | 11.253% | 116.174 | 10.742 | 149.881 | 2345.948 |
| canonical | 2235 | 11.633% | 123.073 | 9.190 | 175.323 | 643.502 |

## Minimum Edit Distance

For the three e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups. Eclass equality has distance zero. The canonical arm uses the production canonical edit distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 18.416 | 14.173 | 20.338 | 16 | 42 |
| java-egglog | 61598 | 18.020 | 13.975 | 19.853 | 15 | 41 |
| slotted-egraph | 61598 | 17.717 | 13.709 | 19.533 | 15 | 40 |
| canonical | 61598 | 13.540 | 9.322 | 15.452 | 11 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the current full canonical arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.332 | 0.293 | 2.028 |
| java-egglog | 0.307 | 0.250 | 1.978 |
| slotted-egraph | 1.132 | 0.265 | 1.846 |
| canonical | 1.000 | 1.000 | 1.000 |

## Pair-Level Transitions

These counts make clear whether each successive arm is a strict extension on this corpus.

| Transition | Retained zeroes | Newly zero | No longer zero |
| --- | ---: | ---: | ---: |
| raw-egraph -> java-egglog | 823 | 0 | 0 |
| java-egglog -> slotted-egraph | 823 | 1339 | 0 |
| slotted-egraph -> canonical | 2162 | 73 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 58.208 | 55.468 | 58.208 | 9581.037 | 49152 |
| java-egglog | 56.760 | 54.070 | 56.760 | 9347.546 | 39830 |
| slotted-egraph | 52.971 | 50.313 | 52.971 | 14359.114 | 60310 |
| canonical | 28.700 | 23.803 | 23.940 | 1836.798 | 10240 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Canonical representation units are the existing canonical-form size, while the three baseline units are retained e-nodes. E-class and e-node columns are reachable saturated-graph counts for every arm; canonical e-nodes include retained alternatives across all temporal matrices.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input classified-data --output egraph_ablation --threads 32 --max-heap 3g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
