package is.fivefivefive.CanDis.theory;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeMap;

/** Deterministic producer bridge into the standalone {@code .acgncert} schema. */
public final class CertificateBundleWriter {
    private static final String SCHEMA_VERSION = "acgncert-schema-v2";
    private static final int FORMAT_VERSION = 1;
    private static final byte[] MAGIC = new byte[] {
            'A', 'C', 'G', 'N', 'C', 'E', 'R', 'T'
    };

    private CertificateBundleWriter() {
    }

    /** Writes the finite Phase-J bridge slice after validating all retained evidence. */
    public static void write(CertificateExportSession session, Path output)
            throws IOException {
        Objects.requireNonNull(output, "output");
        Objects.requireNonNull(session, "session").provenance().requirePublishable();
        Slice slice = requireSupportedSlice(session);
        byte[] encoded = encode(new Assembler(session, slice).build());
        replaceAtomically(output.toAbsolutePath(), encoded);
    }

    private static void replaceAtomically(Path output, byte[] encoded)
            throws IOException {
        Path parent = output.getParent();
        if (parent == null) {
            throw new IOException("Output path has no parent: " + output);
        }
        Files.createDirectories(parent);
        String prefix = output.getFileName().toString() + ".";
        if (prefix.length() < 3) {
            prefix = "acgncert.";
        }
        Path temporary = Files.createTempFile(parent, prefix, ".tmp");
        boolean moved = false;
        try {
            Files.write(temporary, encoded);
            try {
                Files.move(
                        temporary,
                        output,
                        StandardCopyOption.ATOMIC_MOVE,
                        StandardCopyOption.REPLACE_EXISTING);
            } catch (AtomicMoveNotSupportedException exception) {
                throw new IOException(
                        "Atomic replacement is unavailable for " + output,
                        exception);
            }
            moved = true;
        } finally {
            if (!moved) {
                Files.deleteIfExists(temporary);
            }
        }
    }

    private static Slice requireSupportedSlice(CertificateExportSession session)
            throws IOException {
        if (!session.containerLaws().isEmpty()
                || !session.artifact().containerLaws().isEmpty()) {
            throw uncheckable("SEQ, BAG, and SET law registries are not exportable");
        }
        List<CertificateTraceEvent> events = session.events();
        if (events.isEmpty()) {
            throw uncheckable("the retained transition history is empty");
        }
        Map<EClassId, InsertionEvidence> insertions = new LinkedHashMap<>();
        Map<CanonicalShape, InsertionEvidence> shapes = new LinkedHashMap<>();
        ParentEdgeCertificate union = null;
        CertificateTraceSnapshot prior = null;
        for (int index = 0; index < events.size(); index++) {
            CertificateTraceEvent event = events.get(index);
            if (event.sequence() != index) {
                throw uncheckable("transition sequence is not consecutive");
            }
            if (prior != null && !prior.stateKey().equals(event.before().stateKey())) {
                throw uncheckable("retained snapshots are discontinuous");
            }
            requireSupportedSnapshot(event.before());
            requireSupportedSnapshot(event.after());
            switch (event.kind()) {
                case INSERT_FRESH -> {
                    if (!(event.payload() instanceof CertificateTracePayload.Insertion)) {
                        throw uncheckable("fresh insertion payload is missing");
                    }
                    CertifiedInsertionResult insertion =
                            ((CertificateTracePayload.Insertion) event.payload()).result();
                    requireSupportedInsertion(insertion);
                    if (insertion.collided()) {
                        throw uncheckable("insert collisions are not exportable");
                    }
                    InsertionEvidence evidence = new InsertionEvidence(event, insertion);
                    if (insertions.putIfAbsent(
                            insertion.insertedClass().id(), evidence) != null) {
                        throw uncheckable("one e-class has two fresh insertion records");
                    }
                    CanonicalShape shape = insertion.canonicalization().shape();
                    if (shapes.putIfAbsent(shape, evidence) != null) {
                        throw uncheckable("one canonical shape has two fresh owners");
                    }
                }
                case UNION -> {
                    if (union != null
                            || !(event.payload() instanceof CertificateTracePayload.Union)) {
                        throw uncheckable("the supported slice has exactly one certified union");
                    }
                    union = ((CertificateTracePayload.Union) event.payload()).certificate();
                    requireDirectGroundEdge(union);
                }
                case REBUILD_COMPLETE -> {
                    if (!(event.payload()
                            instanceof CertificateTracePayload.RebuildComplete)) {
                        throw uncheckable("rebuild completion payload is missing");
                    }
                    RebuildReport report =
                            ((CertificateTracePayload.RebuildComplete) event.payload()).report();
                    if (report.processedRecords() != 0
                            || report.changedKeys() != 0
                            || report.collisions() != 0
                            || report.certifiedUnions() != 0) {
                        throw uncheckable(
                                "a rebuild requiring REBUILD_RECORD is outside this slice");
                    }
                }
                default -> throw uncheckable(
                        event.kind() + " transitions are outside the supported slice");
            }
            prior = event.after();
        }

        boolean singleFresh = events.size() == 1
                && events.get(0).kind() == CertificateTraceEvent.Kind.INSERT_FRESH;
        boolean parentFixture = events.size() == 5
                && events.get(0).kind() == CertificateTraceEvent.Kind.INSERT_FRESH
                && events.get(1).kind() == CertificateTraceEvent.Kind.INSERT_FRESH
                && events.get(2).kind() == CertificateTraceEvent.Kind.UNION
                && events.get(3).kind() == CertificateTraceEvent.Kind.REBUILD_COMPLETE
                && events.get(4).kind() == CertificateTraceEvent.Kind.INSERT_FRESH;
        if (!singleFresh && !parentFixture) {
            throw uncheckable(
                    "history is neither one fresh insertion nor the exact parent-path slice");
        }
        if (singleFresh != (union == null)) {
            throw uncheckable("union evidence does not match the retained event slice");
        }

        CertificateTraceSnapshot finalSnapshot = session.finalSnapshot();
        if (!prior.stateKey().equals(finalSnapshot.stateKey())
                || finalSnapshot.status() != GraphStatus.QUIESCENT
                || !finalSnapshot.dirtyParents().isEmpty()
                || !session.artifact().classes().equals(finalSnapshot.classes())
                || session.artifact().witnesses().graphRevision()
                        != finalSnapshot.revision()) {
            throw uncheckable("publication is not the final complete quiescent snapshot");
        }
        if (!finalSnapshot.insertions().keySet().equals(insertions.keySet())) {
            throw uncheckable("retained insertion history is incomplete");
        }
        for (Map.Entry<EClassId, CertifiedInsertionResult> entry
                : finalSnapshot.insertions().entrySet()) {
            InsertionEvidence retained = insertions.get(entry.getKey());
            if (retained == null || !retained.insertion().equals(entry.getValue())) {
                throw uncheckable("snapshot insertion provenance differs from the event log");
            }
        }

        EClassId rootId = events.get(events.size() - 1).after().insertions()
                .keySet().stream().max(EClassId::compareTo)
                .orElseThrow(() -> new IllegalStateException("missing insertion"));
        CertifiedInsertionResult rootInsertion = insertions.get(rootId).insertion();
        if (!session.artifact().root().equals(rootInsertion.returnedInvocation())) {
            throw uncheckable("published root is not the final fresh insertion");
        }
        if (session.artifact().unfoldings().size() != 1) {
            throw uncheckable("exactly one complete root unfolding is required");
        }
        FiniteUnfoldingTree unfolding = session.artifact().unfoldings().get(0);
        requireSupportedUnfolding(unfolding, rootInsertion, parentFixture);

        if (parentFixture) {
            requireParentFixture(events, insertions, union, rootInsertion);
        } else if (!rootInsertion.canonicalization().structural().xi()
                .findResults().isEmpty()) {
            throw uncheckable("the single-fresh slice cannot contain invocations");
        }
        return new Slice(
                List.copyOf(events),
                Map.copyOf(insertions),
                Map.copyOf(shapes),
                union,
                rootInsertion,
                unfolding);
    }

