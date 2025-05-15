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
        sb.append(" (");
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
                return "";
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
                    // TODO: PARAMS
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
                        switch ((int) Math.round(root.getSemantic())) {
                            case 1:
                                sb.append("disj ");
                                break;
                            case 2:
                                sb.append("var ");
                                break;
                            case 3:
                                sb.append("disj var ");
                                break;
                            default:
                                break;
                        }
                        List<MASGEdge> downlinksRD = root.getDownlinksAtTimeOfVisit(tov);
                        for (int i = 1; i < downlinksRD.size(); ++i) {
                            MASGEdge e = downlinksRD.get(i);
                            AugmentedNode relDecl = e.getTarget();
                            tovTracker.putIfAbsent(relDecl, 1);
                            int tovRelDecl = tovTracker.get(relDecl);
                            sb.append(toCode(relDecl, tovRelDecl));
                            if (i != downlinksRD.size() - 1) {
                                sb.append(", ");
                            }
                        }
                        sb.append(" : ");
                        AugmentedNode relDeclBody = downlinksRD.get(0).getTarget();
                        tovTracker.putIfAbsent(relDeclBody, 1);
                        int tovRelDecl = tovTracker.get(relDeclBody);
                        sb.append(toCode(relDeclBody, tovRelDecl));
                        break;
                    case 2:
                    case -2:
                        // ITEExprOrFormula
                        List<MASGEdge> downlinksITE = root.getDownlinksAtTimeOfVisit(tov);
                        AugmentedNode ifExpr = downlinksITE.get(0).getTarget();
                        AugmentedNode thenExpr = downlinksITE.get(1).getTarget();
                        AugmentedNode elseExpr = downlinksITE.get(2).getTarget();
                        tovTracker.putIfAbsent(ifExpr, 1);
                        int tovIfExpr = tovTracker.get(ifExpr);
                        sb.append(toCode(ifExpr, tovIfExpr));
                        sb.append(" => ");
                        tovTracker.putIfAbsent(thenExpr, 1);
                        int tovThenExpr = tovTracker.get(thenExpr);
                        sb.append(toCode(thenExpr, tovThenExpr));
                        sb.append(" else ");
                        tovTracker.putIfAbsent(elseExpr, 1);
                        int tovElseExpr = tovTracker.get(elseExpr);
                        sb.append(toCode(elseExpr, tovElseExpr));
                        break;
                    case 3:
                    case -3:
                        // QtExprOrFormula
                        List<MASGEdge> downlinksQT = root.getDownlinksAtTimeOfVisit(tov);
                        AugmentedNode QtBody = downlinksQT.get(0).getTarget();
                        for (int i = 1; i < downlinksQT.size(); ++i) {
                            MASGEdge e = downlinksQT.get(i);
                            AugmentedNode QtVar = e.getTarget();
                            tovTracker.putIfAbsent(QtVar, 1);
                            int tovQtVar = tovTracker.get(QtVar);
                            sb.append(toCode(QtVar, tovQtVar));
                            if (i != downlinksQT.size() - 1) {
                                sb.append(", ");
                            }
                        }
                        sb.append(" | ");
                        tovTracker.putIfAbsent(QtBody, 1);
                        int tovQtBody = tovTracker.get(QtBody);
                        sb.append(toCode(QtBody, tovQtBody));
                        break;
                    case 7:
                    case -7:
                        // CallExprOrFormula
                        List<MASGEdge> downlinksCall = root.getDownlinksAtTimeOfVisit(tov);
                        AugmentedNode calledNode = downlinksCall.get(0).getTarget();
                        tovTracker.putIfAbsent(calledNode, 1);
                        int tovCalledNode = tovTracker.get(calledNode);
                        sb.append(toCode(calledNode, tovCalledNode));
                        sb.append("[");
                        for (int i = 1; i < downlinksCall.size(); ++i) {
                            MASGEdge e = downlinksCall.get(i);
                            AugmentedNode callParam = e.getTarget();
                            tovTracker.putIfAbsent(callParam, 1);
                            int tovCallParam = tovTracker.get(callParam);
                            sb.append(toCode(callParam, tovCallParam));
                            if (i != downlinksCall.size() - 1) {
                                sb.append(", ");
                            }
                        }
                        sb.append("]");
                        break;
                    case 4:
                        switch ((int) Math.round(root.getSemantic())) {
                            // ListExpr
                            case 1:
                                sb.append("disjoint [");
                                break;
                            case 2:
                                sb.append("pred/totalorder [");
                                break;
                            default:
                                break;
                        }
                        List<MASGEdge> downlinksList = root.getDownlinksAtTimeOfVisit(tov);
                        for (int i = 0; i < downlinksList.size(); ++i) {
                            MASGEdge e = downlinksList.get(i);
                            AugmentedNode listElem = e.getTarget();
                            tovTracker.putIfAbsent(listElem, 1);
                            int tovListElem = tovTracker.get(listElem);
                            sb.append(toCode(listElem, tovListElem));
                            if (i != downlinksList.size() - 1) {
                                sb.append(", ");
                            }
                        }
                        sb.append("]");
                        break;
                    case -4:
                        // ListFormula
                        String listOp = " && ";
                        switch((int) Math.round(root.getSemantic())) {
                            case 1:
                                listOp = " && ";
                                break;
                            case 2:
                                listOp = " || ";
                                break;
                            default:
                                break;
                        }
                        List<MASGEdge> downlinksListFormula = root.getDownlinksAtTimeOfVisit(tov);
                        for (int i = 0; i < downlinksListFormula.size(); ++i) {
                            MASGEdge e = downlinksListFormula.get(i);
                            AugmentedNode listElemFormula = e.getTarget();
                            tovTracker.putIfAbsent(listElemFormula, 1);
                            int tovListElemFormula = tovTracker.get(listElemFormula);
                            sb.append(toCode(listElemFormula, tovListElemFormula));
                            if (i != downlinksListFormula.size() - 1) {
                                sb.append(listOp);
                            }
                        }
                        break;
                    case 5:
                    case -5:
                        // TODO: BinaryExprOrFormula
                        break;
                    case 6:
                    case -6:
                        // TODO: UnaryExprOrFormula
                        break;
                    default:
                        break;
                }
        }
        sb.append(")");
        return sb.toString();
    }
}
