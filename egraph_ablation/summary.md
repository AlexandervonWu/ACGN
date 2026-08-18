# Alloy E-Graph Ablation

- Generated at: `2026-08-18T12:00:39.761544414Z`
- Run ID: `c48a105a-796c-483c-9f75-7e3a35ff1db0`
- Git SHA: `6d409311a0962d90eb5f97fd1b1ec3d0cd040697` (dirty: true)
- Dataset SHA-256: `d6741fbf4c4a9b3714d012d068f84cc918052f1f55211bf4d0443b990736a689`
- Input root: `/home/augustus/ACGN/classified-data`
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
| raw-egraph | 61598 / 61598 | 4482 | 823 | 16.390 | 15.969 | 3857.347 | 181.760 | 4.510 | 5.072 | 0.082 | 0.049 | 0.169 | 490.842 | 1016.941 | 9.353 |
| raw-egraph-debruijn | 61598 / 61598 | 4482 | 2163 | 16.830 | 16.424 | 3750.574 | 185.250 | 5.363 | 6.006 | 0.098 | 0.055 | 0.205 | 579.966 | 1166.605 | 9.303 |
| java-egglog | 61598 / 61598 | 4482 | 823 | 16.600 | 16.159 | 3811.880 | 181.280 | 4.107 | 4.606 | 0.075 | 0.046 | 0.141 | 538.066 | 1093.113 | 9.125 |
| java-egglog-debruijn | 61598 / 61598 | 4482 | 2163 | 17.050 | 16.618 | 3706.790 | 187.840 | 5.077 | 5.653 | 0.092 | 0.056 | 0.188 | 492.710 | 1007.789 | 9.074 |
| slotted-egraph | 61598 / 61598 | 4482 | 2162 | 17.010 | 16.589 | 3713.094 | 198.890 | 14.504 | 16.361 | 0.266 | 0.115 | 0.952 | 531.365 | 1090.402 | 14.017 |
| canonical | 61598 / 61598 | 4482 | 2316 | 18.360 | 17.835 | 3453.811 | 230.820 | 13.107 | 15.992 | 0.260 | 0.165 | 0.475 | 3173.017 | 3989.914 | 1.865 |
| typed-slotted-port-egraph | 61598 / 61598 | 4482 | 2317 | 2265.990 | 2265.466 | 27.190 | 64841.260 | 52088.164 | 72008.635 | 1169.009 | 543.022 | 4351.800 | 3911.482 | 4671.211 | 3.743 |

## Observations

- De Bruijn storage adds 1340 zero-distance pairs to the fixed-arity arm, with 0 losses.
- Variadic egglog encoding adds 0 zero-distance pairs over the fixed-arity e-graph, with 0 losses.
- De Bruijn storage adds 1340 zero-distance pairs to the variadic egglog arm, with 0 losses.
- Under De Bruijn storage, variadic egglog encoding adds 0 pairs over the fixed-arity arm, with 0 losses.
- Slot-aware shapes add 2 pairs over the De Bruijn egglog arm, with 3 losses.
- The Fast Rewrite IR adds 154 zeroes over slotted storage and loses 0.
- The Certificate-Integrated IR adds 1 zeroes over the Fast Rewrite IR and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 0.028% of engine CPU time and 23.343% of maximum RSS. End-to-end wall time is parser-dominated.

## Implementation Tradeoff

The Fast Rewrite IR directly executes the repaired temporal/prenex rewrite system and established metric for high-throughput corpus analysis. The Certificate-Integrated IR checks typed ports, law provenance, binder automorphisms, congruence quiescence, and graph invariants before accepting equality. It therefore provides a stronger fail-closed semantic-assurance boundary while preserving the same repair objective.

On this run, certificate integration costs 123.420x wall time and 3974.092x engine CPU, with 1.171x maximum RSS. The Fast Rewrite IR remains an active artifact path for broad experiments; the Certificate-Integrated IR is the audit path when certified admissibility matters more than throughput. Dataset labels and bounded solver checks are empirical evidence, not an unbounded semantic proof.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 823 / 19212 | 4.284% | 0 / 42386 | 0.000% |
| raw-egraph-debruijn | 2163 / 19212 | 11.259% | 0 / 42386 | 0.000% |
| java-egglog | 823 / 19212 | 4.284% | 0 / 42386 | 0.000% |
| java-egglog-debruijn | 2163 / 19212 | 11.259% | 0 / 42386 | 0.000% |
| slotted-egraph | 2162 / 19212 | 11.253% | 0 / 42386 | 0.000% |
| canonical | 2316 / 19212 | 12.055% | 0 / 42386 | 0.000% |
| typed-slotted-port-egraph | 2317 / 19212 | 12.060% | 0 / 42386 | 0.000% |

