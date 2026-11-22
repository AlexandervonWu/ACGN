# Targeted Equivalence Capability Benchmark

- Generated at: `2026-11-16T00:13:51.896471036Z`
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
| canonical | 61598 | 4174 / 19212 (21.73%) | 0 | 14.010974 |
| typed-slotted-port-egraph | 61598 | 4174 / 19212 (21.73%) | 0 | 14.010974 |

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
| alpha | raw-egraph | 3.868000 / 4 / 4 | 0.094370 | 0.107659 | 42.930000 | 7175.808000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.053128 | 0.059494 | 28.930000 | 4810.544000 |
| alpha | java-egglog | 3.868000 / 4 / 4 | 0.095906 | 0.099053 | 41.146000 | 6888.700000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.065655 | 0.069205 | 27.322000 | 4547.092000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.319573 | 0.346936 | 25.322000 | 6995.740000 |
| alpha | canonical | 0.000000 / 0 / 0 | 5.837534 | 6.219312 | 30.984000 | 1982.976000 |
| alpha | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 57.790428 | 62.836701 | 30.984000 | 3879.616000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.035422 | 0.036531 | 24.282000 | 3963.400000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.038167 | 0.040652 | 24.282000 | 3963.400000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.035757 | 0.036989 | 22.490000 | 3670.512000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.039458 | 0.042308 | 22.490000 | 3670.512000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.079339 | 0.083835 | 20.988000 | 5562.088000 |
| aci | canonical | 0.000000 / 0 / 0 | 2.988858 | 3.446504 | 22.424000 | 1435.136000 |
| aci | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 35.681328 | 38.531136 | 22.424000 | 3158.528000 |
| binder_permutation | raw-egraph | 5.402000 / 4 / 7 | 0.037203 | 0.037256 | 45.000000 | 7441.452000 |
| binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.036227 | 0.037054 | 42.416000 | 7013.592000 |
| binder_permutation | java-egglog | 5.402000 / 4 / 7 | 0.031378 | 0.032299 | 42.220000 | 6991.000000 |
| binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.043651 | 0.044869 | 39.636000 | 6563.140000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.140864 | 0.148915 | 23.364000 | 6574.064000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 1.485554 | 1.844701 | 36.956000 | 2365.184000 |
| binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 82.071084 | 90.244407 | 36.956000 | 4229.504000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.025808 | 0.025849 | 31.302000 | 5104.504000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.029958 | 0.029994 | 32.302000 | 5282.504000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.022933 | 0.023917 | 30.150000 | 4915.836000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.029081 | 0.030799 | 31.150000 | 5093.836000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.065685 | 0.068835 | 27.282000 | 7336.084000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 0.926165 | 1.352238 | 29.788000 | 1906.432000 |
| safe_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 40.033132 | 42.160844 | 29.788000 | 3852.416000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.085971 | 0.087590 | 54.366000 | 8745.900000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.099073 | 0.102667 | 54.698000 | 8804.996000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.057004 | 0.058301 | 43.914000 | 7086.636000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.098953 | 0.103165 | 44.246000 | 7145.732000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.168935 | 0.178635 | 43.900000 | 11520.808000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 1.451618 | 1.849539 | 30.044000 | 1922.816000 |
| logical_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 45.039753 | 48.270386 | 30.044000 | 4005.952000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.039087 | 0.039161 | 47.680000 | 7673.660000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.039403 | 0.039458 | 47.680000 | 7673.660000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.030341 | 0.030377 | 42.552000 | 6853.368000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.037837 | 0.037925 | 42.552000 | 6853.368000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.080263 | 0.082063 | 42.552000 | 10852.136000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 2.030423 | 2.319984 | 29.860000 | 1911.040000 |
| temporal_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 30.334551 | 31.838542 | 29.860000 | 3920.768000 |
| alpha_ac | raw-egraph | 2.752000 / 3 / 3 | 0.048519 | 0.049699 | 43.436000 | 7221.936000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.050838 | 0.052145 | 35.500000 | 5868.192000 |
| alpha_ac | java-egglog | 2.752000 / 3 / 3 | 0.043418 | 0.043558 | 40.278000 | 6713.728000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.054960 | 0.058532 | 32.650000 | 5401.272000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.100857 | 0.103892 | 28.650000 | 7850.112000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 2.012460 | 2.441133 | 34.228000 | 2190.592000 |
| alpha_ac | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 55.706761 | 60.365986 | 34.228000 | 4387.712000 |
| alpha_binder_permutation | raw-egraph | 3.912000 / 4 / 4 | 0.033247 | 0.034219 | 39.018000 | 6470.400000 |
| alpha_binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.039098 | 0.040293 | 36.930000 | 6095.880000 |
| alpha_binder_permutation | java-egglog | 3.912000 / 4 / 4 | 0.028623 | 0.029566 | 37.234000 | 6183.292000 |
| alpha_binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.068205 | 0.071048 | 35.146000 | 5808.772000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.096527 | 0.102852 | 23.366000 | 6484.836000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 1.277793 | 1.655153 | 30.984000 | 1982.976000 |
| alpha_binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 54.472264 | 58.707240 | 30.984000 | 3879.616000 |
| binder_permutation_prenex | raw-egraph | 3.824000 / 4 / 4 | 0.046208 | 0.046316 | 41.754000 | 6874.504000 |
| binder_permutation_prenex | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.053265 | 0.053676 | 39.754000 | 6534.504000 |
| binder_permutation_prenex | java-egglog | 3.824000 / 4 / 4 | 0.042042 | 0.044123 | 39.970000 | 6587.396000 |
| binder_permutation_prenex | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.052173 | 0.052430 | 37.970000 | 6247.396000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.096546 | 0.098872 | 26.322000 | 7306.660000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 1.935331 | 2.204223 | 30.896000 | 1977.344000 |
| binder_permutation_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 55.296694 | 59.128966 | 30.896000 | 3895.616000 |
| ac_logical | raw-egraph | 0.000000 / 0 / 0 | 0.278728 | 0.319281 | 61.436000 | 9846.796000 |
| ac_logical | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.276584 | 0.363789 | 61.436000 | 9846.796000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.198405 | 0.233018 | 45.252000 | 7277.468000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.206889 | 0.263323 | 45.252000 | 7277.468000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.432380 | 0.562414 | 45.252000 | 11819.724000 |
| ac_logical | canonical | 0.000000 / 0 / 0 | 7.650058 | 8.940290 | 25.248000 | 1615.872000 |
| ac_logical | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 46.458877 | 53.057544 | 25.248000 | 3532.672000 |
| mixed | raw-egraph | 3.504000 / 4 / 4 | 0.272291 | 0.276635 | 105.326000 | 17062.340000 |
| mixed | raw-egraph-debruijn | 1.752000 / 2 / 2 | 0.277372 | 0.285595 | 103.326000 | 16722.340000 |
| mixed | java-egglog | 3.504000 / 4 / 4 | 0.099971 | 0.100910 | 77.766000 | 12675.388000 |
| mixed | java-egglog-debruijn | 1.752000 / 2 / 2 | 0.242667 | 0.251643 | 75.766000 | 12335.388000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.219658 | 0.226468 | 65.520000 | 18233.972000 |
| mixed | canonical | 0.000000 / 0 / 0 | 1.537161 | 2.038650 | 37.448000 | 2396.672000 |
| mixed | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 74.257827 | 80.312085 | 37.448000 | 4877.056000 |

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
