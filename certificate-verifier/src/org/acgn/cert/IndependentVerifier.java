package org.acgn.cert;

import java.util.ArrayDeque;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Public fail-closed entry point; no producer object crosses this boundary. */
public final class IndependentVerifier {
    public VerificationResult verify(
            byte[] encoded,
            Profile profile,
            VerificationPolicy policy) {
        Objects.requireNonNull(encoded, "encoded");
        Objects.requireNonNull(profile, "profile");
        Objects.requireNonNull(policy, "policy");
        if (profile == Profile.PAIR) {
            return VerificationResult.rejected(
                    FailureCode.INVALID_RECORD_SHAPE,
                    "PAIR requires verifyPair with two bundles");
        }
        try {
            Session session = open(encoded, policy);
            verifyProfile(session, profile);
            return VerificationResult.verified(
                    profile.name().toLowerCase() + " profile independently verified");
        } catch (UncheckableException exception) {
            return VerificationResult.uncheckable(exception.code(), exception.getMessage());
        } catch (TermOps.ResourceLimitException exception) {
            return VerificationResult.uncheckable(
                    FailureCode.RESOURCE_LIMIT, exception.getMessage());
        } catch (FormatException exception) {
            if (exception.code() == FailureCode.RESOURCE_LIMIT) {
                return VerificationResult.uncheckable(
                        exception.code(), exception.getMessage());
            }
            return VerificationResult.rejected(exception.code(), exception.getMessage());
        } catch (RuntimeException exception) {
            return VerificationResult.rejected(
                    FailureCode.INTERNAL_ERROR,
                    exception.getClass().getSimpleName() + ": " + exception.getMessage());
        }
    }

    public VerificationResult verifyPair(
            byte[] leftEncoded,
            byte[] rightEncoded,
            VerificationPolicy policy) {
        Objects.requireNonNull(leftEncoded, "leftEncoded");
        Objects.requireNonNull(rightEncoded, "rightEncoded");
        Objects.requireNonNull(policy, "policy");
        try {
            Session left = open(leftEncoded, policy);
            Session right = open(rightEncoded, policy);
            if (!left.bundle.theoryDigest().equals(right.bundle.theoryDigest())) {
                throw new FormatException(
                        FailureCode.THEORY_MISMATCH,
                        "Pair bundles use different pinned theories");
            }
            verifyProfile(left, Profile.FULL);
            verifyProfile(right, Profile.FULL);
            PairEndpoint leftEndpoint = commonKernelEndpoint(left);
            PairEndpoint rightEndpoint = commonKernelEndpoint(right);
            if (!leftEndpoint.representativeKey.equals(rightEndpoint.representativeKey)
                    || !leftEndpoint.representative.sort().equals(
                            rightEndpoint.representative.sort())) {
                throw new UncheckableException(
                        FailureCode.MISSING_PAIR_DERIVATION,
                        "Verified bundles do not expose a compatible common canonical kernel");
            }
            requireCompatibleVocabulary(
                    leftEndpoint.representative,
                    left.model,
                    rightEndpoint.representative,
                    right.model);
            if (!leftEndpoint.replay.right().id().equals(leftEndpoint.orbit.left().id())
                    || !rightEndpoint.replay.right().id().equals(
                            rightEndpoint.orbit.left().id())) {
                throw new FormatException(
                        FailureCode.MISSING_PAIR_DERIVATION,
                        "Source replay and orbit derivation do not compose exactly");
            }
            // The checked composite is replay_L ; orbit_L ; sym(orbit_R) ; sym(replay_R).
            // Equality of complete representative structures, not observation hashes,
            // supplies the exact middle endpoint after canonical-context comparison.
            return VerificationResult.verified(
                    "pair independently derives both sources through one checked kernel");
        } catch (UncheckableException exception) {
            return VerificationResult.uncheckable(exception.code(), exception.getMessage());
        } catch (TermOps.ResourceLimitException exception) {
            return VerificationResult.uncheckable(
                    FailureCode.RESOURCE_LIMIT, exception.getMessage());
        } catch (FormatException exception) {
            if (exception.code() == FailureCode.RESOURCE_LIMIT) {
                return VerificationResult.uncheckable(
                        exception.code(), exception.getMessage());
            }
            return VerificationResult.rejected(exception.code(), exception.getMessage());
        } catch (RuntimeException exception) {
            return VerificationResult.rejected(
                    FailureCode.INTERNAL_ERROR,
                    exception.getClass().getSimpleName() + ": " + exception.getMessage());
        }
    }

    private static Session open(byte[] encoded, VerificationPolicy policy) {
        Wire.Node root = Codec.decode(encoded, policy.limits());
        Bundle bundle = Bundle.parse(root);
        if (!policy.trustedTheoryDigests().contains(bundle.theoryDigest())) {
            throw new FormatException(
                    FailureCode.UNTRUSTED_THEORY,
                    "Theory digest is not pinned by the verifier caller");
        }
        KernelModel model = new KernelModel(bundle);
        KernelVerifier kernel = new KernelVerifier(model, policy.limits());
        return new Session(bundle, model, kernel, policy.limits());
    }

