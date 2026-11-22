package is.fivefivefive.CanDis.theory;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.net.URI;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import javax.lang.model.element.*;
import javax.tools.*;

/** Extracts the live-owner traversal and dirty-to-quiescent completion stream from javac. */
public final class P408CompilerContract {
    private static final String PACKAGE="is.fivefivefive.CanDis.theory.";
    private static final String GRAPH="TypedSlottedPortEGraph";
    private static final String PIN="b97926b51f6b0f081c1dca0567629c9aed145e1b194b3833617453347ad3811a";
    private static final Map<String,List<String>> METHODS=Map.of(
        GRAPH,List.of("restrictInterfaceCertified/1","verifyInterfaceRestriction/1","rebuild/0","rebuild/1",
            "rebuildHashConsExactly/0","requireHashBucketsExact/0","addHashOwner/2","checkInvariants/0",
            "hashBucketsSnapshot/0","hashConsSnapshot/0","hashOwner/1","requireQuiescent/0",
            "sealEmptyShapeFixtureForPhaseE/0","markParentsDirty/1","isLeader/1","classes/0","parentAssignments/0"),
        "TypedRenamedUnionFind",List.of("restrictLeader/1","isLeader/1"),
        "ParentAssignment",List.of("isRoot/0"),
        "TypedEClassRecord",List.of("withInterfaceAndState/3","withSymmetryGroup/1","withoutStoredShapes/0","withoutStoredShape/1","withStoredShape/2","shapeWitnesses/0","id/0"),
        "CanonicalShape",List.of("equals/1","compareTo/1"), "EClassId",List.of("equals/1","compareTo/1"));

    private static void check(boolean ok,String reason) {
        if(!ok) throw new IllegalArgumentException("P408 compiler: "+reason);
    }
    private static String compact(Tree t) {return t.toString().replaceAll("\\s+","");}
    private static void ordered(Tree body,String... codes) {
        String value=compact(body);int at=0;
        for(String code:codes) {
            int next=value.indexOf(code,at);check(next>=0,"missing "+code);at=next+code.length();
        }
    }
    private static String signature(Element e) {
        if(e instanceof ExecutableElement m && m.getEnclosingElement() instanceof TypeElement owner)
            return owner.getQualifiedName()+"#"+m.getSimpleName()+":"+m.asType();
        throw new IllegalArgumentException("P408 unresolved invocation");
    }
    private static void add(MessageDigest h,String str) {
        byte[] b=str.getBytes(StandardCharsets.UTF_8);
        h.update(ByteBuffer.allocate(4).putInt(b.length).array());h.update(b);
    }
    private record Result(List<String> program,String digest,int methods,List<String> statusWrites,List<String> classWrites) {}
    private static List<? extends StatementTree> body(StatementTree tree) {
        check(tree instanceof BlockTree,"expected block");return ((BlockTree)tree).getStatements();
    }
    private static void traversal(EnhancedForLoopTree loop,boolean populate) {
        check(compact(loop.getVariable()).equals("TypedEClassRecordrecord") && compact(loop.getExpression()).equals("classes.values()"),"iterate actual class records");
        var statements=body(loop.getStatement());
        check(statements.size()==2 && statements.get(0) instanceof IfTree && statements.get(1) instanceof EnhancedForLoopTree,"nested loop");
        IfTree guard=(IfTree)statements.get(0);
        check(compact(guard.getCondition()).equals("(!unionFind.isLeader(record.id()))") && guard.getElseStatement()==null
                && body(guard.getThenStatement()).size()==1 && body(guard.getThenStatement()).get(0) instanceof ContinueTree,"leader skip");
        var inner=(EnhancedForLoopTree)statements.get(1);
        check(compact(inner.getVariable()).equals("CanonicalShapeshape") && compact(inner.getExpression()).equals("record.shapeWitnesses().keySet()"),"stored shape traversal");
        var write=body(inner.getStatement());
        check(write.size()==1 && compact(write.get(0)).equals(populate ? "addHashOwner(shape,record.id());" :
                "expected.computeIfAbsent(shape,(ignored)->newTreeSet<>()).add(record.id());"),"exact shape/owner insertion: "+compact(write.get(0)));
    }

