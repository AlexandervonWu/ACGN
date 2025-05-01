package is.fivefivefive.ACGN.util;

import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.HashMap;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import parser.etc.Pair;

public final class GlobalVariables {
    private Map<Pair<AugmentedNode, Integer>, Set<AugmentedNode>> edgeMap;
    public GlobalVariables() {
        edgeMap = new HashMap<Pair<AugmentedNode, Integer>, Set<AugmentedNode>>();
    }
    public Map<Pair<AugmentedNode, Integer>, Set<AugmentedNode>> getEdgeMap() {
        return edgeMap;
    }
    public Set<AugmentedNode> getCandidates(AugmentedNode node, int position) {
        return edgeMap.get(Pair.of(node, position));
    }
    public void addEdge(AugmentedNode source, AugmentedNode target, int position) {
        if (!edgeMap.containsKey(Pair.of(source, position))) {
            edgeMap.put(Pair.of(source, position), new HashSet<AugmentedNode>());
        }
        edgeMap.get(Pair.of(source, position)).add(target);
    }
    public void addEdge(MASGEdge edge, int position) {
        addEdge(edge.getSource(), edge.getTarget(), position);
    }
    public void combine(GlobalVariables another) {
        // Combine the edgeMaps
        for (Pair<AugmentedNode, Integer> source : another.getEdgeMap().keySet()) {
            if (!edgeMap.containsKey(source)) {
                edgeMap.put(source, new HashSet<AugmentedNode>());
            }
            edgeMap.get(source).addAll(another.getEdgeMap().get(source));
        }
    }
}
