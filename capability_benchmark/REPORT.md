# Targeted Equivalence Capability Benchmark

- Generated at: `2026-08-19T18:15:35.878132788Z`
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
| All composed families | 2023/4000 (50.58%) | 2566/4000 (64.15%) | 2023/4000 (50.58%) | 2566/4000 (64.15%) | 4000/4000 (100.00%) | 4000/4000 (100.00%) | 4000/4000 (100.00%) |
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
| raw-egraph | 61598 | 823 / 19212 (4.28%) | 0 | 18.390419 |
| raw-egraph-debruijn | 61598 | 2163 / 19212 (11.26%) | 0 | 17.922985 |
| java-egglog | 61598 | 823 / 19212 (4.28%) | 0 | 17.996412 |
| java-egglog-debruijn | 61598 | 2163 / 19212 (11.26%) | 0 | 17.529952 |
| slotted-egraph | 61598 | 2162 / 19212 (11.25%) | 0 | 17.693902 |
| canonical | 61598 | 2316 / 19212 (12.05%) | 0 | 14.029027 |
| typed-slotted-port-egraph | 61598 | 2317 / 19212 (12.06%) | 0 | 14.042096 |

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
| alpha | raw-egraph | 3.868000 / 4 / 4 | 0.070096 | 0.082428 | 65.858000 | 10978.056000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.061120 | 0.068670 | 43.030000 | 7110.832000 |
| alpha | java-egglog | 3.868000 / 4 / 4 | 0.077894 | 0.088279 | 64.074000 | 10690.948000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.057595 | 0.064381 | 41.422000 | 6847.380000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.340895 | 0.381108 | 39.422000 | 10671.244000 |
| alpha | canonical | 0.000000 / 0 / 0 | 1.613343 | 2.223377 | 40.864000 | 2615.296000 |
| alpha | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 713.419492 | 912.592685 | 40.864000 | 5920.064000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.036602 | 0.038419 | 33.274000 | 5390.644000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.034402 | 0.035662 | 33.274000 | 5390.644000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.030586 | 0.034089 | 31.332000 | 5073.156000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.037443 | 0.038474 | 31.332000 | 5073.156000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.084586 | 0.087470 | 29.328000 | 7618.156000 |
| aci | canonical | 0.000000 / 0 / 0 | 0.343360 | 0.409925 | 41.472000 | 2654.208000 |
| aci | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 605.208041 | 754.099837 | 41.472000 | 5320.960000 |
| binder_permutation | raw-egraph | 5.402000 / 4 / 7 | 0.035600 | 0.039865 | 64.090000 | 10605.892000 |
| binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.042159 | 0.043353 | 60.466000 | 9947.932000 |
| binder_permutation | java-egglog | 5.402000 / 4 / 7 | 0.034631 | 0.035926 | 61.310000 | 10155.440000 |
| binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.035567 | 0.035643 | 57.686000 | 9497.480000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.113719 | 0.119517 | 35.502000 | 9795.084000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 0.226346 | 0.261867 | 46.864000 | 2999.296000 |
| binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 1401.111742 | 1745.286800 | 46.864000 | 6368.064000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.033132 | 0.034314 | 47.232000 | 7687.500000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.031471 | 0.031513 | 48.232000 | 7865.500000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.024957 | 0.025020 | 46.080000 | 7498.832000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.030175 | 0.032611 | 47.080000 | 7676.832000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.056568 | 0.057719 | 41.300000 | 10940.208000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 0.115338 | 0.137089 | 39.864000 | 2551.296000 |
| safe_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 435.016102 | 549.509547 | 39.864000 | 5712.064000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.134522 | 0.142202 | 72.306000 | 11612.312000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.100428 | 0.103576 | 72.638000 | 11671.408000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.053011 | 0.053273 | 60.278000 | 9707.192000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.081984 | 0.088015 | 60.610000 | 9766.288000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.130499 | 0.131860 | 60.264000 | 15625.348000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 0.226902 | 0.271651 | 44.916000 | 2874.624000 |
| logical_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 919.527062 | 1116.531267 | 44.900000 | 5924.096000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.041613 | 0.041657 | 61.776000 | 9916.500000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.042465 | 0.042545 | 61.776000 | 9916.500000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.031985 | 0.032026 | 56.152000 | 9018.832000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.036474 | 0.038931 | 56.152000 | 9018.832000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.072134 | 0.074375 | 56.152000 | 14214.400000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 0.103567 | 0.121044 | 39.832000 | 2549.248000 |
| temporal_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 406.884601 | 507.806520 | 39.832000 | 5224.256000 |
| alpha_ac | raw-egraph | 2.752000 / 3 / 3 | 0.062766 | 0.063119 | 63.214000 | 10485.252000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.059611 | 0.063220 | 51.402000 | 8458.852000 |
| alpha_ac | java-egglog | 2.752000 / 3 / 3 | 0.055700 | 0.058431 | 60.056000 | 9977.044000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.060486 | 0.066761 | 48.552000 | 7991.932000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.152522 | 0.166258 | 42.552000 | 11426.660000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 0.312219 | 0.337400 | 55.532000 | 3554.048000 |
| alpha_ac | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 1062.710787 | 1346.316828 | 55.532000 | 7497.920000 |
| alpha_binder_permutation | raw-egraph | 3.912000 / 4 / 4 | 0.036833 | 0.036987 | 57.118000 | 9470.688000 |
| alpha_binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.047398 | 0.050147 | 53.986000 | 8867.304000 |
| alpha_binder_permutation | java-egglog | 3.912000 / 4 / 4 | 0.032052 | 0.033246 | 55.334000 | 9183.580000 |
| alpha_binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.044222 | 0.044974 | 52.202000 | 8580.196000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.144540 | 0.156287 | 35.510000 | 9683.604000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 0.225426 | 0.248419 | 40.864000 | 2615.296000 |
| alpha_binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 717.654501 | 909.368977 | 40.864000 | 5920.064000 |
| binder_permutation_prenex | raw-egraph | 3.824000 / 4 / 4 | 0.063788 | 0.067542 | 61.546000 | 10132.760000 |
| binder_permutation_prenex | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.184582 | 0.184832 | 58.590000 | 9580.528000 |
| binder_permutation_prenex | java-egglog | 3.824000 / 4 / 4 | 0.051931 | 0.052129 | 59.762000 | 9845.652000 |
| binder_permutation_prenex | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.056590 | 0.056696 | 56.806000 | 9293.420000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.078087 | 0.081619 | 40.334000 | 10948.028000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 0.186150 | 0.202659 | 40.864000 | 2615.296000 |
| binder_permutation_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 713.048165 | 915.241647 | 40.864000 | 5920.064000 |
| ac_logical | raw-egraph | 0.000000 / 0 / 0 | 0.449978 | 0.807888 | 79.138000 | 12664.080000 |
| ac_logical | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.400383 | 0.957610 | 79.138000 | 12664.080000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.270091 | 0.507861 | 61.130000 | 9810.204000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.329089 | 0.629712 | 61.130000 | 9810.204000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.576648 | 1.193495 | 61.130000 | 15749.724000 |
| ac_logical | canonical | 0.000000 / 0 / 0 | 0.993435 | 2.093854 | 39.104000 | 2502.656000 |
| ac_logical | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 506.887525 | 657.725704 | 39.104000 | 5136.704000 |
| mixed | raw-egraph | 3.504000 / 4 / 4 | 0.707137 | 0.733637 | 143.228000 | 23171.416000 |
| mixed | raw-egraph-debruijn | 1.752000 / 2 / 2 | 0.382102 | 0.394193 | 140.352000 | 22636.944000 |
| mixed | java-egglog | 3.504000 / 4 / 4 | 0.184948 | 0.194492 | 110.878000 | 18037.080000 |
| mixed | java-egglog-debruijn | 1.752000 / 2 / 2 | 0.351863 | 0.358730 | 108.002000 | 17502.608000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.233254 | 0.245735 | 93.760000 | 25364.872000 |
| mixed | canonical | 0.000000 / 0 / 0 | 0.214588 | 0.220950 | 51.864000 | 3319.296000 |
| mixed | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 1208.278793 | 1528.231699 | 51.864000 | 7112.064000 |

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
