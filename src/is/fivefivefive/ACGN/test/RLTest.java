package is.fivefivefive.ACGN.test;

import java.io.File;
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
    public static final boolean DEBUG = true;
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
        MASGVisitor visitor = new MASGVisitor();
        visitor.visit(mu, null);
        Multigraph groundTruthGraph = visitor.getForest().get(2);
        
        Multigraph studentSolutionGraph = visitor.getForest().get(1);
        AugmentedNode groundTruthRoot = groundTruthGraph.getRoot();
        AugmentedNode studentSolutionRoot = studentSolutionGraph.getRoot();
        if (groundTruthRoot == null || studentSolutionRoot == null) {
            System.out.println("Failed to create AugmentedNode for ground truth or student solution.");
            throw new RuntimeException("AugmentedNode creation failed.");
        }
        // unique nodes? gv? 
        DoubleMap<Symbol, AugmentedNode> uniqueNodes = visitor.getUniqueNode();
        System.out.println(uniqueNodes.rget(groundTruthGraph.getRoot()).getName());
        System.out.println(uniqueNodes);
        RLAgentFrame agent = new RLAgentFrame(gv, groundTruthGraph, uniqueNodes, studentSolutionGraph);
        agent.initialize();
        // begin RL
        Pair<InstancePool, InstancePool> instancePoolPair = Rewarder.instances(cm, groundTruth.getName(), Hyperparams.POOL_SIZE);
        double maxReward = 0;
        for (int i = 0; i < maxSteps; ++i) {
            String name = "invX" + i;
            String nextPredCode = agent.generateNextPred(name);
            if (DEBUG) {
                System.out.println(nextPredCode);
            }
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

    public static void main(String[] args) {
        GlobalVariables gv = GlobalVariables.readFromFile("global_variables.ser");
        if (gv == null) {
            System.out.println("Failed to load global variables.");
            return;
        }
        final int CPU_THREADS = 32;
        // parallelize by files
        String path = "classified-data";
        File dir = new File(path);
        if (!dir.exists() || !dir.isDirectory()) {
            System.out.println("Invalid directory: " + path);
            return;
        }
        File[] files = dir.listFiles();
        if (files == null || files.length == 0) {
            System.out.println("No files found in the directory: " + path);
            return;
        }
        // PARALLELIZE
        for (File file : files) {
            // first layer are still directories
            if (file.isDirectory()) {
                System.out.println("Processing directory: " + file.getName());
                String subDirPath = file.getAbsolutePath();
                File[] subFiles = new File(subDirPath).listFiles();
                
                if (subFiles != null && subFiles.length > 0) {
                    for (File subFile : subFiles) {
                        String dirName = subFile.getName();
                        File[] subsubFiles = subFile.listFiles();
                        for (File subsubFile : subsubFiles) {
                            if (subsubFile.isDirectory()) {
                                System.out.println("Processing subdirectory: " + subsubFile.getName());
                            } else if (subsubFile.isFile() && subsubFile.getName().endsWith(".als")) {
                                // add a new thread for each file
                                System.out.println("Processing file: " + subsubFile.getName());
                                Pair<Boolean, Double> result = learn(gv, subsubFile.getAbsolutePath(), 1000);
                                if (result.a) {
                                    System.out.println("Successfully learned from " + subsubFile.getName() + " in " + result.b + " steps.");
                                } else {
                                    System.out.println("Failed to learn from " + subsubFile.getName() + ". Max reward: " + result.b);
                                }
                            }
                        }
                    }
                } else {
                    System.out.println("No .als files found in the directory: " + subDirPath
                            + ". Skipping this directory.");
                }
            }
        }
        System.out.println("All files processed.");
    }
}
