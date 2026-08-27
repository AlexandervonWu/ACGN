# P0 Imported Module Instance Incident

## Status

`IMPLEMENTATION/FORMAL REPAIRED; PENDING FRESH IMMUTABLE REVIEW`. This record
documents GC-F110. It does not establish complete parser-to-import-index
refinement, and the artifact assurance result remains `INCOMPLETE`.

## Trigger

Independent review supplied this valid Alloy shape:

```alloy
open util/ordering[A] as o1
open util/ordering[B] as o2

sig A {}
sig B {}

pred p { o1/first in A and o2/first in B }
```

Before any callable graph was constructed, `MASGVisitor` threw
`Ambiguous imported module alias util/ordering`.

## Root Cause

Each `OpenDecl` was registered under its declared client alias and again under
its raw module filename. Distinct parameterizations therefore collided on the
second, non-source-visible key even though `o1` and `o2` unambiguously named
separate module instances. The raw path identifies module provenance; it is
not an additional client alias when the source declares an alias.

## Repair Contract

1. Index an explicitly aliased import by its declared alias only.
2. Retain the derived short alias and raw-path lookup for an unaliased import.
3. Include module arguments in the imported instance identity and in imported
   callable semantic identities.
4. Admit distinct instances of one module under distinct declared aliases.
5. Reject distinct instances assigned the same declared alias.

## Evidence

- `CallExtractionRegressionTest` parses two `util/ordering` instances,
  constructs the graph, and requires exactly one
  `util/ordering<A>/first` and one `util/ordering<B>/first` call.
- The existing conflicting-alias mutation still requires a fail-closed
  `Ambiguous imported module alias` result.
- `PrenexAciScheduling.distinct_declared_aliases_separate_module_instances`
  proves the abstract distinct-alias admission condition.
- `PrenexAciScheduling.same_alias_distinct_module_instances_reject` proves
  the abstract same-alias conflict condition.
- The bounded Java suite and standalone Lean module pass on the repaired
  development bytes.

These checks are bounded. They do not prove every Alloy import form, transitive
open, alias normalization, or Java-parser refinement.