    private static void verifyProfile(Session session, Profile profile) {
        session.kernel.verifyAll();
        switch (profile) {
            case KERNEL -> {
                return;
            }
            case CANONICAL -> {
                new CanonicalProfileVerifier(
                        session.model, session.kernel, session.limits).verifyAllRecords();
                return;
            }
            case CHECKPOINT -> {
                CheckpointVerifier checkpoint = new CheckpointVerifier(
                        session.model, session.kernel);
                CheckpointVerifier.Snapshot end = checkpoint.verifyTransitions();
                checkpoint.verifyPublication(end);
                return;
            }
            case UNFOLD -> {
                CheckpointVerifier checkpoint = new CheckpointVerifier(
                        session.model, session.kernel);
                CheckpointVerifier.Snapshot end = checkpoint.verifyTransitions();
                CheckpointVerifier.Snapshot published = checkpoint.verifyPublication(end);
                new UnfoldProfileVerifier(
                        session.model, session.kernel, published, session.limits).verifyAll();
                return;
            }
            case FULL -> {
                CheckpointVerifier checkpoint = new CheckpointVerifier(
                        session.model, session.kernel);
                CheckpointVerifier.Snapshot end = checkpoint.verifyTransitions();
                CheckpointVerifier.Snapshot published = checkpoint.verifyPublication(end);
                new CanonicalProfileVerifier(
                        session.model, session.kernel, session.limits).verifyAllRecords();
                new UnfoldProfileVerifier(
                        session.model, session.kernel, published, session.limits).verifyAll();
                return;
            }
            case PAIR -> throw new IllegalArgumentException(
                    "PAIR is handled by verifyPair");
        }
    }

    private static PairEndpoint commonKernelEndpoint(Session session) {
        Wire.Node publication = session.bundle.publication();
        String rootId = publication.scalar(2);
        for (Wire.Node record : session.bundle.canonicalRecords().values()) {
            String orbitProofId = record.scalar(1);
            String replayProofId = record.child(0).scalar(0);
            KernelVerifier.Judgment replay = session.kernel.verify(replayProofId);
            KernelVerifier.Judgment orbit = session.kernel.verify(orbitProofId);
            if (!replay.left().id().equals(rootId)) {
                continue;
            }
            Wire.Node representativeKey = session.kernel.termOps()
                    .structuralNode(orbit.right());
            return new PairEndpoint(replay, orbit, orbit.right(), representativeKey);
        }
        throw new UncheckableException(
                FailureCode.MISSING_PAIR_DERIVATION,
                "Published root has no source-to-common-kernel derivation");
    }

    /** Prevents equal local IDs from disguising different per-bundle declarations. */
    private static void requireCompatibleVocabulary(
            KernelModel.Term left,
            KernelModel leftModel,
            KernelModel.Term right,
            KernelModel rightModel) {
        ArrayDeque<TermPair> work = new ArrayDeque<>();
        Set<String> visited = new HashSet<>();
        work.add(new TermPair(left, right));
        while (!work.isEmpty()) {
            TermPair pair = work.removeFirst();
            String visitKey = pair.left.id() + "\u0000" + pair.right.id();
            if (!visited.add(visitKey)) {
                continue;
            }
            if (pair.left.kind() != pair.right.kind()
                    || !pair.left.symbol().equals(pair.right.symbol())
                    || pair.left.children().size() != pair.right.children().size()) {
                throw new FormatException(
                        FailureCode.THEORY_MISMATCH,
                        "Common representative has incompatible term declarations");
            }
            switch (pair.left.kind()) {
                case APP -> requireEqualDeclaration(
                        leftModel.operator(pair.left.symbol()),
                        rightModel.operator(pair.right.symbol()),
                        "operator " + pair.left.symbol());
                case ONE_SLOT, ONE_TERM, SEQ, BAG, SET, BIND, BIND_BLOCK -> {
                    KernelModel.Schema leftSchema = leftModel.schema(pair.left.symbol());
                    KernelModel.Schema rightSchema = rightModel.schema(pair.right.symbol());
                    requireEqualDeclaration(
                            leftSchema, rightSchema, "schema " + pair.left.symbol());
                    if (pair.left.kind() == KernelModel.TermKind.BIND_BLOCK) {
                        requireEqualDeclaration(
                                leftModel.binder(leftSchema.value()),
                                rightModel.binder(rightSchema.value()),
                                "binder " + leftSchema.value());
                    }
                }
                case INVOKE -> {
                    KernelModel.Witness leftWitness = leftModel.witness(pair.left.symbol());
                    KernelModel.Witness rightWitness = rightModel.witness(pair.right.symbol());
                    if (!leftWitness.context().equals(rightWitness.context())
                            || !leftWitness.type().equals(rightWitness.type())) {
                        throw new FormatException(
                                FailureCode.THEORY_MISMATCH,
                                "Witness " + pair.left.symbol()
                                        + " has incompatible declarations");
                    }
                    work.add(new TermPair(
                            leftWitness.definition(), rightWitness.definition()));
                }
                default -> {
                    // SLOT, BOUND, and META carry no local declaration records.
                }
            }
            for (int index = 0; index < pair.left.children().size(); index++) {
                work.add(new TermPair(
                        leftModel.term(pair.left.children().get(index)),
                        rightModel.term(pair.right.children().get(index))));
            }
        }
    }

    private static void requireEqualDeclaration(
            Object left,
            Object right,
            String label) {
        if (!left.equals(right)) {
            throw new FormatException(
                    FailureCode.THEORY_MISMATCH,
                    "Common representative uses incompatible " + label);
        }
    }

    private record Session(
            Bundle bundle,
            KernelModel model,
            KernelVerifier kernel,
            Limits limits) {
    }

    private record PairEndpoint(
            KernelVerifier.Judgment replay,
            KernelVerifier.Judgment orbit,
            KernelModel.Term representative,
            Wire.Node representativeKey) {
    }

    private record TermPair(KernelModel.Term left, KernelModel.Term right) {
    }
}
