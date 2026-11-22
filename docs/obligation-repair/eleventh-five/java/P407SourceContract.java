package is.fivefivefive.CanDis.theory;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import javax.lang.model.element.*;
import javax.tools.*;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;

public final class P407SourceContract {
    private static final String PIN = "c0542163f067687acd48cc27a3143bea7e1f0fd6647d6bf701b4f13679722e2f";
    private static final String G = "TypedSlottedPortEGraph";
    private static final String K = "ParentRecordKey";
    private static final String W = "Assembler";
    private static final String V = "CheckpointVerifier";
    private static final Map<String,Set<String>> METHODS = Map.of(
        G, Set.of("hashOwner","hashConsSnapshot","hashBucketsSnapshot","parentUsesSnapshot","addHashOwner",
                "removeHashOwner","indexRecord","unindexRecord","invocationIds","collectInvocationIds",
                "registerRecord","insertNodeWithConstruction","unionCertifiedInternal","rebuildRecord","removeStoredRecord",
                "installStoredRecord","admitFixedBatchRecordCertified","rebuild","firstCollisionWithOwners",
                "resolveShapeCollisionsDetailed","resolveAllShapeCollisionsDetailed","recordExists",
                "requireShapeCertificate","stateStructuralKey","traceSnapshot","rebuildHashConsExactly","requireHashBucketsExact","checkInvariants","markParentsDirty"),
        K,Set.of("<init>","compareTo","equals","hashCode","owner","shape","structuralKey"),
        "CertificateBundleWriter",Set.of("requireSupportedSlice"),
        W,Set.of("shapeId","shapeWire","snapshot","internManifest"),
        V,Set.of("parseHashOwners","parsePairSet","parseShapes","validateSnapshot","validateHashes",
                "exactHashOwners","validateParentUses","shapeId","termsKey","shapeForOwnerAndKey"));
    private static final List<String> FILES = List.of(
        "src/is/fivefivefive/CanDis/theory/TypedSlottedPortEGraph.java",
        "src/is/fivefivefive/CanDis/theory/ParentRecordKey.java",
        "src/is/fivefivefive/CanDis/theory/CertificateBundleWriter.java",
        "certificate-verifier/src/org/acgn/cert/CheckpointVerifier.java");

    static void require(boolean ok,String reason) {
        if(!ok) throw new IllegalArgumentException(reason);
    }
    private static String compact(Tree t) {return t.toString().replaceAll("\\s+","");}
    private static String target(Element e) {
        require(e instanceof ExecutableElement && e.getEnclosingElement() instanceof TypeElement,"unresolved method");
        TypeElement owner=(TypeElement)e.getEnclosingElement();
        return owner.getQualifiedName()+"#"+e.getSimpleName()+e.asType();
    }
    private static void frame(MessageDigest d,String text) {
        byte[] raw=text.getBytes(StandardCharsets.UTF_8);
        d.update(ByteBuffer.allocate(4).putInt(raw.length).array()); d.update(raw);
    }
    private static List<? extends ExpressionTree> args(MethodTree m,String bound) {
        var calls=new ArrayList<MethodInvocationTree>();
        new TreeScanner<Void,Void>() {
            @Override public Void visitMethodInvocation(MethodInvocationTree t,Void v) {
                if(compact(t.getMethodSelect()).equals(bound)) calls.add(t);
                return super.visitMethodInvocation(t,v);
            }
        }.scan(m.getBody(),null);
        require(calls.size()==1,m.getName()+" missing or ambiguous "+bound);
        return calls.get(0).getArguments();
    }
    private static String argument(MethodTree m,String bound) {return compact(args(m,bound).get(0));}

