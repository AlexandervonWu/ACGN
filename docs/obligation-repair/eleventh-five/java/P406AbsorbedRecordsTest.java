package is.fivefivefive.CanDis.theory;

import java.nio.file.*;
import java.util.*;
import java.util.concurrent.TimeUnit;
import is.fivefivefive.CanDis.theory.CertificateTracePayload.ShapeRecord;
import is.fivefivefive.CanDis.theory.CertificateTracePayload.Union;

/** Independent projection of strict, public producer calls on a constant-true Boolean interpretation. */
public final class P406AbsorbedRecordsTest {
    private P406AbsorbedRecordsTest() {}
    private static void check(boolean ok,String reason) {if (!ok) throw new AssertionError("P406 "+reason);}

    private static TypedENode node(String name,TypedSlotContext context,List<OnePort> ports) {
        var op=OperatorDeclaration.monomorphic(name,ports.stream().<PortSchema>map(OnePort::schema).toList(),
                GraphType.BOOL,Map.of(),null).instantiateMonomorphic();
        return TypedENode.construct(op,context,ports);
    }
    private static TypedENode literal(String name) {return node(name,TypedSlotContext.empty(),List.of());}
    private static TypedEClassInterface put(TypedSlottedPortEGraph graph,TypedENode node) {
        return graph.insertNode(node,graph.coherentWitnessFamily()).insertedClass();
    }
    private static TypedENode wrapper(TypedEClassInterface child) {
        var context=child.exposedSlots();
        return node("P406-true-wrapper",context,List.of(OnePort.invocation(context,TypedInvocation.identity(child))));
    }
    private static ParentEdgeCertificate edge(TypedEClassInterface from,TypedEClassInterface to,TypedEmbedding embedding,int n) {
        // Each operator used here denotes true on every Boolean valuation. Hence all explicit
        // input equations, including the one ignoring a free coordinate, hold in this interpretation.
        var invoked=new TypedInvocation(to,embedding);
        var eq=new InputEquationCertificate(CertificateOrigin.inputEquation("P406","constant-true",n),
                TypedCertificateEndpoint.eclassWitness(from),TypedCertificateEndpoint.invocation(invoked));
        return new ParentEdgeCertificate(from,invoked,eq);
    }
    private static void checkRebuilt(ShapeRecord old,ShapeRecord next,ParentEdgeCertificate edge) {
        check(old.key().owner().equals(edge.child().id()) && next.key().owner().equals(edge.parent().id())
                && next.key().shape().equals(old.key().shape()),"source and target identity");
        var inclusion=TypedEmbedding.inclusion(edge.child().exposedSlots(),old.witness().ambientSupport());
        var relabel=old.witness().instantiatingRenaming().inverse().andThen(next.witness().instantiatingRenaming());
        for(var slot:edge.parent().exposedSlots())
            check(relabel.apply(edge.embedding().apply(slot)).equals(slot),"parent slot transported to literal parent interface");
        var source=TypedCertificateEndpoint.node(old.key().shape().node().act(old.witness().instantiatingRenaming()));
        var owner=TypedCertificateEndpoint.invocation(new TypedInvocation(edge.child(),inclusion));
        var oriented=EqualityCertificates.orient(old.ownerEquation(),source,owner);
        var composed=EqualityCertificates.transitive(oriented,EqualityCertificates.rename(edge,inclusion));
        var rebuilt=EqualityCertificates.rename(composed,relabel);
        var targetNode=TypedCertificateEndpoint.node(next.key().shape().node().act(next.witness().instantiatingRenaming()));
        var targetOwner=TypedCertificateEndpoint.invocation(new TypedInvocation(edge.parent(),
                    TypedEmbedding.inclusion(edge.parent().exposedSlots(),next.witness().ambientSupport())));
        var checked=EqualityCertificates.orient(rebuilt,targetNode,targetOwner);
        CertificateVerifier.verify(checked); CertificateVerifier.verify(next.ownerEquation());
        check(checked.structuralKey().equals(next.ownerEquation().structuralKey()),"exact independently recomposed owner proof");
    }
    private static String ids(Collection<CanonicalShape> keys,Map<CanonicalShape,Integer> ids) {
        return keys.isEmpty()?"_":String.join(",",keys.stream().map(key->Integer.toString(ids.get(key))).toList());
    }
    private static TreeSet<CanonicalShape> slice(Map<ParentRecordKey,ShapeRecord> live,EClassId owner) {
        var shapes=new TreeSet<CanonicalShape>();
        live.keySet().stream().filter(k->k.owner().equals(owner)).forEach(k->shapes.add(k.shape()));
        return shapes;
    }
    private static void observe(String route,Union union,TreeMap<ParentRecordKey,ShapeRecord> live,
                                TreeMap<ParentRecordKey,RetiredShapeRecordCertificate> ledger,List<String> traces,List<String> cases) {
        var edge=union.certificate(); var child=edge.child().id(); var parent=edge.parent().id();
        var src=slice(live,child); var dst=slice(live,parent);
        var moved=new ArrayList<CanonicalShape>();var dup=new ArrayList<CanonicalShape>();
        var newLedger=new TreeSet<CanonicalShape>();
        var all=new TreeSet<>(src);all.addAll(dst);
        var shapeIds=new TreeMap<CanonicalShape,Integer>();for(var shape:all)shapeIds.put(shape,shapeIds.size());
        for(var item:union.rehomes()) {
            var old=item.original();var next=item.replacement();
            check(old.equals(live.remove(old.key())),"exact old rehome record");
            checkRebuilt(old,next,edge);
            check(live.putIfAbsent(next.key(),next)==null,"fresh unique candidate");
            moved.add(old.key().shape());
        }
        for(var item:union.retirements()) {
            item.verify();var old=item.retiredShapeRecord();var keep=item.retainedShapeRecord();
            check(item.cause()==RetiredShapeRecordCertificate.Cause.OWNER_UNION && item.parentEdge().equals(edge)
                            && old.equals(live.remove(old.key())),"old duplicate record and directed proof");
            checkRebuilt(old,item.replacementShapeRecord(),edge);
            check(item.replacementRecord().equals(keep.key()) && keep.equals(live.get(keep.key())),
                    "retained exact original owner proof and witness");
            check(ledger.putIfAbsent(old.key(),item)==null,"unique new retirement");
            newLedger.add(old.key().shape()); dup.add(old.key().shape());
        }
        check(slice(live,child).isEmpty() && src.size()==moved.size()+dup.size(),"old source exactly partitioned");
        check(src.stream().filter(dst::contains).toList().equals(dup)
                && src.stream().filter(k->!dst.contains(k)).toList().equals(moved),"pointwise branch classification");
        traces.add(String.join("\t",route,ids(src,shapeIds),ids(dst,shapeIds),ids(moved,shapeIds),ids(dup,shapeIds),
                            ids(slice(live,parent),shapeIds),ids(newLedger,shapeIds)));
        cases.add(route+"\t"+src.size()+"\t"+moved.size()+"\t"+dup.size()+"\t"+edge.child().exposedSlots().size()
                  +"\t"+edge.parent().exposedSlots().size());
    }
    private static void stream(String label,RecordingCertificateTraceSink sink,List<String> projections,List<String> cases) {
        int n=0;
        for(var event:sink.events()) {
            var live=new TreeMap<>(event.before().liveShapeRecords());
            var ledger=new TreeMap<>(event.before().retiredShapeRecords());
            List<Union> unions;
            if(event.payload() instanceof Union u) unions=List.of(u);
            else if(event.payload() instanceof CertificateTracePayload.Insertion p && !p.generatedSubtransitions().isEmpty()){
                var result=p.result();var key=new ParentRecordKey(result.insertedClass().id(),result.canonicalization().shape());
                var fresh=new ShapeRecord(key,result.insertedClass(),result.shapeWitness(),result.shapeEquation());
                check(live.putIfAbsent(key,fresh)==null,"fresh insertion before nested union");unions=p.generatedSubtransitions();
            } else if(event.payload() instanceof CertificateTracePayload.RebuildRecord p && !p.generatedSubtransitions().isEmpty()){
                check(live.remove(p.original()).equals(p.originalRecord()),"nested rebuild source");
                if(p.replacementRecord()!=null)check(live.putIfAbsent(p.replacementRecord().key(),p.replacementRecord())==null,"rebuilt record");
                else {
                    var retired=p.retirement();
                    check(live.get(retired.retainedRecord()).equals(retired.retainedShapeRecord()) && ledger.putIfAbsent(retired.retiredRecord(),retired)==null,
                            "base rebuild retirement");
                }
                unions=p.generatedSubtransitions();
            } else continue;
            for(var u:unions)observe(label+"-"+event.kind()+"-"+n++,u,live,ledger,projections,cases);
            check(live.equals(event.after().liveShapeRecords()) && ledger.equals(event.after().retiredShapeRecords()),
                    "complete post-state records and ledger (all owners)");
            event.before().verifyConservationTo(event.after(),event.payload());
        }
    }
    private static void replay(Path program,Path observations,Path log,int code,String marker) throws Exception {
        var proc=new ProcessBuilder(Objects.requireNonNull(System.getenv("ACGN_ELEVENTH_LEAN")),"-j1","-M512","--run",
                Objects.requireNonNull(System.getenv("ACGN_ELEVENTH_PROOF")),program.toString(),observations.toString())
                .redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if(!proc.waitFor(45,TimeUnit.SECONDS)){proc.destroyForcibly().waitFor();throw new AssertionError("P406 kernel replay timeout");}
        check(proc.exitValue()==code && Files.readString(log).stripTrailing().endsWith(marker),"Lean replay "+marker);
    }
    public static void main(String[] args) throws Exception {
        if(args.length!=2)throw new IllegalArgumentException("source root, result TSV");
        var root=Path.of(args[0]);var result=Path.of(args[1]);
        var program=result.resolveSibling("p406-program.tsv");var observations=result.resolveSibling("p406-project.tsv");
        String source=P406TransferProgram.extract(root,program);
        var traces=new ArrayList<String>();var cases=new ArrayList<String>();
        cases.add("case\tsource\trehome\tretire\tchild-width\tparent-width");
        var empty=TypedSlotContext.empty();var sink=new RecordingCertificateTraceSink();var g=new TypedSlottedPortEGraph(sink);
        var a=put(g,literal("P406-a"));var b=put(g,literal("P406-b"));var c=put(g,literal("P406-c"));
        var first=edge(a,b,TypedEmbedding.identity(empty),1);g.unionCertified(first);
        var before=g.stateStructuralKey();int events=sink.events().size();
        try{g.unionCertified(first);throw new AssertionError("reused nonleader edge");}
        catch(IllegalArgumentException expected){check(g.stateStructuralKey().equals(before) && sink.events().size()==events,"ordinary admission refusal is read-only");}
        g.unionCertified(edge(b,c,TypedEmbedding.identity(empty),2));g.rebuild();
        put(g,literal("P406-c"));g.rebuild();stream("ordinary",sink,traces,cases);
        var xs=TypedSlot.source(GraphType.BOOL,31);var ys=TypedSlot.source(GraphType.BOOL,32);
        var ctx=TypedSlotContext.of(xs,ys);var one=TypedSlotContext.singleton(xs);
        sink=new RecordingCertificateTraceSink();g=new TypedSlottedPortEGraph(sink);
        var twoArgs=put(g,node("P406-true-two",ctx,List.of(OnePort.slot(ctx,xs),OnePort.slot(ctx,ys))));
        var oneArg=put(g,node("P406-true-one",one,List.of(OnePort.slot(one,xs))));
        var map=Map.of(oneArg.exposedSlots().iterator().next(),List.copyOf(twoArgs.exposedSlots().slots()).get(1));
        g.unionCertified(edge(twoArgs,oneArg,TypedEmbedding.of(oneArg.exposedSlots(),twoArgs.exposedSlots(),map),3));
        g.rebuild();stream("relabel",sink,traces,cases);
        sink=new RecordingCertificateTraceSink();g=new TypedSlottedPortEGraph(sink);
        var left=put(g,literal("P406-left"));var right=put(g,literal("P406-right"));
        put(g,wrapper(left));put(g,wrapper(right));g.unionCertified(edge(left,right,TypedEmbedding.identity(empty),4));g.rebuild();
        stream("rebuild",sink,traces,cases);
        sink=new RecordingCertificateTraceSink();g=new TypedSlottedPortEGraph(sink);
        left=put(g,literal("P406-mixed-left"));right=put(g,literal("P406-mixed-right"));
        put(g,wrapper(left));var rightParent=put(g,wrapper(right));
        var extra=put(g,literal("P406-extra-distinct"));
        g.unionCertified(edge(extra,rightParent,TypedEmbedding.identity(empty),5));
        g.unionCertified(edge(left,right,TypedEmbedding.identity(empty),6));g.rebuild();
        stream("mixed",sink,traces,cases);
        check(cases.stream().anyMatch(x->x.startsWith("mixed-REBUILD_RECORD") && x.contains("\t2\t1\t1\t")),
                "same absorbed owner both rehomed a distinct shape and retired a duplicate");
        var recorded=new RecordingCertificateTraceSink();
        class InterruptedObserver extends RuntimeException {}
        var observer=new CertificateTraceSink() {
            public boolean enabled(){return true;}
            public void append(CertificateTraceEvent event) {
                recorded.append(event);
                if(event.kind()==CertificateTraceEvent.Kind.UNION)throw new InterruptedObserver();
            }
        };
        g=new TypedSlottedPortEGraph(observer);
        left=put(g,literal("P406-observer-left"));right=put(g,literal("P406-observer-right"));
        try {g.unionCertified(edge(left,right,TypedEmbedding.identity(empty),7));throw new AssertionError("observer notification");}
        catch(InterruptedObserver expected) {
            check(!g.isLeader(left.id()) && g.eclass(left.id()).shapeWitnesses().isEmpty()
                    && g.eclass(right.id()).shapeWitnesses().size()==2,"observable post-install exception retains transfer");
            g.checkInvariants();
        }
        stream("observer",recorded,traces,cases);
        check(cases.stream().anyMatch(x->x.startsWith("ordinary-INSERT_COLLISION") && x.contains("\t1\t0\t1\t")),"ordinary duplicate insertion retired");
        check(cases.stream().anyMatch(x->x.startsWith("ordinary-UNION") && x.contains("\t2\t2\t0\t")),"all shapes of two-record child rehomed");
        check(cases.stream().anyMatch(x->x.startsWith("rebuild-REBUILD_RECORD") && x.contains("\t1\t0\t1\t")),"nested rebuild generated retirement");
        check(cases.stream().anyMatch(x->x.startsWith("relabel-UNION") && x.endsWith("\t2\t1")),"nonidentity parent embedding");
        Files.write(observations,traces);
        var bad=Files.createTempFile("p406-program-",".tsv");var missing=Files.createTempFile("p406-projection-",".tsv");
        var log=Files.createTempFile("p406-replay-",".txt");
        try {
            replay(program,observations,log,0,"P406 transfer partitions verified: "+traces.size());
            var shortProgram=new ArrayList<>(Files.readAllLines(program));check(shortProgram.remove("duplicate-keep-add-retirement"),"registered retirement step");
            Files.write(bad,shortProgram);replay(bad,observations,log,1,"P406 attributed transfer program rejected");
            Files.writeString(missing,"missing-candidate\t0\t_\t_\t_\t_\t_\n");
            replay(program,missing,log,1,"P406 transfer projection rejected");
        } finally {Files.deleteIfExists(bad);Files.deleteIfExists(missing);Files.deleteIfExists(log);}
        Files.write(result,cases);
        System.out.println("P406TransferProgram: "+source);
        System.out.println("P406AbsorbedRecordsTest passed: "+traces.size()+" certified unions, two omission controls");
    }
}
