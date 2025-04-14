package is.fivefivefive.ACGN.structure;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.Multigraph;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.LinkedList;

public class ScopeTreeNode {
    private int id;
    private Set<Symbol> symbols;
    private List<ScopeTreeNode> children;
    private ScopeTreeNode parent;
    private Multigraph affliation;
    public ScopeTreeNode(int id, ScopeTreeNode parent, Multigraph affl) {
        this.id = id;
        symbols = new HashSet<>();
        children = new LinkedList<>();
        this.parent = parent;
        affliation = affl;
        if (parent != null) {
            parent.addChildren(this);
        }
    }
    public ScopeTreeNode(int id, Set<Symbol> symbols, ScopeTreeNode parent, Multigraph affl) {
        this.id = id;
        this.symbols = symbols;
        children = new LinkedList<>();
        this.parent = parent;
        affliation = affl;
        if (parent != null) {
            parent.addChildren(this);
        }
    }
    public List<ScopeTreeNode> getChildren() {
        return children;
    }
    public Multigraph getAffliation() {
        return affliation;
    }
    public void addChildren(ScopeTreeNode next) {
        children.add(next);
    }
    public Set<Symbol> getSymbols() {
        return symbols;
    }
    public boolean containsSymbol(Symbol sym) {
        return symbols.contains(sym);
    }
    public int getId() {
        return id;
    }
    public ScopeTreeNode getParent() {
        return parent;
    }
    public void addSymbol(Symbol next) {
        symbols.add(next);
    }
    public Set<Symbol> symbolsAvailable() {
        Set<Symbol> result = new HashSet<>();
        result.addAll(symbols);
        ScopeTreeNode current = this;
        while (current.parent != null) {
            current = current.parent;
            result.addAll(current.getSymbols());
        }
        return result;
    }
}
