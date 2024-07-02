package is.fivefivefive.ACGN.alloy;

import java.util.List;

public class SubsetRelation extends RelationSet {
    private boolean isExtends; // true if the subset relation requires muturally exclusive with other subsets; - identity-mapping
    public SubsetRelation(String n, SigSet s, List<SigSet> t, boolean isExt) {
        super(n, s, t);
        isExtends = isExt;
    }
    public boolean isExtends() {
        return isExtends;
    }
}
