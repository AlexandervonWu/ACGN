package is.fivefivefive.ACGN.visitor;
import java.util.List;
import java.util.ArrayList;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.alloy.AAME;
import parser.ast.visitor.VoidVisitorAdapter;
public class MASGVisitor<A> extends VoidVisitorAdapter<A> {
    // forest: the ASG forest of the predicates within the model
    private List<Multigraph> forest;
    private AAME aame;

    public MASGVisitor() {
        forest = new ArrayList<Multigraph>();
    }
    public List<Multigraph> getForest() {
        return forest;
    }
    public AAME getAAME() {
        return aame;
    }
    // visits, all non-predicates are discarded. 
    // consider AAME into it. 
}
