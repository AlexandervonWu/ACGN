# Independent Certificate Verifier: Formal Coverage Audit

Status: Phase J pre-implementation audit; implementation status appended  
Audited branch: `aislop`  
Audited commit: `d2239b53783d874c6ce45f75f9c452b45acd214e`  
Audit date: 2026-08-17

## Scope And Trust Boundary

The existing `is.fivefivefive.CanDis.theory.CertificateVerifier` is an
in-process admission guard. It recursively invokes producer-side
`TypedEqualityCertificate.verifyLocal()` methods and therefore is not an
independent verifier. The Phase J verifier must decode a language-neutral
bundle and synthesize every judgment without loading producer classes.

The independent trusted base is limited to:

1. the standalone byte decoder and canonical encoder;
2. finite maps, sets, sorting, arithmetic, and SHA-256 supplied by
   `java.base`;
3. the dependent equality kernel listed below;
4. explicitly named, independently replayed algorithms for support,
   containers, binder automorphisms, graph transitions, orbit enumeration,
   and finite unfolding;
5. the exact pinned theory (including admitted axioms) whose digest is carried by the
   bundle and selected by the verifier.

Producer structural keys, endpoint claims, hashes, canonical observations,
and transition conclusions are untrusted data. Hashes provide identity and
integrity only. Complete decoded structures are compared after every hash
lookup.

The kernel rules are exactly reflexivity, equality symmetry, transitivity
with an identical synthesized middle term, typed transport along an
injection, a registered theory instance with checked type/term substitution
and side evidence, and forward congruence. Context contraction, structural
alpha, canonicalization, collisions, and graph transitions are algorithms,
not extra axioms. No rule derives child equality from parent equality.

## Evidence Availability At The Audited Commit

The producer retains final graph state, current EC/PC/SC evidence,
canonicalization traces, insertion results, and finite unfolding trees. It
does not retain an ordered, immutable history of all successful internal
mutations. In particular, path compression replaces parent assignments,
rebuild removes stale hash-cons keys, and publication exposes only the final
revision. Consequently an artifact produced at this commit cannot be
retro-certified as a Phase J transition trace. It is `UNCHECKABLE`, not
`REJECTED`, unless exported through the new proof-retaining path.

## Serialization Vocabulary

The planned `.acgncert` records are closed variants. An unknown variant is
always `REJECTED`.

| Record family | Required content | Synthesized object/judgment |
| --- | --- | --- |
| `Manifest` | format/schema versions, producer metadata, signature, laws, axiom registry and digest | hash-pinned theory \(T_{\Sigma,E}\) |
| `Context`, `Slot`, `Sort` | ordered typed coordinates and finite sort declarations | finite well-typed context |
| `Embedding` | source, codomain and total coordinate map | typed injection |
| `Renaming`, `Permutation` | context(s) and total map | typed bijection/onto map |
| `Term` | source operator/binder/container constructors and children | typed source term with recomputed support |
| `ProofNode` | closed proof variant, premise IDs and rule-specific payload | synthesized `(context,lhs,rhs,sort)` |
| `WitnessVersion` | class ID, revision, interface and defining term | versioned source witness \(w_a^r\) |
| `GraphSnapshot` | classes, parents, shape table, reverse uses, dirty queue and revision | complete independently checked state |
| `TransitionEvent` | kind, sequence number, pre/post snapshot IDs and exact payload | one replayed graph transition |
| `CanonicalRecord` | source, \(\Gamma_0,K,\Delta,\iota,\sigma,\omega\), ports, paths and orbit | source-to-kernel and global-minimum judgments |
| `UnfoldTree` | explicit finite `Rep` tree and index/coherence evidence | finite unfolding judgment |
| `Publication` | final revision, root, EC/PC/SC, unfoldings and observation | quiescent semantic artifact |

Missing required records are `UNCHECKABLE`; present records that are
malformed, inconsistent, ill-typed, or false are `REJECTED`.

## Certificate Coverage

For every proof node, serialized endpoints are checked claims. The verifier
first synthesizes its conclusion from premises and payload and then requires
byte-for-byte structural equality with those claims.

