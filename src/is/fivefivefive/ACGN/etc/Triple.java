package is.fivefivefive.ACGN.etc;

import is.fivefivefive.ACGN.util.Hasher;

public class Triple<A, B, C> extends is.fivefivefive.alloyasg.etc.Triple<A, B, C> {
    public Triple(A first, B second, C third) {
        super(first, second, third);
    }

    public int hashCode() {
        return Hasher.hashByTwo(Hasher.hashByTwo(x.hashCode(), y.hashCode()), z.hashCode());
    }
    
}
