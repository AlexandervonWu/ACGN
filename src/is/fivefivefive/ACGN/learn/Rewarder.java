package is.fivefivefive.ACGN.learn;

import java.util.ArrayList;
import java.util.List;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.alloy4.ErrorWarning;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.Node;
import parser.ast.nodes.Predicate;

/**
 * The Rewarder class is the utility file for all the processing of the Alloy model files until computing the RL reward.
 * It uses the MASGVisitor to traverse the model and extract the relevant graphs.
 * This class is part of the ACGN (Alloy Code Generation Network) project.
 */
public class Rewarder {
    /**
     * Compiles an Alloy model from a file and returns the CompModule representation.
     * This method is used to parse the Alloy model and create a CompModule object that can be used for further processing.
     * @param file The path to the Alloy model file.
     * @return A CompModule representing the parsed Alloy model.
     */
    public static CompModule fromFile(String file) {
		String file_name = file;
		 A4Reporter rep = new A4Reporter() {
            @Override
            public void warning(ErrorWarning msg) {
                System.out.println(msg.toString().trim());
                System.out.flush();
            }
	    };
        CompModule world = CompUtil.parseEverything_fromFile(rep, null, file_name);
        return world;
    }

    /*
     * Returns a list of Multigraphs representing the predicate graph for the given predicate name.
     * The predicate graph is a forest of graphs, where each graph corresponds to a predicate with the given name.
     * @param cm The CompModule containing the predicate.
     * @param name The name of the predicate to find.
     * @return A list of Multigraphs representing the predicate graph.
     * Throws IllegalArgumentException if no predicate with the given name is found.
     * Throws IllegalArgumentException if the node found is not a Predicate.
     * Throws IllegalArgumentException if no graph is found for the predicate.
     */
    public static List<Multigraph> predicateGraph(CompModule cm, String name) {
        MASGVisitor visitor = new MASGVisitor();
        ModelUnit mu = new ModelUnit(null, cm);
        List<Node> roots = parser.ast.visitor.ASTNodeFinder.findNodesByTypeAndName(mu, Predicate.class, name, false);
        if (roots.isEmpty()) {
            throw new IllegalArgumentException("No predicate found with name: " + name);
        }
        visitor.visit(mu, null);
        DoubleMap<Integer, Multigraph> forest = visitor.getForest();
        List<Multigraph> graphs = new ArrayList<>();
        // get the forest of graphs by the roots
        for (Node root : roots) {
            if (!(root instanceof Predicate)) {
                throw new IllegalArgumentException("Node is not a Predicate: " + root);
            }
            Predicate predicate = (Predicate) root;
            String rootName = predicate.getName();
            for (int i : forest.keys()) {
                Multigraph graph = forest.get(i);
                if (graph.getRoot().getSymbol().getName().equals(rootName)) {
                    graphs.add(graph);
                }
            }
        }
        if (graphs.isEmpty()) {
            throw new IllegalArgumentException("No graph found for predicate: " + name);
        }
        return graphs;
    }

}
