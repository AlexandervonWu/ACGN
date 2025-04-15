package is.fivefivefive.ACGN.asg;

import java.util.ArrayList;
import java.util.List;
import is.fivefivefive.alloyasg.representations.NodeRepresentation;

/*
 * A node in the Abstract Semantic Graph.
 * NOTE THAT SIGNATURE DOES NOT RELATED TO THE SEMANTIC AND SYNTACTIC PREASSIGNED CODES ANYMORE! 
 */
public class AugmentedNode {
    private byte syntactic;
    private int semantic;
    private double signature;
    private List<MASGEdge> uplinks;
    private List<MASGEdge> downlinks;
    private boolean isShadow;
    public AugmentedNode(int syntactic, int semantic) throws IllegalArgumentException {
        if (syntactic > 127 || syntactic < -128) {
            throw new IllegalArgumentException("Syntactic is a single byte! ");
        }
        this.syntactic = (byte) syntactic;
        this.semantic = semantic;
        this.signature = 0.0;
        this.isShadow = false;
        uplinks = new ArrayList<>();
        downlinks = new ArrayList<>();
    }
    public AugmentedNode(NodeRepresentation nr) {
        this((byte) nr.getSyntacticRepresentation(), (int) nr.getSemanticRepresentation());
    }
    // Create a shadow node to resolve self loops
    public AugmentedNode(AugmentedNode original) {
        this.syntactic = original.getSyntactic();
        this.semantic = (int) Math.round(original.getSemantic());
        // TODO: Exponential forms must be removed! What are exponential? 
        this.isShadow = true;
    }
    public byte getSyntactic() {
        return syntactic;
    }
    public double getSemantic() {
       return semantic;
    }
    public double getSignature() {
        return signature;
    }
    public List<MASGEdge> getUplinks() {
        return uplinks;
    }
    public List<MASGEdge> getDownlinks() {
        return downlinks;
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
    public MASGEdge connect(AugmentedNode target, int position, int timeOfVisit) {
        MASGEdge e = new MASGEdge(this, target, position, timeOfVisit);
        downlinks.add(e);
        target.uplinks.add(e);
        return e;
    }
    public MASGEdge inverseConnect(AugmentedNode source, int position, int timeOfVisit) {
        MASGEdge e = new MASGEdge(source, this, position, timeOfVisit);
        uplinks.add(e);
        source.downlinks.add(e);
        return e;
    }
    public static MASGEdge connect(AugmentedNode source, AugmentedNode target, int position, int timeOfVisit) {
        MASGEdge e = new MASGEdge(source, target, position, timeOfVisit);
        source.downlinks.add(e);
        target.uplinks.add(e);
        return e;
    }
    @Override
    public boolean equals(Object o) {
        if (o instanceof AugmentedNode) {
            AugmentedNode n = (AugmentedNode) o;
            return n.getSyntactic() == syntactic && n.getSemantic() == semantic;
        }
        return false;
    }
    // hashCode by the Cantor formula
    @Override 
    public int hashCode() {
        int synPositive = syntactic + 128;
        return (int) (0.5 * (synPositive + semantic) * (synPositive + semantic + 1)  + semantic);
    }
}
