package org.acgn.cert;

import java.util.Objects;
import java.util.Set;

/** Caller-owned theory pin and explicit resource limits. */
public record VerificationPolicy(Set<String> trustedTheoryDigests, Limits limits) {
    public VerificationPolicy {
        trustedTheoryDigests = Set.copyOf(trustedTheoryDigests);
        Objects.requireNonNull(limits, "limits");
        if (trustedTheoryDigests.isEmpty()) {
            throw new IllegalArgumentException("At least one trusted theory digest is required");
        }
    }

    public static VerificationPolicy trust(String digest) {
        return new VerificationPolicy(Set.of(digest), Limits.defaults());
    }
}
