# Targeted Equivalence Capability Benchmark

- Generated at: `2026-11-26T10:08:25.485793511Z`
- RNG seed: `55520260811`
- Valid, parser-AST-different pairs: 5500
- Ground truth: equivalence by construction using only the implemented rule set
- Seed source: zero-parameter predicates from Alloy4Fun `CORRECT` folders

Dataset labels and generated ground truth are distinct: `CORRECT` is used only to select real seed predicates; benchmark equivalence follows from each recorded transformation and side condition.

## Recovery By Family

| Transformation family | raw-egraph | raw-egraph-debruijn | java-egglog | java-egglog-debruijn | slotted-egraph | canonical | typed-slotted-port-egraph |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Alpha-equivalence | 0/500 (0.00%) | 500/500 (100.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Associativity / commutativity / idempotence | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Binder-block permutations | 1/500 (0.20%) | 22/500 (4.40%) | 1/500 (0.20%) | 22/500 (4.40%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Safe prenex transformations | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Negation / logical normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Temporal normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: alpha + AC | 0/500 (0.00%) | 500/500 (100.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: alpha + binder permutation | 0/500 (0.00%) | 22/500 (4.40%) | 0/500 (0.00%) | 22/500 (4.40%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: binder permutation + prenex | 22/500 (4.40%) | 22/500 (4.40%) | 22/500 (4.40%) | 22/500 (4.40%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: AC + logical normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: mixed 2-4 transformations | 62/500 (12.40%) | 62/500 (12.40%) | 62/500 (12.40%) | 62/500 (12.40%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| All composed families | 584/2500 (23.36%) | 1106/2500 (44.24%) | 584/2500 (23.36%) | 1106/2500 (44.24%) | 2500/2500 (100.00%) | 2500/2500 (100.00%) | 2500/2500 (100.00%) |
| All families | 2585/5500 (47.00%) | 3628/5500 (65.96%) | 2585/5500 (47.00%) | 3628/5500 (65.96%) | 5500/5500 (100.00%) | 5500/5500 (100.00%) | 5500/5500 (100.00%) |

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
| Composed: AC + logical normalization | raw-egraph | raw-egraph | yes | 0 |
| Composed: mixed 2-4 transformations | slotted-egraph | slotted-egraph | yes | 0 |

## Natural-Corpus Context

The generated benchmark isolates specific capabilities; the natural corpus reflects their observed mixture and prevalence.

| Arm | Successful pairs | CORRECT zero coverage | Incorrect zeroes | Avg distance |
| --- | ---: | ---: | ---: | ---: |
| raw-egraph | 61598 | 820 / 19212 (4.27%) | 0 | 16.606172 |
| raw-egraph-debruijn | 61598 | 2160 / 19212 (11.24%) | 0 | 16.145346 |
| java-egglog | 61598 | 820 / 19212 (4.27%) | 0 | 16.476882 |
| java-egglog-debruijn | 61598 | 2160 / 19212 (11.24%) | 0 | 16.017825 |
| slotted-egraph | 61598 | 2228 / 19212 (11.60%) | 0 | 16.324296 |
| canonical | 61598 | 4499 / 19212 (23.42%) | 0 | 13.909932 |
| typed-slotted-port-egraph | 61598 | 4499 / 19212 (23.42%) | 0 | 13.909932 |

## Bounded Soundness Sanity Check

- Sampled family/subtype cases: 29
- Conclusive failures: 0
- Completed bounded temporal checks: 8
- Inconclusive checks: 0
- Raw solver-reported counterexamples among inconclusive checks: 0

Only completed checks contribute bounded evidence, not semantic proofs. Inconclusive checks remain unresolved; backend notes and per-command bounds are retained in `SOUNDNESS.md` and `soundness.csv`.

## Distance And Cost

Wall time below is aggregate per-pair engine latency; CPU is summed worker-thread CPU. Process RSS belongs to the separate full-corpus ablation.

| Family | Arm | Avg / P50 / P95 distance | Engine CPU s | Aggregate engine wall s | Avg representation units | Avg estimated bytes |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| alpha | raw-egraph | 3.868000 / 4 / 4 | 0.069987 | 0.074121 | 42.930000 | 7175.808000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.056855 | 0.062357 | 28.930000 | 4810.544000 |
| alpha | java-egglog | 3.868000 / 4 / 4 | 0.081610 | 0.084768 | 41.146000 | 6888.700000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.053458 | 0.055182 | 27.322000 | 4547.092000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.273232 | 0.292689 | 25.322000 | 6995.740000 |
| alpha | canonical | 0.000000 / 0 / 0 | 8.139917 | 8.456997 | 30.984000 | 1982.976000 |
| alpha | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 52.578186 | 57.231503 | 30.984000 | 3879.616000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.033781 | 0.033904 | 24.282000 | 3963.400000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.036268 | 0.038126 | 24.282000 | 3963.400000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.034976 | 0.036505 | 22.490000 | 3670.512000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.038580 | 0.041023 | 22.490000 | 3670.512000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.075165 | 0.079614 | 20.988000 | 5562.088000 |
| aci | canonical | 0.000000 / 0 / 0 | 4.019449 | 4.328868 | 22.424000 | 1435.136000 |
| aci | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 32.521971 | 35.417525 | 22.424000 | 3158.528000 |
| binder_permutation | raw-egraph | 5.402000 / 4 / 7 | 0.035281 | 0.035414 | 45.000000 | 7441.452000 |
| binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.038056 | 0.038241 | 42.416000 | 7013.592000 |
| binder_permutation | java-egglog | 5.402000 / 4 / 7 | 0.031574 | 0.031840 | 42.220000 | 6991.000000 |
| binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.034438 | 0.035353 | 39.636000 | 6563.140000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.114171 | 0.118037 | 23.364000 | 6574.064000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 1.804536 | 2.372624 | 36.956000 | 2365.184000 |
| binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 79.210951 | 87.860449 | 36.956000 | 4229.504000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.026775 | 0.026846 | 31.302000 | 5104.504000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.030364 | 0.030464 | 32.302000 | 5282.504000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.023012 | 0.023065 | 30.150000 | 4915.836000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.026453 | 0.026513 | 31.150000 | 5093.836000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.051322 | 0.051478 | 27.282000 | 7336.084000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 1.195293 | 1.586861 | 29.788000 | 1906.432000 |
| safe_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 38.665871 | 40.941452 | 29.788000 | 3852.416000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.097314 | 0.099010 | 54.366000 | 8745.900000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.097598 | 0.099427 | 54.698000 | 8804.996000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.068716 | 0.070087 | 43.914000 | 7086.636000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.063471 | 0.064111 | 44.246000 | 7145.732000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.196687 | 0.197530 | 43.900000 | 11520.808000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 1.996845 | 2.375990 | 30.044000 | 1922.816000 |
| logical_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 44.814073 | 48.624216 | 30.044000 | 4005.952000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.036867 | 0.039624 | 47.680000 | 7673.660000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.041935 | 0.042061 | 47.680000 | 7673.660000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.030718 | 0.031388 | 42.552000 | 6853.368000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.036804 | 0.037016 | 42.552000 | 6853.368000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.065755 | 0.067066 | 42.552000 | 10852.136000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 1.485084 | 1.873616 | 29.860000 | 1911.040000 |
| temporal_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 28.422695 | 29.961823 | 29.860000 | 3920.768000 |
| alpha_ac | raw-egraph | 2.752000 / 3 / 3 | 0.046170 | 0.048940 | 43.436000 | 7221.936000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.051418 | 0.054542 | 35.500000 | 5868.192000 |
| alpha_ac | java-egglog | 2.752000 / 3 / 3 | 0.045185 | 0.045857 | 40.278000 | 6713.728000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.047045 | 0.049535 | 32.650000 | 5401.272000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.089297 | 0.093744 | 28.650000 | 7850.112000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 2.237918 | 2.673646 | 34.228000 | 2190.592000 |
| alpha_ac | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 50.662255 | 55.116103 | 34.228000 | 4387.712000 |
| alpha_binder_permutation | raw-egraph | 3.912000 / 4 / 4 | 0.030225 | 0.030308 | 39.018000 | 6470.400000 |
| alpha_binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.043810 | 0.048612 | 36.930000 | 6095.880000 |
| alpha_binder_permutation | java-egglog | 3.912000 / 4 / 4 | 0.031054 | 0.033157 | 37.234000 | 6183.292000 |
| alpha_binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.043517 | 0.043850 | 35.146000 | 5808.772000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.084731 | 0.091663 | 23.366000 | 6484.836000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 1.538548 | 1.935367 | 30.984000 | 1982.976000 |
| alpha_binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 52.120039 | 56.480810 | 30.984000 | 3879.616000 |
| binder_permutation_prenex | raw-egraph | 3.824000 / 4 / 4 | 0.049539 | 0.050004 | 41.754000 | 6874.504000 |
| binder_permutation_prenex | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.057507 | 0.057866 | 39.754000 | 6534.504000 |
| binder_permutation_prenex | java-egglog | 3.824000 / 4 / 4 | 0.042902 | 0.045935 | 39.970000 | 6587.396000 |
| binder_permutation_prenex | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.050710 | 0.050942 | 37.970000 | 6247.396000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.084843 | 0.088750 | 26.322000 | 7306.660000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 2.035034 | 2.372927 | 30.896000 | 1977.344000 |
| binder_permutation_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 52.763955 | 56.798633 | 30.896000 | 3895.616000 |
| ac_logical | raw-egraph | 0.000000 / 0 / 0 | 0.289083 | 0.345434 | 61.436000 | 9846.796000 |
| ac_logical | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.292954 | 0.339084 | 61.436000 | 9846.796000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.208412 | 0.260433 | 45.252000 | 7277.468000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.235537 | 0.308589 | 45.252000 | 7277.468000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.433958 | 0.533279 | 45.252000 | 11819.724000 |
| ac_logical | canonical | 0.000000 / 0 / 0 | 8.962982 | 10.162950 | 25.248000 | 1615.872000 |
| ac_logical | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 42.787857 | 48.514477 | 25.248000 | 3532.672000 |
| mixed | raw-egraph | 3.504000 / 4 / 4 | 0.215629 | 0.218774 | 105.326000 | 17062.340000 |
| mixed | raw-egraph-debruijn | 1.752000 / 2 / 2 | 0.260564 | 0.265035 | 103.326000 | 16722.340000 |
| mixed | java-egglog | 3.504000 / 4 / 4 | 0.108028 | 0.110798 | 77.766000 | 12675.388000 |
| mixed | java-egglog-debruijn | 1.752000 / 2 / 2 | 0.123098 | 0.124692 | 75.766000 | 12335.388000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.192571 | 0.195059 | 65.520000 | 18233.972000 |
| mixed | canonical | 0.000000 / 0 / 0 | 2.117865 | 2.536627 | 37.448000 | 2396.672000 |
| mixed | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 72.845891 | 79.378058 | 37.448000 | 4877.056000 |

## Pair-Level Transitions

| Family | Transition | Retained | Newly zero | No longer zero |
| --- | --- | ---: | ---: | ---: |
| alpha | raw-egraph -> raw-egraph-debruijn | 0 | 500 | 0 |
| alpha | raw-egraph -> java-egglog | 0 | 0 | 0 |
| alpha | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| alpha | java-egglog -> java-egglog-debruijn | 0 | 500 | 0 |
| alpha | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| alpha | slotted-egraph -> canonical | 500 | 0 | 0 |
| alpha | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| aci | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| aci | raw-egraph -> java-egglog | 500 | 0 | 0 |
| aci | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| aci | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| aci | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| aci | slotted-egraph -> canonical | 500 | 0 | 0 |
| aci | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| binder_permutation | raw-egraph -> raw-egraph-debruijn | 1 | 21 | 0 |
| binder_permutation | raw-egraph -> java-egglog | 1 | 0 | 0 |
| binder_permutation | raw-egraph-debruijn -> java-egglog-debruijn | 22 | 0 | 0 |
| binder_permutation | java-egglog -> java-egglog-debruijn | 1 | 21 | 0 |
| binder_permutation | java-egglog-debruijn -> slotted-egraph | 22 | 478 | 0 |
| binder_permutation | slotted-egraph -> canonical | 500 | 0 | 0 |
| binder_permutation | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| safe_prenex | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| safe_prenex | raw-egraph -> java-egglog | 500 | 0 | 0 |
| safe_prenex | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| safe_prenex | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| safe_prenex | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| safe_prenex | slotted-egraph -> canonical | 500 | 0 | 0 |
| safe_prenex | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| logical_normalization | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| logical_normalization | raw-egraph -> java-egglog | 500 | 0 | 0 |
| logical_normalization | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| logical_normalization | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| logical_normalization | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| logical_normalization | slotted-egraph -> canonical | 500 | 0 | 0 |
| logical_normalization | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| temporal_normalization | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| temporal_normalization | raw-egraph -> java-egglog | 500 | 0 | 0 |
| temporal_normalization | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| temporal_normalization | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| temporal_normalization | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| temporal_normalization | slotted-egraph -> canonical | 500 | 0 | 0 |
| temporal_normalization | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| alpha_ac | raw-egraph -> raw-egraph-debruijn | 0 | 500 | 0 |
| alpha_ac | raw-egraph -> java-egglog | 0 | 0 | 0 |
| alpha_ac | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| alpha_ac | java-egglog -> java-egglog-debruijn | 0 | 500 | 0 |
| alpha_ac | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| alpha_ac | slotted-egraph -> canonical | 500 | 0 | 0 |
| alpha_ac | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| alpha_binder_permutation | raw-egraph -> raw-egraph-debruijn | 0 | 22 | 0 |
| alpha_binder_permutation | raw-egraph -> java-egglog | 0 | 0 | 0 |
| alpha_binder_permutation | raw-egraph-debruijn -> java-egglog-debruijn | 22 | 0 | 0 |
| alpha_binder_permutation | java-egglog -> java-egglog-debruijn | 0 | 22 | 0 |
| alpha_binder_permutation | java-egglog-debruijn -> slotted-egraph | 22 | 478 | 0 |
| alpha_binder_permutation | slotted-egraph -> canonical | 500 | 0 | 0 |
| alpha_binder_permutation | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| binder_permutation_prenex | raw-egraph -> raw-egraph-debruijn | 22 | 0 | 0 |
| binder_permutation_prenex | raw-egraph -> java-egglog | 22 | 0 | 0 |
| binder_permutation_prenex | raw-egraph-debruijn -> java-egglog-debruijn | 22 | 0 | 0 |
| binder_permutation_prenex | java-egglog -> java-egglog-debruijn | 22 | 0 | 0 |
| binder_permutation_prenex | java-egglog-debruijn -> slotted-egraph | 22 | 478 | 0 |
| binder_permutation_prenex | slotted-egraph -> canonical | 500 | 0 | 0 |
| binder_permutation_prenex | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| ac_logical | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| ac_logical | raw-egraph -> java-egglog | 500 | 0 | 0 |
| ac_logical | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| ac_logical | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| ac_logical | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| ac_logical | slotted-egraph -> canonical | 500 | 0 | 0 |
| ac_logical | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |
| mixed | raw-egraph -> raw-egraph-debruijn | 62 | 0 | 0 |
| mixed | raw-egraph -> java-egglog | 62 | 0 | 0 |
| mixed | raw-egraph-debruijn -> java-egglog-debruijn | 62 | 0 | 0 |
| mixed | java-egglog -> java-egglog-debruijn | 62 | 0 | 0 |
| mixed | java-egglog-debruijn -> slotted-egraph | 62 | 438 | 0 |
| mixed | slotted-egraph -> canonical | 500 | 0 | 0 |
| mixed | canonical -> typed-slotted-port-egraph | 500 | 0 | 0 |

## Generation Skips

No generation attempts were skipped.

## Reproduce

```bash
./scripts/run_capability_benchmark.sh --dataset classified-data --output capability_benchmark --target 500 --seed 55520260811
```
