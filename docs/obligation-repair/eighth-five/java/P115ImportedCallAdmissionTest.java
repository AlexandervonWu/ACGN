package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.Func;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.alloy.AlloyLibraryCallableLedger;
import is.fivefivefive.ACGN.alloy.CallSymbol;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import parser.ast.nodes.Call;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.Node;
import parser.ast.nodes.ResolvedCallOrigins;

/** Compare every admitted imported tuple with installed library declarations and genuine producer calls. */
public final class P115ImportedCallAdmissionTest {
    private static final String ORDER = "util/ordering";
    private static final String INT = "util/integer";
    private static final String HEADER = "module admission\nopen util/ordering[A] as ord\nsig A {}\n";
    private static final String JAR_SHA256 = "8a8746b89d95f28762903c9acbd2bee8aca5014fe49a522b7184ba32ffcc5b58";
    private static final Map<String, String> RESOURCES = Map.of(
            ORDER, "c7b35d80efdf8d33a967417578523b36a5f6dfdafe9b4a20862dee0b283402bf",
            INT, "d15e0dfd7b8150f2e77cdb9557196de90896163ba16a7611b3f8fd9cf9dff7eb");
    private static final Set<String> ALLOWED_INTEGER = Set.of("max/0", "max/1", "min/0", "min/1", "prev/0", "next/0");

    private record Key(String module, String member, CallSymbol.Kind kind, int arity) {
        String display() { return module + "/" + member + "/" + kind + "/" + arity; }
    }

    private record Input(CompModule module, ModelUnit tree) {
        static Input parse(String text) throws Exception {
            CompModule module = CompUtil.parseEverything_fromString(A4Reporter.NOP, text);
            return new Input(module, new ModelUnit(null, module));
        }

        MASGVisitor visit() {
            var visitor = new MASGVisitor(new GlobalVariables(), module);
            visitor.visit(tree, null);
            return visitor;
        }
    }

