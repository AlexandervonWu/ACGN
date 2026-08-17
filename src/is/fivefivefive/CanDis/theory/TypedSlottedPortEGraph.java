package is.fivefivefive.CanDis.theory;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.NavigableMap;
import java.util.NavigableSet;
import java.util.Objects;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

/** Graph-owned typed state {@code G=(U,M,H)} with certified Phase G rebuilding. */
public final class TypedSlottedPortEGraph {
    private static final String ENGINE_IDENTIFIER = "typed-slotted-port-egraph";
    private final NavigableMap<EClassId, TypedEClassRecord> classes = new TreeMap<>();
    private final TypedRenamedUnionFind unionFind = new TypedRenamedUnionFind();
    private final NavigableMap<CanonicalShape, EClassId> hashCons = new TreeMap<>();
    private final NavigableMap<ParentRecordKey, TypedEqualityCertificate>
            shapeCertificates = new TreeMap<>();
    private final NavigableMap<EClassId, NavigableSet<ParentRecordKey>>
            parentUses = new TreeMap<>();
    private final NavigableSet<ParentRecordKey> dirtyParents = new TreeSet<>();
    private final NavigableMap<EClassId, List<InterfaceRestrictionCertificate>>
            restrictionHistory = new TreeMap<>();
    private final NavigableMap<EClassId, CertifiedInsertionResult>
            insertionHistory = new TreeMap<>();
    private final GraphCertificateMode certificateMode;
    private GraphStatus status = GraphStatus.QUIESCENT;
    private long coherenceRevision;
    private boolean rebuildActive;
    private ParentRecordKey rebuildingRecord;

    public TypedSlottedPortEGraph() {
        this(GraphCertificateMode.REQUIRED);
    }

    private TypedSlottedPortEGraph(GraphCertificateMode certificateMode) {
        this.certificateMode = Objects.requireNonNull(certificateMode, "certificateMode");
    }

    static TypedSlottedPortEGraph structuralFixture() {
        return new TypedSlottedPortEGraph(GraphCertificateMode.STRUCTURAL_FIXTURE);
    }

    public String engineIdentifier() {
        return ENGINE_IDENTIFIER;
    }

    public String canonicalizerVersion() {
        return ProductionGraphCanonicalizer.VERSION;
    }

    public String leaderKernelVersion() {
        return LeaderKernelExtractor.VERSION;
    }

    public String certificateVersion() {
        return CertificateVerifier.VERSION;
    }

    public String rebuildVersion() {
        return "typed-fixed-batch-rebuild-v1";
    }

    public GraphCertificateMode certificateMode() {
        return certificateMode;
    }

    /**
     * Phase D setup primitive retained only for structural gate fixtures; the
     * strict graph uses the certified insertion path below.
     */
    synchronized void registerRecordForPhaseD(TypedEClassRecord record) {
        requireStructuralFixture("Phase D record registration");
        registerRecord(record);
    }

    /** Empty-class setup for exercising the Phase F transition boundary before insertion. */
    synchronized void registerEmptyClassForPhaseF(TypedEClassInterface eclass) {
        if (certificateMode != GraphCertificateMode.REQUIRED) {
            throw new IllegalStateException(
                    "Phase F setup requires certificate-enforcing graph mode");
        }
        registerRecord(TypedEClassRecord.empty(
                Objects.requireNonNull(eclass, "eclass")));
        coherenceRevision = Math.incrementExact(coherenceRevision);
    }

    /**
     * Admits one already-flat record into a fixed batch with an exact equation
     * for every stored shape. This remains the fixed-batch counterpart of the
     * source-level insertion wrapper for witness-dependent {@code d_n^w}.
     */
    public synchronized void admitFixedBatchRecordCertified(
            TypedEClassRecord record,
            Map<CanonicalShape, ? extends TypedEqualityCertificate> certificates) {
        if (certificateMode != GraphCertificateMode.REQUIRED) {
            throw new IllegalStateException(
                    "Certified fixed-batch admission requires strict graph mode");
        }
        TypedEClassRecord checkedRecord = Objects.requireNonNull(record, "record");
        Objects.requireNonNull(certificates, "certificates");
        if (status != GraphStatus.QUIESCENT) {
            throw new IllegalStateException(
                    "A fixed-batch record can be admitted only between rebuild epochs");
        }
        if (!checkedRecord.shapeWitnesses().keySet().equals(certificates.keySet())) {
            throw new IllegalArgumentException(
                    "Certified admission requires exactly one equation per stored shape");
        }
        checkedRecord.symmetryGroup().requireCertifiedFor(
                checkedRecord.interfaceView());
        validateStoredInvocations(checkedRecord);
        for (CanonicalShape shape : checkedRecord.shapeWitnesses().keySet()) {
            requireCertifiedNodeTheory(shape.node());
            for (EClassId child : invocationIds(shape.node())) {
                if (!unionFind.isLeader(child)) {
                    throw new IllegalArgumentException(
                            "Fixed-batch admission is bottom-up and requires leader children");
                }
            }
            if (hashCons.containsKey(shape)) {
                throw new IllegalArgumentException(
                        "Use certified collision union instead of admitting a duplicate key");
            }
            EffectiveShapeCollisionCertificate.orientShapeEquation(
                    shape,
                    checkedRecord,
                    checkedRecord.shapeWitnesses().get(shape),
                    certificates.get(shape));
        }
        if (classes.containsKey(checkedRecord.id())) {
            throw new IllegalArgumentException(
                    "Duplicate e-class id: " + checkedRecord.id());
        }

        unionFind.register(checkedRecord.interfaceView());
        classes.put(checkedRecord.id(), checkedRecord);
        for (CanonicalShape shape : checkedRecord.shapeWitnesses().keySet()) {
            ParentRecordKey key = new ParentRecordKey(checkedRecord.id(), shape);
            shapeCertificates.put(key, EffectiveShapeCollisionCertificate.orientShapeEquation(
                    shape,
                    checkedRecord,
                    checkedRecord.shapeWitnesses().get(shape),
                    certificates.get(shape)));
            hashCons.put(shape, checkedRecord.id());
            indexRecord(key);
        }
        coherenceRevision = Math.incrementExact(coherenceRevision);
        checkInvariants();
    }

