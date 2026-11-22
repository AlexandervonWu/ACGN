package is.fivefivefive.CanDis.theory;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.concurrent.TimeUnit;

/** Compares every public bucket to a projection of independent record/parent snapshots. */
public final class P408OwnerRestorationTest {
    private static void require(boolean condition, String description) {
        if (!condition) throw new AssertionError(description);
    }

    static Map<CanonicalShape,Set<EClassId>> fromRecords(TypedSlottedPortEGraph graph) {
        var parents = graph.parentAssignments();
        var projected = new TreeMap<CanonicalShape,Set<EClassId>>();
        for (var entry : graph.classes().entrySet()) {
            if (!parents.get(entry.getKey()).isRoot()) continue;
            for (var shape : entry.getValue().shapeWitnesses().keySet())
                projected.computeIfAbsent(shape, ignored -> new TreeSet<>()).add(entry.getKey());
        }
        return projected;
    }

    static Map<CanonicalShape,Set<EClassId>> observe(TypedSlottedPortEGraph graph) {
        var actual = graph.hashBucketsSnapshot();
        var expected = fromRecords(graph);
        require(actual.equals(expected),"quiescent exact owner relation");
        for (var entry : expected.entrySet()) {
            var observed = actual.get(entry.getKey());
            require(!observed.isEmpty() && new ArrayList<>(observed).equals(new ArrayList<>(entry.getValue())),
                    "nonempty sorted owner membership");
            require(graph.hashOwner(entry.getKey()).equals(observed.iterator().next()),"least owner view");
        }
        require(graph.dirtyParentCount()==0,"quiescent work queue");
        return actual;
    }

    private static void gated(TypedSlottedPortEGraph g, CanonicalShape shape) {
        require(g.status()==GraphStatus.DIRTY,"restriction must enter dirty status");
        List<Runnable> reads = List.of(g::hashBucketsSnapshot,g::hashConsSnapshot,() -> g.hashOwner(shape));
        for(var read:reads) {
            try { read.run(); } catch(IllegalStateException e) { continue; }
            throw new AssertionError("dirty hash read");
        }
    }

    private static TypedENode node(String name, TypedSlotContext ctx, List<OnePort> ports) {
        var operator = OperatorDeclaration.monomorphic(name, ports.stream().<PortSchema>map(OnePort::schema).toList(),
                GraphType.BOOL,Map.of(),null).instantiateMonomorphic();
        return TypedENode.construct(operator,ctx,ports);
    }

    private static boolean denotation(boolean x,boolean y) {
        return (x || !x) && (y || !y);
    }

    private static void restrict(TypedSlottedPortEGraph graph, EClassId owner, int width, int step) {
        var current = graph.eclass(owner);
        var slots = List.copyOf(current.exposedSlots().slots());
        var retained = TypedSlotContext.of(slots.subList(0,width));
        // The two-slot literal in this fixture denotes true under all four Boolean
        // valuations; the unary parent denotes the literal unchanged. Each
        // explicitly supplied input factorization is true under its interpretation.
        for(boolean x:List.of(false,true)) for(boolean y:List.of(false,true))
            require(denotation(x,y) == denotation(x,false) && denotation(x,y) == denotation(false,false),
                    "input factorization in witness interpretation");
        var left = TypedCertificateEndpoint.eclassWitness(current.interfaceView());
        var right = TypedCertificateEndpoint.restrictedWitness(current.interfaceView(),retained)
                .act(TypedEmbedding.inclusion(retained,current.exposedSlots()));
        var input = new InputEquationCertificate(CertificateOrigin.inputEquation("P408",
                "boolean-tautology-independent-input",step),left,right);
        graph.restrictInterfaceCertified(new InterfaceRestrictionCertificate(current,retained,input));
    }

    private static String numbers(Collection<String> values) {
        return values.isEmpty() ? "_" : String.join(",",values);
    }

