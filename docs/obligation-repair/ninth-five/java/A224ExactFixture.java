package is.fivefivefive.CanDis.theory;

import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

/** Legitimate graph construction and publication writer with explicit TEST_ONLY provenance. */
public final class A224ExactFixture {
    public static final String IDENTIFIER="fixture/a224-exact";
    public static final String CONTENT="JOIN of test constants X->A and A->U";
    private static DependentChainLeaf leaf(TypedSlottedPortEGraph graph,String name,String l,String r) {
        var type=GraphType.relation(GraphType.constructor("AlloySig:"+l),GraphType.constructor("AlloySig:"+r));
        var node=TypedENode.construct(OperatorDeclaration.monomorphic(name,List.of(),type,Map.of(),null).instantiateMonomorphic(),
                TypedSlotContext.empty(),List.of());
        var inv=graph.insertNode(node,graph.coherentWitnessFamily()).returnedInvocation();
        graph.rebuild();
        return new DependentChainLeaf(OnePort.invocation(TypedSlotContext.empty(),inv),type);
    }
    public static byte[] export() throws Exception {
        if(!Boolean.getBoolean("acgn.provenance.testOverride"))throw new IllegalStateException("explicit TEST_ONLY provenance required");
        var profile=SemanticProfile.alloyOverflowForbidding();var sink=new RecordingCertificateTraceSink();
        var graph=new TypedSlottedPortEGraph(profile,sink);
        var source=new DependentChainApplication(DependentChainKind.JOIN,leaf(graph,"a224-left","X","A"),leaf(graph,"a224-right","A","U"));
        var occurrence=StructuralKey.of("alloy-dependent-chain-source-occurrence-v1",List.of(IDENTIFIER),List.of(
                StructuralKey.branch("alloy-dependent-chain-typed-source-v1",List.of(source.structuralKey())),
                StructuralKey.leaf("alloy-dependent-chain-source-content-v1",CONTENT)));
        var ledger=ConstructionSourceLedger.builder(profile);ledger.recordDependentChain(source,occurrence);
        var construction=TypedENode.constructDependentChainCertified(source,profile,occurrence);
        CertificateVerifier.verify(construction.certificate());
        var root=graph.insertNodeConstructed(construction,graph.coherentWitnessFamily());
        graph.rebuild();
        var family=graph.coherentWitnessFamily();
        var unfolding=graph.finiteUnfoldingOracle(family,new FiniteUnfoldingBounds(2,32)).enumerate(root.returnedInvocation())
                .stream().filter(t->t.height()==2).findFirst().orElseThrow();
        var artifact=new CertifiedSemanticArtifact(root.returnedInvocation(),graph.classes(),family,List.of(unfolding),Map.of(),List.of(),
                List.of(),List.of(construction.certificate()),ledger.build(),profile);
        var session=new CertificateExportSession(sink,graph,artifact,unfolding.normalizedTermKey(),Map.of(),
                CertificateProvenance.capture(IDENTIFIER,CONTENT.getBytes(StandardCharsets.UTF_8),"a224-exact-fixture;"+CertificateTheoryManifest.VERSION),
                "a224-exact-fixture");
        Path file=Files.createTempFile("a224-exact-", ".acgncert");
        try {session.write(file);return Files.readAllBytes(file);}finally{Files.delete(file);}
    }
}
