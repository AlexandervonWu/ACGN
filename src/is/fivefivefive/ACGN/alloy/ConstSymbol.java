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
    
}
