package is.fivefivefive.CanDis.theory;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.*;
import javax.lang.model.element.*;
import javax.tools.*;

/** Verifies the bodies and resolved call targets which supply A2-21 typed trace semantics. */
public final class A221CompilerContract {
    private static final String PIN = "46a7f0c8ad68d0f1a2cc3b943700d2f6dad34092e20de7ac55ac628b2014e019";
    private static final Map<String, List<String>> METHODS = Map.of(
            "DependentTypeDag", List.of("<init>/1","<init>/2","fromExactAlloyType/1","exactAlternative/2","union/1","empty/1",
                    "normalize/1","productType/1","preferAuthenticated/2","productSubtypeOrEqual/2","requireCompatibleAuthority/1"),
            "DependentColumnEvidence", List.of("<init>/3","exact/1","fromExactAlloyType/3","isAdmittedAtomicColumn/1","equals/1","ancestorIndex/1",
                    "hasParserModuleAuthority/0","sharesParserModuleAuthorityWith/1","sameOccurrenceEvidenceAs/1"),
            "DependentBoundaryCorrespondence", List.of("derive/2","isAlloySignature/1"),
            "DependentChainTheory", List.of("requireConsistentHierarchy/1"),
            "ExactAlloyType", List.of("fromParser/2","from/3","parserSignatures/1","hasParserAuthenticatedParents/2","ancestryOf/1",
                    "isTrustedBuiltinParentEdge/2","hasParserAuthenticatedAncestry/0","sharesParserModuleAuthorityWith/1"),
            "GraphType", List.of("equals/1","hashCode/0","compareTo/1","compareNullable/2"));

    private static String target(Element element) {
        if (element instanceof ExecutableElement method && method.getEnclosingElement() instanceof TypeElement type)
            return type.getQualifiedName() + "#" + method.getSimpleName() + ":" + method.asType();
        throw new IllegalArgumentException("unresolved A2-21 compiler binding");
    }

    private static void add(MessageDigest digest, String value) {
        byte[] bytes = value.getBytes(StandardCharsets.UTF_8);
        digest.update(ByteBuffer.allocate(4).putInt(bytes.length).array());
        digest.update(bytes);
    }

    private static void ordered(Map<String,String> bodies, String name, String... operations) {
        String body = Objects.requireNonNull(bodies.get(name),name).replaceAll("\\s+", "");
        int offset = 0;
        for (String op : operations) {
            int at = body.indexOf(op,offset);
            if (at < 0) throw new IllegalArgumentException("unrecognized A2-21 operation " + name + ": " + op);
            offset = at + op.length();
        }
    }

