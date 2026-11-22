package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.function.Supplier;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.concurrent.TimeUnit;
import java.util.TreeSet;
import java.util.stream.Collectors;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;

/** Independent key-by-key oracle over input products, with live parsed Alloy columns. */
public final class A221NormalizationTest {
    private static final String MODEL = "abstract sig P {} sig A, B extends P {} sig C extends A {}";

    private static List<GraphType> key(List<DependentColumnEvidence> row) {
        return row.stream().map(DependentColumnEvidence::exactColumn).toList();
    }

    private static List<DependentColumnEvidence> representative(List<List<DependentColumnEvidence>> group) {
        var row = new ArrayList<DependentColumnEvidence>();
        for (int i = 0; i < group.get(0).size(); i++) {
            int coordinate = i;
            row.add(group.stream().map(p -> p.get(coordinate))
                    .filter(DependentColumnEvidence::hasParserModuleAuthority)
                    .findFirst().orElse(group.get(0).get(i)));
        }
        return row;
    }

    private static boolean dominates(List<DependentColumnEvidence> narrow, List<DependentColumnEvidence> wide) {
        if (narrow.size() != wide.size() || key(narrow).equals(key(wide))) return false;
        for (int i = 0; i < narrow.size(); i++) {
            var specific = narrow.get(i);
            var general = wide.get(i);
            if (specific.exactColumn().equals(general.exactColumn())) continue;
            if (!specific.sharesParserModuleAuthorityWith(general)
                    || !specific.ancestry().subList(1, specific.ancestry().size()).contains(general.exactColumn())) {
                return false;
            }
        }
        return true;
    }

    private static boolean compatibleInputs(List<DependentTypeDag> operands) {
        DependentColumnEvidence owner = null;
        Map<GraphType,List<GraphType>> paths = new java.util.HashMap<>();
        Map<GraphType,GraphType> parents = new java.util.HashMap<>();
        for (var operand : operands) {
            for (var row : operand.alternatives()) {
                for (var column : row) {
                    if (column.hasParserModuleAuthority()) {
                        if (owner == null) owner = column;
                        else if (!owner.sharesParserModuleAuthorityWith(column)) return false;
                    }
                    var path = column.ancestry();
                    var prior = paths.putIfAbsent(column.exactColumn(),path);
                    if (prior != null && !prior.equals(path)) return false;
                    for (int i = 1; i < path.size(); i++) {
                        var existing = parents.putIfAbsent(path.get(i-1),path.get(i));
                        if (existing != null && !existing.equals(path.get(i))) return false;
                    }
                }
            }
        }
        for (var start : parents.keySet()) {
            var visited = new java.util.HashSet<GraphType>();
            for (var current = start; current != null; current = parents.get(current))
                if (!visited.add(current)) return false;
        }
        return true;
    }

    public static boolean matches(List<DependentTypeDag> operands, DependentTypeDag result) {
        if (operands.size() < 2 || !compatibleInputs(operands) || operands.stream().anyMatch(p -> p.arity() != result.arity())) return false;
        Map<List<GraphType>, List<List<DependentColumnEvidence>>> inputs = new LinkedHashMap<>();
        for (var operand : operands) {
            for (var row : operand.alternatives()) {
                inputs.computeIfAbsent(key(row), ignored -> new ArrayList<>()).add(row);
            }
        }
        var classes = inputs.values().stream().map(A221NormalizationTest::representative).toList();
        var wanted = classes.stream().filter(p -> classes.stream().noneMatch(q -> dominates(p, q)))
                .sorted(Comparator.comparing(p -> GraphType.relation(key(p)))).toList();
        if (wanted.size() != result.alternatives().size()) return false;
        for (int r = 0; r < wanted.size(); r++) {
            var observed = result.alternatives().get(r);
            if (!key(wanted.get(r)).equals(key(observed))) return false;
            for (int c = 0; c < observed.size(); c++) {
                if (!wanted.get(r).get(c).sameOccurrenceEvidenceAs(observed.get(c))) return false;
            }
        }
        return true;
    }

