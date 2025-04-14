package is.fivefivefive.ACGN.structure;

import is.fivefivefive.ACGN.alloy.Symbol;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.LinkedList;

public class ScopeTreeNode {
    private int id;
    private Set<Symbol> symbols;
    private List<ScopeTreeNode> children;
    private ScopeTreeNode parent;
    public ScopeTreeNode(int id, ScopeTreeNode parent) {
        this.id = id;
        symbols = new HashSet<>();
        children = new LinkedList<>();
        this.parent = parent;
    }
    public ScopeTreeNode(int id, Set<Symbol> symbols, ScopeTreeNode parent) {
        this.id = id;
        this.symbols = symbols;
        children = new LinkedList<>();
        this.parent = parent;
    }
    public List<ScopeTreeNode> getChildren() {
        return children;
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
