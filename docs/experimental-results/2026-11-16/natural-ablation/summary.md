# Alloy E-Graph Ablation

- Generated at: `2026-11-15T23:59:31.636485338Z`
- Run ID: `8dfc4fcc-84f0-4e9e-a88f-218fe05439b6`
- Git SHA: `2d70f89ab67241cd071387ecedd3b2f432821921` (dirty: false)
- Dataset SHA-256: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Input root: `/home/augustus/ACGN/classified-data`
- Predicate-pair limit: full corpus
- Deterministic seed: `55520260811`
- Worker threads per arm: 16
- Logical processors: 32
- Thread policy: `min(requested, logical processors, 32)`
- JVM heap cap per arm: `8g`
- Java: `17.0.21.0.3`

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
| raw-egraph | 61598 / 61598 | 4482 | 820 | 18.440 | 18.005 | 3421.142 | 190.740 | 3.410 | 3.513 | 0.057 | 0.038 | 0.133 | 857.527 | 1678.523 | 6.303 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2160 | 19.010 | 18.586 | 3314.241 | 191.520 | 4.173 | 4.331 | 0.070 | 0.046 | 0.169 | 762.923 | 1529.398 | 6.313 |
| java-egglog | 61598 / 61598 | 4482 | 820 | 18.520 | 18.106 | 3402.068 | 190.010 | 3.101 | 3.212 | 0.052 | 0.036 | 0.114 | 803.306 | 1584.039 | 6.163 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2160 | 18.690 | 18.270 | 3371.543 | 189.630 | 3.999 | 4.136 | 0.067 | 0.045 | 0.150 | 776.701 | 1530.180 | 6.172 |
| slotted-egraph | 61598 / 61598 | 4482 | 2228 | 18.930 | 18.392 | 3349.215 | 209.570 | 18.695 | 19.387 | 0.315 | 0.105 | 0.614 | 1094.825 | 2058.027 | 9.243 |
| canonical | 61598 / 61598 | 4482 | 4174 | 26.320 | 25.904 | 2377.902 | 410.180 | 148.908 | 173.338 | 2.814 | 1.809 | 8.076 | 1051.682 | 2189.059 | 1.846 |
| typed-slotted-port-egraph | 61598 / 61598 | 4482 | 4174 | 407.400 | 406.822 | 151.413 | 6819.300 | 5873.331 | 6331.679 | 102.790 | 69.586 | 291.612 | 6750.838 | 8662.199 | 3.371 |

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 71 pairs over the De Bruijn egglog arm, with 3 losses.
- The Fast Rewrite IR adds 1956 zeroes over slotted storage and loses 10.
- The Certificate-Integrated IR adds 0 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.318% of engine CPU time and 23.759% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 15.479x wall time and 39.443x engine CPU, with 3.957x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| raw-egraph-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| java-egglog | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| java-egglog-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| slotted-egraph | 2228 / 19212 | 11.597% | 0 / 42386 | 0.000% |
| canonical | 4174 / 19212 | 21.726% | 0 / 42386 | 0.000% |
| typed-slotted-port-egraph | 4174 / 19212 | 21.726% | 0 / 42386 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 820 | 4.268% | 44.469 | 4.299 | 240.499 | 500.249 |
| raw-egraph-debruijn | 2160 | 11.243% | 113.624 | 11.278 | 517.637 | 1446.216 |
| java-egglog | 820 | 4.268% | 44.276 | 4.316 | 264.463 | 530.088 |
| java-egglog-debruijn | 2160 | 11.243% | 115.570 | 11.391 | 540.110 | 1445.477 |
| slotted-egraph | 2228 | 11.597% | 117.697 | 10.631 | 119.175 | 1108.572 |
| canonical | 4174 | 21.726% | 158.587 | 10.176 | 28.031 | 1952.518 |
| typed-slotted-port-egraph | 4174 | 21.726% | 10.245 | 0.612 | 0.711 | 493.429 |

## Minimum Edit Distance

For the five retained e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The Certificate-Integrated IR obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 16.606 | 12.906 | 18.283 | 14 | 37 |
| raw-egraph-debruijn | 61598 | 16.145 | 12.508 | 17.794 | 14 | 36 |
| java-egglog | 61598 | 16.477 | 12.811 | 18.139 | 14 | 36 |
| java-egglog-debruijn | 61598 | 16.018 | 12.422 | 17.648 | 14 | 36 |
| slotted-egraph | 61598 | 16.324 | 12.638 | 17.995 | 14 | 37 |
| canonical | 61598 | 14.011 | 9.174 | 16.204 | 12 | 34 |
| typed-slotted-port-egraph | 61598 | 14.011 | 9.174 | 16.204 | 12 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the exact typed slotted-port arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.001 | 0.194 | 1.326 |
| raw-egraph-debruijn | 0.001 | 0.177 | 1.325 |
| java-egglog | 0.001 | 0.183 | 1.296 |
| java-egglog-debruijn | 0.001 | 0.177 | 1.295 |
| slotted-egraph | 0.003 | 0.238 | 1.162 |
| canonical | 0.025 | 0.253 | 1.000 |
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
| slotted-egraph -> canonical | 2218 | 1956 | 10 |
| canonical -> typed-slotted-port-egraph | 4174 | 0 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 39.154 | 36.596 | 39.154 | 6453.876 | 38200 |
| raw-egraph-debruijn | 39.142 | 36.604 | 39.142 | 6464.223 | 39776 |
| java-egglog | 38.265 | 35.757 | 38.265 | 6310.699 | 30750 |
| java-egglog-debruijn | 38.250 | 35.761 | 38.250 | 6320.611 | 31990 |
| slotted-egraph | 34.311 | 31.844 | 34.311 | 9465.067 | 41286 |
| canonical | 29.537 | 25.425 | 25.425 | 1890.351 | 13248 |
| typed-slotted-port-egraph | 29.537 | 19.020 | 16.523 | 3451.572 | 18448 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Fast Rewrite IR units retain the repaired canonical-form size; Certificate-Integrated IR units count its normalized finite-unfolding key. E-class and e-node columns for the certificate-integrated arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input /home/augustus/ACGN/classified-data --output /media/augustus/8618-0ED0/ACGN/intermediate/publication-studies-20261115-v3/natural-ablation --threads 16 --max-heap 8g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
