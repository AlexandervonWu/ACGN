package is.fivefivefive.ACGN.alloy;

import is.fivefivefive.ACGN.asg.AugmentedNode;

public class RefSymbol extends AbstractSymbol {
    private AugmentedNode node;
    private String name;
    private String type;
    private boolean isEnd;
    public RefSymbol(AugmentedNode n, String nm) {
        node = n;
        name = nm;
        type = ""; // TODO: get type from node
    }
    public RefSymbol(boolean end) {
        isEnd = end;
        node = new AugmentedNode(-1, 0);
        name = "<END>";
    }
    @Override
    public String getName() {
        return name;
    }
    @Override
    public String getType() {
        return type;
    }
    public void setType(String t) {
        type = t;
    }
    @Override
    public boolean isEndSymbol() {
        return isEnd;
    }
    public AugmentedNode getNode() {
        return node;
    }
    @Override
    public int getMaxDownlinks() {
        return -1; // RefSymbol can have any number of downlinks
    }
    @Override
    public void setMaxDownlinks(int maxDownlinks) {
        // RefSymbol does not have a fixed number of downlinks, so this method does nothing 
    }
}
