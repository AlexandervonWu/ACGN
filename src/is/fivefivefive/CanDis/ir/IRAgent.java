package is.fivefivefive.CanDis.ir;

import java.util.Map;

import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.macros.NormalForm;

public class IRAgent {
    private Multigraph graph;
    private Map<AugmentedNode, Integer> tovTracker;
    private NormalForm nf;
    // try to normalize as much as possible from MASG to the normal form. Try prenexing. 
}
