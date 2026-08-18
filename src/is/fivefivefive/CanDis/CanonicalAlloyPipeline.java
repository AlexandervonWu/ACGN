package is.fivefivefive.CanDis;

import java.util.Objects;

import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.adapter.TheoryAlloyAdapter;
import is.fivefivefive.CanDis.canonical.CanonicalObservation;
import is.fivefivefive.CanDis.canonical.CanonicalRepresentativeTreeDistance;
import is.fivefivefive.CanDis.metric.QuotientRepairDistance;
import is.fivefivefive.CanDis.metric.RepairProjection;
import is.fivefivefive.CanDis.metric.RepairView;
import is.fivefivefive.CanDis.theory.CertifiedSemanticArtifact;
import is.fivefivefive.CanDis.theory.CertificateExportSession;
import is.fivefivefive.CanDis.theory.RecordingCertificateTraceSink;

/**
 * Three-layer Alloy boundary: certified semantics, canonical equality, and the
 * established repair metric evaluated over certified admissible alignments.
 * Canonical representative TED remains available only as an explicitly named
 * diagnostic baseline.
 */
public final class CanonicalAlloyPipeline {
    public static final String PIPELINE_VERSION = "canonical-alloy-pipeline-v10-three-layer";
    public static final String MEASUREMENT_PROJECTION_VERSION = RepairProjection.VERSION;
    public static final String REPRESENTATIVE_TED_VERSION =
            CanonicalRepresentativeTreeDistance.VERSION;
    public static final String QUOTIENT_METRIC_VERSION = QuotientRepairDistance.VERSION;

    private CanonicalAlloyPipeline() {
    }

    public static Prepared prepare(Multigraph graph) {
        return prepare(Canonical.prepare(graph));
    }

    public static Prepared prepare(Canonical.Prepared normalized) {
        Objects.requireNonNull(normalized, "normalized");
        TheoryAlloyAdapter.Result result = TheoryAlloyAdapter.adapt(
                normalized.normalizedForms());
        return new Prepared(normalized, result);
    }

    /**
     * Explicit proof-retaining preparation. Callers must export before using
     * {@link Prepared#compactForComparison()}.
     */
    public static Prepared prepareForVerification(Multigraph graph) {
        return prepareForVerification(Canonical.prepare(graph));
    }

    public static Prepared prepareForVerification(Canonical.Prepared normalized) {
        Objects.requireNonNull(normalized, "normalized");
        RecordingCertificateTraceSink sink = new RecordingCertificateTraceSink();
        String commit = System.getProperty("acgn.producer.commit", "unrecorded");
        boolean dirty = Boolean.parseBoolean(
                System.getProperty("acgn.producer.dirty", "true"));
        TheoryAlloyAdapter.Result result = TheoryAlloyAdapter.adaptForVerification(
                normalized.normalizedForms(), sink, commit, dirty);
        return new Prepared(normalized, result);
    }

    /**
     * Primary repair metric. Its geometry is specified by CanonicalDistance;
     * faithful certificates replace the legacy structural assumptions.
     */
    public static int distance(Prepared left, Prepared right) {
        return distanceEvaluation(left, right).distance();
    }

    public static QuotientRepairDistance.Result distanceEvaluation(
            Prepared left,
            Prepared right) {
        requirePrepared(left, right);
        return QuotientRepairDistance.enforceCertifiedKernel(
                QuotientRepairDistance.evaluate(left.repairView, right.repairView),
                left.observation.equivalentTo(right.observation));
    }

    /** Diagnostic baseline retained to expose canonical-representative discontinuity. */
    public static int canonicalRepresentativeTreeDistance(Prepared left, Prepared right) {
        requirePrepared(left, right);
        return CanonicalRepresentativeTreeDistance.distance(
                left.observation, right.observation);
    }

    private static void requirePrepared(Prepared left, Prepared right) {
        Objects.requireNonNull(left, "left");
        Objects.requireNonNull(right, "right");
    }

    public static final class Prepared {
        private final CertifiedSemanticArtifact semanticArtifact;
        private final CanonicalObservation observation;
        private final RepairView repairView;
        private final int representativeTreeSize;
        private final int repairObservationSize;
        private final long eclasses;
        private final long enodes;
        private final long slots;
        private final long rebuilds;
        private final long estimatedBytes;
        private final long constructionNanos;
        private final long unfoldingNanos;
        private final long observationNanos;
        private final long repairProjectionNanos;
        private final CertificateExportSession exportSession;

