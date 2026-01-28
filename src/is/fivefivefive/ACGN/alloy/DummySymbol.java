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
    @Override
    public int getMaxDownlinks() {
        return 0; // DummySymbol does not have downlinks
    }
    @Override
    public void setMaxDownlinks(int maxDownlinks) {
        // DummySymbol does not have downlinks, so this method does nothing
    }

    public static final DummySymbol DUMMY_VAR = new DummySymbol("var");
    public static final DummySymbol DUMMY_SIG = new DummySymbol("sig");
    public static final DummySymbol DUMMY_FIELD = new DummySymbol("field");
    public static final DummySymbol DUMMY_REF = new DummySymbol("ref");
    public static final DummySymbol DUMMY_SUBSET = new DummySymbol("subset");
    public static final DummySymbol DUMMY_PREDROOT = new DummySymbol("predroot");
}
