package is.fivefivefive.ACGN.alloy;

import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.Hasher;

public class AssertSymbol extends AbstractSymbol {
    private String name;
    private Multigraph graph;
    public AssertSymbol(String name, Multigraph subgraph) {
        this.name = name;
        this.graph = subgraph;
    }
    public String getType() {
        return "Assertion";
    }
    public boolean isEndSymbol() {
        return false;
    }
    public String getName() {
        return name;
    }
    @Override
    public int hashCode() {
        return Hasher.hashByTwo(name.hashCode(), graph.hashCode());
    }
}
