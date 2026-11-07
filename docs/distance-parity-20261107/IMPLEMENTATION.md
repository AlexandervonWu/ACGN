# Common Sound Representation Space

## Target

The author requires both tracks to cover the union of their sound
representations, use result-type-aware edit costs, and return the same exact
minimum on the full natural corpus. This is a repair target, not a completed
validation claim. The November 7 results remain immutable before-repair data.

For each input, the common space must contain the admitted representations
from both tracks, with source, type, scope, temporal ownership and proof
provenance retained. The distance is the minimum over the cross-product of
these spaces under **one** edit-cost function. Taking the smaller of the two
old scalar distances is insufficient: it misses cross-track pairs and mixes
different edit-cost policies. A new zero must still pass the certified
observation and certificate authority checks; a Fast zero is not authority.

Minimum means minimum over the explicitly admitted finite space and stored
alpha orbits. It does not mean minimization over every Alloy-equivalent
program. Resource exhaustion must fail, not return a partial minimum as exact.
Sharing the algorithm must not secretly run the entire certified producer in
the Fast arm and continue reporting it as a separate lightweight engine.

The author's subsequent clarification requires replaying the shorter sequence
first. If replay fails, locate and repair the shorter path's fault. If it
succeeds, locate the longer path's extra/misclassified edits or missed admitted
representation, and repair that producer. Incomplete replay is not a pass.
Do not select a scalar minimum or keep two competing final distances.

The certified track must retain full alignment: original occurrence, Lean
contract, source-linked typed construction, certificate premises, selected
representation, edit operations, replay endpoints and charged cost. Result
types, binder scope and temporal ownership remain part of that alignment.
Agreement with Fast cannot supply a missing certificate or correspondence.
An unavailable or failed alignment/replay check still stops the scan; native
cost coverage does not discharge the independent public-proof boundary.
Do not pad results or change units merely to keep a release mean in range.

## Proof-First Increment: Result Types

`IncidentLaws.lean` proves that changing the result type of an otherwise equal
semantic head costs one, equal typed heads cost zero, and changing both identity
and type still costs one head update, not two. The Java implementation now
compares the same `GraphType` result identities used by the certified projection:
Boolean heads use Bool, integer cardinality/casts use Int, and relational heads
use `AlloyTypeBridge.graphType` of retained exact parser types. Local declaration
wrappers remain structural; binding types are charged/aligned by declarations,
not separately at every variable use. Missing type metadata in historical
non-certified unit fixtures grants no certification authority.

Computed result keys are cached per prepared Fast node, not rebuilt in each
edit-distance DP comparison. Diagnostic edits must expose result-type changes.
This changes Fast experimental distances and requires fresh measurements before
any parity or performance claim. It does not change retained certification input.

## Proof-First Increment: Fast Presentation Coverage

The detached Fast copy erases only incidental labels of binary Boolean
IN/NOT_IN/EQUALS/NOT_EQUALS nodes with exact typed operands. Opcode, operand
order/commutativity, exact result type and binding identities remain intact.
`fixed_predicate_presentation` states that the chosen predicate's interpretation
does not depend on its source label; `mutual_exclusion` validates the reduced
duplicate-atom witness. The existing ACI laws then remove duplicate operands.
No new logical rewrite family is introduced.

Deduplication also reuses `certifiedContainerInvocationKey`, which composes
invocation maps down to the variable leaves. It no longer serializes a whole
multi-slot map with insertion-order-dependent `Map.toString` in the Fast copy.
The existing key retains distinct slots and exact types; its name grants no
new certificate authority. `distinct_slot_map_order_irrelevant` proves the
elementary map-order law for distinct keys.

For matrix-local ALL blocks, adjacent non-disjoint GENERICRELDECL nodes may be
combined only when their fully copied domain invocation keys agree. Their
ordered variable coordinates and already-resolved lexical identities are
concatenated, not permuted or rebound. Disjoint declarations, different domains
and temporal-reference-containing local binders retain the existing barriers.
`independent_all_grouping` supplies the semantic grouping law. This is the same
grouping quotient already supplied by the certified projection, applied only
to the metric copy, never to its source evidence.

## Delivered And Checked

The result-type cost increment and the Fast presentation increments above are
implemented. `FastResultTypeCostTest` checks changed versus unchanged relational
result types, typed-empty JOINs, same-spelled fields with different owners,
alpha-equivalence, declaration-only type changes and integer results. The older
field-owner pipeline assertion now expects two edits (field and JOIN result),
not the previous type-insensitive one. Its certified expectation remains two.

At checkpoint `f34de688892ea914bea41c99b10473ceed12df68`,
`bash scripts/run_distance_parity_tests.sh` passes 13,226 numbered Java checks,
the unnumbered batch/saturation checks, both replay/stop CLI suites, and ten
Python checks. Sixteen Lean files compile, including the four existing guarded
chain dependencies. The frozen input inventory was unchanged after execution.
Evidence is retained in the workstation's external
`ACGN/intermediate/join-integration-20261107-fgCFYL/` directory.
Java source-backed checks provide bounded correspondence evidence, not a
verified Java compiler or a complete proof of candidate enumeration.

This checkpoint repairs the archived local-domain pair from 49/50 to 49/49,
the reduced partial-JOIN pair from 0/8 to 0/0, and the reduced/natural guarded
chain cost pair from 3/1 to 1/1. These are individual regression results, not a
new full-corpus measurement or proof of complete ordered-sequence agreement.

The subsequent closed-temporal-phase increment repairs the archived 17/11
witness to 11/11 in both directions. The combined regression passes 13,314
numbered Java checks, eighteen Lean files, three one-pair fail-stop CLI checks,
the diagnostic replay CLI checks, and ten Python checks. Its 66,694-file input
inventory (including the natural inputs) was unchanged afterward. Evidence is
under `ACGN/intermediate/temporal-integration-20261107-FLmXNU/`; the repeated
CLI checks and their raw incidents are retained under `retained-parity-stop-cli/`.
This is bounded regression evidence, not full-corpus closure.

## Remaining Representation Transfers

1. Source-linked partial-JOIN rotations now have an in-memory typed certificate
   with exact insertion premises and source-ledger checks. Independent wire
   replay for this new certificate is not implemented; export explicitly
   rejects it. Extend that boundary without dropping source or typed premises.
2. Guarded JOIN operand units now agree in the tested chain cases. Complete
   binary/flat alternative coverage, canonical live temporal phases, and common
   declaration alignment remain open. Closed, binding-free duplicate temporal
   leaves now reduce the tested 17/11 witness to 11/11; original owner references
   remain untouched and only detached metric coordinates are transported.
   The subsequent scoped temporal occurrence accounting repair changes
   `trash_ltl/both/oivT9pBECZFsYCGWq_inv18.als` from 21/22 to 21/21 by counting
   one source-owned temporal occurrence once while preserving its matrix uses.
   See `STOPPED_RUN.md` for the replay, contract and bounded evidence.
   Native numerical replay is not a full source-to-public-sequence certificate.
3. Re-run all archived disagreements and negative controls, then the full
   paired corpus and truth-pool comparisons. Gate on per-row equality, not
   aggregate averages or matching zero counts. Independently check minimization
   over the admitted candidate space; equal outputs alone do not prove minimality.

`UnionMinimum.lean` proves finite minimum attainment, both union upper bounds,
and semantic preservation for a zero between sound admitted representatives
under a sound base zero kernel. It deliberately does not claim that the current
Java candidate generation satisfies those premises.
