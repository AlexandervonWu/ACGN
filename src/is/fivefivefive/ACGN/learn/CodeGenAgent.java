package is.fivefivefive.ACGN.learn;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
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
import is.fivefivefive.ACGN.alloy.FieldRelation;
import is.fivefivefive.ACGN.alloy.MiddleSymbol;
import is.fivefivefive.ACGN.alloy.PredRootSymbol;
import is.fivefivefive.ACGN.alloy.SetSymbol;
import is.fivefivefive.ACGN.alloy.SigSymbol;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.alloy.VarSymbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.codegen.Generator;
import is.fivefivefive.ACGN.etc.BiMap;
import is.fivefivefive.ACGN.etc.Triple;
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
    // private BiMap<Integer, Symbol> symbolId;
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
    private Map<Pair<Symbol, Integer>, Map<Symbol, Float>> localVarDist;
    private Map<Triple<Symbol, Integer, Symbol>, Integer> localVarCounter; // track the polling scaling
    private Set<Symbol> leaves; // track the leaf nodes for local reward calculation.
    private Map<Symbol, RLScopeTreeNode> symbolScopeMap; // track the scopes that a symbol appears in, for scope collapsing and reward backpropagation.
    private Set<RLScopeTreeNode> visitedScopes; // a temporary set to track the synchronization of the scope tree over updating of the Q-table
    // TODO: fill the scope map so RL backpropagation works. 

    public CodeGenAgent(Multigraph groundTruth, MASGVisitor visitor, GlobalVariables gv) {
        this.groundTruth = groundTruth;
        this.currentAns = new Multigraph();
        this.visitor = visitor;
        this.gv = gv;
        // this.symbolId = symbolId;
        this.dynamicUniqueNodes = new BiMap<Symbol, AugmentedNode>();
        for (Symbol sym : gv.getUniqueNodes().keys()) {
            this.dynamicUniqueNodes.put(sym, gv.getUniqueNodes().get(sym));
        }
        this.coarseToFineBin = new HashMap<Symbol, Set<Symbol>>();
        for (Symbol dummy : DummySymbol.ALL_DUMMIES) {
            this.coarseToFineBin.put(dummy, new LinkedHashSet<Symbol>());
            this.coarseToFineBin.get(dummy).addAll(visitor.getFineSymbolsForCoarseSymbol(dummy));
        }
        this.actionSequence = new ArrayList<>();
        this.tovMap = new HashMap<>();
        this.treeId = visitor.getForest().size();
        this.rootScope = new RLScopeTreeNode(rlScopeTreeNodeId, null, currentAns);
        rootScope.addSymbol(DummySymbol.DUMMY_LOCAL_VAR); // the dummy for local vars to be preserved in the root scope
        // initialize the Q-table for the root scope
        this.globalQTable = initialCoarseQTable();
        initializationState = 0;
        this.localVarDist = new HashMap<>();
        this.localVarCounter = new HashMap<>();
        this.edgeRewardMap = new HashMap<>();
        this.leaves = new LinkedHashSet<>();
        this.symbolScopeMap = new HashMap<>();
        for (Symbol sym : gv.getUniqueNodes().keys()) {
            this.symbolScopeMap.put(sym, rootScope);
        }
    }
    public int getInitializationState() {
        return initializationState;
    }

    public Map<Pair<Symbol, Integer>, Map<Symbol, Float>> initialCoarseQTable() {
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qTable = new HashMap<>();
        Map<Pair<Symbol, Integer>, Set<Symbol>> edgeMap = gv.getCoarseGrainCandidateMap();
        for (Pair<Symbol, Integer> positional : edgeMap.keySet()) {
            Symbol source = positional.a;
            int position = positional.b;
            Map<Symbol, Float> coarseProbabilities = Probability.coarseTokenProbabilities(gv, dynamicUniqueNodes, source, position);
            // Map<Symbol, Float> fineProbabilities = coarseToFineInit(coarseProbabilities);
            qTable.put(positional, coarseProbabilities);
        }
        return qTable;
    }
    public void initialize() {
        // TODO: Initialize the agent with coarse-grained token candidates and the unique nodes presenting in the model. 
        // to begin with, find all signatures, fields, reference points; 
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> initialQTable = initialCoarseQTable();
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> fineQTable = new HashMap<>();
        // System.err.println("Initial Q-table for predroot at 1: " + initialQTable.get(Pair.of(DummySymbol.DUMMY_PREDROOT, 1)));
        for (Pair<Symbol, Integer> key : initialQTable.keySet()) {
            Map<Symbol, Float> coarseProbabilities = initialQTable.get(key);
            System.err.println("Coarse probabilities for " + key.a.getName() + " at position " + key.b + ": " + coarseProbabilities);
            Map<Symbol, Float> fineProbabilities = coarseToFineInit(coarseProbabilities);
            System.err.println("Fine probabilities for " + key.a.getName() + " at position " + key.b + ": " + fineProbabilities);
            fineQTable.put(key, fineProbabilities);
        }
        this.rootScope.setqDist(fineQTable); // set the Q-table of the root scope to the fine-grained initialized Q-table
        stepNum = 0;
        this.tovMap = new HashMap<>();
        initialQTable = fineQTable;
        globalQTable = initialQTable; // set the global Q-table to the fine-grained initialized Q-table
        if (initializationState == 0) {
            initializationState = 1;
        } else {
            initializationState = 2; // reinitialized flag
        }
    } 
    private Map<Symbol, Float> coarseToFineInit(Map<Symbol, Float> coarseProbabilities) {
        Map<Symbol, Float> fineProbabilities = new HashMap<>();
        float totalRemovedCoarseProb = 0.0f; 
        for (Map.Entry<Symbol, Float> entry : coarseProbabilities.entrySet()) {
            Symbol coarseToken = entry.getKey();
            Float coarseProb = entry.getValue();
            if ((! (coarseToken instanceof DummySymbol)) || (coarseToken.equals(DummySymbol.DUMMY_LOCAL_VAR))) fineProbabilities.put(coarseToken, coarseProb);
            else if (coarseToFineBin.get(coarseToken) != null && !coarseToFineBin.get(coarseToken).isEmpty()) {
                // expand the dummy token to fine tokens
                coarseToFineBin.get(coarseToken).forEach(fineToken -> {
                    float fineProb = coarseProb / coarseToFineBin.get(coarseToken).size();
                    fineProbabilities.put(fineToken, fineProb);
                });
                fineProbabilities.remove(coarseToken); // remove the dummy token itself from the fine probabilities
                System.err.println("Expanded " + coarseToken.getName() + " at position to fine tokens: " + coarseToFineBin.get(coarseToken) + " with probability " + coarseProb);
            } else {
                // scale other tokens up
                fineProbabilities.remove(coarseToken);
                totalRemovedCoarseProb += coarseProb;
            }
        }
        // rescale
        if (totalRemovedCoarseProb > 0) {
            float scaleFactor = 1.0f / (1.0f - totalRemovedCoarseProb);
            for (Map.Entry<Symbol, Float> e : fineProbabilities.entrySet()) {
                Symbol token = e.getKey();
                fineProbabilities.put(token, e.getValue() * scaleFactor);
            }
        }
        return fineProbabilities;
    }
    
    public String generateNextPred(String predName) {
        currentAns = new Multigraph();
        // rootScope = new RLScopeTreeNode(treeId, visitor.getRootScope(), currentAns);
        rlScopeTreeNodeId = 100; // reset the scope tree node id for each new generation
        tovMap = new HashMap<>();
        leaves = new LinkedHashSet<>();
        AugmentedNode rootNode = new AugmentedNode(-1, treeId);
        Symbol root = new PredRootSymbol(rootNode, predName);
        dynamicUniqueNodes.put(root, rootNode);
        rootNode.setSymbol(root);
        Multigraph predGraph = new Multigraph(rootNode, gv);
        // rootScope.setqDist(globalQTable); // set the Q-table of the root scope to the global Q-table before generation
        currentAns.addVertex(rootNode);
        currentAns.setScope(rootScope);
        // System.err.println("rootScope dist: " + rootScope.getqDist());
        generateNextNode(rootNode, 1, rootScope);
        Generator generator = new Generator();
        String code = null;
        try {
            code = generator.toCode(predGraph, predGraph.getRoot(), 1);
        } catch (Exception e) {
            System.out.println("Error during code generation: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
        this.globalQTable = rootScope.getqDist(); // update the global Q-table with the one from the root scope after generation
        return code;
    }

    public int generateNextNode(AugmentedNode localParent, int position, RLScopeTreeNode scope) {
        if (stepNum > MAX_STEPS) {
            throw new RuntimeException("Exceeded maximum steps in generation. Current node: " + localParent.getSymbol().getName() + ", position: " + position);
        }
        if (position == 1) {
            // update the times of visit only for the first position for each visit
            tovMap.putIfAbsent(localParent.getSymbol(), 0);
            tovMap.put(localParent.getSymbol(), tovMap.get(localParent.getSymbol()) + 1);
        }
        stepNum++;
        Symbol source = localParent.getSymbol();
        if (source instanceof MiddleSymbol && ((MiddleSymbol) source).isQt()) {
            AugmentedNode qtNode = fillHoleQt(source, scope);
            currentAns.addVertex(qtNode);
            localParent.connect(qtNode, position, currentAns, tovMap.getOrDefault(source, 1));
            // TODO: recursively generate downstream
            return 0; // success
        }
        Symbol nextToken = fillHole(source, position, scope);
        AugmentedNode nextNode = dynamicUniqueNodes.get(nextToken);
        currentAns.addVertex(nextNode);
        localParent.connect(nextNode, position, currentAns, tovMap.getOrDefault(source, 1));
        if (nextToken instanceof EndSymbol) {
            leaves.add(nextToken);
            return -1; // end symbol reached, pass a signal to stop further generation in this branch
        } 
        // no need to generate siblings, since there is only one node down the root
        if (nextToken.getMaxDownlinks() != 0) {
            int childPosition = 1;
            while (childPosition <= nextToken.getMaxDownlinks() || nextToken.getMaxDownlinks() == -1) {
                int result = generateNextNode(nextNode, childPosition, scope);
                if (result == -1) break; // end symbol reached
                childPosition++;
            }// TODO: recursively generate downstream
        } else {
            leaves.add(nextToken);
        }
        return 0; // success
    }
    public Symbol fillHole(Symbol source, int position, RLScopeTreeNode currentScope) {
        // TODO: 1. use a randomizer and the Q-table to select the next token;
        // 2. log the action into the sequence; 
        // 3. return the selected token;
        if (source instanceof PredRootSymbol) {
            return fillHole(DummySymbol.DUMMY_PREDROOT, position, currentScope);
        }
        if (!currentScope.getqDist().containsKey(Pair.of(source, position))) {
            System.out.println("Q-table missing for " + source.getName() + " at position " + position);
            throw new RuntimeException("Q-table missing for " + source.getName() + " at position " + position);
        }
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
            System.err.println("Selected token is a dummy symbol: " + nextToken.getName() + " at position " + position + " of " + source.getName() + ". Reverting and selecting again.");
            System.err.println("Current Q-entry value: " + qTable.get(Pair.of(source, position)));
            System.err.println("for RL Scope Tree ID " + rlScopeTreeNodeId);
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
        currentAns.addVertex(qtNode);
        rlScopeTreeNodeId++;
        RLScopeTreeNode qtScope = new RLScopeTreeNode(rlScopeTreeNodeId, currentScope, currentAns);
        // TODO: update the qtable of the new scope;
        Symbol qt1 = fillHole(qtRoot, 1, qtScope);
        AugmentedNode qt1Node = dynamicUniqueNodes.get(qt1);
        currentAns.addVertex(qt1Node);
        tovMap.putIfAbsent(qtRoot, 0);
        tovMap.put(qtRoot, tovMap.get(qtRoot) + 1);
        qtNode.connect(qt1Node, 1, currentAns, tovMap.get(qtRoot));
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
                currentAns.addVertex(endNode);
                qtNode.connect(endNode, i, currentAns, tovMap.get(qtRoot));
                actionSequence.add(qtRoot.getName() + ", " + i + ", <END>");
                break;
            } else {
                Map<Symbol, Float> sigProbabilities = Probability.coarseTokenProbabilities(gv, dynamicUniqueNodes, qtRoot, i);
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
                        currentAns.addVertex(anDown);
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
                int result = generateNextNode(qt1Node, childPosition, qtScope);
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
        generateNextNode(relDeclNode, 1, currentScope);
        Symbol typeSig = typeCheckSymbol(relDeclNode.getDownlinksAtTimeOfVisit(currentAns, tovMap.get(relDeclRoot)).get(0).getTarget().getSymbol());
        AugmentedNode sigNode = dynamicUniqueNodes.get(typeSig);
        tovMap.putIfAbsent(relDeclRoot, 0);
        tovMap.put(relDeclRoot, tovMap.get(relDeclRoot) + 1);
        relDeclNode.connect(sigNode, 1, currentAns, tovMap.get(relDeclRoot));
        String sigName = typeSig.getName();
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
                relDeclNode.connect(endNode, i, currentAns, tovMap.get(relDeclRoot));
                actionSequence.add(relDeclRoot.getName() + ", " + i + " <END> ");
                break;
            }
            addVariableDecl(sigName, treeId, qtNode, currentScope);
            i++;
        }
        return relDeclNode;
    }

    private SetSymbol typeCheckSymbol(Symbol sym) {
        // like MASGVisitor.typeCheckExpr but with symbols
        if (sym instanceof VarSymbol) {
            VarSymbol varSym = (VarSymbol) sym;
            String sigName = varSym.getType().substring(4); // remove "VAR_" prefix
            return new SigSymbol(sigName);
        } else if (sym instanceof SigSymbol) {
            return (SigSymbol) sym;
        } else if (sym instanceof FieldRelation) {
            return (FieldRelation) sym;
        } else if (sym instanceof MiddleSymbol) {
            AugmentedNode node = dynamicUniqueNodes.get(sym);
            List<MASGEdge> downlinks = node.getDownlinksAtTimeOfVisit(currentAns, tovMap.getOrDefault(sym, 1));
            if (downlinks == null || downlinks.isEmpty()) {
                throw new RuntimeException("No downlinks found for symbol: " + sym.getName() + " at time of visit: " + tovMap.getOrDefault(sym, 1));
            }
            for (MASGEdge downlink : downlinks) {
                Symbol targetSym = downlink.getTarget().getSymbol();
                if (targetSym instanceof SigSymbol) {
                    return (SigSymbol) targetSym;
                } else if (targetSym instanceof FieldRelation) {
                    return (FieldRelation) targetSym;
                }
            }
            return downlinks.isEmpty() ? null : typeCheckSymbol(downlinks.get(0).getTarget().getSymbol()); // recursive check
        } else {
            return null; // for other symbol types, return null or throw an exception based on your design choice
        }
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
        // encoding corresponding to De Bruijn indices: the variable name is not important, but the place in the scope tree is
        Symbol newVar = new VarSymbol(sigName, "var_" + globalNewVarCounter, "local_var_" + sigName + "_s" + rlScopeTreeNodeId + "_" + currentScope.size(), treeId, confinerNode);
        actionSequence.add("ADD_VAR " + ((VarSymbol)newVar).getHashName());
        // this.symbolId.put(this.symbolId.size(), newVar);
        symbolScopeMap.put(newVar, currentScope);
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
        if (currentScope == rootScope) {
            globalQTable = qTable; // keep the global Q-table updated with the root scope's Q-table
        }
        if (currentScope.getParent() != null && currentScope.getParent() instanceof RLScopeTreeNode && !visitedScopes.contains(currentScope.getParent())) {
            RLScopeTreeNode parentScope = (RLScopeTreeNode) currentScope.getParent();
            visitedScopes.add(parentScope);
            if (parentScope.symbolsAvailable().containsValue(selection)) {
                updateQTable(source, position, selection, reward, parentScope);
            } else {
                // if the selected symbol is not available in the parent scope, we can update the local variable distribution scope
                Queue<RLScopeTreeNode> queue = new LinkedList<>();
                float localVarProb = currentScope.localVarProb(Pair.of(source, position));
                queue.offer(parentScope);
                while (!queue.isEmpty()) {
                    RLScopeTreeNode scopeNode = queue.poll();
                    scopeNode.rescaleLocalVars(localVarProb);
                    if (scopeNode.getParent() != null && scopeNode.getParent() instanceof RLScopeTreeNode && !visitedScopes.contains(scopeNode.getParent())) {
                        visitedScopes.add((RLScopeTreeNode) scopeNode.getParent());
                        queue.offer((RLScopeTreeNode) scopeNode.getParent());
                    }
                    // other children
                    for (ScopeTreeNode child : scopeNode.getChildren()) {
                        if (child instanceof RLScopeTreeNode && !visitedScopes.contains(child)) {
                            visitedScopes.add((RLScopeTreeNode) child);
                            queue.offer((RLScopeTreeNode) child);
                        }
                    }
                }
            }
        }
        for (ScopeTreeNode child : currentScope.getChildren()) {
            RLScopeTreeNode childNode = (child instanceof RLScopeTreeNode) ? (RLScopeTreeNode) child : null;
            if (!visitedScopes.contains(childNode)) {
                visitedScopes.add(childNode);
                updateQTable(source, position, selection, reward, childNode);
            }
        }
    }

    /**
     * Calculate the local reward for a candidate symbol based on its children in
     * the ASG.
     * This method looks for all children of the candidate symbol and calculates the
     * local reward based on their probabilities.
     * * If the candidate symbol has no children, it returns the raw reward.
     * 
     * @param source    the source symbol from which the candidate is derived.
     * @param position  the position in the ASG where the candidate is located.
     * @param candidate the candidate symbol for which the local reward is
     *                  calculated.
     * @param rawReward the raw reward value associated with the generated current
     *                  predicate.
     * @return the calculated local reward based on the children of the candidate
     *         symbol.
     */
    public float localReward(Symbol source, int position, Symbol candidate, float rawReward, RLScopeTreeNode currentScope) throws IllegalArgumentException {
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qTable = currentScope.getqDist();
        if (candidate == null) {
            throw new IllegalArgumentException("Candidate symbol cannot be null");
        }
        if (candidate.getMaxDownlinks() == 0) {
            edgeRewardMap.put(Pair.of(source, position), rawReward);
            return rawReward;
        }
        // look for all children of the candidate
        AugmentedNode candidateNode = gv.getUniqueNodes().get(candidate);
        if (candidateNode == null) {
            throw new IllegalArgumentException("Candidate node not found for " + candidate);
        }
        List<MASGEdge> downlinks = currentAns.edgesUnder(candidateNode);
        if (downlinks.isEmpty()) {
            return rawReward; // No children, return the raw reward
        }
        float ans = 0.0f;
        for (MASGEdge edge : downlinks) {
            AugmentedNode targetNode = edge.getTarget();
            Symbol targetSymbol = targetNode.getSymbol();
            if (targetSymbol == null) {
                throw new IllegalArgumentException("Target symbol cannot be null for edge: " + edge);
            }
            // Calculate the local reward based on the target symbol
            float localImpact = 0.0f;
            Map<Symbol, Float> candidateProbs = qTable.get(Pair.of(source, position));
            if (candidateProbs != null) {
                localImpact = candidateProbs.getOrDefault(targetSymbol, 0.0f);
            }
            float downReward = 0.0f;
            if (edgeRewardMap.containsKey(Pair.of(source, edge.getPosition()))) {
                downReward = edgeRewardMap.get(Pair.of(source, edge.getPosition()));
            } else {
                downReward = localReward(candidate, edge.getPosition(), targetSymbol, rawReward, currentScope);
            }
            ans += localImpact * downReward;
        }
        edgeRewardMap.put(Pair.of(source, position), ans);
        return ans; // Placeholder for local reward calculation
        // TODO: Up-pooling rewards for collapsing Scope Tree.
    }

    public void backpropagateReward(float reward) {
        List<MASGEdge> edges = currentAns.getEdges();
        Map<Pair<Symbol, Integer>, Set<Symbol>> children = new HashMap<>();
        Map<Symbol, Set<Pair<Symbol, Integer>>> parents = new HashMap<>();
        for (MASGEdge edge : edges) {
            Symbol source = edge.getSource().getSymbol();
            Symbol target = edge.getTarget().getSymbol();
            int position = edge.getPosition();
            children.putIfAbsent(Pair.of(source, position), new LinkedHashSet<>());
            children.get(Pair.of(source, position)).add(target);
            parents.putIfAbsent(target, new LinkedHashSet<>());
            parents.get(target).add(Pair.of(source, position));
        }
        Queue<Pair<Symbol, Integer>> queue = new LinkedList<>();
        Map<Pair<Symbol, Integer>, Integer> remaining = new HashMap<>();
        for (Map.Entry<Pair<Symbol, Integer>, Set<Symbol>> entry : children.entrySet()) {
            Pair<Symbol, Integer> parent = entry.getKey();
            Set<Symbol> childSet = entry.getValue();
            boolean allLeaves = true;
            int leafOffset = 0;
            for (Symbol child : childSet) {
                if (!leaves.contains(child)) {
                    allLeaves = false;
                    leafOffset++;
                }
            }
            if (allLeaves) {
                queue.offer(parent);
            }
            remaining.put(parent, childSet.size() - leafOffset);
        }
        while (!queue.isEmpty()) {
            Pair<Symbol, Integer> current = queue.poll();
            Symbol source = current.a;
            int position = current.b;
            Set<Symbol> childSet = children.get(current);
            // TODO: calculate the reward for the current node based on its children and the edge rewards
            for (Symbol child : childSet) {
                visitedScopes = new HashSet<RLScopeTreeNode>();
                float edgeReward = localReward(source, position, child, reward, rootScope);
                edgeRewardMap.put(Pair.of(source, position), edgeReward);
                updateQTable(source, position, child, edgeReward, rootScope);
            }
            for (Pair<Symbol, Integer> parent : parents.get(source)) {
                int rem = remaining.get(parent) - 1;
                remaining.put(parent, rem);
                if (rem == 0) {
                    queue.offer(parent);
                }
            }
        }
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
