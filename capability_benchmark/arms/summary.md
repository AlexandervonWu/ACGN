# Alloy E-Graph Ablation

- Generated at: `2026-09-08T21:38:20.479368672Z`
- Run ID: `57a6e527-6718-41fd-b53d-3f9c9bbb118d`
- Git SHA: `8ad5fead39b687d2cadc79b01ac27743c1ece990` (dirty: false)
- Dataset SHA-256: `898d8123ce12ee9a28cb106b801c4d3cb9e1c8aaa2644e0389aedd41e6fb49c3`
- Input root: `/home/augustus/acgn-v215-full-20260908T190500Z/run/capability_benchmark/models`
- Predicate-pair limit: full corpus
- Deterministic seed: `55520260811`
- Worker threads per arm: 16
- Logical processors: 32
- Thread policy: `min(requested, logical processors, 32)`
- JVM heap cap per arm: `8g`
- Java: `17.0.20`

## Arms

1. **Conventional e-graph:** fixed-arity Alloy constructors, the shared rule program, union-find, hash-consing, and congruence rebuilding.
2. **Conventional e-graph + De Bruijn:** the same fixed-arity engine, with bound variables stored as nameless nearest-binder indices.
3. **Java egglog core:** variadic Alloy constructors plus union facts, semi-naive rule rounds, and congruence rebuilding. This is a Java replica of the egglog execution core used here, not a textual-language-compatible port of every egglog feature.
4. **Java egglog + De Bruijn:** the same variadic engine and rules, with nameless bound-variable storage.
5. **Slotted e-graph:** the same raw terms and rules represented as shape-hash-consed renamed eclass invocations with exposed slots, slot redundancy, and finite permutation groups.
6. **Fast Rewrite IR:** the co-maintained temporal/prenex/slotted implementation, with bounded rewrite saturation and direct execution of the reference repair metric.
7. **Certificate-Integrated IR:** the complete `CanonicalAlloyPipeline`, using certified insertion, exact-support typed slots, strict invariant checks, congruence rebuild, and finite-unfolding observation.

## Shared Rule Program

The first five arms use the same `canonical-equivalences-v3-explicit-laws` rule set; only their term/eclass representation differs. The rules are: operator aliases, NOOP elimination, capture-avoiding let beta reduction, implication elimination, iff elimination, formula ITE elimination, boolean constant negation and double negation, De Morgan, atomic negation duals, temporal negation duals, quantifier negation duals, no-to-all-not quantifier expansion, empty quantifier domains, constant quantifier bodies, safe existential-conjunction prenex, safe universal-disjunction prenex, associativity, commutativity, idempotence, boolean identities and annihilators, boolean complements, membership in none/univ, relational union with none, relational intersection with none.

## Runtime And Memory

Each arm ran in a fresh JVM. Wall time, process CPU, and maximum RSS come from `/usr/bin/time -v`; peak used heap is sampled every 10 ms. Engine CPU uses worker-thread CPU counters around representation construction, saturation, and comparison, excluding parsing. Aggregate task time is summed worker latency and may exceed wall time under parallelism.