    private static List<String> lower(Map<String,MethodTree> m) {
        for(String name:List.of("rebuild/0","restrictInterfaceCertified/1","hashBucketsSnapshot/0",
                "hashConsSnapshot/0","hashOwner/1","classes/0","parentAssignments/0")) {
            var flags=m.get(GRAPH+"#"+name).getModifiers().getFlags();
            check(flags.contains(Modifier.PUBLIC) && flags.contains(Modifier.SYNCHRONIZED),
                    "normal transition/read holds graph monitor: "+name);
        }
        var fn=m.get(GRAPH+"#rebuild/1");
        var tr=fn.getBody().getStatements().stream().filter(TryTree.class::isInstance).map(TryTree.class::cast).toList();
        check(tr.size()==1,"one rebuild completion interval");
        var stmts=tr.get(0).getBlock().getStatements();
        check(stmts.get(0) instanceof WhileLoopTree,"dirty work precedes reconstruction");
        ordered(stmts.get(0),"while(!dirtyParents.isEmpty())","requireUnionBudget(","if(resolved==0&&dirtyParents.isEmpty())",
                "freshTransitions=resolveAllShapeCollisionsDetailed(true)","if(freshResolved==0&&dirtyParents.isEmpty())","break;");
        ordered(fn.getBody(),"if(!requiresCertificates())","if(rebuildActive)","if(status==GraphStatus.QUIESCENT)",
                "checkInvariants()","returnnewRebuildReport(0,0,0,0,0)","rebuildActive=true","try{");
        ordered(tr.get(0).getCatches().get(0),"RuntimeExceptionexception","status=GraphStatus.DIRTY","throwexception");
        ordered(tr.get(0).getFinallyBlock(),"rebuildingRecord=null","rebuildActive=false");
        var helper=m.get(GRAPH+"#rebuildHashConsExactly/0").getBody().getStatements();
        var chk=m.get(GRAPH+"#requireHashBucketsExact/0").getBody().getStatements();
        check(chk.size()==3 && chk.get(1) instanceof EnhancedForLoopTree,"check loop");
        traversal((EnhancedForLoopTree)chk.get(1),false);
        ordered(chk.get(0),"expected=newTreeMap<>()");ordered(chk.get(2),"if(!expected.equals(hashCons))","thrownewIllegalStateException");
        ordered(m.get(GRAPH+"#addHashOwner/2").getBody(),"hashCons.computeIfAbsent(shape,(ignored)->newTreeSet<>()).add(owner)");
        var ops=new ArrayList<String>();
        for(int i=1;i<stmts.size();i++) {
            switch(compact(stmts.get(i))) {
                case "requireHashBucketsExact();" -> ops.add("validate");
                case "hashCons.clear();" -> ops.add("clear-index");
                case "rebuildHashConsExactly();" -> {
                    for(var step:helper) {
                        if(compact(step).equals("hashCons.clear();"))ops.add("clear-index");
                        else if(step instanceof EnhancedForLoopTree loop) {
                            traversal(loop,true);ops.add("visit-live-owners");
                        } else check(compact(step).equals("hashIndexRebuilds=Math.incrementExact(hashIndexRebuilds);"),"unexpected helper operation");
                    }
                }
                case "status=GraphStatus.QUIESCENT;" -> ops.add("publish-quiescent");
                default -> {}
            }
        }
        ordered(tr.get(0).getBlock(),"status=GraphStatus.QUIESCENT","checkInvariants()","REBUILD_COMPLETE","returnreport");
        ordered(m.get(GRAPH+"#restrictInterfaceCertified/1").getBody(),"if(!requiresCertificates())","verifyInterfaceRestriction(checked)",
                "!unionFind.isLeader(originalRecord.id())","unionFind.restrictLeader(checked)","originalRecord.withInterfaceAndState(",
                "classes.put(replacement.id(),replacement)","markParentsDirty(replacement.id())","status=GraphStatus.DIRTY","checkInvariants()");
        for(String get:List.of("hashBucketsSnapshot/0","hashConsSnapshot/0","hashOwner/1"))
            check(compact(m.get(GRAPH+"#"+get).getBody().getStatements().get(0)).equals("requireQuiescent();"),"gated public hash observation");
        ordered(m.get(GRAPH+"#sealEmptyShapeFixtureForPhaseE/0").getBody(),"requireStructuralFixture(","!record.shapeWitnesses().isEmpty()",
                "!hashCons.isEmpty()","status=GraphStatus.QUIESCENT","checkInvariants()");
        return List.copyOf(ops);
    }

