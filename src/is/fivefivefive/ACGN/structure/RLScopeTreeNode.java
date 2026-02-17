package is.fivefivefive.ACGN.structure;

import java.util.Map;
import java.util.HashMap;
import parser.etc.Pair;
import is.fivefivefive.ACGN.alloy.Symbol;

import is.fivefivefive.ACGN.asg.Multigraph;

public class RLScopeTreeNode extends ScopeTreeNode {
    private Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qDist;
    public RLScopeTreeNode(int id, ScopeTreeNode parent) {
        super(id, parent);
        this.qDist = new HashMap<>();
    }
    public RLScopeTreeNode(int id, ScopeTreeNode parent, Multigraph affl) {
        super(id, parent, affl);
        this.qDist = new HashMap<>();
    }
    public RLScopeTreeNode(int id, Map<String, Symbol> symbols, ScopeTreeNode parent, Multigraph affl) {
        super(id, symbols, parent, affl);
        this.qDist = new HashMap<>();
    }
    public RLScopeTreeNode(int id, RLScopeTreeNode parent) {
        super(id, parent);
        this.qDist = parent.getqDist();
    }
    public RLScopeTreeNode(int id, RLScopeTreeNode parent, Multigraph affl) {
        super(id, parent, affl);
        this.qDist = parent.getqDist();
    }
    public RLScopeTreeNode(int id, Map<String, Symbol> symbols, RLScopeTreeNode parent, Multigraph affl) {
        super(id, symbols, parent, affl);
        this.qDist = parent.getqDist();
    }
    public RLScopeTreeNode(int id, Map<String, Symbol> symbols, ScopeTreeNode parent, Multigraph affl, Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qDist) {
        super(id, symbols, parent, affl);
        this.qDist = qDist;
    }
    public Map<Pair<Symbol, Integer>, Map<Symbol, Float>> getqDist() {
        return qDist;
    }
    public void setqDist(Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qDist) {
        this.qDist = qDist;
    }
    public void resetQDist() {
        this.qDist = new HashMap<>();
        for (ScopeTreeNode children : getChildren()) {
            if (children instanceof RLScopeTreeNode) {
                ((RLScopeTreeNode) children).resetQDist();
            }
        }
    }
}
