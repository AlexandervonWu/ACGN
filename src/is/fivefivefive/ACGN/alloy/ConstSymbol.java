package is.fivefivefive.ACGN.alloy;

public class ConstSymbol extends AbstractSymbol {
    private String name;
    private boolean isBoolean;
    private boolean isIden;

    public ConstSymbol(String n, boolean b, boolean iden) {
        name = n;
        isBoolean = b;
        isIden = iden;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public String getType() {
        return isBoolean ? "boolean" : isIden ? "iden" : "int";
    }

    @Override
    public boolean isEndSymbol() {
        return false;
    }
    
    @Override
    public boolean equals(Object o) {
        if (o instanceof ConstSymbol) {
            ConstSymbol other = (ConstSymbol) o;
            return this.name.equals(other.getName());
        } else {
            return false;
        }
    }
    @Override
    public int hashCode() {
        return name.hashCode();
    }
    @Override
    public int getMaxDownlinks() {
        return 0; // ConstSymbol does not have downlinks
    }
    @Override
    public void setMaxDownlinks(int maxDownlinks) {
        // ConstSymbol does not have downlinks, so this method does nothing
    }
}
