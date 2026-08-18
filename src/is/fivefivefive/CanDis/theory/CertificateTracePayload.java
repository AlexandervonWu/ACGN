package is.fivefivefive.CanDis.theory;

import java.util.Objects;

/** Closed producer-side payloads retained until independent export. */
public sealed interface CertificateTracePayload permits
        CertificateTracePayload.Insertion,
        CertificateTracePayload.Union,
        CertificateTracePayload.Symmetry,
        CertificateTracePayload.Restriction,
        CertificateTracePayload.PathCompression,
        CertificateTracePayload.RebuildRecord,
        CertificateTracePayload.RebuildComplete {

    record Insertion(CertifiedInsertionResult result) implements CertificateTracePayload {
        public Insertion {
            Objects.requireNonNull(result, "result");
        }
    }

    record Union(ParentEdgeCertificate certificate) implements CertificateTracePayload {
        public Union {
            Objects.requireNonNull(certificate, "certificate");
        }
    }

    record Symmetry(EClassId eclass, SymmetryCertificate certificate)
            implements CertificateTracePayload {
        public Symmetry {
            Objects.requireNonNull(eclass, "eclass");
            Objects.requireNonNull(certificate, "certificate");
        }
    }

    record Restriction(InterfaceRestrictionCertificate certificate)
            implements CertificateTracePayload {
        public Restriction {
            Objects.requireNonNull(certificate, "certificate");
        }
    }

    record PathCompression(TypedFindResult result) implements CertificateTracePayload {
        public PathCompression {
            Objects.requireNonNull(result, "result");
        }
    }

    record RebuildRecord(
            ParentRecordKey original,
            boolean changed,
            boolean collision,
            boolean union) implements CertificateTracePayload {
        public RebuildRecord {
            Objects.requireNonNull(original, "original");
        }
    }

    record RebuildComplete(RebuildReport report) implements CertificateTracePayload {
        public RebuildComplete {
            Objects.requireNonNull(report, "report");
        }
    }
}
