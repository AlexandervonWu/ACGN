package is.fivefivefive.CanDis.core.egraph;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.*;
import java.util.*;
import javax.lang.model.element.*;
import javax.tools.*;

/** Full method bodies with resolved invocation, construction and method-reference targets.
    Only data/storage internals below SlottedEGraph's frontier boundary are excluded. */
final class P511Entrypoints {
    private static final String EXPECTED = "416f8582fbb0f215ceb3a7386e894303a25761cb4330a81bc7b9de51cf992e2b";
    private static final String ROOT = "is.fivefivefive.CanDis.";
    private static final String CORE = ROOT + "core.egraph.";
    private static final List<String> CLASSES = List.of("AblationEngine","AlloyTerm","AlloyRewriteSystem",
            "DeBruijnVariables","JavaEgglog","JavaEgglogDeBruijn","RawEGraph","RawDeBruijnEGraph",
            "SlotBindingBlocks","SlotCanonicalizer","SlotPermutationSearch","SlottedEGraph");

    record Census(int methods, int symbols, String hash) {}

    static Census inspect(Path root) throws Exception {
        Path src = root.resolve("src/is/fivefivefive/CanDis");
        var files = new ArrayList<Path>();
        for (String owner : CLASSES) files.add(src.resolve("core/egraph/"+owner+".java"));
        files.add(src.resolve("EGraphAblationStudy.java"));
        files.add(src.resolve("adapter/AlloyAstTermAdapter.java"));
        var compiler = ToolProvider.getSystemJavaCompiler();
        var diagnostics = new DiagnosticCollector<JavaFileObject>();
        var bodies = new TreeMap<String,String>();
        var symbols = new int[1];
        try (var manager = compiler.getStandardFileManager(diagnostics,Locale.ROOT,StandardCharsets.UTF_8)) {
            List<String> options = List.of("-proc:none","--source-path","","-classpath",System.getProperty("java.class.path"));
            var task = (JavacTask)compiler.getTask(null,manager,diagnostics,options,null,
                    manager.getJavaFileObjectsFromPaths(files));
            var units = new ArrayList<CompilationUnitTree>();
            task.parse().forEach(units::add);
            task.analyze();
            for (var diagnostic : diagnostics.getDiagnostics()) {
                if (diagnostic.getKind() == Diagnostic.Kind.ERROR) throw new IllegalArgumentException(diagnostic.toString());
            }
            Trees trees = Trees.instance(task);
            for (var unit : units) new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree tree, Void unused) {
                    var method = (ExecutableElement)trees.getElement(getCurrentPath());
                    String owner = ((TypeElement)method.getEnclosingElement()).getQualifiedName().toString();
                    String name = method.getSimpleName().toString();
                    boolean include = owner.equals(ROOT+"EGraphAblationStudy") ? name.equals("processFile")
                            : owner.equals(ROOT+"EGraphAblationStudy.Engine") ? name.equals("newEngine") || name.equals("parse")
                            : owner.startsWith(ROOT+"EGraphAblationStudy.") ? false
                            : !owner.startsWith(CORE+"SlottedEGraph.") && (owner.startsWith(CORE) || owner.startsWith(ROOT+"adapter."));
                    if (!include || tree.getBody() == null) return null;
                    String key = owner + "#" + method;
                    StringBuilder evidence = new StringBuilder(tree.getBody().toString()).append('\n');
                    new TreePathScanner<Void,Void>() {
                        private void target() {
                            Element e = trees.getElement(getCurrentPath());
                            if (!(e instanceof ExecutableElement)) throw new AssertionError("Unresolved call in "+key);
                            evidence.append(e.getEnclosingElement()).append('#').append(e).append('\n');
                            symbols[0]++;
                        }
                        @Override public Void visitMethodInvocation(MethodInvocationTree t,Void x) {
                            target(); return super.visitMethodInvocation(t,x);
                        }
                        @Override public Void visitNewClass(NewClassTree t,Void x) {
                            target(); return super.visitNewClass(t,x);
                        }
                        @Override public Void visitMemberReference(MemberReferenceTree t,Void x) {
                            target(); return super.visitMemberReference(t,x);
                        }
                    }.scan(new TreePath(getCurrentPath(),tree.getBody()),null);
                    if (bodies.put(key,evidence.toString()) != null) throw new AssertionError("Duplicate selected body "+key);
                    return null;
                }
            }.scan(unit,null);
        }
        for (String owner : List.of("RawEGraph","RawDeBruijnEGraph","JavaEgglog","JavaEgglogDeBruijn","SlottedEGraph"))
            if (bodies.keySet().stream().noneMatch(k->k.startsWith(CORE+owner+"#compare(")))
                throw new AssertionError("Missing implementing compare method "+owner);
        var md = MessageDigest.getInstance("SHA-256");
        for (var row : bodies.entrySet()) {
            md.update((row.getKey()+"\n"+row.getValue()+"\n").getBytes(StandardCharsets.UTF_8));
        }
        String digest = HexFormat.of().formatHex(md.digest());
        if (!EXPECTED.equals(digest)) throw new AssertionError("Source/dispatch drift "+bodies.size()+"/"+symbols[0]+"/"+digest);
        return new Census(bodies.size(),symbols[0],digest);
    }
}