    private static void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    private static String digest(byte[] bytes) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
    }

    private static String shortName(Func f) { return f.label.substring(f.label.lastIndexOf('/') + 1); }

    private static void checkResources() throws Exception {
        Path jar = Path.of(CompModule.class.getProtectionDomain().getCodeSource().getLocation().toURI());
        check(JAR_SHA256.equals(digest(Files.readAllBytes(jar))), "different loaded Alloy dependency");
        for (var entry : RESOURCES.entrySet()) {
            try (var in = CompModule.class.getResourceAsStream("/models/" + entry.getKey() + ".als")) {
                check(in != null && entry.getValue().equals(digest(in.readAllBytes())), "different embedded resource");
            }
        }
    }

    private static List<Key> dependency(Input input) {
        List<Key> keys = new ArrayList<>();
        for (var open : input.module.getOpens()) {
            check(RESOURCES.containsKey(open.filename), "unexpected open " + open.filename);
            for (Func original : open.getRealModule().getAllFunc()) {
                if (shortName(original).contains("$")) continue; // implicit compiler command
                String embedded = edu.mit.csail.sdg.alloy4.Util.jarPrefix() + "models/"
                        + open.filename + ".als";
                check(original.pos.filename.equals(embedded.replace('/', java.io.File.separatorChar)),
                        "fixture resolved a non-embedded library file: " + original.pos.filename);
                check(original.isPrivate == null, "expected public library declaration");
                int arity = original.decls.stream().mapToInt(decl -> decl.names.size()).sum();
                check(arity == original.count(), "declared parameter count");
                keys.add(new Key(open.filename, shortName(original),
                        original.isPred ? CallSymbol.Kind.FORMULA : CallSymbol.Kind.EXPRESSION, arity));
            }
        }
        check(keys.size() == 45 && Set.copyOf(keys).size() == 45, "expected 45 distinct declarations");
        return keys;
    }

    private static void reject(String name, String expected, Runnable attempt) {
        try {
            attempt.run();
        } catch (IllegalStateException error) {
            check(error.getMessage().contains(expected), name + " unexpected rejection: " + error);
            System.out.println("P1-15\t" + name + "\tREJECT " + expected);
            return;
        }
        throw new AssertionError(name + " accepted");
    }

    private static void collect(Node node, String name, List<Call> out) {
        if (node instanceof Call c && c.getName().equals(name)) out.add(c);
        for (Node child : node.getChildren()) collect(child, name, out);
    }

    private static Call call(Input input, String name, int arity) {
        List<Call> found = new ArrayList<>();
        collect(input.tree, name, found);
        return found.stream().filter(c -> c.getArguments().size() == arity).findFirst().orElseThrow();
    }

    private static void wholeTable() throws Exception {
        List<Key> all = dependency(Input.parse(HEADER + "pred stub {}"));
        var accepted = new TreeMap<String, Key>();
        var absent = new TreeSet<String>();
        for (Key key : all) {
            boolean admitted = key.module.equals(ORDER) ||
                    ALLOWED_INTEGER.contains(key.member + "/" + key.arity);
            if (admitted) {
                var signature = AlloyLibraryCallableLedger.require(key.module, key.member, key.kind, key.arity);
                check(signature.arity() == key.arity && signature.kind() == key.kind, "different signature");
                accepted.put(key.display(), key);
            } else {
                try {
                    AlloyLibraryCallableLedger.require(key.module, key.member, key.kind, key.arity);
                    throw new AssertionError("unlisted integer signature accepted " + key);
                } catch (IllegalStateException expected) {
                    absent.add(key.display());
                }
            }
        }
        // Enumerate the actual immutable table as well, so an extra key outside both modules is visible.
        var field = AlloyLibraryCallableLedger.class.getDeclaredField("SIGNATURES");
        field.setAccessible(true);
        check(((Map<?, ?>) field.get(null)).keySet().equals(accepted.keySet()), "extra or missing ledger tuple");
        check(accepted.size() == 20 && absent.size() == 25, "pinned subset census");

        StringBuilder text = new StringBuilder(HEADER);
        var predicates = new TreeMap<String, Key>();
        for (Key key : accepted.values()) {
            String predicate = "case" + predicates.size();
            String arg = key.module.equals(ORDER) ? "A" : "Int";
            String alias = key.module.equals(ORDER) ? "ord" : "integer";
            String params = key.arity == 0 ? "" : "[" + String.join(",", java.util.Collections.nCopies(key.arity, arg)) + "]";
            String expr = alias + "/" + key.member + params;
            text.append("pred ").append(predicate).append(" { ")
                    .append(key.kind == CallSymbol.Kind.EXPRESSION ? "some " : "").append(expr).append(" }\n");
            predicates.put(predicate, key);
        }
        Input model = Input.parse(text.toString());
        MASGVisitor visitor = model.visit();
        for (var entry : predicates.entrySet()) {
            Key k = entry.getValue();
            String canonical = (k.module.equals(ORDER) ? ORDER + "<A>" : INT) + "/" + k.member;
            var graph = visitor.getForest().get(visitor.getForestId(entry.getKey()));
            var calls = graph.getVertices().stream().map(n -> n.getSymbol()).filter(CallSymbol.class::isInstance)
                    .map(CallSymbol.class::cast).toList();
            check(calls.size() == 1, "expected one imported CALL for " + k);
            var c = calls.get(0);
            check(c.getArityAuthority() == CallSymbol.ArityAuthority.TYPECHECKED_IMPORT
                    && c.getCallee().equals(canonical) && c.getDeclaredArity() == k.arity
                    && c.getKind() == k.kind, "producer selected a different tuple " + k);
        }
        for (String key : accepted.keySet()) System.out.println("P1-15\t" + key + "\tACCEPT ledger + resolved producer CALL");
        for (String key : absent) System.out.println("P1-15\t" + key + "\tREJECT outside fixed library ledger");
    }

    private static void alternativeResource() throws Exception {
        // Alloy accepts dependency bytes through its source-map API before trying the JAR.
        String root = Path.of("p115-source-map-only.als").toAbsolutePath().normalize().toString();
        String library = "module util/ordering[elem]\nfun first: set elem { none }";
        var sources = new java.util.HashMap<String, String>();
        sources.put(root, HEADER + "pred chosen { some ord/first }");
        sources.put(ORDER, library);
        var compiled = CompUtil.parseEverything_fromFile(A4Reporter.NOP, sources, root);
        var input = new Input(compiled, new ModelUnit(null, compiled));
        var original = ResolvedCallOrigins.original(call(input, "ord/first", 0));
        check(original != null && sources.containsValue(library) && original.fun.pos.filename.equals(ORDER),
                "expected caller-supplied library origin, found " + (original == null ? "none" : original.fun.pos.filename));
        var visitor = input.visit();
        var graph = visitor.getForest().get(visitor.getForestId("chosen"));
        check(graph.getVertices().stream().map(n -> n.getSymbol()).anyMatch(s -> s instanceof CallSymbol c
                && c.getCallee().equals(ORDER + "<A>/first") && c.getDeclaredArity() == 0
                && c.getArityAuthority() == CallSymbol.ArityAuthority.TYPECHECKED_IMPORT),
                "same supported tuple in a caller-supplied module");
        System.out.println("P1-15\tcaller-supplied-library\tACCEPT exact signature; source-map body differs from JAR");
    }

    public static void main(String[] args) throws Exception {
        check(args.length == 0, "no arguments expected");
        checkResources();
        wholeTable();
        reject("delimiter-collision", "lacks an independently pinned declaration",
                () -> AlloyLibraryCallableLedger.require("util", "ordering/first", CallSymbol.Kind.EXPRESSION, 0));
        reject("wrong-kind", "lacks an independently pinned declaration",
                () -> AlloyLibraryCallableLedger.require(ORDER, "first", CallSymbol.Kind.FORMULA, 0));
        reject("wrong-integer-arity", "arity disagrees with imported declaration",
                () -> AlloyLibraryCallableLedger.require(INT, "max", CallSymbol.Kind.EXPRESSION, 2));
        for (String member : List.of("max", "min")) {
            String source = HEADER + "pred pair { integer/" + member + " in integer/" + member + "[Int] }";
            for (int oldArity : List.of(0, 1)) {
                Input input = Input.parse(source);
                Call zero = call(input, "integer/" + member, 0), one = call(input, "integer/" + member, 1);
                Call changed = oldArity == 0 ? zero : one;
                Call other = oldArity == 0 ? one : zero;
                changed.setArguments(other.getArguments());
                // The editable parser map is not an origin oracle.
                changed.getNodeMap().addToMap(ResolvedCallOrigins.original(other), changed);
                check(ResolvedCallOrigins.original(changed).fun.count() == oldArity, "original not sealed");
                reject(member + "-" + oldArity + "-to-" + (1-oldArity), "arity disagrees with imported declaration", input::visit);
            }
        }
        Input rename = Input.parse(HEADER + "pred p { some ord/first }");
        call(rename, "ord/first", 0).setName("ord/last");
        reject("same-type-renamed-import", "disagrees with its resolved declaration", rename::visit);
        Input local = Input.parse(HEADER + "fun loc: A { A }\npred p { some ord/first }");
        call(local, "ord/first", 0).setName("loc");
        reject("import-masquerading-as-local", "disagrees with its resolved declaration", local::visit);
        Input ownership = Input.parse(HEADER + "sig B {}\npred p { some ord/first }");
        ownership.tree.getOpenDeclList().stream().filter(o -> o.getFileName().equals(ORDER)).findFirst()
                .orElseThrow().setArguments(List.of("B"));
        reject("foreign-module-arguments", "disagrees with its resolved module", ownership::visit);
        Input first = Input.parse(HEADER + "pred p { some ord/first }");
        Input second = Input.parse(HEADER + "pred p { some ord/first }");
        reject("foreign-parser-instance", "disagrees with its resolved module",
                () -> new MASGVisitor(new GlobalVariables(), second.module).visit(first.tree, null));
        alternativeResource();
        System.out.println("P115ImportedCallAdmissionTest: PASS (20 admitted, 25 outside ledger, 11 rejections, 1 alternative library origin)");
    }
}
