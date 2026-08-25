# P0 Lexical Binding Node Identity Incident

## Status

`IMPLEMENTATION/FORMAL REPAIRED; PENDING FRESH IMMUTABLE REVIEW`. This record
documents GC-F111. Complete parser-to-De-Bruijn refinement remains open, and
the artifact assurance result remains `INCOMPLETE`.

## Trigger

Independent review supplied two accepted shadowing shapes:

```alloy
pred p { all x: File | (all x: File | no x) and some x }
pred q { let x = File | (let x = none | no x) and some x }
```

In each graph, the final outer use resolved through `ScopeTreeNode` to the
correct outer symbol, but global node lookup returned the inner node.

## Root Cause

`VarSymbol` hash identity contained only type and source spelling, and
`LetSymbol` inherited `RefSymbol` equality over presentation metadata. The
global symbol-to-node map therefore treated same-spelled nested binders as one
key even though the lexical scope tree held distinct objects.

## Repair Contract

1. Preserve source spelling only as readable presentation metadata.
2. Include the unique lexical scope coordinate in every parser-created
   variable's node-map identity.
3. Give each `let` binder a unique lexical identity without changing its
   source spelling or beta-rewrite semantics.
4. Require same-spelled nested forms to agree with alpha-renamed controls at
   both Fast rewrite and certified boundaries.

The first repair encoded the scope together with type/name text and was
falsified by GC-F113. The current repair uses only the injective numeric
`(scope id, slot)` coordinate; see
[`p0-lexical-coordinate-injectivity-incident.md`](p0-lexical-coordinate-injectivity-incident.md).

## Evidence

- `MASGVisitorTypeRegressionTest` retains the two minimum shadowing witnesses
  and their alpha-renamed controls.
- `PrenexAciScheduling.same_spelling_nested_let_bindings_separate` proves the
  nested scope-coordinate distinction; the existing quantified-binding scope
  theorems cover the same invariant for variables.
- The bounded Java suite passes on the repaired development bytes.

These checks are bounded and do not establish complete parser-to-De-Bruijn
refinement for every binding construct.