## Equivalent Discovery Efficiency

A found semantic equivalent is a zero-distance pair carrying the dataset's SAT-validated `CORRECT` label. Rates therefore exclude zero-distance pairs from incorrect classes.

| Arm | Found equivalents | CORRECT coverage | Found / wall s | Found / process CPU s | Found / engine CPU s | Found / GiB max RSS |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 823 | 4.284% | 50.214 | 4.528 | 182.487 | 828.712 |
| raw-egraph-debruijn | 2163 | 11.259% | 128.520 | 11.676 | 403.325 | 1898.596 |
| java-egglog | 823 | 4.284% | 49.578 | 4.540 | 200.390 | 770.965 |
| java-egglog-debruijn | 2163 | 11.259% | 126.862 | 11.515 | 425.999 | 2197.793 |
| slotted-egraph | 2162 | 11.253% | 127.102 | 10.870 | 149.060 | 2030.340 |
| canonical | 2316 | 12.055% | 126.144 | 10.034 | 176.700 | 594.395 |
| typed-slotted-port-egraph | 2317 | 12.060% | 1.023 | 0.036 | 0.044 | 507.921 |

## Minimum Edit Distance

For the five retained e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups, while the two De Bruijn arms index bound variables before e-graph storage and distance. Eclass equality has distance zero. Both canonical arms use the established repair metric. The Certificate-Integrated IR obtains admissible scope and operator alignments from the certified semantic artifact; normalized finite-unfolding keys define equality but are not edited to obtain distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 18.390 | 14.173 | 20.302 | 16 | 42 |
| raw-egraph-debruijn | 61598 | 17.923 | 13.771 | 19.805 | 15 | 42 |
| java-egglog | 61598 | 17.996 | 13.975 | 19.819 | 15 | 41 |
| java-egglog-debruijn | 61598 | 17.530 | 13.576 | 19.322 | 15 | 40 |
| slotted-egraph | 61598 | 17.694 | 13.709 | 19.500 | 15 | 40 |
| canonical | 61598 | 14.029 | 9.361 | 16.145 | 12 | 34 |
| typed-slotted-port-egraph | 61598 | 14.042 | 9.363 | 16.163 | 12 | 34 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the exact typed slotted-port arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.000 | 0.218 | 1.950 |
| raw-egraph-debruijn | 0.000 | 0.250 | 1.940 |
| java-egglog | 0.000 | 0.234 | 1.902 |
| java-egglog-debruijn | 0.000 | 0.216 | 1.891 |
| slotted-egraph | 0.000 | 0.233 | 1.775 |
| canonical | 0.000 | 0.854 | 1.000 |
| typed-slotted-port-egraph | 1.000 | 1.000 | 1.000 |

## Pair-Level Transitions

These edges isolate variable encoding, variadic representation, slots, and the full method.

| Transition | Retained zeroes | Newly zero | No longer zero |
| --- | ---: | ---: | ---: |
| raw-egraph -> raw-egraph-debruijn | 823 | 1340 | 0 |
| raw-egraph -> java-egglog | 823 | 0 | 0 |
| raw-egraph-debruijn -> java-egglog-debruijn | 2163 | 0 | 0 |
| java-egglog -> java-egglog-debruijn | 823 | 1340 | 0 |
| java-egglog-debruijn -> slotted-egraph | 2160 | 2 | 3 |
| slotted-egraph -> canonical | 2162 | 154 | 0 |
| canonical -> typed-slotted-port-egraph | 2316 | 1 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 58.184 | 55.445 | 58.184 | 9577.116 | 49152 |
| raw-egraph-debruijn | 57.865 | 55.145 | 57.865 | 9526.746 | 50728 |
| java-egglog | 56.740 | 54.051 | 56.740 | 9344.246 | 39830 |
| java-egglog-debruijn | 56.410 | 53.740 | 56.410 | 9291.928 | 40902 |
| slotted-egraph | 52.952 | 50.294 | 52.952 | 14353.400 | 60310 |
| canonical | 29.843 | 25.022 | 25.173 | 1909.958 | 10112 |
| typed-slotted-port-egraph | 29.830 | 20.935 | 18.059 | 3832.735 | 16336 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Fast Rewrite IR units retain the repaired canonical-form size; Certificate-Integrated IR units count its normalized finite-unfolding key. E-class and e-node columns for the certificate-integrated arm are reachable strict graph counts across both predicates.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input /home/augustus/ACGN/classified-data --output /home/augustus/ACGN/egraph_ablation --threads 32 --max-heap 4g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
