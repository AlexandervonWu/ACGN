package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import parser.ast.nodes.ModelUnit;

public final class MASGVisitorTypeRegressionTest {
    private MASGVisitorTypeRegressionTest() {
    }

    public static void main(String[] args) throws Exception {
        String source = String.join("\n",
                "sig User { follows: set User }",
                "sig Photo {}",
                "pred candidate {",
                "  all x: univ | x in User implies x in User",
                "  all u: User | all f: u - u.follows | f in User",
                "  all y: User | some z: y | z in User",
                "  all n: none | n = n",
                "}",
                "pred oracle { no none }",
                "assert quantified {",
                "  all p: Photo, u1, u2: User | u1 = u2 implies p = p",
                "}");

        CompModule module = CompUtil.parseEverything_fromString(A4Reporter.NOP, source);
        MASGVisitor visitor = new MASGVisitor(new GlobalVariables());
        visitor.visit(new ModelUnit(null, module), null);

        Multigraph candidate = visitor.getForest().get(1);
        Multigraph oracle = visitor.getForest().get(2);
        if (candidate == null || oracle == null) {
            throw new AssertionError("Expected both predicate graphs");
        }
        int graphSize = Canonical.canonicalFormSize(candidate);
        int graphDistance = Canonical.distance(candidate, oracle);
        Canonical.Prepared preparedCandidate = Canonical.prepare(candidate);
        Canonical.Prepared preparedOracle = Canonical.prepare(oracle);
        if (graphSize != Canonical.canonicalFormSize(preparedCandidate)
                || graphDistance != Canonical.distance(preparedCandidate, preparedOracle)
                || !Canonical.irTemporalFol(candidate).equals(Canonical.irTemporalFol(preparedCandidate))
                || !Canonical.edits(candidate, oracle).equals(Canonical.edits(preparedCandidate, preparedOracle))) {
            throw new AssertionError("Prepared canonical form changed graph-based results");
        }
        System.out.println("MASGVisitorTypeRegressionTest passed");
    }
}
