import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Collectors;
import javax.lang.model.element.*;
import javax.tools.*;

/** Compiler-resolved, deliberately closed constructor/getter grammar for P2-02. */
public final class PolicyRepresentationExtractor {
    private static final String OWNER = "is.fivefivefive.CanDis.core.AlloyOperatorPolicy";
    private static final List<String> NAMES = List.of(
            "arityPolicy", "siblingQuotient", "flatLicense", "unitLicense");
    private static final List<String> TYPES = List.of(
            "ArityPolicy", "SiblingQuotient", "FlatLicense", "UnitLicense");

    private static void require(boolean value, String message) {
        if (!value) throw new IllegalArgumentException(message);
    }

    private static boolean ownField(ExpressionTree expression) {
        return expression instanceof IdentifierTree
                || expression instanceof MemberSelectTree member
                && member.getExpression() instanceof IdentifierTree receiver
                && receiver.getName().contentEquals("this");
    }

    public static void main(String[] args) throws Exception {
        require(args.length == 2, "Usage: PolicyRepresentationExtractor ROOT OUTPUT.tsv");
        Path root = Path.of(args[0]).toAbsolutePath().normalize();
        Path source = root.resolve("src/" + OWNER.replace('.', '/') + ".java");
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "A full JDK is required");
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            List<Path> jars;
            try (var stream = Files.list(root.resolve("lib"))) {
                jars = stream.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
            }
            JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                    List.of("--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8",
                            "-sourcepath", root.resolve("src").toString(), "-classpath",
                            jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                    null, fm.getJavaFileObjectsFromPaths(List.of(source)));
            CompilationUnitTree unit = task.parse().iterator().next();
            task.analyze();
            for (var d : diagnostics.getDiagnostics()) {
                require(d.getKind() != Diagnostic.Kind.ERROR, d.toString());
            }
            Trees trees = Trees.instance(task);
            ClassTree clazz = (ClassTree) unit.getTypeDecls().get(0);
            require(trees.getElement(TreePath.getPath(unit, clazz)).toString().equals(OWNER), "Wrong owner");
            require(clazz.getModifiers().getFlags().equals(Set.of(Modifier.PUBLIC, Modifier.FINAL)),
                    "Policy must be a final public class");
            Map<String, VariableElement> fields = new HashMap<>();
            Map<String, MethodTree> methods = new HashMap<>();
            for (Tree member : clazz.getMembers()) {
                if (member instanceof VariableTree field) {
                    String name = field.getName().toString();
                    int i = NAMES.indexOf(name);
                    require(i >= 0 && field.getInitializer() == null, "Unknown/initialized field: " + name);
                    require(field.getModifiers().getFlags().equals(Set.of(Modifier.PRIVATE, Modifier.FINAL)),
                            "Field is not independently immutable: " + name);
                    VariableElement symbol = (VariableElement) trees.getElement(TreePath.getPath(unit, field));
                    require(symbol.asType().toString().equals("is.fivefivefive.CanDis.theory." + TYPES.get(i)),
                            "Wrong nominal type: " + name);
                    require(fields.put(name, symbol) == null, "Duplicate field");
                } else if (member instanceof MethodTree method) {
                    String name = method.getName().toString();
                    if (NAMES.contains(name) || name.equals("<init>")) {
                        require(methods.put(name, method) == null, "Ambiguous method: " + name);
                    }
                } else {
                    throw new IllegalArgumentException("Unexpected member: " + member.getKind());
                }
            }
            require(fields.size() == 4 && methods.size() == 5, "Incomplete policy representation");
            MethodTree constructor = methods.get("<init>");
            require(constructor.getModifiers().getFlags().equals(Set.of(Modifier.PRIVATE))
                    && constructor.getParameters().size() == 4 && constructor.getTypeParameters().isEmpty(),
                    "Unexpected constructor signature");
            List<Element> parameters = constructor.getParameters().stream()
                    .map(p -> trees.getElement(TreePath.getPath(unit, p))).toList();
            int[] assignments = {-1, -1, -1, -1};
            for (int i = 0; i < 4; i++) {
                require(parameters.get(i).asType().equals(fields.get(NAMES.get(i)).asType()),
                        "Constructor parameter nominal type mismatch");
            }
            for (StatementTree statement : constructor.getBody().getStatements()) {
                require(statement instanceof ExpressionStatementTree, "Unexpected constructor effect");
                ExpressionTree expression = ((ExpressionStatementTree) statement).getExpression();
                if (expression instanceof MethodInvocationTree call
                        && trees.getElement(TreePath.getPath(unit, call)) instanceof ExecutableElement e
                        && e.getKind() == ElementKind.CONSTRUCTOR
                        && e.getEnclosingElement().toString().equals("java.lang.Object")
                        && call.getArguments().isEmpty()) continue;
                require(expression instanceof AssignmentTree, "Constructor must assign parameters only");
                AssignmentTree assignment = (AssignmentTree) expression;
                require(ownField(assignment.getVariable()), "Assignment is not to this receiver");
                Element field = trees.getElement(TreePath.getPath(unit, assignment.getVariable()));
                int index = NAMES.indexOf(field.getSimpleName().toString());
                require(index >= 0 && fields.get(NAMES.get(index)).equals(field)
                        && assignments[index] < 0, "Foreign or repeated field assignment");
                require(assignment.getExpression() instanceof MethodInvocationTree, "Missing null guard");
                MethodInvocationTree call = (MethodInvocationTree) assignment.getExpression();
                ExecutableElement callee = (ExecutableElement) trees.getElement(TreePath.getPath(unit, call));
                require(call.getMethodSelect() instanceof MemberSelectTree, "Null guard must be type-qualified");
                ExpressionTree qualifier = ((MemberSelectTree) call.getMethodSelect()).getExpression();
                Element qualifierSymbol = trees.getElement(TreePath.getPath(unit, qualifier));
                require(qualifierSymbol instanceof TypeElement
                        && qualifierSymbol.toString().equals("java.util.Objects")
                        && call.getTypeArguments().isEmpty(), "Effectful or unmodeled null-guard qualifier");
                require(callee.getEnclosingElement().toString().equals("java.util.Objects")
                        && callee.getSimpleName().contentEquals("requireNonNull")
                        && call.getArguments().size() == 2
                        && call.getArguments().get(1) instanceof LiteralTree literal
                        && literal.getValue() instanceof String, "Unexpected null-guard call");
                int parameter = parameters.indexOf(trees.getElement(TreePath.getPath(unit, call.getArguments().get(0))));
                require(parameter >= 0, "Assignment is not from a constructor parameter");
                assignments[index] = parameter;
            }
            StringBuilder output = new StringBuilder("field\tnominalType\tconstructorParameter\tgetterField\n");
            for (int index = 0; index < 4; index++) {
                String name = NAMES.get(index);
                MethodTree getter = methods.get(name);
                require(getter.getModifiers().getFlags().equals(Set.of(Modifier.PUBLIC))
                        && getter.getTypeParameters().isEmpty()
                        && getter.getParameters().isEmpty() && getter.getBody().getStatements().size() == 1
                        && getter.getBody().getStatements().get(0) instanceof ReturnTree,
                        "Unexpected getter effects: " + name);
                ReturnTree ret = (ReturnTree) getter.getBody().getStatements().get(0);
                require(ownField(ret.getExpression()), "Getter reads a foreign receiver");
                require(((ExecutableElement) trees.getElement(TreePath.getPath(unit, getter))).getReturnType()
                        .equals(fields.get(name).asType()), "Getter nominal return type mismatch");
                Element returned = trees.getElement(TreePath.getPath(unit, ret.getExpression()));
                require(fields.containsValue(returned), "Getter does not return a stored field");
                int from = NAMES.indexOf(returned.getSimpleName().toString());
                require(assignments[index] >= 0, "Uninitialized field");
                output.append(name).append('\t').append(fields.get(name).asType()).append('\t')
                        .append(assignments[index]).append('\t').append(from).append('\n');
            }
            Files.writeString(Path.of(args[1]), output, StandardCharsets.UTF_8);
        }
    }
}