    private static void requireParentFixture(
            List<CertificateTraceEvent> events,
            Map<EClassId, InsertionEvidence> insertions,
            ParentEdgeCertificate union,
            CertifiedInsertionResult root) throws IOException {
        if (union == null || insertions.size() != 3) {
            throw uncheckable("parent-path slice requires two leaves and one wrapper");
        }
        CertifiedInsertionResult first = insertion(events.get(0));
        CertifiedInsertionResult second = insertion(events.get(1));
        if (!union.child().equals(second.insertedClass())
                || !union.parent().equals(first.insertedClass())
                || !isIdentity(union.embedding())) {
            throw uncheckable("the retained union is not the direct second-to-first edge");
        }
        if (!onlySlotPorts(first.canonicalization().structural().source())
                || !onlySlotPorts(second.canonicalization().structural().source())) {
            throw uncheckable("parent-path leaves must be ONE_SLOT applications");
        }
        List<TypedFindResult> finds = root.canonicalization().structural()
                .xi().findResults();
        if (finds.size() != 1
                || finds.get(0).parentPath().steps().size() != 1
                || !finds.get(0).parentPath().steps().get(0).certificate().equals(union)
                || !finds.get(0).originalInvocation().eclass()
                        .equals(second.insertedClass())
                || !finds.get(0).leaderInvocation().eclass()
                        .equals(first.insertedClass())) {
            throw uncheckable("wrapper does not retain the required nonidentity parent path");
        }
        TypedENode source = root.canonicalization().structural().source();
        if (source.ports().size() != 1
                || !(source.ports().get(0) instanceof OnePort)
                || !(((OnePort) source.ports().get(0)).leaf()
                        instanceof InvocationPortLeaf)) {
            throw uncheckable("wrapper must contain one ONE_TERM invocation");
        }
    }

    private static CertifiedInsertionResult insertion(CertificateTraceEvent event) {
        return ((CertificateTracePayload.Insertion) event.payload()).result();
    }

    private static void requireSupportedSnapshot(CertificateTraceSnapshot snapshot)
            throws IOException {
        if (!snapshot.restrictions().isEmpty()) {
            throw uncheckable("interface restrictions are not exportable");
        }
        for (TypedEClassRecord record : snapshot.classes().values()) {
            requireRigidContext(record.exposedSlots());
            if (!record.symmetryGroup().generators().isEmpty()) {
                throw uncheckable("nontrivial e-class symmetries are not exportable");
            }
            for (Map.Entry<CanonicalShape, ShapeWitness> stored
                    : record.shapeWitnesses().entrySet()) {
                requireRigidContext(stored.getKey().exactSlots());
                ShapeWitness witness = stored.getValue();
                if (!witness.exactSlots().equals(witness.ambientSupport())
                        || !witness.ambientSupport().equals(witness.exposedInterface())
                        || !isIdentity(witness.instantiatingRenaming())) {
                    throw uncheckable(
                            "redundant shape coordinates are outside the supported slice");
                }
                requireSupportedNode(stored.getKey().node());
            }
        }
        for (ParentAssignment assignment : snapshot.parents().values()) {
            if (!assignment.isRoot()) {
                ParentPath path = assignment.provenancePath();
                if (path.steps().size() != 1 || !path.hasCertificates()) {
                    throw uncheckable("only one retained primitive parent edge is exportable");
                }
                requireDirectGroundEdge(path.steps().get(0).certificate());
            }
        }
    }

    private static void requireSupportedInsertion(CertifiedInsertionResult insertion)
            throws IOException {
        CanonicalizationResult result = insertion.canonicalization().structural();
        TypedENode source = result.source();
        TypedENode kernel = result.kernel();
        requireSupportedNode(source);
        requireSupportedNode(kernel);
        requireRigidContext(source.context());
        if (!source.context().equals(source.support())
                || !source.context().equals(result.effectiveSupport())
                || !source.context().equals(kernel.context())
                || !source.context().equals(insertion.insertedClass().exposedSlots())
                || !result.shape().node().equals(kernel)
                || !isIdentity(result.inclusion())
                || !isIdentity(result.sigma())
                || !isIdentity(result.omega())
                || !isIdentity(insertion.shapeWitness().instantiatingRenaming())) {
            throw uncheckable(
                    "support contraction or nonidentity iota/sigma/omega is not exportable");
        }
        if (!insertion.returnedInvocation().eclass().equals(
                    insertion.insertedClass())
                || !isIdentity(insertion.returnedInvocation().embedding())) {
            throw uncheckable("fresh insertion does not return its identity invocation");
        }
        for (TypedFindResult find : result.xi().findResults()) {
            if (!find.originalInvocation().equals(find.normalizedInvocation())
                    || !find.parentPath().hasCertificates()) {
                throw uncheckable("invocation normalization lacks an exact retained path");
            }
            for (ParentStep step : find.parentPath().steps()) {
                requireDirectGroundEdge(step.certificate());
            }
        }
    }

    private static void requireSupportedNode(TypedENode node) throws IOException {
        if (!node.operator().containerLaws().isEmpty()) {
            throw uncheckable("container operators are not exportable");
        }
        for (PortValue port : node.ports()) {
            if (!(port instanceof OnePort)) {
                throw uncheckable("only ONE_SLOT and ONE_TERM ports are exportable");
            }
            OnePort one = (OnePort) port;
            if (!(one.leaf() instanceof SlotPortLeaf)
                    && !(one.leaf() instanceof InvocationPortLeaf)) {
                throw uncheckable("unsupported ONE port leaf");
            }
            requireRigidContext(one.context());
        }
    }

    private static boolean onlySlotPorts(TypedENode node) {
        for (PortValue port : node.ports()) {
            if (!(port instanceof OnePort)
                    || !(((OnePort) port).leaf() instanceof SlotPortLeaf)) {
                return false;
            }
        }
        return !node.ports().isEmpty();
    }

    private static void requireRigidContext(TypedSlotContext context)
            throws IOException {
        for (int count : context.typeCounts().values()) {
            if (count > 1) {
                throw uncheckable(
                        "repeated same-type free slots require complete permutation export");
            }
        }
    }

    private static void requireDirectGroundEdge(ParentEdgeCertificate edge)
            throws IOException {
        TypedEqualityCertificate derivation = edge.endpointDerivation();
        if (derivation.category() == CertificateCategory.EQUATIONAL_SYMMETRY
                && derivation.premises().size() == 1) {
            derivation = derivation.premises().get(0);
        }
        if (!(derivation instanceof InputEquationCertificate)
                || !derivation.premises().isEmpty()
                || (derivation.category() != CertificateCategory.INPUT_EQUATION
                        && derivation.category() != CertificateCategory.REWRITE_AXIOM)) {
            throw uncheckable(
                    "parent edge is not a direct ground input equation or rewrite");
        }
        if (!edge.child().exposedSlots().equals(edge.parentInvocation().callerContext())) {
            throw uncheckable("parent edge endpoints do not share one ground context");
        }
    }