| Producer certificate/category | Serialized variant | Independent synthesis and premises | Missing evidence |
| --- | --- | --- | --- |
| `DerivedEqualityCertificate` / `REFLEXIVITY` | `Proof.Refl` | Type-check one term and synthesize \(t=t\) | `REJECTED` when node is present but malformed; dangling root is `UNCHECKABLE` |
| `EQUATIONAL_SYMMETRY` | `Proof.Sym` | Reverse the synthesized conclusion of one premise | same |
| `TRANSITIVITY` | `Proof.Trans` | Require exact structural equality of the synthesized middle context, term and sort | same |
| `RENAMING` | `Proof.Transport` | Validate a typed injection and apply capture-avoiding action to both premise terms | same |
| `CONTEXT_RESTRICTION` | `Algorithm.RestrictEquality` | Validate literal inclusion, independently check both endpoint factorizations, and synthesize the restricted equality | absent factorization is `UNCHECKABLE`; false factorization is `REJECTED` |
| `InputEquationCertificate` / `INPUT_EQUATION` | `Proof.AxiomInstance` | Look up axiom ID in the pinned manifest; validate type instantiation, total typed term substitution and side-condition evidence; instantiate both registered sides | unregistered/under-specified leaf is `REJECTED` |
| `InputEquationCertificate` / `REWRITE_AXIOM` | `Proof.AxiomInstance` | Same rule; rewrite orientation is metadata and does not broaden equality | same |
| `CongruenceCertificate` | `Proof.Congruence` | Reconstruct source node/port/binder constructor, require one premise for every changed direct child, preserve slot leaves and binder descriptors, and synthesize forward congruence | missing child is `REJECTED`; inverse child inference is `REJECTED` |
| `ParentEdgeCertificate` | `Algorithm.ParentEdge` | Require an independently checked endpoint derivation \(w_a=m\cdot w_b\), exact child/parent interfaces and typed embedding | absent endpoint derivation is `UNCHECKABLE`; generic ill-matching proof is `REJECTED` |
| `ContainerLawCertificate` | `Proof.AxiomInstance` | Resolve the exact schema/law axiom in the manifest and instantiate it; Seq has no AC/ACI laws, Bag has AC with multiplicity, Set has ACI after quotient | missing registry entry is `REJECTED` |
| `BinderAutomorphismCertificate` | `Proof.AxiomInstance` | Resolve descriptor-certified generator, validate type/quantifier/disjointness/scope descriptors, and instantiate its body action | incomplete descriptor/generator registry is `UNCHECKABLE`; incompatible permutation is `REJECTED` |
| `ContainerNormalizationCertificate` | `Algorithm.ContainerNormalize` | Replay occurrence IDs and child proofs; preserve Seq order, sort and aggregate Bag multiplicities, quotient then deduplicate Set elements | missing occurrence/child proof is `UNCHECKABLE`; Bag dedup or premature Set dedup is `REJECTED` |
| `SymmetryCertificate` | `Algorithm.FullInterfaceSymmetry` | Enumerate/close current certified leader generators and prove a full-interface bijection fixes the witness term; never cancel a parent equation to infer a child equation | absent full-interface witness is `UNCHECKABLE`; automatic same-leader symmetry is `REJECTED` |
| `InterfaceRestrictionCertificate` | `Algorithm.RestrictInterface` | Check restricted witness, literal inclusion, old witness factorization, and complete EC/PC/SC transport to the new revision | missing transported family member is `UNCHECKABLE`; implicit contraction is `REJECTED` |
| `StructuralAlphaCertificate` | `Algorithm.StructuralAlpha` | Independently recurse over typed syntax under one environment; binders extend it capture-avoidably and containers use declared semantics | missing explicit syntax is `UNCHECKABLE`; producer boolean is ignored |
| `KernelReplayCertificate` | `Algorithm.KernelReplay` | Perform the complete source-to-kernel procedure described below and elaborate its structural equalities into kernel proofs | any absent path, occurrence, support, or structural step is `UNCHECKABLE`; a generic endpoint proof is `REJECTED` |
| `CanonicalOrbitCertificate` | `Algorithm.CanonicalOrbit` | Enumerate the full admissible orbit and independently prove the claimed key is its lexicographic minimum | incomplete orbit/resource cap is `UNCHECKABLE`; missed smaller member is `REJECTED` |
| `FreshWitnessDefinitionCertificate` | `Algorithm.FreshWitness` | Require fresh interface exactly \(\Delta\), witness term exactly \(K\) in \(\Delta\), and returned widening exactly \(\iota\) | absent definition is `UNCHECKABLE`; allocation at \(\Gamma_0\) is `REJECTED` |
| `RebuildCongruenceCertificate` | `Algorithm.RebuildNode` | Recompute normalized child invocations and forward constructor congruence, then rerun source-to-kernel and orbit checks | missing child/path proof is `UNCHECKABLE`; producer `verifyWitness` is not evidence |
| `EffectiveShapeCollisionCertificate` | `Algorithm.ShapeCollision` | Require equal complete canonical keys, both independent source-to-kernel proofs, compatible common-ambient embeddings, and synthesize the endpoint equation | one replay side absent is `UNCHECKABLE`; hash-only collision is `REJECTED` |

