# Phase 3 Audit: Exact Types, Profiles, and Endpoints

> Historical review verdicts and check counts below are retained as repair
> provenance only. They are not current evidence or ballots under the
> closed-world gate in `adversarial-review-protocol.md`.

## Status

PRELIMINARY MAXIMUM-ADVERSARIAL REVIEW: **FAIL**. Exact structural types,
independently indexed law evidence, concrete flat/container construction
traces, and binder-occurrence evidence exist on the moving worktree, but the
profile is not source-command derived and the independent verifier cannot bind
it to the selected Alloy command or execution options. The width, overflow,
temporal, version, and source-binding counterexamples below remain blocking.
Phase 3 is not eligible for review ballots until those faults and every other
claim-ledger obligation are closed.

The current producer/verifier mutation harness must be invoked with
`bind-block-symmetric-a.acgncert` as its fourth argument: that position is the
single-binder-occurrence fixture, not a generic binder node. Passing the
law-free `bind-a` or `bind-block-a` fixture correctly exposes zero occurrence
records and cannot exercise the binder-record mutations. The exact intended
fixture invocation passes 60 checks on the current moving worktree; this is
bounded evidence only.

The earlier pass below is evidence only. Current closure requires `5/5 PASS`
on one unchanged snapshot under `adversarial-review-protocol.md`.

The independent abstract contract in
`formal/Phase3ExactTypesEndpoints.lean` now proves ordered relation-column
observability, fail-closed missing-type decisions, complete profile/law/binder
index injectivity, source-owned obligation matching, alpha/automorphism
separation, and retention-record injectivity. It does not prove parser-to-Java
refinement, cryptographic encoding injectivity, flat/container replay,
descriptor closure, or canonical wire ordering. Those omissions keep this
phase blocked under the current all-claims gate.

## Contract

Phase 3 preserves and checks:

1. exact result kinds, relation arities, and ordered relation columns;
2. bitwidth, overflow, temporal mode, rewrite mode, signature version, and the
   resulting semantic-profile fingerprint;
3. exact operator, result/element type, schema path, quotient, arity policy,
   law parameter, independent source-theory digest, and endpoints for A/C/I/U;
4. concrete source occurrences, output occurrences, quotient fibers, flat
   splice positions/arities, and construction endpoints;
5. complete binder descriptors, fresh occurrence maps, descriptor
   automorphisms, conjugated occurrence actions, source paths, endpoints, and
   the exact generator-word derivation.

Malformed, missing, ambiguous, cross-profile, cross-operator, cross-type,
cross-path, cross-arity, and cross-occurrence evidence fails closed.

## Code Map

| Obligation | Implementation |
| --- | --- |
| Occurrence-level parser type | `ExactAlloyType`; `MASGVisitor.recordExactType`; graph/TOV-indexed storage in `AugmentedNode` |
| MASG-to-IR propagation | `IRAgent.attachSourceMetadata`; `EGraphNode.exactAlloyType` |
| Exact graph relation type | `AlloyTypeBridge.graphType`; ordered `GraphType.relation` columns and relation alternatives |
| Semantic profile | `SemanticProfile.structuralKey` and SHA-256 fingerprint |
| Independently fixed law theory | `AlloyLawRegistry`; verifier-owned registry text/digest in `SemanticEvidenceVerifier` |
| Concrete flat evidence | `FlatConstructionCertificate`, splice ledger, source tree, and `ContainerApplicationTrace` |
| Concrete container evidence | `ContainerConstructionCertificate`, ordered input ledger, normalized output ledger, and exact quotient fibers |
| Binder occurrence evidence | `BinderOccurrenceAutomorphismCertificate`; complete descriptor group and occurrence conjugation replay |
| Complete binder orbit | `CertificateBundleWriter.binderOrbitSummary` streams the descriptor product, retains its exact candidate count, and serializes only the independently checked minimum |
| Independent wire replay | `SemanticEvidenceVerifier.SemanticReplay` reconstructs types, laws, constructions, endpoints, and binder derivations |
| Artifact retention | `CanonicalOrbitCertificate`; `CoherentWitnessFamily`; `CertifiedSemanticArtifact` |

## Fault And Contradiction Log

