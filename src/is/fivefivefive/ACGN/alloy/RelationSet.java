package is.fivefivefive.ACGN.alloy;

import java.util.List;

public abstract class RelationSet implements Symbol {
    private String name;
    private SigSet source;
    private List<SigSet> targets;
    public RelationSet(String n, SigSet s, List<SigSet> t) {
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
    public SigSet getSource() {
        return source;
    }
    public List<SigSet> getTargets() {
        return targets;
    }
}
