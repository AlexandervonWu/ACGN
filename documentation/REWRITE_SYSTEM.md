# CanDis Rewrite System

This document is the implementation-level summary of the equivalence theory
used by CanDis. It describes how an Alloy predicate is transformed into a
temporal tree of prenex normal forms whose matrices are saturated slotted
e-graphs.

The executable normalization described here is the **Fast Rewrite IR**. It is
a co-maintained, high-throughput artifact path and directly supplies the
established repair metric. The **Certificate-Integrated IR** consumes the same
repaired phases through `TheoryAlloyAdapter`, represents operators with typed
ports, and admits the corresponding A, AC, ACI, binder, and congruence actions
only with checked evidence. Certificate integration strengthens the
fail-closed semantic-assurance boundary; it does not replace this rewrite IR or
define a different repair objective.

The rewrite relation is intentionally incomplete. Two predicates at canonical
distance zero are equal under the rules below; CanDis does not claim that every
pair of semantically equivalent Alloy predicates rewrites to distance zero.

## Frozen bootstrap and adaptive misses

The rules in this document now form immutable bootstrap theory `R0` for the
adaptive equivalence layer. Do not extend this inventory when a later corpus
pair is semantically equivalent but remains at positive repair distance.
Instead, submit that pair to the optional in-flight augmenter described in
[`docs/adaptive-equivalence-augmentation.md`](../docs/adaptive-equivalence-augmentation.md).
It records exact local evidence, proposes guarded anti-unified schemas from at
least two witnesses, requires independent Alloy and Lean validation, and keeps
equality admission separate from rewrite orientation. The default canonical
pipeline remains R0-only.

## Canonical Object

For an input predicate `P`, canonicalization produces:

```text
Canonical(P) = TemporalTree(Phase_0, ..., Phase_n)

Phase_i = (temporal label, parameter bindings, prenex bindings,
           saturated matrix e-graph, child phases)
```

Each prenex binding is a `QuantiVar` tuple:

```text
(slot, source name, quantifier, cardinality, primitive carrier,
 disjointness class, binding path)
```

The canonical slot is used for equality and distance. The source name is kept
only for diagnostics, backtranslation, and readable edit paths.

## Ordered Pipeline

Rule order is part of the construction. The production driver first builds the
whole temporal skeleton, then normalizes it parent-first. It applies the
following sequence:

1. Build the MASG and translate it into `EGraphNode` objects.
2. Split each temporal operand into its own `NormalForm`; leave a temporal
   reference in the parent matrix.
3. Remove internal `<END>` markers and dangling wrappers.
4. Alpha-normalize every binder using scope-aware canonical slots.
5. Beta-reduce `let` expressions with capture avoidance.
6. Eliminate formula implication, IFF, and Boolean ITE.
7. Push matrix-local negations to NNF, including quantifier duals.
8. Prenex formula quantifiers within the current temporal phase.
9. Encode primitive type, cardinality, and disjointness in `QuantiVar`; move
   only necessary complex-domain membership guards into the matrix.
10. Eliminate any branch connectives introduced by guards and run NNF again.
11. Flatten and order associative operators according to their arity law.
12. Saturate matrix e-classes to a bounded fixed point and register compatible
    binding permutations.
13. Rewrite negated temporal references by dualizing their child-phase labels
    and negating the child matrices.
14. Recursively normalize those child phases with the parent's bindings in
    scope.
15. After the full temporal tree is normalized, discard unreachable e-classes.

Quantifiers never move across a temporal boundary. A descendant phase may refer
to an ancestor slot, but binding ownership remains in the phase where the
binder was introduced.

## Structural Rewrites

### Alpha normalization

Every lexical binder receives a fresh internal slot before substitution or
prenexing. References are resolved against lexical scope, so shadowed source
names remain distinct. The final `_qN` slot and its binding-path-derived
De Bruijn key are independent of the source variable spelling.

Consequently:

```alloy
all x: S | P[x]
all y: S | P[y]
```

have the same canonical binding and matrix shape.

### Let beta reduction

```text
let x = E | P[x]  ->  P[E]
```

Substitution is capture-avoiding. Inner `let`, quantified declarations,
predicate parameters, and function parameters shadow an outer binding.

