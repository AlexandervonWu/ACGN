package is.fivefivefive.ACGN.learn;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Random;
import java.util.Set;
import java.util.Vector;

import is.fivefivefive.ACGN.alloy.DeclRootSymbol;
import is.fivefivefive.ACGN.alloy.DummySymbol;
import is.fivefivefive.ACGN.alloy.EndSymbol;
import is.fivefivefive.ACGN.alloy.MiddleSymbol;
import is.fivefivefive.ACGN.alloy.PredRootSymbol;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.alloy.VarSymbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.codegen.Generator;
import is.fivefivefive.ACGN.etc.BiMap;
import is.fivefivefive.ACGN.structure.RLScopeTreeNode;
import is.fivefivefive.ACGN.structure.ScopeTreeNode;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.util.Probability;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.alloyasg.vector.Vector1D;
import parser.etc.Pair;

public class CodeGenAgent {
    private GlobalVariables gv;
    private MASGVisitor visitor; // the visitor for the specific Alloy Model
    static final int MAX_STEPS = 500;
    private Multigraph groundTruth;
    private Multigraph currentAns;
    private Map<Pair<Symbol, Integer>, Map<Symbol, Float>> globalQTable;
    private BiMap<Integer, Symbol> symbolId;
    private Map<Pair<Symbol, Integer>, Float> edgeRewardMap; // reward for each edge
    private int globalNewVarCounter = 100;
    private int rlScopeTreeNodeId = 100;
    private int stepNum = 0;
    private BiMap<Symbol, AugmentedNode> dynamicUniqueNodes;
    private Map<Symbol, Set<Symbol>> coarseToFineBin; // local rather than global. 
    private List<String> actionSequence; // log the action sequence, then apply reinforcement learning by Q-learning.
    private Map<Symbol, Integer> tovMap; // track the times of visit. 
    private int treeId;
    private RLScopeTreeNode rootScope;
    private int initializationState = 0;

    public CodeGenAgent(Multigraph groundTruth, MASGVisitor visitor, GlobalVariables gv, BiMap<Integer, Symbol> symbolId) {
        this.groundTruth = groundTruth;
        this.currentAns = new Multigraph();
        this.visitor = visitor;
        this.gv = gv;
        this.symbolId = symbolId;
        this.dynamicUniqueNodes = new BiMap<Symbol, AugmentedNode>();
        for (Symbol sym : gv.getUniqueNodes().keys()) {
            this.dynamicUniqueNodes.put(sym, gv.getUniqueNodes().get(sym));
        }
        this.coarseToFineBin = new HashMap<Symbol, Set<Symbol>>();
        for (Symbol dummy : DummySymbol.ALL_DUMMIES) {
            this.coarseToFineBin.put(dummy, new LinkedHashSet<Symbol>());
            this.coarseToFineBin.get(dummy).addAll(gv.getCoarseToFineBin().get(dummy));
        }
        this.actionSequence = new ArrayList<>();
        this.tovMap = new HashMap<>();
        this.treeId = visitor.getForest().size();
        this.rootScope = new RLScopeTreeNode(rlScopeTreeNodeId, visitor.getRootScope(), currentAns);
        // initialize the Q-table for the root scope
        this.globalQTable = initialCoarseQTable();
        initializationState = 0;
    }
    public int getInitializationState() {
        return initializationState;
    }

