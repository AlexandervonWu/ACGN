# P0 Lexical Signature Shadow Incident

## Status

`IMPLEMENTATION/FORMAL REPAIRED; PENDING FRESH IMMUTABLE REVIEW`. This record
documents GC-F109. It does not close the broader parser-to-certified-IR
refinement obligation, and the artifact assurance result remains `INCOMPLETE`.

## Trigger

The bounded publication smoke rooted at
`/tmp/acgn-publication-smoke-20260824-225833` reached all seven ablation arms
and then stopped at the semantic-soundness gate. Its permanent targeted probe
`signature_shadow_inv3.als` supplied this pair:

```alloy
sig File {}
sig Trash in File {}

pred inv3 {
  all Trash: File | File in Trash
}

pred inv3c {
  File in Trash
}
```

Alloy found a counterexample to `inv3 iff inv3c`, while both the Fast rewrite
IR and certified canonical observation reported equality.

## Root Cause

The parser resolves the capitalized body occurrence of the local `Trash` as a
`VarExpr`. `MASGVisitor.visitAbsorbing` previously consulted the global AAME
before `ScopeTreeNode`, so the shared spelling selected the signature despite
the parser's variable authority. The resulting MASG retained a declaration
node but no use of its `VarSymbol`; normalization then legitimately removed
what appeared to be an unused quantifier.

The first repair made every leaf lexical-first. Adversarial review then showed
that this captured parser-resolved `SigExpr` and `FieldExpr` leaves after the
parser normalized their display names, including explicit `this/Trash`.
A second repair separated lexical and global leaves, but the global AAME still
stored signatures and fields in one spelling map. A field named `A` could
therefore overwrite signature `A`, and overloaded fields from distinct owners
could overwrite one another.
The next review found that indexing only local `SigDecl` nodes omitted imported
signatures; `open util/time` followed by `some Time` failed to resolve
`time/Time`.

## Repair Contract

1. Treat the parser-resolved leaf class, not display spelling, as namespace
   authority.
2. Resolve `VarExpr` only through the current lexical scope and reject a
   missing lexical binding.
3. Resolve `SigExpr` through a dedicated signature namespace.
4. Resolve `FieldExpr` by field spelling plus its parser-certified exact
   relation type, preserving distinct owners and overloads.
5. Preserve explicit globals after display normalization without consulting a
   same-spelled lexical or different global namespace.
6. Build signature and field namespaces from the parser's complete reachable
   module environment, then reuse those symbols when local declaration graph
   structure is attached.
7. Do not retain an otherwise unused quantifier merely to mask a failed lookup;
   the body occurrence must point to the correct `VarSymbol`.

## Evidence

- `PrenexAciScheduling.lexical_binding_precedes_global` proves the variable
  leaf rule.
- `PrenexAciScheduling.signature_leaf_ignores_other_namespaces` proves the
  signature leaf rule.
- `PrenexAciScheduling.field_leaf_ignores_other_namespaces` proves the field
  leaf rule.
- `PrenexAciScheduling.missing_lexical_binding_rejects` proves fail-closed
  handling of an unresolved variable leaf.
- `PrenexAciScheduling.reachable_signature_is_indexed` proves the abstract
  reachable-inventory conservation rule.
- `PrenexAciScheduling.same_named_fields_with_distinct_exact_types_separate`
  proves the exact-typed field key distinction.
- `MASGVisitorTypeRegressionTest` parses the concrete collision and requires
  nonzero Fast rewrite IR distance plus nonequivalent certified observations;
  it separately requires explicit `this/Trash` and `@x` to retain signature
  and field authority under same-named local binders, requires `this/A` to
  survive a same-named field, and separates same-named fields owned by
  different signatures. It also resolves `time/Time` from `open util/time`.
- `EGraphSemanticSoundnessCheck` retains `signature_shadow_inv3.als` as an
  Alloy-backed targeted probe.

Development Run AJ at
`/tmp/acgn-section3-release-post-shadow-fix-v6` completed all 58 executable
steps with zero executable failures. Its result remains `INCOMPLETE` because
182 broader traceability obligations are still open.

These are bounded conformance checks. They do not prove that every parser leaf
variant, qualification form, imported namespace, or nested scope refines the
abstract lookup model.
