# Targeted Equivalence Capability Benchmark

- Generated at: `2026-11-21T18:28:07.878715303Z`
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
| canonical | 61598 | 4413 / 19212 (22.97%) | 0 | 13.960405 |
| typed-slotted-port-egraph | 61598 | 4413 / 19212 (22.97%) | 0 | 13.960405 |

## Distance And Cost

Wall time below is aggregate per-pair engine latency; CPU is summed worker-thread CPU. Process RSS belongs to the separate full-corpus ablation.

| Family | Arm | Avg / P50 / P95 distance | Engine CPU s | Aggregate engine wall s | Avg representation units | Avg estimated bytes |
| --- | --- | --- | ---: | ---: | ---: | ---: |
| alpha | raw-egraph | 3.868000 / 4 / 4 | 0.083485 | 0.085641 | 42.930000 | 7175.808000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.067124 | 0.070274 | 28.930000 | 4810.544000 |
| alpha | java-egglog | 3.868000 / 4 / 4 | 0.104599 | 0.109970 | 41.146000 | 6888.700000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.061712 | 0.068782 | 27.322000 | 4547.092000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.235053 | 0.250164 | 25.322000 | 6995.740000 |
| alpha | canonical | 0.000000 / 0 / 0 | 6.395772 | 6.701558 | 30.984000 | 1982.976000 |
| alpha | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 49.201761 | 53.446334 | 30.984000 | 3879.616000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.036355 | 0.041699 | 24.282000 | 3963.400000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.041648 | 0.043920 | 24.282000 | 3963.400000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.041059 | 0.044181 | 22.490000 | 3670.512000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.042937 | 0.048159 | 22.490000 | 3670.512000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.076855 | 0.083802 | 20.988000 | 5562.088000 |
| aci | canonical | 0.000000 / 0 / 0 | 2.942400 | 3.232016 | 22.424000 | 1435.136000 |
| aci | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 29.819901 | 32.089789 | 22.424000 | 3158.528000 |
| binder_permutation | raw-egraph | 5.402000 / 4 / 7 | 0.035542 | 0.035683 | 45.000000 | 7441.452000 |
| binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.040710 | 0.041265 | 42.416000 | 7013.592000 |
| binder_permutation | java-egglog | 5.402000 / 4 / 7 | 0.034267 | 0.034424 | 42.220000 | 6991.000000 |
| binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.041484 | 0.042959 | 39.636000 | 6563.140000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.131873 | 0.135044 | 23.364000 | 6574.064000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 1.548759 | 1.832964 | 36.956000 | 2365.184000 |
| binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 73.983461 | 81.579410 | 36.956000 | 4229.504000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.024205 | 0.024369 | 31.302000 | 5104.504000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.028521 | 0.030204 | 32.302000 | 5282.504000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.023249 | 0.024821 | 30.150000 | 4915.836000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.025644 | 0.025873 | 31.150000 | 5093.836000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.052967 | 0.055213 | 27.282000 | 7336.084000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 0.923573 | 1.266126 | 29.788000 | 1906.432000 |
| safe_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 36.371521 | 38.200508 | 29.788000 | 3852.416000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.107479 | 0.108343 | 54.366000 | 8745.900000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.147061 | 0.151884 | 54.698000 | 8804.996000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.068109 | 0.073993 | 43.914000 | 7086.636000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.081439 | 0.084910 | 44.246000 | 7145.732000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.163971 | 0.170788 | 43.900000 | 11520.808000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 1.691079 | 2.015687 | 30.044000 | 1922.816000 |
| logical_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 41.248749 | 44.225139 | 30.044000 | 4005.952000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.036623 | 0.038479 | 47.680000 | 7673.660000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.043495 | 0.045201 | 47.680000 | 7673.660000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.031536 | 0.032284 | 42.552000 | 6853.368000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.032335 | 0.033931 | 42.552000 | 6853.368000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.068992 | 0.074578 | 42.552000 | 10852.136000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 1.246000 | 1.620270 | 29.860000 | 1911.040000 |
| temporal_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 27.479984 | 28.787575 | 29.860000 | 3920.768000 |
| alpha_ac | raw-egraph | 2.752000 / 3 / 3 | 0.050142 | 0.053573 | 43.436000 | 7221.936000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.058216 | 0.061446 | 35.500000 | 5868.192000 |
| alpha_ac | java-egglog | 2.752000 / 3 / 3 | 0.055027 | 0.055280 | 40.278000 | 6713.728000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.049367 | 0.052182 | 32.650000 | 5401.272000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.089077 | 0.090294 | 28.650000 | 7850.112000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 2.078673 | 2.472779 | 34.228000 | 2190.592000 |
| alpha_ac | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 47.987914 | 52.077729 | 34.228000 | 4387.712000 |
| alpha_binder_permutation | raw-egraph | 3.912000 / 4 / 4 | 0.034049 | 0.036295 | 39.018000 | 6470.400000 |
| alpha_binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.047511 | 0.053241 | 36.930000 | 6095.880000 |
| alpha_binder_permutation | java-egglog | 3.912000 / 4 / 4 | 0.033129 | 0.034407 | 37.234000 | 6183.292000 |
| alpha_binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.053366 | 0.060230 | 35.146000 | 5808.772000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.095767 | 0.100891 | 23.366000 | 6484.836000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 1.311943 | 1.657744 | 30.984000 | 1982.976000 |
| alpha_binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 48.513578 | 52.337586 | 30.984000 | 3879.616000 |
| binder_permutation_prenex | raw-egraph | 3.824000 / 4 / 4 | 0.046915 | 0.047913 | 41.754000 | 6874.504000 |
| binder_permutation_prenex | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.059913 | 0.061075 | 39.754000 | 6534.504000 |
| binder_permutation_prenex | java-egglog | 3.824000 / 4 / 4 | 0.045385 | 0.047005 | 39.970000 | 6587.396000 |
| binder_permutation_prenex | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.053569 | 0.055098 | 37.970000 | 6247.396000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.083121 | 0.086890 | 26.322000 | 7306.660000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 1.718467 | 1.938898 | 30.896000 | 1977.344000 |
| binder_permutation_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 49.428564 | 52.723896 | 30.896000 | 3895.616000 |
| ac_logical | raw-egraph | 0.000000 / 0 / 0 | 0.273919 | 0.322299 | 61.436000 | 9846.796000 |
| ac_logical | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.315718 | 0.369420 | 61.436000 | 9846.796000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.206623 | 0.253105 | 45.252000 | 7277.468000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.223471 | 0.283710 | 45.252000 | 7277.468000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.421989 | 0.520802 | 45.252000 | 11819.724000 |
| ac_logical | canonical | 0.000000 / 0 / 0 | 6.334174 | 7.569874 | 25.248000 | 1615.872000 |
| ac_logical | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 40.913355 | 46.141080 | 25.248000 | 3532.672000 |
| mixed | raw-egraph | 3.504000 / 4 / 4 | 0.279232 | 0.288147 | 105.326000 | 17062.340000 |
| mixed | raw-egraph-debruijn | 1.752000 / 2 / 2 | 0.357519 | 0.369488 | 103.326000 | 16722.340000 |
| mixed | java-egglog | 3.504000 / 4 / 4 | 0.143649 | 0.145534 | 77.766000 | 12675.388000 |
| mixed | java-egglog-debruijn | 1.752000 / 2 / 2 | 0.130686 | 0.137462 | 75.766000 | 12335.388000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.217895 | 0.232414 | 65.520000 | 18233.972000 |
| mixed | canonical | 0.000000 / 0 / 0 | 1.867139 | 2.297395 | 37.448000 | 2396.672000 |
| mixed | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 67.919143 | 73.522704 | 37.448000 | 4877.056000 |

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
