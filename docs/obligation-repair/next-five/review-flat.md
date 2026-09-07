# P2-06 Bounded Adversarial Review

**FAIL**: one concrete falsely accepted implementation-to-proof mapping. No scoped semantic defect was found in the unmodified production Java. This is a review verdict, not a mechanical-closure status.

## Finding

**[P1] The extractor accepts shared schema storage as per-instantiation storage.**

[FlatTypeSubstitutionExtractor.java](/home/augustus/ACGN/scripts/java/FlatTypeSubstitutionExtractor.java:110) checks that modeled classes are final, but does not check their field modifiers. Its constructor-body comparison at line 93 cannot distinguish assignment to an instance field from assignment to a static field. The subsequent symbol check at line 144 covers the substitution argument's owner, not the storage of the resulting schemas.

In an isolated source copy, change only [InstantiatedOperator.java](/home/augustus/ACGN/src/is/fivefivefive/CanDis/theory/InstantiatedOperator.java:14):

```diff
-    private final List<PortSchema> portSchemas;
+    private static List<PortSchema> portSchemas;
```

The mutated source compiles with javac 17.0.20. The extractor exits 0 and emits the same mapping as the baseline:

```text
elementSubstitution  resultSubstitution  checkedMethods
typeArguments        typeArguments       10
```

Both baseline and mutant pass **6,307 checks / 675 observations**, producing byte-identical observation TSVs. Yet the public-only [InstanceIsolationWitness.java](/tmp/acgn-p206-review.W6NEcG/InstanceIsolationWitness.java) constructs a valid `Seq/Bag/Set(One(a)) => a` declaration, instantiates `a := Int`, then instantiates `a := Bool`, and rereads the first instance:

```text
SEQ first.element=Bool first.output=Int first.arguments={a=Int} second.output=Bool homogeneous=false
BAG first.element=Bool first.output=Int first.arguments={a=Int} second.output=Bool homogeneous=false
SET first.element=Bool first.output=Int first.arguments={a=Int} second.output=Bool homogeneous=false
```

The witness exits 1 for the mutant and 0 for the baseline, where all three first elements remain `Int`. No reflection, concurrency, direct field writes, or hostile intermediate-object mutation is involved. The sole source mutation is a verifier regression fixture; the behavior is triggered by ordinary public construction and getters.

[FlatTypeSubstitutionRegressionTest.java](/home/augustus/ACGN/src/is/fivefivefive/CanDis/theory/FlatTypeSubstitutionRegressionTest.java:70) creates differently instantiated operators but never rechecks the earlier one's schema after constructing the later one. Its operand rejection still succeeds because `outputType` remains an instance field. The Lean preservation theorem models immutable schema values and therefore cannot justify this accepted Java storage behavior.

**Smallest fix:** require the existing private, final, nonstatic storage contract for the modeled `InstantiatedOperator` fields, using javac field symbols. The declaration-field check in `FlatRootPortExtractor` is an existing local pattern. Add this one-line source mutant as a required rejection and recheck a retained instance's element/result equality after a second instantiation. No production or theorem change is needed for this witness.

## Evidence

Artifacts are retained under `/tmp/acgn-p206-review.W6NEcG`; `baseline` and `static-schema` contain the source snapshots, and `classes`, `static-classes`, `extractor`, and `witness` contain separately compiled outputs.

| Check | Result |
| --- | --- |
| Current Lean proof, pinned installed Lean 4.33.0 | Exit 0; 13 printed theorem inventories, all only `propext` |
| Baseline and static-field-mutant Java compile | Exit 0 |
| Baseline and mutant extractor | Both exit 0; identical mapping |
| Baseline and mutant regression | Both exit 0; 6,307 checks / 675 observations |
| Public instance-isolation witness | Baseline exit 0; mutant exit 1 for all three containers |
| Diagnostic-string-only source change | Accepted, exit 0 |
| Remove exact-type guard | Rejected, exit 1: `Unmodeled flat admission effect` |
| Replace result substitution map with `Map.of()` | Rejected, exit 1: `Unmodeled type effect: InstantiatedOperator#<init>` |
| Remove `One` substitution | Rejected, exit 1: `Unmodeled type effect: OnePortSchema#substitute` |
| Replay encoder unit tests | Four tests passed |

Both mapping TSVs have SHA-256 `2a30f4756ce390218097a532e4b86528c4829dd977ee66b9eaf8c6b4c9a956b2`. Both observation TSVs have SHA-256 `9b67e64db0b6817b2e82c5616c61e0be5799f627cfa2b4af697e121b1aa8f525`.

Reviewed extractor SHA-256: `00a4d5292ba0adcaf67fbcc89d094295bd84c1ae40ff0fed7770f28a76dfec29`; regression: `ec3f056ae7eec2c5bc5afa4441dc6da88865060ca6187148994935e59d4443f8`; proof: `8ec039f1a013f4c7a58b000ce0dcd7e2911a6707bc6b8a5991ab92c80b11d0fd`.

