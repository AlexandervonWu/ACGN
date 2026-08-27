# P0 Repeated Binder Slot Allocation Incident

## Status

`IMPLEMENTATION/FORMAL REPAIRED; PENDING FRESH IMMUTABLE REVIEW`. This record
documents GC-F114 and supersedes the map-size slot allocator in the first
GC-F113 repair. Complete parser binding-resolution refinement remains open,
and the artifact assurance result remains `INCOMPLETE`.

## Trigger

Alloy accepts repeated spellings in a declaration such as:

```alloy
pred p { all x, x, y: File | no x and no y }
```

The name-keyed scope map overwrote the first `x`; its size therefore remained
one when `y` was allocated. Both the second `x` and `y` received slot one, and
body lookup of `x` returned the `y` node through the global node map.

## Root Cause

Map cardinality is not an allocation counter when insertion may replace an
existing key. The coordinate shape was injective, but the Java allocator did
not guarantee fresh coordinates.

## Repair Contract

1. Each lexical scope owns a monotonic binding-slot counter initialized to
   zero.
2. Every declaration consumes exactly one slot, even when its readable name
   replaces an existing name-map entry.
3. Name lookup and coordinate allocation are separate operations.
4. The repeated-binder witness retains distinct parser-exposed `x` and `y`
   node identities and agrees with an alpha-renamed control whose first binder
   is unused. The parser AST does not expose the overwritten first `x` as a
   separate declaration-edge variable.

## Evidence

- `MASGVisitorTypeRegressionTest` parses `all x,x,y`, requires distinct
  parser-exposed `x` and `y` `VarSymbol` identities, and compares it with the
  alpha-renamed control at both Fast rewrite and certified boundaries.
- `PrenexAciScheduling.allocation_returns_current_slot_and_advances` pins the
  allocator transition.
- `PrenexAciScheduling.consecutive_allocations_are_distinct` proves two
  consecutive allocations cannot reuse a slot.
- The bounded Java suite passes on the repaired development bytes.

These checks do not prove every parser duplicate-name or malformed-AST policy.

## Bounded Re-review

Two independent fresh reviews of the current development bytes returned
bounded `PASS`. Their concrete probes covered repeated names in one and
multiple declaration groups, deeper nested quantifiers, dependent domains,
mixed quantifier/`let` shadowing, imported-module identities, and local
signature arities. They found no coordinate reuse. Both reviews explicitly
exclude malformed ASTs, integer-counter exhaustion, exhaustive Alloy syntax,
and immutable-snapshot authority; those limits prevent promotion of the
artifact-wide assurance result.
