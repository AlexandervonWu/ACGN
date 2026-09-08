# Independent P2-19 Registry Review

## Result

**PASS, bounded P2-19 obligations only.** No reproducible blocking defect was found in the declared general admission/index model and bounded DIRECT Java correspondence. This is not a global-matrix PASS, a whole-Java refinement theorem, or the final integrated closure report.

Reviewed on 2026-09-08. The reviewed encoder includes the integration namespace `ACGN.ThirdFive.RegistryReplay` and explicit namespace endings in negative slices. No implementation was edited. The only repository write by this review is this report; compilations, registered source variants, and generated evidence are isolated under `/tmp/acgn-p219-review-xx020elo`. Neither supplied development-output directory was reused.

The mechanical-closure skill and protocol were read. This is an audit of the requested finite surface, not a redesign of the existing closure schema or an additional compiler-proof obligation. No internet, subagents, new rewrite families, reflection, Unsafe, or mutation of retained objects was used.

## Independently Executed Evidence

Two fresh source/library copies, `A` and `B`, were compiled with OpenJDK/javac 17.0.20, `--release 17 -proc:none -encoding UTF-8`. Lean was 4.33.0, commit `d8b18978322de05a8f3dba51ef03cf5461676c17`; Python was 3.10.11; host was Linux 7.0.0-31-generic x86_64. Both builds completed successfully.

| Check | Result in each clean build |
| --- | --- |
| Fresh Java compilation and regression main | Exit 0; 9,516 rows, 68 issued, 8,656 registry rejections, 612 reconstruction controls, 11,383 assertions |
| Independently counted schema-rejection stage | 792 `SCHEMA_REJECTED`; not counted as registry execution |
| Frozen resolved-source extractor | Exit 0; exactly four expected owners/shapes/binding inventories |
| General Lean model | Exit 0; 17 theorem axiom reports |
| Generated namespaced replay | Exit 0; 298 kernel-checked groups covering 9,516 requests |
| Observed-acceptance, observed-index, invented-unit negative replays | Each exit 1, specifically because `decide` reports the proposition false |
| Four registered source variants | Each exit 1 at `Unregistered registry source shape/binding`; no output TSV retained |
| Encoder unit tests | Exit 0; all nine tests pass |

Positive Lean outputs contain no `sorryAx`. General theorem dependencies are confined to `propext`, `Classical.choice`, and `Quot.sound`; the replay groups depend on `propext`. Failed negative proofs print `sorryAx` as error-recovery output, but their exit status is 1 and they are not accepted evidence. The negative slices include the changed block and a matching namespace ending; no syntax/import failure substitutes for rejection.

All 874 compiled Java class files are byte-identical between builds. The observation TSV, source TSV, generated Lean text, model `.olean`, and both positive axiom inventories also match byte-for-byte. Examined source hashes were checked before execution and again after both builds and supplemental probes. The broader compiled-source inventory was also checked unchanged after the two builds.

Evidence root: `/tmp/acgn-p219-review-xx020elo`. `result.json` records the two-build result; `A` and `B` contain individual command logs, TSVs, Lean outputs, and source variants. The canonical examined manifest is sorted `sha256sum` text with relative paths, two spaces, and LF endings. Its SHA-256 is `a8a4bc120707679270a37e41becd6acf639bf866784634b06ca9b9c43a2b981b`. `build-inputs.sha256`, which additionally binds all compiled Java sources, jars, and the toolchain selector, hashes to `47a80c38af963ab527d30433213bf987e3860bae733f28aa85a5d4ada6d81501`. These are independent audit inventory roots, not a claim about the unreviewed integrated closure manifest.

## Semantic Review

