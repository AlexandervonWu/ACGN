package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.NavigableMap;
import java.util.Objects;
import java.util.TreeMap;

/** Graph-owned Phase D realization of the typed state {@code G=(U,M,H)}. */
public final class TypedSlottedPortEGraph {
    private static final String ENGINE_IDENTIFIER = "typed-slotted-port-egraph";
    private final NavigableMap<EClassId, TypedEClassRecord> classes = new TreeMap<>();
    private final TypedRenamedUnionFind unionFind = new TypedRenamedUnionFind();
    private final NavigableMap<CanonicalShape, EClassId> hashCons = new TreeMap<>();
    private GraphStatus status = GraphStatus.QUIESCENT;

    public TypedSlottedPortEGraph() {
    }

    public String engineIdentifier() {
        return ENGINE_IDENTIFIER;
    }

    public String canonicalizerVersion() {
        return ProductionGraphCanonicalizer.VERSION;
    }

    /**
     * Phase D setup primitive. Phase F insertion will be the only graph path
     * allowed to call it after constructing the corresponding certificates.
     */
    synchronized void registerRecordForPhaseD(TypedEClassRecord record) {
        Objects.requireNonNull(record, "record");
        if (status != GraphStatus.QUIESCENT) {
            throw new IllegalStateException("Cannot register a setup record in a dirty graph");
        }
        if (classes.containsKey(record.id())) {
            throw new IllegalArgumentException("Duplicate e-class id: " + record.id());
        }
        validateStoredInvocations(record);
        for (CanonicalShape shape : record.shapeWitnesses().keySet()) {
            EClassId owner = hashCons.get(shape);
            if (owner != null) {
                throw new IllegalArgumentException(
                        "Two quiescent leaders cannot own the same canonical shape: " + owner);
            }
        }

        unionFind.register(record.interfaceView());
        classes.put(record.id(), record);
        for (CanonicalShape shape : record.shapeWitnesses().keySet()) {
            hashCons.put(shape, record.id());
        }
        checkInvariants();
    }

    /** Package-private raw link used only to discharge the Phase D algebra gate. */
    synchronized void linkLeadersForPhaseD(ParentStep step) {
        Objects.requireNonNull(step, "step");
        requireRecord(step.child());
        requireRecord(step.parent());
        unionFind.linkRoots(step);
        status = GraphStatus.DIRTY;
        checkInvariants();
    }

    public synchronized TypedFindResult findWithProvenance(TypedInvocation invocation) {
        requireRecord(Objects.requireNonNull(invocation, "invocation").eclass());
        TypedFindResult result = unionFind.findWithProvenance(invocation);
        checkInvariants();
        return result;
    }

    /** Canonicalizes one exact-support flat node against this quiescent graph. */
    public synchronized CanonicalizationResult canonicalize(TypedENode node) {
        return ProductionGraphCanonicalizer.instance().canonicalize(this, node);
    }

    synchronized TypedFindResult findWithoutCompressionForTesting(TypedInvocation invocation) {
        requireRecord(Objects.requireNonNull(invocation, "invocation").eclass());
        return unionFind.findWithoutCompression(invocation);
    }

    public synchronized TypedEClassRecord eclass(EClassId id) {
        TypedEClassRecord record = classes.get(Objects.requireNonNull(id, "id"));
        if (record == null) {
            throw new IllegalArgumentException("Unknown e-class id: " + id);
        }
        return record;
    }

    public synchronized Map<EClassId, TypedEClassRecord> classes() {
        return Collections.unmodifiableMap(new LinkedHashMap<>(classes));
    }

    public synchronized Map<EClassId, ParentAssignment> parentAssignments() {
        return unionFind.assignments();
    }

    public synchronized boolean isLeader(EClassId id) {
        eclass(id);
        return unionFind.isLeader(id);
    }

    public synchronized GraphStatus status() {
        return status;
    }

    synchronized void requireQuiescentForCanonicalization() {
        requireQuiescent();
    }

    synchronized TypedFindResult findForCanonicalization(TypedInvocation invocation) {
        requireQuiescent();
        requireRecord(Objects.requireNonNull(invocation, "invocation").eclass());
        return unionFind.findWithProvenance(invocation);
    }

    /**
     * Closes an empty-shape test fixture after raw Phase D parent setup. This is
     * deliberately not a rebuild substitute and cannot publish stored shapes.
     */
    synchronized void sealEmptyShapeFixtureForPhaseE() {
        for (TypedEClassRecord record : classes.values()) {
            if (!record.shapeWitnesses().isEmpty()) {
                throw new IllegalStateException(
                        "Only an empty-shape fixture may use the Phase E setup seal");
            }
        }
        if (!hashCons.isEmpty()) {
            throw new IllegalStateException("An empty-shape fixture must have an empty hash-cons");
        }
        status = GraphStatus.QUIESCENT;
        checkInvariants();
    }