    private static String trace(String name,TypedSlottedPortEGraph graph, Map<CanonicalShape,Set<EClassId>> buckets,
                                Map<CanonicalShape,Integer> shapeIds) {
        var stored=graph.classes();
        var parents=graph.parentAssignments();
        var shapes=new TreeSet<>(buckets.keySet());
        stored.values().forEach(r -> shapes.addAll(r.shapeWitnesses().keySet()));
        for (var shape : shapes) shapeIds.computeIfAbsent(shape, ignored -> shapeIds.size());
        var rows=new ArrayList<String>();
        for(var entry:new TreeMap<>(stored).entrySet()) {
            rows.add(entry.getKey().value()+":"+(parents.get(entry.getKey()).isRoot() ? 1 : 0)+":"
                    +numbers(entry.getValue().shapeWitnesses().keySet().stream().map(k -> Integer.toString(shapeIds.get(k))).toList()));
        }
        var output=new ArrayList<String>();
        for(var entry:new TreeMap<>(buckets).entrySet())
            output.add(shapeIds.get(entry.getKey())+":"+numbers(entry.getValue().stream().map(i -> Long.toString(i.value())).toList()));
        return name+"\t"+(rows.isEmpty()?"-":String.join(";",rows))+"\t"+(output.isEmpty()?"-":String.join(";",output));
    }

    private static void replay(Path program,Path trace,Path log,int exit,String marker) throws Exception {
        String lean=Objects.requireNonNull(System.getenv("ACGN_TENTH_LEAN"));
        String proof=Objects.requireNonNull(System.getenv("ACGN_TENTH_PROOF"));
        var process=new ProcessBuilder(lean,"-j1","-M512","--run",proof,program.toString(),trace.toString())
                .redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if(!process.waitFor(45,TimeUnit.SECONDS)) {
            process.destroyForcibly().waitFor();
            throw new AssertionError("P408 Lean replay timed out");
        }
        require(process.exitValue()==exit && Files.readString(log).stripTrailing().endsWith(marker),"Lean replay "+marker);
    }