There is intentionally no serialized `Proof.Other`, generic certificate, or
"locally valid" rule.

## Source-To-Kernel Judgment

`CanonicalRecord` independently establishes

\[
 d_n^w : \llbracket n\rrbracket_w
   = \iota\cdot\llbracket K\rrbracket_w
   \quad\text{in }\Gamma_0.
\]

The verifier recomputes `slots(n)` as \(\Gamma_0\), replays every complete
current parent path without leader unfolding, composes typed embeddings and
PC proofs, normalizes every Seq/Bag/Set port, recomputes effective support
\(\Delta\), checks literal inclusion \(\iota:\Delta\hookrightarrow\Gamma_0\),
reconstructs exact-context \(K\), requires a bijective
\(\sigma\in TRen(C_\Delta,\Delta)\), and checks
\(\omega=\iota\circ\sigma\). A non-surjective \(\omega\) is an embedding,
never a renaming. The structural trace is then replayed constructor by
constructor into the displayed equality.

Any missing complete parent path, PC proof, normalized occurrence map,
effective-support derivation, or structural step is `UNCHECKABLE`. Any
present but false support, map composition, or endpoint is `REJECTED`.

## Transition And Publication Coverage

Events are ordered and append-only. Each event references complete pre/post
snapshots and stable source edge/event IDs. The verifier checks the pre-state
matches the preceding post-state before replaying the operation. An event is
exported only after the producer operation and invariant check have
succeeded.

| Mutation/publication path | Event record | Independently checked transition | Missing evidence |
| --- | --- | --- | --- |
| Fresh insertion | `Event.InsertFresh` | source-to-kernel, full orbit, fresh ID, interface \(\Delta\), witness \(K\), shape equation, hash-cons insertion and returned widening through \(\iota\) | `UNCHECKABLE` |
| Insertion collision | `Event.InsertCollision` | all fresh checks plus existing owner lookup by complete key, both replay certificates, collision equation and certified union | `UNCHECKABLE` |
| Distinct-leader union | `Event.Union` | checked parent-edge equation, deterministic parent choice, installed edge ID, reverse uses, dirty propagation and revision | `UNCHECKABLE` |
| Same-leader symmetry | `Event.AddSymmetry` | independently derived full-interface SC member and closure update; no parent mutation | `UNCHECKABLE` |
| Interface restriction | `Event.RestrictInterface` | strict contraction, restricted witness, complete EC/PC/SC transport, parent/hash/reverse-use rewrites and revision | `UNCHECKABLE` |
| Rebuild record | `Event.RebuildRecord` | child finds with proofs, stale-key removal, required explicit restriction, new source-to-kernel/orbit result, collision/union if any and recursive dirtiness | `UNCHECKABLE` |
| Rebuild completion | `Event.RebuildComplete` | empty dirty queue, exact hash-cons ownership and graph invariants | `UNCHECKABLE` |
| Path compression | `Event.PathCompress` | original stable edge IDs, unchanged root, composed embedding and transported PC proof, replacement assignment | `UNCHECKABLE` |
| Coherent witness publication | `Publication.WitnessFamily` | exact current revision, one EC per class, PC per current parent edge, SC generator/closure evidence, no dirty state | `UNCHECKABLE` |
| Finite unfolding | `Publication.Unfolding` | explicit finite `Rep` tree, selected shape/witness/EC, ambient extension, fresh redundant-coordinate assignment and recursively exact child indices | `UNCHECKABLE` |
| Semantic artifact publication | `Publication.Artifact` | quiescent final snapshot, current witness family, verified root invocation, complete requested unfoldings and recomputed observation stable form | `UNCHECKABLE` |

For an event that is present, a pre/post mismatch, stale witness revision,
dirty publication, omitted collision side, invented cutoff leaf, or
unexplained state delta is `REJECTED`.

## Canonical Exactness Coverage

The canonical profile reconstructs a finite orbit from the manifest and
current certified state. It applies one global free-slot bijection to the
whole node, closes all current leader-group generators, closes every
descriptor-certified binder-block group, preserves Seq order, retains Bag
multiplicity, and quotients each Set element before deduplication. Complete
keys include constructor head, type instantiation, port schema, leader ID and
embedding map. The claimed representative is accepted only when every
admissible combination has been enumerated and no smaller complete key
exists.

