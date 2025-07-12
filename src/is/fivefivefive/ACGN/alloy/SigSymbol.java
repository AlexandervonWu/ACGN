package is.fivefivefive.ACGN.alloy;

/*
 * A signature in the Alloy model as a set. 
 * One of the symbols in the AAME.
 */
public class SigSymbol extends SetSymbol {
    private String name;
    public SigSymbol(String n) {
        name = n;
    }
    @Override
    public String getName() {
        return name;
    }
    @Override
    public String getType() {
        return "Signature";
    }
    @Override
    public boolean isEndSymbol() {
        return false;
    }
    @Override
    public int hashCode() {
        return name.hashCode();
    }
    @Override
    public boolean equals(Object o) {
        if (o instanceof SigSymbol) {
            SigSymbol other = (SigSymbol) o;
            return this.name.equals(other.getName());
        } else {
            return false;
        }
    }
    @Override
    public int getMaxDownlinks() {
        return 0; // SigSymbol does not have downlinks
    }
    @Override
    public void setMaxDownlinks(int maxDownlinks) {
        // SigSymbol does not have downlinks, so this method does nothing
    }
}
