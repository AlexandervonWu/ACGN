package is.fivefivefive.ACGN.learn;

import java.util.Map;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.etc.BiMap;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import parser.etc.Pair;

public class CodeGenAgent {
    private GlobalVariables gv;
    private MASGVisitor visitor; // the visitor for the specific Alloy Model
    static final int MAX_STEPS = 500;
    private Multigraph groundTruth;
    private Multigraph currentAns;
    private Map<Pair<Symbol, Integer>, float[]> qTable;
    private BiMap<Integer, Symbol> symbolId;
    private Map<Pair<Symbol, Integer>, Float> edgeRewardMap; // reward for each edge
    private int globalNewVarCounter = 100;
    private BiMap<Symbol, AugmentedNode> dynamicUniqueNodes;

    public CodeGenAgent(Multigraph groundTruth, MASGVisitor visitor, GlobalVariables gv, BiMap<Integer, Symbol> symbolId) {
        this.groundTruth = groundTruth;
        this.currentAns = new Multigraph();
        this.visitor = visitor;
        this.gv = gv;
        this.symbolId = symbolId;
        this.dynamicUniqueNodes = new BiMap<Symbol, AugmentedNode>();
    }

    public void initialize() {
        // TODO: Initialize the agent with coarse-grained token candidates and the unique nodes presenting in the model. 
    }
}