    private static String hashInsert(MethodTree m) {
        var call=(MethodInvocationTree)((ExpressionStatementTree)m.getBody().getStatements().get(0)).getExpression();
        var select=(MemberSelectTree)call.getMethodSelect();
        require(select.getIdentifier().contentEquals("add"),"hash insertion");
        var inner=(MethodInvocationTree)select.getExpression();
        require(compact(inner.getMethodSelect()).equals("hashCons.computeIfAbsent"),"hash bucket target");
        return "attach hash "+compact(inner.getArguments().get(0))+" "+compact(call.getArguments().get(0));
    }
    private static String useEdit(MethodTree m,boolean adding) {
        var loop=(EnhancedForLoopTree)m.getBody().getStatements().get(0);
        require(compact(loop.getExpression()).equals("invocationIds(key.shape().node())"),"referenced child frontier");
        String child=loop.getVariable().getName().toString();
        if(adding) {
            var stmt=(ExpressionStatementTree)((BlockTree)loop.getStatement()).getStatements().get(0);
            var call=(MethodInvocationTree)stmt.getExpression();
            var select=(MemberSelectTree)call.getMethodSelect();
            var inner=(MethodInvocationTree)select.getExpression();
            require(select.getIdentifier().contentEquals("add") && compact(inner.getMethodSelect()).equals("parentUses.computeIfAbsent")
                    && compact(inner.getArguments().get(0)).equals(child),"reverse insertion");
            return "attach use "+child+" "+compact(call.getArguments().get(0));
        }
        require(argument(m,"parentUses.get").equals(child) && argument(m,"parentUses.remove").equals(child)
                && compact(m.getBody()).contains("if(uses.isEmpty())"),"empty reverse bucket handling");
        return "retire use "+child+" "+argument(m,"uses.remove");
    }
    public static String verify(Path root,Path program) throws Exception {
        var compiler=ToolProvider.getSystemJavaCompiler(); var diagnostics=new DiagnosticCollector<JavaFileObject>();
        var bodies=new TreeMap<String,MethodTree>(); var traces=new TreeMap<String,List<String>>();
        var fields=new ArrayList<String>();
        try(var fm=compiler.getStandardFileManager(diagnostics,Locale.ROOT,StandardCharsets.UTF_8)) {
            var units=fm.getJavaFileObjectsFromPaths(FILES.stream().map(root::resolve).toList());
            var task=(JavacTask)compiler.getTask(null,fm,diagnostics,List.of("--release","17","-proc:none","-classpath",
                    System.getProperty("java.class.path")),null,units);
            var parsed=new ArrayList<CompilationUnitTree>();task.parse().forEach(parsed::add);task.analyze();
            for(var msg:diagnostics.getDiagnostics())require(msg.getKind()!=Diagnostic.Kind.ERROR,msg.toString());
            var trees=Trees.instance(task);
            for(var unit:parsed)new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree m,Void ignored) {
                    var el=(ExecutableElement)trees.getElement(getCurrentPath());
                    String owner=el.getEnclosingElement().getSimpleName().toString();
                    String method=m.getName().toString();
                    boolean selected=METHODS.getOrDefault(owner,Set.of()).contains(method);
                    if(m.getBody()==null)return null;
                    var trace=new ArrayList<String>();
                    String id=owner+"#"+method+"/"+m.getParameters().size();
                    if(selected) {
                        require(bodies.put(id,m)==null,"ambiguous selected method "+id);
                        trace.add(target(el));trace.add(m.getModifiers().toString());trace.add(m.getBody().toString());traces.put(id,trace);
                    }
                    new TreePathScanner<Void,Void>() {
                        private void recordBinding(Tree t) {
                            if(selected)trace.add(t.getKind()+" "+target(trees.getElement(getCurrentPath())));
                        }
                        @Override public Void visitMethodInvocation(MethodInvocationTree t,Void v) {
                            recordBinding(t);
                            if(t.getMethodSelect() instanceof MemberSelectTree member) {
                                var receiver=trees.getElement(new TreePath(new TreePath(getCurrentPath(),member),member.getExpression()));
                                if(receiver instanceof VariableElement field && field.getKind()==ElementKind.FIELD
                                        && field.getEnclosingElement().getSimpleName().contentEquals(G)
                                        && Set.of("hashCons","parentUses").contains(field.getSimpleName().toString())) {
                                    fields.add(id+" "+compact(t)+" "+target(trees.getElement(getCurrentPath())));
                                }
                            }
                            return super.visitMethodInvocation(t,v);
                        }
                        @Override public Void visitNewClass(NewClassTree t,Void v) {recordBinding(t);return super.visitNewClass(t,v);}
                        @Override public Void visitMemberReference(MemberReferenceTree t,Void v) {recordBinding(t);return super.visitMemberReference(t,v);}
                    }.scan(new TreePath(getCurrentPath(),m.getBody()),null);
                    return null;
                }
            }.scan(unit,null);
        }
        for(var group:METHODS.entrySet())for(var method:group.getValue())
            require(bodies.keySet().stream().anyMatch(k->k.startsWith(group.getKey()+"#"+method+"/")),"unseen method "+group.getKey()+"."+method);
        var add=bodies.get(G+"#addHashOwner/2");var del=bodies.get(G+"#removeHashOwner/2");
        require(compact(del.getBody()).contains("if(owners.isEmpty())") && argument(del,"hashCons.remove").equals("shape"),"empty hash bucket handling");
        var ops=List.of(hashInsert(add),useEdit(bodies.get(G+"#indexRecord/1"),true),
                "retire hash "+argument(del,"hashCons.get")+" "+argument(del,"owners.remove"),
                useEdit(bodies.get(G+"#unindexRecord/1"),false));
        var digest=MessageDigest.getInstance("SHA-256");
        for(var entry:traces.entrySet()) {frame(digest,entry.getKey());entry.getValue().forEach(s->frame(digest,s));}
        Collections.sort(fields);fields.forEach(s->frame(digest,s));
        String actual=HexFormat.of().formatHex(digest.digest());
        require(actual.equals(PIN),"P407 attributed source "+actual+" methods="+traces.size()+" field-accesses="+fields.size());
        Files.write(program,ops);
        return traces.size()+" methods, "+fields.size()+" field accesses, "+actual;
    }
}
