# E-Graph Semantic Soundness Check

- Generated at: `2026-11-07T08:54:42.148072308Z`
- Checked unique predicate pairs: 4098
- Mode: union of all equivalence claims
- Threads: 16
- Claim-source run: `4b05d9e4-ed6c-4aff-8822-dbdb428216bb`
- Exact checker: `canonical-alloy-pipeline-v38-phase-local-bindings` / `typed-alloy-normal-form-adapter-v13` / `canonical-alloy-signature-v8`

This is a bounded semantic check using each model's own `check correct` command. An Alloy counterexample disproves a merge; absence of a counterexample is evidence only within that command's scope and temporal bounds.

## Results By Arm

| Arm | Claims checked | No counterexample | Counterexamples | Errors | Bounded precision |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 820 | 820 | 0 | 0 | 100.000% |
| raw-egraph-debruijn | 2160 | 2160 | 0 | 0 | 100.000% |
| java-egglog | 820 | 820 | 0 | 0 | 100.000% |
| java-egglog-debruijn | 2160 | 2160 | 0 | 0 | 100.000% |
| slotted-egraph | 2228 | 2228 | 0 | 0 | 100.000% |
| canonical | 4088 | 4088 | 0 | 0 | 100.000% |
| typed-slotted-port-egraph | 4088 | 4088 | 0 | 0 | 100.000% |

## Counterexamples

No bounded counterexamples were found.

## Targeted Rule-Level Probes

These deliberately exercise binder cases absent from the observed zero-distance corpus. A merge in a row with an Alloy counterexample is a semantic-soundness violation.

| Probe | Alloy counterexample | Raw | Raw DB | Java egglog | Egglog DB | Slotted | Canonical | Exact |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `comprehension_order_inv2` | true | false | false | false | false | false | false | false |
| `let_shadow_inv1` | true | false | false | false | false | false | false | false |
| `signature_shadow_inv3` | true | false | false | false | false | false | false | false |
| `temporal_implication_inv4` | true | false | false | false | false | false | false | false |

- `let_shadow_inv1`: detects capture during beta reduction when an inner quantifier shadows a name.
- `comprehension_order_inv2`: detects illegal permutation of comprehension columns.
- `signature_shadow_inv3`: detects confusion between a local binder and a same-named signature.
- `temporal_implication_inv4`: detects loss of the implication antecedent across temporal phases.
