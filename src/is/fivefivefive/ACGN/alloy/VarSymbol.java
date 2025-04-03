package is.fivefivefive.ACGN.alloy;

import is.fivefivefive.ACGN.asg.AugmentedNode;

public class VarSymbol implements Symbol {
    private String type; // signature that the variable is an element of 
    private String varName; // the name of the variable
    private int treeIdScope; // 0 for global symbols;
    private AugmentedNode node; // the node that this symbol is associated with
    public VarSymbol(String sig, String varName, int treeId) {
        type = sig;
        this.varName = varName;
        treeIdScope = treeId;
        node = new AugmentedNode(-1, 0);
    }
    public String getType() {
        return type;
    }
    public String getName() {
        return varName;
    }
    public AugmentedNode toNode() {
        return node;
    }
    public boolean isEndSymbol() {
        return true;
    }
    public int getScopeId() {
        return treeIdScope;
    }
}
