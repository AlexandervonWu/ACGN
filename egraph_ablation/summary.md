# Alloy E-Graph Ablation

- Generated at: `2026-08-29T23:24:05.167978286Z`
- Run ID: `f46b5647-7373-4cd7-ac3d-f8fd9b802db6`
- Git SHA: `fbd9b1497a9036c55780da777f56581bc1c6bcec` (dirty: false)
- Dataset SHA-256: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Input root: `/home/augustus/ACGN/classified-data`
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
| raw-egraph | 61598 / 61598 | 4482 | 820 | 19.440 | 19.015 | 3239.524 | 191.390 | 4.335 | 4.475 | 0.073 | 0.048 | 0.163 | 768.877 | 1485.313 | 9.335 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2160 | 19.440 | 18.997 | 3242.506 | 189.760 | 5.292 | 5.485 | 0.089 | 0.058 | 0.208 | 758.824 | 1491.105 | 9.286 |
| java-egglog | 61598 / 61598 | 4482 | 820 | 19.010 | 18.566 | 3317.706 | 186.150 | 4.099 | 4.264 | 0.069 | 0.047 | 0.146 | 813.645 | 1608.297 | 9.176 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2160 | 19.090 | 18.635 | 3305.541 | 188.430 | 5.010 | 5.232 | 0.085 | 0.057 | 0.189 | 857.351 | 1647.250 | 9.126 |
| slotted-egraph | 61598 / 61598 | 4482 | 2159 | 19.300 | 18.858 | 3266.350 | 200.960 | 16.389 | 16.937 | 0.275 | 0.119 | 1.049 | 930.996 | 1772.973 | 14.066 |
| canonical | 61598 / 61598 | 4482 | 4074 | 23.860 | 23.451 | 2626.617 | 296.040 | 73.605 | 101.532 | 1.648 | 1.247 | 3.581 | 906.640 | 1840.508 | 1.875 |
| typed-slotted-port-egraph | 61598 / 61598 | 4482 | 4088 | 2775.650 | 2775.049 | 22.197 | 45118.210 | 42224.753 | 44215.687 | 717.810 | 324.876 | 2414.924 | 7153.183 | 8912.141 | 3.295 |

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 2 pairs over the De Bruijn egglog arm, with 3 losses.
- The Fast Rewrite IR adds 1915 zeroes over slotted storage and loses 0.
- The Certificate-Integrated IR adds 14 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.039% of engine CPU time and 19.894% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 116.331x wall time and 573.666x engine CPU, with 4.842x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| raw-egraph-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| java-egglog | 820 / 19212 | 4.268% | 0 / 42386 | 0.000% |
| java-egglog-debruijn | 2160 / 19212 | 11.243% | 0 / 42386 | 0.000% |
| slotted-egraph | 2159 / 19212 | 11.238% | 0 / 42386 | 0.000% |
| canonical | 4074 / 19212 | 21.205% | 0 / 42386 | 0.000% |
| typed-slotted-port-egraph | 4088 / 19212 | 21.278% | 0 / 42386 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 820 | 4.268% | 42.181 | 4.284 | 189.154 | 565.322 |
| raw-egraph-debruijn | 2160 | 11.243% | 111.111 | 11.383 | 408.131 | 1483.356 |
| java-egglog | 820 | 4.268% | 43.135 | 4.405 | 200.071 | 522.093 |
| java-egglog-debruijn | 2160 | 11.243% | 113.148 | 11.463 | 431.160 | 1342.747 |
| slotted-egraph | 2159 | 11.238% | 111.865 | 10.743 | 131.737 | 1246.954 |
| canonical | 4074 | 21.205% | 170.746 | 13.762 | 55.349 | 2266.644 |
| typed-slotted-port-egraph | 4088 | 21.278% | 1.473 | 0.091 | 0.097 | 469.709 |

## Minimum Edit Distance

For the five retained e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The Certificate-Integrated IR obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 18.364 | 14.177 | 20.262 | 16 | 42 |
| raw-egraph-debruijn | 61598 | 17.911 | 13.781 | 19.783 | 15 | 41 |
| java-egglog | 61598 | 18.147 | 14.047 | 20.005 | 15 | 41 |
| java-egglog-debruijn | 61598 | 17.690 | 13.653 | 19.520 | 15 | 40 |
| slotted-egraph | 61598 | 17.824 | 13.764 | 19.665 | 15 | 41 |
| canonical | 61598 | 13.943 | 9.092 | 16.142 | 12 | 35 |
| typed-slotted-port-egraph | 61598 | 14.022 | 9.175 | 16.219 | 12 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the exact typed slotted-port arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.000 | 0.167 | 1.966 |
| raw-egraph-debruijn | 0.000 | 0.167 | 1.955 |
| java-egglog | 0.000 | 0.180 | 1.931 |
| java-egglog-debruijn | 0.000 | 0.185 | 1.920 |
| slotted-egraph | 0.000 | 0.199 | 1.800 |
| canonical | 0.002 | 0.207 | 1.016 |
| typed-slotted-port-egraph | 1.000 | 1.000 | 1.000 |

## Pair-Level Transitions

These edges isolate variable encoding, variadic representation, slots, and the full method.

| Transition | Retained zeroes | Newly zero | No longer zero |
| --- | ---: | ---: | ---: |
| raw-egraph -> raw-egraph-debruijn | 820 | 1340 | 0 |
| raw-egraph -> java-egglog | 820 | 0 | 0 |
| raw-egraph-debruijn -> java-egglog-debruijn | 2160 | 0 | 0 |
| java-egglog -> java-egglog-debruijn | 820 | 1340 | 0 |
| java-egglog-debruijn -> slotted-egraph | 2157 | 2 | 3 |
| slotted-egraph -> canonical | 2159 | 1915 | 0 |
| canonical -> typed-slotted-port-egraph | 4074 | 14 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 58.073 | 55.333 | 58.073 | 9559.125 | 48816 |
| raw-egraph-debruijn | 57.752 | 55.032 | 57.752 | 9508.509 | 50392 |
| java-egglog | 57.055 | 54.365 | 57.055 | 9395.913 | 39806 |
| java-egglog-debruijn | 56.732 | 54.062 | 56.732 | 9344.861 | 41046 |
| slotted-egraph | 53.168 | 50.511 | 53.168 | 14403.897 | 60214 |
| canonical | 30.001 | 25.489 | 25.506 | 1920.033 | 13440 |
| typed-slotted-port-egraph | 29.541 | 18.443 | 16.148 | 3373.664 | 16496 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Fast Rewrite IR units retain the repaired canonical-form size; Certificate-Integrated IR units count its normalized finite-unfolding key. E-class and e-node columns for the certificate-integrated arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input /home/augustus/ACGN/classified-data --output /home/augustus/acgn-codex-supervised-20260829T205326Z/run/egraph_ablation --threads 16 --max-heap 8g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
