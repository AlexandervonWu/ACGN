import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Collectors;
import javax.lang.model.element.*;
import javax.tools.*;

/** Closed Java source grammar for the P2-06 type guard and shared substitution. */
public final class FlatTypeSubstitutionExtractor {
    private static final String PACKAGE = "is.fivefivefive.CanDis.theory.";

    private static void require(boolean condition, String message) {
        if (!condition) throw new IllegalArgumentException(message);
    }

    public static void main(String[] args) throws Exception {
        require(args.length == 2, "Usage: FlatTypeSubstitutionExtractor ROOT OUTPUT.tsv");
        Path root = Path.of(args[0]).toAbsolutePath().normalize();
        // Includes the exact One(outputType) equality guard and constructor dominance.
        Path rootTrace = Files.createTempFile("flat-root-", ".tsv");
        try { FlatRootPortExtractor.main(new String[] {root.toString(), rootTrace.toString()}); }
        finally { Files.deleteIfExists(rootTrace); }
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            List<Path> sources, jars;
            try (var files = Files.walk(root.resolve("src"))) {
                sources = files.filter(p -> p.toString().endsWith(".java")).sorted().toList();
            }
            try (var files = Files.list(root.resolve("lib"))) {
                jars = files.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
            }
            JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                    List.of("--release", "17", "-proc:none", "-encoding", "UTF-8", "-classpath",
                            jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                    null, fm.getJavaFileObjectsFromPaths(sources));
            Map<String, CompilationUnitTree> units = new TreeMap<>();
            for (CompilationUnitTree unit : task.parse()) {
                String filename = Path.of(unit.getSourceFile().toUri()).getFileName().toString();
                String qualified = unit.getPackageName() + "." + filename.replace(".java", "");
                require(units.put(qualified, unit) == null, "Ambiguous source unit");
            }
            Map<String, String> bodies = new LinkedHashMap<>();
            bodies.put("OperatorDeclaration#elementSchema", """
                {
                  if (schema instanceof SeqPortSchema) { return ((SeqPortSchema) schema).elementSchema(); }
                  if (schema instanceof BagPortSchema) { return ((BagPortSchema) schema).elementSchema(); }
                  if (schema instanceof SetPortSchema) { return ((SetPortSchema) schema).elementSchema(); }
                  throw new IllegalArgumentException("diagnostic" + schema);
                }
                """);
            bodies.put("InstantiatedOperator#<init>", """
                {
                  this.declaration = Objects.requireNonNull(declaration, "declaration");
                  this.typeArguments = Collections.unmodifiableMap(new LinkedHashMap<>(typeArguments));
                  List<PortSchema> schemas = new ArrayList<>(declaration.portSchemas().size());
                  for (PortSchema schema : declaration.portSchemas()) {
                    schemas.add(schema.substitute(this.typeArguments));
                  }
                  this.portSchemas = Collections.unmodifiableList(schemas);
                  this.outputType = declaration.outputType().substitute(this.typeArguments);
                }
                """);
            bodies.put("OnePortSchema#substitute", "{ return new OnePortSchema(type.substitute(substitution)); }");
            bodies.put("OnePortSchema#type", "{ return type; }");
            bodies.put("SeqPortSchema#substitute", """
                {
                  if (isDependent()) {
                    return dependent(positionalElementSchemas.stream()
                        .map(schema -> schema.substitute(substitution)).toList());
                  }
                  return new SeqPortSchema(arityPolicy, elementSchema.substitute(substitution));
                }
                """);
            bodies.put("SeqPortSchema#elementSchema", """
                {
                  if (isDependent()) { throw new IllegalStateException("diagnostic"); }
                  return elementSchema;
                }
                """);
            for (String kind : List.of("Bag", "Set")) {
                bodies.put(kind + "PortSchema#substitute", "{ return new " + kind
                        + "PortSchema(arityPolicy, elementSchema.substitute(substitution)); }");
                bodies.put(kind + "PortSchema#elementSchema", "{ return elementSchema; }");
            }
            Map<String, MethodTree> methods = new LinkedHashMap<>();
            for (var entry : bodies.entrySet()) {
                String[] key = entry.getKey().split("#");
                MethodTree method = JoinGuardExtractor.find(units.get(PACKAGE + key[0]), key[1]);
                require(JoinGuardExtractor.shape(method.getBody()).equals(JoinGuardExtractor.shape(
                        JoinGuardExtractor.expected(compiler, entry.getValue()))), "Unmodeled type effect: " + entry.getKey());
                methods.put(entry.getKey(), method);
            }
            task.analyze();
            for (var diagnostic : diagnostics.getDiagnostics())
                require(diagnostic.getKind() != Diagnostic.Kind.ERROR, diagnostic.toString());
            Trees trees = Trees.instance(task);
            Set<String> allowed = new HashSet<>(List.of("java.util.Objects", "java.util.Collections",
                    "java.util.List", "java.util.Collection", "java.util.stream.Stream"));
            for (String name : List.of("OperatorDeclaration", "InstantiatedOperator", "GraphType",
                    "PortSchema", "OnePortSchema", "SeqPortSchema", "BagPortSchema", "SetPortSchema"))
                allowed.add(PACKAGE + name);
            Map<String, String> nominal = new HashMap<>();
            for (String name : allowed) nominal.put(name.substring(name.lastIndexOf('.') + 1), name);
            nominal.put("ArrayList", "java.util.ArrayList");
            nominal.put("LinkedHashMap", "java.util.LinkedHashMap");
            for (var entry : methods.entrySet()) {
                String owner = PACKAGE + entry.getKey().split("#")[0];
                CompilationUnitTree unit = units.get(owner);
                ClassTree clazz = (ClassTree) unit.getTypeDecls().get(0);
                require(clazz.getModifiers().getFlags().contains(Modifier.FINAL), "Extensible exact type owner");
                for (Tree member : clazz.getMembers()) {
                    if (member instanceof VariableTree field) {
                        require(field.getModifiers().getFlags().equals(Set.of(Modifier.PRIVATE, Modifier.FINAL)),
                                "Exact type state must be private final per-instance storage: " + field.getName());
                    }
                }
                require(trees.getElement(TreePath.getPath(unit, entry.getValue())).getEnclosingElement()
                        .toString().equals(owner), "Foreign type method");
                new TreeScanner<Void, Void>() {
                    @Override public Void visitIdentifier(IdentifierTree id, Void unused) {
                        if (nominal.containsKey(id.getName().toString())) {
                            Element symbol = trees.getElement(TreePath.getPath(unit, id));
                            require(symbol instanceof TypeElement && symbol.toString().equals(
                                    nominal.get(id.getName().toString())), "Shadowed nominal type: " + id);
                        }
                        return super.visitIdentifier(id, unused);
                    }
                    @Override public Void visitMethodInvocation(MethodInvocationTree call, Void unused) {
                        Element symbol = trees.getElement(TreePath.getPath(unit, call));
                        // javac's implicit super() is outside the modeled constructor body.
                        if (call.getMethodSelect().toString().equals("super")) return null;
                        require(symbol instanceof ExecutableElement && allowed.contains(
                                symbol.getEnclosingElement().toString()), "Foreign type callee: " + symbol);
                        return super.visitMethodInvocation(call, unused);
                    }
                }.scan(entry.getValue().getBody(), null);
            }
            MethodTree constructor = methods.get("InstantiatedOperator#<init>");
            List<String> substitutionFields = new ArrayList<>();
            new TreeScanner<Void, Void>() {
                @Override public Void visitMethodInvocation(MethodInvocationTree call, Void unused) {
                    if (call.getMethodSelect() instanceof MemberSelectTree method
                            && method.getIdentifier().contentEquals("substitute")) {
                        ExpressionTree argument = call.getArguments().get(0);
                        Element field = trees.getElement(TreePath.getPath(units.get(PACKAGE + "InstantiatedOperator"), argument));
                        require(field.getKind() == ElementKind.FIELD
                                && field.getEnclosingElement().toString().equals(PACKAGE + "InstantiatedOperator"),
                                "Substitution must come from the captured instantiation");
                        substitutionFields.add(field.getSimpleName().toString());
                    }
                    return super.visitMethodInvocation(call, unused);
                }
            }.scan(constructor.getBody(), null);
            require(substitutionFields.size() == 2, "Missing substitution site");
            Files.writeString(Path.of(args[1]), "elementSubstitution\tresultSubstitution\tcheckedMethods\n"
                    + String.join("\t", substitutionFields) + "\t" + methods.size() + "\n", StandardCharsets.UTF_8);
        }
    }
}
