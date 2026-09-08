# P3-03: Exact Semantic Profile Wire

## Interface And Frozen Surface

`fourth_profile_replays.py` implements `generate(build, formal)`, returning
`[("SemanticProfileWireReplay.lean", source, 272)]`, `negatives(build, formal)`,
and `source_mutations()`. It reads `semantic-profile-wire.tsv` and
`semantic-profile-wire-source.tsv`. The Java main takes optional `OUTPUT.tsv`
and writes that exact path; no-argument execution just runs assertions. All
certificate fixtures live in a temporary directory cleaned in `finally`.
The extractor takes `ROOT OUTPUT.tsv`. Both require JDK17. The regression
compiles against producer sources alone and uses only public verifier APIs
through reflection at runtime. Include separately compiled verifier classes
and local `lib/*.jar` on its runtime classpath. No verifier tests are needed.

The proof imports only `Std` under Lean 4.33.0. There are no additional project
proof dependencies. The parent P3-03 statement, status and hash remain owned
by the shared harness. This area does not claim closure by itself.

## General Contract

Seventeen audited general theorems establish exact five-scalar reconstruction,
field-list injectivity, rejection of every unequal profile by exact field
comparison, and agreement of independently structured producer and verifier
encodings. The encoding fixes the tag, scalar count, order, delimiters, empty
child list, and each text length. Text is an exact list of Unicode scalar
values, with a proved `String.ofList` roundtrip. Java string lengths are UTF-16 code units;
supplementary Unicode values count twice. No Unicode normalization occurs.

The profile model retains the exact bitwidth and overflow wire texts rather
than claiming a verified Java integer or enum parser. Numeric canonicalization,
range and source-context/version checks are exercised by the finite census.
Lean reconstruction consumes a list of five scalar texts, not arbitrary certificate bytes.
No general theorem of the Java binary codec or stable-key parser is asserted.
Isolated Java surrogates are outside Lean's Unicode-scalar String domain;
production canonical UTF-8 encoder rejection is source-pinned and trusted.
The executable context-version guard accepts exactly the complete v4 version
text; a general theorem rejects every unequal version, including aliases.

Authority is a separate explicit input, not a spelling test. A custom profile
never acquires export authority from equal scalar fields, key or fingerprint.
Compatibility authority permits TEST_ONLY export only. Source authority is
supplied by the independently pinned source factory, not inferred by Lean.

The digest theorem is parametric in an arbitrary deterministic function. It
does not assert SHA-256 injectivity. Real Java SHA-256 outputs are compared to
Python hashlib over exact UTF-8 payloads; digest security and implementations
remain declared cryptographic trust.

## Independent Finite Observations

The independent Python census fixes every case identity, order, field, source
command text/options, authority, mutation, expected outcome and rejection
detail. It rejects omitted, duplicate, extra, reordered and altered inputs.
Outputs enter Lean propositions independently of expected inputs and outcomes.

- 132 custom serialization cases: widths 0/4/30, both overflow modes, baseline
  plus seven text variants independently in each of the three string fields.
  Variants cover delimiters/digits, quotes/backslashes, newline/tab, BMP Unicode,
  supplementary Unicode, combining marks, and embedded NUL.
- 132 writer/verifier cases: two fixed profiles and six actual parser-owned
  source profiles at widths 3/4/6 in both overflow modes, each with baseline,
  five individual field mutations retaining the old digest, the same five
  mutations with independently recomputed digest, digest/registry/version
  controls, and an explicit publication-mode verifier control. Each of the six
  source profiles additionally tests old-v2 and future-v5 context versions with
  corrected nested length framing and recomputed profile/envelope digests.
- Eight custom equal-spelling clones: exact key and fingerprint equality,
  no admissibility/authorization, public writer rejection preserving existing
  target bytes, and rejection by both explicit export-authority modes.

The writer is `CertificateBundleWriter.write` via its public session wrapper.
Its actual certificate bytes are decoded with public `Codec`/`Bundle` APIs.
Mutations create fresh immutable public wire nodes, recompute the enclosing
vocabulary and binary digests, and call public `IndependentVerifier.verify` at
KERNEL scope. No verifier-private access or mutation occurs. The test-side
`independentKey` column is independently reconstructed expected payload, not a
claim to expose the verifier's private key. Runtime acceptance and exact
rejection detail, plus resolved source pins, link that reconstruction to the
actual verifier. Fixed-profile rehashed overflow changes are correctly accepted
as another permitted profile; exact comparison with the original still fails.

The CALL-free nullary fixture supplies a caller-owned empty CALL census using
its fixed input identifier/content and canonical commitment framing. It does
not inspect a bundle to grant it occurrence authority. Theory trust is confined
to the controlled test fixture. Publication-mode wire mutation tests verifier
policy only, not clean publication provenance. TEST_ONLY provenance capture
is restored after the Java main and confers no authority on custom profiles.

