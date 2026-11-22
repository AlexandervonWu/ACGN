# Alloy E-Graph Ablation

- Generated at: `2026-11-21T18:26:21.135349598Z`
- Run ID: `b6c1b779-d05d-4ff8-a292-f3048eff69e1`
- Git SHA: `d71cd1c2343b9fdb61d311331feafbe14bea2925` (dirty: false)
- Dataset SHA-256: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Input root: `/home/augustus/ACGN/classified-data`
- Predicate-pair limit: full corpus
- Deterministic seed: `55520260811`
- Worker threads per arm: 16
- Logical processors: 32
- Thread policy: `min(requested, logical processors, 32)`
- JVM heap cap per arm: `8g`
- Java: `17.0.21.1`

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
| raw-egraph | 61598 / 61598 | 4482 | 820 | 15.890 | 15.460 | 3984.362 | 173.110 | 3.503 | 3.673 | 0.060 | 0.040 | 0.141 | 836.557 | 1665.668 | 6.303 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2160 | 16.000 | 15.552 | 3960.841 | 176.760 | 4.356 | 4.571 | 0.074 | 0.049 | 0.181 | 878.941 | 1694.770 | 6.313 |
| java-egglog | 61598 / 61598 | 4482 | 820 | 15.770 | 15.335 | 4016.822 | 170.570 | 3.244 | 3.387 | 0.055 | 0.038 | 0.120 | 787.327 | 1560.930 | 6.163 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2160 | 16.220 | 15.795 | 3899.751 | 177.380 | 4.224 | 4.405 | 0.072 | 0.048 | 0.166 | 858.205 | 1650.977 | 6.172 |
| slotted-egraph | 61598 / 61598 | 4482 | 2228 | 16.770 | 16.245 | 3791.738 | 194.910 | 18.600 | 19.329 | 0.314 | 0.108 | 0.626 | 1019.953 | 1930.852 | 9.243 |
| canonical | 61598 / 61598 | 4482 | 4413 | 25.470 | 25.053 | 2458.734 | 407.650 | 152.338 | 179.005 | 2.906 | 1.823 | 8.344 | 1043.824 | 2206.473 | 1.844 |
| typed-slotted-port-egraph | 61598 / 61598 | 4482 | 4413 | 387.400 | 386.870 | 159.222 | 6467.520 | 5557.802 | 6001.764 | 97.434 | 66.685 | 276.916 | 6667.868 | 8792.566 | 3.367 |

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 71 pairs over the De Bruijn egglog arm, with 3 losses.
- The Fast Rewrite IR adds 2195 zeroes over slotted storage and loses 10.
- The Certificate-Integrated IR adds 0 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.335% of engine CPU time and 21.960% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 15.210x wall time and 36.483x engine CPU, with 3.985x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| raw-egraph-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| java-egglog | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| java-egglog-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| slotted-egraph | 2228 / 19212 | 11.597% | 0 / 42386 | 0.000% |
| canonical | 4413 / 19212 | 22.970% | 0 / 42386 | 0.000% |
| typed-slotted-port-egraph | 4413 / 19212 | 22.970% | 0 / 42386 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 820 | 4.268% | 51.605 | 4.737 | 234.104 | 504.110 |
| raw-egraph-debruijn | 2160 | 11.243% | 135.000 | 12.220 | 495.860 | 1305.098 |
| java-egglog | 820 | 4.268% | 51.997 | 4.807 | 252.809 | 537.936 |
| java-egglog-debruijn | 2160 | 11.243% | 133.169 | 12.177 | 511.349 | 1339.716 |
| slotted-egraph | 2228 | 11.597% | 132.856 | 11.431 | 119.784 | 1181.588 |
| canonical | 4413 | 22.970% | 173.263 | 10.825 | 28.968 | 2048.025 |
| typed-slotted-port-egraph | 4413 | 22.970% | 11.391 | 0.682 | 0.794 | 513.947 |

## Minimum Edit Distance

For the five retained e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The Certificate-Integrated IR obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 16.606 | 12.906 | 18.283 | 14 | 37 |
| raw-egraph-debruijn | 61598 | 16.145 | 12.508 | 17.794 | 14 | 36 |
| java-egglog | 61598 | 16.477 | 12.811 | 18.139 | 14 | 36 |
| java-egglog-debruijn | 61598 | 16.018 | 12.422 | 17.648 | 14 | 36 |
| slotted-egraph | 61598 | 16.324 | 12.638 | 17.995 | 14 | 37 |
| canonical | 61598 | 13.960 | 9.064 | 16.180 | 12 | 34 |
| typed-slotted-port-egraph | 61598 | 13.960 | 9.064 | 16.180 | 12 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the exact typed slotted-port arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.001 | 0.189 | 1.327 |
| raw-egraph-debruijn | 0.001 | 0.193 | 1.327 |
| java-egglog | 0.001 | 0.178 | 1.297 |
| java-egglog-debruijn | 0.001 | 0.188 | 1.296 |
| slotted-egraph | 0.003 | 0.220 | 1.163 |
| canonical | 0.027 | 0.251 | 1.000 |
| typed-slotted-port-egraph | 1.000 | 1.000 | 1.000 |

## Pair-Level Transitions

These edges isolate variable encoding, variadic representation, slots, and the full method.

| Transition | Retained zeroes | Newly zero | No longer zero |
| --- | ---: | ---: | ---: |
| raw-egraph -> raw-egraph-debruijn | 820 | 1340 | 0 |
| raw-egraph -> java-egglog | 820 | 0 | 0 |
| raw-egraph-debruijn -> java-egglog-debruijn | 2160 | 0 | 0 |
| java-egglog -> java-egglog-debruijn | 820 | 1340 | 0 |
| java-egglog-debruijn -> slotted-egraph | 2157 | 71 | 3 |
| slotted-egraph -> canonical | 2218 | 2195 | 10 |
| canonical -> typed-slotted-port-egraph | 4413 | 0 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 39.154 | 36.596 | 39.154 | 6453.876 | 38200 |
| raw-egraph-debruijn | 39.142 | 36.604 | 39.142 | 6464.223 | 39776 |
| java-egglog | 38.265 | 35.757 | 38.265 | 6310.699 | 30750 |
| java-egglog-debruijn | 38.250 | 35.761 | 38.250 | 6320.611 | 31990 |
| slotted-egraph | 34.311 | 31.844 | 34.311 | 9465.067 | 41286 |
| canonical | 29.505 | 25.402 | 25.402 | 1888.319 | 12480 |
| typed-slotted-port-egraph | 29.505 | 19.003 | 16.510 | 3448.139 | 17920 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Fast Rewrite IR units retain the repaired canonical-form size; Certificate-Integrated IR units count its normalized finite-unfolding key. E-class and e-node columns for the certificate-integrated arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input /home/augustus/ACGN/classified-data --output /home/augustus/.local/state/acgn-v31-studies-d71cd1c2/run-v4/natural-report/work --threads 16 --max-heap 8g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
