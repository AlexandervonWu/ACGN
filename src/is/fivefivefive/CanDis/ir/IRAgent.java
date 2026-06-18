package is.fivefivefive.CanDis.ir;

import java.util.HashMap;
import java.util.Map;
import java.util.Queue;
import java.util.List;
import java.util.ArrayList;
import java.util.LinkedList;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.macros.NormalForm;
import is.fivefivefive.CanDis.macros.NormalForm.TemporalOp;
import parser.etc.Pair;

public class IRAgent {
    private Multigraph graph;
    
    private List<NormalForm> nfs; // the normal forms from the graph in temporal logical operators order; 
    // try to normalize as much as possible from MASG to the normal form. Try prenexing. 

    public IRAgent(Multigraph graph) {
        this.graph = graph;
        this.nfs = new ArrayList<>();
    }

    public List<NormalForm> normalForms() {
        return nfs;
    }

    public void computeNormalForm() {
        Map<AugmentedNode, Integer> tovTracker = new HashMap<>(); // track the time of visit
        AugmentedNode root = graph.getRoot();
        boolean negation = false;
        Map<Pair<AugmentedNode, Integer>, NormalForm> anchor = new HashMap<>(); // anchor each pair of (node, time of visit) to its normal form up to temporals
        Queue<AugmentedNode> queue = new LinkedList<>();
        queue.add(graph.getRoot());
        while (!queue.isEmpty()) {
            AugmentedNode node = queue.poll();
            tovTracker.putIfAbsent(node, 0);
            int tov = tovTracker.get(node) + 1;
            tovTracker.put(node, tov);
            List<MASGEdge> downlinksAtTov = node.getDownlinksAtTimeOfVisit(graph, tov);
            Symbol symbol = node.getSymbol();
            switch (symbol.getClass().getSimpleName()) {
                case "PredRootSymbol":
                    NormalForm rootNf = new NormalForm(TemporalOp.NONE);
                    anchor.put(Pair.of(node, tov), rootNf);
                    
                case "MiddleSymbol":
                    switch (root.getSyntactic()) {
                        case -127:
                            // RelDecl Roots; put decls into 
                            switch ((int) Math.round(root.getSemantic())) {
                                case 1:
                                    
                            }
                    }
            }
            for (MASGEdge downlink : downlinksAtTov) {
                queue.add(downlink.getTarget());
            }
        }
    }

    private static boolean flip(boolean f) {
        return f ? false : true;
    }
}
