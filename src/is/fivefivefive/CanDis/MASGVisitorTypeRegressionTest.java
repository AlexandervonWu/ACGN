package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.core.QuantiVar;
import parser.ast.nodes.ModelUnit;

public final class MASGVisitorTypeRegressionTest {
    private MASGVisitorTypeRegressionTest() {
    }

    public static void main(String[] args) throws Exception {
        String source = String.join("\n",
                "sig User { follows: set User }",
                "sig Photo {}",
                "sig File {}",
                "sig Protected, Trash in File {}",
                "pred candidate {",
                "  all x: univ | x in User implies x in User",
                "  all u: User | all f: u - u.follows | f in User",
                "  all y: User | some z: y | z in User",
                "  all n: none | n = n",
                "  all pt: Protected & Trash | pt in File",
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
        long eclasses = Canonical.eclassCount(preparedCandidate);
        long enodes = Canonical.enodeCount(preparedCandidate);
        if (eclasses <= 0 || enodes < eclasses) {
            throw new AssertionError("Prepared canonical form did not retain valid e-graph counts");
        }
        boolean guardedPrimitiveCarrier = false;
        for (NormalForm form : preparedCandidate.normalizedForms()) {
            for (QuantiVar variable : form.getMatrixQuantiVars()) {
                if (variable.getOriginalNames().contains("pt")) {
                    guardedPrimitiveCarrier = "File".equals(variable.getTypeName())
                            && "univ".equals(variable.getCarrierTypeName());
                }
            }
        }
        if (!guardedPrimitiveCarrier) {
            throw new AssertionError(
                    "A guarded binder did not separate primitive color from prenex carrier");
        }
        System.out.println("MASGVisitorTypeRegressionTest passed");
    }
}