### Branch connective elimination

These rules run before prenexing so implicit negative branches affect the
quantifiers correctly:

```text
A implies B          ->  (not A) or B
A iff B              ->  ((not A) or B) and ((not B) or A)
if A then B else C   ->  (A and B) or ((not A) and C)
```

The ITE rule applies to formula-valued ITEs. Expression-valued ITEs are not
silently rewritten as Boolean formulas.

## Negation Normal Form

### Boolean rules

```text
not (not A)          ->  A
not (A and B)        ->  (not A) or (not B)
not (A or B)         ->  (not A) and (not B)
not true             ->  false
not false            ->  true
```

The binary rules generalize over the flexible-arity child list.

### Atomic duals

| Operator | Negated form |
| --- | --- |
| `=` | `!=` |
| `!=` | `=` |
| `>` | `<=` |
| `>=` | `<` |
| `<` | `>=` |
| `<=` | `>` |
| `in` | `not in` |
| `not in` | `in` |
| unary `some` | unary `no` |
| unary `no` | unary `some` |

`NOT_GT`, `NOT_GTE`, `NOT_LT`, and `NOT_LTE` parser opcodes are reduced to the
corresponding comparison when their surrounding negation is consumed.

### Temporal duals

```text
not always A             ->  eventually (not A)
not eventually A         ->  always (not A)
not historically A       ->  once (not A)
not once A               ->  historically (not A)
not (A until B)           ->  (not A) releases (not B)
not (A releases B)        ->  (not A) until (not B)
not (A since B)           ->  (not A) triggered (not B)
not (A triggered B)       ->  (not A) since (not B)
```

Binary temporal operands are stored as separate left and right phases, for
example `UNTILL` and `UNTILR`. Distance and backtranslation recover the natural
binary operator. `BEFORE` and `AFTER` are not assigned an unsupported negation
dual by this system.

## Quantifier Rewrites

### Negation duals

```text
not (all x: S | P)    ->  some x: S | not P
not (some x: S | P)   ->  all x: S | not P
not (no x: S | P)     ->  some x: S | P
not (one x: S | P)    ->  notone x: S | P
not (lone x: S | P)   ->  notlone x: S | P
no x: S | P           ->  all x: S | not P
```

`NOTONE` and `NOTLONE` are internal `QuantiVar` quantifiers. Negating them gives
`ONE` and `LONE`, respectively. A negation consumed by `ONE`, `LONE`, `NOTONE`,
or `NOTLONE` does not also negate the matrix.

### Strict phase-local prenexing

After branch elimination and NNF, every prenexable formula quantifier is moved
to the binding list of its current temporal phase. `SUM` and
`COMPREHENSION` remain local because they produce or delimit expressions rather
than ordinary formula prefixes.

The basic movement laws, with `x` absent from `FV(Q)`, include:

```text
(some x: S | P) and Q  <=>  some x: S | (P and Q)
(all x: S | P) or Q    <=>  all x: S | (P or Q)
```

Scope-aware alpha slots enforce the non-capture side condition. In contexts
where empty carriers make direct movement unsafe, the binder is relativized to
`univ` and its original domain is retained as a local matrix guard. This makes
strict prenexing possible without assuming that `S` is nonempty.

### Domains, cardinality, and disjointness

For a primitive domain whose type matches the variable carrier:

```alloy
all x: one Person | P[x]
```

the `ONE` cardinality and `Person` carrier are stored in `QuantiVar`. No
redundant `x in one Person` matrix term is emitted.

For a complex domain such as `(S2 :> F).x`, the binding keeps a primitive
carrier and the matrix receives the required membership guard. Universal guards
use implication; existential-style guards use conjunction:

```text
all x: D | P     ->  all x: carrier(D) | (x in D implies P)
some x: D | P    ->  some x: carrier(D) | (x in D and P)
```

Empty source domains are folded before retaining a binding:

```text
all x: none | P   -> true
no x: none | P    -> true
lone x: none | P  -> true
some x: none | P  -> false
one x: none | P   -> false
```

The shared ablation normalizer also folds quantified matrices whose truth value
is independent of the carrier:

```text
all x: S | true       -> true
some x: S | false     -> false
no x: S | false       -> true
one x: S | false      -> false
lone x: S | false     -> true
notone x: S | false   -> true
notlone x: S | false  -> false
```

Cases such as `some x: S | true` and `all x: S | false` are retained because
their result depends on whether `S` is empty.

Each `disj` declaration receives its own positive disjointness-class identifier.
Thus two separate declarations remain distinct even when their carrier types
match.

## Flexible-Arity Algebra

Operators are assigned one of three algebraic representations:

| Alloy operation | Law | E-node collection |
| --- | --- | --- |
| formula `and`, formula `or` | ACI | `SET` |
| relational union `+`, intersection `&` | ACI | `SET` |
| integer addition, multiplication | AC | `BAG` |
| relational join `.`, product `->` | A | `SEQUENCE` |
| equality and inequality | C only | fixed arity |
| all other operators | none unless listed | fixed/structural arity |

The laws mean:

- `A` (associative): nested occurrences flatten, source order is retained.
- `AC` (associative and commutative): nested occurrences flatten and operands
  sort canonically; duplicates remain significant.
- `ACI` (associative, commutative, and idempotent): nested occurrences flatten,
  operands sort canonically, and duplicate e-class invocations are removed.

Examples:

```text
(A and B) and A       -> SET[AND]{A, B}
(R + S) + R           -> SET[PLUS]{R, S}
(i + j) + i           -> BAG[IPLUS]{i x 2, j}
(A.B).C               -> SEQUENCE[JOIN]{A, B, C}
```

A BAG records repeated child e-class invocations and exposes their
cardinalities. It must not collapse duplicates merely because their e-class IDs
match. A SEQUENCE never sorts its children.

## Saturation Simplifications

After variadic normalization, each reachable matrix e-class is rewritten to a
bounded fixed point, currently at most 32 local iterations. Rewritten shapes
are retained as alternatives in the same e-class.

### Boolean identities and complements

```text
A and A              -> A
A or A               -> A
A and true           -> A
A or false           -> A
A and false          -> false
A or true            -> true
A and not A          -> false
A or not A           -> true
```

Complement detection also recognizes atomic duals such as `x in S` versus
`x not in S` when their operands are the same e-class invocations.

### Relational identities

```text
x in none            -> false
x in univ            -> true
R + none             -> R
R & none             -> none
R + R                -> R
R & R                -> R
```

The last two rules follow from the ACI/SET representation. They do not apply to
AC/BAG arithmetic operators.

### Boolean and relational lattice normalization

The Boolean and relational ACI lattices use the same four absorption schemas:

```text
A and (A or B)       -> A
A or (A and B)       -> A
R & (R + S)          -> R
R + (R & S)          -> R
```

For a flexible-arity owner, each schema is a local submultiset rewrite. It
removes only the matched dual-container operand and retains every unrelated
sibling:

```text
X and A and (A or B) and Y  ->  X and A and Y
X + R + (R & S) + Y         ->  X + R + Y
```

The source-rule pass repeats this strictly reducing step before the certified
matrix snapshot. This matters when one variadic parent contains multiple
independent absorption redexes. Distributive expansions are oriented in the
factored direction so the same pass cannot oscillate:

```text
(A and B) or (A and C)  ->  A and (B or C)
(R & S) + (R & T)       ->  R & (S + T)
```

The dual Boolean and relational directions are admitted under the same exact
operator/type guards. See the P0 incident record in
[`docs/section3-repair-audit/p0-variadic-absorption-incident.md`](../docs/section3-repair-audit/p0-variadic-absorption-incident.md).

### Parser-certified restriction and composition laws

The following relational laws run only when the parser-authenticated exact
occurrence types independently validate every source and constructed node.
They preserve JOIN sequence order and composed slot invocations:

```text
univ <: R             -> R
Carrier <: R          -> R       when exact restriction typing proves no narrowing
R :> univ             -> R
R :> Carrier          -> R       under the same exact endpoint proof
none <: R             -> none
R :> none             -> none
D <: none             -> none
none :> C             -> none

(D <: R).S            -> D <: (R.S)    when arity(R) >= 2
R.(S :> C)            -> (R.S) :> C    when arity(S) >= 2
(R :> M).S            -> R.(M <: S)
(M <: R1).S           -> R1.(M <: S)   when arity(R1) = 1
R.(S1 :> M)           -> R.(M <: S1)   when arity(S1) = 1
R1 :> M               -> M <: R1       when arity(R1) = 1
```

