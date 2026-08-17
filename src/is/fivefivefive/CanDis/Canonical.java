package is.fivefivefive.CanDis;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.core.CanonicalDistance;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.ir.IRAgent;

/** Alloy/MASG adapter for the parser-independent canonical-distance core. */
public final class Canonical {
    private Canonical() {
    }

    public static int distance(Multigraph left, Multigraph right) {
        return distance(prepare(left), prepare(right));
    }

    public static int distance(Prepared left, Prepared right) {
        return CanonicalDistance.distance(left.delegate, right.delegate);
    }

    public static List<String> edits(Multigraph left, Multigraph right) {
        return edits(prepare(left), prepare(right));
    }

    public static List<String> edits(Prepared left, Prepared right) {
        return CanonicalDistance.edits(left.delegate, right.delegate);
    }

    public static List<String> irTemporalFol(Multigraph graph) {
        return irTemporalFol(prepare(graph));
    }

    public static List<String> irTemporalFol(Prepared prepared) {
        return CanonicalDistance.irTemporalFol(prepared.delegate);
    }

    public static int canonicalFormSize(Multigraph graph) {
        return canonicalFormSize(prepare(graph));
    }

    public static int canonicalFormSize(Prepared prepared) {
        return CanonicalDistance.canonicalFormSize(prepared.delegate);
    }

    public static long eclassCount(Prepared prepared) {
        return prepared.delegate.eclassCount();
    }

    public static long enodeCount(Prepared prepared) {
        return prepared.delegate.enodeCount();
    }

    public static Prepared prepare(Multigraph graph) {
        if (graph == null) {
            throw new IllegalArgumentException("Multigraph cannot be null");
        }
        IRAgent agent = new IRAgent(graph);
        agent.computeNormalForm();
        List<NormalForm> normalized = Collections.unmodifiableList(
                new ArrayList<>(agent.normalForms()));
        return new Prepared(CanonicalDistance.prepare(normalized), normalized);
    }

    /** Compatibility wrapper that keeps Alloy-specific code out of the core API. */
    public static final class Prepared {
        private final CanonicalDistance.Prepared delegate;
        private final List<NormalForm> normalizedForms;

        private Prepared(
                CanonicalDistance.Prepared delegate,
                List<NormalForm> normalizedForms) {
            this.delegate = delegate;
            this.normalizedForms = normalizedForms;
        }

        List<NormalForm> normalizedForms() {
            return normalizedForms;
        }
    }
}
