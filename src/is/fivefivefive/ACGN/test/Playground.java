package is.fivefivefive.ACGN.test;

import java.util.List;

import edu.mit.csail.sdg.parser.CompModule;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.codegen.Generator;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.Node;
import parser.ast.nodes.Predicate;
import parser.ast.visitor.ASTNodeFinder;
import parser.util.AlloyUtil;

public class Playground {

    public static void main(String[] args) {
        String file = "dynamic_ball_graph.als";
        CompModule module = AlloyUtil.compileAlloyModule(file);
        ModelUnit mu = new ModelUnit(null, module);
        List<Node> root = ASTNodeFinder.findNodesByTypeAndName(mu, Predicate.class, "moved", false);
        Predicate rootMoved = (Predicate) root.get(0);
        MASGVisitor visitor = new MASGVisitor();
        visitor.visit(mu, null);
        System.out.println("Finished visiting the model unit.");
        DoubleMap<Integer, Multigraph> map = visitor.getForest();
        /*for (int i : map.keys()) {
            System.out.println("Graph " + i + ":");
            Multigraph graph = map.get(i);
            System.out.println(graph);
        }*/
        Generator generator = new Generator();
        System.out.println(map.get(2).getRoot().getSyntactic() + " " + map.get(2).getRoot().getSemantic());
        String code3 = generator.toCode(map.get(2), map.get(2).getRoot(), 1);
        System.out.println("Generated code for graph 2: ");
        System.out.println(code3);
    }


}