- **Claim preservation: PASS.** The notes retain exact fixed-entry/profile admission and explicitly distinguish the general model from finite implementation observations. They do not promote AST pins to semantic refinement. No earlier associativity-only restriction remains in `familyAdmitted`: all production registry families and all four law constructors participate.
- **Authority: PASS.** `RegistryAdmission.lean:40` branches on a separate `ProfileAuthority`, not temporal/rewrite/profile spelling. Java's public profile constructor assigns CUSTOM; its equality and fingerprint deliberately omit authority. Admission nevertheless tests `isAdmissibleAlloyProfile`. Compatibility admission is internal and does not imply publication authority. The actual parsed-source factory checks command ownership; the six source observations do not override provenance. Its parser/profile-construction boundary remains trusted, not proved by this model.
- **Index and provenance: PASS.** `RegistryAdmission.lean:150` defines executable issuance, and `:168` proves accepted-certificate reconstruction for arbitrary certificates, rather than accepting a validity hypothesis as the conclusion. Full profile key, opcode/identity, result, path, schema, and law survive the structural parameter. Origin kind, theory, declaration function, ordinal, and both endpoint sides are compared. The digest function need not be injective. In Java, `AlloyLawRegistry.accepts` reconstructs parameter and origin; the private, final-field certificate constructor derives index/endpoints and calls `verifyLocal`. The stronger model endpoint checks are consistent with this supported construction boundary; no arbitrary-object mutation is needed or claimed.
- **Independent observations: PASS.** `RegistryAdmissionRegressionTest.java:117` independently assembles the parameter, index, origin declaration, fingerprint comparison, and both source-endpoint keys, then compares actual certificate getters. It separately calls production `accepts` and `verifyLocal`. The finite expected-admission table is not the source of these observed flags. `third_registry_replays.py:96` reads issuance, acceptance, and index matching independently and `:103` conjoins all three with executable Lean admission. Shared structural-key/type/schema helpers are an explicit trusted representation boundary, not an independently proved Java serializer.
- **Coverage honesty: PASS.** The product is exactly two compatibility overflow modes x eleven operator representatives x nine result/element cases x three carriers x four arity policies x four laws, plus six boundary and six actual-source requests. The source-profile rows exercise AND associativity, not the whole product at each source profile. The type cases include Bool, Int, equal/distinct exact relation identities, opaque identity, mismatches, and nested non-One elements. They do not enumerate all relation-family representations, Java types, arity lists, bitwidths, or parser contexts. Set/exact-two construction rejects before admission, and the notes and TSV preserve that distinction. Remaining opcodes have additional Java negatives outside the emitted product. None of these finite limits is represented as a whole-Java theorem.
- **Pins and control contracts: PASS.** `RegistryAdmissionExtractor.java:18` fixes complete normalized class shapes and resolved bindings for four final classes; there is no learn-current-source mode. Each registered mutation is unique in its source, remains analyzable, and fails the pin check in both builds. The encoder validates source census/owner/hash syntax, not the expected digest values again: authenticity comes from the freshly run pinned extractor and frozen inputs. Accordingly, arbitrary caller-supplied TSVs are not authenticated certificates. This review does not promote the standalone encoder to that unclaimed role.

## Additional Adversarial Probes

The independent `IndependentRegistryBoundaryProbe` was compiled from an in-memory Java source unit in the existing theory package and executed against clean build A. It passed **58 assertions**, using only normal source parsing, public APIs, and the same package-scoped certificate constructor used by the package controls. Its complete reproducible source, classpath, exit code, and stdout are retained in `supplemental-probe.json`.

- Parse `sig A {} pred p { some A } run p for 3 but 4 Int` under each overflow mode. Clone all five profile fields with the public constructor. Equality and fingerprint still match, but direct issuance, certificate reconstruction with the clone, and publication all reject. Genuine source profiles publish; compatibility profiles reject non-test publication and retain their test-only allowance.
- From an issued AND certificate, separately change only origin kind, source artifact, declaration ID, or ordinal. Every reconstruction rejects. This isolates the origin fields more finely than the registered aggregate origin replacement.
- Parse legitimate alternate profiles by changing width 4 to 3, or predicate/command label `p` to `q`. Both profiles issue normally, but parameters, origin, index, and both endpoints differ. Transplanting the old parameter, old origin, or both rejects. Reconstructing with both newly matching values succeeds, ensuring that an always-rejecting constructor cannot satisfy this probe.
- A non-root depth `PortPath.at(0).child()` rejects. Source-profile IPLUS issues for modular positive-arity associativity and overflow-forbidding binary commutativity; the latter also uses Java's canonicalization of `ArityPolicy.finite(2, 2)`.

Eleven additional full-census encoder probes all raised `Blocked`: missing request, duplicate request, wrong case order, noncanonical observed Boolean, noncanonical Base64, unregistered authority, schema-rejection relabeled as registry rejection, missing field-control count, missing source object, duplicate source object, and foreign owner. The exact reasons are in `additional-encoder-probes.json`. A separate standard-library CSV read independently confirmed all stage counts, flag agreement, and the sum of 612 field controls.

Reproduction entry points, after a fresh Java compile with the local jars:

```text
java -cp CLASSES:JARS is.fivefivefive.CanDis.theory.RegistryAdmissionRegressionTest BUILD/registry-admission.tsv
java -cp CLASSES RegistryAdmissionExtractor BUILD BUILD/registry-admission-source.tsv
PYTHONPATH=scripts python3 -B -m unittest -v test_third_registry_replays
third_registry_replays.generate(BUILD, FORMAL)
LEAN_PATH=FORMAL lean -o RegistryAdmission.olean RegistryAdmission.lean
LEAN_PATH=FORMAL lean RegistryAdmissionReplay.lean
```