The schemas orient surviving endpoint guards outward and a guard on an
existentially eliminated JOIN boundary onto the right adjacent operand. A
unary operand's only coordinate is such a boundary, not a surviving endpoint.
JOIN associativity extends the rules through a longer chain. Moving a guard to
the opposite endpoint, changing the guard invocation, reordering JOIN operands,
or relying on synthetic type labels is not admitted.

For an authenticated empty binary relation `E`, `~E` and `^E` normalize to
typed empty while `*E` normalizes to authenticated `iden`.

Parser-authenticated relation comparisons also close under certified operand
identity, including identity already established by an ACI container:

```text
R in R                 -> true
R = R                  -> true
R not in R             -> false
R != R                 -> false
```

The two operands must have the same certified invocation. Merely sharing a
surface spelling, type label, or ordered-container payload does not authorize
the rule.

For parser-authenticated equal-arity relation expressions, structural subset
proofs and the two lattice adjunctions are also normalized:

```text
R in R + S                    -> true
R & S in R                    -> true
R - S in R                    -> true
(D <: R) in R                 -> true
(R :> C) in R                 -> true
(R1 + ... + Rn) in T          -> (R1 in T) and ... and (Rn in T)
R in (T1 & ... & Tn)          -> (R in T1) and ... and (R in Tn)
(R1 + ... + Rn) not in T      -> (R1 not in T) or ... or (Rn not in T)
R not in (T1 & ... & Tn)      -> (R not in T1) or ... or (R not in Tn)
```

The structural proof composes these inclusions recursively. The opposite
directions are not rules: `R in S + T` is not generally `(R in S) or
(R in T)`, and `R & S in T` is not generally `(R in T) or (S in T)`.

### Derived implication identities

Implication is normally eliminated earlier. The saturation layer also handles
it defensively:

```text
false implies A      -> true
true implies A       -> A
A implies true       -> true
A implies false      -> not A
```

## Slotted E-Graph Equivalence

An e-node does not embed child trees directly. It contains invocations of child
e-classes:

```text
ENode(op, [EClassRef(classId, slotRenaming), ...])
```

`RenamedIdUnionFind` performs e-class unions while composing slot renamings.
Each e-class also owns a finite `SlotPermutationGroup`. Compatible adjacent
bindings with the same quantifier, cardinality, primitive type, and
disjointness class contribute swap generators; closure of those generators
represents every legal binding permutation. For example:

```alloy
all x, y: S | f[x, y]
all x, y: S | f[y, x]
```

are equivalent under the generated two-slot permutation group.

Slot sets are recomputed after every shape change. Therefore a rewrite such as
`A or not A -> true` removes the now-unused slots instead of leaving redundant
bindings attached to the constant e-class.

## Canonical Invariants

After normalization of a well-formed predicate:

- no internal `<END>` node remains in a matrix;
- formula-valued `let`, `IMPLIES`, `IFF`, and Boolean `ITE` are eliminated;
- lifted formula declarations are represented by flat `QuantiVar` lists;
- `SUM` and `COMPREHENSION` declarations remain local;
- every retained matrix negation is above an irreducible or unsupported atom;
- no quantifier crosses a temporal phase;
- source names do not affect alpha-equivalence;
- separate `disj` declarations have separate classes;
- SET children are unique, BAG multiplicity is retained, and SEQUENCE order is
  retained;
- e-class alternatives and slot symmetries are considered by canonical matrix
  distance.

## Relation To Distance

The rewrite system defines the zero-cost equivalences used by
`CanonicalDistance`. The complete metric is:

```text
D = D_temporal + D_bindings + D_matrix
```

Alpha renaming and the rewrites above cost zero. A temporal edit, a binding
insertion/deletion/modification, or an unmatched matrix edit contributes to the
corresponding component. A binding modification changes any of quantifier,
primitive type, cardinality, or disjointness class at unit cost.

## Implementation Map

