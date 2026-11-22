package org.acgn.cert;

import com.sun.source.tree.ClassTree;
import com.sun.source.tree.CompilationUnitTree;
import com.sun.source.tree.LiteralTree;
import com.sun.source.tree.MemberReferenceTree;
import com.sun.source.tree.MethodInvocationTree;
import com.sun.source.tree.MethodTree;
import com.sun.source.tree.NewClassTree;
import com.sun.source.util.JavacTask;
import com.sun.source.util.TreePathScanner;
import com.sun.source.util.Trees;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import javax.lang.model.element.ExecutableElement;
import javax.tools.Diagnostic;
import javax.tools.DiagnosticCollector;
import javax.tools.JavaFileObject;
import javax.tools.ToolProvider;

/** Resolves actual wire constructors, wire reads, and the complete bodies that order them. */
public final class A225SourceContract {
    private static final Map<String, Set<String>> METHODS = Map.ofEntries(
            Map.entry("CertificateBundleWriter", Set.of("writeNode", "writeString", "encodeCanonicalUtf8")),
            Map.entry("Assembler", Set.of("dependentChainInput", "dependentTypeDag", "dependentTypeProduct",
                    "dependentCombinationCases", "dependentCombinationCase", "dependentBoundary", "type", "exactType")),
            Map.entry("DependentTypeDag", Set.of("combine")),
            Map.entry("Codec", Set.of("decode", "readNode", "readString", "readCount", "writeNode", "writeString", "encodeCanonicalUtf8")),
            Map.entry("Bundle", Set.of("<init>", "parse", "parseUnsignedLong")),
            Map.entry("SemanticEvidenceVerifier", Set.of("verify", "requireType", "isAdmittedAtomicChainColumn", "parsePositiveInt")),
            Map.entry("SemanticReplay", Set.of("dependentChainInput", "dependentTypeDag", "dependentTypeProduct",
                    "requireChainCombination", "requireCombinationCasesWire", "requireBoundaryWire", "boundaryPath",
                    "type", "requireKey", "requireNormalizedAlternatives", "commonAncestorType", "registerChainAncestry")),
            Map.entry("IndependentVerifier", Set.of("open", "verify", "verifyPair")));

    private static final String PRODUCER = "src/is/fivefivefive/CanDis/theory/";
    private static final String VERIFIER = "certificate-verifier/src/org/acgn/cert/";

    static List<String> capture(Path root) throws Exception {
        var sources = List.of(PRODUCER + "CertificateBundleWriter.java", PRODUCER + "DependentTypeDag.java",
                VERIFIER + "Bundle.java", VERIFIER + "Codec.java", VERIFIER + "SemanticEvidenceVerifier.java",
                VERIFIER + "IndependentVerifier.java");
        var compiler = ToolProvider.getSystemJavaCompiler();
        var messages = new DiagnosticCollector<JavaFileObject>();
        var rows = new TreeMap<String, String>();
        var covered = new java.util.HashSet<String>();
        try (var files = compiler.getStandardFileManager(messages, null, StandardCharsets.UTF_8)) {
            var task = (JavacTask) compiler.getTask(null, files, messages,
                    List.of("--release", "17", "-proc:none", "-classpath", System.getProperty("java.class.path")),
                    null, files.getJavaFileObjectsFromPaths(sources.stream().map(root::resolve).toList()));
            var units = new ArrayList<CompilationUnitTree>();
            task.parse().forEach(units::add);
            var trees = Trees.instance(task);
            task.analyze();
            for (var error : messages.getDiagnostics()) {
                if (error.getKind() == Diagnostic.Kind.ERROR) throw new AssertionError(error);
            }
            for (var unit : units) new TreePathScanner<Void, String>() {
                @Override public Void visitClass(ClassTree node, String ignored) {
                    return super.visitClass(node, node.getSimpleName().toString());
                }

                @Override public Void visitMethod(MethodTree method, String owner) {
                    String name = method.getName().toString();
                    if (!METHODS.getOrDefault(owner, Set.of()).contains(name)) return null;
                    var symbol = (ExecutableElement) trees.getElement(getCurrentPath());
                    String id = owner + "." + symbol;
                    covered.add(owner + "." + name);
                    List<String> bindings = new ArrayList<>();
                    new TreePathScanner<Void, Void>() {
                        private void bind() {
                            var target = trees.getElement(getCurrentPath());
                            if (!(target instanceof ExecutableElement fn)) throw new AssertionError("unresolved " + getCurrentPath());
                            bindings.add(fn.getEnclosingElement() + "#" + fn + ":" + fn.asType());
                        }

                        private void record(String code, String value) {
                            String label = id + "/" + code + "/" + bindings.size();
                            if (rows.put(label, value) != null) throw new AssertionError(label);
                        }

                        @Override public Void visitMemberReference(MemberReferenceTree node, Void unused) {
                            bind();
                            return super.visitMemberReference(node, unused);
                        }

                        @Override public Void visitNewClass(NewClassTree node, Void unused) {
                            bind();
                            return super.visitNewClass(node, unused);
                        }

                        @Override public Void visitMethodInvocation(MethodInvocationTree call, Void unused) {
                            bind();
                            String select = call.getMethodSelect().toString();
                            var args = call.getArguments();
                            if (owner.equals("Assembler") && (select.equals("node") || select.equals("leaf"))
                                    && !args.isEmpty() && args.get(0) instanceof LiteralTree tag
                                    && tag.getValue() instanceof String t && t.startsWith("dependent-")) {
                                record("writer", flatten(call));
                            } else if (owner.equals("SemanticReplay") && select.endsWith(".requireShape")) {
                                record("replay-shape", flatten(call));
                            } else if (owner.equals("SemanticReplay") && (select.endsWith(".scalar") || select.endsWith(".child"))) {
                                record("replay-field", flatten(call) + " => " + flatten(getCurrentPath().getParentPath().getLeaf()));
                            }
                            return super.visitMethodInvocation(call, unused);
                        }
                    }.scan(getCurrentPath(), null);
                    String hash = sha256(method + "\n" + String.join("\n", bindings));
                    if (rows.put(id + "/method", hash) != null) throw new AssertionError("ambiguous method " + id);
                    return null;
                }
            }.scan(unit, "");
        }
        for (var owner : METHODS.entrySet()) for (String method : owner.getValue()) {
            if (!covered.contains(owner.getKey() + "." + method)) throw new AssertionError("unresolved " + owner.getKey() + "." + method);
        }
        return rows.entrySet().stream().map(row -> row.getKey() + "\t" + row.getValue()).toList();
    }

    private static String flatten(Object node) {
        return node.toString().replaceAll("\\s+", " ").trim();
    }

    private static String sha256(String body) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(body.getBytes(StandardCharsets.UTF_8)));
        } catch (java.security.NoSuchAlgorithmException impossible) {
            throw new AssertionError(impossible);
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("SOURCE REGISTERED_LAYOUT_TSV");
        System.out.println("A225SourceContract passed: " + check(Path.of(args[0]), Path.of(args[1]))
                + " method and field observations");
    }

    static int check(Path root, Path expected) throws Exception {
        List<String> result = capture(root);
        if (!result.equals(Files.readAllLines(expected, StandardCharsets.UTF_8)))
            throw new AssertionError("candidate compiler-resolved dependent wire layout differs");
        return result.size();
    }
}
