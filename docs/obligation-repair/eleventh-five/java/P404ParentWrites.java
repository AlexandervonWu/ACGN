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

/** Enumerate every use of the private assignment map and its mutation paths via attributed javac trees. */
public final class P404ParentWrites {
    private static final String PACKAGE = "is.fivefivefive.CanDis.theory.";
    private static final String PIN = "b36c208fc0d2849b91835ccf4b745e13e27e8056af0a81dc7f182bfb45b8af6a";
    private static final Map<String, Set<String>> BODY = Map.ofEntries(
        Map.entry("TypedRenamedUnionFind",Set.of("*")),
        Map.entry("TypedSlottedPortEGraph",Set.of("<init>","structuralFixture","certifiedFixture",
            "requireStructuralFixture","requiresCertificates","unionCertified","unionCertifiedInternal",
            "linkLeadersForPhaseD","collisionParentEdgeOriented","restrictInterfaceCertified","checkInvariants")),
        Map.entry("ParentAssignment",Set.of("<init>","root","direct","compressed","isRoot")),
        Map.entry("ParentEdgeCertificate",Set.of("<init>","build","verifyLocal")),
        Map.entry("ParentStep",Set.of("<init>","certified","certificate")),
        Map.entry("ParentPath",Set.of("<init>","identity","direct","andThen","validateAndCompose","composedCertificate","hasCertificates")),
        Map.entry("TypedFindResult",Set.of("<init>","parentCertificate")),
        Map.entry("TypedInvocation",Set.of("<init>","act","identity","equals")),
        Map.entry("TypedEmbedding",Set.of("<init>","isInjective","isTypePreserving","andThen","inclusion","identity","equals")),
        Map.entry("TypedRenaming",Set.of("<init>","identity")),
        Map.entry("TypedCertificateEndpoint",Set.of("invocation","eclassWitness","restrictedWitness","act","equals")),
        Map.entry("TypedEClassInterface",Set.of("equals")),
        Map.entry("TheoryKeys",Set.of("type","slot","context","embedding","eclass","invocation")),
        Map.entry("StructuralKey",Set.of("<init>","of","branch","equals")),
        Map.entry("TypedSlot",Set.of("equals","compareTo")), Map.entry("TypedSlotContext",Set.of("equals","of")),
        Map.entry("CertificateSort",Set.of("equals","term")),
        Map.entry("InterfaceRestrictionCertificate",Set.of("build","verifyLocal")),
        Map.entry("CertificateVerifier",Set.of("verifyParentEdge","verifyInterfaceRestriction","verify","requirePermittedUnionDerivation")),
        Map.entry("EqualityCertificates",Set.of("rename","transitive","symmetric","orient")),
        Map.entry("DerivedEqualityCertificate",Set.of("rename","transitive","symmetric","verifyLocal")));
    private static final Set<String> GRAPH_CALLERS = Set.of("register","linkRoots","restrictLeader",
            "findWithProvenance","findWithoutCompression");
    private static void require(boolean ok,String reason) {
        if (!ok) throw new IllegalArgumentException(reason);
    }
    private static String text(Tree node) { return node.toString().replaceAll("\\s+", ""); }
    private static String name(Element e) {
        require(e!=null,"unresolved compiler target");
        return e.getEnclosingElement()+"#"+e.getSimpleName()+":"+e.asType();
    }
    private static void hash(MessageDigest d,String item) {
        byte[] bytes=item.getBytes(StandardCharsets.UTF_8);
        d.update(ByteBuffer.allocate(4).putInt(bytes.length).array()); d.update(bytes);
    }
    private static void ordered(MethodTree method, String... parts) {
        String body=text(method.getBody());
        int pos=0;
        for(String part:parts) {
            int found=body.indexOf(part,pos);
            require(found>=0,"missing or reordered '"+part+"' in "+method.getName());
            pos=found+part.length();
        }
    }
    private static final class Scan extends TreePathScanner<Void,Void> {
        final Trees trees;
        final Map<String,List<String>> bindings=new TreeMap<>();
        final Map<String,MethodTree> unique=new HashMap<>();
        final List<String> accesses=new ArrayList<>(),routes=new ArrayList<>(),callers=new ArrayList<>(),graphUses=new ArrayList<>();
        int publicGraphConstructors;
        ExecutableElement method; List<String> items;
        Scan(Trees trees){this.trees=trees;}
        @Override public Void visitMethod(MethodTree m,Void v) {
            var enclosing=method; var previous=items;
            method=(ExecutableElement)trees.getElement(getCurrentPath()); items=null;
            String owner=method.getEnclosingElement().getSimpleName().toString();
            String id=method.getSimpleName().toString();
            if(BODY.getOrDefault(owner,Set.of()).contains(id)||BODY.getOrDefault(owner,Set.of()).contains("*")) {
                items=new ArrayList<>(); require(bindings.put(name(method),items)==null,"ambiguous resolved method");
                items.add(method.getModifiers().toString());items.add(m.getBody().toString());
                if(owner.equals("TypedSlottedPortEGraph") && id.equals("<init>") && method.getModifiers().contains(Modifier.PUBLIC)) {
                    publicGraphConstructors++;
                    require(text(m.getBody()).startsWith("{this(GraphCertificateMode.REQUIRED,"),"public graph certificate mode");
                }
                if(owner.equals("TypedSlottedPortEGraph") && (id.equals("structuralFixture")||id.equals("linkLeadersForPhaseD")))
                    require(!method.getModifiers().contains(Modifier.PUBLIC) && !method.getModifiers().contains(Modifier.PROTECTED),
                        "structural setup visibility");
                unique.put(owner+"."+id,m);
            }
            super.visitMethod(m,v);method=enclosing;items=previous;return null;
        }
        private void ref(Element e){if(items!=null)items.add(name(e));}
        @Override public Void visitNewClass(NewClassTree t,Void v) {ref(trees.getElement(getCurrentPath()));return super.visitNewClass(t,v);}
        @Override public Void visitVariable(VariableTree decl,Void v) {
            var field=trees.getElement(getCurrentPath());
            if(field!=null && field.getKind().isField() && (isMapField(field) || (field.getSimpleName().contentEquals("unionFind") &&
                    field.getEnclosingElement().toString().equals(PACKAGE+"TypedSlottedPortEGraph"))))
                require(field.getModifiers().containsAll(Set.of(Modifier.PRIVATE,Modifier.FINAL)),"mutable or exposed ownership field");
            return super.visitVariable(decl,v);
        }
        @Override public Void visitMemberReference(MemberReferenceTree t,Void v) {ref(trees.getElement(getCurrentPath()));return super.visitMemberReference(t,v);}
        @Override public Void visitMemberSelect(MemberSelectTree t,Void v) {
            var e=trees.getElement(getCurrentPath());if(e!=null&&e.getKind().isField())ref(e);
            if(isMapField(e))mapUse();graphUse(e);return super.visitMemberSelect(t,v);
        }
        @Override public Void visitIdentifier(IdentifierTree t,Void v) {
            var e=trees.getElement(getCurrentPath());if(isMapField(e))mapUse();graphUse(e);
            return super.visitIdentifier(t,v);
        }
        private static boolean isMapField(Element e) {
            return e!=null && e.getKind().isField() && e.getSimpleName().contentEquals("assignments")
                && e.getEnclosingElement().toString().equals(PACKAGE+"TypedRenamedUnionFind");
        }
        private void graphUse(Element e) {
            if(e==null || !e.getKind().isField() || !e.getSimpleName().contentEquals("unionFind")
                   || !e.getEnclosingElement().toString().equals(PACKAGE+"TypedSlottedPortEGraph"))return;
            var parent=getCurrentPath().getParentPath();
            require(method!=null && parent.getLeaf() instanceof MemberSelectTree &&
                    parent.getParentPath().getLeaf() instanceof MethodInvocationTree,
                    "graph-owned union-find escapes method receiver boundary");
            graphUses.add(name(method)+"="+text(parent.getParentPath().getLeaf()));
        }
        private void mapUse() {
            require(method!=null,"assignment map escape outside a method");
            accesses.add(name(method)+"="+text(getCurrentPath().getParentPath().getLeaf()));
        }
        @Override public Void visitMethodInvocation(MethodInvocationTree call,Void v) {
            var target=trees.getElement(getCurrentPath());ref(target);
            if(method!=null && call.getMethodSelect() instanceof MemberSelectTree select) {
                var path=new TreePath(new TreePath(getCurrentPath(),select),select.getExpression());
                var receiver=trees.getElement(path);
                String owner=method.getEnclosingElement().getSimpleName().toString();
                String field=receiver==null?"":receiver.getSimpleName().toString();
                String methodName=method.getSimpleName().toString(), op=target.getSimpleName().toString();
                if (owner.equals("TypedRenamedUnionFind") && (isMapField(receiver)
                        || (methodName.equals("restrictLeader")&&field.equals("replacements")))
                        && (op.equals("put")||op.equals("putAll"))) {
                    require(target.getEnclosingElement().toString().equals("java.util.Map"),"unregistered store");
                    routes.add(methodName+"\t"+text(call));
                }
                if (target.getEnclosingElement().toString().equals(PACKAGE+"TypedRenamedUnionFind")
                    && GRAPH_CALLERS.contains(op) && owner.equals("TypedSlottedPortEGraph"))
                    callers.add(methodName+"\t"+text(call));
            }
            return super.visitMethodInvocation(call,v);
        }
    }
    static List<String> verify(Path repo) throws Exception {
        var compiler=ToolProvider.getSystemJavaCompiler();var errors=new DiagnosticCollector<JavaFileObject>();
        var classes=new TreeSet<>(BODY.keySet());classes.remove("DerivedEqualityCertificate");
        var sources=classes.stream().map(c->repo.resolve("src/is/fivefivefive/CanDis/theory/"+c+".java")).toList();
        try(var fm=compiler.getStandardFileManager(errors,Locale.ROOT,StandardCharsets.UTF_8)) {
            var task=(JavacTask)compiler.getTask(null,fm,errors,List.of("--release","17","-proc:none",
                "-sourcepath","","-classpath",System.getProperty("java.class.path")),null,fm.getJavaFileObjectsFromPaths(sources));
            var units=new ArrayList<CompilationUnitTree>();task.parse().forEach(units::add);task.analyze();
            for(var d:errors.getDiagnostics())require(d.getKind()!=Diagnostic.Kind.ERROR,d.toString());
            var scan=new Scan(Trees.instance(task));units.forEach(unit->scan.scan(unit,null));
            var m=scan.unique;
            ordered(m.get("TypedRenamedUnionFind.pathToRoot"),"current.provenancePath().andThen(tail)","if(compress)","ParentAssignment.compressed(full)");
            ordered(m.get("TypedRenamedUnionFind.restrictLeader"),"verifyInterfaceRestriction(restriction)",
                "findWithoutCompression(","ParentAssignment.root(replacement)","restriction.inclusion().andThen(oldLeaderInChild)",
                "result.parentCertificate()","rename(restriction.factorization(),oldLeaderInChild)","transitive(path,factorization)",
                "newParentEdgeCertificate(child,newTypedInvocation(replacement,newLeaderInChild),derivation)",
                "ParentStep.certified(edge)","assignments.putAll(replacements)");
            ordered(m.get("TypedSlottedPortEGraph.unionCertifiedInternal"),"verifyParentEdge(checked)",
                "ParentStep.certified(checked)","unionFind.linkRoots(step)");
            ordered(m.get("TypedSlottedPortEGraph.linkLeadersForPhaseD"),"requireStructuralFixture(","unionFind.linkRoots(step)");
            ordered(m.get("TypedSlottedPortEGraph.requireStructuralFixture"),"certificateMode!=GraphCertificateMode.STRUCTURAL_FIXTURE","thrownewIllegalStateException");
            ordered(m.get("ParentEdgeCertificate.build"),"newParentStep(child,parentInvocation)","eclassWitness(child)",
                "invocation(parentInvocation)","CertificateVerifier.verify(","requirePermittedUnionDerivation(endpointDerivation)",
                "EqualityCertificates.orient(endpointDerivation,left,right)");
            ordered(m.get("EqualityCertificates.orient"),"leftEndpoint().equals(left)","rightEndpoint().equals(right)","returncertificate",
                "leftEndpoint().equals(right)","rightEndpoint().equals(left)","returnsymmetric(certificate)","thrownewIllegalArgumentException");
            ordered(m.get("ParentPath.composedCertificate"),"if(steps.isEmpty())","EqualityCertificates.reflexive(",
                "if(!hasCertificates())","steps.get(0).certificate()","rename(step.certificate(),prefix)",
                "transitive(result,transported)","step.embedding().andThen(prefix)","newTypedInvocation(end,compositeEmbedding)",
                "result.leftEndpoint().equals(","result.rightEndpoint().equals(","CertificateVerifier.verify(result)");
            ordered(m.get("ParentPath.validateAndCompose"),"steps.get(0).embedding()","step.embedding().andThen(composite)");
            ordered(m.get("TypedFindResult.parentCertificate"),"parentPath.composedCertificate()","rename(pathCertificate,normalizedInvocation.embedding())",
                "transitive(normalizationCertificate,transported)","result.leftEndpoint().equals(","invocation(originalInvocation)",
                "result.rightEndpoint().equals(","invocation(leaderInvocation)");
            require(m.containsKey("DerivedEqualityCertificate.transitive")&&m.containsKey("TypedEmbedding.isInjective"),
                "missing constructors for typed action or proof");
            Collections.sort(scan.routes);Collections.sort(scan.callers);Collections.sort(scan.accesses);Collections.sort(scan.graphUses);
            require(scan.publicGraphConstructors==3,"unexpected public graph construction surface");
            var md=MessageDigest.getInstance("SHA-256");
            scan.bindings.forEach((k,v)->{hash(md,k);v.forEach(item->hash(md,item));});
            for(var seq:List.of(scan.accesses,scan.routes,scan.callers,scan.graphUses))seq.forEach(x->hash(md,x));
            String digest=HexFormat.of().formatHex(md.digest());System.out.println("P404 compiler methods="+scan.bindings.size()
                +" privateReceivers="+scan.graphUses.size()+" mapUses="+scan.accesses.size()+" writes="+scan.routes.size()+" graphRoutes="+scan.callers.size()+" sha256="+digest);
            require(PIN.equals(digest),"unregistered P4-04 compiler binding "+digest);
            return List.copyOf(scan.routes);
        }
    }
}