        private Prepared(
                Canonical.Prepared normalized,
                TheoryAlloyAdapter.Result result) {
            semanticArtifact = result.semanticArtifact();
            observation = new CanonicalObservation(result.canonicalKey());
            representativeTreeSize = CanonicalRepresentativeTreeDistance.size(observation);
            long projectionStarted = System.nanoTime();
            repairView = RepairProjection.project(
                    semanticArtifact,
                    normalized.normalizedForms(),
                    result.phaseBinderDescriptors(),
                    result.phaseSourceCoordinates(),
                    result.localBinderDescriptors(),
                    result.localBinderSourceCoordinates(),
                    observation.digest());
            repairProjectionNanos = System.nanoTime() - projectionStarted;
            exportSession = result.retainsCertificateExportSession()
                    ? result.certificateExportSession() : null;
            repairObservationSize = repairView.semanticSize();
            eclasses = result.eclasses();
            enodes = result.enodes();
            slots = result.slots();
            rebuilds = result.rebuilds();
            estimatedBytes = result.estimatedBytes();
            constructionNanos = result.constructionNanos();
            unfoldingNanos = result.unfoldingNanos();
            observationNanos = result.observationNanos();
        }

        private Prepared(Prepared source) {
            semanticArtifact = null;
            observation = source.observation;
            repairView = source.repairView;
            representativeTreeSize = source.representativeTreeSize;
            repairObservationSize = source.repairObservationSize;
            eclasses = source.eclasses;
            enodes = source.enodes;
            slots = source.slots;
            rebuilds = source.rebuilds;
            estimatedBytes = source.estimatedBytes;
            constructionNanos = source.constructionNanos;
            unfoldingNanos = source.unfoldingNanos;
            observationNanos = source.observationNanos;
            repairProjectionNanos = source.repairProjectionNanos;
            exportSession = null;
        }

        public CertifiedSemanticArtifact semanticArtifact() {
            if (semanticArtifact == null) {
                throw new IllegalStateException(
                        "The compact comparison representation does not retain the construction artifact");
            }
            return semanticArtifact;
        }

        /** Whether this value still owns the proof-heavy construction artifact. */
        public boolean retainsSemanticArtifact() {
            return semanticArtifact != null;
        }

        public boolean retainsCertificateExportSession() {
            return exportSession != null;
        }

        public CertificateExportSession certificateExportSession() {
            if (exportSession == null) {
                throw new IllegalStateException(
                        "This value was not prepared through prepareForVerification, "
                                + "or it has been compacted");
            }
            return exportSession;
        }

        /**
         * Drops construction-only graph witnesses after their certified observation and
         * repair projection have been produced. Equality and every distance operation are
         * unchanged; callers needing certificate replay must retain the original value.
         */
        public Prepared compactForComparison() {
            return semanticArtifact == null ? this : new Prepared(this);
        }

        public CanonicalObservation canonicalObservation() {
            return observation;
        }

        public RepairView repairView() {
            return repairView;
        }

        /** Size of the established metric's certified repair observation. */
        public int repairObservationSize() {
            return repairObservationSize;
        }

        /** Size of the diagnostic canonical-representative TED tree. */
        public int representativeTreeSize() {
            return representativeTreeSize;
        }

        /**
         * Compatibility alias for the former exact measurement size. New
         * repair-distance normalization must use {@link #repairObservationSize()}.
         */
        public int representationSize() {
            return representativeTreeSize;
        }

        public long eclassCount() {
            return eclasses;
        }

        public long enodeCount() {
            return enodes;
        }

        public long slotCount() {
            return slots;
        }

        public long rebuildCount() {
            return rebuilds;
        }

        public long estimatedBytes() {
            return estimatedBytes;
        }

        public long constructionNanos() {
            return constructionNanos;
        }

        public long unfoldingNanos() {
            return unfoldingNanos;
        }

        public long observationNanos() {
            return observationNanos;
        }

        public long repairProjectionNanos() {
            return repairProjectionNanos;
        }

        public String digest() {
            return observation.digest();
        }

        public String stableForm() {
            return observation.stableForm();
        }

        /** Stable diagnostic projection consumed only by representative TED. */
        public String measurementForm() {
            return CanonicalRepresentativeTreeDistance.projection(observation).stableString();
        }

        public boolean equivalentTo(Prepared other) {
            return other != null && observation.equivalentTo(other.observation);
        }
    }
}
