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

/** Bounded javac-resolved control extraction, not a Java-to-Lean compiler. */
public final class CallValidationExtractor {
    private static final String IR = "is.fivefivefive.CanDis.ir.IRAgent";
    private static final String VISITOR = "is.fivefivefive.ACGN.visitor.MASGVisitor";
    private static final String ASG = "is.fivefivefive.ACGN.asg.";
    private static final String ALLOY = "is.fivefivefive.ACGN.alloy.";
    private static final String OPCODE = "is.fivefivefive.CanDis.core.EGraphNode.Opcode";
    private CallValidationExtractor() { }

    private static void require(boolean ok, String message) {
        if (!ok) throw new IllegalArgumentException(message);
    }

    // Like JoinGuardExtractor: retain the entire effect/expression grammar;
    // only literal diagnostic text is irrelevant, never its evaluation sites.
    private static List<String> shape(Tree tree) {
        List<String> result = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            @Override public Void visitLambdaExpression(LambdaExpressionTree lambda, Void unused) {
                // analyze() materializes inferred parameter type trees. Their
                // resolved MASGEdge types are checked separately below.
                for (VariableTree parameter : lambda.getParameters()) result.add(parameter.getName().toString());
                scan(lambda.getBody(), unused);
                return null;
            }
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

    private static MethodTree find(CompilationUnitTree unit, String name) {
        List<MethodTree> found = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            @Override public Void visitMethod(MethodTree method, Void unused) {
                if (method.getName().contentEquals(name)) found.add(method);
                return super.visitMethod(method, unused);
            }
        }.scan(unit, null);
        require(found.size() == 1, "Missing/ambiguous method: " + name);
        return found.get(0);
    }

    private static void sameShape(Tree actual, Tree template, String name) {
        List<String> left = shape(actual), right = shape(template);
        for (int i = 0; i < Math.max(left.size(), right.size()); i++) {
            require(i < left.size() && i < right.size() && left.get(i).equals(right.get(i)),
                    "Unmodeled control " + name + " at AST token " + i + ": actual="
                    + left.subList(Math.max(0, i - 4), Math.min(left.size(), i + 4)) + " expected="
                    + right.subList(Math.max(0, i - 4), Math.min(right.size(), i + 4)));
        }
    }

    private static BlockTree expected(JavaCompiler compiler, String body) throws Exception {
        JavaFileObject file = new SimpleJavaFileObject(URI.create("string:///Template.java"), JavaFileObject.Kind.SOURCE) {
            @Override public CharSequence getCharContent(boolean ignored) {
                return "class Template { void control() " + body + " }";
            }
        };
        JavacTask task = (JavacTask) compiler.getTask(null, null, null, List.of("-proc:none"), null, List.of(file));
        return find(task.parse().iterator().next(), "control").getBody();
    }

    private static void resolved(Trees trees, CompilationUnitTree unit, Tree root) {
        Map<String, String> nominal = Map.ofEntries(
                Map.entry("List", "java.util.List"), Map.entry("ArrayList", "java.util.ArrayList"),
                Map.entry("Integer", "java.lang.Integer"), Map.entry("IllegalStateException", "java.lang.IllegalStateException"),
                Map.entry("CallSymbol", ALLOY + "CallSymbol"), Map.entry("Symbol", ALLOY + "Symbol"),
                Map.entry("MASGEdge", ASG + "MASGEdge"), Map.entry("AugmentedNode", ASG + "AugmentedNode"),
                Map.entry("Multigraph", ASG + "Multigraph"), Map.entry("Opcode", OPCODE));
        Set<String> callees = Set.of(IR, "java.util.Map", "java.util.List", "java.lang.Integer",
                ASG + "Multigraph", ASG + "AugmentedNode", ASG + "MASGEdge", ALLOY + "CallSymbol", ALLOY + "Symbol");
        new TreeScanner<Void, Void>() {
            private Element element(Tree tree) { return trees.getElement(TreePath.getPath(unit, tree)); }
            @Override public Void visitLambdaExpression(LambdaExpressionTree lambda, Void unused) {
                for (VariableTree parameter : lambda.getParameters()) {
                    Element e = element(parameter);
                    require(e instanceof VariableElement && e.asType().toString().equals(ASG + "MASGEdge")
                            && parameter.getModifiers().getFlags().isEmpty()
                            && parameter.getModifiers().getAnnotations().isEmpty()
                            && parameter.getInitializer() == null, "Unmodeled comparator parameter");
                }
                return super.visitLambdaExpression(lambda, unused);
            }
            @Override public Void visitIdentifier(IdentifierTree id, Void unused) {
                String name = id.getName().toString();
                if (nominal.containsKey(name)) {
                    Element e = element(id);
                    require(e instanceof TypeElement && e.toString().equals(nominal.get(name)), "Shadowed nominal type: " + name);
                }
                return super.visitIdentifier(id, unused);
            }
            @Override public Void visitMemberSelect(MemberSelectTree member, Void unused) {
                if (member.getIdentifier().contentEquals("CALL")) {
                    Element e = element(member), qualifier = element(member.getExpression());
                    require(e != null && e.getKind() == ElementKind.ENUM_CONSTANT
                            && e.getEnclosingElement().toString().equals(OPCODE)
                            && qualifier instanceof TypeElement && qualifier.toString().equals(OPCODE), "Foreign CALL enum");
                }
                return super.visitMemberSelect(member, unused);
            }
            @Override public Void visitMethodInvocation(MethodInvocationTree call, Void unused) {
                Element e = element(call);
                require(e instanceof ExecutableElement && callees.contains(e.getEnclosingElement().toString()),
                        "Unregistered resolved callee: " + e);
                return super.visitMethodInvocation(call, unused);
            }
            @Override public Void visitNewClass(NewClassTree allocation, Void unused) {
                Element e = element(allocation);
                require(e instanceof ExecutableElement && Set.of("java.util.ArrayList", "java.lang.IllegalStateException")
                        .contains(e.getEnclosingElement().toString()), "Unregistered constructor: " + e);
                return super.visitNewClass(allocation, unused);
            }
        }.scan(root, null);
    }