| ID | Located fault | Repair | Regression |
| --- | --- | --- | --- |
| P3-F01 | The initial standalone verifier checked only semantic-evidence table order and trusted concrete construction records. | Added independent flat, container, and binder replay from decoded vocabulary/model records. | Producer semantic fixtures must verify under `FULL`; mutations must reject. |
| P3-F02 | Serialized canonical binder orbits were hard-coded as singleton even for a nonidentity descriptor automorphism. | Enumerate the complete finite descriptor automorphism product, deduplicate by structural key, and serialize the full orbit/minimum. | `bind-block-symmetric` fixture verifies rather than returning `INCOMPLETE_ORBIT`. |
| P3-F03 | Wire `Set`/`Bag` term order could differ from source occurrence order, which misaligned replay finds and normalization claims. | Canonically order wire children while retaining an explicit source occurrence ledger and occurrence-wise realignment. | Nested flat `AND` and commutative equality fixtures verify byte-deterministically. |
| P3-F04 | Verifier replay demanded bare decimal e-class text although producer witnesses use `e<decimal>` and structural keys use the decimal payload. | Parse the producer grammar strictly and reconstruct the decimal structural-key payload. | Positive flat fixture reaches semantic replay; malformed/noncanonical identifiers reject. |
| P3-F05 | Verifier replay omitted the `flat-input/leaf` wrapper from a flat source key. | Reconstruct the exact wrapper around the concrete `One` port key. | Flat source key verifies; a cross-key mutation rejects with `THEORY_MISMATCH`. |
| P3-F06 | Verifier substituted a direct binder-generator premise for the producer's exact closure derivation. | Independently rebuild the deterministic generator/inverse BFS and its renaming, symmetry, and transitivity proof keys. | Symmetric binder fixture verifies; endpoint mutation rejects. |
| P3-F07 | The symmetric producer fixture used arbitrary fixture provenance while the verifier correctly authorizes only the fixed Alloy binder source. | Bind the fixture to `canonical-alloy-signature-v7/alloy-binder-block/0`. | Positive binder evidence verifies under the fixed source theory. |
| P3-F08 | Semantic construction and binder sections could be omitted while `FULL` still verified. | Kernel replays now carry `source-construction` references, canonical orbits carry complete binder-occurrence references, and verification requires exact set equality with independently replayed records. | Omitting any flat, container, or binder evidence record rejects with `MISSING_EVIDENCE`. |
| P3-F09 | Kernel normalization projected exact law authority down to schema-only authority. | Every normalization now carries its enclosing operator ID and schema path; authorization is indexed and checked by exact `(operator,path,schema,kind)`. | Cross-operator and cross-path authority substitutions reject. |
| P3-F10 | Binder occurrence paths were accepted under any application in the term table. | Every occurrence record now names its enclosing root and path lookup starts only at that root. | A root substitution rejects with `THEORY_MISMATCH`. |
| P3-F11 | A missing relational occurrence type could fall back to textual source type metadata. | `TheoryAlloyAdapter.outputType` now requires `ExactAlloyType` for non-Boolean, non-Int nodes. | A manually constructed relation node with only `sourceType` fails closed. |
| P3-F12 | Producer adversarial coverage omitted completeness, rootedness, and exact authority attacks. | Added producer omission/root mutations, verifier cross-index tests, and an on-disk ordered relation-column fixture. | The focused producer harness and full bounded gate pass. |
| P3-F13 | Construction/binder completeness was checked against producer-authored references, allowing coordinated record-plus-reference omission and cross-replay substitution. | Derive the required construction kind from each decoded replay source and bind its referenced record to that exact source term/operator/path; traverse every orbit source and reconstruct the exact binder certificate key for every descriptor generator at every occurrence path. | Three paired omissions and two fully rehashed cross-replay swaps now reject with `MISSING_EVIDENCE`. |
| P3-F14 | The populated fixtures did not contain multiple construction and binder owners, so exact cross-owner substitution remained untested. | Add alternate flat-construction and dual binder-owner fixtures with distinct source provenance. | Cross-owner construction and binder-reference substitutions are permanent producer mutations. |
| P3-F15 | A construction record and its complete replay reference could be replaced together by an alternate valid record with the same target/operator/path because the expected source endpoint was not replay-owned. | Derive a stable construction source owner from input identifier/hash, insertion event sequence, and inserted e-class; carry it in both the evidence record and replay reference; independently reconstruct and compare it. | Stale-owner and complete record-plus-reference substitution reject in both directions. |

## Regression Evidence

