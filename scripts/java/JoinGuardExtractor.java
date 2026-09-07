import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.io.File;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Collectors;
import javax.lang.model.element.*;
import javax.tools.*;

/** Closed AST/effect grammar for the two independent JOIN arity guards. */
public final class JoinGuardExtractor {
    private static void require(boolean ok, String message) {
        if (!ok) throw new IllegalArgumentException(message);
    }

    // Payloads of diagnostic strings are irrelevant; their expression positions are not.
    static List<String> shape(Tree tree) {
        List<String> result = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            @Override public Void scan(Tree node, Void unused) {
                if (node == null) { result.add("null"); return null; }
                result.add("(" + node.getKind());
                if (node instanceof IdentifierTree x) result.add(x.getName().toString());
                if (node instanceof MemberSelectTree x) result.add(x.getIdentifier().toString());
                if (node instanceof VariableTree x) result.add(x.getName().toString());
                if (node instanceof LiteralTree x) result.add(x.getValue() instanceof String
                        ? "diagnostic-string" : String.valueOf(x.getValue()));
                super.scan(node, unused);
                result.add(")");
                return null;
            }
        }.scan(tree, null);
        return result;
    }

    static MethodTree find(CompilationUnitTree unit, String name) {
        List<MethodTree> methods = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            @Override public Void visitMethod(MethodTree node, Void unused) {
                if (node.getName().contentEquals(name)) methods.add(node);
                return super.visitMethod(node, unused);
            }
        }.scan(unit, null);
        require(methods.size() == 1, "Ambiguous/missing guard: " + name);
        return methods.get(0);
    }

    static BlockTree expected(JavaCompiler compiler, String body) throws Exception {
        JavaFileObject file = new SimpleJavaFileObject(URI.create("string:///Template.java"), JavaFileObject.Kind.SOURCE) {
            @Override public CharSequence getCharContent(boolean ignored) {
                return "class Template { void guard() " + body + " }";
            }
        };
        JavacTask task = (JavacTask) compiler.getTask(null, null, null, List.of("-proc:none"), null, List.of(file));
        return find(task.parse().iterator().next(), "guard").getBody();
    }

    private static int threshold(MethodTree method) {
        List<BinaryTree> comparisons = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            @Override public Void visitBinary(BinaryTree node, Void unused) {
                if (node.getKind() == Tree.Kind.LESS_THAN
                        && (node.getLeftOperand() instanceof IdentifierTree id && id.getName().contentEquals("arity")
                        || node.getLeftOperand() instanceof MethodInvocationTree call
                        && call.getMethodSelect() instanceof MemberSelectTree member
                        && member.getIdentifier().contentEquals("relationArity"))) comparisons.add(node);
                return super.visitBinary(node, unused);
            }
        }.scan(method, null);
        require(comparisons.size() == 1, "Missing or ambiguous interior comparison");
        require(comparisons.get(0).getRightOperand() instanceof LiteralTree, "Nonliteral threshold");
        Object value = ((LiteralTree) comparisons.get(0).getRightOperand()).getValue();
        require(value instanceof Integer && (Integer) value >= 0, "Unsupported threshold");
        return (Integer) value;
    }

    public static void main(String[] args) throws Exception {
        require(args.length == 2, "Usage: JoinGuardExtractor ROOT OUTPUT.tsv");
        Path root = Path.of(args[0]).toAbsolutePath().normalize();
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "Full JDK required");
        StringBuilder output = new StringBuilder("guard\tminimumInteriorArity\tstart\tendOffset\n");
        for (boolean producer : new boolean[] {true, false}) {
            String owner = producer ? "is.fivefivefive.CanDis.theory.DependentChainTheory"
                    : "org.acgn.cert.SemanticEvidenceVerifier";
            String name = producer ? "requireSoundFlattening" : "requireSoundDependentFlattening";
            Path base = root.resolve(producer ? "src" : "certificate-verifier/src");
            Path source = base.resolve(owner.replace('.', '/') + ".java");
            DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
            try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
                List<Path> jars;
                try (var paths = Files.list(root.resolve("lib"))) {
                    jars = paths.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
                }
                List<Path> sources;
                try (var paths = Files.walk(base)) {
                    sources = paths.filter(p -> p.toString().endsWith(".java")).sorted().toList();
                }
                JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                        List.of("--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8",
                                "-sourcepath", base.toString(), "-classpath",
                                jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                        null, fm.getJavaFileObjectsFromPaths(sources));
                List<CompilationUnitTree> units = new ArrayList<>();
                task.parse().forEach(units::add);
                CompilationUnitTree unit = units.stream().filter(u -> Path.of(u.getSourceFile().toUri()).equals(source))
                        .findFirst().orElseThrow();
                task.analyze();
                for (var d : diagnostics.getDiagnostics()) require(d.getKind() != Diagnostic.Kind.ERROR, d.toString());
                Trees trees = Trees.instance(task);
                MethodTree method = find(unit, name);
                Element symbol = trees.getElement(TreePath.getPath(unit, method));
                require(symbol.getEnclosingElement().toString().startsWith(owner), "Foreign guard owner");
                int minimum = threshold(method);
                String body = producer ? """
                    {
                      Objects.requireNonNull(kind, "kind");
                      Objects.requireNonNull(operandTypes, "operandTypes");
                      if (operandTypes.size() < 2) { throw new IllegalArgumentException("diagnostic"); }
                      for (GraphType operand : operandTypes) {
                        GraphType checked = Objects.requireNonNull(operand, "operand type");
                        if (!AlloyTypeBridge.isRelationFamily(checked)) { throw new IllegalArgumentException("diagnostic"); }
                      }
                      if (kind == DependentChainKind.JOIN && operandTypes.size() > 2) {
                        for (int index = 1; index + 1 < operandTypes.size(); index++) {
                          if (AlloyTypeBridge.relationArity(operandTypes.get(index)) < MINIMUM) {
                            throw new UnsupportedFlattening("diagnostic");
                          }
                        }
                      }
                    }
                    """ : """
                    {
                      if (operandTypes.size() < 2) { throw theory("diagnostic"); }
                      if (kind == ChainKind.JOIN && operandTypes.size() > 2) {
                        for (int index = 1; index + 1 < operandTypes.size(); index++) {
                          ExactType interior = operandTypes.get(index);
                          Integer arity = relationArity(interior);
                          if (arity == null || arity < MINIMUM) { throw theory("diagnostic"); }
                        }
                      }
                    }
                    """;
                require(shape(method.getBody()).equals(shape(expected(compiler,
                        body.replace("MINIMUM", Integer.toString(minimum))))), "Unmodeled guard structure/effect");
                Set<String> allowed = producer ? Set.of("java.util.Objects", "java.util.List",
                        "is.fivefivefive.CanDis.theory.AlloyTypeBridge")
                        : Set.of("java.util.List", "org.acgn.cert.SemanticEvidenceVerifier",
                                "org.acgn.cert.SemanticEvidenceVerifier.SemanticReplay");
                new TreeScanner<Void, Void>() {
                    @Override public Void visitIdentifier(IdentifierTree id, Void unused) {
                        String name = id.getName().toString();
                        Map<String, String> names = producer ? Map.of(
                                "Objects", "java.util.Objects",
                                "GraphType", "is.fivefivefive.CanDis.theory.GraphType",
                                "DependentChainKind", "is.fivefivefive.CanDis.theory.DependentChainKind",
                                "AlloyTypeBridge", "is.fivefivefive.CanDis.theory.AlloyTypeBridge")
                                : Map.of("Integer", "java.lang.Integer",
                                    "ExactType", "org.acgn.cert.SemanticEvidenceVerifier.ExactType",
                                    "ChainKind", "org.acgn.cert.SemanticEvidenceVerifier.SemanticReplay.ChainKind");
                        if (names.containsKey(name)) {
                            Element element = trees.getElement(TreePath.getPath(unit, id));
                            require(element instanceof TypeElement && element.toString().equals(names.get(name)),
                                    "Nominal guard type is shadowed: " + name);
                        }
                        return super.visitIdentifier(id, unused);
                    }
                    @Override public Void visitMemberSelect(MemberSelectTree member, Void unused) {
                        if (member.getIdentifier().contentEquals("JOIN")) {
                            Element constant = trees.getElement(TreePath.getPath(unit, member));
                            Element qualifier = trees.getElement(TreePath.getPath(unit, member.getExpression()));
                            String enumOwner = producer ? "is.fivefivefive.CanDis.theory.DependentChainKind"
                                    : "org.acgn.cert.SemanticEvidenceVerifier.SemanticReplay.ChainKind";
                            require(constant != null && constant.getKind() == ElementKind.ENUM_CONSTANT
                                    && constant.getEnclosingElement().toString().equals(enumOwner)
                                    && qualifier instanceof TypeElement && qualifier.toString().equals(enumOwner),
                                    "JOIN must resolve to the exact chain enum constant");
                        }
                        return super.visitMemberSelect(member, unused);
                    }
                    @Override public Void visitMethodInvocation(MethodInvocationTree call, Void unused) {
                        Element callee = trees.getElement(TreePath.getPath(unit, call));
                        require(callee instanceof ExecutableElement && allowed.contains(callee.getEnclosingElement().toString()),
                                "Unregistered guard callee: " + callee);
                        return super.visitMethodInvocation(call, unused);
                    }
                }.scan(method.getBody(), null);
                output.append(producer ? "producer" : "verifier").append('\t').append(minimum).append("\t1\t1\n");
            }
        }
        Files.writeString(Path.of(args[1]), output, StandardCharsets.UTF_8);
    }
}
