# P5-05 and P5-07 membership guards

The two original rows are about the membership decision on its operands. P5-05 requires a static nonemptiness proof for the false result of unary `x in none`. Its statement digest is `4252bf755653e6ab1d7954ae66372c23a5df58520d532a0dfef38b7d46ec0652`. P5-07 requires exactly the relational dual and the same authority for `NOT_IN`. Its statement digest is `da74ebe0acd1ce6b63daadf6b3b6d1abd901208b31d3e9381134dc2b5130be83`.

## From the source slot to the decision

`P505ParsedMembership.observed_false_requires_source` is exported as `ACGN.Tenth.P505.observed_false_requires_source`. It starts at a real indexed compiler row observed to return false for an ordinary unary relational value and an empty right operand. The proof recovers the actual visible slot and issuing ONE or SOME declaration through the ninth sealed-model authority. Under Alloy's original premise that the binding value satisfies its declaration, the proof derives a member of that value and disproves its containment in the empty relation. An empty relation is an explicit counterexample to forcing the same false conclusion for an arbitrary value.

`ACGN.Tenth.P507.observed_relational_duals` uses the two observed compiler rows with identical operand, type, expansion and authority coordinates. Both must belong to the checked complete instruction table. The theorem derives both the opposite decisions and their denotations. Literal true/false, a residual membership comparison, and an equivalent NO/SOME cardinality formula have distinct results in the model. The source-slot appearance has exactly the same condition in both polarities.

For the earlier canonical structural paths, `structural_sound` derives subset inclusion by induction over shared identity, empty/universal endpoints, union and intersection descent, difference and restriction. `lattice_without_proved_pairs` relates the positive conjunction and negative disjunction to the full ordered operand pair conditions, permitting omission of separately derived structural facts. These claims are about well-typed relations over a common carrier. A unary `univ` has every atom of that carrier and need not have an inhabitant. Common tuple sorts also support the relation lemmas. A separate typed binary control does not assume a unary universe covers a binary relation. Alloy rejects a binary product compared to unary `univ`, a formula on the left of `in`, and incompatible relation arities for `not in` before conversion.

## Compiler and public witnesses

`MembershipInstructions` attributes 27 production methods with JDK 17, including the exact canonical, saturation and ablation branch bodies, their operand/target symbols, the source-binding readers, original parser adapter and certified expansion helpers. Its digest is `9e02bc0537cf72f2c0b9ae90159b514375b1c5b2be88dd231abfb1805c35bdc7`. The restricted source interpreter reads Boolean tests, operand selections, returned constants, saturation assignments and the NO/SOME opcode from those methods. It enumerates three paths, two polarities, three heads for each operand and three Boolean inputs. The empty-right expansion coordinate indicates entry to the actual certified expansion under equal compatible parser arities and the route's frame conditions. Every one of the 432 decisions must equal the executable Lean table in order. Missing, duplicated, reversed and polarity-altered output each fails the check. `exact_observed_answer` proves that an accepted table's indexed observed result equals the modeled result, including the residual cases.

The canonical normalizer checks lexical nonemptiness before its optional empty-right expansion. Saturation itself has no lexical map. The raw rewriter folds an empty left operand against an empty right operand, a positively bound variable against empty, and a unary relation against `univ`. It can retain a source comparison that another engine converts to a cardinality formula or computes directly.

`MembershipDualTest` parses ordinary predicates, normalizes them via `CanonicalAlloyPipeline`, compares the same predicates under six raw configurations, and checks both Boolean references. It covers grouped operands, implicit ONE, explicit ONE and SOME, nullable LONE, SET, an unconstrained unary relation, both empty, membership in `univ`, potentially empty `univ`, user signatures named `None` and `Univ`, structural inclusion, lattice expansion, binary emptiness and two nested shadows. Foreign reads from a separately sealed adapter and an in-place operator change in an authentic declaration each withhold the affected folds. Raw stale controls use the exact current parameter term for their reference. Restoring the adapter regains the original slot.

Two features of the actual normal forms matter for interpreting the results.

* A nullable direct `x in none` normalized to `NO(x)`, and its direct `x not in none` normalized to `SOME(x)`. Some explicit negated spellings kept an `IN` or `NOT_IN` node. The witness inspects those nodes and distinguishes the engine's representative equality from the proved relational duality.
* Inside `all x: set A`, every admitted value lies in none exactly when A is empty, while the negative membership cannot hold for every binding because the empty binding is available. Inside `all x: some A`, the positive universal also holds exactly when A is empty and all admitted bindings satisfy the negative property. `shadowed_set` and `shadowed_some` derive these four outcomes directly from declaration admission. The production witness checks the enclosing canonical formulas against `no A`, false or true as applicable. The quantifier cannot be distributed over negation.

## Focused reproduction and limits

Compile `Phase5SourceRules`, ninth `P506SourceNonempty`, `Membership`, `MembershipStream`, the selected primary and `MembershipReplay` into a private module directory with Lean 4.35.0. Set `LEAN_PATH` to that directory, `ACGN_TENTH_LEAN` to the installed Lean binary and `ACGN_TENTH_PROOF` to `MembershipReplay.lean`. Compile both Java sources with the integrated ninth producer and repository libraries. Invoke the same Java main with the appropriate original requirement ID and a separate fresh output directory for each row.

```text
java -ea -Xmx620m -cp CLASSPATH is.fivefivefive.CanDis.MembershipDualTest P5-05 CHECKOUT FRESH_RESULTS
java -ea -Xmx620m -cp CLASSPATH is.fivefivefive.CanDis.MembershipDualTest P5-07 CHECKOUT FRESH_RESULTS
```

| Output | Observations | SHA-256 |
| --- | ---: | --- |
| Each instructions.tsv | 432 | `d073730ecad38191e30963e9889f2b75de831bd397571f9550fb8bc1a1c84fbc` |
| P5-05 cases.tsv | 24 | `6ddb46c9221d071c8dd8ee99e120b733d2a9a2480bd4729459866cea02202603` |
| P5-07 cases.tsv | 27 | `ca5d0c3f56dc599d96b4ccf0652dcd67765e4c4ebd577ba6b88d0c1beb242995` |

Both primary modules, the 15 common semantic theorems and eight instruction-stream theorems pass the repository's theorem census and axiom-log checks. The two primary inventories have two and three named theorems, respectively. Their combined assumptions use only `propext`, `Quot.sound` and, where reported, `Classical.choice`. The trusted boundary includes the ninth registered parser identity and sequential adapter authority, type-correct source conversion, the JDK's attributed syntax, the registered branch interpreter and the runtime. The evidence covers the literal two membership guards and their modeled relational expansions. Complete normal-form equivalence, all quantifier rewrites, arbitrary untyped trees and project-wide certification require their own obligations.