- `CanonicalAlloyPipelineTest`: 251 checks pass, including exact JOIN/ARROW
  relation columns, ordered-column distinction, and missing-type rejection.
- `TheoryLawPolicyRegressionTest`: 182 checks pass, including cross-index and
  overflow-profile rejection.
- `TheoryCertificatesTest`: 294 checks pass, including concrete construction
  endpoints/fibers and occurrence-specific binder automorphisms.
- `CertificateBundleWriterTest`: 94 checks pass in each of two byte-identical
  runs, including ordered relation columns and nested same-descriptor binders.
- `ProducerBundleInspectionTest`: 68 checks pass.
- `ProducerSemanticEvidenceMutationTest`: 42 checks pass, including complete
  alternate-source substitution, paired omission, cross-orbit binder moves,
  nested occurrence replay, and ordered relation columns.
- `VerifierTest`: 88 standalone checks pass, including cross-operator and
  cross-path normalization-authority rejection.
- `TrustedTheoryPinsTest`: 31 checks pass.
- Export census remains exactly `VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`.
- Trusted theory digests remain:
  - `9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c`
  - `0901e1ee21d8f82c128ebc93f0e5f1e0b421f7a6833ec16cf5473df3b222b147`
- `scripts/run_bounded_ci_java_tests.sh` passes in full.

No corpus experiment or protected empirical result directory was modified.

## Review Gate

The independent reviewer must confirm that the verifier reconstructs rather
than trusts every retained Phase 3 field, that the binder closure proof is
complete and deterministic, and that no production path can use the empty
test-only semantic ledger as publication authority. Any finding reopens this
phase and is appended above before remediation.

## Independent Review 1

Verdict: **FAIL**.

The fresh read-only reviewer ran the producer/verifier harness and a custom
omission probe. It found:

1. `flat-constructions`, `container-constructions`, and `binder-occurrences`
   could each be removed in full while `FULL` still returned `VERIFIED`;
2. kernel normalization authority had been projected from exact
   `(operator,path,schema)` evidence to `schema -> laws`;
3. binder occurrence paths were accepted beneath any term-table application
   rather than one named source root;
4. `TheoryAlloyAdapter.outputType` retained an exact-type-to-text fallback;
5. producer-level adversarial coverage did not yet include omission and rooted
   occurrence attacks.

The phase remains open. These findings are tracked as P3-F08 through P3-F12
and require another independent review after remediation.

| ID | Review fault | Required remediation |
| --- | --- | --- |
| P3-F08 | Semantic construction and binder sections lacked a checked completeness ledger. | Bind exact evidence keys into replay/orbit payloads and require set equality with verified records. |
| P3-F09 | Kernel normalization discarded exact operator/path authority. | Carry and check the enclosing operator and schema path on every normalization proof. |
| P3-F10 | Binder paths were not rooted. | Serialize the enclosing root term and resolve the path only from that root. |
| P3-F11 | Missing occurrence types could fall back to source text. | Make the theory adapter fail closed when exact occurrence type metadata is absent. |
| P3-F12 | Mutation coverage did not exercise omission/root/authority attacks. | Add producer-bundle omission and cross-index regressions before re-review. |

## Remediation After Review 1

All five findings were repaired without widening the trusted theory or using
producer claims as authority. The wire-format documentation now records the
coverage references and rooted occurrence field. The focused producer harness
passes with 86 verifier checks, 66 writer checks per deterministic run, 67
inspection checks, 14 semantic mutation checks, and 31 pin checks. The complete
bounded Java gate also passes, and its export census remains exactly
`VERIFIED=1`, `UNCHECKABLE=2`, `REJECTED=0`.

Review 1 remains in this record as historical evidence. A fresh reviewer must
independently re-test the repaired boundary before the phase can close.

## Independent Review 2

Verdict: **FAIL**.

The fresh reviewer confirmed exact operator/path authority, rooted binder
lookup, fail-closed occurrence typing, ordered relation columns, and separation
of test-only law authority. It nevertheless found a critical circularity in
the new completeness ledger: expected construction and binder keys were read
from producer-authored replay/orbit references rather than derived from the
decoded source terms themselves.

The reviewer's `/tmp` probe recomputed all affected content IDs and obtained:

```text
FLAT paired omission      => VERIFIED
CONTAINER paired omission => VERIFIED
BINDER paired omission    => VERIFIED
FLAT cross-replay reference swap      => VERIFIED
CONTAINER cross-replay reference swap => VERIFIED
```

