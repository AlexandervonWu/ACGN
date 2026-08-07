# Canonical-Only Equivalences

This report filters the current ablation run to pairs for which the canonical
distance is zero while the slotted e-graph does not put the predicates in the
same e-class. There are 26 such pairs: 16 labeled `CORRECT` and 10 labeled
incorrect.

## Label-Confirmed Equivalences

| Source | Main additional canonical normalization |
| --- | --- |
| `classroom_rl/correct/GRP85rwsHuKm8zhkx_inv11.als` | `not some R` to `no R` after implication elimination |
| `classroom_rl/correct/TJXPvBgM5AHwvorzS_inv11.als` | `not some R` to `no R` after implication elimination |
| `classroom_rl/correct/qMkSypneHnbzhKpuR_inv6.als` | `not no R` to `some R` |
| `lts/correct/8uTw54mmMHWM6qj3L_inv1.als` | quantified negation plus `not no R` to `some R` |
| `lts/correct/rJPtqFiHsbCzBgCAu_inv1.als` | quantified negation plus `not no R` to `some R` |
| `lts/correct/viZeRLo7kTSfXQ6zE_inv4.als` | beta reduction and flattening equivalent same-domain declaration groups |
| `productionLineNew/correct/AGohzw2pbtqJDxFEc_inv5.als` | implication elimination plus `not some R` to `no R` |
| `productionLine_v2/correct/2BNBMcc7uBfj3zgNC_inv4.als` | `not no R` to `some R` |
| `productionLine_v2/correct/CHSzeMXJNwcpXtNz6_inv5.als` | implication elimination plus `not some R` to `no R` |
| `productionLine_v2/correct/HaN259F3Ti2vFScWr_inv4.als` | `not some R` to `no R` |
| `productionLine_v2/correct/RvbXi4j6gYaS8ZAh9_inv7.als` | implication elimination plus `not some R` to `no R` |
| `trainStationNew/correct/ATSGF4ogkW7WCRRSR_inv9.als` | implication elimination and cardinality polarity normalization |
| `trainStationNew/correct/JurcKCg9wB2X48g6k_inv1.als` | `not no R` to `some R` |
| `trainStationNew/correct/Q2YYR7QmX2DLN5iDw_inv1.als` | `not no R` to `some R` |
| `trainStationNew/correct/u6Jn8CAM4z9rkjMxA_inv3.als` | complementary operands of `iff` plus cardinality polarity normalization |
| `trash_ltl/correct/WCmW6XqHcDpTMcHzX_inv16.als` | redundant typed-domain antecedent across a temporal phase |

The `lts/inv4` pair is semantically equivalent, but its printed canonical IR is
also lossy: both matrices become `s in i`, omitting the closure and relation
comprehension. It therefore should not be treated as positive evidence for the
soundness of that particular merge.

## Incorrect Equivalences

| Source | Status | Failure mode |
| --- | --- | --- |
| `trash_fol/both/zqAktmMuWYgwS4Mzu_inv2.als` | `BOTH` | local binder `Trash` is confused with global signature `Trash`; the quantifier is discarded |
| `trash_ltl/under/4k53NfRpJjdZxHJrZ_inv12.als` | `UNDERCONSTRAINED` | implication antecedent is lost when `always` is extracted into another phase |
| `trash_ltl/under/7rD4MERBSEKTL4gBd_inv12.als` | `UNDERCONSTRAINED` | implication antecedent is lost when `always` is extracted into another phase |
| `trash_ltl/under/Bk6zyS4GmGBxziabr_inv12.als` | `UNDERCONSTRAINED` | negated implication antecedent is lost when `always` is extracted into another phase |
| `trash_ltl/under/LAdeCajAbFbS9rtjn_inv12.als` | `UNDERCONSTRAINED` | implication antecedent is lost when `always` is extracted into another phase |
| `trash_ltl/under/PjtzPSLM57jJJZExo_inv12.als` | `UNDERCONSTRAINED` | implication antecedent is lost when `always` is extracted into another phase |
| `trash_ltl/under/WakmHvGhLY7dz5mP7_inv12.als` | `UNDERCONSTRAINED` | implication antecedent is lost when `always` is extracted into another phase |
| `trash_ltl/under/d95FTPaYmvChpJYGW_inv12.als` | `UNDERCONSTRAINED` | implication antecedent is lost when `always` is extracted into another phase |
| `trash_ltl/under/muiF9M33YEp7vfvu9_inv12.als` | `UNDERCONSTRAINED` | implication antecedent is lost when `always` is extracted into another phase |
| `trash_ltl/under/vbKNCFFWy9EtCXRNh_inv12.als` | `UNDERCONSTRAINED` | implication antecedent is lost when `always` is extracted into another phase |

For the shadowing pair, both current canonical IRs print as `File in Trash`.
For the temporal pairs, both current canonical IRs contain an `EVENTUALLY`
normal form equivalent to `SOME f : one File . true` and a separate `ALWAYS`
normal form containing `f in Trash`. The original implication dependency is no
longer represented.
