package is.fivefivefive.ACGN.learn;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.util.Probability;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import parser.etc.Pair;

public class RLAgentFrame {
    private GlobalVariables gv;
    private Multigraph groundTruth;
    private Multigraph currentAns;
    private Map<Pair<Symbol, Integer>, List<Double>> qTable;
    private DoubleMap<Integer, Symbol> symbolId;
    public RLAgentFrame(GlobalVariables gv, Multigraph groundTruth) {
        this.gv = gv;
        this.groundTruth = groundTruth;
        qTable = new HashMap<Pair<Symbol, Integer>, List<Double>>();
        symbolId = new DoubleMap<Integer, Symbol>();
    }
    public RLAgentFrame(GlobalVariables gv, Multigraph groundTruth, Multigraph currentAns) {
        this.gv = gv;
        this.groundTruth = groundTruth;
        this.currentAns = currentAns;
        qTable = new HashMap<Pair<Symbol, Integer>, List<Double>>();
        symbolId = new DoubleMap<Integer, Symbol>();
    }
    public void testMethod() {

    }
}
