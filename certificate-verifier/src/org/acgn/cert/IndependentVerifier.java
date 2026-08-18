package org.acgn.cert;

import java.util.Map;
import java.util.Objects;

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
}
