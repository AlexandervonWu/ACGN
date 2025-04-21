package is.fivefivefive.ACGN.visitor;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

import java.util.HashSet;
import java.util.List;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.structure.ScopeTreeNode;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.alloy.VarSymbol;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import is.fivefivefive.ACGN.alloy.AAME;
import is.fivefivefive.ACGN.alloy.EndSymbol;
import is.fivefivefive.ACGN.alloy.ExtFact;
import is.fivefivefive.ACGN.alloy.FieldConfiner;
import is.fivefivefive.ACGN.alloy.FieldRelation;
import is.fivefivefive.ACGN.alloy.RefSymbol;
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
import parser.ast.nodes.ITEExprOrFormula;
import parser.ast.nodes.QtFormula;
import parser.ast.nodes.RelDecl;
import parser.ast.nodes.QtExpr;
import parser.ast.nodes.QtExprOrFormula;
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
import parser.ast.nodes.PredOrFun;
import parser.ast.nodes.FieldDecl;
import parser.ast.nodes.ModuleDecl;
import parser.ast.nodes.Node;
import parser.ast.visitor.GenericVisitor;
import parser.ast.visitor.PrettyStringVisitor;
import parser.etc.Pair;
public class MASGVisitor implements GenericVisitor<AugmentedNode, ScopeTreeNode> {

    // forest: the ASG forest of the predicates within the model
    // TODO: A fix, such that the recursive returns of the nodes connects with each other. 
    private DoubleMap<Integer, Multigraph> forest;
    private AAME aame;
    // timeOfVisitMap is for concrete nodes only, tracking the nodes that we actually consider to visit. 
    // ATTENTION: this means the time of visit of the SOURCE node. Only nonleaf nodes need it. 
    private Map<AugmentedNode, Integer> timeOfVisitMap; // TODO: TRACK THIS.
    // ATTENTION: GlobalVariables is not the "global variables" within the model, but describing the global properties under each node.
    private GlobalVariables globalVariables;
    private int numPredicates, scopeNodeId;
    // store local symbols within the scope of each predicate.
    // TODO: We may need more branching for localSymbols. Consider a ``scope tree''. 
    // private DoubleMap<Multigraph, Set<Symbol>> localSymbols;
    private ScopeTreeNode rootScope;
    // Unique (leaf) nodes with user-defined names. 
    private DoubleMap<Symbol, AugmentedNode> uniqueNode;
    private final Symbol END_SYMBOL = new EndSymbol();
    private final AugmentedNode END_NODE = new AugmentedNode(-128, 0);
    private List<ExtFact> facts;