## Source And Rejection Controls

Seven complete javac-normalized class trees and resolved symbol/modifier
inventories are fixed: SemanticProfile, StructuralKey, AlloySemanticProfileFactory,
CertificateBundleWriter, SemanticEvidenceVerifier, Wire, and Codec. Python also
checks exact pins, not just digest syntax. The extractor has no learn mode,
deletes stale output before extraction, and fails before output on mismatches.

Fifteen source controls independently replace every writer field, change both
UTF-16 length computations, omit a verifier field, bypass digest/authority or
publication/version checks, alter dispatch modifiers, or change digest algorithm.
Required rejection is exit 1 with first-line `UNMODELED_SOURCE:` and only
registered object-pin diagnostics/stack frames thereafter. Eleven Lean controls
alter key observations, a digest, all five stale-field outcomes, or clone
authority rejection, or the two version-control outcomes. They must fail via
false `decide`, never loader/syntax failure. All 17 general and 272 replay
theorems have explicit axiom audits. Kernel-only `decide +kernel` and general
reconstruction lemmas discharge the observations without native evaluation.

## Trust And Run Status

TRUSTED: Lean kernel/core (allowed standard axioms `propext`, `Classical.choice`,
`Quot.sound`), JDK17 compiler/JVM and standard library, Alloy parser/options,
public API reflection dispatch, source extractor and replay encoder, Python
runtime/hashlib, SHA-256 and collision resistance, provenance capture,
CALL-commitment framing, filesystem/OS and hardware. TESTED correspondence is
finite; javac pins are CHECKED syntactic/resolution evidence, not semantic
refinement. Unlisted inputs, parser/JVM/codec correctness, future revisions,
full certificate/pair semantics and publication provenance are OUT_OF_SCOPE.

Development blocker found at the production boundary: the source factory emits
`alloy-command-options-v4-independent-search-domain`, but the verifier pins
`alloy-command-options-v2`. Untouched source-profile bundles reject before the
profile mutation checks. The census intentionally expects those baselines to
pass; it does not convert this mismatch into a successful negative case.
Production repair requires coordination and fresh source pins/evidence. Final
area evidence and two isolated clean builds are owned by the shared harness;
no VERIFIED claim is made by these local development files.

### Coordinated Resolution

The preceding blocker records the initial production defect, not the final
source state. Main corrected only the verifier context-version constant to
the producer's exact v4 text and added independent verifier version controls.
The original reproduction is preserved in `/tmp/acgn-v215-profile-before-main`
and `/tmp/acgn-profile-local/source-version-repro.json` as development evidence.
All six unchanged parsed-source baselines now require and obtain VERIFIED from
the public KERNEL verifier. Old-v2 and future-v5 profiles reject specifically
at the context-version guard even after all affected digests are recomputed.

The publication-mode mutation remains a TEST_ONLY fixture with its metadata
changed. Fixed profiles reject at profile authorization. Source profiles reach
the later exact-type-reference guard and reject with the frozen MISSING_EVIDENCE
detail: TEST_ONLY display-form type references are not publication IDs. This
is not a source-baseline failure or a claim of publication correctness.

Main also repaired unrelated flat-splice ordering in the same verifier class;
the final whole-class pin includes that coordinated change. Its semantic
coverage belongs to the container area, not P3-03. Main subsequently repaired
the writer's dependent-chain exact-type registration to include canonical
left-fold intermediate types absent from a right-associated source. The writer
whole-class pin was refreshed after reviewing that diff; the verifier pin did
not change again. This third repair belongs to the chain area and does not
alter profile encoding or authority. No production source was edited by this
area.

After all three coordinated repairs, a fresh producer/verifier compilation
passes 757 Java assertions in both CLI forms and reproduces all 272 observations
byte-for-byte. The current seven-class source census also passes. Regeneration
produces exactly the same 272-theorem program that completed its local kernel
check in 203.5 seconds, and the same eleven false-decision negative programs.
The encoder has 16 passing unit tests. Local development traces are under
`/tmp/acgn-profile-current`; proof logs are under
`/tmp/acgn-profile-local/formal`. All fifteen source rejection controls also
pass against the final reviewed writer/verifier pins, with strict diagnostics
and stale-output rejection; logs are under
`/tmp/acgn-profile-source-controls-current/logs`. Producer-only compilation
passes without verifier sources, and both CLI forms leave no temporary fixture
directory behind. These checks are development evidence, not evidence inherited
across frozen input roots. Only the final shared, frozen two-build report may
establish bounded closure.
