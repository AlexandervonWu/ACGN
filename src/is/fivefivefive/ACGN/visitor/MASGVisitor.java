package is.fivefivefive.ACGN.visitor;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

import java.util.HashSet;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.alloy.VarSymbol;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import is.fivefivefive.ACGN.alloy.AAME;
import is.fivefivefive.ACGN.alloy.FieldConfiner;
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
import parser.ast.nodes.RelDecl;
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
import parser.ast.nodes.Node;
import parser.ast.visitor.GenericVisitor;
import parser.etc.Pair;
public class MASGVisitor implements GenericVisitor<AugmentedNode, Multigraph> {

    // forest: the ASG forest of the predicates within the model
    // TODO: A fix, such that the recursive returns of the nodes connects with each other. 
    private List<Multigraph> forest;
    private AAME aame;
    // timeOfVisitMap is for concrete nodes only, tracking the nodes that we actually consider to visit. 
    // ATTENTION: this means the time of visit of the SOURCE node. 
    private Map<AugmentedNode, Integer> timeOfVisitMap; // TODO: TRACK THIS.
    // ATTENTION: GlobalVariables is not the "global variables" within the model, but describing the global properties under each node.
    private GlobalVariables globalVariables;
    private int numPredicates;
    // store local symbols within the scope of each predicate.
    private DoubleMap<Multigraph, Set<Symbol>> localSymbols;

    public MASGVisitor() {
        forest = new ArrayList<Multigraph>();
        aame = new AAME();
        timeOfVisitMap = new HashMap<>();
        forest.add(new Multigraph()); // zero-th tree in the forest is the main AST/G
        numPredicates = 0;
        globalVariables = new GlobalVariables();
        localSymbols = new DoubleMap<Multigraph, Set<Symbol>>();
    }
    public List<Multigraph> getForest() {
        return forest;
    }
    public AAME getAAME() {
        return aame;
    }
    public int numPredicates() {
        return numPredicates;
    }
    public GlobalVariables getGlobalVariables() {
        return globalVariables;
    }
    // visits, all non-predicates are discarded. 
    // consider AAME into it. 
    
    // syn == 0, sem == 0 reserved for dummy roots of each non-global ASG. 
    // ModelUnit; the concrete "root". Syntactic == 0 for Non-modificable. Semantic == 1
    @Override
    public AugmentedNode visit(ModelUnit n, Multigraph arg) {
        AugmentedNode mu = new AugmentedNode(0, 1);
        Multigraph demoGraph = forest.get(0);
        demoGraph.addVertex(mu);
        AugmentedNode md = n.getModuleDecl().accept(this, arg);
        demoGraph.connect(mu, md, 1, 1);
        demoGraph.addVertex(md);
        // Open: non-modificable, syn == 0, sem == 3;
        for (OpenDecl o : n.getOpenDeclList()) {
            AugmentedNode oNode = o.accept(this, arg);
            demoGraph.connect(mu, oNode, 2, 1);
            demoGraph.addVertex(oNode);
        }
        // SigDecl: non-mod, syn == 0, sem == 4; defines a new symbol in scope.
        for (SigDecl sd : n.getSigDeclList()) {
            AugmentedNode sdNode = sd.accept(this, arg);
            demoGraph.addVertex(sdNode);
            demoGraph.connect(mu, sdNode, 3, 1);
        }

        // Predicate : each creates a tree in the forest. syn = 0, sem == 5; define a new predicate, which is a subtree. 
        for (Predicate p : n.getPredDeclList()) {
            AugmentedNode pNode = p.accept(this, arg);
            demoGraph.addVertex(pNode);
            demoGraph.connect(mu, pNode, 4, 1);
        }
        return mu;
    }

    @Override
    public AugmentedNode visit(ModuleDecl n, Multigraph arg) {
        return new AugmentedNode(0, 2);
    }

    @Override
    public AugmentedNode visit(OpenDecl n, Multigraph arg) {
        return new AugmentedNode(0, 3);
    }

    @Override
    public AugmentedNode visit(SigDecl n, Multigraph arg) {
        String nameKey = n.getName();
        SigSymbol sigsy = new SigSymbol(nameKey);
        aame.addSymbol(nameKey, sigsy);
        return new AugmentedNode(0, 4);
    }

    @Override
    public AugmentedNode visit(Predicate n, Multigraph arg) {
        AugmentedNode predNode = new AugmentedNode(0, 5);
        numPredicates++;
        Multigraph predGraph = new Multigraph(predNode, globalVariables);
        localSymbols.put(predGraph, new HashSet<Symbol>());
        int iter = 2;
        for (ParamDecl pd : n.getParamList()) {
            // From here, we need to pass the subgraph into the child nodes.
            AugmentedNode pdNode = pd.accept(this, predGraph);
            predGraph.addVertex(pdNode);
            predGraph.connect(predNode, pdNode, iter, 1);
            iter++;
        }
        AugmentedNode bodyNode = n.getBody().accept(this, predGraph);
        predGraph.addVertex(bodyNode);
        predGraph.connect(predNode, bodyNode, 1, 1);
        forest.add(predGraph);
        return predNode;
    }