    private static void requireSupportedUnfolding(
            FiniteUnfoldingTree tree,
            CertifiedInsertionResult root,
            boolean parentFixture) throws IOException {
        if (!tree.rootInvocation().equals(root.returnedInvocation())) {
            throw uncheckable("finite unfolding belongs to another root");
        }
        int expectedHeight = parentFixture ? 2 : 1;
        int expectedChildren = parentFixture ? 1 : 0;
        if (tree.height() != expectedHeight
                || tree.invocationChildren().size() != expectedChildren) {
            throw uncheckable("finite unfolding is not the exact supported height");
        }
        requireUnfoldingNode(tree, new HashSet<>());
        FiniteUnfoldingIndexTrace trace = tree.indexTrace();
        if (!trace.finalContext().equals(tree.rootInvocation().callerContext())
                || !isIdentity(trace.finalWeakening())
                || trace.steps().size() != expectedHeight) {
            throw uncheckable("unfolding index trace is not the retained rigid trace");
        }
    }

    private static void requireUnfoldingNode(
            FiniteUnfoldingTree tree,
            Set<String> active) throws IOException {
        String key = tree.rootInvocation().toString() + "\u0000"
                + tree.selectedShape().structuralKey().stableString();
        if (!active.add(key)) {
            throw uncheckable("cyclic unfoldings are not exportable");
        }
        try {
            ShapeWitness witness = tree.shapeWitness();
            if (!witness.ambientSupport().equals(witness.exposedInterface())) {
                throw uncheckable("redundant unfolding coordinates are not exportable");
            }
            for (FiniteUnfoldingTree child : tree.invocationChildren()) {
                requireUnfoldingNode(child, active);
            }
        } finally {
            active.remove(key);
        }
    }

    private static boolean isIdentity(TypedEmbedding embedding) {
        if (!embedding.source().equals(embedding.codomain())) {
            return false;
        }
        for (TypedSlot slot : embedding.source()) {
            if (!slot.equals(embedding.mapping().get(slot))) {
                return false;
            }
        }
        return true;
    }

    private static IOException uncheckable(String detail) {
        return new IOException("UNCHECKABLE: " + detail);
    }

    private static final class Assembler {
        private final CertificateExportSession session;
        private final Slice slice;
        private final Tables tables = new Tables();
        private final Map<EClassId, String> witnessIds = new LinkedHashMap<>();
        private final Map<EClassId, InsertionWire> insertionWires = new LinkedHashMap<>();
        private final Map<CanonicalShape, InsertionWire> shapeWires = new LinkedHashMap<>();
        private final Map<StructuralKey, Node> snapshots = new LinkedHashMap<>();
        private final Map<String, Node> schemas = new TreeMap<>();
        private final Map<String, Node> operators = new TreeMap<>();
        private final Map<String, Node> axioms = new TreeMap<>();
        private final Map<String, Node> edgeProofs = new LinkedHashMap<>();

        private Assembler(CertificateExportSession session, Slice slice) {
            this.session = session;
            this.slice = slice;
            for (InsertionEvidence evidence : slice.insertions().values()) {
                EClassId id = evidence.insertion().insertedClass().id();
                witnessIds.put(id, "w/" + id + "@" + evidence.event().after().revision());
            }
        }

        private Node build() throws IOException {
            for (CertificateTraceEvent event : slice.events()) {
                if (event.kind() == CertificateTraceEvent.Kind.INSERT_FRESH) {
                    buildReplay(insertion(event));
                }
            }
            for (InsertionEvidence evidence : slice.insertions().values()) {
                InsertionWire wire = insertionWires.get(
                        evidence.insertion().insertedClass().id());
                Node definition = term(evidence.insertion()
                        .canonicalization().structural().kernel());
                tables.witness(leaf(
                        "witness",
                        wire.witnessId,
                        Long.toString(evidence.event().after().revision()),
                        wire.eclassId,
                        scalar(context(evidence.insertion().insertedClass()
                                .exposedSlots()), 0),
                        type(evidence.insertion().insertedClass().outputType()),
                        scalar(definition, 0)));
            }
            for (CertificateTraceEvent event : slice.events()) {
                snapshot(event.before());
                snapshot(event.after());
            }
            Node finalSnapshot = snapshot(session.finalSnapshot());
            for (InsertionWire wire : insertionWires.values()) {
                finishInsertion(wire, finalSnapshot);
            }
            buildEvents();
            Node unfolding = buildUnfolding(finalSnapshot);
            Node theory = theory();
            String theoryDigest = contentId(theory);
            Node vocabulary = vocabulary();
            String vocabularyDigest = contentId(vocabulary);
            Node publication = publication(
                    finalSnapshot, unfolding, theoryDigest);
            List<String> runIdentity = new ArrayList<>(
                    session.provenance().identityScalars());
            runIdentity.add(session.componentVersions());
            runIdentity.add(session.finalSnapshot().stateKey().stableString());
            runIdentity.add(session.canonicalObservation().stableString());
            runIdentity.add(theoryDigest);
            runIdentity.add(vocabularyDigest);
            String runId = contentId(node(
                    "producer-run",
                    runIdentity,
                    List.of()));
            return node(
                    "acgncert-bundle",
                    List.of(SCHEMA_VERSION),
                    List.of(
                            node(
                                    "metadata",
                                    session.provenance().metadataScalars(
                                            session.componentVersions(), runId),
                                    List.of()),
                            node(
                                    "manifest",
                                    List.of(theoryDigest, vocabularyDigest),
                                    List.of(theory, vocabulary)),
                            tables.section("contexts", tables.contexts),
                            tables.section("embeddings", tables.embeddings),
                            tables.section("terms", tables.terms),
                            tables.section("proofs", tables.proofs),
                            tables.section("witnesses", tables.witnesses),
                            tables.section("snapshots", tables.snapshots),
                            node("events", tables.events),
                            tables.section(
                                    "canonical-records", tables.canonicalRecords),
                            tables.section("unfoldings", tables.unfoldings),
                            publication));
        }

        private void buildReplay(CertifiedInsertionResult insertion)
                throws IOException {
            CanonicalizationResult result = insertion.canonicalization().structural();
            Node source = term(result.source());
            Node normalized = term(result.leaderKernel().ambientLeaderNode());
            Node kernel = term(result.kernel());
            if (!normalized.equals(kernel)) {
                throw uncheckable(
                        "supported replay requires an identity exact-context restriction");
            }
            Node gamma = context(result.source().context());
            Node delta = context(result.effectiveSupport());
            Node iota = embedding(result.inclusion());
            Node sigma = embedding(result.sigma());
            Node omega = embedding(result.omega());

            List<PathWire> paths = parentPaths(result);
            List<Node> pathRecords = new ArrayList<>();
            for (PathWire path : paths) {
                List<Node> edges = path.edgeProofs.stream()
                        .map(proof -> leaf("edge-ref", scalar(proof, 0))).toList();
                pathRecords.add(node(
                        "parent-path",
                        List.of(
                                encodePath(path.path),
                                path.initialWitness,
                                path.leaderWitness,
                                scalar(path.finalInvocation, 0)),
                        edges));
            }
            List<Node> premises = new ArrayList<>();
            for (int index = paths.size() - 1; index >= 0; index--) {
                premises.addAll(paths.get(index).edgeProofs);
            }
            Node structural = proof(
                    "REFL",
                    gamma,
                    "TERM",
                    type(result.source().outputType()),
                    normalized,
                    normalized,
                    List.of(),
                    leaf("refl", scalar(normalized, 0)));
            premises.add(structural);
            Node replay = proof(
                    "KERNEL_REPLAY",
                    gamma,
                    "TERM",
                    type(result.source().outputType()),
                    source,
                    normalized,
                    premises,
                    node(
                            "kernel-replay",
                            List.of(
                                    scalar(source, 0),
                                    scalar(gamma, 0),
                                    scalar(kernel, 0),
                                    scalar(delta, 0),
                                    scalar(iota, 0),
                                    scalar(sigma, 0),
                                    scalar(omega, 0)),
                            List.of(
                                    node("parent-paths", pathRecords),
                                    node("port-normalizations", List.of()),
                                    leaf("structural-proof", scalar(structural, 0)),
                                    node(
                                            "effective-support",
                                            result.effectiveSupport().slots().stream()
                                                    .sorted(Comparator.comparing(
                                                            Assembler::slotOrder))
                                                    .map(Assembler::slotName)
                                                    .toList(),
                                            List.of()))));
            emitLiftedCongruence(result, source, normalized, paths);
            InsertionEvidence evidence = slice.insertions().get(
                    insertion.insertedClass().id());
            InsertionWire wire = new InsertionWire(
                    insertion,
                    witnessIds.get(insertion.insertedClass().id()),
                    insertion.insertedClass().id().toString(),
                    shapeId(result.shape()),
                    source,
                    kernel,
                    replay,
                    evidence);
            insertionWires.put(insertion.insertedClass().id(), wire);
            shapeWires.put(result.shape(), wire);
        }

