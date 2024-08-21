package is.fivefivefive.ACGN.asg;

import is.fivefivefive.alloyasg.representations.NodeRepresentation;

/*
 * A node in the Abstract Semantic Graph.
 */
public class AugmentedNode {
    private int syntactic;
    private double semantic;
    private double signature;
    private boolean isShadow;
    public AugmentedNode(int syntactic, int semantic) {
        this.syntactic = syntactic;
        this.semantic = semantic;
        this.isShadow = false;
    }
    public AugmentedNode(NodeRepresentation nr) {
        this.syntactic = nr.getSyntacticRepresentation();
        this.semantic = nr.getSemanticRepresentation();
        this.isShadow = false;
    }
    // Create a shadow node to resolve self loops
    public AugmentedNode(AugmentedNode original) {
        this.syntactic = original.getSyntactic();
        this.semantic = original.getSemantic();
        this.isShadow = true;
    }
    public int getSyntactic() {
        return syntactic;
    }
    public double getSemantic() {
       return semantic;
    }
    public double getSignature() {
        return signature;
    }
    public void setSignature(double signature) {
        this.signature = signature;
    }
    public void initSignature() {
        this.signature = 0.0;
    }
    public boolean isShadow() {
        return isShadow;
    }
    @Override
    public boolean equals(Object o) {
        if (o instanceof AugmentedNode) {
            AugmentedNode n = (AugmentedNode) o;
            return n.getSyntactic() == syntactic && n.getSemantic() == semantic;
        }
        return false;
    }
}
