package is.fivefivefive.CanDis.macros;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;


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
    private String sourceName;
    private String sourceType;
    private String alphaName;
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
        PREDICATE,
        FUNCTION,
        VARIABLE,
        GLOBALBINDING,
        CONSTANT,
        TEMPORALROOT,
        ASSERTION,
        CHECK,
        RUN,
        FACT,
        LET,
        DUMMY,
        REF,
        SHADOW,
        END,

        // STRUCTURAL IR NODES
        ITE,
        CALL,
        LIST,
        DISJOINT_LIST,
        TOTALORDER_LIST,
        COMPREHENSION,
        SUM,

        // TEMPORAL LEAVES
        RELEASES,
        SINCE,
        TRIGGERED,
        UNTIL,
        BEFORE,
        HISTORICALLY,
        ONCE,
        ALWAYS,
        EVENTUALLY,
        AFTER,

        // FORMULA OPERATORS
        EQUALS,
        NOT_EQUALS,
        GT,
        GTE,
        IN,
        LT,
        LTE,
        NOT_GT,
        NOT_GTE,
        NOT_IN,
        NOT_LT,
        NOT_LTE,
        SOME,
        NO,

        // EXPRESSION OPERATORS
        ARROW,
        ANY_ARROW_SOME,
        ANY_ARROW_ONE,
        ANY_ARROW_LONE,
        SOME_ARROW_ANY,
        SOME_ARROW_SOME,
        SOME_ARROW_ONE,
        SOME_ARROW_LONE,
        ONE_ARROW_ANY,
        ONE_ARROW_SOME,
        ONE_ARROW_ONE,
        ONE_ARROW_LONE,
        LONE_ARROW_ANY,
        LONE_ARROW_SOME,
        LONE_ARROW_ONE,
        LONE_ARROW_LONE,
        ISSEQ_ARROW_LONE,
        JOIN,
        DOMAIN,
        RANGE,
        INTERSECT,
        PLUSPLUS,
        PLUS,
        IPLUS,
        MINUS,
        IMINUS,
        MUL,
        DIV,
        REM,
        SHL,
        SHA,
        SHR,
        SETOF,
        EXACTLY,
        TRANSPOSE,
        RCLOSURE,
        CLOSURE,
        CARDINALITY,
        CAST2INT,
        CAST2SIGINT,
        PRIME,
        
        // QUANTIFIER IR NODES TO BE ELIMINATED
        FORALL,
        EXISTS,
        LONE,
        ONE,

        // DECLS IR NODES TO BE ELIMINATED
        GENERICRELDECL,
        DISJ,
        VAR,
        DISJVAR,
        
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
    public void setChildren(List<EGraphNode> children) {
        this.children = children;
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
    public String getSourceName() {
        return sourceName;
    }
    public void setSourceName(String sourceName) {
        this.sourceName = sourceName;
    }
    public String getSourceType() {
        return sourceType;
    }
    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }
    public String getAlphaName() {
        return alphaName;
    }
    public void setAlphaName(String alphaName) {
        this.alphaName = alphaName;
    }

    /**
     * Rewrite the e-graph with regard to rewriting rules; canonicalize the formula with equality saturation. 
     */
    public void saturate() {
        if (children == null || children.isEmpty()) {
            return;
        }
        List<EGraphNode> saturatedChildren = new ArrayList<>();
        for (EGraphNode child : children) {
            child.saturate();
            if (isAssociative(opcode) && child.getOpcode() == opcode) {
                saturatedChildren.addAll(child.getChildren());
            } else {
                saturatedChildren.add(child);
            }
        }
        if (isCommutative) {
            Collections.sort(saturatedChildren, Comparator.comparing(EGraphNode::sortKey));
        }
        children = saturatedChildren;
    }

    private static boolean isAssociative(Opcode opcode) {
        return opcode == Opcode.AND || opcode == Opcode.OR
                || opcode == Opcode.INTERSECT || opcode == Opcode.PLUS || opcode == Opcode.MUL
                || opcode == Opcode.IPLUS || opcode == Opcode.JOIN || opcode == Opcode.ARROW;
    }

    private String sortKey() {
        StringBuilder sb = new StringBuilder();
        appendSortKey(this, sb);
        return sb.toString();
    }

    private static void appendSortKey(EGraphNode node, StringBuilder sb) {
        sb.append(node.opcode).append(':');
        if (node.alphaName != null) {
            sb.append(node.alphaName);
        } else if (node.sourceName != null) {
            sb.append(node.sourceName);
        } else {
            sb.append(node.id);
        }
        sb.append('[');
        if (node.children != null) {
            for (EGraphNode child : node.children) {
                appendSortKey(child, sb);
                sb.append(',');
            }
        }
        sb.append(']');
    }

}
