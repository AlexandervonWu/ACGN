package is.fivefivefive.CanDis.theory;

import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/** Ordinary typed source and export; the source identity is its full structural key. */
public final class P609BinderFixture {
    private P609BinderFixture() {}

    public static CertificateExportSession export(String kind, List<Integer> widths, Path path) throws Exception {
        var context = TypedSlotContext.empty();
        var type = GraphType.constructor("T");
        var first = TypedSlot.canonicalBound(type, 0);
        var second = TypedSlot.canonicalBound(type, 1);
        var domain = StructuralKey.leaf("fixture-domain", "T");
        var coords = List.of(first, second).stream().map(slot -> new BinderCoordinateDescriptor(
                slot, domain, "ALL", "SET", BinderCoordinateDescriptor.NO_DISJOINTNESS_CLASS, context)).toList();
        var swap = TypedPermutation.of(TypedSlotContext.of(first, second), Map.of(first, second, second, first));
        var declaration = new BinderAutomorphismCertificate(coords, swap, CertificateOrigin.binderAutomorphism(
                TheoryAlloyAdapter.SIGNATURE_VERSION, "alloy-binder-block", 0));
        var descriptor = BinderBlockDescriptor.certified(coords, List.of(declaration));
        if (kind.equals("BIND")) return exportBind(type, descriptor, first, path);
        var bodySchema = new SeqPortSchema(new OnePortSchema(type));
        var blockSchema = new BindBlockPortSchema(descriptor, bodySchema);
        var occurrence = descriptor.freshOccurrenceRenaming(context);
        var slot = OnePort.slot(occurrence.codomain(), occurrence.apply(first));
        List<PortValue> blocks = new ArrayList<>();
        for (int width : widths) {
            var body = new SeqPort(bodySchema, occurrence.codomain(), Collections.nCopies(width, slot));
            blocks.add(new BindBlockPort(blockSchema, context, occurrence, body));
        }
        PortValue outer = switch (kind) {
            case "BAG" -> new BagPort(new BagPortSchema(blockSchema), context, blocks);
            case "SET" -> new SetPort(new SetPortSchema(blockSchema), context, blocks);
            case "SEQ" -> new SeqPort(new SeqPortSchema(blockSchema), context, blocks);
            default -> throw new IllegalArgumentException(kind);
        };
        var operator = OperatorDeclaration.monomorphic("binder-container-" + kind, List.of(outer.schema()),
                GraphType.BOOL, Map.of(PortPath.at(0), ContainerLawDeclaration.of(
                        ContainerLawDeclaration.Kind.valueOf(kind), false, !kind.equals("SEQ"), kind.equals("SET"), false),
                        PortPath.at(0).child().child(), ContainerLawDeclaration.of(
                                ContainerLawDeclaration.Kind.SEQ, false, false, false, false)), null).instantiateMonomorphic();
        var source = TypedENode.construct(operator, context, List.of(outer));
        var sink = new RecordingCertificateTraceSink();
        var profile = SemanticProfile.alloyOverflowForbidding();
        var graph = new TypedSlottedPortEGraph(profile, sink);
        var ledger = ConstructionSourceLedger.builder(profile);
        ledger.recordContainer(operator, PortPath.at(0), context, blocks);
        var construction = TypedENode.constructContainerCertified(operator, PortPath.at(0), context, blocks, profile);
        var root = graph.insertNodeConstructed(construction, graph.coherentWitnessFamily()).returnedInvocation();
        var family = graph.coherentWitnessFamily();
        var unfold = graph.finiteUnfoldingOracle(family, new FiniteUnfoldingBounds(1, 128))
                .enumerate(root).stream().findFirst().orElseThrow();
        var laws = Map.of(operator.operator(), List.copyOf(operator.containerLaws().values()));
        var artifact = new CertifiedSemanticArtifact(root, graph.classes(), family, List.of(unfold),
                laws, List.of(), List.of(construction.certificate()), ledger.build(), profile);
        var session = new CertificateExportSession(sink, graph, artifact, unfold.normalizedTermKey(), laws,
                CertificateProvenance.capture("p609/" + kind,
                        source.structuralKey().stableString().getBytes(StandardCharsets.UTF_8), "p609-typed-source"),
                "p609-typed-source");
        session.write(path);
        return session;
    }

    private static CertificateExportSession exportBind(GraphType type, BinderBlockDescriptor descriptor,
            TypedSlot coordinate, Path path) throws Exception {
        var caller = TypedSlotContext.empty();
        var outerSlot = TypedSlot.canonicalBound(type, 0);
        var bodyContext = caller.plus(outerSlot);
        var occurrence = descriptor.freshOccurrenceRenaming(bodyContext);
        var blockSchema = new BindBlockPortSchema(descriptor, new OnePortSchema(type));
        var body = OnePort.slot(bodyContext.union(occurrence.codomain()), occurrence.apply(coordinate));
        var block = new BindBlockPort(blockSchema, bodyContext, occurrence, body);
        var outer = new BindPort(new BindPortSchema(type, blockSchema), caller, outerSlot, block);
        var operator = OperatorDeclaration.monomorphic("p609/\uD83E\uDDED:[{}]",
                List.of(outer.schema()), GraphType.BOOL, Map.of(), null).instantiateMonomorphic();
        var source = TypedENode.construct(operator, caller, List.of(outer));
        var sink = new RecordingCertificateTraceSink();
        var profile = SemanticProfile.alloyOverflowForbidding();
        var graph = new TypedSlottedPortEGraph(profile, sink);
        var root = graph.insertNode(source, graph.coherentWitnessFamily()).returnedInvocation();
        var family = graph.coherentWitnessFamily();
        var unfold = graph.finiteUnfoldingOracle(family, new FiniteUnfoldingBounds(1, 128))
                .enumerate(root).stream().findFirst().orElseThrow();
        var artifact = new CertifiedSemanticArtifact(root, graph.classes(), family, List.of(unfold), Map.of(), profile);
        var session = new CertificateExportSession(sink, graph, artifact, unfold.normalizedTermKey(), Map.of(),
                CertificateProvenance.capture("p609/BIND", source.structuralKey().stableString()
                .getBytes(StandardCharsets.UTF_8), "p609-typed-source"), "p609-typed-source");
        session.write(path);
        return session;
    }

}
