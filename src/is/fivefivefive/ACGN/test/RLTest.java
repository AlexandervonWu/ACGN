package is.fivefivefive.ACGN.test;

import java.util.List;

import edu.mit.csail.sdg.parser.CompModule;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.learn.RLAgentFrame;
import is.fivefivefive.ACGN.learn.Rewarder;
import is.fivefivefive.ACGN.structure.ScopeTreeNode;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.Node;
import parser.ast.nodes.Predicate;
import parser.ast.visitor.ASTNodeFinder;
import parser.etc.Pair;

public class RLTest {
    private static Pair<Boolean, Integer> learn(GlobalVariables gv, String path, int maxSteps) {
        CompModule cm = Rewarder.fromFile(path);
        if (cm == null) {
            System.out.println("Failed to compile Alloy module at " + path);
            return Pair.of(false, 0);
        }
        ModelUnit mu = new ModelUnit(null, cm);
        List<Node> predicates = ASTNodeFinder.findNodesByTypeAndName(mu, Predicate.class, "inv", false);
        predicates.addAll(ASTNodeFinder.findNodesByTypeAndName(mu, Predicate.class, "Inv", false));
        predicates.addAll(ASTNodeFinder.findNodesByTypeAndName(mu, Predicate.class, "prop", false));
        if (predicates.isEmpty()) {
            System.out.println("No predicate found with the name 'inv', 'Inv', or 'prop'.");
            return Pair.of(false, 0);
        }
        if (predicates.size() > 2) {
            System.out.println("Warning: More than 2 predicates found with the name 'inv', 'Inv', or 'prop'. Using the first one.");
        }
        Node groundTruthNode = predicates.get(1);
        Node studentSolutionNode = predicates.get(0);
        Predicate groundTruth = (Predicate) groundTruthNode;
        Predicate studentSolution = (Predicate) studentSolutionNode;
        MASGVisitor visitor = new MASGVisitor(gv);
        
        return null;
    }
}
