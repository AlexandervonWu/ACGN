package is.fivefivefive.ACGN.asg;

import java.util.ArrayList;
import java.util.List;

import is.fivefivefive.ACGN.util.Hasher;
import is.fivefivefive.alloyasg.representations.NodeRepresentation;
import is.fivefivefive.ACGN.alloy.Symbol;

/*
 * A node in the Abstract Semantic Graph.
 * NOTE THAT SIGNATURE DOES NOT RELATED TO THE SEMANTIC AND SYNTACTIC PREASSIGNED CODES ANYMORE! 
 */
public class AugmentedNode {
    private byte syntactic;
    private int semantic;
    // private double signature;
    private List<MASGEdge> uplinks;
    private List<MASGEdge> downlinks;
    private boolean isShadow;
    private Symbol symbol;
    public AugmentedNode(int syntactic, int semantic, Symbol symbol) throws IllegalArgumentException {
        if (syntactic > 127 || syntactic < -128) {
            throw new IllegalArgumentException("Syntactic is a single byte! ");
        }
        this.syntactic = (byte) syntactic;
        this.semantic = semantic;
        this.isShadow = false;
        this.symbol = symbol;
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
    public AugmentedNode(int syntactic, int semantic) {
        this(syntactic, semantic, null);
    }
    public Symbol getSymbol() {
        return symbol;
    }
    public void setSymbol(Symbol symbol) {
        this.symbol = symbol;
    }
    public byte getSyntactic() {
        return syntactic;
    }
    public double getSemantic() {
       return semantic;
    }
    public double getSignature() {
        return this.symbol.getSignature();
    }
    public List<MASGEdge> getUplinks() {
        return uplinks;
    }
    public List<MASGEdge> getDownlinks() {
        return downlinks;
    }
    public void setSignature(double signature) {
        this.symbol.setSignature(signature);
    }
    public void initSignature() {
        this.symbol.setSignature(0);
    }
    public boolean isShadow() {
        return isShadow;
    }
    public MASGEdge connect(AugmentedNode target, int position, int timeOfVisit) {
        MASGEdge e = new MASGEdge(this, target, position, timeOfVisit);
        downlinks.add(e);
        target.uplinks.add(e);
        //System.out.println("Connecting " + this.syntactic + " " + this.semantic + " to " + target.syntactic + " " + target.semantic + " at " + position + ", for " + timeOfVisit + "-th time");
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
        return Hasher.hashByTwo(synPositive, semantic);
    }
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("AugmentedNode: ");
        sb.append("Syntactic: ").append(syntactic).append(", ");
        sb.append("Semantic: ").append(semantic).append(", ");
        sb.append("Signature: ").append(getSignature()).append(", ");
        for (MASGEdge e : downlinks) {
            sb.append('\n');
            sb.append("Downlink: ").append(e).append(", ");
        }
        return sb.toString();
    }
}
