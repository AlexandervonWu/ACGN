package is.fivefivefive.CanDis.theory;

import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

/** Checks stored assignments after ordinary graph operations, against independent expected finite maps. */
public final class P404ParentAssignmentTest {
    private static void require(boolean condition,String message) {
        if (!condition) throw new AssertionError(message);
    }
    private static TypedEClassInterface face(int id,TypedSlot... slots) {
        return new TypedEClassInterface(EClassId.of(id),GraphType.BOOL,TypedSlotContext.of(slots));
    }
    private static TypedInvocation application(TypedEClassInterface target,TypedEClassInterface ambient,
            Map<TypedSlot,TypedSlot> map) {
        return new TypedInvocation(target,TypedEmbedding.of(target.exposedSlots(),ambient.exposedSlots(),map));
    }
    private static ParentEdgeCertificate edge(TypedEClassInterface child,TypedInvocation parent,int index,boolean reverse) {
        var a=TypedCertificateEndpoint.eclassWitness(child);var b=TypedCertificateEndpoint.invocation(parent);
        // All of these classes denote the constant true, at every assignment to every exposed slot.
        var premise=new InputEquationCertificate(CertificateOrigin.inputEquation("P4-04","constant-true",index),
                reverse?b:a,reverse?a:b);
        return new ParentEdgeCertificate(child,parent,premise);
    }
    private static String ids(Map<TypedSlot,TypedSlot> mapping) {
        var parts=new ArrayList<String>();
        for(var e:new TreeMap<>(mapping).entrySet())parts.add(e.getKey()+"="+e.getValue());
        return String.join(",",parts);
    }
    private static void checkedPath(ParentAssignment a) {
        var target=a.parentInvocation();var path=a.provenancePath();
        require(path.start().equals(a.child()) && path.end().equals(target.eclass()),"path identity");
        var values=new HashMap<TypedSlot,TypedSlot>();
        for(var slot:a.child().exposedSlots())values.put(slot,slot);
        var previous=a.child();
        for(var step:path.steps()) {
            require(step.child().equals(previous) && step.hasCertificate(),"ordered primitive edges");
            var proof=step.certificate();CertificateVerifier.verifyParentEdge(proof);
            var left=TypedCertificateEndpoint.eclassWitness(step.child());
            var right=TypedCertificateEndpoint.invocation(step.parentInvocation());
            require(proof.leftEndpoint().equals(left)&&proof.rightEndpoint().equals(right)
                &&proof.endpointDerivation().leftEndpoint().equals(left)
                &&proof.endpointDerivation().rightEndpoint().equals(right),"primitive certificate direction");
            var next=new HashMap<TypedSlot,TypedSlot>();
            for(var slot:step.parent().exposedSlots()) {
                var mid=step.embedding().mapping().get(slot);var mapped=values.get(mid);
                require(mapped!=null&&slot.type().equals(mapped.type()),"composed slot type");
                next.put(slot,mapped);
            }
            require(new HashSet<>(next.values()).size()==next.size(),"composed injection");
            values=next;previous=step.parent();
        }
        require(previous.equals(target.eclass())&&values.equals(target.embedding().mapping()),"independent finite composition");
        var actual=path.composedCertificate();CertificateVerifier.verify(actual);
        require(actual.leftEndpoint().equals(TypedCertificateEndpoint.eclassWitness(a.child()))
            &&actual.rightEndpoint().equals(TypedCertificateEndpoint.invocation(target)),"composed directed certificate");
    }
    private static void observe(List<String> output,String label,TypedSlottedPortEGraph graph,
            TypedEClassInterface child,TypedEClassInterface parent,Map<TypedSlot,TypedSlot> map,int length) {
        for(var entry:graph.parentAssignments().entrySet()) {
            require(entry.getKey().equals(entry.getValue().child().id()),"stored key");checkedPath(entry.getValue());
        }
        var a=graph.parentAssignments().get(child.id());
        require(a.child().equals(child)&&a.parentInvocation().equals(application(parent,child,map))
            &&a.provenancePath().steps().size()==length,"expected graph coordinates for "+label);
        output.add(label+"\t"+child.id().value()+"\t"+parent.id().value()+"\t"+ids(map)+"\t"+length);
    }
    private static void multi(List<String> rows) {
        var x=TypedSlot.source(GraphType.BOOL,10);var y=TypedSlot.source(GraphType.BOOL,11);
        var z=TypedSlot.source(GraphType.INT,12);var m=TypedSlot.source(GraphType.BOOL,20);
        var n=TypedSlot.source(GraphType.INT,21);var u=TypedSlot.source(GraphType.BOOL,30);
        var v=TypedSlot.source(GraphType.INT,31);var p=TypedSlot.source(GraphType.BOOL,40);
        var q=TypedSlot.source(GraphType.INT,41);var child=face(1,x,y,z);var middle=face(2,m,n);
        var leader=face(3,u,v);var sibling=face(4,p,q);
        var graph=new TypedSlottedPortEGraph();
        for(var face:List.of(child,middle,leader,sibling))graph.registerEmptyClassForPhaseF(face);
        observe(rows,"registration",graph,child,child,Map.of(x,x,y,y,z,z),0);
        graph.unionCertified(edge(child,application(middle,child,Map.of(m,y,n,z)),0,false));
        observe(rows,"direct",graph,child,middle,Map.of(m,y,n,z),1);
        graph.unionCertified(edge(middle,application(leader,middle,Map.of(u,m,v,n)),1,true));
        graph.unionCertified(edge(sibling,application(leader,sibling,Map.of(u,p,v,q)),2,false));
        observe(rows,"reversed-input-oriented",graph,middle,leader,Map.of(u,m,v,n),1);
        var pre=graph.findWithProvenance(TypedInvocation.identity(child));
        require(pre.hasParentCertificate()&&pre.parentCertificate().rightEndpoint().equals(
            TypedCertificateEndpoint.invocation(application(leader,child,Map.of(u,y,v,z)))),"compressed find return");
        observe(rows,"compressed",graph,child,leader,Map.of(u,y,v,z),2);
        var kept=TypedSlotContext.singleton(u);var include=TypedEmbedding.inclusion(kept,leader.exposedSlots());
        var old=TypedCertificateEndpoint.eclassWitness(leader);
        var narrow=TypedCertificateEndpoint.restrictedWitness(leader,kept).act(include);
        var eq=new InputEquationCertificate(CertificateOrigin.inputEquation("P4-04","constant-true-independent-of-int",3),old,narrow);
        var restriction=new InterfaceRestrictionCertificate(graph.eclass(leader.id()),kept,eq);
        graph.restrictInterfaceCertified(restriction);
        var current=restriction.restrictedInterface();
        observe(rows,"restricted-root",graph,current,current,Map.of(u,u),0);
        observe(rows,"restricted-deep",graph,child,current,Map.of(u,y),1);
        observe(rows,"restricted-middle",graph,middle,current,Map.of(u,m),1);
        observe(rows,"restricted-sibling",graph,sibling,current,Map.of(u,p),1);
        var history=graph.findWithProvenance(TypedInvocation.identity(leader));
        var cert=history.parentCertificate();CertificateVerifier.verify(cert);
        require(cert.leftEndpoint().equals(old)&&cert.rightEndpoint().equals(
            TypedCertificateEndpoint.invocation(new TypedInvocation(current,include))),"historical endpoint normalization");
        rows.add("historical-leader\t3\t3\t"+ids(include.mapping())+"\t0");
        graph.rebuild();graph.checkInvariants();
    }
    private static void publicCollision(List<String> rows) {
        var graph=new TypedSlottedPortEGraph();var empty=TypedSlotContext.empty();
        var op=OperatorDeclaration.monomorphic("p404-constant",List.of(),GraphType.BOOL,Map.of(),null).instantiateMonomorphic();
        var node=TypedENode.construct(op,empty,List.of());
        var one=graph.insertNode(node,graph.coherentWitnessFamily()).insertedClass();
        var two=graph.insertNode(node,graph.coherentWitnessFamily()).insertedClass();
        var assignments=graph.parentAssignments();
        var child=assignments.get(one.id()).isRoot()?two:one;
        var parent=child.equals(one)?two:one;
        observe(rows,"public-insertion-collision",graph,child,parent,Map.of(),1);
    }
    private static void structuralBoundary(List<String> rows) {
        var a=face(50);var b=face(51);var structural=TypedSlottedPortEGraph.structuralFixture();
        var step=new ParentStep(a,TypedInvocation.identity(b));
        for(var graph:List.of(new TypedSlottedPortEGraph(),TypedSlottedPortEGraph.certifiedFixture())) {
            graph.registerEmptyClassForPhaseF(a);graph.registerEmptyClassForPhaseF(b);
            var before=graph.parentAssignments();
            try {graph.linkLeadersForPhaseD(step);throw new AssertionError("fixture link on certificate graph");}
            catch(IllegalStateException expected){require(expected.getMessage().contains("only to structural gate fixtures"),"wrong boundary");}
            require(before.equals(graph.parentAssignments()),"rejected setup left state unchanged");
            rows.add(graph.certificateMode()+"-raw-denied\t50\t51\tunchanged\t0");
        }
        structural.registerRecordForPhaseD(TypedEClassRecord.empty(a));structural.registerRecordForPhaseD(TypedEClassRecord.empty(b));
        structural.linkLeadersForPhaseD(step);
        var res=structural.findWithProvenance(TypedInvocation.identity(a));
        require(!res.hasParentCertificate(),"the structural fixture has no parent proof");
        try {res.parentCertificate();throw new AssertionError("structural path certified");}
        catch(IllegalStateException expected){require(expected.getMessage().contains("cannot be replayed"),"wrong structural diagnostic");}
        rows.add("structural-only\t50\t51\tuncertified\t1");
    }
    private static void existing(Class<?> owner,String method,List<String> rows) throws Exception {
        var m=owner.getDeclaredMethod(method);m.setAccessible(true);m.invoke(null);
        rows.add("existing\t"+owner.getSimpleName()+"\t"+method+"\tpass\t-");
    }
    public static void main(String[] args) throws Exception {
        if(args.length!=2)throw new IllegalArgumentException("CHECKOUT FRESH_RESULTS_DIR");
        Path out=Path.of(args[1]);
        var writers=P404ParentWrites.verify(Path.of(args[0]));
        Files.write(out.resolve("parent-writes.tsv"),writers,StandardCharsets.UTF_8,StandardOpenOption.CREATE_NEW);
        String lean=Objects.requireNonNull(System.getenv("ACGN_ELEVENTH_LEAN"),"registered Lean tool");
        String proof=Objects.requireNonNull(System.getenv("ACGN_ELEVENTH_PROOF"),"registered executable checker");
        var replay=new ProcessBuilder(lean,"--run",proof,out.resolve("parent-writes.tsv").toString()).inheritIO().start();
        try {
            require(replay.waitFor(60,java.util.concurrent.TimeUnit.SECONDS)&&replay.exitValue()==0,"extracted write replay");
        } finally {if(replay.isAlive())replay.destroyForcibly();}
        var rows=new ArrayList<String>();multi(rows);publicCollision(rows);structuralBoundary(rows);
        existing(TheoryCertificatesTest.class,"testCertificateAlgebra",rows);
        existing(TheoryCertificatesTest.class,"testCertifiedUnionAndFindReplay",rows);
        existing(TheoryCertificatesTest.class,"testGeneratedCertifiedChains",rows);
        existing(TheoryRebuildTest.class,"testRestrictionObligationIsNotInferred",rows);
        existing(TheoryStateTest.class,"testParentDirectionAndCompression",rows);
        Files.write(out.resolve("parent-observations.tsv"),rows,StandardCharsets.UTF_8,StandardOpenOption.CREATE_NEW);
        System.out.println("P404 checked "+rows.size()+" assignment observations and existing unit controls");
    }
}
