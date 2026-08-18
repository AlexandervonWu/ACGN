package is.fivefivefive.CanDis.theory;

import java.util.Objects;

/** One ordered transition appended only after producer invariants hold. */
public final class CertificateTraceEvent {
    public enum Kind {
        INSERT_FRESH,
        INSERT_COLLISION,
        UNION,
        ADD_SYMMETRY,
        RESTRICT_INTERFACE,
        PATH_COMPRESSION,
        REBUILD_RECORD,
        REBUILD_COMPLETE
    }

    private final long sequence;
    private final Kind kind;
    private final CertificateTraceSnapshot before;
    private final CertificateTraceSnapshot after;
    private final CertificateTracePayload payload;

    public CertificateTraceEvent(
            long sequence,
            Kind kind,
            CertificateTraceSnapshot before,
            CertificateTraceSnapshot after,
            CertificateTracePayload payload) {
        if (sequence < 0) {
            throw new IllegalArgumentException("Negative trace sequence");
        }
        this.sequence = sequence;
        this.kind = Objects.requireNonNull(kind, "kind");
        this.before = Objects.requireNonNull(before, "before");
        this.after = Objects.requireNonNull(after, "after");
        this.payload = Objects.requireNonNull(payload, "payload");
    }

    public long sequence() {
        return sequence;
    }

    public Kind kind() {
        return kind;
    }

    public CertificateTraceSnapshot before() {
        return before;
    }

    public CertificateTraceSnapshot after() {
        return after;
    }

    public CertificateTracePayload payload() {
        return payload;
    }
}
