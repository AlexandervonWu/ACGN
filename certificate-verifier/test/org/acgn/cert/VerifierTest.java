package org.acgn.cert;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Standalone positive and adversarial regression suite. */
public final class VerifierTest {
    private static int checks;

    private VerifierTest() {
    }

    public static void main(String[] args) {
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
        assertOutcome(
                Outcome.UNCHECKABLE,
                verify(verifier, collisionMissingSideFixture(), Profile.KERNEL),
                "collision missing its second replay certificate");
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, collisionTransitionFixture(), Profile.CHECKPOINT),
                "certified insertion collision transition");
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, rebuildRecordFixture(), Profile.CHECKPOINT),
                "rebuild-record transition with explicit forward evidence");
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
        assertOutcome(
                Outcome.UNCHECKABLE,
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
                FailureCode.IMPLICIT_INTERFACE_CONTRACTION,
                verify(
                        verifier,
                        implicitInterfaceMutationFixture(),
                        Profile.CHECKPOINT),
                "implicit interface mutation outside restriction event");
        assertOutcome(
                Outcome.VERIFIED,
                verify(verifier, unionTransitionFixture(), Profile.CHECKPOINT),
                "distinct-leader union with checked endpoint equation");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        restrictionTransitionFixture(),
                        Profile.CHECKPOINT),
                "strict interface restriction with versioned witness factorization");
        assertOutcome(
                Outcome.VERIFIED,
                verify(
                        verifier,
                        symmetryTransitionFixture(),
                        Profile.CHECKPOINT),
                "nonidentity full-interface symmetry transition");
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
                                            List.of("snapshot-orbit", "complete"),
                                            List.of()),
                                    Wire.node("orbit-members", List.of(
                                            Wire.leaf("term-ref", smaller.scalar(0)),
                                            Wire.leaf("term-ref", larger.scalar(0)))))));
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
                                    Wire.node("parent-paths", List.of(
                                            Wire.node(
                                                    "parent-path",
                                                    List.of(
                                                            "0/0", "wc@1", "w0@1",
                                                            parentInvocation.scalar(0)),
                                                    List.of(Wire.leaf(
                                                            "edge-ref",
                                                            parentEdge.scalar(0)))))),
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

    private static TestBundleBuilder.Encoded collisionTransitionFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            builder.witness(
                    "w1@2", 2, "1", fixture.empty(), "Bool", fixture.truth());
            Wire.Node secondInvocation = builder.term(
                    "INVOKE", fixture.empty(), "TERM", "Bool", "w1@2",
                    List.of(fixture.identity().scalar(0)));

            String axiomId = "axiom/collision-witnesses";
            builder.axiom(
                    axiomId,
                    Wire.node(
                            "pattern",
                            List.of(
                                    "INVOKE", "TERM", "Bool", "w1@2",
                                    fixture.identity().scalar(0)),
                            List.of()),
                    Wire.node(
                            "pattern",
                            List.of(
                                    "INVOKE", "TERM", "Bool", "w0@1",
                                    fixture.identity().scalar(0)),
                            List.of()),
                    List.of(), List.of(), List.of());
            Wire.Node equation = builder.proof(
                    "AXIOM", fixture.empty(), "TERM", "Bool",
                    secondInvocation, fixture.invoke(), List.of(),
                    Wire.node(
                            "axiom-instance",
                            List.of(axiomId, fixture.empty().scalar(0)),
                            List.of(
                                    Wire.node("type-substitution", List.of()),
                                    Wire.node("term-substitution", List.of()),
                                    Wire.node("side-evidence", List.of()))));
            Wire.Node edge = builder.proof(
                    "PARENT_EDGE", fixture.empty(), "TERM", "Bool",
                    secondInvocation, fixture.invoke(), List.of(equation),
                    Wire.leaf(
                            "parent-edge", "w1@2", "w0@1",
                            fixture.identity().scalar(0)));
            Wire.Node collision = builder.proof(
                    "COLLISION", fixture.empty(), "TERM", "Bool",
                    fixture.truth(), fixture.truth(),
                    List.of(fixture.replay(), fixture.replay()),
                    Wire.leaf(
                            "collision",
                            fixture.replay().scalar(0),
                            fixture.replay().scalar(0),
                            "same-complete-key",
                            "same-complete-key"));

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
            builder.event(
                    1,
                    "INSERT_COLLISION",
                    fixture.after(),
                    dirty,
                    Wire.leaf(
                            "insert-collision",
                            "1",
                            "collision-source",
                            fixture.replay().scalar(0),
                            collision.scalar(0),
                            edge.scalar(0)));
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
            builder.event(
                    2,
                    "REBUILD_COMPLETE",
                    dirty,
                    finalSnapshot,
                    Wire.leaf("rebuild-complete", "false"));
            builder.publication(publication(
                    fixture,
                    finalSnapshot,
                    2,
                    List.of(
                            Wire.leaf("ec", "0", "w0@1"),
                            Wire.leaf("ec", "1", "w1@2")),
                    List.of(Wire.leaf("pc", "edge-1-0", edge.scalar(0)))));
        });
    }

    private static TestBundleBuilder.Encoded rebuildRecordFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            Wire.Node forward = fixture.builder().proof(
                    "REBUILD_CONGRUENCE",
                    fixture.empty(),
                    "TERM",
                    "Bool",
                    fixture.truth(),
                    fixture.truth(),
                    List.of(fixture.reflexive()),
                    Wire.leaf(
                            "rebuild-congruence", fixture.reflexive().scalar(0)));
            fixture.builder().event(
                    1,
                    "REBUILD_RECORD",
                    fixture.after(),
                    fixture.after(),
                    Wire.leaf(
                            "rebuild-record", "shape-0", forward.scalar(0), ""));
        });
    }

    private static TestBundleBuilder.Encoded pathCompressionFixture(
            boolean omitOriginalEdges) {
        return fullFixture(BaseOptions.defaults(), fixture -> {
            TestBundleBuilder builder = fixture.builder();
            builder.witness(
                    "w1@2", 2, "1", fixture.empty(), "Bool", fixture.truth());
            builder.witness(
                    "w2@3", 3, "2", fixture.empty(), "Bool", fixture.truth());
            Wire.Node invocation1 = builder.term(
                    "INVOKE", fixture.empty(), "TERM", "Bool", "w1@2",
                    List.of(fixture.identity().scalar(0)));
            Wire.Node invocation2 = builder.term(
                    "INVOKE", fixture.empty(), "TERM", "Bool", "w2@3",
                    List.of(fixture.identity().scalar(0)));
            Wire.Node edge10 = witnessEdge(
                    fixture, "w1@2", "w0@1", invocation1, fixture.invoke(), "10");
            Wire.Node edge21 = witnessEdge(
                    fixture, "w2@3", "w1@2", invocation2, invocation1, "21");
            Wire.Node edge20 = witnessEdge(
                    fixture, "w2@3", "w0@1", invocation2, fixture.invoke(), "20");
            Wire.Node collision = builder.proof(
                    "COLLISION", fixture.empty(), "TERM", "Bool",
                    fixture.truth(), fixture.truth(),
                    List.of(fixture.replay(), fixture.replay()),
                    Wire.leaf(
                            "collision",
                            fixture.replay().scalar(0),
                            fixture.replay().scalar(0),
                            "same-complete-key",
                            "same-complete-key"));
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
                            "insert-collision", "1", "collision-source-1",
                            fixture.replay().scalar(0), collision.scalar(0),
                            edge10.scalar(0)));

            Wire.Node chain = builder.snapshot(
                    3,
                    "DIRTY",
                    classRecords(fixture, List.of(
                            new ClassWitness("1", "w1@2"),
                            new ClassWitness("2", "w2@3"))),
                    List.of(
                            parent(
                                    "edge-1-0", "1", "0",
                                    fixture.identity(), edge10),
                            parent(
                                    "edge-2-1", "2", "1",
                                    fixture.identity(), edge21)),
                    baseShape(fixture),
                    List.of(Wire.leaf("hash-owner", trueKey, "0")),
                    List.of(), List.of(), List.of());
            builder.event(
                    2,
                    "INSERT_COLLISION",
                    oneParent,
                    chain,
                    Wire.leaf(
                            "insert-collision", "2", "collision-source-2",
                            fixture.replay().scalar(0), collision.scalar(0),
                            edge21.scalar(0)));

            Wire.Node compressed = builder.snapshot(
                    3,
                    "DIRTY",
                    classRecords(fixture, List.of(
                            new ClassWitness("1", "w1@2"),
                            new ClassWitness("2", "w2@3"))),
                    List.of(
                            parent(
                                    "edge-1-0", "1", "0",
                                    fixture.identity(), edge10),
                            parent(
                                    "edge-2-0", "2", "0",
                                    fixture.identity(), edge20)),
                    baseShape(fixture),
                    List.of(Wire.leaf("hash-owner", trueKey, "0")),
                    List.of(), List.of(), List.of());
            List<Wire.Node> originalEdges = omitOriginalEdges
                    ? List.of()
                    : List.of(
                            Wire.leaf("original-edge", "edge-2-1"),
                            Wire.leaf("original-edge", "edge-1-0"));
            builder.event(
                    3,
                    "PATH_COMPRESS",
                    chain,
                    compressed,
                    Wire.node(
                            "path-compress",
                            List.of("2", edge20.scalar(0)),
                            originalEdges));

            Wire.Node quiescent = builder.snapshot(
                    3,
                    "QUIESCENT",
                    classRecords(fixture, List.of(
                            new ClassWitness("1", "w1@2"),
                            new ClassWitness("2", "w2@3"))),
                    List.of(
                            parent(
                                    "edge-1-0", "1", "0",
                                    fixture.identity(), edge10),
                            parent(
                                    "edge-2-0", "2", "0",
                                    fixture.identity(), edge20)),
                    baseShape(fixture),
                    List.of(Wire.leaf("hash-owner", trueKey, "0")),
                    List.of(), List.of(), List.of());
            builder.event(
                    4,
                    "REBUILD_COMPLETE",
                    compressed,
                    quiescent,
                    Wire.leaf("rebuild-complete", "false"));
            builder.publication(publication(
                    fixture,
                    quiescent,
                    3,
                    List.of(
                            Wire.leaf("ec", "0", "w0@1"),
                            Wire.leaf("ec", "1", "w1@2"),
                            Wire.leaf("ec", "2", "w2@3")),
                    List.of(
                            Wire.leaf("pc", "edge-1-0", edge10.scalar(0)),
                            Wire.leaf("pc", "edge-2-0", edge20.scalar(0)))));
        });
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
                                    locallyRenamed.scalar(0), "1"),
                            List.of(
                                    Wire.node("free-renamings", renamings),
                                    Wire.node(
                                            "leader-groups",
                                            List.of("snapshot-local", "complete"),
                                            List.of()),
                                    Wire.node("orbit-members", List.of(
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
                    baseShape(fixture),
                    List.of(Wire.leaf(
                            "hash-owner", trueTermKey(fixture), "0")),
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
                    List.of(
                            Wire.leaf(
                                    "shape", "shape-0", "0",
                                    fixture.truth().scalar(0),
                                    fixture.replay().scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-1", "0",
                                    second.term().scalar(0),
                                    second.replay().scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueKey, "0"),
                            Wire.leaf("hash-owner", falseKey, "0")),
                    List.of(), List.of(), List.of());
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
                    List.of(
                            Wire.leaf(
                                    "shape", "shape-0", "0",
                                    fixture.truth().scalar(0),
                                    fixture.replay().scalar(0)),
                            Wire.leaf(
                                    "shape", "shape-1", "0",
                                    second.term().scalar(0),
                                    second.replay().scalar(0))),
                    List.of(
                            Wire.leaf("hash-owner", trueKey, "0"),
                            Wire.leaf("hash-owner", falseKey, "0")),
                    List.of(), List.of(), List.of());
            builder.event(
                    3,
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
                                            List.of("snapshot-restrict", "complete"),
                                            List.of()),
                                    Wire.node("orbit-members", List.of(Wire.leaf(
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
                                    "transported-evidence", List.of()))));
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
                                    source.scalar(0), replay.scalar(0))),
                    List.of(
                            Wire.leaf(
                                    "hash-owner", trueTermKey(fixture), "0"),
                            Wire.leaf("hash-owner", sourceKey, "1")),
                    List.of(), List.of(), List.of());
            builder.event(
                    3,
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
                                    source.scalar(0), "1"),
                            List.of(
                                    Wire.node("free-renamings", freeRenamings),
                                    Wire.node(
                                            "leader-groups",
                                            List.of("snapshot-symmetry", "complete"),
                                            List.of()),
                                    Wire.node("orbit-members", List.of(Wire.leaf(
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
            builder.event(
                    3,
                    "REBUILD_COMPLETE",
                    dirty,
                    quiescent,
                    Wire.leaf("rebuild-complete", "false"));
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
                                        List.of("snapshot-fresh", "complete"),
                                        List.of()),
                                Wire.node("orbit-members", List.of(Wire.leaf(
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
                        List.of(kind, source.scalar(0), target.scalar(0)),
                        occurrences));
    }

    static TestBundleBuilder.Encoded fullFixture() {
        return fullFixture(BaseOptions.defaults(), fixture -> { });
    }

    private static TestBundleBuilder.Encoded fullFixture(
            BaseOptions options,
            FixtureExtension extension) {
        TestBundleBuilder builder = new TestBundleBuilder();
        Wire.Node empty = builder.context(List.of());
        Wire.Node identity = builder.identity(empty);
        builder.operator("true", "Bool");
        Wire.Node truth = builder.term(
                "APP", empty, "TERM", "Bool", "true", List.of());
        builder.witness("w0@1", 1, "0", empty, "Bool", truth);
        Wire.Node invoke = builder.term(
                "INVOKE", empty, "TERM", "Bool", "w0@1",
                List.of(identity.scalar(0)));

        Wire.Node reflexive = builder.proof(
                "REFL", empty, "TERM", "Bool", truth, truth, List.of(),
                Wire.leaf("refl", truth.scalar(0)));
        Wire.Node replay = builder.proof(
                "KERNEL_REPLAY", empty, "TERM", "Bool", truth, truth,
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

        Wire.Node orbit = builder.proof(
                "CANONICAL_ORBIT", empty, "TERM", "Bool", truth, truth,
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
                                        List.of("snapshot-after", "complete"), List.of()),
                                Wire.node("orbit-members", List.of(
                                        Wire.leaf("term-ref", truth.scalar(0)))))));
        Wire.Node fresh = builder.proof(
                "FRESH_WITNESS", empty, "TERM", "Bool", truth, truth,
                List.of(replay),
                Wire.leaf("fresh-witness", "w0@1", truth.scalar(0),
                        identity.scalar(0), replay.scalar(0)));

        Wire.Node before = builder.snapshot(
                0, options.dirtyPublication ? "DIRTY" : "QUIESCENT",
                List.of(), List.of(), List.of(), List.of(),
                List.of(), List.of(), List.of());
        String termKey = Wire.contentId(Wire.node(
                "term-key/APP",
                List.of(empty.scalar(0), "TERM", "Bool", "true"),
                List.of()));
        Wire.Node shape = Wire.leaf(
                "shape", "shape-0", "0", truth.scalar(0), replay.scalar(0));
        Wire.Node after = builder.snapshot(
                1,
                options.dirtyPublication ? "DIRTY" : "QUIESCENT",
                List.of(Wire.leaf("class", "0", "w0@1", empty.scalar(0), "Bool")),
                List.of(),
                List.of(shape),
                List.of(Wire.leaf("hash-owner", termKey, "0")),
                List.of(),
                List.of(),
                List.of());
        builder.event(
                0,
                "INSERT_FRESH",
                before,
                after,
                Wire.leaf("insert-fresh", "0", "shape-0",
                        options.genericReplayInEvent
                                ? reflexive.scalar(0) : replay.scalar(0),
                        orbit.scalar(0), fresh.scalar(0)));

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
                List.of(after.scalar(0), options.stalePublication ? "0" : "1",
                        options.publicationUsesInvocation
                                ? invoke.scalar(0) : truth.scalar(0),
                        truth.scalar(0),
                        "theory-digest-placeholder"),
                List.of(
                        Wire.node("ec-evidence", List.of(
                                Wire.leaf("ec", "0", "w0@1"))),
                        Wire.node("pc-evidence", List.of()),
                        Wire.node("sc-evidence", List.of()),
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

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    @FunctionalInterface
    private interface FixtureExtension {
        void extend(FixtureParts fixture);
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

    private record FreshNullary(
            Wire.Node term,
            Wire.Node invocation,
            Wire.Node replay,
            Wire.Node orbit,
            Wire.Node fresh) {
    }

    private enum ContractionMutation {
        NONE,
        PRE_FIND_SUPPORT,
        WRONG_OMEGA,
        FRESH_AT_GAMMA
    }
}
