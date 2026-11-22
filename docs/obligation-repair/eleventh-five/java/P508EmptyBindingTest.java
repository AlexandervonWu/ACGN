package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.Decl;
import edu.mit.csail.sdg.ast.Expr;
import edu.mit.csail.sdg.ast.ExprQt;
import edu.mit.csail.sdg.ast.ExprUnary;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter;
import is.fivefivefive.CanDis.core.egraph.AblationEngine;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.Predicate;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

public final class P508EmptyBindingTest {
    private record Example(String id, String expr, String declarations, boolean truth, boolean mustFold) {}
    private record Arm(String name, boolean typed, AblationEngine instance) {}

    private static final String PREFIX = "module p508\nsig A {}\n";
    private static final String PARAMS = "[r:A->A]";
    private static final String HEADER = "case\tarm\tdeclaration_groups\texpected\tobserved";

    private static List<Example> examples() {
        return List.of(
            new Example("bare-unary", "some x:none | no none", "1x1:one", false, true),
            new Example("one", "some x:one none | no none", "1x1:one", false, true),
            new Example("some", "some x:some none | no none", "1x1:some", false, true),
            new Example("set", "some x:set none | no none", "1x1:set", true, false),
            new Example("lone", "some x:lone none | no none", "1x1:lone", true, false),
            new Example("binary-difference", "some x:(r-r) | no none", "1x2:set", true, false),
            new Example("empty-binary-type", "some x:(none->none) | no none", "1x2:set", true, false),
            new Example("empty-ternary-type", "some x:(none->none->none) | no none", "1x3:set", true, false),
            new Example("shared-positive", "some x,y:one none | no none", "2x1:one", false, true),
            new Example("shared-nullable", "some x,y:(none->none) | no none", "2x2:set", true, false),
            new Example("dependent-positive", "some x:A,y:one(x-x) | no none", "1x1:one;1x1:one", false, true),
            new Example("dependent-nullable", "some x:set none,y:lone x | no none", "1x1:set;1x1:lone", true, false),
            new Example("inner-shadow-nullable", "some x:one A | some x:set none | no none", "1x1:one;1x1:set", true, false),
            new Example("inner-shadow-positive", "some x:set none | some x:one none | no none", "1x1:set;1x1:one", false, true),
            new Example("used-nullable", "some x:(none->none) | no x", "1x2:set", true, false),
            new Example("used-binary-difference", "some x:(r-r) | no x", "1x2:set", true, false),
            new Example("all-empty", "all x:one none | some none", "1x1:one", true, true),
            new Example("no-empty", "no x:one none | no none", "1x1:one", true, true),
            new Example("one-empty", "one x:one none | no none", "1x1:one", false, true),
            new Example("lone-empty", "lone x:one none | no none", "1x1:one", true, true),
            new Example("not-one-empty", "not (one x:one none | no none)", "1x1:one", true, true),
            new Example("not-lone-empty", "not (lone x:one none | no none)", "1x1:one", false, true),
            new Example("all-nullable", "all x:lone none | some none", "1x1:lone", false, false),
            new Example("one-nullable", "one x:set none | no none", "1x1:set", true, false));
    }

    private static List<Arm> arms() throws ReflectiveOperationException {
        Class<?> engine = Class.forName(EGraphAblationStudy.class.getName() + "$Engine");
        Method factory = engine.getDeclaredMethod("newEngine");
        factory.setAccessible(true);
        var arms = new ArrayList<Arm>();
        var supported = Set.of("RAW", "RAW_DEBRUIJN", "EGGLOG", "EGGLOG_DEBRUIJN", "SLOTTED", "SLOTTED_TYPED");
        for (Object kind : engine.getEnumConstants()) {
            String name = ((Enum<?>)kind).name();
            if (supported.contains(name))
                arms.add(new Arm(name, name.equals("SLOTTED_TYPED"), (AblationEngine)factory.invoke(kind)));
        }
        require(arms.size() == supported.size(), "Missing production route");
        return arms;
    }

    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    // Inspect Alloy's original resolved declarations, before the production adapter runs.
    private static String declarations(Expr expr) {
        var entries = new ArrayList<String>();
        while (true) {
            if (expr instanceof ExprUnary unary && (unary.op == ExprUnary.Op.NOOP || unary.op == ExprUnary.Op.NOT)) {
                expr = unary.sub;
            } else if (expr instanceof ExprQt quantifier) {
                for (Decl declaration : quantifier.decls) {
                    Expr domain = declaration.expr;
                    int arity = domain.type().arity();
                    String mode = domain.mult == 0 ? (arity == 1 ? "one" : "set") : switch(domain.mult()) {
                        case ONEOF -> "one"; case SOMEOF -> "some"; case SETOF -> "set";
                        case LONEOF -> "lone"; case EXACTLYOF -> "exactly";
                        default -> throw new AssertionError(domain.mult());
                    };
                    entries.add(declaration.names.size() + "x" + arity + ":" + mode);
                }
                expr = quantifier.sub;
            } else return String.join(";", entries);
        }
    }

