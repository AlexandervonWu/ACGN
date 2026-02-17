package is.fivefivefive.ACGN.structure;

import java.util.Map;
import java.util.HashMap;
import is.fivefivefive.ACGN.alloy.Symbol;

import is.fivefivefive.ACGN.asg.Multigraph;

public class RLScopeTreeNode extends ScopeTreeNode {
    private Map<Symbol, Float> qDist;
    public RLScopeTreeNode(int id, ScopeTreeNode parent, Multigraph affl) {
        super(id, parent, affl);
        this.qDist = new HashMap<>();
    }
    public RLScopeTreeNode(int id, ScopeTreeNode parent) {
        super(id, parent);
    }
    public RLScopeTreeNode(int id, Map<String, Symbol> symbols, ScopeTreeNode parent, Multigraph affl) {
        super(id, symbols, parent, affl);
    }
    public Map<Symbol, Float> getqDist() {
        return qDist;
    }
    public void setqDist(Map<Symbol, Float> qDist) {
        this.qDist = qDist;
    }

}