A configured orbit/state/term limit yields `UNCHECKABLE`. It must not be
silently truncated and can never yield `VERIFIED`.

## Finite Unfolding And Pair Coverage

The unfold profile verifies explicit finite trees only. A leaf is valid only
when it is a declared source leaf; a resource cutoff is not a semantic leaf.
Every redundant ambient coordinate must receive a typed fresh value distinct
from retained coordinates, and every selected shape must be justified by the
current EC/SC family.

Pair mode first verifies both full bundles against the same pinned-theory digest,
then independently recomputes both kernels, constructs compatible common
context embeddings, and synthesizes source-left-to-source-right equality by
symmetry/transitivity through that common kernel. Equal observation bytes or
hashes are insufficient. Missing common-kernel derivation is `UNCHECKABLE`;
a supplied false derivation is `REJECTED`.

## Required Producer Changes Identified By This Audit

1. Add an optional no-op/recording trace sink at graph construction.
2. Assign stable IDs to every source witness, parent edge, shape equation and
   transition before later path compression or rebuild can replace it.
3. Buffer each public transition and append its internal events only after
   the final producer invariant check succeeds.
4. Export complete pre/post snapshots and internal insertion/rebuild
   collisions rather than reconstructing them from final state.
5. Export the signature/theory registry and rule instances, not merely their
   structural hashes.
6. Export explicit canonical orbits or sufficient finite generators and
   completeness bounds for independent exhaustive reconstruction.
7. Export explicit finite unfolding trees and versioned witness references.
8. Add a proof-retaining `CanonicalAlloyPipeline.prepareForVerification`
   path and reject export after `compactForComparison()`.

Until these records are emitted, the corresponding profile outcome is
`UNCHECKABLE`. This audit does not reinterpret their absence as evidence of
falsehood and does not permit producer-only validation to fill the gap.

## Implementation Status (2026-08-17)

The standalone `certificate-verifier/` module now implements the closed
`acgncert-schema-v2` decoder, dependent equality kernel, all dedicated replay
variants, checkpoint/event verifier, exhaustive canonical profile, explicit
finite-unfolding profile, and two-bundle pair profile. It compiles separately
with JDK 17 and `java.base` only. Proof endpoint fields are comparison-only
claims; each rule synthesizes its conclusion from decoded premises and
payload.

The producer now has optional no-op/recording trace sinks and a
`CanonicalAlloyPipeline.prepareForVerification(...)` path. Successful graph
operations append immutable pre/post snapshots only after their local
invariant checks. Ordinary preparation remains no-op and retains no trace.

The producer writer deliberately implements only one complete vertical
slice: an empty-context nullary source, one fresh insertion at empty effective
support, one canonical orbit member, and one complete height-one unfolding.
It validates the entire retained slice before opening the output file. All
other producer traces are currently refused as `UNCHECKABLE`; no final-state
history is invented.

The remaining producer serialization gaps are exact:

1. nonempty source contexts, typed ports, and parent paths;
2. support contraction, nonidentity `sigma`/`omega`, and structural alpha;
3. Seq/Bag/Set normalization and complete law registries;
4. insertion collisions and both source-to-kernel sides;
5. distinct-leader union and same-leader symmetry events;
6. interface-restriction witness versions and transported EC/PC/SC families;
7. rebuild-record, rebuild-completion, and path-compression histories;
8. multiple transitions/classes/canonical records; and
9. recursive, higher, or multiple finite unfoldings.

These are exporter gaps, not accepted assumptions. The independent verifier
has direct positive and adversarial byte/DTO fixtures for each record family,
but an actual producer artifact using one of these features remains
`UNCHECKABLE` until its retained evidence is serialized.

The standalone suite currently passes 44 checks. The deterministic smoke
exports 100 supported preparations twice, compares every pair byte-for-byte,
verifies every bundle with `full`, and verifies a pair. `jdeps -summary`
reports only `acgn-certificate-verifier.jar -> java.base`. The unchanged
theory, pipeline, and repair-distance suites also pass; exact commands and
counts are recorded in `docs/independent-certificate-verifier-handoff.md`.

No checked-in August 17 result is retro-certified. No paper, LaTeX, metric,
result directory, generated table, or full-corpus output was modified or
regenerated by Phase J.
