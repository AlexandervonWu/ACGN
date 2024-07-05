package is.fivefivefive.ACGN.asg;

import java.util.List;
import java.util.Set;

import is.fivefivefive.alloyasg.asg.ASGVisitor;
import is.fivefivefive.ACGN.asg.Multigraph;

/*
 * A naive, intermediate multigraph representation of the Multi-ASG.
 */
public class Multigraph {
    private Set<AugmentedNode> vertices;
    private List<MASGEdge> edges;
    public Multigraph(Set<AugmentedNode> v, List<MASGEdge> e) {
        vertices = v;
        edges = e;
    }
    public Set<AugmentedNode> getVertices() {
        return vertices;
    }
    public List<MASGEdge> getEdges() {
        return edges;
    }
    public void connect(AugmentedNode source, AugmentedNode target, int position, int timeOfVisit) {
        edges.add(new MASGEdge(source, target, position, timeOfVisit));
    }
    public MASGEdge edgeBetween(AugmentedNode source, AugmentedNode target) {
        for (MASGEdge e : edges) {
            if (e.getSource().equals(source) && e.getTarget().equals(target)) {
                return e;
            }
        }
        return null;
    }
    public int size() {
        return vertices.size();
    }
    public static Multigraph fromAST(ASGVisitor<Object> visitor, int root) {
        // TODO: Implement this method
        return null;
    }
}
