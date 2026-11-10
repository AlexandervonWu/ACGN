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

/** Strict javac-resolved pins, not a Java semantics theorem or a pin-learning mode. */
public final class SourceOccurrenceBindingsExtractor {
    private static final String P = "is.fivefivefive.CanDis.theory.";
    private static final Map<String, String> OWNERS = Map.of(
            "CertificateVerificationScope", P + "CertificateVerificationScope",
            "CertificateVerifier", P + "CertificateVerifier",
            "TheoryAlloyAdapter", P + "TheoryAlloyAdapter",
            "EGraphNode", "is.fivefivefive.CanDis.core.EGraphNode",
            "NormalForm", "is.fivefivefive.CanDis.core.NormalForm",
            "StructuralKey", P + "StructuralKey",
            "DependentChainCertificate", P + "DependentChainCertificate");
    private static final Map<String, String> EXPECTED = Map.of(
            "CertificateVerificationScope", "b756bbdfe372252e690bb2811a56e671e199ae5cda83c1fe4f42f0b12d24822a 986c75b0fef819e817dfb1cf29590e7d2c553fdc0b3f2ad48189403c171b4805",
            "CertificateVerifier", "368b02d882d4bcf7395cfc0dc76ccf1c0140b91bac7881340966e3594d393146 c4917a8b2603d5b8d751c0c881dede3c6de748875d447cf1d22566d15b7cd654",
            "TheoryAlloyAdapter", "34fab8469ffe44905c7aedb253c0bb27b40257987281bfc61536c2550c23d86f 65675f4936fbd2b8f5a2e056c752d728be467f4d574096863252da0939580b25",
            "EGraphNode", "ee8a3ff167b38878bffa8429c7735de618a19f5832d23abaa518d61be39b7b54 ce15aa5eb135475c10b7890732c2a94ff367edfb4a94f2e45305f14d27cb446b",
            "NormalForm", "ea74cf5d68c587d1bfd0848a3b3630400e2062a083d48754696865d2620c8412 7a162a721d2710f615cd1309aae94a245a9e92600ef78e8a4dbc5ea530a7912b",
            "StructuralKey", "62183e7e02a6c3cb416290405dea37ea44a00d9cfe662b74e1c04ccc7e91ba96 63f1e1524ff3c28e48a3991dccdbeeee7e9319f5b5bf47dc03523bfd8392386f",
            "DependentChainCertificate", "800b128e0f225b68f242d201009689bb5eeded3391250ef4259378dce034c35f 123b6c433070bf4455f1a888010e09bd51b45b584833ff884c6d71d48f0978e4");

    private static void require(boolean condition, String message) {
        if (!condition) throw new IllegalArgumentException("UNMODELED_SOURCE:" + message);
    }

    private static String digest(String value) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                .digest(value.getBytes(StandardCharsets.UTF_8)));
    }

    private static String modifiers(Element e) {
        return e.getModifiers().stream().map(Object::toString).sorted().collect(Collectors.joining(","));
    }

    private static String resolved(ClassTree node, CompilationUnitTree unit, Trees trees) {
        List<String> result = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            private void bind(Tree tree) {
                Element element = trees.getElement(TreePath.getPath(unit, tree));
                require(element != null, "unresolved source-occurrence symbol");
                Element owner = element.getEnclosingElement();
                result.add(tree.getKind() + ":" + element.getKind() + ":" + owner + ":" + element + ":"
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
        return String.join("\n", result);
    }

    public static void main(String[] args) throws Exception {
        // javac anonymous-class names use the process locale, not the task locale.
        Locale.setDefault(Locale.ROOT);
        require(args.length == 2, "Usage: SourceOccurrenceBindingsExtractor ROOT OUTPUT.tsv");
        require(Runtime.version().feature() == 17, "JDK17 required");
        Path root = Path.of(args[0]).toAbsolutePath().normalize(), output = Path.of(args[1]);
        Files.deleteIfExists(output);
        List<Path> sources = new ArrayList<>(), jars;
        for (String directory : List.of("src", "certificate-verifier/src")) {
            try (var files = Files.walk(root.resolve(directory))) {
                sources.addAll(files.filter(p -> p.toString().endsWith(".java")).sorted().toList());
            }
        }
        try (var files = Files.list(root.resolve("lib"))) {
            jars = files.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
        }
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "full JDK required");
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        List<String> rows = new ArrayList<>(List.of("object\towner\tshapeSha256\tbindingsSha256")), errors = new ArrayList<>();
        try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                    List.of("--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8",
                            "-classpath", jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                    null, fm.getJavaFileObjectsFromPaths(sources));
            task.setLocale(Locale.ROOT);
            List<CompilationUnitTree> units = new ArrayList<>();
            task.parse().forEach(units::add);
            task.analyze();
            require(diagnostics.getDiagnostics().stream().noneMatch(d -> d.getKind() == Diagnostic.Kind.ERROR),
                    "compiler diagnostics " + diagnostics.getDiagnostics().stream()
                            .filter(d -> d.getKind() == Diagnostic.Kind.ERROR).map(Object::toString)
                            .collect(Collectors.joining(" ")).replace('\n', ' ').replace('\r', ' '));
            Trees trees = Trees.instance(task);
            for (String name : new TreeSet<>(OWNERS.keySet())) {
                String owner = OWNERS.get(name);
                Path path = root.resolve("src/"
                        + owner.replace('.', '/') + ".java");
                var matching = units.stream().filter(u -> Path.of(u.getSourceFile().toUri()).equals(path)).toList();
                require(matching.size() == 1, "missing/ambiguous unit " + name);
                var unit = matching.get(0);
                var classes = unit.getTypeDecls().stream().filter(t -> t instanceof ClassTree)
                        .map(t -> (ClassTree) t).filter(t -> t.getSimpleName().contentEquals(name)).toList();
                require(classes.size() == 1, "missing/ambiguous class " + name);
                var node = classes.get(0);
                Element symbol = trees.getElement(TreePath.getPath(unit, node));
                require(symbol instanceof TypeElement && symbol.toString().equals(owner), "foreign owner " + name);
                String shape = digest(node.toString()), bindings = digest(resolved(node, unit, trees));
                if (!EXPECTED.get(name).equals(shape + " " + bindings))
                    errors.add(name + " observed " + shape + " " + bindings);
                rows.add(String.join("\t", name, owner, shape, bindings));
            }
        }
        require(errors.isEmpty(), "source-occurrence shape/binding mismatch\n" + String.join("\n", errors));
        require(rows.size() == 8, "incomplete source census");
        Files.write(output, rows, StandardCharsets.UTF_8);
        System.out.println("SourceOccurrenceBindingsExtractor passed: objects=7");
    }
}