    private static DependentColumnEvidence column(CompModule module, String expression) throws Exception {
        var t = CompUtil.parseOneExpression_fromString(module, expression).type();
        return DependentTypeDag.fromExactAlloyType(ExactAlloyType.fromParser(t, module)).alternatives().get(0).get(0);
    }

    private static DependentTypeDag row(DependentColumnEvidence... columns) {
        var ordered = List.of(columns);
        return DependentTypeDag.exactAlternative(GraphType.relation(key(ordered)), ordered);
    }

    private static final List<String> traces = new ArrayList<>();
    private static final List<String> outcomes = new ArrayList<>();

    private static void replay(Path source, Path log, boolean valid) throws Exception {
        String lean = java.util.Objects.requireNonNull(System.getenv("ACGN_NINTH_LEAN"), "audited Lean executable");
        String proof = java.util.Objects.requireNonNull(System.getenv("ACGN_NINTH_PROOF"), "frozen proof source");
        Process process = new ProcessBuilder(lean, "-j1", "-M512", "--run", proof, source.toString())
                .redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if (!process.waitFor(60, TimeUnit.SECONDS)) {
            process.destroyForcibly().waitFor();
            throw new AssertionError("Lean normalization trace timeout");
        }
        String expected = valid ? "A221 typed normalization traces verified " + traces.size()
                : "A221 typed normalization trace rejected";
        if (process.exitValue() != (valid ? 0 : 1) || !Files.readString(log).stripTrailing().endsWith(expected))
            throw new AssertionError("unexpected Lean trace verdict in " + log);
    }

    private static String encodeRows(List<List<DependentColumnEvidence>> rows,
            List<GraphType> orderedTypes) {
        if (rows.isEmpty()) return "-";
        return rows.stream().map(row -> row.stream().map(c -> {
            var parents = c.ancestry().stream().skip(1)
                    .map(t -> Integer.toString(orderedTypes.indexOf(t))).collect(Collectors.joining(","));
            return orderedTypes.indexOf(c.exactColumn()) + "/" + (c.hasParserModuleAuthority() ? 1 : 0)
                    + "/" + (parents.isEmpty() ? "_" : parents);
        }).collect(Collectors.joining("|"))).collect(Collectors.joining(";"));
    }

    private static String trace(String name, List<DependentTypeDag> operands, DependentTypeDag result) {
        var input = operands.stream().flatMap(d -> d.alternatives().stream()).toList();
        var types = new TreeSet<GraphType>();
        DependentColumnEvidence owner = null;
        for (var rows : List.of(input, result.alternatives()))
            for (var product : rows)
                for (var c : product) {
                    types.addAll(c.ancestry());
                    if (c.hasParserModuleAuthority()) {
                        if (owner == null) owner = c;
                        else if (!owner.sharesParserModuleAuthorityWith(c)) throw new AssertionError("foreign trace");
                    }
                }
        var orderedTypes = List.copyOf(types);
        return name + "\t" + encodeRows(input, orderedTypes) + "\t"
                + encodeRows(result.alternatives(), orderedTypes);
    }

    private static void check(String name, int count, DependentTypeDag... args) {
        var operands = List.of(args);
        var result = DependentTypeDag.union(operands);
        if (!matches(operands, result) || result.alternatives().size() != count) throw new AssertionError(name);
        traces.add(trace(name, operands, result));
        outcomes.add(name + "\t" + count);
    }