    public synchronized EClassId hashOwner(CanonicalShape shape) {
        requireQuiescent();
        return hashCons.get(Objects.requireNonNull(shape, "shape"));
    }

    public synchronized Map<CanonicalShape, EClassId> hashConsSnapshot() {
        requireQuiescent();
        return Collections.unmodifiableMap(new LinkedHashMap<>(hashCons));
    }

    public synchronized StructuralKey stateStructuralKey() {
        List<StructuralKey> children = new ArrayList<>();
        children.add(StructuralKey.leaf("graph-status", status.name()));
        for (TypedEClassRecord record : classes.values()) {
            children.add(record.structuralKey());
        }
        for (ParentAssignment assignment : unionFind.assignments().values()) {
            children.add(assignment.structuralKey());
        }
        for (Map.Entry<CanonicalShape, EClassId> entry : hashCons.entrySet()) {
            children.add(StructuralKey.of(
                    "hash-owner",
                    Collections.singletonList(Long.toString(entry.getValue().value())),
                    Collections.singletonList(entry.getKey().structuralKey())));
        }
        return StructuralKey.branch("typed-slotted-port-egraph", children);
    }

    public synchronized void checkInvariants() {
        unionFind.checkInvariants();
        if (!classes.keySet().equals(unionFind.interfaces().keySet())) {
            throw new IllegalStateException("U and M have different e-class domains");
        }
        for (Map.Entry<EClassId, TypedEClassRecord> entry : classes.entrySet()) {
            if (!entry.getKey().equals(entry.getValue().id())) {
                throw new IllegalStateException("E-class record is stored under the wrong id");
            }
            TypedEClassInterface registered = unionFind.interfaces().get(entry.getKey());
            if (!entry.getValue().interfaceView().equals(registered)) {
                throw new IllegalStateException("U and M disagree on an e-class interface");
            }
            validateStoredInvocationsState(entry.getValue());
        }
        if (status == GraphStatus.QUIESCENT) {
            NavigableMap<CanonicalShape, EClassId> expected = new TreeMap<>();
            for (TypedEClassRecord record : classes.values()) {
                if (!unionFind.isLeader(record.id())) {
                    continue;
                }
                for (CanonicalShape shape : record.shapeWitnesses().keySet()) {
                    EClassId prior = expected.putIfAbsent(shape, record.id());
                    if (prior != null && !prior.equals(record.id())) {
                        throw new IllegalStateException(
                                "Two leaders own one canonical shape at quiescence");
                    }
                }
            }
            if (!expected.equals(hashCons)) {
                throw new IllegalStateException(
                        "Quiescent hash-cons does not exactly match leader-owned shapes");
            }
        }
    }

    private void requireQuiescent() {
        if (status != GraphStatus.QUIESCENT) {
            throw new IllegalStateException(
                    "Canonical hash-cons queries require a quiescent graph");
        }
    }

    private void requireRecord(TypedEClassInterface eclass) {
        TypedEClassRecord record = classes.get(eclass.id());
        if (record == null) {
            throw new IllegalArgumentException("Unknown e-class id: " + eclass.id());
        }
        if (!record.interfaceView().equals(eclass)) {
            throw new IllegalArgumentException(
                    "E-class metadata differs from the graph-owned record");
        }
    }

    private void validateStoredInvocations(TypedEClassRecord record) {
        for (CanonicalShape shape : record.shapeWitnesses().keySet()) {
            for (PortValue port : shape.node().ports()) {
                validatePortInvocations(port, false);
            }
        }
    }

    private void validateStoredInvocationsState(TypedEClassRecord record) {
        for (CanonicalShape shape : record.shapeWitnesses().keySet()) {
            for (PortValue port : shape.node().ports()) {
                validatePortInvocations(port, true);
            }
        }
    }

    private void validatePortInvocations(PortValue port, boolean invariantCheck) {
        if (port instanceof OnePort) {
            PortLeaf leaf = ((OnePort) port).leaf();
            if (leaf instanceof InvocationPortLeaf) {
                TypedEClassInterface target = ((InvocationPortLeaf) leaf)
                        .invocation().eclass();
                if (invariantCheck) {
                    try {
                        requireRecord(target);
                    } catch (IllegalArgumentException exception) {
                        throw new IllegalStateException(
                                "Stored shape references missing or stale e-class metadata",
                                exception);
                    }
                } else {
                    requireRecord(target);
                }
            }
            return;
        }
        if (port instanceof SeqPort) {
            for (PortValue element : ((SeqPort) port).elements()) {
                validatePortInvocations(element, invariantCheck);
            }
        } else if (port instanceof BagPort) {
            for (PortValue element : ((BagPort) port).occurrences()) {
                validatePortInvocations(element, invariantCheck);
            }
        } else if (port instanceof SetPort) {
            for (PortValue element : ((SetPort) port).elements()) {
                validatePortInvocations(element, invariantCheck);
            }
        } else {
            validatePortInvocations(((BindPort) port).body(), invariantCheck);
        }
    }
}
