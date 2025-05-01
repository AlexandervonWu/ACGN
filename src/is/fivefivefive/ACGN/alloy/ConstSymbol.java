package is.fivefivefive.ACGN.alloy;

public class ConstSymbol implements Symbol {
    private String name;
    private boolean isBoolean;

    public ConstSymbol(String n, boolean b) {
        name = n;
        isBoolean = b;
    }

    @Override
    public String getName() {
        return name;
    }

    @Override
    public String getType() {
        return isBoolean ? "boolean" : "int";
    }

    @Override
    public boolean isEndSymbol() {
        return false;
    }
    
}
