package is.fivefivefive.ACGN.alloy;

public class DummySymbol extends AbstractSymbol {
    // A dummy symbol representing anything of the signatures, vars, references, etc.
    private String type;
    public DummySymbol(String type) {
        this.type = type;
    }
    public String getName() {
        return "Dummy for " + getType();
    }
    public String getType() {
        return type;
    }
    public boolean isEndSymbol() {
        return false;
    }
    @Override
    public int hashCode() {
        return type.hashCode();
    }
    @Override
    public boolean equals(Object obj) {
        if (obj instanceof DummySymbol) {
            return type.equals(((DummySymbol)obj).type);
        }
        return false;
    }
    @Override
    public String toString() {
        return "DummySymbol{" +
                "type='" + type + '\'' +
                '}';
    }
}
