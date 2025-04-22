package is.fivefivefive.ACGN.alloy;

public class MiddleSymbol implements Symbol {
    private String name;
    public MiddleSymbol(String name) {
        this.name = name;
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
