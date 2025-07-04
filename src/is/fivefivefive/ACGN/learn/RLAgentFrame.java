package is.fivefivefive.ACGN.learn;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.util.Probability;
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

    public void testMethod() {

    }
}