- Production orchestration: [`IRAgent.java`](../src/is/fivefivefive/CanDis/ir/IRAgent.java)
- Ordered normalization and prenexing: [`NormalForm.java`](../src/is/fivefivefive/CanDis/core/NormalForm.java)
- Slotted e-node saturation: [`EGraphNode.java`](../src/is/fivefivefive/CanDis/core/EGraphNode.java)
- Binding tuples: [`QuantiVar.java`](../src/is/fivefivefive/CanDis/core/QuantiVar.java)
- Renamed-ID union-find: [`RenamedIdUnionFind.java`](../src/is/fivefivefive/CanDis/core/RenamedIdUnionFind.java)
- Permutation closure: [`SlotPermutationGroup.java`](../src/is/fivefivefive/CanDis/core/SlotPermutationGroup.java)
- Shared ablation rules: [`AlloyRewriteSystem.java`](../src/is/fivefivefive/CanDis/core/egraph/AlloyRewriteSystem.java)
- Distance extraction: [`CanonicalDistance.java`](../src/is/fivefivefive/CanDis/core/CanonicalDistance.java)

The shared ablation rule set is versioned as
`canonical-equivalences-v3-explicit-laws`. The
production canonicalizer adds temporal partitioning, strict phase-local
prenexing, binding tuples, renamed slots, and permutation groups around that
core equivalence vocabulary.

## Proof Connectivity

The immutable `R0` rewrite inventory is governed directly by
[`rewrite-rule-traceability.tsv`](../docs/section3-repair-audit/rewrite-rule-traceability.tsv).
It contains 61 semantic rule families: all 24 rules exported by the shared
ablation rewrite system and 37 production-only binder, alpha, and relational
families. Every row names at least one independent Lean theorem, every Java
method that realizes the family, and at least one executable regression entry
point.

The Java declarations carry `@LeanVerifiedRewrite` rule IDs.
`RewriteRuleTraceability` checks the connection in both directions: every
catalog Java reference must have the matching annotation, and every annotation
must point back to a catalog row. It also rejects a missing Lean theorem, a
definition substituted for a theorem, a missing test method, a non-approved
row, any forbidden Lean proof escape, or disagreement between the 24 catalog
bootstrap names and `JavaEgglog.ruleNames()`. The bounded assurance runner
executes this gate before the semantic regressions and compiles every governed
Lean file.

The broader claim-level obligations remain in
[`requirements-traceability.tsv`](../docs/section3-repair-audit/requirements-traceability.tsv).
`Section3AssuranceTraceability` additionally checks their claim hashes,
implementation and test declarations, evidence classes, and exact formal-file
inventory.

This connection has a deliberately exact claim boundary. `PROVED` means the
listed semantic equation or finite obligation was proved in Lean without
`sorry`, `admit`, `axiom`, or `unsafe`. `DIRECT` means the named Java
path was exercised through its parser/type/provenance guards. It does not mean
Lean verified Java bytecode or that every possible Alloy parser input has been
exhausted. Open broader refinement diagnostics remain open in the generated
assurance catalog rather than being promoted by a rewrite-level proof.

## Executable Checks

The principal regression suites are:

```bash
java -cp '/tmp/acgn-build:lib/*' is.fivefivefive.CanDis.EGraphSaturationTest
java -cp '/tmp/acgn-build:lib/*' is.fivefivefive.CanDis.ablation.EGraphAblationTest
java -cp '/tmp/acgn-build:lib/*' is.fivefivefive.CanDis.CanonicalBacktranslatorTest
java -cp '/tmp/acgn-build:lib/*' is.fivefivefive.CanDis.RewriteRuleTraceability .
```

`EGraphSaturationTest` and `EGraphAblationTest` cover branch negation,
quantifier duals, strict prenexing, empty domains, constant quantified bodies,
alpha-equivalence, binding permutations,
disjointness classes, A/AC/ACI behavior, BAG multiplicity, tautologies, and
temporal dualization.

## Boundary Of The Theory

CanDis is a canonicalizer and structural distance engine, not an Alloy theorem
prover. It does not infer arbitrary relational algebra, transitive-closure
identities, user-defined predicate semantics, or solver-level equivalence.
Unsupported operators remain structural. A zero distance is evidence of
equivalence under this documented theory; bounded Alloy checking remains the
semantic validation mechanism.
