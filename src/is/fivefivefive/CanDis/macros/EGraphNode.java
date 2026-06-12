package edu.uta.cse.scope.macros;

import java.util.List;

import edu.uta.cse.scope.macros.EGraphNode.Metatype;

/**
 * This class represents a node in the slotted e-graph of the matrix of the normal form.
 * The e-graph is a graph representation of the formula, where each node represents a subformula, and edges represent the structure of the formula.
 * For example, for a formula like "P(x) and Q(y)", the e-graph would have a node for "P(x)", a node for "Q(y)", and an edge between them representing the "and" operator. 
 * The e-graph shall be used to make the distance minimal, to capture the symmetry, associativity, commutativity, and other properties of the formula, 
 * which can help to make the distance calculation more accurate and efficient.
 * TODO: define the structure of the e-graph, and how to generate it from the original formula using the Normal Form Visitor.
 */
public class EGraphNode {
    private int id;
    private Opcode opcode; // the semantic operator of this node with a corresponding opcode
    private List<EGraphNode> children; // the child nodes of this node, which are the subformulas of this node
    private boolean isCommutative; // whether the operator of this node is commutative, which can help to capture the symmetry of the formula
    private int maxArity; // the maximum arity of this node, which is the maximum number of children this node can have, and it is determined by the operator of this node
    private boolean flexibleArity; // whether this node has flexible arity, which is determined by the operator of this node, e.g., "and" and "or" have flexible arity, while "implies" and "iff" have fixed arity of 2.
    public enum Metatype {
        ATOMIC, 
        SET, 
        BOOLEAN,
        CONTROL
    }
    public enum Opcode {
        AND,
        OR,
        NOT,
        IMPLIES,
        IFF,
        FORALL,
        EXISTS,
        LONE,
        ONE,
        PREDICATE,
        FUNCTION,
        VARIABLE,
        CONSTANT,
        // ... other operators can be added here
        MODULEDECL,
        OPEN,
        PARAMDECL,
        SIGDECL,
        FIELDDECL
    }
    private Metatype metatype; // the metatype of this node, which can be used to capture the type of the formula, e.g., atomic formula, set formula, boolean formula, etc.
    public EGraphNode(int id, Opcode opcode, List<EGraphNode> children, boolean isCommutative, int maxArity, boolean flexibleArity, Metatype metatype) {
        this.id = id;
        this.opcode = opcode;
        this.children = children;
        this.isCommutative = isCommutative;
        this.maxArity = maxArity;
        this.flexibleArity = flexibleArity;
        this.metatype = metatype;
    }
    public int getId() {
        return id;
    }
    public Opcode getOpcode() {
        return opcode;
    }
    public List<EGraphNode> getChildren() {
        return children;
    }
    public boolean isCommutative() {
        return isCommutative;
    }
    public int getMaxArity() {
        return maxArity;
    }
    public boolean isFlexibleArity() {
        return flexibleArity;
    }
    public void addChild(EGraphNode child) {
        children.add(child);
    }
    public Metatype getMetatype() {
        return metatype;
    }

    /**
     * Rewrite the e-graph with regard to rewriting rules; canonicalize the formula with equality saturation. 
     */
    public void rewrite() {
        // TODO : rewrite this node according to the operator and the structure. 
        for (EGraphNode child : children) {
            child.rewrite();
        }
    }

}
