package is.fivefivefive.ACGN.alloy;

import java.util.ArrayList;
import java.util.List;
import is.fivefivefive.alloyasg.asg.ASGVisitor;

/*
 * Abstract Alloy Model Environment defined by a collection of predefined sets.
 * Consider a universal representation of the various Alloy models.
 */
public class AAME {
    // TODO
    private List<Symbol> symbols;
    private List<ExtFact> facts;
    public AAME(ASGVisitor<Object> asgv) {
        //TODO: Find all of the nonpredicate symbols in the Alloy environment and put into the AAME
        
    }
    public AAME() {
        symbols = new ArrayList<>();
        facts = new ArrayList<>();
    }
    public void fetchFromCloud(String cloud) {
        // TODO: Setup a database
    }
    // TODO: IMPLEMENT FACTS AND FIELD IMPLICIT FACTS. 
    public List<Symbol> getSymbols() {
        return symbols;
    }
    public List<ExtFact> getFacts() {
        return facts;
    }
    public void setSymbols(List<Symbol> symbols) {
        this.symbols = symbols;
    }
    public void setFacts(List<ExtFact> facts) {
        this.facts = facts;
    }
    public void addSymbol(Symbol s) {
        symbols.add(s);
    }
    public void addFact(ExtFact f) {
        facts.add(f);
    }
}