    private void visitAndConnect(AugmentedNode parent, AugmentedNode child, int position, Multigraph arg) {
        int timeOfVisit = 1;
        if (!timeOfVisitMap.containsKey(parent)) {
            timeOfVisitMap.put(parent, 1);
        } else {
            timeOfVisit = timeOfVisitMap.get(parent);
            timeOfVisitMap.put(parent,  + 1);
        }
        arg.addVertex(child);
        arg.connect(parent, child, position, timeOfVisit);
    }

    // Assume that a RelDecl declares a set of relations all subject to the same type scope. 
    private AugmentedNode visitRelDecl(RelDecl n, Multigraph arg) {
        // TODO: All real decls goes to this. Concrete symbol to consider. 
        Set<Symbol> localSyms = localSymbols.get(arg);
        int isVar = n.isVariable() ? 1 : 0;
        int isDisj = n.isDisjoint() ? 1 : 0;
        // TODO: syntactic: according to the signature type and the confiners. 
        
        int semantic = 1 + isVar << 1 + isDisj; // class of the decl;
        AugmentedNode declRoot = new AugmentedNode(-1, semantic); // a virtual root node of the decl set. 
        arg.addVertex(declRoot);
        ExprOrFormula expr = n.getExpr(); // the type with constraints. 
        AugmentedNode exprNode = expr.accept(this, arg);
        visitAndConnect(declRoot, exprNode, 1, arg);
        Pair<SigSymbol, Set<FieldConfiner>> sigPair = getSigSymbolByExpr(expr);
        SigSymbol sigSymbol = sigPair.a;
        Set<FieldConfiner> confiners = sigPair.b;
        for (String name : n.getNames()) {
            VarSymbol varSym = new VarSymbol(sigSymbol.getName(), name, forest.indexOf(arg));
            varSym.setFieldConfinerSet(confiners);
            localSyms.add(varSym);
        }
        int iter = 2;
        n.getVariables().forEach(v -> {
            AugmentedNode varNode = v.accept(this, arg);
            visitAndConnect(declRoot, varNode, iter, arg);
        });
        return declRoot;
    }
 
    private Pair<SigSymbol, Set<FieldConfiner>> getSigSymbolByExpr(ExprOrFormula n) {
        // Question: what is the ** signature ** type of the paramater? The expr of the ParamDecl is an arbitrary Expr. 
        try {
            Set<FieldConfiner> confiners = new HashSet<>();
            Node iter = n;
            while (iter instanceof UnaryExpr) {
                UnaryExpr unIter = (UnaryExpr) iter;
                switch (unIter.getOp()) {
                    case SET:
                        confiners.add(FieldConfiner.SET);
                        break;
                    case LONE:
                        confiners.add(FieldConfiner.LONE);
                        break;
                    case ONE:
                        confiners.add(FieldConfiner.ONE);
                        break;
                    case SOME:
                        confiners.add(FieldConfiner.SOME);
                        break;
                    case EXACTLYOF:
                        confiners.add(FieldConfiner.EXACTLY);
                        break;
                    default:
                        throw new Exception("Unknown unary operator: " + unIter.getOp());
                }
                iter = unIter.getChildren().get(0);
            }
            if (iter instanceof SigExpr) {
                SigExpr sigExpr = (SigExpr) iter;
                String sigName = sigExpr.getName();
                Symbol sigSymbol = aame.getSymbol(sigName);
                if (sigSymbol == null || !(sigSymbol instanceof SigSymbol)) {
                    throw new Exception("Unknown signature: " + sigName);
                }
                SigSymbol concSigSymbol = (SigSymbol) sigSymbol;
                return Pair.of(concSigSymbol, confiners);
            } else {
                throw new Exception("Unknown expression type: " + iter.getClass());
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    @Override 
    public AugmentedNode visit(ParamDecl n, Multigraph arg) {
        return visitRelDecl(n, arg);
    }

    @Override
    public AugmentedNode visit(Body n, Multigraph arg) {
        // not a concrete node, bypass
        Node bodyChild = n.getChildren().get(0);
        return bodyChild.accept(this, arg);
    }

    @Override
    public AugmentedNode visit(Check n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Run n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Assertion n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Fact n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(Function n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ConstExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(LetExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ITEFormula n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ITEExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(QtFormula n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(QtExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(CallFormula n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(CallExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ListFormula n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ListExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(BinaryFormula n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(BinaryExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(UnaryFormula n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(UnaryExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(VarExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(FieldExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(SigExpr n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ExprOrFormula n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(VarDecl n, Multigraph arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(FieldDecl n, Multigraph arg) {
        // Implementation here
        return null;
    }
}
