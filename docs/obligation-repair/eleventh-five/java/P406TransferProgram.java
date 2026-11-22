package is.fivefivefive.CanDis.theory;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import javax.lang.model.element.*;
import javax.tools.*;

/** Lower the actual certified union body to its finite record-transfer operations. */
public final class P406TransferProgram {
    private static final String THEORY = "is.fivefivefive.CanDis.theory.";
    private static final String GRAPH = "TypedSlottedPortEGraph";
    private static final String PIN = "d78c01b6b6ddb992fcf0fd141ad5757d74ae097958b1a20cc686a8df1accd27b";
    private static final Map<String,List<String>> SELECT = Map.ofEntries(
        Map.entry(GRAPH, List.of("unionCertifiedInternal","unionCertified","transferShapeToParent","shapeRecord",
            "parentLiteralRelabeling","requireShapeCertificate","requireRecord","checkInvariants","appendTrace",
            "insertNodeWithConstruction","rebuildRecord","resolveShapeCollisionsDetailed","resolveAllShapeCollisionsDetailed",
            "linkLeadersForPhaseD","unindexRecord","indexRecord")),
        Map.entry("TypedEClassRecord",List.of("validateShape","withStoredShape","withoutStoredShapes","shapeWitnesses")),
        Map.entry("EffectiveShapeCollisionCertificate",List.of("orientShapeEquation")),
        Map.entry("ShapeWitness",List.of("<init>")),
        Map.entry("EqualityCertificates",List.of("orient","transitive","rename")),
        Map.entry("DerivedEqualityCertificate",List.of("transitive","rename")),
        Map.entry("ShapeRecord",List.of("<init>")), Map.entry("ShapeRehome",List.of("<init>")),
        Map.entry("Union",List.of("<init>","requireCanonicalRehomeOrder","requireCanonicalRetirementOrder")),
        Map.entry("RetiredShapeRecordCertificate",List.of("<init>","ownerUnion","verify","verifyOwnerUnion")),
        Map.entry("CertificateTraceSnapshot",List.of("verifyConservationTo","applyUnionState","putFresh","removeExact",
            "requireRetirementTarget","applyUnion","verifyUnionTopology")),
        Map.entry("TypedRenamedUnionFind",List.of("linkRoots")),
        Map.entry("CheckpointVerifier",List.of("verifyUnion","requireExactUnionTransfer","parseRetirements")),
        Map.entry("CertificateBundleWriter",List.of("requireSupportedSnapshot")));
    private static final List<String> FILES = List.of(GRAPH,"TypedEClassRecord","EffectiveShapeCollisionCertificate",
        "ShapeWitness","EqualityCertificates","CertificateTracePayload","RetiredShapeRecordCertificate",
        "CertificateTraceSnapshot","TypedRenamedUnionFind","CertificateBundleWriter");
    private P406TransferProgram() {}
    private static void require(boolean ok, String message) {
        if (!ok) throw new IllegalStateException("P406 source correspondence: "+message);
    }
    private static String compact(Tree tree) { return tree.toString().replaceAll("\\s+",""); }
    private static String signature(Element e) {
        if (e instanceof ExecutableElement fn && fn.getEnclosingElement() instanceof TypeElement owner)
            return owner.getQualifiedName()+"#"+fn.getSimpleName()+":"+fn.asType();
        throw new IllegalArgumentException("unresolved compiler binding "+e);
    }
    private static void field(MessageDigest h,String value) {
        byte[] raw=value.getBytes(StandardCharsets.UTF_8);
        h.update(ByteBuffer.allocate(4).putInt(raw.length).array()); h.update(raw);
    }
    private static void ordered(String body,String... tokens) {
        int at=0;
        for(String token : tokens) {
            int next=body.indexOf(token,at);
            require(next>=0,"expected ordered operand "+token); at=next+token.length();
        }
    }
    private static void addStatement(List<String> program, Map<String,String> meanings, StatementTree stmt) {
        String key=compact(stmt);
        if (stmt instanceof VariableTree && !key.endsWith(";")) key += ";";
        String meaning=meanings.get(key);
        if(meaning!=null) program.add(meaning);
    }
    private static List<String> lower(MethodTree union, MethodTree transfer) {
        var program=new ArrayList<String>();
        var top=union.getBody().getStatements();
        for(var statement:top) {
            String source=compact(statement);
            addStatement(program,Map.of(
                "List<CanonicalShape>childShapes=newArrayList<>(child.shapeWitnesses().keySet());","snapshot-child-keys",
                "classes.put(parent.id(),updatedParent);","install-parent-records",
                "classes.put(child.id(),child.withoutStoredShapes());","empty-child-records",
                "unionFind.linkRoots(step);","install-directed-edge",
                "returnnewUnionMutation(step,newCertificateTracePayload.Union(checked,rehomes,retirements));","emit-dispositions"),statement);
            if(!(statement instanceof EnhancedForLoopTree loop)) continue;
            require(compact(loop.getExpression()).equals("childShapes") && compact(loop.getVariable()).equals("CanonicalShapeshape"),
                    "iterate actual child key snapshot"); program.add("visit-each-shape");
            new TreeScanner<Void,Void>() {
                @Override public Void visitReturn(ReturnTree t,Void v){throw new IllegalStateException("P406 early return in record fold");}
                @Override public Void visitContinue(ContinueTree t,Void v){throw new IllegalStateException("P406 skipped live shape");}
                @Override public Void visitBreak(BreakTree t,Void v){throw new IllegalStateException("P406 truncated live shapes");}
                @Override public Void visitTry(TryTree t,Void v){throw new IllegalStateException("P406 swallowed transfer exception");}
            }.scan(loop.getStatement(),null);
            var body=((BlockTree)loop.getStatement()).getStatements();
            require(body.stream().filter(x->x instanceof IfTree).count()==1,"unique disposition branch");
            for(var item:body) {
                addStatement(program,Map.of(
                    "ParentRecordKeyoldKey=newParentRecordKey(child.id(),shape);","source-owner-shape",
                    "TypedEqualityCertificateoldEquation=requireShapeCertificate(oldKey);","load-certified-source",
                    "TransferredShapetransferred=transferShapeToParent(shape,child,oldWitness,oldEquation,parent,checked);","derive-candidate",
                    "shapeCertificates.remove(oldKey);","remove-old-equation",
                    "ParentRecordKeynewKey=newParentRecordKey(parent.id(),shape);","candidate-owner-shape",
                    "CertificateTracePayload.ShapeRecordreplacementRecord=shapeRecord(newKey,parent,transferred.witness,transferred.equation);","check-candidate"),item);
                if(item instanceof IfTree branch) {
                    require(compact(branch.getCondition()).equals("(!updatedParent.shapeWitnesses().containsKey(shape))"),
                        "branch on actual evolving target table");
                    program.add("lookup-parent-shape");
                    ordered(compact(branch.getThenStatement()),"updatedParent=updatedParent.withStoredShape(shape,transferred.witness);",
                            "shapeCertificates.put(newKey,transferred.equation);","rehomes.add(newCertificateTracePayload.ShapeRehome(oldRecord,shapeRecord(newKey,updatedParent,transferred.witness,requireShapeCertificate(newKey))))");
                    program.add("fresh-install-candidate-and-rehome");
                    ordered(compact(branch.getElseStatement()),"retainedRecord=shapeRecord(newKey,updatedParent,updatedParent.shapeWitnesses().get(shape),requireShapeCertificate(newKey));",
                            "retirement=RetiredShapeRecordCertificate.ownerUnion(oldRecord,replacementRecord,retainedRecord,checked);",
                            "prior=retiredShapeRecords.putIfAbsent(oldKey,retirement);",
                            "if(prior!=null&&!prior.structuralKey().equals(retirement.structuralKey()))", "retirements.add(retirement);");
                    program.add("duplicate-keep-add-retirement");
                }
            }
        }
        ordered(compact(transfer.getBody()),"orientShapeEquation(shape,child,witness,equation)",
                "parentLiteralRelabeling(witness.ambientSupport(),edge.embedding())","witness.instantiatingRenaming().andThen(relabeling)",
                "TypedEmbedding.inclusion(child.exposedSlots(),witness.ambientSupport())",
                "EqualityCertificates.transitive(oriented,EqualityCertificates.rename(edge,childInAmbient))",
                "EqualityCertificates.rename(parentInOldAmbient,relabeling)",
                "orientShapeEquation(shape,parent,transported,transportedEquation)","returnnewTransferredShape(transported,checkedEquation)");
        program.add("proof-orient-rename-edge-trans-rename-orient");
        return List.copyOf(program);
    }
    public static String extract(Path sourceRoot, Path programFile) throws Exception {
        var compiler=ToolProvider.getSystemJavaCompiler();
        var diagnostics=new DiagnosticCollector<JavaFileObject>();
        var paths=new ArrayList<Path>();
        for(var name:FILES) paths.add(sourceRoot.resolve("src/"+THEORY.replace('.','/')+name+".java"));
        paths.add(sourceRoot.resolve("certificate-verifier/src/org/acgn/cert/CheckpointVerifier.java"));
        var results=new TreeMap<String,List<String>>();var seen=new TreeSet<String>();
        var routes=new TreeSet<String>();var graphs=new HashMap<String,MethodTree>();
        try(var fm=compiler.getStandardFileManager(diagnostics,Locale.ROOT,StandardCharsets.UTF_8)) {
            String cp=System.getProperty("java.class.path")+java.io.File.pathSeparator
                    +sourceRoot.resolve("certificate-verifier/build/acgn-certificate-verifier.jar");
            var task=(JavacTask)compiler.getTask(null,fm,diagnostics,List.of("--release","17","-proc:none","-classpath",cp),
                    null,fm.getJavaFileObjectsFromPaths(paths));
            var units=new ArrayList<CompilationUnitTree>();task.parse().forEach(units::add);task.analyze();
            for(var d:diagnostics.getDiagnostics()) require(d.getKind()!=Diagnostic.Kind.ERROR,d.toString());
            var trees=Trees.instance(task);
            for(var u:units) new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree method,Void v) {
                    var def=(ExecutableElement)trees.getElement(getCurrentPath());
                    String owner=def.getEnclosingElement().getSimpleName().toString(),name=def.getSimpleName().toString();
                    boolean selected=SELECT.getOrDefault(owner,List.of()).contains(name);
                    boolean graph=owner.equals(GRAPH);
                    if (method.getBody()==null || (!selected && !graph)) return null;
                    var entries=new ArrayList<String>();
                    if(selected) {
                        seen.add(owner+"#"+name);
                        require(results.put(signature(def),entries)==null,"ambiguous symbol");
                        entries.add(method.getBody().toString());
                        if(graph)graphs.put(name,method);
                    }
                    new TreePathScanner<Void,Void>() {
                        private void visitCall(Tree tree) {
                            var bound=trees.getElement(getCurrentPath());
                            if(selected)entries.add(tree.getKind()+":"+signature(bound));
                            if(graph && bound instanceof ExecutableElement call && call.getEnclosingElement() instanceof TypeElement type) {
                                String target=type.getQualifiedName()+"#"+call.getSimpleName();
                                if(target.equals(THEORY+GRAPH+"#unionCertifiedInternal") || target.equals(THEORY+"TypedRenamedUnionFind#linkRoots"))
                                    routes.add(name+"->"+target.substring(THEORY.length()));
                            }
                        }
                        @Override public Void visitMethodInvocation(MethodInvocationTree t,Void x){visitCall(t);return super.visitMethodInvocation(t,x);}
                        @Override public Void visitNewClass(NewClassTree t,Void x){visitCall(t);return super.visitNewClass(t,x);}
                        @Override public Void visitMemberReference(MemberReferenceTree t,Void x){visitCall(t);return super.visitMemberReference(t,x);}
                    }.scan(new TreePath(getCurrentPath(),method.getBody()),null);
                    return null;
                }
            }.scan(u,null);
        }
        var wanted=new TreeSet<String>();SELECT.forEach((k,v)->v.forEach(n->wanted.add(k+"#"+n)));
        require(seen.equals(wanted),"selection differs: "+wanted.stream().filter(k->!seen.contains(k)).toList());
        require(routes.equals(Set.of("insertNodeWithConstruction->TypedSlottedPortEGraph#unionCertifiedInternal",
            "resolveShapeCollisionsDetailed->TypedSlottedPortEGraph#unionCertifiedInternal","unionCertified->TypedSlottedPortEGraph#unionCertifiedInternal",
            "unionCertifiedInternal->TypedRenamedUnionFind#linkRoots","linkLeadersForPhaseD->TypedRenamedUnionFind#linkRoots")),"parent route census "+routes);
        ordered(compact(graphs.get("linkLeadersForPhaseD").getBody()),"requireStructuralFixture(","unionFind.linkRoots(");
        var prog=lower(graphs.get("unionCertifiedInternal"),graphs.get("transferShapeToParent"));
        var h=MessageDigest.getInstance("SHA-256");results.forEach((k,v)->{field(h,k);v.forEach(row->field(h,row));});
        routes.forEach(row->field(h,row));String digest=HexFormat.of().formatHex(h.digest());
        require(digest.equals(PIN),"unregistered shape/binding inventory "+digest+" methods="+results.size()+" program="+prog);
        Files.write(programFile,prog);
        return results.size()+" methods, 5 bound call routes, "+prog.size()+" operations, sha256="+digest;
    }
}
