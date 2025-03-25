package is.fivefivefive.ACGN.visitor;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.alloy.AAME;
import is.fivefivefive.ACGN.alloy.SigSymbol;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.OpenDecl;
import parser.ast.nodes.SigDecl;
import parser.ast.nodes.Predicate;
import parser.ast.nodes.Check;
import parser.ast.nodes.Run;
import parser.ast.nodes.Assertion;
import parser.ast.nodes.Fact;
import parser.ast.nodes.Function;
import parser.ast.nodes.Body;
import parser.ast.nodes.ConstExpr;
import parser.ast.nodes.LetExpr;
import parser.ast.nodes.ITEFormula;
import parser.ast.nodes.ITEExpr;
import parser.ast.nodes.QtFormula;
import parser.ast.nodes.QtExpr;
import parser.ast.nodes.CallFormula;
import parser.ast.nodes.CallExpr;
import parser.ast.nodes.ListFormula;
import parser.ast.nodes.ListExpr;
import parser.ast.nodes.BinaryFormula;
import parser.ast.nodes.BinaryExpr;
import parser.ast.nodes.UnaryFormula;
import parser.ast.nodes.UnaryExpr;
import parser.ast.nodes.VarExpr;
import parser.ast.nodes.FieldExpr;
import parser.ast.nodes.SigExpr;
import parser.ast.nodes.ExprOrFormula;
import parser.ast.nodes.VarDecl;
import parser.ast.nodes.ParamDecl;
import parser.ast.nodes.FieldDecl;
import parser.ast.nodes.ModuleDecl;
import parser.ast.visitor.GenericVisitor;
public class MASGVisitor implements GenericVisitor<AugmentedNode, Object> {

    // forest: the ASG forest of the predicates within the model
    // TODO: A fix, such that the recursive returns of the nodes connects with each other. 
    private List<Multigraph> forest;
    private AAME aame;
    private Map<AugmentedNode, Integer> timeOfVisit;
    private GlobalVariables globalVariables;
    private long numPredicates;

    public MASGVisitor() {
        forest = new ArrayList<Multigraph>();
        aame = new AAME();
        timeOfVisit = new HashMap<>();
        forest.add(new Multigraph()); // zero-th tree in the forest is the main AST/G
        numPredicates = 0;
        globalVariables = new GlobalVariables();
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
    public AugmentedNode visit(ModelUnit n, Object arg) {
        AugmentedNode mu = new AugmentedNode(0, 1);
        Multigraph demoGraph = forest.get(0);
        demoGraph.addVertex(mu);
        AugmentedNode md = n.getModuleDecl().accept(this, arg);
        demoGraph.connect(mu, md, 0, 1);
        demoGraph.addVertex(md);
        // Open: non-modificable, syn == 0, sem == 3;
        for (OpenDecl o : n.getOpenDeclList()) {
            AugmentedNode oNode = o.accept(this, arg);
            demoGraph.connect(mu, oNode, 1, 1);
            demoGraph.addVertex(oNode);
        }
        // SigDecl: non-mod, syn == 0, sem == 4; defines a new symbol in scope.
        for (SigDecl sd : n.getSigDeclList()) {
            AugmentedNode sdNode = new AugmentedNode(0, 3);
            demoGraph.addVertex(sdNode);
            demoGraph.connect(mu, sdNode, 2, 1);
            SigSymbol sigsy = new SigSymbol(sd.getName());
            aame.addSymbol(sigsy);
            sd.accept(this, arg);
        }

        // Predicate : each creates a tree in the forest. syn = 0, sem == 5; define a new predicate, which is a subtree. 
        for (Predicate p : n.getPredDeclList()) {
            AugmentedNode pNode = new AugmentedNode(0, 4);
            demoGraph.addVertex(pNode);
            demoGraph.connect(mu, pNode, 3, 1);
            Multigraph newTree = new Multigraph(pNode, GV);
            forest.add(newTree);
            p.accept(this, arg);
        }
        return mu;
    }

    @Override
    public AugmentedNode visit(Check n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Run n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Assertion n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Fact n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Function n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Predicate n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Body n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ConstExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(LetExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ITEFormula n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ITEExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(QtFormula n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(QtExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(CallFormula n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(CallExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ListFormula n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ListExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(BinaryFormula n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(BinaryExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(UnaryFormula n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(UnaryExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(VarExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(FieldExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(SigExpr n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ExprOrFormula n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(VarDecl n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ParamDecl n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(FieldDecl n, Object arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(SigDecl n, Object arg) {
        return new AugmentedNode(0, 4);
    }

    @Override
    public AugmentedNode visit(OpenDecl n, Object arg) {
        return new AugmentedNode(0, 3);
    }

    @Override
    public AugmentedNode visit(ModuleDecl n, Object arg) {
        return new AugmentedNode(0, 2);
    }

    
}
