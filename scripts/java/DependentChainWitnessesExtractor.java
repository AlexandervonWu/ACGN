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

/** Whole-class compiler-resolved conformance pins; not Java semantic refinement. */
public final class DependentChainWitnessesExtractor {
    private static final String P = "is.fivefivefive.CanDis.theory.";
    private static final Map<String, String> PINS = Map.ofEntries(
            Map.entry("DependentChainTheory", "325740a2f5587deeb28ab091880d6f2d9ce0894dd659b872103cb13a5cb3c194 e107211d2bfeb3a5a7bca53dc0d0f7db63ffbcf61fe327cdfd405e0d81a72796"),
            Map.entry("DependentChainLeaf", "64c387d33dc40528ac4b1a9faa8a72237a10f0d049f656731fd5af4b88470fb8 13f9b2a502d11b0836d7453950bf0e028f8fb3f03cb416013436794fbd25b5a6"),
            Map.entry("DependentChainApplication", "db81a97d3a9553bf83a22b8721205b61e940ec4c6f550ed115206782470a30f5 90dca62f7db47fe638762cbcb0a617f536bfba19a876012b122842f63e7f25bb"),
            Map.entry("DependentChainCertificate", "800b128e0f225b68f242d201009689bb5eeded3391250ef4259378dce034c35f 9ab2f002f27397ca2a0df0e45f98eee11a4a6993c73f8986dae6b4d0d91ec4ec"),
            Map.entry("DependentTypeDag", "b6c18c3ca66eba2bdaba5385211ab9f557419ac6dc6f807659fef0c33acb5c4e b52e7b1c6925e177d91e6202f01cd5ceb4786d0ce26d9c01ec8bf2972be90c42"),
            Map.entry("DependentColumnEvidence", "3aad8a1cfd9aa91431ec46ec25f3dbae94f82d8926e129d5702f9675ee495e54 11cf028d508997595a314cef1f0a36d411d1ba8f799e8c0e125bedecc02e6e47"),
            Map.entry("DependentBoundaryCorrespondence", "201590a925c01cd5a6e9f51dd7e9b9a497a7dcea5efbf499780da8dba263e67e c9763fd525bc78c86203a875e0e5063955dbe396d34dd30249b464cdd23da3da"),
            Map.entry("CertificateBundleWriter", "94c4ab8b81db73094f3dbf1987660fa2e662af108973b5c78dca58b82d213aa6 a8dc4e4157b854b38e8d98da97e6bf614c72ac4ffc7f08ef4fd39dc2bce4126d"),
            Map.entry("TheoryKeys", "6996cae14018896b70e600cdc3252ba1654f49d0865927feb30626de2bb0be80 2e67b77018788888b9be5085d2f4bd8824af0079ee701a86dccf480325f02534"),
            Map.entry("TypedCertificateEndpoint", "9592eec198ba9ef3b3073cbef9ecf994dd0a8f8d70fe6eeab7bc218e8703891f a6dbd09bd87ecf04e7139b6c214047614be7324329d3ada157a66d877010399a"),
            Map.entry("TypedEqualityCertificate", "460176ca8939a4fe2f29a9ad2b1bbe916ffcee7075e48151d55c581d8e6dd916 3fd2cb09eab2671bf23a1d0d1317428eb8b21f65f5e4bfad138813bf7d5fb22e"),
            Map.entry("SemanticProfile", "1b9144c54170bcd98528f79b4432cb1203057dc2ee1b7fedc0d55c2223120492 3bb8166269c04aa1cb967873088cfdeaefc3bafdbc3399c01122f12e1b99334b"),
            Map.entry("SemanticEvidenceVerifier", "c91040e65f45bfc520051f2ccdba9aa6a609e01c0d597eba731fd613f65743da a96e5e846bc4901abe3350c51da5a02ba7650677d50a176ab88b8390e0660177"));

