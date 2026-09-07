import com.sun.source.tree.*;
import com.sun.source.util.JavacTask;
import com.sun.source.util.TreePath;
import com.sun.source.util.Trees;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.stream.Collectors;
import javax.lang.model.element.*;
import javax.lang.model.util.Types;
import javax.tools.*;

/**
 * JDK 17 only. ROOT OUTPUT.json writes OUTPUT.json and OUTPUT.lean; no proofs.
 * Trusted bounded AST projection, not a Java interpreter. Callee bodies are not interpreted.
 * Span offsets count UTF-16 code units, start inclusive and end exclusive; lines are 1-based.
 */
public final class SmartConstructionSourceExtractor {
    private static final String P = "is.fivefivefive.CanDis.theory.";
    private static final String OWNER = P + "TypedENode";
    private static final String METHOD = "flatConstructCertified";
    private final Path root;
    private final Trees trees;
    private final Types types;
    private final CompilationUnitTree unit;
    private final Map<Element, String> locals = new HashMap<>();
    private final SortedSet<String> symbols = new TreeSet<>();

    private record N(String kind, List<Object> args) {}
    private static N n(String kind, Object... args) {
        return new N(kind, Arrays.asList(args));
    }
    private static void require(boolean ok, String message) {
        if (!ok) throw new IllegalArgumentException(message);
    }
    private SmartConstructionSourceExtractor(Path root, JavacTask task, CompilationUnitTree unit) {
        this.root = root; this.trees = Trees.instance(task); this.types = task.getTypes(); this.unit = unit;
    }
    private Element element(Tree tree) {
        Element e = trees.getElement(TreePath.getPath(unit, tree));
        require(e != null, "Unresolved symbol: " + tree.getKind());
        return e;
    }
    private String erased(javax.lang.model.type.TypeMirror type) {
        return types.erasure(type).toString();
    }
    private String symbol(Element e) {
        String result;
        TypeElement owner;
        if (e instanceof ExecutableElement m) {
            owner = (TypeElement) m.getEnclosingElement();
            result = owner.getQualifiedName() + "#" + m.getSimpleName() + "(" +
                    m.getParameters().stream().map(p -> erased(p.asType())).collect(Collectors.joining(",")) +
                    "):" + erased(m.getReturnType());
            require(m.getTypeParameters().isEmpty() && !m.isVarArgs(), "Generic/varargs method: " + result);
        } else {
            require(e instanceof TypeElement, "Not a type or callable: " + e);
            owner = (TypeElement) e; result = owner.getQualifiedName().toString();
        }
        if (owner.getQualifiedName().toString().startsWith(P)) {
            TreePath declaration = trees.getPath(owner);
            Path expected = root.resolve("src/" + owner.getQualifiedName().toString().replace('.', '/') + ".java");
            require(declaration != null && Path.of(declaration.getCompilationUnit().getSourceFile().toUri())
                    .toAbsolutePath().normalize().equals(expected), "Not resolved to production source: " + result);
        }
        symbols.add(result);
        return result;
    }
    private String type(Tree tree) {
        require(tree.getKind() == Tree.Kind.IDENTIFIER || tree.getKind() == Tree.Kind.MEMBER_SELECT,
                "Unhandled type: " + tree.getKind());
        return symbol(element(tree));
    }
    private void modifiers(ModifiersTree m, Set<Modifier> expected) {
        require(m.getFlags().equals(expected) && m.getAnnotations().isEmpty(), "Unexpected modifiers/annotations");
    }
    private N variable(VariableTree v, boolean parameter) {
        modifiers(v.getModifiers(), Set.of());
        Element e = element(v);
        require(e.getKind() == (parameter ? ElementKind.PARAMETER : ElementKind.LOCAL_VARIABLE), "Not a local");
        String t = type(v.getType()), name = v.getName().toString();
        N value = parameter ? null : expression(v.getInitializer());
        require(!locals.containsValue(name), "Shadowed local: " + name);
        locals.put(e, name);
        return n("bind", name, t, value);
    }
    private N expression(ExpressionTree tree) {
        require(tree != null, "Missing expression");
        return switch (tree.getKind()) {
            case PARENTHESIZED -> expression(((ParenthesizedTree) tree).getExpression());
            case IDENTIFIER -> {
                String name = locals.get(element(tree));
                require(name != null, "Not a bound parameter/local: " + tree);
                yield n("ref", name);
            }
            case INT_LITERAL -> {
                int value = (Integer) ((LiteralTree) tree).getValue();
                require(value >= 0, "Negative natural"); yield n("nat", value);
            }
            case STRING_LITERAL -> n("text", ((LiteralTree) tree).getValue());
            case CONDITIONAL_AND, CONDITIONAL_OR, EQUAL_TO -> {
                BinaryTree b = (BinaryTree) tree;
                yield n(tree.getKind() == Tree.Kind.CONDITIONAL_AND ? "and" :
                                tree.getKind() == Tree.Kind.CONDITIONAL_OR ? "or" : "eq",
                        expression(b.getLeftOperand()), expression(b.getRightOperand()));
            }
            case LOGICAL_COMPLEMENT -> n("not", expression(((UnaryTree) tree).getExpression()));
            case INSTANCE_OF -> {
                InstanceOfTree i = (InstanceOfTree) tree;
                require(i.getPattern() == null, "Pattern instanceof is not supported");
                String t = type(i.getType());
                require(t.equals(P + "SetPort") || t.equals(P + "OnePort"), "Unexpected instanceof type: " + t);
                yield n(t.equals(P + "SetPort") ? "isSet" : "isOne", expression(i.getExpression()));
            }
            case TYPE_CAST -> {
                TypeCastTree c = (TypeCastTree) tree;
                yield n("cast", type(c.getType()), expression(c.getExpression()));
            }
            case METHOD_INVOCATION -> {
                MethodInvocationTree c = (MethodInvocationTree) tree;
                require(c.getTypeArguments().isEmpty(), "Explicit type arguments");
                Element resolved = element(c);
                require(resolved instanceof ExecutableElement, "Unresolved call");
                String s = symbol(resolved);
                boolean isStatic = resolved.getModifiers().contains(Modifier.STATIC);
                N receiver = null;
                if (c.getMethodSelect() instanceof MemberSelectTree select) {
                    if (isStatic) require(type(select.getExpression()).equals(
                            ((TypeElement) resolved.getEnclosingElement()).getQualifiedName().toString()),
                            "Static call qualifier differs from owner");
                    else receiver = expression(select.getExpression());
                } else require(c.getMethodSelect() instanceof IdentifierTree && isStatic
                        && resolved.getEnclosingElement().toString().equals(OWNER), "Implicit receiver");
                List<N> args = expressions(c.getArguments());
                if (s.equals("java.util.List#size():int")) {
                    require(receiver != null && args.isEmpty(), "Invalid size call");
                    yield n("size", receiver);
                }
                yield n("call", s, receiver, args);
            }
            case NEW_CLASS -> {
                NewClassTree c = (NewClassTree) tree;
                require(c.getClassBody() == null && c.getEnclosingExpression() == null
                        && c.getTypeArguments().isEmpty(), "Extended constructor syntax");
                String t = type(c.getIdentifier());
                Element e = element(c);
                require(e.getKind() == ElementKind.CONSTRUCTOR && e.getEnclosingElement().toString().equals(t),
                        "Constructor owner mismatch");
                yield n("newObject", symbol(e), expressions(c.getArguments()));
            }
            default -> throw new IllegalArgumentException("Unhandled expression: " + tree.getKind());
        };
    }
    private List<N> expressions(List<? extends ExpressionTree> ts) {
        return ts.stream().map(this::expression).toList();
    }
    private List<N> block(StatementTree tree) {
        require(tree instanceof BlockTree && !((BlockTree) tree).isStatic(), "Expected ordinary block");
        return ((BlockTree) tree).getStatements().stream().map(this::statement).toList();
    }
    private N statement(StatementTree tree) {
        return switch (tree.getKind()) {
            case VARIABLE -> variable((VariableTree) tree, false);
            case RETURN -> n("ret", expression(((ReturnTree) tree).getExpression()));
            case THROW -> n("throwValue", expression(((ThrowTree) tree).getExpression()));
            case IF -> {
                IfTree i = (IfTree) tree;
                yield n("branch", expression(i.getCondition()), block(i.getThenStatement()),
                        i.getElseStatement() == null ? List.of() : block(i.getElseStatement()));
            }
            default -> throw new IllegalArgumentException("Unhandled statement: " + tree.getKind());
        };
    }
    private static String sig(String owner, String method, String result, String... params) {
        return P + owner + "#" + method + "(" + String.join(",", params) + "):" + result;
    }
    private static N call(String symbol, N receiver, N... args) { return n("call", symbol, receiver, List.of(args)); }
    private static N ref(String name) { return n("ref", name); }
    private static N access(String owner, String method, String result, N receiver) {
        return call(sig(owner, method, result), receiver);
    }
    // This grammar is an acceptance check only. Both exports below use the parsed tree.
    private static List<N> expectedPlan(N condition, N guard, N whenTrue, N whenFalse) {
        N source = ref("source"), node = ref("node"), container = ref("container"), sole = ref("sole");
        N elements = access("SetPort", "elements", "java.util.List", n("cast", P + "SetPort", container));
        N index = access("PortPath", "portIndex", "int", access("FlatLicense", "path", P + "PortPath",
                access("InstantiatedOperator", "flatLicense", P + "FlatLicense",
                        access("FlatApplication", "operator", P + "InstantiatedOperator", source))));
        return List.of(
                n("bind", "node", OWNER, call(sig("TypedENode", "flattenVisible", OWNER,
                        P + "FlatApplication", P + "NodeSealer"), null, source, ref("sealer"))),
                n("bind", "container", P + "PortValue", call("java.util.List#get(int):java.lang.Object",
                        access("TypedENode", "ports", "java.util.List", node), index)),
                n("branch", condition, List.of(
                        n("bind", "sole", P + "PortValue", call("java.util.List#get(int):java.lang.Object", elements, n("nat", 0))),
                        n("branch", guard, List.of(n("throwValue", n("newObject",
                                "java.lang.IllegalStateException#<init>(java.lang.String):void",
                                List.of(n("text", "A flat singleton must inhabit the declared One element schema"))))), List.of()),
                        n("bind", "singleton", P + "OnePort", n("cast", P + "OnePort", sole)),
                        whenTrue), List.of()), whenFalse);
    }
    private static N expectedReturn(String targetType, String factory, N target, N source, N profile) {
        return n("ret", n("newObject", sig("CertifiedFlatConstruction", "<init>", "void",
                P + targetType, P + "FlatConstructionCertificate"), List.of(target,
                call(sig("FlatConstructionCertificate", factory, P + "FlatConstructionCertificate",
                        P + "FlatApplication", P + targetType, P + "SemanticProfile"), null, source, target, profile))));
    }
    private List<N> extract(MethodTree m) {
        modifiers(m.getModifiers(), Set.of(Modifier.PUBLIC, Modifier.STATIC));
        require(m.getTypeParameters().isEmpty() && m.getThrows().isEmpty() && m.getDefaultValue() == null
                && m.getReceiverParameter() == null && m.getBody() != null, "Unexpected method declaration");
        require(type(m.getReturnType()).equals(P + "CertifiedFlatConstruction"), "Wrong return type");
        require(symbol(element(m)).equals(sig("TypedENode", METHOD, P + "CertifiedFlatConstruction",
                P + "FlatApplication", P + "NodeSealer", P + "SemanticProfile")), "Wrong method signature");
        require(m.getParameters().size() == 3, "Wrong parameter count");
        String[] names = {"source", "sealer", "semanticProfile"};
        String[] ts = {"FlatApplication", "NodeSealer", "SemanticProfile"};
        for (int i = 0; i < 3; i++) require(variable(m.getParameters().get(i), true)
                .equals(n("bind", names[i], P + ts[i], null)), "Wrong parameter at " + i);
        List<N> plan = block(m.getBody());
        require(plan.size() == 4 && plan.get(2).kind.equals("branch"), "Unexpected top-level statements");
        List<?> branch = (List<?>) plan.get(2).args.get(1);
        require(branch.size() == 4 && ((N) branch.get(1)).kind.equals("branch"), "Unexpected singleton statements");
        N condition = (N) plan.get(2).args.get(0), guard = (N) ((N) branch.get(1)).args.get(0);
        predicate(condition, false); predicate(guard, true);
        N whenTrue = (N) branch.get(3), whenFalse = plan.get(3);
        action(whenTrue); action(whenFalse);
        require(plan.equals(expectedPlan(condition, guard, whenTrue, whenFalse)),
                "Method AST differs from supported production grammar: " + json(plan));
        return plan;
    }
    private static String action(N ret) {
        if (ret.equals(expectedReturn("OnePort", "createSingletonProduction", ref("singleton"), ref("source"), ref("semanticProfile")))) return "SINGLETON";
        require(ret.equals(expectedReturn("TypedENode", "createProduction", ref("node"), ref("source"), ref("semanticProfile"))), "Unsupported return/certificate pair");
        return "NODE";
    }
    // Erase receivers only after checking the exact environment slot and collection access.
    private static Map<String, Object> predicate(N expr, boolean guard) {
        return switch (expr.kind) {
            case "isSet", "isOne" -> {
                require(expr.equals(n(guard ? "isOne" : "isSet", ref(guard ? "sole" : "container"))), "Unexpected predicate receiver/type");
                yield object("kind", expr.kind);
            }
            case "not" -> object("kind", "not", "condition", predicate((N) expr.args.get(0), guard));
            case "and", "or" -> object("kind", expr.kind, "left", predicate((N) expr.args.get(0), guard), "right", predicate((N) expr.args.get(1), guard));
            case "eq" -> object("kind", "eq", "left", number((N) expr.args.get(0)), "right", number((N) expr.args.get(1)));
            default -> throw new IllegalArgumentException("Unsupported predicate: " + expr.kind);
        };
    }
    private static Map<String, Object> number(N expr) {
        if (expr.kind.equals("nat")) return object("kind", "nat", "value", expr.args.get(0));
        require(expr.equals(n("size", access("SetPort", "elements", "java.util.List", n("cast", P + "SetPort", ref("container"))))), "Unsupported numeric expression");
        return object("kind", "size");
    }
    private static Map<String, Object> object(Object... entries) {
        Map<String, Object> result = new LinkedHashMap<>();
        for (int i = 0; i < entries.length; i += 2) result.put((String) entries[i], entries[i + 1]);
        return result;
    }
    private static String quote(String s) {
        StringBuilder b = new StringBuilder("\"");
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"' -> b.append("\\\""); case '\\' -> b.append("\\\\");
                case '\n' -> b.append("\\n"); case '\r' -> b.append("\\r"); case '\t' -> b.append("\\t");
                default -> { if (c < 32) b.append(String.format(Locale.ROOT, "\\u%04x", (int) c)); else b.append(c); }
            }
        }
        return b.append('"').toString();
    }
    private static String json(Object value) {
        if (value == null) return "null";
        if (value instanceof N node) {
            String[] keys = switch (node.kind) {
                case "ref" -> new String[]{"name"}; case "nat", "text" -> new String[]{"value"};
                case "and", "or", "eq" -> new String[]{"left", "right"};
                case "not", "isSet", "isOne", "size", "ret", "throwValue" -> new String[]{"value"};
                case "cast" -> new String[]{"type", "value"}; case "call" -> new String[]{"symbol", "receiver", "arguments"};
                case "newObject" -> new String[]{"symbol", "arguments"};
                case "bind" -> new String[]{"name", "type", "value"};
                case "branch" -> new String[]{"condition", "then", "else"};
                default -> throw new IllegalArgumentException("Unknown export node");
            };
            Map<String, Object> m = object("kind", node.kind);
            for (int i = 0; i < keys.length; i++) m.put(keys[i], node.args.get(i));
            return json(m);
        }
        if (value instanceof String s) return quote(s);
        if (value instanceof Number) return value.toString();
        if (value instanceof List<?> l) return l.stream().map(SmartConstructionSourceExtractor::json).collect(Collectors.joining(",", "[", "]"));
        if (value instanceof Map<?, ?> m) return m.entrySet().stream().map(e -> quote((String) e.getKey()) + ":" + json(e.getValue())).collect(Collectors.joining(",", "{", "}"));
        throw new IllegalArgumentException("Unsupported JSON value");
    }
    private static String lean(Object value) {
        if (value instanceof N node) {
            List<String> args = new ArrayList<>();
            for (int i = 0; i < node.args.size(); i++) {
                Object arg = node.args.get(i);
                args.add(node.kind.equals("call") && i == 1 ? (arg == null ? "none" : "(some " + lean(arg) + ")") : lean(arg));
            }
            return "(." + node.kind + " " + String.join(" ", args) + ")";
        }
        if (value instanceof String s) return quote(s);
        if (value instanceof Number) return value.toString();
        if (value instanceof List<?> l) return l.stream().map(SmartConstructionSourceExtractor::lean).collect(Collectors.joining(", ", "[", "]"));
        throw new IllegalArgumentException("Unsupported Lean value");
    }
    private static final String LEAN_TYPES = """
            -- Generated from javac's resolved production AST. Data only; no correctness claim.
            namespace SmartConstructionSource
            inductive Expr where
              | ref : String -> Expr
              | nat : Nat -> Expr
              | text : String -> Expr
              | and : Expr -> Expr -> Expr
              | or : Expr -> Expr -> Expr
              | eq : Expr -> Expr -> Expr
              | not : Expr -> Expr
              | isSet : Expr -> Expr
              | isOne : Expr -> Expr
              | size : Expr -> Expr
              | cast : String -> Expr -> Expr
              | call : String -> Option Expr -> List Expr -> Expr
              | newObject : String -> List Expr -> Expr
              deriving Repr, BEq
            inductive Stmt where
              | bind : String -> String -> Expr -> Stmt
              | branch : Expr -> List Stmt -> List Stmt -> Stmt
              | ret : Expr -> Stmt
              | throwValue : Expr -> Stmt
              deriving Repr, BEq
            """;

    public static void main(String[] args) throws Exception {
        require(args.length == 2, "Usage: SmartConstructionSourceExtractor ROOT OUTPUT.json");
        Path root = Path.of(args[0]).toAbsolutePath().normalize(), output = Path.of(args[1]).toAbsolutePath().normalize();
        require(output.toString().endsWith(".json"), "OUTPUT must end in .json");
        Path source = root.resolve("src/" + OWNER.replace('.', '/') + ".java");
        byte[] bytes = Files.readAllBytes(source);
        String content = new String(bytes, StandardCharsets.UTF_8);
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "A full JDK 17+ is required");
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        try (StandardJavaFileManager fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            List<Path> sources, jars;
            try (var paths = Files.walk(root.resolve("src"))) { sources = paths.filter(p -> p.toString().endsWith(".java")).sorted().toList(); }
            try (var paths = Files.list(root.resolve("lib"))) { jars = paths.filter(p -> p.toString().endsWith(".jar")).sorted().toList(); }
            List<JavaFileObject> files = new ArrayList<>();
            for (JavaFileObject f : fm.getJavaFileObjectsFromPaths(sources)) files.add(Path.of(f.toUri()).equals(source)
                    ? new SimpleJavaFileObject(source.toUri(), JavaFileObject.Kind.SOURCE) {
                        @Override public CharSequence getCharContent(boolean ignoreEncodingErrors) { return content; }
                    } : f);
            String cp = jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator));
            JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics,
                    List.of("--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8", "-classpath", cp), null, files);
            List<CompilationUnitTree> units = new ArrayList<>();
            task.parse().forEach(units::add); task.analyze();
            for (Diagnostic<?> d : diagnostics.getDiagnostics()) require(d.getKind() != Diagnostic.Kind.ERROR,
                    "Compiler error: " + d);
            List<CompilationUnitTree> matches = units.stream().filter(u -> Path.of(u.getSourceFile().toUri()).equals(source)).toList();
            require(matches.size() == 1, "Ambiguous/missing production compilation unit");
            CompilationUnitTree unit = matches.get(0);
            SmartConstructionSourceExtractor extractor = new SmartConstructionSourceExtractor(root, task, unit);
            List<MethodTree> methods = new ArrayList<>();
            for (Tree t : unit.getTypeDecls()) if (t instanceof ClassTree c
                    && extractor.symbol(extractor.element(c)).equals(OWNER)) {
                for (Tree member : c.getMembers()) if (member instanceof MethodTree m && m.getName().contentEquals(METHOD)) methods.add(m);
            }
            require(methods.size() == 1, "Ambiguous/missing production method");
            MethodTree method = methods.get(0);
            List<N> plan = extractor.extract(method);
            N condition = (N) plan.get(2).args.get(0);
            List<?> then = (List<?>) plan.get(2).args.get(1);
            N guard = (N) ((N) then.get(1)).args.get(0);
            String whenTrue = action((N) then.get(3)), whenFalse = action(plan.get(3));
            List<String> tags = List.of(whenTrue.toLowerCase(Locale.ROOT), whenFalse.toLowerCase(Locale.ROOT));
            long start = extractor.trees.getSourcePositions().getStartPosition(unit, method);
            long end = extractor.trees.getSourcePositions().getEndPosition(unit, method);
            require(start >= 0 && end > start, "Missing method span");
            require(Arrays.equals(bytes, Files.readAllBytes(source)), "Production source changed during extraction");
            String sha = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
            Map<String, Object> result = object("schemaVersion", 1, "method", OWNER + "." + METHOD,
                    "sourceSha256", sha, "span", object("path", root.relativize(source).toString(),
                            "startOffset", start, "endOffset", end, "startLine", unit.getLineMap().getLineNumber(start),
                            "endLine", unit.getLineMap().getLineNumber(end - 1)), "condition", predicate(condition, false),
                    "rejectionGuard", predicate(guard, true), "whenTrue", whenTrue, "whenFalse", whenFalse,
                    "branchTags", tags, "plan", plan, "resolvedSymbols", new ArrayList<>(extractor.symbols),
                    "trustBoundary", "Trusted javac symbol resolution and bounded AST projection; callee bodies are named effects, not interpreted.");
            String lean = LEAN_TYPES + "def sourceSha256 : String := " + quote(sha) + "\n"
                    + "def condition : Expr := " + lean(condition) + "\n"
                    + "def rejectionGuard : Expr := " + lean(guard) + "\n"
                    + "def whenTrue : String := " + quote(whenTrue) + "\n"
                    + "def whenFalse : String := " + quote(whenFalse) + "\n"
                    + "def methodPlan : List Stmt := " + lean(plan) + "\n"
                    + "def branchTags : List String := " + lean(tags) + "\nend SmartConstructionSource\n";
            Files.createDirectories(output.getParent());
            Files.writeString(Path.of(output.toString().substring(0, output.toString().length() - 5) + ".lean"), lean, StandardCharsets.UTF_8);
            Files.writeString(output, json(result) + "\n", StandardCharsets.UTF_8);
        }
    }
}
