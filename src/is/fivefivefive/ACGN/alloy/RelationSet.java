package is.fivefivefive.ACGN.alloy;


public abstract class RelationSet extends AbstractSymbol {
    private String name;
    private SigSymbol source;
    private SigSymbol target;
    public RelationSet(String n, SigSymbol s, SigSymbol t) {
        name = n;
        source = s;
        target = t;
    }
    @Override
    public String getName() {
        return name;
    }
    @Override
    public String getType() {
        return "Relation";
    }
    @Override
    public boolean isEndSymbol() {
        return false;
    }
    public SigSymbol getSource() {
        return source;
    }
    public SigSymbol getTarget() {
        return target;
    }
}
