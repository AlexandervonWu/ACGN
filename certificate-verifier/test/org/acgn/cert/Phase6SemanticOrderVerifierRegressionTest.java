package org.acgn.cert;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Minimal verifier counterexamples for complete orbit and polymorphic key order. */
public final class Phase6SemanticOrderVerifierRegressionTest {
    private static final java.util.Set<Integer> CONTENT_TABLES =
            java.util.Set.of(2, 3, 4, 5, 7, 9, 10);
    private static int checks;

    private Phase6SemanticOrderVerifierRegressionTest() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 5) {
            throw new IllegalArgumentException(
                    "usage: Phase6SemanticOrderVerifierRegressionTest "
                            + "<canonical> <reversed> <polymorphic> <monomorphic> "
                            + "<order-directory>");
        }
        byte[] canonical = Files.readAllBytes(Path.of(args[0]));
        byte[] reversed = Files.readAllBytes(Path.of(args[1]));
        byte[] polymorphic = Files.readAllBytes(Path.of(args[2]));
        byte[] monomorphic = Files.readAllBytes(Path.of(args[3]));
        Bundle canonicalBundle = decode(canonical);
        String digest = canonicalBundle.theoryDigest();
        VerificationPolicy policy = VerificationPolicy.trust(digest);
        for (byte[] bytes : List.of(canonical, reversed, polymorphic, monomorphic)) {
            policy = policy.withCallOccurrenceCommitment(
                    CallOccurrenceCommitment.inspect(bytes, Limits.defaults()));
        }
        IndependentVerifier verifier = new IndependentVerifier();

        assertVerified(verifier.verify(canonical, Profile.FULL, policy),
                "canonical source");
        assertVerified(verifier.verify(reversed, Profile.FULL, policy),
                "nonidentity producer witness");
        assertVerified(verifier.verify(polymorphic, Profile.FULL, policy),
                "polymorphic declaration");
        assertVerified(verifier.verify(monomorphic, Profile.FULL, policy),
                "monomorphic declaration");
        assertVerified(verifier.verifyPair(canonical, reversed, policy),
                "alpha-equivalent source pair");
        for (int index = 0; index < 6; index++) {
            byte[] order = Files.readAllBytes(
                    Path.of(args[4]).resolve("order-" + index + ".acgncert"));
            VerificationPolicy orderPolicy = policy.withCallOccurrenceCommitment(
                    CallOccurrenceCommitment.inspect(order, Limits.defaults()));
            assertVerified(verifier.verify(order, Profile.FULL, orderPolicy),
                    "three-slot order " + index);
        }

        VerificationResult distinctDeclarations = verifier.verifyPair(
                polymorphic, monomorphic, policy);
        check(distinctDeclarations.outcome() == Outcome.UNCHECKABLE
                        && distinctDeclarations.code()
                                == FailureCode.MISSING_PAIR_DERIVATION,
                "polymorphic and monomorphic declarations do not share a kernel");
        check(!representativeKey(polymorphic).equals(representativeKey(monomorphic)),
                "semantic representative keys preserve type parameters and substitution");
        check(!representativeOperator(polymorphic).equals(
                        representativeOperator(monomorphic)),
                "wire operator identities preserve generic declaration provenance");

        VerificationResult wrongWitness = verifier.verify(
                replaceProducerWitnessWithWireIdentity(reversed),
                Profile.FULL,
                policy);
        check(wrongWitness.outcome() == Outcome.REJECTED
                        && wrongWitness.code()
                                == FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                "equal canonical shapes cannot hide a different selected permutation");
        assertWitnessTieOrder(canonical);

        System.out.println("Phase6SemanticOrderVerifierRegressionTest: "
                + checks + " checks passed");
    }

    private static void assertWitnessTieOrder(byte[] encoded) {
        Bundle bundle = decode(encoded);
        KernelModel model = new KernelModel(bundle, Limits.defaults());
        SemanticEvidenceVerifier.Authorization authorization =
                new SemanticEvidenceVerifier(
                        bundle, model, policyFor(encoded, bundle)).verify();
        KernelVerifier kernel = new KernelVerifier(
                model, Limits.defaults(), authorization);
        KernelModel.Term term = model.term(onlyCanonicalRecord(bundle).scalar(2));
        List<KernelModel.Embedding> candidates = model.embeddings().values().stream()
                .filter(embedding -> embedding.kind()
                        == KernelModel.EmbeddingKind.BIJECTION)
                .filter(embedding -> embedding.source().equals(term.context())
                        && embedding.target().equals(term.context()))
                .toList();
        KernelModel.Embedding identity = candidates.stream()
                .filter(Phase6SemanticOrderVerifierRegressionTest::isIdentity)
                .findFirst().orElseThrow();
        KernelModel.Embedding nonidentity = candidates.stream()
                .filter(embedding -> !isIdentity(embedding))
                .findFirst().orElseThrow();
        CanonicalProfileVerifier profile = new CanonicalProfileVerifier(
                model, kernel, Limits.defaults());
        check(profile.compareCandidatePairForTesting(
                        term, identity, term, nonidentity) < 0,
                "equal shapes are ordered by the complete canonical witness key");
        check(profile.compareCandidatePairForTesting(
                        term, nonidentity, term, identity) > 0,
                "witness tie ordering is antisymmetric on a nonidentity permutation");
        check(profile.minimumWitnessForTesting(
                        term, List.of(nonidentity, identity)).equals(identity.id()),
                "standalone orbit minimum replaces a larger first witness");
        check(profile.minimumWitnessForTesting(
                        term, List.of(identity, nonidentity)).equals(identity.id()),
                "standalone orbit minimum is independent of candidate order");
    }

    private static boolean isIdentity(KernelModel.Embedding embedding) {
        if (!embedding.source().equals(embedding.target())) {
            return false;
        }
        return embedding.source().slots().stream().allMatch(
                slot -> slot.name().equals(embedding.apply(slot.name())));
    }

    private static String representativeKey(byte[] encoded) {
        Bundle bundle = decode(encoded);
        KernelModel model = new KernelModel(bundle, Limits.defaults());
        SemanticEvidenceVerifier.Authorization authorization =
                new SemanticEvidenceVerifier(
                        bundle, model, policyFor(encoded, bundle)).verify();
        KernelVerifier kernel = new KernelVerifier(
                model, Limits.defaults(), authorization);
        Wire.Node record = onlyCanonicalRecord(bundle);
        return kernel.canonicalTermKey(model.term(record.scalar(2)));
    }

    private static String representativeOperator(byte[] encoded) {
        Bundle bundle = decode(encoded);
        KernelModel model = new KernelModel(bundle, Limits.defaults());
        KernelModel.Term term = model.term(onlyCanonicalRecord(bundle).scalar(2));
        check(term.kind() == KernelModel.TermKind.APP,
                "fixture representative is an application");
        return term.symbol();
    }

    private static VerificationPolicy policyFor(byte[] encoded, Bundle bundle) {
        return VerificationPolicy.trust(bundle.theoryDigest())
                .withCallOccurrenceCommitment(
                        CallOccurrenceCommitment.inspect(encoded, Limits.defaults()));
    }

    private static Wire.Node onlyCanonicalRecord(Bundle bundle) {
        check(bundle.canonicalRecords().size() == 1,
                "fixture has one canonical record");
        return bundle.canonicalRecords().values().iterator().next();
    }

    private static byte[] replaceProducerWitnessWithWireIdentity(byte[] source) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        String identity = null;
        for (Wire.Node proof : root.child(5).children()) {
            if ("CANONICAL_ORBIT".equals(proof.scalar(1))) {
                identity = proof.child(1).requireShape(
                        "canonical-orbit", 6, 4).scalar(4);
            }
        }
        if (identity == null) {
            throw new AssertionError("fixture has no canonical orbit");
        }
        List<Wire.Node> proofs = new ArrayList<>();
        int changed = 0;
        for (Wire.Node proof : root.child(5).children()) {
            Wire.Node next = proof;
            if ("KERNEL_REPLAY".equals(proof.scalar(1))) {
                Wire.Node payload = proof.child(1).requireShape(
                        "kernel-replay", 7, 5);
                Wire.Node reference = payload.child(4).requireShape(
                        "source-construction", 4, 0);
                if ("producer-orbit-source-v1".equals(reference.scalar(1))) {
                    List<String> scalars = new ArrayList<>(reference.scalars());
                    scalars.set(3, identity);
                    next = replaceChild(
                            proof,
                            1,
                            replaceChild(payload, 4, Wire.node(
                                    reference.tag(), scalars, reference.children())));
                    changed++;
                }
            }
            proofs.add(next);
        }
        if (changed != 1) {
            throw new AssertionError(
                    "fixture must have exactly one producer-orbit marker");
        }
        root = replaceChild(root, 5, Wire.node("proofs", sorted(proofs)));
        return Codec.encode(closeContentIds(root));
    }

    private static Wire.Node closeContentIds(Wire.Node root) {
        for (int pass = 0; pass < 32; pass++) {
            Map<String, String> ids = new HashMap<>();
            List<Wire.Node> sections = new ArrayList<>(root.children());
            for (int index : CONTENT_TABLES) {
                Wire.Node section = sections.get(index);
                List<Wire.Node> records = new ArrayList<>();
                for (Wire.Node record : section.children()) {
                    Wire.Node rewritten = rewriteIds(record, ids);
                    Wire.Node identified = Bundle.withContentId(
                            rewritten.tag(),
                            rewritten.scalars().subList(1, rewritten.scalars().size()),
                            rewritten.children());
                    ids.put(record.scalar(0), identified.scalar(0));
                    records.add(identified);
                }
                sections.set(index, Wire.node(section.tag(), sorted(records)));
            }
            Wire.Node next = rewriteIds(
                    Wire.node(root.tag(), root.scalars(), sections), ids);
            List<Wire.Node> finalSections = new ArrayList<>(next.children());
            Wire.Node vocabulary = finalSections.get(1).child(1);
            finalSections.set(1, Wire.node(
                    "manifest",
                    List.of(finalSections.get(1).scalar(0), Wire.contentId(vocabulary)),
                    List.of(finalSections.get(1).child(0), vocabulary)));
            next = Wire.node(next.tag(), next.scalars(), finalSections);
            if (java.util.Arrays.equals(Codec.encode(next), Codec.encode(root))) {
                return next;
            }
            root = next;
        }
        throw new AssertionError("content-ID closure did not converge");
    }

    private static Wire.Node rewriteIds(Wire.Node node, Map<String, String> ids) {
        return Wire.node(
                node.tag(),
                node.scalars().stream()
                        .map(value -> ids.getOrDefault(value, value)).toList(),
                node.children().stream()
                        .map(child -> rewriteIds(child, ids)).toList());
    }

    private static List<Wire.Node> sorted(List<Wire.Node> nodes) {
        nodes.sort(Comparator.comparing(node -> node.scalar(0)));
        return nodes;
    }

    private static Wire.Node replaceChild(
            Wire.Node parent,
            int index,
            Wire.Node replacement) {
        List<Wire.Node> children = new ArrayList<>(parent.children());
        children.set(index, replacement);
        return Wire.node(parent.tag(), parent.scalars(), children);
    }

    private static Bundle decode(byte[] encoded) {
        return Bundle.parse(Codec.decode(encoded, Limits.defaults()));
    }

    private static void assertVerified(VerificationResult result, String label) {
        check(result.outcome() == Outcome.VERIFIED,
                label + " failed: " + result.outcome() + "/" + result.code()
                        + " " + result.detail());
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
