package is.fivefivefive.ACGN.alloy;

public class VarSymbol implements Symbol {
    private String type; // signature that the variable is an element of 
    private String varName; // the name of the variable
    private int treeIdScope; // 0 for global symbols;
    public VarSymbol(String sig, String varName, int treeId) {
        type = sig;
        this.varName = varName;
        treeIdScope = treeId;
    }
    public String getType() {
        return type;
    }
    public String getName() {
        return varName;
    }
    public boolean isEndSymbol() {
        return true;
    }
    public int getScopeId() {
        return treeIdScope;
    }
}
