# E-Graph Semantic Soundness Check

- Generated at: `2026-08-18T11:41:03.298178703Z`
- Checked unique predicate pairs: 2320
- Mode: union of all equivalence claims
- Threads: 32
- Claim-source run: `c48a105a-796c-483c-9f75-7e3a35ff1db0`
- Exact checker: `canonical-alloy-pipeline-v11-three-layer` / `typed-alloy-normal-form-adapter-v8` / `canonical-alloy-signature-v7`

This is a bounded semantic check using each model's own `check correct` command. An Alloy counterexample disproves a merge; absence of a counterexample is evidence only within that command's scope and temporal bounds.

## Results By Arm

| Arm | Claims checked | No counterexample | Counterexamples | Errors | Bounded precision |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 823 | 823 | 0 | 0 | 100.000% |
| raw-egraph-debruijn | 2163 | 2163 | 0 | 0 | 100.000% |
| java-egglog | 823 | 823 | 0 | 0 | 100.000% |
| java-egglog-debruijn | 2163 | 2163 | 0 | 0 | 100.000% |
| slotted-egraph | 2162 | 2162 | 0 | 0 | 100.000% |
| canonical | 2316 | 2316 | 0 | 0 | 100.000% |
| typed-slotted-port-egraph | 2317 | 2317 | 0 | 0 | 100.000% |

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
