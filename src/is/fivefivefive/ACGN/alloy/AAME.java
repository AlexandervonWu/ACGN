package is.fivefivefive.ACGN.alloy;

import java.util.List;
import is.fivefivefive.alloyasg.asg.ASGVisitor;

/*
 * Abstract Alloy Model Environment defined by a collection of predefined sets.
 * Consider a universal representation of the various Alloy models.
 */
public class AAME {
    // TODO
    private List<Symbol> symbols;

    public AAME(ASGVisitor<Object> asgv) {
        //TODO: Find all of the nonpredicate symbols in the Alloy environment and put into the AAME
        
    }
    public void fetchFromCloud(String cloud) {
        // TODO: Setup a database
    }
    // TODO: IMPLEMENT FACTS AND FIELD IMPLICIT FACTS. 
    public List<Symbol> getSymbols() {
        return symbols;
    }
}
