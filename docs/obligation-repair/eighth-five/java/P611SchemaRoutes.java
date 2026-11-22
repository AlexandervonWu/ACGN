package org.acgn.cert;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import javax.lang.model.element.*;
import javax.tools.*;

/** Checks the closed source-built admission routes with javac attribution and statement order. */
final class P611SchemaRoutes {
    private static final String PKG = "org.acgn.cert.";
    private static final Map<String,List<String>> ROUTES = Map.ofEntries(
        Map.entry("Bundle#<init>", List.of("Wire.Node#requireShape","String#equals","Wire.Node#scalar","FormatException#<init>")),
        Map.entry("Bundle#parse", List.of("Bundle#<init>")),
        Map.entry("Bundle#metadata", List.of()),
        Map.entry("Wire.Node#requireShape", List.of("String#equals","List#size","List#size","FormatException#<init>")),
        Map.entry("IndependentVerifier#open", List.of("Codec#decode","Bundle#parse","KernelModel#<init>")),
        Map.entry("IndependentVerifier#verify", List.of("IndependentVerifier#open","IndependentVerifier#verifyProfile","VerificationResult#verified")),
        Map.entry("IndependentVerifier#verifyPair", List.of("IndependentVerifier#open","IndependentVerifier#open",
                "IndependentVerifier#verifyProfile","IndependentVerifier#verifyProfile","VerificationResult#verified")),
        Map.entry("CallOccurrenceCommitment#inspect", List.of("Bundle#parse","Codec#decode","Bundle#semanticEvidence")),
        Map.entry("ManifestInspector#main", List.of("Codec#decode","Bundle#theoryDigest","Bundle#parse")),
        Map.entry("Main#main", List.of("Main#run")),
        Map.entry("Main#run", List.of("Main.Arguments#parse","CallOccurrenceCommitment#inspect",
                "IndependentVerifier#verifyPair","IndependentVerifier#verify")),
        Map.entry("RawCallSourceAuthority#commitment", List.of("Bundle#parse","Codec#decode","Bundle.Metadata#inputIdentifier","Bundle#metadata")),
        Map.entry("RawCallSourceAuthority#main", List.of("RawCallSourceAuthority#fromSource","RawCallSourceAuthority#commitment")),
        Map.entry("P613SourcePair#bind", List.of("RawCallSourceAuthority#fromSource","RawCallSourceAuthority#commitment")),
        Map.entry("P613SourcePair#verifyFull", List.of("P613SourcePair#bind","IndependentVerifier#verify")),
        Map.entry("P613SourcePair#verify", List.of("P613SourcePair#bind","P613SourcePair#bind","IndependentVerifier#verifyPair")),
        Map.entry("P613SourcePair#main", List.of("P613SourcePair#verify"))
    );

    private static void require(boolean ok, String detail) {
        if (!ok) throw new AssertionError("P6-11 source correspondence: " + detail);
    }

    private static String id(ExecutableElement executable) {
        String owner = ((TypeElement)executable.getEnclosingElement()).getQualifiedName().toString();
        if (owner.startsWith(PKG)) owner = owner.substring(PKG.length());
        else if (owner.startsWith("java.lang.") || owner.startsWith("java.util."))
            owner = executable.getEnclosingElement().getSimpleName().toString();
        return owner + "#" + executable.getSimpleName();
    }

    private static String compact(Tree tree) {
        return tree.toString().replaceAll("\\s+", "");
    }

    private static void prefix(BlockTree block, String... expected) {
        var statements = block.getStatements();
        require(statements.size() >= expected.length, "missing statement");
        for (int i=0; i<expected.length; i++) {
            String got = compact(statements.get(i));
            if (statements.get(i) instanceof VariableTree) got += ";";
            require(got.equals(expected[i]), "wanted " + expected[i] + ", got " + got);
        }
    }

    private static TryTree guardedTry(MethodTree method) {
        return method.getBody().getStatements().stream().filter(TryTree.class::isInstance)
                .map(TryTree.class::cast).findFirst().orElseThrow();
    }