    private void registerRecord(TypedEClassRecord record) {
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
            indexRecord(new ParentRecordKey(record.id(), shape));
        }
        checkInvariants();
    }

    /** Package-private raw link used only to discharge the Phase D algebra gate. */
    synchronized void linkLeadersForPhaseD(ParentStep step) {
        requireStructuralFixture("Phase D leader linking");
        Objects.requireNonNull(step, "step");
        requireRecord(step.child());
        requireRecord(step.parent());
        unionFind.linkRoots(step);
        status = GraphStatus.DIRTY;
        checkInvariants();
    }

    /** Installs exactly one distinct-leader parent edge after checking its proof. */
    public synchronized ParentStep unionCertified(ParentEdgeCertificate certificate) {
        ParentEdgeCertificate checked = Objects.requireNonNull(
                certificate, "certificate");
        CertificateVerifier.verifyParentEdge(checked);
        requireRecord(checked.child());
        requireRecord(checked.parent());
        if (checked.child().id().equals(checked.parent().id())) {
            throw new IllegalArgumentException(
                    "A same-leader equation is not a union or an automatic symmetry");
        }
        if (!unionFind.isLeader(checked.child().id())
                || !unionFind.isLeader(checked.parent().id())) {
            throw new IllegalArgumentException(
                    "Certified union endpoints must be current distinct leaders");
        }
        ParentStep step = unionCertifiedInternal(checked);
        coherenceRevision = Math.incrementExact(coherenceRevision);
        checkInvariants();
        return step;
    }

    /** Adds one separately certified generator; endpoint equality alone is insufficient. */
    public synchronized boolean addSymmetryCertified(
            EClassId leaderId,
            SymmetryCertificate certificate) {
        TypedEClassRecord record = eclass(Objects.requireNonNull(leaderId, "leaderId"));
        SymmetryCertificate checked = Objects.requireNonNull(certificate, "certificate");
        CertificateVerifier.verifySymmetry(checked);
        if (!unionFind.isLeader(leaderId)) {
            throw new IllegalArgumentException(
                    "Only a current leader may receive a symmetry generator");
        }
        if (!record.interfaceView().equals(checked.eclass())) {
            throw new IllegalArgumentException(
                    "Symmetry certificate names a different graph e-class");
        }
        TypedSymmetryGroup current = record.symmetryGroup();
        current.requireCertifiedFor(record.interfaceView());
        if (current.contains(checked.inducedPermutation())) {
            return false;
        }
        TypedSymmetryGroup updated = current.withCertifiedGenerator(
                record.interfaceView(), checked);
        classes.put(leaderId, record.withSymmetryGroup(updated));
        markParentsDirty(leaderId);
        status = GraphStatus.DIRTY;
        coherenceRevision = Math.incrementExact(coherenceRevision);
        checkInvariants();
        return true;
    }

    /** Checks restriction provenance without performing the Phase G transport transaction. */
    public synchronized void verifyInterfaceRestriction(
            InterfaceRestrictionCertificate certificate) {
        InterfaceRestrictionCertificate checked = Objects.requireNonNull(
                certificate, "certificate");
        CertificateVerifier.verifyInterfaceRestriction(checked);
        TypedEClassRecord record = eclass(checked.originalInterface().id());
        if (!record.interfaceView().equals(checked.originalInterface())) {
            throw new IllegalArgumentException(
                    "Restriction certificate uses stale e-class metadata");
        }
        if (!record.shapeWitnesses().keySet().equals(
                    checked.transportedShapeWitnesses().keySet())) {
            throw new IllegalArgumentException(
                    "Restriction certificate does not transport every stored shape");
        }
        for (Map.Entry<CanonicalShape, ShapeWitness> entry
                : record.shapeWitnesses().entrySet()) {
            ShapeWitness original = entry.getValue();
            ShapeWitness transported = checked.transportedShapeWitnesses().get(
                    entry.getKey());
            if (transported == null
                    || !transported.exactSlots().equals(original.exactSlots())
                    || !transported.ambientSupport().equals(original.ambientSupport())
                    || !transported.instantiatingRenaming().equals(
                            original.instantiatingRenaming())
                    || !transported.exposedInterface().equals(
                            checked.restrictedInterface().exposedSlots())) {
                throw new IllegalArgumentException(
                        "Restriction certificate changes a stored shape witness");
            }
        }
    }

    /** Performs the sole atomic interface-narrowing transition. */
    public synchronized void restrictInterfaceCertified(
            InterfaceRestrictionCertificate certificate) {
        if (certificateMode != GraphCertificateMode.REQUIRED) {
            throw new IllegalStateException(
                    "Interface restriction requires strict certificate mode");
        }
        InterfaceRestrictionCertificate checked = Objects.requireNonNull(
                certificate, "certificate");
        verifyInterfaceRestriction(checked);
        TypedEClassRecord originalRecord = eclass(checked.originalInterface().id());
        if (!unionFind.isLeader(originalRecord.id())) {
            throw new IllegalArgumentException(
                    "Only a current leader interface may be restricted");
        }

        TypedSymmetryGroup restrictedGroup = restrictSymmetryGroup(
                originalRecord, checked);
        NavigableMap<CanonicalShape, ShapeWitness> transportedWitnesses =
                new TreeMap<>(checked.transportedShapeWitnesses());
        NavigableMap<ParentRecordKey, TypedEqualityCertificate> transportedEquations =
                new TreeMap<>();
        for (Map.Entry<CanonicalShape, ShapeWitness> entry
                : originalRecord.shapeWitnesses().entrySet()) {
            ParentRecordKey key = new ParentRecordKey(originalRecord.id(), entry.getKey());
            TypedEqualityCertificate oldEquation = requireShapeCertificate(key);
            TypedEmbedding oldInterfaceInAmbient = TypedEmbedding.inclusion(
                    originalRecord.exposedSlots(), entry.getValue().ambientSupport());
            TypedEqualityCertificate factorization = EqualityCertificates.rename(
                    checked.factorization(), oldInterfaceInAmbient);
            transportedEquations.put(key, EqualityCertificates.transitive(
                    oldEquation, factorization));
        }

        unionFind.restrictLeader(checked);
        TypedEClassRecord replacement = originalRecord.withInterfaceAndState(
                checked.restrictedInterface(),
                transportedWitnesses,
                restrictedGroup);
        classes.put(replacement.id(), replacement);
        shapeCertificates.putAll(transportedEquations);
        restrictionHistory.computeIfAbsent(
                replacement.id(), ignored -> new ArrayList<>()).add(checked);
        markParentsDirty(replacement.id());
        status = GraphStatus.DIRTY;
        coherenceRevision = Math.incrementExact(coherenceRevision);
        checkInvariants();
    }

    public synchronized TypedFindResult findWithProvenance(TypedInvocation invocation) {
        TypedFindResult result = findNormalized(
                Objects.requireNonNull(invocation, "invocation"), true);
        checkInvariants();
        return result;
    }

    /** Canonicalizes one exact-support flat node against this quiescent graph. */
    public synchronized CanonicalizationResult canonicalize(TypedENode node) {
        requireCertifiedNodeTheory(Objects.requireNonNull(node, "node"));
        return ProductionGraphCanonicalizer.instance().canonicalize(this, node);
    }

    /** Captures the compact EC/PC/SC witness family of one quiescent prefix. */
    public synchronized CoherentWitnessFamily coherentWitnessFamily() {
        if (certificateMode != GraphCertificateMode.REQUIRED) {
            throw new IllegalStateException(
                    "Coherent witnesses require the strict certificate graph");
        }
        requireQuiescent();
        checkInvariants();
        return CoherentWitnessFamily.capture(
                this,
                coherenceRevision,
                new LinkedHashMap<>(classes),
                unionFind.assignments(),
                new LinkedHashMap<>(shapeCertificates));
    }

    /** Opens a read-only bounded {@code Rep_G} oracle on one coherent prefix. */
    public synchronized BoundedFiniteUnfoldingOracle finiteUnfoldingOracle(
            CoherentWitnessFamily family,
            FiniteUnfoldingBounds bounds) {
        requireCurrentWitnessFamily(Objects.requireNonNull(family, "family"));
        return BoundedFiniteUnfoldingOracle.create(
                this, family, Objects.requireNonNull(bounds, "bounds"));
    }

    synchronized void requireCurrentWitnessFamily(CoherentWitnessFamily family) {
        if (certificateMode != GraphCertificateMode.REQUIRED) {
            throw new IllegalStateException(
                    "Witness-dependent replay requires strict certificate mode");
        }
        requireQuiescent();
        Objects.requireNonNull(family, "family").requireCurrent(
                this, coherenceRevision);
    }

    synchronized void requireFreshWitnessDefinition(
            TypedEClassInterface fresh,
            KernelReplayCertificate replay) {
        requireCurrentWitnessFamily(Objects.requireNonNull(
                replay, "replay").witnessFamily());
        TypedEClassInterface checked = Objects.requireNonNull(fresh, "fresh");
        if (classes.containsKey(checked.id())) {
            throw new IllegalArgumentException(
                    "A witness definition requires an unregistered e-class id");
        }
        if (!checked.outputType().equals(replay.leaderKernel().kernel().outputType())
                || !checked.exposedSlots().equals(
                        replay.leaderKernel().effectiveSupport())) {
            throw new IllegalArgumentException(
                    "A fresh witness must use the effective kernel type and interface");
        }
    }

    /** Runs the structural canonicalizer and separately replays {@code xi} to {@code d^w}. */
    public synchronized CertifiedCanonicalizationResult canonicalizeCertified(
            TypedENode node,
            CoherentWitnessFamily family) {
        requireCurrentWitnessFamily(Objects.requireNonNull(family, "family"));
        CanonicalizationResult structural = canonicalize(
                Objects.requireNonNull(node, "node"));
        KernelReplayCertificate replay = KernelReplayCertificate.create(
                this, family, structural.leaderKernel());
        return new CertifiedCanonicalizationResult(structural, replay);
    }

    /**
     * Bottom-up source/rewrite insertion through the coherent, certified
     * mutation boundary. A colliding key installs a certified parent edge and
     * leaves the ordinary Phase G dirty queue to {@link #rebuild()}.
     */
    public synchronized CertifiedInsertionResult insertNode(
            TypedENode node,
            CoherentWitnessFamily family) {
        TypedENode source = Objects.requireNonNull(node, "node");
        requireCurrentWitnessFamily(Objects.requireNonNull(family, "family"));
        requireCertifiedNodeTheory(source);
        for (PortValue port : source.ports()) {
            validatePortInvocations(port, false);
        }

        CertifiedCanonicalizationResult certified = canonicalizeCertified(
                source, family);
        CanonicalizationResult structural = certified.structural();
        EClassId freshId = nextEClassId();
        TypedEClassInterface fresh = new TypedEClassInterface(
                freshId,
                source.outputType(),
                structural.effectiveSupport());
        CanonicalOrbitCertificate orbit = CanonicalOrbitCertificate.create(
                this, family, structural);
        FreshWitnessDefinitionCertificate definition =
                FreshWitnessDefinitionCertificate.create(
                        this, structural.kernel(), fresh, certified.d());
        TypedEqualityCertificate shapeEquation = EqualityCertificates.transitive(
                orbit, definition);
        ShapeWitness shapeWitness = new ShapeWitness(
                structural.shape().exactSlots(),
                structural.effectiveSupport(),
                fresh.exposedSlots(),
                structural.witness());
        TypedEClassRecord freshRecord = TypedEClassRecord.of(
                fresh,
                Collections.singletonMap(structural.shape(), shapeWitness),
                TypedSymmetryGroup.identity(fresh.exposedSlots()));
        shapeEquation = EffectiveShapeCollisionCertificate.orientShapeEquation(
                structural.shape(), freshRecord, shapeWitness, shapeEquation);
        CertificateVerifier.verify(shapeEquation);

        TypedEqualityCertificate sourceToFresh = EqualityCertificates.transitive(
                certified.d(),
                EqualityCertificates.rename(definition, structural.inclusion()));
        TypedInvocation freshInSource = new TypedInvocation(
                fresh, structural.inclusion());
        sourceToFresh = EqualityCertificates.orient(
                sourceToFresh,
                TypedCertificateEndpoint.node(source),
                TypedCertificateEndpoint.invocation(freshInSource));
        CertificateVerifier.verify(sourceToFresh);

        EClassId existingOwner = hashCons.get(structural.shape());
        ParentEdgeCertificate collision = null;
        if (existingOwner != null) {
            TypedEClassRecord existing = eclass(existingOwner);
            collision = collisionParentEdge(
                    structural.shape(),
                    freshRecord,
                    shapeEquation,
                    existing,
                    requireShapeCertificate(new ParentRecordKey(
                            existing.id(), structural.shape())));
        }

        TypedInvocation expectedReturned = freshInSource;
        TypedEqualityCertificate expectedSourceToReturned = sourceToFresh;
        if (collision != null && collision.child().equals(fresh)) {
            expectedReturned = collision.parentInvocation().act(
                    structural.inclusion());
            expectedSourceToReturned = EqualityCertificates.transitive(
                    sourceToFresh,
                    EqualityCertificates.rename(collision, structural.inclusion()));
            CertificateVerifier.verify(expectedSourceToReturned);
        } else if (collision != null && !collision.parent().equals(fresh)) {
            throw new IllegalStateException(
                    "A prospective insertion collision does not contain the fresh class");
        }
        CertifiedInsertionResult insertion = new CertifiedInsertionResult(
                certified,
                fresh,
                shapeWitness,
                orbit,
                definition,
                shapeEquation,
                sourceToFresh,
                collision,
                expectedReturned,
                expectedSourceToReturned);

        unionFind.register(fresh);
        classes.put(freshId, freshRecord);
        ParentRecordKey freshKey = new ParentRecordKey(freshId, structural.shape());
        shapeCertificates.put(freshKey, shapeEquation);
        indexRecord(freshKey);
        if (collision == null) {
            hashCons.put(structural.shape(), freshId);
        } else {
            unionCertifiedInternal(collision);
        }

        TypedFindResult returned = findNormalized(freshInSource, true);
        if (!returned.leaderInvocation().equals(expectedReturned)) {
            throw new IllegalStateException(
                    "Certified collision and union-find return different leaders");
        }
        insertionHistory.put(freshId, insertion);
        coherenceRevision = Math.incrementExact(coherenceRevision);
        checkInvariants();
        return insertion;
    }

    private EClassId nextEClassId() {
        return classes.isEmpty()
                ? EClassId.of(0)
                : EClassId.of(Math.incrementExact(classes.lastKey().value()));
    }

    /** Extracts the Phase DA exact leader kernel and structural provenance. */
    public synchronized LeaderKernelResult extractLeaderKernel(TypedENode node) {
        requireCertifiedNodeTheory(Objects.requireNonNull(node, "node"));
        return LeaderKernelExtractor.instance().extract(this, node);
    }

    synchronized TypedFindResult findWithoutCompressionForTesting(TypedInvocation invocation) {
        return findNormalized(Objects.requireNonNull(invocation, "invocation"), false);
    }

    /** Nonmutating provenance lookup used by the read-only Phase H oracle. */
    synchronized TypedFindResult findForFiniteUnfolding(TypedInvocation invocation) {
        TypedFindResult result = findNormalized(
                Objects.requireNonNull(invocation, "invocation"), false);
        checkInvariants();
        return result;
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
        if (!rebuildActive) {
            requireQuiescent();
        }
    }

    synchronized void requireCertifiedNodeTheoryForCanonicalization(TypedENode node) {
        requireCertifiedNodeTheory(Objects.requireNonNull(node, "node"));
    }

    synchronized TypedSymmetryGroup symmetryGroupForCanonicalization(
            TypedEClassInterface eclass) {
        TypedEClassRecord record = this.eclass(eclass.id());
        if (!record.interfaceView().equals(eclass)) {
            throw new IllegalArgumentException("Stale e-class interface in canonicalization");
        }
        if (certificateMode == GraphCertificateMode.REQUIRED) {
            record.symmetryGroup().requireCertifiedFor(eclass);
        }
        return record.symmetryGroup();
    }

    synchronized BinderAutomorphismGroup binderGroupForCanonicalization(
            BinderBlockDescriptor descriptor) {
        Objects.requireNonNull(descriptor, "descriptor");
        if (certificateMode == GraphCertificateMode.REQUIRED
                && !descriptor.hasCertifiedAutomorphisms()) {
            throw new IllegalStateException(
                    "Canonicalization cannot use an uncertified binder automorphism");
        }
        return descriptor.automorphisms();
    }

    synchronized TypedFindResult findForCanonicalization(TypedInvocation invocation) {
        if (!rebuildActive) {
            requireQuiescent();
        }
        return findNormalized(
                Objects.requireNonNull(invocation, "invocation"), !rebuildActive);
    }

    /**
     * Closes an empty-shape test fixture after raw Phase D parent setup. This is
     * deliberately not a rebuild substitute and cannot publish stored shapes.
     */
    synchronized void sealEmptyShapeFixtureForPhaseE() {
        requireStructuralFixture("Phase E empty-shape seal");
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

    public synchronized int dirtyParentCount() {
        return dirtyParents.size();
    }

    public synchronized Map<ParentRecordKey, TypedEqualityCertificate>
            shapeCertificatesSnapshot() {
        return Collections.unmodifiableMap(new LinkedHashMap<>(shapeCertificates));
    }

    /** Source-level provenance retained independently of current leader ownership. */
    public synchronized Map<EClassId, CertifiedInsertionResult>
            insertionHistorySnapshot() {
        return Collections.unmodifiableMap(new LinkedHashMap<>(insertionHistory));
    }

    public synchronized Map<EClassId, Set<ParentRecordKey>> parentUsesSnapshot() {
        Map<EClassId, Set<ParentRecordKey>> snapshot = new LinkedHashMap<>();
        for (Map.Entry<EClassId, NavigableSet<ParentRecordKey>> entry
                : parentUses.entrySet()) {
            snapshot.put(entry.getKey(), Collections.unmodifiableSet(
                    new LinkedHashSet<>(entry.getValue())));
        }
        return Collections.unmodifiableMap(snapshot);
    }

    /** Restores the fixed finite stored-node batch without inserting rewrites. */
    public synchronized RebuildReport rebuild() {
        return rebuild(false);
    }

    synchronized RebuildReport rebuildReverseForTesting() {
        return rebuild(true);
    }

    private RebuildReport rebuild(boolean reverseOrder) {
        if (certificateMode != GraphCertificateMode.REQUIRED) {
            throw new IllegalStateException(
                    "The Phase G rebuild is available only in strict certificate mode");
        }
        if (rebuildActive) {
            throw new IllegalStateException("Rebuild is not reentrant");
        }
        if (status == GraphStatus.QUIESCENT) {
            checkInvariants();
            return new RebuildReport(0, 0, 0, 0, 0);
        }

        int processed = 0;
        int changed = 0;
        int collisions = 0;
        int unions = 0;
        int maximumDirty = dirtyParents.size();
        rebuildActive = true;
        try {
            while (!dirtyParents.isEmpty()) {
                maximumDirty = Math.max(maximumDirty, dirtyParents.size());
                ParentRecordKey key = reverseOrder
                        ? dirtyParents.pollLast()
                        : dirtyParents.pollFirst();
                if (!recordExists(key)) {
                    continue;
                }
                rebuildingRecord = key;
                RebuildStepResult step;
                try {
                    step = rebuildRecord(key);
                } catch (RuntimeException exception) {
                    if (recordExists(key)) {
                        dirtyParents.add(key);
                    }
                    throw exception;
                } finally {
                    rebuildingRecord = null;
                }
                processed++;
                changed += step.changed ? 1 : 0;
                collisions += step.collision ? 1 : 0;
                unions += step.union ? 1 : 0;
                checkInvariants();
            }
            requireCollisionFreeLeaderKeys();
            rebuildHashConsExactly();
            status = GraphStatus.QUIESCENT;
            if (changed != 0 || collisions != 0 || unions != 0) {
                coherenceRevision = Math.incrementExact(coherenceRevision);
            }
            checkInvariants();
            return new RebuildReport(
                    processed, changed, collisions, unions, maximumDirty);
        } catch (RuntimeException exception) {
            status = GraphStatus.DIRTY;
            throw exception;
        } finally {
            rebuildingRecord = null;
            rebuildActive = false;
        }
    }

    private RebuildStepResult rebuildRecord(ParentRecordKey key) {
        TypedEClassRecord owner = eclass(key.owner());
        if (!unionFind.isLeader(owner.id())) {
            throw new IllegalStateException(
                    "Only leader-owned records may enter the Phase G rebuild queue");
        }
        ShapeWitness oldWitness = owner.shapeWitnesses().get(key.shape());
        if (oldWitness == null) {
            return RebuildStepResult.unchanged();
        }
        TypedEqualityCertificate oldEquation = requireShapeCertificate(key);
        TypedENode source = key.shape().node().act(
                oldWitness.instantiatingRenaming());
        CanonicalizationResult result = ProductionGraphCanonicalizer.instance()
                .canonicalize(this, source);
        if (!owner.exposedSlots().isSubcontextOf(result.effectiveSupport())) {
            throw new InterfaceRestrictionRequiredException(
                    owner.interfaceView(), result.effectiveSupport());
        }

        TypedEqualityCertificate rebuildEquation =
                RebuildCongruenceCertificate.create(this, result);
        TypedEqualityCertificate ambientNewToOwner = EqualityCertificates.transitive(
                EqualityCertificates.symmetric(rebuildEquation), oldEquation);
        TypedEmbedding effectiveInOldAmbient = TypedEmbedding.inclusion(
                result.effectiveSupport(), oldWitness.ambientSupport());
        ShapeWitness newWitness = new ShapeWitness(
                result.shape().exactSlots(),
                result.effectiveSupport(),
                owner.exposedSlots(),
                result.witness());
        TypedCertificateEndpoint newNode = TypedCertificateEndpoint.node(
                result.shape().node().act(result.witness()));
        TypedCertificateEndpoint newOwner = TypedCertificateEndpoint.invocation(
                new TypedInvocation(
                        owner.interfaceView(),
                        TypedEmbedding.inclusion(
                                owner.exposedSlots(), result.effectiveSupport())));
        TypedEqualityCertificate newEquation = EqualityCertificates.restrict(
                ambientNewToOwner,
                newNode,
                newOwner,
                effectiveInOldAmbient);

        EClassId prospectiveCollisionOwner = hashCons.get(result.shape());
        ParentEdgeCertificate prospectiveCollision = null;
        if (prospectiveCollisionOwner != null
                && !prospectiveCollisionOwner.equals(owner.id())) {
            TypedEClassRecord prospectiveOwner = owner.withoutStoredShape(key.shape());
            TypedEqualityCertificate prospectiveEquation = newEquation;
            if (prospectiveOwner.shapeWitnesses().containsKey(result.shape())) {
                prospectiveEquation = requireShapeCertificate(
                        new ParentRecordKey(owner.id(), result.shape()));
            } else {
                prospectiveOwner = prospectiveOwner.withStoredShape(
                        result.shape(), newWitness);
            }
            TypedEClassRecord other = eclass(prospectiveCollisionOwner);
            prospectiveCollision = collisionParentEdge(
                    result.shape(),
                    prospectiveOwner,
                    prospectiveEquation,
                    other,
                    requireShapeCertificate(new ParentRecordKey(
                            other.id(), result.shape())));
        }

        removeStoredRecord(key);
        ParentRecordKey replacementKey = new ParentRecordKey(
                owner.id(), result.shape());
        boolean duplicateInOwner = recordExists(replacementKey);
        if (!duplicateInOwner) {
            installStoredRecord(
                    owner.id(), result.shape(), newWitness, newEquation);
        }
        boolean changed = !key.shape().equals(result.shape())
                || !oldWitness.equals(newWitness)
                || duplicateInOwner;

        EClassId collisionOwner = hashCons.get(result.shape());
        if (prospectiveCollision == null && collisionOwner == null) {
            hashCons.put(result.shape(), owner.id());
            return new RebuildStepResult(changed, false, false);
        }
        if (prospectiveCollision == null && collisionOwner.equals(owner.id())) {
            return new RebuildStepResult(changed, false, false);
        }
        unionCertifiedInternal(prospectiveCollision);
        return new RebuildStepResult(true, true, true);
    }

    private ParentEdgeCertificate collisionParentEdge(
            CanonicalShape shape,
            TypedEClassRecord first,
            TypedEqualityCertificate firstEquation,
            TypedEClassRecord second,
            TypedEqualityCertificate secondEquation) {
        EClassId preferredParent = first.id().compareTo(second.id()) < 0
                ? first.id() : second.id();
        EClassId preferredChild = preferredParent.equals(first.id())
                ? second.id() : first.id();
        IllegalArgumentException firstFailure;
        try {
            return collisionParentEdgeOriented(
                    shape,
                    preferredChild.equals(first.id()) ? first : second,
                    preferredChild.equals(first.id()) ? firstEquation : secondEquation,
                    preferredParent.equals(first.id()) ? first : second,
                    preferredParent.equals(first.id()) ? firstEquation : secondEquation);
        } catch (IllegalArgumentException exception) {
            firstFailure = exception;
        }
        try {
            return collisionParentEdgeOriented(
                    shape,
                    preferredParent.equals(first.id()) ? first : second,
                    preferredParent.equals(first.id()) ? firstEquation : secondEquation,
                    preferredChild.equals(first.id()) ? first : second,
                    preferredChild.equals(first.id()) ? firstEquation : secondEquation);
        } catch (IllegalArgumentException exception) {
            exception.addSuppressed(firstFailure);
            throw new IllegalStateException(
                    "Colliding exact shapes have no typed interface embedding; "
                            + "an explicit certified restriction is required",
                    exception);
        }
    }

    private ParentEdgeCertificate collisionParentEdgeOriented(
            CanonicalShape shape,
            TypedEClassRecord child,
            TypedEqualityCertificate childEquation,
            TypedEClassRecord parent,
            TypedEqualityCertificate parentEquation) {
        EffectiveShapeCollisionCertificate collision =
                EffectiveShapeCollisionCertificate.create(
                        shape,
                        child,
                        child.shapeWitnesses().get(shape),
                        childEquation,
                        parent,
                        parent.shapeWitnesses().get(shape),
                        parentEquation);
        CertificateVerifier.verify(collision);
        return new ParentEdgeCertificate(
                collision.child(),
                collision.parentInvocation(),
                collision);
    }

    private ParentStep unionCertifiedInternal(ParentEdgeCertificate certificate) {
        ParentEdgeCertificate checked = Objects.requireNonNull(
                certificate, "certificate");
        CertificateVerifier.verifyParentEdge(checked);
        requireRecord(checked.child());
        requireRecord(checked.parent());
        if (checked.child().id().equals(checked.parent().id())
                || !unionFind.isLeader(checked.child().id())
                || !unionFind.isLeader(checked.parent().id())) {
            throw new IllegalArgumentException(
                    "Certified union requires current distinct leaders");
        }

        TypedEClassRecord child = eclass(checked.child().id());
        TypedEClassRecord parent = eclass(checked.parent().id());
        TypedSymmetryGroup mergedGroup = mergeStabilizingSymmetries(
                child, parent, checked);
        TypedEClassRecord updatedParent = parent.withSymmetryGroup(mergedGroup);
        List<CanonicalShape> childShapes = new ArrayList<>(
                child.shapeWitnesses().keySet());
        for (CanonicalShape shape : childShapes) {
            ParentRecordKey oldKey = new ParentRecordKey(child.id(), shape);
            boolean wasDirty = dirtyParents.remove(oldKey);
            TransferredShape transferred = transferShapeToParent(
                    shape,
                    child,
                    child.shapeWitnesses().get(shape),
                    requireShapeCertificate(oldKey),
                    parent,
                    checked);
            unindexRecord(oldKey);
            shapeCertificates.remove(oldKey);
            hashCons.remove(shape, child.id());

            if (!updatedParent.shapeWitnesses().containsKey(shape)) {
                updatedParent = updatedParent.withStoredShape(
                        shape, transferred.witness);
                ParentRecordKey newKey = new ParentRecordKey(parent.id(), shape);
                shapeCertificates.put(newKey, transferred.equation);
                indexRecord(newKey);
                if (wasDirty) {
                    dirtyParents.add(newKey);
                }
            }
            hashCons.put(shape, parent.id());
        }

        classes.put(parent.id(), updatedParent);
        classes.put(child.id(), child.withoutStoredShapes());
        ParentStep step = ParentStep.certified(checked);
        unionFind.linkRoots(step);
        markParentsDirty(child.id());
        if (!mergedGroup.equals(parent.symmetryGroup())) {
            markParentsDirty(parent.id());
        }
        status = GraphStatus.DIRTY;
        return step;
    }

    private TransferredShape transferShapeToParent(
            CanonicalShape shape,
            TypedEClassRecord child,
            ShapeWitness witness,
            TypedEqualityCertificate equation,
            TypedEClassRecord parent,
            ParentEdgeCertificate edge) {
        TypedEqualityCertificate oriented =
                EffectiveShapeCollisionCertificate.orientShapeEquation(
                        shape, child, witness, equation);
        TypedRenaming relabeling = parentLiteralRelabeling(
                witness.ambientSupport(), edge.embedding());
        TypedRenaming instantiation = witness.instantiatingRenaming()
                .andThen(relabeling);
        ShapeWitness transported = new ShapeWitness(
                witness.exactSlots(),
                relabeling.codomain(),
                parent.exposedSlots(),
                instantiation);

        TypedEmbedding childInAmbient = TypedEmbedding.inclusion(
                child.exposedSlots(), witness.ambientSupport());
        TypedEqualityCertificate parentInOldAmbient = EqualityCertificates.transitive(
                oriented,
                EqualityCertificates.rename(edge, childInAmbient));
        TypedEqualityCertificate transportedEquation = EqualityCertificates.rename(
                parentInOldAmbient, relabeling);
        TypedEqualityCertificate checkedEquation =
                EffectiveShapeCollisionCertificate.orientShapeEquation(
                        shape, parent, transported, transportedEquation);
        return new TransferredShape(transported, checkedEquation);
    }

    private TypedRenaming parentLiteralRelabeling(
            TypedSlotContext ambient,
            TypedEmbedding parentInChild) {
        Map<TypedSlot, TypedSlot> mapping = new LinkedHashMap<>();
        Set<TypedSlot> forcedSources = new HashSet<>();
        Set<TypedSlot> usedTargets = new HashSet<>();
        for (TypedSlot parentSlot : parentInChild.source()) {
            TypedSlot childSlot = parentInChild.apply(parentSlot);
            if (!ambient.contains(childSlot) || !forcedSources.add(childSlot)) {
                throw new IllegalStateException(
                        "Parent embedding is incompatible with a child shape ambient context");
            }
            mapping.put(childSlot, parentSlot);
            usedTargets.add(parentSlot);
        }
        for (TypedSlot source : ambient) {
            if (forcedSources.contains(source)) {
                continue;
            }
            TypedSlot target = source;
            if (usedTargets.contains(target)) {
                target = freshSourceSlot(source.type(), usedTargets);
            }
            mapping.put(source, target);
            usedTargets.add(target);
        }
        return TypedRenaming.of(
                ambient, TypedSlotContext.of(mapping.values()), mapping);
    }

    private static TypedSlot freshSourceSlot(
            GraphType type,
            Set<TypedSlot> occupied) {
        BigInteger ordinal = BigInteger.ZERO;
        while (occupied.contains(TypedSlot.of(type, SlotAlphabet.SOURCE, ordinal))) {
            ordinal = ordinal.add(BigInteger.ONE);
        }
        return TypedSlot.of(type, SlotAlphabet.SOURCE, ordinal);
    }

    private TypedSymmetryGroup mergeStabilizingSymmetries(
            TypedEClassRecord child,
            TypedEClassRecord parent,
            ParentEdgeCertificate edge) {
        TypedSymmetryGroup result = parent.symmetryGroup();
        for (TypedPermutation childPermutation
                : child.symmetryGroup().elements()) {
            TypedPermutation induced = inducedPermutation(
                    edge.embedding(), childPermutation);
            if (induced == null
                    || induced.equals(TypedPermutation.identity(parent.exposedSlots()))
                    || result.contains(induced)) {
                continue;
            }
            TypedEqualityCertificate childSymmetry = child.symmetryGroup()
                    .derivationFor(child.interfaceView(), childPermutation);
            TypedEqualityCertificate ambient = EqualityCertificates.transitive(
                    EqualityCertificates.transitive(
                            EqualityCertificates.symmetric(edge), childSymmetry),
                    EqualityCertificates.rename(edge, childPermutation));
            TypedEqualityCertificate restricted = EqualityCertificates.restrict(
                    ambient,
                    TypedCertificateEndpoint.eclassWitness(parent.interfaceView()),
                    TypedCertificateEndpoint.invocation(
                            new TypedInvocation(parent.interfaceView(), induced)),
                    edge.embedding());
            SymmetryCertificate transported = new SymmetryCertificate(
                    TypedInvocation.identity(parent.interfaceView()),
                    new TypedInvocation(parent.interfaceView(), induced),
                    restricted);
            result = result.withCertifiedGenerator(
                    parent.interfaceView(), transported);
        }
        return result;
    }

    private TypedSymmetryGroup restrictSymmetryGroup(
            TypedEClassRecord original,
            InterfaceRestrictionCertificate restriction) {
        List<SymmetryCertificate> certificates = new ArrayList<>();
        TypedEClassInterface replacement = restriction.restrictedInterface();
        for (TypedPermutation permutation : original.symmetryGroup().elements()) {
            TypedPermutation induced = inducedPermutation(
                    restriction.inclusion(), permutation);
            if (induced == null
                    || induced.equals(TypedPermutation.identity(
                            replacement.exposedSlots()))) {
                continue;
            }
            TypedEqualityCertificate oldSymmetry = original.symmetryGroup()
                    .derivationFor(original.interfaceView(), permutation);
            TypedEqualityCertificate ambient = EqualityCertificates.transitive(
                    EqualityCertificates.transitive(
                            EqualityCertificates.symmetric(restriction.factorization()),
                            oldSymmetry),
                    EqualityCertificates.rename(
                            restriction.factorization(), permutation));
            TypedEqualityCertificate restricted = EqualityCertificates.restrict(
                    ambient,
                    TypedCertificateEndpoint.eclassWitness(replacement),
                    TypedCertificateEndpoint.invocation(
                            new TypedInvocation(replacement, induced)),
                    restriction.inclusion());
            certificates.add(new SymmetryCertificate(
                    TypedInvocation.identity(replacement),
                    new TypedInvocation(replacement, induced),
                    restricted));
        }
        return TypedSymmetryGroup.certified(replacement, certificates);
    }

    private static TypedPermutation inducedPermutation(
            TypedEmbedding subcontextEmbedding,
            TypedPermutation ambientPermutation) {
        Map<TypedSlot, TypedSlot> inverseImage = new LinkedHashMap<>();
        for (TypedSlot source : subcontextEmbedding.source()) {
            inverseImage.put(subcontextEmbedding.apply(source), source);
        }
        Map<TypedSlot, TypedSlot> induced = new LinkedHashMap<>();
        for (TypedSlot source : subcontextEmbedding.source()) {
            TypedSlot moved = ambientPermutation.apply(
                    subcontextEmbedding.apply(source));
            TypedSlot target = inverseImage.get(moved);
            if (target == null) {
                return null;
            }
            induced.put(source, target);
        }
        return TypedPermutation.of(subcontextEmbedding.source(), induced);
    }

    private TypedEqualityCertificate requireShapeCertificate(ParentRecordKey key) {
        TypedEqualityCertificate certificate = shapeCertificates.get(key);
        if (certificate == null) {
            throw new IllegalStateException(
                    "Strict stored record has no exact shape equation: " + key);
        }
        CertificateVerifier.verify(certificate);
        return certificate;
    }

    private boolean recordExists(ParentRecordKey key) {
        TypedEClassRecord record = classes.get(key.owner());
        return record != null && record.shapeWitnesses().containsKey(key.shape());
    }

    private void removeStoredRecord(ParentRecordKey key) {
        TypedEClassRecord owner = eclass(key.owner());
        if (!owner.shapeWitnesses().containsKey(key.shape())) {
            return;
        }
        hashCons.remove(key.shape(), key.owner());
        unindexRecord(key);
        shapeCertificates.remove(key);
        classes.put(owner.id(), owner.withoutStoredShape(key.shape()));
    }

    private void installStoredRecord(
            EClassId ownerId,
            CanonicalShape shape,
            ShapeWitness witness,
            TypedEqualityCertificate equation) {
        TypedEClassRecord owner = eclass(ownerId);
        ParentRecordKey key = new ParentRecordKey(ownerId, shape);
        if (owner.shapeWitnesses().containsKey(shape)) {
            throw new IllegalArgumentException("Duplicate stored record key: " + key);
        }
        TypedEClassRecord updated = owner.withStoredShape(shape, witness);
        TypedEqualityCertificate oriented =
                EffectiveShapeCollisionCertificate.orientShapeEquation(
                        shape, updated, witness, equation);
        classes.put(ownerId, updated);
        shapeCertificates.put(key, oriented);
        indexRecord(key);
    }

    private void indexRecord(ParentRecordKey key) {
        for (EClassId child : invocationIds(key.shape().node())) {
            parentUses.computeIfAbsent(child, ignored -> new TreeSet<>()).add(key);
        }
    }

    private void unindexRecord(ParentRecordKey key) {
        for (EClassId child : invocationIds(key.shape().node())) {
            NavigableSet<ParentRecordKey> uses = parentUses.get(child);
            if (uses == null) {
                continue;
            }
            uses.remove(key);
            if (uses.isEmpty()) {
                parentUses.remove(child);
            }
        }
    }

    private void markParentsDirty(EClassId child) {
        NavigableSet<ParentRecordKey> uses = parentUses.get(child);
        if (uses != null) {
            dirtyParents.addAll(uses);
        }
    }

    private static Set<EClassId> invocationIds(TypedENode node) {
        Set<EClassId> result = new TreeSet<>();
        for (PortValue port : node.ports()) {
            collectInvocationIds(port, result);
        }
        return result;
    }

    private static void collectInvocationIds(
            PortValue port,
            Set<EClassId> target) {
        if (port instanceof OnePort) {
            PortLeaf leaf = ((OnePort) port).leaf();
            if (leaf instanceof InvocationPortLeaf) {
                target.add(((InvocationPortLeaf) leaf).invocation().eclass().id());
            }
        } else if (port instanceof SeqPort) {
            for (PortValue child : ((SeqPort) port).elements()) {
                collectInvocationIds(child, target);
            }
        } else if (port instanceof BagPort) {
            for (PortValue child : ((BagPort) port).occurrences()) {
                collectInvocationIds(child, target);
            }
        } else if (port instanceof SetPort) {
            for (PortValue child : ((SetPort) port).elements()) {
                collectInvocationIds(child, target);
            }
        } else if (port instanceof BindPort) {
            collectInvocationIds(((BindPort) port).body(), target);
        } else if (port instanceof BindBlockPort) {
            collectInvocationIds(((BindBlockPort) port).body(), target);
        }
    }

    private TypedFindResult findNormalized(
            TypedInvocation original,
            boolean compress) {
        InvocationNormalization normalization = normalizeInvocation(original);
        TypedFindResult current = compress
                ? unionFind.findWithProvenance(normalization.invocation)
                : unionFind.findWithoutCompression(normalization.invocation);
        if (normalization.invocation.equals(original)) {
            return current;
        }
        return new TypedFindResult(
                original,
                normalization.invocation,
                current.leaderInvocation(),
                current.parentPath(),
                normalization.certificate);
    }

    private InvocationNormalization normalizeInvocation(TypedInvocation original) {
        TypedEClassRecord record = classes.get(original.eclass().id());
        if (record == null) {
            throw new IllegalArgumentException(
                    "Unknown e-class id: " + original.eclass().id());
        }
        if (!record.outputType().equals(original.outputType())) {
            throw new IllegalArgumentException(
                    "Historical invocation changed e-class output type");
        }
        if (record.interfaceView().equals(original.eclass())) {
            return new InvocationNormalization(
                    original,
                    EqualityCertificates.reflexive(
                            TypedCertificateEndpoint.invocation(original)));
        }

        TypedInvocation current = original;
        TypedEqualityCertificate proof = null;
        List<InterfaceRestrictionCertificate> history = restrictionHistory.get(
                original.eclass().id());
        if (history != null) {
            for (InterfaceRestrictionCertificate restriction : history) {
                if (!restriction.originalInterface().equals(current.eclass())) {
                    continue;
                }
                TypedEmbedding oldEmbedding = current.embedding();
                TypedInvocation next = new TypedInvocation(
                        restriction.restrictedInterface(),
                        restriction.inclusion().andThen(oldEmbedding));
                TypedEqualityCertificate step = EqualityCertificates.rename(
                        restriction.factorization(), oldEmbedding);
                proof = proof == null
                        ? step
                        : EqualityCertificates.transitive(proof, step);
                current = next;
            }
        }
        if (!record.interfaceView().equals(current.eclass()) || proof == null) {
            throw new IllegalArgumentException(
                    "Invocation e-class metadata is neither current nor certified historical state");
        }
        CertificateVerifier.verify(proof);
        return new InvocationNormalization(current, proof);
    }

    private void requireCollisionFreeLeaderKeys() {
        NavigableMap<CanonicalShape, EClassId> seen = new TreeMap<>();
        for (TypedEClassRecord record : classes.values()) {
            if (!unionFind.isLeader(record.id())) {
                continue;
            }
            for (CanonicalShape shape : record.shapeWitnesses().keySet()) {
                EClassId prior = seen.putIfAbsent(shape, record.id());
                if (prior != null && !prior.equals(record.id())) {
                    throw new IllegalStateException(
                            "Rebuild ended with an unprocessed leader collision");
                }
            }
        }
    }

    private void rebuildHashConsExactly() {
        hashCons.clear();
        for (TypedEClassRecord record : classes.values()) {
            if (!unionFind.isLeader(record.id())) {
                continue;
            }
            for (CanonicalShape shape : record.shapeWitnesses().keySet()) {
                hashCons.put(shape, record.id());
            }
        }
    }

    public synchronized StructuralKey stateStructuralKey() {
        List<StructuralKey> children = new ArrayList<>();
        children.add(StructuralKey.leaf("graph-status", status.name()));
        children.add(StructuralKey.leaf(
                "graph-certificate-mode", certificateMode.name()));
        children.add(StructuralKey.leaf(
                "coherence-revision", Long.toString(coherenceRevision)));
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
        for (Map.Entry<ParentRecordKey, TypedEqualityCertificate> entry
                : shapeCertificates.entrySet()) {
            children.add(StructuralKey.branch(
                    "shape-equation",
                    java.util.Arrays.asList(
                            entry.getKey().structuralKey(),
                            entry.getValue().structuralKey())));
        }
        for (Map.Entry<EClassId, NavigableSet<ParentRecordKey>> entry
                : parentUses.entrySet()) {
            List<StructuralKey> uses = new ArrayList<>();
            uses.add(StructuralKey.leaf(
                    "child", Long.toString(entry.getKey().value())));
            for (ParentRecordKey key : entry.getValue()) {
                uses.add(key.structuralKey());
            }
            children.add(StructuralKey.branch("parent-use-index", uses));
        }
        for (ParentRecordKey key : dirtyParents) {
            children.add(StructuralKey.branch(
                    "dirty-parent", Collections.singletonList(key.structuralKey())));
        }
        for (Map.Entry<EClassId, CertifiedInsertionResult> entry
                : insertionHistory.entrySet()) {
            children.add(StructuralKey.branch(
                    "source-insertion-provenance",
                    java.util.Arrays.asList(
                            StructuralKey.leaf(
                                    "inserted-class", Long.toString(entry.getKey().value())),
                            entry.getValue().structuralKey())));
        }
        return StructuralKey.branch("typed-slotted-port-egraph", children);
    }

    public synchronized void checkInvariants() {
        unionFind.checkInvariants();
        if (!classes.keySet().equals(unionFind.interfaces().keySet())) {
            throw new IllegalStateException("U and M have different e-class domains");
        }
        NavigableSet<ParentRecordKey> expectedShapeKeys = new TreeSet<>();
        NavigableMap<EClassId, NavigableSet<ParentRecordKey>> expectedUses =
                new TreeMap<>();
        for (Map.Entry<EClassId, TypedEClassRecord> entry : classes.entrySet()) {
            if (!entry.getKey().equals(entry.getValue().id())) {
                throw new IllegalStateException("E-class record is stored under the wrong id");
            }
            TypedEClassInterface registered = unionFind.interfaces().get(entry.getKey());
            if (!entry.getValue().interfaceView().equals(registered)) {
                throw new IllegalStateException("U and M disagree on an e-class interface");
            }
            if (certificateMode == GraphCertificateMode.REQUIRED
                    && !unionFind.isLeader(entry.getKey())
                    && !entry.getValue().shapeWitnesses().isEmpty()) {
                throw new IllegalStateException(
                        "A strict nonleader may not retain stored shapes");
            }
            if (certificateMode == GraphCertificateMode.REQUIRED) {
                entry.getValue().symmetryGroup().requireCertifiedFor(
                        entry.getValue().interfaceView());
            }
            for (Map.Entry<CanonicalShape, ShapeWitness> stored
                    : entry.getValue().shapeWitnesses().entrySet()) {
                CanonicalShape shape = stored.getKey();
                ParentRecordKey key = new ParentRecordKey(entry.getKey(), shape);
                expectedShapeKeys.add(key);
                validateStoredInvocationsState(key, shape.node());
                for (EClassId child : invocationIds(shape.node())) {
                    expectedUses.computeIfAbsent(
                            child, ignored -> new TreeSet<>()).add(key);
                }
                if (certificateMode == GraphCertificateMode.REQUIRED) {
                    requireCertifiedNodeTheory(shape.node());
                    TypedEqualityCertificate equation = requireShapeCertificate(key);
                    EffectiveShapeCollisionCertificate.orientShapeEquation(
                            shape, entry.getValue(), stored.getValue(), equation);
                }
            }
        }
        if (certificateMode == GraphCertificateMode.REQUIRED
                && !expectedShapeKeys.equals(shapeCertificates.navigableKeySet())) {
            throw new IllegalStateException(
                    "Strict shape records and exact shape equations differ");
        }
        if (!expectedUses.equals(parentUses)) {
            throw new IllegalStateException(
                    "Reverse parent-use index is not exact");
        }
        for (ParentRecordKey dirty : dirtyParents) {
            if (!recordExists(dirty)) {
                throw new IllegalStateException(
                        "Dirty queue references a missing parent record");
            }
        }
        if (certificateMode == GraphCertificateMode.REQUIRED) {
            for (ParentAssignment assignment : unionFind.assignments().values()) {
                if (!assignment.provenancePath().hasCertificates()) {
                    throw new IllegalStateException(
                            "Certificate mode contains an uncertified parent edge");
                }
                if (!assignment.isRoot()) {
                    CertificateVerifier.verify(
                            assignment.provenancePath().composedCertificate());
                }
            }
            for (Map.Entry<EClassId, CertifiedInsertionResult> entry
                    : insertionHistory.entrySet()) {
                if (!classes.containsKey(entry.getKey())
                        || !entry.getKey().equals(
                                entry.getValue().insertedClass().id())) {
                    throw new IllegalStateException(
                            "Insertion provenance names an unregistered e-class");
                }
                for (TypedEqualityCertificate certificate
                        : entry.getValue().retainedSourceProofs()) {
                    CertificateVerifier.verify(certificate);
                }
                entry.getValue().collisionEdge().ifPresent(
                        CertificateVerifier::verifyParentEdge);
            }
        }
        validateRestrictionHistory();
        if (status == GraphStatus.QUIESCENT) {
            if (!dirtyParents.isEmpty()) {
                throw new IllegalStateException(
                        "A quiescent graph cannot retain dirty parent records");
            }
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

    private void validateRestrictionHistory() {
        for (Map.Entry<EClassId, List<InterfaceRestrictionCertificate>> entry
                : restrictionHistory.entrySet()) {
            TypedEClassRecord current = classes.get(entry.getKey());
            if (current == null || entry.getValue().isEmpty()) {
                throw new IllegalStateException("Malformed interface-restriction history");
            }
            TypedEClassInterface previous = entry.getValue().get(0).originalInterface();
            for (InterfaceRestrictionCertificate restriction : entry.getValue()) {
                CertificateVerifier.verifyInterfaceRestriction(restriction);
                if (!previous.equals(restriction.originalInterface())) {
                    throw new IllegalStateException(
                            "Interface-restriction history is not composable");
                }
                previous = restriction.restrictedInterface();
            }
            if (!previous.equals(current.interfaceView())) {
                throw new IllegalStateException(
                        "Interface-restriction history does not reach current metadata");
            }
        }
    }

    private void requireQuiescent() {
        if (status != GraphStatus.QUIESCENT) {
            throw new IllegalStateException(
                    "Canonical hash-cons queries require a quiescent graph");
        }
    }

    private void requireStructuralFixture(String operation) {
        if (certificateMode != GraphCertificateMode.STRUCTURAL_FIXTURE) {
            throw new IllegalStateException(
                    operation + " is available only to structural gate fixtures");
        }
    }

    private void requireCertifiedNodeTheory(TypedENode node) {
        if (certificateMode == GraphCertificateMode.REQUIRED) {
            CertificateVerifier.requireCertifiedNodeTheory(node);
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

    private void validateStoredInvocationsState(
            ParentRecordKey key,
            TypedENode node) {
        for (PortValue port : node.ports()) {
            validatePortInvocationsState(key, port);
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
        } else if (port instanceof BindPort) {
            validatePortInvocations(((BindPort) port).body(), invariantCheck);
        } else if (port instanceof BindBlockPort) {
            validatePortInvocations(((BindBlockPort) port).body(), invariantCheck);
        } else {
            throw new IllegalStateException("Unhandled port value " + port.getClass().getName());
        }
    }

    private void validatePortInvocationsState(
            ParentRecordKey key,
            PortValue port) {
        if (port instanceof OnePort) {
            PortLeaf leaf = ((OnePort) port).leaf();
            if (leaf instanceof InvocationPortLeaf) {
                TypedInvocation invocation = ((InvocationPortLeaf) leaf).invocation();
                TypedEClassRecord target = classes.get(invocation.eclass().id());
                if (target == null) {
                    throw new IllegalStateException(
                            "Stored shape references a missing e-class");
                }
                boolean current = target.interfaceView().equals(invocation.eclass());
                boolean leader = current && unionFind.isLeader(target.id());
                if (status == GraphStatus.QUIESCENT && (!current || !leader)) {
                    throw new IllegalStateException(
                            "Quiescent stored invocation is historical or nonleader");
                }
                if ((!current || !leader)
                        && !dirtyParents.contains(key)
                        && !key.equals(rebuildingRecord)) {
                    throw new IllegalStateException(
                            "Every stale stored invocation must have a dirty parent record");
                }
                try {
                    normalizeInvocation(invocation);
                } catch (IllegalArgumentException exception) {
                    throw new IllegalStateException(
                            "Stored invocation lacks certified current metadata", exception);
                }
            }
            return;
        }
        if (port instanceof SeqPort) {
            for (PortValue child : ((SeqPort) port).elements()) {
                validatePortInvocationsState(key, child);
            }
        } else if (port instanceof BagPort) {
            for (PortValue child : ((BagPort) port).occurrences()) {
                validatePortInvocationsState(key, child);
            }
        } else if (port instanceof SetPort) {
            for (PortValue child : ((SetPort) port).elements()) {
                validatePortInvocationsState(key, child);
            }
        } else if (port instanceof BindPort) {
            validatePortInvocationsState(key, ((BindPort) port).body());
        } else if (port instanceof BindBlockPort) {
            validatePortInvocationsState(key, ((BindBlockPort) port).body());
        } else {
            throw new IllegalStateException("Unhandled port value " + port.getClass().getName());
        }
    }

    private static final class InvocationNormalization {
        private final TypedInvocation invocation;
        private final TypedEqualityCertificate certificate;

        private InvocationNormalization(
                TypedInvocation invocation,
                TypedEqualityCertificate certificate) {
            this.invocation = invocation;
            this.certificate = certificate;
        }
    }

    private static final class TransferredShape {
        private final ShapeWitness witness;
        private final TypedEqualityCertificate equation;

        private TransferredShape(
                ShapeWitness witness,
                TypedEqualityCertificate equation) {
            this.witness = witness;
            this.equation = equation;
        }
    }

    private static final class RebuildStepResult {
        private final boolean changed;
        private final boolean collision;
        private final boolean union;

        private RebuildStepResult(
                boolean changed,
                boolean collision,
                boolean union) {
            this.changed = changed;
            this.collision = collision;
            this.union = union;
        }

        private static RebuildStepResult unchanged() {
            return new RebuildStepResult(false, false, false);
        }
    }
}
