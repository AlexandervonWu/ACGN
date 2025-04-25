package is.fivefivefive.ACGN.test;

import edu.mit.csail.sdg.parser.CompModule;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

public class Playground {

    public static void main(String[] args) {
        String file = "dynamic_ball_graph.als";
        CompModule module = AlloyUtil.compileAlloyModule(file);
        ModelUnit mu = new ModelUnit(null, module);
        MASGVisitor visitor = new MASGVisitor();
        visitor.visit(mu, null);
        System.out.println("Finished visiting the model unit.");
        System.out.println(visitor.getOverallRoot());
    }


}