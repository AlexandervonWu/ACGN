# Alloy E-Graph Ablation

- Generated at: `2026-08-18T14:08:35.981771290Z`
- Run ID: `d06fc18f-8d04-4ba3-bebf-af2ddc0aabd7`
- Git SHA: `fc66da28ebebee3ba73ea9694aa01b5a7bcda958` (dirty: true)
- Dataset SHA-256: `e9901ba9e63a8090e0beb9d04d19bd66da3a7f49ca681ef6adf164e8ca6265f0`
- Input root: `/home/augustus/ACGN/capability_benchmark/models`
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
| raw-egraph | 5500 / 5500 | 0 | 2585 | 2.420 | 2.288 | 2403.947 | 34.240 | 1.105 | 1.401 | 0.255 | 0.092 | 0.675 | 413.796 | 869.504 | 10.841 |
| raw-egraph-debruijn | 5500 / 5500 | 0 | 3628 | 2.510 | 2.376 | 2314.409 | 35.840 | 1.574 | 1.926 | 0.350 | 0.096 | 1.416 | 381.250 | 849.770 | 10.131 |
| java-egglog | 5500 / 5500 | 0 | 2585 | 2.410 | 2.274 | 2418.666 | 34.730 | 1.016 | 1.363 | 0.248 | 0.084 | 0.636 | 371.678 | 820.160 | 9.677 |
| java-egglog-debruijn | 5500 / 5500 | 0 | 3628 | 2.380 | 2.255 | 2439.331 | 34.540 | 0.981 | 1.307 | 0.238 | 0.088 | 0.483 | 370.112 | 814.801 | 8.972 |
| slotted-egraph | 5500 / 5500 | 0 | 5500 | 2.480 | 2.352 | 2338.719 | 40.380 | 1.908 | 2.609 | 0.474 | 0.200 | 0.944 | 402.980 | 886.117 | 12.610 |
| canonical | 5500 / 5500 | 0 | 5500 | 2.500 | 2.324 | 2366.569 | 47.970 | 4.370 | 6.306 | 1.147 | 0.440 | 3.823 | 1082.460 | 1813.117 | 2.739 |
| typed-slotted-port-egraph | 5500 / 5500 | 0 | 5500 | 337.000 | 336.742 | 16.333 | 9283.410 | 8542.754 | 10705.671 | 1946.486 | 1619.082 | 4730.967 | 3579.258 | 4573.574 | 5.864 |

## Observations

- De Bruijn storage adds 1043 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1043 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 1872 pairs over the De Bruijn egglog arm, with 0 losses.
- The Fast Rewrite IR adds 0 zeroes over slotted storage and loses 0.
- The Certificate-Integrated IR adds 0 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.022% of engine CPU time and 19.375% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 134.800x wall time and 1954.834x engine CPU, with 2.522x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

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
| raw-egraph | 2585 | 47.000% | 1068.182 | 75.496 | 2340.314 | 3044.311 |
| raw-egraph-debruijn | 3628 | 65.964% | 1445.418 | 101.228 | 2304.770 | 4371.858 |
| java-egglog | 2585 | 47.000% | 1072.614 | 74.431 | 2543.059 | 3227.467 |
| java-egglog-debruijn | 3628 | 65.964% | 1524.370 | 105.038 | 3697.446 | 4559.485 |
| slotted-egraph | 5500 | 100.000% | 2217.742 | 136.206 | 2882.039 | 6355.818 |
| canonical | 5500 | 100.000% | 2200.000 | 114.655 | 1258.562 | 3106.253 |
| typed-slotted-port-egraph | 5500 | 100.000% | 16.320 | 0.592 | 0.644 | 1231.422 |

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
| raw-egraph | 0.000 | 0.190 | 1.553 |
| raw-egraph-debruijn | 0.000 | 0.186 | 1.458 |
| java-egglog | 0.000 | 0.179 | 1.382 |
| java-egglog-debruijn | 0.000 | 0.178 | 1.288 |
| slotted-egraph | 0.000 | 0.194 | 1.110 |
| canonical | 0.001 | 0.396 | 1.000 |
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
./scripts/run_egraph_ablation.sh --input /home/augustus/ACGN/capability_benchmark/models --output /home/augustus/ACGN/capability_benchmark/arms --threads 32 --max-heap 4g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
