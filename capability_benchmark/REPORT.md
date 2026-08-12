# Targeted Equivalence Capability Benchmark

- Generated at: `2026-08-11T23:58:23.742270918Z`
- RNG seed: `55520260811`
- Valid, parser-AST-different pairs: 5500
- Ground truth: equivalence by construction using only the implemented rule set
- Seed source: zero-parameter predicates from Alloy4Fun `CORRECT` folders

Dataset labels and generated ground truth are distinct: `CORRECT` is used only to select real seed predicates; benchmark equivalence follows from each recorded transformation and side condition.

## Recovery By Family

| Transformation family | raw-egraph | raw-egraph-debruijn | java-egglog | java-egglog-debruijn | slotted-egraph | canonical |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Alpha-equivalence | 0/500 (0.00%) | 500/500 (100.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Associativity / commutativity / idempotence | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Binder-block permutations | 0/500 (0.00%) | 0/500 (0.00%) | 0/500 (0.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Safe prenex transformations | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Negation / logical normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Temporal normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: alpha + AC | 0/500 (0.00%) | 500/500 (100.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: alpha + binder permutation | 0/500 (0.00%) | 0/500 (0.00%) | 0/500 (0.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: binder permutation + prenex | 0/500 (0.00%) | 0/500 (0.00%) | 0/500 (0.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: AC + logical normalization | 479/500 (95.80%) | 479/500 (95.80%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: mixed 2-4 transformations | 0/500 (0.00%) | 26/500 (5.20%) | 0/500 (0.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| All composed families | 1979/4000 (49.48%) | 2479/4000 (61.98%) | 2000/4000 (50.00%) | 2500/4000 (62.50%) | 4000/4000 (100.00%) | 4000/4000 (100.00%) |
| All families | 2479/5500 (45.07%) | 3505/5500 (63.73%) | 2500/5500 (45.45%) | 3500/5500 (63.64%) | 5500/5500 (100.00%) | 5500/5500 (100.00%) |

## Expected Capability Boundary

Expectations are annotations only and do not affect generation or evaluation. Observed first means the earliest listed arm with 100% recovery.

| Transformation | Expected first capable | Observed first capable | Match | Failures at expected arm |
| --- | --- | --- | --- | ---: |
| Alpha-equivalence | raw-egraph-debruijn | raw-egraph-debruijn | yes | 0 |
| Associativity / commutativity / idempotence | raw-egraph | raw-egraph | yes | 0 |
| Binder-block permutations | slotted-egraph | slotted-egraph | yes | 0 |
| Safe prenex transformations | raw-egraph | raw-egraph | yes | 0 |
| Negation / logical normalization | raw-egraph | raw-egraph | yes | 0 |
| Temporal normalization | raw-egraph | raw-egraph | yes | 0 |
| Composed: alpha + AC | raw-egraph-debruijn | raw-egraph-debruijn | yes | 0 |
| Composed: alpha + binder permutation | slotted-egraph | slotted-egraph | yes | 0 |
| Composed: binder permutation + prenex | slotted-egraph | slotted-egraph | yes | 0 |
| Composed: AC + logical normalization | raw-egraph | java-egglog | no | 21 |
| Composed: mixed 2-4 transformations | slotted-egraph | slotted-egraph | yes | 0 |

## Natural-Corpus Context

The generated benchmark isolates specific capabilities; the natural corpus reflects their observed mixture and prevalence.

| Arm | Successful pairs | CORRECT zero coverage | Incorrect zeroes | Avg distance |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 823 / 19212 (4.28%) | 0 | 18.415549 |
| raw-egraph-debruijn | 61598 | 2163 / 19212 (11.26%) | 0 | 17.947612 |
| java-egglog | 61598 | 823 / 19212 (4.28%) | 0 | 18.019903 |
| java-egglog-debruijn | 61598 | 2163 / 19212 (11.26%) | 0 | 17.552697 |
| slotted-egraph | 61598 | 2162 / 19212 (11.25%) | 0 | 17.716663 |
| canonical | 61598 | 2235 / 19212 (11.63%) | 0 | 13.540131 |

## Bounded Soundness Sanity Check

- Sampled family/subtype cases: 29
- Conclusive non-temporal failures: 0
- Inconclusive temporal checks: 6
- Raw solver-reported counterexamples among inconclusive checks: 1

The temporal sample is retained but not treated as evidence: this installation has no temporal backend, and Alloy explicitly warns that SAT4J uses a possibly-unsound static reduction. See `SOUNDNESS.md` and `soundness.csv`.

## Distance And Cost

Wall time below is aggregate per-pair engine latency; CPU is summed worker-thread CPU. Process RSS belongs to the separate full-corpus ablation.

| Family | Arm | Avg / P50 / P95 distance | Engine CPU s | Aggregate engine wall s | Avg representation units | Avg estimated bytes |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| alpha | raw-egraph | 4.000000 / 4 / 4 | 0.067462 | 0.074141 | 67.032000 | 11175.024000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.073296 | 0.085041 | 43.846000 | 7244.776000 |
| alpha | java-egglog | 4.000000 / 4 / 4 | 0.072198 | 0.084549 | 65.018000 | 10850.964000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.089820 | 0.108368 | 42.018000 | 6945.316000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.307797 | 0.359860 | 40.018000 | 10843.676000 |
| alpha | canonical | 0.000000 / 0 / 0 | 1.137187 | 1.351016 | 40.864000 | 2615.296000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.036997 | 0.042640 | 34.554000 | 5601.568000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.032343 | 0.032349 | 34.554000 | 5601.568000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.030424 | 0.031427 | 32.184000 | 5214.144000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.032061 | 0.034290 | 32.184000 | 5214.144000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.070375 | 0.078862 | 30.180000 | 7860.440000 |
| aci | canonical | 0.000000 / 0 / 0 | 0.265240 | 0.281253 | 41.472000 | 2654.208000 |
| binder_permutation | raw-egraph | 5.500000 / 4 / 7 | 0.035033 | 0.035043 | 65.032000 | 10761.056000 |
| binder_permutation | raw-egraph-debruijn | 2.000000 / 2 / 2 | 0.038571 | 0.038595 | 61.532000 | 10123.056000 |
| binder_permutation | java-egglog | 5.500000 / 4 / 7 | 0.032235 | 0.033312 | 62.018000 | 10272.996000 |
| binder_permutation | java-egglog-debruijn | 2.000000 / 2 / 2 | 0.037268 | 0.039280 | 58.518000 | 9634.996000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.100435 | 0.100582 | 36.018000 | 9945.708000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 0.200105 | 0.216628 | 46.864000 | 2999.296000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.040571 | 0.040630 | 48.346000 | 7870.432000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.038404 | 0.038411 | 49.346000 | 8048.432000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.024038 | 0.026150 | 47.018000 | 7652.972000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.038054 | 0.038063 | 48.018000 | 7830.972000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.055012 | 0.056141 | 42.018000 | 11143.676000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 0.104097 | 0.118978 | 39.864000 | 2551.296000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.117224 | 0.119725 | 76.844000 | 12339.888000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.161390 | 0.171011 | 77.176000 | 12398.984000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.083761 | 0.086575 | 63.062000 | 10157.968000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.081984 | 0.091804 | 63.394000 | 10217.064000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.149431 | 0.153020 | 63.062000 | 16390.024000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 0.185732 | 0.211115 | 48.192000 | 3084.288000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.039497 | 0.041600 | 64.560000 | 10364.420000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.043106 | 0.045270 | 64.560000 | 10364.420000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.032243 | 0.033247 | 58.370000 | 9377.032000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.036168 | 0.036207 | 58.370000 | 9377.032000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.069182 | 0.070273 | 58.370000 | 14803.496000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 0.101568 | 0.101786 | 42.244000 | 2703.616000 |
| alpha_ac | raw-egraph | 3.000000 / 3 / 3 | 0.062274 | 0.062415 | 66.024000 | 10948.548000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.063908 | 0.064675 | 53.668000 | 8832.740000 |
| alpha_ac | java-egglog | 3.000000 / 3 / 3 | 0.061770 | 0.063535 | 62.084000 | 10314.656000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.061886 | 0.062753 | 50.084000 | 8245.624000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.148425 | 0.154630 | 44.084000 | 11872.792000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 0.221949 | 0.253461 | 55.532000 | 3554.048000 |
| alpha_binder_permutation | raw-egraph | 4.000000 / 4 / 4 | 0.031903 | 0.033382 | 58.032000 | 9621.008000 |
| alpha_binder_permutation | raw-egraph-debruijn | 2.000000 / 2 / 2 | 0.038110 | 0.040113 | 55.032000 | 9039.008000 |
| alpha_binder_permutation | java-egglog | 4.000000 / 4 / 4 | 0.030379 | 0.033344 | 56.018000 | 9296.948000 |
| alpha_binder_permutation | java-egglog-debruijn | 2.000000 / 2 / 2 | 0.052097 | 0.059809 | 53.018000 | 8714.948000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.133242 | 0.140272 | 36.018000 | 9831.660000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 0.190671 | 0.198762 | 40.864000 | 2615.296000 |
| binder_permutation_prenex | raw-egraph | 4.000000 / 4 / 4 | 0.064541 | 0.064624 | 63.032000 | 10379.648000 |
| binder_permutation_prenex | raw-egraph-debruijn | 2.000000 / 2 / 2 | 0.063773 | 0.065015 | 60.032000 | 9817.648000 |
| binder_permutation_prenex | java-egglog | 4.000000 / 4 / 4 | 0.062121 | 0.062165 | 61.018000 | 10055.588000 |
| binder_permutation_prenex | java-egglog-debruijn | 2.000000 / 2 / 2 | 0.062420 | 0.064706 | 58.018000 | 9493.588000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.077440 | 0.079514 | 41.018000 | 11147.652000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 0.147593 | 0.156786 | 40.864000 | 2615.296000 |
| ac_logical | raw-egraph | 0.532000 / 0 / 0 | 0.541801 | 0.845568 | 87.744000 | 14037.396000 |
| ac_logical | raw-egraph-debruijn | 0.532000 / 0 / 0 | 0.422898 | 0.841810 | 87.744000 | 14037.396000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.336276 | 0.643377 | 65.386000 | 10496.396000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.404981 | 0.703969 | 65.386000 | 10496.396000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.714393 | 1.330753 | 65.386000 | 16903.196000 |
| ac_logical | canonical | 0.000000 / 0 / 0 | 1.111994 | 2.226040 | 45.532000 | 2914.048000 |
| mixed | raw-egraph | 4.438000 / 4 / 4 | 3.100731 | 3.263274 | 157.340000 | 25448.192000 |
| mixed | raw-egraph-debruijn | 2.438000 / 2 / 2 | 2.889506 | 3.111219 | 154.184000 | 24860.920000 |
| mixed | java-egglog | 4.000000 / 4 / 4 | 0.295485 | 0.300543 | 119.494000 | 19440.452000 |
| mixed | java-egglog-debruijn | 2.000000 / 2 / 2 | 0.326262 | 0.333235 | 116.494000 | 18878.452000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.230812 | 0.240166 | 100.894000 | 27384.100000 |
| mixed | canonical | 0.000000 / 0 / 0 | 0.179425 | 0.184234 | 59.532000 | 3810.048000 |

## Pair-Level Transitions

| Family | Transition | Retained | Newly zero | No longer zero |
| --- | --- | ---: | ---: | ---: |
| alpha | raw-egraph -> raw-egraph-debruijn | 0 | 500 | 0 |
| alpha | raw-egraph -> java-egglog | 0 | 0 | 0 |
| alpha | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| alpha | java-egglog -> java-egglog-debruijn | 0 | 500 | 0 |
| alpha | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| alpha | slotted-egraph -> canonical | 500 | 0 | 0 |
| aci | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| aci | raw-egraph -> java-egglog | 500 | 0 | 0 |
| aci | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| aci | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| aci | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| aci | slotted-egraph -> canonical | 500 | 0 | 0 |
| binder_permutation | raw-egraph -> raw-egraph-debruijn | 0 | 0 | 0 |
| binder_permutation | raw-egraph -> java-egglog | 0 | 0 | 0 |
| binder_permutation | raw-egraph-debruijn -> java-egglog-debruijn | 0 | 0 | 0 |
| binder_permutation | java-egglog -> java-egglog-debruijn | 0 | 0 | 0 |
| binder_permutation | java-egglog-debruijn -> slotted-egraph | 0 | 500 | 0 |
| binder_permutation | slotted-egraph -> canonical | 500 | 0 | 0 |
| safe_prenex | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| safe_prenex | raw-egraph -> java-egglog | 500 | 0 | 0 |
| safe_prenex | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| safe_prenex | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| safe_prenex | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| safe_prenex | slotted-egraph -> canonical | 500 | 0 | 0 |
| logical_normalization | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| logical_normalization | raw-egraph -> java-egglog | 500 | 0 | 0 |
| logical_normalization | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| logical_normalization | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| logical_normalization | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| logical_normalization | slotted-egraph -> canonical | 500 | 0 | 0 |
| temporal_normalization | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| temporal_normalization | raw-egraph -> java-egglog | 500 | 0 | 0 |
| temporal_normalization | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| temporal_normalization | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| temporal_normalization | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| temporal_normalization | slotted-egraph -> canonical | 500 | 0 | 0 |
| alpha_ac | raw-egraph -> raw-egraph-debruijn | 0 | 500 | 0 |
| alpha_ac | raw-egraph -> java-egglog | 0 | 0 | 0 |
| alpha_ac | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| alpha_ac | java-egglog -> java-egglog-debruijn | 0 | 500 | 0 |
| alpha_ac | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| alpha_ac | slotted-egraph -> canonical | 500 | 0 | 0 |
| alpha_binder_permutation | raw-egraph -> raw-egraph-debruijn | 0 | 0 | 0 |
| alpha_binder_permutation | raw-egraph -> java-egglog | 0 | 0 | 0 |
| alpha_binder_permutation | raw-egraph-debruijn -> java-egglog-debruijn | 0 | 0 | 0 |
| alpha_binder_permutation | java-egglog -> java-egglog-debruijn | 0 | 0 | 0 |
| alpha_binder_permutation | java-egglog-debruijn -> slotted-egraph | 0 | 500 | 0 |
| alpha_binder_permutation | slotted-egraph -> canonical | 500 | 0 | 0 |
| binder_permutation_prenex | raw-egraph -> raw-egraph-debruijn | 0 | 0 | 0 |
| binder_permutation_prenex | raw-egraph -> java-egglog | 0 | 0 | 0 |
| binder_permutation_prenex | raw-egraph-debruijn -> java-egglog-debruijn | 0 | 0 | 0 |
| binder_permutation_prenex | java-egglog -> java-egglog-debruijn | 0 | 0 | 0 |
| binder_permutation_prenex | java-egglog-debruijn -> slotted-egraph | 0 | 500 | 0 |
| binder_permutation_prenex | slotted-egraph -> canonical | 500 | 0 | 0 |
| ac_logical | raw-egraph -> raw-egraph-debruijn | 479 | 0 | 0 |
| ac_logical | raw-egraph -> java-egglog | 479 | 21 | 0 |
| ac_logical | raw-egraph-debruijn -> java-egglog-debruijn | 479 | 21 | 0 |
| ac_logical | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| ac_logical | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| ac_logical | slotted-egraph -> canonical | 500 | 0 | 0 |
| mixed | raw-egraph -> raw-egraph-debruijn | 0 | 26 | 0 |
| mixed | raw-egraph -> java-egglog | 0 | 0 | 0 |
| mixed | raw-egraph-debruijn -> java-egglog-debruijn | 0 | 0 | 26 |
| mixed | java-egglog -> java-egglog-debruijn | 0 | 0 | 0 |
| mixed | java-egglog-debruijn -> slotted-egraph | 0 | 500 | 0 |
| mixed | slotted-egraph -> canonical | 500 | 0 | 0 |

## Generation Skips

No generation attempts were skipped.

## Reproduce

```bash
./scripts/run_capability_benchmark.sh --dataset classified-data --output capability_benchmark --target 500 --seed 55520260811
```
