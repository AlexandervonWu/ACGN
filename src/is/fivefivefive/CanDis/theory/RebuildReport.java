package is.fivefivefive.CanDis.theory;

/** Immutable accounting for one finite, rewrite-disabled rebuild fixed point. */
public final class RebuildReport {
    private final int processedRecords;
    private final int changedKeys;
    private final int collisions;
    private final int certifiedUnions;
    private final int maximumDirtyRecords;

    RebuildReport(
            int processedRecords,
            int changedKeys,
            int collisions,
            int certifiedUnions,
            int maximumDirtyRecords) {
        this.processedRecords = processedRecords;
        this.changedKeys = changedKeys;
        this.collisions = collisions;
        this.certifiedUnions = certifiedUnions;
        this.maximumDirtyRecords = maximumDirtyRecords;
    }

    public int processedRecords() {
        return processedRecords;
    }

    public int changedKeys() {
        return changedKeys;
    }

    public int collisions() {
        return collisions;
    }

    public int certifiedUnions() {
        return certifiedUnions;
    }

    public int maximumDirtyRecords() {
        return maximumDirtyRecords;
    }

    @Override
    public String toString() {
        return "rebuild(processed=" + processedRecords
                + ", changed=" + changedKeys
                + ", collisions=" + collisions
                + ", unions=" + certifiedUnions
                + ", maxDirty=" + maximumDirtyRecords + ")";
    }
}
