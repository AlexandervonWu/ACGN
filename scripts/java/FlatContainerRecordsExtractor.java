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
public final class FlatContainerRecordsExtractor {
    private static final String P = "is.fivefivefive.CanDis.theory.";
    private static final Map<String, String> EXPECTED = Map.ofEntries(
            Map.entry("AlloyLawRegistry", "272257f8d03588e9cd009512c35a32a18c5194b5f74044c87a2716081690fb7b 9cad15d627e624d2998e965e86e8f5b52868552ca5c2d0015e12fb2fecebd041"),
            Map.entry("CertificateBundleWriter", "94c4ab8b81db73094f3dbf1987660fa2e662af108973b5c78dca58b82d213aa6 880ff160e6040325eccf17d41bba699294ab06e13ee57a3d29ee188dae88566a"),
            Map.entry("CertificateVerifier", "c4e7d05ca65ed2c0ff5ea4244ee409e6e7eb4ea36c4ab387e6e5c7e4032ddf56 68c116205f4cbdcbaa4b0ab023d279d86f7ab4aa00c3bc9db6a72e28a2760ee7"),
            Map.entry("ContainerApplicationTrace", "38cca38c37ca76f05b9c5d08f85adb69c65b2f0fed8719c891b05e3d2d52db8b fe99c389770466e820400d38e0ff8d81b86bf258d5cb994f8e66314966a45f1d"),
            Map.entry("ContainerConstructionCertificate", "55e8e7749ca80eb280bf17b7e93bdfe065e5f0701fbe957a91587dc1ea44922b de3134e92cead0a801f768498d3fe76d5ac8df926af55b61ad01023f3cb3de0d"),
            Map.entry("ContainerLawCertificate", "b058b18d175022e193564a5e93c254fbd48924e82de99820daf6ad7142cdc0f2 d952931af1f841172ecdef2d6d04e8f94279d45869f97b0e5e0de49d4cea049e"),
            Map.entry("ContainerLawDeclaration", "4eca6d09ff3245d98b2711c865cb0dc61b0a82166d05348df11728722bc5618f 7b51b568114f1f32547156934bc46ae0029e9a65fd4054a172de0faa1096f298"),
            Map.entry("FlatApplication", "1e57064a889494f17cd75c659ee30d648a0a081befa802b8c25c6287025b2398 890ca35964d2a0cbe1586e0f8dec7ce881447fc868300679f5482a084905e0be"),
            Map.entry("FlatConstructionCertificate", "a918ac6d487f045cca2371a43ad0f10b27d59ac5026f6c3420d8f7adc83cf735 11398eb89b926928e61e13004d2da313588fc3767021d6d091a6a5e2d00fdf7f"),
            Map.entry("SemanticEvidenceVerifier", "c91040e65f45bfc520051f2ccdba9aa6a609e01c0d597eba731fd613f65743da cd2fe91218d45a6eaebc03233f04d8119c8a23064ab520a3f7657e3ee54755cd"),
            Map.entry("StructuralKey", "62183e7e02a6c3cb416290405dea37ea44a00d9cfe662b74e1c04ccc7e91ba96 63f1e1524ff3c28e48a3991dccdbeeee7e9319f5b5bf47dc03523bfd8392386f"),
            Map.entry("TheoryAlloyAdapter", "e4c13603b97a2b342cd80a2aa25e131abdda5ff91aea63248f15bca102080495 2781b813137ddf634e7d56b3f3649302d7a94e1d1503449cb2e0cf21c0c4d2a5"),
            Map.entry("TypedENode", "f58f8be6ec83b8fc4128e4f77b75271c6024f467057e19b34763d561513994d4 a5bdd4799200142c86ee60d9430b50a9009eddc592c03ee828614eef7686aea8"));

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
                require(element != null, "unresolved records symbol");
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
        require(errors.isEmpty(), "records source signature/body/binding mismatch\n" + String.join("\n", errors));
        require(rows.size() == 14, "incomplete source census");
        Files.write(output, rows, StandardCharsets.UTF_8);
        System.out.println("FlatContainerRecordsExtractor passed: objects=13");
    }
}
