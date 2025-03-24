package is.fivefivefive.ACGN.alloy;

import java.util.List;

public abstract class RelationSet implements Symbol {
    private String name;
    private SigSymbol source;
    private List<SigSymbol> targets;
    public RelationSet(String n, SigSymbol s, List<SigSymbol> t) {
        name = n;
        source = s;
        targets = t;
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
    public List<SigSymbol> getTargets() {
        return targets;
    }
}