    public static String verify(Path root) throws Exception {
        var src = root.resolve("src/is/fivefivefive");
        var files = new ArrayList<Path>();
        for (var name : new TreeSet<>(METHODS.keySet())) {
            var directory = src.resolve(name.equals("ExactAlloyType") ? "ACGN/alloy" : "CanDis/theory");
            files.add(directory.resolve(name + ".java"));
        }
        var digest = MessageDigest.getInstance("SHA-256");
        var rows = new TreeMap<String,List<String>>();
        var bodies = new TreeMap<String,String>();
        var compiler = ToolProvider.getSystemJavaCompiler();
        var diagnostics = new DiagnosticCollector<JavaFileObject>();
        try (var manager = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            var task = (JavacTask) compiler.getTask(null, manager, diagnostics,
                    List.of("--release","17","-proc:none","-classpath",System.getProperty("java.class.path")),
                    null, manager.getJavaFileObjectsFromPaths(files));
            var units = new ArrayList<CompilationUnitTree>();
            task.parse().forEach(units::add);
            task.analyze();
            for (var diag : diagnostics.getDiagnostics())
                if (diag.getKind() == Diagnostic.Kind.ERROR) throw new IllegalArgumentException(diag.toString());
            var trees = Trees.instance(task);
            for (var unit : units) new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree method, Void unused) {
                    var element = (ExecutableElement) trees.getElement(getCurrentPath());
                    var owner = (TypeElement) element.getEnclosingElement();
                    var name = owner.getSimpleName().toString();
                    var sig = method.getName() + "/" + method.getParameters().size();
                    if (!METHODS.getOrDefault(name, List.of()).contains(sig)) return null;
                    String key = name + "#" + sig;
                    var data = new ArrayList<String>();
                    if (rows.putIfAbsent(key, data) != null) throw new IllegalArgumentException("ambiguous " + key);
                    bodies.put(key, method.getBody().toString());
                    data.add(target(element));
                    data.add(bodies.get(key));
                    new TreePathScanner<Void,Void>() {
                        private void collect(Tree tree) { data.add(tree.getKind() + ":" + target(trees.getElement(getCurrentPath()))); }
                        @Override public Void visitMethodInvocation(MethodInvocationTree tree, Void u) {
                            collect(tree); return super.visitMethodInvocation(tree,u);
                        }
                        @Override public Void visitNewClass(NewClassTree tree, Void u) { collect(tree); return super.visitNewClass(tree,u); }
                        @Override public Void visitMemberReference(MemberReferenceTree tree, Void u) { collect(tree); return super.visitMemberReference(tree,u); }
                    }.scan(new TreePath(getCurrentPath(),method.getBody()),null);
                    return null;
                }
            }.scan(unit,null);
        }
        var expected = new TreeSet<String>();
        METHODS.forEach((owner, members) -> members.forEach(member -> expected.add(owner + "#" + member)));
        if (!rows.keySet().equals(expected)) {
            expected.removeAll(rows.keySet());
            throw new IllegalArgumentException("missing A2-21 method bindings " + expected);
        }
        ordered(bodies,"DependentTypeDag#normalize/1","product.isEmpty()","arity=product.size()","product.size()!=arity",
                "requireCompatibleAuthority(copied)","DependentChainTheory.requireConsistentHierarchy(copied)",
                "newLinkedHashMap<>()","type=productType(product)","unique.get(type)","unique.put(type,product)","!previous.equals(product)",
                "unique.put(type,preferAuthenticated(previous,product))","newArrayList<>(unique.values())","candidateIndex==otherIndex",
                "productSubtypeOrEqual(candidate,candidates.get(otherIndex))","absorbed=true","if(!absorbed)","antichain.add(candidate)",
                "antichain.sort(Comparator.comparing(DependentTypeDag::productType))","returnCollections.unmodifiableList(frozen)");
        ordered(bodies,"DependentTypeDag#preferAuthenticated/2","index=0;index<left.size();index++",
                "!left.get(index).hasParserModuleAuthority()&&right.get(index).hasParserModuleAuthority()",
                "merged=newArrayList<>(left)","merged.set(index,right.get(index))","returnmerged==null?left:List.copyOf(merged)");
        ordered(bodies,"DependentTypeDag#productSubtypeOrEqual/2","specific.size()!=general.size()","strict=false","index<specific.size()",
                "left.exactColumn().equals(right.exactColumn())","continue;","DependentBoundaryCorrespondence.derive(left,right)",
                "UnsupportedCorrespondenceexception","returnfalse","proof.rule()!=DependentBoundaryCorrespondence.Rule.LEFT_SUBTYPE_OF_RIGHT","strict=true","returnstrict");
        ordered(bodies,"DependentBoundaryCorrespondence#derive/2","leftBoundary.equals(rightBoundary)","Rule.EXACT",
                "!left.sharesParserModuleAuthorityWith(right)","rightInLeft=left.ancestorIndex(rightBoundary)",
                "leftInRight=right.ancestorIndex(leftBoundary)","rightInLeft>0&&leftInRight>0","if(rightInLeft>0)","Rule.LEFT_SUBTYPE_OF_RIGHT");
        ordered(bodies,"ExactAlloyType#sharesParserModuleAuthorityWith/1","parserModuleAuthority!=null","parserModuleAuthority==other.parserModuleAuthority");
        ordered(bodies,"ExactAlloyType#hasParserAuthenticatedParents/2","!parserSignatures.contains(current)","current.parent!=null&&current.parent!=Sig.UNIV",
                "!parserSignatures.contains(current.parent)","!isTrustedBuiltinParentEdge(current,current.parent)","Pos.UNKNOWN.equals(declaration)","current=current.parent");
        for (var e : rows.entrySet()) { add(digest,e.getKey()); e.getValue().forEach(v -> add(digest,v)); }
        var observed = HexFormat.of().formatHex(digest.digest());
        if (!PIN.equals(observed)) throw new IllegalArgumentException("unregistered A2-21 source/binding digest " + observed);
        return rows.size() + " methods, " + observed;
    }
}
