package is.fivefivefive.ACGN.structure;

import java.util.Map;
import java.util.HashMap;

import parser.etc.Pair;
import is.fivefivefive.ACGN.alloy.DummySymbol;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.alloy.VarSymbol;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.etc.Triple;

public class RLScopeTreeNode extends ScopeTreeNode {
    public static final float OLD_VARS_RESERVE_RATE = 0.2f;
    private Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qDist;
    private Map<Symbol, String> sigCorr;
    public RLScopeTreeNode(int id, ScopeTreeNode parent) {
        super(id, parent);
        this.qDist = new HashMap<>();
    }
    public RLScopeTreeNode(int id, ScopeTreeNode parent, Multigraph affl) {
        super(id, parent, affl);
        this.qDist = new HashMap<>();
    }
    public RLScopeTreeNode(int id, Map<String, Symbol> symbols, ScopeTreeNode parent, Multigraph affl) {
        super(id, symbols, parent, affl);
        this.qDist = new HashMap<>();
    }
    public RLScopeTreeNode(int id, RLScopeTreeNode parent) {
        super(id, parent);
        this.qDist = parent.getqDist();
    }
    public RLScopeTreeNode(int id, RLScopeTreeNode parent, Multigraph affl) {
        super(id, parent, affl);
        this.qDist = parent.getqDist();
    }
    public RLScopeTreeNode(int id, Map<String, Symbol> symbols, RLScopeTreeNode parent, Multigraph affl) {
        super(id, symbols, parent, affl);
        this.qDist = parent.getqDist();
    }
    public RLScopeTreeNode(int id, Map<String, Symbol> symbols, ScopeTreeNode parent, Multigraph affl, Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qDist) {
        super(id, symbols, parent, affl);
        this.qDist = qDist;
    }
    public void addSymbol(Symbol next) {
        super.addSymbol(next);
        if (next instanceof VarSymbol) {
            VarSymbol varNext = (VarSymbol) next;
            sigCorr.put(varNext, varNext.getType());
        }
    }
    public String typeOf(Symbol s) {
        if (sigCorr.containsKey(s)) {
            return sigCorr.get(s);
        }
        if (getParent() != null && getParent() instanceof RLScopeTreeNode) {
            return ((RLScopeTreeNode) getParent()).typeOf(s);
        }
        return null;
    }
    public Map<Pair<Symbol, Integer>, Map<Symbol, Float>> getqDist() {
        return qDist;
    }
    public void setqDist(Map<Pair<Symbol, Integer>, Map<Symbol, Float>> qDist) {
        this.qDist = qDist;
    }
    public void resetQDist() {
        this.qDist = new HashMap<>();
        for (ScopeTreeNode children : getChildren()) {
            if (children instanceof RLScopeTreeNode) {
                ((RLScopeTreeNode) children).resetQDist();
            }
        }
    }

    public void localizeQDist(Map<Pair<Symbol, Integer>, Map<Symbol, Float>> globalQDist) {
        // use the inherited qDist as the original qDist, and localize it by the symbols in the current node. 
        // for each pair of (symbol, position) in the global qDist, find the probability of DUMMY_LOCAL_VAR
        Map<Pair<Symbol, Integer>, Float> localVarProbs = new HashMap<>();
        // find the probability of DUMMY_LOCAL_VAR for each (symbol, position) pair in the global qDist
        for (Pair<Symbol, Integer> pair : globalQDist.keySet()) {
            Map<Symbol, Float> candidateProbs = globalQDist.get(pair);
            float dummyLocalVarProb = candidateProbs.getOrDefault(DummySymbol.DUMMY_LOCAL_VAR, 0f);
            localVarProbs.put(pair, dummyLocalVarProb);
        }
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> localizedQDist = new HashMap<>();
        Map<String, Symbol> inheritedSymbols = getParent() instanceof RLScopeTreeNode ? getParent().symbolsAvailable() : null;
        // distribute the probability of DUMMY_LOCAL_VAR to the symbols in the current node according to the reserve rate, and keep the rest for DUMMY_LOCAL_VAR
        if (inheritedSymbols != null) {
            for (Map.Entry<Pair<Symbol, Integer>, Map<Symbol, Float>> entry : qDist.entrySet()) {
                Pair<Symbol, Integer> pair = entry.getKey();
                Map<Symbol, Float> candidateProbs = entry.getValue();
                float dummyLocalVarProb = localVarProbs.getOrDefault(pair, 0f);
                float distributedProb = dummyLocalVarProb * (1 - OLD_VARS_RESERVE_RATE);
                Map<Symbol, Float> localizedCandidateProbs = new HashMap<>();
                for (Map.Entry<Symbol, Float> candidateEntry : candidateProbs.entrySet()) {
                    Symbol candidate = candidateEntry.getKey();
                    float prob = candidateEntry.getValue();
                    if (inheritedSymbols.containsValue(candidate)) {
                        localizedCandidateProbs.put(candidate, prob * OLD_VARS_RESERVE_RATE);
                    } else {
                        localizedCandidateProbs.put(candidate, prob);
                    }
                }
                for (Symbol localSymbol : getSymbols().values()) {
                    localizedCandidateProbs.put(localSymbol, distributedProb / getSymbols().size());
                }
                localizedQDist.put(pair, localizedCandidateProbs);
            }
        } else {
            // initial distribution
            for (Map.Entry<Pair<Symbol, Integer>, Map<Symbol, Float>> entry : qDist.entrySet()) {
                Pair<Symbol, Integer> pair = entry.getKey();
                Map<Symbol, Float> candidateProbs = entry.getValue();
                float dummyLocalVarProb = localVarProbs.getOrDefault(pair, 0f);
                Map<Symbol, Float> localizedCandidateProbs = new HashMap<>(candidateProbs);
                for (Symbol localSymbol : getSymbols().values()) {
                    localizedCandidateProbs.put(localSymbol, dummyLocalVarProb / getSymbols().size());
                }
                localizedQDist.put(pair, localizedCandidateProbs);
            }
        }
        this.qDist = localizedQDist;
    }

