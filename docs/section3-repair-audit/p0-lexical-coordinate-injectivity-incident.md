# P0 Lexical Coordinate Injectivity Incident

## Status

`IMPLEMENTATION/FORMAL REPAIRED; PENDING FRESH IMMUTABLE REVIEW`. This record
documents GC-F113 and supersedes the presentation-derived variable key used in
the first GC-F111 repair. Complete parser-to-coordinate refinement remains
open, and the artifact assurance result remains `INCOMPLETE`.

## Trigger

Independent review supplied this accepted Alloy predicate:

```alloy
sig A {}
sig A_B {}
pred p { all C: A_B, B_C: A | no C and no B_C }
```

The first repair gave both bindings the key `VAR_A_B_C@scope:2`; both body
occurrences therefore selected the second variable node.

## Root Cause

Concatenation of arbitrary source/type strings with a delimiter is not an
injective encoding. Adding a scope suffix prevented nested-shadow collisions
but could not distinguish two presentations whose components contained the
delimiter.

## Repair Contract

1. Variable node-map identity is the numeric lexical coordinate `(scope id,
   slot)` and contains no source spelling or type text.
2. Source spelling and exact type remain separate readable/certified metadata.
3. Distinct slots in one scope remain distinct regardless of presentation.
4. The delimiter witness must agree with an alpha-renamed control at both
   observation boundaries.

The first numeric-coordinate repair derived slots from name-map cardinality
and was falsified by repeated binder spellings under GC-F114. The current
allocator is monotonic and independent of that map; see
[`p0-repeated-binder-slot-allocation-incident.md`](p0-repeated-binder-slot-allocation-incident.md).

## Evidence

- `MASGVisitorTypeRegressionTest` retains the exact `(A_B,C)` versus
  `(A,B_C)` witness and its alpha-renamed control.
- `PrenexAciScheduling.different_slots_separate_bindings` proves
  slot injectivity under a shared scope path.
- `PrenexAciScheduling.same_scope_distinct_slots_ignore_presentation` pins
  presentation independence for two concrete slots.
- The bounded Java suite passes on the repaired development bytes.

These checks do not prove that every parser binding construct is assigned the
intended scope/slot coordinate.
