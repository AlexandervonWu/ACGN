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
public final class SemanticProfileWireExtractor {
    private static final String P = "is.fivefivefive.CanDis.theory.";
    private static final Map<String, String> OWNERS = Map.of(
            "SemanticProfile", P + "SemanticProfile", "StructuralKey", P + "StructuralKey",
            "AlloySemanticProfileFactory", P + "AlloySemanticProfileFactory",
            "CertificateBundleWriter", P + "CertificateBundleWriter",
            "SemanticEvidenceVerifier", "org.acgn.cert.SemanticEvidenceVerifier",
            "Wire", "org.acgn.cert.Wire", "Codec", "org.acgn.cert.Codec");
    private static final Map<String, String> EXPECTED = Map.of(
            "SemanticProfile", "1b9144c54170bcd98528f79b4432cb1203057dc2ee1b7fedc0d55c2223120492 3bb8166269c04aa1cb967873088cfdeaefc3bafdbc3399c01122f12e1b99334b",
            "StructuralKey", "62183e7e02a6c3cb416290405dea37ea44a00d9cfe662b74e1c04ccc7e91ba96 63f1e1524ff3c28e48a3991dccdbeeee7e9319f5b5bf47dc03523bfd8392386f",
            "AlloySemanticProfileFactory", "d9821e2209abefbbc39e5ca2ef3b44fb82a0720b0f89c824b5bde13b28bdafc2 9f2bb6130489dc740ba241f4811186be27d0ba8526300b0df2b7c6e2e3703818",
            "CertificateBundleWriter", "94c4ab8b81db73094f3dbf1987660fa2e662af108973b5c78dca58b82d213aa6 880ff160e6040325eccf17d41bba699294ab06e13ee57a3d29ee188dae88566a",
            "SemanticEvidenceVerifier", "c91040e65f45bfc520051f2ccdba9aa6a609e01c0d597eba731fd613f65743da cd2fe91218d45a6eaebc03233f04d8119c8a23064ab520a3f7657e3ee54755cd",
            "Wire", "5f62baead2c72f173aad5319a4c84a46d5e757f91c1b973e021e37b707a37e84 46015d7ca07b6ba13eb1b1fdebccb382f7492ee90d2827d9539bdde8853ad86e",
            "Codec", "c0869254cca18a781b4952ae50e4c752d015f3734347dc877c2d60f62bafb1ec 099694a8e4863290df0dbe1ef62e69237d728b92d2cfef1c5826cc5c28b1d77b");

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
                require(element != null, "unresolved profile symbol");
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
        require(args.length == 2, "Usage: SemanticProfileWireExtractor ROOT OUTPUT.tsv");
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
                Path path = root.resolve((owner.startsWith(P) ? "src/" : "certificate-verifier/src/")
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
        require(errors.isEmpty(), "profile shape/binding mismatch\n" + String.join("\n", errors));
        require(rows.size() == 8, "incomplete source census");
        Files.write(output, rows, StandardCharsets.UTF_8);
        System.out.println("SemanticProfileWireExtractor passed: objects=7");
    }
}
