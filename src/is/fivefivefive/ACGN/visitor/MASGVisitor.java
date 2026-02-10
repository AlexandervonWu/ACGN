package is.fivefivefive.ACGN.visitor;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;

import java.util.HashSet;
import java.util.List;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.etc.BiMap;
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
import is.fivefivefive.ACGN.alloy.PredRootSymbol;
import is.fivefivefive.ACGN.alloy.RefSymbol;
import is.fivefivefive.ACGN.alloy.SetSymbol;
import is.fivefivefive.ACGN.alloy.ShadowSymbol;
import is.fivefivefive.ACGN.alloy.SigSymbol;
import is.fivefivefive.ACGN.alloy.DeclRootSymbol;
import is.fivefivefive.ACGN.test.Playground;
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
    private Map<AugmentedNode, Integer> timeOfVisitMap; // TODO: TRACK THIS. REFRACT IT INTO EACH SEPARATE MULTIGRAPH
    // ATTENTION: GlobalVariables is not the "global variables" within the model, but describing the global properties under each node.
    private GlobalVariables globalVariables;
    private int numPredicates, scopeNodeId;
    // store local symbols within the scope of each predicate.
    // TODO: We may need more branching for localSymbols. Consider a ``scope tree''. 
    // private DoubleMap<Multigraph, Set<Symbol>> localSymbols;
    private ScopeTreeNode rootScope;
    // Unique nodes with unique symbols to represent.
    private BiMap<Symbol, AugmentedNode> uniqueNode;
    public static final Symbol END_SYMBOL = new EndSymbol();
    public static final AugmentedNode END_NODE = new AugmentedNode(-128, 0, END_SYMBOL);
    private final Symbol EMPTY_SET_SYMBOL = new SigSymbol("none");
    private final AugmentedNode EMPTY_SET_NODE = new AugmentedNode(126, 0, EMPTY_SET_SYMBOL);
    public static final Symbol SHADOW_SYMBOL = new ShadowSymbol();
    public static final AugmentedNode SHADOW_NODE = new AugmentedNode(-128, 1, SHADOW_SYMBOL);
    private Map<Integer, AugmentedNode> nodeDict;
    private AugmentedNode overallRoot;
    private Map<String, SigSymbol> unfoundSigs;

    public MASGVisitor() {
        forest = new DoubleMap<>();
        aame = new AAME();
        timeOfVisitMap = new HashMap<>();
        // forest.put(0, new Multigraph()); // zero-th tree in the forest is the main AST/G
        numPredicates = 0;
        scopeNodeId = 0;
        globalVariables = new GlobalVariables();
        // localSymbols = new DoubleMap<Multigraph, Set<Symbol>>();
        uniqueNode = new BiMap<>();
        uniqueNode.put(END_SYMBOL, END_NODE);
        uniqueNode.put(EMPTY_SET_SYMBOL, EMPTY_SET_NODE);
        uniqueNode.put(SHADOW_SYMBOL, SHADOW_NODE);
        nodeDict = new HashMap<>();
        nodeDict.put(0, END_NODE);
        nodeDict.put(1, EMPTY_SET_NODE);
        nodeDict.put(2, SHADOW_NODE);
        aame.addSymbol("NONE_SET", EMPTY_SET_SYMBOL);
        unfoundSigs = new HashMap<>();
        END_NODE.setMaxDownlinks(0);
        EMPTY_SET_NODE.setMaxDownlinks(0);
        SHADOW_NODE.setMaxDownlinks(0);
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
    public BiMap<Symbol, AugmentedNode> getUniqueNode() {
        return uniqueNode;
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
        Multigraph demoGraph = new Multigraph(mu, globalVariables);
        forest.put(0, demoGraph);
        rootScope = new ScopeTreeNode(0, null, demoGraph);
        rootScope.addSymbol(EMPTY_SET_SYMBOL);
        demoGraph.addVertex(mu);
        AugmentedNode md = n.getModuleDecl().accept(this, rootScope);
        demoGraph.addVertex(md);
        demoGraph.connect(mu, md, demoGraph, 1, 1);
        // Open: non-modificable, syn == 0, sem == 3;
        for (OpenDecl o : n.getOpenDeclList()) {
            AugmentedNode oNode = o.accept(this, rootScope);
            demoGraph.addVertex(oNode);
            demoGraph.connect(mu, oNode, demoGraph, 2, 1);
            
        }
        int predId = 0;
        // SigDecl: non-mod, syn == 0, sem == 4; defines a new symbol in scope.
        for (SigDecl sd : n.getSigDeclList()) {
            AugmentedNode sdNode = sd.accept(this, rootScope);
            demoGraph.addVertex(sdNode);
            demoGraph.connect(mu, sdNode, demoGraph, 3 + predId, 1);
            predId++;
        }

        // Predicate : each creates a tree in the forest. syn = 1, sem == 0; define a new predicate, which is a subtree. 
        // the foci of learning
        
        for (Predicate p : n.getPredDeclList()) {
            AugmentedNode pNode = p.accept(this, rootScope);
            demoGraph.addVertex(pNode);
            demoGraph.connect(mu, pNode, demoGraph, 3 + predId, 1);
            predId++;
        }

        // Function : a callable symbol, unchanged in operation
        for (Function f : n.getFunDeclList()) {
            AugmentedNode fNode = f.accept(this, rootScope);
            demoGraph.addVertex(fNode);
            demoGraph.connect(mu, fNode, demoGraph, 3 + predId, 1);
            predId++;
        }
        // Facts can be directly stored in AAME. 
        for (Fact f : n.getFactDeclList()) {
            AugmentedNode fNode = f.accept(this, rootScope);
            demoGraph.addVertex(fNode);
            demoGraph.connect(mu, fNode, demoGraph, 3 + predId, 1);
            predId++;
        }
        // Assertion: a non-modifiable node, syn == 0, sem == 21
        for (Assertion a : n.getAssertDeclList()) {
            AugmentedNode aNode = a.accept(this, rootScope);
            demoGraph.addVertex(aNode);
            demoGraph.connect(mu, aNode, demoGraph, 3 + predId, 1);
            predId++;
        }
        // Check: a non-modifiable node, syn == 0, sem == 101
        for (Check c : n.getCheckCmdList()) {
            AugmentedNode cNode = c.accept(this, rootScope);
            demoGraph.addVertex(cNode);
            demoGraph.connect(mu, cNode, demoGraph, 3 + predId, 1);
            predId++;
        }
        // Run: a non-modifiable node, syn == 0, sem == 102
        for (Run r : n.getRunCmdList()) {
            AugmentedNode rNode = r.accept(this, rootScope);
            demoGraph.addVertex(rNode);
            demoGraph.connect(mu, rNode, demoGraph, 3 + predId, 1);
            predId++;
        }
        if (!unfoundSigs.isEmpty()) {
            throw new RuntimeException("Unfound sigs: " + unfoundSigs);
        }
        globalVariables.addUniqueNodes(uniqueNode);
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
        updateTimeOfVisit(sigExprNode, arg);
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
        if (arg == null) {
            rootScope = new ScopeTreeNode(scopeNodeId, null, null);
            scopeNodeId++;
        }
        numPredicates++; 
        scopeNodeId++;
        // Once declared, the PredNode when called is just a near-leaf (d=1) node symbol. 
        int syn = n instanceof Function ? 1 : -1;
        AugmentedNode predNode = new AugmentedNode(syn, numPredicates);
        
        String predName = n.getName();
        Symbol predSymbol = new PredRootSymbol(predNode, predName);
        predNode.setSymbol(predSymbol);
        uniqueNode.put(predSymbol, predNode);
        // System.out.println("Visiting predicate: " + predName + " with symbol: " + predSymbol + " into uniqueNode. ");
        aame.addSymbol(predName, predSymbol);
        Multigraph predGraph = new Multigraph(predNode, globalVariables);
        forest.put(numPredicates, predGraph);
        // localSymbols.put(predGraph, new HashSet<Symbol>());
        ScopeTreeNode subscope = new ScopeTreeNode(scopeNodeId, rootScope, predGraph);
        // System.out.println("Scope affliation root: " + subscope.getAffliation().getRoot());
        updateTimeOfVisit(predNode, subscope);
        predNode.initLocalTovAsRoot(predGraph);
        int iter = 2;
        for (ParamDecl pd : n.getParamList()) {
            // From here, we need to pass the subgraph into the child nodes.
            // TODO: Incorporate the timeOfVisitMap to ensure unique visit time.
            AugmentedNode pdNode = pd.accept(this, subscope);
            globalVariables.addEdge(predNode, pdNode, 2); // equivalent in infinity;
            visitAndConnect(predNode, pdNode, iter, subscope);
            // predGraph.connect(predNode, pdNode, iter, 1);
            iter++;
        }
        globalVariables.addEdge(predNode, END_NODE, iter);
        visitAndConnect(predNode, END_NODE, iter, subscope);
        AugmentedNode bodyNode = n.getBody().accept(this, subscope);
        globalVariables.addEdge(predNode, bodyNode, 1);
        visitAndConnect(predNode, bodyNode, 1, subscope);
        // predGraph.addVertex(bodyNode);
        // predGraph.connect(predNode, bodyNode, 1, 1);
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
        Symbol declRootSym = new DeclRootSymbol(semantic);
        AugmentedNode declRoot; // a virtual root node of the decl set. 
        if (!uniqueNode.containsKey(declRootSym)) {
            uniqueNode.put(declRootSym, new AugmentedNode(-127, semantic, declRootSym));
            declRoot = uniqueNode.get(declRootSym);
        } else {
            declRoot = uniqueNode.get(declRootSym);
            if (declRoot.getSyntactic() != -127 || declRoot.getSemantic() != semantic) {
                throw new RuntimeException("Inconsistent syntactic/semantic for " + declRootSym + ": " + declRoot);
            }
        }
        declRoot = uniqueNode.get(declRootSym) == null ? 
            declRoot : uniqueNode.get(declRootSym);
        updateTimeOfVisit(declRoot, arg);
        Multigraph graph = arg.getAffliation();
        graph.addVertex(declRoot);
        /*if (timeOfVisitMap.containsKey(declRoot)) {
            int prevValue = timeOfVisitMap.get(declRoot);
            timeOfVisitMap.put(declRoot, prevValue + 1);
        } else {
            timeOfVisitMap.put(declRoot, 1);
        }*/
        ExprOrFormula expr = n.getExpr(); // the type with constraints. 
        // TODO: Write the ExprNode accept method. 
        AugmentedNode exprNode = expr.accept(this, arg);
        AugmentedNode iterNode = exprNode;
        while (iterNode.getDownlinks() != null && !iterNode.getDownlinks().isEmpty()) {
            iterNode = iterNode.getDownlinks().get(0).getTarget();
        }
        if (iterNode.getSymbol() instanceof SigSymbol) {
            ((DeclRootSymbol) declRootSym).setSigType((SigSymbol) iterNode.getSymbol());
        } else {
            System.err.println("WARNING: NO SIG FOUND. ");
        }
        if (exprNode == null) {
            exprNode = EMPTY_SET_NODE;
        }
        globalVariables.addEdge(declRoot, exprNode, 1);
        visitAndConnect(declRoot, exprNode, 1, arg);
        // Pair<SigSymbol, Set<FieldConfiner>> sigPair = getSigSymbolByExpr(expr);
        // SigSymbol sigSymbol = sigPair.a;
        SigSymbol sigSymbol = typeCheckExpr(expr);
        for (String name : n.getNames()) {
            VarSymbol varSym = new VarSymbol(sigSymbol.getName(), name, forest.rget(graph), exprNode);
            arg.addSymbol(varSym);
            AugmentedNode varNode = new AugmentedNode(127, uniqueNode.size(), varSym);
            uniqueNode.put(varSym, varNode);
            varNode.setMaxDownlinks(0);
        }
        int iter = 2;
        for (ExprOrFormula v : n.getVariables()) {
            AugmentedNode varNode = v.accept(this, arg);
            if (Playground.DEBUG) {
                PrettyStringVisitor psv = new PrettyStringVisitor();
                String varStr = psv.visit(v, null);
                psv = new PrettyStringVisitor();
                if (n instanceof ParamDecl) {
                    ParamDecl pd = (ParamDecl) n;
                    psv = new PrettyStringVisitor();
                    String paramStr = psv.visit(pd, null);
                    // System.out.println("Visiting variable " + varStr + " in parameter declaration " + paramStr);
                } else if (n instanceof VarDecl) {
                    VarDecl vd = (VarDecl) n;
                    psv = new PrettyStringVisitor();
                    String varDeclStr = psv.visit(vd, null);
                    // System.out.println("Visiting variable " + varStr + " in variable declaration " + varDeclStr);
                } else {
                    // System.out.println("Visiting variable " + varStr + " in unknown declaration " + n.getClass().getSimpleName());
                }
            }
            // globalVariables.addEdge(declRoot, varNode, iter);
            visitAndConnect(declRoot, varNode, iter, arg);
            iter++;
        }
        // graph.addVertex(END_NODE);
        // globalVariables.addEdge(declRoot, END_NODE, iter);
        visitAndConnect(declRoot, END_NODE, iter, arg);
        return declRoot;
    }
    // TODO: Down here we need more implementation of the gv augmentations.

    private void visitAndConnect(AugmentedNode parent, AugmentedNode child, int position, ScopeTreeNode arg) {
        if (child == null) {
            return;
        }
        // int timeOfVisit = timeOfVisitMap.containsKey(parent) ? timeOfVisitMap.get(parent) : 1;
        // TODO: Retire global time of visit. 
        int timeOfVisit = arg.getAffliation().getTimeOfVisitMap().getOrDefault(parent, 1);
        Multigraph graph = arg.getAffliation();
        if (Playground.DEBUG) {
            System.out.println("Visiting " + parent.getSymbol().getName() + " for " + child.getSymbol().getName() + " at time of visit " + timeOfVisit);
        }
        graph.addVertex(parent);
        boolean flagEq = parent.equals(child);
        if (flagEq) {
            // create a shadow node
            if (Playground.DEBUG) {
                System.out.println("Shadow node created for " + parent.getSymbol().getName() + " at time of visit " + timeOfVisit);
            }
            graph.addVertex(SHADOW_NODE);
            graph.connect(parent, SHADOW_NODE, graph, position, timeOfVisit);
            globalVariables.addEdge(parent, SHADOW_NODE, position);
        } else {
            graph.addVertex(child);
            graph.connect(parent, child, graph, position, timeOfVisit);
            globalVariables.addEdge(parent, child, position);
        }
        if (Playground.DEBUG) {
            System.out.println(parent.getDownlinksAtTimeOfVisit(graph, timeOfVisit));
            System.out.println(parent.getDownlinks());
        }
    }

    // TODO: We have not touched internal nodes yet. ALSO UPDATE THE INTERNAL TIME OF VISIT
    private void updateTimeOfVisit(AugmentedNode parent, ScopeTreeNode arg) {

        if (!timeOfVisitMap.containsKey(parent)) {
            timeOfVisitMap.put(parent, 1);
        } else {
            int timeOfVisit = timeOfVisitMap.get(parent);
            timeOfVisitMap.put(parent, timeOfVisit + 1);
        }
        Multigraph graph = arg.getAffliation();
        Map<AugmentedNode, Integer> localTovMap = graph.getTimeOfVisitMap();
        if (!localTovMap.containsKey(parent)) {
            localTovMap.put(parent, 1);
            if (Playground.DEBUG) {
                System.out.println("Time of visit for " + parent.getSymbol().getName() + " set to 1");
            }
        } else {
            int localTov = localTovMap.get(parent);
            localTovMap.put(parent, localTov + 1);
            if (Playground.DEBUG) {
                System.out.println("Updated time of visit for " + parent.getSymbol().getName() + " to " + (localTov + 1));
            }
        }
    }

    private void downTimeOfVisit(AugmentedNode parent, ScopeTreeNode arg) {
        if (!timeOfVisitMap.containsKey(parent)) {
            throw new RuntimeException("Time of visit not supposed to downgrade here");
        } else {
            int timeOfVisit = timeOfVisitMap.get(parent);
            timeOfVisitMap.put(parent, timeOfVisit - 1);
        }
        Multigraph graph = arg.getAffliation();
        Map<AugmentedNode, Integer> localTovMap = graph.getTimeOfVisitMap();
        if (!localTovMap.containsKey(parent)) {
            throw new RuntimeException("Time of visit not supposed to downgrade here");
        } else {
            int localTov = localTovMap.get(parent);
            localTovMap.put(parent, localTov - 1);
            if (Playground.DEBUG) {
                System.out.println("Updated time of visit for " + parent.getSymbol().getName() + " to " + (localTov - 1));
            }
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
                        Node fieldExprRaw = binExpr.getChildren().get(1);

                        if (fieldExprRaw instanceof UnaryExpr) {
                            if (((UnaryExpr)fieldExprRaw).getOp() == UnaryExpr.UnaryOp.NOOP) {
                                fieldExprRaw = ((UnaryExpr)fieldExprRaw).getChildren().get(0);
                            }
                        } 
                        if (!(fieldExprRaw instanceof FieldExpr)) {
                            fieldExprRaw = binExpr.getChildren().get(0);
                            if (((UnaryExpr)fieldExprRaw).getOp() == UnaryExpr.UnaryOp.NOOP) {
                                fieldExprRaw = ((UnaryExpr)fieldExprRaw).getChildren().get(0);
                            }
                        }
                        FieldExpr fieldExpr = (FieldExpr) fieldExprRaw;
                        String fieldName = fieldExpr.getName();
                        Symbol fieldSymbol = aame.getSymbol(fieldName);
                        FieldRelation fieldRel = (FieldRelation) fieldSymbol;
                        SetSymbol iterSym = fieldRel;
                        while (iterSym instanceof FieldRelation) {
                            iterSym = ((FieldRelation) iterSym).getTarget();
                        }
                        SigSymbol sigSym = (SigSymbol) iterSym;
                        return Pair.of(sigSym, confiners);
                    } else {
                        // select one branch and find its type
                        return getSigSymbolByExpr(binExpr.getLeft());
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
        assertionRoot.setMaxDownlinks(1);
        Multigraph subgraph = new Multigraph(assertionRoot, globalVariables);
        Symbol assertionSym = new AssertSymbol(name, subgraph);
        arg.addSymbol(assertionSym);
        uniqueNode.put(assertionSym, assertionRoot);
        assertionRoot.setSymbol(assertionSym);
        aame.addSymbol(name, assertionSym);
        scopeNodeId++;
        ScopeTreeNode subscope = new ScopeTreeNode(scopeNodeId, arg, subgraph);
        AugmentedNode body = n.getBody().accept(this, subscope);
        // globalVariables.addEdge(assertionRoot, body, 1);
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
                AugmentedNode node = new AugmentedNode(124, 1, boolSymbol);
                node.setMaxDownlinks(0);
                uniqueNode.put(boolSymbol, node);
                return node;
            } else {
                Symbol boolSymbol = new ConstSymbol("false", true, false);
                AugmentedNode node = new AugmentedNode(124, 0, boolSymbol);
                node.setMaxDownlinks(0);
                uniqueNode.put(boolSymbol, node);
                return node;
            }
        } else {
            if (val.equalsIgnoreCase("iden")) {
                Symbol constSymbol = new ConstSymbol("iden", false, true);
                AugmentedNode node = new AugmentedNode(121, 1, constSymbol);
                node.setMaxDownlinks(0);
                uniqueNode.put(constSymbol, node);
                return node;
            }
            try {
                int semantic = Integer.parseInt(n.getValue());
                Symbol constSymbol = new ConstSymbol(n.getValue(), false, false);
                AugmentedNode node = new AugmentedNode(123, semantic, constSymbol);
                node.setMaxDownlinks(0);
                uniqueNode.put(constSymbol, node);
                return node;
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
        if (var instanceof UnaryExpr) {
            if (((UnaryExpr) var).getOp() == UnaryExpr.UnaryOp.NOOP) {
                var = ((UnaryExpr) var).getSub();
            }
        }
        ExprOrFormula bound = n.getBound();
        Body body = n.getBody();
        arg.addChildren(child);
        if (var instanceof VarExpr) { 
            VarExpr varExpr = (VarExpr) var;
            AugmentedNode letNode = new AugmentedNode(122, uniqueNode.size());
            letNode.setMaxDownlinks(3);
            Symbol varSymbol = new RefSymbol(letNode, varExpr.getName());
            uniqueNode.put(varSymbol, letNode);
            child.addSymbol(varSymbol);
            letNode.setSymbol(varSymbol);
            updateTimeOfVisit(letNode, arg);
            AugmentedNode boundNode = bound.accept(this, arg); 
            // globalVariables.addEdge(letNode, boundNode, 1);
            AugmentedNode bodyNode = body.accept(this, child);
            // globalVariables.addEdge(letNode, bodyNode, 2);
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
        ITEDummy.setMaxDownlinks(3);
        updateTimeOfVisit(ITEDummy, arg);
        ExprOrFormula condition = n.getCondition();
        ExprOrFormula thenClause = n.getThenClause();
        ExprOrFormula elseClause = n.getElseClause();
        AugmentedNode condNode = condition.accept(this, arg);
        if (condNode == ITEDummy) {
            downTimeOfVisit(ITEDummy, arg);
        }
        // globalVariables.addEdge(ITEDummy, condNode, 1);
        AugmentedNode thenNode = thenClause.accept(this, arg);
        if (thenNode == ITEDummy) {
            downTimeOfVisit(ITEDummy, arg);
        }
        // globalVariables.addEdge(ITEDummy, thenNode, 2);
        AugmentedNode elseNode = elseClause.accept(this, arg);
        if (elseNode == ITEDummy) {
            downTimeOfVisit(ITEDummy, arg);
        }
        // globalVariables.addEdge(ITEDummy, elseNode, 3);
        visitAndConnect(ITEDummy, condNode, 1, arg);
        visitAndConnect(ITEDummy, thenNode, 2, arg);
        visitAndConnect(ITEDummy, elseNode, 3, arg);
        if (condNode == ITEDummy) {
            updateTimeOfVisit(ITEDummy, arg);
        }
        if (thenNode == ITEDummy) {
            updateTimeOfVisit(ITEDummy, arg);
        }
        if (elseNode == ITEDummy) {
            updateTimeOfVisit(ITEDummy, arg);
        }
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
        int semantic = -1;
        if (n instanceof QtFormula) {
            QtFormula.Quantifier quantifier = ((QtFormula) n).getOp();
            if (quantifier == QtFormula.Quantifier.ALL) {
                semantic = 1; // universal quantifier
                label += "_ALL1"; 
            } else if (quantifier == QtFormula.Quantifier.SOME) {
                semantic = 2; // existential quantifier
                label += "_SOME2"; 
            } else if (quantifier == QtFormula.Quantifier.NO) {
                semantic = 3; // negation of existential quantifier
                label += "_NO3";  
            } else if (quantifier == QtFormula.Quantifier.LONE) {
                semantic = 4; // lone quantifier
                label += "_LONE4"; 
            } else if (quantifier == QtFormula.Quantifier.ONE) {
                semantic = 5; // one quantifier
                label += "_ONE5"; 
            }
        } else {
            QtExpr.Quantifier quantifier = ((QtExpr) n).getOp();
            if (quantifier == QtExpr.Quantifier.SUM) {
                semantic = 1; // summation
                label += "_SUM1"; 
            } else if (quantifier == QtExpr.Quantifier.COMPREHENSION) {
                semantic = 2; // comprehension
                label += "_COMP2";
            }
        }
        MiddleSymbol qtSymbol = new MiddleSymbol(label);
        qtSymbol.setInfiniteRoot(true); // infinite root for quantifier
        List<VarDecl> varDecls = n.getVarDecls();
        scopeNodeId++;
        ScopeTreeNode subscope = new ScopeTreeNode(scopeNodeId, arg);
        Body body = n.getBody();
        Multigraph graph = arg.getAffliation();
        AugmentedNode qtRoot;
        if (uniqueNode.containsKey(qtSymbol)) {
            qtRoot = uniqueNode.get(qtSymbol);
        } else {
            qtRoot = new AugmentedNode(syntactic, semantic, qtSymbol);
            uniqueNode.put(qtSymbol, qtRoot);
        }
        graph.addVertex(qtRoot);
        updateTimeOfVisit(qtRoot, arg);
        int iter = 2;
        for (VarDecl var : varDecls) {
            AugmentedNode varDeclNode = var.accept(this, subscope);
            // globalVariables.addEdge(qtRoot, varDeclNode, 2);
            visitAndConnect(qtRoot, varDeclNode, iter, subscope);
            if (Playground.DEBUG) System.out.println("VarDecl at " + iter + ": " + var);
            iter++;
        }
        visitAndConnect(qtRoot, END_NODE, iter, subscope);
        AugmentedNode bodyNode = body.accept(this, subscope);
        // globalVariables.addEdge(qtRoot, bodyNode, 1);
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
        updateTimeOfVisit(callNode, arg);
        Symbol predOrFunSymbol = aame.getSymbol(n.getName());
        AugmentedNode calledNode = uniqueNode.get(predOrFunSymbol);
        // globalVariables.addEdge(callNode, calledNode, 1);
        // connect the callNode to the calledNode at position 1
        visitAndConnect(callNode, calledNode, 1, arg);
        int iter = 2;
        for (ExprOrFormula param : n.getArguments()) {
            AugmentedNode paramAug = param.accept(this, arg);
            // globalVariables.addEdge(callNode, calledNode, 2);
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
        updateTimeOfVisit(callNode, arg);
        Symbol predOrFunSymbol = aame.getSymbol(n.getName());
        AugmentedNode calledNode = uniqueNode.get(predOrFunSymbol);
        if (calledNode == null) {
            // the node is a built-in function
            calledNode = new AugmentedNode(7, 1, new RefSymbol(null, n.getName()));
            uniqueNode.put(calledNode.getSymbol(), calledNode);
        }
        // globalVariables.addEdge(callNode, calledNode, 1);
        visitAndConnect(callNode, calledNode, 1, arg);
        int iter = 2;
        for (ExprOrFormula param : n.getArguments()) {
            AugmentedNode paramAug = param.accept(this, arg);
            // globalVariables.addEdge(callNode, calledNode, 2);
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
        opSymbol.setInfiniteRoot(true); // infinite root for list formula
        AugmentedNode opNode;
        if (uniqueNode.containsKey(opSymbol)) {
            opNode = uniqueNode.get(opSymbol);
        } else {
            opNode = new AugmentedNode(-4, semantics, opSymbol);
            uniqueNode.put(opSymbol, opNode);
        }
        arg.getAffliation().addVertex(opNode);
        updateTimeOfVisit(opNode, arg);
        int iter = 1;
        for (ExprOrFormula child : n.getArguments()) {
            AugmentedNode argChildNode = child.accept(this, arg);
            // globalVariables.addEdge(opNode, argChildNode, iter);
            visitAndConnect(opNode, argChildNode, iter, arg);
            iter++;
        }
        // globalVariables.addEdge(opNode, END_NODE, iter);
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
        opSymbol.setInfiniteRoot(true); // infinite root for list expression
        AugmentedNode opNode;
        if (uniqueNode.containsKey(opSymbol)) {
            opNode = uniqueNode.get(opSymbol);
        } else {
            opNode = new AugmentedNode(4, semantics, opSymbol);
            uniqueNode.put(opSymbol, opNode);
        }
        updateTimeOfVisit(opNode, arg);
        int iter = 1;
        for (ExprOrFormula child : n.getArguments()) {
            AugmentedNode argChildNode = child.accept(this, arg);
            // globalVariables.addEdge(opNode, argChildNode, iter);
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
        bopNode.setMaxDownlinks(2);
        arg.getAffliation().addVertex(bopNode);
        updateTimeOfVisit(bopNode, arg);
        ExprOrFormula left = n.getLeft();
        ExprOrFormula right = n.getRight();
        AugmentedNode leftNode = left.accept(this, arg);
        if (leftNode == bopNode) {
            // shadow node created, need to down the time of visit tracker
            downTimeOfVisit(bopNode, arg);
        }
        // globalVariables.addEdge(bopNode, leftNode, 1);
        AugmentedNode rightNode = right.accept(this, arg);
        if (rightNode == bopNode) {
            // shadow node created, need to down the time of visit tracker
            downTimeOfVisit(bopNode, arg);
        }
        // globalVariables.addEdge(bopNode, rightNode, 2);
        visitAndConnect(bopNode, leftNode, 1, arg);
        visitAndConnect(bopNode, rightNode, 2, arg);
        // update the shadow node time of visit back
        if (leftNode == bopNode) {
            updateTimeOfVisit(bopNode, arg);
        }
        if (rightNode == bopNode) {
            updateTimeOfVisit(bopNode, arg);
        }
        // System.out.println("BOP: " + bopNode.getSymbol().getName() + " at " + timeOfVisitMap.get(bopNode));
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
            case RANGE:
                symbolLabel = "BOPEXPR_RANGE";
                semantic = 20;
                break;
            case INTERSECT:
                symbolLabel = "BOPEXPR_INTERSECT";
                semantic = 21;
                break;
            case PLUSPLUS:
                symbolLabel = "BOPEXPR_PLUSPLUS";
                semantic = 22;
                break;
            case PLUS:
                symbolLabel = "BOPEXPR_PLUS";
                semantic = 23;
                break;
            case IPLUS:
                symbolLabel = "BOPEXPR_IPLUS";
                semantic = 24;
                break;
            case MINUS:
                symbolLabel = "BOPEXPR_MINUS";
                semantic = 25;
                break;
            case IMINUS:
                symbolLabel = "BOPEXPR_IMINUS";
                semantic = 26;
                break;
            case MUL:
                symbolLabel = "BOPEXPR_MUL";
                semantic = 27;
                break;
            case DIV:
                symbolLabel = "BOPEXPR_DIV";
                semantic = 28;
                break;
            case REM:
                symbolLabel = "BOPEXPR_REM";
                semantic = 29;
                break;
            case SHL:
                symbolLabel = "BOPEXPR_SHL";
                semantic = 30;
                break;
            case SHA:
                symbolLabel = "BOPEXPR_SHA";
                semantic = 31;
                break;
            case SHR:
                symbolLabel = "BOPEXPR_SHR";
                semantic = 32;
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
        bopNode.setMaxDownlinks(2);
        arg.getAffliation().addVertex(bopNode);
        updateTimeOfVisit(bopNode, arg);
        ExprOrFormula left = n.getLeft();
        ExprOrFormula right = n.getRight();
        AugmentedNode leftNode = left.accept(this, arg);
        if (leftNode == bopNode) {
            // shadow node created, need to down the time of visit tracker
            downTimeOfVisit(bopNode, arg);
        }
        // globalVariables.addEdge(bopNode, leftNode, 1);
        visitAndConnect(bopNode, leftNode, 1, arg);
        AugmentedNode rightNode = right.accept(this, arg);
        if (rightNode == bopNode) {
            // shadow node created, need to down the time of visit tracker
            downTimeOfVisit(bopNode, arg);
        }
        // globalVariables.addEdge(bopNode, rightNode, 2);
        visitAndConnect(bopNode, rightNode, 2, arg);
        // update the shadow node time of visit back
        // TODO: ALSO APPLY TO OTHER SHADOWY NODES
        if (leftNode == bopNode) {
            updateTimeOfVisit(bopNode, arg);
        }
        if (rightNode == bopNode) {
            updateTimeOfVisit(bopNode, arg);
        }
        // System.out.println("BOPex: " + bopNode.getSymbol().getName() + " at " + timeOfVisitMap.get(bopNode));

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
        unopNode.setMaxDownlinks(1);
        arg.getAffliation().addVertex(unopNode);
        updateTimeOfVisit(unopNode, arg);
        ExprOrFormula sub = n.getSub();
        AugmentedNode subNode = sub.accept(this, arg);
        if (subNode == unopNode) {
            // shadow node created, need to down the time of visit tracker
            downTimeOfVisit(unopNode, arg);
        }
        // globalVariables.addEdge(unopNode, subNode, 1);
        visitAndConnect(unopNode, subNode, 1, arg);
        // update the shadow node time of visit back
        if (subNode == unopNode) {
            updateTimeOfVisit(unopNode, arg);
        }
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
            if (Playground.DEBUG) System.out.println("Creating new unary node: " + unopSymbol);
            uniqueNode.put(unopSymbol, unopNode);
        }
        unopNode.setMaxDownlinks(1);
        arg.getAffliation().addVertex(unopNode);
        updateTimeOfVisit(unopNode, arg);
        ExprOrFormula sub = n.getSub();
        AugmentedNode subNode = sub.accept(this, arg);
        if (subNode == unopNode) {
            // shadow node created, need to down the time of visit tracker
            downTimeOfVisit(unopNode, arg);
        }
        // globalVariables.addEdge(unopNode, subNode, 1);
        visitAndConnect(unopNode, subNode, 1, arg);
        // update the shadow node time of visit back
        if (subNode == unopNode) {
            updateTimeOfVisit(unopNode, arg);
        }
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
        Pair<SigSymbol, Set<FieldConfiner>> targetPair = getSigSymbolByExpr(fieldRelType);
        SigSymbol targetSymbol = targetPair.a;
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
    private SigSymbol typeCheckExpr(ExprOrFormula e) {
        // use this function to check the overall set / type of the expression
        // System.out.println(e);
        if (e instanceof SigExpr) {
            SigExpr sigExpr = (SigExpr) e;
            String sigName = sigExpr.getName();
            Symbol sigSymbol = aame.getSymbol(sigName);
            return (SigSymbol) sigSymbol;
        }
        if (e instanceof FieldExpr) {
            FieldExpr fieldExpr = (FieldExpr) e;
            String fieldName = fieldExpr.getName();
            Symbol fieldSymbol = aame.getSymbol(fieldName);
            if (fieldSymbol instanceof FieldRelation) {
                FieldRelation fieldRel = (FieldRelation) fieldSymbol;
                SetSymbol iterSym = fieldRel;
                while (iterSym instanceof FieldRelation) {
                    iterSym = ((FieldRelation) iterSym).getTarget();
                }
                return (SigSymbol) iterSym;
            } else {
                throw new RuntimeException("Field " + fieldName + " is not a field relation");
            }
        }
        if (e instanceof UnaryExpr) {
            UnaryExpr unaryExpr = (UnaryExpr) e;
            ExprOrFormula sub = unaryExpr.getSub();
            return typeCheckExpr(sub);
        }
        if (e instanceof BinaryExpr) {
            BinaryExpr binaryExpr = (BinaryExpr) e;
            if (binaryExpr.getOp() == BinaryOp.JOIN) {
                // see if its left or right is a field. Fields first. 
                ExprOrFormula left = binaryExpr.getLeft();
                ExprOrFormula right = binaryExpr.getRight();
                if (isSigOrField(right)) {
                    return typeCheckExpr(right);
                } else {
                    return typeCheckExpr(left);
                }
            } else {
                // select one branch and find its type
                return typeCheckExpr(binaryExpr.getLeft());
            }
        }
        if (e instanceof ITEExpr) {
            // use its THEN branch\
            return typeCheckExpr(((ITEExpr) e).getThenClause());
        }
        if (e instanceof VarExpr) {
            VarExpr varExpr = (VarExpr) e;
            String varName = varExpr.getName();
            System.out.println("Unknown expression type: " + e.getClass() + " " + varName);
        }
        return null;
    }
    private boolean isSigOrField(ExprOrFormula e) {
        if (e instanceof SigExpr) {
            return true;
        }
        if (e instanceof FieldExpr) {
            return true;
        }
        if (e instanceof UnaryExpr) {
            UnaryExpr unaryExpr = (UnaryExpr) e;
            ExprOrFormula sub = unaryExpr.getSub();
            return isSigOrField(sub);
        }
        if (e instanceof BinaryExpr) {
            BinaryExpr binaryExpr = (BinaryExpr) e;
            if (binaryExpr.getOp() == BinaryOp.JOIN) {
                // see if its left or right is a field. Fields first. 
                ExprOrFormula left = binaryExpr.getLeft();
                ExprOrFormula right = binaryExpr.getRight();
                return isSigOrField(right) || isSigOrField(left);
            } else {
                // select one branch and find its type
                return isSigOrField(binaryExpr.getLeft());
            }
        }
        return false;
    }
}