    private static Result compile(Path repo,boolean omitLoop) throws Exception {
        var source=new ArrayList<JavaFileObject>();
        for(String type:new TreeSet<>(METHODS.keySet())) {
            var file=repo.resolve("src/"+PACKAGE.replace('.','/')+type+".java");
            String body=Files.readString(file);
            if(type.equals(GRAPH) && omitLoop) {
                int start=body.indexOf("    private void rebuildHashConsExactly()");
                int a=body.indexOf("        for (TypedEClassRecord",start), b=body.indexOf("        hashIndexRebuilds =",a);
                check(start>=0 && a>start && b>a,"historical incomplete-rebuild control");
                body=body.substring(0,a)+body.substring(b);
            }
            String text=body;
            source.add(new SimpleJavaFileObject(URI.create("string:///"+PACKAGE.replace('.','/')+type+".java"),JavaFileObject.Kind.SOURCE) {
                public CharSequence getCharContent(boolean ignored) {return text;}
            });
        }
        var compiler=ToolProvider.getSystemJavaCompiler();var diagnostics=new DiagnosticCollector<JavaFileObject>();
        var m=new TreeMap<String,MethodTree>();var data=new TreeMap<String,List<String>>();var writes=new ArrayList<String>();var classWrites=new ArrayList<String>();var recordWriters=new TreeSet<String>();
        var roots=Map.of("classes","newTreeMap<>()","hashCons","newTreeMap<>()","unionFind","newTypedRenamedUnionFind()",
                "status","GraphStatus.QUIESCENT");
        var inspectedRoots=new TreeSet<String>();
        try(var fm=compiler.getStandardFileManager(diagnostics,Locale.ROOT,StandardCharsets.UTF_8)) {
            var task=(JavacTask)compiler.getTask(null,fm,diagnostics,List.of("--release","17","-proc:none","-classpath",
                    System.getProperty("java.class.path")),null,source);
            var units=new ArrayList<CompilationUnitTree>();task.parse().forEach(units::add);task.analyze();
            for(var d:diagnostics.getDiagnostics())check(d.getKind()!=Diagnostic.Kind.ERROR,d.toString());
            var trees=Trees.instance(task);
            for(var u:units)new TreePathScanner<Void,Void>() {
                @Override public Void visitVariable(VariableTree field,Void unused) {
                    var element=trees.getElement(getCurrentPath());
                    if(element != null && element.getEnclosingElement() instanceof TypeElement owner
                            && owner.getQualifiedName().contentEquals(PACKAGE+GRAPH)) {
                        String name=field.getName().toString();
                        if(roots.containsKey(name)) {
                            var flags=field.getModifiers().getFlags();
                            check(inspectedRoots.add(name) && field.getInitializer()!=null && flags.contains(Modifier.PRIVATE)
                                    && (name.equals("status") || flags.contains(Modifier.FINAL))
                                    && compact(field.getInitializer()).equals(roots.get(name)), "fresh graph field "+name);
                        }
                    }
                    return super.visitVariable(field,unused);
                }
                @Override public Void visitMethod(MethodTree method,Void unused) {
                    var el=(ExecutableElement)trees.getElement(getCurrentPath());
                    String owner=el.getEnclosingElement().getSimpleName().toString();
                    String name=method.getName()+"/"+method.getParameters().size(),key=owner+"#"+name;
                    boolean mutator=owner.equals(GRAPH) && method.getBody()!=null && method.getBody().toString().contains("classes.put(");
                    if(mutator)recordWriters.add(key);
                    boolean selected=mutator || METHODS.getOrDefault(owner,List.of()).contains(name);
                    var trace=new ArrayList<String>();
                    if(selected) {
                        check(m.put(key,method)==null,"ambiguous "+key);data.put(key,trace);
                        trace.add(signature(el));trace.add(method.getBody().toString());
                    }
                    if(method.getBody()!=null)new TreePathScanner<Void,Void>() {
                        @Override public Void visitAssignment(AssignmentTree a,Void v) {
                            var e=trees.getElement(new TreePath(getCurrentPath(),a.getVariable()));
                            if(e!=null && e.getSimpleName().contentEquals("status") && e.getEnclosingElement() instanceof TypeElement t
                                    && t.getQualifiedName().contentEquals(PACKAGE+GRAPH)) writes.add(key+"="+compact(a.getExpression()));
                            return super.visitAssignment(a,v);
                        }
                        private void handle(Tree tree) { if(selected)trace.add(tree.getKind()+" "+signature(trees.getElement(getCurrentPath()))); }
                        @Override public Void visitMethodInvocation(MethodInvocationTree t,Void v) {
                            if(t.getMethodSelect() instanceof MemberSelectTree call && owner.equals(GRAPH)) {
                                var receiver=trees.getElement(new TreePath(new TreePath(getCurrentPath(),call),call.getExpression()));
                                if(receiver!=null && receiver.getSimpleName().contentEquals("classes")
                                        && receiver.getEnclosingElement() instanceof TypeElement type
                                        && type.getQualifiedName().contentEquals(PACKAGE+GRAPH)) {
                                    String verb=call.getIdentifier().toString();
                                    if(verb.equals("put")) {
                                        check(selected,"unregistered record replacement");classWrites.add(key+"="+compact(t));
                                    } else check(Set.of("values","entrySet","keySet","navigableKeySet","isEmpty","lastKey","containsKey",
                                            "size","get","firstKey","getOrDefault").contains(verb),"unknown class-map operation "+verb);
                                }
                                if(call.getIdentifier().contentEquals("restrictLeader"))check(key.equals(GRAPH+"#restrictInterfaceCertified/1"),"alternate interface mutator");
                            }
                            handle(t);return super.visitMethodInvocation(t,v);
                        }
                        @Override public Void visitNewClass(NewClassTree t,Void v) {handle(t);return super.visitNewClass(t,v);}
                        @Override public Void visitMemberReference(MemberReferenceTree t,Void v) {handle(t);return super.visitMemberReference(t,v);}
                    }.scan(new TreePath(getCurrentPath(),method.getBody()),null);
                    return null;
                }
            }.scan(u,null);
        }
        check(inspectedRoots.equals(roots.keySet()),"missing graph field initializer");
        var expected=new TreeSet<String>();METHODS.forEach((k,v)->v.forEach(s->expected.add(k+"#"+s)));
        expected.addAll(recordWriters);
        check(expected.equals(m.keySet()),"incomplete target inventory: "+expected.stream().filter(k->!m.containsKey(k)).toList());
        Collections.sort(writes);
        var publish=writes.stream().filter(k->k.endsWith("=GraphStatus.QUIESCENT")).toList();
        check(publish.equals(List.of(GRAPH+"#rebuild/1=GraphStatus.QUIESCENT",GRAPH+"#sealEmptyShapeFixtureForPhaseE/0=GraphStatus.QUIESCENT")),"unknown successful status writer "+publish);
        var ops=lower(m);var hash=MessageDigest.getInstance("SHA-256");
        for(var row:data.entrySet()){add(hash,row.getKey());row.getValue().forEach(s->add(hash,s));}
        writes.forEach(s->add(hash,s));Collections.sort(classWrites);classWrites.forEach(s->add(hash,s));
        return new Result(ops,HexFormat.of().formatHex(hash.digest()),m.size(),List.copyOf(writes),List.copyOf(classWrites));
    }

    public static String verify(Path repo,Path good,Path omitted) throws Exception {
        var live=compile(repo,false);var prior=compile(repo,true);
        check(live.digest.equals(PIN),"unregistered source/bindings "+live.digest+" methods "+live.methods+" statusWrites "+live.statusWrites.size()+" classWrites "+live.classWrites);
        check(!live.digest.equals(prior.digest) && !live.program.equals(prior.program),"omitted traversal must alter both semantic program and compiler binding");
        Files.write(good,live.program);Files.write(omitted,prior.program);
        return live.methods+" methods, "+live.statusWrites.size()+" status assignments, "+live.classWrites.size()+" class-map writes, "+live.digest;
    }
}