    private static void checkFlow(String name, MethodTree method) {
        BlockTree body = method.getBody();
        switch (name) {
            case "Bundle#<init>" -> {
                prefix(body, "super();", "this.root=Objects.requireNonNull(root,\"root\");",
                        "root.requireShape(\"acgncert-bundle\",1,SECTION_TAGS.size());");
                var guard=(IfTree)body.getStatements().get(3);
                require(compact(guard.getCondition()).equals("(!SCHEMA_VERSION.equals(root.scalar(0)))")
                        && guard.getElseStatement()==null, "version predicate or direction");
                var branch=(BlockTree)guard.getThenStatement();
                require(branch.getStatements().size()==1 && branch.getStatements().get(0) instanceof ThrowTree
                        && compact(branch).startsWith("{thrownewFormatException(FailureCode.UNSUPPORTED_FORMAT_VERSION,"),
                        "version mismatch must throw before metadata");
            }
            case "Wire.Node#requireShape" -> {
                var branch = (IfTree)body.getStatements().get(0);
                require(compact(branch.getCondition()).equals("(!tag.equals(expectedTag)||scalars.size()!=scalarCount||children.size()!=childCount)")
                        && compact(branch.getThenStatement()).startsWith("{thrownewFormatException(FailureCode.INVALID_RECORD_SHAPE,")
                        && branch.getElseStatement()==null && body.getStatements().size()==2
                        && compact(body.getStatements().get(1)).equals("returnthis;"), "exact root shape gate");
            }
            case "Bundle#parse" -> {
                require(body.getStatements().size()==1, "alternative Bundle constructor");
                prefix(body,"returnnewBundle(root);");
            }
            case "IndependentVerifier#open" -> prefix(body, "Wire.Noderoot=Codec.decode(encoded,policy.limits());",
                    "Bundlebundle=Bundle.parse(root);");
            case "IndependentVerifier#verify", "IndependentVerifier#verifyPair" -> {
                var guarded = guardedTry(method).getBlock();
                if (name.endsWith("#verify")) prefix(guarded,"Sessionsession=open(encoded,policy);","verifyProfile(session,profile);");
                else prefix(guarded,"Sessionleft=open(leftEncoded,policy);","Sessionright=open(rightEncoded,policy);");
                var last = guarded.getStatements().get(guarded.getStatements().size()-1);
                require(last instanceof ReturnTree && compact(last).startsWith("returnVerificationResult.verified("),
                        "verified exit outside guarded path");
            }
            case "CallOccurrenceCommitment#inspect" -> {
                require(compact(body).contains("Bundlebundle=Bundle.parse(Codec.decode(encoded,limits));"),
                        "inspection must parse its own supplied bytes");
            }
            case "RawCallSourceAuthority#commitment" -> prefix(body,"Limitslimits=Limits.defaults();",
                    "Bundlebundle=Bundle.parse(Codec.decode(encoded,limits));");
            default -> { }
        }
    }