Thus global set equality was not a sufficient completeness proof. This is
tracked as P3-F13. The reviewer also observed a transient Phase 4 assertion
failure while owner-qualified shape IDs were being edited; that assertion has
since been corrected and the latest complete bounded gate passes, but Phase 3
remains open independently of that later fix.

| ID | Review fault | Required remediation |
| --- | --- | --- |
| P3-F13 | Construction/binder obligations were obtained from producer-authored references, allowing coordinated omission and cross-replay substitution. | Derive exact per-replay construction obligations from decoded source/kernel structure, derive binder occurrences by traversing each orbit source, bind every record to that specific replay/orbit and its endpoints, and add paired-omission plus cross-replay attacks as permanent regressions. |

## Remediation After Review 2

The verifier no longer asks a producer reference whether a decoded replay needs
construction evidence. The exact replay source operator, its flat license, and
its independently checked root law set determine `NONE`, `FLAT`, or
`CONTAINER`. A construction record is accepted for that replay only when its
target term, operator identity, and schema path match the replay source.

Likewise, binder completeness is no longer a global comparison against orbit
references. The verifier traverses each decoded orbit source, reconstructs the
descriptor occurrence map and conjugated action for every declared generator,
derives the complete certificate key at that exact path, and requires the
record's named root/source/path to match. Producer references are checked
against this independently derived per-orbit set.

The Review 2 content-ID-closure attack is now part of
`ProducerSemanticEvidenceMutationTest`. The focused harness passes with 19
semantic mutation checks and the unchanged trusted theory digests/census. A
third fresh reviewer must rerun coordinated omission and relocation probes
before closure.

## Independent Review 3

Verdict: **FAIL**.

The fresh reviewer reran an improved complete-content-ID-closure probe. All 13
constructible semantic attacks rejected, including paired flat, container, and
binder omission; cross-replay construction relocation; altered binder roots;
cross-operator/path reuse; and deleted exact law/type evidence. This confirms
that P3-F13's derived-obligation repair is effective for the populated fixture
space.

The reviewer correctly withheld closure because the fixtures contain only one
populated construction/orbit owner. A same-target but different-source record
substitution and a true cross-orbit binder-reference move therefore could not
be constructed. The verifier currently checks construction target, operator,
and path, but the record comparison does not independently assert exact source
identity. This is tracked as P3-F14.

The review also observed two gate failures while Phase 4/5 edits were occurring:
writer bytes differed during the transient shape-witness serialization change,
and the backtranslator test still expected the old bare-domain cardinality.
Both are resolved in the current tree: the complete bounded gate passes,
writer runs are byte-identical, and the backtranslator compiles explicit
`one` bindings. They are recorded here for chronology but are not the remaining
Phase 3 blocker.

| ID | Review fault | Required remediation |
| --- | --- | --- |
| P3-F14 | No multi-owner fixture proves that matching-target/different-source construction substitution and true cross-orbit binder relocation reject. Exact source identity is not compared at the construction-reference check. | Bind each derived obligation and verified record to the decoded source term ID, add at least two populated construction and orbit owners, and promote both cross-owner substitutions to permanent attacks. |

A fourth fresh reviewer must rerun the multi-owner substitutions and all prior
paired-omission attacks before Phase 3 can close.

## Independent Review 4

Verdict: **FAIL**. The reviewer built a complete content-closed substitution:
it copied the alternate flat construction record and replaced the replay
reference key and endpoint together. Both directions still verified. Binder
cross-owner substitutions and all prior omission attacks rejected. This
isolated P3-F15: endpoint agreement was local to two replaceable producer
fields and was not bound to the replay's exact source owner.

## Remediation After Review 4

Construction records and `source-construction` references now carry the exact
source-owner key. The standalone verifier reconstructs that key from immutable
bundle provenance and the retained insertion event rather than trusting either
wire field. The permanent mutation suite copies the complete alternate record
and complete alternate reference and requires `THEORY_MISMATCH` in both
directions.

## Independent Review 5 Service Result

The first two requested fresh reviews were stopped by the independent-agent
service before technical work began and do not count as verdicts. A subsequent
read-only review completed a 32-check source-identity probe and confirmed that
all stale-owner and complete cross-source substitutions reject in both
directions. Its overall verdict remained **FAIL** only because a concurrently
added Phase 6 nested-binder fixture exposed an unrelated verifier caller-scope
fault before the ordinary harness completed. That Phase 6 fault is recorded
and repaired in `phase-6-streaming-occurrences.md`; a fresh Phase 3 review is
pending on the now-green harness.

