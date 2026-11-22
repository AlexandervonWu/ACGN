package is.fivefivefive.CanDis.theory;

import java.util.List;
import java.util.ArrayList;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.concurrent.TimeUnit;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

/** Verifies the complete ownership and reverse-use views from independent record and port walks. */
public final class P407QualifiedUsesTest {
    private static void require(boolean ok, String message) {
        if (!ok) throw new AssertionError(message);
    }

    private static TypedENode node(String name, TypedSlotContext context, List<OnePort> ports) {
        var schemas = ports.stream().<PortSchema>map(OnePort::schema).toList();
        var operator = OperatorDeclaration.monomorphic(name, schemas, GraphType.BOOL, Map.of(), null)
                .instantiateMonomorphic();
        return TypedENode.construct(operator, context, ports);
    }

    private static TypedEClassRecord insert(TypedSlottedPortEGraph graph, TypedENode node) {
        return graph.eclass(graph.insertNode(node, graph.coherentWitnessFamily()).insertedClass().id());
    }

    private static OnePort invoke(TypedSlotContext context, TypedEClassRecord record) {
        var inclusion = TypedEmbedding.inclusion(record.exposedSlots(), context);
        return OnePort.invocation(context, new TypedInvocation(record.interfaceView(), inclusion));
    }

    private static void restrict(TypedSlottedPortEGraph graph, EClassId id, TypedSlotContext retained, int index) {
        var original = graph.eclass(id);
        var lhs = TypedCertificateEndpoint.eclassWitness(original.interfaceView());
        var rhs = TypedCertificateEndpoint.restrictedWitness(original.interfaceView(), retained)
                .act(TypedEmbedding.inclusion(retained, original.exposedSlots()));
        var input = new InputEquationCertificate(CertificateOrigin.inputEquation("P407", "K-ignores-free-arguments", index), lhs, rhs);
        graph.restrictInterfaceCertified(new InterfaceRestrictionCertificate(original, retained, input));
    }

    private static void identifyMarkers(TypedSlottedPortEGraph graph, TypedEClassRecord child, TypedEClassRecord parent) {
        // Both distinct nullary marker operators denote true in the witness interpretation.
        var rhs = TypedInvocation.identity(parent.interfaceView());
        var input = new InputEquationCertificate(CertificateOrigin.inputEquation("P407", "both-markers-denote-true", 0),
                TypedCertificateEndpoint.eclassWitness(child.interfaceView()), TypedCertificateEndpoint.invocation(rhs));
        graph.unionCertified(new ParentEdgeCertificate(child.interfaceView(), rhs, input));
    }

    private static void children(PortValue port, Set<EClassId> found) {
        if (port instanceof OnePort scalar) {
            if (scalar.leaf() instanceof InvocationPortLeaf leaf) found.add(leaf.invocation().eclass().id());
            else require(scalar.leaf() instanceof SlotPortLeaf, "unknown scalar port");
        } else if (port instanceof SeqPort seq) {
            seq.elements().forEach(v -> children(v, found));
        } else if (port instanceof SetPort set) {
            set.elements().forEach(v -> children(v, found));
        } else if (port instanceof BagPort bag) {
            bag.occurrences().forEach(v -> children(v, found));
        } else if (port instanceof BindPort bind) {
            children(bind.body(), found);
        } else if (port instanceof BindBlockPort block) {
            children(block.body(), found);
        } else {
            throw new AssertionError("unknown constructor " + port.getClass());
        }
    }

    private static void observe(TypedSlottedPortEGraph graph, int epoch,
                                Map<CanonicalShape,Integer> shapeIds, List<String> rows) {
        var assignments = graph.parentAssignments();
        var buckets = new TreeMap<CanonicalShape, Set<EClassId>>();
        var uses = new TreeMap<EClassId, Set<ParentRecordKey>>();
        for (var record : new TreeMap<>(graph.classes()).values()) {
            if (!assignments.get(record.id()).isRoot()) continue;
            for (var shape : record.shapeWitnesses().keySet()) {
                buckets.computeIfAbsent(shape, ignored -> new TreeSet<>()).add(record.id());
                var referenced = new TreeSet<EClassId>();
                for (var port : shape.node().ports()) children(port, referenced);
                int shapeId=shapeIds.computeIfAbsent(shape, unused->shapeIds.size());
                String refs=referenced.isEmpty() ? "_" : String.join(",",referenced.stream().map(id->Long.toString(id.value())).toList());
                rows.add(epoch+"\trecord\t"+record.id().value()+"\t"+shapeId+"\t"+refs);
                for (var child : referenced) {
                    uses.computeIfAbsent(child, ignored -> new TreeSet<>()).add(new ParentRecordKey(record.id(), shape));
                }
            }
        }
        require(buckets.equals(graph.hashBucketsSnapshot()), "owner-qualified bucket census");
        require(uses.equals(graph.parentUsesSnapshot()), "owner-qualified reverse-use census");
        for(var e:new TreeMap<>(graph.hashBucketsSnapshot()).entrySet()) {
            for(var owner:new TreeSet<>(e.getValue()))rows.add(epoch+"\thash\t"+owner.value()+"\t"+shapeIds.get(e.getKey())+"\t_");
        }
        for(var e:new TreeMap<>(graph.parentUsesSnapshot()).entrySet()) {
            for(var k:new TreeSet<>(e.getValue()))rows.add(epoch+"\tuse\t"+k.owner().value()+"\t"+shapeIds.get(k.shape())+"\t"+e.getKey().value());
        }
    }