    private static void require(boolean ok, String message) {
        if (!ok) throw new IllegalArgumentException("UNMODELED_SOURCE:" + message);
    }
    private static String modifiers(Element e) {
        return e == null ? "" : e.getModifiers().stream().map(Object::toString).sorted().collect(Collectors.joining(","));
    }
    private static String hash(String value) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8)));
    }
    private static String bindings(ClassTree node, CompilationUnitTree unit, Trees trees) {
        List<String> result = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            private void bind(Tree tree) {
                Element e = trees.getElement(TreePath.getPath(unit, tree));
                require(e != null, "unresolved symbol");
                result.add(tree.getKind() + ":" + e.getKind() + ":" + e.getEnclosingElement() + ":" + e
                        + ":" + e.asType() + ":" + modifiers(e) + ":owner=" + modifiers(e.getEnclosingElement()));
            }
            @Override public Void visitClass(ClassTree t, Void p) { bind(t); return super.visitClass(t, p); }
            @Override public Void visitMethod(MethodTree t, Void p) { bind(t); return super.visitMethod(t, p); }
            @Override public Void visitVariable(VariableTree t, Void p) { bind(t); return super.visitVariable(t, p); }
            @Override public Void visitIdentifier(IdentifierTree t, Void p) { bind(t); return super.visitIdentifier(t, p); }
            @Override public Void visitMemberSelect(MemberSelectTree t, Void p) { bind(t); return super.visitMemberSelect(t, p); }
            @Override public Void visitMethodInvocation(MethodInvocationTree t, Void p) { bind(t); return super.visitMethodInvocation(t, p); }
            @Override public Void visitNewClass(NewClassTree t, Void p) { bind(t); return super.visitNewClass(t, p); }
            @Override public Void visitMemberReference(MemberReferenceTree t, Void p) { bind(t); return super.visitMemberReference(t, p); }
        }.scan(node, null);
        return String.join("\n", result);
    }
    public static void main(String[] args) throws Exception {
        require(args.length == 2, "usage ROOT OUTPUT.tsv");
        Path root = Path.of(args[0]).toAbsolutePath().normalize(), output = Path.of(args[1]);
        Files.deleteIfExists(output);
        require(Runtime.version().feature() == 17, "JDK17 required");
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "full compiler required");
        List<String> rows = new ArrayList<>(List.of("object\towner\tshapeSha256\tbindingsSha256"));
        List<String> errors = new ArrayList<>();
        for (String baseName : List.of("src", "certificate-verifier/src")) {
            Path base = root.resolve(baseName);
            List<Path> sources, jars;
            try (var paths = Files.walk(base)) { sources = paths.filter(p -> p.toString().endsWith(".java")).sorted().toList(); }
            if (baseName.equals("src")) {
                sources = new ArrayList<>(sources);
                try (var paths = Files.walk(root.resolve("certificate-verifier/src"))) {
                    sources.addAll(paths.filter(p -> p.toString().endsWith(".java")).sorted().toList());
                }
            }
            try (var paths = Files.list(root.resolve("lib"))) { jars = paths.filter(p -> p.toString().endsWith(".jar")).sorted().toList(); }
            DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
            try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
                JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                        List.of("--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8",
                                "-sourcepath", base.toString(), "-classpath",
                                jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                        null, fm.getJavaFileObjectsFromPaths(sources));
                List<CompilationUnitTree> units = new ArrayList<>(); task.parse().forEach(units::add); task.analyze();
                require(diagnostics.getDiagnostics().stream().noneMatch(d -> d.getKind() == Diagnostic.Kind.ERROR), "compiler errors");
                Trees trees = Trees.instance(task);
                for (String name : new TreeSet<>(PINS.keySet())) {
                    boolean verifier = name.equals("SemanticEvidenceVerifier");
                    if (verifier != baseName.equals("certificate-verifier/src")) continue;
                    String owner = (verifier ? "org.acgn.cert." : P) + name;
                    Path file = base.resolve(owner.replace('.', '/') + ".java");
                    List<CompilationUnitTree> found = units.stream().filter(u -> Path.of(u.getSourceFile().toUri()).equals(file)).toList();
                    require(found.size() == 1, "missing/ambiguous source unit");
                    CompilationUnitTree unit = found.get(0);
                    List<ClassTree> classes = unit.getTypeDecls().stream().filter(t -> t instanceof ClassTree)
                            .map(t -> (ClassTree) t).filter(t -> t.getSimpleName().contentEquals(name)).toList();
                    require(classes.size() == 1, "missing/ambiguous source class");
                    ClassTree node = classes.get(0);
                    Element symbol = trees.getElement(TreePath.getPath(unit, node));
                    require(symbol instanceof TypeElement && symbol.toString().equals(owner), "foreign owner");
                    String shape = hash(node.toString()), binding = hash(bindings(node, unit, trees));
                    if (!PINS.get(name).equals(shape + " " + binding)) errors.add(name + " observed " + shape + " " + binding);
                    rows.add(String.join("\t", name, owner, shape, binding));
                }
            }
        }
        require(errors.isEmpty(), "dependent-chain shape/binding\n" + String.join("\n", errors));
        require(rows.size() == 14, "source census");
        Files.write(output, rows, StandardCharsets.UTF_8);
        System.out.println("DependentChainWitnessesExtractor passed: objects=13");
    }
}
