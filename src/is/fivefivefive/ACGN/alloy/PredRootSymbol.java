package is.fivefivefive.ACGN.alloy;

import is.fivefivefive.ACGN.asg.AugmentedNode;

public class PredRootSymbol extends AbstractSymbol {
    private AugmentedNode node;
    private String name;
    public PredRootSymbol(AugmentedNode n, String nm) {
        node = n;
        name = nm;
    }
    @Override
    public String getName() {
        return name;
    }
    @Override
    public String getType() {
        return "predroot";
    }
    @Override
    public boolean isEndSymbol() {
        return false;
    }
    public AugmentedNode getNode() {
        return node;
    }
    @Override
    public int getMaxDownlinks() {
        return -1; // PredRootSymbol can have any number of downlinks
    }
    @Override
    public void setMaxDownlinks(int maxDownlinks) {
        // PredRootSymbol does not have a fixed number of downlinks, so this method does nothing 
    }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof PredRootSymbol)) return false;
        PredRootSymbol that = (PredRootSymbol) o;
        return name.equals(that.name);
    }
    @Override
    public int hashCode() {
        return name.hashCode();
    }
}