        private void emitLiftedCongruence(
                CanonicalizationResult result,
                Node source,
                Node normalized,
                List<PathWire> paths) throws IOException {
            if (source.equals(normalized)) {
                return;
            }
            List<Node> changedPorts = new ArrayList<>();
            int pathIndex = 0;
            for (LeaderPortTrace trace : result.xi().portTraces()) {
                if (trace.sourcePort().equals(trace.normalizedPort())) {
                    continue;
                }
                if (trace.kind() != LeaderPortTrace.Kind.INVOCATION
                        || pathIndex >= paths.size()
                        || paths.get(pathIndex).edgeProofs.size() != 1) {
                    throw uncheckable("changed port cannot be lifted in the exact ONE slice");
                }
                Node left = term(trace.sourcePort());
                Node right = term(trace.normalizedPort());
                Node edge = paths.get(pathIndex).edgeProofs.get(0);
                changedPorts.add(proof(
                        "CONGRUENCE",
                        context(trace.sourcePort().context()),
                        "PORT",
                        schemaId(trace.sourcePort().schema()),
                        left,
                        right,
                        List.of(edge),
                        leaf("congruence", scalar(left, 0), scalar(right, 0))));
                pathIndex++;
            }
            Node app = proof(
                    "CONGRUENCE",
                    context(result.source().context()),
                    "TERM",
                    type(result.source().outputType()),
                    source,
                    normalized,
                    changedPorts,
                    leaf("congruence", scalar(source, 0), scalar(normalized, 0)));
            Node reflexive = proof(
                    "REFL",
                    context(result.source().context()),
                    "TERM",
                    type(result.source().outputType()),
                    normalized,
                    normalized,
                    List.of(),
                    leaf("refl", scalar(normalized, 0)));
            proof(
                    "TRANS",
                    context(result.source().context()),
                    "TERM",
                    type(result.source().outputType()),
                    source,
                    normalized,
                    List.of(app, reflexive),
                    node("trans", List.of()));
        }

        private List<PathWire> parentPaths(CanonicalizationResult result)
                throws IOException {
            List<List<Integer>> occurrencePaths = invocationPaths(result.source());
            List<TypedFindResult> finds = result.xi().findResults();
            if (occurrencePaths.size() != finds.size()) {
                throw uncheckable("leader trace does not cover every invocation occurrence");
            }
            List<PathWire> paths = new ArrayList<>();
            for (int index = 0; index < finds.size(); index++) {
                TypedFindResult find = finds.get(index);
                List<Node> edgeNodes = new ArrayList<>();
                for (ParentStep step : find.parentPath().steps()) {
                    edgeNodes.add(parentEdgeProof(step.certificate()));
                }
                paths.add(new PathWire(
                        occurrencePaths.get(index),
                        witnessId(find.originalInvocation().eclass()),
                        witnessId(find.leaderInvocation().eclass()),
                        term(find.leaderInvocation()),
                        List.copyOf(edgeNodes)));
            }
            return List.copyOf(paths);
        }

        private void finishInsertion(InsertionWire wire, Node finalSnapshot)
                throws IOException {
            CanonicalizationResult result = wire.insertion
                    .canonicalization().structural();
            Node orbitSource = term(result.shape().node().act(result.witness()));
            Node representative = term(result.kernel());
            if (!orbitSource.equals(representative)) {
                throw uncheckable("supported canonical orbit is not rigid identity");
            }
            Node identity = embedding(TypedEmbedding.identity(
                    result.effectiveSupport()));
            List<Node> groups = new ArrayList<>();
            for (InvocationOccurrence occurrence : invocationOccurrences(
                    result.shape().node().act(result.witness()))) {
                groups.add(node(
                        "leader-group",
                        List.of(
                                encodePath(occurrence.path),
                                witnessId(occurrence.invocation.eclass())),
                        List.of()));
            }
            Node orbit = proof(
                    "CANONICAL_ORBIT",
                    context(result.effectiveSupport()),
                    "TERM",
                    type(result.kernel().outputType()),
                    orbitSource,
                    representative,
                    List.of(),
                    node(
                            "canonical-orbit",
                            List.of(
                                    scalar(orbitSource, 0),
                                    scalar(context(result.effectiveSupport()), 0),
                                    scalar(representative, 0),
                                    "1"),
                            List.of(
                                    node("free-renamings", List.of(
                                            leaf("embedding-ref", scalar(identity, 0)))),
                                    node(
                                            "leader-groups",
                                            List.of(scalar(finalSnapshot, 0), "complete"),
                                            groups),
                                    node("orbit-members", List.of(
                                            leaf("term-ref", scalar(representative, 0)))))));
            Node fresh = proof(
                    "FRESH_WITNESS",
                    context(result.effectiveSupport()),
                    "TERM",
                    type(result.kernel().outputType()),
                    representative,
                    representative,
                    List.of(wire.replay),
                    leaf(
                            "fresh-witness",
                            wire.witnessId,
                            scalar(representative, 0),
                            scalar(embedding(result.inclusion()), 0),
                            scalar(wire.replay, 0)));
            Node canonical = tables.canonical(withContentId(
                    "canonical-record",
                    List.of(scalar(orbit, 0), scalar(representative, 0)),
                    List.of(leaf("source-replay-ref", scalar(wire.replay, 0)))));
            wire.orbit = orbit;
            wire.fresh = fresh;
            wire.canonical = canonical;
        }

