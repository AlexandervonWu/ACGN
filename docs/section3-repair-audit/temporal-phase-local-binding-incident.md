# Temporal Phase-Local Binding Incident

Date: 2026-08-27

## Failure Class

Six valid Alloy predicates failed exact adaptation with `Unbound normalized
variable`. Each source declaration lexically dominated a temporal expression,
but temporal skeleton extraction placed the expression in a distinct
`NormalForm` phase without carrying the declaration's certified scope.

The minimal pattern is:

```alloy
all f: File |
  once f in Trash implies always f in Trash
```

Alloy accepts this source because the quantifier scopes the complete formula,
including both temporal operands. The variable is therefore not globally free.
It is an outer-bound variable used inside two phase-local matrices.

The six corpus witnesses were:

1. `classified-data/trainStationOld/under/4NSwuo4gkLvZfpFpL_inv3.als`
2. `classified-data/trainStationOld/under/MQeaKWF4jwqyeaxBn_inv3.als`
3. `classified-data/trash_ltl/both/7MEWsRCR2QHykYucm_inv12.als`
4. `classified-data/trash_ltl/both/Emtyi2nisqui7NZBt_inv12.als`
5. `classified-data/trash_ltl/both/MLYQCydzguqvzdhwL_inv12.als`
6. `classified-data/trash_ltl/both/Zcgx3MHPpHtJ6Sowg_inv12.als`

## Root Cause

`NormalForm` correctly kept declarations that could not be soundly lifted over
their surrounding Boolean context. However, a temporal `REF` retained only
the detached child phase. `IRAgent` normalized that child without the active
local binder environment, and `TheoryAlloyAdapter` eagerly constructed the
child before entering the owner binder. Exact adaptation then saw a variable
leaf with no admissible slot and failed closed.

Globally prenexing the declaration is not a valid repair. For example, moving
`all x : none` across conjunction can change a false formula into a vacuously
true one. Temporal phase separation also cannot be removed because distinct
temporal operands are distinct metric and certificate phases.

## Repaired Invariant

Every temporal phase use of a lexically active local binder now carries an
explicit import identified by:

```text
(source binder lineage, owner phase path, target phase path,
 binder context, owner coordinate)
```

The implementation enforces these properties:

1. The source binder lineage is positive and comes from the actual declaration.
2. Owner and target phases remain distinct objects with deterministic paths.
3. The target is built only while the exact owner binder frame is active.
4. The imported coordinate, slot, and exact graph type match that owner frame.
5. Imported locals are visible to alpha normalization but are not reclassified
   as ordinary matrix or globally inherited quantifiers.
6. Repair projection uses the separate `LOCAL_INHERITED` role and retains the
   certified owner context, preventing collisions with unrelated binders.
7. Same-spelled declarations from another source lineage, owner phase,
   coordinate, or binder context reject.

Declarations and uses in different temporal branches therefore remain
phase-distinct. Only their authenticated relationship to the same lexical
owner is shared.

## Normalization Identity Correction

The first implementation compared the owner binder by Java object identity.
Normalization may clone a source binder while preserving its exact normalized
occurrence lineage, so the first six-file replay rejected all six witnesses.
The corrected check uses the normalized owner occurrence lineage together with
the owner phase and local coordinate. This accepts only an authenticated clone
of the same binder and does not permit matching by name or by source lineage
alone.

## Repeated Temporal Reference Correction

The first complete corpus run repaired the original six failures but exposed
five additional `trash_ltl` sources. IFF elimination had duplicated an already
issued temporal `REF`, so scope capture visited the same child phase twice.
The initial implementation rejected every second snapshot, including an exact
repeat under the same binder.

The corrected invariant is idempotent only for an exact snapshot. Repeating a
child reference is accepted when every imported binding has the same variable
identity, owner phase, owner binder occurrence, source-binder lineage, owner
and target phase paths, and binder context in the same deterministic order.
Any difference still reports conflicting local scopes and fails closed.

The five first-pass witnesses were:

1. `classified-data/trash_ltl/both/8PXGBSXFqdcbX5vSw_inv12.als`
2. `classified-data/trash_ltl/both/CkAdkqNkn2sbgQxuc_inv18.als`
3. `classified-data/trash_ltl/both/ZXmB8Q9qwwERJwvqZ_inv18.als`
4. `classified-data/trash_ltl/both/oivT9pBECZFsYCGWq_inv18.als`
5. `classified-data/trash_ltl/both/zEzT5f72uzYudEzyu_inv18.als`

The minimized parser-backed regression uses a local binder around an IFF with
`ALWAYS` and `AFTER`. Lean separately proves exact-snapshot idempotence and
rejection after changing the binder context.

## Formal Boundary

`formal/TemporalPhaseLocalBinding.lean` models the bounded property proved by
this repair. It exhaustively enumerates all supported unary temporal operators:

```text
BEFORE, HISTORICALLY, ONCE, ALWAYS, EVENTUALLY, AFTER
```

It also covers both phase roles of every supported binary operator:

```text
UNTIL, RELEASES, SINCE, TRIGGERED
```

The model proves that every constructor preserves the surrounding lexical
depth, detached children are not closed on their own, sibling phases may share
one exact owner while retaining distinct target identities, and altered source
lineage or binder context rejects. It also proves the empty-carrier
counterexample to unconditional global prenexing.

This is a proof of scope and provenance transport through the complete
temporal vocabulary. It is not a replacement proof for each operator's full
linear-time temporal semantics.

## Regression Evidence

| Check | Result |
| --- | --- |
| `TemporalPhaseLocalBinding.lean` | PASS |
| forbidden-declaration source audit | zero matches |
| `CanonicalAlloyPipelineTest` | PASS, 1,991 checks |
| `QuotientRepairDistanceTest` | PASS, 2,266 checks |
| `FullCorpusNonTemporalP0RegressionTest` | PASS, 45 checks |
| exact six-file replay | PASS, 6 successes and 0 failures |
| repeated-reference five-file replay | PASS, 5 successes and 0 failures |
| complete historical 241-file replay | PASS, 241 successes and 0 failures |
| complete 66,080-file corpus | PASS, 61,598 successes, 4,482 AST skips, 0 failures |

The final full-corpus output is
`/tmp/acgn-phase-local-full-v2.OCa5Ws`. All replay outputs were written under
`/tmp`; no protected experimental result directory was modified.
