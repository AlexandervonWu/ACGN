package is.fivefivefive.ACGN.asg;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;

import is.fivefivefive.alloyasg.asg.ASGVisitor;
import is.fivefivefive.alloyasg.asg.ASGraph;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import is.fivefivefive.alloyasg.exceptions.ScopeNotFoundException;
import is.fivefivefive.alloyasg.exceptions.UnsupportedConstantException;
import is.fivefivefive.alloyasg.representations.NodeRepresentation;
import parser.ast.nodes.Node;
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
    public static Multigraph fromAST(ASGVisitor<Object> visitor, int root) throws ScopeNotFoundException, UnsupportedConstantException {
        ASGraph ast = visitor.getGraph();
        DoubleMap<Integer, Node> nodeMap = visitor.getNodeMap();
        Node rootNode = nodeMap.get(root);
        NodeRepresentation rootRep = new NodeRepresentation(visitor, rootNode);
        AugmentedNode rootAug = new AugmentedNode(rootRep);
        Set<AugmentedNode> vertices = new HashSet<AugmentedNode>();
        List<MASGEdge> edges = new ArrayList<MASGEdge>();
        vertices.add(rootAug);
        Queue<Integer> nodeQueue = new LinkedList<Integer>();
        nodeQueue.add(root);
        Map<NodeRepresentation, Integer> timeOfVisit = new HashMap<NodeRepresentation, Integer>();
        while (!nodeQueue.isEmpty()) {
            int localRoot = nodeQueue.poll();
            double[] rootRow = ast.getRow(localRoot);
            for (int i = 0; i < rootRow.length; i++) {
                Node n = nodeMap.get(i);
                NodeRepresentation nr = new NodeRepresentation(visitor, n);
                if (rootRow[i] > 0) {
                    if (timeOfVisit.containsKey(nr)) {
                        timeOfVisit.put(nr, timeOfVisit.get(nr) + 1);
                    } else {
                        timeOfVisit.put(nr, 1);
                    }
                    if (i == localRoot) {
                        AugmentedNode shadow = new AugmentedNode(rootAug);
                        vertices.add(shadow);
                        edges.add(new MASGEdge(rootAug, shadow, i, timeOfVisit.get(nr)));
                        continue;
                    }

                    AugmentedNode an = new AugmentedNode(nr);
                    vertices.add(an);
                    nodeQueue.add(i);
                    edges.add(new MASGEdge(rootAug, an, i, timeOfVisit.get(nr)));
                }
            }
        }
        return new Multigraph(vertices, edges);
    }
}
