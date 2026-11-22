package is.fivefivefive.CanDis;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import javax.lang.model.element.ExecutableElement;
import javax.tools.*;

/** Binds the checked guards to the compiler's resolved implementation and decodes
    both quantifier switch tables from the actual methods. */
final class P508CompilerContract {
    private static final String EXPECTED = "4b53160d4eec36b975fa3e3099518a2a0602232852e49dc0ae1c9726f1fc89d0";
    private static final Map<String, Set<String>> TARGETS = Map.of(
        "is/fivefivefive/CanDis/core/NormalForm", Set.of("normalize", "prenex", "localQuantifier",
            "prenexRelDecl", "localRelDecl", "descopeUnusedBindings", "emptyTupleDomainValue",
            "emptyDomainValue", "hasEmptyAdmissibleBindingSet", "isStaticallyEmptySet", "domainDescriptor",
            "cardinalityOf", "hasScopedInhabitedCarrierWitness", "isNone"),
        "is/fivefivefive/CanDis/core/EGraphNode", Set.of("sameSemanticInvocation", "isSetConstant"),
        "is/fivefivefive/ACGN/alloy/ExactAlloyType", Set.of("from", "fromParser", "relationArity"),
        "parser/ast/nodes/ResolvedBindingOrigins", Set.of("effectiveMultiplicity", "implicitOne"),
        "is/fivefivefive/CanDis/core/egraph/AlloyRewriteSystem", Set.of("rewriteTree", "rewriteScopedTree",
            "rewriteNode", "emptyDomainResult", "isEmptyDomain", "isAuthenticatedUnaryDeclaration",
            "constantBodyResult"));

    private static String hash(String body) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
            .digest(body.getBytes(StandardCharsets.UTF_8)));
    }

    private static final Map<String, Boolean> FORMULAS = Map.of(
        "ALL", true, "NO", true, "LONE", true, "NOTONE", true,
        "SOME", false, "ONE", false, "NOTLONE", false);

    private static void decode(SwitchTree table) {
        var pending = new ArrayList<String>();
        var decoded = new TreeMap<String,Boolean>();
        boolean rejectOthers = false;
        for (var arm : table.getCases()) {
            boolean fallback = arm.getExpressions().isEmpty();
            for (var label : arm.getExpressions()) {
                String key = label instanceof LiteralTree literal ? literal.getValue().toString() : label.toString();
                pending.add(key.startsWith("QF/") ? key.substring(3) : key);
            }
            var statements = arm.getStatements();
            if (statements == null || statements.size() > 1) throw new AssertionError("Unmodeled quantifier branch");
            if (statements.isEmpty()) continue;
            if (!(statements.get(0) instanceof ReturnTree value)) throw new AssertionError("Unmodeled fold exit");
            ExpressionTree expression = value.getExpression();
            if (expression instanceof MethodInvocationTree call && call.getMethodSelect().toString().equals("bool")
                    && call.getArguments().size() == 1) expression = call.getArguments().get(0);
            if (!(expression instanceof LiteralTree literal)) throw new AssertionError("Expected a literal fold result");
            if (fallback) {
                if (!pending.isEmpty() || literal.getValue() != null) throw new AssertionError("Unexpected default");
                rejectOthers = true;
            } else {
                if (!(literal.getValue() instanceof Boolean truth)) throw new AssertionError("Expected Boolean branch");
                for (String key : pending)
                    if (decoded.put(key, truth) != null) throw new AssertionError("Duplicate quantifier " + key);
                pending.clear();
            }
        }
        if (!rejectOthers || !decoded.equals(FORMULAS)) throw new AssertionError("Quantifier truth table " + decoded);
    }

    static String inspect(Path root, Path output) throws Exception {
        var files = TARGETS.keySet().stream().sorted().map(s -> root.resolve("src/" + s + ".java")).toList();
        var compiler = ToolProvider.getSystemJavaCompiler();
        var diagnostics = new DiagnosticCollector<JavaFileObject>();
        var rows = new TreeMap<String,String>();
        var seen = new TreeSet<String>();
        var switches = new TreeSet<String>();
        int[] symbolCount = {0};
        try (var manager = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            var options = List.of("-proc:none", "--source-path", "", "-classpath", System.getProperty("java.class.path"));
            var task = (JavacTask) compiler.getTask(null, manager, diagnostics, options, null, manager.getJavaFileObjectsFromPaths(files));
            var units = new ArrayList<CompilationUnitTree>();
            task.parse().forEach(units::add);
            task.analyze();
            for (var diagnostic : diagnostics.getDiagnostics()) if (diagnostic.getKind() == Diagnostic.Kind.ERROR)
                throw new AssertionError(diagnostic);
            var trees = Trees.instance(task);
            for (var unit : units) new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree method, Void ignore) {
                    var executable = (ExecutableElement) trees.getElement(getCurrentPath());
                    String owner = executable.getEnclosingElement().toString();
                    String ownerFile = owner.replace('.', '/');
                    if (owner.endsWith(".ResolvedBindingOrigins.Slot"))
                        ownerFile = "parser/ast/nodes/ResolvedBindingOrigins";
                    String name = executable.getSimpleName().toString();
                    if (!TARGETS.getOrDefault(ownerFile, Set.of()).contains(name)) return null;
                    String key = owner + "#" + executable;
                    seen.add(ownerFile + "#" + name);
                    var targets = new ArrayList<String>();
                    new TreePathScanner<Void,Void>() {
                        private void target() {
                            var element = trees.getElement(getCurrentPath());
                            if (!(element instanceof ExecutableElement target)) throw new AssertionError("Unresolved call in " + key);
                            targets.add(target.getEnclosingElement() + "#" + target);
                        }
                        @Override public Void visitMethodInvocation(MethodInvocationTree t,Void v) {target(); return super.visitMethodInvocation(t,v);}
                        @Override public Void visitMemberReference(MemberReferenceTree t,Void v) {target(); return super.visitMemberReference(t,v);}
                        @Override public Void visitNewClass(NewClassTree t,Void v) {target(); return super.visitNewClass(t,v);}
                        @Override public Void visitSwitch(SwitchTree t,Void v) {
                            if (name.equals("emptyDomainValue") || name.equals("emptyDomainResult")) {
                                decode(t);
                                if (!switches.add(key)) throw new AssertionError("Multiple fold switches " + key);
                            }
                            return super.visitSwitch(t,v);
                        }
                    }.scan(new TreePath(getCurrentPath(), method.getBody()), null);
                    symbolCount[0] += targets.size();
                    try {
                        if (rows.put(key, key + "\t" + targets.size() + "\t" +
                                hash(method.getBody() + "\n" + String.join("\n", targets))) != null)
                            throw new AssertionError("Duplicate source body " + key);
                    } catch (Exception e) { throw new IllegalStateException(e); }
                    return null;
                }
            }.scan(unit, null);
        }
        for (var file : TARGETS.entrySet()) for (String name : file.getValue())
            if (!seen.contains(file.getKey()+"#"+name)) throw new AssertionError("Missing source body " + name);
        if (switches.size() != 2) throw new AssertionError("Incomplete fold switch census");
        String tsv = "resolved_method\tresolved_calls\tbody_and_target_sha256\n" + String.join("\n", rows.values()) + "\n";
        String observed = hash(tsv);
        if (!EXPECTED.equals(observed)) throw new AssertionError("Compiler contract " + rows.size() +
                "/" + symbolCount[0] + "/" + observed);
        Files.writeString(output, tsv, StandardCharsets.UTF_8, StandardOpenOption.CREATE_NEW);
        return rows.size() + "/" + symbolCount[0] + "/" + observed;
    }
}
