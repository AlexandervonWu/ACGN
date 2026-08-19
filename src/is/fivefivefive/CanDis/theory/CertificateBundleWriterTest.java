package is.fivefivefive.CanDis.theory;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/** Producer-side deterministic fixtures for the exact certificate bridge slice. */
public final class CertificateBundleWriterTest {
    private static final GraphType T = GraphType.constructor("T");
    private static int checks;

    private CertificateBundleWriterTest() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            throw new IllegalArgumentException(
                    "usage: CertificateBundleWriterTest <output-dir>");
        }
        Path output = Path.of(args[0]);
        Files.createDirectories(output);

        CertificateExportSession nullary = singleFresh(constant("nullary"));
        CertificateExportSession slot = singleFresh(slotLeaf("slot-only"));
        CertificateExportSession parent = parentPathFixture();
        exportTwice(nullary, output, "nullary");
        exportTwice(slot, output, "slot-only");
        exportTwice(parent, output, "parent-path");

        assertUnsupportedPreservesTarget(
                repeatedSameTypeFixture(), output.resolve("unsupported-repeated-slot.acgncert"));
        assertUnsupportedPreservesTarget(
                singleFresh(sourceAlphabetLeaf()),
                output.resolve("unsupported-alpha.acgncert"));
        assertUnsupportedPreservesTarget(
                singleFresh(bindNode()), output.resolve("unsupported-bind.acgncert"));
        assertUnsupportedPreservesTarget(
                singleFresh(bindBlockNode()),
                output.resolve("unsupported-bind-block.acgncert"));
        assertUnsupportedPreservesTarget(
                multipleUnfoldingsFixture(),
                output.resolve("unsupported-multiple-unfoldings.acgncert"));
        assertUnsupportedPreservesTarget(
                insertionCollisionFixture(),
                output.resolve("unsupported-insert-collision.acgncert"));
        assertUnsupportedPreservesTarget(
                parentPathFixture(true),
                output.resolve("unsupported-indirect-parent.acgncert"));
        for (ContainerLawDeclaration.Kind kind : List.of(
                ContainerLawDeclaration.Kind.SEQ,
                ContainerLawDeclaration.Kind.BAG,
                ContainerLawDeclaration.Kind.SET)) {
            assertUnsupportedPreservesTarget(
                    containerRegistryFixture(kind),
                    output.resolve("unsupported-" + kind.name().toLowerCase()
                            + ".acgncert"));
        }
        for (CertificateTraceEvent.Kind kind : List.of(
                CertificateTraceEvent.Kind.ADD_SYMMETRY,
                CertificateTraceEvent.Kind.RESTRICT_INTERFACE,
                CertificateTraceEvent.Kind.REBUILD_RECORD,
                CertificateTraceEvent.Kind.PATH_COMPRESSION)) {
            assertUnsupportedPreservesTarget(
                    unsupportedEventFixture(kind),
                    output.resolve("unsupported-" + kind.name().toLowerCase()
                            + ".acgncert"));
        }
        assertUnsupportedPreservesTarget(
                unsupportedEventFixture(CertificateTraceEvent.Kind.UNION),
                output.resolve("unsupported-incomplete-history.acgncert"));

        System.out.println("CertificateBundleWriterTest passed: " + checks
                + " checks; fixtures=" + output);
    }

    private static CertificateExportSession singleFresh(TypedENode source) {
        FreshFixture fixture = freshFixture(source);
        return session(
                fixture.sink(),
                fixture.graph(),
                fixture.insertion().returnedInvocation(),
                fixture.family(),
                List.of(fixture.unfolding()),
                Map.of());
    }

    private static FreshFixture freshFixture(TypedENode source) {
        RecordingCertificateTraceSink sink = new RecordingCertificateTraceSink();
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph(sink);
        CertifiedInsertionResult insertion = graph.insertNode(
                source, graph.coherentWitnessFamily());
        CoherentWitnessFamily family = graph.coherentWitnessFamily();
        List<FiniteUnfoldingTree> trees = graph.finiteUnfoldingOracle(
                family, new FiniteUnfoldingBounds(1, 8))
                .enumerate(insertion.returnedInvocation());
        check(trees.size() == 1 && trees.get(0).height() == 1,
                "single fresh insertion has one height-one unfolding");
        return new FreshFixture(sink, graph, insertion, family, trees.get(0));
    }

    private static CertificateExportSession parentPathFixture() {
        return parentPathFixture(false);
    }

    private static CertificateExportSession parentPathFixture(boolean indirectEdge) {
        RecordingCertificateTraceSink sink = new RecordingCertificateTraceSink();
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph(sink);
        CertifiedInsertionResult left = graph.insertNode(
                slotLeaf("left"), graph.coherentWitnessFamily());
        CertifiedInsertionResult right = graph.insertNode(
                slotLeaf("right"), graph.coherentWitnessFamily());

        TypedInvocation parent = TypedInvocation.identity(left.insertedClass());
        InputEquationCertificate equation = new InputEquationCertificate(
                CertificateOrigin.inputEquation(
                        "certificate-writer-fixture", "right=left", 0),
                TypedCertificateEndpoint.eclassWitness(right.insertedClass()),
                TypedCertificateEndpoint.invocation(parent));
        TypedEqualityCertificate derivation = equation;
        if (indirectEdge) {
            derivation = EqualityCertificates.transitive(
                    equation,
                    EqualityCertificates.reflexive(
                            TypedCertificateEndpoint.invocation(parent)));
        }
        ParentEdgeCertificate edge = new ParentEdgeCertificate(
                right.insertedClass(), parent, derivation);
        graph.unionCertified(edge);
        RebuildReport rebuild = graph.rebuild();
        check(rebuild.processedRecords() == 0
                        && rebuild.changedKeys() == 0
                        && graph.status() == GraphStatus.QUIESCENT,
                "leaf union needs only REBUILD_COMPLETE");

        TypedSlotContext gamma = right.insertedClass().exposedSlots();
        OnePortSchema schema = new OnePortSchema(GraphType.BOOL);
        InstantiatedOperator wrapper = OperatorDeclaration.monomorphic(
                "wrap",
                List.of(schema),
                GraphType.BOOL,
                Map.of(),
                null).instantiateMonomorphic();
        TypedENode wrapperSource = TypedENode.construct(
                wrapper,
                gamma,
                List.of(OnePort.invocation(
                        gamma, TypedInvocation.identity(right.insertedClass()))));
        CertifiedInsertionResult wrapped = graph.insertNode(
                wrapperSource, graph.coherentWitnessFamily());
        List<TypedFindResult> finds = wrapped.canonicalization()
                .structural().xi().findResults();
        check(finds.size() == 1 && finds.get(0).parentPath().steps().size() == 1,
                "wrapper retains one genuine parent step");
        check(finds.get(0).parentPath().steps().get(0).certificate().equals(edge),
                "wrapper parent path retains the certified union edge");

        CoherentWitnessFamily family = graph.coherentWitnessFamily();
        List<FiniteUnfoldingTree> trees = graph.finiteUnfoldingOracle(
                family, new FiniteUnfoldingBounds(2, 16))
                .enumerate(wrapped.returnedInvocation());
        FiniteUnfoldingTree selected = trees.stream()
                .filter(tree -> tree.height() == 2)
                .findFirst()
                .orElseThrow(() -> new AssertionError("missing height-two unfolding"));
        check(selected.invocationChildren().size() == 1,
                "wrapper unfolding has its exact representative child");
        check(sink.events().stream().map(CertificateTraceEvent::kind).toList().equals(
                        List.of(
                                CertificateTraceEvent.Kind.INSERT_FRESH,
                                CertificateTraceEvent.Kind.INSERT_FRESH,
                                CertificateTraceEvent.Kind.UNION,
                                CertificateTraceEvent.Kind.REBUILD_COMPLETE,
                                CertificateTraceEvent.Kind.INSERT_FRESH)),
                "parent fixture retains the exact five-event history");
        return session(
                sink,
                graph,
                wrapped.returnedInvocation(),
                family,
                List.of(selected),
                Map.of());
    }

    private static CertificateExportSession repeatedSameTypeFixture() {
        TypedSlot first = TypedSlot.canonicalFree(T, 0);
        TypedSlot second = TypedSlot.canonicalFree(T, 1);
        TypedSlotContext context = TypedSlotContext.of(first, second);
        InstantiatedOperator operator = OperatorDeclaration.monomorphic(
                "two-slots",
                List.of(new OnePortSchema(T), new OnePortSchema(T)),
                GraphType.BOOL,
                Map.of(),
                null).instantiateMonomorphic();
        TypedENode source = TypedENode.construct(
                operator,
                context,
                List.of(OnePort.slot(context, first), OnePort.slot(context, second)));
        return singleFresh(source);
    }

    private static CertificateExportSession multipleUnfoldingsFixture() {
        FreshFixture fixture = freshFixture(constant("multiple-unfoldings"));
        return session(
                fixture.sink(),
                fixture.graph(),
                fixture.insertion().returnedInvocation(),
                fixture.family(),
                List.of(fixture.unfolding(), fixture.unfolding()),
                Map.of());
    }

    private static CertificateExportSession insertionCollisionFixture() {
        RecordingCertificateTraceSink sink = new RecordingCertificateTraceSink();
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph(sink);
        TypedENode source = constant("collision");
        graph.insertNode(source, graph.coherentWitnessFamily());
        CertifiedInsertionResult collision = graph.insertNode(
                source, graph.coherentWitnessFamily());
        check(collision.collided(), "duplicate source creates a retained collision");
        graph.rebuild();
        CoherentWitnessFamily family = graph.coherentWitnessFamily();
        FiniteUnfoldingTree tree = graph.finiteUnfoldingOracle(
                family, new FiniteUnfoldingBounds(1, 8))
                .enumerate(collision.returnedInvocation()).get(0);
        return session(
                sink,
                graph,
                collision.returnedInvocation(),
                family,
                List.of(tree),
                Map.of());
    }

    private static CertificateExportSession containerRegistryFixture(
            ContainerLawDeclaration.Kind kind) {
        FreshFixture fixture = freshFixture(constant("container-" + kind.name()));
        ContainerLawDeclaration declaration = switch (kind) {
            case SEQ -> ContainerLawDeclaration.of(kind, true, false, false, false);
            case BAG -> ContainerLawDeclaration.of(kind, true, true, false, false);
            case SET -> ContainerLawDeclaration.of(kind, true, true, true, false);
            default -> throw new IllegalArgumentException("not a container kind: " + kind);
        };
        return session(
                fixture.sink(),
                fixture.graph(),
                fixture.insertion().returnedInvocation(),
                fixture.family(),
                List.of(fixture.unfolding()),
                Map.of(kind.name(), List.of(declaration)));
    }

    private static CertificateExportSession unsupportedEventFixture(
            CertificateTraceEvent.Kind kind) {
        FreshFixture fixture = freshFixture(constant("event-" + kind.name()));
        CertificateTraceSnapshot snapshot = fixture.graph().certificateTraceSnapshot();
        fixture.sink().append(new CertificateTraceEvent(
                1,
                kind,
                snapshot,
                snapshot,
                new CertificateTracePayload.Insertion(fixture.insertion())));
        return session(
                fixture.sink(),
                fixture.graph(),
                fixture.insertion().returnedInvocation(),
                fixture.family(),
                List.of(fixture.unfolding()),
                Map.of());
    }

    private static CertificateExportSession session(
            RecordingCertificateTraceSink sink,
            TypedSlottedPortEGraph graph,
            TypedInvocation root,
            CoherentWitnessFamily family,
            List<? extends FiniteUnfoldingTree> unfoldings,
            Map<String, ? extends List<ContainerLawDeclaration>> containerLaws) {
        CertifiedSemanticArtifact artifact = new CertifiedSemanticArtifact(
                root,
                graph.classes(),
                family,
                unfoldings,
                Map.of());
        return new CertificateExportSession(
                sink,
                graph,
                artifact,
                unfoldings.get(0).normalizedTermKey(),
                containerLaws,
                "e0e4320766518c110ab0b8c37fe772e02eb04249",
                false,
                "certificate-writer-fixture-v2");
    }

    private static TypedENode constant(String name) {
        InstantiatedOperator operator = OperatorDeclaration.monomorphic(
                name,
                Collections.emptyList(),
                GraphType.BOOL,
                Map.of(),
                null).instantiateMonomorphic();
        return TypedENode.construct(
                operator, TypedSlotContext.empty(), Collections.emptyList());
    }

    private static TypedENode slotLeaf(String name) {
        TypedSlot slot = TypedSlot.canonicalFree(T, 0);
        TypedSlotContext context = TypedSlotContext.singleton(slot);
        InstantiatedOperator operator = OperatorDeclaration.monomorphic(
                name,
                List.of(new OnePortSchema(T)),
                GraphType.BOOL,
                Map.of(),
                null).instantiateMonomorphic();
        return TypedENode.construct(
                operator, context, List.of(OnePort.slot(context, slot)));
    }

    private static TypedENode sourceAlphabetLeaf() {
        TypedSlot slot = TypedSlot.source(T, 0);
        TypedSlotContext context = TypedSlotContext.singleton(slot);
        InstantiatedOperator operator = OperatorDeclaration.monomorphic(
                "source-alpha",
                List.of(new OnePortSchema(T)),
                GraphType.BOOL,
                Map.of(),
                null).instantiateMonomorphic();
        return TypedENode.construct(
                operator, context, List.of(OnePort.slot(context, slot)));
    }

    private static TypedENode bindNode() {
        TypedSlotContext context = TypedSlotContext.empty();
        TypedSlot bound = TypedSlot.canonicalBound(T, 0);
        TypedSlotContext bodyContext = TypedSlotContext.singleton(bound);
        BindPortSchema schema = new BindPortSchema(T, new OnePortSchema(T));
        BindPort port = new BindPort(
                schema,
                context,
                bound,
                OnePort.slot(bodyContext, bound));
        InstantiatedOperator operator = OperatorDeclaration.monomorphic(
                "bind",
                List.of(schema),
                GraphType.BOOL,
                Map.of(),
                null).instantiateMonomorphic();
        return TypedENode.construct(operator, context, List.of(port));
    }

    private static TypedENode bindBlockNode() {
        TypedSlotContext context = TypedSlotContext.empty();
        TypedSlot bound = TypedSlot.canonicalBound(T, 0);
        BinderCoordinateDescriptor coordinate = new BinderCoordinateDescriptor(
                bound,
                StructuralKey.leaf("fixture-domain", "T"),
                "ALL",
                "SET",
                BinderCoordinateDescriptor.NO_DISJOINTNESS_CLASS,
                TypedSlotContext.empty());
        BinderBlockDescriptor descriptor = BinderBlockDescriptor.certified(
                List.of(coordinate), List.of());
        BindBlockPortSchema schema = new BindBlockPortSchema(
                descriptor, new OnePortSchema(T));
        TypedRenaming occurrence = descriptor.freshOccurrenceRenaming(context);
        TypedSlot occurrenceSlot = occurrence.codomain().iterator().next();
        BindBlockPort port = new BindBlockPort(
                schema,
                context,
                occurrence,
                OnePort.slot(occurrence.codomain(), occurrenceSlot));
        InstantiatedOperator operator = OperatorDeclaration.monomorphic(
                "bind-block",
                List.of(schema),
                GraphType.BOOL,
                Map.of(),
                null).instantiateMonomorphic();
        return TypedENode.construct(operator, context, List.of(port));
    }

    private static void exportTwice(
            CertificateExportSession session,
            Path output,
            String name) throws IOException {
        Path first = output.resolve(name + "-a.acgncert");
        Path second = output.resolve(name + "-b.acgncert");
        session.write(first);
        session.write(second);
        check(java.util.Arrays.equals(
                        Files.readAllBytes(first), Files.readAllBytes(second)),
                name + " exports are byte deterministic");
    }

    private static void assertUnsupportedPreservesTarget(
            CertificateExportSession unsupported,
            Path target) throws IOException {
        byte[] sentinel = "sentinel-certificate-output".getBytes(StandardCharsets.UTF_8);
        Files.write(target, sentinel);
        try {
            unsupported.write(target);
            throw new AssertionError("unsupported export unexpectedly succeeded");
        } catch (IOException exception) {
            check(exception.getMessage().startsWith("UNCHECKABLE: "),
                    "unsupported export is classified UNCHECKABLE");
        }
        check(java.util.Arrays.equals(sentinel, Files.readAllBytes(target)),
                "unsupported export leaves a pre-existing target unchanged");
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private record FreshFixture(
            RecordingCertificateTraceSink sink,
            TypedSlottedPortEGraph graph,
            CertifiedInsertionResult insertion,
            CoherentWitnessFamily family,
            FiniteUnfoldingTree unfolding) {
    }
}
