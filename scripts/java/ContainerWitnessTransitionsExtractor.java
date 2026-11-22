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
            Map.entry("CertificateVerificationScope", "96cbb043b0b01bba17d547f3048e1fb93b4c4cf53553a4840c4c783b763deea4 40e9edc6e7d3909ffa2a28b08367c3c0850a8d5bc50aacb0df43e6d69674af32"),
            Map.entry("AlloyLawRegistry", "272257f8d03588e9cd009512c35a32a18c5194b5f74044c87a2716081690fb7b 9cad15d627e624d2998e965e86e8f5b52868552ca5c2d0015e12fb2fecebd041"),
            Map.entry("CertificateBundleWriter", "0c7358f17cbc534336696dec1d885130976602d2de0d520bea4ab3705cb812dd e69aff29b43f39f894de79e0470eb93e7d0bd5427a37f62ba9c4e1cbf23ba15e"),
            Map.entry("CertificateVerifier", "3d6c3503df22ddfb41c12c61916d90ef9c40efaa31ef4079510e99c5fc949d04 bffa5b50b8e99dca4b4dd59288a0d4d0fd0253d3145cad4816913efa22e5f8b8"),
            Map.entry("ContainerApplicationTrace", "38cca38c37ca76f05b9c5d08f85adb69c65b2f0fed8719c891b05e3d2d52db8b fe99c389770466e820400d38e0ff8d81b86bf258d5cb994f8e66314966a45f1d"),
            Map.entry("ContainerConstructionCertificate", "55e8e7749ca80eb280bf17b7e93bdfe065e5f0701fbe957a91587dc1ea44922b de3134e92cead0a801f768498d3fe76d5ac8df926af55b61ad01023f3cb3de0d"),
            Map.entry("ContainerLawCertificate", "b058b18d175022e193564a5e93c254fbd48924e82de99820daf6ad7142cdc0f2 d952931af1f841172ecdef2d6d04e8f94279d45869f97b0e5e0de49d4cea049e"),
            Map.entry("ContainerLawDeclaration", "4eca6d09ff3245d98b2711c865cb0dc61b0a82166d05348df11728722bc5618f 7b51b568114f1f32547156934bc46ae0029e9a65fd4054a172de0faa1096f298"),
            Map.entry("FlatApplication", "1e57064a889494f17cd75c659ee30d648a0a081befa802b8c25c6287025b2398 890ca35964d2a0cbe1586e0f8dec7ce881447fc868300679f5482a084905e0be"),
            Map.entry("FlatConstructionCertificate", "fddb9145978709c2881df347a902401fb1cc51ced2ac375aeb8e5d1413a97c9a 1de9f3d0ef542c59dc12a3bc379a5dd527330e103312940db1eca53e5a883aa2"),
            Map.entry("SemanticEvidenceVerifier", "85f06b745f3974245747abc0cb30b749864c54d716212132e53d0a4cf0502d95 800f352adbfef4646c7bd58e37f2a8b7b239653ef1ebd87358df0154c38decc4"),
            Map.entry("StructuralKey", "62183e7e02a6c3cb416290405dea37ea44a00d9cfe662b74e1c04ccc7e91ba96 63f1e1524ff3c28e48a3991dccdbeeee7e9319f5b5bf47dc03523bfd8392386f"),
            Map.entry("TheoryAlloyAdapter", "f1fa121d2b059147dc2af5bf7e44531585c147cf827a7aa6138aec658bca9d6c d9551bea070c3fd486e496ba2e9daacaae558c862bddbffae0fb9bbd9104bdb5"),
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
