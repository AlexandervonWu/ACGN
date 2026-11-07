# Fast / Certificate-Integrated Distance Parity Audit

## Frozen Baseline

The preliminary result package was committed and pushed as
`c07f74bfaa7bb56e3e7a7224fa731a9b8ab518c6`. The underlying natural run is
`03817f3e-1542-4ce1-98b2-753bd2b320d1`, produced from
`3ef7d93bcab87ecd30ffba4c02e01c690981a137`. None of its measurements are replaced
by this investigation or the subsequent working-tree repairs.

The read-only inventory covers all 61,598 successful paired-oracle comparisons:
40,870 distances agree, 12,951 are larger in Certificate-Integrated, and 7,777
are larger in Fast. Thus 20,728 rows (33.65%) disagree, although **every paired
zero decision agrees**. The summed signed difference is only 3,180, explaining
why the means look close. Per-instance differences range from -32 to +15
(Certificate-Integrated minus Fast). There are 20,726 matrix-component,
19 temporal-component and five quantifier-component disagreements; these
component populations overlap. The separate ablation stage reproduces exactly
the same mismatch inventory and distances.

For the 42,386 incorrect-to-any-truth rows, 27,545 nearest distances agree,
9,627 are larger in Certificate-Integrated, and 5,214 are larger in Fast.
Neither arm has an incorrect zero. These are independent minima over the truth
pool: the winning truth need not be the same, so they are not all same-pair
comparisons.

The correct-pool zero reports have **282 certified-only zeroes and two Fast-only
zeroes**, not just 280 additional equalities. All 284 differences were replayed
from their original corpus sources, in both argument directions, with identical
distances to the archive. The net aggregate gain of 280 concealed the reverse
direction. The 13 selected Alloy checks (two reductions and one representative
from each of 11 question/direction groups) found no counterexample at scope 4.
These bounded checks are not universal proofs.

## Concrete Mechanisms

### P-01: Fast ACI Keys Retain Presentation Details

278 of the certified-only correct-pool cases involve duplicate comparison
atoms and/or insertion-order-sensitive slot-map keys. A small example is
`duplicate-atoms.als`:

```alloy
all p:P | p not in A or p not in B
all p:P | (p in A implies p not in B) and (p in B implies p not in A)
```

Both mean the same thing. The second normalizes to two equal disjunctions,
but explicit NOT_IN retains `BOP_NOT_IN` while negation-derived NOT_IN has no
source label. `EGraphNode.appendSemanticHead` includes that label in
`invocationKey`; `FastComparison.copy` previously erased unary-test and Boolean
container labels, but not these comparison labels. Deduplication keeps both
operands. Fast charges 15; certified projection deduplicates them and charges 0.
Other witnesses retain a duplicate IN atom (76 socialMedia/inv3 pairs, cost 3)
or NOT_IN over a product (24 trash_fol/inv6 pairs, cost 5).

Erasing comparison labels alone does not close the production-line cases.
`invocationKey` and `invocationSortKey` append a map using `Map.toString`:
commuting disjuncts changes slot-map insertion order even when every mapping
entry is identical. The existing container comparison key instead composes
maps to their leaves and does not assign identity to this ordering. A focused
post-label-repair replay exposed this second contributor before the final
Fast coverage patch.

The violated parity condition is **consistent semantic identity between
comparison and ACI deduplication**: heads that the comparator identifies must
not remain distinct merely because one came from a different parser spelling.
The repair must preserve operator, exact type, slot, field and call identity.
This is presentation normalization of existing laws, not another logical axiom.

### P-02: Matrix-Local ALL Declaration Grouping

The other four certified-only zeroes are socialMedia/inv1 pairs. One writes
`all x,y:User | ...`; another writes `all x:User,y:User | ...`. They remain
matrix-local because of their surrounding formula. Fast alpha-renames the
coordinates, but previously normalized declaration grouping only inside
comprehensions. Certified `RepairProjection.canMergeLocalDeclarations` merges
adjacent non-disjoint declarations with equal projected domains. Fast charges
5 for the extra declaration/domain presentation; certified charges 0.

Witness: `socialMedia/correct/73534DjxruC4QihSp_inv1.als` against
`socialMedia/correct/aoDFSRzH2a9akWy68_inv1.als`. Domain, coordinate order,
disjointness and temporal barriers must remain meaningful.

### P-03: Certified Whole-Chain Guard Misses Valid Partial Rotations

Both Fast-only zeroes are classroom_rl/inv12. The paired student sources are:

- `qnxyu7R5W48bktkkJ_inv12.als` / `rFKSTy9XyDT6hQKKA_inv12.als`;
- `DTvPvFQrJCN5rrmEe_inv12.als` / `f6HNybZwPFRfocGYW_inv12.als`.

The shared difference is `Teaches.(Groups.Group.Person)` versus
`((Teaches.Groups).Group).Person`. Fast returns 0, certified returns 8.
`partial-join.als` reduces this to relations `r:A->B`, `s:B->C->D` and unary
sets C,D: `r.((s.D).C)` versus `((r.s).D).C`.

Fast applies two individually guarded rotations: the first middle relation is
`s.D` (binary), then the middle relation is `s` (ternary). Both are sound.
Certified `TheoryAlloyAdapter.dependentChainInput` recursively collects the
entire same-op tree. The flat operand list `[r,s,D,C]` has unary D in an interior
position, so `DependentChainTheory.requireSoundFlattening` rejects whole-list
flattening. Fallback construction keeps different subtrees; one side projects
as `JOIN(r,JOIN(JOIN(s,D),C))`, the other as `JOIN(JOIN(r,s,D),C)`.

