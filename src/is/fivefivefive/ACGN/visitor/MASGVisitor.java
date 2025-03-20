package is.fivefivefive.ACGN.visitor;
import java.util.List;
import java.util.ArrayList;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.alloy.AAME;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.OpenDecl;

import parser.ast.visitor.VoidVisitorAdapter;
public class MASGVisitor<A> extends VoidVisitorAdapter<A> {
    // forest: the ASG forest of the predicates within the model
    private List<Multigraph> forest;
    private AAME aame;

    public MASGVisitor() {
        forest = new ArrayList<Multigraph>();
        aame = new AAME();
        forest.add(new Multigraph()); // zero-th tree in the forest is the main AST/G
    }
    public List<Multigraph> getForest() {
        return forest;
    }
    public AAME getAAME() {
        return aame;
    }
    // visits, all non-predicates are discarded. 
    // consider AAME into it. 
    
    // syn == 0, sem == 0 reserved for dummy roots of each non-global ASG. 
    // ModelUnit; the concrete "root". Syntactic == 0 for Non-modificable. Semantic == 1
    @Override
    public void visit(ModelUnit n, A arg) {
        AugmentedNode mu = new AugmentedNode(0, 1);
        Multigraph demoGraph = forest.get(0);
        demoGraph.addVertex(mu);
        // Open: non-modificable, syn == 0, sem == 2;
        for (OpenDecl o : n.getOpenDeclList()) {
            AugmentedNode oNode = new AugmentedNode(0, 2);
            demoGraph.addVertex(oNode);
            demoGraph.connect(mu, oNode, 1, 1);
        }
        // SigDecl: 
    }
}
