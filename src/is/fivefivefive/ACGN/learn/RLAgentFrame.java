package is.fivefivefive.ACGN.learn;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import is.fivefivefive.ACGN.alloy.RefSymbol;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.util.Probability;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
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
    private DoubleMap<Integer, Symbol> symbolId;
    private DoubleMap<Symbol, AugmentedNode> uniqueNodes;
    public RLAgentFrame(GlobalVariables gv, Multigraph groundTruth, DoubleMap<Symbol, AugmentedNode> uniqueNodes) {
        this.gv = gv;
        this.groundTruth = groundTruth;
        this.uniqueNodes = uniqueNodes;
        qTable = new HashMap<Pair<Symbol, Integer>, float[]>();
        symbolId = new DoubleMap<Integer, Symbol>();
    }
    public RLAgentFrame(GlobalVariables gv, Multigraph groundTruth, DoubleMap<Symbol, AugmentedNode> uniqueNodes, Multigraph currentAns) {
        this.gv = gv;
        this.groundTruth = groundTruth;
        this.currentAns = currentAns;
        this.uniqueNodes = uniqueNodes;
        qTable = new HashMap<Pair<Symbol, Integer>, float[]>();
        symbolId = new DoubleMap<Integer, Symbol>();
    }

    /**
     * Initialize the Q-table with the pretrained signatures.
     * The Q-table is a mapping from (source symbol, position) to a set of probabilities for each candidate symbol.
     */
    public void initialize() {
        // initialize the Q-table
        Map<Pair<Symbol, Integer>, Set<Symbol>> edgeMap = gv.getEdgeMap();
        for (Pair<Symbol, Integer> positional : edgeMap.keySet()) {
            // calculate by the pretrained signatures
            float[] dist = Probability.probabilitiesBySignatures(gv, uniqueNodes, positional.a, positional.b);
            qTable.put(positional, dist);
            Symbol parent = positional.a;
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

    public float localReward(Symbol source, int position, Symbol candidate) {
        return 0.0f; // Placeholder for local reward calculation
    }

    public String generateNextPred(String predName) {
        // make a root node
        AugmentedNode rootNode = new AugmentedNode(-1, -1);
        Symbol root = new RefSymbol(rootNode, predName);
        rootNode.setSymbol(root);
        Multigraph predGraph = new Multigraph(rootNode, gv);
        // same parameters as the ground truth
        List<MASGEdge> downlinks = groundTruth.getRoot().getDownlinks();
        int iter = 2;
        if (downlinks.size() > 1) {
            for (int i = 0; i < downlinks.size() - 1; ++i) {
                MASGEdge edge = downlinks.get(i);
                AugmentedNode param = edge.getTarget();
                predGraph.connect(rootNode, param, predGraph, iter, 1);
                iter++;
            }
        }
        // generate the body root. 
        generateNextNode(rootNode, 1, new HashMap<>());
        return null;

    }
    public void generateNextNode(AugmentedNode localRoot, int position, Map<Symbol, Integer> tovMap) {
        // TODO : TOV TRACKER. 
        if (position > localRoot.getMaxDownlinks()) {
            return; // No more positions to explore
        }
        Symbol localRootSym = localRoot.getSymbol();
        tovMap.putIfAbsent(localRootSym, 0);
        tovMap.put(localRootSym, tovMap.get(localRootSym) + 1);
        Random rand = new Random();
        Set<Symbol> candidates = gv.getCandidates(localRootSym, position);
        float[] distribution = qTable.get(Pair.of(localRootSym, position));
        if (candidates == null || candidates.isEmpty() || distribution == null) {
            return; // No candidates or no distribution available
        }
        // Select a candidate based on the distribution
        float randomValue = rand.nextFloat();
        float cumulativeProbability = 0.0f;
        Symbol selectedCandidate = null;
        for (int i = 0; i < candidates.size(); i++) {
            cumulativeProbability += distribution[i];
            if (randomValue <= cumulativeProbability) {
                selectedCandidate = symbolId.get(i);
                break;
            }
        }
        if (selectedCandidate == null) {
            return; // No candidate selected
        }
        // Create a new node for the selected candidate
        // AugmentedNode newNode = 
        AugmentedNode newNode = uniqueNodes.get(selectedCandidate);
        localRoot.connect(newNode, position, currentAns, tovMap.get(localRootSym));
        // TODO: Recursively generate the next node
        if (!(newNode == MASGVisitor.END_NODE)) {
            // next sibling
            generateNextNode(localRoot, position + 1, tovMap);
        }
        if (newNode.getMaxDownlinks() > 0) {
            // first child
            generateNextNode(newNode, 1, tovMap);
        }
    }
    public void testMethod() {

    }
}
