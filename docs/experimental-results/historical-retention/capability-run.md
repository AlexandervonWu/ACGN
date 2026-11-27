# Targeted Equivalence Capability Benchmark

- Generated at: `2026-11-27T04:47:58.676840552Z`
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
| canonical | 61598 | 5137 / 19212 (26.74%) | 0 | 13.470778 |
| typed-slotted-port-egraph | 61598 | 5137 / 19212 (26.74%) | 0 | 13.470778 |

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
| alpha | raw-egraph | 3.868000 / 4 / 4 | 0.084458 | 0.087214 | 42.930000 | 7175.808000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.061010 | 0.064218 | 28.930000 | 4810.544000 |
| alpha | java-egglog | 3.868000 / 4 / 4 | 0.081051 | 0.084473 | 41.146000 | 6888.700000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.048922 | 0.050582 | 27.322000 | 4547.092000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.258744 | 0.269169 | 25.322000 | 6995.740000 |
| alpha | canonical | 0.000000 / 0 / 0 | 8.036970 | 8.289187 | 30.984000 | 1982.976000 |
| alpha | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 50.324181 | 54.811637 | 30.984000 | 3879.616000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.037407 | 0.037578 | 24.282000 | 3963.400000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.034487 | 0.035560 | 24.282000 | 3963.400000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.032571 | 0.034309 | 22.490000 | 3670.512000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.034535 | 0.036454 | 22.490000 | 3670.512000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.073919 | 0.075985 | 20.988000 | 5562.088000 |
| aci | canonical | 0.000000 / 0 / 0 | 3.711448 | 4.004677 | 22.424000 | 1435.136000 |
| aci | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 31.686159 | 34.621185 | 22.424000 | 3153.408000 |
| binder_permutation | raw-egraph | 5.402000 / 4 / 7 | 0.036334 | 0.037289 | 45.000000 | 7441.452000 |
| binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.036134 | 0.036984 | 42.416000 | 7013.592000 |
| binder_permutation | java-egglog | 5.402000 / 4 / 7 | 0.032958 | 0.034728 | 42.220000 | 6991.000000 |
| binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.035760 | 0.037725 | 39.636000 | 6563.140000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.106040 | 0.111014 | 23.364000 | 6574.064000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 1.748309 | 2.089284 | 36.956000 | 2365.184000 |
| binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 75.311024 | 83.677189 | 36.956000 | 4229.504000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.025350 | 0.025497 | 31.302000 | 5104.504000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.027417 | 0.028396 | 32.302000 | 5282.504000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.022491 | 0.022522 | 30.150000 | 4915.836000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.026078 | 0.026113 | 31.150000 | 5093.836000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.051869 | 0.051936 | 27.282000 | 7336.084000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 1.145820 | 1.623559 | 29.788000 | 1906.432000 |
| safe_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 34.763114 | 36.592212 | 29.788000 | 3820.928000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.091407 | 0.091688 | 54.366000 | 8745.900000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.105459 | 0.105629 | 54.698000 | 8804.996000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.053203 | 0.055334 | 43.914000 | 7086.636000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.062904 | 0.063268 | 44.246000 | 7145.732000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.132590 | 0.136721 | 43.900000 | 11520.808000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 2.057021 | 2.438146 | 29.740000 | 1903.360000 |
| logical_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 41.803771 | 45.148726 | 29.740000 | 3967.360000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.038391 | 0.039555 | 47.680000 | 7673.660000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.039411 | 0.039442 | 47.680000 | 7673.660000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.030597 | 0.031728 | 42.552000 | 6853.368000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.032570 | 0.033777 | 42.552000 | 6853.368000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.064508 | 0.064572 | 42.552000 | 10852.136000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 2.395010 | 2.674077 | 29.860000 | 1911.040000 |
| temporal_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 27.022790 | 28.412674 | 29.860000 | 3919.488000 |
| alpha_ac | raw-egraph | 2.752000 / 3 / 3 | 0.046673 | 0.046743 | 43.436000 | 7221.936000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.045598 | 0.046526 | 35.500000 | 5868.192000 |
| alpha_ac | java-egglog | 2.752000 / 3 / 3 | 0.042026 | 0.043827 | 40.278000 | 6713.728000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.043179 | 0.044488 | 32.650000 | 5401.272000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.082269 | 0.092551 | 28.650000 | 7850.112000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 2.224601 | 2.738422 | 34.228000 | 2190.592000 |
| alpha_ac | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 49.480108 | 54.047479 | 34.228000 | 4387.712000 |
| alpha_binder_permutation | raw-egraph | 3.912000 / 4 / 4 | 0.030761 | 0.030971 | 39.018000 | 6470.400000 |
| alpha_binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.039531 | 0.041565 | 36.930000 | 6095.880000 |
| alpha_binder_permutation | java-egglog | 3.912000 / 4 / 4 | 0.028826 | 0.028912 | 37.234000 | 6183.292000 |
| alpha_binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.038896 | 0.039062 | 35.146000 | 5808.772000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.082552 | 0.088706 | 23.366000 | 6484.836000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 1.431997 | 1.891932 | 30.984000 | 1982.976000 |
| alpha_binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 50.025121 | 54.115490 | 30.984000 | 3879.616000 |
| binder_permutation_prenex | raw-egraph | 3.824000 / 4 / 4 | 0.045049 | 0.045167 | 41.754000 | 6874.504000 |
| binder_permutation_prenex | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.052041 | 0.058688 | 39.754000 | 6534.504000 |
| binder_permutation_prenex | java-egglog | 3.824000 / 4 / 4 | 0.042417 | 0.043559 | 39.970000 | 6587.396000 |
| binder_permutation_prenex | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.047391 | 0.048538 | 37.970000 | 6247.396000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.078472 | 0.078575 | 26.322000 | 7306.660000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 1.521958 | 1.856656 | 30.896000 | 1977.344000 |
| binder_permutation_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 48.325602 | 51.868700 | 30.896000 | 3864.128000 |
| ac_logical | raw-egraph | 0.000000 / 0 / 0 | 0.304300 | 0.353093 | 61.436000 | 9846.796000 |
| ac_logical | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.268157 | 0.335484 | 61.436000 | 9846.796000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.186081 | 0.243041 | 45.252000 | 7277.468000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.226032 | 0.276888 | 45.252000 | 7277.468000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.421905 | 0.509684 | 45.252000 | 11819.724000 |
| ac_logical | canonical | 0.000000 / 0 / 0 | 9.188648 | 10.283626 | 25.248000 | 1615.872000 |
| ac_logical | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 42.175809 | 47.289750 | 25.248000 | 3532.672000 |
| mixed | raw-egraph | 3.504000 / 4 / 4 | 0.229056 | 0.234996 | 105.326000 | 17062.340000 |
| mixed | raw-egraph-debruijn | 1.752000 / 2 / 2 | 0.249446 | 0.262063 | 103.326000 | 16722.340000 |
| mixed | java-egglog | 3.504000 / 4 / 4 | 0.096412 | 0.101628 | 77.766000 | 12675.388000 |
| mixed | java-egglog-debruijn | 1.752000 / 2 / 2 | 0.130284 | 0.132583 | 75.766000 | 12335.388000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.199221 | 0.208038 | 65.520000 | 18233.972000 |
| mixed | canonical | 0.000000 / 0 / 0 | 2.063524 | 2.512204 | 37.448000 | 2396.672000 |
| mixed | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 64.939798 | 70.839938 | 37.448000 | 4815.232000 |

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
