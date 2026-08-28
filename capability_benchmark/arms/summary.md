# Alloy E-Graph Ablation

- Generated at: `2026-08-28T09:21:44.585318312Z`
- Run ID: `36c4a62b-6aff-4fe9-a38c-180eeb83fcbf`
- Git SHA: `88363ea23728329948ccc9d5cdad690cc5787ca5` (dirty: false)
- Dataset SHA-256: `898d8123ce12ee9a28cb106b801c4d3cb9e1c8aaa2644e0389aedd41e6fb49c3`
- Input root: `/home/augustus/acgn-publication-v2.1-20260828T064537Z/capability_benchmark/models`
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
| raw-egraph | 5500 / 5500 | 0 | 2585 | 2.500 | 2.368 | 2322.860 | 31.220 | 1.133 | 1.190 | 0.216 | 0.091 | 0.752 | 471.100 | 1031.371 | 10.841 |
| raw-egraph-debruijn | 5500 / 5500 | 0 | 3628 | 2.480 | 2.346 | 2344.872 | 33.820 | 1.374 | 1.475 | 0.268 | 0.099 | 1.108 | 441.140 | 1034.008 | 10.131 |
| java-egglog | 5500 / 5500 | 0 | 2585 | 2.450 | 2.311 | 2380.411 | 32.200 | 0.851 | 0.909 | 0.165 | 0.085 | 0.521 | 478.954 | 1013.395 | 9.679 |
| java-egglog-debruijn | 5500 / 5500 | 0 | 3628 | 2.520 | 2.391 | 2300.521 | 32.600 | 1.080 | 1.159 | 0.211 | 0.085 | 0.669 | 382.957 | 966.707 | 8.974 |
| slotted-egraph | 5500 / 5500 | 0 | 5500 | 2.550 | 2.422 | 2270.604 | 35.620 | 1.659 | 1.793 | 0.326 | 0.181 | 0.720 | 509.559 | 1076.223 | 12.613 |
| canonical | 5500 / 5500 | 0 | 5500 | 3.620 | 3.475 | 1582.874 | 65.240 | 20.067 | 25.123 | 4.568 | 2.797 | 12.637 | 693.113 | 1448.234 | 2.068 |
| typed-slotted-port-egraph | 5500 / 5500 | 0 | 5500 | 316.630 | 316.321 | 17.387 | 5206.020 | 4751.857 | 5029.141 | 914.389 | 658.969 | 2687.625 | 6869.241 | 8842.340 | 4.293 |

## Observations

- De Bruijn storage adds 1043 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1043 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 1872 pairs over the De Bruijn egglog arm, with 0 losses.
- The Fast Rewrite IR adds 0 zeroes over slotted storage and loses 0.
- The Certificate-Integrated IR adds 0 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.035% of engine CPU time and 12.171% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 87.467x wall time and 236.803x engine CPU, with 6.106x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

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
| raw-egraph | 2585 | 47.000% | 1034.000 | 82.799 | 2281.686 | 2566.525 |
| raw-egraph-debruijn | 3628 | 65.964% | 1462.903 | 107.274 | 2639.944 | 3592.886 |
| java-egglog | 2585 | 47.000% | 1055.102 | 80.280 | 3038.856 | 2612.053 |
| java-egglog-debruijn | 3628 | 65.964% | 1439.683 | 111.288 | 3359.824 | 3843.017 |
| slotted-egraph | 5500 | 100.000% | 2156.863 | 154.408 | 3315.387 | 5233.118 |
| canonical | 5500 | 100.000% | 1519.337 | 84.304 | 274.086 | 3888.873 |
| typed-slotted-port-egraph | 5500 | 100.000% | 17.370 | 1.056 | 1.157 | 636.935 |

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
| raw-egraph | 0.000 | 0.117 | 2.057 |
| raw-egraph-debruijn | 0.000 | 0.117 | 1.931 |
| java-egglog | 0.000 | 0.115 | 1.831 |
| java-egglog-debruijn | 0.000 | 0.109 | 1.707 |
| slotted-egraph | 0.000 | 0.122 | 1.471 |
| canonical | 0.004 | 0.164 | 1.000 |
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
./scripts/run_egraph_ablation.sh --input /home/augustus/acgn-publication-v2.1-20260828T064537Z/capability_benchmark/models --output /home/augustus/acgn-publication-v2.1-20260828T064537Z/capability_benchmark/arms --threads 16 --max-heap 8g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
