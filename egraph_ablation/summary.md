# Alloy E-Graph Ablation

- Generated at: `2026-08-07T15:31:50.056089612Z`
- Input root: `classified-data`
- Predicate-pair limit: full corpus
- Threads per arm: 32
- JVM heap cap per arm: `12g`
- Java: `17.0.19`

## Arms

1. **Raw e-graph:** exact Alloy AST constructors, union-find, and hash-consing only.
2. **Java egglog core:** the raw terms plus union facts, semi-naive rule rounds, and congruence rebuilding. This is a Java replica of the egglog execution core used here, not a textual-language-compatible port of every egglog feature.
3. **Slotted e-graph:** the same raw terms and rules represented as shape-hash-consed renamed eclass invocations with exposed slots, slot redundancy, and finite permutation groups.
4. **Canonical:** the current method, adding temporal-phase partitioning, connective elimination, strict per-phase prenexing, primitive binding tuples, and canonical variadic matrices.

## Runtime And Memory

Each arm ran in a fresh JVM. Wall time and maximum RSS come from `/usr/bin/time -v`; peak used heap is sampled every 10 ms inside that JVM. Engine CPU time is the sum of timed representation construction, saturation, and comparison across worker tasks, excluding parsing.

| Arm | Successful / files | Equivalent pairs | Process wall s | Dataset wall s | Pairs/s | Engine CPU s | Avg engine ms | P50 ms | P95 ms | Peak heap MiB | Max RSS MiB | Avg structural KiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 66080 / 66080 | 4482 | 16.320 | 15.893 | 4157.731 | 1.609 | 0.024 | 0.013 | 0.029 | 909.708 | 1766.219 | 4.743 |
| java-egglog | 66080 / 66080 | 5259 | 16.430 | 16.014 | 4126.303 | 4.566 | 0.069 | 0.040 | 0.122 | 873.881 | 1630.777 | 8.420 |
| slotted-egraph | 66080 / 66080 | 6574 | 16.890 | 16.471 | 4011.836 | 13.622 | 0.206 | 0.093 | 0.582 | 821.730 | 1565.684 | 12.599 |
| canonical | 66080 / 66080 | 6662 | 21.740 | 21.018 | 3144.000 | 87.676 | 1.327 | 0.696 | 2.760 | 9169.852 | 11011.152 | 1.738 |

## Observations

- Egglog-style saturation adds 777 zero-distance pairs over raw hash-consing, with 0 losses.
- Slot-aware shapes add 1315 pairs over the egglog arm, with 0 losses.
- The current canonical method is a strict superset of the slotted arm on this corpus: it adds 88 zeroes and loses 0. Its zero set contains 0 predicates labeled incorrect; the slotted arm contains 0.
- Relative to the full method, the slotted arm uses 15.537% of engine CPU time and 14.219% of maximum RSS. End-to-end wall time is parser-dominated.

## Agreement With Dataset Labels

`Equivalent` means eclass equality or canonical distance zero; it is not an additional SAT proof. The dataset's `CORRECT` label is the positive semantic-equivalence class, and every other status is negative.

| Arm | CORRECT zero / CORRECT | CORRECT coverage | Incorrect zero / incorrect | Incorrect zero rate |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 4482 / 23694 | 18.916% | 0 / 42386 | 0.000% |
| java-egglog | 5259 / 23694 | 22.195% | 0 / 42386 | 0.000% |
| slotted-egraph | 6574 / 23694 | 27.745% | 0 / 42386 | 0.000% |
| canonical | 6662 / 23694 | 28.117% | 0 / 42386 | 0.000% |

## Minimum Edit Distance

For the three e-graph baselines, this is the minimum unit-cost rooted-tree edit distance over concrete root witnesses retained during saturation; slotted witnesses are normalized under alpha-renaming and declaration permutation groups. Eclass equality has distance zero. The canonical arm uses the production canonical edit distance.

| Arm | Pairs | All avg | CORRECT avg | Incorrect avg | P50 | P95 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 66080 | 21.288 | 14.517 | 25.073 | 19 | 50 |
| java-egglog | 66080 | 17.419 | 11.760 | 20.583 | 15 | 42 |
| slotted-egraph | 66080 | 17.178 | 11.565 | 20.315 | 15 | 42 |
| canonical | 66080 | 12.880 | 7.773 | 15.734 | 11 | 33 |

## Relative To Full Method

Ratios below use engine CPU time and maximum RSS; values below 1 use less than the current full canonical arm.

| Arm | Engine CPU ratio | Max RSS ratio | Representation-unit ratio |
| --- | ---: | ---: | ---: |
| raw-egraph | 0.018 | 0.160 | 1.051 |
| java-egglog | 0.052 | 0.148 | 1.881 |
| slotted-egraph | 0.155 | 0.142 | 1.714 |
| canonical | 1.000 | 1.000 | 1.000 |

## Pair-Level Transitions

These counts make clear whether each successive arm is a strict extension on this corpus.

| Transition | Retained zeroes | Newly zero | No longer zero |
| --- | ---: | ---: | ---: |
| raw-egraph -> java-egglog | 4482 | 777 | 0 |
| java-egglog -> slotted-egraph | 5259 | 1315 | 0 |
| slotted-egraph -> canonical | 6574 | 88 | 0 |

## Representation

| Arm | Avg units | Avg eclasses | Avg enodes | Avg estimated bytes | Peak estimated bytes |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 29.242 | 29.242 | 29.242 | 4856.848 | 16630 |
| java-egglog | 52.312 | 49.965 | 52.312 | 8622.126 | 36418 |
| slotted-egraph | 47.680 | 45.549 | 47.680 | 12901.865 | 54826 |
| canonical | 27.813 | n/a | n/a | 1780.034 | 10240 |

The structural byte count is an implementation-level estimate for graph objects; Max RSS is the primary measured memory result. Canonical representation units are the existing canonical-form size, while the three baseline units are retained e-nodes.

## Reproduce

```bash
./scripts/run_egraph_ablation.sh --input classified-data --output egraph_ablation --threads 32 --max-heap 12g
```

Use `--limit N` for a smoke run. Use `--report-only` to regenerate the combined JSON, disagreement CSV, and Markdown from retained per-arm files without rerunning the engines.
