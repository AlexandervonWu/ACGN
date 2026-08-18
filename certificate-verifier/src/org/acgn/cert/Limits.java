package org.acgn.cert;

/** Explicit resource bounds; exhaustion is UNCHECKABLE rather than success. */
public record Limits(
        int maxBundleBytes,
        int maxStringBytes,
        int maxNodes,
        int maxDepth,
        int maxTableEntries,
        long maxOrbitMembers,
        int maxUnfoldNodes) {
    public Limits {
        if (maxBundleBytes <= 0 || maxStringBytes <= 0 || maxNodes <= 0
                || maxDepth <= 0 || maxTableEntries <= 0
                || maxOrbitMembers <= 0 || maxUnfoldNodes <= 0) {
            throw new IllegalArgumentException("All verifier limits must be positive");
        }
    }

    public static Limits defaults() {
        return new Limits(
                256 * 1024 * 1024,
                8 * 1024 * 1024,
                5_000_000,
                512,
                1_000_000,
                2_000_000,
                5_000_000);
    }
}