    public MASGVisitor() {
        forest = new DoubleMap<>();
        aame = new AAME();
        timeOfVisitMap = new HashMap<>();
        forest.put(0, new Multigraph()); // zero-th tree in the forest is the main AST/G
        numPredicates = 0;
        scopeNodeId = 0;
        globalVariables = new GlobalVariables();
        // localSymbols = new DoubleMap<Multigraph, Set<Symbol>>();
        uniqueNode = new DoubleMap<>();
        uniqueNode.put(END_SYMBOL, END_NODE);
        facts = new ArrayList<>();
    }
    public DoubleMap<Integer, Multigraph> getForest() {
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
    /*
     * An explanation of the Syntactic and Semantic identifiers: 
     * Syn := the identifiers of "what it does" in a concrete tree; Interchangable
     * Sem := what exactly it is. leaf symbols starts at 1. 
     * Special case: all non-changing nodes got assigned with zero syntactic. 
     * Dictionary of Syntactics: 
     *   0 = non-changing nodes, such as "ModuleDecl", "Open", irrelevant to modeling;
     *   1 = block starters, such as a Predicate, Let or Function;
     *   2 = dummy node for ITE / => ELSE; 
     *   3 = dummy node for the root of a quantifier; 
     *   -1 = dummy node for the list of declarations;
     *   -128 = the End Symbol (predefined);
     *   122 - Let Expressions; 
     *   123 - Integer Constants;
     *   124 - Boolean Constants;
     *   125 - FieldSymbols;
     *   126 - SigSymbols;
     *   127 - VarSymbols;
     */
    @Override
    public AugmentedNode visit(ModelUnit n, ScopeTreeNode arg) {
        AugmentedNode mu = new AugmentedNode(0, 1);
        Multigraph demoGraph = forest.get(0);
        rootScope = new ScopeTreeNode(0, null, demoGraph);
        demoGraph.addVertex(mu);
        AugmentedNode md = n.getModuleDecl().accept(this, rootScope);
        demoGraph.connect(mu, md, 1, 1);
        demoGraph.addVertex(md);
        // Open: non-modificable, syn == 0, sem == 3;
        for (OpenDecl o : n.getOpenDeclList()) {
            AugmentedNode oNode = o.accept(this, rootScope);
            demoGraph.connect(mu, oNode, 2, 1);
            demoGraph.addVertex(oNode);
        }
        // SigDecl: non-mod, syn == 0, sem == 4; defines a new symbol in scope.
        for (SigDecl sd : n.getSigDeclList()) {
            AugmentedNode sdNode = sd.accept(this, rootScope);
            demoGraph.addVertex(sdNode);
            demoGraph.connect(mu, sdNode, 3, 1);
        }

        // Predicate : each creates a tree in the forest. syn = 1, sem == 0; define a new predicate, which is a subtree. 
        // the foci of learning
        int predId = 0;
        for (Predicate p : n.getPredDeclList()) {
            AugmentedNode pNode = p.accept(this, rootScope);
            demoGraph.addVertex(pNode);
            demoGraph.connect(mu, pNode, 4 + predId, 1);
            predId++;
        }

        // Function : a callable symbol, unchanged in operation
        for (Function f : n.getFunDeclList()) {
            AugmentedNode fNode = f.accept(this, rootScope);
            demoGraph.addVertex(fNode);
            demoGraph.connect(mu, fNode, 4 + predId, 1);
            predId++;
        }
        // Facts can be directly stored in AAME. 
        for (Fact f : n.getFactDeclList()) {
            AugmentedNode fNode = f.accept(this, rootScope);
            demoGraph.addVertex(fNode);
            demoGraph.connect(mu, fNode, 4 + predId, 1);
            predId++;
        }
        return mu;
    }

    @Override
    public AugmentedNode visit(ModuleDecl n, ScopeTreeNode arg) {
        return new AugmentedNode(0, 2);
    }

    @Override
    public AugmentedNode visit(OpenDecl n, ScopeTreeNode arg) {
        return new AugmentedNode(0, 3);
    }

    @Override
    public AugmentedNode visit(SigDecl n, ScopeTreeNode arg) {
        String nameKey = n.getName();
        SigSymbol sigsy = new SigSymbol(nameKey);
        aame.addSymbol(nameKey, sigsy);
        rootScope.addSymbol(sigsy);
        AugmentedNode sigExprNode = new AugmentedNode(127, uniqueNode.size());
        uniqueNode.put(sigsy, sigExprNode);
        for (FieldDecl f : n.getFieldList()) {
            f.accept(this, arg); // register the symbols, but not use here
        }
        return sigExprNode;
    }

    /*
     * TODO: Remember that predicates and similar items are called in CallExprOrFormula. Update the timeOfVisit there. 
     */
    @Override
    public AugmentedNode visit(Predicate n, ScopeTreeNode arg) {
        return visitPredOrFun(n, arg);
    }

    @Override
    public AugmentedNode visit(Function n, ScopeTreeNode arg) {
        return visitPredOrFun(n, arg);
    }

    private AugmentedNode visitPredOrFun(PredOrFun n, ScopeTreeNode arg) {
        numPredicates++; 
        scopeNodeId++;
        // Once declared, the PredNode when called is just a leaf node symbol. 
        AugmentedNode predNode = new AugmentedNode(1,numPredicates);
        timeOfVisitMap.put(predNode, 1);
        String predName = n.getName();
        Symbol predSymbol = new RefSymbol(predNode, predName);
        aame.addSymbol(predName, predSymbol);
        Multigraph predGraph = new Multigraph(predNode, globalVariables);
        // localSymbols.put(predGraph, new HashSet<Symbol>());
        ScopeTreeNode subscope = new ScopeTreeNode(scopeNodeId, rootScope, predGraph);

        int iter = 2;
        for (ParamDecl pd : n.getParamList()) {
            // From here, we need to pass the subgraph into the child nodes.
            // TODO: Incorporate the timeOfVisitMap to ensure unique visit time.
            AugmentedNode pdNode = pd.accept(this, subscope);
            predGraph.connect(predNode, pdNode, iter, 1);
            iter++;
        }
        AugmentedNode bodyNode = n.getBody().accept(this, subscope);
        predGraph.addVertex(bodyNode);
        predGraph.connect(predNode, bodyNode, 1, 1);
        forest.put(numPredicates, predGraph);
        return predNode;
    }

    // Assume that a RelDecl declares a set of relations all subject to the same type scope. 
    // RelDecls here except Fields.
    private AugmentedNode visitRelDecl(RelDecl n, ScopeTreeNode arg) {
        // All real decls goes to this. Concrete symbol to consider. 
        // Set<Symbol> localSyms = arg.getSymbols();
        int isVar = n.isVariable() ? 1 : 0;
        int isDisj = n.isDisjoint() ? 1 : 0;
        // syntactic: according to the signature type and the confiners. 
        int semantic = isVar << 1 + isDisj; // class of the decl; confined by property of the decl. 
        AugmentedNode declRoot = new AugmentedNode(-1, semantic); // a virtual root node of the decl set. 
        Multigraph graph = arg.getAffliation();
        graph.addVertex(declRoot);
        if (timeOfVisitMap.containsKey(declRoot)) {
            int prevValue = timeOfVisitMap.get(declRoot);
            timeOfVisitMap.put(declRoot, prevValue + 1);
        } else {
            timeOfVisitMap.put(declRoot, 1);
        }
        ExprOrFormula expr = n.getExpr(); // the type with constraints. 
        // TODO: Write the ExprNode accept method. 
        AugmentedNode exprNode = expr.accept(this, arg);
        visitAndConnect(declRoot, exprNode, 1, arg);
        Pair<SigSymbol, Set<FieldConfiner>> sigPair = getSigSymbolByExpr(expr);
        SigSymbol sigSymbol = sigPair.a;
        Set<FieldConfiner> confiners = sigPair.b;
        for (String name : n.getNames()) {
            VarSymbol varSym = new VarSymbol(sigSymbol.getName(), name, forest.rget(graph));
            varSym.setFieldConfinerSet(confiners);
            arg.addSymbol(varSym);
            uniqueNode.put(varSym, new AugmentedNode(127, uniqueNode.size()));
        }
        int iter = 2;
        for (ExprOrFormula v : n.getVariables()) {
            AugmentedNode varNode = v.accept(this, arg);
            visitAndConnect(declRoot, varNode, iter, arg);
            iter++;
        }
        // graph.addVertex(END_NODE);
        visitAndConnect(declRoot, END_NODE, iter + 1, arg);
        return declRoot;
    }

    private void visitAndConnect(AugmentedNode parent, AugmentedNode child, int position, ScopeTreeNode arg) {
        int timeOfVisit = timeOfVisitMap.containsKey(parent) ? timeOfVisitMap.get(parent) : 1;
        Multigraph graph = arg.getAffliation();
        graph.addVertex(child);
        graph.connect(parent, child, position, timeOfVisit);
    }

    // TODO: We have not touched internal nodes yet. 
    private void updateTimeOfVisit(AugmentedNode parent) {
        int timeOfVisit = 1;
        if (!timeOfVisitMap.containsKey(parent)) {
            timeOfVisitMap.put(parent, 1);
        } else {
            timeOfVisit = timeOfVisitMap.get(parent);
            timeOfVisitMap.put(parent, timeOfVisit + 1);
        }
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
    public AugmentedNode visit(ParamDecl n, ScopeTreeNode arg) {
        return visitRelDecl(n, arg);
    }

    @Override
    public AugmentedNode visit(Body n, ScopeTreeNode arg) {
        // not a concrete node, bypass
        Node bodyChild = n.getChildren().get(0);
        return bodyChild.accept(this, arg);
    }

    @Override
    public AugmentedNode visit(Check n, ScopeTreeNode arg) {
        // Implementation here
        return new AugmentedNode(0, 101);
    }

    @Override
    public AugmentedNode visit(Run n, ScopeTreeNode arg) {
        // Implementation here
        return new AugmentedNode(0, 102);
    }

    // Assertion is also a paragraph to be checked
    @Override
    public AugmentedNode visit(Assertion n, ScopeTreeNode arg) {
        // Implementation here

        return null;
    }
    
    // catch the explicit facts
    @Override
    public AugmentedNode visit(Fact n, ScopeTreeNode arg) {
        PrettyStringVisitor psv = new PrettyStringVisitor();
        String code = psv.visit(n, null);
        ExtFact fact = new ExtFact(true, code);
        facts.add(fact);
        return new AugmentedNode(0, 5);
    }

    @Override
    public AugmentedNode visit(ConstExpr n, ScopeTreeNode arg) {
        if (n.isBoolean()) {
            String val = n.getValue();
            if (val.equalsIgnoreCase("true")) {
                return new AugmentedNode(124, 1);
            } else {
                return new AugmentedNode(124, 0);
            }
        } else {
            try {
                int semantic = Integer.parseInt(n.getValue());
                return new AugmentedNode(123, semantic);
            } catch (Exception e) {
                System.out.println("Type of constant not supported! ");
                throw e;
            }
        }
    }

    // A new symbol, a new scope
    @Override
    public AugmentedNode visit(LetExpr n, ScopeTreeNode arg) {
        scopeNodeId++;
        ScopeTreeNode child = new ScopeTreeNode(scopeNodeId, arg);
        // Question: Is the 'var' here a VarExpr? Does it allow further cons? 
        ExprOrFormula var = n.getVar();
        ExprOrFormula bound = n.getBound();
        Body body = n.getBody();
        arg.addChildren(child);
        if (var instanceof VarExpr) { 
            VarExpr varExpr = (VarExpr) var;
            AugmentedNode letNode = new AugmentedNode(122, uniqueNode.size());
            Symbol varSymbol = new RefSymbol(letNode, varExpr.getName());
            uniqueNode.put(varSymbol, letNode);
            child.addSymbol(varSymbol);
            AugmentedNode boundNode = bound.accept(this, arg); 
            AugmentedNode bodyNode = body.accept(this, child);
            visitAndConnect(letNode, boundNode, 1, arg);
            visitAndConnect(letNode, bodyNode, 2, arg);
            return letNode;
        } else {
            throw new RuntimeException("Implicit let not supported! ");
        }
    }

    private AugmentedNode visitITE(ITEExprOrFormula n, ScopeTreeNode arg) {
        int semantic = n instanceof ITEExpr ? 1 : 2;
        AugmentedNode ITEDummy = new AugmentedNode(2, semantic);
        updateTimeOfVisit(ITEDummy);
        ExprOrFormula condition = n.getCondition();
        ExprOrFormula thenClause = n.getThenClause();
        ExprOrFormula elseClause = n.getElseClause();
        AugmentedNode condNode = condition.accept(this, arg);
        AugmentedNode thenNode = thenClause.accept(this, arg);
        AugmentedNode elseNode = elseClause.accept(this, arg);
        visitAndConnect(ITEDummy, condNode, 1, arg);
        visitAndConnect(ITEDummy, thenNode, 2, arg);
        visitAndConnect(ITEDummy, elseNode, 3, arg);
        return ITEDummy;
    }

    @Override
    public AugmentedNode visit(ITEFormula n, ScopeTreeNode arg) {
        return visitITE(n, arg);
    }

    @Override
    public AugmentedNode visit(ITEExpr n, ScopeTreeNode arg) {
        return visitITE(n, arg);
    }

    // A list of Var Decls with confiners, usually the actual root under a predicate
    private AugmentedNode visitQt(QtExprOrFormula n, ScopeTreeNode arg) {
        int semantic = n instanceof QtExpr ? 1 : 2;
        List<VarDecl> varDecls = n.getVarDecls();
        scopeNodeId++;
        ScopeTreeNode subscope = new ScopeTreeNode(scopeNodeId, arg);
        Body body = n.getBody();
        Multigraph graph = arg.getAffliation();
        AugmentedNode qtRoot = new AugmentedNode(3, semantic);
        graph.addVertex(qtRoot);
        int iter = 2;
        for (VarDecl var : varDecls) {
            AugmentedNode varDeclNode = visitRelDecl(var, subscope);
            graph.connect(qtRoot, varDeclNode, iter, 1);
            iter++;
        }
        AugmentedNode bodyNode = body.accept(this, subscope);
        visitAndConnect(qtRoot, bodyNode, 1, subscope);
        return qtRoot;
    }

    @Override
    public AugmentedNode visit(QtFormula n, ScopeTreeNode arg) {
        return visitQt(n, arg);
    }

    @Override
    public AugmentedNode visit(QtExpr n, ScopeTreeNode arg) {
        return visitQt(n, arg);
    }

    @Override
    public AugmentedNode visit(CallFormula n, ScopeTreeNode arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(CallExpr n, ScopeTreeNode arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ListFormula n, ScopeTreeNode arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(ListExpr n, ScopeTreeNode arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(BinaryFormula n, ScopeTreeNode arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(BinaryExpr n, ScopeTreeNode arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(UnaryFormula n, ScopeTreeNode arg) {
        // Implementation here
        return null;
    }

    @Override
    public AugmentedNode visit(UnaryExpr n, ScopeTreeNode arg) {
        // Implementation here
        return null;
    }

    // TODO: Singular exprs starting here. 
    // Only invoked when the symbol was already declared and now used. 
    private AugmentedNode visitAbsorbing(ExprOrFormula n, ScopeTreeNode arg, String name) {
        if (aame.hasSymbol(name)) {
            return uniqueNode.get(aame.getSymbol(name)); // a global var
        } else {
            return uniqueNode.get(arg.getSymbol(name)); // recursively find the unique node
        }
    }

    @Override
    public AugmentedNode visit(VarExpr n, ScopeTreeNode arg) {
        String name = n.getName();
        return visitAbsorbing(n, arg, name);
    }

    // TODO: How about fields? 
    @Override
    public AugmentedNode visit(FieldExpr n, ScopeTreeNode arg) {
        String name = n.getName();
        return visitAbsorbing(n, arg, name);
    }

    @Override
    public AugmentedNode visit(SigExpr n, ScopeTreeNode arg) {
        String name = n.getName();
        return visitAbsorbing(n, arg, name);
    }

    @Override
    public AugmentedNode visit(ExprOrFormula n, ScopeTreeNode arg) {
        AugmentedNode undefinedExpr = new AugmentedNode(-128, 0);
        return undefinedExpr;
    }

    @Override
    public AugmentedNode visit(VarDecl n, ScopeTreeNode arg) {
        return visitRelDecl(n, arg);
    }

    @Override
    public AugmentedNode visit(FieldDecl n, ScopeTreeNode arg) {
        SigDecl sig = (SigDecl) n.getParent();
        String sigName = sig.getName();
        int isVar = n.isVariable() ? 1 : 0;
        int isDisj = n.isDisjoint() ? 1 : 0;
        int semantic = isVar << 1 + isDisj;
        AugmentedNode declRoot = new AugmentedNode(-1, semantic);
        if (timeOfVisitMap.containsKey(declRoot)) {
            int prevValue = timeOfVisitMap.get(declRoot);
            timeOfVisitMap.put(declRoot, prevValue + 1);
        } else {
            timeOfVisitMap.put(declRoot, 1);
        }
        if (!aame.hasSymbol(sigName)) {
            throw new RuntimeException("No signature found in AAME for signature " + sigName + " of field " + n.getNames().toString());
        }
        ExprOrFormula fieldRelType = n.getExpr();
        Pair<SigSymbol, Set<FieldConfiner>> targetPair = getSigSymbolByExpr(fieldRelType);
        SigSymbol targetSymbol = targetPair.a;
        Set<FieldConfiner> confiners = targetPair.b;
        SigSymbol sourceSymbol = (SigSymbol) aame.getSymbol(sigName);
        int iter = 2;
        for (String fieldName : n.getNames()) {
            Symbol fieldSymbol = new FieldRelation(fieldName, sourceSymbol, targetSymbol, confiners);
            AugmentedNode fieldNode = new AugmentedNode(125, uniqueNode.size());
            uniqueNode.put(fieldSymbol, fieldNode);
            // TODO: Name problem? Consider same-name nodes...
            visitAndConnect(declRoot, fieldNode, iter, arg);
            iter++;
        }
        return declRoot;
    }
}