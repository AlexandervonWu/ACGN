import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Collectors;
import javax.lang.model.element.*;
import javax.tools.*;

/** P2-05 source-local admission check; it does not certify type substitution. */
public final class FlatRootPortExtractor {
    private static void require(boolean ok, String message) {
        if (!ok) throw new IllegalArgumentException(message);
    }

    public static void main(String[] args) throws Exception {
        require(args.length == 2, "Usage: FlatRootPortExtractor ROOT OUTPUT.tsv");
        Path root = Path.of(args[0]).toAbsolutePath().normalize();
        Path source = root.resolve("src/is/fivefivefive/CanDis/theory/OperatorDeclaration.java");
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            List<Path> sources, jars;
            try (var paths = Files.walk(root.resolve("src"))) {
                sources = paths.filter(p -> p.toString().endsWith(".java")).sorted().toList();
            }
            try (var paths = Files.list(root.resolve("lib"))) {
                jars = paths.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
            }
            JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                    List.of("--release", "17", "-proc:none", "-encoding", "UTF-8", "-classpath",
                            jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                    null, fm.getJavaFileObjectsFromPaths(sources));
            List<CompilationUnitTree> units = new ArrayList<>();
            task.parse().forEach(units::add);
            CompilationUnitTree unit = units.stream().filter(u -> Path.of(u.getSourceFile().toUri()).equals(source))
                    .findFirst().orElseThrow();
            // Preserve the explicit constructor before javac inserts Object.super().
            MethodTree constructor = JoinGuardExtractor.find(unit, "<init>");
            List<String> constructorShape = JoinGuardExtractor.shape(constructor.getBody());
            task.analyze();
            for (var d : diagnostics.getDiagnostics()) require(d.getKind() != Diagnostic.Kind.ERROR, d.toString());
            MethodTree method = JoinGuardExtractor.find(unit, "validateFlatPort");
            List<BinaryTree> tests = new ArrayList<>();
            new TreeScanner<Void, Void>() {
                @Override public Void visitBinary(BinaryTree tree, Void unused) {
                    if (tree.getKind() == Tree.Kind.NOT_EQUAL_TO) tests.add(tree);
                    return super.visitBinary(tree, unused);
                }
            }.scan(method, null);
            require(tests.size() == 2, "Missing or ambiguous root guards");
            List<Integer> constants = new ArrayList<>();
            for (BinaryTree comparison : tests) {
                require(comparison.getRightOperand() instanceof LiteralTree literal
                        && literal.getValue() instanceof Integer, "Nonliteral root guard");
                constants.add((Integer) ((LiteralTree) comparison.getRightOperand()).getValue());
            }
            String body = """
                {
                  if (!flatLicense.enabled()) { return; }
                  int flatPortIndex = flatLicense.path().portIndex();
                  if (flatPortIndex < 0 || flatPortIndex >= portSchemas.size()) {
                    throw new IllegalArgumentException("diagnostic");
                  }
                  if (portSchemas.size() != COUNT || flatPortIndex != ROOT) {
                    throw new IllegalArgumentException("diagnostic");
                  }
                  PortSchema schema = portSchemas.get(flatPortIndex);
                  PortSchema element = elementSchema(schema);
                  if (!(element instanceof OnePortSchema) || !((OnePortSchema) element).type().equals(outputType)) {
                    throw new IllegalArgumentException("diagnostic");
                  }
                  if (!containerLaws.get(PortPath.at(flatPortIndex)).associative()) {
                    throw new IllegalArgumentException("diagnostic");
                  }
                  ArityPolicy arities = ContainerLawDeclaration.arityPolicy(schema);
                  arities.requireFlatSpliceClosure("diagnostic");
                  if (arities.admitsZero() && !containerLaws.get(PortPath.at(flatPortIndex)).hasUnit()) {
                    throw new IllegalArgumentException("diagnostic");
                  }
                }
                """;
            require(JoinGuardExtractor.shape(method.getBody()).equals(JoinGuardExtractor.shape(
                    JoinGuardExtractor.expected(compiler, body.replace("COUNT", constants.get(0).toString())
                            .replace("ROOT", constants.get(1).toString())))), "Unmodeled flat admission effect");
            String expectedConstructor = """
                {
                  this.operator = requireName(operator, "operator");
                  this.typeParameters = copyTypeParameters(typeParameters);
                  this.portSchemas = copySchemas(portSchemas);
                  this.outputType = Objects.requireNonNull(outputType, "outputType");
                  this.containerLaws = copyLaws(containerLaws);
                  this.flatLicense = flatPortIndex == null ? FlatLicense.none() : FlatLicense.atRootPort(flatPortIndex);
                  validateTypeVariables();
                  validateContainerLaws();
                  validateFlatPort();
                }
                """;
            require(constructorShape.equals(JoinGuardExtractor.shape(JoinGuardExtractor.expected(compiler,
                    expectedConstructor))), "Flat validation does not dominate constructor return");
            Trees trees = Trees.instance(task);
            String owner = "is.fivefivefive.CanDis.theory.OperatorDeclaration";
            require(trees.getElement(TreePath.getPath(unit, method)).getEnclosingElement().toString().equals(owner),
                    "Unexpected guard owner");
            require(method.getModifiers().getFlags().equals(Set.of(Modifier.PRIVATE)), "Overridable guard");
            Map<String, String> nominalTypes = Map.of(
                    "Objects", "java.util.Objects",
                    "FlatLicense", "is.fivefivefive.CanDis.theory.FlatLicense",
                    "PortPath", "is.fivefivefive.CanDis.theory.PortPath",
                    "ContainerLawDeclaration", "is.fivefivefive.CanDis.theory.ContainerLawDeclaration",
                    "ArityPolicy", "is.fivefivefive.CanDis.theory.ArityPolicy",
                    "OnePortSchema", "is.fivefivefive.CanDis.theory.OnePortSchema",
                    "PortSchema", "is.fivefivefive.CanDis.theory.PortSchema");
            TreeScanner<Void, Void> nominalScan = new TreeScanner<>() {
                @Override public Void visitIdentifier(IdentifierTree id, Void unused) {
                    String expected = nominalTypes.get(id.getName().toString());
                    if (expected != null) {
                        Element element = trees.getElement(TreePath.getPath(unit, id));
                        require(element instanceof TypeElement && element.toString().equals(expected),
                                "Nominal type is shadowed: " + id);
                    }
                    return super.visitIdentifier(id, unused);
                }
            };
            nominalScan.scan(constructor.getBody(), null);
            nominalScan.scan(method.getBody(), null);
            ClassTree clazz = (ClassTree) unit.getTypeDecls().get(0);
            require(clazz.getModifiers().getFlags().contains(Modifier.FINAL), "Extensible declaration");
            for (Tree member : clazz.getMembers()) if (member instanceof VariableTree field) {
                require(field.getModifiers().getFlags().equals(Set.of(Modifier.PRIVATE, Modifier.FINAL)),
                        "Declaration field is not immutable");
            }
            new TreeScanner<Void, Void>() {
                @Override public Void visitMethodInvocation(MethodInvocationTree call, Void unused) {
                    if (call.getMethodSelect() instanceof MemberSelectTree select
                            && (select.getIdentifier().contentEquals("none")
                                || select.getIdentifier().contentEquals("atRootPort"))) {
                        Element qualifier = trees.getElement(TreePath.getPath(unit, select.getExpression()));
                        Element callee = trees.getElement(TreePath.getPath(unit, call));
                        require(qualifier instanceof TypeElement
                                && qualifier.toString().equals("is.fivefivefive.CanDis.theory.FlatLicense")
                                && callee instanceof ExecutableElement
                                && callee.getEnclosingElement().equals(qualifier),
                                "Flat license factory must resolve to its exact type, not a shadow field");
                    }
                    return super.visitMethodInvocation(call, unused);
                }
            }.scan(constructor.getBody(), null);
            Set<String> allowedOwners = Set.of("java.util.List", "java.util.Map", "java.util.Objects",
                    owner, "is.fivefivefive.CanDis.theory.FlatLicense", "is.fivefivefive.CanDis.theory.PortPath",
                    "is.fivefivefive.CanDis.theory.OnePortSchema", "is.fivefivefive.CanDis.theory.GraphType",
                    "is.fivefivefive.CanDis.theory.ContainerLawDeclaration", "is.fivefivefive.CanDis.theory.ArityPolicy");
            new TreeScanner<Void, Void>() {
                @Override public Void visitMethodInvocation(MethodInvocationTree call, Void unused) {
                    Element callee = trees.getElement(TreePath.getPath(unit, call));
                    require(callee instanceof ExecutableElement && allowedOwners.contains(callee.getEnclosingElement().toString()),
                            "Foreign root-guard callee: " + callee);
                    return super.visitMethodInvocation(call, unused);
                }
                @Override public Void visitInstanceOf(InstanceOfTree test, Void unused) {
                    Element type = trees.getElement(TreePath.getPath(unit, test.getType()));
                    require(type instanceof TypeElement && type.toString().equals("is.fivefivefive.CanDis.theory.OnePortSchema"),
                            "Root element test must name the exact One schema type");
                    return super.visitInstanceOf(test, unused);
                }
            }.scan(method.getBody(), null);
            Files.writeString(Path.of(args[1]), "requiredPortCount\trootPortIndex\n"
                    + constants.get(0) + "\t" + constants.get(1) + "\n", StandardCharsets.UTF_8);
        }
    }
}
