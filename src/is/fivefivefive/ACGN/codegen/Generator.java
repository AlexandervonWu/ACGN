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
        // TODO: Rewrite to use the labels, not semantic IDs; these IDs are not corresponding. 
        try {
            System.out.println("Generating code for " + root.getSymbol().getName() + " at TOV " + tov);
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
                        sb.append('[');
                        int i = 0;
                        List<MASGEdge> downlinks = root.getDownlinksAtTimeOfVisit(1);
                        for (i = 0; i < downlinks.size() - 1; ++i) {
                            MASGEdge e = root.getDownlinks().get(i);
                            AugmentedNode refSub = e.getTarget();
                            tovTracker.putIfAbsent(refSub, 1);
                            int tovRefSub = tovTracker.get(refSub);
                            sb.append(toCode(refSub, tovRefSub));
                            if (i != root.getDownlinks().size() - 2) {
                                sb.append(", ");
                            }
                        }
                        sb.append(']');
                        sb.append('\n');
                        sb.append('{');
                        AugmentedNode refBody = downlinks.get(i).getTarget();
                        tovTracker.putIfAbsent(refBody, 1);
                        int bodyTov = tovTracker.get(refBody);
                        sb.append(toCode(refBody, bodyTov));
                        sb.append('}');
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
                            if (downlinksRD == null) {
                                return "";
                            }
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
                            switch ((int) Math.round(root.getSemantic())) {
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
                            // BinaryExpr
                            List<MASGEdge> downlinksBin = root.getDownlinksAtTimeOfVisit(tov);
                            AugmentedNode leftExpr = downlinksBin.get(0).getTarget();
                            AugmentedNode rightExpr = downlinksBin.get(1).getTarget();
                            tovTracker.putIfAbsent(leftExpr, 1);
                            int tovLeftExpr = tovTracker.get(leftExpr);
                            tovTracker.putIfAbsent(rightExpr, 1);
                            int tovRightExpr = tovTracker.get(rightExpr);
                            switch ((int) Math.round(root.getSemantic())) {
                                case 1:
                                    // ARROW
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" -> ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 2:
                                    // ANY_ARROW_SOME
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" ->some ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 3:
                                    // ANY_ARROW_ONE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" ->one ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 4:
                                    // ANY_ARROW_LONE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" ->lone ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 5:
                                    // SOME_ARROW_ANY
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" some-> ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 6:
                                    // SOME_ARROW_SOME
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" some->some ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 7:
                                    // SOME_ARROW_ONE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" some->one ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 8:
                                    // SOME_ARROW_LONE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" some->lone ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 9:
                                    // ONE_ARROW_ANY
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" one-> ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 10:
                                    // ONE_ARROW_SOME
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" one->some ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 11:
                                    // ONE_ARROW_ONE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" one->one ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 12:
                                    // ONE_ARROW_LONE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" one->lone ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 13:
                                    // LONE_ARROW_ANY
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" lone-> ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 14:
                                    // LONE_ARROW_SOME
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" lone->some ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 15:
                                    // LONE_ARROW_ONE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" lone->one ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 16:
                                    // LONE_ARROW_LONE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" lone->lone ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 17:
                                    // ISSEQ_ARROW_LONE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" isSeq->lone ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 18:
                                    // JOIN
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(".");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 19:
                                    // DOMAIN
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append("<:");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 20:
                                    // RANGE
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(":>");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 21:
                                    // INTERSECT
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" & ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 22:
                                    // PLUSPLUS
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" ++ ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 23:
                                    // PLUS
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" + ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 24:
                                    // IPLUS
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" @+ ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 25:
                                    // MINUS
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" - ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 26:
                                    // IMINUS
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" @- ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 27:
                                    // MUL
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" * ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 28:
                                    // DIV
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" / ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 29:
                                    // REM
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" % ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 30:
                                    // SHL
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" << ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                case 31:
                                    // SHR
                                    sb.append(toCode(leftExpr, tovLeftExpr));
                                    sb.append(" >> ");
                                    sb.append(toCode(rightExpr, tovRightExpr));
                                    break;
                                default:
                                    break;
                            }
                            break;
                        case -5:
                            // BinaryFormula
                            List<MASGEdge> downlinksBinFormula = root.getDownlinksAtTimeOfVisit(tov);
                            AugmentedNode leftFormula = downlinksBinFormula.get(0).getTarget();
                            AugmentedNode rightFormula = downlinksBinFormula.get(1).getTarget();
                            tovTracker.putIfAbsent(leftFormula, 1);
                            int tovLeftFormula = tovTracker.get(leftFormula);
                            tovTracker.putIfAbsent(rightFormula, 1);
                            int tovRightFormula = tovTracker.get(rightFormula);
                            switch ((int) Math.round(root.getSemantic())) {
                                case 1:
                                    // EQUALS
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" = ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 2:
                                    // NOT_EQUALS
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" != ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 3:
                                    // IMPLIES
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" => ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 4:
                                    // LT
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" < ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 5:
                                    // LTE
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" <= ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 6:
                                    // GT
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" > ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 7:
                                    // GTE
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" >= ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 8:
                                    // NOT_LT
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" !< ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 9:
                                    // NOT_LTE
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" !<= ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 10:
                                    // NOT_GT
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" !> ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 11:
                                    // NOT_GTE
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" !>= ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 12:
                                    // IN
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" in ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 13:
                                    // NOT_IN
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" !in ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 14:
                                    // AND
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" && ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 15:
                                    // OR
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" || ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 16:
                                    // IFF
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" <=> ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 17:
                                    // UNTIL
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" until ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 18:
                                    // RELEASES
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" releases ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 19:
                                    // SINCE
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" since ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                case 20:
                                    // TRIGGERED
                                    sb.append(toCode(leftFormula, tovLeftFormula));
                                    sb.append(" triggered ");
                                    sb.append(toCode(rightFormula, tovRightFormula));
                                    break;
                                default:
                                    break;
                            }
                            break;
                        case 6:
                            // UnaryExpr
                            List<MASGEdge> downlinksUnary = root.getDownlinksAtTimeOfVisit(tov);
                            AugmentedNode unaryExprSub = downlinksUnary.get(0).getTarget();
                            tovTracker.putIfAbsent(unaryExprSub, 1);
                            int tovUnaryExprSub = tovTracker.get(unaryExprSub);
                            switch ((int) Math.round(root.getSemantic())) {
                                case 1:
                                    // SET
                                    sb.append("set ");
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 2:
                                    // lone
                                    sb.append("lone ");
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 3:
                                    // one
                                    sb.append("one ");
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 4:
                                    // some
                                    sb.append("some ");
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 5:
                                    // exactlyof
                                    sb.append("exactly ");
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 6:
                                    // transpose
                                    sb.append('~');
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 7:
                                    // Rclosure
                                    sb.append('*');
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 8:
                                    // closure
                                    sb.append('^');
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 9:
                                    // cardinality
                                    sb.append("#");
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 10:
                                    // cast2int
                                    sb.append("Int->int ");
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 11:
                                    // cast2sigint
                                    sb.append("int->Int ");
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 12:
                                    // prime
                                    sb.append(toCode(unaryExprSub, tovUnaryExprSub));
                                    sb.append("'");
                                    break;
                                default:
                                    break;
                            }
                        case -6:
                            // UnaryFormula
                            List<MASGEdge> downlinksUnaryFormula = root.getDownlinksAtTimeOfVisit(tov);
                            AugmentedNode unaryFormulaSub = downlinksUnaryFormula.get(0).getTarget();
                            tovTracker.putIfAbsent(unaryFormulaSub, 1);
                            int tovUnaryFormulaSub = tovTracker.get(unaryFormulaSub);
                            switch ((int) Math.round(root.getSemantic())) {
                                case 1:
                                    // lone
                                    sb.append("lone ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 2:
                                    // one
                                    sb.append("one ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 3:
                                    // some
                                    sb.append("some ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 4:
                                    // no
                                    sb.append("no ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 5:
                                    // not
                                    sb.append("!");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 6:
                                    // before
                                    sb.append("before ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 7:
                                    // historically
                                    sb.append("historically ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 8:
                                    // once
                                    sb.append("once ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 9:
                                    // always
                                    sb.append("always ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 10:
                                    // eventually
                                    sb.append("eventually ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 11:
                                    // after
                                    sb.append("after ");
                                    sb.append(toCode(unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                default:
                                    break;
                            }
                            break;
                        default:
                            break;
                    }
            }
            sb.append(")");
            return sb.toString();
        } catch (Exception e) {
            System.out.println("Error in generating code for " + root.getSymbol().getName() + " at " + tov);
            e.printStackTrace();
            return "<ERROR>";
        }
    }
}
