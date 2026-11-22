package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.egraph.*;
import java.util.ArrayDeque;
import java.util.List;
import parser.ast.nodes.*;

public final class P506MutableDomainTest {
    private static final String SOURCE = """
            module domain_edits
            sig A, B {}
            pred target[x: (A + B) & (B + A)] { x in none }
            pred decline[x: (A + B) & (B + A)] { some none }
            pred relation[x: A -> B] { some x }
            """;
    private record Input(CompModule module, ModelUnit tree, Predicate target, Predicate decline, Predicate relation) {}
    private static Input input() throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, SOURCE);
        var tree = new ModelUnit(null, module);
        var preds = tree.getPredDeclList();
        return new Input(module, tree, preds.stream().filter(p->p.getName().equals("target")).findFirst().orElseThrow(),
                preds.stream().filter(p->p.getName().equals("decline")).findFirst().orElseThrow(),
                preds.stream().filter(p->p.getName().equals("relation")).findFirst().orElseThrow());
    }
    private static void require(boolean condition, String diagnostic) {
        if (!condition) throw new AssertionError(diagnostic);
    }

    private static BinaryExpr innerSum(ExprOrFormula domain) {
        var nodes = new ArrayDeque<Node>();
        nodes.push(domain);
        while (!nodes.isEmpty()) {
            Node n = nodes.pop();
            if (n instanceof BinaryExpr b && b.getOp() == BinaryExpr.BinaryOp.PLUS) return b;
            for (Node child : n.getChildren()) if (child != null) nodes.push(child);
        }
        throw new AssertionError("missing nested union");
    }

    private static boolean rawFold(Input input) {
        AlloyTerm target = AlloyAstTermAdapter.fromPredicate(input.target,true);
        AlloyTerm decline = AlloyAstTermAdapter.fromPredicate(input.decline,true);
        // Reuse the precise currently converted declaration for the false reference.
        // A changed domain cannot make the comparison fail on a parameter mismatch.
        AlloyTerm sameDeclaration = AlloyTerm.node("PREDICATE", target.children().get(0), decline.children().get(1));
        boolean result = new JavaEgglog().compare(target, sameDeclaration).equivalent;
        for (var engine : List.<AblationEngine>of(new RawEGraph(), new RawDeBruijnEGraph(), new JavaEgglogDeBruijn(),
                new SlottedEGraph(), new SlottedEGraph(true))) {
            require(engine.compare(target,sameDeclaration).equivalent == result, "different raw guard in " + engine.getClass());
        }
        return result;
    }

    private static boolean canonicalFold(Input input) {
        var visitor = new MASGVisitor(new GlobalVariables(),input.module);
        visitor.visit(input.tree,null);
        var graph = visitor.getForest().get(visitor.getForestId("target"));
        var matrix = Canonical.prepare(graph).normalizedForms().get(0).getCertificationMatrixEGraph();
        var nodes = new ArrayDeque<EGraphNode>();
        nodes.push(matrix);
        while (!nodes.isEmpty()) {
            var node = nodes.pop();
            if (node.getOpcode()==EGraphNode.Opcode.CONSTANT && "false".equals(node.getSourceName())) return true;
            node.getChildren().forEach(nodes::push);
        }
        return false;
    }

    public static void run(String edit) throws Exception {
        Input input=input();
        var declaration=input.target.getParamList().get(0);
        var slot=ResolvedBindingOrigins.declaration(declaration).get(0);
        require(slot.implicitOne() && rawFold(input) && canonicalFold(input), "valid complex unary domain");
        var domain=declaration.getExpr();
        var sum=innerSum(domain);
        Runnable restore;
        switch (edit) {
            case "adapter-type" -> {
                var original=domain.getType();
                domain.setType(input.relation.getParamList().get(0).getExpr().getType());
                require(domain.getType().arity()==2, "replacement must be binary");
                restore=()->domain.setType(original);
            }
            case "adapter-operator" -> {
                var original=sum.getOp();
                sum.setOp(BinaryExpr.BinaryOp.INTERSECT);
                restore=()->sum.setOp(original);
            }
            case "adapter-arity-operator" -> {
                var original=sum.getOp();
                sum.setOp(BinaryExpr.BinaryOp.ARROW);
                restore=()->sum.setOp(original);
            }
            case "adapter-nested-operand" -> {
                var original=sum.getRight();
                sum.setRight(sum.getLeft());
                restore=()->sum.setRight(original);
            }
            case "adapter-children" -> {
                var original=sum.getChildren().get(1);
                sum.getChildren().set(1,sum.getChildren().get(0));
                restore=()->sum.getChildren().set(1,original);
            }
            default -> throw new AssertionError("unknown edit");
        }
        require(ResolvedBindingOrigins.declaration(declaration).isEmpty(), "stale slot issued for "+edit);
        require(!rawFold(input), "raw term folded for "+edit);
        require(!canonicalFold(input), "canonical matrix folded for "+edit);
        restore.run();
        require(ResolvedBindingOrigins.declaration(declaration).get(0)==slot && rawFold(input) && canonicalFold(input),
                "restored source no longer matches "+edit);
    }
}
