package is.fivefivefive.ACGN.util;

import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.HashMap;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;

public final class GlobalVariables {
    private Map<AugmentedNode, Set<AugmentedNode>> edgeMap;
    public GlobalVariables() {
        edgeMap = new HashMap<AugmentedNode, Set<AugmentedNode>>();
    }
    public Map<AugmentedNode, Set<AugmentedNode>> getEdgeMap() {
        return edgeMap;
    }
    public Set<AugmentedNode> getCandidates(AugmentedNode node) {
        return edgeMap.get(node);
    }
    public void addEdge(AugmentedNode source, AugmentedNode target) {
        if (!edgeMap.containsKey(source)) {
            edgeMap.put(source, new HashSet<AugmentedNode>());
        }
        edgeMap.get(source).add(target);
    }
    public void addEdge(MASGEdge edge) {
        addEdge(edge.getSource(), edge.getTarget());
    }
}
