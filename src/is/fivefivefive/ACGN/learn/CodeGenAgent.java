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

import is.fivefivefive.ACGN.alloy.DeclRootSymbol;
import is.fivefivefive.ACGN.alloy.DummySymbol;
import is.fivefivefive.ACGN.alloy.EndSymbol;
import is.fivefivefive.ACGN.alloy.PredRootSymbol;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.alloy.VarSymbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.etc.BiMap;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.util.Probability;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import parser.etc.Pair;

public class CodeGenAgent {
    private GlobalVariables gv;
    private MASGVisitor visitor; // the visitor for the specific Alloy Model
    static final int MAX_STEPS = 500;
    private Multigraph groundTruth;
    private Multigraph currentAns;
    private Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qTable;
    private BiMap<Integer, Symbol> symbolId;
    private Map<Pair<Symbol, Integer>, Float> edgeRewardMap; // reward for each edge
    private int globalNewVarCounter = 100;
    private BiMap<Symbol, AugmentedNode> dynamicUniqueNodes;
    private Map<Symbol, Set<Symbol>> coarseToFineBin; // local rather than global. 
    private List<String> actionSequence; // log the action sequence, then apply reinforcement learning by Q-learning.
    private Map<Symbol, Integer> tovMap; // track the times of visit. 
    private int treeId;

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
            this.qTable.put(key, fineProbabilities); // initial partially fine Q-table, waiting for the local variable declarations. 
        }
        this.tovMap = new HashMap<>();
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
        Map<Symbol, Integer> tovTracker = new HashMap<>();
        AugmentedNode rootNode = new AugmentedNode(-1, -1);
        Symbol root = new PredRootSymbol(rootNode, predName);
        Multigraph predGraph = new Multigraph(rootNode, gv);
        // TODO: begin with generaing the quantifiers and decls; 
        Queue<Symbol> nonterminals = new LinkedList<>();
        nonterminals.add(root);
        while (!nonterminals.isEmpty()) {
            // TODO: exception case for the predroot; 
            Symbol current = nonterminals.poll();
            tovTracker.putIfAbsent(current, 1);
            tovTracker.put(current, tovTracker.get(current) + 1);
            AugmentedNode currentNode = dynamicUniqueNodes.get(current);
            if (current.getMaxDownlinks() > 0 || current.getMaxDownlinks() == -1) {
                int position = 1;
                Symbol nextToken = fillHole(current, position);
                while (position <= current.getMaxDownlinks() && !(nextToken instanceof EndSymbol)) {
                    nonterminals.add(nextToken);
                    position++;
                    nextToken = fillHole(current, position);
                    if (nextToken.getMaxDownlinks() != 0) {
                        nonterminals.add(nextToken);
                    }
                    AugmentedNode nextNode = dynamicUniqueNodes.get(nextToken);
                    predGraph.connect(currentNode, nextNode, predGraph, position, tovTracker.get(current));
                }
            }
        }
        return generateNextPred(predName);
    }

    public Symbol fillHole(Symbol source, int position) {
        // TODO: 1. use a randomizer and the Q-table to select the next token;
        // 2. log the action into the sequence; 
        // 3. return the selected token;

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
        if (nextToken == null) {
            System.out.println("Incomplete Q-table set for " + source.getName() + " at position " + position);
            throw new RuntimeException("No next token selected for " + source.getName() + " at position " + position);
        }
        actionSequence.add(source.getName() + ", " + position + " -> " + nextToken.getName());
        return nextToken;
    }

    private AugmentedNode fillHoleQt(Symbol qtRoot) {
        String label = qtRoot.getName();
        char label3 = label.charAt(3);
        int syntactic = label3 == 'E' ? 3 : -3;
        char labelLast = label.charAt(label.length() - 1);
        int semantic = labelLast - '0';
        AugmentedNode qtNode = new AugmentedNode(syntactic, semantic, qtRoot); 
        Symbol qt1 = fillHole(qtRoot, 1);
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
            }
            Symbol relDeclRoot = new DeclRootSymbol(0);
            AugmentedNode anDown = fillHoleRelDecl(relDeclRoot, qtNode);
            currentAns.connect(qtNode, anDown, currentAns, i, tovMap.get(qtRoot));
            actionSequence.add(qtRoot.getName() + ", " + i + ", RELDECL ");
        }
        return qtNode;
    }

    private AugmentedNode fillHoleRelDecl(Symbol relDeclRoot, AugmentedNode qtNode) {
        if (!dynamicUniqueNodes.containsKey(relDeclRoot)) {
            dynamicUniqueNodes.put(relDeclRoot, new AugmentedNode(-127, 0, relDeclRoot));
        }
        AugmentedNode relDeclNode = dynamicUniqueNodes.get(relDeclRoot);
        Random random = new Random();
        // TODO: generate type first PROBLEM: HERE BEGINS WITH CONFINERS NOT NODES
        // DEFINED SIGNATURE TYPE, TRY FILLHOLE HERE
        Symbol sig = fillHole(relDeclRoot, 1);
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
            addVariableDecl(sigName, treeId, qtNode);
            actionSequence.add(relDeclRoot.getName() + ", " + i + " ADD_VAR " + globalNewVarCounter + " TYPE " + sigName);
        }
        return relDeclNode;
    }

    /**
     * An action defined to add a variable declaration in the scope. 
     * @param sigName The signature name that the variable belongs to.
     * @param treeId The tree ID representing the scope level (0 for global).
     * @param confinerNode The AugmentedNode that confines the variable.
     */
    public void addVariableDecl(String sigName, int treeId, AugmentedNode confinerNode) {
        // add a new variable into the scope of coarse to fine bin;
        globalNewVarCounter++;
        Symbol newVar = new VarSymbol(sigName, "local_var_" + globalNewVarCounter, treeId, confinerNode);
        this.symbolId.put(this.symbolId.size(), newVar);
        // update the coarse to fine bin
        coarseToFineBin.get(DummySymbol.DUMMY_LOCAL_VAR).add(newVar);
        // update the dynamic unique nodes
        AugmentedNode newNode = new AugmentedNode(127, globalNewVarCounter); // var nodes have signature 127
        this.dynamicUniqueNodes.put(newVar, newNode);
    }

    private static final double INERTIA = Hyperparams.INERTIA;
    public void updateQTable(Symbol source, int position, Symbol selection, float reward) throws IllegalArgumentException {
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
    }
    
    /*
     * // TODOS: 
     * 1. Coarse token to fine token expansion; not in initialization because new fine tokens as the newly declared variables; 
     * Fields and signatures could be initialized by the general coarse token metric. 
     * 2. RL Agent PER MODEL: - rewrite the dynamic unique nodes each iteration; 
     * REDESIGN some Q-learning to include some multivariance? Increase the uplooking depth? 
     * Use a map: [nextToken : probability] at each (currentToken, position) pair. 
     */
}