        private Node parentEdgeProof(ParentEdgeCertificate edge)
                throws IOException {
            String key = edge.structuralKey().stableString();
            Node prior = edgeProofs.get(key);
            if (prior != null) {
                return prior;
            }
            TypedEqualityCertificate supplied = edge.endpointDerivation();
            boolean reversed = supplied.category()
                    == CertificateCategory.EQUATIONAL_SYMMETRY;
            TypedEqualityCertificate ground = reversed
                    ? supplied.premises().get(0) : supplied;
            if (!(ground instanceof InputEquationCertificate)) {
                throw uncheckable("parent edge lacks a serializable ground origin");
            }
            InputEquationCertificate equation = (InputEquationCertificate) ground;
            Node child = term(TypedInvocation.identity(edge.child()));
            Node parent = term(edge.parentInvocation());
            Node axiomLeft = reversed ? parent : child;
            Node axiomRight = reversed ? child : parent;
            String axiomId = axiomId(equation.origin());
            registerAxiom(axiomId, pattern(axiomLeft), pattern(axiomRight));
            Node axiom = proof(
                    "AXIOM",
                    context(edge.child().exposedSlots()),
                    "TERM",
                    type(edge.child().outputType()),
                    axiomLeft,
                    axiomRight,
                    List.of(),
                    node(
                            "axiom-instance",
                            List.of(
                                    axiomId,
                                    scalar(context(edge.child().exposedSlots()), 0)),
                            List.of(
                                    node("type-substitution", List.of()),
                                    node("term-substitution", List.of()),
                                    node("side-evidence", List.of()))));
            Node oriented = axiom;
            if (reversed) {
                oriented = proof(
                        "SYM",
                        context(edge.child().exposedSlots()),
                        "TERM",
                        type(edge.child().outputType()),
                        child,
                        parent,
                        List.of(axiom),
                        node("sym", List.of()));
            }
            Node edgeProof = proof(
                    "PARENT_EDGE",
                    context(edge.child().exposedSlots()),
                    "TERM",
                    type(edge.child().outputType()),
                    child,
                    parent,
                    List.of(oriented),
                    leaf(
                            "parent-edge",
                            witnessId(edge.child()),
                            witnessId(edge.parent()),
                            scalar(embedding(edge.embedding()), 0)));
            edgeProofs.put(key, edgeProof);
            return edgeProof;
        }

        private void registerAxiom(String id, Node left, Node right)
                throws IOException {
            Node axiom = node(
                    "axiom",
                    List.of(id),
                    List.of(
                            left,
                            right,
                            node("type-variables", List.of(), List.of()),
                            node("term-variables", List.of()),
                            node("side-conditions", List.of())));
            internManifest(axioms, id, axiom, "axiom");
        }

        private Node pattern(Node term) throws IOException {
            String kind = term.scalars.get(1);
            List<String> scalars = new ArrayList<>();
            scalars.add(kind);
            scalars.add(term.scalars.get(3));
            scalars.add(term.scalars.get(4));
            scalars.add(term.scalars.get(5));
            scalars.addAll(term.scalars.subList(6, term.scalars.size()));
            List<Node> children = new ArrayList<>();
            for (Node child : term.children) {
                Node childTerm = tables.terms.get(scalar(child, 0));
                if (childTerm == null) {
                    throw uncheckable("axiom pattern references an absent term");
                }
                children.add(pattern(childTerm));
            }
            return node("pattern", scalars, children);
        }

        private Node snapshot(CertificateTraceSnapshot snapshot)
                throws IOException {
            Node existing = snapshots.get(snapshot.stateKey());
            if (existing != null) {
                return existing;
            }
            List<Node> classes = new ArrayList<>();
            for (TypedEClassRecord record : snapshot.classes().values()) {
                classes.add(leaf(
                        "class",
                        record.id().toString(),
                        witnessId(record.interfaceView()),
                        scalar(context(record.exposedSlots()), 0),
                        type(record.outputType())));
            }
            List<Node> parents = new ArrayList<>();
            for (ParentAssignment assignment : snapshot.parents().values()) {
                if (assignment.isRoot()) {
                    continue;
                }
                ParentStep step = assignment.provenancePath().steps().get(0);
                Node proof = parentEdgeProof(step.certificate());
                Node map = embedding(assignment.parentInvocation().embedding());
                parents.add(leaf(
                        "parent",
                        edgeId(step.certificate()),
                        assignment.child().id().toString(),
                        assignment.parentInvocation().eclass().id().toString(),
                        scalar(map, 0),
                        scalar(proof, 0)));
            }
            List<Node> shapes = new ArrayList<>();
            for (ParentRecordKey key : snapshot.shapeCertificates().keySet()) {
                InsertionWire wire = shapeWires.get(key.shape());
                if (wire == null) {
                    throw uncheckable("stored shape has no retained source insertion");
                }
                Node shapeTerm = term(key.shape().node());
                shapes.add(leaf(
                        "shape",
                        wire.shapeId,
                        key.owner().toString(),
                        scalar(shapeTerm, 0),
                        scalar(wire.replay, 0)));
            }
            List<Node> hashes = new ArrayList<>();
            for (Map.Entry<CanonicalShape, EClassId> entry
                    : snapshot.hashCons().entrySet()) {
                hashes.add(leaf(
                        "hash-owner",
                        termKey(term(entry.getKey().node())),
                        entry.getValue().toString()));
            }
            List<Node> parentUses = new ArrayList<>();
            for (Map.Entry<EClassId, Set<ParentRecordKey>> entry
                    : snapshot.parentUses().entrySet()) {
                for (ParentRecordKey use : entry.getValue()) {
                    InsertionWire wire = shapeWires.get(use.shape());
                    if (wire == null) {
                        throw uncheckable("parent-use index names an unknown shape");
                    }
                    parentUses.add(leaf(
                            "parent-use", entry.getKey().toString(), wire.shapeId));
                }
            }
            List<Node> dirty = new ArrayList<>();
            for (ParentRecordKey key : snapshot.dirtyParents()) {
                InsertionWire wire = shapeWires.get(key.shape());
                if (wire == null) {
                    throw uncheckable("dirty queue names an unknown shape");
                }
                dirty.add(leaf("dirty-shape", wire.shapeId));
            }
            Node encoded = tables.snapshot(
                    snapshot.revision(),
                    snapshot.status().name(),
                    classes,
                    parents,
                    shapes,
                    hashes,
                    parentUses,
                    List.of(),
                    dirty);
            snapshots.put(snapshot.stateKey(), encoded);
            return encoded;
        }

        private void buildEvents() throws IOException {
            for (CertificateTraceEvent event : slice.events()) {
                Node payload;
                switch (event.kind()) {
                    case INSERT_FRESH -> {
                        InsertionWire wire = insertionWires.get(
                                insertion(event).insertedClass().id());
                        payload = leaf(
                                "insert-fresh",
                                wire.eclassId,
                                wire.shapeId,
                                scalar(wire.replay, 0),
                                scalar(wire.orbit, 0),
                                scalar(wire.fresh, 0));
                    }
                    case UNION -> payload = leaf(
                            "union",
                            scalar(parentEdgeProof(
                                    ((CertificateTracePayload.Union) event.payload())
                                            .certificate()), 0));
                    case REBUILD_COMPLETE -> payload = leaf(
                            "rebuild-complete",
                            Boolean.toString(event.after().revision()
                                    != event.before().revision()));
                    default -> throw new AssertionError(event.kind());
                }
                tables.event(node(
                        "event",
                        List.of(
                                Long.toString(event.sequence()),
                                event.kind().name(),
                                scalar(snapshot(event.before()), 0),
                                scalar(snapshot(event.after()), 0)),
                        List.of(payload)));
            }
        }

        private Node buildUnfolding(Node finalSnapshot) throws IOException {
            FiniteUnfoldingTree tree = slice.unfolding();
            List<FiniteUnfoldingStepIndex> steps = tree.indexTrace().steps();
            StepCursor cursor = new StepCursor(steps);
            RepWire rep = rep(tree, cursor);
            if (!cursor.exhausted()) {
                throw uncheckable("unfolding index trace contains extra steps");
            }
            return tables.unfolding(withContentId(
                    "unfolding",
                    List.of(
                            scalar(rep.invocation, 0),
                            Integer.toString(tree.height()),
                            scalar(rep.normalized, 0),
                            scalar(finalSnapshot, 0)),
                    List.of(rep.rep)));
        }