The whole-chain guard is correct and must stay. The missing coverage is
**composition of source-linked, locally guarded rotations**, not unrestricted
JOIN associativity. `IncidentLaws.partial_join` proves the reduced relational
equality for arbitrary sets. This identifies a certified completeness gap,
not a demonstrated Fast false equality.

### P-04: Different Result-Type Head Costs

Natural witness: `classroom_rl/over/Se6vis3cGzgX7GkN3_inv5.als`, comparing
`some Teacher.Groups` and `some Teacher.Teaches`. Baseline Fast charges 1,
certified 2. `type-cost.als` reduces the same mechanism.

`CanonicalDistance.nodeUpdateCost` previously compared opcodes and atom/call
identity but ignored derived operator result types. Certified
`RepairProjection.repairSemanticPayload` contains the exact result GraphType
and `QuotientRepairDistance.MatrixDistanceContext.updateCost` compares it.
The field edit and changed JOIN result type therefore cost two distinct node
updates on the certified path. This is a **cost-policy mismatch**, separate
from which equalities either canonicalizer knows. The author has requested
type-aware Fast costs; the repair and proof correspondence are in
[IMPLEMENTATION.md](IMPLEMENTATION.md).

### P-05: Binary Trees Versus Flat Sequence Edit Units

`chain-cost.als` compares `all a:A | a not in (a.r).^r` with
`all a:A | a not in a.^r`. Fast charges 3; certified charges 1. In the certified
flat sequence `[a,r,^r]`, removing r costs one operand. Fast still represents
the left side as nested binary JOIN and uses whole-subtree operand edits.
This also occurs in `productionLine_v1/correct/Nc6rBGbJRWcFSpGY8_inv2.als`.

Sound reassociation alone does not make these geometries identical. A shared
cost model needs the same sound representation alternatives and the same
minimum search, including mixed-origin representative pairs.

### P-06: Different Live Temporal Projections

Fast `CanonicalDistance.temporalTree` traverses retained NormalForm temporal
children in source order; `NormalForm.fastComparisonView` retains that list.
Certified `CanonicalPhaseProjection` follows canonically ordered references
in the projected matrix, dropping phases eliminated by the certified quotient
and reindexing their bindings. Subsequent declaration alignment is therefore
also over potentially different phase sequences.

Replayed examples: classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als has temporal
costs 2 versus 1; trash_ltl/over/C8fwykgcniKQBrybn_inv12.als has quantifier costs
2 versus 1; trash_ltl/both/oivT9pBECZFsYCGWq_inv18.als has temporal costs 1
versus 2. No cross-phase binder identity is licensed to collapse in a repair.

## Separate Export Incident

The archived augmented `correct/classroom_fol/inv3.als` is not parsable: after
its module line it starts `Tutors : set Person,`, missing `sig Person {`.
`Alloy4FunAugmenter.writeAugmentedFiles` unconditionally strips the first line
of `group.prelude()` as though it were always a module declaration. The
original source starts with a signature. This is a real artifact-export defect,
but does not explain these measured distances: production preparation uses
the original corpus, and all 284 differences replay there. The failed export
probe is retained externally; no archived exported file has been edited.

## Checked Repair Increment

The fresh-build replay in [after-replays.jsonl](evidence/after-replays.jsonl)
completed all 293 probes. All 282 previously certified-only correct-pool
zeroes now have Fast distance 0 as well. The two Fast-only partial-JOIN pairs
still return Fast 0 / certified 8; P-03 remains open. The reduced and natural
result-type witnesses now both return 2 / 2. Binary/flat and temporal witnesses
retain their documented differences; this is not a full-corpus parity claim.

Before/after checks matched both source hashes, retained matrix diagnostics,
certified projection diagnostics, observation-equality decisions and certified
distance components for every probe. Both argument directions agree. All 13
selected scope-4 solver checks again found no counterexample. Diagnostic JSON
equality is bounded evidence, not a proof that every internal field is unchanged.

The [bounded regression log](evidence/bounded-tests.log) records 36 result-type,
208 Fast parity, 2,266 quotient-distance and 2,041 pipeline checks, plus a passing
saturation suite. Both standalone Lean files compile (14 theorems total).
[validation.json](evidence/validation.json) binds the changed Java implementation
and tests, Lean files, runner and resulting evidence to their SHA-256 hashes.
The result-producing historical data remains unchanged. No new full-corpus
performance measurement or release has been produced by this increment.

## Evidence And Limits

[summary.json](evidence/summary.json) pins the six measurement inputs by SHA-256.
[paired-mismatches.csv](evidence/paired-mismatches.csv) lists every paired
distance mismatch and its components. The correct-pool JSON identifies all 284
source pairs; [baseline-replays.jsonl](evidence/baseline-replays.jsonl) records
293 fresh probes, source hashes, both decompositions, retained matrices and
certified projections. Positive-distance mechanisms above have source-backed
witnesses; the audit does not assign a unique root cause to every positive row.

Lean checks the semantic reductions and finite admitted-minimum contract,
without `sorry`, new `axiom` declarations or `unsafe`. Standard Lean logical
axioms appear in the printed dependencies. These proofs do not establish a
complete Java refinement or corpus-wide distance parity. The implementation
ledger explicitly separates delivered increments from the remaining union
and certificate-bridge work. Existing archived natural and synthetic results
remain unchanged and are not after-repair performance measurements.
