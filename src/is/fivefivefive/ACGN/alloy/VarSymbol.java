package is.fivefivefive.ACGN.alloy;

import java.util.HashSet;
import java.util.Set;

import is.fivefivefive.ACGN.asg.AugmentedNode;

public class VarSymbol implements Symbol {
    private String type; // signature that the variable is an element of 
    private String varName; // the name of the variable
    private int treeIdScope; // 0 for global symbols;
    private AugmentedNode node; // the node that this symbol is associated with
    private Set<FieldConfiner> fieldConfinerSet; // the set of field confiners that this variable is subject to
    public VarSymbol(String sig, String varName, int treeId) {
        type = sig;
        this.varName = varName;
        treeIdScope = treeId;
        node = new AugmentedNode(-1, 0);
        fieldConfinerSet = new HashSet<>();
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
        return false;
    }
    public int getScopeId() {
        return treeIdScope;
    }
    public Set<FieldConfiner> getFieldConfinerSet() {
        return fieldConfinerSet;
    }
    public void setFieldConfinerSet(Set<FieldConfiner> fieldConfinerSet) {
        this.fieldConfinerSet = fieldConfinerSet;
    }
}
