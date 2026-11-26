# Alloy E-Graph Ablation

- Generated at: `2026-11-26T10:06:48.692307089Z`
- Run ID: `3b4f707d-f090-46e8-8c8c-7ffbedf86ebb`
- Git SHA: `d5c0c2a07504d53b13b28c61e9e64768c37eb984` (dirty: false)
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
| raw-egraph | 61598 / 61598 | 4482 | 820 | 18.700 | 18.233 | 3378.468 | 181.080 | 3.284 | 3.381 | 0.055 | 0.037 | 0.130 | 802.419 | 1532.934 | 6.303 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2160 | 19.230 | 18.765 | 3282.644 | 186.550 | 4.121 | 4.248 | 0.069 | 0.045 | 0.166 | 727.929 | 1418.660 | 6.313 |
| java-egglog | 61598 / 61598 | 4482 | 820 | 19.040 | 18.602 | 3311.309 | 183.190 | 3.175 | 3.276 | 0.053 | 0.037 | 0.115 | 672.847 | 1478.883 | 6.163 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2160 | 19.180 | 18.715 | 3291.377 | 186.830 | 3.939 | 4.062 | 0.066 | 0.045 | 0.147 | 787.452 | 1508.488 | 6.172 |
| slotted-egraph | 61598 / 61598 | 4482 | 2228 | 19.400 | 18.802 | 3276.118 | 206.760 | 18.409 | 18.922 | 0.307 | 0.104 | 0.590 | 1034.924 | 1901.836 | 9.243 |
| canonical | 61598 / 61598 | 4482 | 4499 | 27.130 | 26.683 | 2308.537 | 388.660 | 141.496 | 170.233 | 2.764 | 1.839 | 7.556 | 1067.934 | 2115.727 | 1.834 |
| typed-slotted-port-egraph | 61598 / 61598 | 4482 | 4499 | 398.760 | 398.186 | 154.697 | 6401.690 | 5676.430 | 6201.523 | 100.677 | 68.253 | 287.193 | 6483.813 | 8595.605 | 3.356 |

## Slotted zero coverage

PASSED across 2228 required zero pairs.

- canonical lost 0, added 2271 correct zeros, and found 0 incorrect zeros.
- typed-slotted-port-egraph lost 0, added 2271 correct zeros, and found 0 incorrect zeros.

Exact loss and incorrect-zero paths are recorded in `comparison.json`.

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 71 pairs over the De Bruijn egglog arm, with 3 losses.
- The Fast Rewrite IR adds 2271 zeroes over slotted storage and loses 0.
- The Certificate-Integrated IR adds 0 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.324% of engine CPU time and 22.126% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 14.698x wall time and 40.117x engine CPU, with 4.063x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| raw-egraph-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| java-egglog | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| java-egglog-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| slotted-egraph | 2228 / 19212 | 11.597% | 0 / 42386 | 0.000% |
| canonical | 4499 / 19212 | 23.418% | 0 / 42386 | 0.000% |
| typed-slotted-port-egraph | 4499 / 19212 | 23.418% | 0 / 42386 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 820 | 4.268% | 43.850 | 4.528 | 249.712 | 547.760 |
| raw-egraph-debruijn | 2160 | 11.243% | 112.324 | 11.579 | 524.132 | 1559.105 |
| java-egglog | 820 | 4.268% | 43.067 | 4.476 | 258.240 | 567.780 |
| java-egglog-debruijn | 2160 | 11.243% | 112.617 | 11.561 | 548.320 | 1466.263 |
| slotted-egraph | 2228 | 11.597% | 114.845 | 10.776 | 121.025 | 1199.616 |
| canonical | 4499 | 23.418% | 165.831 | 11.576 | 31.796 | 2177.491 |
| typed-slotted-port-egraph | 4499 | 23.418% | 11.282 | 0.703 | 0.793 | 535.969 |

## Minimum Edit Distance

For the five retained e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The Certificate-Integrated IR obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 16.606 | 12.906 | 18.283 | 14 | 37 |
| raw-egraph-debruijn | 61598 | 16.145 | 12.508 | 17.794 | 14 | 36 |
| java-egglog | 61598 | 16.477 | 12.811 | 18.139 | 14 | 36 |
| java-egglog-debruijn | 61598 | 16.018 | 12.422 | 17.648 | 14 | 36 |
| slotted-egraph | 61598 | 16.324 | 12.638 | 17.995 | 14 | 37 |
| canonical | 61598 | 13.910 | 9.078 | 16.100 | 11 | 34 |
| typed-slotted-port-egraph | 61598 | 13.910 | 9.078 | 16.100 | 11 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the exact typed slotted-port arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.001 | 0.178 | 1.335 |
| raw-egraph-debruijn | 0.001 | 0.165 | 1.334 |
| java-egglog | 0.001 | 0.172 | 1.304 |
| java-egglog-debruijn | 0.001 | 0.175 | 1.304 |
| slotted-egraph | 0.003 | 0.221 | 1.169 |
| canonical | 0.025 | 0.246 | 1.000 |
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
| slotted-egraph -> canonical | 2228 | 2271 | 0 |
| canonical -> typed-slotted-port-egraph | 4499 | 0 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 39.154 | 36.596 | 39.154 | 6453.876 | 38200 |
| raw-egraph-debruijn | 39.142 | 36.604 | 39.142 | 6464.223 | 39776 |
| java-egglog | 38.265 | 35.757 | 38.265 | 6310.699 | 30750 |
| java-egglog-debruijn | 38.250 | 35.761 | 38.250 | 6320.611 | 31990 |
| slotted-egraph | 34.311 | 31.844 | 34.311 | 9465.067 | 41286 |
| canonical | 29.339 | 25.277 | 25.277 | 1877.674 | 12480 |
| typed-slotted-port-egraph | 29.339 | 18.962 | 16.471 | 3436.696 | 17920 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Fast Rewrite IR units retain the repaired canonical-form size; Certificate-Integrated IR units count its normalized finite-unfolding key. E-class and e-node columns for the certificate-integrated arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input [CHECKOUT]/classified-data --output [ARTIFACTS]/egraph_ablation --threads 16 --max-heap 8g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
