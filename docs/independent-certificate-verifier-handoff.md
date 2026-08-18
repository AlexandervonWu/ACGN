# Independent Certificate Verifier: Phase J Handoff

Date: 2026-08-17  
Branch: `aislop`  
Audited and implemented HEAD: `d2239b53783d874c6ce45f75f9c452b45acd214e`  
Worktree at entry: dirty, with unrelated user/generated files preserved

## Result

Phase J establishes a standalone, fail-closed verifier for the closed
`acgncert-schema-v1` language. It builds on JDK 17 with `java.base` only and
does not load the producer, canonicalizer, pipeline, or repair metric.

The verifier implementation covers every schema proof/event/profile. The
producer exporter does not yet cover every producer transition. It exports
and independently verifies one exact vertical slice only: a nullary source,
one fresh insertion at empty effective support, one canonical orbit member,
and one complete height-one unfolding. Richer traces fail before output with
`UNCHECKABLE`. The producer-to-verifier system must not yet be described as
complete.

## Changed Files

Standalone module (29 files):

```text
certificate-verifier/.gitignore
certificate-verifier/README.md
certificate-verifier/FORMAT.md
certificate-verifier/TRUST.md
certificate-verifier/FAILURE_CODES.md
certificate-verifier/trusted/README.md
certificate-verifier/src/org/acgn/cert/{Bundle,CanonicalProfileVerifier,
  CheckpointVerifier,Codec,FailureCode,FormatException,IndependentVerifier,
  KernelModel,KernelVerifier,Limits,Main,ManifestInspector,Outcome,Profile,
  SourceToKernelVerifier,TermOps,UncheckableException,VerificationPolicy,
  VerificationResult,Wire}.java
certificate-verifier/test/org/acgn/cert/{TestBundleBuilder,VerifierTest}.java
```

Producer bridge and trace retention:

```text
src/is/fivefivefive/CanDis/CanonicalAlloyPipeline.java
src/is/fivefivefive/CanDis/adapter/TheoryAlloyAdapter.java
src/is/fivefivefive/CanDis/theory/TypedSlottedPortEGraph.java
src/is/fivefivefive/CanDis/theory/CertificateBundleWriter.java
src/is/fivefivefive/CanDis/theory/CertificateExportSession.java
src/is/fivefivefive/CanDis/theory/CertificateTraceEvent.java
src/is/fivefivefive/CanDis/theory/CertificateTracePayload.java
src/is/fivefivefive/CanDis/theory/CertificateTraceSink.java
src/is/fivefivefive/CanDis/theory/CertificateTraceSnapshot.java
src/is/fivefivefive/CanDis/theory/NoOpCertificateTraceSink.java
src/is/fivefivefive/CanDis/theory/RecordingCertificateTraceSink.java
src/is/fivefivefive/CanDis/CertificateVerifierExportSmoke.java
```

Audit, handoff, and entry points:

```text
docs/independent-certificate-verifier-audit.md
docs/independent-certificate-verifier-handoff.md
scripts/build_certificate_verifier.sh
scripts/run_certificate_verifier_tests.sh
scripts/run_certificate_verifier_smoke.sh
```

Phase J changes 46 files: 10,632 inserted lines and 9 deleted lines (10,417
lines in new files, plus a tracked-file diff of 215 insertions/9 deletions).
Generated classes/jars remain ignored under `certificate-verifier/build/`.

## Exact Trust Boundary

Trusted:

1. canonical Wire decoding/encoding and SHA-256 from `java.base`;
2. finite typed contexts, source terms, typed injection checking, and
   capture-avoiding action implemented in the standalone module;
3. reflexivity, symmetry, exact-middle transitivity, typed transport,
   checked registered-axiom instantiation, and forward congruence;
4. the named finite replay algorithms for restriction, parent edges,
   containers, alpha action, source-to-kernel replay, graph transitions,
   canonical orbits, and finite unfolding; and
5. the theory digest selected out of band by the caller.

Untrusted: all producer objects and code, `verifyLocal()`, every serialized
endpoint/type/hash/state/revision/orbit/observation claim, the adapter,
canonicalizer, pipeline, repair projection, and distance metric. Equal hashes
or observations never prove equality.

## Proof Coverage

| Variant | Independently synthesized result | Required evidence |
| --- | --- | --- |
| `REFL`, `SYM`, `TRANS` | dependent equality, with exact middle for transitivity | term or exact premise judgments |
| `TRANSPORT` | capture-avoiding action on both endpoints | typed injection; bijection only when onto |
| `AXIOM` | instantiated registered equation | pinned axiom, total typed substitutions, side evidence |
| `CONGRUENCE` | forward source-constructor equality | one proof for every changed direct child |
| `RESTRICT` | old witness equals widened new witness | versioned witnesses and literal inclusion |
| `PARENT_EDGE` | exact child invocation equals embedded parent invocation | child/parent witnesses and embedding |
| `CONTAINER_NORMALIZE` | Seq/Bag/Set normalization | ordered occurrence-to-premise map |
| `STRUCTURAL_ALPHA` | one global capture-avoiding structural action | explicit left/right syntax |
| `FULL_INTERFACE_SYMMETRY` | witness fixed by full typed bijection | descriptor-compatible permutation |
| `KERNEL_REPLAY` | source equals `iota(sigma(K))` in `Gamma0` | complete paths, port proofs, support, maps, structural proof |
| `FRESH_WITNESS` | fresh definition exactly `K` at `Delta` | matching replay, witness, and `iota` |
| `CANONICAL_ORBIT` | source equals global minimum representative | complete free/leader/binder orbit |
| `COLLISION` | equality through two replay sides and one complete key | both replay proofs and identical keys |
| `REBUILD_CONGRUENCE` | checked reconstructed rebuild equality | named reconstructed premise |

