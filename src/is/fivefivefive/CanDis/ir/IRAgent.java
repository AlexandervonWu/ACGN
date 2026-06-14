package is.fivefivefive.CanDis.ir;

import java.util.HashMap;
import java.util.Map;
import java.util.Queue;
import java.util.List;
import java.util.ArrayList;
import java.util.LinkedList;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.macros.NormalForm;

public class IRAgent {
    private Multigraph graph;
    private Map<AugmentedNode, Integer> tovTracker;
    private List<NormalForm> nfs; // the normal forms from the graph in temporal logical operators order; 
    // try to normalize as much as possible from MASG to the normal form. Try prenexing. 

    public IRAgent(Multigraph graph) {
        this.graph = graph;
        this.nfs = new ArrayList<>();
        this.tovTracker = new HashMap<>();
    }

    public List<NormalForm> normalForms() {
        return nfs;
    }

    public void computeNormalForm() {
        AugmentedNode root = graph.getRoot();
        this.tovTracker = new HashMap<>();
        boolean negation = false;
        Queue<AugmentedNode> queue = new LinkedList<>();
        
    }

    private static boolean flip(boolean f) {
        return f ? false : true;
    }
}
