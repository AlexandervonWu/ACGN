package is.fivefivefive.ACGN.alloy;

import java.util.Set;

public class FieldRelation extends RelationSet {
    private Set<FieldConfiner> confiners; // one, lone, some, ...
    public FieldRelation(String n, SigSymbol s, SigSymbol t, Set<FieldConfiner> conf) {
        super(n, s, t);
        confiners = conf;
    }
    public Set<FieldConfiner> getConfiners() {
        return confiners;
    }
    @Override
    public String getType() {
        return "FieldRelation :" + confiners.toString();
    }
}
