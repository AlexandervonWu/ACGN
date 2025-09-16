package is.fivefivefive.ACGN.learn;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import is.fivefivefive.ACGN.alloy.PredRootSymbol;
import is.fivefivefive.ACGN.alloy.RefSymbol;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.codegen.Generator;
import is.fivefivefive.ACGN.etc.BiMap;
import is.fivefivefive.ACGN.test.Playground;
import is.fivefivefive.ACGN.test.RLTest;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.util.Probability;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.AlloyDataProcessor.EdgeCounter;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import parser.etc.Pair;

/**
 * RLAgentFrame is the frame for the RL agent.
 * It contains the global variables, the ground truth, the current answer, and the Q-table.
 * The Q-table is a mapping from (source symbol, position) to a set of probabilities for each candidate symbol.
 */
public class RLAgentFrame {
    private GlobalVariables gv;
    private Multigraph groundTruth;
    private Multigraph currentAns;
    private Map<Pair<Symbol, Integer>, float[]> qTable;
    private BiMap<Integer, Symbol> symbolId;
    // private BiMap<Symbol, AugmentedNode> uniqueNodes;
    public RLAgentFrame(GlobalVariables gv, Multigraph groundTruth, BiMap<Symbol, AugmentedNode> uniqueNodes) {
        this.gv = gv;
        this.groundTruth = groundTruth;
        // this.uniqueNodes = uniqueNodes;
        qTable = gv.getInitQTable() == null ? new HashMap<Pair<Symbol, Integer>, float[]>() : gv.getInitQTable();
        symbolId = new BiMap<Integer, Symbol>();
    }
    public RLAgentFrame(GlobalVariables gv, Multigraph groundTruth, BiMap<Symbol, AugmentedNode> uniqueNodes, Multigraph currentAns) {
        this(gv, groundTruth, uniqueNodes);
        this.currentAns = currentAns;
    }
    // also the case with the initial Q-table
    public RLAgentFrame(GlobalVariables gv, Multigraph groundTruth, BiMap<Symbol, AugmentedNode> uniqueNodes, Multigraph currentAns, Map<Pair<Symbol, Integer>, float[]> qTable) {
        this(gv, groundTruth, uniqueNodes, currentAns);
        this.qTable = qTable;
    }

    /**
     * Initialize the Q-table with the pretrained signatures.
     * The Q-table is a mapping from (source symbol, position) to a set of probabilities for each candidate symbol.
     */
    public void initialize() {
        // initialize the Q-table
        /*if (gv.getInitQTable() != null) {
            qTable = gv.getInitQTable();
            return; // already initialized
        }*/
        Map<Pair<Symbol, Integer>, Set<Symbol>> edgeMap = gv.getEdgeMap();
        for (Pair<Symbol, Integer> positional : edgeMap.keySet()) {
            // calculate by the pretrained signatures
            Symbol transformedA = positional.a instanceof PredRootSymbol ? EdgeCounter.getSymbolForPretrain(positional.a) : positional.a;
            if (!gv.getUniqueNodes().containsKey(transformedA)) {
                System.out.println("Transformed symbol not found in unique nodes: " + transformedA.getType() + " -> " + transformedA.getName());
                continue; // non-presenting symbols
            }
            float[] dist = Probability.probabilitiesBySignatures(gv, gv.getUniqueNodes(), transformedA, positional.b);
            qTable.put(positional, dist);
            Symbol parent = transformedA;
            if (!symbolId.containsValue(parent)) {
                int id = symbolId.size();
                symbolId.put(id, parent);
            }
            for (Symbol child : edgeMap.get(positional)) {
                if (!symbolId.containsValue(child)) {
                    int id = symbolId.size();
                    symbolId.put(id, child);
                }
            }
        }
        gv.setInitQTable(qTable);
    }

    /**
     * Get the probability of a candidate symbol given a source symbol and its position in the ASG.
     * @param source
     * @param position
     * @param candidate
     * @return
     */
    public float getProbability(Symbol source, int position, Symbol candidate) {
        Pair<Symbol, Integer> positional = Pair.of(source, position);
        if (qTable.containsKey(positional)) {
            float[] probabilities = qTable.get(positional);
            int index = symbolId.rget(candidate);
            if (index >= 0 && index < probabilities.length) {
                return probabilities[index];
            }
        }
        return 0.0f; // Default probability if not found
    }

