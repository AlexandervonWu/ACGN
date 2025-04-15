package is.fivefivefive.ACGN.alloy;

import java.util.List;

public class FieldRelation extends RelationSet {
    private List<String> confiners; // one, lone, some, ...
    public FieldRelation(String n, SigSymbol s, List<SigSymbol> t, List<String> conf) {
        super(n, s, t);
        confiners = conf;
    }
    public List<String> getConfiners() {
        return confiners;
    }
    @Override
    public String getType() {
        return "FieldRelation :" + confiners.toString();
    }
}