    public static void main(String[] args) throws Exception {
        if(args.length!=2)throw new IllegalArgumentException("expected source root and result TSV");
        var root=Path.of(args[0]);var result=Path.of(args[1]);
        var rows=new ArrayList<String>(List.of("case\tresult"));
        var states=new ArrayList<String>();
        var shapeIds=new TreeMap<CanonicalShape,Integer>();
        var program=result.resolveSibling("p408-live-owner-program.txt");
        var omitted=Files.createTempFile("p408-incomplete-program",".txt");
        var invalid=Files.createTempFile("p408-incomplete-observation",".tsv");
        var log=Files.createTempFile("p408-lean",".log");
        try {
            rows.add("compiler\t"+P408CompilerContract.verify(root,program,omitted));
            var graph = new TypedSlottedPortEGraph();
            states.add(trace("empty",graph,observe(graph),shapeIds));
            var stable = graph.insertNode(node("P408-true",TypedSlotContext.empty(),List.of()),graph.coherentWitnessFamily());
            var x = TypedSlot.source(GraphType.BOOL,10);
            var y = TypedSlot.source(GraphType.BOOL,11);
            var ctx = TypedSlotContext.of(x,y);
            var child = graph.insertNode(node("P408-boolean-tautology",ctx,List.of(OnePort.slot(ctx,x),OnePort.slot(ctx,y))),
                    graph.coherentWitnessFamily()).insertedClass();
            var pc = child.exposedSlots();
            var parent = graph.insertNode(node("P408-boolean-identity",pc,
                    List.of(OnePort.invocation(pc,TypedInvocation.identity(child)))),graph.coherentWitnessFamily()).insertedClass();
            var old=observe(graph);
            states.add(trace("unrestricted",graph,old,shapeIds));
            require(child.exposedSlots().size()==2 && parent.exposedSlots().size()==2, "two exposed slots");
            var stableKey=graph.eclass(stable.insertedClass().id()).shapeWitnesses().firstKey();
            var oldParent=graph.eclass(parent.id()).shapeWitnesses().firstKey();
            require(old.get(oldParent).contains(parent.id()),"initial parent is indexed");
            int ordinal=0;
            for (int width:List.of(1,0)) {
                var before = graph.eclass(parent.id()).shapeWitnesses().firstKey();
                long count=graph.hashIndexRebuildCount();
                restrict(graph,child.id(),width,ordinal++);
                gated(graph,before);
                require(graph.dirtyParentCount()>0,"real stored parent queued");
                var beforeRetry = graph.stateStructuralKey();
                try {
                    graph.rebuild();
                    throw new AssertionError("rebuild requires the parent factorization");
                } catch (InterfaceRestrictionRequiredException expected) {
                    gated(graph,before);
                    require(graph.dirtyParentCount() > 0 && beforeRetry.equals(graph.stateStructuralKey())
                            && graph.hashIndexRebuildCount() == count,"deferred parent restriction preserves dirty state");
                }
                restrict(graph,parent.id(),width,ordinal++);
                var report=graph.rebuild();
                require(report.processedRecords()>0 && graph.hashIndexRebuildCount()==count+1,"dirty rebuild performed");
                var now=observe(graph);
                var revised=graph.eclass(parent.id()).shapeWitnesses().firstKey();
                require(!before.equals(revised) && !now.containsKey(before),"retired parent shape removed");
                require(now.get(revised).contains(parent.id()) && now.get(stableKey).equals(old.get(stableKey)),
                        "revised and unrelated owner membership");
                require(graph.eclass(parent.id()).exposedSlots().size()==width,"restricted width");
                require(graph.rebuild().processedRecords()==0 && graph.hashIndexRebuildCount()==count+1
                        && observe(graph).equals(now),"quiescent re-observation");
                states.add(trace("width-"+width,graph,now,shapeIds));
                rows.add("interface-width-" + width + "\told-key-absent,new-owner-present,unrelated-preserved");
            }
            rows.add("deferred-parent-restriction\tDIRTY-until-factorization");
            int oldClasses=graph.classes().size();
            graph.insertNode(node("P408-true",TypedSlotContext.empty(),List.of()),graph.coherentWitnessFamily());
            if(graph.status()==GraphStatus.DIRTY)graph.rebuild();
            var coalesced=observe(graph);
            var retired=graph.parentAssignments().entrySet().stream().filter(e->!e.getValue().isRoot()).map(Map.Entry::getKey).toList();
            require(graph.classes().size()==oldClasses+1 && !retired.isEmpty(), "normal duplicate insertion coalesced a real owner");
            for(var owners:coalesced.values()) require(Collections.disjoint(owners,retired),"nonleader omitted from every bucket");
            states.add(trace("coalesced",graph,coalesced,shapeIds));
            rows.add("coalesced-owner\tfiltered-from-every-bucket");
            var traceFile=result.resolveSibling("p408-owner-observations.tsv");
            Files.write(traceFile,states);
            replay(program,traceFile,log,0,"P408 live-owner reconstruction verified "+states.size()+" snapshots");
            replay(omitted,traceFile,log,1,"P408 live-owner reconstruction program rejected");
            Files.writeString(invalid,trace("missing-observed-keys",graph,Map.of(),shapeIds)+"\n");
            replay(program,invalid,log,1,"P408 live-owner snapshot rejected");
            rows.add("live-snapshots\t"+states.size());
            rows.add("omitted-reconstruction\tREJECTED");rows.add("missing-observed-keys\tREJECTED");
            Files.write(result,rows);
            System.out.println("P408OwnerRestorationTest passed: rows="+(rows.size()-1));
        } finally {
            Files.deleteIfExists(log);Files.deleteIfExists(invalid);Files.deleteIfExists(omitted);
        }
    }
}