    public static void main(String[] args) throws Exception {
        require(args.length == 2, "Usage: CallValidationExtractor ROOT OUTPUT.tsv");
        Path root = Path.of(args[0]).toAbsolutePath().normalize();
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "Full JDK required");
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            List<Path> jars, sources;
            try (var paths = Files.list(root.resolve("lib"))) {
                jars = paths.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
            }
            try (var paths = Files.walk(root.resolve("src"))) {
                sources = paths.filter(p -> p.toString().endsWith(".java")).sorted().toList();
            }
            JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                    List.of("--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8",
                            "-sourcepath", root.resolve("src").toString(), "-classpath",
                            jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                    null, fm.getJavaFileObjectsFromPaths(sources));
            List<CompilationUnitTree> units = new ArrayList<>();
            task.parse().forEach(units::add);
            task.analyze();
            for (var d : diagnostics.getDiagnostics()) require(d.getKind() != Diagnostic.Kind.ERROR, d.toString());
            Trees trees = Trees.instance(task);
            StringBuilder output = new StringBuilder("control\towner\tmethod\tstart\tendOffset\tstep\n");
            for (String control : List.of("call-early-return", "ir-argument-validation", "masg-argument-validation")) {
                boolean dispatch = control.equals("call-early-return");
                boolean producer = control.equals("masg-argument-validation");
                String owner = producer ? VISITOR : IR;
                String name = dispatch ? "downlinksFor" : producer ? "validateCompletedCallVisit" : "validateCallDownlinks";
                Path path = root.resolve("src/" + owner.replace('.', '/') + ".java");
                CompilationUnitTree unit = units.stream().filter(u -> Path.of(u.getSourceFile().toUri()).equals(path))
                        .findFirst().orElseThrow();
                MethodTree method = find(unit, name);
                Element symbol = trees.getElement(TreePath.getPath(unit, method));
                require(symbol instanceof ExecutableElement && symbol.getEnclosingElement() instanceof TypeElement
                        && ((TypeElement) symbol.getEnclosingElement()).getQualifiedName().contentEquals(owner), "Foreign method owner");
                ExecutableElement executable = (ExecutableElement) symbol;
                List<String> parameterTypes = executable.getParameters().stream().map(p -> p.asType().toString()).toList();
                require(parameterTypes.equals(dispatch ? List.of(ASG + "AugmentedNode", "int", OPCODE)
                        : producer ? List.of(ASG + "AugmentedNode", ALLOY + "CallSymbol", ASG + "Multigraph", "int")
                        : List.of(ASG + "AugmentedNode", "int", "java.util.List<" + ASG + "MASGEdge>")), "Changed control signature");
                require(executable.getModifiers().equals(dispatch ? Set.of(Modifier.PRIVATE)
                        : Set.of(Modifier.PRIVATE, Modifier.STATIC)), "Changed dispatch/effect modifiers");
                BlockTree template = expected(compiler, dispatch ? DISPATCH : producer ? PRODUCER : VALIDATOR);
                if (dispatch) {
                    List<? extends StatementTree> actual = method.getBody().getStatements();
                    require(actual.size() > 4 && template.getStatements().size() == 4, "Missing CALL prefix or fallback suffix");
                    for (int i = 0; i < 4; i++) {
                        sameShape(actual.get(i), template.getStatements().get(i), "CALL early-return prefix");
                        resolved(trees, unit, actual.get(i));
                    }
                } else {
                    sameShape(method.getBody(), template, name);
                    resolved(trees, unit, method.getBody());
                }
                output.append(control).append('\t').append(owner).append('\t').append(name)
                        .append(dispatch ? "\t0\t0\t0\n" : producer ? "\t2\t0\t1\n" : "\t1\t1\t1\n");
            }
            Files.writeString(Path.of(args[1]), output, StandardCharsets.UTF_8);
        }
    }

    private static final String DISPATCH = """
        {
            int maxTov = graph.getTimeOfVisitMap().getOrDefault(node, tov);
            if (tov > maxTov) {
                if (opcode == Opcode.CALL) {
                    throw new IllegalStateException("diagnostic" + requireCallSymbol(node) + "@" + tov);
                }
                return null;
            }
            List<MASGEdge> downlinks = node.getDownlinksAtTimeOfVisit(graph, tov);
            if (opcode == Opcode.CALL) { return validateCallDownlinks(node, tov, downlinks); }
        }
        """;

    private static final String VALIDATOR = """
        {
            CallSymbol call = requireCallSymbol(node);
            int expected = call.getDeclaredArity() + 2;
            if (downlinks == null || downlinks.size() != expected) {
                throw new IllegalStateException("diagnostic" + call + "@" + tov
                    + ": expected " + expected + " downlinks, found " + (downlinks == null ? 0 : downlinks.size()));
            }
            List<MASGEdge> ordered = new ArrayList<>(downlinks);
            ordered.sort((left, right) -> Integer.compare(left.getPosition(), right.getPosition()));
            for (int index = 0; index < ordered.size(); index++) {
                MASGEdge edge = ordered.get(index);
                if (edge.getPosition() != index + 1 || edge.getTimeOfVisit() != tov || edge.getSource() != node) {
                    throw new IllegalStateException("diagnostic" + call + "@" + tov);
                }
            }
            Symbol callee = ordered.get(0).getTarget().getSymbol();
            if (!call.matchesTarget(callee)) { throw new IllegalStateException("diagnostic" + call + "@" + tov); }
            for (int index = 1; index < expected - 1; index++) {
                Symbol argument = ordered.get(index).getTarget().getSymbol();
                if (argument != null && argument.isEndSymbol()) {
                    throw new IllegalStateException("diagnostic" + call + "@" + tov);
                }
            }
            Symbol terminator = ordered.get(expected - 1).getTarget().getSymbol();
            if (terminator == null || !terminator.isEndSymbol()) {
                throw new IllegalStateException("diagnostic" + call + "@" + tov);
            }
            return ordered;
        }
        """;

    private static final String PRODUCER = """
        {
            List<MASGEdge> edges = callNode.getDownlinksAtTimeOfVisit(graph, callTov);
            int expected = callSymbol.getDeclaredArity() + 2;
            if (edges == null || edges.size() != expected) {
                throw new IllegalStateException("diagnostic" + callSymbol + "@" + callTov
                    + ": expected " + expected + " downlinks, found " + (edges == null ? 0 : edges.size()));
            }
            MASGEdge[] byPosition = new MASGEdge[expected + 1];
            for (MASGEdge edge : edges) {
                int position = edge.getPosition();
                if (edge.getTimeOfVisit() != callTov || edge.getSource() != callNode
                    || position < 1 || position > expected || byPosition[position] != null) {
                    throw new IllegalStateException("diagnostic" + callSymbol + "@" + callTov);
                }
                byPosition[position] = edge;
            }
            Symbol callee = byPosition[1].getTarget().getSymbol();
            if (!callSymbol.matchesTarget(callee)) { throw new IllegalStateException("diagnostic" + callSymbol + "@" + callTov); }
            for (int position = 2; position < expected; position++) {
                Symbol argument = byPosition[position].getTarget().getSymbol();
                if (argument != null && argument.isEndSymbol()) {
                    throw new IllegalStateException("diagnostic" + callSymbol);
                }
            }
            Symbol terminator = byPosition[expected].getTarget().getSymbol();
            if (terminator == null || !terminator.isEndSymbol()) {
                throw new IllegalStateException("diagnostic" + callSymbol + "@" + callTov);
            }
        }
        """;
}
