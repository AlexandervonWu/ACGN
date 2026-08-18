package is.fivefivefive.CanDis.theory;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/** Deterministic producer bridge into the standalone {@code .acgncert} schema. */
public final class CertificateBundleWriter {
    private static final String SCHEMA_VERSION = "acgncert-schema-v1";
    private static final int FORMAT_VERSION = 1;
    private static final byte[] MAGIC = new byte[] {
            'A', 'C', 'G', 'N', 'C', 'E', 'R', 'T'
    };

    private CertificateBundleWriter() {
    }

    /**
     * Writes the currently implemented exact vertical slice.
     *
     * <p>The slice is intentionally narrow: one nullary source node, one fresh
     * insertion at the empty effective support, and one complete height-one
     * unfolding. All validation happens before the output file is opened. A
     * richer retained trace is therefore reported as uncheckable instead of
     * being reconstructed from final producer state.</p>
     */
    public static void write(CertificateExportSession session, Path output)
            throws IOException {
        Objects.requireNonNull(output, "output");
        Slice slice = requireSupportedSlice(
                Objects.requireNonNull(session, "session"));
        byte[] encoded = encode(buildBundle(session, slice));
        Path absolute = output.toAbsolutePath();
        Path parent = absolute.getParent();
        if (parent != null) {
            Files.createDirectories(parent);
        }
        Files.write(absolute, encoded);
    }

    private static Slice requireSupportedSlice(CertificateExportSession session)
            throws IOException {
        List<CertificateTraceEvent> events = session.events();
        if (events.size() != 1) {
            throw uncheckable("export currently requires exactly one retained transition");
        }
        CertificateTraceEvent event = events.get(0);
        if (event.sequence() != 0
                || event.kind() != CertificateTraceEvent.Kind.INSERT_FRESH
                || !(event.payload() instanceof CertificateTracePayload.Insertion)) {
            throw uncheckable("export currently supports only one fresh insertion");
        }
        CertifiedInsertionResult insertion =
                ((CertificateTracePayload.Insertion) event.payload()).result();
        if (insertion.collided()) {
            throw uncheckable("collision evidence has not yet been serialized");
        }

        CertificateTraceSnapshot before = event.before();
        CertificateTraceSnapshot after = event.after();
        if (before.revision() != 0
                || before.status() != GraphStatus.QUIESCENT
                || !before.classes().isEmpty()
                || !before.parents().isEmpty()
                || !before.hashCons().isEmpty()
                || !before.shapeCertificates().isEmpty()
                || !before.parentUses().isEmpty()
                || !before.dirtyParents().isEmpty()
                || !before.restrictions().isEmpty()
                || !before.insertions().isEmpty()) {
            throw uncheckable("fresh-insertion pre-state is not the exact empty graph");
        }
        if (after.revision() != 1
                || after.status() != GraphStatus.QUIESCENT
                || after.classes().size() != 1
                || after.hashCons().size() != 1
                || after.shapeCertificates().size() != 1
                || !after.parentUses().isEmpty()
                || !after.dirtyParents().isEmpty()
                || !after.restrictions().isEmpty()
                || after.insertions().size() != 1) {
            throw uncheckable("fresh-insertion post-state exceeds the exact vertical slice");
        }
        if (!after.parents().values().stream().allMatch(ParentAssignment::isRoot)) {
            throw uncheckable("nontrivial parent paths have not yet been serialized");
        }

        TypedEClassInterface eclass = insertion.insertedClass();
        TypedEClassRecord record = after.classes().get(eclass.id());
        if (record == null
                || record.shapeWitnesses().size() != 1
                || !record.symmetryGroup().generators().isEmpty()
                || !after.insertions().get(eclass.id()).equals(insertion)
                || !session.finalSnapshot().stateKey().equals(after.stateKey())) {
            throw uncheckable("fresh class state is incomplete or contains symmetry");
        }

        CanonicalizationResult canonical = insertion.canonicalization().structural();
        TypedENode source = canonical.source();
        TypedENode kernel = canonical.kernel();
        if (!source.context().isEmpty()
                || !source.support().isEmpty()
                || !source.ports().isEmpty()
                || !kernel.context().isEmpty()
                || !kernel.support().isEmpty()
                || !kernel.ports().isEmpty()
                || !source.equals(kernel)
                || !canonical.shape().node().equals(kernel)
                || !canonical.effectiveSupport().isEmpty()
                || !canonical.inclusion().mapping().isEmpty()
                || !canonical.sigma().mapping().isEmpty()
                || !canonical.omega().mapping().isEmpty()
                || !eclass.exposedSlots().isEmpty()
                || !eclass.outputType().equals(source.outputType())) {
            throw uncheckable(
                    "typed ports, support contraction, or nonidentity alpha action "
                            + "requires the next exporter slice");
        }
        if (!insertion.returnedInvocation().equals(session.artifact().root())
                || !insertion.returnedInvocation().callerContext().isEmpty()
                || !insertion.returnedInvocation().embedding().mapping().isEmpty()) {
            throw uncheckable("published invocation is outside the nullary fresh class");
        }
        if (!session.artifact().classes().equals(after.classes())
                || session.artifact().witnesses().graphRevision() != after.revision()
                || !session.containerLaws().isEmpty()) {
            throw uncheckable("publication state or law registry exceeds this exporter slice");
        }
        if (session.artifact().unfoldings().size() != 1) {
            throw uncheckable("export currently requires one complete finite unfolding");
        }
        FiniteUnfoldingTree unfolding = session.artifact().unfoldings().get(0);
        if (!unfolding.rootInvocation().equals(session.artifact().root())
                || !unfolding.selectedShape().equals(canonical.shape())
                || !unfolding.restoredRoot().equals(source)
                || unfolding.height() != 1
                || !unfolding.invocationChildren().isEmpty()
                || unfolding.indexTrace().steps().size() != 1
                || !unfolding.indexTrace().finalContext().isEmpty()
                || !unfolding.indexTrace().finalWeakening().mapping().isEmpty()) {
            throw uncheckable("finite unfolding is not the exact height-one witness");
        }
        return new Slice(event, insertion, source, kernel, eclass, unfolding);
    }