There is no generic proof or inverse congruence variant. Supplied false
evidence is `REJECTED`; missing premises needed for an exhaustive replay are
`UNCHECKABLE`.

## Transition Coverage

| Event/profile | Independent check |
| --- | --- |
| Fresh insertion | exact `Delta` allocation, replay/orbit/fresh proofs, state delta |
| Collision | fresh replay plus both collision sides, parent equation, state delta |
| Union | checked parent edge, deterministic state mutation and dirtiness |
| Symmetry | independently checked full-interface symmetry, no parent mutation |
| Restriction | strict typed contraction, versioned witness, complete changed evidence |
| Rebuild record/completion | rebuilt congruence/collision, bounded delta, exact quiescence |
| Path compression | original current edge IDs, composed proof, unchanged semantics |
| Publication | final quiescent revision and complete EC/PC/SC/reference families |
| Canonical | exhaustive finite free/leader/binder orbit and global minimum |
| Unfold | explicit finite `Rep` tree, ambient extension, fresh assignments |
| Pair | both full bundles, same pin, composable replays and one structural kernel |

## Test Inventory

Positive fixtures cover the nullary full/pair profiles, non-surjective support
contraction, binder-block permutation, Seq/Bag/Set semantics, fresh insertion,
collision, distinct-leader union, interface restriction, nonidentity
full-interface symmetry, rebuild, path compression from a two-edge original
path, and finite unfolding.

Adversarial fixtures cover unregistered axioms and altered pins/digests;
ill-typed embeddings/substitutions; false bijections; transitivity mismatch;
inverse child inference; missing congruence/path/replay evidence; pre-find
support; allocation at `Gamma0`; generic replay substitutes; wrong `omega`;
per-element free renaming; incomplete/nonminimal orbit; Bag/Set errors;
automatic symmetry; implicit restriction; one-sided collisions; unsupported
compression maps; stale revisions; dirty publication; invented unfolding
cutoffs; hash-only pair claims; resource caps; malformed payload digests; and
trailing bytes.

## Commands And Results

```bash
scripts/run_certificate_verifier_tests.sh
```

Result: `VerifierTest: 44 checks passed`. The script compiles with
`--release 17 -Xlint:all -Werror`, runs the dependency/import audit, and
reports:

```text
acgn-certificate-verifier.jar -> java.base
```

```bash
scripts/run_certificate_verifier_smoke.sh \
  100 /tmp/acgn-certificate-verifier-smoke-100
```

Result: 100 supported preparations exported twice, all corresponding bytes
identical, all 100 verified under `full`, and pair mode verified. The common
theory digest was:

```text
a5d877177882ef5366d01013be52ca9973e8e5e2a9463d2d19d67084df492b8f
```

The full repository compiled with JDK 17. The unchanged suites passed:

| Suite | Checks |
| --- | ---: |
| `TheoryFoundationsTest` | 1,053 |
| `TheoryPortsTest` | 1,006 |
| `TheoryStateTest` | 4,204 |
| `TheoryCanonicalizationTest` | 11,186 |
| `TheoryLeaderKernelTest` | 233 |
| `TheoryCertificatesTest` | 251 |
| `TheoryCoherentInsertionTest` | 18 |
| `TheoryRebuildTest` | 101 |
| `TheoryFiniteUnfoldingTest` | 424 |
| `TheoryDeterminismTest` | 47 |
| `CanonicalAlloyPipelineTest` | 185 |
| `QuotientRepairDistanceTest` | 13 |

## Remaining `UNCHECKABLE` Producer Cases

`CertificateBundleWriter` currently refuses, before opening its output:

1. any trace other than exactly one successful fresh insertion from the
   exact empty graph;
2. collisions, parent paths, union, symmetry, restriction, rebuild, or path
   compression;
3. nonempty source/free contexts, typed ports, nonempty support, support
   contraction, or nonidentity alpha maps;
4. nontrivial EC/PC/SC families and multiple classes/transitions;
5. Seq/Bag/Set law registries and container normalization evidence; and
6. absent, multiple, recursive, or height-greater-than-one unfoldings.

At verification time, absent proof premises, complete parent paths, orbit
members/generators, transported evidence, current EC/PC/SC members, pair
derivations, or complete finite unfolding records are also `UNCHECKABLE`.
Configured count/depth/orbit/unfold limits are `UNCHECKABLE`, never success.

## Protected Outputs

Phase J did not edit the paper, LaTeX, evaluation prose, metrics, result
directories, generated tables, or checked-in experiment outputs, and did not
run the 61,598-pair corpus. `distance_results/summary.md` was already modified
when this work began and was left untouched.
