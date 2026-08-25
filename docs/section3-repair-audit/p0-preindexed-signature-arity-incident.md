# Preindexed Signature Arity Incident

## Status

`IMPLEMENTATION/FORMAL REPAIRED; PENDING FRESH IMMUTABLE REVIEW`. This record
documents GC-F112. The broader generation refinement remains open, and the
artifact assurance result remains `INCOMPLETE`.

## Trigger

For `sig Owner { x: set File }`, reachable-relation preindexing created the
`Owner` node as a zero-arity leaf. Local declaration traversal reused the node
and attached field `x` plus `END`, but its maximum-downlink metadata remained
zero.

## Root Cause

Preindexing did not distinguish provisional expression-leaf use from the
later local declaration occurrence. Reuse correctly preserved symbol identity
but failed to replace the provisional arity with declaration arity.

## Repair Contract

1. Imported signatures without local declaration structure may remain leaves.
2. A visited local signature declaration has one child per field-declaration
   group plus its explicit terminator; each group separately owns its fields.
3. Reusing a preindexed signature node must set its maximum downlinks to that
   declaration arity before edges are attached.

## Evidence

- `MASGVisitorTypeRegressionTest` requires a one-field `Owner` declaration to
  report maximum arity two.
- `PrenexAciScheduling.signature_declaration_arity_includes_field_declarations_and_end`
  proves the abstract equation, and
  `one_field_signature_has_two_declaration_children` pins the concrete witness.
- The bounded Java suite passes on the repaired development bytes.

These checks do not prove every downstream consumer's treatment of signature
declaration nodes.
