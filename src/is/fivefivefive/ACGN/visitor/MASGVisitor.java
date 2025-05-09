package is.fivefivefive.ACGN.visitor;
import java.util.Map;
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
import is.fivefivefive.ACGN.alloy.AssertSymbol;
import is.fivefivefive.ACGN.alloy.ConstSymbol;
import is.fivefivefive.ACGN.alloy.EndSymbol;
import is.fivefivefive.ACGN.alloy.ExtFact;
import is.fivefivefive.ACGN.alloy.FieldConfiner;
import is.fivefivefive.ACGN.alloy.FieldRelation;
import is.fivefivefive.ACGN.alloy.MiddleSymbol;
import is.fivefivefive.ACGN.alloy.RefSymbol;
import is.fivefivefive.ACGN.alloy.SetSymbol;
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
import parser.ast.nodes.BinaryExpr.BinaryOp;
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

// TODO : RESTRUCTURE: Get rid of all unnecessary new objects by looking for the nodes first. 
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
    // Unique nodes with unique symbols to represent.
    private DoubleMap<Symbol, AugmentedNode> uniqueNode;
    private final Symbol END_SYMBOL = new EndSymbol();
    private final AugmentedNode END_NODE = new AugmentedNode(-128, 0, END_SYMBOL);
    private Map<Integer, AugmentedNode> nodeDict;
    private AugmentedNode overallRoot;
    private Map<String, SigSymbol> unfoundSigs;

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
        nodeDict = new HashMap<>();
        nodeDict.put(0, END_NODE);
        unfoundSigs = new HashMap<>();
    }
    public MASGVisitor(GlobalVariables gv) {
        this();
        globalVariables = gv;
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
    public AugmentedNode getOverallRoot() {
        return overallRoot;
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
     *   1 = block starters of a FUNCTION (returns a set or element of a set);
     *   -1 = block starters of a PREDICATE (returns a boolean);
     *   21 = ASSERTIONS
     *   2 = dummy node for ITE / => ELSE EXPRS (set);
     *   -2 = dummy node for ITE / => ELSE FORMULAE (BOOLEAN) 
     *   3 = dummy node for the root of a quantifier EXPR; 
     *   -3 = dummy node for the root of a quantifier FORMULA;
     *   4 = starter of a ListExpr;
     *   -4 = starter of a ListFormula;
     *   5 = starter of a BinaryExpr;
     *   -5 = Binary Formula;
     *   6 = Unary Expr;
     *   -6 = Unary Formula;
     *   7 = CallExpr;
     *  -7 = CallFormula;
     *   -127 = dummy node for the list of declarations;
     *   -128 = the End Symbol (predefined);
     *   121 - 'iden' constant
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
        overallRoot = mu;
        Multigraph demoGraph = forest.get(0);
        rootScope = new ScopeTreeNode(0, null, demoGraph);
        demoGraph.addVertex(mu);
        AugmentedNode md = n.getModuleDecl().accept(this, rootScope);
        demoGraph.addVertex(md);
        demoGraph.connect(mu, md, 1, 1);
        // Open: non-modificable, syn == 0, sem == 3;
        for (OpenDecl o : n.getOpenDeclList()) {
            AugmentedNode oNode = o.accept(this, rootScope);
            demoGraph.addVertex(oNode);
            demoGraph.connect(mu, oNode, 2, 1);
            
        }
        int predId = 0;
        // SigDecl: non-mod, syn == 0, sem == 4; defines a new symbol in scope.
        for (SigDecl sd : n.getSigDeclList()) {
            AugmentedNode sdNode = sd.accept(this, rootScope);
            demoGraph.addVertex(sdNode);
            demoGraph.connect(mu, sdNode, 3 + predId, 1);
            predId++;
        }

        // Predicate : each creates a tree in the forest. syn = 1, sem == 0; define a new predicate, which is a subtree. 
        // the foci of learning
        
        for (Predicate p : n.getPredDeclList()) {
            AugmentedNode pNode = p.accept(this, rootScope);
            demoGraph.addVertex(pNode);
            demoGraph.connect(mu, pNode, 3 + predId, 1);
            predId++;
        }

        // Function : a callable symbol, unchanged in operation
        for (Function f : n.getFunDeclList()) {
            AugmentedNode fNode = f.accept(this, rootScope);
            demoGraph.addVertex(fNode);
            demoGraph.connect(mu, fNode, 3 + predId, 1);
            predId++;
        }
        // Facts can be directly stored in AAME. 
        for (Fact f : n.getFactDeclList()) {
            AugmentedNode fNode = f.accept(this, rootScope);
            demoGraph.addVertex(fNode);
            demoGraph.connect(mu, fNode, 3 + predId, 1);
            predId++;
        }
        // Assertion: a non-modifiable node, syn == 0, sem == 21
        for (Assertion a : n.getAssertDeclList()) {
            AugmentedNode aNode = a.accept(this, rootScope);
            demoGraph.addVertex(aNode);
            demoGraph.connect(mu, aNode, 3 + predId, 1);
            predId++;
        }
        // Check: a non-modifiable node, syn == 0, sem == 101
        for (Check c : n.getCheckCmdList()) {
            AugmentedNode cNode = c.accept(this, rootScope);
            demoGraph.addVertex(cNode);
            demoGraph.connect(mu, cNode, 3 + predId, 1);
            predId++;
        }
        // Run: a non-modifiable node, syn == 0, sem == 102
        for (Run r : n.getRunCmdList()) {
            AugmentedNode rNode = r.accept(this, rootScope);
            demoGraph.addVertex(rNode);
            demoGraph.connect(mu, rNode, 3 + predId, 1);
            predId++;
        }
        if (!unfoundSigs.isEmpty()) {
            throw new RuntimeException("Unfound sigs: " + unfoundSigs);
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
        if (unfoundSigs.containsKey(nameKey)) {
            sigsy = unfoundSigs.get(nameKey);
            unfoundSigs.remove(nameKey);
        }
        aame.addSymbol(nameKey, sigsy);
        rootScope.addSymbol(sigsy);
        AugmentedNode sigExprNode = new AugmentedNode(126, uniqueNode.size(), sigsy);
        uniqueNode.put(sigsy, sigExprNode);
        int iter = 1;
        for (FieldDecl f : n.getFieldList()) {
            AugmentedNode field = f.accept(this, arg);
            visitAndConnect(sigExprNode, field, iter, arg);
            iter++;
        }
        visitAndConnect(sigExprNode, END_NODE, iter, arg);
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
        // Once declared, the PredNode when called is just a near-leaf (d=1) node symbol. 
        int syn = n instanceof Function ? 1 : -1;
        AugmentedNode predNode = new AugmentedNode(syn, numPredicates);
        timeOfVisitMap.put(predNode, 1);
        String predName = n.getName();
        Symbol predSymbol = new RefSymbol(predNode, predName);
        predNode.setSymbol(predSymbol);
        uniqueNode.put(predSymbol, predNode);
        aame.addSymbol(predName, predSymbol);
        Multigraph predGraph = new Multigraph(predNode, globalVariables);
        forest.put(numPredicates, predGraph);
        // localSymbols.put(predGraph, new HashSet<Symbol>());
        ScopeTreeNode subscope = new ScopeTreeNode(scopeNodeId, rootScope, predGraph);

        int iter = 2;
        for (ParamDecl pd : n.getParamList()) {
            // From here, we need to pass the subgraph into the child nodes.
            // TODO: Incorporate the timeOfVisitMap to ensure unique visit time.
            AugmentedNode pdNode = pd.accept(this, subscope);
            globalVariables.addEdge(predNode, pdNode, 2); // equivalent in infinity;
            predGraph.connect(predNode, pdNode, iter, 1);
            iter++;
        }
        AugmentedNode bodyNode = n.getBody().accept(this, subscope);
        globalVariables.addEdge(predNode, bodyNode, 1);
        predGraph.addVertex(bodyNode);
        predGraph.connect(predNode, bodyNode, 1, 1);
        return predNode;
    }

    // Assume that a RelDecl declares a set of relations all subject to the same type scope. 
    // RelDecls here except Fields.
    // TODO: How to capture the types of the RelDecls???
    private AugmentedNode visitRelDecl(RelDecl n, ScopeTreeNode arg) {
        // All real decls goes to this. Concrete symbol to consider. 
        // Set<Symbol> localSyms = arg.getSymbols();
        int isVar = n.isVariable() ? 1 : 0;
        int isDisj = n.isDisjoint() ? 1 : 0;
        // syntactic: according to the signature type and the confiners. 
        int semantic = isVar * 2 + isDisj; // class of the decl; confined by property of the decl. 
        Symbol declRootSym = new MiddleSymbol("RELDECL_" + semantic);
        AugmentedNode declRoot = new AugmentedNode(-127, semantic, declRootSym); // a virtual root node of the decl set. 
        updateTimeOfVisit(declRoot);
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
        globalVariables.addEdge(declRoot, exprNode, 1);
        visitAndConnect(declRoot, exprNode, 1, arg);
        Pair<SetSymbol, Set<FieldConfiner>> sigPair = getSigSymbolByExpr(expr);
        SetSymbol sigSymbol = sigPair.a;
        Set<FieldConfiner> confiners = sigPair.b;
        for (String name : n.getNames()) {
            VarSymbol varSym = new VarSymbol(sigSymbol.getName(), name, forest.rget(graph));
            varSym.setFieldConfinerSet(confiners);
            arg.addSymbol(varSym);
            uniqueNode.put(varSym, new AugmentedNode(127, uniqueNode.size(), varSym));
        }
        int iter = 2;
        for (ExprOrFormula v : n.getVariables()) {
            AugmentedNode varNode = v.accept(this, arg);
            globalVariables.addEdge(declRoot, varNode, iter);
            visitAndConnect(declRoot, varNode, iter, arg);
            iter++;
        }
        // graph.addVertex(END_NODE);
        visitAndConnect(declRoot, END_NODE, iter, arg);
        return declRoot;
    }
    // TODO: Down here we need more implementation of the gv augmentations.

    private void visitAndConnect(AugmentedNode parent, AugmentedNode child, int position, ScopeTreeNode arg) {
        if (child == null) {
            return;
        }
        int timeOfVisit = timeOfVisitMap.containsKey(parent) ? timeOfVisitMap.get(parent) : 1;
        Multigraph graph = arg.getAffliation();
        graph.addVertex(parent);
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

    private Pair<SetSymbol, Set<FieldConfiner>> getSigSymbolByExpr(ExprOrFormula n) {
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
                    case NOOP:
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
                    sigSymbol = new SigSymbol(sigName);
                    unfoundSigs.put(sigName, (SigSymbol) sigSymbol);
                }
                SigSymbol concSigSymbol = (SigSymbol) sigSymbol;
                return Pair.of(concSigSymbol, confiners);
            } else {
                if (iter instanceof BinaryExpr) {
                    BinaryExpr binExpr = (BinaryExpr) iter;
                    if (binExpr.getOp() == BinaryOp.JOIN) {
                        FieldExpr fieldExpr = (FieldExpr) binExpr.getChildren().get(1);
                        String fieldName = fieldExpr.getName();
                        Symbol fieldSymbol = aame.getSymbol(fieldName);
                        return Pair.of((FieldRelation) fieldSymbol, confiners);
                    }
                }
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
        return new AugmentedNode(0, 101);
    }

    @Override
    public AugmentedNode visit(Run n, ScopeTreeNode arg) {
        return new AugmentedNode(0, 102);
    }

    // Assertion is also a paragraph to be checked
    @Override
    public AugmentedNode visit(Assertion n, ScopeTreeNode arg) {
        String name = n.getName();
        AugmentedNode assertionRoot = new AugmentedNode(21, 1);
        Multigraph subgraph = new Multigraph(assertionRoot, globalVariables);
        Symbol assertionSym = new AssertSymbol(name, subgraph);
        arg.addSymbol(assertionSym);
        uniqueNode.put(assertionSym, assertionRoot);
        assertionRoot.setSymbol(assertionSym);
        aame.addSymbol(name, assertionSym);
        scopeNodeId++;
        ScopeTreeNode subscope = new ScopeTreeNode(scopeNodeId, arg, subgraph);
        AugmentedNode body = n.getBody().accept(this, subscope);
        globalVariables.addEdge(assertionRoot, body, 1);
        visitAndConnect(assertionRoot, body, 1, subscope);
        return assertionRoot;
    }
    
    // catch the explicit facts
    @Override
    public AugmentedNode visit(Fact n, ScopeTreeNode arg) {
        PrettyStringVisitor psv = new PrettyStringVisitor();
        String code = psv.visit(n, null);
        ExtFact fact = new ExtFact(true, code);
        aame.addFact(fact);
        return new AugmentedNode(0, 5);
    }

    @Override
    public AugmentedNode visit(ConstExpr n, ScopeTreeNode arg) {
        String val = n.getValue();
        if (n.isBoolean()) {
            if (val.equalsIgnoreCase("true")) {
                Symbol boolSymbol = new ConstSymbol("true", true, false);
                return new AugmentedNode(124, 1, boolSymbol);
            } else {
                Symbol boolSymbol = new ConstSymbol("false", true, false);
                return new AugmentedNode(124, 0, boolSymbol);
            }
        } else {
            if (val.equalsIgnoreCase("iden")) {
                Symbol constSymbol = new ConstSymbol("iden", false, true);
                return new AugmentedNode(121, 1, constSymbol);
            }
            try {
                int semantic = Integer.parseInt(n.getValue());
                Symbol constSymbol = new ConstSymbol(n.getValue(), false, false);
                return new AugmentedNode(123, semantic, constSymbol);
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
            letNode.setSymbol(varSymbol);
            AugmentedNode boundNode = bound.accept(this, arg); 
            globalVariables.addEdge(letNode, boundNode, 1);
            AugmentedNode bodyNode = body.accept(this, child);
            globalVariables.addEdge(letNode, bodyNode, 2);
            visitAndConnect(letNode, boundNode, 1, arg);
            visitAndConnect(letNode, bodyNode, 2, arg);
            return letNode;
        } else {
            throw new RuntimeException("Implicit let not supported! ");
        }
    }

    private AugmentedNode visitITE(ITEExprOrFormula n, ScopeTreeNode arg) {
        int syntactic = n instanceof ITEExpr ? 2 : -2;
        String label = n instanceof ITEExpr ? "ITE_EXPR" : "ITE_FORMULA";
        MiddleSymbol ITESymbol = new MiddleSymbol(label);
        AugmentedNode ITEDummy;
        if (uniqueNode.containsKey(ITESymbol)) {
            ITEDummy = uniqueNode.get(ITESymbol);
        } else {
            ITEDummy = new AugmentedNode(syntactic, 1, ITESymbol);
            uniqueNode.put(ITESymbol, ITEDummy);
        }
        updateTimeOfVisit(ITEDummy);
        ExprOrFormula condition = n.getCondition();
        ExprOrFormula thenClause = n.getThenClause();
        ExprOrFormula elseClause = n.getElseClause();
        AugmentedNode condNode = condition.accept(this, arg);
        globalVariables.addEdge(ITEDummy, condNode, 1);
        AugmentedNode thenNode = thenClause.accept(this, arg);
        globalVariables.addEdge(ITEDummy, thenNode, 2);
        AugmentedNode elseNode = elseClause.accept(this, arg);
        globalVariables.addEdge(ITEDummy, elseNode, 3);
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
        int syntactic = n instanceof QtExpr ? 3 : -3;
        String label = n instanceof QtExpr ? "QT_EXPR" : "QT_FORMULA";
        MiddleSymbol qtSymbol = new MiddleSymbol(label);
        List<VarDecl> varDecls = n.getVarDecls();
        scopeNodeId++;
        ScopeTreeNode subscope = new ScopeTreeNode(scopeNodeId, arg);
        Body body = n.getBody();
        Multigraph graph = arg.getAffliation();
        AugmentedNode qtRoot;
        if (uniqueNode.containsKey(qtSymbol)) {
            qtRoot = uniqueNode.get(qtSymbol);
        } else {
            qtRoot = new AugmentedNode(syntactic, 1, qtSymbol);
            uniqueNode.put(qtSymbol, qtRoot);
        }
        graph.addVertex(qtRoot);
        updateTimeOfVisit(qtRoot);
        int iter = 2;
        for (VarDecl var : varDecls) {
            AugmentedNode varDeclNode = visitRelDecl(var, subscope);
            globalVariables.addEdge(qtRoot, varDeclNode, 2);
            visitAndConnect(qtRoot, varDeclNode, iter, subscope);
            iter++;
        }
        visitAndConnect(qtRoot, END_NODE, iter, subscope);
        AugmentedNode bodyNode = body.accept(this, subscope);
        globalVariables.addEdge(qtRoot, bodyNode, 1);
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

    // Calling a predicate or function
    @Override
    public AugmentedNode visit(CallFormula n, ScopeTreeNode arg) {
        Symbol callSymbol = new MiddleSymbol("CALL_FORMULA");
        AugmentedNode callNode;
        if (uniqueNode.containsKey(callSymbol)) {
            callNode = uniqueNode.get(callSymbol);
        } else {
            callNode = new AugmentedNode(-7, 1, callSymbol);
            uniqueNode.put(callSymbol, callNode);
        }
        arg.getAffliation().addVertex(callNode);
        updateTimeOfVisit(callNode);
        Symbol predOrFunSymbol = aame.getSymbol(n.getName());
        AugmentedNode calledNode = uniqueNode.get(predOrFunSymbol);
        globalVariables.addEdge(callNode, calledNode, 1);
        // connect the callNode to the calledNode at position 1
        visitAndConnect(callNode, calledNode, 1, arg);
        int iter = 2;
        for (ExprOrFormula param : n.getArguments()) {
            AugmentedNode paramAug = param.accept(this, arg);
            globalVariables.addEdge(callNode, calledNode, 2);
            visitAndConnect(callNode, paramAug, iter, arg);
            iter++;
        }
        visitAndConnect(callNode, END_NODE, iter, arg);
        return callNode;
    }

    @Override
    public AugmentedNode visit(CallExpr n, ScopeTreeNode arg) {
        Symbol callSymbol = new MiddleSymbol("CALL_EXPR");
        AugmentedNode callNode;
        if (uniqueNode.containsKey(callSymbol)) {
            callNode = uniqueNode.get(callSymbol);
        } else {
            callNode = new AugmentedNode(7, 1, callSymbol);
            uniqueNode.put(callSymbol, callNode);
        }
        arg.getAffliation().addVertex(callNode);
        updateTimeOfVisit(callNode);
        Symbol predOrFunSymbol = aame.getSymbol(n.getName());
        AugmentedNode calledNode = uniqueNode.get(predOrFunSymbol);
        globalVariables.addEdge(callNode, calledNode, 1);
        arg.getAffliation().connect(callNode, calledNode, 1, timeOfVisitMap.get(callNode));
        int iter = 2;
        for (ExprOrFormula param : n.getArguments()) {
            AugmentedNode paramAug = param.accept(this, arg);
            globalVariables.addEdge(callNode, calledNode, 2);
            visitAndConnect(callNode, paramAug, iter, arg);
            iter++;
        }
        visitAndConnect(callNode, END_NODE, iter, arg);
        return callNode;
    }

    @Override
    public AugmentedNode visit(ListFormula n, ScopeTreeNode arg) {
        int semantics;
        switch (n.getOp()) {
            case AND: semantics = 1; break;
            case OR: semantics = 2; break;
            default: throw new RuntimeException("Custom labeled list not supported");
        }
        MiddleSymbol opSymbol = new MiddleSymbol("LIST_FORMULA_" + semantics);
        AugmentedNode opNode;
        if (uniqueNode.containsKey(opSymbol)) {
            opNode = uniqueNode.get(opSymbol);
        } else {
            opNode = new AugmentedNode(-4, semantics, opSymbol);
            uniqueNode.put(opSymbol, opNode);
        }
        arg.getAffliation().addVertex(opNode);
        updateTimeOfVisit(opNode);
        int iter = 1;
        for (ExprOrFormula child : n.getArguments()) {
            AugmentedNode argChildNode = child.accept(this, arg);
            globalVariables.addEdge(opNode, argChildNode, 2);
            visitAndConnect(opNode, argChildNode, iter, arg);
            iter++;
        }
        globalVariables.addEdge(opNode, END_NODE, iter);
        visitAndConnect(opNode, END_NODE, iter, arg);
        return opNode;
    }

    @Override
    public AugmentedNode visit(ListExpr n, ScopeTreeNode arg) {
        int semantics;
        switch (n.getOp()) {
            case DISJOINT: semantics = 1; break;
            case TOTALORDER: semantics = 2; break;
            default: throw new RuntimeException("Custom labeled list not supported");
        }
        MiddleSymbol opSymbol = new MiddleSymbol("LIST_EXPR_" + semantics);
        AugmentedNode opNode;
        if (uniqueNode.containsKey(opSymbol)) {
            opNode = uniqueNode.get(opSymbol);
        } else {
            opNode = new AugmentedNode(4, semantics, opSymbol);
            uniqueNode.put(opSymbol, opNode);
        }
        updateTimeOfVisit(opNode);
        int iter = 1;
        for (ExprOrFormula child : n.getArguments()) {
            AugmentedNode argChildNode = child.accept(this, arg);
            globalVariables.addEdge(opNode, argChildNode, 2);
            visitAndConnect(opNode, argChildNode, iter, arg);
            iter++;
        }
        visitAndConnect(opNode, END_NODE, iter, arg);
        return opNode;
    }

    @Override
    public AugmentedNode visit(BinaryFormula n, ScopeTreeNode arg) {
        String symbolLabel = "BOP_";
        int semantic = 0;
        int syntactic = -5;
        switch (n.getOp()) {
            case EQUALS: 
                symbolLabel = "BOP_EQ"; 
                semantic = 1;
                break;
            case NOT_EQUALS: 
                symbolLabel = "BOP_NEQ"; 
                semantic = 2;
                break;
            case AND:
                symbolLabel = "BOP_AND";
                semantic = 3;
                break;
            case GT:
                symbolLabel = "BOP_GT";
                semantic = 4;
                break;
            case GTE:
                symbolLabel = "BOP_GTE";
                semantic = 5;
                break;
            case IFF:
                symbolLabel = "BOP_IFF";
                semantic = 6;
                break;
            case IMPLIES:
                symbolLabel = "BOP_IMPLIES";
                semantic = 7;
                break;
            case IN:
                symbolLabel = "BOP_IN";
                semantic = 8;
                break;
            case LT:
                symbolLabel = "BOP_LT";
                semantic = 9;
                break;
            case LTE:
                symbolLabel = "BOP_LTE";
                semantic = 10;
                break;
            case NOT_GT:
                symbolLabel = "BOP_NOT_GT";
                semantic = 11;
                break;
            case NOT_GTE:
                symbolLabel = "BOP_NOT_GTE";
                semantic = 12;
                break;
            case NOT_IN:
                symbolLabel = "BOP_NOT_IN";
                semantic = 13;
                break;
            case NOT_LT:
                symbolLabel = "BOP_NOT_LT";
                semantic = 14;
                break;
            case NOT_LTE:
                symbolLabel = "BOP_NOT_LTE";
                semantic = 15;
                break;
            case OR:
                symbolLabel = "BOP_OR";
                semantic = 16;
                break;
            case RELEASES:
                symbolLabel = "BOP_RELEASES";
                semantic = 17;
                break;
            case SINCE:
                symbolLabel = "BOP_SINCE";
                semantic = 18;
                break;
            case TRIGGERED:
                symbolLabel = "BOP_TRIGGERED";
                semantic = 19;
                break;
            case UNTIL:
                symbolLabel = "BOP_UNTIL";
                semantic = 20;
                break;
            default:
                break;
        }
        MiddleSymbol bopSymbol = new MiddleSymbol(symbolLabel);
        AugmentedNode bopNode;
        if (uniqueNode.containsKey(bopSymbol)) {
            bopNode = uniqueNode.get(bopSymbol);
        } else {
            bopNode = new AugmentedNode(syntactic, semantic, bopSymbol);
            uniqueNode.put(bopSymbol, bopNode);
        }
        arg.getAffliation().addVertex(bopNode);
        updateTimeOfVisit(bopNode);
        ExprOrFormula left = n.getLeft();
        ExprOrFormula right = n.getRight();
        AugmentedNode leftNode = left.accept(this, arg);
        globalVariables.addEdge(bopNode, leftNode, 1);
        AugmentedNode rightNode = right.accept(this, arg);
        globalVariables.addEdge(bopNode, rightNode, 2);
        visitAndConnect(bopNode, leftNode, 1, arg);
        visitAndConnect(bopNode, rightNode, 2, arg);
        return bopNode;
    }

    @Override
    public AugmentedNode visit(BinaryExpr n, ScopeTreeNode arg) {
        String symbolLabel = "BOPEXPR_";
        int syntactic = 5;
        int semantic = 0;
        switch (n.getOp()) {
            case ARROW:
                symbolLabel = "BOPEXPR_ARROW";
                semantic = 1;
                break;
            case ANY_ARROW_SOME:
                symbolLabel = "BOPEXPR_ANY_ARROW_SOME";
                semantic = 2;
                break;
            case ANY_ARROW_ONE:
                symbolLabel = "BOPEXPR_ANY_ARROW_ONE";
                semantic = 3;
                break;
            case ANY_ARROW_LONE:
                symbolLabel = "BOPEXPR_ANY_ARROW_LONE";
                semantic = 4;
                break;
            case SOME_ARROW_ANY:
                symbolLabel = "BOPEXPR_SOME_ARROW_ANY";
                semantic = 5;
                break;
            case SOME_ARROW_SOME:
                symbolLabel = "BOPEXPR_SOME_ARROW_SOME";
                semantic = 6;
                break;
            case SOME_ARROW_ONE:
                symbolLabel = "BOPEXPR_SOME_ARROW_ONE";
                semantic = 7;
                break;
            case SOME_ARROW_LONE:
                symbolLabel = "BOPEXPR_SOME_ARROW_LONE";
                semantic = 8;
                break;
            case ONE_ARROW_ANY:
                symbolLabel = "BOPEXPR_ONE_ARROW_ANY";
                semantic = 9;
                break;
            case ONE_ARROW_SOME:
                symbolLabel = "BOPEXPR_ONE_ARROW_SOME";
                semantic = 10;
                break;
            case ONE_ARROW_ONE:
                symbolLabel = "BOPEXPR_ONE_ARROW_ONE";
                semantic = 11;
                break;
            case ONE_ARROW_LONE:
                symbolLabel = "BOPEXPR_ONE_ARROW_LONE";
                semantic = 12;
                break;
            case LONE_ARROW_ANY:
                symbolLabel = "BOPEXPR_LONE_ARROW_ANY";
                semantic = 13;
                break;
            case LONE_ARROW_SOME:
                symbolLabel = "BOPEXPR_LONE_ARROW_SOME";
                semantic = 14;
                break;
            case LONE_ARROW_ONE:
                symbolLabel = "BOPEXPR_LONE_ARROW_ONE";
                semantic = 15;
                break;
            case LONE_ARROW_LONE:
                symbolLabel = "BOPEXPR_LONE_ARROW_LONE";
                semantic = 16;
                break;
            case ISSEQ_ARROW_LONE:
                symbolLabel = "BOPEXPR_ISSEQ_ARROW_LONE";
                semantic = 17;
                break;
            case JOIN:
                symbolLabel = "BOPEXPR_JOIN";
                semantic = 18;
                break;
            case DOMAIN:
                symbolLabel = "BOPEXPR_DOMAIN";
                semantic = 19;
                break;
            case INTERSECT:
                symbolLabel = "BOPEXPR_INTERSECT";
                semantic = 20;
                break;
            case PLUSPLUS:
                symbolLabel = "BOPEXPR_PLUSPLUS";
                semantic = 21;
                break;
            case PLUS:
                symbolLabel = "BOPEXPR_PLUS";
                semantic = 22;
                break;
            case IPLUS:
                symbolLabel = "BOPEXPR_IPLUS";
                semantic = 23;
                break;
            case MINUS:
                symbolLabel = "BOPEXPR_MINUS";
                semantic = 24;
                break;
            case IMINUS:
                symbolLabel = "BOPEXPR_IMINUS";
                semantic = 25;
                break;
            case MUL:
                symbolLabel = "BOPEXPR_MUL";
                semantic = 26;
                break;
            case DIV:
                symbolLabel = "BOPEXPR_DIV";
                semantic = 27;
                break;
            case REM:
                symbolLabel = "BOPEXPR_REM";
                semantic = 28;
                break;
            case SHL:
                symbolLabel = "BOPEXPR_SHL";
                semantic = 29;
                break;
            case SHA:
                symbolLabel = "BOPEXPR_SHA";
                semantic = 30;
                break;
            case SHR:
                symbolLabel = "BOPEXPR_SHR";
                semantic = 31;
                break;
            default:
                break;
        }
        MiddleSymbol bopSymbol = new MiddleSymbol(symbolLabel);
        AugmentedNode bopNode;
        if (uniqueNode.containsKey(bopSymbol)) {
            bopNode = uniqueNode.get(bopSymbol);
        } else {
            bopNode = new AugmentedNode(syntactic, semantic, bopSymbol);
            uniqueNode.put(bopSymbol, bopNode);
        }
        arg.getAffliation().addVertex(bopNode);
        updateTimeOfVisit(bopNode);
        ExprOrFormula left = n.getLeft();
        ExprOrFormula right = n.getRight();
        AugmentedNode leftNode = left.accept(this, arg);
        globalVariables.addEdge(bopNode, leftNode, 1);
        AugmentedNode rightNode = right.accept(this, arg);
        globalVariables.addEdge(bopNode, rightNode, 2);
        visitAndConnect(bopNode, leftNode, 1, arg);
        visitAndConnect(bopNode, rightNode, 2, arg);
        return bopNode;
    }

    @Override
    public AugmentedNode visit(UnaryFormula n, ScopeTreeNode arg) {
        String symbolLabel = "UNOPF_";
        int syntactic = -6;
        int semantic = 0;
        switch (n.getOp()) {
            case LONE:
                symbolLabel = "UNOPF_LONE";
                semantic = 1;
                break;
            case ONE:
                symbolLabel = "UNOPF_ONE";
                semantic = 2;
                break;
            case SOME:
                symbolLabel = "UNOPF_SOME";
                semantic = 3;
                break;
            case NO:
                symbolLabel = "UNOPF_NO";
                semantic = 4;
                break;
            case NOT:
                symbolLabel = "UNOPF_NOT";
                semantic = 5;
                break;
            case BEFORE:
                symbolLabel = "UNOPF_BEFORE";
                semantic = 6;
                break;
            case HISTORICALLY:
                symbolLabel = "UNOPF_HISTORICALLY";
                semantic = 7;
                break;
            case ONCE:
                symbolLabel = "UNOPF_ONCE";
                semantic = 8;
                break;
            case ALWAYS:
                symbolLabel = "UNOPF_ALWAYS";
                semantic = 9;
                break;
            case EVENTUALLY:
                symbolLabel = "UNOPF_EVENTUALLY";
                semantic = 10;
                break;
            case AFTER:
                symbolLabel = "UNOPF_AFTER";
                semantic = 11;
                break;
            default:
                break;
        }
        MiddleSymbol unopSymbol = new MiddleSymbol(symbolLabel);
        AugmentedNode unopNode;
        if (uniqueNode.containsKey(unopSymbol)) {
            unopNode = uniqueNode.get(unopSymbol);
        } else {
            unopNode = new AugmentedNode(syntactic, semantic, unopSymbol);
            uniqueNode.put(unopSymbol, unopNode);
        }
        arg.getAffliation().addVertex(unopNode);
        updateTimeOfVisit(unopNode);
        ExprOrFormula sub = n.getSub();
        AugmentedNode subNode = sub.accept(this, arg);
        globalVariables.addEdge(unopNode, subNode, 1);
        visitAndConnect(unopNode, subNode, 1, arg);
        return unopNode;
    }

    @Override
    public AugmentedNode visit(UnaryExpr n, ScopeTreeNode arg) {
        String symbolLabel = "UNOPE_";
        int syntactic = 6;
        int semantic = 0;
        switch (n.getOp()) {
            case NOOP:
                return n.getSub().accept(this, arg);
            case SET:
                symbolLabel = "UNOPE_SET";
                semantic = 1;
                break;
            case LONE:
                symbolLabel = "UNOPE_LONE";
                semantic = 2;
                break;
            case ONE:
                symbolLabel = "UNOPE_ONE";
                semantic = 3;
                break;
            case SOME:
                symbolLabel = "UNOPE_SOME";
                semantic = 4;
                break;
            case EXACTLYOF:
                symbolLabel = "UNOPE_EXACTLYOF";
                semantic = 5;
                break;
            case TRANSPOSE:
                symbolLabel = "UNOPE_TRANSPOSE";
                semantic = 6;
                break;
            case RCLOSURE:
                symbolLabel = "UNOPE_RCLOSURE";
                semantic = 7;
                break;
            case CLOSURE:
                symbolLabel = "UNOPE_CLOSURE";
                semantic = 8;
                break;
            case CARDINALITY:
                symbolLabel = "UNOPE_CARDINALITY";
                semantic = 9;
                break;
            case CAST2INT:
                symbolLabel = "UNOPE_CAST2INT";
                semantic = 10;
                break;
            case CAST2SIGINT:
                symbolLabel = "UNOPE_CAST2SIGINT";
                semantic = 11;
                break;
            case PRIME:
                symbolLabel = "UNOPE_PRIME";
                semantic = 12;
                break;
            default:
                break;
        }
        MiddleSymbol unopSymbol = new MiddleSymbol(symbolLabel);
        AugmentedNode unopNode;
        if (uniqueNode.containsKey(unopSymbol)) {
            unopNode = uniqueNode.get(unopSymbol);
        } else {
            unopNode = new AugmentedNode(syntactic, semantic, unopSymbol);
            uniqueNode.put(unopSymbol, unopNode);
        }
        arg.getAffliation().addVertex(unopNode);
        updateTimeOfVisit(unopNode);
        ExprOrFormula sub = n.getSub();
        AugmentedNode subNode = sub.accept(this, arg);
        globalVariables.addEdge(unopNode, subNode, 1);
        visitAndConnect(unopNode, subNode, 1, arg);
        return unopNode;
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
        int semantic = isVar * 2 + isDisj + 4;
        Symbol declRootSym = new MiddleSymbol("FIELD_DECL");
        AugmentedNode declRoot;
        if (uniqueNode.containsKey(declRootSym)) {
            declRoot = uniqueNode.get(declRootSym);
        } else {
            declRoot = new AugmentedNode(-127, semantic, declRootSym);
            uniqueNode.put(declRootSym, declRoot);
        }
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
        Pair<SetSymbol, Set<FieldConfiner>> targetPair = getSigSymbolByExpr(fieldRelType);
        SetSymbol targetSymbol = targetPair.a;
        Set<FieldConfiner> confiners = targetPair.b;
        SigSymbol sourceSymbol = (SigSymbol) aame.getSymbol(sigName);
        int iter = 2;
        for (String fieldName : n.getNames()) {
            Symbol fieldSymbol = new FieldRelation(fieldName, sourceSymbol, targetSymbol, confiners);
            AugmentedNode fieldNode = new AugmentedNode(125, uniqueNode.size(), fieldSymbol);
            uniqueNode.put(fieldSymbol, fieldNode);
            aame.addSymbol(fieldName, fieldSymbol);
            fieldNode.setSymbol(fieldSymbol);
            // TODO: Name problem? Consider same-name nodes...
            visitAndConnect(declRoot, fieldNode, iter, arg);
            iter++;
        }
        visitAndConnect(declRoot, END_NODE, iter, arg);
        return declRoot;
    }
}