    private static void reject(String name, Supplier<DependentTypeDag> operation, String message) {
        try { operation.get(); }
        catch (IllegalArgumentException exception) {
            if (!exception.getMessage().contains(message)) throw exception;
            outcomes.add(name + "\tREJECTED"); return;
        }
        throw new AssertionError(name);
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("expected frozen source root and result TSV");
        Path root = Path.of(args[0]), output = Path.of(args[1]);
        traces.clear();
        outcomes.clear();
        outcomes.add("case\tresult");
        outcomes.add("compiler-boundary\t" + A221CompilerContract.verify(root));
        var module = CompUtil.parseEverything_fromString(null, MODEL);
        var foreign = CompUtil.parseEverything_fromString(null, MODEL);
        var a = column(module, "A");
        var b = column(module, "B");
        var c = column(module, "C");
        var p = column(module, "P");
        var u = column(module, "univ");
        var bare = DependentColumnEvidence.exact(u.exactColumn());
        var aa = row(a, a);
        var ab = row(a, b);
        var ba = row(b, a);
        var left = row(u, bare);
        var right = row(bare, u);
        var both = row(u, u);
        check("complete-after-partial", 1, aa, left, both);
        check("complete-before-partial", 1, aa, both, left);
        check("complementary-forward", 1, aa, left, right);
        check("complementary-reverse", 1, aa, right, left);
        check("one-coordinate-missing", 2, aa, left);
        check("exact-and-strict-coordinate", 1, aa, row(a, p));
        check("transitive-ancestry", 1, row(c, b), row(p, b));
        check("opposite-directions", 2, row(a, p), row(p, b));
        check("sibling-products-and-duplicates", 2, ab, ba, ab);
        check("bare-exact-port-only", 2, row(a), row(bare));
        check("typed-empty", 0, DependentTypeDag.empty(2), DependentTypeDag.empty(2));
        check("empty-with-row", 1, ab, DependentTypeDag.empty(2));
        var foreignA = column(foreign, "A");
        reject("identical-text-foreign-module", () -> DependentTypeDag.union(List.of(row(a),row(foreignA))), "module");
        reject("conflicting-paths", () -> DependentTypeDag.union(List.of(row(a),row(DependentColumnEvidence.exact(a.exactColumn())))), "conflicting");
        reject("mixed-widths", () -> DependentTypeDag.union(List.of(aa,row(a))), "arities");
        if (matches(List.of(row(a),row(foreignA)),row(a))) throw new AssertionError("foreign-input");
        if (matches(List.of(row(a),row(DependentColumnEvidence.exact(a.exactColumn()))),row(a)))
            throw new AssertionError("conflicting-input");
        if (matches(List.of(aa, both), aa)) throw new AssertionError("omitted-dominator");
        if (matches(List.of(ab, ba), DependentTypeDag.union(List.of(aa, ab)))) throw new AssertionError("cross-product");
        if (matches(List.of(left, right), left)) throw new AssertionError("lost-origin");
        outcomes.add("oracle-incomplete-crossed-or-lost-authority\tREJECTED");
        // All finite subsets of eight correlated input products, in both source orders.
        var basis = List.of(aa, ab, ba, row(p,b), row(c,b), left, right, both);
        int checked = 0;
        for (int mask = 0; mask < 1 << basis.size(); mask++) {
            var ops = new ArrayList<DependentTypeDag>();
            ops.add(DependentTypeDag.empty(2));
            for (int i = 0; i < basis.size(); i++) if ((mask & (1 << i)) != 0) ops.add(basis.get(i));
            ops.add(DependentTypeDag.empty(2));
            for (int order = 0; order < 2; order++) {
                var observed = DependentTypeDag.union(ops);
                if (!matches(ops, observed)) throw new AssertionError("finite-family-" + mask + "-" + order);
                traces.add(trace("family-" + mask + "-" + order, ops, observed));
                java.util.Collections.reverse(ops);
                checked++;
            }
        }
        Path positive = output.resolveSibling("a221-typed-traces.tsv");
        Path negative = output.resolveSibling("a221-wrong-result.tsv");
        Files.write(positive, traces);
        Files.writeString(negative, trace("omitted-general-product",List.of(aa,both),aa) + "\n");
        replay(positive, output.resolveSibling("a221-lean-traces.log"), true);
        replay(negative, output.resolveSibling("a221-lean-rejection.log"), false);
        outcomes.add("finite-family-order-checks\t" + checked);
        outcomes.add("typed-production-traces\t" + traces.size());
        outcomes.add("lean-wrong-result\tREJECTED");
        Files.write(output,outcomes);
        System.out.println("A221NormalizationTest passed: rows=" + (outcomes.size() - 1));
    }
}
