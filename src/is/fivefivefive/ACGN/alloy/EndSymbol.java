package is.fivefivefive.ACGN.alloy;

public final class EndSymbol implements Symbol {
    public EndSymbol() {}
    public String getName() {
        return "<END>";
    }
    public String getType() {
        return "SYMBOL_END";
    }
    public boolean isEndSymbol() {
        return true;
    }
    public boolean equals(EndSymbol another) {
        return true;
    }
    public int hashCode() {
        return 0;
    }
}