    public Map<Pair<Symbol, Integer>, Map<Symbol, Float>> initialCoarseQTable() {
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qTable = new HashMap<>();
        Map<Pair<Symbol, Integer>, Set<Symbol>> edgeMap = gv.getEdgeMap();
        for (Pair<Symbol, Integer> positional : edgeMap.keySet()) {
            Symbol source = positional.a;
            int position = positional.b;
            Map<Symbol, Float> coarseProbabilities = Probability.coarseTokenProbabilities(gv, source, position);
            // Map<Symbol, Float> fineProbabilities = coarseToFineInit(coarseProbabilities);
            qTable.put(positional, coarseProbabilities);
        }
        return qTable;
    }
    public void initialize() {
        // TODO: Initialize the agent with coarse-grained token candidates and the unique nodes presenting in the model. 
        // to begin with, find all signatures, fields, reference points; 
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> initialQTable = initialCoarseQTable();
        for (Pair<Symbol, Integer> key : initialQTable.keySet()) {
            Map<Symbol, Float> coarseProbabilities = initialQTable.get(key);
            Map<Symbol, Float> fineProbabilities = coarseToFineInit(coarseProbabilities);
            this.rootScope.getqDist().put(key, fineProbabilities); // initial partially fine Q-table, waiting for the local variable declarations. 
        }
        stepNum = 0;
        this.tovMap = new HashMap<>();
        rootScope.setqDist(initialQTable);
        globalQTable = initialQTable;
        if (initializationState == 0) {
            initializationState = 1;
        } else {
            initializationState = 2; // reinitialized flag
        }
    } 
    private Map<Symbol, Float> coarseToFineInit(Map<Symbol, Float> coarseProbabilities) {
        Map<Symbol, Float> fineProbabilities = new HashMap<>();
        for (Map.Entry<Symbol, Float> entry : coarseProbabilities.entrySet()) {
            Symbol coarseToken = entry.getKey();
            Float coarseProb = entry.getValue();
            if (!(coarseToken instanceof DummySymbol) || (coarseToken == DummySymbol.DUMMY_LOCAL_VAR)) fineProbabilities.put(coarseToken, coarseProb);
            else {
                // expand the dummy token to fine tokens
                coarseToFineBin.get(coarseToken).forEach(fineToken -> {
                    float fineProb = coarseProb / coarseToFineBin.get(coarseToken).size();
                    fineProbabilities.put(fineToken, fineProb);
                });
            }
        }
        return fineProbabilities;
    }
    
