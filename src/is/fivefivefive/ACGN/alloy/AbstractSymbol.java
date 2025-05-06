package is.fivefivefive.ACGN.alloy;

public class AbstractSymbol implements Symbol {
    private double signature;
    public AbstractSymbol() {}
    public String getName() {
        return "<UNDEFINED>";
    }
    public String getType() {
        return "SYMBOL_UNDEFINED";
    }
    public boolean isEndSymbol() {
        return false;
    }
    public double getSignature() {
        return signature;
    }
    public void setSignature(double sig) {
        signature = sig;
    }
}
