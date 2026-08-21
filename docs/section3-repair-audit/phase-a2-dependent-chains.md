# Phase A2 Audit: Dependent JOIN and ARROW Chains

> Historical review verdicts and check counts below are retained as repair
> provenance only. They are not current evidence or ballots under the
> closed-world gate in `adversarial-review-protocol.md`.

## Status

PRELIMINARY REVIEWS FAILED; BOTH COUNTEREXAMPLES REPAIRED; FORMAL AND FOCUSED
GATES PASS; THE PHASE REMAINS OPEN PENDING THE COMPLETE CLAIM CENSUS, BOUNDED
GATE, AND FIVE FRESH UNANIMOUS REVIEWS OF ONE IMMUTABLE SNAPSHOT.

## Contract

Phase A2 extends Phase 2 without weakening its homogeneous-flat-port
restrictions. JOIN and ARROW remain ordered and multiplicity preserving. Their
binary source associations may reach one variadic `Seq` target only through a
separate dependent-chain certificate family whose proof is indexed by every
operand type and the exact result type.

For exact nonempty relation-column lists `cols(R)`:

```text
ARROW(R, S): cols(R) ++ cols(S)

JOIN(R, S):  init(cols(R)) ++ tail(cols(S))
             provided last(cols(R)) = first(cols(S))

JOIN(R1,...,Rn) may be reassociated only if every interior operand
R2,...,R(n-1) has at least two columns. This keeps its left and right join
boundaries distinct. A unary interior operand remains ordinary binary syntax.
```

Repeated operands remain repeated. Source order remains observable. The
dependent `Seq` carrier grants no generic associativity, commutativity,
idempotency, permutation, or unit authority. Reassociation is justified only
by independently replaying the typed source chain against the equations and
the interior-arity guard above. ARROW needs no corresponding guard.

## Independent Leaf Typing

Every leaf contains its own stored port type, exact relation view, named typing
rule, structural proof, and source identity. The closed v4 rule family is:

- `EXACT_RELATION`: the stored type and relation view are identical;
- `PRIMITIVE_SET_SINGLETON`: `Int` or `AlloyCarrier(S)` is lifted to the unary
  relation view `Rel(Int)` or `Rel(AlloySig:S)`.

There is no name-based parameter rule. A source spelling such as `ParameterN`
has no independent typing authority; parameter occurrences must carry the same
exact relation or primitive carrier evidence as every other leaf.

No absent type is converted to `univ`. Missing source provenance rejects at
binding construction. A parser-authenticated or explicit `univ` type remains
legal; a genuinely polymorphic expression whose exact relation columns cannot
be proved does not receive a dependent-chain certificate and stays in the
ordinary fixed-binary representation.

## Implemented Obligations

| Obligation | Implementation | Regression evidence |
| --- | --- | --- |
| Ordered heterogeneous carrier | `SeqPortSchema.dependent` stores one exact schema per position | role swaps reject; duplicate ARROW operands survive |
| Closed chain equations | `DependentChainKind` implements exact-column JOIN and ARROW folds; `DependentChainTheory.requireSoundFlattening` enforces the JOIN side condition | boundary mismatch and nonrelation operands reject; unary-interior JOIN stays binary |
| Independent leaf proofs | `DependentChainLeaf` and `DependentChainTheory` bind stored type, relation view, rule, and proof | exact and primitive singleton rules replay independently |
| Exact certificate index | `DependentChainCertificate` binds profile, deterministic source occurrence/content, source association, all operand types, result, target, theory version, and digest | left/right associations have distinct source endpoints and one target only when the guard holds |
| Source authority | `ConstructionSourceLedger` records concrete source applications before certified construction | omitted, extra, or unreferenced evidence rejects |
| Independent wire replay | schema v8 retains source occurrence/content commitments, source trees, leaf rules/proofs, applications, and dependent positional schemas | malformed commitments, unary JOIN interiors, and arity mismatches reject |
| Metric preservation | `RepairProjection` flattens only an immutable occurrence binding mapped to an artifact-admitted certificate, then rechecks lineage, source content, kind, output, leaf order, and every leaf type | licensed JOIN/ARROW reassociations have certified equality and repair distance zero; unlicensed JOIN remains nonzero |
| Fail-closed fallback | unsupported or polymorphic chains remain fixed binary | `x.*r` receives no dependent JOIN certificate |