## Historical Independent Review 7 (Invalidated)

Verdict: **PASS**. The fresh read-only reviewer completed the ordinary
producer/verifier harness, observed all 42 permanent semantic mutation checks
pass, and independently reran a 32-check bidirectional source-owner probe.
Both complete alternate record-plus-reference substitutions reject with
`THEORY_MISMATCH`. The export census remains exactly `1/2/0`, and the reviewer
made no repository edits. Phase 3 is closed on this repaired boundary.

That closing sentence records the historical review's conclusion only. It is
invalidated by the current closed-world gate and the counterexamples below;
Phase 3 is `BLOCKED`.

## Current Preliminary Maximum-Adversarial Review

Verdict: **FAIL / BLOCKED; not a ballot.** The moving-worktree review at
`/tmp/acgn-phase3-max-review/PRELIMINARY-FAIL.md` located three decisive
counterexamples:

1. `ExactAlloyType.EMPTY_RELATION` and `AlloyTypeBridge` erased the arity of
   statically empty unary, binary, and ternary relations. The current moving
   worktree retains the parser-proved positive arity in exact types, graph and
   metric keys, certificate types, the independent verifier, and visualization.
   It rejects arityless and malformed encodings and deliberately does not
   invent parent columns that Alloy has masked to `none`; column-dependent
   JOIN/ARROW proof remains unavailable. The preliminary report is
   `/tmp/acgn-empty-relation-review/report.md` (SHA-256
   `2a49cc406764a589c37f1529f7413222ddbc6d389422127183651b09ed01721f`).
   Complete serialization and layer-refinement review remains blocked.
2. Source commands using four-bit and five-bit integers receive the same fixed
   four-bit `SemanticProfile` and fingerprint. A separate complete preliminary
   review at `/tmp/acgn-profile-fingerprint-review/report.md` (SHA-256
   `2d37f739c2bda0e852a9d86859683f7303c95efa577aac53e54d7b1643b11f1c`)
   also proved that default solver execution is modular while the producer
   default claims overflow-forbidding, temporal trace bounds and effective
   sequence bounds are not represented, and the free-form profile labels do
   not identify the running rewrite/adapter/signature versions. Both exported
   mismatched bundles passed `FULL` verification because source bytes and an
   exact selected command are not verifier inputs. This remains unresolved.
   `formal/Phase3SemanticProfile.lean` independently proves the fixed-selector
   width, overflow, and temporal collisions and the minimum unique-selection
   separation contract. It intentionally does not claim Java/source/verifier
   refinement.
3. `RepairProjection.project` accepted a post-certification source mutation
   from `A : Rel(A)` to `ATTACKER_REPLACEMENT : Rel(Z)`. On the current moving
   worktree, adaptation freezes the complete reachable normalized source and
   its bindings under one mutation lock, retains exact phase identities, and
   projection derives and validates the result digest. The independent
   one-node `true` to `false` witness now rejects at the mutation boundary;
   foreign-source and forged-digest probes also reject. A 32-interleaving
   two-thread regression checks that mutation either precedes certification
   completely or rejects, never producing a mixed view. After the independent
   empty-relation wire checks were added, the focused pipeline suite passes
   450 checks and the standalone verifier suite passes 97 checks. Complete
   field-family and Java-refinement evidence is still absent, so this repair is
   not a Phase 3 PASS.

The report SHA-256 is
`1e30171e0117c01503aed4b97b51615d226e8dae1885f009fb1cea5f7c1624a8`.
Its independent Lean file compiles but proves only its abstract contracts and
countermodels, not Java or wire refinement. The profile finding remains open.
The empty-relation and source-ownership repairs, exact public grammar, current
check counts, and every formal-to-implementation mapping require fresh
immutable-snapshot review.

On the later moving worktree, `CanonicalAlloyPipeline.Prepared` also retains
its exact semantic profile after comparison compaction, checks that profile
against the certified artifact at construction, and rejects distance,
representative-TED, and equality queries across profiles before evaluating an
observation. The fixed source-command selector itself remains unrepaired, so
this closes only the cross-profile comparison subcase of P3-16.