        private RepWire rep(FiniteUnfoldingTree tree, StepCursor cursor)
                throws IOException {
            FiniteUnfoldingStepIndex step = cursor.next();
            if (!step.selectedShape().equals(tree.selectedShape())
                    || !step.shapeWitness().equals(tree.shapeWitness())
                    || !step.invocationAtStep().equals(tree.rootInvocation())
                    || !step.freshCoordinates().isEmpty()) {
                throw uncheckable("unfolding index step differs from the retained Rep node");
            }
            TypedENode restored = tree.restoredRoot().act(step.restoredExtension());
            Node restoredTerm = term(restored);
            List<InvocationOccurrence> occurrences = invocationOccurrences(restored);
            if (occurrences.size() != tree.invocationChildren().size()) {
                throw uncheckable("Rep children do not cover restored invocations");
            }
            List<RepWire> children = new ArrayList<>();
            List<Node> childRecords = new ArrayList<>();
            for (int index = 0; index < tree.invocationChildren().size(); index++) {
                RepWire child = rep(tree.invocationChildren().get(index), cursor);
                children.add(child);
                childRecords.add(node(
                        "rep-child",
                        List.of(encodePath(occurrences.get(index).path)),
                        List.of(child.rep)));
            }
            Node normalized = expandedTerm(restored, children);
            InsertionWire shape = shapeWires.get(tree.selectedShape());
            if (shape == null) {
                throw uncheckable("unfolding selects an unretained shape");
            }
            Node invocation = term(step.invocationAtStep());
            Node rep = node(
                    "rep",
                    List.of(
                            scalar(invocation, 0),
                            shape.shapeId,
                            scalar(restoredTerm, 0),
                            Integer.toString(tree.height())),
                    List.of(
                            leaf(
                                    "ambient-extension",
                                    scalar(embedding(step.restoredExtension()), 0)),
                            node("redundant-assignments", List.of()),
                            node("rep-children", childRecords)));
            return new RepWire(rep, invocation, normalized);
        }

        private Node expandedTerm(TypedENode node, List<RepWire> children)
                throws IOException {
            int cursor = 0;
            List<Node> ports = new ArrayList<>();
            for (PortValue port : node.ports()) {
                OnePort one = (OnePort) port;
                if (one.leaf() instanceof SlotPortLeaf) {
                    ports.add(term(one));
                } else {
                    if (cursor >= children.size()) {
                        throw uncheckable("expanded term lacks an unfolding child");
                    }
                    Node child = children.get(cursor++).normalized;
                    ports.add(tables.term(
                            "ONE_TERM",
                            context(one.context()),
                            "PORT",
                            schemaId(one.schema()),
                            schemaId(one.schema()),
                            List.of(),
                            List.of(child)));
                }
            }
            if (cursor != children.size()) {
                throw uncheckable("expanded term has extra unfolding children");
            }
            return tables.term(
                    "APP",
                    context(node.context()),
                    "TERM",
                    type(node.outputType()),
                    operatorId(node.operator()),
                    List.of(),
                    ports);
        }

        private Node publication(
                Node finalSnapshot,
                Node unfolding,
                String theoryDigest) throws IOException {
            List<Node> ec = new ArrayList<>();
            for (TypedEClassRecord record : session.finalSnapshot().classes().values()) {
                ec.add(leaf("ec", record.id().toString(), witnessId(record.interfaceView())));
            }
            List<Node> pc = new ArrayList<>();
            for (ParentAssignment assignment
                    : session.finalSnapshot().parents().values()) {
                if (assignment.isRoot()) {
                    continue;
                }
                ParentEdgeCertificate edge = assignment.provenancePath()
                        .steps().get(0).certificate();
                pc.add(leaf(
                        "pc",
                        edgeId(edge),
                        scalar(parentEdgeProof(edge), 0)));
            }
            InsertionWire root = insertionWires.get(
                    slice.rootInsertion().insertedClass().id());
            String normalized = unfolding.scalars.get(3);
            return node(
                    "publication",
                    List.of(
                            scalar(finalSnapshot, 0),
                            Long.toString(session.finalSnapshot().revision()),
                            scalar(root.source, 0),
                            normalized,
                            theoryDigest),
                    List.of(
                            tables.sortedSection("ec-evidence", ec),
                            tables.sortedSection("pc-evidence", pc),
                            node("sc-evidence", List.of()),
                            node(
                                    "canonical-refs",
                                    tables.canonicalRecords.values().stream()
                                            .map(value -> leaf(
                                                    "canonical-ref", scalar(value, 0)))
                                            .toList()),
                            node(
                                    "unfolding-refs",
                                    List.of(leaf(
                                            "unfolding-ref", scalar(unfolding, 0))))));
        }

        private Node theory() {
            return node(
                    "theory",
                    CertificateTheoryManifest.scalars(),
                    List.of(node("axioms", new ArrayList<>(axioms.values()))));
        }

        private Node vocabulary() {
            return node(
                    "vocabulary",
                    List.of(CertificateTheoryManifest.VOCABULARY_POLICY),
                    List.of(
                            node("schemas", new ArrayList<>(schemas.values())),
                            node("operators", new ArrayList<>(operators.values())),
                            node("binders", List.of())));
        }

        private Node context(TypedSlotContext context) throws IOException {
            return tables.context(context);
        }

        private Node embedding(TypedEmbedding embedding) throws IOException {
            return tables.embedding(embedding);
        }

        private Node term(TypedENode node) throws IOException {
            String operator = operatorId(node.operator());
            List<Node> children = new ArrayList<>();
            for (PortValue port : node.ports()) {
                children.add(term(port));
            }
            return tables.term(
                    "APP",
                    context(node.context()),
                    "TERM",
                    type(node.outputType()),
                    operator,
                    List.of(),
                    children);
        }

        private Node term(PortValue port) throws IOException {
            if (!(port instanceof OnePort)) {
                throw uncheckable("non-ONE term reached the exact serializer");
            }
            OnePort one = (OnePort) port;
            String schema = schemaId(one.schema());
            if (one.leaf() instanceof SlotPortLeaf) {
                return tables.term(
                        "ONE_SLOT",
                        context(one.context()),
                        "PORT",
                        schema,
                        schema,
                        List.of(slotName(((SlotPortLeaf) one.leaf()).slot())),
                        List.of());
            }
            TypedInvocation invocation =
                    ((InvocationPortLeaf) one.leaf()).invocation();
            return tables.term(
                    "ONE_TERM",
                    context(one.context()),
                    "PORT",
                    schema,
                    schema,
                    List.of(),
                    List.of(term(invocation)));
        }

        private Node term(TypedInvocation invocation) throws IOException {
            return tables.term(
                    "INVOKE",
                    context(invocation.callerContext()),
                    "TERM",
                    type(invocation.outputType()),
                    witnessId(invocation.eclass()),
                    List.of(scalar(embedding(invocation.embedding()), 0)),
                    List.of());
        }

        private Node proof(
                String variant,
                Node context,
                String sortKind,
                String sortValue,
                Node left,
                Node right,
                List<Node> premises,
                Node payload) throws IOException {
            return tables.proof(
                    variant, context, sortKind, sortValue,
                    left, right, premises, payload);
        }

