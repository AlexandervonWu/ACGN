# E-Graph Semantic Soundness Check

- Generated at: `2026-08-07T14:05:35.118959350Z`
- Checked unique predicate pairs: 6591
- Mode: union of all equivalence claims
- Threads: 32

This is a bounded semantic check using each model's own `check correct` command. An Alloy counterexample disproves a merge; absence of a counterexample is evidence only within that command's scope and temporal bounds.

## Results By Arm

| Arm | Claims checked | No counterexample | Counterexamples | Errors | Bounded precision |
| --- | ---: | ---: | ---: | ---: | ---: |
| raw-egraph | 4482 | 4482 | 0 | 0 | 100.000% |
| java-egglog | 5259 | 5259 | 0 | 0 | 100.000% |
| slotted-egraph | 6574 | 6574 | 0 | 0 | 100.000% |
| canonical | 6571 | 6571 | 0 | 0 | 100.000% |

## Counterexamples

No bounded counterexamples were found.

## Targeted Rule-Level Probes

These deliberately exercise binder cases absent from the observed zero-distance corpus. A merge in a row with an Alloy counterexample is a semantic-soundness violation.

| Probe | Alloy counterexample | Raw | Java egglog | Slotted | Canonical |
| --- | --- | --- | --- | --- | --- |
| `comprehension_order_inv2` | true | false | false | false | false |
| `let_shadow_inv1` | true | false | false | false | false |
| `signature_shadow_inv3` | true | false | false | false | false |
| `temporal_implication_inv4` | true | false | false | false | false |

- `let_shadow_inv1`: detects capture during beta reduction when an inner quantifier shadows a name.
- `comprehension_order_inv2`: detects illegal permutation of comprehension columns.
- `signature_shadow_inv3`: detects confusion between a local binder and a same-named signature.
- `temporal_implication_inv4`: detects loss of the implication antecedent across temporal phases.
