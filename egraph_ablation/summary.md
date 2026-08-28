# Alloy E-Graph Ablation

- Generated at: `2026-08-28T09:15:42.508230022Z`
- Run ID: `6d3cd13e-e9e4-4c8b-984a-7f9842a12707`
- Git SHA: `88363ea23728329948ccc9d5cdad690cc5787ca5` (dirty: false)
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
| raw-egraph | 61598 / 61598 | 4482 | 820 | 18.930 | 18.501 | 3329.473 | 184.290 | 4.345 | 4.473 | 0.073 | 0.049 | 0.165 | 733.097 | 1434.855 | 9.335 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2160 | 19.060 | 18.614 | 3309.280 | 188.940 | 5.087 | 5.234 | 0.085 | 0.056 | 0.202 | 774.353 | 1501.480 | 9.286 |
| java-egglog | 61598 / 61598 | 4482 | 820 | 19.210 | 18.775 | 3280.875 | 185.540 | 4.108 | 4.235 | 0.069 | 0.047 | 0.147 | 724.132 | 1431.375 | 9.176 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2160 | 19.260 | 18.813 | 3274.309 | 187.280 | 4.871 | 5.035 | 0.082 | 0.054 | 0.176 | 816.447 | 1598.816 | 9.126 |
| slotted-egraph | 61598 / 61598 | 4482 | 2159 | 19.340 | 18.912 | 3257.148 | 201.080 | 15.336 | 15.851 | 0.257 | 0.111 | 1.019 | 772.260 | 1509.496 | 14.066 |
| canonical | 61598 / 61598 | 4482 | 4074 | 24.710 | 24.289 | 2536.042 | 289.260 | 72.573 | 103.144 | 1.674 | 1.285 | 3.651 | 929.797 | 1837.043 | 1.875 |
| typed-slotted-port-egraph | 61598 / 61598 | 4482 | 4088 | 2708.920 | 2708.318 | 22.744 | 44065.660 | 41253.576 | 43159.822 | 700.669 | 318.125 | 2348.612 | 7212.730 | 8947.977 | 3.295 |

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 2 pairs over the De Bruijn egglog arm, with 3 losses.
- The Fast Rewrite IR adds 1915 zeroes over slotted storage and loses 0.
- The Certificate-Integrated IR adds 14 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.037% of engine CPU time and 16.870% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 109.628x wall time and 568.441x engine CPU, with 4.871x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

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
| raw-egraph | 820 | 4.268% | 43.317 | 4.450 | 188.704 | 585.202 |
| raw-egraph-debruijn | 2160 | 11.243% | 113.326 | 11.432 | 424.580 | 1473.106 |
| java-egglog | 820 | 4.268% | 42.686 | 4.420 | 199.587 | 586.625 |
| java-egglog-debruijn | 2160 | 11.243% | 112.150 | 11.534 | 443.416 | 1383.423 |
| slotted-egraph | 2159 | 11.238% | 111.634 | 10.737 | 140.782 | 1464.605 |
| canonical | 4074 | 21.205% | 164.873 | 14.084 | 56.136 | 2270.919 |
| typed-slotted-port-egraph | 4088 | 21.278% | 1.509 | 0.093 | 0.099 | 467.828 |

## Minimum Edit Distance

For the five retained e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The Certificate-Integrated IR obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 18.364 | 14.177 | 20.262 | 16 | 42 |
| raw-egraph-debruijn | 61598 | 17.911 | 13.781 | 19.783 | 15 | 41 |
| java-egglog | 61598 | 18.147 | 14.047 | 20.005 | 15 | 41 |
| java-egglog-debruijn | 61598 | 17.690 | 13.653 | 19.520 | 15 | 40 |
| slotted-egraph | 61598 | 17.824 | 13.764 | 19.665 | 15 | 41 |
| canonical | 61598 | 13.939 | 9.091 | 16.136 | 12 | 35 |
| typed-slotted-port-egraph | 61598 | 14.022 | 9.175 | 16.219 | 12 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the exact typed slotted-port arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.000 | 0.160 | 1.966 |
| raw-egraph-debruijn | 0.000 | 0.168 | 1.955 |
| java-egglog | 0.000 | 0.160 | 1.931 |
| java-egglog-debruijn | 0.000 | 0.179 | 1.920 |
| slotted-egraph | 0.000 | 0.169 | 1.800 |
| canonical | 0.002 | 0.205 | 1.016 |
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
./scripts/run_egraph_ablation.sh --input /home/augustus/ACGN/classified-data --output /home/augustus/acgn-publication-v2.1-20260828T064537Z/egraph_ablation --threads 16 --max-heap 8g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
