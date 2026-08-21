# Repair Metric Assurance Record

## Boundary

`QuotientRepairDistance` re-expresses the established Fast Rewrite repair
geometry over `RepairView`. The certified representation supplies admissible
scope symmetries and hidden identities; it does not replace pairwise alpha
minimization or ACI assignment with independently sorted representatives.

This record is bounded DO-178C-style evidence. Compiling Lean models and
passing finite Java differentials do not prove arbitrary JVM executions.

## Claim And Proof Process

| Claim | Implementation obligation | Lean obligation | Bounded falsification process | Current disposition |
| --- | --- | --- | --- | --- |
| M-01 | Add temporal, quantifier/parameter, and matrix components with checked arithmetic. | `decomposition_is_additive` | Component sum and profile/kernel boundary probes. | `PARTIAL`: algorithm refinement is incomplete. |
| M-02 | Every declaration edit costs one; a matrix binding is forced only by an injective paid modification or explicit positional-parameter diagonal selected by a minimum edit plan. | Quantifier unit theorems; paid and positional authority theorems; left/right injectivity theorems. | Source-level `S`/`T` fixtures plus 1,156 independently enumerated parameter-reference/edit-plan cases. | `DIRECT-BOUNDED`: unbounded Java refinement remains open. |
| M-03 | Enumerate all minimum quantifier plans and all maximum-cardinality certified alpha mappings; never infer authority from equal coordinates. | Exact alpha minimum; compatibility/maximality; no-coordinate and bound/free-identity theorems. | Typed permutation witness, scope-block rejection, inherited-phase consistency, and the finite parameter-plan differential. | `DIRECT-BOUNDED`: general quantified-scope candidate refinement remains open. |
| M-04 | Use minimum-cost assignment for bag/set operands and reject unsupported arithmetic totals. | Exact assignment minimum, crossed assignment, and Java-int range theorems. | Deterministic random matrices versus exhaustive permutations; malformed, negative, and two-`Integer.MAX_VALUE` cases. | `DIRECT-BOUNDED`: universal Hungarian refinement open. |
| M-05 | Apply ordered-forest edit distance only to the separated temporal tree. | `OrderedTreeEditDistance.lean`. | Forty-nine tree pairs versus an independent ancestor/order-preserving mapping oracle. | `PARTIAL`: Java refinement remains bounded. |
| M-06 | Charge one for a matrix head update and the full size of an inserted/deleted operand subtree; use assignment only at certified unordered containers. | `matrixOperandDeletionRemovesTheWholeSubtree`. | Sequence/bag/set vectors and `A(X)` to `X = 2`. | `DIRECT-BOUNDED`: general recurrence proof open. |
| M-07 | Keep readable spelling separate from certified variable, atom, parameter, and type identity. | Readable/type theorems plus paid-binding authority. | Qualified/unqualified atom spelling, type changes, alpha names, and parameter-type fixtures. | `PARTIAL`: no certified readable edit witness is emitted yet. |
| M-08 | Stream quantifier and scope products, use checked assignment arithmetic, and fail before returning a partial minimum when an exact-search bound is exhausted. | Arithmetic and no-coordinate-authority theorems. | Forced bound exhaustion, assignment oracle, typed alpha oracle, and source-pipeline controls. | `PARTIAL`: pruning and complete candidate-generation refinement remain open. |

## Repaired Counterexamples

The maximum-adversarial review at
`/tmp/acgn-metric-max-review-20260821.md` has SHA-256
`fc8569ebc5a1d267de3b4c3d508db5025da2928c53d878102b379c3ba250a4b0`.
It found these decisive defects on its frozen snapshot:

1. `pS[x:S] { some x }` versus `pT[x:T] { some x }` returned zero because
   parameters were not charged and a same-coordinate fallback bypassed type
   compatibility.
2. A typed three-binding differential disagreed in 210 of 1,521 cases.
3. a 2-by-2 all-`Integer.MAX_VALUE` assignment returned `-2` instead of
   rejecting the unrepresentable exact total `4,294,967,294`.
4. M-06 used ordinary node-edit prose although the established matrix
   recurrence deletes complete operands.
5. scope products were materialized and alpha search had no fail-closed bound.

The moving implementation repairs those exact failures by carrying minimum
edit correspondences, charging positional parameters once, carrying selected
zero-cost positional diagonals across insertions/deletions, deleting the
coordinate fallback, distinguishing bound from free variables symmetrically,
streaming scope products, using checked arithmetic, and declaring checked
exact-search bounds. The failed report is not retroactively converted to PASS.

A later frozen review at
`/tmp/acgn-metric-postrepair-review-20260821.md` (SHA-256
`620a4c718f316ccb8348f2a7f2ecd8504587337f89e8594a2cf15c06ccb9e57b`)
also returned `FAIL / INCOMPLETE`. It found that `[T] -> [S,T]` charged an
extra matrix edit because the implementation retained paid modifications but
discarded an unchanged positional-parameter diagonal. The current bytes carry
that selected diagonal, reject bound/free spelling conflation symmetrically,
and pass an independent 1,156-case edit-plan oracle. That failed review remains
fault provenance, not current approval.

## Resource Contract

The exact evaluator recognizes these positive system properties:

- `acgn.metric.maxQuantifierAlignments`, default `1,000,000`;
- `acgn.metric.maxScopeAlignments`, default `1,000,000`;
- `acgn.metric.maxAlphaAlignments`, default `10,000,000`.

Exceeding a bound throws `QuotientRepairDistance.ResourceLimitException`.
No result produced after an incomplete traversal is marked exact or returned
as a repair distance.

## Remaining Closure Work

- Run a fresh independent typed alignment and controlled-variant review against
  the repaired edit-plan implementation.
- Extend the Lean executable model with typed parameters and all tied minimum
  quantifier plans, then bind generated vectors to Java inputs.
- Carry predecessor decisions through every component before claiming a
  certified readable edit path.
- Bind any final claim to one immutable clean snapshot and independent ballot.
