package is.fivefivefive.AlloyDataProcessor;
import is.fivefivefive.ACGN.alloy.DummySymbol;
import is.fivefivefive.ACGN.alloy.FieldRelation;
import is.fivefivefive.ACGN.alloy.RefSymbol;
import is.fivefivefive.ACGN.alloy.SigSymbol;
import is.fivefivefive.ACGN.alloy.SubsetRelation;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.alloy.VarSymbol;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.alloyasg.etc.Triple;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

import java.io.File;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

import edu.mit.csail.sdg.parser.CompModule;

public class EdgeCounter {
    public static Map<Triple<Symbol, Symbol, Integer>, Integer> countEdges(String dir) {
        File dirFile = new File(dir);
        if (!dirFile.isDirectory()) {
            System.out.println("The provided path is not a directory.");
            return null;
        }
        Map<Triple<Symbol, Symbol, Integer>, Integer> edgeCountMap = new HashMap<>();
        File[] files = dirFile.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isFile() && file.getName().endsWith(".ast")) {
                    try {
                        CompModule module = AlloyUtil.compileAlloyModule(dir + "/" + file.getName());
                        ModelUnit mu = new ModelUnit(null, module);
                        MASGVisitor visitor = new MASGVisitor();
                        mu.accept(visitor, null);
                        for (int id : visitor.getForest().keys()) {
                            Multigraph graph = visitor.getForest().get(id);
                            for (MASGEdge e : graph.getEdges()) {
                                Symbol source = getSymbolForPretrain(e.getSource().getSymbol());
                                Symbol target = getSymbolForPretrain(e.getTarget().getSymbol());
                                int position = e.getPosition();
                                Triple<Symbol, Symbol, Integer> edge = new Triple<>(source, target, position);
                                edgeCountMap.put(edge, edgeCountMap.getOrDefault(edge, 0) + 1);
                            }
                        }
                    } catch (Exception e) {
                        System.out.println("Error processing file: " + file.getName());
                        e.printStackTrace();
                    }
                }
            }
        }
        return edgeCountMap;
    }
    private static Symbol getSymbolForPretrain(Symbol original) {
        if (original instanceof VarSymbol) {
            return new DummySymbol("var");
        } else if (original instanceof RefSymbol) {
            return new DummySymbol("ref");
        } else if (original instanceof FieldRelation) {
            return new DummySymbol("field");
        } else if (original instanceof SigSymbol) {
            return new DummySymbol("sig");
        } else if (original instanceof SubsetRelation) {
            return new DummySymbol("subset");
        } else {
            return original;
        }
    }
}
