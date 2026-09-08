# P2-19: Fixed Registry Admission

## Frozen Claim And Scope

The original P2-19 claim is unchanged: a law can be issued only for the exact
fixed registry entry and semantic profile fingerprint. This package adds a
general executable admission/index model and bounded direct Java conformance.
It does not alter the production registry, authorize new rules, or prove the
whole Java implementation or Alloy parser.

The earlier proof checked only opcode/profile associativity authority. The new
model covers every production registry family, all four law kinds, Set/Bag/Seq,
exact result/element types, primitive One versus nested elements, finite versus
at-least arities, root path, exact operator identity, profile admission, complete
parameters, origin, theory digest, and both indexed source endpoints.

## General Lean Model

`RegistryAdmission.lean` supplies 17 general theorems. Its executable decision
does not assume that a request was valid. `issue_some_iff` characterizes issuance;
`accepts_iff_reconstructed` reconstructs accepted certificates from the fixed
theory and exact request. `issued_is_accepted` relates both operations.
Parameter equality preserves every index coordinate, including the complete
profile key; theory, profile, path, identity and nested-element changes reject.
No production registry family admits U or an unsupported operator.

`ProfileAuthority` is an input from the separately checked profile-construction
boundary. Public custom profiles cannot acquire authority from equality of
profile spelling or fingerprint. Compatibility profiles remain internal/test
profiles and do not gain publication authority. Source profiles must retain
the production rewrite and signature versions. The type view distinguishes
Bool, Int, exact relation identities and exact opaque identities; relation
classification itself is not proved by this model.

The origin-declaration digest is an arbitrary deterministic function of the
complete structural index. The proof does not assume it injective. Parameter
and profile comparisons retain full data independently of that digest. Java
uses the existing SHA-256 declaration builder; the observations independently
reconstruct that builder's outputs and both endpoint keys. The Lean model's
origin record additionally retains signature-law kind and law ordinal.

## Java And Correspondence

`RegistryAdmissionRegressionTest` executes:

- 9,504 requests: two fixed overflow modes, eleven operator representatives,
  nine exact element/result pair cases, three carriers, four arity policies,
  and four laws.
- Six authority/path/identity controls, including custom profiles with exactly
  the same structural key and fingerprint as a compatibility profile.
- Six actual parsed-source command profiles: bitwidths 3, 4, 6 in both overflow
  modes, without a test override of source provenance.
- Every remaining opcode against all four laws, outside the emitted product
  table, as additional direct negative coverage.

There are 68 issued certificates, each checked against independently assembled
parameter/index/origin/endpoint bytes and the production acceptance routine.
Each undergoes nine one-field reconstruction controls through the existing
package-scoped certificate-construction boundary. No reflection or mutation of
retained certificate fields is used. All 612 controls reject. The Java main
currently performs 11,383 assertions.

The Set/exact-two cells cannot construct a valid schema: positive downward
closure rejects them before the registry runs. Their TSV stage is explicitly
`SCHEMA_REJECTED`, not `REGISTRY_REJECTED`. This distinction was found during
initial test execution and preserved rather than treating every exception as
an admission result. Of 9,516 emitted requests, 792 reject at schema construction,
8,656 reject at registry admission, and 68 issue and locally verify.

`RegistryAdmissionExtractor` fixes the complete javac-normalized class trees and
resolved-symbol/modifier inventories of `AlloyLawRegistry`,
`ContainerLawCertificate`, `SemanticProfile`, and `CertificateOrigin`. It does
not offer a learn-current-source mode. These checks bind the reviewed code to
the executable observations; a source hash or syntactic match is not itself a
semantic refinement theorem. The four structures, their helpers and runtime
dependencies are included in the closure input manifest.

The replay encoder emits 298 kernel-checked conjunctions covering all 9,516
requests. Actual issuance, acceptance and independently measured index matches
enter separately from the reconstructed input request. The request census,
source-object census and rejection stages are checked before encoding. Profile
strings use strict canonical Base64 and lossless UTF-8 decoding, not aliases.

## Rejection Controls And Trust

Three Lean negative controls change observed acceptance, index matching, or
attempt to admit a unit law. Four source variants remove parameter comparison,
admit custom profiles, shift the root path, or remove exact operator identity
checking. Each must reject with exactly exit status 1 in both clean builds.
The encoder's nine unit tests cover representation, census and control contracts.

The declared TCB includes Lean's kernel, javac/JVM and standard-library
contracts, frozen extractors and encoders, SHA-256, the parser and exact-type
classification for finite observations, filesystem/OS and hardware. The general
proof is parametric at those documented representation boundaries; the Java
correspondence result is bounded. A complete source/parser/compiler refinement,
all operator semantic laws, raw-source certificate replay, and empirical claims
remain outside this five-obligation package.

Local compilation and initial tests are development evidence only. Final status
comes from the two-clean-build report bound to the final input root.
