package is.fivefivefive.ACGN.alloy;

public final class ShadowSymbol extends AbstractSymbol {
    public ShadowSymbol() {
        super();
    }
    public String getName() {
        return "<SHADOW>";
    }
    public String getType() {
        return "SHADOW";
    }
    public boolean isEndSymbol() {
        return false;
    }
    @Override
    public int hashCode() {
        return 1145141919;
    }
    @Override
    public boolean equals(Object obj) {
        if (obj instanceof ShadowSymbol) {
            return true;
        }
        return false;
    }
    @Override
    public String toString() {
        return "ShadowSymbol{" +
                "signature=" + getSignature() +
                '}';
    }
}
