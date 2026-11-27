# Alloy E-Graph Ablation

- Generated at: `2026-11-27T04:46:23.941504329Z`
- Run ID: `ec572937-1012-464d-8642-bb298eea09fc`
- Git SHA: `9693595eb4f60c6c70b6d8d174ee309d1fdcf9aa` (dirty: false)
- Dataset SHA-256: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Input root: `[CHECKOUT]/classified-data`
- Predicate-pair limit: full corpus
- Deterministic seed: `55520260811`
- Worker threads per arm: 16
- Logical processors: 16
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
| raw-egraph | 61598 / 61598 | 4482 | 820 | 18.050 | 17.531 | 3513.573 | 187.340 | 3.842 | 4.155 | 0.067 | 0.044 | 0.161 | 696.080 | 1347.555 | 6.303 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2160 | 18.310 | 17.788 | 3462.936 | 191.030 | 4.862 | 5.222 | 0.085 | 0.054 | 0.209 | 728.839 | 1381.813 | 6.313 |
| java-egglog | 61598 / 61598 | 4482 | 820 | 18.120 | 17.633 | 3493.347 | 188.770 | 3.725 | 3.999 | 0.065 | 0.044 | 0.144 | 732.746 | 1391.395 | 6.163 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2160 | 18.260 | 17.699 | 3480.361 | 191.580 | 4.659 | 4.993 | 0.081 | 0.053 | 0.187 | 711.465 | 1383.207 | 6.172 |
| slotted-egraph | 61598 / 61598 | 4482 | 2228 | 18.920 | 18.292 | 3367.474 | 220.040 | 25.556 | 26.761 | 0.434 | 0.123 | 0.816 | 1097.102 | 1963.070 | 9.243 |
| canonical | 61598 / 61598 | 4482 | 5137 | 28.360 | 27.910 | 2206.984 | 412.330 | 151.309 | 181.467 | 2.946 | 1.963 | 8.157 | 1027.121 | 2059.301 | 1.807 |
| typed-slotted-port-egraph | 61598 / 61598 | 4482 | 5137 | 387.320 | 386.579 | 159.341 | 6241.530 | 5512.368 | 6013.238 | 97.621 | 66.604 | 278.154 | 6303.346 | 8638.945 | 3.332 |

## Slotted zero coverage

PASSED across 2228 required zero pairs.

- canonical lost 0, added 2909 correct zeros, and found 0 incorrect zeros.
- typed-slotted-port-egraph lost 0, added 2909 correct zeros, and found 0 incorrect zeros.

Exact loss and incorrect-zero paths are recorded in `comparison.json`.

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 71 pairs over the De Bruijn egglog arm, with 3 losses.
- The Fast Rewrite IR adds 2909 zeroes over slotted storage and loses 0.
- The Certificate-Integrated IR adds 0 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.464% of engine CPU time and 22.723% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 13.657x wall time and 36.431x engine CPU, with 4.195x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| raw-egraph-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| java-egglog | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| java-egglog-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| slotted-egraph | 2228 / 19212 | 11.597% | 0 / 42386 | 0.000% |
| canonical | 5137 / 19212 | 26.738% | 0 / 42386 | 0.000% |
| typed-slotted-port-egraph | 5137 / 19212 | 26.738% | 0 / 42386 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 820 | 4.268% | 45.429 | 4.377 | 213.409 | 623.114 |
| raw-egraph-debruijn | 2160 | 11.243% | 117.968 | 11.307 | 444.231 | 1600.680 |
| java-egglog | 820 | 4.268% | 45.254 | 4.344 | 220.118 | 603.481 |
| java-egglog-debruijn | 2160 | 11.243% | 118.291 | 11.275 | 463.601 | 1599.066 |
| slotted-egraph | 2228 | 11.597% | 117.759 | 10.125 | 87.182 | 1162.196 |
| canonical | 5137 | 26.738% | 181.135 | 12.458 | 33.950 | 2554.405 |
| typed-slotted-port-egraph | 5137 | 26.738% | 13.263 | 0.823 | 0.932 | 608.904 |

## Minimum Edit Distance

For the five retained e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The Certificate-Integrated IR obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 16.606 | 12.906 | 18.283 | 14 | 37 |
| raw-egraph-debruijn | 61598 | 16.145 | 12.508 | 17.794 | 14 | 36 |
| java-egglog | 61598 | 16.477 | 12.811 | 18.139 | 14 | 36 |
| java-egglog-debruijn | 61598 | 16.018 | 12.422 | 17.648 | 14 | 36 |
| slotted-egraph | 61598 | 16.324 | 12.638 | 17.995 | 14 | 37 |
| canonical | 61598 | 13.471 | 8.468 | 15.739 | 11 | 33 |
| typed-slotted-port-egraph | 61598 | 13.471 | 8.468 | 15.739 | 11 | 33 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the exact typed slotted-port arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.001 | 0.156 | 1.354 |
| raw-egraph-debruijn | 0.001 | 0.160 | 1.354 |
| java-egglog | 0.001 | 0.161 | 1.323 |
| java-egglog-debruijn | 0.001 | 0.160 | 1.323 |
| slotted-egraph | 0.005 | 0.227 | 1.187 |
| canonical | 0.027 | 0.238 | 1.000 |
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
| slotted-egraph -> canonical | 2228 | 2909 | 0 |
| canonical -> typed-slotted-port-egraph | 5137 | 0 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 39.154 | 36.596 | 39.154 | 6453.876 | 38200 |
| raw-egraph-debruijn | 39.142 | 36.604 | 39.142 | 6464.223 | 39776 |
| java-egglog | 38.265 | 35.757 | 38.265 | 6310.699 | 30750 |
| java-egglog-debruijn | 38.250 | 35.761 | 38.250 | 6320.611 | 31990 |
| slotted-egraph | 34.311 | 31.844 | 34.311 | 9465.067 | 41286 |
| canonical | 28.916 | 24.923 | 24.923 | 1850.612 | 12480 |
| typed-slotted-port-egraph | 28.916 | 18.834 | 16.394 | 3411.745 | 17264 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Fast Rewrite IR units retain the repaired canonical-form size; Certificate-Integrated IR units count its normalized finite-unfolding key. E-class and e-node columns for the certificate-integrated arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input [CHECKOUT]/classified-data --output [ARTIFACTS]/egraph_ablation --threads 16 --max-heap 8g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