    private static final double INERTIA = Hyperparams.INERTIA;

    /**
     * Update the Q-table with the reward for a given source symbol and its position.
     * The update is done using the inertia and the reward.
     * local inertia wanes 
     * @param source
     * @param position
     * @param reward
     */
    public void updateQTable(Symbol source, int position, float reward) throws IllegalArgumentException {
        float[] qVector = qTable.get(Pair.of(source, position));
        if (qVector == null) {
            throw new IllegalArgumentException("Q-table entry not found for " + source + " at position " + position);
        }
        float[] temp = new float[qVector.length];
        for (int i = 0; i < qVector.length; i++) {
            temp[i] = (float) (Math.log(qVector[i]) * INERTIA + (reward > 0 ? Math.log(reward) * (1 - INERTIA) : 0));
        }
        // Softmax normalization
        float sum = 0.0f;
        for (float value : temp) {
            sum += Math.exp(value);
        }
        for (int i = 0; i < temp.length; i++) {
            temp[i] = (float) (Math.exp(temp[i]) / sum);
        }
        qTable.put(Pair.of(source, position), temp);
    }

    /**
     * Calculate the local reward for a candidate symbol based on its children in the ASG.
     * This method looks for all children of the candidate symbol and calculates the local reward based on their probabilities.
     * * If the candidate symbol has no children, it returns the raw reward.
     * @param source the source symbol from which the candidate is derived.
     * @param position the position in the ASG where the candidate is located.
     * @param candidate the candidate symbol for which the local reward is calculated.
     * @param rawReward the raw reward value associated with the generated current predicate.
     * @return the calculated local reward based on the children of the candidate symbol.
     */
    public float localReward(Symbol source, int position, Symbol candidate, float rawReward) {
        if (candidate == null) {
            throw new IllegalArgumentException("Candidate symbol cannot be null");
        }
        if (candidate.getMaxDownlinks() == 0) {
            return rawReward;
        }
        // look for all children of the candidate
        AugmentedNode candidateNode = gv.getUniqueNodes().get(candidate);
        if (candidateNode == null) {
            throw new IllegalArgumentException("Candidate node not found for " + candidate);
        }
        List<MASGEdge> downlinks = currentAns.edgesUnder(candidateNode);
        if (downlinks.isEmpty()) {
            return rawReward; // No children, return the raw reward
        }
        float ans = 0.0f;
        for (MASGEdge edge : downlinks) {
            AugmentedNode targetNode = edge.getTarget();
            Symbol targetSymbol = targetNode.getSymbol();
            if (targetSymbol == null) {
                throw new IllegalArgumentException("Target symbol cannot be null for edge: " + edge);
            }
            // Calculate the local reward based on the target symbol
            float localImpact = qTable.get(Pair.of(source, position))[symbolId.rget(targetSymbol)];
            float downReward = localReward(candidate, edge.getPosition(), targetSymbol, rawReward);
            ans += localImpact * downReward;
        }
        return ans; // Placeholder for local reward calculation
    }

    /**
     * Generate the next predicate in the ASG based on the ground truth.
     * This method creates a root node and connects it to the parameters of the ground truth.
     * It then generates the body root and recursively generates the next nodes in the ASG.
     * 
     * @param predName The name of the predicate to be generated.
     * @return The generated code as a string.
     */
    public String generateNextPred(String predName) {
        // make a root node
        AugmentedNode rootNode = new AugmentedNode(-1, -1);
        Symbol root = new PredRootSymbol(rootNode, predName);
        rootNode.setSymbol(root);
        root.setMaxDownlinks(1);
        Multigraph predGraph = new Multigraph(rootNode, gv);
        // same parameters as the ground truth
        List<MASGEdge> downlinks = groundTruth.getRoot().getDownlinks();
        if (RLTest.DEBUG) {
            System.out.println("Generating predicate: " + predName);
            System.out.println("Downlinks size: " + downlinks.size());
            // System.out.println(downlinks);
        }
        int iter = 2;
        if (downlinks.size() > 1) {
            for (int i = 0; i < downlinks.size() - 1; ++i) {
                MASGEdge edge = downlinks.get(i);
                AugmentedNode param = new AugmentedNode(edge.getTarget());
                predGraph.addVertex(param);
                predGraph.connect(rootNode, param, predGraph, iter, 1);
                iter++;
            }
        }
        rootNode.setMaxDownlinks(1);
        // generate the body root. 
        generateNextNode(rootNode, 1, new HashMap<>());
        Generator generator = new Generator();
        currentAns = predGraph;
        String code = generator.toCode(currentAns, rootNode, 1);
        return code;

    }

