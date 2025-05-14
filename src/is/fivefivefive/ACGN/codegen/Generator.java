package is.fivefivefive.ACGN.codegen;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;

public class Generator {
    // TODO: The main code generator
    private Map<AugmentedNode, Integer> tovTracker;
    public Generator() {
        tovTracker = new HashMap<AugmentedNode, Integer>();
    }
    public String toCode(AugmentedNode root, int tov) {
        // TODO: Complete this. 
        tovTracker.putIfAbsent(root, tov);
        StringBuilder sb = new StringBuilder();
        switch (root.getSymbol().getClass().getSimpleName()) {
            case "AssertSymbol":
                sb.append("assert ");
                sb.append(root.getSymbol().getName());
                // sb.append(root.getDownlinks().get(0).getTarget().toCode(0));
                AugmentedNode assertBody = root.getDownlinks().get(0).getTarget();
                tovTracker.putIfAbsent(assertBody, 1);
                int tovAssertBody = tovTracker.get(assertBody);
                sb.append(toCode(root.getDownlinks().get(0).getTarget(), tovAssertBody));
                break;
            case "EndSymbol":
                break;
            case "ShadowSymbol":
                // sb.append(root.getUplinks().get(0).getSource().toCode(tov + 1)); 
                AugmentedNode explicit = root.getUplinks().get(0).getSource();
                tovTracker.putIfAbsent(explicit, 1);
                int tovExplicit = tovTracker.get(explicit) + 1;
                tovTracker.putIfAbsent(explicit, tovExplicit);
                sb.append(toCode(root.getUplinks().get(0).getSource(), tovExplicit));
                break;
            case "SigSymbol":
            case "VarSymbol":
            case "FieldRelation":
            case "ConstSymbol":
                sb.append(root.getSymbol().getName());
                break;
            case "RefSymbol":
                if (root.getSyntactic() == 122) {
                    // a let expression
                    sb.append("let ");
                    sb.append(root.getSymbol().getName());
                    sb.append(" = ");
                    AugmentedNode letBody = root.getDownlinks().get(0).getTarget();
                    tovTracker.putIfAbsent(letBody, 1);
                    int tovLetBody = tovTracker.get(letBody);
                    sb.append(" | ");
                    sb.append(toCode(letBody, tovLetBody));
                    break;
                } else {
                    // references of predicates, functions, etc
                    sb.append(root.getSymbol().getName());
                    for (MASGEdge e : root.getDownlinksAtTimeOfVisit(tov)) {
                        AugmentedNode refSub = e.getTarget();
                        tovTracker.putIfAbsent(refSub, 1);
                        int tovRefSub = tovTracker.get(refSub);
                        sb.append(toCode(refSub, tovRefSub));
                    }
                }
                break;
            case "MiddleSymbol":
                // multiple cases
                switch (root.getSyntactic()) {
                    case -127: 
                        // RelDecl roots
                        switch ((int)Math.round(root.getSemantic())) {
                            case 0:
                                // neither variable nor disjoint
                                List<MASGEdge> downlinks = root.getDownlinksAtTimeOfVisit(tov);
                                for (MASGEdge e : downlinks) {
                                    
                                }
                            default:
                                break;
                        }
                }
            default:
                break;
        }
        return sb.toString();
    }
}