## Limitations

- The proof is parametric in an exact type carrier and one function. It proves equality preservation, not Java `GraphType` interpreter refinement, Alloy subtyping, widening, or injectivity. Those documented limits are not this finding.
- The runtime census covers three homogeneous containers, nine patterns, and 25 ground replacement pairs, with an independent recursive expectation over six type kinds. Structural fixture laws confer no semantic or certificate authority. Dependent sequences and arbitrary hostile object mutation remain outside this review.
- The proof gained `extracted_shared_substitution` during concurrent work, so the checked version has 13 theorem inventories rather than the initially reported 12. Target hashes above identify the reviewed versions.
- The initial full-source build/extraction encountered four unrelated `Pair.of` compile errors in the concurrently added `OrderedCallValidationRegressionTest.java`. Only that test was moved outside `src` in both temporary snapshots before the successful focused runs. No clean whole-worktree build is claimed.
- Full generated replay was attempted, not completed: default Lean recursion depth fails on long type encodings; a supplemental `-DmaxRecDepth=10000` run was terminated to keep the review bounded. Logs are `static-replay.log` and `static-replay-depth10000.log`. No 675-row Lean replay success, two-build closure, or integrated pipeline success is claimed. Identical extracted/observed inputs establish the concrete verifier blind spot independently of that unfinished replay.
- No internet was used. No workspace production, proof, test, or pipeline file was edited; this report is the sole review-owned workspace write.

## Follow-Up: Same-Witness Fix Recheck

**PASS**, bounded to the original shared-instance-state finding. The prior FAIL and its evidence above remain historical; the reviewed fix now rejects that exact mutation through both source extraction and the Java regression.

[FlatTypeSubstitutionExtractor.java](/home/augustus/ACGN/scripts/java/FlatTypeSubstitutionExtractor.java:115) requires every field of each modeled class to have exactly `PRIVATE FINAL` modifiers, excluding static storage. [FlatTypeSubstitutionRegressionTest.java](/home/augustus/ACGN/src/is/fivefivefive/CanDis/theory/FlatTypeSubstitutionRegressionTest.java:72) rechecks the retained Int instance after constructing Bool, then checks the Bool instance. The added `flat-shared-instance-state` entry in [next_obligation_replays.py](/home/augustus/ACGN/scripts/next_obligation_replays.py:100) was loaded and asserted to be unique and to select the original one-line `portSchemas` mutation and `FlatTypeSubstitutionExtractor`.

Fresh source snapshots and separately compiled baseline/mutant outputs are retained under `/tmp/acgn-p206-followup.hk60i0`. The mutant differs only by `private final List<PortSchema> portSchemas;` becoming `private static List<PortSchema> portSchemas;`. The original public-only witness was reused unchanged.

| Follow-up check | Result |
| --- | --- |
| Patched extractor compilation; baseline and mutant Java compilation | All exit 0; current source snapshots required no test exclusions |
| Patched extractor on baseline | Exit 0; original `typeArguments/typeArguments/10` mapping |
| Patched extractor on original static-field mutant | Exit 1: `Exact type state must be private final per-instance storage: portSchemas`; no output TSV |
| Updated regression on baseline | Exit 0: **6,313 checks / 675 observations** |
| Updated regression on original mutant | Exit 1 at line 72: `A later Bool instantiation must not alter the retained Int instance` |
| Unchanged public witness on baseline | Exit 0; retained element/result both Int for Seq, Bag, and Set after Bool construction |
| Unchanged public witness on mutant | Exit 1; retained element Bool / result Int for all three containers, reproducing the original defect |
| Registered source control | Exact original mutation and extractor confirmed programmatically; direct rejection executed above |

The baseline mapping and observation TSV hashes remain the original `2a30f475...956b2` and `9b67e64d...8f525`, respectively; the added checks do not change the observation census. Reviewed workspace files matched the tested snapshot hashes at completion:

- Extractor: `2ee0e87dffa7c0bf52d1bdab06cd438418c84f4b693b7e834944e2be3478a3f2`.
- Regression: `d1941fa3ef371123147a0171630290ffb1e6f3bad526312ab68c32b0671b8346`.
- Replay plugin: `a296ffeed8f3bedd8322de87930175aef1aedc3899a29fd85877f27f06781ae8`.

**Follow-up limitations:** no additional defect search, Lean replay, integrated runner, or two-build closure was attempted. Integrated checks remain with the main run after all edits. The earlier type-model and trust limitations are unchanged. No further fix is requested for this witness. This follow-up only appends to the review-owned report; production, proofs, tests, and pipeline files were not edited, and no internet was used.
