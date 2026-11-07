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

`bash scripts/run_distance_parity_tests.sh` passes: 36 result-type checks,
208 Fast parity checks, EGraphSaturationTest, 2,266 quotient-distance checks,
and 2,041 pipeline checks. The script first compiles both standalone Lean files
(eight incident laws and six finite-minimum laws). Java source-backed checks
provide bounded correspondence evidence, not a verified Java compiler or a
complete proof of candidate enumeration.

## Remaining Representation Transfers

1. Certified dependent JOIN construction must admit composed, individually
   guarded rotations across a partially flattenable tree. Do not weaken the
   full-chain unary-interior guard. Each rotation needs source-linked evidence
   accepted by the verifier; a standalone Lean theorem is not that bridge.
2. Both metrics need a common representation of binary/flat chain alternatives
   and canonical live temporal phases, plus common declaration alignment.
3. Re-run all archived disagreements and negative controls, then the full
   paired corpus and truth-pool comparisons. Gate on per-row equality, not
   aggregate averages or matching zero counts. Independently check minimization
   over the admitted candidate space; equal outputs alone do not prove minimality.

`UnionMinimum.lean` proves finite minimum attainment, both union upper bounds,
and semantic preservation for a zero between sound admitted representatives
under a sound base zero kernel. It deliberately does not claim that the current
Java candidate generation satisfies those premises.
