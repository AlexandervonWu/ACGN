# Targeted Equivalence Capability Benchmark

- Generated at: `2026-08-14T14:26:59.460400848Z`
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
| Binder-block permutations | 1/500 (0.20%) | 22/500 (4.40%) | 1/500 (0.20%) | 22/500 (4.40%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Safe prenex transformations | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Negation / logical normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Temporal normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: alpha + AC | 0/500 (0.00%) | 500/500 (100.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: alpha + binder permutation | 0/500 (0.00%) | 22/500 (4.40%) | 0/500 (0.00%) | 22/500 (4.40%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: binder permutation + prenex | 22/500 (4.40%) | 22/500 (4.40%) | 22/500 (4.40%) | 22/500 (4.40%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: AC + logical normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: mixed 2-4 transformations | 62/500 (12.40%) | 62/500 (12.40%) | 62/500 (12.40%) | 62/500 (12.40%) | 500/500 (100.00%) | 500/500 (100.00%) |
| All composed families | 2023/4000 (50.58%) | 2566/4000 (64.15%) | 2023/4000 (50.58%) | 2566/4000 (64.15%) | 4000/4000 (100.00%) | 4000/4000 (100.00%) |
| All families | 2585/5500 (47.00%) | 3628/5500 (65.96%) | 2585/5500 (47.00%) | 3628/5500 (65.96%) | 5500/5500 (100.00%) | 5500/5500 (100.00%) |

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
| alpha | raw-egraph | 3.868000 / 4 / 4 | 0.079497 | 0.090186 | 65.858000 | 10978.056000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.072712 | 0.084858 | 43.030000 | 7110.832000 |
| alpha | java-egglog | 3.868000 / 4 / 4 | 0.095039 | 0.108228 | 64.074000 | 10690.948000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.058167 | 0.063857 | 41.422000 | 6847.380000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.299640 | 0.340219 | 39.422000 | 10671.244000 |
| alpha | canonical | 0.000000 / 0 / 0 | 0.852303 | 1.254205 | 40.864000 | 2615.296000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.039845 | 0.043251 | 33.274000 | 5390.644000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.036719 | 0.038274 | 33.274000 | 5390.644000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.032127 | 0.037654 | 31.332000 | 5073.156000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.034107 | 0.034869 | 31.332000 | 5073.156000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.075151 | 0.082335 | 29.328000 | 7618.156000 |
| aci | canonical | 0.000000 / 0 / 0 | 0.304027 | 0.390507 | 41.472000 | 2654.208000 |
| binder_permutation | raw-egraph | 5.402000 / 4 / 7 | 0.038011 | 0.038036 | 64.090000 | 10605.892000 |
| binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.040339 | 0.042628 | 60.466000 | 9947.932000 |
| binder_permutation | java-egglog | 5.402000 / 4 / 7 | 0.035255 | 0.036748 | 61.310000 | 10155.440000 |
| binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.037192 | 0.038491 | 57.686000 | 9497.480000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.123038 | 0.126431 | 35.502000 | 9795.084000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 0.255528 | 0.283300 | 46.864000 | 2999.296000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.042878 | 0.042962 | 47.232000 | 7687.500000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.049116 | 0.049435 | 48.232000 | 7865.500000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.031698 | 0.032726 | 46.080000 | 7498.832000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.033087 | 0.035504 | 47.080000 | 7676.832000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.065423 | 0.067253 | 41.300000 | 10940.208000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 0.123174 | 0.134186 | 39.864000 | 2551.296000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.102450 | 0.106995 | 72.306000 | 11612.312000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.095748 | 0.098189 | 72.638000 | 11671.408000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.067334 | 0.071912 | 60.278000 | 9707.192000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.073954 | 0.077647 | 60.610000 | 9766.288000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.146928 | 0.155122 | 60.264000 | 15625.348000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 0.334768 | 0.367357 | 48.192000 | 3084.288000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.040868 | 0.043944 | 61.776000 | 9916.500000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.042485 | 0.043530 | 61.776000 | 9916.500000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.033318 | 0.033364 | 56.152000 | 9018.832000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.039409 | 0.039567 | 56.152000 | 9018.832000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.081674 | 0.085096 | 56.152000 | 14214.400000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 0.108494 | 0.122415 | 42.244000 | 2703.616000 |
| alpha_ac | raw-egraph | 2.752000 / 3 / 3 | 0.067393 | 0.068629 | 63.214000 | 10485.252000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.072457 | 0.074750 | 51.402000 | 8458.852000 |
| alpha_ac | java-egglog | 2.752000 / 3 / 3 | 0.061376 | 0.064666 | 60.056000 | 9977.044000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.066517 | 0.069123 | 48.552000 | 7991.932000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.109885 | 0.114236 | 42.552000 | 11426.660000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 0.422194 | 0.472060 | 55.532000 | 3554.048000 |
| alpha_binder_permutation | raw-egraph | 3.912000 / 4 / 4 | 0.037107 | 0.038419 | 57.118000 | 9470.688000 |
| alpha_binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.047659 | 0.053167 | 53.986000 | 8867.304000 |
| alpha_binder_permutation | java-egglog | 3.912000 / 4 / 4 | 0.032612 | 0.032727 | 55.334000 | 9183.580000 |
| alpha_binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.049538 | 0.050730 | 52.202000 | 8580.196000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.145877 | 0.156929 | 35.510000 | 9683.604000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 0.234567 | 0.302312 | 40.864000 | 2615.296000 |
| binder_permutation_prenex | raw-egraph | 3.824000 / 4 / 4 | 0.059171 | 0.062452 | 61.546000 | 10132.760000 |
| binder_permutation_prenex | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.142764 | 0.148121 | 58.590000 | 9580.528000 |
| binder_permutation_prenex | java-egglog | 3.824000 / 4 / 4 | 0.056216 | 0.056406 | 59.762000 | 9845.652000 |
| binder_permutation_prenex | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.052840 | 0.054151 | 56.806000 | 9293.420000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.088161 | 0.091941 | 40.334000 | 10948.028000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 0.193007 | 0.224883 | 40.864000 | 2615.296000 |
| ac_logical | raw-egraph | 0.000000 / 0 / 0 | 0.482498 | 0.853537 | 79.138000 | 12664.080000 |
| ac_logical | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.443541 | 0.834694 | 79.138000 | 12664.080000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.264176 | 0.549797 | 61.130000 | 9810.204000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.342017 | 0.621761 | 61.130000 | 9810.204000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.620211 | 1.188766 | 61.130000 | 15749.724000 |
| ac_logical | canonical | 0.000000 / 0 / 0 | 1.032325 | 2.429527 | 45.532000 | 2914.048000 |
| mixed | raw-egraph | 3.504000 / 4 / 4 | 2.537637 | 2.647393 | 143.228000 | 23171.416000 |
| mixed | raw-egraph-debruijn | 1.752000 / 2 / 2 | 2.684649 | 2.872495 | 140.352000 | 22636.944000 |
| mixed | java-egglog | 3.504000 / 4 / 4 | 0.232479 | 0.238121 | 110.878000 | 18037.080000 |
| mixed | java-egglog-debruijn | 1.752000 / 2 / 2 | 0.329679 | 0.334877 | 108.002000 | 17502.608000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.266492 | 0.280306 | 93.760000 | 25364.872000 |
| mixed | canonical | 0.000000 / 0 / 0 | 0.256935 | 0.289693 | 59.532000 | 3810.048000 |

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
| binder_permutation | raw-egraph -> raw-egraph-debruijn | 1 | 21 | 0 |
| binder_permutation | raw-egraph -> java-egglog | 1 | 0 | 0 |
| binder_permutation | raw-egraph-debruijn -> java-egglog-debruijn | 22 | 0 | 0 |
| binder_permutation | java-egglog -> java-egglog-debruijn | 1 | 21 | 0 |
| binder_permutation | java-egglog-debruijn -> slotted-egraph | 22 | 478 | 0 |
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
| alpha_binder_permutation | raw-egraph -> raw-egraph-debruijn | 0 | 22 | 0 |
| alpha_binder_permutation | raw-egraph -> java-egglog | 0 | 0 | 0 |
| alpha_binder_permutation | raw-egraph-debruijn -> java-egglog-debruijn | 22 | 0 | 0 |
| alpha_binder_permutation | java-egglog -> java-egglog-debruijn | 0 | 22 | 0 |
| alpha_binder_permutation | java-egglog-debruijn -> slotted-egraph | 22 | 478 | 0 |
| alpha_binder_permutation | slotted-egraph -> canonical | 500 | 0 | 0 |
| binder_permutation_prenex | raw-egraph -> raw-egraph-debruijn | 22 | 0 | 0 |
| binder_permutation_prenex | raw-egraph -> java-egglog | 22 | 0 | 0 |
| binder_permutation_prenex | raw-egraph-debruijn -> java-egglog-debruijn | 22 | 0 | 0 |
| binder_permutation_prenex | java-egglog -> java-egglog-debruijn | 22 | 0 | 0 |
| binder_permutation_prenex | java-egglog-debruijn -> slotted-egraph | 22 | 478 | 0 |
| binder_permutation_prenex | slotted-egraph -> canonical | 500 | 0 | 0 |
| ac_logical | raw-egraph -> raw-egraph-debruijn | 500 | 0 | 0 |
| ac_logical | raw-egraph -> java-egglog | 500 | 0 | 0 |
| ac_logical | raw-egraph-debruijn -> java-egglog-debruijn | 500 | 0 | 0 |
| ac_logical | java-egglog -> java-egglog-debruijn | 500 | 0 | 0 |
| ac_logical | java-egglog-debruijn -> slotted-egraph | 500 | 0 | 0 |
| ac_logical | slotted-egraph -> canonical | 500 | 0 | 0 |
| mixed | raw-egraph -> raw-egraph-debruijn | 62 | 0 | 0 |
| mixed | raw-egraph -> java-egglog | 62 | 0 | 0 |
| mixed | raw-egraph-debruijn -> java-egglog-debruijn | 62 | 0 | 0 |
| mixed | java-egglog -> java-egglog-debruijn | 62 | 0 | 0 |
| mixed | java-egglog-debruijn -> slotted-egraph | 62 | 438 | 0 |
| mixed | slotted-egraph -> canonical | 500 | 0 | 0 |

## Generation Skips

No generation attempts were skipped.

## Reproduce

```bash
./scripts/run_capability_benchmark.sh --dataset classified-data --output capability_benchmark --target 500 --seed 55520260811
```
