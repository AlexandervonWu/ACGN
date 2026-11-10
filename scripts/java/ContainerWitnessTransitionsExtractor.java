import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.stream.Collectors;
import javax.lang.model.element.*;
import javax.tools.*;

/** Compiler-resolved signatures, bodies, dispatch and bindings; not JVM refinement. */
public final class ContainerWitnessTransitionsExtractor {
    private static final String P = "is.fivefivefive.CanDis.theory.";
    private static final Map<String, String> EXPECTED = Map.ofEntries(
            Map.entry("CertificateVerificationScope", "b756bbdfe372252e690bb2811a56e671e199ae5cda83c1fe4f42f0b12d24822a 986c75b0fef819e817dfb1cf29590e7d2c553fdc0b3f2ad48189403c171b4805"),
            Map.entry("AlloyLawRegistry", "272257f8d03588e9cd009512c35a32a18c5194b5f74044c87a2716081690fb7b 9cad15d627e624d2998e965e86e8f5b52868552ca5c2d0015e12fb2fecebd041"),
            Map.entry("CertificateBundleWriter", "b30d10623694288f274a1fc26b6f92dc6b00ecc6264a58a54e5f01b3a35e7e46 0807ef1b7acdba3a1c72c6f339a02ede7d8beebc969500c4e66de3c5983b1d21"),
            Map.entry("CertificateVerifier", "368b02d882d4bcf7395cfc0dc76ccf1c0140b91bac7881340966e3594d393146 c4917a8b2603d5b8d751c0c881dede3c6de748875d447cf1d22566d15b7cd654"),
            Map.entry("ContainerApplicationTrace", "38cca38c37ca76f05b9c5d08f85adb69c65b2f0fed8719c891b05e3d2d52db8b fe99c389770466e820400d38e0ff8d81b86bf258d5cb994f8e66314966a45f1d"),
            Map.entry("ContainerConstructionCertificate", "55e8e7749ca80eb280bf17b7e93bdfe065e5f0701fbe957a91587dc1ea44922b de3134e92cead0a801f768498d3fe76d5ac8df926af55b61ad01023f3cb3de0d"),
            Map.entry("ContainerLawCertificate", "b058b18d175022e193564a5e93c254fbd48924e82de99820daf6ad7142cdc0f2 d952931af1f841172ecdef2d6d04e8f94279d45869f97b0e5e0de49d4cea049e"),
            Map.entry("ContainerLawDeclaration", "4eca6d09ff3245d98b2711c865cb0dc61b0a82166d05348df11728722bc5618f 7b51b568114f1f32547156934bc46ae0029e9a65fd4054a172de0faa1096f298"),
            Map.entry("FlatApplication", "1e57064a889494f17cd75c659ee30d648a0a081befa802b8c25c6287025b2398 890ca35964d2a0cbe1586e0f8dec7ce881447fc868300679f5482a084905e0be"),
            Map.entry("FlatConstructionCertificate", "fddb9145978709c2881df347a902401fb1cc51ced2ac375aeb8e5d1413a97c9a 1de9f3d0ef542c59dc12a3bc379a5dd527330e103312940db1eca53e5a883aa2"),
            Map.entry("SemanticEvidenceVerifier", "bff2c3471c7fc123e9752ce4a70a964811382f52df9d6e5475b6854a10df03bc cd2fe91218d45a6eaebc03233f04d8119c8a23064ab520a3f7657e3ee54755cd"),
            Map.entry("StructuralKey", "62183e7e02a6c3cb416290405dea37ea44a00d9cfe662b74e1c04ccc7e91ba96 63f1e1524ff3c28e48a3991dccdbeeee7e9319f5b5bf47dc03523bfd8392386f"),
            Map.entry("TheoryAlloyAdapter", "34fab8469ffe44905c7aedb253c0bb27b40257987281bfc61536c2550c23d86f 65675f4936fbd2b8f5a2e056c752d728be467f4d574096863252da0939580b25"),
            Map.entry("TypedENode", "b70e73eaabd850acf69575e9e134f165dbc8a60dc1790e816b7aaa6d65e18cc1 ef393be4a64e937af202fa7ca18d9858f6aa0afe0faa6c113b8155223a767a2b"));

