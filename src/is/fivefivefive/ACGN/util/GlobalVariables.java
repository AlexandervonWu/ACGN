package is.fivefivefive.ACGN.util;

import java.util.Map;
import java.util.Set;
import java.util.LinkedHashSet;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.HashMap;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import parser.etc.Pair;

public final class GlobalVariables implements Serializable {
    private Map<Pair<Symbol, Integer>, Set<Symbol>> edgeMap;
    private Map<Symbol, Integer> maxChildCount;
    private Map<Pair<Symbol, Integer>, float[]> initQTable;
    public GlobalVariables() {
        edgeMap = new HashMap<Pair<Symbol, Integer>, Set<Symbol>>();
        maxChildCount = new HashMap<Symbol, Integer>();
        initQTable = new HashMap<Pair<Symbol, Integer>, float[]>();
    }
    public Map<Pair<Symbol, Integer>, Set<Symbol>> getEdgeMap() {
        return edgeMap;
    }
    public Set<Symbol> getCandidates(Symbol source, int position) {
        return edgeMap.get(Pair.of(source, position));
    }
    public void addEdge(Symbol source, Symbol target, int position) {
        if (!edgeMap.containsKey(Pair.of(source, position))) {
            edgeMap.put(Pair.of(source, position), new LinkedHashSet<Symbol>());
        }
        if (maxChildCount.containsKey(source)) {
            int count = maxChildCount.get(source);
            if (count < position + 1) {
                maxChildCount.put(source, position + 1);
            }
        } else {
            maxChildCount.put(source, position + 1);
        }
        edgeMap.get(Pair.of(source, position)).add(target);
    }
    public void addEdge(MASGEdge edge, int position) {
        addEdge(edge.getSource().getSymbol(), edge.getTarget().getSymbol(), position);
    }
    public void addEdge(AugmentedNode source, AugmentedNode target, int position) {
        addEdge(source.getSymbol(), target.getSymbol(), position);

    }
    public void combine(GlobalVariables another) {
        // Combine the edgeMaps
        for (Pair<Symbol, Integer> source : another.getEdgeMap().keySet()) {
            if (!edgeMap.containsKey(source)) {
                edgeMap.put(source, new LinkedHashSet<Symbol>());
            }
            edgeMap.get(source).addAll(another.getEdgeMap().get(source));
        }
    }
    public int getMaxChildCount(Symbol source) {
        if (maxChildCount.containsKey(source)) {
            return maxChildCount.get(source);
        } else {
            return 0; // No children
        }
    }
    public Map<Symbol, Integer> getMaxChildCountMap() {
        return maxChildCount;
    }
    public void setInitQTable(Map<Pair<Symbol, Integer>, float[]> initQTable) {
        this.initQTable = initQTable;
    }
    public Map<Pair<Symbol, Integer>, float[]> getInitQTable() {
        return initQTable;
    }
    public static void writeToFile(String filename, GlobalVariables gv) {
        // serialize the GlobalVariables object to a file
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(filename)))
        {
            oos.writeObject(gv);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public static GlobalVariables readFromFile(String filename) {
        // deserialize the GlobalVariables object from a file
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(filename))) {
            return (GlobalVariables) ois.readObject();
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }
}
