package is.fivefivefive.ACGN.alloy;

import java.util.Set;
import edu.mit.csail.sdg.ast.Sig;

public class FieldRelation extends RelationSet {
    private final Sig.Field parserField;
    private Set<FieldConfiner> confiners; // one, lone, some, ...
    public FieldRelation(String n, SigSymbol s, SetSymbol t, Set<FieldConfiner> conf) {
        this(n, s, t, conf, null);
    }
    private FieldRelation(String name, SigSymbol source, SetSymbol target,
            Set<FieldConfiner> confiners, Sig.Field parserField) {
        super(name, source, target);
        this.confiners = confiners;
        this.parserField = parserField;
    }
    public static FieldRelation fromParser(Sig.Field field, SigSymbol source, SetSymbol target,
            Set<FieldConfiner> confiners) {
        return new FieldRelation(field.label.substring(field.label.lastIndexOf('/') + 1),
                source, target, confiners, field);
    }
    public final boolean resolvesTo(Sig.Field declaration) {
        return parserField != null && parserField == declaration;
    }
    public Set<FieldConfiner> getConfiners() {
        return confiners;
    }
    @Override
    public String getType() {
        return "FieldRelation :" + confiners.toString();
    }
    @Override
    public int getMaxDownlinks() {
        return 0; // FieldRelation has at most one downlink
    }
    public void setMaxDownlinks(int maxDownlinks) {
        // FieldRelation does not have downlinks, so this method does nothing
    }
}
