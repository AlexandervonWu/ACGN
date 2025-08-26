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

import is.fivefivefive.ACGN.alloy.DummySymbol;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.etc.BiMap;
import is.fivefivefive.ACGN.test.Playground;
import is.fivefivefive.AlloyDataProcessor.EdgeCounter;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import parser.etc.Pair;

// TODO: Globalize all unique nodes. 
public final class GlobalVariables implements Serializable {
    private Map<Pair<Symbol, Integer>, Set<Symbol>> edgeMap;
    private Map<Symbol, Integer> maxChildCount;
    private Map<Pair<Symbol, Integer>, float[]> initQTable;
    private BiMap<Symbol, AugmentedNode> uniqueNode;
    private Map<Symbol, Double> pretrainedSignatures;
    public GlobalVariables() {
        edgeMap = new HashMap<Pair<Symbol, Integer>, Set<Symbol>>();
        maxChildCount = new HashMap<Symbol, Integer>();
        initQTable = new HashMap<Pair<Symbol, Integer>, float[]>();
        uniqueNode = new BiMap<Symbol, AugmentedNode>();
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
        System.out.println("Initialized Q-table with " + initQTable.size() + " entries.");
        writeToFile("global_variables.ser", this);
    }
    public Map<Pair<Symbol, Integer>, float[]> getInitQTable() {
        return initQTable;
    }
    public BiMap<Symbol, AugmentedNode> getUniqueNodes() {
        return uniqueNode;
    }
    public void setUniqueNodes(BiMap<Symbol, AugmentedNode> uniqueNode) {
        this.uniqueNode = uniqueNode;
    }
    public void addUniqueNodes(BiMap<Symbol, AugmentedNode> nextUniqueNodes) {
        for (Symbol key : nextUniqueNodes.keys()) {
            Symbol keyMod = EdgeCounter.getSymbolForPretrain(key);
            AugmentedNode node = nextUniqueNodes.get(key);
            if (keyMod instanceof DummySymbol) {
                // make a dummy AugmentedNode
                int dummyId = uniqueNode.size();
                AugmentedNode dummyNode = new AugmentedNode(-1, dummyId, keyMod);
                node = dummyNode;
            }
            if (!uniqueNode.containsKey(keyMod)) {
                System.out.println("Adding key: " + keyMod);
                uniqueNode.put(keyMod, node);
            }
        }
    }
    public void addCustomUniqueNodes(BiMap<Symbol, AugmentedNode> visitorNodes) {
        for (Symbol symbol : visitorNodes.keys()) {
            AugmentedNode node = visitorNodes.get(symbol);
            Symbol categorySymbol = EdgeCounter.getSymbolForPretrain(symbol);
            if (categorySymbol instanceof DummySymbol) {
                // transformed
                System.out.println("Adding custom unique node: " + categorySymbol.getType() + " -> " + symbol.getName());
                double signature = uniqueNode.get(categorySymbol).getSignature();
                double randomNoise = (Math.random() - 1) * 0.01; // small noise
                node.setSignature(signature + randomNoise);
            }
            if (!uniqueNode.containsKey(symbol)) {
                uniqueNode.put(symbol, node);
            }
        }
    }
    public static void writeToFile(String filename, GlobalVariables gv) {
        // serialize the GlobalVariables object to a file
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(filename)))
        {
            oos.writeObject(gv);
            BiMap.writeToFile("map_" + filename, gv.uniqueNode);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public static GlobalVariables readFromFile(String filename) {
        // deserialize the GlobalVariables object from a file
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream(filename))) {
            GlobalVariables gv = (GlobalVariables) ois.readObject();
            System.out.println(gv.edgeMap.size());
            System.out.println(gv.uniqueNode.size());
            return gv;
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    public void loadPretrainedSignatures(String nodeIdCsvPath, String signatureCsvPath) {
        Map<String, Float> symbolSignatureMap = EdgeCounter.generateNodeSignatureMap(nodeIdCsvPath, signatureCsvPath);
        for (Symbol symbol : uniqueNode.keys()) {
            String key = symbol.getName();
            if (symbolSignatureMap.containsKey(key)) {
                float signature = symbolSignatureMap.get(key);
                uniqueNode.get(symbol).setSignature(signature);
            } else {
                System.out.println("ERR: No pretrained signature for: " + key);
            }
        }
    }

}
