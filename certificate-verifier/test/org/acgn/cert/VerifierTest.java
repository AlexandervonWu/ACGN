package org.acgn.cert;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Standalone positive and adversarial regression suite. */
public final class VerifierTest {
    private static final String ALLOY_LAW_VERSION =
            "alloy-container-law-theory-v2";
    private static final String ALLOY_LAW_TEXT = String.join("\n",
            "AND:Set+:A,C,I",
            "OR:Set+:A,C,I",
            "PLUS:Set+:A,C,I",
            "INTERSECT:Set+:A,C,I",
            "IPLUS:forbid=Bag2:C;modular=Bag+:A,C",
            "MUL:forbid=Bag2:C;modular=Bag+:A,C",
            "EQUALS:Bag2:C",
            "NOT_EQUALS:Bag2:C",
            "IFF:Bag2:C",
            "DISJOINT:Bag+:C");
    private static final String ALLOY_LAW_DIGEST = sha256(
            ALLOY_LAW_VERSION + "\n" + ALLOY_LAW_TEXT);
    private static int checks;

    private VerifierTest() {
    }

    public static void main(String[] args) {
        testSubtypeStackLedger();
        testDependentAtomicColumnVocabulary();
        testCallAnchorIsolationPredicate();
        TestBundleBuilder.Encoded fixture = fullFixture();
        IndependentVerifier verifier = new IndependentVerifier();
        VerificationPolicy policy = VerificationPolicy.trust(fixture.theoryDigest());

        for (Profile profile : List.of(
                Profile.KERNEL,
                Profile.CHECKPOINT,
                Profile.CANONICAL,
                Profile.UNFOLD,
                Profile.FULL)) {
            assertOutcome(
                    Outcome.VERIFIED,
                    verifier.verify(fixture.bytes(), profile, policy),
                    "positive " + profile);
        }
        assertOutcome(
                Outcome.VERIFIED,
                verifier.verifyPair(fixture.bytes(), fixture.bytes(), policy),
                "positive pair");
        check(java.util.Arrays.equals(fixture.bytes(), fullFixture().bytes()),
                "identical fixture runs must be byte-identical");

        TestBundleBuilder.Encoded publication = publicationAndFixture();
        for (Profile profile : List.of(
                Profile.KERNEL,
                Profile.CHECKPOINT,
                Profile.CANONICAL,
                Profile.UNFOLD,
                Profile.FULL)) {
            assertOutcome(
                    Outcome.VERIFIED,
                    verify(verifier, publication, profile),
                    "publication semantic evidence " + profile);
        }
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(
                        verifier,
                        withSemanticEvidenceScalars(
                                publication, fixedCompatibilityProfile("FORBID")),
                        Profile.KERNEL),
                "fixed compatibility profile cannot authorize publication");
        assertCode(
                FailureCode.INVALID_RECORD_SHAPE,
                verify(verifier, withSemanticProfileScalar(
                        publication, 2, "mutated-temporal"), Profile.KERNEL),
                "malformed source-command context mutation");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withSemanticProfileScalar(
                        publication,
                        2,
                        sourceCommandContext("5", "true")), Profile.KERNEL),
                "well-formed source-command context mismatch");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withSemanticProfileScalar(
                        publication, 0, "5"), Profile.KERNEL),
                "semantic bitwidth mutation");
        assertCode(
                FailureCode.UNKNOWN_VARIANT,
                verify(verifier, withSemanticProfileScalar(
                        publication, 1, "WRAP"), Profile.KERNEL),
                "semantic overflow mutation");
        assertCode(
                FailureCode.DIGEST_MISMATCH,
                verify(verifier, withSemanticScalar(
                        publication, 5, "0".repeat(64)), Profile.KERNEL),
                "semantic profile fingerprint mutation");
        assertCode(
                FailureCode.DIGEST_MISMATCH,
                verify(verifier, withSemanticScalar(
                        publication, 7, "0".repeat(64)), Profile.KERNEL),
                "Alloy law-registry digest mutation");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withVocabularyRecordScalar(
                        publication, 1, 2, "ALLOY/AND", 2, "ALLOY/OR"),
                        Profile.KERNEL),
                "law-bearing operator mutation");
        assertCode(
                FailureCode.MISSING_EVIDENCE,
                verify(verifier, withVocabularyRecordScalar(
                        publication, 1, 0, "operator/publication/and", 1, "Bool"),
                        Profile.KERNEL),
                "publication runtime type must be an exact type ID");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withLawScalar(
                        publication, "COMMUTATIVITY", 5, "0/1"),
                        Profile.KERNEL),
                "law path mutation");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withVocabularyRecordScalar(
                        publication, 0, 0, "schema/publication/and/set",
                        3, "AT_LEAST:0"), Profile.KERNEL),
                "law carrier arity mutation");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withLawIndexMutation(publication),
                        Profile.KERNEL),
                "law index mutation");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withCrossLawEndpoint(publication), Profile.KERNEL),
                "cross-index law endpoint mutation");
        assertCode(
                FailureCode.INVALID_RECORD_SHAPE,
                verify(verifier, withLawScalar(
                        publication, "COMMUTATIVITY", 10, "not-a-key"),
                        Profile.KERNEL),
                "malformed structural key");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withLawScalar(
                        publication, "COMMUTATIVITY", 3, "Bool"),
                        Profile.KERNEL),
                "law runtime type reference mutation");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withLawScalar(
                        publication, "COMMUTATIVITY", 4, "Bool"),
                        Profile.KERNEL),
                "law exact type ID mutation");
        assertCode(
                FailureCode.CONTENT_ID_MISMATCH,
                verify(verifier, withExactTypeScalar(
                        publication, "BOOL", 1, "INT"), Profile.KERNEL),
                "exact type content mutation");
        assertCode(
                FailureCode.DUPLICATE_ID,
                verify(verifier, duplicateFirstExactType(publication), Profile.KERNEL),
                "duplicate exact type record");
        assertCode(
                FailureCode.NONCANONICAL_ENCODING,
                verify(verifier, reverseExactTypes(publication), Profile.KERNEL),
                "noncanonical exact type order");
        assertCode(
                FailureCode.INVALID_TYPE,
                verify(verifier, typeReferenceNamespaceCollision(), Profile.KERNEL),
                "test-only type display cannot collide with another type ID");
        for (String forbiddenIdentity : List.of(
                "AlloySig:",
                "AlloySig:this/A",
                "AlloySig:S\u200b",
                "AlloySig:S\u0000T",
                "AlloySig:S\ue000",
                "AlloySig:S\u0378")) {
            assertCode(
                    FailureCode.INVALID_TYPE,
                    verify(verifier, publicationWithConstructorType(
                            forbiddenIdentity), Profile.KERNEL),
                    "forbidden exact-type identity");
        }
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, publicationWithConstructorType(
                        "AlloyEmptyRelation$arity=2"), Profile.KERNEL),
                "canonical positive empty relation arity");
        for (String malformedEmpty : List.of(
                "AlloyEmptyRelation",
                "AlloyEmptyRelation$arity=0",
                "AlloyEmptyRelation$arity=-1",
                "AlloyEmptyRelation$arity=02",
                "AlloyEmptyRelation$arity=not-a-number")) {
            assertCode(
                    FailureCode.INVALID_TYPE,
                    verify(verifier, publicationWithConstructorType(
                            malformedEmpty), Profile.KERNEL),
                    "malformed empty relation type " + malformedEmpty);
        }
        assertCode(
                FailureCode.INVALID_TYPE,
                verify(verifier, publicationWithArgumentBearingEmptyRelationType(),
                        Profile.KERNEL),
                "empty relation arity encoding must be nullary");
        assertCode(
                FailureCode.MISSING_EVIDENCE,
                verify(verifier, withoutLaw(
                        publication, "IDEMPOTENCY"), Profile.KERNEL),
                "incomplete exact law coverage");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(verifier, withExtraLaw(publication), Profile.KERNEL),
                "extra law evidence");
        assertCode(
                FailureCode.MISSING_EVIDENCE,
                verify(verifier, publicationUnlicensedBagFixture(), Profile.KERNEL),
                "generic container normalization requires semantic law authority");
        assertCode(
                FailureCode.MISSING_EVIDENCE,
                verify(verifier, publicationAndFixture("false", "0/0"),
                        Profile.KERNEL),
                "container law authority cannot cross operators sharing a schema");
        assertCode(
                FailureCode.MISSING_EVIDENCE,
                verify(verifier, publicationAndFixture(
                        "operator/publication/and", "0/1"), Profile.KERNEL),
                "container law authority cannot cross schema paths");
        assertCode(
                FailureCode.UNSUPPORTED_FORMAT_VERSION,
                verify(
                        verifier,
                        withSchemaVersion(fixture, "acgncert-schema-v2"),
                        Profile.KERNEL),
                "legacy single-owner schema is not silently reinterpreted");
        assertCode(
                FailureCode.UNSUPPORTED_FORMAT_VERSION,
                verify(
                        verifier,
                        withSchemaVersion(fixture, "acgncert-schema-v5"),
                        Profile.KERNEL),
                "rootless-binder schema is not silently reinterpreted");
        assertCode(
                FailureCode.UNSUPPORTED_FORMAT_VERSION,
                verify(
                        verifier,
                        withSchemaVersion(fixture, "acgncert-schema-v6"),
                        Profile.KERNEL),
                "schema without CALL occurrence provenance is not silently reinterpreted");
        assertCode(
                FailureCode.UNSUPPORTED_FORMAT_VERSION,
                verify(
                        verifier,
                        withSchemaVersion(fixture, "acgncert-schema-v7"),
                        Profile.KERNEL),
                "schema without explicit owner EC and retirement sum is rejected");
        assertCode(
                FailureCode.UNSUPPORTED_FORMAT_VERSION,
                verify(
                        verifier,
                        withSchemaVersion(fixture, "acgncert-schema-v8"),
                        Profile.KERNEL),
                "schema without dependent ancestry and boundary children is rejected");
        assertCode(
                FailureCode.UNSUPPORTED_FORMAT_VERSION,
                verify(
                        verifier,
                        withSchemaVersion(fixture, "acgncert-schema-v9"),
                        Profile.KERNEL),
                "schema without correlated DAGs and complete pair matrices is rejected");
        assertCode(
                FailureCode.INVALID_RECORD_SHAPE,
                verify(
                        verifier,
                        fullFixture(
                                BaseOptions.defaults(),
                                TestBundleBuilder::omitShapeOwnerProofForNegativeTest,
                                ignored -> { }),
                        Profile.CHECKPOINT),
                "shape owner proof field is mandatory");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        collisionBucketSnapshotFixture(false),
                        Profile.CHECKPOINT),
                "incomparable leaders coexist in one v8 hash bucket");
        assertCode(
                FailureCode.INVALID_COLLISION,
                verify(
                        verifier,
                        collisionBucketSnapshotFixture(true),
                        Profile.CHECKPOINT),
                "compatible leaders cannot remain in one v8 hash bucket");
        assertCode(
                FailureCode.INVALID_COLLISION,
                verify(
                        verifier,
                        collisionBucketSnapshotFixture(false, true),
                        Profile.CHECKPOINT),
                "shape-owner proof must have exact ambient oriented endpoints");
        assertCode(
                FailureCode.NONCANONICAL_ENCODING,
                verify(verifier, noncanonicalShapeIdFixture(), Profile.CHECKPOINT),
                "shape IDs must be derived from exact owner and canonical term");

        assertCode(
                FailureCode.DIGEST_MISMATCH,
                verify(
                        verifier,
                        withMetadataScalar(fixture, 16, "stale-test-configuration"),
                        Profile.KERNEL),
                "stale configuration provenance");
        assertCode(
                FailureCode.INVALID_RECORD_SHAPE,
                verify(
                        verifier,
                        withMetadataScalar(fixture, 6, "PUBLICATION"),
                        Profile.KERNEL),
                "dirty publication provenance");
        assertCode(
                FailureCode.THEORY_MISMATCH,
                verify(
                        verifier,
                        withMetadataScalar(
                                withMetadataScalar(fixture, 1, "false"),
                                6,
                                "PUBLICATION"),
                        Profile.KERNEL),
                "test-only empty semantic evidence cannot authorize publication");

        byte[] badDigest = fixture.bytes().clone();
        badDigest[badDigest.length - 1] ^= 1;
        assertOutcome(
                Outcome.REJECTED,
                verifier.verify(badDigest, Profile.KERNEL, policy),
                "altered payload digest");

        VerificationPolicy wrongTheory = VerificationPolicy.trust("00".repeat(32));
        assertCode(
                FailureCode.UNTRUSTED_THEORY,
                verifier.verify(fixture.bytes(), Profile.KERNEL, wrongTheory),
                "altered theory pin");

        byte[] trailing = java.util.Arrays.copyOf(fixture.bytes(), fixture.bytes().length + 1);
        assertCode(
                FailureCode.TRAILING_BYTES,
                verifier.verify(trailing, Profile.KERNEL, policy),
                "trailing bytes");

        assertCode(
                FailureCode.UNREGISTERED_AXIOM,
                verify(verifier, unregisteredAxiomFixture(), Profile.KERNEL),
                "unregistered axiom origin");
        assertCode(
                FailureCode.ILL_TYPED_EMBEDDING,
                verify(verifier, illTypedEmbeddingFixture(), Profile.KERNEL),
                "ill-typed embedding");
        assertCode(
                FailureCode.NON_BIJECTIVE_RENAMING,
                verify(verifier, nonBijectiveRenamingFixture(), Profile.KERNEL),
                "non-bijective value labeled a renaming");
        assertCode(
                FailureCode.TRANSITIVITY_MIDDLE_MISMATCH,
                verify(verifier, transitivityMismatchFixture(), Profile.KERNEL),
                "transitivity exact-middle mismatch");
        assertCode(
                FailureCode.INVERSE_CONGRUENCE,
                verify(verifier, inverseCongruenceFixture(), Profile.KERNEL),
                "inverse child inference");
        assertCode(
                FailureCode.MISSING_CONGRUENCE_PREMISE,
                verify(verifier, missingCongruenceFixture(), Profile.KERNEL),
                "missing forward-congruence premise");
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, witnessUnfoldIdentityFixture(), Profile.KERNEL),
                "witness unfolding under identity embedding");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.NONE),
                        Profile.KERNEL),
                "witness unfolding under nonidentity embedding");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        witnessUnfoldFixture(
                                WitnessUnfoldMutation.COHERENT_ALTERNATE_WITNESS),
                        Profile.KERNEL),
                "witness unfolding reconstructs a coherent alternate witness");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        witnessUnfoldFixture(
                                WitnessUnfoldMutation.COHERENT_ALTERNATE_EMBEDDING),
                        Profile.KERNEL),
                "witness unfolding reconstructs a coherent alternate embedding");
        assertCode(
                FailureCode.ENDPOINT_CLAIM_MISMATCH,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.WRONG_WITNESS),
                        Profile.KERNEL),
                "witness unfolding rejects a substituted witness");
        assertCode(
                FailureCode.ENDPOINT_CLAIM_MISMATCH,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.WRONG_EMBEDDING),
                        Profile.KERNEL),
                "witness unfolding rejects a substituted embedding");
        assertCode(
                FailureCode.INVALID_UNFOLDING,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.WRONG_CONTEXT),
                        Profile.KERNEL),
                "witness unfolding rejects the wrong claimed context");
        assertCode(
                FailureCode.INVALID_UNFOLDING,
                verify(
                        verifier,
                        witnessUnfoldFixture(
                                WitnessUnfoldMutation.WRONG_EMBEDDING_SOURCE),
                        Profile.KERNEL),
                "witness unfolding rejects the wrong embedding source");
        assertCode(
                FailureCode.ENDPOINT_CLAIM_MISMATCH,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.WRONG_SORT),
                        Profile.KERNEL),
                "witness unfolding rejects a fabricated claimed sort");
        assertCode(
                FailureCode.ENDPOINT_CLAIM_MISMATCH,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.WRONG_LEFT),
                        Profile.KERNEL),
                "witness unfolding rejects a fabricated left endpoint");
        assertCode(
                FailureCode.ENDPOINT_CLAIM_MISMATCH,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.WRONG_RIGHT),
                        Profile.KERNEL),
                "witness unfolding rejects a fabricated right endpoint");
        assertCode(
                FailureCode.INVALID_RECORD_SHAPE,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.EXTRA_PREMISE),
                        Profile.KERNEL),
                "witness unfolding rejects premises");
        for (WitnessUnfoldMutation mutation : List.of(
                WitnessUnfoldMutation.WRONG_PAYLOAD_TAG,
                WitnessUnfoldMutation.MISSING_PAYLOAD_SCALAR,
                WitnessUnfoldMutation.EXTRA_PAYLOAD_SCALAR,
                WitnessUnfoldMutation.EXTRA_PAYLOAD_CHILD)) {
            assertCode(
                    FailureCode.INVALID_RECORD_SHAPE,
                    verify(verifier, witnessUnfoldFixture(mutation), Profile.KERNEL),
                    "witness unfolding rejects malformed payload " + mutation);
        }
        assertCode(
                FailureCode.DANGLING_REFERENCE,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.DANGLING_WITNESS),
                        Profile.KERNEL),
                "witness unfolding rejects a dangling witness");
        assertCode(
                FailureCode.DANGLING_REFERENCE,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.DANGLING_EMBEDDING),
                        Profile.KERNEL),
                "witness unfolding rejects a dangling embedding");
        assertCode(
                FailureCode.UNKNOWN_VARIANT,
                verify(
                        verifier,
                        witnessUnfoldFixture(WitnessUnfoldMutation.WRONG_VARIANT),
                        Profile.KERNEL),
                "witness unfolding remains a closed proof variant");

        TestBundleBuilder.Encoded genericReplay = fullFixture(
                BaseOptions.defaults().withGenericReplayInEvent(), ignored -> { });
        assertCode(
                FailureCode.INVALID_RECORD_SHAPE,
                verify(verifier, genericReplay, Profile.CHECKPOINT),
                "generic substitute for d_n^w");
        TestBundleBuilder.Encoded incompleteOrbit = fullFixture(
                BaseOptions.defaults().withOmittedFreeRenaming(), ignored -> { });
        assertOutcome(
                Outcome.UNCHECKABLE,
                verify(verifier, incompleteOrbit, Profile.CANONICAL),
                "incomplete canonical orbit");
        TestBundleBuilder.Encoded dirtyPublication = fullFixture(
                BaseOptions.defaults().withDirtyPublication(), ignored -> { });
        assertCode(
                FailureCode.DIRTY_PUBLICATION,
                verify(verifier, dirtyPublication, Profile.CHECKPOINT),
                "publication while dirty");
        TestBundleBuilder.Encoded stalePublication = fullFixture(
                BaseOptions.defaults().withStalePublication(), ignored -> { });
        assertCode(
                FailureCode.STALE_WITNESS_REVISION,
                verify(verifier, stalePublication, Profile.CHECKPOINT),
                "stale coherent-witness revision");
        TestBundleBuilder.Encoded incompleteUnfolding = fullFixture(
                BaseOptions.defaults().withIncompleteUnfolding(), ignored -> { });
        assertCode(
                FailureCode.INCOMPLETE_UNFOLDING,
                verify(verifier, incompleteUnfolding, Profile.UNFOLD),
                "invented finite-unfolding cutoff leaf");
        TestBundleBuilder.Encoded noPairDerivation = fullFixture(
                BaseOptions.defaults().withPublicationInvocation(), ignored -> { });
        assertCode(
                FailureCode.MISSING_PAIR_DERIVATION,
                verifier.verifyPair(
                        noPairDerivation.bytes(), noPairDerivation.bytes(),
                        VerificationPolicy.trust(noPairDerivation.theoryDigest())),
                "equal observations without pair derivation");
        TestBundleBuilder.Encoded ambiguousPair = duplicateRootCanonicalEndpointFixture();
        assertCode(
                FailureCode.NONCANONICAL_ENCODING,
                verifier.verifyPair(
                        ambiguousPair.bytes(), ambiguousPair.bytes(),
                        VerificationPolicy.trust(ambiguousPair.theoryDigest())),
                "PAIR rejects multiple canonical records owned by one source root");

        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, containerPositiveFixture(), Profile.KERNEL),
                "Seq/Bag/Set positive normalization");
        assertCode(
                FailureCode.INVALID_CONTAINER_NORMALIZATION,
                verify(verifier, bagDeduplicationFixture(), Profile.KERNEL),
                "Bag multiplicity must not be deduplicated");
        assertCode(
                FailureCode.INVALID_CONTAINER_NORMALIZATION,
                verify(verifier, prematureSetDeduplicationFixture(), Profile.KERNEL),
                "Set quotient must precede deduplication");
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, binderPermutationFixture(), Profile.KERNEL),
                "descriptor-certified binder-block permutation");
        assertCode(
                FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                verify(verifier, missedCanonicalMinimumFixture(), Profile.CANONICAL),
                "missed smaller canonical key");
        assertCode(
                FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                verify(verifier, missedCanonicalWitnessTieFixture(), Profile.CANONICAL),
                "equal canonical term cannot hide a larger selected witness");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        supportContractionFixture(ContractionMutation.NONE),
                        Profile.KERNEL),
                "non-surjective post-find support contraction");
        assertCode(
                FailureCode.INVALID_EFFECTIVE_SUPPORT,
                verify(
                        verifier,
                        supportContractionFixture(
                                ContractionMutation.PRE_FIND_SUPPORT),
                        Profile.KERNEL),
                "pre-find support substituted for effective support");
        assertCode(
                FailureCode.INVALID_OMEGA,
                verify(
                        verifier,
                        supportContractionFixture(ContractionMutation.WRONG_OMEGA),
                        Profile.KERNEL),
                "omega differs from iota composed after sigma");
        assertCode(
                FailureCode.INVALID_FRESH_WITNESS,
                verify(
                        verifier,
                        supportContractionFixture(
                                ContractionMutation.FRESH_AT_GAMMA),
                        Profile.KERNEL),
                "fresh class allocated at Gamma_0 instead of Delta");
        assertResult(
                Outcome.UNCHECKABLE,
                FailureCode.INCOMPLETE_PARENT_PATH,
                verify(
                        verifier,
                        supportContractionFixture(ContractionMutation.MISSING_PATH),
                        Profile.KERNEL),
                "required parent path removed");
        assertResult(
                Outcome.REJECTED,
                FailureCode.INCOMPLETE_PARENT_PATH,
                verify(
                        verifier,
                        supportContractionFixture(ContractionMutation.WRONG_PATH),
                        Profile.KERNEL),
                "wrong parent occurrence path");
        assertResult(
                Outcome.REJECTED,
                FailureCode.INCOMPLETE_PARENT_PATH,
                verify(
                        verifier,
                        supportContractionFixture(ContractionMutation.WRONG_INITIAL),
                        Profile.KERNEL),
                "wrong initial parent witness");
        assertResult(
                Outcome.REJECTED,
                FailureCode.INCOMPLETE_PARENT_PATH,
                verify(
                        verifier,
                        supportContractionFixture(ContractionMutation.WRONG_LEADER),
                        Profile.KERNEL),
                "wrong leader parent witness");
        assertResult(
                Outcome.REJECTED,
                FailureCode.INCOMPLETE_PARENT_PATH,
                verify(
                        verifier,
                        supportContractionFixture(ContractionMutation.WRONG_FINAL),
                        Profile.KERNEL),
                "wrong final parent invocation");
        assertResult(
                Outcome.REJECTED,
                FailureCode.NONCANONICAL_ENCODING,
                verify(
                        verifier,
                        supportContractionFixture(ContractionMutation.DUPLICATE_PATH),
                        Profile.KERNEL),
                "duplicate parent path");
        assertResult(
                Outcome.REJECTED,
                FailureCode.NONCANONICAL_ENCODING,
                verify(
                        verifier,
                        supportContractionFixture(
                                ContractionMutation.REORDERED_PATHS),
                        Profile.KERNEL),
                "reordered parent paths");
        assertResult(
                Outcome.REJECTED,
                FailureCode.INCOMPLETE_PARENT_PATH,
                verify(
                        verifier,
                        supportContractionFixture(
                                ContractionMutation.DUPLICATE_EDGE),
                        Profile.KERNEL),
                "duplicated parent edge in one path");
        assertResult(
                Outcome.REJECTED,
                FailureCode.INCOMPLETE_PARENT_PATH,
                verify(
                        verifier,
                        supportContractionFixture(ContractionMutation.NON_EDGE_PROOF),
                        Profile.KERNEL),
                "non-parent proof in a parent path");
        assertOutcome(
                Outcome.UNCHECKABLE,
                verify(verifier, collisionMissingSideFixture(), Profile.KERNEL),
                "collision missing its second replay certificate");
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, collisionTransitionFixture(), Profile.CHECKPOINT),
                "certified insertion collision transition");
        assertCode(
                FailureCode.INVALID_REBUILD,
                verify(
                        verifier,
                        collisionTransitionWithoutRebuildStartFixture(),
                        Profile.CHECKPOINT),
                "rebuild completion requires its retained start boundary");
        assertCode(
                FailureCode.INVALID_REBUILD,
                verify(
                        verifier,
                        collisionTransitionWithOpenRebuildFixture(),
                        Profile.CHECKPOINT),
                "checkpoint history cannot end inside an open rebuild interval");
        assertCode(
                FailureCode.INVALID_COLLISION,
                verify(verifier, unlinkedCollisionTransitionFixture(), Profile.CHECKPOINT),
                "collision transition cannot install an independently proved parent edge");
        assertCode(
                FailureCode.INVALID_RECORD_SHAPE,
                verify(verifier, incompleteCollisionTransitionFixture(), Profile.CHECKPOINT),
                "collision transition cannot omit one distinct v8 field");
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, rebuildRecordFixture(), Profile.CHECKPOINT),
                "rebuild-record transition with explicit forward evidence");
        assertCode(
                FailureCode.INVALID_RECORD_SHAPE,
                verify(verifier, incompleteRebuildRecordFixture(), Profile.CHECKPOINT),
                "rebuild-record requires an explicit replacement-or-retirement branch");
        assertCode(
                FailureCode.INVALID_REBUILD,
                verify(verifier, mixedRebuildRecordFixture(), Profile.CHECKPOINT),
                "rebuild replacement cannot also install a retirement");
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, rebuildRetirementFixture(), Profile.CHECKPOINT),
                "rebuild-record retirement is exclusive from replacement");
        assertCode(
                FailureCode.INVALID_RECORD_SHAPE,
                verify(
                        verifier,
                        incompleteRebuildRetirementFixture(),
                        Profile.CHECKPOINT),
                "rebuild retirement cannot omit a conservation-ledger field");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        pathCompressionFixture(false),
                        Profile.CHECKPOINT),
                "path compression from original edge IDs and composed proof");
        assertOutcome(
                Outcome.UNCHECKABLE,
                verify(
                        verifier,
                        pathCompressionFixture(true),
                        Profile.CHECKPOINT),
                "path compression map without original-path evidence");
        assertCode(
                FailureCode.INVALID_SUBSTITUTION,
                verify(verifier, illTypedSubstitutionFixture(), Profile.KERNEL),
                "ill-typed axiom substitution");
        assertCode(
                FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                verify(
                        verifier,
                        localElementRenamingFixture(),
                        Profile.CANONICAL),
                "local-per-element free renamings are not one global action");
        assertCode(
                FailureCode.INVALID_SYMMETRY,
                verify(
                        verifier,
                        automaticSameLeaderSymmetryFixture(),
                        Profile.CHECKPOINT),
                "same-leader collision cannot add symmetry automatically");
        assertCode(
                FailureCode.INVALID_REBUILD,
                verify(
                        verifier,
                        implicitInterfaceMutationFixture(),
                        Profile.CHECKPOINT),
                "rebuild-record mutation cannot bypass its missing start boundary");
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, unionTransitionFixture(), Profile.CHECKPOINT),
                "distinct-leader union with checked endpoint equation");
        assertCode(
                FailureCode.INVALID_UNION,
                verify(verifier, unionTransitionFixture(true), Profile.CHECKPOINT),
                "union cannot silently drop an absorbed owner's shape");
        assertCode(
                FailureCode.INVALID_UNION,
                verify(
                        verifier,
                        unionTransitionFixture(false, true),
                        Profile.CHECKPOINT),
                "ordinary union rehome cannot also claim retirement");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        restrictionTransitionFixture(),
                        Profile.CHECKPOINT),
                "strict interface restriction with versioned witness factorization");
        assertCode(
                FailureCode.INVALID_RESTRICTION,
                verify(verifier, restrictionDeletionAttackFixture(), Profile.CHECKPOINT),
                "RESTRICT_INTERFACE cannot delete an unrelated live shape");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        symmetryTransitionFixture(),
                        Profile.CHECKPOINT),
                "nonidentity full-interface symmetry transition");
        assertCode(
                FailureCode.UNEXPLAINED_STATE_DELTA,
                verify(verifier, symmetryDeletionAttackFixture(), Profile.CHECKPOINT),
                "ADD_SYMMETRY cannot delete an existing SC record while adding another");
        VerificationPolicy capped = new VerificationPolicy(
                Set.of(fixture.theoryDigest()),
                new Limits(
                        fixture.bytes().length + 1,
                        1024,
                        1,
                        32,
                        128,
                        128,
                        128));
        assertOutcome(
                Outcome.UNCHECKABLE,
                verifier.verify(fixture.bytes(), Profile.KERNEL, capped),
                "decoder resource cap cannot produce VERIFIED");

        System.out.println("VerifierTest: " + checks + " checks passed");
    }

    private static void testCallAnchorIsolationPredicate() {
        KernelModel.Context sourceContext = new KernelModel.Context(
                "context/source", List.of());
        KernelModel.Context foreignContext = new KernelModel.Context(
                "context/foreign", List.of());
        KernelModel.Sort sourceSort = new KernelModel.Sort(
                KernelModel.SortKind.TERM, "AlloySig:A");
        KernelModel.Sort foreignSort = new KernelModel.Sort(
                KernelModel.SortKind.TERM, "AlloySig:B");
        KernelModel.Term source = new KernelModel.Term(
                "term/source",
                KernelModel.TermKind.APP,
                sourceContext,
                sourceSort,
                "operator/source",
                List.of(),
                List.of());
        KernelModel.Term marker = new KernelModel.Term(
                "term/marker",
                KernelModel.TermKind.APP,
                sourceContext,
                sourceSort,
                "operator/marker",
                List.of(),
                List.of());
        check(SemanticEvidenceVerifier.isIsolatedCallAnchor(marker, source, 1),
                "one source-matched marker reference is isolated");
        check(!SemanticEvidenceVerifier.isIsolatedCallAnchor(marker, source, 2),
                "a semantically referenced marker is not isolated");
        check(!SemanticEvidenceVerifier.isIsolatedCallAnchor(
                        new KernelModel.Term(
                                marker.id(), marker.kind(), foreignContext,
                                marker.sort(), marker.symbol(),
                                marker.attributes(), marker.children()),
                        source,
                        1),
                "a foreign-context marker is rejected");
        check(!SemanticEvidenceVerifier.isIsolatedCallAnchor(
                        new KernelModel.Term(
                                marker.id(), marker.kind(), marker.context(),
                                foreignSort, marker.symbol(),
                                marker.attributes(), marker.children()),
                        source,
                        1),
                "a foreign-sort marker is rejected");
    }

    private static void testSubtypeStackLedger() {
        SubtypeStackLedger<String> ledger = new SubtypeStackLedger<>();
        ledger.register("Child", List.of("Child", "Parent", "univ"));
        ledger.register("Child", List.of("Child", "Parent", "univ"));
        boolean rejected = false;
        try {
            ledger.register("Child", List.of("Child"));
        } catch (IllegalArgumentException expected) {
            rejected = true;
        }
        check(rejected,
                "a singleton stack cannot replace an authenticated full subtype stack");
    }

    private static void testDependentAtomicColumnVocabulary() {
        check(SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "INT", null, 0),
                "Int is an admitted exact dependent column");
        check(SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:S", 0),
                "a nonempty Alloy signature identity is admitted");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "Bogus", 0),
                "a generic nullary constructor cannot forge an exact column");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:", 0),
                "an empty Alloy signature identity is rejected");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:this/A", 0),
                "a noncanonical this/ Alloy signature identity is rejected");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig: ", 0),
                "a whitespace-only Alloy signature identity is rejected");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:\u00a0", 0),
                "a nonbreaking-space Alloy signature identity is rejected");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:S\u200b", 0),
                "a format-character Alloy signature identity is rejected");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:S\u0000T", 0),
                "a control-character Alloy signature identity is rejected");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:\ud800", 0),
                "an unpaired-surrogate Alloy signature identity is rejected");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:S\ue000", 0),
                "a private-use Alloy signature identity is rejected");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:S\u0378", 0),
                "an unassigned Alloy signature identity is rejected");
        String supplementary = new String(Character.toChars(0x10400));
        check(SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:S" + supplementary, 0),
                "a valid supplementary-plane Alloy signature identity is admitted");
        for (String forbidden : List.of(
                "\u00a0", "\u0000", "\u200b", "\ue000", "\u0378")) {
            check(!SemanticEvidenceVerifier.isAdmittedIdentity(forbidden),
                    "a forbidden polymorphic identity is rejected");
            expectThrows(FormatException.class, () ->
                    SemanticEvidenceVerifier.requireCanonicalIdentity(
                            forbidden, "type parameter"));
        }
        check(SemanticEvidenceVerifier.isAdmittedIdentity("T" + supplementary),
                "a supplementary polymorphic identity is admitted");
        check(SemanticEvidenceVerifier.requireCanonicalIdentity(
                        "T" + supplementary, "type parameter")
                        .equals("T" + supplementary),
                "the polymorphic identity guard preserves supplementary scalars");
        expectThrows(IllegalArgumentException.class, () ->
                Codec.encodeCanonicalUtf8("AlloySig:\ud800"));
        expectThrows(IllegalArgumentException.class, () ->
                Wire.leaf("identity", "AlloySig:\ud800"));
        expectThrows(IllegalArgumentException.class, () ->
                Wire.utf8Length("AlloySig:\ud800"));
        expectThrows(FormatException.class, () ->
                SemanticEvidenceVerifier.decodeCanonicalUtf8(
                        new byte[] {(byte) 0xed, (byte) 0xa0, (byte) 0x80},
                        "test identity"));
        check(SemanticEvidenceVerifier.decodeCanonicalUtf8(
                        ("S" + supplementary).getBytes(StandardCharsets.UTF_8),
                        "test identity").equals("S" + supplementary),
                "strict UTF-8 replay admits a valid supplementary-plane identity");
        check(!SemanticEvidenceVerifier.isAdmittedAtomicChainColumn(
                        "CONSTRUCTOR", "AlloySig:S", 1),
                "a constructor application is not one atomic column");
    }

    private static VerificationResult verify(
            IndependentVerifier verifier,
            TestBundleBuilder.Encoded fixture,
            Profile profile) {
        return verifier.verify(
                fixture.bytes(), profile,
                VerificationPolicy.trust(fixture.theoryDigest()));
    }

    private static TestBundleBuilder.Encoded unregisteredAxiomFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> fixture.builder().proof(
                "AXIOM",
                fixture.empty(),
                "TERM",
                "Bool",
                fixture.truth(),
                fixture.truth(),
                List.of(),
                Wire.node(
                        "axiom-instance",
                        List.of("missing/axiom", fixture.empty().scalar(0)),
                        List.of(
                                Wire.node("type-substitution", List.of()),
                                Wire.node("term-substitution", List.of()),
                                Wire.node("side-evidence", List.of())))));
    }

    private static TestBundleBuilder.Encoded illTypedEmbeddingFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            Wire.Node source = fixture.builder().context(List.of(
                    Wire.leaf("slot", "x", "T")));
            Wire.Node target = fixture.builder().context(List.of(
                    Wire.leaf("slot", "y", "U")));
            fixture.builder().embedding(
                    "INJECTION", source, target, Map.of("x", "y"));
        });
    }

    private static TestBundleBuilder.Encoded nonBijectiveRenamingFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            Wire.Node source = fixture.builder().context(List.of(
                    Wire.leaf("slot", "x", "T")));
            Wire.Node target = fixture.builder().context(List.of(
                    Wire.leaf("slot", "y", "T"),
                    Wire.leaf("slot", "z", "T")));
            fixture.builder().embedding(
                    "BIJECTION", source, target, Map.of("x", "y"));
        });
    }

    private static TestBundleBuilder.Encoded transitivityMismatchFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            Wire.Node falsity = booleanConstant(fixture, "false/trans");
            Wire.Node falseRefl = fixture.builder().proof(
                    "REFL", fixture.empty(), "TERM", "Bool",
                    falsity, falsity, List.of(),
                    Wire.leaf("refl", falsity.scalar(0)));
            fixture.builder().proof(
                    "TRANS", fixture.empty(), "TERM", "Bool",
                    fixture.truth(), falsity,
                    List.of(fixture.reflexive(), falseRefl),
                    Wire.node("trans", List.of()));
        });
    }

    private static TestBundleBuilder.Encoded inverseCongruenceFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            Wire.Node falsity = booleanConstant(fixture, "false/inverse");
            fixture.builder().proof(
                    "CONGRUENCE", fixture.empty(), "TERM", "Bool",
                    fixture.truth(), falsity, List.of(),
                    Wire.leaf(
                            "congruence",
                            fixture.truth().scalar(0), falsity.scalar(0)));
        });
    }

    private static TestBundleBuilder.Encoded missingCongruenceFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node falsity = booleanConstant(fixture, "false/congruence");
            String one = builder.schema(
                    "schema/one-bool/congruence", "ONE_TERM", "Bool", "")
                    .scalar(0);
            builder.operator("operator/box/congruence", "Bool", one);
            Wire.Node truePort = builder.term(
                    "ONE_TERM", fixture.empty(), "PORT", one, one,
                    List.of(), fixture.truth());
            Wire.Node falsePort = builder.term(
                    "ONE_TERM", fixture.empty(), "PORT", one, one,
                    List.of(), falsity);
            Wire.Node left = builder.term(
                    "APP", fixture.empty(), "TERM", "Bool",
                    "operator/box/congruence", List.of(), truePort);
            Wire.Node right = builder.term(
                    "APP", fixture.empty(), "TERM", "Bool",
                    "operator/box/congruence", List.of(), falsePort);
            builder.proof(
                    "CONGRUENCE", fixture.empty(), "TERM", "Bool",
                    left, right, List.of(),
                    Wire.leaf("congruence", left.scalar(0), right.scalar(0)));
        });
    }

    private static TestBundleBuilder.Encoded witnessUnfoldIdentityFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> fixture.builder().proof(
                "WITNESS_UNFOLD",
                fixture.empty(),
                "TERM",
                fixture.truth().scalar(4),
                fixture.invoke(),
                fixture.truth(),
                List.of(),
                Wire.leaf(
                        "witness-unfold", "w0@1", fixture.identity().scalar(0))));
    }

    private static TestBundleBuilder.Encoded witnessUnfoldFixture(
            WitnessUnfoldMutation mutation) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            String type = "WitnessUnfoldT";
            Wire.Node source = builder.context(List.of(
                    Wire.leaf("slot", "x", type)));
            Wire.Node target = builder.context(List.of(
                    Wire.leaf("slot", "y", type),
                    Wire.leaf("slot", "z", type)));
            Wire.Node embedding = builder.embedding(
                    "INJECTION", source, target, Map.of("x", "y"));
            Wire.Node alternateEmbedding = builder.embedding(
                    "INJECTION", source, target, Map.of("x", "z"));
            Wire.Node otherSource = builder.context(List.of(
                    Wire.leaf("slot", "q", type)));
            Wire.Node wrongSourceEmbedding = builder.embedding(
                    "INJECTION", otherSource, target, Map.of("q", "y"));
            Wire.Node sourceSlot = builder.term(
                    "SLOT", source, "TERM", type, "x", List.of());
            Wire.Node targetSlot = builder.term(
                    "SLOT", target, "TERM", type, "y", List.of());
            Wire.Node alternateTargetSlot = builder.term(
                    "SLOT", target, "TERM", type, "z", List.of());
            builder.operator("witness-unfold/constant", type);
            Wire.Node alternateDefinition = builder.term(
                    "APP", source, "TERM", type,
                    "witness-unfold/constant", List.of());
            Wire.Node actedAlternateDefinition = builder.term(
                    "APP", target, "TERM", type,
                    "witness-unfold/constant", List.of());
            builder.witness(
                    "witness-unfold/source", 1, "unfold-class", source, type, sourceSlot);
            builder.witness(
                    "witness-unfold/alternate", 1, "alternate-class",
                    source, type, alternateDefinition);
            Wire.Node invocation = builder.term(
                    "INVOKE", target, "TERM", type, "witness-unfold/source",
                    List.of(embedding.scalar(0)));
            Wire.Node alternateWitnessInvocation = builder.term(
                    "INVOKE", target, "TERM", type, "witness-unfold/alternate",
                    List.of(embedding.scalar(0)));
            Wire.Node alternateEmbeddingInvocation = builder.term(
                    "INVOKE", target, "TERM", type, "witness-unfold/source",
                    List.of(alternateEmbedding.scalar(0)));

            String variant = mutation == WitnessUnfoldMutation.WRONG_VARIANT
                    ? "WITNESS_UNF0LD" : "WITNESS_UNFOLD";
            Wire.Node claimedContext = mutation == WitnessUnfoldMutation.WRONG_CONTEXT
                    ? source : target;
            Wire.Node claimedLeft = switch (mutation) {
                case WRONG_LEFT -> targetSlot;
                case COHERENT_ALTERNATE_WITNESS -> alternateWitnessInvocation;
                case COHERENT_ALTERNATE_EMBEDDING -> alternateEmbeddingInvocation;
                default -> invocation;
            };
            Wire.Node claimedRight = switch (mutation) {
                case WRONG_RIGHT -> invocation;
                case COHERENT_ALTERNATE_WITNESS -> actedAlternateDefinition;
                case COHERENT_ALTERNATE_EMBEDDING -> alternateTargetSlot;
                default -> targetSlot;
            };
            String payloadWitness = switch (mutation) {
                case WRONG_WITNESS, COHERENT_ALTERNATE_WITNESS ->
                        "witness-unfold/alternate";
                case DANGLING_WITNESS -> "witness-unfold/missing";
                default -> "witness-unfold/source";
            };
            String payloadEmbedding = switch (mutation) {
                case WRONG_EMBEDDING, COHERENT_ALTERNATE_EMBEDDING ->
                        alternateEmbedding.scalar(0);
                case WRONG_EMBEDDING_SOURCE -> wrongSourceEmbedding.scalar(0);
                case DANGLING_EMBEDDING -> "embedding/witness-unfold/missing";
                default -> embedding.scalar(0);
            };
            List<Wire.Node> premises = mutation == WitnessUnfoldMutation.EXTRA_PREMISE
                    ? List.of(fixture.reflexive()) : List.of();
            Wire.Node payload = switch (mutation) {
                case WRONG_PAYLOAD_TAG -> Wire.leaf(
                        "not-witness-unfold", payloadWitness, payloadEmbedding);
                case MISSING_PAYLOAD_SCALAR -> Wire.leaf(
                        "witness-unfold", payloadWitness);
                case EXTRA_PAYLOAD_SCALAR -> Wire.leaf(
                        "witness-unfold", payloadWitness, payloadEmbedding, "extra");
                case EXTRA_PAYLOAD_CHILD -> Wire.node(
                        "witness-unfold",
                        List.of(payloadWitness, payloadEmbedding),
                        List.of(Wire.node("extra", List.of())));
                default -> Wire.leaf(
                        "witness-unfold", payloadWitness, payloadEmbedding);
            };
            builder.proof(
                    variant,
                    claimedContext,
                    "TERM",
                    mutation == WitnessUnfoldMutation.WRONG_SORT
                            ? "WitnessUnfoldWrongT" : type,
                    claimedLeft,
                    claimedRight,
                    premises,
                    payload);
        });
    }

    private static TestBundleBuilder.Encoded containerPositiveFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            ContainerTerms terms = containerTerms(fixture, "positive");
            TestBundleBuilder builder = fixture.builder();

            List<Wire.Node> seqChildren = List.of(terms.falsePort(), terms.truePort());
            Wire.Node seq = builder.term(
                    "SEQ", fixture.empty(), "PORT", terms.seqSchema(),
                    terms.seqSchema(), List.of(),
                    seqChildren.toArray(Wire.Node[]::new));
            normalize(
                    builder, fixture.empty(), "SEQ", terms.seqSchema(),
                    seq, seq, seqChildren);

            List<Wire.Node> bagChildren = new ArrayList<>(List.of(
                    terms.truePort(), terms.falsePort(), terms.truePort()));
            List<Wire.Node> sortedBag = new ArrayList<>(bagChildren);
            sortedBag.sort(Comparator.comparing(node -> node.scalar(0)));
            Wire.Node bag = builder.term(
                    "BAG", fixture.empty(), "PORT", terms.bagSchema(),
                    terms.bagSchema(), List.of(),
                    bagChildren.toArray(Wire.Node[]::new));
            Wire.Node normalizedBag = builder.term(
                    "BAG", fixture.empty(), "PORT", terms.bagSchema(),
                    terms.bagSchema(), List.of(),
                    sortedBag.toArray(Wire.Node[]::new));
            normalize(
                    builder, fixture.empty(), "BAG", terms.bagSchema(),
                    bag, normalizedBag, bagChildren);

            List<Wire.Node> setChildren = List.of(
                    terms.truePort(), terms.falsePort(), terms.truePort());
            List<Wire.Node> normalizedSetChildren = new ArrayList<>(List.of(
                    terms.truePort(), terms.falsePort()));
            normalizedSetChildren.sort(Comparator.comparing(node -> node.scalar(0)));
            Wire.Node set = builder.term(
                    "SET", fixture.empty(), "PORT", terms.setSchema(),
                    terms.setSchema(), List.of(),
                    setChildren.toArray(Wire.Node[]::new));
            Wire.Node normalizedSet = builder.term(
                    "SET", fixture.empty(), "PORT", terms.setSchema(),
                    terms.setSchema(), List.of(),
                    normalizedSetChildren.toArray(Wire.Node[]::new));
            normalize(
                    builder, fixture.empty(), "SET", terms.setSchema(),
                    set, normalizedSet, setChildren);
        });
    }

    private static TestBundleBuilder.Encoded bagDeduplicationFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            ContainerTerms terms = containerTerms(fixture, "bag-dedup");
            List<Wire.Node> sourceChildren = List.of(
                    terms.truePort(), terms.truePort(), terms.falsePort());
            Wire.Node source = fixture.builder().term(
                    "BAG", fixture.empty(), "PORT", terms.bagSchema(),
                    terms.bagSchema(), List.of(),
                    sourceChildren.toArray(Wire.Node[]::new));
            List<Wire.Node> wronglyUnique = new ArrayList<>(List.of(
                    terms.truePort(), terms.falsePort()));
            wronglyUnique.sort(Comparator.comparing(node -> node.scalar(0)));
            Wire.Node target = fixture.builder().term(
                    "BAG", fixture.empty(), "PORT", terms.bagSchema(),
                    terms.bagSchema(), List.of(),
                    wronglyUnique.toArray(Wire.Node[]::new));
            normalize(
                    fixture.builder(), fixture.empty(), "BAG", terms.bagSchema(),
                    source, target, sourceChildren);
        });
    }

    private static TestBundleBuilder.Encoded prematureSetDeduplicationFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            ContainerTerms terms = containerTerms(fixture, "set-quotient");
            TestBundleBuilder builder = fixture.builder();
            List<Wire.Node> firstChildren = List.of(
                    terms.truePort(), terms.falsePort());
            List<Wire.Node> secondChildren = List.of(
                    terms.falsePort(), terms.truePort());
            List<Wire.Node> normalizedChildren = new ArrayList<>(firstChildren);
            normalizedChildren.sort(Comparator.comparing(node -> node.scalar(0)));
            Wire.Node first = builder.term(
                    "BAG", fixture.empty(), "PORT", terms.bagSchema(),
                    terms.bagSchema(), List.of(),
                    firstChildren.toArray(Wire.Node[]::new));
            Wire.Node second = builder.term(
                    "BAG", fixture.empty(), "PORT", terms.bagSchema(),
                    terms.bagSchema(), List.of(),
                    secondChildren.toArray(Wire.Node[]::new));
            Wire.Node normalized = builder.term(
                    "BAG", fixture.empty(), "PORT", terms.bagSchema(),
                    terms.bagSchema(), List.of(),
                    normalizedChildren.toArray(Wire.Node[]::new));
            Wire.Node firstProof = normalize(
                    builder, fixture.empty(), "BAG", terms.bagSchema(),
                    first, normalized, firstChildren);
            Wire.Node secondProof = normalize(
                    builder, fixture.empty(), "BAG", terms.bagSchema(),
                    second, normalized, secondChildren);

            String outerSet = builder.schema(
                    "schema/set-of-bags/set-quotient",
                    "SET", "", terms.bagSchema()).scalar(0);
            Wire.Node source = builder.term(
                    "SET", fixture.empty(), "PORT", outerSet, outerSet,
                    List.of(), first, second);
            Wire.Node premature = builder.term(
                    "SET", fixture.empty(), "PORT", outerSet, outerSet,
                    List.of(), normalized, normalized);
            builder.proof(
                    "CONTAINER_NORMALIZE",
                    fixture.empty(),
                    "PORT",
                    outerSet,
                    source,
                    premature,
                    List.of(firstProof, secondProof),
                    Wire.node(
                            "container-normalization",
                            List.of(
                                    "SET", source.scalar(0), premature.scalar(0)),
                            List.of(
                                    Wire.leaf("occurrence", "0", firstProof.scalar(0)),
                                    Wire.leaf("occurrence", "1", secondProof.scalar(0)))));
        });
    }

    private static TestBundleBuilder.Encoded binderPermutationFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node bodyContext = builder.context(List.of(
                    Wire.leaf("slot", "b0", "T"),
                    Wire.leaf("slot", "b1", "T")));
            LinkedHashMap<String, String> identityMap = new LinkedHashMap<>();
            identityMap.put("b0", "b0");
            identityMap.put("b1", "b1");
            Wire.Node occurrence = builder.embedding(
                    "BIJECTION", bodyContext, bodyContext, identityMap);
            LinkedHashMap<String, String> swapMap = new LinkedHashMap<>();
            swapMap.put("b0", "b1");
            swapMap.put("b1", "b0");
            builder.embedding("BIJECTION", bodyContext, bodyContext, swapMap);

            String binder = "binder/two-interchangeable";
            builder.binder(
                    binder,
                    List.of(
                            Wire.leaf("coordinate", "0", "b0", "T", "ALL", "d", "s"),
                            Wire.leaf("coordinate", "1", "b1", "T", "ALL", "d", "s")),
                    List.of(Wire.node("generator", List.of("1", "0"), List.of())));
            String one = builder.schema(
                    "schema/binder-one", "ONE_SLOT", "T", "").scalar(0);
            String seq = builder.schema(
                    "schema/binder-seq", "SEQ", "", one).scalar(0);
            String block = builder.schema(
                    "schema/binder-block", "BIND_BLOCK", binder, seq).scalar(0);
            Wire.Node b0 = builder.term(
                    "ONE_SLOT", bodyContext, "PORT", one, one,
                    List.of("b0"));
            Wire.Node b1 = builder.term(
                    "ONE_SLOT", bodyContext, "PORT", one, one,
                    List.of("b1"));
            Wire.Node leftBody = builder.term(
                    "SEQ", bodyContext, "PORT", seq, seq,
                    List.of(), b0, b1);
            Wire.Node rightBody = builder.term(
                    "SEQ", bodyContext, "PORT", seq, seq,
                    List.of(), b1, b0);
            Wire.Node left = builder.term(
                    "BIND_BLOCK", fixture.empty(), "PORT", block, block,
                    List.of(occurrence.scalar(0)), leftBody);
            Wire.Node right = builder.term(
                    "BIND_BLOCK", fixture.empty(), "PORT", block, block,
                    List.of(occurrence.scalar(0)), rightBody);
            builder.proof(
                    "STRUCTURAL_ALPHA", fixture.empty(), "PORT", block,
                    left, right, List.of(),
                    Wire.leaf(
                            "structural-alpha", left.scalar(0), right.scalar(0)));
        });
    }

    private static TestBundleBuilder.Encoded duplicateRootCanonicalEndpointFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node symmetric = builder.proof(
                    "SYM",
                    fixture.empty(),
                    "TERM",
                    fixture.truth().scalar(4),
                    fixture.truth(),
                    fixture.truth(),
                    List.of(fixture.reflexive()),
                    Wire.node("sym", List.of()));
            Wire.Node secondReplay = builder.proof(
                    "KERNEL_REPLAY",
                    fixture.empty(),
                    "TERM",
                    fixture.truth().scalar(4),
                    fixture.truth(),
                    fixture.truth(),
                    List.of(symmetric),
                    Wire.node(
                            "kernel-replay",
                            List.of(
                                    fixture.truth().scalar(0),
                                    fixture.empty().scalar(0),
                                    fixture.truth().scalar(0),
                                    fixture.empty().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0)),
                            List.of(
                                    Wire.node("parent-paths", List.of()),
                                    Wire.node("port-normalizations", List.of()),
                                    Wire.leaf(
                                            "structural-proof", symmetric.scalar(0)),
                                    Wire.node("effective-support", List.of()))));
            Wire.Node secondCanonical = builder.canonicalRecord(
                    fixture.orbit(), fixture.truth(), secondReplay);
            List<Wire.Node> canonicalReferences = new ArrayList<>(List.of(
                    Wire.leaf(
                            "canonical-ref", fixture.canonical().scalar(0)),
                    Wire.leaf(
                            "canonical-ref", secondCanonical.scalar(0))));
            canonicalReferences.sort(Comparator.comparing(node -> node.scalar(0)));
            builder.publication(Wire.node(
                    "publication",
                    List.of(
                            fixture.after().scalar(0),
                            "1",
                            fixture.truth().scalar(0),
                            fixture.truth().scalar(0),
                            "theory-digest-placeholder"),
                    List.of(
                            Wire.node("ec-evidence", List.of(
                                    Wire.leaf("ec", "0", "w0@1"))),
                            Wire.node("pc-evidence", List.of()),
                            Wire.node("sc-evidence", List.of()),
                            Wire.node("canonical-refs", canonicalReferences),
                            Wire.node("unfolding-refs", List.of(
                                    Wire.leaf(
                                            "unfolding-ref",
                                            fixture.unfolding().scalar(0)))))));
        });
    }

    private static TestBundleBuilder.Encoded missedCanonicalMinimumFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node context = builder.context(List.of(
                    Wire.leaf("slot", "x", "T"),
                    Wire.leaf("slot", "y", "T")));
            LinkedHashMap<String, String> identityMap = new LinkedHashMap<>();
            identityMap.put("x", "x");
            identityMap.put("y", "y");
            Wire.Node identity = builder.embedding(
                    "BIJECTION", context, context, identityMap);
            LinkedHashMap<String, String> swapMap = new LinkedHashMap<>();
            swapMap.put("x", "y");
            swapMap.put("y", "x");
            Wire.Node swap = builder.embedding(
                    "BIJECTION", context, context, swapMap);
            String one = builder.schema(
                    "schema/orbit-one", "ONE_SLOT", "T", "").scalar(0);
            String seq = builder.schema(
                    "schema/orbit-seq", "SEQ", "", one).scalar(0);
            builder.operator("operator/orbit-seq", "Bool", seq);
            Wire.Node x = builder.term(
                    "ONE_SLOT", context, "PORT", one, one, List.of("x"));
            Wire.Node y = builder.term(
                    "ONE_SLOT", context, "PORT", one, one, List.of("y"));
            Wire.Node xy = builder.term(
                    "SEQ", context, "PORT", seq, seq, List.of(), x, y);
            Wire.Node yx = builder.term(
                    "SEQ", context, "PORT", seq, seq, List.of(), y, x);
            Wire.Node smaller = builder.term(
                    "APP", context, "TERM", "Bool", "operator/orbit-seq",
                    List.of(), xy);
            Wire.Node larger = builder.term(
                    "APP", context, "TERM", "Bool", "operator/orbit-seq",
                    List.of(), yx);
            List<Wire.Node> renamings = new ArrayList<>(List.of(
                    Wire.leaf("embedding-ref", identity.scalar(0)),
                    Wire.leaf("embedding-ref", swap.scalar(0))));
            renamings.sort(Comparator.comparing(node -> node.scalar(0)));
            builder.proof(
                    "CANONICAL_ORBIT", context, "TERM", "Bool",
                    smaller, larger, List.of(),
                    Wire.node(
                            "canonical-orbit",
                            List.of(
                                    smaller.scalar(0), context.scalar(0),
                                    larger.scalar(0), "2"),
                            List.of(
                                    Wire.node("free-renamings", renamings),
                                    Wire.node(
                                            "leader-groups",
                                            List.of(fixture.after().scalar(0), "complete"),
                                            List.of()),
                                    Wire.node("orbit-minimum", List.of(
                                            Wire.leaf("term-ref", larger.scalar(0)))))));
        });
    }

    private static TestBundleBuilder.Encoded missedCanonicalWitnessTieFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node context = builder.context(List.of(
                    Wire.leaf("slot", "x", "T"),
                    Wire.leaf("slot", "y", "T")));
            Wire.Node identity = builder.embedding(
                    "BIJECTION", context, context, Map.of("x", "x", "y", "y"));
            Wire.Node swap = builder.embedding(
                    "BIJECTION", context, context, Map.of("x", "y", "y", "x"));
            String one = builder.schema(
                    "schema/orbit-tie-one", "ONE_SLOT", "T", "").scalar(0);
            String set = builder.schema(
                    "schema/orbit-tie-set", "SET", "", one).scalar(0);
            builder.operator("operator/orbit-tie-set", "Bool", set);
            Wire.Node x = builder.term(
                    "ONE_SLOT", context, "PORT", one, one, List.of("x"));
            Wire.Node y = builder.term(
                    "ONE_SLOT", context, "PORT", one, one, List.of("y"));
            List<Wire.Node> ordered = new ArrayList<>(List.of(x, y));
            ordered.sort(Comparator.comparing(node -> node.scalar(0)));
            List<Wire.Node> reversed = new ArrayList<>(ordered);
            java.util.Collections.reverse(reversed);
            Wire.Node baseSet = builder.term(
                    "SET", context, "PORT", set, set, List.of(),
                    ordered.toArray(Wire.Node[]::new));
            Wire.Node swappedSet = builder.term(
                    "SET", context, "PORT", set, set, List.of(),
                    reversed.toArray(Wire.Node[]::new));
            Wire.Node base = builder.term(
                    "APP", context, "TERM", "Bool", "operator/orbit-tie-set",
                    List.of(), baseSet);
            Wire.Node source = builder.term(
                    "APP", context, "TERM", "Bool", "operator/orbit-tie-set",
                    List.of(), swappedSet);
            List<Wire.Node> renamings = new ArrayList<>(List.of(
                    Wire.leaf("embedding-ref", identity.scalar(0)),
                    Wire.leaf("embedding-ref", swap.scalar(0))));
            renamings.sort(Comparator.comparing(node -> node.scalar(0)));
            builder.proof(
                    "CANONICAL_ORBIT", context, "TERM", "Bool",
                    source, base, List.of(),
                    Wire.node(
                            "canonical-orbit",
                            List.of(
                                    source.scalar(0),
                                    base.scalar(0),
                                    context.scalar(0),
                                    base.scalar(0),
                                    swap.scalar(0),
                                    "2"),
                            List.of(
                                    Wire.node("free-renamings", renamings),
                                    Wire.node(
                                            "leader-groups",
                                            List.of(fixture.after().scalar(0), "complete"),
                                            List.of()),
                                    Wire.node(
                                            "orbit-minimum",
                                            List.of(
                                                    Wire.leaf(
                                                            "term-ref",
                                                            base.scalar(0)),
                                                    Wire.leaf(
                                                            "embedding-ref",
                                                            swap.scalar(0)))),
                                    Wire.node(
                                            "binder-occurrence-refs",
                                            List.of()))));
        });
    }

    private static TestBundleBuilder.Encoded supportContractionFixture(
            ContractionMutation mutation) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node gamma = builder.context(List.of(
                    Wire.leaf("slot", "x", "T")));
            Wire.Node gammaIdentity = builder.embedding(
                    "BIJECTION", gamma, gamma, Map.of("x", "x"));
            Wire.Node emptyIntoGamma = builder.embedding(
                    "INJECTION", fixture.empty(), gamma, Map.of());

            builder.operator("operator/child-definition", "Bool");
            Wire.Node childDefinition = builder.term(
                    "APP", gamma, "TERM", "Bool",
                    "operator/child-definition", List.of());
            builder.witness("wc@1", 1, "child", gamma, "Bool", childDefinition);
            Wire.Node childInvocation = builder.term(
                    "INVOKE", gamma, "TERM", "Bool", "wc@1",
                    List.of(gammaIdentity.scalar(0)));
            Wire.Node parentInvocation = builder.term(
                    "INVOKE", gamma, "TERM", "Bool", "w0@1",
                    List.of(emptyIntoGamma.scalar(0)));

            String one = builder.schema(
                    "schema/contraction-one", "ONE_TERM", "Bool", "")
                    .scalar(0);
            builder.operator("operator/contraction-wrapper", "Bool", one);
            Wire.Node sourcePort = builder.term(
                    "ONE_TERM", gamma, "PORT", one, one,
                    List.of(), childInvocation);
            Wire.Node normalizedPort = builder.term(
                    "ONE_TERM", gamma, "PORT", one, one,
                    List.of(), parentInvocation);
            Wire.Node kernelPort = builder.term(
                    "ONE_TERM", fixture.empty(), "PORT", one, one,
                    List.of(), fixture.invoke());
            Wire.Node source = builder.term(
                    "APP", gamma, "TERM", "Bool",
                    "operator/contraction-wrapper", List.of(), sourcePort);
            Wire.Node normalized = builder.term(
                    "APP", gamma, "TERM", "Bool",
                    "operator/contraction-wrapper", List.of(), normalizedPort);
            Wire.Node kernel = builder.term(
                    "APP", fixture.empty(), "TERM", "Bool",
                    "operator/contraction-wrapper", List.of(), kernelPort);

            String axiomId = "axiom/child-to-parent";
            builder.axiom(
                    axiomId,
                    Wire.node(
                            "pattern",
                            List.of(
                                    "INVOKE", "TERM", "Bool", "wc@1",
                                    gammaIdentity.scalar(0)),
                            List.of()),
                    Wire.node(
                            "pattern",
                            List.of(
                                    "INVOKE", "TERM", "Bool", "w0@1",
                                    emptyIntoGamma.scalar(0)),
                            List.of()),
                    List.of(),
                    List.of(),
                    List.of());
            Wire.Node endpointEquation = builder.proof(
                    "AXIOM", gamma, "TERM", "Bool",
                    childInvocation, parentInvocation, List.of(),
                    Wire.node(
                            "axiom-instance",
                            List.of(axiomId, gamma.scalar(0)),
                            List.of(
                                    Wire.node("type-substitution", List.of()),
                                    Wire.node("term-substitution", List.of()),
                                    Wire.node("side-evidence", List.of()))));
            Wire.Node parentEdge = builder.proof(
                    "PARENT_EDGE", gamma, "TERM", "Bool",
                    childInvocation, parentInvocation,
                    List.of(endpointEquation),
                    Wire.leaf(
                            "parent-edge", "wc@1", "w0@1",
                            emptyIntoGamma.scalar(0)));
            Wire.Node structural = builder.proof(
                    "REFL", gamma, "TERM", "Bool",
                    normalized, normalized, List.of(),
                    Wire.leaf("refl", normalized.scalar(0)));

            Wire.Node delta = mutation == ContractionMutation.PRE_FIND_SUPPORT
                    ? gamma : fixture.empty();
            Wire.Node inclusion = mutation == ContractionMutation.PRE_FIND_SUPPORT
                    ? gammaIdentity : emptyIntoGamma;
            Wire.Node sigma = fixture.identity();
            Wire.Node omega = mutation == ContractionMutation.WRONG_OMEGA
                    ? fixture.identity() : emptyIntoGamma;
            String path = mutation == ContractionMutation.WRONG_PATH
                    ? "1/0" : "0/0";
            String initial = mutation == ContractionMutation.WRONG_INITIAL
                    ? "w0@1" : "wc@1";
            String leader = mutation == ContractionMutation.WRONG_LEADER
                    ? "wc@1" : "w0@1";
            Wire.Node finalInvocation = mutation == ContractionMutation.WRONG_FINAL
                    ? childInvocation : parentInvocation;
            Wire.Node pathEdge = mutation == ContractionMutation.NON_EDGE_PROOF
                    ? structural : parentEdge;
            Wire.Node pathRecord = Wire.node(
                    "parent-path",
                    List.of(
                            path, initial, leader,
                            finalInvocation.scalar(0)),
                    List.of(Wire.leaf(
                            "edge-ref", pathEdge.scalar(0))));
            List<Wire.Node> pathRecords;
            if (mutation == ContractionMutation.MISSING_PATH) {
                pathRecords = List.of();
            } else if (mutation == ContractionMutation.DUPLICATE_PATH) {
                pathRecords = List.of(pathRecord, pathRecord);
            } else if (mutation == ContractionMutation.REORDERED_PATHS) {
                Wire.Node later = Wire.node(
                        "parent-path",
                        List.of(
                                "1/0", initial, leader,
                                finalInvocation.scalar(0)),
                        List.of(Wire.leaf(
                                "edge-ref", pathEdge.scalar(0))));
                pathRecords = List.of(later, pathRecord);
            } else if (mutation == ContractionMutation.DUPLICATE_EDGE) {
                pathRecords = List.of(Wire.node(
                        "parent-path",
                        List.of(
                                path, initial, leader,
                                finalInvocation.scalar(0)),
                        List.of(
                                Wire.leaf("edge-ref", pathEdge.scalar(0)),
                                Wire.leaf("edge-ref", pathEdge.scalar(0)))));
            } else {
                pathRecords = List.of(pathRecord);
            }
            Wire.Node replay = builder.proof(
                    "KERNEL_REPLAY", gamma, "TERM", "Bool",
                    source, normalized,
                    List.of(parentEdge, structural),
                    Wire.node(
                            "kernel-replay",
                            List.of(
                                    source.scalar(0),
                                    gamma.scalar(0),
                                    kernel.scalar(0),
                                    delta.scalar(0),
                                    inclusion.scalar(0),
                                    sigma.scalar(0),
                                    omega.scalar(0)),
                            List.of(
                                    Wire.node("parent-paths", pathRecords),
                                    Wire.node("port-normalizations", List.of()),
                                    Wire.leaf(
                                            "structural-proof", structural.scalar(0)),
                                    Wire.node(
                                            "effective-support",
                                            mutation == ContractionMutation.PRE_FIND_SUPPORT
                                                    ? List.of("x") : List.of(),
                                            List.of()))));

            if (mutation == ContractionMutation.FRESH_AT_GAMMA) {
                builder.witness(
                        "wf@1", 1, "fresh-wide", gamma, "Bool", normalized);
                builder.proof(
                        "FRESH_WITNESS", gamma, "TERM", "Bool",
                        normalized, normalized, List.of(replay),
                        Wire.leaf(
                                "fresh-witness",
                                "wf@1",
                                normalized.scalar(0),
                                gammaIdentity.scalar(0),
                                replay.scalar(0)));
            }
        });
    }

    private static TestBundleBuilder.Encoded collisionMissingSideFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> fixture.builder().proof(
                "COLLISION",
                fixture.empty(),
                "TERM",
                "Bool",
                fixture.truth(),
                fixture.truth(),
                List.of(fixture.replay()),
                Wire.leaf(
                        "collision",
                        fixture.replay().scalar(0),
                        fixture.replay().scalar(0),
                        "same-complete-key",
                        "same-complete-key")));
    }

    private static TestBundleBuilder.Encoded collisionBucketSnapshotFixture(
            boolean comparable) {
        return collisionBucketSnapshotFixture(comparable, false);
    }

    private static TestBundleBuilder.Encoded collisionBucketSnapshotFixture(
            boolean comparable,
            boolean forgeRightOwnerProof) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node leftContext = builder.context(List.of(
                    Wire.leaf("slot", "left-slot", "Int")));
            Wire.Node rightContext = builder.context(List.of(
                    Wire.leaf(
                            "slot", comparable ? "left-slot" : "right-slot",
                            "Int")));
            Wire.Node ambientContext = comparable
                    ? leftContext
                    : builder.context(List.of(
                            Wire.leaf("slot", "left-slot", "Int"),
                            Wire.leaf("slot", "right-slot", "Int")));
            Wire.Node leftDefinition = builder.term(
                    "APP",
                    leftContext,
                    "TERM",
                    "Bool",
                    "true",
                    List.of());
            Wire.Node rightDefinition = builder.term(
                    "APP",
                    rightContext,
                    "TERM",
                    "Bool",
                    "true",
                    List.of());
            builder.witness("bucket-left@9", 9, "90", leftContext,
                    "Bool", leftDefinition);
            builder.witness("bucket-right@9", 9, "91", rightContext,
                    "Bool", rightDefinition);
            Wire.Node commonShape = builder.term(
                    "APP", ambientContext, "TERM", "Bool", "true", List.of());
            Wire.Node commonReflexive = builder.proof(
                    "REFL", ambientContext, "TERM", "Bool",
                    commonShape, commonShape, List.of(),
                    Wire.leaf("refl", commonShape.scalar(0)));
            Wire.Node commonReplay = builder.proof(
                    "REBUILD_CONGRUENCE", ambientContext, "TERM", "Bool",
                    commonShape, commonShape, List.of(commonReflexive),
                    Wire.leaf("rebuild-congruence", commonReflexive.scalar(0)));
            Wire.Node occurrence = builder.identity(ambientContext);
            Wire.Node leftAmbient = builder.embedding(
                    leftContext.children().size() == ambientContext.children().size()
                            ? "BIJECTION" : "INJECTION",
                    leftContext,
                    ambientContext,
                    Map.of("left-slot", "left-slot"));
            String rightSlot = comparable ? "left-slot" : "right-slot";
            Wire.Node rightAmbient = builder.embedding(
                    rightContext.children().size() == ambientContext.children().size()
                            ? "BIJECTION" : "INJECTION",
                    rightContext,
                    ambientContext,
                    Map.of(rightSlot, rightSlot));
            Wire.Node rightReflexive = builder.proof(
                    "REFL", rightContext, "TERM", "Bool",
                    rightDefinition, rightDefinition, List.of(),
                    Wire.leaf("refl", rightDefinition.scalar(0)));
            String key = termKey(ambientContext, "Bool", "true");
            builder.snapshot(
                    9,
                    "QUIESCENT",
                    List.of(
                            Wire.leaf(
                                    "class", "90", "bucket-left@9",
                                    leftContext.scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "91", "bucket-right@9",
                                    rightContext.scalar(0), "Bool")),
                    List.of(),
                    List.of(
                            Wire.leaf(
                                    "shape", "bucket-shape-left", "90",
                                    commonShape.scalar(0),
                                    commonReplay.scalar(0), occurrence.scalar(0),
                                    leftAmbient.scalar(0), commonReflexive.scalar(0)),
                            Wire.leaf(
                                    "shape", "bucket-shape-right", "91",
                                    commonShape.scalar(0),
                                    commonReplay.scalar(0), occurrence.scalar(0),
                                    rightAmbient.scalar(0),
                                    forgeRightOwnerProof
                                            ? rightReflexive.scalar(0)
                                            : commonReflexive.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", key, "90"),
                            Wire.leaf("hash-owner", key, "91")),
                    List.of(),
                    List.of(),
                    List.of());
        });
    }

    private static TestBundleBuilder.Encoded noncanonicalShapeIdFixture() {
        return fullFixture(
                BaseOptions.defaults(),
                TestBundleBuilder::preserveProvidedShapeIdsForNegativeTest,
                fixture -> { });
    }

    private static TestBundleBuilder.Encoded collisionTransitionFixture() {
        return collisionTransitionFixture(true, false, false, false);
    }

    private static TestBundleBuilder.Encoded unlinkedCollisionTransitionFixture() {
        return collisionTransitionFixture(false, false, false, false);
    }

    private static TestBundleBuilder.Encoded incompleteCollisionTransitionFixture() {
        return collisionTransitionFixture(true, true, false, false);
    }

    private static TestBundleBuilder.Encoded
            collisionTransitionWithoutRebuildStartFixture() {
        return collisionTransitionFixture(true, false, true, false);
    }

    private static TestBundleBuilder.Encoded
            collisionTransitionWithOpenRebuildFixture() {
        return collisionTransitionFixture(true, false, false, true);
    }

    private static TestBundleBuilder.Encoded collisionTransitionFixture(
            boolean linkCollisionToParent,
            boolean omitOwnerProofField,
            boolean omitRebuildStart,
            boolean omitRebuildCompletion) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            builder.witness(
                    "w1@2", 2, "1", fixture.empty(), "Bool", fixture.truth());
            Wire.Node secondInvocation = builder.term(
                    "INVOKE", fixture.empty(), "TERM", "Bool", "w1@2",
                    List.of(fixture.identity().scalar(0)));

            CollisionEdge insertion = witnessCollisionEdge(
                    fixture,
                    "w1@2",
                    "w0@1",
                    secondInvocation,
                    fixture.invoke(),
                    "transition");
            Wire.Node collision = insertion.collision();
            Wire.Node edge = linkCollisionToParent
                    ? insertion.edge()
                    : witnessEdge(
                            fixture,
                            "w1@2",
                            "w0@1",
                            secondInvocation,
                            fixture.invoke(),
                            "unlinked-transition");

            String trueKey = Wire.contentId(Wire.node(
                    "term-key/APP",
                    List.of(
                            fixture.empty().scalar(0), "TERM", "Bool", "true"),
                    List.of()));
            Wire.Node dirty = builder.snapshot(
                    2,
                    "DIRTY",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@2",
                                    fixture.empty().scalar(0), "Bool")),
                    List.of(Wire.leaf(
                            "parent", "edge-1-0", "1", "0",
                            fixture.identity().scalar(0), edge.scalar(0))),
                    List.of(Wire.leaf(
                            "shape", "shape-0", "0", fixture.truth().scalar(0),
                            fixture.replay().scalar(0))),
                    List.of(Wire.leaf("hash-owner", trueKey, "0")),
                    List.of(), List.of(), List.of());
            List<String> collisionFields = new ArrayList<>(List.of(
                    "1",
                    fixture.truth().scalar(0),
                    fixture.truth().scalar(0),
                    insertion.sourceReplay().scalar(0),
                    insertion.fresh().scalar(0),
                    fixture.identity().scalar(0),
                    fixture.identity().scalar(0),
                    fixture.reflexive().scalar(0),
                    "shape-0",
                    collision.scalar(0),
                    edge.scalar(0)));
            if (omitOwnerProofField) {
                collisionFields.remove(7);
            }
            builder.event(
                    1,
                    "INSERT_COLLISION",
                    fixture.after(),
                    dirty,
                    Wire.node("insert-collision", collisionFields, List.of()));
            Wire.Node finalSnapshot = builder.snapshot(
                    2,
                    "QUIESCENT",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@2",
                                    fixture.empty().scalar(0), "Bool")),
                    List.of(Wire.leaf(
                            "parent", "edge-1-0", "1", "0",
                            fixture.identity().scalar(0), edge.scalar(0))),
                    List.of(Wire.leaf(
                            "shape", "shape-0", "0", fixture.truth().scalar(0),
                            fixture.replay().scalar(0))),
                    List.of(Wire.leaf("hash-owner", trueKey, "0")),
                    List.of(), List.of(), List.of());
            int nextSequence = 2;
            if (!omitRebuildStart) {
                addRebuildStart(builder, nextSequence++, dirty);
            }
            if (!omitRebuildCompletion) {
                builder.event(
                        nextSequence,
                        "REBUILD_COMPLETE",
                        dirty,
                        finalSnapshot,
                        Wire.leaf("rebuild-complete", "false"));
            }
            builder.publication(publication(
                    fixture,
                    omitRebuildCompletion ? dirty : finalSnapshot,
                    2,
                    List.of(
                            Wire.leaf("ec", "0", "w0@1"),
                            Wire.leaf("ec", "1", "w1@2")),
                    List.of(Wire.leaf("pc", "edge-1-0", edge.scalar(0)))));
        });
    }

    private static TestBundleBuilder.Encoded rebuildRecordFixture() {
        return rebuildRecordFixture(false, false);
    }

    private static TestBundleBuilder.Encoded incompleteRebuildRecordFixture() {
        return rebuildRecordFixture(true, false);
    }

    private static TestBundleBuilder.Encoded mixedRebuildRecordFixture() {
        return rebuildRecordFixture(false, true);
    }

    private static TestBundleBuilder.Encoded rebuildRecordFixture(
            boolean omitBranch,
            boolean addRetirementToReplacement) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            String one = builder.schema(
                    "schema/rebuild-one", "ONE_TERM", "Bool", "").scalar(0);
            String box = "operator/rebuild-box";
            builder.operator(box, "Bool", one);

            Wire.Node selfInvocation = builder.term(
                    "INVOKE", fixture.empty(), "TERM", "Bool", "w1@2",
                    List.of(fixture.identity().scalar(0)));
            Wire.Node oldPort = builder.term(
                    "ONE_TERM", fixture.empty(), "PORT", one, one,
                    List.of(), selfInvocation);
            Wire.Node oldTerm = builder.term(
                    "APP", fixture.empty(), "TERM", "Bool", box,
                    List.of(), oldPort);
            builder.witness("w1@2", 2, "1", fixture.empty(), "Bool", oldTerm);
            Wire.Node oldReflexive = builder.proof(
                    "REFL", fixture.empty(), "TERM", "Bool",
                    oldTerm, oldTerm, List.of(), Wire.leaf("refl", oldTerm.scalar(0)));
            Wire.Node oldReplay = builder.proof(
                    "KERNEL_REPLAY", fixture.empty(), "TERM", "Bool",
                    oldTerm, oldTerm, List.of(oldReflexive),
                    Wire.node(
                            "kernel-replay",
                            List.of(
                                    oldTerm.scalar(0), fixture.empty().scalar(0),
                                    oldTerm.scalar(0), fixture.empty().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0)),
                            List.of(
                                    Wire.node(
                                            "parent-paths",
                                            List.of(Wire.node(
                                                    "parent-path",
                                                    List.of(
                                                            "0/0", "w1@2", "w1@2",
                                                            selfInvocation.scalar(0)),
                                                    List.of()))),
                                    Wire.node("port-normalizations", List.of()),
                                    Wire.leaf(
                                            "structural-proof", oldReflexive.scalar(0)),
                                    Wire.node("effective-support", List.of()))));
            String oldKey = boxedInvocationKey(
                    fixture, one, box, "w1@2");
            Wire.Node twoLeaders = builder.snapshot(
                    2,
                    "QUIESCENT",
                    classRecords(fixture, List.of(new ClassWitness("1", "w1@2"))),
                    List.of(),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-1", "1", oldTerm.scalar(0),
                                    oldReplay.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", oldKey, "1")),
                    List.of(Wire.leaf("parent-use", "1", "shape-1")),
                    List.of(), List.of());
            Wire.Node oldOrbit = builder.proof(
                    "CANONICAL_ORBIT", fixture.empty(), "TERM", "Bool",
                    oldTerm, oldTerm, List.of(),
                    Wire.node(
                            "canonical-orbit",
                            List.of(
                                    oldTerm.scalar(0), oldTerm.scalar(0),
                                    fixture.empty().scalar(0), oldTerm.scalar(0),
                                    fixture.identity().scalar(0), "1"),
                            List.of(
                                    Wire.node("free-renamings", List.of(Wire.leaf(
                                            "embedding-ref",
                                            fixture.identity().scalar(0)))),
                                    Wire.node(
                                            "leader-groups",
                                            List.of(twoLeaders.scalar(0), "complete"),
                                            List.of(Wire.node(
                                                    "leader-group",
                                                    List.of("0/0", "w1@2"),
                                                    List.of()))),
                                    Wire.node(
                                            "orbit-minimum",
                                            List.of(
                                                    Wire.leaf(
                                                            "term-ref", oldTerm.scalar(0)),
                                                    Wire.leaf(
                                                            "embedding-ref",
                                                            fixture.identity().scalar(0)))),
                                    Wire.node("binder-occurrence-refs", List.of()))));
            Wire.Node oldFresh = builder.proof(
                    "FRESH_WITNESS", fixture.empty(), "TERM", "Bool",
                    oldTerm, oldTerm, List.of(oldReplay),
                    Wire.leaf(
                            "fresh-witness", "w1@2", oldTerm.scalar(0),
                            fixture.identity().scalar(0), oldReplay.scalar(0)));
            builder.event(
                    1, "INSERT_FRESH", fixture.after(), twoLeaders,
                    Wire.leaf(
                            "insert-fresh", "1", "shape-1", oldReplay.scalar(0),
                            oldOrbit.scalar(0), oldFresh.scalar(0)));

            Wire.Node edge = witnessEdge(
                    fixture, "w1@2", "w0@1", selfInvocation, fixture.invoke(),
                    "rebuild-union");
            String transferAxiom = "axiom/rebuild-transfer";
            builder.axiom(
                    transferAxiom,
                    Wire.node(
                            "pattern", List.of("APP", "TERM", "Bool", box),
                            List.of(Wire.node(
                                    "pattern", List.of("ONE_TERM", "PORT", one, one),
                                    List.of(Wire.node(
                                            "pattern",
                                            List.of(
                                                    "INVOKE", "TERM", "Bool", "w1@2",
                                                    fixture.identity().scalar(0)),
                                            List.of()))))),
                    Wire.node(
                            "pattern", List.of("APP", "TERM", "Bool", "true"),
                            List.of()),
                    List.of(), List.of(), List.of());
            Wire.Node transfer = builder.proof(
                    "AXIOM", fixture.empty(), "TERM", "Bool",
                    oldTerm, fixture.truth(), List.of(),
                    Wire.node(
                            "axiom-instance",
                            List.of(transferAxiom, fixture.empty().scalar(0)),
                            List.of(
                                    Wire.node("type-substitution", List.of()),
                                    Wire.node("term-substitution", List.of()),
                                    Wire.node("side-evidence", List.of()))));
            String oldOwnerZero = shapeId("0", oldTerm.scalar(0));
            Wire.Node unionDirty = builder.snapshot(
                    3,
                    "DIRTY",
                    classRecords(fixture, List.of(new ClassWitness("1", "w1@2"))),
                    List.of(parent(
                            "edge-rebuild-union", "1", "0", fixture.identity(), edge)),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-1", "0", oldTerm.scalar(0),
                                    oldReplay.scalar(0), fixture.identity().scalar(0),
                                    fixture.identity().scalar(0), transfer.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", oldKey, "0")),
                    List.of(Wire.leaf("parent-use", "1", "shape-1")),
                    List.of(),
                    List.of(),
                    List.of(Wire.leaf("dirty-shape", "shape-1")));
            builder.event(
                    2, "UNION", twoLeaders, unionDirty,
                    Wire.leaf("union", edge.scalar(0)));

            Wire.Node newPort = builder.term(
                    "ONE_TERM", fixture.empty(), "PORT", one, one,
                    List.of(), fixture.invoke());
            Wire.Node newTerm = builder.term(
                    "APP", fixture.empty(), "TERM", "Bool", box,
                    List.of(), newPort);
            Wire.Node portCongruence = builder.proof(
                    "CONGRUENCE", fixture.empty(), "PORT", one,
                    oldPort, newPort, List.of(edge),
                    Wire.leaf(
                            "congruence", oldPort.scalar(0), newPort.scalar(0)));
            Wire.Node rootCongruence = builder.proof(
                    "CONGRUENCE", fixture.empty(), "TERM", "Bool",
                    oldTerm, newTerm, List.of(portCongruence),
                    Wire.leaf(
                            "congruence", oldTerm.scalar(0), newTerm.scalar(0)));
            Wire.Node rebuild = builder.proof(
                    "REBUILD_CONGRUENCE", fixture.empty(), "TERM", "Bool",
                    oldTerm, newTerm, List.of(rootCongruence),
                    Wire.leaf("rebuild-congruence", rootCongruence.scalar(0)));
            Wire.Node reverseRebuild = builder.proof(
                    "SYM", fixture.empty(), "TERM", "Bool",
                    newTerm, oldTerm, List.of(rebuild), Wire.node("sym", List.of()));
            Wire.Node newOwnerProof = builder.proof(
                    "TRANS", fixture.empty(), "TERM", "Bool",
                    newTerm, fixture.truth(), List.of(reverseRebuild, transfer),
                    Wire.node("trans", List.of()));
            String newKey = boxedInvocationKey(
                    fixture, one, box, "w0@1");
            String newShapeId = shapeId("0", newTerm.scalar(0));
            Wire.Node mixedRetirement = Wire.leaf(
                    "retirement",
                    oldOwnerZero,
                    "0",
                    oldTerm.scalar(0),
                    oldReplay.scalar(0),
                    fixture.identity().scalar(0),
                    newShapeId,
                    rebuild.scalar(0),
                    fixture.identity().scalar(0),
                    transfer.scalar(0),
                    newOwnerProof.scalar(0));
            List<Wire.Node> replacementRetirements = addRetirementToReplacement
                    ? List.of(mixedRetirement) : List.of();
            Wire.Node rebuilt = builder.snapshot(
                    3,
                    "DIRTY",
                    classRecords(fixture, List.of(new ClassWitness("1", "w1@2"))),
                    List.of(parent(
                            "edge-rebuild-union", "1", "0", fixture.identity(), edge)),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-new", "0", newTerm.scalar(0),
                                    rebuild.scalar(0), fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    newOwnerProof.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", newKey, "0")),
                    List.of(Wire.leaf("parent-use", "0", "shape-new")),
                    List.of(),
                    replacementRetirements,
                    List.of());
            addRebuildStart(builder, 3, unionDirty);
            builder.event(
                    4, "REBUILD_RECORD", unionDirty, rebuilt,
                    omitBranch
                            ? Wire.leaf(
                                    "rebuild-record", oldOwnerZero, newShapeId,
                                    rebuild.scalar(0))
                            : Wire.node(
                                    "rebuild-record",
                                    List.of(
                                            oldOwnerZero, newShapeId,
                                            rebuild.scalar(0)),
                                    List.of(Wire.node("replace", List.of()))));
            Wire.Node quiescent = builder.snapshot(
                    3,
                    "QUIESCENT",
                    classRecords(fixture, List.of(new ClassWitness("1", "w1@2"))),
                    List.of(parent(
                            "edge-rebuild-union", "1", "0", fixture.identity(), edge)),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-new", "0", newTerm.scalar(0),
                                    rebuild.scalar(0), fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    newOwnerProof.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", newKey, "0")),
                    List.of(Wire.leaf("parent-use", "0", "shape-new")),
                    List.of(),
                    replacementRetirements,
                    List.of());
            builder.event(
                    5, "REBUILD_COMPLETE", rebuilt, quiescent,
                    Wire.leaf("rebuild-complete", "false"));
            builder.publication(publication(
                    fixture,
                    quiescent,
                    3,
                    List.of(
                            Wire.leaf("ec", "0", "w0@1"),
                            Wire.leaf("ec", "1", "w1@2")),
                    List.of(Wire.leaf(
                            "pc", "edge-rebuild-union", edge.scalar(0)))));
        });
    }

    private static TestBundleBuilder.Encoded rebuildRetirementFixture() {
        return rebuildRetirementFixture(false);
    }

    private static TestBundleBuilder.Encoded incompleteRebuildRetirementFixture() {
        return rebuildRetirementFixture(true);
    }

    private static TestBundleBuilder.Encoded rebuildRetirementFixture(
            boolean omitRetainedOwnerProof) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            String one = builder.schema(
                    "schema/rebuild-retire-one", "ONE_TERM", "Bool", "").scalar(0);
            String box = "operator/rebuild-retire-box";
            builder.operator(box, "Bool", one);

            FreshBox target = addFreshBox(
                    fixture, one, box, "2", "w2@2", 2, "w0@1");
            String targetKey = boxedInvocationKey(
                    fixture, one, box, "w0@1");
            Wire.Node targetInserted = builder.snapshot(
                    2,
                    "QUIESCENT",
                    classRecords(fixture, List.of(new ClassWitness("2", "w2@2"))),
                    List.of(),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-target", "2",
                                    target.term().scalar(0),
                                    target.replay().scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", targetKey, "2")),
                    List.of(Wire.leaf("parent-use", "0", "shape-target")),
                    List.of(), List.of());
            Wire.Node targetOrbit = freshBoxOrbit(
                    fixture, target, targetInserted, "w0@1");
            builder.event(
                    1,
                    "INSERT_FRESH",
                    fixture.after(),
                    targetInserted,
                    Wire.leaf(
                            "insert-fresh", "2", "shape-target",
                            target.replay().scalar(0), targetOrbit.scalar(0),
                            target.fresh().scalar(0)));

            Wire.Node targetEdge = witnessEdge(
                    fixture, "w2@2", "w0@1",
                    target.ownerInvocation(), fixture.invoke(),
                    "rebuild-retire-target-union");
            Wire.Node targetOwnerProof = equationToTruth(
                    fixture, target.term(), one, box, "w0@1",
                    "axiom/rebuild-retire-target-owner");
            Wire.Node targetUnionDirty = builder.snapshot(
                    3,
                    "DIRTY",
                    classRecords(fixture, List.of(new ClassWitness("2", "w2@2"))),
                    List.of(parent(
                            "edge-rebuild-retire-target", "2", "0",
                            fixture.identity(), targetEdge)),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-target", "0",
                                    target.term().scalar(0),
                                    target.replay().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    targetOwnerProof.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", targetKey, "0")),
                    List.of(Wire.leaf("parent-use", "0", "shape-target")),
                    List.of(), List.of(), List.of());
            builder.event(
                    2, "UNION", targetInserted, targetUnionDirty,
                    Wire.leaf("union", targetEdge.scalar(0)));
            Wire.Node targetReady = builder.snapshot(
                    3,
                    "QUIESCENT",
                    classRecords(fixture, List.of(new ClassWitness("2", "w2@2"))),
                    List.of(parent(
                            "edge-rebuild-retire-target", "2", "0",
                            fixture.identity(), targetEdge)),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-target", "0",
                                    target.term().scalar(0),
                                    target.replay().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    targetOwnerProof.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", targetKey, "0")),
                    List.of(Wire.leaf("parent-use", "0", "shape-target")),
                    List.of(), List.of(), List.of());
            addRebuildStart(builder, 3, targetUnionDirty);
            builder.event(
                    4, "REBUILD_COMPLETE", targetUnionDirty, targetReady,
                    Wire.leaf("rebuild-complete", "false"));

            FreshBox old = addFreshBox(
                    fixture, one, box, "1", "w1@4", 4, "w1@4");
            String oldKey = boxedInvocationKey(
                    fixture, one, box, "w1@4");
            Wire.Node oldInserted = builder.snapshot(
                    4,
                    "QUIESCENT",
                    classRecords(fixture, List.of(
                            new ClassWitness("1", "w1@4"),
                            new ClassWitness("2", "w2@2"))),
                    List.of(parent(
                            "edge-rebuild-retire-target", "2", "0",
                            fixture.identity(), targetEdge)),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-old", "1",
                                    old.term().scalar(0), old.replay().scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-target", "0",
                                    target.term().scalar(0),
                                    target.replay().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    targetOwnerProof.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", oldKey, "1"),
                            Wire.leaf("hash-owner", targetKey, "0")),
                    List.of(
                            Wire.leaf("parent-use", "0", "shape-target"),
                            Wire.leaf("parent-use", "1", "shape-old")),
                    List.of(), List.of());
            Wire.Node oldOrbit = freshBoxOrbit(
                    fixture, old, oldInserted, "w1@4");
            builder.event(
                    5,
                    "INSERT_FRESH",
                    targetReady,
                    oldInserted,
                    Wire.leaf(
                            "insert-fresh", "1", "shape-old",
                            old.replay().scalar(0), oldOrbit.scalar(0),
                            old.fresh().scalar(0)));

            Wire.Node oldEdge = witnessEdge(
                    fixture, "w1@4", "w0@1",
                    old.ownerInvocation(), fixture.invoke(),
                    "rebuild-retire-old-union");
            Wire.Node oldOwnerProof = equationToTruth(
                    fixture, old.term(), one, box, "w1@4",
                    "axiom/rebuild-retire-old-owner");
            String oldOwnerZero = shapeId("0", old.term().scalar(0));
            String targetOwnerZero = shapeId("0", target.term().scalar(0));
            Wire.Node oldUnionDirty = builder.snapshot(
                    5,
                    "DIRTY",
                    classRecords(fixture, List.of(
                            new ClassWitness("1", "w1@4"),
                            new ClassWitness("2", "w2@2"))),
                    List.of(
                            parent(
                                    "edge-rebuild-retire-old", "1", "0",
                                    fixture.identity(), oldEdge),
                            parent(
                                    "edge-rebuild-retire-target", "2", "0",
                                    fixture.identity(), targetEdge)),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-old", "0",
                                    old.term().scalar(0), old.replay().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    oldOwnerProof.scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-target", "0",
                                    target.term().scalar(0),
                                    target.replay().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    targetOwnerProof.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", oldKey, "0"),
                            Wire.leaf("hash-owner", targetKey, "0")),
                    List.of(
                            Wire.leaf("parent-use", "0", "shape-target"),
                            Wire.leaf("parent-use", "1", "shape-old")),
                    List.of(), List.of(),
                    List.of(Wire.leaf("dirty-shape", "shape-old")));
            builder.event(
                    6, "UNION", oldInserted, oldUnionDirty,
                    Wire.leaf("union", oldEdge.scalar(0)));

            Wire.Node portCongruence = builder.proof(
                    "CONGRUENCE", fixture.empty(), "PORT", one,
                    old.port(), target.port(), List.of(oldEdge),
                    Wire.leaf(
                            "congruence", old.port().scalar(0),
                            target.port().scalar(0)));
            Wire.Node rootCongruence = builder.proof(
                    "CONGRUENCE", fixture.empty(), "TERM", "Bool",
                    old.term(), target.term(), List.of(portCongruence),
                    Wire.leaf(
                            "congruence", old.term().scalar(0),
                            target.term().scalar(0)));
            Wire.Node rebuild = builder.proof(
                    "REBUILD_CONGRUENCE", fixture.empty(), "TERM", "Bool",
                    old.term(), target.term(), List.of(rootCongruence),
                    Wire.leaf("rebuild-congruence", rootCongruence.scalar(0)));
            List<String> retirementFields = new ArrayList<>(List.of(
                    oldOwnerZero,
                    "0",
                    old.term().scalar(0),
                    old.replay().scalar(0),
                    fixture.identity().scalar(0),
                    targetOwnerZero,
                    rebuild.scalar(0),
                    fixture.identity().scalar(0),
                    oldOwnerProof.scalar(0),
                    targetOwnerProof.scalar(0)));
            if (omitRetainedOwnerProof) {
                retirementFields.remove(retirementFields.size() - 1);
            }
            Wire.Node retirement = Wire.node(
                    "retirement", retirementFields, List.of());
            Wire.Node retired = builder.snapshot(
                    5,
                    "DIRTY",
                    classRecords(fixture, List.of(
                            new ClassWitness("1", "w1@4"),
                            new ClassWitness("2", "w2@2"))),
                    List.of(
                            parent(
                                    "edge-rebuild-retire-old", "1", "0",
                                    fixture.identity(), oldEdge),
                            parent(
                                    "edge-rebuild-retire-target", "2", "0",
                                    fixture.identity(), targetEdge)),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-target", "0",
                                    target.term().scalar(0),
                                    target.replay().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    targetOwnerProof.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", targetKey, "0")),
                    List.of(Wire.leaf("parent-use", "0", "shape-target")),
                    List.of(), List.of(retirement), List.of());
            addRebuildStart(builder, 7, oldUnionDirty);
            builder.event(
                    8,
                    "REBUILD_RECORD",
                    oldUnionDirty,
                    retired,
                    Wire.node(
                            "rebuild-record",
                            List.of(oldOwnerZero, targetOwnerZero, rebuild.scalar(0)),
                            List.of(Wire.leaf("retire", oldOwnerZero))));
            Wire.Node quiescent = builder.snapshot(
                    5,
                    "QUIESCENT",
                    classRecords(fixture, List.of(
                            new ClassWitness("1", "w1@4"),
                            new ClassWitness("2", "w2@2"))),
                    List.of(
                            parent(
                                    "edge-rebuild-retire-old", "1", "0",
                                    fixture.identity(), oldEdge),
                            parent(
                                    "edge-rebuild-retire-target", "2", "0",
                                    fixture.identity(), targetEdge)),
                    List.of(
                            baseShape(fixture).get(0),
                            Wire.leaf(
                                    "shape", "shape-target", "0",
                                    target.term().scalar(0),
                                    target.replay().scalar(0),
                                    fixture.identity().scalar(0),
                                    fixture.identity().scalar(0),
                                    targetOwnerProof.scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", targetKey, "0")),
                    List.of(Wire.leaf("parent-use", "0", "shape-target")),
                    List.of(), List.of(retirement), List.of());
            builder.event(
                    9, "REBUILD_COMPLETE", retired, quiescent,
                    Wire.leaf("rebuild-complete", "false"));
            builder.publication(publication(
                    fixture,
                    quiescent,
                    5,
                    List.of(
                            Wire.leaf("ec", "0", "w0@1"),
                            Wire.leaf("ec", "1", "w1@4"),
                            Wire.leaf("ec", "2", "w2@2")),
                    List.of(
                            Wire.leaf(
                                    "pc", "edge-rebuild-retire-old",
                                    oldEdge.scalar(0)),
                            Wire.leaf(
                                    "pc", "edge-rebuild-retire-target",
                                    targetEdge.scalar(0)))));
        });
    }

    private static FreshBox addFreshBox(
            FixtureParts fixture,
            String one,
            String operator,
            String eclass,
            String witness,
            long revision,
            String invokedWitness) {
        TestBundleBuilder builder = fixture.builder();
        Wire.Node invocation = builder.term(
                "INVOKE", fixture.empty(), "TERM", "Bool", invokedWitness,
                List.of(fixture.identity().scalar(0)));
        Wire.Node port = builder.term(
                "ONE_TERM", fixture.empty(), "PORT", one, one,
                List.of(), invocation);
        Wire.Node term = builder.term(
                "APP", fixture.empty(), "TERM", "Bool", operator,
                List.of(), port);
        builder.witness(witness, revision, eclass, fixture.empty(), "Bool", term);
        Wire.Node ownerInvocation = builder.term(
                "INVOKE", fixture.empty(), "TERM", "Bool", witness,
                List.of(fixture.identity().scalar(0)));
        Wire.Node reflexive = builder.proof(
                "REFL", fixture.empty(), "TERM", "Bool",
                term, term, List.of(), Wire.leaf("refl", term.scalar(0)));
        Wire.Node replay = builder.proof(
                "KERNEL_REPLAY", fixture.empty(), "TERM", "Bool",
                term, term, List.of(reflexive),
                Wire.node(
                        "kernel-replay",
                        List.of(
                                term.scalar(0), fixture.empty().scalar(0),
                                term.scalar(0), fixture.empty().scalar(0),
                                fixture.identity().scalar(0),
                                fixture.identity().scalar(0),
                                fixture.identity().scalar(0)),
                        List.of(
                                Wire.node(
                                        "parent-paths",
                                        List.of(Wire.node(
                                                "parent-path",
                                                List.of(
                                                        "0/0", invokedWitness,
                                                        invokedWitness,
                                                        invocation.scalar(0)),
                                                List.of()))),
                                Wire.node("port-normalizations", List.of()),
                                Wire.leaf("structural-proof", reflexive.scalar(0)),
                                Wire.node("effective-support", List.of()))));
        Wire.Node fresh = builder.proof(
                "FRESH_WITNESS", fixture.empty(), "TERM", "Bool",
                term, term, List.of(replay),
                Wire.leaf(
                        "fresh-witness", witness, term.scalar(0),
                        fixture.identity().scalar(0), replay.scalar(0)));
        return new FreshBox(term, invocation, ownerInvocation, port, replay, fresh);
    }

    private static Wire.Node freshBoxOrbit(
            FixtureParts fixture,
            FreshBox box,
            Wire.Node snapshot,
            String invocationLeader) {
        Wire.Node payload = Wire.node(
                "canonical-orbit",
                List.of(
                        box.term().scalar(0), fixture.empty().scalar(0),
                        box.term().scalar(0), "1"),
                List.of(
                        Wire.node(
                                "free-renamings",
                                List.of(Wire.leaf(
                                        "embedding-ref",
                                        fixture.identity().scalar(0)))),
                        Wire.node(
                                "leader-groups",
                                List.of(snapshot.scalar(0), "complete"),
                                List.of(Wire.node(
                                        "leader-group",
                                        List.of("0/0", invocationLeader),
                                        List.of()))),
                        Wire.node(
                                "orbit-minimum",
                                List.of(Wire.leaf(
                                        "term-ref", box.term().scalar(0))))));
        return fixture.builder().proof(
                "CANONICAL_ORBIT", fixture.empty(), "TERM", "Bool",
                box.term(), box.term(), List.of(),
                payload);
    }

    private static Wire.Node equationToTruth(
            FixtureParts fixture,
            Wire.Node term,
            String one,
            String operator,
            String invokedWitness,
            String axiomId) {
        TestBundleBuilder builder = fixture.builder();
        builder.axiom(
                axiomId,
                Wire.node(
                        "pattern", List.of("APP", "TERM", "Bool", operator),
                        List.of(Wire.node(
                                "pattern", List.of("ONE_TERM", "PORT", one, one),
                                List.of(Wire.node(
                                        "pattern",
                                        List.of(
                                                "INVOKE", "TERM", "Bool",
                                                invokedWitness,
                                                fixture.identity().scalar(0)),
                                        List.of()))))),
                Wire.node(
                        "pattern", List.of("APP", "TERM", "Bool", "true"),
                        List.of()),
                List.of(), List.of(), List.of());
        return builder.proof(
                "AXIOM", fixture.empty(), "TERM", "Bool",
                term, fixture.truth(), List.of(),
                Wire.node(
                        "axiom-instance",
                        List.of(axiomId, fixture.empty().scalar(0)),
                        List.of(
                                Wire.node("type-substitution", List.of()),
                                Wire.node("term-substitution", List.of()),
                                Wire.node("side-evidence", List.of()))));
    }

    private static String boxedInvocationKey(
            FixtureParts fixture,
            String one,
            String operator,
            String witness) {
        Wire.Node invocation = Wire.node(
                "term-key/INVOKE",
                List.of(
                        fixture.empty().scalar(0), "TERM", "Bool", witness,
                        fixture.identity().scalar(0)),
                List.of());
        Wire.Node port = Wire.node(
                "term-key/ONE_TERM",
                List.of(
                        fixture.empty().scalar(0), "PORT", one, one),
                List.of(invocation));
        return Wire.contentId(Wire.node(
                "term-key/APP",
                List.of(
                        fixture.empty().scalar(0), "TERM", "Bool", operator),
                List.of(port)));
    }

    private static TestBundleBuilder.Encoded pathCompressionFixture(
            boolean omitOriginalEdges) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            builder.witness(
                    "w1@2", 2, "1", fixture.empty(), "Bool", fixture.truth());
            Wire.Node invocation1 = builder.term(
                    "INVOKE", fixture.empty(), "TERM", "Bool", "w1@2",
                    List.of(fixture.identity().scalar(0)));
            CollisionEdge collision10 = witnessCollisionEdge(
                    fixture, "w1@2", "w0@1", invocation1, fixture.invoke(), "10");
            Wire.Node edge10 = collision10.edge();
            Wire.Node replacement = witnessEdge(
                    fixture, "w1@2", "w0@1", invocation1, fixture.invoke(),
                    "10-compressed");
            String trueKey = trueTermKey(fixture);

            Wire.Node oneParent = builder.snapshot(
                    2,
                    "DIRTY",
                    classRecords(fixture, List.of(
                            new ClassWitness("1", "w1@2"))),
                    List.of(parent(
                            "edge-1-0", "1", "0", fixture.identity(), edge10)),
                    baseShape(fixture),
                    List.of(Wire.leaf("hash-owner", trueKey, "0")),
                    List.of(), List.of(), List.of());
            builder.event(
                    1,
                    "INSERT_COLLISION",
                    fixture.after(),
                    oneParent,
                    Wire.leaf(
                            "insert-collision", "1", fixture.truth().scalar(0),
                            fixture.truth().scalar(0),
                            collision10.sourceReplay().scalar(0),
                            collision10.fresh().scalar(0),
                            fixture.identity().scalar(0),
                            fixture.identity().scalar(0),
                            fixture.reflexive().scalar(0),
                            "shape-0",
                            collision10.collision().scalar(0),
                            edge10.scalar(0)));

            Wire.Node compressed = builder.snapshot(
                    2,
                    "DIRTY",
                    classRecords(fixture, List.of(new ClassWitness("1", "w1@2"))),
                    List.of(parent(
                            "edge-1-0-compressed", "1", "0",
                            fixture.identity(), replacement)),
                    baseShape(fixture),
                    List.of(Wire.leaf("hash-owner", trueKey, "0")),
                    List.of(), List.of(), List.of());
            List<Wire.Node> originalEdges = omitOriginalEdges
                    ? List.of()
                    : List.of(Wire.leaf("original-edge", "edge-1-0"));
            builder.event(
                    2,
                    "PATH_COMPRESS",
                    oneParent,
                    compressed,
                    Wire.node(
                            "path-compress",
                            List.of("1", replacement.scalar(0)),
                            originalEdges));

            Wire.Node quiescent = builder.snapshot(
                    2,
                    "QUIESCENT",
                    classRecords(fixture, List.of(new ClassWitness("1", "w1@2"))),
                    List.of(parent(
                            "edge-1-0-compressed", "1", "0",
                            fixture.identity(), replacement)),
                    baseShape(fixture),
                    List.of(Wire.leaf("hash-owner", trueKey, "0")),
                    List.of(), List.of(), List.of());
            addRebuildStart(builder, 3, compressed);
            builder.event(
                    4,
                    "REBUILD_COMPLETE",
                    compressed,
                    quiescent,
                    Wire.leaf("rebuild-complete", "false"));
            builder.publication(publication(
                    fixture,
                    quiescent,
                    2,
                    List.of(
                            Wire.leaf("ec", "0", "w0@1"),
                            Wire.leaf("ec", "1", "w1@2")),
                    List.of(Wire.leaf(
                            "pc", "edge-1-0-compressed", replacement.scalar(0)))));
        });
    }

    private static TestBundleBuilder.Encoded withSemanticProfileScalar(
            TestBundleBuilder.Encoded source,
            int index,
            String replacement) {
        return mutateVocabulary(source, vocabulary -> {
            Wire.Node evidence = vocabulary.child(3);
            List<String> scalars = new ArrayList<>(evidence.scalars());
            scalars.set(index, replacement);
            scalars.set(5, sha256(stableKey(
                    "semantic-profile", scalars.subList(0, 5), List.of())));
            return replaceChild(
                    vocabulary,
                    3,
                    Wire.node("semantic-evidence", scalars, evidence.children()));
        });
    }

    private static TestBundleBuilder.Encoded withSemanticScalar(
            TestBundleBuilder.Encoded source,
            int index,
            String replacement) {
        return mutateVocabulary(source, vocabulary -> {
            Wire.Node evidence = vocabulary.child(3);
            List<String> scalars = new ArrayList<>(evidence.scalars());
            scalars.set(index, replacement);
            return replaceChild(
                    vocabulary,
                    3,
                    Wire.node("semantic-evidence", scalars, evidence.children()));
        });
    }

    private static TestBundleBuilder.Encoded withSemanticEvidenceScalars(
            TestBundleBuilder.Encoded source,
            List<String> replacement) {
        return mutateVocabulary(source, vocabulary -> {
            Wire.Node evidence = vocabulary.child(3);
            return replaceChild(
                    vocabulary,
                    3,
                    Wire.node(
                            "semantic-evidence",
                            replacement,
                            evidence.children()));
        });
    }

    private static TestBundleBuilder.Encoded withVocabularyRecordScalar(
            TestBundleBuilder.Encoded source,
            int sectionIndex,
            int matchScalar,
            String match,
            int targetScalar,
            String replacement) {
        return mutateVocabulary(source, vocabulary -> {
            Wire.Node section = vocabulary.child(sectionIndex);
            List<Wire.Node> records = new ArrayList<>(section.children());
            boolean found = false;
            for (int index = 0; index < records.size(); index++) {
                Wire.Node record = records.get(index);
                if (record.scalar(matchScalar).equals(match)) {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(targetScalar, replacement);
                    records.set(index, Wire.node(
                            record.tag(), scalars, record.children()));
                    found = true;
                    break;
                }
            }
            if (!found) {
                throw new AssertionError("Missing fixture record " + match);
            }
            return replaceChild(
                    vocabulary,
                    sectionIndex,
                    Wire.node(section.tag(), section.scalars(), records));
        });
    }

    private static TestBundleBuilder.Encoded withLawScalar(
            TestBundleBuilder.Encoded source,
            String law,
            int scalarIndex,
            String replacement) {
        return mutateLawRecords(source, records -> {
            for (int index = 0; index < records.size(); index++) {
                Wire.Node record = records.get(index);
                if (record.scalar(6).equals(law)) {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(scalarIndex, replacement);
                    records.set(index, Wire.node(
                            record.tag(), scalars, record.children()));
                    return;
                }
            }
            throw new AssertionError("Missing fixture law " + law);
        });
    }

    private static TestBundleBuilder.Encoded withCrossLawEndpoint(
            TestBundleBuilder.Encoded source) {
        return mutateLawRecords(source, records -> {
            Wire.Node associativity = null;
            Wire.Node commutativity = null;
            int associativityIndex = -1;
            for (int index = 0; index < records.size(); index++) {
                Wire.Node record = records.get(index);
                if (record.scalar(6).equals("ASSOCIATIVITY")) {
                    associativity = record;
                    associativityIndex = index;
                } else if (record.scalar(6).equals("COMMUTATIVITY")) {
                    commutativity = record;
                }
            }
            if (associativity == null || commutativity == null) {
                throw new AssertionError("Fixture lacks cross-index laws");
            }
            List<String> scalars = new ArrayList<>(associativity.scalars());
            scalars.set(11, commutativity.scalar(11));
            records.set(associativityIndex, Wire.node(
                    associativity.tag(), scalars, associativity.children()));
        });
    }

    private static TestBundleBuilder.Encoded withLawIndexMutation(
            TestBundleBuilder.Encoded source) {
        return mutateLawRecords(source, records -> {
            for (int index = 0; index < records.size(); index++) {
                Wire.Node record = records.get(index);
                if (record.scalar(6).equals("ASSOCIATIVITY")) {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(0, stableKey(
                            "zzzz-law-index", List.of(), List.of()));
                    records.set(index, Wire.node(
                            record.tag(), scalars, record.children()));
                    records.sort(Comparator.comparing(node -> node.scalar(0)));
                    return;
                }
            }
            throw new AssertionError("Missing fixture associativity law");
        });
    }

    private static TestBundleBuilder.Encoded withExactTypeScalar(
            TestBundleBuilder.Encoded source,
            String kind,
            int scalarIndex,
            String replacement) {
        return mutateExactTypes(source, records -> {
            for (int index = 0; index < records.size(); index++) {
                Wire.Node record = records.get(index);
                if (record.scalar(1).equals(kind)) {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(scalarIndex, replacement);
                    records.set(index, Wire.node(
                            record.tag(), scalars, record.children()));
                    return;
                }
            }
            throw new AssertionError("Missing fixture exact type " + kind);
        });
    }

    private static TestBundleBuilder.Encoded duplicateFirstExactType(
            TestBundleBuilder.Encoded source) {
        return mutateExactTypes(source, records -> records.add(1, records.get(0)));
    }

    private static TestBundleBuilder.Encoded reverseExactTypes(
            TestBundleBuilder.Encoded source) {
        return mutateExactTypes(source, java.util.Collections::reverse);
    }

    private static TestBundleBuilder.Encoded withoutLaw(
            TestBundleBuilder.Encoded source,
            String law) {
        return mutateLawRecords(source, records -> {
            if (!records.removeIf(record -> record.scalar(6).equals(law))) {
                throw new AssertionError("Missing fixture law " + law);
            }
        });
    }

    private static TestBundleBuilder.Encoded withExtraLaw(
            TestBundleBuilder.Encoded source) {
        return mutateLawRecords(source, records -> {
            Wire.Node template = records.get(records.size() - 1);
            List<String> scalars = new ArrayList<>(template.scalars());
            scalars.set(0, stableKey("z".repeat(30), List.of(), List.of()));
            records.add(Wire.node(template.tag(), scalars, template.children()));
        });
    }

    private static TestBundleBuilder.Encoded mutateLawRecords(
            TestBundleBuilder.Encoded source,
            java.util.function.Consumer<List<Wire.Node>> mutation) {
        return mutateSemanticSection(source, 0, mutation);
    }

    private static TestBundleBuilder.Encoded mutateExactTypes(
            TestBundleBuilder.Encoded source,
            java.util.function.Consumer<List<Wire.Node>> mutation) {
        return mutateSemanticSection(source, 4, mutation);
    }

    private static TestBundleBuilder.Encoded mutateSemanticSection(
            TestBundleBuilder.Encoded source,
            int sectionIndex,
            java.util.function.Consumer<List<Wire.Node>> mutation) {
        return mutateVocabulary(source, vocabulary -> {
            Wire.Node evidence = vocabulary.child(3);
            Wire.Node section = evidence.child(sectionIndex);
            List<Wire.Node> records = new ArrayList<>(section.children());
            mutation.accept(records);
            Wire.Node changedSection = Wire.node(
                    section.tag(), section.scalars(), records);
            Wire.Node changedEvidence = replaceChild(
                    evidence, sectionIndex, changedSection);
            return replaceChild(vocabulary, 3, changedEvidence);
        });
    }

    private static TestBundleBuilder.Encoded mutateVocabulary(
            TestBundleBuilder.Encoded source,
            java.util.function.UnaryOperator<Wire.Node> mutation) {
        Wire.Node root = source.root();
        Wire.Node manifest = root.child(1);
        Wire.Node vocabulary = mutation.apply(manifest.child(1));
        Wire.Node changedManifest = Wire.node(
                "manifest",
                List.of(manifest.scalar(0), Wire.contentId(vocabulary)),
                List.of(manifest.child(0), vocabulary));
        Wire.Node changedRoot = replaceChild(root, 1, changedManifest);
        return new TestBundleBuilder.Encoded(
                Codec.encode(changedRoot), changedRoot, source.theoryDigest());
    }

    private static Wire.Node replaceChild(
            Wire.Node parent,
            int index,
            Wire.Node replacement) {
        List<Wire.Node> children = new ArrayList<>(parent.children());
        children.set(index, replacement);
        return Wire.node(parent.tag(), parent.scalars(), children);
    }

    private static TestBundleBuilder.Encoded withMetadataScalar(
            TestBundleBuilder.Encoded source,
            int index,
            String replacement) {
        Wire.Node metadata = source.root().child(0);
        List<String> scalars = new ArrayList<>(metadata.scalars());
        scalars.set(index, replacement);
        List<Wire.Node> children = new ArrayList<>(source.root().children());
        children.set(0, Wire.node("metadata", scalars, List.of()));
        Wire.Node root = Wire.node(
                source.root().tag(), source.root().scalars(), children);
        return new TestBundleBuilder.Encoded(
                Codec.encode(root), root, source.theoryDigest());
    }

    private static TestBundleBuilder.Encoded withSchemaVersion(
            TestBundleBuilder.Encoded source,
            String schemaVersion) {
        Wire.Node root = Wire.node(
                source.root().tag(),
                List.of(schemaVersion),
                source.root().children());
        return new TestBundleBuilder.Encoded(
                Codec.encode(root), root, source.theoryDigest());
    }

    private static TestBundleBuilder.Encoded illTypedSubstitutionFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            String one = builder.schema(
                    "schema/substitution-one", "ONE_TERM", "Bool", "")
                    .scalar(0);
            Wire.Node port = builder.term(
                    "ONE_TERM", fixture.empty(), "PORT", one, one,
                    List.of(), fixture.truth());
            String axiom = "axiom/substitution";
            Wire.Node meta = Wire.node(
                    "pattern",
                    List.of("META", "TERM", "Bool", "p"),
                    List.of());
            builder.axiom(
                    axiom,
                    meta,
                    meta,
                    List.of(),
                    List.of(Wire.leaf(
                            "term-variable", "p", "TERM", "Bool")),
                    List.of());
            builder.proof(
                    "AXIOM", fixture.empty(), "TERM", "Bool",
                    fixture.truth(), fixture.truth(), List.of(),
                    Wire.node(
                            "axiom-instance",
                            List.of(axiom, fixture.empty().scalar(0)),
                            List.of(
                                    Wire.node("type-substitution", List.of()),
                                    Wire.node("term-substitution", List.of(
                                            Wire.leaf(
                                                    "term-entry", "p",
                                                    port.scalar(0)))),
                                    Wire.node("side-evidence", List.of()))));
        });
    }

    private static TestBundleBuilder.Encoded localElementRenamingFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node context = builder.context(List.of(
                    Wire.leaf("slot", "x", "T"),
                    Wire.leaf("slot", "y", "T")));
            LinkedHashMap<String, String> identityMap = new LinkedHashMap<>();
            identityMap.put("x", "x");
            identityMap.put("y", "y");
            Wire.Node identity = builder.embedding(
                    "BIJECTION", context, context, identityMap);
            LinkedHashMap<String, String> swapMap = new LinkedHashMap<>();
            swapMap.put("x", "y");
            swapMap.put("y", "x");
            Wire.Node swap = builder.embedding(
                    "BIJECTION", context, context, swapMap);
            String one = builder.schema(
                    "schema/local-one", "ONE_SLOT", "T", "").scalar(0);
            String bag = builder.schema(
                    "schema/local-bag", "BAG", "", one).scalar(0);
            builder.operator("operator/local-bag", "Bool", bag);
            Wire.Node x = builder.term(
                    "ONE_SLOT", context, "PORT", one, one, List.of("x"));
            Wire.Node y = builder.term(
                    "ONE_SLOT", context, "PORT", one, one, List.of("y"));
            List<Wire.Node> globalChildren = new ArrayList<>(List.of(x, y));
            globalChildren.sort(Comparator.comparing(node -> node.scalar(0)));
            Wire.Node globalBag = builder.term(
                    "BAG", context, "PORT", bag, bag, List.of(),
                    globalChildren.toArray(Wire.Node[]::new));
            Wire.Node mixedBag = builder.term(
                    "BAG", context, "PORT", bag, bag, List.of(), x, x);
            Wire.Node source = builder.term(
                    "APP", context, "TERM", "Bool", "operator/local-bag",
                    List.of(), globalBag);
            Wire.Node locallyRenamed = builder.term(
                    "APP", context, "TERM", "Bool", "operator/local-bag",
                    List.of(), mixedBag);
            List<Wire.Node> renamings = new ArrayList<>(List.of(
                    Wire.leaf("embedding-ref", identity.scalar(0)),
                    Wire.leaf("embedding-ref", swap.scalar(0))));
            renamings.sort(Comparator.comparing(node -> node.scalar(0)));
            builder.proof(
                    "CANONICAL_ORBIT", context, "TERM", "Bool",
                    source, locallyRenamed, List.of(),
                    Wire.node(
                            "canonical-orbit",
                            List.of(
                                    source.scalar(0), context.scalar(0),
                                    locallyRenamed.scalar(0), "2"),
                            List.of(
                                    Wire.node("free-renamings", renamings),
                                    Wire.node(
                                            "leader-groups",
                                            List.of(fixture.after().scalar(0), "complete"),
                                            List.of()),
                                    Wire.node("orbit-minimum", List.of(
                                            Wire.leaf(
                                                    "term-ref",
                                                    locallyRenamed.scalar(0)))))));
        });
    }

    private static TestBundleBuilder.Encoded automaticSameLeaderSymmetryFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            Wire.Node symmetrySnapshot = fixture.builder().snapshot(
                    2,
                    "DIRTY",
                    classRecords(fixture, List.of()),
                    List.of(),
                    baseShape(fixture),
                    List.of(Wire.leaf(
                            "hash-owner", trueTermKey(fixture), "0")),
                    List.of(),
                    List.of(Wire.leaf(
                            "symmetry", "0", fixture.identity().scalar(0),
                            fixture.reflexive().scalar(0))),
                    List.of());
            fixture.builder().event(
                    1,
                    "ADD_SYMMETRY",
                    fixture.after(),
                    symmetrySnapshot,
                    Wire.leaf(
                            "add-symmetry", "0", fixture.identity().scalar(0),
                            fixture.reflexive().scalar(0)));
        });
    }

    private static TestBundleBuilder.Encoded implicitInterfaceMutationFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node gamma = builder.context(List.of(
                    Wire.leaf("slot", "x", "T")));
            Wire.Node widenedTruth = builder.term(
                    "APP", gamma, "TERM", "Bool", "true", List.of());
            builder.witness("w0-wide@1", 1, "0", gamma, "Bool", widenedTruth);
            Wire.Node hiddenMutation = builder.snapshot(
                    1,
                    "QUIESCENT",
                    List.of(Wire.leaf(
                            "class", "0", "w0-wide@1", gamma.scalar(0), "Bool")),
                    List.of(),
                    List.of(),
                    List.of(),
                    List.of(), List.of(), List.of());
            Wire.Node forward = builder.proof(
                    "REBUILD_CONGRUENCE",
                    fixture.empty(),
                    "TERM",
                    "Bool",
                    fixture.truth(),
                    fixture.truth(),
                    List.of(fixture.reflexive()),
                    Wire.leaf(
                            "rebuild-congruence", fixture.reflexive().scalar(0)));
            builder.event(
                    1,
                    "REBUILD_RECORD",
                    fixture.after(),
                    hiddenMutation,
                    Wire.leaf(
                            "rebuild-record", "shape-0", forward.scalar(0), ""));
        });
    }

    private static TestBundleBuilder.Encoded unionTransitionFixture() {
        return unionTransitionFixture(false, false);
    }

    private static TestBundleBuilder.Encoded unionTransitionFixture(
            boolean dropTransferredShape) {
        return unionTransitionFixture(dropTransferredShape, false);
    }

    private static TestBundleBuilder.Encoded unionTransitionFixture(
            boolean dropTransferredShape,
            boolean addRetirementToRehome) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            FreshNullary second = addFreshNullary(
                    fixture, "false/union", "1", "w1@2", 2);
            String trueKey = trueTermKey(fixture);
            String falseKey = termKey(
                    fixture.empty(), "Bool", "false/union");
            Wire.Node twoLeaders = builder.snapshot(
                    2,
                    "QUIESCENT",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@2",
                                    fixture.empty().scalar(0), "Bool")),
                    List.of(),
                    List.of(
                            Wire.leaf(
                                    "shape", "shape-0", "0",
                                    fixture.truth().scalar(0),
                                    fixture.replay().scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-1", "1",
                                    second.term().scalar(0),
                                    second.replay().scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueKey, "0"),
                            Wire.leaf("hash-owner", falseKey, "1")),
                    List.of(), List.of(), List.of());
            builder.event(
                    1,
                    "INSERT_FRESH",
                    fixture.after(),
                    twoLeaders,
                    Wire.leaf(
                            "insert-fresh", "1", "shape-1",
                            second.replay().scalar(0),
                            second.orbit().scalar(0),
                            second.fresh().scalar(0)));

            Wire.Node edge = witnessEdge(
                    fixture,
                    "w1@2",
                    "w0@1",
                    second.invocation(),
                    fixture.invoke(),
                    "union");
            String transferAxiom = "axiom/union-shape-transfer";
            builder.axiom(
                    transferAxiom,
                    Wire.node(
                            "pattern",
                            List.of("APP", "TERM", "Bool", "false/union"),
                            List.of()),
                    Wire.node(
                            "pattern", List.of("APP", "TERM", "Bool", "true"),
                            List.of()),
                    List.of(), List.of(), List.of());
            Wire.Node transferProof = builder.proof(
                    "AXIOM", fixture.empty(), "TERM", "Bool",
                    second.term(), fixture.truth(), List.of(),
                    Wire.node(
                            "axiom-instance",
                            List.of(transferAxiom, fixture.empty().scalar(0)),
                            List.of(
                                    Wire.node("type-substitution", List.of()),
                                    Wire.node("term-substitution", List.of()),
                                    Wire.node("side-evidence", List.of()))));
            List<Wire.Node> transferredShapes = new ArrayList<>();
            transferredShapes.add(Wire.leaf(
                    "shape", "shape-0", "0",
                    fixture.truth().scalar(0), fixture.replay().scalar(0)));
            List<Wire.Node> transferredHashes = new ArrayList<>();
            transferredHashes.add(Wire.leaf("hash-owner", trueKey, "0"));
            if (!dropTransferredShape) {
                transferredShapes.add(Wire.leaf(
                        "shape", "shape-1", "0",
                        second.term().scalar(0), second.replay().scalar(0),
                        fixture.identity().scalar(0), fixture.identity().scalar(0),
                        transferProof.scalar(0)));
                transferredHashes.add(Wire.leaf("hash-owner", falseKey, "0"));
            }
            String retiredShape = shapeId("1", second.term().scalar(0));
            String retainedShape = shapeId("0", second.term().scalar(0));
            List<Wire.Node> retirements = addRetirementToRehome
                    ? List.of(Wire.leaf(
                            "retirement",
                            retiredShape,
                            "1",
                            second.term().scalar(0),
                            second.replay().scalar(0),
                            fixture.identity().scalar(0),
                            retainedShape,
                            edge.scalar(0),
                            fixture.identity().scalar(0),
                            transferProof.scalar(0),
                            transferProof.scalar(0)))
                    : List.of();
            Wire.Node dirty = builder.snapshot(
                    3,
                    "DIRTY",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@2",
                                    fixture.empty().scalar(0), "Bool")),
                    List.of(parent(
                            "edge-union", "1", "0", fixture.identity(), edge)),
                    transferredShapes,
                    transferredHashes,
                    List.of(), List.of(), retirements, List.of());
            builder.event(
                    2,
                    "UNION",
                    twoLeaders,
                    dirty,
                    Wire.leaf("union", edge.scalar(0)));
            Wire.Node quiescent = builder.snapshot(
                    3,
                    "QUIESCENT",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@2",
                                    fixture.empty().scalar(0), "Bool")),
                    List.of(parent(
                            "edge-union", "1", "0", fixture.identity(), edge)),
                    transferredShapes,
                    transferredHashes,
                    List.of(), List.of(), retirements, List.of());
            addRebuildStart(builder, 3, dirty);
            builder.event(
                    4,
                    "REBUILD_COMPLETE",
                    dirty,
                    quiescent,
                    Wire.leaf("rebuild-complete", "false"));
            builder.publication(publication(
                    fixture,
                    quiescent,
                    3,
                    List.of(
                            Wire.leaf("ec", "0", "w0@1"),
                            Wire.leaf("ec", "1", "w1@2")),
                    List.of(Wire.leaf(
                            "pc", "edge-union", edge.scalar(0)))));
        });
    }

    private static TestBundleBuilder.Encoded restrictionTransitionFixture() {
        return restrictionTransitionFixture(false);
    }

    private static TestBundleBuilder.Encoded restrictionDeletionAttackFixture() {
        return restrictionTransitionFixture(true);
    }

    private static TestBundleBuilder.Encoded restrictionTransitionFixture(
            boolean deleteUnrelatedShape) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node gamma = builder.context(List.of(
                    Wire.leaf("slot", "x", "T")));
            Wire.Node gammaIdentity = builder.embedding(
                    "BIJECTION", gamma, gamma, Map.of("x", "x"));
            Wire.Node inclusion = builder.embedding(
                    "INJECTION", fixture.empty(), gamma, Map.of());
            String one = builder.schema(
                    "schema/restrict-one", "ONE_SLOT", "T", "").scalar(0);
            String operator = "operator/restrict-slot";
            builder.operator(operator, "Bool", one);
            Wire.Node slot = builder.term(
                    "ONE_SLOT", gamma, "PORT", one, one, List.of("x"));
            Wire.Node source = builder.term(
                    "APP", gamma, "TERM", "Bool", operator, List.of(), slot);
            builder.witness("w1@2", 2, "1", gamma, "Bool", source);
            Wire.Node invocation = builder.term(
                    "INVOKE", gamma, "TERM", "Bool", "w1@2",
                    List.of(gammaIdentity.scalar(0)));
            Wire.Node reflexive = builder.proof(
                    "REFL", gamma, "TERM", "Bool",
                    source, source, List.of(), Wire.leaf("refl", source.scalar(0)));
            Wire.Node replay = builder.proof(
                    "KERNEL_REPLAY", gamma, "TERM", "Bool",
                    source, source, List.of(reflexive),
                    Wire.node(
                            "kernel-replay",
                            List.of(
                                    source.scalar(0), gamma.scalar(0),
                                    source.scalar(0), gamma.scalar(0),
                                    gammaIdentity.scalar(0),
                                    gammaIdentity.scalar(0),
                                    gammaIdentity.scalar(0)),
                            List.of(
                                    Wire.node("parent-paths", List.of()),
                                    Wire.node("port-normalizations", List.of()),
                                    Wire.leaf(
                                            "structural-proof", reflexive.scalar(0)),
                                    Wire.node(
                                            "effective-support", List.of("x"),
                                            List.of()))));
            Wire.Node orbit = builder.proof(
                    "CANONICAL_ORBIT", gamma, "TERM", "Bool",
                    source, source, List.of(),
                    Wire.node(
                            "canonical-orbit",
                            List.of(
                                    source.scalar(0), gamma.scalar(0),
                                    source.scalar(0), "1"),
                            List.of(
                                    Wire.node("free-renamings", List.of(Wire.leaf(
                                            "embedding-ref",
                                            gammaIdentity.scalar(0)))),
                                    Wire.node(
                                            "leader-groups",
                                            List.of(fixture.after().scalar(0), "complete"),
                                            List.of()),
                                    Wire.node("orbit-minimum", List.of(Wire.leaf(
                                            "term-ref", source.scalar(0)))))));
            Wire.Node fresh = builder.proof(
                    "FRESH_WITNESS", gamma, "TERM", "Bool",
                    source, source, List.of(replay),
                    Wire.leaf(
                            "fresh-witness", "w1@2", source.scalar(0),
                            gammaIdentity.scalar(0), replay.scalar(0)));
            String sourceKey = slotApplicationKey(gamma, one, operator, "x");
            Wire.Node wide = builder.snapshot(
                    2,
                    "QUIESCENT",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@2",
                                    gamma.scalar(0), "Bool")),
                    List.of(),
                    List.of(
                            Wire.leaf(
                                    "shape", "shape-0", "0",
                                    fixture.truth().scalar(0),
                                    fixture.replay().scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-1", "1",
                                    source.scalar(0), replay.scalar(0),
                                    gammaIdentity.scalar(0), gammaIdentity.scalar(0),
                                    reflexive.scalar(0))),
                    List.of(
                            Wire.leaf(
                                    "hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", sourceKey, "1")),
                    List.of(), List.of(), List.of());
            builder.event(
                    1,
                    "INSERT_FRESH",
                    fixture.after(),
                    wide,
                    Wire.leaf(
                            "insert-fresh", "1", "shape-1",
                            replay.scalar(0), orbit.scalar(0), fresh.scalar(0)));

            Wire.Node widenedTruth = builder.term(
                    "APP", gamma, "TERM", "Bool", "true", List.of());
            builder.witness(
                    "w1@3", 3, "1", fixture.empty(), "Bool", fixture.truth());
            String factorAxiom = "axiom/restrict-factorization";
            builder.axiom(
                    factorAxiom,
                    Wire.node(
                            "pattern",
                            List.of("APP", "TERM", "Bool", operator),
                            List.of(Wire.node(
                                    "pattern",
                                    List.of(
                                            "ONE_SLOT", "PORT", one, one, "x"),
                                    List.of()))),
                    Wire.node(
                            "pattern",
                            List.of("APP", "TERM", "Bool", "true"),
                            List.of()),
                    List.of(), List.of(), List.of());
            Wire.Node factorization = builder.proof(
                    "AXIOM", gamma, "TERM", "Bool",
                    source, widenedTruth, List.of(),
                    Wire.node(
                            "axiom-instance",
                            List.of(factorAxiom, gamma.scalar(0)),
                            List.of(
                                    Wire.node("type-substitution", List.of()),
                                    Wire.node("term-substitution", List.of()),
                                    Wire.node("side-evidence", List.of()))));
            Wire.Node restriction = builder.proof(
                    "RESTRICT", gamma, "TERM", "Bool",
                    source, widenedTruth, List.of(factorization),
                    Wire.leaf(
                            "restriction", "w1@2", "w1@3",
                            inclusion.scalar(0)));
            List<Wire.Node> restrictedShapes = new ArrayList<>();
            if (!deleteUnrelatedShape) {
                restrictedShapes.add(Wire.leaf(
                        "shape", "shape-0", "0", fixture.truth().scalar(0),
                        fixture.replay().scalar(0)));
            }
            restrictedShapes.add(Wire.leaf(
                    "shape", "shape-1", "1", source.scalar(0), replay.scalar(0),
                    gammaIdentity.scalar(0), inclusion.scalar(0),
                    factorization.scalar(0)));
            Wire.Node dirty = builder.snapshot(
                    3,
                    "DIRTY",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@3",
                                    fixture.empty().scalar(0), "Bool")),
                    List.of(),
                    restrictedShapes,
                    List.of(
                            Wire.leaf(
                                    "hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", sourceKey, "1")),
                    List.of(), List.of(), List.of());
            builder.event(
                    2,
                    "RESTRICT_INTERFACE",
                    wide,
                    dirty,
                    Wire.node(
                            "restrict-interface",
                            List.of(
                                    "1", gamma.scalar(0), fixture.empty().scalar(0),
                                    restriction.scalar(0)),
                            List.of(Wire.node(
                                    "transported-evidence",
                                    List.of(Wire.leaf(
                                            "transported-shape",
                                            shapeId("1", source.scalar(0)),
                                            gammaIdentity.scalar(0),
                                            reflexive.scalar(0),
                                            inclusion.scalar(0),
                                    factorization.scalar(0)))))));
            if (deleteUnrelatedShape) {
                return;
            }
            Wire.Node quiescent = builder.snapshot(
                    3,
                    "QUIESCENT",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@3",
                                    fixture.empty().scalar(0), "Bool")),
                    List.of(),
                    List.of(
                            Wire.leaf(
                                    "shape", "shape-0", "0",
                                    fixture.truth().scalar(0),
                                    fixture.replay().scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-1", "1",
                                    source.scalar(0), replay.scalar(0),
                                    gammaIdentity.scalar(0), inclusion.scalar(0),
                                    factorization.scalar(0))),
                    List.of(
                            Wire.leaf(
                                    "hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", sourceKey, "1")),
                    List.of(), List.of(), List.of());
            addRebuildStart(builder, 3, dirty);
            builder.event(
                    4,
                    "REBUILD_COMPLETE",
                    dirty,
                    quiescent,
                    Wire.leaf("rebuild-complete", "false"));
            builder.publication(publication(
                    fixture,
                    quiescent,
                    3,
                    List.of(
                            Wire.leaf("ec", "0", "w0@1"),
                            Wire.leaf("ec", "1", "w1@3")),
                    List.of()));
        });
    }

    private static String slotApplicationKey(
            Wire.Node context,
            String schema,
            String operator,
            String slot) {
        Wire.Node leaf = Wire.node(
                "term-key/ONE_SLOT",
                List.of(
                        context.scalar(0), "PORT", schema, schema, slot),
                List.of());
        return Wire.contentId(Wire.node(
                "term-key/APP",
                List.of(context.scalar(0), "TERM", "Bool", operator),
                List.of(leaf)));
    }

    private static TestBundleBuilder.Encoded symmetryTransitionFixture() {
        return symmetryTransitionFixture(false);
    }

    private static TestBundleBuilder.Encoded symmetryDeletionAttackFixture() {
        return symmetryTransitionFixture(true);
    }

    private static TestBundleBuilder.Encoded symmetryTransitionFixture(
            boolean deleteExistingSymmetry) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            Wire.Node gamma = builder.context(List.of(
                    Wire.leaf("slot", "x", "T"),
                    Wire.leaf("slot", "y", "T")));
            LinkedHashMap<String, String> identityMap = new LinkedHashMap<>();
            identityMap.put("x", "x");
            identityMap.put("y", "y");
            Wire.Node identity = builder.embedding(
                    "BIJECTION", gamma, gamma, identityMap);
            LinkedHashMap<String, String> swapMap = new LinkedHashMap<>();
            swapMap.put("x", "y");
            swapMap.put("y", "x");
            Wire.Node swap = builder.embedding(
                    "BIJECTION", gamma, gamma, swapMap);
            String one = builder.schema(
                    "schema/symmetry-one", "ONE_SLOT", "T", "").scalar(0);
            String bag = builder.schema(
                    "schema/symmetry-bag", "BAG", "", one).scalar(0);
            String operator = "operator/symmetric-bag";
            builder.operator(operator, "Bool", bag);
            Wire.Node x = builder.term(
                    "ONE_SLOT", gamma, "PORT", one, one, List.of("x"));
            Wire.Node y = builder.term(
                    "ONE_SLOT", gamma, "PORT", one, one, List.of("y"));
            List<Wire.Node> elements = new ArrayList<>(List.of(x, y));
            elements.sort(Comparator.comparing(node -> node.scalar(0)));
            Wire.Node bagTerm = builder.term(
                    "BAG", gamma, "PORT", bag, bag, List.of(),
                    elements.toArray(Wire.Node[]::new));
            Wire.Node source = builder.term(
                    "APP", gamma, "TERM", "Bool", operator, List.of(), bagTerm);
            Wire.Node normalization = normalize(
                    builder, gamma, "BAG", bag, bagTerm, bagTerm, elements);
            builder.witness("w1@2", 2, "1", gamma, "Bool", source);
            Wire.Node structural = builder.proof(
                    "REFL", gamma, "TERM", "Bool",
                    source, source, List.of(), Wire.leaf("refl", source.scalar(0)));
            Wire.Node replay = builder.proof(
                    "KERNEL_REPLAY", gamma, "TERM", "Bool",
                    source, source, List.of(normalization, structural),
                    Wire.node(
                            "kernel-replay",
                            List.of(
                                    source.scalar(0), gamma.scalar(0),
                                    source.scalar(0), gamma.scalar(0),
                                    identity.scalar(0), identity.scalar(0),
                                    identity.scalar(0)),
                            List.of(
                                    Wire.node("parent-paths", List.of()),
                                    Wire.node("port-normalizations", List.of(Wire.leaf(
                                            "port-normalization", "0",
                                            normalization.scalar(0)))),
                                    Wire.leaf(
                                            "structural-proof", structural.scalar(0)),
                                    Wire.node(
                                            "effective-support", List.of("x", "y"),
                                            List.of()))));
            List<Wire.Node> freeRenamings = new ArrayList<>(List.of(
                    Wire.leaf("embedding-ref", identity.scalar(0)),
                    Wire.leaf("embedding-ref", swap.scalar(0))));
            freeRenamings.sort(Comparator.comparing(node -> node.scalar(0)));
            Wire.Node orbit = builder.proof(
                    "CANONICAL_ORBIT", gamma, "TERM", "Bool",
                    source, source, List.of(),
                    Wire.node(
                            "canonical-orbit",
                            List.of(
                                    source.scalar(0), gamma.scalar(0),
                                    source.scalar(0), "2"),
                            List.of(
                                    Wire.node("free-renamings", freeRenamings),
                                    Wire.node(
                                            "leader-groups",
                                            List.of(fixture.after().scalar(0), "complete"),
                                            List.of()),
                                    Wire.node("orbit-minimum", List.of(Wire.leaf(
                                            "term-ref", source.scalar(0)))))));
            Wire.Node fresh = builder.proof(
                    "FRESH_WITNESS", gamma, "TERM", "Bool",
                    source, source, List.of(replay),
                    Wire.leaf(
                            "fresh-witness", "w1@2", source.scalar(0),
                            identity.scalar(0), replay.scalar(0)));
            String sourceKey = bagApplicationKey(
                    gamma, one, bag, operator, elements);
            Wire.Node beforeSymmetry = builder.snapshot(
                    2,
                    "QUIESCENT",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@2",
                                    gamma.scalar(0), "Bool")),
                    List.of(),
                    List.of(
                            Wire.leaf(
                                    "shape", "shape-0", "0",
                                    fixture.truth().scalar(0),
                                    fixture.replay().scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-1", "1",
                                    source.scalar(0), replay.scalar(0))),
                    List.of(
                            Wire.leaf(
                                    "hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", sourceKey, "1")),
                    List.of(), List.of(), List.of());
            builder.event(
                    1,
                    "INSERT_FRESH",
                    fixture.after(),
                    beforeSymmetry,
                    Wire.leaf(
                            "insert-fresh", "1", "shape-1",
                            replay.scalar(0), orbit.scalar(0), fresh.scalar(0)));

            List<Wire.Node> movedElements = new ArrayList<>();
            for (Wire.Node element : elements) {
                movedElements.add(element.scalar(0).equals(x.scalar(0)) ? y : x);
            }
            Wire.Node movedBag = builder.term(
                    "BAG", gamma, "PORT", bag, bag, List.of(),
                    movedElements.toArray(Wire.Node[]::new));
            Wire.Node moved = builder.term(
                    "APP", gamma, "TERM", "Bool", operator, List.of(), movedBag);
            Wire.Node symmetry = builder.proof(
                    "FULL_INTERFACE_SYMMETRY", gamma, "TERM", "Bool",
                    source, moved, List.of(),
                    Wire.leaf(
                            "full-interface-symmetry",
                            swap.scalar(0), source.scalar(0)));
            Wire.Node dirty = builder.snapshot(
                    3,
                    "DIRTY",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@2",
                                    gamma.scalar(0), "Bool")),
                    List.of(),
                    List.of(
                            Wire.leaf(
                                    "shape", "shape-0", "0",
                                    fixture.truth().scalar(0),
                                    fixture.replay().scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-1", "1",
                                    source.scalar(0), replay.scalar(0))),
                    List.of(
                            Wire.leaf(
                                    "hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", sourceKey, "1")),
                    List.of(),
                    List.of(Wire.leaf(
                            "symmetry", "1", swap.scalar(0), symmetry.scalar(0))),
                    List.of());
            builder.event(
                    2,
                    "ADD_SYMMETRY",
                    beforeSymmetry,
                    dirty,
                    Wire.leaf(
                            "add-symmetry", "1", swap.scalar(0),
                            symmetry.scalar(0)));
            Wire.Node quiescent = builder.snapshot(
                    3,
                    "QUIESCENT",
                    List.of(
                            Wire.leaf(
                                    "class", "0", "w0@1",
                                    fixture.empty().scalar(0), "Bool"),
                            Wire.leaf(
                                    "class", "1", "w1@2",
                                    gamma.scalar(0), "Bool")),
                    List.of(),
                    List.of(
                            Wire.leaf(
                                    "shape", "shape-0", "0",
                                    fixture.truth().scalar(0),
                                    fixture.replay().scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-1", "1",
                                    source.scalar(0), replay.scalar(0))),
                    List.of(
                            Wire.leaf(
                                    "hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", sourceKey, "1")),
                    List.of(),
                    List.of(Wire.leaf(
                            "symmetry", "1", swap.scalar(0), symmetry.scalar(0))),
                    List.of());
            addRebuildStart(builder, 3, dirty);
            builder.event(
                    4,
                    "REBUILD_COMPLETE",
                    dirty,
                    quiescent,
                    Wire.leaf("rebuild-complete", "false"));
            if (deleteExistingSymmetry) {
                Wire.Node identitySymmetry = builder.proof(
                        "FULL_INTERFACE_SYMMETRY", gamma, "TERM", "Bool",
                        source, source, List.of(),
                        Wire.leaf(
                                "full-interface-symmetry",
                                identity.scalar(0), source.scalar(0)));
                Wire.Node attacked = builder.snapshot(
                        4,
                        "DIRTY",
                        List.of(
                                Wire.leaf(
                                        "class", "0", "w0@1",
                                        fixture.empty().scalar(0), "Bool"),
                                Wire.leaf(
                                        "class", "1", "w1@2",
                                        gamma.scalar(0), "Bool")),
                        List.of(),
                        List.of(
                                Wire.leaf(
                                        "shape", "shape-0", "0",
                                        fixture.truth().scalar(0),
                                        fixture.replay().scalar(0)),
                                Wire.leaf(
                                        "shape", "shape-1", "1",
                                        source.scalar(0), replay.scalar(0))),
                        List.of(
                                Wire.leaf(
                                        "hash-owner", trueTermKey(fixture), "0"),
                                Wire.leaf("hash-owner", sourceKey, "1")),
                        List.of(),
                        List.of(Wire.leaf(
                                "symmetry", "1", identity.scalar(0),
                                identitySymmetry.scalar(0))),
                        List.of());
                builder.event(
                        5,
                        "ADD_SYMMETRY",
                        quiescent,
                        attacked,
                        Wire.leaf(
                                "add-symmetry", "1", identity.scalar(0),
                                identitySymmetry.scalar(0)));
                builder.publication(Wire.node(
                        "publication",
                        List.of(
                                attacked.scalar(0), "4", fixture.truth().scalar(0),
                                fixture.truth().scalar(0), "theory-digest-placeholder"),
                        List.of(
                                Wire.node("ec-evidence", List.of(
                                        Wire.leaf("ec", "0", "w0@1"),
                                        Wire.leaf("ec", "1", "w1@2"))),
                                Wire.node("pc-evidence", List.of()),
                                Wire.node("sc-evidence", List.of(Wire.leaf(
                                        "sc", "1", identity.scalar(0),
                                        identitySymmetry.scalar(0)))),
                                Wire.node("canonical-refs", List.of(Wire.leaf(
                                        "canonical-ref", fixture.canonical().scalar(0)))),
                                Wire.node("unfolding-refs", List.of(Wire.leaf(
                                        "unfolding-ref", fixture.unfolding().scalar(0)))))));
                return;
            }
            builder.publication(Wire.node(
                    "publication",
                    List.of(
                            quiescent.scalar(0), "3", fixture.truth().scalar(0),
                            fixture.truth().scalar(0), "theory-digest-placeholder"),
                    List.of(
                            Wire.node("ec-evidence", List.of(
                                    Wire.leaf("ec", "0", "w0@1"),
                                    Wire.leaf("ec", "1", "w1@2"))),
                            Wire.node("pc-evidence", List.of()),
                            Wire.node("sc-evidence", List.of(Wire.leaf(
                                    "sc", "1", swap.scalar(0),
                                    symmetry.scalar(0)))),
                            Wire.node("canonical-refs", List.of(Wire.leaf(
                                    "canonical-ref", fixture.canonical().scalar(0)))),
                            Wire.node("unfolding-refs", List.of(Wire.leaf(
                                    "unfolding-ref", fixture.unfolding().scalar(0)))))));
        });
    }

    private static String bagApplicationKey(
            Wire.Node context,
            String oneSchema,
            String bagSchema,
            String operator,
            List<Wire.Node> elements) {
        List<Wire.Node> keys = new ArrayList<>();
        for (Wire.Node element : elements) {
            keys.add(Wire.node(
                    "term-key/ONE_SLOT",
                    List.of(
                            context.scalar(0), "PORT", oneSchema, oneSchema,
                            element.scalar(6)),
                    List.of()));
        }
        Wire.Node bag = Wire.node(
                "term-key/BAG",
                List.of(
                        context.scalar(0), "PORT", bagSchema, bagSchema),
                keys);
        return Wire.contentId(Wire.node(
                "term-key/APP",
                List.of(context.scalar(0), "TERM", "Bool", operator),
                List.of(bag)));
    }

    private static FreshNullary addFreshNullary(
            FixtureParts fixture,
            String operator,
            String eclass,
            String witness,
            long revision) {
        TestBundleBuilder builder = fixture.builder();
        builder.operator(operator, "Bool");
        Wire.Node term = builder.term(
                "APP", fixture.empty(), "TERM", "Bool", operator, List.of());
        builder.witness(
                witness, revision, eclass, fixture.empty(), "Bool", term);
        Wire.Node invocation = builder.term(
                "INVOKE", fixture.empty(), "TERM", "Bool", witness,
                List.of(fixture.identity().scalar(0)));
        Wire.Node reflexive = builder.proof(
                "REFL", fixture.empty(), "TERM", "Bool",
                term, term, List.of(), Wire.leaf("refl", term.scalar(0)));
        Wire.Node replay = builder.proof(
                "KERNEL_REPLAY", fixture.empty(), "TERM", "Bool",
                term, term, List.of(reflexive),
                Wire.node(
                        "kernel-replay",
                        List.of(
                                term.scalar(0), fixture.empty().scalar(0),
                                term.scalar(0), fixture.empty().scalar(0),
                                fixture.identity().scalar(0),
                                fixture.identity().scalar(0),
                                fixture.identity().scalar(0)),
                        List.of(
                                Wire.node("parent-paths", List.of()),
                                Wire.node("port-normalizations", List.of()),
                                Wire.leaf(
                                        "structural-proof", reflexive.scalar(0)),
                                Wire.node("effective-support", List.of()))));
        Wire.Node orbit = builder.proof(
                "CANONICAL_ORBIT", fixture.empty(), "TERM", "Bool",
                term, term, List.of(),
                Wire.node(
                        "canonical-orbit",
                        List.of(
                                term.scalar(0), fixture.empty().scalar(0),
                                term.scalar(0), "1"),
                        List.of(
                                Wire.node("free-renamings", List.of(Wire.leaf(
                                        "embedding-ref",
                                        fixture.identity().scalar(0)))),
                                Wire.node(
                                        "leader-groups",
                                        List.of(fixture.after().scalar(0), "complete"),
                                        List.of()),
                                Wire.node("orbit-minimum", List.of(Wire.leaf(
                                        "term-ref", term.scalar(0)))))));
        Wire.Node fresh = builder.proof(
                "FRESH_WITNESS", fixture.empty(), "TERM", "Bool",
                term, term, List.of(replay),
                Wire.leaf(
                        "fresh-witness", witness, term.scalar(0),
                        fixture.identity().scalar(0), replay.scalar(0)));
        return new FreshNullary(term, invocation, replay, orbit, fresh);
    }

    private static String termKey(
            Wire.Node context,
            String type,
            String operator) {
        return Wire.contentId(Wire.node(
                "term-key/APP",
                List.of(context.scalar(0), "TERM", type, operator),
                List.of()));
    }

    private static String shapeId(String owner, String termId) {
        return "shape/" + Wire.contentId(Wire.leaf(
                "producer-shape-id", owner, termId));
    }

    private static Wire.Node witnessEdge(
            FixtureParts fixture,
            String childWitness,
            String parentWitness,
            Wire.Node childInvocation,
            Wire.Node parentInvocation,
            String suffix) {
        TestBundleBuilder builder = fixture.builder();
        String axiomId = "axiom/witness-edge/" + suffix;
        builder.axiom(
                axiomId,
                Wire.node(
                        "pattern",
                        List.of(
                                "INVOKE", "TERM", "Bool", childWitness,
                                fixture.identity().scalar(0)),
                        List.of()),
                Wire.node(
                        "pattern",
                        List.of(
                                "INVOKE", "TERM", "Bool", parentWitness,
                                fixture.identity().scalar(0)),
                        List.of()),
                List.of(), List.of(), List.of());
        Wire.Node equation = builder.proof(
                "AXIOM", fixture.empty(), "TERM", "Bool",
                childInvocation, parentInvocation, List.of(),
                Wire.node(
                        "axiom-instance",
                        List.of(axiomId, fixture.empty().scalar(0)),
                        List.of(
                                Wire.node("type-substitution", List.of()),
                                Wire.node("term-substitution", List.of()),
                                Wire.node("side-evidence", List.of()))));
        return builder.proof(
                "PARENT_EDGE", fixture.empty(), "TERM", "Bool",
                childInvocation, parentInvocation, List.of(equation),
                Wire.leaf(
                        "parent-edge", childWitness, parentWitness,
                        fixture.identity().scalar(0)));
    }

    private static CollisionEdge witnessCollisionEdge(
            FixtureParts fixture,
            String childWitness,
            String parentWitness,
            Wire.Node childInvocation,
            Wire.Node parentInvocation,
            String suffix) {
        TestBundleBuilder builder = fixture.builder();
        Wire.Node childSide = invocationEquationToTruth(
                fixture, childWitness, childInvocation, suffix + "/child");
        Wire.Node parentSide = invocationEquationToTruth(
                fixture, parentWitness, parentInvocation, suffix + "/parent");
        Wire.Node fresh = builder.proof(
                "FRESH_WITNESS",
                fixture.empty(),
                "TERM",
                "Bool",
                fixture.truth(),
                fixture.truth(),
                List.of(fixture.replay()),
                Wire.leaf(
                        "fresh-witness", childWitness, fixture.truth().scalar(0),
                        fixture.identity().scalar(0), fixture.replay().scalar(0)));
        Wire.Node collision = builder.proof(
                "COLLISION", fixture.empty(), "TERM", "Bool",
                childInvocation, parentInvocation,
                List.of(childSide, parentSide),
                Wire.leaf(
                        "collision",
                        childSide.scalar(0),
                        parentSide.scalar(0),
                        trueTermKey(fixture),
                        trueTermKey(fixture)));
        Wire.Node edge = builder.proof(
                "PARENT_EDGE", fixture.empty(), "TERM", "Bool",
                childInvocation, parentInvocation, List.of(collision),
                Wire.leaf(
                        "parent-edge", childWitness, parentWitness,
                        fixture.identity().scalar(0)));
        return new CollisionEdge(fixture.replay(), fresh, collision, edge);
    }

    private static Wire.Node invocationEquationToTruth(
            FixtureParts fixture,
            String witness,
            Wire.Node invocation,
            String suffix) {
        TestBundleBuilder builder = fixture.builder();
        String axiomId = "axiom/collision-replay/" + suffix;
        builder.axiom(
                axiomId,
                Wire.node(
                        "pattern",
                        List.of(
                                "INVOKE", "TERM", "Bool", witness,
                                fixture.identity().scalar(0)),
                        List.of()),
                Wire.node(
                        "pattern", List.of("APP", "TERM", "Bool", "true"),
                        List.of()),
                List.of(), List.of(), List.of());
        return builder.proof(
                "AXIOM", fixture.empty(), "TERM", "Bool",
                invocation, fixture.truth(), List.of(),
                Wire.node(
                        "axiom-instance",
                        List.of(axiomId, fixture.empty().scalar(0)),
                        List.of(
                                Wire.node("type-substitution", List.of()),
                                Wire.node("term-substitution", List.of()),
                                Wire.node("side-evidence", List.of()))));
    }

    private static List<Wire.Node> classRecords(
            FixtureParts fixture,
            List<ClassWitness> additional) {
        List<Wire.Node> classes = new ArrayList<>();
        classes.add(Wire.leaf(
                "class", "0", "w0@1", fixture.empty().scalar(0), "Bool"));
        for (ClassWitness entry : additional) {
            classes.add(Wire.leaf(
                    "class", entry.eclass(), entry.witness(),
                    fixture.empty().scalar(0), "Bool"));
        }
        return classes;
    }

    private static List<Wire.Node> baseShape(FixtureParts fixture) {
        return List.of(Wire.leaf(
                "shape", "shape-0", "0", fixture.truth().scalar(0),
                fixture.replay().scalar(0)));
    }

    private static Wire.Node parent(
            String edgeId,
            String child,
            String target,
            Wire.Node embedding,
            Wire.Node proof) {
        return Wire.leaf(
                "parent", edgeId, child, target,
                embedding.scalar(0), proof.scalar(0));
    }

    private static void addRebuildStart(
            TestBundleBuilder builder,
            int sequence,
            Wire.Node snapshot) {
        builder.event(
                sequence,
                "REBUILD_START",
                snapshot,
                snapshot,
                Wire.leaf("rebuild-start", snapshot.scalar(0)));
    }

    private static String trueTermKey(FixtureParts fixture) {
        return Wire.contentId(Wire.node(
                "term-key/APP",
                List.of(
                        fixture.empty().scalar(0), "TERM", "Bool", "true"),
                List.of()));
    }

    private static Wire.Node publication(
            FixtureParts fixture,
            Wire.Node snapshot,
            long revision,
            List<Wire.Node> ec,
            List<Wire.Node> pc) {
        return Wire.node(
                "publication",
                List.of(
                        snapshot.scalar(0),
                        Long.toString(revision),
                        fixture.truth().scalar(0),
                        fixture.truth().scalar(0),
                        "theory-digest-placeholder"),
                List.of(
                        Wire.node("ec-evidence", ec),
                        Wire.node("pc-evidence", pc),
                        Wire.node("sc-evidence", List.of()),
                        Wire.node("canonical-refs", List.of(Wire.leaf(
                                "canonical-ref", fixture.canonical().scalar(0)))),
                        Wire.node("unfolding-refs", List.of(Wire.leaf(
                                "unfolding-ref", fixture.unfolding().scalar(0))))));
    }

    private static Wire.Node booleanConstant(FixtureParts fixture, String name) {
        fixture.builder().operator(name, "Bool");
        return fixture.builder().term(
                "APP", fixture.empty(), "TERM", "Bool", name, List.of());
    }

    private static ContainerTerms containerTerms(
            FixtureParts fixture,
            String suffix) {
        TestBundleBuilder builder = fixture.builder();
        Wire.Node falsity = booleanConstant(fixture, "false/" + suffix);
        String one = builder.schema(
                "schema/one-bool/" + suffix, "ONE_TERM", "Bool", "").scalar(0);
        String seq = builder.schema(
                "schema/seq/" + suffix, "SEQ", "", one).scalar(0);
        String bag = builder.schema(
                "schema/bag/" + suffix, "BAG", "", one).scalar(0);
        String set = builder.schema(
                "schema/set/" + suffix, "SET", "", one).scalar(0);
        Wire.Node truePort = builder.term(
                "ONE_TERM", fixture.empty(), "PORT", one, one,
                List.of(), fixture.truth());
        Wire.Node falsePort = builder.term(
                "ONE_TERM", fixture.empty(), "PORT", one, one,
                List.of(), falsity);
        return new ContainerTerms(one, seq, bag, set, truePort, falsePort);
    }

    private static Wire.Node normalize(
            TestBundleBuilder builder,
            Wire.Node context,
            String kind,
            String schema,
            Wire.Node source,
            Wire.Node target,
            List<Wire.Node> sourceChildren) {
        return normalize(
                builder,
                context,
                kind,
                schema,
                source,
                target,
                sourceChildren,
                "test-only/operator",
                "0/0");
    }

    private static Wire.Node normalize(
            TestBundleBuilder builder,
            Wire.Node context,
            String kind,
            String schema,
            Wire.Node source,
            Wire.Node target,
            List<Wire.Node> sourceChildren,
            String operator,
            String path) {
        List<Wire.Node> premises = new ArrayList<>();
        List<Wire.Node> occurrences = new ArrayList<>();
        for (int index = 0; index < sourceChildren.size(); index++) {
            Wire.Node child = sourceChildren.get(index);
            Wire.Node premise = builder.proof(
                    "REFL", context, "PORT", child.scalar(4),
                    child, child, List.of(),
                    Wire.leaf("refl", child.scalar(0)));
            premises.add(premise);
            occurrences.add(Wire.leaf(
                    "occurrence", Integer.toString(index), premise.scalar(0)));
        }
        return builder.proof(
                "CONTAINER_NORMALIZE", context, "PORT", schema,
                source, target, premises,
                Wire.node(
                        "container-normalization",
                        List.of(
                                kind,
                                source.scalar(0),
                                target.scalar(0),
                                operator,
                                path),
                        occurrences));
    }

    private static TestBundleBuilder.Encoded publicationAndFixture() {
        return publicationAndFixture("operator/publication/and", "0/0");
    }

    private static TestBundleBuilder.Encoded publicationAndFixture(
            String normalizationOperator,
            String normalizationPath) {
        return fullFixture(
                BaseOptions.defaults(),
                builder -> builder.publicationSemanticEvidence(
                        publicationProfile("FORBID")),
                fixture -> {
                    TestBundleBuilder builder = fixture.builder();
                    String boolType = builder.exactType("BOOL", "");
                    String arrowType = builder.exactType(
                            "ARROW", "", boolType, boolType);
                    String relationType = builder.exactType(
                            "RELATION", "", boolType, boolType);
                    builder.context(List.of(Wire.leaf(
                            "slot", "function", arrowType)));
                    builder.context(List.of(Wire.leaf(
                            "slot", "relation", relationType)));
                    String oneSchema = builder.schema(
                            "schema/publication/and/one",
                            "ONE",
                            boolType,
                            "",
                            "FINITE:1",
                            "RIGID").scalar(0);
                    String setSchema = builder.schema(
                            "schema/publication/and/set",
                            "SET",
                            "",
                            oneSchema,
                            "AT_LEAST:1",
                            "COMMUTATIVE_IDEMPOTENT_SET").scalar(0);
                    builder.operator(
                            "operator/publication/and",
                            boolType,
                            "ALLOY/AND",
                            "0/0",
                            new String[] {setSchema});
                    for (String law : List.of(
                            "ASSOCIATIVITY", "COMMUTATIVITY", "IDEMPOTENCY")) {
                        builder.lawCertificate(andLawCertificate(
                                boolType, setSchema, law));
                    }
                    builder.operator("false", boolType);
                    Wire.Node falsity = builder.term(
                            "APP",
                            fixture.empty(),
                            "TERM",
                            boolType,
                            "false",
                            List.of());
                    Wire.Node truePort = builder.term(
                            "ONE_TERM",
                            fixture.empty(),
                            "PORT",
                            oneSchema,
                            oneSchema,
                            List.of(),
                            fixture.truth());
                    Wire.Node falsePort = builder.term(
                            "ONE_TERM",
                            fixture.empty(),
                            "PORT",
                            oneSchema,
                            oneSchema,
                            List.of(),
                            falsity);
                    List<Wire.Node> normalized = new ArrayList<>(
                            List.of(truePort, falsePort));
                    normalized.sort(Comparator.comparing(node -> node.scalar(0)));
                    List<Wire.Node> sourceChildren = new ArrayList<>(normalized);
                    java.util.Collections.reverse(sourceChildren);
                    sourceChildren.add(sourceChildren.get(0));
                    Wire.Node source = builder.term(
                            "SET",
                            fixture.empty(),
                            "PORT",
                            setSchema,
                            setSchema,
                            List.of(),
                            sourceChildren.toArray(Wire.Node[]::new));
                    Wire.Node target = builder.term(
                            "SET",
                            fixture.empty(),
                            "PORT",
                            setSchema,
                            setSchema,
                            List.of(),
                            normalized.toArray(Wire.Node[]::new));
                    normalize(
                            builder,
                            fixture.empty(),
                            "SET",
                            setSchema,
                            source,
                            target,
                            sourceChildren,
                            normalizationOperator,
                            normalizationPath);
                });
    }

    private static TestBundleBuilder.Encoded publicationUnlicensedBagFixture() {
        return fullFixture(
                BaseOptions.defaults(),
                builder -> builder.publicationSemanticEvidence(
                        publicationProfile("FORBID")),
                fixture -> {
                    TestBundleBuilder builder = fixture.builder();
                    String boolType = builder.exactType("BOOL", "");
                    String oneSchema = builder.schema(
                            "schema/publication/unlicensed/one",
                            "ONE",
                            boolType,
                            "",
                            "FINITE:1",
                            "RIGID").scalar(0);
                    String bagSchema = builder.schema(
                            "schema/publication/unlicensed/bag",
                            "BAG",
                            "",
                            oneSchema,
                            "AT_LEAST:0",
                            "COMMUTATIVE_BAG").scalar(0);
                    builder.operator("false", boolType);
                    Wire.Node falsity = builder.term(
                            "APP",
                            fixture.empty(),
                            "TERM",
                            boolType,
                            "false",
                            List.of());
                    Wire.Node truePort = builder.term(
                            "ONE_TERM",
                            fixture.empty(),
                            "PORT",
                            oneSchema,
                            oneSchema,
                            List.of(),
                            fixture.truth());
                    Wire.Node falsePort = builder.term(
                            "ONE_TERM",
                            fixture.empty(),
                            "PORT",
                            oneSchema,
                            oneSchema,
                            List.of(),
                            falsity);
                    Wire.Node source = builder.term(
                            "BAG",
                            fixture.empty(),
                            "PORT",
                            bagSchema,
                            bagSchema,
                            List.of(),
                            truePort,
                            falsePort);
                    Wire.Node target = builder.term(
                            "BAG",
                            fixture.empty(),
                            "PORT",
                            bagSchema,
                            bagSchema,
                            List.of(),
                            falsePort,
                            truePort);
                    normalize(
                            builder,
                            fixture.empty(),
                            "BAG",
                            bagSchema,
                            source,
                            target,
                            List.of(truePort, falsePort));
                });
    }

    private static TestBundleBuilder.Encoded publicationWithConstructorType(
            String symbol) {
        return fullFixture(
                BaseOptions.defaults(),
                builder -> builder.publicationSemanticEvidence(
                        publicationProfile("FORBID")),
                fixture -> fixture.builder().exactType("CONSTRUCTOR", symbol));
    }

    private static TestBundleBuilder.Encoded typeReferenceNamespaceCollision() {
        return fullFixture(
                BaseOptions.defaults(),
                builder -> builder.publicationSemanticEvidence(
                        publicationProfile("FORBID")),
                fixture -> {
                    String boolId = fixture.builder().exactType("BOOL", "");
                    fixture.builder().exactType("CONSTRUCTOR", boolId);
                });
    }

    private static TestBundleBuilder.Encoded
            publicationWithArgumentBearingEmptyRelationType() {
        return fullFixture(
                BaseOptions.defaults(),
                builder -> builder.publicationSemanticEvidence(
                        publicationProfile("FORBID")),
                fixture -> {
                    TestBundleBuilder builder = fixture.builder();
                    String boolType = builder.exactType("BOOL", "");
                    builder.exactType(
                            "CONSTRUCTOR", "AlloyEmptyRelation$arity=1", boolType);
                });
    }

    private static List<String> publicationProfile(String overflow) {
        String context = sourceCommandContext(
                "4", Boolean.toString(overflow.equals("FORBID")));
        List<String> profile = List.of(
                "4",
                overflow,
                context,
                "repaired-normal-form-v3;typed-alloy-normal-form-adapter-v11",
                "canonical-alloy-signature-v7");
        return List.of(
                profile.get(0),
                profile.get(1),
                profile.get(2),
                profile.get(3),
                profile.get(4),
                sha256(stableKey("semantic-profile", profile, List.of())),
                ALLOY_LAW_VERSION,
                ALLOY_LAW_DIGEST);
    }

    private static String sourceCommandContext(
            String effectiveBitwidth,
            String noOverflow) {
        return stableKey(
                "alloy-source-command-context-v1",
                List.of(
                        "alloy-command-options-v2",
                        "$run",
                        "true",
                        "false",
                        "-1",
                        effectiveBitwidth,
                        "-1",
                        "1",
                        "-1",
                        "-1",
                        "-1"),
                List.of(
                        stableKey("scopes", List.of(), List.of()),
                        stableKey(
                                "additional-exact-scopes",
                                List.of(),
                                List.of()),
                        stableKey(
                                "execution-options",
                                List.of(
                                        "false",
                                        "20",
                                        "0",
                                        "0",
                                        "0",
                                        "SAT4J",
                                        noOverflow,
                                        "0",
                                        "0",
                                        "4"),
                                List.of())));
    }

    private static List<String> fixedCompatibilityProfile(String overflow) {
        List<String> profile = List.of(
                "4",
                overflow,
                "alloy-temporal",
                "repaired-normal-form-v2",
                "alloy-signature-v2");
        return List.of(
                profile.get(0),
                profile.get(1),
                profile.get(2),
                profile.get(3),
                profile.get(4),
                sha256(stableKey("semantic-profile", profile, List.of())),
                ALLOY_LAW_VERSION,
                ALLOY_LAW_DIGEST);
    }

    private static Wire.Node andLawCertificate(
            String boolType,
            String schemaId,
            String law) {
        String profileKey = stableKey(
                "semantic-profile",
                publicationProfile("FORBID").subList(0, 5),
                List.of());
        String typeKey = stableKey("type/BOOL", List.of(), List.of());
        String arityKey = stableKey(
                "arity-policy", List.of("AT_LEAST", "1"), List.of());
        String oneSchemaKey = stableKey(
                "schema/one", List.of(), List.of(typeKey));
        String schemaKey = stableKey(
                "schema/set",
                List.of("COMMUTATIVE_IDEMPOTENT_SET"),
                List.of(arityKey, oneSchemaKey));
        String family = switch (law) {
            case "ASSOCIATIVITY" ->
                    "all-legal-outer-nested-arities-and-splice-positions";
            case "COMMUTATIVITY" -> "all-admitted-sibling-permutations";
            case "IDEMPOTENCY" -> "all-admitted-quotient-surjections";
            default -> throw new AssertionError("Unknown test law " + law);
        };
        int ordinal = switch (law) {
            case "ASSOCIATIVITY" -> 0;
            case "COMMUTATIVITY" -> 1;
            case "IDEMPOTENCY" -> 2;
            default -> throw new AssertionError("Unknown test law " + law);
        };
        String parameter = stableKey(
                "alloy-law-parameter-v1",
                List.of("AND", "0/0", law, family),
                List.of(profileKey, typeKey, schemaKey));
        String index = stableKey(
                "container-law-index-v2",
                List.of(
                        "ALLOY_PROFILE_THEORY",
                        "ALLOY/AND",
                        "0/0",
                        law,
                        ALLOY_LAW_DIGEST),
                List.of(profileKey, typeKey, schemaKey, parameter));
        String left = stableKey(
                "container-law-source-endpoint", List.of("left"), List.of(index));
        String right = stableKey(
                "container-law-source-endpoint", List.of("right"), List.of(index));
        String sourceArtifact = ALLOY_LAW_VERSION + "/" + ALLOY_LAW_DIGEST;
        String declaration = "ALLOY/AND@0/0:" + law + ":" + sha256(parameter);
        return Wire.leaf(
                "law-certificate",
                index,
                "ALLOY_PROFILE_THEORY",
                "ALLOY/AND",
                boolType,
                boolType,
                "0/0",
                law,
                ALLOY_LAW_DIGEST,
                schemaId,
                schemaKey,
                parameter,
                left,
                right,
                "SIGNATURE_CONTAINER_LAW",
                sourceArtifact,
                declaration,
                Integer.toString(ordinal));
    }

    private static String stableKey(
            String tag,
            List<String> scalars,
            List<String> children) {
        StringBuilder result = new StringBuilder();
        appendStableField(result, tag);
        result.append('[').append(scalars.size()).append(':');
        for (String scalar : scalars) {
            appendStableField(result, scalar);
        }
        result.append(']').append('{').append(children.size()).append(':');
        for (String child : children) {
            result.append(child.length()).append(':').append(child);
        }
        return result.append('}').toString();
    }

    private static void appendStableField(StringBuilder target, String value) {
        target.append(value.length()).append(':').append(value);
    }

    private static String sha256(String value) {
        try {
            return java.util.HexFormat.of().formatHex(
                    java.security.MessageDigest.getInstance("SHA-256").digest(
                            value.getBytes(java.nio.charset.StandardCharsets.UTF_8)));
        } catch (java.security.NoSuchAlgorithmException exception) {
            throw new AssertionError(exception);
        }
    }

    static TestBundleBuilder.Encoded fullFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> { });
    }

    private static TestBundleBuilder.Encoded fullFixture(
            BaseOptions options,
            FixtureExtension extension) {
        return fullFixture(options, builder -> { }, extension);
    }

    private static TestBundleBuilder.Encoded fullFixture(
            BaseOptions options,
            BuilderSetup setup,
            FixtureExtension extension) {
        TestBundleBuilder builder = new TestBundleBuilder();
        setup.configure(builder);
        String boolType = builder.runtimeType("Bool", "BOOL", "");
        Wire.Node empty = builder.context(List.of());
        Wire.Node identity = builder.identity(empty);
        builder.operator("true", boolType);
        Wire.Node truth = builder.term(
                "APP", empty, "TERM", boolType, "true", List.of());
        builder.witness("w0@1", 1, "0", empty, boolType, truth);
        Wire.Node invoke = builder.term(
                "INVOKE", empty, "TERM", boolType, "w0@1",
                List.of(identity.scalar(0)));

        Wire.Node reflexive = builder.proof(
                "REFL", empty, "TERM", boolType, truth, truth, List.of(),
                Wire.leaf("refl", truth.scalar(0)));
        Wire.Node replay = builder.proof(
                "KERNEL_REPLAY", empty, "TERM", boolType, truth, truth,
                List.of(reflexive),
                Wire.node(
                        "kernel-replay",
                        List.of(
                                truth.scalar(0), empty.scalar(0), truth.scalar(0),
                                empty.scalar(0), identity.scalar(0), identity.scalar(0),
                                identity.scalar(0)),
                        List.of(
                                Wire.node("parent-paths", List.of()),
                                Wire.node("port-normalizations", List.of()),
                                Wire.leaf("structural-proof", reflexive.scalar(0)),
                                Wire.node("effective-support", List.of()))));

        Wire.Node before = builder.snapshot(
                0, "QUIESCENT",
                List.of(), List.of(), List.of(), List.of(),
                List.of(), List.of(), List.of());
        String termKey = Wire.contentId(Wire.node(
                "term-key/APP",
                List.of(empty.scalar(0), "TERM", boolType, "true"),
                List.of()));
        Wire.Node shape = Wire.leaf(
                "shape", "shape-0", "0", truth.scalar(0), replay.scalar(0));
        Wire.Node after = builder.snapshot(
                1,
                "QUIESCENT",
                List.of(Wire.leaf(
                        "class", "0", "w0@1", empty.scalar(0), boolType)),
                List.of(),
                List.of(shape),
                List.of(Wire.leaf("hash-owner", termKey, "0")),
                List.of(),
                List.of(),
                List.of());
        Wire.Node canonicalSnapshot = after;
        Wire.Node orbit = builder.proof(
                "CANONICAL_ORBIT", empty, "TERM", boolType, truth, truth,
                List.of(),
                Wire.node(
                        "canonical-orbit",
                        List.of(truth.scalar(0), empty.scalar(0), truth.scalar(0), "1"),
                        List.of(
                                Wire.node("free-renamings", options.omitFreeRenaming
                                        ? List.of()
                                        : List.of(Wire.leaf(
                                                "embedding-ref", identity.scalar(0)))),
                                Wire.node("leader-groups",
                                        List.of(canonicalSnapshot.scalar(0), "complete"), List.of()),
                                Wire.node("orbit-minimum", List.of(
                                        Wire.leaf("term-ref", truth.scalar(0)))))));
        Wire.Node fresh = builder.proof(
                "FRESH_WITNESS", empty, "TERM", boolType, truth, truth,
                List.of(replay),
                Wire.leaf("fresh-witness", "w0@1", truth.scalar(0),
                        identity.scalar(0), replay.scalar(0)));
        builder.event(
                0,
                "INSERT_FRESH",
                before,
                after,
                Wire.leaf("insert-fresh", "0", "shape-0",
                        options.genericReplayInEvent
                                ? reflexive.scalar(0) : replay.scalar(0),
                        orbit.scalar(0), fresh.scalar(0)));

        Wire.Node publicationSnapshot = after;
        long publicationRevision = 1;
        List<Wire.Node> publicationSc = List.of();
        if (options.dirtyPublication) {
            Wire.Node symmetry = builder.proof(
                    "FULL_INTERFACE_SYMMETRY",
                    empty,
                    "TERM",
                    boolType,
                    truth,
                    truth,
                    List.of(),
                    Wire.leaf(
                            "full-interface-symmetry",
                            identity.scalar(0), truth.scalar(0)));
            publicationSnapshot = builder.snapshot(
                    2,
                    "DIRTY",
                    List.of(Wire.leaf(
                            "class", "0", "w0@1", empty.scalar(0), boolType)),
                    List.of(),
                    List.of(shape),
                    List.of(Wire.leaf("hash-owner", termKey, "0")),
                    List.of(),
                    List.of(Wire.leaf(
                            "symmetry", "0", identity.scalar(0), symmetry.scalar(0))),
                    List.of());
            builder.event(
                    1,
                    "ADD_SYMMETRY",
                    after,
                    publicationSnapshot,
                    Wire.leaf(
                            "add-symmetry", "0", identity.scalar(0),
                            symmetry.scalar(0)));
            publicationRevision = 2;
            publicationSc = List.of(Wire.leaf(
                    "sc", "0", identity.scalar(0), symmetry.scalar(0)));
        }

        Wire.Node canonical = builder.canonicalRecord(orbit, truth, replay);
        Wire.Node rep = Wire.node(
                "rep",
                List.of(invoke.scalar(0), "shape-0", truth.scalar(0), "1"),
                List.of(
                        Wire.leaf("ambient-extension", identity.scalar(0)),
                        Wire.node("redundant-assignments", List.of()),
                        Wire.node("rep-children", options.incompleteUnfolding
                                ? List.of(Wire.leaf("cutoff", "invented"))
                                : List.of())));
        Wire.Node unfolding = builder.unfolding(invoke, 1, truth, after, rep);
        builder.publication(Wire.node(
                "publication",
                List.of(
                        publicationSnapshot.scalar(0),
                        options.stalePublication
                                ? "0" : Long.toString(publicationRevision),
                        options.publicationUsesInvocation
                                ? invoke.scalar(0) : truth.scalar(0),
                        truth.scalar(0),
                        "theory-digest-placeholder"),
                List.of(
                        Wire.node("ec-evidence", List.of(
                                Wire.leaf("ec", "0", "w0@1"))),
                        Wire.node("pc-evidence", List.of()),
                        Wire.node("sc-evidence", publicationSc),
                        Wire.node("canonical-refs", List.of(
                                Wire.leaf("canonical-ref", canonical.scalar(0)))),
                        Wire.node("unfolding-refs", List.of(
                                Wire.leaf("unfolding-ref", unfolding.scalar(0)))))));

        extension.extend(new FixtureParts(
                builder,
                empty,
                identity,
                truth,
                invoke,
                reflexive,
                replay,
                orbit,
                fresh,
                before,
                after,
                canonical,
                unfolding));

        TestBundleBuilder.Encoded provisional = builder.build();
        Wire.Node fixedRoot = replacePublicationDigest(
                provisional.root(), provisional.theoryDigest());
        return new TestBundleBuilder.Encoded(
                Codec.encode(fixedRoot), fixedRoot, provisional.theoryDigest());
    }

    private static Wire.Node replacePublicationDigest(Wire.Node root, String digest) {
        List<Wire.Node> children = new java.util.ArrayList<>(root.children());
        Wire.Node publication = children.get(11);
        List<String> scalars = new java.util.ArrayList<>(publication.scalars());
        scalars.set(4, digest);
        children.set(11, Wire.node("publication", scalars, publication.children()));
        return Wire.node(root.tag(), root.scalars(), children);
    }

    private static void assertOutcome(
            Outcome expected,
            VerificationResult actual,
            String label) {
        check(actual.outcome() == expected,
                label + ": expected " + expected + " but got " + actual);
    }

    private static void assertCode(
            FailureCode expected,
            VerificationResult actual,
            String label) {
        check(actual.code() == expected,
                label + ": expected " + expected + " but got " + actual);
    }

    private static void assertResult(
            Outcome expectedOutcome,
            FailureCode expectedCode,
            VerificationResult actual,
            String label) {
        check(actual.outcome() == expectedOutcome && actual.code() == expectedCode,
                label + ": expected " + expectedOutcome + "/" + expectedCode
                        + " but got " + actual);
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private static void expectThrows(
            Class<? extends Throwable> expected,
            Runnable action) {
        checks++;
        try {
            action.run();
        } catch (Throwable thrown) {
            if (expected.isInstance(thrown)) {
                return;
            }
            throw new AssertionError(
                    "Expected " + expected.getSimpleName() + " but got " + thrown,
                    thrown);
        }
        throw new AssertionError("Expected " + expected.getSimpleName());
    }

    @FunctionalInterface
    private interface FixtureExtension {
        void extend(FixtureParts fixture);
    }

    @FunctionalInterface
    private interface BuilderSetup {
        void configure(TestBundleBuilder builder);
    }

    private record FixtureParts(
            TestBundleBuilder builder,
            Wire.Node empty,
            Wire.Node identity,
            Wire.Node truth,
            Wire.Node invoke,
            Wire.Node reflexive,
            Wire.Node replay,
            Wire.Node orbit,
            Wire.Node fresh,
            Wire.Node before,
            Wire.Node after,
            Wire.Node canonical,
            Wire.Node unfolding) {
    }

    private enum WitnessUnfoldMutation {
        NONE,
        COHERENT_ALTERNATE_WITNESS,
        COHERENT_ALTERNATE_EMBEDDING,
        WRONG_WITNESS,
        WRONG_EMBEDDING,
        WRONG_EMBEDDING_SOURCE,
        WRONG_CONTEXT,
        WRONG_SORT,
        WRONG_LEFT,
        WRONG_RIGHT,
        EXTRA_PREMISE,
        WRONG_PAYLOAD_TAG,
        MISSING_PAYLOAD_SCALAR,
        EXTRA_PAYLOAD_SCALAR,
        EXTRA_PAYLOAD_CHILD,
        DANGLING_WITNESS,
        DANGLING_EMBEDDING,
        WRONG_VARIANT
    }

    private record BaseOptions(
            boolean omitFreeRenaming,
            boolean genericReplayInEvent,
            boolean dirtyPublication,
            boolean stalePublication,
            boolean incompleteUnfolding,
            boolean publicationUsesInvocation) {
        private static BaseOptions defaults() {
            return new BaseOptions(false, false, false, false, false, false);
        }

        private BaseOptions withOmittedFreeRenaming() {
            return new BaseOptions(
                    true, genericReplayInEvent, dirtyPublication,
                    stalePublication, incompleteUnfolding,
                    publicationUsesInvocation);
        }

        private BaseOptions withGenericReplayInEvent() {
            return new BaseOptions(
                    omitFreeRenaming, true, dirtyPublication,
                    stalePublication, incompleteUnfolding,
                    publicationUsesInvocation);
        }

        private BaseOptions withDirtyPublication() {
            return new BaseOptions(
                    omitFreeRenaming, genericReplayInEvent, true,
                    stalePublication, incompleteUnfolding,
                    publicationUsesInvocation);
        }

        private BaseOptions withStalePublication() {
            return new BaseOptions(
                    omitFreeRenaming, genericReplayInEvent, dirtyPublication,
                    true, incompleteUnfolding, publicationUsesInvocation);
        }

        private BaseOptions withIncompleteUnfolding() {
            return new BaseOptions(
                    omitFreeRenaming, genericReplayInEvent, dirtyPublication,
                    stalePublication, true, publicationUsesInvocation);
        }

        private BaseOptions withPublicationInvocation() {
            return new BaseOptions(
                    omitFreeRenaming, genericReplayInEvent, dirtyPublication,
                    stalePublication, incompleteUnfolding, true);
        }
    }

    private record ContainerTerms(
            String oneSchema,
            String seqSchema,
            String bagSchema,
            String setSchema,
            Wire.Node truePort,
            Wire.Node falsePort) {
    }

    private record ClassWitness(String eclass, String witness) {
    }

    private record CollisionEdge(
            Wire.Node sourceReplay,
            Wire.Node fresh,
            Wire.Node collision,
            Wire.Node edge) {
    }

    private record FreshNullary(
            Wire.Node term,
            Wire.Node invocation,
            Wire.Node replay,
            Wire.Node orbit,
            Wire.Node fresh) {
    }

    private record FreshBox(
            Wire.Node term,
            Wire.Node invocation,
            Wire.Node ownerInvocation,
            Wire.Node port,
            Wire.Node replay,
            Wire.Node fresh) {
    }

    private enum ContractionMutation {
        NONE,
        PRE_FIND_SUPPORT,
        WRONG_OMEGA,
        FRESH_AT_GAMMA,
        MISSING_PATH,
        WRONG_PATH,
        WRONG_INITIAL,
        WRONG_LEADER,
        WRONG_FINAL,
        DUPLICATE_PATH,
        REORDERED_PATHS,
        DUPLICATE_EDGE,
        NON_EDGE_PROOF
    }
}