        private String schemaId(PortSchema schema) throws IOException {
            if (!(schema instanceof OnePortSchema)) {
                throw uncheckable("only OnePortSchema is exportable");
            }
            String value = type(((OnePortSchema) schema).type());
            String id = "schema/" + contentId(node(
                    "one-schema-id", List.of(value), List.of()));
            internManifest(
                    schemas,
                    id,
                    leaf("schema", id, "ONE", value),
                    "schema");
            return id;
        }

        private String operatorId(InstantiatedOperator operator)
                throws IOException {
            String id = "operator/" + contentId(node(
                    "operator-id",
                    List.of(operator.structuralKey().stableString()),
                    List.of()));
            List<Node> ports = new ArrayList<>();
            for (PortSchema schema : operator.portSchemas()) {
                ports.add(leaf("schema-ref", schemaId(schema)));
            }
            internManifest(
                    operators,
                    id,
                    node("operator", List.of(id, type(operator.outputType())), ports),
                    "operator");
            return id;
        }

        private String witnessId(TypedEClassInterface eclass) throws IOException {
            String id = witnessIds.get(eclass.id());
            InsertionEvidence evidence = slice.insertions().get(eclass.id());
            if (id == null || evidence == null
                    || !evidence.insertion().insertedClass().equals(eclass)) {
                throw uncheckable("invocation references an unretained or stale e-class");
            }
            return id;
        }

        private String axiomId(CertificateOrigin origin) {
            return "axiom/" + contentId(node(
                    "origin-derived-axiom-id",
                    List.of(
                            origin.kind().name(),
                            origin.sourceArtifact(),
                            origin.declarationId(),
                            Integer.toString(origin.ordinal())),
                    List.of()));
        }

        private String shapeId(CanonicalShape shape) {
            return "shape/" + contentId(node(
                    "producer-shape-id",
                    List.of(shape.structuralKey().stableString()),
                    List.of()));
        }

        private String edgeId(ParentEdgeCertificate edge) {
            return "edge/" + contentId(node(
                    "producer-parent-edge-id",
                    List.of(edge.structuralKey().stableString()),
                    List.of()));
        }

        private String termKey(Node term) throws IOException {
            return contentId(tables.structuralTerm(term));
        }

        private static String slotName(TypedSlot slot) {
            return slot.toString();
        }

        private static String slotOrder(TypedSlot slot) {
            return type(slot.type()) + "\u0000" + slotName(slot);
        }

        private static String type(GraphType type) {
            return type.toString();
        }

        private static String encodePath(List<Integer> path) {
            return String.join("/", path.stream().map(Object::toString).toList());
        }

        private static void internManifest(
                Map<String, Node> target,
                String id,
                Node value,
                String kind) throws IOException {
            Node prior = target.putIfAbsent(id, value);
            if (prior != null && !prior.equals(value)) {
                throw uncheckable(kind + " ID collision at " + id);
            }
        }
    }

    private static List<List<Integer>> invocationPaths(TypedENode node) {
        return invocationOccurrences(node).stream()
                .map(InvocationOccurrence::path).toList();
    }

    private static List<InvocationOccurrence> invocationOccurrences(TypedENode node) {
        List<InvocationOccurrence> result = new ArrayList<>();
        for (int index = 0; index < node.ports().size(); index++) {
            OnePort port = (OnePort) node.ports().get(index);
            if (port.leaf() instanceof InvocationPortLeaf) {
                result.add(new InvocationOccurrence(
                        List.of(index, 0),
                        ((InvocationPortLeaf) port.leaf()).invocation()));
            }
        }
        return List.copyOf(result);
    }

    private static byte[] encode(Node root) {
        byte[] payload = encodeNode(root);
        try {
            ByteArrayOutputStream bytes = new ByteArrayOutputStream(
                    MAGIC.length + 2 + 8 + payload.length + 32);
            DataOutputStream output = new DataOutputStream(bytes);
            output.write(MAGIC);
            output.writeShort(FORMAT_VERSION);
            output.writeLong(payload.length);
            output.write(payload);
            output.write(sha256(payload));
            output.flush();
            return bytes.toByteArray();
        } catch (IOException exception) {
            throw new AssertionError("Byte-array encoding cannot fail", exception);
        }
    }

    private static byte[] encodeNode(Node root) {
        try {
            ByteArrayOutputStream bytes = new ByteArrayOutputStream();
            DataOutputStream output = new DataOutputStream(bytes);
            writeNode(output, root);
            output.flush();
            return bytes.toByteArray();
        } catch (IOException exception) {
            throw new AssertionError("Byte-array encoding cannot fail", exception);
        }
    }

    private static void writeNode(DataOutputStream output, Node node)
            throws IOException {
        writeString(output, node.tag);
        output.writeInt(node.scalars.size());
        for (String scalar : node.scalars) {
            writeString(output, scalar);
        }
        output.writeInt(node.children.size());
        for (Node child : node.children) {
            writeNode(output, child);
        }
    }

    private static void writeString(DataOutputStream output, String value)
            throws IOException {
        byte[] encoded = value.getBytes(StandardCharsets.UTF_8);
        output.writeInt(encoded.length);
        output.write(encoded);
    }

    private static byte[] sha256(byte[] bytes) {
        try {
            return MessageDigest.getInstance("SHA-256").digest(bytes);
        } catch (NoSuchAlgorithmException exception) {
            throw new AssertionError("JDK 17 must provide SHA-256", exception);
        }
    }

    private static String contentId(Node node) {
        return HexFormat.of().formatHex(sha256(encodeNode(node)));
    }

    private static Node withContentId(
            String tag,
            List<String> contentScalars,
            List<Node> children) {
        List<String> scalars = new ArrayList<>(contentScalars.size() + 1);
        scalars.add("");
        scalars.addAll(contentScalars);
        Node provisional = node(tag, scalars, children);
        scalars.set(0, contentId(node(
                tag + "/content",
                provisional.scalars.subList(1, provisional.scalars.size()),
                provisional.children)));
        return node(tag, scalars, children);
    }

    private static Node leaf(String tag, String... scalars) {
        return node(tag, Arrays.asList(scalars), List.of());
    }

    private static Node node(String tag, List<Node> children) {
        return node(tag, List.of(), children);
    }

    private static Node node(String tag, List<String> scalars, List<Node> children) {
        return new Node(tag, scalars, children);
    }

    private static String scalar(Node node, int index) {
        return node.scalars.get(index);
    }

    private static final class Tables {
        private final Map<String, Node> contexts = new TreeMap<>();
        private final Map<String, Node> embeddings = new TreeMap<>();
        private final Map<String, Node> terms = new TreeMap<>();
        private final Map<String, Node> proofs = new TreeMap<>();
        private final Map<String, Node> witnesses = new TreeMap<>();
        private final Map<String, Node> snapshots = new TreeMap<>();
        private final List<Node> events = new ArrayList<>();
        private final Map<String, Node> canonicalRecords = new TreeMap<>();
        private final Map<String, Node> unfoldings = new TreeMap<>();

        private Node context(TypedSlotContext context) throws IOException {
            List<TypedSlot> ordered = new ArrayList<>(context.slots());
            ordered.sort(Comparator.comparing(Assembler::slotOrder));
            List<Node> slots = ordered.stream()
                    .map(slot -> leaf(
                            "slot", Assembler.slotName(slot), Assembler.type(slot.type())))
                    .toList();
            return internContent(contexts, withContentId(
                    "context", List.of(), slots), "context");
        }