    private static Node buildBundle(CertificateExportSession session, Slice slice) {
        Tables tables = new Tables();
        Node emptyContext = tables.context(TypedSlotContext.empty());
        Node identity = tables.embedding(
                "BIJECTION", emptyContext, emptyContext, Map.of());

        String type = slice.source().outputType().toString();
        String operatorId = slice.source().operator().structuralKey().stableString();
        Node operator = node("operator", List.of(operatorId, type), List.of());
        Node theory = node(
                "theory",
                List.of("acgn-exact-alloy-theory-v1", "phase-j-nullary-rules-v1"),
                List.of(
                        node("schemas", List.of()),
                        node("operators", List.of(operator)),
                        node("binders", List.of()),
                        node("axioms", List.of())));
        String theoryDigest = contentId(theory);

        Node source = tables.term(
                "APP", emptyContext, "TERM", type, operatorId, List.of(), List.of());
        String eclassId = slice.eclass().id().toString();
        String witnessId = "w:" + eclassId + "@" + slice.event().after().revision();
        tables.witness(node(
                "witness",
                List.of(
                        witnessId,
                        Long.toString(slice.event().after().revision()),
                        eclassId,
                        scalar(emptyContext, 0),
                        type,
                        scalar(source, 0)),
                List.of()));
        Node invocation = tables.term(
                "INVOKE",
                emptyContext,
                "TERM",
                type,
                witnessId,
                List.of(scalar(identity, 0)),
                List.of());

        Node reflexive = tables.proof(
                "REFL", emptyContext, type, source, source, List.of(),
                leaf("refl", scalar(source, 0)));
        Node replay = tables.proof(
                "KERNEL_REPLAY",
                emptyContext,
                type,
                source,
                source,
                List.of(reflexive),
                node(
                        "kernel-replay",
                        List.of(
                                scalar(source, 0),
                                scalar(emptyContext, 0),
                                scalar(source, 0),
                                scalar(emptyContext, 0),
                                scalar(identity, 0),
                                scalar(identity, 0),
                                scalar(identity, 0)),
                        List.of(
                                node("parent-paths", List.of()),
                                node("port-normalizations", List.of()),
                                leaf("structural-proof", scalar(reflexive, 0)),
                                node("effective-support", List.of()))));
        Node orbit = tables.proof(
                "CANONICAL_ORBIT",
                emptyContext,
                type,
                source,
                source,
                List.of(),
                node(
                        "canonical-orbit",
                        List.of(
                                scalar(source, 0),
                                scalar(emptyContext, 0),
                                scalar(source, 0),
                                "1"),
                        List.of(
                                node("free-renamings", List.of(
                                        leaf("embedding-ref", scalar(identity, 0)))),
                                node(
                                        "leader-groups",
                                        List.of("snapshot-after", "complete"),
                                        List.of()),
                                node("orbit-members", List.of(
                                        leaf("term-ref", scalar(source, 0)))))));
        Node fresh = tables.proof(
                "FRESH_WITNESS",
                emptyContext,
                type,
                source,
                source,
                List.of(replay),
                leaf(
                        "fresh-witness",
                        witnessId,
                        scalar(source, 0),
                        scalar(identity, 0),
                        scalar(replay, 0)));

        Node before = tables.snapshot(
                slice.event().before().revision(),
                slice.event().before().status().name(),
                List.of(), List.of(), List.of(), List.of(), List.of(), List.of(),
                List.of());
        String shapeId = "shape:" + contentId(node(
                "producer-shape",
                List.of(slice.insertion().canonicalization().shape()
                        .structuralKey().stableString()),
                List.of()));
        String termKey = contentId(node(
                "term-key/APP",
                List.of(
                        scalar(emptyContext, 0),
                        "TERM",
                        type,
                        operatorId),
                List.of()));
        Node after = tables.snapshot(
                slice.event().after().revision(),
                slice.event().after().status().name(),
                List.of(leaf(
                        "class", eclassId, witnessId, scalar(emptyContext, 0), type)),
                List.of(),
                List.of(leaf(
                        "shape", shapeId, eclassId, scalar(source, 0), scalar(replay, 0))),
                List.of(leaf("hash-owner", termKey, eclassId)),
                List.of(),
                List.of(),
                List.of());
        tables.event(node(
                "event",
                List.of(
                        Long.toString(slice.event().sequence()),
                        "INSERT_FRESH",
                        scalar(before, 0),
                        scalar(after, 0)),
                List.of(leaf(
                        "insert-fresh",
                        eclassId,
                        shapeId,
                        scalar(replay, 0),
                        scalar(orbit, 0),
                        scalar(fresh, 0)))));

        Node canonicalRecord = tables.canonical(withContentId(
                "canonical-record",
                List.of(scalar(orbit, 0), scalar(source, 0)),
                List.of(leaf("source-replay-ref", scalar(replay, 0)))));
        Node rep = node(
                "rep",
                List.of(scalar(invocation, 0), shapeId, scalar(source, 0), "1"),
                List.of(
                        leaf("ambient-extension", scalar(identity, 0)),
                        node("redundant-assignments", List.of()),
                        node("rep-children", List.of())));
        Node unfolding = tables.unfolding(withContentId(
                "unfolding",
                List.of(
                        scalar(invocation, 0),
                        "1",
                        scalar(source, 0),
                        scalar(after, 0)),
                List.of(rep)));

        Node publication = node(
                "publication",
                List.of(
                        scalar(after, 0),
                        Long.toString(slice.event().after().revision()),
                        scalar(source, 0),
                        scalar(source, 0),
                        theoryDigest),
                List.of(
                        node("ec-evidence", List.of(leaf("ec", eclassId, witnessId))),
                        node("pc-evidence", List.of()),
                        node("sc-evidence", List.of()),
                        node("canonical-refs", List.of(
                                leaf("canonical-ref", scalar(canonicalRecord, 0)))),
                        node("unfolding-refs", List.of(
                                leaf("unfolding-ref", scalar(unfolding, 0))))));

        String runId = contentId(node(
                "producer-run",
                List.of(
                        session.producerCommit(),
                        Boolean.toString(session.producerDirty()),
                        session.componentVersions(),
                        session.finalSnapshot().stateKey().stableString(),
                        session.canonicalObservation().stableString()),
                List.of()));
        return node(
                "acgncert-bundle",
                List.of(SCHEMA_VERSION),
                List.of(
                        leaf(
                                "metadata",
                                session.producerCommit(),
                                Boolean.toString(session.producerDirty()),
                                "phase-j-producer-export-v1",
                                session.componentVersions(),
                                runId,
                                "1970-01-01T00:00:00Z"),
                        node("manifest", List.of(theoryDigest), List.of(theory)),
                        section("contexts", tables.contexts),
                        section("embeddings", tables.embeddings),
                        section("terms", tables.terms),
                        section("proofs", tables.proofs),
                        section("witnesses", tables.witnesses),
                        section("snapshots", tables.snapshots),
                        node("events", tables.events),
                        section("canonical-records", tables.canonicalRecords),
                        section("unfoldings", tables.unfoldings),
                        publication));
    }

