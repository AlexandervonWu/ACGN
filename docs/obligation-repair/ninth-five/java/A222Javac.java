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

/** Attribute the selected production methods under the same producer class path as the witness. */
final class A222Javac {
    private static final String THEORY = "is.fivefivefive.CanDis.theory.";
    private static final String ALLOY = "is.fivefivefive.ACGN.alloy.";
    private static final Map<String,List<String>> SCOPE = Map.of(
        THEORY+"DependentTypeDag", List.of("intersection/1","intersectPair/2","moreSpecific/3",
            "requireCompatibleAuthority/2","requireCompatibleAuthority/1","fromExactAlloyType/1","empty/1","<init>/2"),
        THEORY+"DependentBoundaryCorrespondence", List.of("derive/2","firstCommonAncestor/2","isAlloySignature/1",
            "overlaps/0","copyPath/4","validateRule/0","<init>/7"),
        THEORY+"DependentColumnEvidence", List.of("fromExactAlloyType/3","<init>/3","ancestorIndex/1",
            "sharesParserModuleAuthorityWith/1","isAdmittedAtomicColumn/1","alloyColumn/1"),
        THEORY+"DependentChainTheory", List.of("requireConsistentHierarchy/1"),
        THEORY+"AlloyTypeBridge", List.of("dependentTypeDag/1","alloyColumn/1","normalizeAlloyIdentity/1"),
        THEORY+"TheoryAlloyAdapter.Builder", List.of("dependentTypeDagForSource/2"),
        ALLOY+"ExactAlloyType", List.of("fromParser/2","from/3","ancestryOf/1","parserSignatures/1",
            "hasParserAuthenticatedParents/2","isTrustedBuiltinParentEdge/2","normalizeColumn/1",
            "sharesParserModuleAuthorityWith/1","parserCertifiedRelationIntersection/1","intersectShapes/2","intersectShape/2"));
    private static final String PIN = "5b2051216c1dbc4774eca5f013538389cd6e2e98ae152968cf6108863352cc63";

    private static void add(MessageDigest hash, String value) {
        byte[] bytes = value.getBytes(StandardCharsets.UTF_8);
        hash.update(ByteBuffer.allocate(4).putInt(bytes.length).array());
        hash.update(bytes);
    }

    private static String symbol(Element element) {
        if (element == null) throw new AssertionError("Missing resolved compiler element");
        return element.getEnclosingElement()+"#"+element.getSimpleName()+":"+element.asType();
    }

    static List<String> inspect(Path checkout) throws Exception {
        var compiler = ToolProvider.getSystemJavaCompiler();
        var errors = new DiagnosticCollector<JavaFileObject>();
        var methods = new TreeMap<String,List<String>>();
        var program = new ArrayList<String>();
        var controls = new TreeMap<String,List<String>>();
        try (var files = compiler.getStandardFileManager(errors, Locale.ROOT, StandardCharsets.UTF_8)) {
            var paths = SCOPE.keySet().stream().map(s -> s.replace(".Builder","")).distinct().sorted()
                    .map(s -> checkout.resolve("src/"+s.replace('.','/')+".java")).toList();
            var task = (JavacTask) compiler.getTask(null, files, errors,
                    List.of("--release","17","-proc:none","-sourcepath","","-classpath",System.getProperty("java.class.path")),
                    null, files.getJavaFileObjectsFromPaths(paths));
            var units = new ArrayList<CompilationUnitTree>();
            task.parse().forEach(units::add);
            task.analyze();
            for (var error : errors.getDiagnostics()) {
                if (error.getKind() == Diagnostic.Kind.ERROR) throw new IllegalStateException(error.toString());
            }
            Trees trees = Trees.instance(task);
            for (var unit : units) new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree tree, Void unused) {
                    var method = (ExecutableElement) trees.getElement(getCurrentPath());
                    String owner = ((TypeElement)method.getEnclosingElement()).getQualifiedName().toString();
                    String name = method.getSimpleName()+"/"+method.getParameters().size();
                    if (!SCOPE.getOrDefault(owner,List.of()).contains(name)) return super.visitMethod(tree,unused);
                    var observations = new ArrayList<String>(List.of(symbol(method),tree.getBody().toString()));
                    if (methods.put(owner+"#"+name, observations) != null) throw new AssertionError("Ambiguous overload "+name);
                    if (name.equals("derive/2")) controls.put("derive",A222Control.derive(tree));
                    if (name.equals("intersectPair/2")) controls.put("binary",A222Control.binary(tree));
                    if (name.equals("intersection/1")) controls.put("fold",A222Control.fold(tree));
                    var root = new TreePath(getCurrentPath(),tree.getBody());
                    new TreePathScanner<Void,Void>() {
                        private void reference(String kind) {
                            observations.add(kind+" "+symbol(trees.getElement(getCurrentPath())));
                        }
                        @Override public Void visitMethodInvocation(MethodInvocationTree n,Void u) {
                            reference("call"); return super.visitMethodInvocation(n,u);
                        }
                        @Override public Void visitNewClass(NewClassTree n,Void u) {
                            reference("new"); return super.visitNewClass(n,u);
                        }
                        @Override public Void visitMemberReference(MemberReferenceTree n,Void u) {
                            reference("method reference"); return super.visitMemberReference(n,u);
                        }
                        @Override public Void visitMemberSelect(MemberSelectTree n,Void u) {
                            Element el=trees.getElement(getCurrentPath());
                            if(el!=null && el.getKind().isField()) reference("field");
                            return super.visitMemberSelect(n,u);
                        }
                        @Override public Void visitReturn(ReturnTree ret,Void u) {
                            if (name.equals("derive/2") && ret.getExpression() instanceof NewClassTree n) {
                                if (n.getArguments().size()!=7) throw new AssertionError("Malformed returned boundary");
                                var args = n.getArguments();
                                program.add(String.join("|",args.stream().map(Object::toString).toList()));
                            }
                            return super.visitReturn(ret,u);
                        }
                    }.scan(root,null);
                    return null;
                }
            }.scan(unit,null);
        }
        int required=SCOPE.values().stream().mapToInt(List::size).sum();
        if(methods.size()!=required || program.size()!=4) throw new AssertionError("Method inventory "+methods.keySet());
        var hash=MessageDigest.getInstance("SHA-256");
        for(var entry:methods.entrySet()) {
            add(hash,entry.getKey());
            for(String item:entry.getValue()) add(hash,item);
        }
        String actual=HexFormat.of().formatHex(hash.digest());
        if(!actual.equals(PIN)) throw new AssertionError("Unregistered resolved source "+actual);
        System.out.println("A222 compiler methods="+required+" digest="+actual);
        for(var entry:controls.entrySet()) for(String op:entry.getValue()) program.add("control:"+entry.getKey()+"|"+op);
        return List.copyOf(program);
    }
}

