# P0 LET Shadow-Capture Incident

## Disposition

The completed run rooted at
`/home/augustus/acgn-luna-full-20260827T095404Z` is not publication evidence.
Its corpus stages completed without a reported failure, but the required
postflight semantic-soundness probe found a false equality. A replacement run
must start from the repaired source commit and regenerate every result.

## Smallest Witness

The supported Alloy source is:

```alloy
sig S {}

pred inv1 {
  all y: S | let x = y | some y: S | x != y
}

pred inv1c {
  all y: S | some y: S | y != y
}
```

Alloy finds a counterexample to `inv1 <=> inv1c`. In `inv1`, `x` denotes the
outer `y`; in `inv1c`, both occurrences denote the inner `y`, so its matrix is
always false. Before this repair, Fast Rewrite and Certificate-Integrated
canonicalization assigned the pair distance zero.

## Root Cause

`MASGVisitor` assigned distinct parser lexical identities to the outer and
inner binders. `IRAgent` retained only their readable spelling when creating
variable e-nodes. Eager LET beta substitution then moved the outer occurrence
under the inner same-spelled binder. The subsequent alpha-renaming pass looked
up `y` by spelling and captured the substituted occurrence.

The corpus had no reported incorrect zero-distance pair exposing this exact
shape. The targeted probe is therefore a necessary postflight gate; a clean
corpus count alone was insufficient.

## Repair And Invariant

Parser-created variable e-nodes now carry `VarSymbol.getHashName()` as their
lexical binding key. Alpha renaming resolves that key before readable source
spelling. A declaration registers its lexical key, and each resulting
`QuantiVar` retains the key as an identity alias for certified projection and
temporal import. Canonical sort and equality surfaces still use the renamed
alpha identifier, so parser-local lexical keys do not distinguish
alpha-equivalent predicates.

The repaired invariant is:

```text
LET substitution preserves the referenced lexical binder identity;
readable spelling is never binding authority;
canonical equality observes the resulting alpha identity.
```

No rewrite rule or semantic equality family was added.

## Evidence And Limits

`MASGVisitorTypeRegressionTest` checks the original witness, an alpha-renamed
equivalent, and the captured-reference control. `EGraphSemanticSoundnessCheck`
uses Alloy to confirm the control is behaviorally different and verifies that
neither canonical implementation merges it. The retained natural-corpus
4,088-claim replay also reports no bounded counterexample after the repair.

`Phase5SourceRules.lean` proves shadow preservation and LET substitution over
distinct lexical binder identifiers without `sorry`, `axiom`, or `unsafe`.
This is a bounded correspondence: Java tests bind the abstract identifier to
the parser's `VarSymbol` lexical key. It is not a complete mechanized
refinement of the Alloy parser, Java graph construction, or certificate wire
format.