    private static IOException uncheckable(String detail) {
        return new IOException("UNCHECKABLE: " + detail);
    }

    private static Node section(String tag, List<Node> values) {
        List<Node> sorted = new ArrayList<>(values);
        sorted.sort(Comparator.comparing(value -> scalar(value, 0)));
        return node(tag, sorted);
    }

    private static String scalar(Node node, int index) {
        return node.scalars.get(index);
    }

    private static Node withContentId(
            String tag,
            List<String> contentScalars,
            List<Node> children) {
        List<String> provisionalScalars = new ArrayList<>(contentScalars.size() + 1);
        provisionalScalars.add("");
        provisionalScalars.addAll(contentScalars);
        Node provisional = node(tag, provisionalScalars, children);
        String id = identifiedContentId(provisional);
        provisionalScalars.set(0, id);
        return node(tag, provisionalScalars, children);
    }

    private static String identifiedContentId(Node record) {
        return contentId(node(
                record.tag + "/content",
                record.scalars.subList(1, record.scalars.size()),
                record.children));
    }

    private static String contentId(Node node) {
        return HexFormat.of().formatHex(sha256(encodeNode(node)));
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

    private static final class Tables {
        private final List<Node> contexts = new ArrayList<>();
        private final List<Node> embeddings = new ArrayList<>();
        private final List<Node> terms = new ArrayList<>();
        private final List<Node> proofs = new ArrayList<>();
        private final List<Node> witnesses = new ArrayList<>();
        private final List<Node> snapshots = new ArrayList<>();
        private final List<Node> events = new ArrayList<>();
        private final List<Node> canonicalRecords = new ArrayList<>();
        private final List<Node> unfoldings = new ArrayList<>();

        private Node context(TypedSlotContext context) {
            List<Node> slots = new ArrayList<>();
            for (TypedSlot slot : context) {
                slots.add(leaf("slot", slot.toString(), slot.type().toString()));
            }
            Node record = withContentId("context", List.of(), slots);
            contexts.add(record);
            return record;
        }

        private Node embedding(
                String kind,
                Node source,
                Node target,
                Map<String, String> images) {
            List<Node> children = new ArrayList<>();
            for (Map.Entry<String, String> image : images.entrySet()) {
                children.add(leaf("image", image.getKey(), image.getValue()));
            }
            Node record = withContentId(
                    "embedding",
                    List.of(kind, scalar(source, 0), scalar(target, 0)),
                    children);
            embeddings.add(record);
            return record;
        }

        private Node term(
                String kind,
                Node context,
                String sortKind,
                String sortValue,
                String symbol,
                List<String> attributes,
                List<Node> children) {
            List<String> scalars = new ArrayList<>(List.of(
                    kind, scalar(context, 0), sortKind, sortValue, symbol));
            scalars.addAll(attributes);
            Node record = withContentId(
                    "term",
                    scalars,
                    children.stream()
                            .map(child -> leaf("term-ref", scalar(child, 0)))
                            .toList());
            terms.add(record);
            return record;
        }

        private Node proof(
                String variant,
                Node context,
                String type,
                Node left,
                Node right,
                List<Node> premises,
                Node payload) {
            Node record = withContentId(
                    "proof",
                    List.of(
                            variant,
                            scalar(context, 0),
                            "TERM",
                            type,
                            scalar(left, 0),
                            scalar(right, 0)),
                    List.of(
                            node("premises", premises.stream()
                                    .map(proof -> leaf("proof-ref", scalar(proof, 0)))
                                    .toList()),
                            payload));
            proofs.add(record);
            return record;
        }

        private void witness(Node witness) {
            witnesses.add(witness);
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
                List<Node> dirty) {
            Node record = withContentId(
                    "snapshot",
                    List.of(Long.toString(revision), status),
                    List.of(
                            section("classes", classes),
                            section("parents", parents),
                            section("shapes", shapes),
                            section("hash-cons", hashes),
                            section("parent-uses", parentUses),
                            section("symmetries", symmetries),
                            section("dirty", dirty)));
            snapshots.add(record);
            return record;
        }

        private void event(Node event) {
            events.add(event);
        }

        private Node canonical(Node canonical) {
            canonicalRecords.add(canonical);
            return canonical;
        }

        private Node unfolding(Node unfolding) {
            unfoldings.add(unfolding);
            return unfolding;
        }
    }

    private record Node(String tag, List<String> scalars, List<Node> children) {
        private Node {
            Objects.requireNonNull(tag, "tag");
            scalars = List.copyOf(scalars);
            children = List.copyOf(children);
        }
    }

    private record Slice(
            CertificateTraceEvent event,
            CertifiedInsertionResult insertion,
            TypedENode source,
            TypedENode kernel,
            TypedEClassInterface eclass,
            FiniteUnfoldingTree unfolding) {
    }
}