    public void dumpLocalVariables(Map<Pair<Symbol, Integer>, Map<Symbol, Float>> localVarDist, Map<Triple<Symbol, Integer, Symbol>, Integer> localVarCounter) {
        Map<Pair<Symbol, Integer>, Map<Symbol, Float>> localVarProbs = new HashMap<>();
        Map<Triple<Symbol, Integer, Symbol>, Integer> localVarCounterUpdate = new HashMap<>();
        for (Map.Entry<Pair<Symbol, Integer>, Map<Symbol, Float>> entry : qDist.entrySet()) {
            Pair<Symbol, Integer> parentPair = entry.getKey();
            Map<Symbol, Float> candidateProbs = entry.getValue();
            for (Symbol localSymbol : getSymbols().values()) {
                float totalLocalVarProb = 0f;
                if (candidateProbs.containsKey(localSymbol)) {
                    localVarProbs.put(parentPair, candidateProbs);
                    totalLocalVarProb += candidateProbs.get(localSymbol);
                    Triple<Symbol, Integer, Symbol> counterKey = new Triple<>(parentPair.a, parentPair.b, localSymbol);
                    localVarCounterUpdate.put(counterKey, localVarCounterUpdate.getOrDefault(counterKey, 0) + 1);
                    localVarCounter.put(counterKey, localVarCounter.getOrDefault(counterKey, 0) + 1);
                }
                // normalize the probabilities of the candidates for the parent pair, and remove the local symbol from the candidate list
                if (totalLocalVarProb > 0) {
                    Map<Symbol, Float> normalizedCandidateProbs = new HashMap<>();
                    for (Map.Entry<Symbol, Float> candidateEntry : candidateProbs.entrySet()){
                        Symbol candidate = candidateEntry.getKey();
                        float prob = candidateEntry.getValue();
                        if (!candidate.equals(localSymbol)) {
                            normalizedCandidateProbs.put(candidate, prob / totalLocalVarProb);
                        }
                    }
                    localVarProbs.put(parentPair, normalizedCandidateProbs);
                    // scale the localVarDist with the localVarCounter and localVarCounterUpdate
                    for (Map.Entry<Symbol, Float> candidateEntry : candidateProbs.entrySet()){
                        Symbol candidate = candidateEntry.getKey();
                        if (!candidate.equals(localSymbol)) {
                            Triple<Symbol, Integer, Symbol> counterKey = new Triple<>(parentPair.a, parentPair.b, localSymbol);
                            int count = localVarCounter.getOrDefault(counterKey, 1);
                            int updateCount = localVarCounterUpdate.getOrDefault(counterKey, 1);
                            float scale = (float) count / updateCount;
                            localVarProbs.get(parentPair).put(candidate, candidateEntry.getValue() * scale + localVarDist.getOrDefault(localVarCounterUpdate, candidateProbs).getOrDefault(candidate, 0f) * (1 - scale));
                        }
                    }

                }
            }
        }
        
    }
}
