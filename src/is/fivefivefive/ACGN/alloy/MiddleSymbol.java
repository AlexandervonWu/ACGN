package is.fivefivefive.ACGN.alloy;

public class MiddleSymbol extends AbstractSymbol {
    private String name;
    private boolean infiniteRoot;
    public MiddleSymbol(String name) {
        this.name = name;
    }
    public MiddleSymbol(String name, boolean infiniteRoot) {
        this.name = name;
        this.infiniteRoot = infiniteRoot;
    }
    public boolean isInfiniteRoot() {
        return infiniteRoot;
    }
    public void setInfiniteRoot(boolean infiniteRoot) {
        this.infiniteRoot = infiniteRoot;
    }
    public String getName() {
        return name;
    }
    public String getType() {
        return "MIDDLENODE_" + name;
    }
    public boolean isEndSymbol() {
        return false;
    }
    @Override
    public boolean equals(Object o) {
        if (o instanceof MiddleSymbol) {
            MiddleSymbol other = (MiddleSymbol) o;
            return this.name.equals(other.getName());
        } else {
            return false;
        }
    }
    @Override
    public int hashCode() {
        return name.hashCode() % 114493 + 114493; // closest prime number to 114514
    }
}
