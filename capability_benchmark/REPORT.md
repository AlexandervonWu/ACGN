# Targeted Equivalence Capability Benchmark

- Generated at: `2026-08-27T22:25:52.364160872Z`
- RNG seed: `55520260811`
- Valid, parser-AST-different pairs: 5500
- Ground truth: equivalence by construction using only the implemented rule set
- Seed source: zero-parameter predicates from Alloy4Fun `CORRECT` folders

Dataset labels and generated ground truth are distinct: `CORRECT` is used only to select real seed predicates; benchmark equivalence follows from each recorded transformation and side condition.

## Recovery By Family

| Transformation family | raw-egraph | raw-egraph-debruijn | java-egglog | java-egglog-debruijn | slotted-egraph | canonical | typed-slotted-port-egraph |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Alpha-equivalence | 0/500 (0.00%) | 500/500 (100.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Associativity / commutativity / idempotence | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 496/500 (99.20%) | 496/500 (99.20%) |
| Binder-block permutations | 1/500 (0.20%) | 22/500 (4.40%) | 1/500 (0.20%) | 22/500 (4.40%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Safe prenex transformations | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Negation / logical normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Temporal normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: alpha + AC | 0/500 (0.00%) | 500/500 (100.00%) | 0/500 (0.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: alpha + binder permutation | 0/500 (0.00%) | 22/500 (4.40%) | 0/500 (0.00%) | 22/500 (4.40%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: binder permutation + prenex | 22/500 (4.40%) | 22/500 (4.40%) | 22/500 (4.40%) | 22/500 (4.40%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) |
| Composed: AC + logical normalization | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 500/500 (100.00%) | 498/500 (99.60%) | 498/500 (99.60%) |
| Composed: mixed 2-4 transformations | 62/500 (12.40%) | 62/500 (12.40%) | 62/500 (12.40%) | 62/500 (12.40%) | 500/500 (100.00%) | 498/500 (99.60%) | 498/500 (99.60%) |
| All composed families | 2023/4000 (50.58%) | 2566/4000 (64.15%) | 2023/4000 (50.58%) | 2566/4000 (64.15%) | 4000/4000 (100.00%) | 3998/4000 (99.95%) | 3998/4000 (99.95%) |
| All families | 2585/5500 (47.00%) | 3628/5500 (65.96%) | 2585/5500 (47.00%) | 3628/5500 (65.96%) | 5500/5500 (100.00%) | 5492/5500 (99.85%) | 5492/5500 (99.85%) |

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
| raw-egraph | 61598 | 820 / 19212 (4.27%) | 0 | 18.364168 |
| raw-egraph-debruijn | 61598 | 2160 / 19212 (11.24%) | 0 | 17.911491 |
| java-egglog | 61598 | 820 / 19212 (4.27%) | 0 | 18.146514 |
| java-egglog-debruijn | 61598 | 2160 / 19212 (11.24%) | 0 | 17.690039 |
| slotted-egraph | 61598 | 2159 / 19212 (11.24%) | 0 | 17.824231 |
| canonical | 61598 | 4074 / 19212 (21.21%) | 0 | 13.938342 |
| typed-slotted-port-egraph | 61598 | 4088 / 19212 (21.28%) | 0 | 14.021251 |

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
| alpha | raw-egraph | 3.868000 / 4 / 4 | 0.092688 | 0.105678 | 65.858000 | 10978.056000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.077246 | 0.081801 | 43.030000 | 7110.832000 |
| alpha | java-egglog | 3.868000 / 4 / 4 | 0.081069 | 0.086564 | 64.074000 | 10690.948000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.081011 | 0.093792 | 41.422000 | 6847.380000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.291213 | 0.304890 | 39.422000 | 10671.244000 |
| alpha | canonical | 0.000000 / 0 / 0 | 4.552734 | 4.832215 | 30.764000 | 1968.896000 |
| alpha | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 264.620180 | 283.018875 | 30.764000 | 3896.320000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.035909 | 0.037373 | 33.240000 | 5393.508000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.038934 | 0.039147 | 33.240000 | 5393.508000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.036578 | 0.039200 | 31.448000 | 5100.620000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.038021 | 0.038284 | 31.448000 | 5100.620000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.082259 | 0.085490 | 29.444000 | 7658.012000 |
| aci | canonical | 0.024000 / 0 / 0 | 2.270696 | 2.605538 | 19.510000 | 1248.640000 |
| aci | typed-slotted-port-egraph | 0.024000 / 0 / 0 | 236.327673 | 249.459574 | 19.490000 | 2686.976000 |
| binder_permutation | raw-egraph | 5.402000 / 4 / 7 | 0.034640 | 0.035414 | 64.090000 | 10605.892000 |
| binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.045056 | 0.045099 | 60.466000 | 9947.932000 |
| binder_permutation | java-egglog | 5.402000 / 4 / 7 | 0.034508 | 0.034512 | 61.310000 | 10155.440000 |
| binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.038122 | 0.039992 | 57.686000 | 9497.480000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.114658 | 0.118207 | 35.502000 | 9795.084000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 0.805167 | 1.245426 | 36.524000 | 2337.536000 |
| binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 632.711143 | 672.976894 | 36.524000 | 4231.424000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.027235 | 0.027259 | 47.232000 | 7687.500000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.033565 | 0.036823 | 48.232000 | 7865.500000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.025691 | 0.025708 | 46.080000 | 7498.832000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.032376 | 0.032385 | 47.080000 | 7676.832000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.058781 | 0.059871 | 41.300000 | 10940.208000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 0.599270 | 1.055478 | 29.784000 | 1906.176000 |
| safe_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 238.789615 | 246.184558 | 29.784000 | 3883.200000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.111472 | 0.116668 | 72.306000 | 11612.312000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.091029 | 0.094511 | 72.638000 | 11671.408000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.070060 | 0.071158 | 60.278000 | 9707.192000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.060128 | 0.061197 | 60.610000 | 9766.288000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.107462 | 0.108035 | 60.264000 | 15625.348000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 1.202285 | 1.616714 | 32.580000 | 2085.120000 |
| logical_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 577.061780 | 606.876792 | 32.532000 | 4510.976000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.039296 | 0.039287 | 61.776000 | 9916.500000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.043930 | 0.043953 | 61.776000 | 9916.500000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.036097 | 0.036101 | 56.152000 | 9018.832000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.039260 | 0.041193 | 56.152000 | 9018.832000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.070835 | 0.075744 | 56.152000 | 14214.400000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 1.378499 | 1.668107 | 35.664000 | 2282.496000 |
| temporal_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 399.545375 | 413.593018 | 35.664000 | 4961.920000 |
| alpha_ac | raw-egraph | 2.752000 / 3 / 3 | 0.054202 | 0.055564 | 63.214000 | 10485.252000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.059782 | 0.060810 | 51.402000 | 8458.852000 |
| alpha_ac | java-egglog | 2.752000 / 3 / 3 | 0.053802 | 0.056323 | 60.056000 | 9977.044000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.055524 | 0.059227 | 48.552000 | 7991.932000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.088721 | 0.096762 | 42.552000 | 11426.660000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 1.297362 | 1.801384 | 31.080000 | 1989.120000 |
| alpha_ac | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 356.816013 | 378.517949 | 31.080000 | 4066.752000 |
| alpha_binder_permutation | raw-egraph | 3.912000 / 4 / 4 | 0.032377 | 0.032423 | 57.118000 | 9470.688000 |
| alpha_binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.042759 | 0.043895 | 53.986000 | 8867.304000 |
| alpha_binder_permutation | java-egglog | 3.912000 / 4 / 4 | 0.031492 | 0.031585 | 55.334000 | 9183.580000 |
| alpha_binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.046832 | 0.048978 | 52.202000 | 8580.196000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.098508 | 0.101724 | 35.510000 | 9683.604000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 0.802929 | 1.245443 | 30.764000 | 1968.896000 |
| alpha_binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 286.962453 | 301.671437 | 30.764000 | 3896.320000 |
| binder_permutation_prenex | raw-egraph | 3.824000 / 4 / 4 | 0.059805 | 0.059885 | 61.546000 | 10132.760000 |
| binder_permutation_prenex | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.111957 | 0.113626 | 58.590000 | 9580.528000 |
| binder_permutation_prenex | java-egglog | 3.824000 / 4 / 4 | 0.066287 | 0.068242 | 59.762000 | 9845.652000 |
| binder_permutation_prenex | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.056223 | 0.057163 | 56.806000 | 9293.420000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.085066 | 0.089527 | 40.334000 | 10948.028000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 0.670558 | 1.116106 | 30.764000 | 1968.896000 |
| binder_permutation_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 286.972033 | 301.745861 | 30.764000 | 3896.320000 |
| ac_logical | raw-egraph | 0.000000 / 0 / 0 | 0.342769 | 0.384933 | 79.138000 | 12664.080000 |
| ac_logical | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.366086 | 0.431268 | 79.138000 | 12664.080000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.237513 | 0.296682 | 61.130000 | 9810.204000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.222397 | 0.259913 | 61.130000 | 9810.204000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.442586 | 0.506280 | 61.130000 | 15749.724000 |
| ac_logical | canonical | 0.018000 / 0 / 0 | 5.023800 | 6.039246 | 27.348000 | 1750.272000 |
| ac_logical | typed-slotted-port-egraph | 0.018000 / 0 / 0 | 414.272314 | 442.085951 | 27.348000 | 3921.728000 |
| mixed | raw-egraph | 3.504000 / 4 / 4 | 0.319031 | 0.323684 | 143.228000 | 23171.416000 |
| mixed | raw-egraph-debruijn | 1.752000 / 2 / 2 | 0.425534 | 0.434206 | 140.352000 | 22636.944000 |
| mixed | java-egglog | 3.504000 / 4 / 4 | 0.202592 | 0.205205 | 110.878000 | 18037.080000 |
| mixed | java-egglog-debruijn | 1.752000 / 2 / 2 | 0.611544 | 0.625944 | 108.002000 | 17502.608000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.220646 | 0.222150 | 93.760000 | 25364.872000 |
| mixed | canonical | 0.018000 / 0 / 0 | 1.006922 | 1.585897 | 37.528000 | 2401.792000 |
| mixed | typed-slotted-port-egraph | 0.018000 / 0 / 0 | 704.511383 | 761.838904 | 37.528000 | 5046.272000 |

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
| aci | slotted-egraph -> canonical | 496 | 0 | 4 |
| aci | canonical -> typed-slotted-port-egraph | 496 | 0 | 0 |
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
| ac_logical | slotted-egraph -> canonical | 498 | 0 | 2 |
| ac_logical | canonical -> typed-slotted-port-egraph | 498 | 0 | 0 |
| mixed | raw-egraph -> raw-egraph-debruijn | 62 | 0 | 0 |
| mixed | raw-egraph -> java-egglog | 62 | 0 | 0 |
| mixed | raw-egraph-debruijn -> java-egglog-debruijn | 62 | 0 | 0 |
| mixed | java-egglog -> java-egglog-debruijn | 62 | 0 | 0 |
| mixed | java-egglog-debruijn -> slotted-egraph | 62 | 438 | 0 |
| mixed | slotted-egraph -> canonical | 498 | 0 | 2 |
| mixed | canonical -> typed-slotted-port-egraph | 498 | 0 | 0 |

## Generation Skips

No generation attempts were skipped.

## Reproduce

```bash
./scripts/run_capability_benchmark.sh --dataset classified-data --output capability_benchmark --target 500 --seed 55520260811
```
