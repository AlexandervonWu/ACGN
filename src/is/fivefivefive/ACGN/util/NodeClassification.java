package is.fivefivefive.ACGN.util;

import java.util.List;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import parser.etc.Pair;

/**
 * A static collection of methods to classify the ASG nodes. 
 * Most importantly, oversee "what type of nodes under each node at each position" problem.
 */
public class NodeClassification {; //TODO: FILL IT
    // TODO: FIELD CLASSIFICATION; DO WE REALLY NEED TO GET EVERY， OR JUST A SYNTACTIC CATEGORY？？？？
    // EXPR IS EVALUATED TO A VALUE, FORMULA IS EVALUATED TO A SET? 
    public static List<Integer> possibleNodesUnder(AugmentedNode node, int position) {
        int syntactic = node.getSyntactic();
        double semantic = node.getSemantic();
        switch (syntactic) {
            case 0:
                // anything can be under the root node
                return List.of(-1); // -1 means anything
            case 1: // SIGEXPR, nothing
            case 2:// VAREXPR, nothing
            
            case 3:// FieldExpr, also a leaf node
            case 4: // ConstExpr, an integer, reserved
            case 5: // ConstExpr/Boolean
            case 6:  // CallExpr
            case -6: // and CallFormula
                return null; // all leaf nodes
            case -2:// Var/Real Decl, with a set of VarExpr as children. 
                // (2, -1) is a general wildcard VarExpr, as here may be considered newly declared. 
                return List.of(2);
            case 7: // UnaryExpr
            case 8:
            case 9:
            case 10:
                // Any Expr? Could formulae also under it? 
                return List.of(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12);
            case -7: // UnaryFormula
            case -8:
            case -9:
                
                
        }

    }
}