## Fault And Contradiction Log

| ID | Located fault | Repair | Regression |
| --- | --- | --- | --- |
| A2-F01 | Homogeneous flat-port evidence cannot express JOIN/ARROW's changing intermediate types. | Add a separate dependent ordered-Seq family and closed exact-column theory. | JOIN and ARROW association fixtures converge only through dependent evidence. |
| A2-F02 | Initial dependent leaves carried relation views without naming how a primitive stored slot justified that view. | Add a closed leaf typing-rule enum and proof indexed by stored and relation types. | Unsupported constructors and non-unary primitive views reject. |
| A2-F03 | The first wire shape did not expose enough leaf data for independent type replay. | Serialize term, relation type, type rule, source key, and type proof; independently reconstruct all five. | Scalar/rule/proof mutations reject. |
| A2-F04 | Generic flat/container verification paths could accidentally consume a dependent `Seq`. | Reject dependent schemas from homogeneous evidence and require the dedicated source-tree verifier. | Forged generic evidence for a dependent target rejects. |
| A2-F05 | Certified semantic equality initially reached one target while Layer 3 still compared the old binary source syntax, violating the metric kernel. | Transfer the concrete admitted source certificate to its repair occurrence and revalidate kind, output, leaf count, order, and every leaf type before metric flattening. | Both parsed associations have distance zero; unlicensed chains stay binary. |
| A2-F06 | Missing type provenance was normalized to `univ`, fabricating an apparent unary relation proof. | Remove the default and require a nonempty source type at binding boundaries. | A direct null binding-type attack fails closed; unresolved polymorphic closure does not flatten. |
| A2-F07 | Repair labels compared raw atom spelling, so `this/S` and `S` were certified equal but one edit apart; the same spelling at two exact relation types was certified unequal but zero edits apart. | Separate readable payload from a hidden certified semantic payload containing normalized identity and exact result type. | Both kernel directions now accept: spelling normalization costs zero and an exact type change costs one. |
| A2-F08 | Dependent certificates were transferred by reusable parser ID, opcode, result type, and FIFO traversal order. Two same-ID chains with different operand partitions cross-attached proofs. | Reseed a unique non-semantic occurrence lineage at the pre-ACI checkpoint, preserve it through the certification clone and same-opcode normalization, and transfer by lineage. | Two ARROW roots with ID `701` and result `A->B->C` retain distinct lineages and the correct positional proofs after ACI reorder. |
| A2-F09 | An unproved Fast Rewrite e-class union could select one representative for certification and another source spelling for repair projection. | Require every pre-certification source occurrence to be the sole member and canonical leader of its e-class. | A manually unioned `left`/`right` source rejects before any certificate is issued. |
| A2-F10 | A concrete JOIN/ARROW type disagreement could fall through to an unchecked ordinary binary operator. | Reject concrete chain-equation and declared-result mismatches; permit binary fallback only when an exact parser-provided relation type explicitly contains polymorphic `univ`. | A concrete `A -> B` node falsely declared unary `X` rejects; `x.*r` remains binary without a dependent certificate. |
| A2-F11 | The public projection API accepted an artifact and independently supplied evidence maps, permitting certificate-map substitution outside the adapter result. | Accept the privately constructed `TheoryAlloyAdapter.Result` as one evidence unit and enforce injective certificate use. | One certificate cannot be replayed over two roots through the production projection API. |
| A2-F12 | A preliminary reviewer swapped same-typed JOIN/ARROW certificates and mutated leaf names after adaptation; both attacks were accepted because the bridge checked only opcode, output, and positional types. | Bind each certificate endpoint to a deterministic source path and canonical source-content commitment; retain an immutable lineage binding and revalidate it during projection. | Same-typed swaps and post-certification mutations reject for both JOIN and ARROW. |
| A2-F13 | A preliminary reviewer found the minimum unary-middle counterexample to JOIN associativity: `R={(A,B)}`, `S={(B)}`, `T={(A,A)}` makes `(R.S).T={(A)}` but `R.(S.T)={}`. The old type-only proof certified both. | Version the fixed theory to v2 and require every interior JOIN operand in a variadic chain to have at least two columns. Unsafe but valid Alloy expressions fall back to fixed binary syntax. | The exact counterexample now has one inner certificate per side, distinct canonical observations, and repair distance `4`; the independent Lean model proves both the counterexample and guarded reassociation. |
| A2-F14 | The original Lean theorem proved only list-append equality after assuming a decomposition that excluded the unary-middle case. | Replace it with tuple/relation semantics whose dependent middle tuple has distinct left/right boundaries, plus an explicit unguarded countermodel. | Pinned Lean 4.33.0 compiles the guarded denotational theorem and counterexample with no admitted theorem. |
| A2-F15 | A parameterized, guarded JOIN was association-sensitive because an intermediate implementation wrapped a primitive carrier as `ParameterN(AlloyCarrier(S))`. | An attempted v3 repair added name-based `PARAMETER_SINGLETON`; A2-F18 later invalidated and removed that authority. The live v4 repair propagates exact type evidence independently of readable parameter spelling. | Current tests reject forged `ParameterN` typing authority and admit only exact relation or primitive singleton proofs. |
| A2-F16 | The schema-v5 documentation and the intermediate v3 implementation disagreed about whether `PARAMETER_SINGLETON` existed. | Superseded by A2-F18: v4 removes the rule from producer, verifier, formal contract, and live documentation. | The two-rule producer/verifier enum and fixed theory text agree; unsupported constructors reject. |
| A2-F17 | Public schema/verifier documentation described JOIN dependent reassociation without stating its required interior-arity guard, which could be read as authority for the falsified unguarded associativity claim. | State that ARROW is generally associative but a JOIN chain longer than two requires every interior operand to have at least two columns; otherwise it remains fixed binary. | `FORMAT.md`, verifier `README.md`, fixed theory source, verifier replay, Java regressions, and Lean counterexample now state the same boundary. |
| A2-F18 | The attempted v3 `PARAMETER_SINGLETON` rule derived semantic type authority from readable source spelling and contradicted the implementation's later two-rule fail-closed policy. | Version the dependent theory to v4, remove name-based authority, and prove that every successful relation view belongs to the exact-relation or primitive-singleton family. | `parameter_spelling_has_no_independent_authority` and `successful_relation_view_has_only_two_rule_families` compile; forged `Parameter0(...)` and unsupported constructors reject. |

