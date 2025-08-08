package is.fivefivefive.ACGN.test;

import java.util.List;

import edu.mit.csail.sdg.parser.CompModule;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.learn.Hyperparams;
import is.fivefivefive.ACGN.learn.RLAgentFrame;
import is.fivefivefive.ACGN.learn.Rewarder;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.util.InstancePool;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.Node;
import parser.ast.nodes.Predicate;
import parser.ast.visitor.ASTNodeFinder;
import parser.etc.Pair;

public class RLTest {
    private static Pair<Boolean, Double> learn(GlobalVariables gv, String path, int maxSteps) {
        CompModule cm = Rewarder.fromFile(path);
        if (cm == null) {
            System.out.println("Failed to compile Alloy module at " + path);
            return Pair.of(false, 0.0);
        }
        ModelUnit mu = new ModelUnit(null, cm);
        List<Node> predicates = ASTNodeFinder.findNodesByTypeAndName(mu, Predicate.class, "inv", false);
        predicates.addAll(ASTNodeFinder.findNodesByTypeAndName(mu, Predicate.class, "Inv", false));
        predicates.addAll(ASTNodeFinder.findNodesByTypeAndName(mu, Predicate.class, "prop", false));
        if (predicates.isEmpty()) {
            System.out.println("No predicate found with the name 'inv', 'Inv', or 'prop'.");
            return Pair.of(false, 0.0);
        }
        if (predicates.size() > 2) {
            System.out.println("Warning: More than 2 predicates found with the name 'inv', 'Inv', or 'prop'. Using the first one.");
        }
        Node groundTruthNode = predicates.get(1);
        Node studentSolutionNode = predicates.get(0);
        Predicate groundTruth = (Predicate) groundTruthNode;
        Predicate studentSolution = (Predicate) studentSolutionNode;
        MASGVisitor visitor = new MASGVisitor(gv);
        AugmentedNode groundTruthRoot = groundTruth.accept(visitor, null);
        AugmentedNode studentSolutionRoot = studentSolution.accept(visitor, null);
        Multigraph groundTruthGraph = visitor.getForest().get(0);
        Multigraph studentSolutionGraph = visitor.getForest().get(1);
        if (groundTruthRoot == null || studentSolutionRoot == null) {
            System.out.println("Failed to create AugmentedNode for ground truth or student solution.");
            throw new RuntimeException("AugmentedNode creation failed.");
        }
        // unique nodes? gv? 
        DoubleMap<Symbol, AugmentedNode> uniqueNodes = visitor.getUniqueNode();
        RLAgentFrame agent = new RLAgentFrame(gv, groundTruthGraph, uniqueNodes, studentSolutionGraph);
        agent.initialize();
        // begin RL
        Pair<InstancePool, InstancePool> instancePoolPair = Rewarder.instances(cm, groundTruth.getName(), Hyperparams.POOL_SIZE);
        double maxReward = 0;
        for (int i = 0; i < maxSteps; ++i) {
            String name = "invX" + i;
            String nextPredCode = agent.generateNextPred(name);
            double reward = Rewarder.computeReward(cm, instancePoolPair, groundTruth.getName(), name, Hyperparams.POOL_SIZE);
            if (reward > maxReward) {
                maxReward = reward;
            }
            System.out.println("Step " + i + ": reward = " + reward + ", maxReward = " + maxReward);
            if (reward == 1) {
                System.out.println("Successfully learned the predicate: ");
                System.out.println(nextPredCode);
                return Pair.of(true, i + 1.0);
            }
        }
        System.out.println("Failed to learn the predicate within the maximum steps.");
        return Pair.of(false, maxReward);
    }
}
