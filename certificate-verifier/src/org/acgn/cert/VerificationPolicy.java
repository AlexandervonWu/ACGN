package org.acgn.cert;

import java.util.Objects;
import java.util.Map;
import java.util.Set;

/** Caller-owned theory pin and explicit resource limits. */
public record VerificationPolicy(
        Set<String> trustedTheoryDigests,
        Limits limits,
        Map<String, String> trustedCallOccurrenceDigests) {
    public VerificationPolicy {
        trustedTheoryDigests = Set.copyOf(trustedTheoryDigests);
        Objects.requireNonNull(limits, "limits");
        trustedCallOccurrenceDigests = Map.copyOf(trustedCallOccurrenceDigests);
        if (trustedTheoryDigests.isEmpty()) {
            throw new IllegalArgumentException("At least one trusted theory digest is required");
        }
        for (Map.Entry<String, String> entry : trustedCallOccurrenceDigests.entrySet()) {
            new CallOccurrenceCommitment(entry.getKey(), entry.getValue());
        }
    }

    public VerificationPolicy(Set<String> trustedTheoryDigests, Limits limits) {
        this(trustedTheoryDigests, limits, Map.of());
    }

    public static VerificationPolicy trust(String digest) {
        return new VerificationPolicy(Set.of(digest), Limits.defaults(), Map.of());
    }

    public VerificationPolicy withCallOccurrenceCommitment(
            CallOccurrenceCommitment commitment) {
        Objects.requireNonNull(commitment, "commitment");
        Map<String, String> next = new java.util.LinkedHashMap<>(
                trustedCallOccurrenceDigests);
        String prior = next.putIfAbsent(
                commitment.subjectDigest(), commitment.occurrenceDigest());
        if (prior != null && !prior.equals(commitment.occurrenceDigest())) {
            throw new IllegalArgumentException(
                    "Conflicting CALL occurrence commitments for one input hash");
        }
        return new VerificationPolicy(trustedTheoryDigests, limits, next);
    }
}