    private static void observe(List<String> rows, Example e, String arm, boolean equalTrue, boolean equalFalse) {
        require(!(equalTrue && equalFalse), e.id + "/" + arm + " identifies true with false");
        boolean intended = e.truth ? equalTrue : equalFalse;
        boolean contrary = e.truth ? equalFalse : equalTrue;
        require(!contrary, e.id + "/" + arm + " folded to the opposite truth");
        require(!e.mustFold || intended, e.id + "/" + arm + " lost a registered positive fold");
        rows.add(String.join("\t", e.id, arm, e.declarations, Boolean.toString(e.truth),
                equalTrue ? "true" : equalFalse ? "false" : "retained"));
    }

    private static void run(Example e, List<String> rows) throws Exception {
        // A is inhabited so the outer lexical shadow control has exactly the expected existential guard.
        String input = PREFIX.replace("sig A", "one sig A") + "pred test" + PARAMS + " { " + e.expr + " }\n" +
                "pred yes" + PARAMS + " { no none }\npred nope" + PARAMS + " { some none }\n";
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, input);
        var resolved = module.getAllFunc().makeCopy().stream().filter(f -> f.label.equals("this/test")).findFirst().orElseThrow();
        String actual = declarations(resolved.getBody());
        require(e.declarations.equals(actual), e.id + " declaration mismatch " + actual);
        var model = new ModelUnit(null, module);
        var predicates = new HashMap<String, Predicate>();
        model.getPredDeclList().forEach(p -> predicates.put(p.getName(), p));
        var visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(model, null);
        var canonical = new HashMap<String, CanonicalAlloyPipeline.Prepared>();
        for (String name : List.of("test", "yes", "nope")) {
            canonical.put(name, CanonicalAlloyPipeline.prepare(visitor.getForest().get(visitor.getForestId(name))));
        }
        var test = canonical.get("test");
        observe(rows, e, "CANONICAL", test.equivalentTo(canonical.get("yes")), test.equivalentTo(canonical.get("nope")));
        for (Arm arm : arms()) {
            var candidate = AlloyAstTermAdapter.fromPredicate(predicates.get("test"), arm.typed);
            var yes = AlloyAstTermAdapter.fromPredicate(predicates.get("yes"), arm.typed);
            var no = AlloyAstTermAdapter.fromPredicate(predicates.get("nope"), arm.typed);
            observe(rows, e, arm.name, arm.instance.compare(candidate, yes).equivalent,
                    arm.instance.compare(candidate, no).equivalent);
        }
    }

    private static void checkDiscardedDomainPass() throws Exception {
        String source = PREFIX + "pred step" + PARAMS + " {some x:r-r | no none}";
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, source);
        var model = new ModelUnit(null, module);
        var predicate = model.getPredDeclList().get(0);
        var tree = AlloyAstTermAdapter.fromPredicate(predicate, false);
        var quantifier = tree.children().get(tree.children().size()-1);
        var decl = quantifier.children().get(0);
        require(quantifier.head().equals("QF/SOME") && decl.head().startsWith("DECL/"),
                "Expected one parsed quantifier declaration");
        var rewrite = Class.forName("is.fivefivefive.CanDis.core.egraph.AlloyRewriteSystem")
                .getDeclaredMethod("rewriteOnce", decl.getClass());
        rewrite.setAccessible(true);
        Object pass = rewrite.invoke(null, decl);
        var term = pass.getClass().getDeclaredField("term");
        var applications = pass.getClass().getDeclaredField("applications");
        term.setAccessible(true);
        applications.setAccessible(true);
        require(term.get(pass) == decl && applications.getInt(pass) == 0,
                "Discarded arity-erasing domain rewrite reported a committed application");
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2 || !Files.isRegularFile(Path.of(args[0], "lean-toolchain")))
            throw new IllegalArgumentException("Expected source checkout and fresh evidence output path");
        var rows = new ArrayList<String>();
        rows.add(HEADER);
        String census = P508CompilerContract.inspect(Path.of(args[0]), Path.of(args[1]).resolveSibling("empty-binding-source.tsv"));
        checkDiscardedDomainPass();
        for (Example e : examples()) run(e, rows);
        Files.write(Path.of(args[1]), rows, java.nio.file.StandardOpenOption.CREATE_NEW);
        long retained = rows.stream().filter(s -> s.endsWith("\tretained")).count();
        System.out.println("P5-08 PASS cases=" + examples().size() + " routes=7 observations=" + (rows.size()-1) +
                " folded=" + (rows.size()-1-retained) + " retained=" + retained + " discardedApplications=0 compiler=" + census);
    }
}
