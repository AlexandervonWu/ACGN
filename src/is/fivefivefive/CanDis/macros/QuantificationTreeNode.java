package edu.uta.cse.scope.macros;

import java.util.List;
import java.util.ArrayList;

/** 
 * This class encodes the quantification tree for a formula or function. 
 * For example, for a formula like "all x : T, all y : x.Foo, (some z : y.Bar, P(x,y,z)) and (some w : x.Baz, Q(x,w))", the quantification tree would be:
 * *          all x : T
 * *          /       \
 * *     all y : x.Foo   some w : x.Baz
 * *     /               \
 * * some z : y.Bar     [Q(x,w)]
 * *     \
 * *     [P(x,y,z)]
 * it basically stores the quantification structure of the formula, and can be used to generate the normal form of the formula.
 */
public class QuantificationTreeNode {
    private List<QuantiVar> quantiVars; // the quantified variables at this node
    private List<QuantificationTreeNode> children; // the child nodes of this node
    private QuantificationTreeNode parent; // the parent node of this node, null for the root node
    private String quantifier; // the quantifier at this node, e.g., "all", "some", "lone", "one"
    private boolean isDisj; // if these variables in the QTN are disjoint, which is determined by the presence of "disj" keyword in the original formula.
    private String type; // the reduced primitive type of the quantified variables at this node, type-checked by the intepreter, and used to keep De Bruijn equivalence. 
    // invariant: all quantified variables at this node have the same type, which is the same as the type of the quantifier in the original formula. 

    public QuantificationTreeNode(String quantifier, List<QuantiVar> quantiVars, List<QuantificationTreeNode> children, QuantificationTreeNode parent, boolean isDisj, String type) {
        this.quantiVars = quantiVars;
        this.children = children;
        this.parent = parent;
        this.quantifier = quantifier;
        this.isDisj = isDisj;
        this.type = type;

    }
    public QuantificationTreeNode(String quantifier, List<QuantiVar> quantiVars, List<QuantificationTreeNode> children, boolean isDisj, String type) {
        this(quantifier, quantiVars, children, null, isDisj, type);
    }
    public QuantificationTreeNode(String quantifier, List<QuantiVar> quantiVars, boolean isDisj, String type) {
        this(quantifier, quantiVars, new ArrayList<>(), null, isDisj, type);
    }
    public QuantificationTreeNode(String quantifier, List<QuantiVar> quantiVars, QuantificationTreeNode parent, boolean isDisj, String type) {
        this(quantifier, quantiVars, new ArrayList<>(), parent, isDisj, type);
    }
    public List<QuantiVar> getQuantiVars() {
        return quantiVars;
    }
    public List<QuantificationTreeNode> getChildren() {
        return children;
    }
    public QuantificationTreeNode getParent() {
        return parent;
    }
    public void addChild(QuantificationTreeNode child) {
        children.add(child);
    }
    public void addQuantiVar(QuantiVar quantiVar) {
        quantiVars.add(quantiVar);
    }
    public void setParent(QuantificationTreeNode parent) {
        this.parent = parent;
    }
    public String getQuantifier() {
        return quantifier;
    }
    public boolean isDisj() {
        return isDisj;
    }
    public String getType() {
        return type;
    }
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("QuantificationTreeNode{quantiVars=");
        sb.append(quantiVars);
        sb.append(", children=");
        sb.append(children);
        sb.append("}");
        return sb.toString();
    }
}
