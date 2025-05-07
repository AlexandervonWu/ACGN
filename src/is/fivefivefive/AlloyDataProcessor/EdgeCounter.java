package is.fivefivefive.AlloyDataProcessor;
import is.fivefivefive.ACGN.alloy.DummySymbol;
import is.fivefivefive.ACGN.alloy.FieldRelation;
import is.fivefivefive.ACGN.alloy.RefSymbol;
import is.fivefivefive.ACGN.alloy.SigSymbol;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.alloy.VarSymbol;
import is.fivefivefive.alloyasg.etc.Triple;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

public class EdgeCounter {
    public static Map<Triple<Symbol, Symbol, Integer>, Integer> countEdges(String dir) {
        // TODO

        return null;
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
        } else {
            return original;
        }
    }
}
