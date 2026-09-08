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

/** Frozen whole-method AST and resolved binding grammar, not a Java proof. */
public final class GuardedJoinChainExtractor {
    private static final String P = "is.fivefivefive.CanDis.theory.";
    private static final String V = "org.acgn.cert.SemanticEvidenceVerifier";
    private record Target(String id, String owner, String method, int arity, String modifiers,
            String shape, String bindings) { }
    private static final List<Target> TARGETS = List.of(
        new Target("producer-guard", P + "DependentChainTheory", "requireSoundFlattening", 2,
                "public,static", "ba3602904fbde410970535101526e96938d400e18ed14c2a23f50f649b0c8280", "2833b788067346f06fd1549a7e0943855a0e899081e089fbf0d4b7a6e57ba1e4"),
        new Target("producer-combine", P + "DependentTypeDag", "combine", 3,
                "public,static", "a63d65791d82625180c9793b63c8d1b477ec9d643e738059c83d8f53e29dda27", "b05927d7cc63c8e1d54a51871e08e98180d73d4d78564084516f130067e711fb"),
        new Target("verifier-guard", V + ".SemanticReplay", "requireSoundDependentFlattening", 2,
                "private", "86a2ab6dae44a6cad938f0f045abbf63a53409bc082a40c564793f98693ab195", "b06159725dc29b6139dc94b5cfae780de7c3b26e921865064cfd93ba245983ed"),
        new Target("verifier-combine", V + ".SemanticReplay", "requireChainCombination", 3,
                "private", "9b68a2996d5f0fb6f27a2b93f8b430a2ba577c99ec55dd39e8e692feceaa78bf", "6cd8657889f4187de4248e1283eaaa02a35fc7be87962da377b17950ea5931f9")
    );

    private static void require(boolean ok, String message) {
        if (!ok) throw new IllegalArgumentException(message);
    }

    private static String modifiers(Element e) {
        return e == null ? "" : e.getModifiers().stream().map(Object::toString).sorted().collect(Collectors.joining(","));
    }

    private static String digest(List<String> tokens) throws Exception {
        MessageDigest hash = MessageDigest.getInstance("SHA-256");
        for (String token : tokens) {
            byte[] bytes = token.getBytes(StandardCharsets.UTF_8);
            hash.update((bytes.length + ":").getBytes(StandardCharsets.US_ASCII));
            hash.update(bytes);
        }
        return HexFormat.of().formatHex(hash.digest());
    }