The Python entry point returns `(filename, code, count)` tuples to materialize under FORMAL. Run each `negatives(BUILD, FORMAL)` result with Lean and require exit **1 plus a false-proposition diagnostic**. Apply each `source_mutations()` replacement exactly once in a separate source copy, run the extractor, and require exit **1 plus a source-pin mismatch**, not a compiler error. These are the procedures used in both fresh builds here.

## Exact Examined Hashes

All entries are whole-file SHA-256 hashes. For cited production helpers, examination was restricted to the relevant registry/profile/schema/key/endpoint paths; hashing a file does not assert review of unrelated methods. In particular, `EGraphNode` was consulted for the opcode inventory, and `OperatorDeclaration`/`TypedCertificateEndpoint` for the cited helper paths.

```text
870a35f53e330ed26c0cf1f5b6d68f0c6d16518b1e7c786c904390d52f1367e7  docs/obligation-repair/third-five/registry-notes.md
131984b47089fd7a9c644ffd4233edc095b60d856e269ab6600d21ef11a203a0  docs/section3-repair-audit/formal/RegistryAdmission.lean
722996a123d815da4860cc7f1e4acbae52c50af5a7ebc349e405f42880ebfd81  scripts/java/RegistryAdmissionExtractor.java
e68ba76daab9f1143eb282f48c6d38a5d30c42451d6878f8d8bdc67c45f148f3  scripts/test_third_registry_replays.py
5ed40e3eb837318649e4ffe6a543fb342778ada24fcca66ff400db2a1ce1cf21  scripts/third_registry_replays.py
c4d398b99fb8706f2af89176bfab8f2701cd0937b0aaab010bd211fc5af62f5b  src/is/fivefivefive/CanDis/core/EGraphNode.java
45452b6110434d825dfe442b9becef09005e4ad53650b5dc51b73e1f9447aae4  src/is/fivefivefive/CanDis/theory/AlloyLawRegistry.java
ca18929fe4bd0730315ad60f3de73b2e9cae7dafc7453fd15fdee26705b5c459  src/is/fivefivefive/CanDis/theory/AlloySemanticProfileFactory.java
5e30c9cc91978ca5549c98eac6ac27571e72137d4a14fcbcd790fc2326f5f475  src/is/fivefivefive/CanDis/theory/AlloyTypeBridge.java
f19074047a01ab8c9365ad21c06161ad41080652b9edf4853c76b3bfc2440664  src/is/fivefivefive/CanDis/theory/ArityPolicy.java
028394dc343fc6c2dcad44d8c0fd97af1b5f6b85d7f3698b1936f8217c67fe79  src/is/fivefivefive/CanDis/theory/BagPortSchema.java
49ba3d3b131f639348f898ba24ffc72e0f1146f25c3546c4b7f116979ed7af41  src/is/fivefivefive/CanDis/theory/CertificateOrigin.java
41b906b95355354d1eb90f958896a3696279cb6a182966dfb6204a814920bdfb  src/is/fivefivefive/CanDis/theory/ContainerLawCertificate.java
73b8ee9091e3afd0aa0c47a0d5976eb54ac68c887cb6390b5b34dd1ce2103726  src/is/fivefivefive/CanDis/theory/GraphType.java
05f4aa8525202bb94556fb446458f8acec7103a145a889e1c07d0f350357c306  src/is/fivefivefive/CanDis/theory/OnePortSchema.java
e85dd6f93c09e6f696e732fe885e99ea7c86bc4cde00d2a4dc42f5fc6791f052  src/is/fivefivefive/CanDis/theory/OperatorDeclaration.java
177abad62811f0b1975baa4ce56de99b1f6a0ff11d3c8dbfa8a6c4fde11034d3  src/is/fivefivefive/CanDis/theory/PortPath.java
935222fc63741093c216118253dbb1983e0fd8199b54acf812635fcb0c77cf96  src/is/fivefivefive/CanDis/theory/PortSchema.java
a7ab6af370d23021f969c17c963de906253bfbbdc3166a43f01c81dbc306958b  src/is/fivefivefive/CanDis/theory/RegistryAdmissionRegressionTest.java
01ace00f0a2598fe6cbd0646a520712b61e2efb7e062d661ad91bd8360d532d7  src/is/fivefivefive/CanDis/theory/SemanticProfile.java
e24c02883ae6bea3eda4204b89a703f8bef74f0220e0891b700dd8f542363dd8  src/is/fivefivefive/CanDis/theory/SeqPortSchema.java
2be395bfdb393da747632c7a3157919ad5e326e14c4bd1295ffe8af981021cf6  src/is/fivefivefive/CanDis/theory/SetPortSchema.java
ceb4fb845d3a06f6f2ee7940d9d547226e726dfa58a198fcfc9f4caf0767ec46  src/is/fivefivefive/CanDis/theory/StructuralKey.java
a95c2b9a5f371eff4297c09d94011565d7e995e987931d70459044b369818d2e  src/is/fivefivefive/CanDis/theory/TheoryKeys.java
d1b24d361bb0a814c05b9b219e042a5e8489e058de69570e1da103e7ee6fb5f5  src/is/fivefivefive/CanDis/theory/TypedCertificateEndpoint.java
0b30aee4d0c1706ee9660f61e5762e4afd51126dbb997b9a21c616c141be2b77  src/is/fivefivefive/CanDis/theory/TypedEqualityCertificate.java
```

