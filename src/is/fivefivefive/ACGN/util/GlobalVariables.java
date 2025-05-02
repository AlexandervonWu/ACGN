package is.fivefivefive.ACGN.util;

import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.HashMap;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import parser.etc.Pair;

public final class GlobalVariables {
    private Map<Pair<Symbol, Integer>, Set<Symbol>> edgeMap;
    public GlobalVariables() {
        edgeMap = new HashMap<Pair<Symbol, Integer>, Set<Symbol>>();
    }
    public Map<Pair<Symbol, Integer>, Set<Symbol>> getEdgeMap() {
        return edgeMap;
    }
    public Set<Symbol> getCandidates(Symbol node, int position) {
        return edgeMap.get(Pair.of(node, position));
    }
    public void addEdge(Symbol source, Symbol target, int position) {
        if (!edgeMap.containsKey(Pair.of(source, position))) {
            edgeMap.put(Pair.of(source, position), new HashSet<Symbol>());
        }
        edgeMap.get(Pair.of(source, position)).add(target);
    }
    public void addEdge(MASGEdge edge, int position) {
        addEdge(edge.getSource().getSymbol(), edge.getTarget().getSymbol(), position);
    }
    public void addEdge(AugmentedNode source, AugmentedNode target, int position) {
        addEdge(source.getSymbol(), target.getSymbol(), position);
    }
    public void combine(GlobalVariables another) {
        // Combine the edgeMaps
        for (Pair<Symbol, Integer> source : another.getEdgeMap().keySet()) {
            if (!edgeMap.containsKey(source)) {
                edgeMap.put(source, new HashSet<Symbol>());
            }
            edgeMap.get(source).addAll(another.getEdgeMap().get(source));
        }
    }
}