        private Node embedding(TypedEmbedding embedding) throws IOException {
            if (!embedding.mapping().keySet().equals(embedding.source().slots())
                    || !embedding.isInjective()
                    || !embedding.isTypePreserving()) {
                throw uncheckable("embedding is missing, duplicate, or ill typed");
            }
            Node source = context(embedding.source());
            Node target = context(embedding.codomain());
            String kind = embedding.isRenaming() ? "BIJECTION" : "INJECTION";
            List<TypedSlot> ordered = new ArrayList<>(embedding.source().slots());
            ordered.sort(Comparator.comparing(Assembler::slotOrder));
            List<Node> images = new ArrayList<>();
            Set<TypedSlot> targets = new HashSet<>();
            for (TypedSlot slot : ordered) {
                TypedSlot image = embedding.mapping().get(slot);
                if (image == null || !targets.add(image)
                        || !embedding.codomain().contains(image)
                        || !slot.type().equals(image.type())) {
                    throw uncheckable("embedding image is absent, duplicate, or ill typed");
                }
                images.add(leaf(
                        "image", Assembler.slotName(slot), Assembler.slotName(image)));
            }
            if ("BIJECTION".equals(kind)
                    && targets.size() != embedding.codomain().size()) {
                throw uncheckable("embedding falsely claims to be a bijection");
            }
            return internContent(
                    embeddings,
                    withContentId(
                            "embedding",
                            List.of(kind, scalar(source, 0), scalar(target, 0)),
                            images),
                    "embedding");
        }

        private Node term(
                String kind,
                Node context,
                String sortKind,
                String sortValue,
                String symbol,
                List<String> attributes,
                List<Node> children) throws IOException {
            List<String> scalars = new ArrayList<>(List.of(
                    kind, scalar(context, 0), sortKind, sortValue, symbol));
            scalars.addAll(attributes);
            Node record = withContentId(
                    "term",
                    scalars,
                    children.stream()
                            .map(child -> leaf("term-ref", scalar(child, 0)))
                            .toList());
            return internContent(terms, record, "term");
        }

        private Node structuralTerm(Node term) throws IOException {
            if (!"term".equals(term.tag) || term.scalars.size() < 6) {
                throw uncheckable("recursive term key received a malformed term");
            }
            List<String> scalars = new ArrayList<>();
            scalars.add(term.scalars.get(2));
            scalars.add(term.scalars.get(3));
            scalars.add(term.scalars.get(4));
            scalars.add(term.scalars.get(5));
            scalars.addAll(term.scalars.subList(6, term.scalars.size()));
            List<Node> children = new ArrayList<>();
            for (Node child : term.children) {
                Node referenced = terms.get(scalar(child, 0));
                if (referenced == null) {
                    throw uncheckable("recursive term key has a dangling child");
                }
                children.add(structuralTerm(referenced));
            }
            return node("term-key/" + term.scalars.get(1), scalars, children);
        }

        private Node proof(
                String variant,
                Node context,
                String sortKind,
                String sortValue,
                Node left,
                Node right,
                List<Node> premises,
                Node payload) throws IOException {
            Node record = withContentId(
                    "proof",
                    List.of(
                            variant,
                            scalar(context, 0),
                            sortKind,
                            sortValue,
                            scalar(left, 0),
                            scalar(right, 0)),
                    List.of(
                            node("premises", premises.stream()
                                    .map(proof -> leaf("proof-ref", scalar(proof, 0)))
                                    .toList()),
                            payload));
            return internContent(proofs, record, "proof");
        }

        private void witness(Node witness) throws IOException {
            internNamed(witnesses, scalar(witness, 0), witness, "witness");
        }

        private Node snapshot(
                long revision,
                String status,
                List<Node> classes,
                List<Node> parents,
                List<Node> shapes,
                List<Node> hashes,
                List<Node> parentUses,
                List<Node> symmetries,
                List<Node> dirty) throws IOException {
            Node record = withContentId(
                    "snapshot",
                    List.of(Long.toString(revision), status),
                    List.of(
                            sortedSection("classes", classes),
                            sortedSection("parents", parents),
                            sortedSection("shapes", shapes),
                            sortedSection("hash-cons", hashes),
                            sortedSection("parent-uses", parentUses),
                            sortedSection("symmetries", symmetries),
                            sortedSection("dirty", dirty)));
            return internContent(snapshots, record, "snapshot");
        }

        private void event(Node event) {
            events.add(event);
        }

        private Node canonical(Node record) throws IOException {
            return internContent(
                    canonicalRecords, record, "canonical record");
        }

        private Node unfolding(Node record) throws IOException {
            return internContent(unfoldings, record, "unfolding");
        }

        private Node section(String tag, Map<String, Node> values) {
            return node(tag, new ArrayList<>(values.values()));
        }

        private Node sortedSection(String tag, List<Node> values) {
            List<Node> sorted = new ArrayList<>(values);
            sorted.sort(Comparator.comparing(value -> scalar(value, 0)));
            return node(tag, sorted);
        }

        private static Node internContent(
                Map<String, Node> target,
                Node record,
                String kind) throws IOException {
            return internNamed(target, scalar(record, 0), record, kind);
        }

        private static Node internNamed(
                Map<String, Node> target,
                String id,
                Node record,
                String kind) throws IOException {
            Node prior = target.putIfAbsent(id, record);
            if (prior != null && !prior.equals(record)) {
                throw uncheckable(kind + " ID collision at " + id);
            }
            return prior == null ? record : prior;
        }
    }

    private static final class InsertionWire {
        private final CertifiedInsertionResult insertion;
        private final String witnessId;
        private final String eclassId;
        private final String shapeId;
        private final Node source;
        private final Node kernel;
        private final Node replay;
        @SuppressWarnings("unused")
        private final InsertionEvidence evidence;
        private Node orbit;
        private Node fresh;
        @SuppressWarnings("unused")
        private Node canonical;

        private InsertionWire(
                CertifiedInsertionResult insertion,
                String witnessId,
                String eclassId,
                String shapeId,
                Node source,
                Node kernel,
                Node replay,
                InsertionEvidence evidence) {
            this.insertion = insertion;
            this.witnessId = witnessId;
            this.eclassId = eclassId;
            this.shapeId = shapeId;
            this.source = source;
            this.kernel = kernel;
            this.replay = replay;
            this.evidence = evidence;
        }
    }

    private static final class StepCursor {
        private final List<FiniteUnfoldingStepIndex> steps;
        private int index;

        private StepCursor(List<FiniteUnfoldingStepIndex> steps) {
            this.steps = steps;
        }

        private FiniteUnfoldingStepIndex next() throws IOException {
            if (index >= steps.size()) {
                throw uncheckable("unfolding index trace ended early");
            }
            return steps.get(index++);
        }

        private boolean exhausted() {
            return index == steps.size();
        }
    }

    private record Node(String tag, List<String> scalars, List<Node> children) {
        private Node {
            Objects.requireNonNull(tag, "tag");
            scalars = List.copyOf(scalars);
            children = List.copyOf(children);
        }
    }

    private record InsertionEvidence(
            CertificateTraceEvent event,
            CertifiedInsertionResult insertion) {
    }

    private record Slice(
            List<CertificateTraceEvent> events,
            Map<EClassId, InsertionEvidence> insertions,
            Map<CanonicalShape, InsertionEvidence> shapes,
            ParentEdgeCertificate union,
            CertifiedInsertionResult rootInsertion,
            FiniteUnfoldingTree unfolding) {
    }

    private record PathWire(
            List<Integer> path,
            String initialWitness,
            String leaderWitness,
            Node finalInvocation,
            List<Node> edgeProofs) {
    }

    private record InvocationOccurrence(
            List<Integer> path,
            TypedInvocation invocation) {
    }

    private record RepWire(Node rep, Node invocation, Node normalized) {
    }
}
