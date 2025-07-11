package is.fivefivefive.ACGN.util;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.visitor.MASGVisitor;

public class Symbol2Node {
    public static AugmentedNode fromSymbol(Symbol symbol) {
        AugmentedNode node;
        switch(symbol.getClass().getSimpleName()) {
            case "AssertSymbol":
                node = new AugmentedNode(21, 0);
                break;
            case "EndSymbol":
                node = MASGVisitor.END_NODE;
                break;
            case "ShadowSymbol":
                node = new AugmentedNode(MASGVisitor.SHADOW_NODE);
                break;
            case "SigSymbol":
            case "VarSymbol":
            case "FieldRelation":
                // generic leaf node
                node = new AugmentedNode(100, 0);
                break;
            case "RefSymbol":
                // let

            default:
                throw new IllegalArgumentException("Unknown symbol type: " + symbol.getClass().getSimpleName());
        }
        node.setSymbol(symbol);
        return node;
    }
}