    private static void require(boolean value, String message) {
        if (!value) throw new IllegalArgumentException("UNMODELED_SOURCE:" + message);
    }
    private static String digest(String value) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));
    }
    private static String modifiers(Element element) {
        return element.getModifiers().stream().map(Object::toString).sorted().collect(Collectors.joining(","));
    }
    private static String resolved(ClassTree node, CompilationUnitTree unit, Trees trees) {
        List<String> bindings = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            private void bind(Tree tree) {
                Element element = trees.getElement(TreePath.getPath(unit, tree));
                require(element != null, "unresolved container symbol");
                Element owner = element.getEnclosingElement();
                bindings.add(tree.getKind() + ":" + element.getKind() + ":" + owner + ":" + element + ":"
                        + element.asType() + ":" + modifiers(element) + ":owner=" + (owner == null ? "" : modifiers(owner)));
            }
            @Override public Void visitIdentifier(IdentifierTree n, Void p) { bind(n); return super.visitIdentifier(n, p); }
            @Override public Void visitMemberSelect(MemberSelectTree n, Void p) { bind(n); return super.visitMemberSelect(n, p); }
            @Override public Void visitMethodInvocation(MethodInvocationTree n, Void p) { bind(n); return super.visitMethodInvocation(n, p); }
            @Override public Void visitNewClass(NewClassTree n, Void p) { bind(n); return super.visitNewClass(n, p); }
            @Override public Void visitMethod(MethodTree n, Void p) { bind(n); return super.visitMethod(n, p); }
            @Override public Void visitVariable(VariableTree n, Void p) { bind(n); return super.visitVariable(n, p); }
            @Override public Void visitClass(ClassTree n, Void p) { bind(n); return super.visitClass(n, p); }
        }.scan(node, null);
        return String.join("\n", bindings);
    }
    public static void main(String[] args) throws Exception {
        require(args.length == 2, "usage ROOT OUTPUT.tsv");
        require(Runtime.version().feature() == 17, "JDK17 required");
        Path root = Path.of(args[0]).toAbsolutePath().normalize();
        Path output = Path.of(args[1]); Files.deleteIfExists(output);
        List<Path> sources = new ArrayList<>(), jars;
        for (String directory : List.of("src", "certificate-verifier/src")) {
            try (var files = Files.walk(root.resolve(directory))) {
                sources.addAll(files.filter(p -> p.toString().endsWith(".java")).sorted().toList());
            }
        }
        try (var files = Files.list(root.resolve("lib"))) {
            jars = files.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
        }
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler(); require(compiler != null, "full JDK required");
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        List<String> rows = new ArrayList<>(List.of("object\towner\tshapeSha256\tbindingsSha256"));
        List<String> errors = new ArrayList<>();
        try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                    List.of("--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8", "-classpath",
                            jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                    null, fm.getJavaFileObjectsFromPaths(sources));
            task.setLocale(Locale.ROOT);
            List<CompilationUnitTree> units = new ArrayList<>(); task.parse().forEach(units::add); task.analyze();
            if (diagnostics.getDiagnostics().stream().anyMatch(d -> d.getKind() == Diagnostic.Kind.ERROR))
                throw new IllegalStateException("JAVAC_RESOLUTION_FAILURE");
            Trees trees = Trees.instance(task);
            for (String name : new TreeSet<>(EXPECTED.keySet())) {
                String owner = name.equals("SemanticEvidenceVerifier") ? "org.acgn.cert." + name : P + name;
                Path path = root.resolve((name.equals("SemanticEvidenceVerifier") ? "certificate-verifier/src/" : "src/")
                        + owner.replace('.', '/') + ".java");
                List<CompilationUnitTree> matches = units.stream().filter(u -> Path.of(u.getSourceFile().toUri()).equals(path)).toList();
                require(matches.size() == 1, "missing/ambiguous source unit " + name);
                CompilationUnitTree unit = matches.get(0);
                List<ClassTree> classes = unit.getTypeDecls().stream().filter(t -> t instanceof ClassTree)
                        .map(t -> (ClassTree) t).filter(t -> t.getSimpleName().contentEquals(name)).toList();
                require(classes.size() == 1, "missing/ambiguous source class " + name);
                ClassTree node = classes.get(0);
                Element symbol = trees.getElement(TreePath.getPath(unit, node));
                require(symbol instanceof TypeElement && symbol.toString().equals(owner), "foreign owner " + name);
                String shape = digest(node.toString()), bindings = digest(resolved(node, unit, trees));
                if (!EXPECTED.get(name).equals(shape + " " + bindings)) errors.add(name + " observed " + shape + " " + bindings);
                rows.add(String.join("\t", name, owner, shape, bindings));
            }
        }
        require(errors.isEmpty(), "container source signature/body/binding mismatch\n" + String.join("\n", errors));
        require(rows.size() == 15, "incomplete source census");
        Files.write(output, rows, StandardCharsets.UTF_8);
        System.out.println("ContainerWitnessTransitionsExtractor passed: objects=14");
    }
}
