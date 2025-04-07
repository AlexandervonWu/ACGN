package is.fivefivefive.ACGN.alloy;

/*
 * A signature in the Alloy model as a set. 
 * One of the symbols in the AAME.
 */
public class SigSymbol implements Symbol {
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
}