## Focused Evidence

- `TheoryDependentChainTest`: 27 checks pass in the current focused run.
- The bounded runner reaches these assertions through
  `TheoryCertificatesTest`; its post-repair aggregate is rechecked by the
  complete phase gate rather than copied from the pre-repair run.
- `CanonicalAlloyPipelineTest`: 453 checks pass in the current focused run.
- `QuotientRepairDistanceTest`: 15 checks pass.
- `formal/PhaseA2DependentChains.lean` compiles under pinned Lean `4.33.0`
  and discharges guarded JOIN and ARROW denotation, the unguarded JOIN
  counterexample, ordered/multiplicity-preserving `Seq`, closed typing,
  no-invented-`univ`, exact occurrence binding, replay, repair-label,
  mismatch, and pristine-source claims.
- `TheoryCanonicalizationTest`: 11,560 checks pass with deterministic seed
  `55520260819`.
- `ProducerSemanticEvidenceMutationTest`: 88 checks pass when its fourth
  argument is the required single-occurrence
  `bind-block-symmetric-a.acgncert` fixture.
- `CertificateBundleWriterTest`: 95 checks pass in each deterministic run.
- The schema-v8 producer/verifier harness passes with standalone census exactly
  `VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`; the separately pinned fixture
  theory digests remain unchanged.
- A new complete bounded gate has not yet been claimed after these preliminary
  review repairs; that run is part of the phase gate below.

These focused results are evidence, not closure. Phase A2 remains open until
five fresh reviewers satisfy `adversarial-review-protocol.md` on one unchanged
snapshot.

## Review Gate

Reviewers must try to forge leaf type provenance, replace an explicit type by
invented `univ`, reorder or deduplicate operands, cross-use JOIN and ARROW
proofs, replay across profiles/types/source associations, smuggle a dependent
target through generic flat evidence, exploit hash-consed representatives or
source-occurrence transfer, and find any certified equality whose metric view
is nonzero or any zero metric result without certified equality.
