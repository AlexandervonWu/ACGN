# Targeted Equivalence Capability Benchmark

- Generated at: `2026-08-29T23:30:18.458040842Z`
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
| raw-egraph | 61598 | 820 / 19212 (4.27%) | 0 | 18.364168 |
| raw-egraph-debruijn | 61598 | 2160 / 19212 (11.24%) | 0 | 17.911491 |
| java-egglog | 61598 | 820 / 19212 (4.27%) | 0 | 18.146514 |
| java-egglog-debruijn | 61598 | 2160 / 19212 (11.24%) | 0 | 17.690039 |
| slotted-egraph | 61598 | 2159 / 19212 (11.24%) | 0 | 17.824231 |
| canonical | 61598 | 4074 / 19212 (21.21%) | 0 | 13.943342 |
| typed-slotted-port-egraph | 61598 | 4088 / 19212 (21.28%) | 0 | 14.021721 |

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
| alpha | raw-egraph | 3.868000 / 4 / 4 | 0.082305 | 0.087440 | 65.858000 | 10978.056000 |
| alpha | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.075310 | 0.078628 | 43.030000 | 7110.832000 |
| alpha | java-egglog | 3.868000 / 4 / 4 | 0.068125 | 0.071620 | 64.074000 | 10690.948000 |
| alpha | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.065410 | 0.069707 | 41.422000 | 6847.380000 |
| alpha | slotted-egraph | 0.000000 / 0 / 0 | 0.272627 | 0.280342 | 39.422000 | 10671.244000 |
| alpha | canonical | 0.000000 / 0 / 0 | 4.395858 | 4.711239 | 31.072000 | 1988.608000 |
| alpha | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 270.894086 | 290.365207 | 31.072000 | 3942.592000 |
| aci | raw-egraph | 0.000000 / 0 / 0 | 0.034069 | 0.036673 | 33.240000 | 5393.508000 |
| aci | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.042454 | 0.044256 | 33.240000 | 5393.508000 |
| aci | java-egglog | 0.000000 / 0 / 0 | 0.038526 | 0.039577 | 31.448000 | 5100.620000 |
| aci | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.039983 | 0.041872 | 31.448000 | 5100.620000 |
| aci | slotted-egraph | 0.000000 / 0 / 0 | 0.086806 | 0.088223 | 29.444000 | 7658.012000 |
| aci | canonical | 0.000000 / 0 / 0 | 2.421181 | 2.761654 | 22.444000 | 1436.416000 |
| aci | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 288.522483 | 305.530870 | 22.424000 | 3158.528000 |
| binder_permutation | raw-egraph | 5.402000 / 4 / 7 | 0.036551 | 0.036614 | 64.090000 | 10605.892000 |
| binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.045145 | 0.045166 | 60.466000 | 9947.932000 |
| binder_permutation | java-egglog | 5.402000 / 4 / 7 | 0.035921 | 0.037739 | 61.310000 | 10155.440000 |
| binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.039224 | 0.040327 | 57.686000 | 9497.480000 |
| binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.117022 | 0.123695 | 35.502000 | 9795.084000 |
| binder_permutation | canonical | 0.000000 / 0 / 0 | 0.830248 | 1.240855 | 37.052000 | 2371.328000 |
| binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 660.386300 | 704.449667 | 37.052000 | 4293.184000 |
| safe_prenex | raw-egraph | 0.000000 / 0 / 0 | 0.035117 | 0.035127 | 47.232000 | 7687.500000 |
| safe_prenex | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.032138 | 0.033276 | 48.232000 | 7865.500000 |
| safe_prenex | java-egglog | 0.000000 / 0 / 0 | 0.034375 | 0.034688 | 46.080000 | 7498.832000 |
| safe_prenex | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.030449 | 0.030492 | 47.080000 | 7676.832000 |
| safe_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.062275 | 0.064310 | 41.300000 | 10940.208000 |
| safe_prenex | canonical | 0.000000 / 0 / 0 | 0.591946 | 0.983948 | 29.872000 | 1911.808000 |
| safe_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 244.366168 | 252.975135 | 29.872000 | 3898.688000 |
| logical_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.070115 | 0.072592 | 72.306000 | 11612.312000 |
| logical_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.096944 | 0.102690 | 72.638000 | 11671.408000 |
| logical_normalization | java-egglog | 0.000000 / 0 / 0 | 0.056664 | 0.057497 | 60.278000 | 9707.192000 |
| logical_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.062975 | 0.063325 | 60.610000 | 9766.288000 |
| logical_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.119880 | 0.121170 | 60.264000 | 15625.348000 |
| logical_normalization | canonical | 0.000000 / 0 / 0 | 1.323093 | 1.749860 | 34.504000 | 2208.256000 |
| logical_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 644.770456 | 683.424045 | 34.432000 | 4799.168000 |
| temporal_normalization | raw-egraph | 0.000000 / 0 / 0 | 0.040206 | 0.040209 | 61.776000 | 9916.500000 |
| temporal_normalization | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.044678 | 0.044690 | 61.776000 | 9916.500000 |
| temporal_normalization | java-egglog | 0.000000 / 0 / 0 | 0.034165 | 0.035060 | 56.152000 | 9018.832000 |
| temporal_normalization | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.036099 | 0.036423 | 56.152000 | 9018.832000 |
| temporal_normalization | slotted-egraph | 0.000000 / 0 / 0 | 0.074549 | 0.076982 | 56.152000 | 14214.400000 |
| temporal_normalization | canonical | 0.000000 / 0 / 0 | 1.422280 | 1.729339 | 35.964000 | 2301.696000 |
| temporal_normalization | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 409.846545 | 425.311533 | 35.964000 | 5014.720000 |
| alpha_ac | raw-egraph | 2.752000 / 3 / 3 | 0.054438 | 0.056436 | 63.214000 | 10485.252000 |
| alpha_ac | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.062576 | 0.064863 | 51.402000 | 8458.852000 |
| alpha_ac | java-egglog | 2.752000 / 3 / 3 | 0.057724 | 0.058351 | 60.056000 | 9977.044000 |
| alpha_ac | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.054518 | 0.054685 | 48.552000 | 7991.932000 |
| alpha_ac | slotted-egraph | 0.000000 / 0 / 0 | 0.105361 | 0.111064 | 42.552000 | 11426.660000 |
| alpha_ac | canonical | 0.000000 / 0 / 0 | 1.584036 | 2.033636 | 34.228000 | 2190.592000 |
| alpha_ac | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 407.039318 | 431.324124 | 34.228000 | 4511.360000 |
| alpha_binder_permutation | raw-egraph | 3.912000 / 4 / 4 | 0.031867 | 0.034654 | 57.118000 | 9470.688000 |
| alpha_binder_permutation | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.044597 | 0.046939 | 53.986000 | 8867.304000 |
| alpha_binder_permutation | java-egglog | 3.912000 / 4 / 4 | 0.031598 | 0.031740 | 55.334000 | 9183.580000 |
| alpha_binder_permutation | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.041409 | 0.041855 | 52.202000 | 8580.196000 |
| alpha_binder_permutation | slotted-egraph | 0.000000 / 0 / 0 | 0.121380 | 0.124237 | 35.510000 | 9683.604000 |
| alpha_binder_permutation | canonical | 0.000000 / 0 / 0 | 0.844287 | 1.234387 | 31.072000 | 1988.608000 |
| alpha_binder_permutation | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 293.221147 | 308.676676 | 31.072000 | 3942.592000 |
| binder_permutation_prenex | raw-egraph | 3.824000 / 4 / 4 | 0.055166 | 0.055326 | 61.546000 | 10132.760000 |
| binder_permutation_prenex | raw-egraph-debruijn | 1.912000 / 2 / 2 | 0.162790 | 0.165160 | 58.590000 | 9580.528000 |
| binder_permutation_prenex | java-egglog | 3.824000 / 4 / 4 | 0.056240 | 0.056288 | 59.762000 | 9845.652000 |
| binder_permutation_prenex | java-egglog-debruijn | 1.912000 / 2 / 2 | 0.057395 | 0.057507 | 56.806000 | 9293.420000 |
| binder_permutation_prenex | slotted-egraph | 0.000000 / 0 / 0 | 0.078434 | 0.080753 | 40.334000 | 10948.028000 |
| binder_permutation_prenex | canonical | 0.000000 / 0 / 0 | 0.686012 | 1.104275 | 31.072000 | 1988.608000 |
| binder_permutation_prenex | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 300.273583 | 317.751487 | 31.072000 | 3942.592000 |
| ac_logical | raw-egraph | 0.000000 / 0 / 0 | 0.359536 | 0.422302 | 79.138000 | 12664.080000 |
| ac_logical | raw-egraph-debruijn | 0.000000 / 0 / 0 | 0.351037 | 0.441503 | 79.138000 | 12664.080000 |
| ac_logical | java-egglog | 0.000000 / 0 / 0 | 0.232605 | 0.290227 | 61.130000 | 9810.204000 |
| ac_logical | java-egglog-debruijn | 0.000000 / 0 / 0 | 0.262556 | 0.338933 | 61.130000 | 9810.204000 |
| ac_logical | slotted-egraph | 0.000000 / 0 / 0 | 0.450079 | 0.537463 | 61.130000 | 15749.724000 |
| ac_logical | canonical | 0.000000 / 0 / 0 | 6.246690 | 7.433256 | 32.028000 | 2049.792000 |
| ac_logical | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 494.388521 | 528.486384 | 32.028000 | 4704.704000 |
| mixed | raw-egraph | 3.504000 / 4 / 4 | 0.591461 | 0.598975 | 143.228000 | 23171.416000 |
| mixed | raw-egraph-debruijn | 1.752000 / 2 / 2 | 0.453267 | 0.466182 | 140.352000 | 22636.944000 |
| mixed | java-egglog | 3.504000 / 4 / 4 | 0.245002 | 0.248734 | 110.878000 | 18037.080000 |
| mixed | java-egglog-debruijn | 1.752000 / 2 / 2 | 0.199483 | 0.203532 | 108.002000 | 17502.608000 |
| mixed | slotted-egraph | 0.000000 / 0 / 0 | 0.208571 | 0.212285 | 93.760000 | 25364.872000 |
| mixed | canonical | 0.000000 / 0 / 0 | 1.104194 | 1.613142 | 44.728000 | 2862.592000 |
| mixed | typed-slotted-port-egraph | 0.000000 / 0 / 0 | 869.352884 | 932.103061 | 44.728000 | 6147.776000 |

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
