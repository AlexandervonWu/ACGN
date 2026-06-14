package is.fivefivefive.CanDis.ir;

import java.util.HashMap;
import java.util.Map;
import java.util.Queue;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.macros.NormalForm;

public class IRAgent {
    private Multigraph graph;
    private Map<AugmentedNode, Integer> tovTracker;
    private NormalForm nf;
    // try to normalize as much as possible from MASG to the normal form. Try prenexing. 

    public IRAgent(Multigraph graph, NormalForm nf) {
        this.graph = graph;
        this.nf = nf;
        this.tovTracker = new HashMap<>();
    }

    public IRAgent(Multigraph graph) {
        this.graph = graph;
        this.nf = new NormalForm();
        this.tovTracker = new HashMap<>();
    }

    public NormalForm normalForm() {
        return nf;
    }

    public void computeNormalForm() {
        AugmentedNode root = graph.getRoot();
        this.tovTracker = new HashMap<>();
        boolean negation = false;
        
    }

    private static boolean flip(boolean f) {
        return f ? false : true;
    }
}