    private static List<String> bindings(CompilationUnitTree unit, MethodTree method, Trees trees) {
        List<String> result = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            private void bind(Tree tree) {
                Element e = trees.getElement(TreePath.getPath(unit, tree));
                require(e != null, "Unresolved symbol: " + tree);
                result.add(tree.getKind() + ":" + e.getKind() + ":" + e.getEnclosingElement() + ":" + e
                        + ":" + e.asType() + ":" + modifiers(e) + ":owner=" + modifiers(e.getEnclosingElement()));
            }
            @Override public Void visitMethod(MethodTree t, Void p) { bind(t); return super.visitMethod(t, p); }
            @Override public Void visitVariable(VariableTree t, Void p) { bind(t); return super.visitVariable(t, p); }
            @Override public Void visitIdentifier(IdentifierTree t, Void p) { bind(t); return super.visitIdentifier(t, p); }
            @Override public Void visitMemberSelect(MemberSelectTree t, Void p) { bind(t); return super.visitMemberSelect(t, p); }
            @Override public Void visitMethodInvocation(MethodInvocationTree t, Void p) { bind(t); return super.visitMethodInvocation(t, p); }
            @Override public Void visitNewClass(NewClassTree t, Void p) { bind(t); return super.visitNewClass(t, p); }
            @Override public Void visitMemberReference(MemberReferenceTree t, Void p) { bind(t); return super.visitMemberReference(t, p); }
        }.scan(method, null);
        return result;
    }

    public static void main(String[] args) throws Exception {
        require(args.length == 2, "Usage: GuardedJoinChainExtractor ROOT OUTPUT.tsv");
        Path root = Path.of(args[0]).toAbsolutePath().normalize();
        Path output = Path.of(args[1]);
        Files.deleteIfExists(output);
        require(Runtime.version().feature() == 17, "Compiler binding grammar requires JDK 17");
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "Full JDK required");
        // Reuse the reviewed typed guard grammar, including producer validation.
        Path guards = Files.createTempFile(output.toAbsolutePath().getParent(), "join-guard-", ".tsv");
        try {
            JoinGuardExtractor.main(new String[] {root.toString(), guards.toString()});
            require(Files.readString(guards).equals("guard\tminimumInteriorArity\tstart\tendOffset\n"
                    + "producer\t2\t1\t1\nverifier\t2\t1\t1\n"), "Wrong interior guard");
        } finally { Files.deleteIfExists(guards); }
        List<String> rows = new ArrayList<>(List.of(
                "object\towner\tmethod\tmodifiers\tshapeSha256\tbindingsSha256\tminimum\tstart\tendOffset\tleftBoundary\trightBoundary"));
        List<String> failures = new ArrayList<>();
        for (String baseName : List.of("src", "certificate-verifier/src")) {
            Path base = root.resolve(baseName);
            List<Path> sources;
            try (var paths = Files.walk(base)) {
                sources = paths.filter(p -> p.toString().endsWith(".java")).sorted().toList();
            }
            List<Path> jars;
            try (var paths = Files.list(root.resolve("lib"))) {
                jars = paths.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
            }
            DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
            try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
                JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics, List.of(
                        "--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8",
                        "-sourcepath", base.toString(), "-classpath",
                        jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                        null, fm.getJavaFileObjectsFromPaths(sources));
                List<CompilationUnitTree> units = new ArrayList<>();
                task.parse().forEach(units::add);
                task.analyze();
                for (var d : diagnostics.getDiagnostics()) require(d.getKind() != Diagnostic.Kind.ERROR, d.toString());
                Trees trees = Trees.instance(task);
                for (Target target : TARGETS) {
                    if (target.owner.startsWith(P) != baseName.equals("src")) continue;
                    String top = target.owner.startsWith(P) ? target.owner : V;
                    Path source = base.resolve(top.replace('.', '/') + ".java");
                    List<CompilationUnitTree> found = units.stream()
                            .filter(u -> Path.of(u.getSourceFile().toUri()).equals(source)).toList();
                    require(found.size() == 1, "Missing/ambiguous source unit");
                    CompilationUnitTree unit = found.get(0);
                    MethodTree method = JoinGuardExtractor.find(unit, target.method);
                    Element symbol = trees.getElement(TreePath.getPath(unit, method));
                    require(symbol instanceof ExecutableElement, "Unresolved method");
                    ExecutableElement executable = (ExecutableElement) symbol;
                    require(symbol.getEnclosingElement().toString().equals(target.owner)
                            && executable.getParameters().size() == target.arity
                            && modifiers(symbol).equals(target.modifiers), "Foreign signature/modifiers: " + target.id);
                    List<String> shape = new ArrayList<>(JoinGuardExtractor.shape(method));
                    new TreeScanner<Void, Void>() {
                        @Override public Void visitLiteral(LiteralTree t, Void p) {
                            if (t.getValue() instanceof String value) shape.add("string:" + value);
                            return super.visitLiteral(t, p);
                        }
                    }.scan(method, null);
                    String shapeHash = digest(shape), bindingHash = digest(bindings(unit, method, trees));
                    if (!shapeHash.equals(target.shape) || !bindingHash.equals(target.bindings))
                        failures.add(target.id + " observed " + shapeHash + " " + bindingHash);
                    // Values are emitted only after the exact whole-method grammar is checked.
                    rows.add(String.join("\t", target.id, target.owner, target.method, modifiers(symbol),
                            shapeHash, bindingHash, "2", "1", "1", "last", "first"));
                }
            }
        }
        require(failures.isEmpty(), "Unmodeled JOIN structure/resolution:\n" + String.join("\n", failures));
        require(rows.size() == 5, "Incomplete source census");
        Files.writeString(output, String.join("\n", rows) + "\n", StandardCharsets.UTF_8);
        System.out.println("GuardedJoinChainExtractor passed: objects=4");
    }
}