| Arm | Successful / eligible | AST-same skipped | Equivalent pairs | Process wall s | Dataset wall s | Pairs/s | Process CPU s | Engine CPU s | Aggregate task s | Avg engine ms | P50 ms | P95 ms | Peak heap MiB | Max RSS MiB | Avg structural KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 5500 / 5500 | 0 | 2585 | 2.460 | 2.326 | 2364.961 | 31.710 | 1.293 | 1.367 | 0.249 | 0.094 | 1.013 | 514.780 | 1100.035 | 10.841 |
| raw-egraph-debruijn | 5500 / 5500 | 0 | 3628 | 2.450 | 2.319 | 2371.521 | 32.540 | 1.157 | 1.225 | 0.223 | 0.094 | 0.698 | 441.836 | 936.543 | 10.131 |
| java-egglog | 5500 / 5500 | 0 | 2585 | 2.500 | 2.374 | 2317.190 | 31.900 | 0.888 | 0.955 | 0.174 | 0.086 | 0.464 | 398.307 | 888.348 | 9.679 |
| java-egglog-debruijn | 5500 / 5500 | 0 | 3628 | 2.460 | 2.340 | 2350.372 | 32.610 | 0.897 | 0.971 | 0.177 | 0.088 | 0.465 | 431.575 | 986.715 | 8.974 |
| slotted-egraph | 5500 / 5500 | 0 | 5500 | 2.550 | 2.401 | 2290.507 | 35.070 | 1.673 | 1.799 | 0.327 | 0.185 | 0.728 | 569.183 | 1167.770 | 12.613 |
| canonical | 5500 / 5500 | 0 | 5500 | 3.640 | 3.493 | 1574.597 | 68.100 | 20.072 | 24.862 | 4.520 | 2.736 | 12.563 | 703.122 | 1462.223 | 2.068 |
| typed-slotted-port-egraph | 5500 / 5500 | 0 | 5500 | 316.390 | 316.127 | 17.398 | 5209.840 | 4731.819 | 5026.386 | 913.888 | 670.321 | 2652.863 | 5763.772 | 7062.996 | 4.293 |

## Observations

- De Bruijn storage adds 1043 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1043 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 1872 pairs over the De Bruijn egglog arm, with 0 losses.
- The Fast Rewrite IR adds 0 zeroes over slotted storage and loses 0.
- The Certificate-Integrated IR adds 0 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.035% of engine CPU time and 16.534% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 86.920x wall time and 235.741x engine CPU, with 4.830x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

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
| raw-egraph | 2585 | 47.000% | 1050.813 | 81.520 | 1998.614 | 2406.323 |
| raw-egraph-debruijn | 3628 | 65.964% | 1480.816 | 111.494 | 3135.767 | 3966.793 |
| java-egglog | 2585 | 47.000% | 1034.000 | 81.034 | 2911.742 | 2979.734 |
| java-egglog-debruijn | 3628 | 65.964% | 1474.797 | 111.254 | 4046.037 | 3765.092 |
| slotted-egraph | 5500 | 100.000% | 2156.863 | 156.829 | 3286.650 | 4822.869 |
| canonical | 5500 | 100.000% | 1510.989 | 80.764 | 274.012 | 3851.671 |
| typed-slotted-port-egraph | 5500 | 100.000% | 17.384 | 1.056 | 1.162 | 797.395 |

## Minimum Edit Distance

For the five retained e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The Certificate-Integrated IR obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

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
| raw-egraph | 0.000 | 0.156 | 2.057 |
| raw-egraph-debruijn | 0.000 | 0.133 | 1.931 |
| java-egglog | 0.000 | 0.126 | 1.831 |
| java-egglog-debruijn | 0.000 | 0.140 | 1.707 |
| slotted-egraph | 0.000 | 0.165 | 1.471 |
| canonical | 0.004 | 0.207 | 1.000 |
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
| raw-egraph | 68.068 | 64.162 | 68.068 | 11101.633 | 31088 |
| raw-egraph-debruijn | 63.895 | 60.081 | 63.895 | 10373.944 | 30526 |
| java-egglog | 60.591 | 57.212 | 60.591 | 9911.402 | 23040 |
| java-egglog-debruijn | 56.463 | 53.175 | 56.463 | 9189.617 | 22478 |
| slotted-egraph | 48.670 | 45.931 | 48.670 | 12916.108 | 32990 |
| canonical | 33.094 | 30.381 | 31.013 | 2118.028 | 6144 |
| typed-slotted-port-egraph | 33.086 | 27.438 | 21.645 | 4395.991 | 11776 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Fast Rewrite IR units retain the repaired canonical-form size; Certificate-Integrated IR units count its normalized finite-unfolding key. E-class and e-node columns for the certificate-integrated arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input /home/augustus/acgn-v215-full-20260908T190500Z/run/capability_benchmark/models --output /home/augustus/acgn-v215-full-20260908T190500Z/run/capability_benchmark/arms --threads 16 --max-heap 8g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