Runtime imports outside the requested source-review scope were executed and hashed, not source-reviewed: `next_obligation_replays.py` = `77a1b5384a9dbb99479a7fec2754f209ba1e02cb87311d22b0d20b8dc053aac2`; `run_submission_container_closure.py` = `1cb237fdf9e59f021a3906375b43eed68697d0ae1d9f5eae7f7fb9fe2acba528`; `check_rewrite_dispatch_parity.py` = `b89a5276eebdceaa8c99ff9cb1e06ba5488f57801f7942270acef6aeb277ea1a`. These bindings are retained in `encoder-runtime-modules.sha256` and were rechecked.

## Evidence Hashes And Boundary

```text
170bfdce6d42c35914f6c744c7009a1752815614d90b5c172202068091634086  A/registry-admission.tsv
849bdd00d89caa482bf355e264b3f38f2793819f429906aee88786e658c9443b  A/registry-admission-source.tsv
1b03bcce07e8ffdd1d0a051f172c6420f6cbd906f8d527ed8dd9a03bbba8a619  A/formal/RegistryAdmissionReplay.lean
dac64f395a9312fd0bb761dbc5b9952330058b166927ddc4822018275751da56  A/formal/RegistryAdmission.olean
9dfa1f37067233dd05c6dddc8f66bd242741746929b1644857d90948bffe44cd  A/formal/model.log
6c353af4cb16805774dbb64c8686305c2a85cec6c065d4ee421a615e54e7767a  A/formal/replay.log
1e78ee00f4466de7651db0844672d69f102c08f5163ea0a36e34adb8ae7d959f  result.json
466cd5d667fd9a3f51e70d7003ce8cca63ea58fe810c4eb615a88fb3d5be7cec  supplemental-probe.json
5f0b62f823d850bb6507aca1d136f0c8499a6570cbaa00f2b2af53cbfa5b1b58  additional-encoder-probes.json
```

PROVED: the 17 general model theorems and 298 finite replay conjunctions. TESTED: the stated Java observations, constructor controls, source variants, encoder contracts, and supplemental finite probes. CHECKED: four exact source bindings, censuses, rejection diagnostics, source stability, and two-build determinism. TRUSTED: Lean kernel and its reported foundational axioms; javac/JVM/Python and standard-library contracts; the reviewed extractor/encoder and their executed helper imports; SHA-256; parser/profile and exact-type classification at the stated boundary; filesystem, OS, and hardware. OUT_OF_SCOPE: the integrated five-obligation runner/report/manifest, other obligations and rewrite families, universal source/parser/compiler refinement, raw-source certificate replay, operator semantic-law soundness, empirical claims, and hostile arbitrary-object mutation.

The provenance chain assessed here is the P2-19 statement in the hashed notes, through the named model/regression/extractor/encoder, to the fresh execution records and hashed production inputs under that explicit trust. No absence-of-bugs or universal Java guarantee follows.

```json
{
  "audit_id": "P2-19-independent-registry-20260908",
  "bounded_result": "PASS",
  "finite_check_state": "VERIFIED",
  "examined_manifest_sha256": "a8a4bc120707679270a37e41becd6acf639bf866784634b06ca9b9c43a2b981b",
  "clean_builds_passed": 2,
  "general_theorems": 17,
  "replay_groups": 298,
  "observed_rows_per_build": 9516,
  "issued_per_build": 68,
  "reconstruction_controls_per_build": 612,
  "java_assertions_per_build": 11383,
  "negative_lean_runs_rejected": 6,
  "negative_source_runs_rejected": 8,
  "supplemental_java_assertions": 58,
  "supplemental_encoder_rejections": 11,
  "blocking_findings": [],
  "unresolved_bounded_checks": [],
  "final_infrastructure_errors": [],
  "global_matrix_or_integrated_closure_status": "NOT_REVIEWED"
}
```