    private static void replay(Path program,Path trace,int expected,String marker) throws Exception {
        var lean=System.getenv("ACGN_ELEVENTH_LEAN");
        var proof=System.getenv("ACGN_ELEVENTH_PROOF");
        require(lean!=null && proof!=null,"registered Lean replay environment");
        var log=Files.createTempFile("p407-replay",".log");
        try {
            var p=new ProcessBuilder(lean,"-j1","-M900","--run",proof,program.toString(),trace.toString())
                    .redirectErrorStream(true).redirectOutput(log.toFile()).start();
            if(!p.waitFor(45,TimeUnit.SECONDS)){p.destroyForcibly().waitFor();throw new AssertionError("P407 replay timeout");}
            require(p.exitValue()==expected && Files.readString(log).stripTrailing().endsWith(marker),"P407 replay "+marker);
        } finally { Files.deleteIfExists(log); }
    }

    public static void main(String[] args) throws Exception {
        require(args.length==4,"source fixtures verifierJar result.tsv");
        var result=Path.of(args[3]);
        var program=result.resolveSibling("p407-program.txt");
        var trace=result.resolveSibling("p407-observations.tsv");
        var summary=new ArrayList<String>(List.of("case\tresult"));
        summary.add("compiler\t"+P407SourceContract.verify(Path.of(args[0]),program));
        var rows=new ArrayList<String>();
        var shapeIds=new TreeMap<CanonicalShape,Integer>();
        var graph = new TypedSlottedPortEGraph();
        var empty = TypedSlotContext.empty();
        var left = insert(graph, node("P407-marker-left", empty, List.of()));
        var right = insert(graph, node("P407-marker-right", empty, List.of()));
        var x = TypedSlot.source(GraphType.INT, 11);
        var y = TypedSlot.source(GraphType.BOOL, 12);
        var ctx = TypedSlotContext.of(x,y);
        // K returns its Boolean marker and ignores the separately typed free arguments.
        var leftParent = insert(graph, node("P407-K", ctx, List.of(invoke(ctx,left), invoke(ctx,left),
                OnePort.slot(ctx,x),OnePort.slot(ctx,y))));
        var rightParent = insert(graph, node("P407-K", ctx, List.of(invoke(ctx,right), invoke(ctx,right),
                OnePort.slot(ctx,x),OnePort.slot(ctx,y))));
        observe(graph, 0, shapeIds, rows);
        var keepInt = leftParent.exposedSlots().slotsOfType(GraphType.INT).get(0);
        var keepBool = rightParent.exposedSlots().slotsOfType(GraphType.BOOL).get(0);
        restrict(graph, leftParent.id(), TypedSlotContext.singleton(keepInt), 0);
        restrict(graph, rightParent.id(), TypedSlotContext.singleton(keepBool), 1);
        graph.rebuild();
        observe(graph, 1, shapeIds, rows);
        identifyMarkers(graph, right, left);
        graph.rebuild();
        observe(graph, 2, shapeIds, rows);
        var shape = graph.eclass(leftParent.id()).shapeWitnesses().firstKey();
        var leftKey = new ParentRecordKey(leftParent.id(),shape);
        var rightKey = new ParentRecordKey(rightParent.id(),shape);
        require(graph.hashBucketsSnapshot().get(shape).equals(Set.of(leftParent.id(), rightParent.id())),
                "same exact shape has two incomparable live owners");
        require(graph.parentUsesSnapshot().get(left.id()).equals(Set.of(leftKey, rightKey)),
                "same child has both complete parent keys despite repeated invocation");
        var least = new TreeSet<>(Set.of(leftParent.id(), rightParent.id())).first();
        require(least.equals(graph.hashOwner(shape)) && least.equals(graph.hashConsSnapshot().get(shape)),
                "compatibility projections choose the least owner of the full bucket");
        require(!leftKey.structuralKey().equals(rightKey.structuralKey()), "owner differentiates structural record identities");
        restrict(graph, leftParent.id(), empty, 2);
        graph.rebuild();
        observe(graph, 3, shapeIds, rows);
        var survivors = graph.hashBucketsSnapshot().get(shape);
        require(survivors.size()==1, "a now-comparable owner coalesced");
        var survivor = survivors.iterator().next();
        require(graph.parentUsesSnapshot().get(left.id()).equals(Set.of(new ParentRecordKey(survivor,shape))),
                "removing one owner preserves its unrelated exact-shape sibling");
        summary.add("shared-shape-owners\t2");
        summary.add("shared-child-qualified-uses\t2");
        summary.add("surviving-shape-owners\t1");
        summary.add("surviving-qualified-uses\t1");
        Files.write(trace,rows);
        replay(program,trace,0,"P407 owner-qualified observations verified "+rows.size()+" rows");
        var incomplete=Files.createTempFile("p407-incomplete-observation",".tsv");
        try {
            var changed=new ArrayList<>(rows);
            var use=changed.stream().filter(r->r.startsWith("2\tuse\t")).findFirst().orElseThrow();
            changed.remove(use);
            Files.write(incomplete,changed);
            replay(program,incomplete,1,"P407 owner-qualified observation rejected");
        } finally { Files.deleteIfExists(incomplete); }
        summary.add("snapshot-replay\t"+rows.size()+" rows across 4 states");
        summary.add("incomplete-reverse-observation\tREJECTED");
        summary.addAll(org.acgn.cert.P407WireOwnerView.verify(Path.of(args[1]),Path.of(args[2])));
        Files.write(result,summary);
        System.out.println("P407QualifiedUsesTest passed: rows="+(summary.size()-1)+" snapshots=4");

    }
}