    public String generateNextPred(String predName) {
        currentAns = new Multigraph();
        rootScope = new RLScopeTreeNode(treeId, visitor.getRootScope(), currentAns);
        Map<Symbol, Integer> tovTracker = new HashMap<>();
        AugmentedNode rootNode = new AugmentedNode(-1, treeId);
        Symbol root = new PredRootSymbol(rootNode, predName);
        dynamicUniqueNodes.put(root, rootNode);
        rootNode.setSymbol(root);
        Multigraph predGraph = new Multigraph(rootNode, gv);
        generateNextNode(rootNode, 1, tovTracker, rootScope);
        Generator generator = new Generator();
        String code = null;
        try {
            code = generator.toCode(predGraph, predGraph.getRoot(), 1);
        } catch (Exception e) {
            System.out.println("Error during code generation: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
        return code;
    }

    public int generateNextNode(AugmentedNode localParent, int position, Map<Symbol, Integer> tovTracker, RLScopeTreeNode scope) {
        if (stepNum > MAX_STEPS) {
            throw new RuntimeException("Exceeded maximum steps in generation. Current node: " + localParent.getSymbol().getName() + ", position: " + position);
        }
        stepNum++;
        Symbol source = localParent.getSymbol();
        if (source instanceof MiddleSymbol && ((MiddleSymbol) source).isQt()) {
            AugmentedNode qtNode = fillHoleQt(source, scope);
            localParent.connect(qtNode, position, currentAns, tovTracker.getOrDefault(source, 0));
            // TODO: recursively generate downstream
            return 0; // success
        }
        Symbol nextToken = fillHole(source, position, scope);
        AugmentedNode nextNode = dynamicUniqueNodes.get(nextToken);
        currentAns.connect(localParent, nextNode, currentAns, position, tovTracker.getOrDefault(source, 0));
        if (nextToken instanceof EndSymbol) {
            return -1; // end symbol reached
        }
        if (nextToken.getMaxDownlinks() != 0) {
            tovTracker.putIfAbsent(nextToken, 0);
            tovTracker.put(nextToken, tovTracker.get(nextToken) + 1);
            int childPosition = 1;
            while (childPosition <= nextToken.getMaxDownlinks() || nextToken.getMaxDownlinks() == -1) {
                int result = generateNextNode(nextNode, childPosition, tovTracker, scope);
                if (result == -1) break; // end symbol reached
                childPosition++;
            }// TODO: recursively generate downstream
        }
        return 0; // success
    }
    public Symbol fillHole(Symbol source, int position, RLScopeTreeNode currentScope) {
        // TODO: 1. use a randomizer and the Q-table to select the next token;
        // 2. log the action into the sequence; 
        // 3. return the selected token;
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qTable = currentScope.getqDist();
        Random rand = new Random();
        float randomValue = rand.nextFloat();
        float cumulativeProbability = 0.0f;
        Symbol nextToken = null;
        for (Map.Entry<Symbol, Float> entry : qTable.get(Pair.of(source, position)).entrySet()) {
            Symbol token = entry.getKey();
            Float prob = entry.getValue();
            cumulativeProbability += prob;
            if (cumulativeProbability > randomValue) {
                nextToken = token;
                break;
            }
        }
        if (nextToken instanceof DummySymbol) {
            // if the selected token is dummy, we need to revert and generate again
            System.out.println("Selected token is a dummy symbol: " + nextToken.getName() + ". Reverting and selecting again.");
            return fillHole(source, position, currentScope);
        }
        if (nextToken == null) {
            System.out.println("Incomplete Q-table set for " + source.getName() + " at position " + position);
            throw new RuntimeException("No next token selected for " + source.getName() + " at position " + position);
        }
        actionSequence.add(source.getName() + ", " + position + " -> " + nextToken.getName());
        return nextToken;
    }

    private AugmentedNode fillHoleQt(Symbol qtRoot, RLScopeTreeNode currentScope) {
        stepNum++;
        String label = qtRoot.getName();
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qTable = currentScope.getqDist();
        char label3 = label.charAt(3);
        int syntactic = label3 == 'E' ? 3 : -3;
        char labelLast = label.charAt(label.length() - 1);
        int semantic = labelLast - '0';
        AugmentedNode qtNode = new AugmentedNode(syntactic, semantic, qtRoot); 
        rlScopeTreeNodeId++;
        RLScopeTreeNode qtScope = new RLScopeTreeNode(rlScopeTreeNodeId, currentScope, currentAns);
        // TODO: update the qtable of the new scope;
        Symbol qt1 = fillHole(qtRoot, 1, qtScope);
        AugmentedNode qt1Node = dynamicUniqueNodes.get(qt1);
        tovMap.putIfAbsent(qtRoot, 0);
        tovMap.put(qtRoot, tovMap.get(qtRoot) + 1);
        currentAns.connect(qtNode, qt1Node, currentAns, 1, tovMap.get(qtRoot));
        actionSequence.add(qtRoot.getName() + ", body (1)  -> " + qt1.getName());
        int i = 2; 
        Random random = new Random();
        while (true) {
            // find if end; if not end -> add a reldecl;
            if (!qTable.containsKey(Pair.of(qtRoot, i))) break; 
            float nextRandom = random.nextFloat();
            float endProb = qTable.get(Pair.of(qtRoot, i)).containsKey(MASGVisitor.END_SYMBOL) ? 
                qTable.get(Pair.of(qtRoot, i)).get(MASGVisitor.END_SYMBOL) :
                0;
            if (nextRandom < endProb) {
                Symbol endSymbol = MASGVisitor.END_SYMBOL;
                AugmentedNode endNode = dynamicUniqueNodes.get(endSymbol);
                currentAns.connect(qtNode, endNode, currentAns, i, tovMap.get(qtRoot));
                actionSequence.add(qtRoot.getName() + ", " + i + ", <END>");
                break;
            } else {
                Map<Symbol, Float> sigProbabilities = Probability.coarseTokenProbabilities(gv, qtRoot, i);
                nextRandom -= endProb;
                float cumulativeProbability = 0.0f;
                for (Map.Entry<Symbol, Float> entry : sigProbabilities.entrySet()) {
                    Symbol sig = entry.getKey();
                    if (sig instanceof EndSymbol) continue;
                    float sigProb = entry.getValue();
                    cumulativeProbability += sigProb;
                    if (cumulativeProbability > nextRandom) {
                        Symbol relDeclRoot = sig;
                        AugmentedNode anDown = fillHoleRelDecl(relDeclRoot, qtNode, qtScope);
                        currentAns.connect(qtNode, anDown, currentAns, i, tovMap.get(qtRoot));
                        actionSequence.add(qtRoot.getName() + ", " + i + ", RELDECL ");
                        break;
                    }
                }
            }
        }
        qtScope.localizeQDist(globalQTable);
        if (qt1.getMaxDownlinks() != 0) {
            int childPosition = 1;
            while (childPosition <= qt1.getMaxDownlinks() || qt1.getMaxDownlinks() == -1) {
                int result = generateNextNode(qt1Node, childPosition, tovMap, qtScope);
                if (result == -1) break; // end symbol reached
                childPosition++;
            }
        }
        return qtNode;
    }

    private AugmentedNode fillHoleRelDecl(Symbol relDeclRoot, AugmentedNode qtNode, RLScopeTreeNode currentScope) {
        if (!dynamicUniqueNodes.containsKey(relDeclRoot)) {
            dynamicUniqueNodes.put(relDeclRoot, new AugmentedNode(-127, 0, relDeclRoot));
        }
        AugmentedNode relDeclNode = dynamicUniqueNodes.get(relDeclRoot);
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qTable = currentScope.getqDist();
        Random random = new Random();
        // TODO: generate type first PROBLEM: HERE BEGINS WITH CONFINERS NOT NODES
        // DEFINED SIGNATURE TYPE, TRY FILLHOLE HERE
        Symbol sig = fillHole(relDeclRoot, 1, currentScope);
        AugmentedNode sigNode = dynamicUniqueNodes.get(sig);
        tovMap.putIfAbsent(relDeclRoot, 0);
        tovMap.put(relDeclRoot, tovMap.get(relDeclRoot) + 1);
        currentAns.connect(relDeclNode, sigNode, currentAns, 1, tovMap.get(relDeclRoot));
        String sigName = sig.getName();
        actionSequence.add(relDeclRoot.getName() + ", 1 " + sigName);        
        int i = 2; 
        while (true) {
            if (!qTable.containsKey(Pair.of(relDeclNode, i))) break;
            float nextRandom = random.nextFloat();
            float endProb = qTable.get(Pair.of(relDeclRoot, i)).containsKey(MASGVisitor.END_SYMBOL) ? 
                qTable.get(Pair.of(relDeclRoot, i)).get(MASGVisitor.END_SYMBOL) : 
                0;
            if (nextRandom < endProb) {
                Symbol endSymbol = MASGVisitor.END_SYMBOL;
                AugmentedNode endNode = dynamicUniqueNodes.get(endSymbol);
                currentAns.connect(relDeclNode, endNode, currentAns, i, tovMap.get(relDeclRoot));
                actionSequence.add(relDeclRoot.getName() + ", " + i + " <END> ");
                break;
            }
            addVariableDecl(sigName, treeId, qtNode, currentScope);
            actionSequence.add(relDeclRoot.getName() + ", " + i + " ADD_VAR " + globalNewVarCounter + " TYPE " + sigName);
        }
        return relDeclNode;
    }

    /**
     * An action defined to add a variable declaration in the scope. 
     * @param sigName The signature name that the variable belongs to.
     * @param treeId The tree ID representing the scope level (0 for global).
     * @param confinerNode The AugmentedNode that confines the variable.
     * @param currentScope The current RLScopeTreeNode representing the scope in which the variable is declared.
     */
    public void addVariableDecl(String sigName, int treeId, AugmentedNode confinerNode, RLScopeTreeNode currentScope) {
        // add a new variable into the scope of coarse to fine bin;
        globalNewVarCounter++;
        Symbol newVar = new VarSymbol(sigName, "local_var_" + globalNewVarCounter, treeId, confinerNode);
        this.symbolId.put(this.symbolId.size(), newVar);
        // update the coarse to fine bin
        coarseToFineBin.get(DummySymbol.DUMMY_LOCAL_VAR).add(newVar);
        // update the dynamic unique nodes
        AugmentedNode newNode = new AugmentedNode(127, globalNewVarCounter); // var nodes have signature 127
        currentScope.addSymbol(newVar);
        this.dynamicUniqueNodes.put(newVar, newNode);
    }

    private static final double INERTIA = Hyperparams.INERTIA;
    public void updateQTable(Symbol source, int position, Symbol selection, float reward, RLScopeTreeNode currentScope) throws IllegalArgumentException {
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qTable = currentScope.getqDist();
        Map<Symbol, Float> actionProbabilities = qTable.get(Pair.of(source, position));
        if (actionProbabilities == null || !actionProbabilities.containsKey(selection)) {
            throw new IllegalArgumentException("No action probabilities found for source: " + source.getName() + " at position: " + position);
        }
        // Q-learning update
        Map<Symbol, Float> updatedActionProbabilities = new HashMap<>();
        for (Map.Entry<Symbol, Float> entry : actionProbabilities.entrySet()) {
            Symbol action = entry.getKey();
            float oldProb = entry.getValue();
            float newProb;
            if (action.equals(selection)) {
                newProb = (float) (Math.log(oldProb) * INERTIA
                + (reward > 0 ? Math.log(reward) * (1 - INERTIA) : 0));
            } else {
                newProb = (float) (Math.log(oldProb) * INERTIA);
            }
            updatedActionProbabilities.put(action, newProb);
        }
        // softmax normalization
        float sum = 0.0f;
        for (Map.Entry<Symbol, Float> e : actionProbabilities.entrySet()) {
            sum += Math.exp(e.getValue());
        }
        for (Map.Entry<Symbol, Float> e : actionProbabilities.entrySet()) {
            Symbol action = e.getKey();
            float newProb = (float) Math.exp(updatedActionProbabilities.get(action)) / sum;
            updatedActionProbabilities.put(action, newProb);
        }
        qTable.put(Pair.of(source, position), updatedActionProbabilities);
        currentScope.setqDist(qTable);
    }

    public float localReward(Symbol source, int position, Symbol selection, float rawReward, RLScopeTreeNode currentScope) {
        if (selection.getMaxDownlinks() == 0) {
            return rawReward;
        }
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qTable = currentScope.getqDist();
        AugmentedNode selectionNode = dynamicUniqueNodes.get(selection);
        float localReward = 0.0f;
        List<MASGEdge> downlinks = currentAns.edgesUnder(selectionNode);
        for (MASGEdge edge : downlinks) {
            AugmentedNode targetNode = edge.getTarget();
            Symbol targetSymbol = targetNode.getSymbol();
            // TODO: reverse TOV lookup here. 
        }
        return localReward;
    }
    
    /*
     * // TODOS: 
     * 1. Coarse token to fine token expansion; not in initialization because new fine tokens as the newly declared variables; 
     * Fields and signatures could be initialized by the general coarse token metric. 
     * 2. RL Agent PER MODEL: - rewrite the dynamic unique nodes each iteration; 
     * REDESIGN some Q-learning to include some multivariance? Increase the uplooking depth? 
     * Use a map: [nextToken : probability] at each (currentToken, position) pair. 
     */

    // TODOS: Make two types of Q-learner: - keep the scopetree; - reset it totally. 
}
