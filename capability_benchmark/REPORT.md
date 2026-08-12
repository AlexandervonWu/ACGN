# Targeted Equivalence Capability Benchmark

- Generated at: `2026-08-12T14:10:03.265078538Z`
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
| alpha | raw-egraph | 3.868000 / 4 / 4 | 0.084752 | 0.093746 | 65.858000 | 10978.056000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.073456 | 0.085712 | 43.030000 | 7110.832000 |
| alpha | java-egglog | 3.868000 / 4 / 4 | 0.106999 | 0.125755 | 64.074000 | 10690.948000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.086301 | 0.101522 | 41.422000 | 6847.380000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.365457 | 0.448304 | 39.422000 | 10671.244000 |
| alpha | canonical | 0.000000 / 0 / 0 | 1.476334 | 1.982301 | 40.864000 | 2615.296000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.034874 | 0.039719 | 33.274000 | 5390.644000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.038281 | 0.042653 | 33.274000 | 5390.644000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.037411 | 0.039864 | 31.332000 | 5073.156000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.036801 | 0.042741 | 31.332000 | 5073.156000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.082773 | 0.096787 | 29.328000 | 7618.156000 |
| aci | canonical | 0.000000 / 0 / 0 | 0.287438 | 0.323981 | 41.472000 | 2654.208000 |
| binder_permutation | raw-egraph | 5.402000 / 4 / 7 | 0.045815 | 0.048417 | 64.090000 | 10605.892000 |
| binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.049622 | 0.049825 | 60.466000 | 9947.932000 |
| binder_permutation | java-egglog | 5.402000 / 4 / 7 | 0.036809 | 0.036964 | 61.310000 | 10155.440000 |
| binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.040108 | 0.043158 | 57.686000 | 9497.480000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.144910 | 0.158507 | 35.502000 | 9795.084000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 0.248869 | 0.283493 | 46.864000 | 2999.296000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.042155 | 0.042658 | 47.232000 | 7687.500000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.041287 | 0.042646 | 48.232000 | 7865.500000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.046410 | 0.046467 | 46.080000 | 7498.832000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.031320 | 0.032634 | 47.080000 | 7676.832000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.062307 | 0.064523 | 41.300000 | 10940.208000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 0.120292 | 0.128666 | 39.864000 | 2551.296000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.131375 | 0.144043 | 72.306000 | 11612.312000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.115409 | 0.117009 | 72.638000 | 11671.408000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.081158 | 0.082744 | 60.278000 | 9707.192000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.062322 | 0.065107 | 60.610000 | 9766.288000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.141459 | 0.148122 | 60.264000 | 15625.348000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 0.339367 | 0.353838 | 48.192000 | 3084.288000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.048313 | 0.050843 | 61.776000 | 9916.500000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.046127 | 0.047128 | 61.776000 | 9916.500000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.037443 | 0.038523 | 56.152000 | 9018.832000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.038026 | 0.038053 | 56.152000 | 9018.832000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.077316 | 0.080799 | 56.152000 | 14214.400000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 0.113129 | 0.125405 | 42.244000 | 2703.616000 |
| alpha_ac | raw-egraph | 2.752000 / 3 / 3 | 0.070202 | 0.073168 | 63.214000 | 10485.252000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.069945 | 0.070359 | 51.402000 | 8458.852000 |
| alpha_ac | java-egglog | 2.752000 / 3 / 3 | 0.066803 | 0.070851 | 60.056000 | 9977.044000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.059397 | 0.071198 | 48.552000 | 7991.932000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.153288 | 0.166298 | 42.552000 | 11426.660000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 0.309928 | 0.347342 | 55.532000 | 3554.048000 |
| alpha_binder_permutation | raw-egraph | 3.912000 / 4 / 4 | 0.041171 | 0.043812 | 57.118000 | 9470.688000 |
| alpha_binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.057396 | 0.062059 | 53.986000 | 8867.304000 |
| alpha_binder_permutation | java-egglog | 3.912000 / 4 / 4 | 0.039365 | 0.041421 | 55.334000 | 9183.580000 |
| alpha_binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.052695 | 0.054712 | 52.202000 | 8580.196000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.163433 | 0.180308 | 35.510000 | 9683.604000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 0.219817 | 0.245070 | 40.864000 | 2615.296000 |
| binder_permutation_prenex | raw-egraph | 3.824000 / 4 / 4 | 0.067536 | 0.069146 | 61.546000 | 10132.760000 |
| binder_permutation_prenex | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.102210 | 0.104093 | 58.590000 | 9580.528000 |
| binder_permutation_prenex | java-egglog | 3.824000 / 4 / 4 | 0.062625 | 0.064261 | 59.762000 | 9845.652000 |
| binder_permutation_prenex | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.058869 | 0.059122 | 56.806000 | 9293.420000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.096287 | 0.099010 | 40.334000 | 10948.028000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 0.202182 | 0.223472 | 40.864000 | 2615.296000 |
| ac_logical | raw-egraph | 0.000000 / 0 / 0 | 0.414021 | 0.791360 | 79.138000 | 12664.080000 |
| ac_logical | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.477435 | 0.928800 | 79.138000 | 12664.080000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.310487 | 0.598253 | 61.130000 | 9810.204000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.305675 | 0.719784 | 61.130000 | 9810.204000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.627720 | 1.334528 | 61.130000 | 15749.724000 |
| ac_logical | canonical | 0.000000 / 0 / 0 | 1.046744 | 2.212231 | 45.532000 | 2914.048000 |
| mixed | raw-egraph | 3.504000 / 4 / 4 | 2.356595 | 2.523598 | 143.228000 | 23171.416000 |
| mixed | raw-egraph-debruijn | 1.752000 / 2 / 2 | 1.978726 | 2.128514 | 140.352000 | 22636.944000 |
| mixed | java-egglog | 3.504000 / 4 / 4 | 0.223846 | 0.231155 | 110.878000 | 18037.080000 |
| mixed | java-egglog-debruijn | 1.752000 / 2 / 2 | 0.373460 | 0.380053 | 108.002000 | 17502.608000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.247498 | 0.258315 | 93.760000 | 25364.872000 |
| mixed | canonical | 0.000000 / 0 / 0 | 0.219371 | 0.240986 | 59.532000 | 3810.048000 |

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