    /**
     * Recursively generate the next node in the ASG based on the current node and its position.
     * This method uses the Q-table to select candidates based on their probabilities.
     * 
     * @param localRoot The current node in the ASG.
     * @param position The position in the ASG where the next node will be generated.
     * @param tovMap A map tracking the number of times each symbol has been visited.
     */
    public void generateNextNode(AugmentedNode localRoot, int position, Map<Symbol, Integer> tovMap) {
        System.out.println("Generating next node for " + localRoot.getSymbol().getName() + " at position " + position);
        BiMap<Symbol, AugmentedNode> uniqueNodes = gv.getUniqueNodes();
        // TODO : TOV TRACKER. 
        if (localRoot.getMaxDownlinks() != -1 && position > localRoot.getMaxDownlinks()) {
            return; // No more positions to explore
        }
        Symbol localRootSym = localRoot.getSymbol();
        if (localRootSym instanceof PredRootSymbol) {
            localRootSym = EdgeCounter.getSymbolForPretrain(localRootSym);
            System.out.println("Transformed type: " + localRootSym.getName());
        }
        tovMap.putIfAbsent(localRootSym, 0);
        tovMap.put(localRootSym, tovMap.get(localRootSym) + 1);
        Random rand = new Random();
        Set<Symbol> candidates = gv.getCandidates(localRootSym, position);
        /*if (RLTest.DEBUG) {
            System.out.println(qTable);
        }*/
        float[] distribution = qTable.get(Pair.of(localRootSym, position));
        System.out.println("Size of distribution: " + (distribution == null ? "null" : distribution.length));
        if (candidates == null || candidates.isEmpty() || distribution == null) {
            return; // No candidates or no distribution available
        }
        // Select a candidate based on the distribution
        float randomValue = rand.nextFloat();
        float cumulativeProbability = 0.0f;
        Symbol selectedCandidate = null;
        int i = 0;
        for (Symbol candidate : candidates) {
            if (!uniqueNodes.containsKey(candidate)) {
                continue;
            }
            cumulativeProbability += distribution[i];
            if (randomValue <= cumulativeProbability) {
                selectedCandidate = candidate;
                if (RLTest.DEBUG) {
                    System.out.println("Selected candidate: " + selectedCandidate.getName() + " with probability: " + distribution[i] + " at position " + position);
                }
                break;
            }
            i++;
        }
        if (selectedCandidate == null) {
            return; // No candidate selected
        }
        // Create a new node for the selected candidate
        // AugmentedNode newNode = 
        /*if (!uniqueNodes.containsKey(selectedCandidate)) {
            uniqueNodes.put(selectedCandidate, gv.getUniqueNodes().get(selectedCandidate));
        }*/
        AugmentedNode newNode = uniqueNodes.get(selectedCandidate);
        // problem here: the newNode is sometimes null, when referring to a concrete node derived from an abstract class; unknown reason. 
        localRoot.connect(newNode, position, currentAns, tovMap.get(localRootSym));
        // TODO: Recursively generate the next node
        if (!(newNode == MASGVisitor.END_NODE) && localRoot.getMaxDownlinks() > position) {
            // next sibling
            generateNextNode(localRoot, position + 1, tovMap);
        }
        boolean shadow = newNode == MASGVisitor.SHADOW_NODE;
        if (shadow) {
            // shadow node is a copy of the original node with a different T.O.V.
            newNode = new AugmentedNode(localRoot);
            newNode.setSymbol(localRoot.getSymbol());
        }
        System.out.println(newNode.getMaxDownlinks());
        if (newNode.getMaxDownlinks() != 0) {
            // first child
            generateNextNode(newNode, 1, tovMap);
        }
    }

    public void testMethod() {

    }
}
