# Alloy E-Graph Ablation

- Generated at: `2026-08-19T18:15:34.842674153Z`
- Run ID: `cdf14cb3-6481-4512-8022-7c5e0e5929ec`
- Git SHA: `f1bb1607911a4e5a7a0b8527be65148f66cf72d8` (dirty: false)
- Dataset SHA-256: `e9901ba9e63a8090e0beb9d04d19bd66da3a7f49ca681ef6adf164e8ca6265f0`
- Input root: `/absolute/path/to/acgn-publication-run/capability_benchmark/models`
- Predicate-pair limit: full corpus
- Deterministic seed: `55520260811`
- Worker threads per arm: 32
- Logical processors: 32
- Thread policy: `min(requested, logical processors, 32)`
- JVM heap cap per arm: `4g`
- Java: `17.0.19`

## Arms

1. **Conventional e-graph:** fixed-arity Alloy constructors, the shared rule program, union-find, hash-consing, and congruence rebuilding.
2. **Conventional e-graph + De Bruijn:** the same fixed-arity engine, with bound variables stored as nameless nearest-binder indices.
3. **Java egglog core:** variadic Alloy constructors plus union facts, semi-naive rule rounds, and congruence rebuilding. This is a Java replica of the egglog execution core used here, not a textual-language-compatible port of every egglog feature.
4. **Java egglog + De Bruijn:** the same variadic engine and rules, with nameless bound-variable storage.
5. **Slotted e-graph:** the same raw terms and rules represented as shape-hash-consed renamed eclass invocations with exposed slots, slot redundancy, and finite permutation groups.
6. **Fast Rewrite IR:** the co-maintained temporal/prenex/slotted implementation, with bounded rewrite saturation and direct execution of the reference repair metric.
7. **Certificate-Integrated IR:** the complete `CanonicalAlloyPipeline`, using certified insertion, exact-support typed slots, strict invariant checks, congruence rebuild, and finite-unfolding observation.

## Shared Rule Program

The first five arms use the same `canonical-equivalences-v2` rule set; only their term/eclass representation differs. The rules are: operator aliases, NOOP elimination, capture-avoiding let beta reduction, implication elimination, iff elimination, formula ITE elimination, boolean constant negation and double negation, De Morgan, atomic negation duals, temporal negation duals, quantifier negation duals, no-to-all-not quantifier expansion, empty quantifier domains, constant quantifier bodies, safe existential-conjunction prenex, safe universal-disjunction prenex, associativity, commutativity, idempotence, boolean identities and annihilators, boolean complements, membership in none/univ, relational union with none, relational intersection with none.

## Runtime And Memory

Each arm ran in a fresh JVM. Wall time, process CPU, and maximum RSS come from `/usr/bin/time -v`; peak used heap is sampled every 10 ms. Engine CPU uses worker-thread CPU counters around representation construction, saturation, and comparison, excluding parsing. Aggregate task time is summed worker latency and may exceed wall time under parallelism.

| Arm | Successful / eligible | AST-same skipped | Equivalent pairs | Process wall s | Dataset wall s | Pairs/s | Process CPU s | Engine CPU s | Aggregate task s | Avg engine ms | P50 ms | P95 ms | Peak heap MiB | Max RSS MiB | Avg structural KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 5500 / 5500 | 0 | 2585 | 2.290 | 2.166 | 2539.388 | 35.540 | 1.672 | 2.088 | 0.380 | 0.098 | 1.646 | 393.685 | 894.984 | 10.841 |
| raw-egraph-debruijn | 5500 / 5500 | 0 | 3628 | 2.460 | 2.334 | 2356.895 | 37.880 | 1.386 | 1.975 | 0.359 | 0.099 | 1.106 | 399.077 | 874.129 | 10.131 |
| java-egglog | 5500 / 5500 | 0 | 2585 | 2.420 | 2.291 | 2400.340 | 35.140 | 0.848 | 1.115 | 0.203 | 0.079 | 0.462 | 424.375 | 866.754 | 9.677 |
| java-egglog-debruijn | 5500 / 5500 | 0 | 3628 | 2.390 | 2.264 | 2429.248 | 34.980 | 1.121 | 1.455 | 0.265 | 0.090 | 0.651 | 394.127 | 845.957 | 8.972 |
| slotted-egraph | 5500 / 5500 | 0 | 5500 | 2.510 | 2.379 | 2312.089 | 40.660 | 1.983 | 2.695 | 0.490 | 0.217 | 0.943 | 389.300 | 892.980 | 12.610 |
| canonical | 5500 / 5500 | 0 | 5500 | 2.570 | 2.415 | 2277.776 | 46.710 | 4.561 | 6.528 | 1.187 | 0.422 | 4.978 | 1092.407 | 1687.297 | 2.739 |
| typed-slotted-port-egraph | 5500 / 5500 | 0 | 5500 | 344.370 | 344.132 | 15.982 | 9457.050 | 8689.747 | 10942.712 | 1989.584 | 1661.344 | 4839.228 | 3587.211 | 4618.988 | 5.864 |

## Observations

- De Bruijn storage adds 1043 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1043 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 1872 pairs over the De Bruijn egglog arm, with 0 losses.
- The Fast Rewrite IR adds 0 zeroes over slotted storage and loses 0.
- The Certificate-Integrated IR adds 0 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.023% of engine CPU time and 19.333% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 133.996x wall time and 1905.364x engine CPU, with 2.738x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

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
| raw-egraph | 2585 | 47.000% | 1128.821 | 72.735 | 1545.991 | 2957.638 |
| raw-egraph-debruijn | 3628 | 65.964% | 1474.797 | 95.776 | 2617.376 | 4250.028 |
| java-egglog | 2585 | 47.000% | 1068.182 | 73.563 | 3049.125 | 3053.970 |
| java-egglog-debruijn | 3628 | 65.964% | 1517.992 | 103.716 | 3234.987 | 4391.561 |
| slotted-egraph | 5500 | 100.000% | 2191.235 | 135.268 | 2772.944 | 6306.969 |
| canonical | 5500 | 100.000% | 2140.078 | 117.748 | 1205.962 | 3337.883 |
| typed-slotted-port-egraph | 5500 | 100.000% | 15.971 | 0.582 | 0.633 | 1219.315 |

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
| raw-egraph | 0.000 | 0.194 | 1.553 |
| raw-egraph-debruijn | 0.000 | 0.189 | 1.458 |
| java-egglog | 0.000 | 0.188 | 1.382 |
| java-egglog-debruijn | 0.000 | 0.183 | 1.288 |
| slotted-egraph | 0.000 | 0.193 | 1.110 |
| canonical | 0.001 | 0.365 | 1.000 |
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

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Fast Rewrite IR units retain the repaired canonical-form size; Certificate-Integrated IR units count its normalized finite-unfolding key. E-class and e-node columns for the certificate-integrated arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input /absolute/path/to/acgn-publication-run/capability_benchmark/models --output /absolute/path/to/acgn-publication-run/capability_benchmark/arms --threads 32 --max-heap 4g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
