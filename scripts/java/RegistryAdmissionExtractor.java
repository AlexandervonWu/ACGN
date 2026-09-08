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

/** Frozen, resolved source bindings for the P2-19 observation correspondence.
 * A structural check is not a Java semantics theorem; the executable product
 * matrix and general Lean model are separate required evidence.
 */
public final class RegistryAdmissionExtractor {
    private static final String P = "is.fivefivefive.CanDis.theory.";
    private static final Map<String, String> EXPECTED = Map.of(
            "AlloyLawRegistry", "272257f8d03588e9cd009512c35a32a18c5194b5f74044c87a2716081690fb7b 9cad15d627e624d2998e965e86e8f5b52868552ca5c2d0015e12fb2fecebd041",
            "ContainerLawCertificate", "b058b18d175022e193564a5e93c254fbd48924e82de99820daf6ad7142cdc0f2 d952931af1f841172ecdef2d6d04e8f94279d45869f97b0e5e0de49d4cea049e",
            "SemanticProfile", "1b9144c54170bcd98528f79b4432cb1203057dc2ee1b7fedc0d55c2223120492 3bb8166269c04aa1cb967873088cfdeaefc3bafdbc3399c01122f12e1b99334b",
            "CertificateOrigin", "c88d33167e5b9a53f361ab0522a0b9d8559f5e934fa13039be7a98daad5ce9cb 621cef08d188571283089f056b2cf8bb44e22881b9d6a124952774694a3807e9");

    private static void require(boolean condition, String message) {
        if (!condition) throw new IllegalArgumentException(message);
    }

    private static String digest(String value) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));
    }

    private static String modifiers(Element element) {
        return element.getModifiers().stream().map(Object::toString).sorted().collect(Collectors.joining(","));
    }

    private static String resolved(ClassTree node, CompilationUnitTree unit, Trees trees) {
        List<String> result = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            private void bind(Tree tree) {
                Element element = trees.getElement(TreePath.getPath(unit, tree));
                require(element != null, "Unresolved registry symbol: " + tree);
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
        require(args.length == 2, "Usage: RegistryAdmissionExtractor ROOT OUTPUT.tsv");
        require(Runtime.version().feature() == 17, "JDK 17 required for frozen resolved-source grammar");
        Path root = Path.of(args[0]).toAbsolutePath().normalize();
        Path output = Path.of(args[1]);
        Files.deleteIfExists(output);
        List<Path> sources, jars;
        try (var files = Files.walk(root.resolve("src"))) {
            sources = files.filter(p -> p.toString().endsWith(".java")).sorted().toList();
        }
        try (var files = Files.list(root.resolve("lib"))) {
            jars = files.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
        }
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "Full JDK required");
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        List<String> rows = new ArrayList<>(List.of("object\towner\tshapeSha256\tbindingsSha256"));
        List<String> errors = new ArrayList<>();
        try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                    List.of("--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8",
                            "-sourcepath", root.resolve("src").toString(), "-classpath",
                            jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                    null, fm.getJavaFileObjectsFromPaths(sources));
            List<CompilationUnitTree> units = new ArrayList<>();
            task.parse().forEach(units::add);
            task.analyze();
            for (var diagnostic : diagnostics.getDiagnostics())
                require(diagnostic.getKind() != Diagnostic.Kind.ERROR, diagnostic.toString());
            Trees trees = Trees.instance(task);
            for (String name : new TreeSet<>(EXPECTED.keySet())) {
                Path path = root.resolve("src/" + P.replace('.', '/') + name + ".java");
                List<CompilationUnitTree> matching = units.stream().filter(u -> Path.of(u.getSourceFile().toUri()).equals(path)).toList();
                require(matching.size() == 1, "Missing/ambiguous registry source unit: " + name);
                CompilationUnitTree unit = matching.get(0);
                List<ClassTree> classes = unit.getTypeDecls().stream().filter(t -> t instanceof ClassTree)
                        .map(t -> (ClassTree) t).filter(t -> t.getSimpleName().contentEquals(name)).toList();
                require(classes.size() == 1, "Missing/ambiguous exact registry class: " + name);
                ClassTree node = classes.get(0);
                Element symbol = trees.getElement(TreePath.getPath(unit, node));
                require(symbol instanceof TypeElement && symbol.toString().equals(P + name), "Foreign registry owner");
                String shape = digest(node.toString());
                String bindings = digest(resolved(node, unit, trees));
                require(symbol.getModifiers().contains(Modifier.FINAL), "Registry carrier must retain final class dispatch");
                if (!EXPECTED.get(name).equals(shape + " " + bindings)) errors.add(name + " observed " + shape + " " + bindings);
                rows.add(String.join("\t", name, symbol.toString(), shape, bindings));
            }
        }
        require(errors.isEmpty(), "Unregistered registry source shape/binding:\n" + String.join("\n", errors));
        require(rows.size() == 5, "Incomplete registry source census");
        Files.write(output, rows, StandardCharsets.UTF_8);
        System.out.println("RegistryAdmissionExtractor passed: objects=4");
    }
}