    private static String digest(String s) {
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(s.getBytes(StandardCharsets.UTF_8))); }
        catch (java.security.NoSuchAlgorithmException e) { throw new AssertionError(e); }
    }

    static List<String> audit(Path root) throws Exception {
        var compiler = ToolProvider.getSystemJavaCompiler();
        var diagnostics = new DiagnosticCollector<JavaFileObject>();
        List<Path> sources;
        try (Stream<Path> stream = Files.walk(root.resolve("certificate-verifier/src"))) {
            sources = new ArrayList<>(stream.filter(p -> p.toString().endsWith(".java")).sorted().toList());
        }
        sources.add(root.resolve("src/is/fivefivefive/CanDis/theory/StructuralKey.java"));
        sources.add(root.resolve("docs/obligation-repair/sixth-five/java/RawCallSourceAuthority.java"));
        sources.add(root.resolve("docs/obligation-repair/seventh-five/java/P613SourcePair.java"));
        String jars;
        try (var paths=Files.list(root.resolve("lib"))) {
            jars=paths.filter(p->p.toString().endsWith(".jar")).sorted().map(Path::toString).collect(Collectors.joining(File.pathSeparator));
        }
        try (var fm=compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            var task=(JavacTask)compiler.getTask(null,fm,diagnostics,List.of("--release","17","-proc:none",
                    "-implicit:none","-sourcepath","","-classpath",jars),null,fm.getJavaFileObjectsFromPaths(sources));
            List<CompilationUnitTree> units=new ArrayList<>();
            task.parse().forEach(units::add); task.analyze();
            for(var d:diagnostics.getDiagnostics()) require(d.getKind()!=Diagnostic.Kind.ERROR,d.toString());
            Trees trees=Trees.instance(task);
            var bundle=task.getElements().getTypeElement(PKG+"Bundle");
            require(bundle.getModifiers().contains(Modifier.FINAL), "subclassable Bundle");
            var constructors=bundle.getEnclosedElements().stream().filter(e->e.getKind()==ElementKind.CONSTRUCTOR).toList();
            require(constructors.size()==1 && constructors.get(0).getModifiers().contains(Modifier.PRIVATE),"unsealed constructor");
            var constant=(VariableElement)bundle.getEnclosedElements().stream().filter(e->e.getSimpleName().contentEquals("SCHEMA_VERSION")).findFirst().orElseThrow();
            require("acgncert-schema-v10".equals(constant.getConstantValue()),"schema discriminator");
            var sections=(VariableElement)bundle.getEnclosedElements().stream()
                    .filter(e -> e.getSimpleName().contentEquals("SECTION_TAGS")).findFirst().orElseThrow();
            var initialization=(MethodInvocationTree)((VariableTree)trees.getTree(sections)).getInitializer();
            List<String> sectionTags=initialization.getArguments().stream().map(t -> (String)((LiteralTree)t).getValue()).toList();
            require(sectionTags.equals(List.of("metadata","manifest","contexts","embeddings","terms","proofs","witnesses",
                    "snapshots","events","canonical-records","unfoldings","publication")), "twelve ordered sections");
            Map<String,String> results=new TreeMap<>();
            List<String> allocations=new ArrayList<>(), successes=new ArrayList<>(), mains=new ArrayList<>();
            for(var unit:units) new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree m, Void p) {
                    var current=(ExecutableElement)trees.getElement(getCurrentPath());
                    String caller=id(current);
                    if(m.getBody()==null) return null;
                    if(current.getModifiers().containsAll(Set.of(Modifier.PUBLIC,Modifier.STATIC))
                            && m.getName().contentEquals("main")) mains.add(caller);
                    List<String> called=new ArrayList<>(), bindings=new ArrayList<>();
                    new TreePathScanner<Void,Void>() {
                        private void target(Tree tree) {
                            var callee=(ExecutableElement)trees.getElement(getCurrentPath());
                            require(callee != null, "unresolved method in "+caller);
                            String target=id(callee); called.add(target);
                            bindings.add(callee.getEnclosingElement()+"#"+callee+"::"+callee.asType());
                            if(target.equals("Bundle#<init>")) allocations.add(caller);
                            if(target.equals("VerificationResult#verified")) successes.add(caller);
                            if(target.equals("VerificationResult#<init>")) {
                                require(caller.startsWith("VerificationResult#"), "result construction bypass in "+caller);
                            }
                        }
                        @Override public Void visitMethodInvocation(MethodInvocationTree t,Void q){target(t);return super.visitMethodInvocation(t,q);}
                        @Override public Void visitNewClass(NewClassTree t,Void q){target(t);return super.visitNewClass(t,q);}
                        @Override public Void visitMemberReference(MemberReferenceTree t,Void q){target(t);return super.visitMemberReference(t,q);}
                        @Override public Void visitClass(ClassTree t,Void q){return null;}
                    }.scan(getCurrentPath(),null);
                    if (ROUTES.containsKey(caller)) {
                        var ordered=ROUTES.get(caller);
                        int index=0;
                        for(String actual:called) if(index<ordered.size() && ordered.get(index).equals(actual)) index++;
                        require(index==ordered.size(),caller+" unresolved route: "+ordered+" (matched "+index+")");
                        checkFlow(caller,m);
                        String pin=digest(m.toString()+"\n"+String.join("\n",bindings));
                        require(results.put(caller,pin)==null,"overloaded unmodeled route "+caller);
                    }
                    return super.visitMethod(m,p);
                }
            }.scan(unit,null);
            require(allocations.equals(List.of("Bundle#parse")), "constructor sites "+allocations);
            require(successes.stream().sorted().toList().equals(List.of("IndependentVerifier#verify","IndependentVerifier#verifyPair")), "success sites "+successes);
            require(mains.stream().sorted().toList().equals(List.of("Main#main","ManifestInspector#main","P613SourcePair#main","RawCallSourceAuthority#main")), "public main census "+mains);
            require(results.keySet().equals(ROUTES.keySet()),"missing source route");
            return results.entrySet().stream().map(e->"source\t"+e.getKey()+"\tattributed\t"+e.getValue()).toList();
        }
    }
}
