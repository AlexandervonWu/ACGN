package is.fivefivefive.ACGN.codegen;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.test.Playground;
import is.fivefivefive.ACGN.util.GlobalVariables;
import parser.etc.Pair;

public class Generator {
    // TODO: The main code generator
    private Map<AugmentedNode, Integer> tovTracker;

    public Generator() {
        tovTracker = new HashMap<AugmentedNode, Integer>();
    }

    public String toCode(Multigraph graph, AugmentedNode root, int tov) {
        // TODO: Rewrite to use the labels, not semantic IDs; these IDs are not corresponding. 
        try {
            System.out.println("Generating code for " + root.getSymbol().getName() + " at TOV " + tov);
            tovTracker.putIfAbsent(root, tov);
            StringBuilder sb = new StringBuilder();
            switch (root.getSymbol().getClass().getSimpleName()) {
                case "AssertSymbol":
                    sb.append("assert ");
                    sb.append(root.getSymbol().getName());
                    // sb.append(root.getDownlinks().get(0).getTarget().toCode(0));
                    AugmentedNode assertBody = root.getDownlinks().get(0).getTarget();
                    tovTracker.putIfAbsent(assertBody, 0);
                    tovTracker.put(assertBody, tovTracker.get(assertBody) + 1);
                    int tovAssertBody = tovTracker.get(assertBody);
                    sb.append(toCode(graph, root.getDownlinks().get(0).getTarget(), tovAssertBody));
                    break;
                case "EndSymbol":
                    return "";
                case "ShadowSymbol":
                    // sb.append(root.getUplinks().get(0).getSource().toCode(tov + 1));
                    AugmentedNode explicit = root.getUplinks().get(0).getSource();
                    tovTracker.putIfAbsent(explicit, 1);
                    int tovExplicit = tovTracker.get(explicit) + 1;
                    tovTracker.putIfAbsent(explicit, tovExplicit);
                    sb.append(toCode(graph, root.getUplinks().get(0).getSource(), tovExplicit));
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
                        sb.append(toCode(graph, letBody, tovLetBody));
                    } else {
                        // references of predicates, functions, etc
                        List<MASGEdge> downlinks = root.getDownlinksAtTimeOfVisit(graph, tov);
                        if (downlinks != null && downlinks.size() > 0) {
                            // This is a predicate definition - add pred keyword, parameters and body
                            sb.append("pred ");
                            sb.append(root.getSymbol().getName());
                            sb.append("[");
                            // Process parameters (if any)
                            if (downlinks.size() > 1) {
                                for (int i = 0; i < downlinks.size() - 1; ++i) {
                                    MASGEdge e = downlinks.get(i);
                                    AugmentedNode param = e.getTarget();
                                    tovTracker.putIfAbsent(param, 0);
                                    tovTracker.put(param, tovTracker.get(param) + 1);
                                    int tovParam = tovTracker.get(param);
                                    if (Playground.DEBUG) {
                                        System.out.println("Processing parameter " + param.getSymbol().getName() + " at TOV " + tovParam);
                                    }
                                    sb.append(toCode(graph, param, tovParam));
                                    if (i < downlinks.size() - 2) {
                                        sb.append(", ");
                                    }
                                }
                            }
                            sb.append("] {\n  ");
                            // Process body
                            AugmentedNode refBody = downlinks.get(downlinks.size() - 1).getTarget();
                            tovTracker.putIfAbsent(refBody, 0);
                            tovTracker.put(refBody, tovTracker.get(refBody) + 1);
                            int bodyTov = tovTracker.get(refBody);
                            sb.append(toCode(graph, refBody, bodyTov));
                            sb.append("\n}");
                        } else {
                            // This is a function/predicate call - just output the name
                            sb.append(root.getSymbol().getName());
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
                                    sb.append("var disj ");
                                    break;
                                default:
                                    break;
                            }
                            List<MASGEdge> downlinksRD = root.getDownlinksAtTimeOfVisit(graph, tov);
                            if (downlinksRD == null) {
                                System.out.println(root.getDownlinkMapTOV());
                                System.out.println("No downlinks for RelDecl at TOV " + tov);
                                return "";
                            }
                            for (int i = 1; i < downlinksRD.size(); ++i) {
                                MASGEdge e = downlinksRD.get(i);
                                AugmentedNode relDecl = e.getTarget();
                                tovTracker.putIfAbsent(relDecl, 0);
                                tovTracker.put(relDecl, tovTracker.get(relDecl) + 1);
                                int tovRelDecl = tovTracker.get(relDecl);
                                sb.append(toCode(graph, relDecl, tovRelDecl));
                                if (i < downlinksRD.size() - 2) {
                                    sb.append(", ");
                                }
                            }
                            sb.append(" : ");
                            AugmentedNode relDeclBody = downlinksRD.get(0).getTarget();
                            tovTracker.putIfAbsent(relDeclBody, 0);
                            tovTracker.put(relDeclBody, tovTracker.get(relDeclBody) + 1);
                            int tovRelDeclBody = tovTracker.get(relDeclBody);
                            sb.append(toCode(graph, relDeclBody, tovRelDeclBody));
                            break;
                        case 2:
                        case -2:
                            // ITEExprOrFormula
                            List<MASGEdge> downlinksITE = root.getDownlinksAtTimeOfVisit(graph, tov);
                            AugmentedNode ifExpr = downlinksITE.get(0).getTarget();
                            AugmentedNode thenExpr = downlinksITE.get(1).getTarget();
                            AugmentedNode elseExpr = downlinksITE.get(2).getTarget();
                            tovTracker.putIfAbsent(ifExpr, 0);
                            tovTracker.put(ifExpr, tovTracker.get(ifExpr) + 1);
                            int tovIfExpr = tovTracker.get(ifExpr);
                            sb.append(toCode(graph, ifExpr, tovIfExpr));
                            sb.append(" => ");
                            tovTracker.putIfAbsent(thenExpr, 0);
                            tovTracker.put(thenExpr, tovTracker.get(thenExpr) + 1);
                            int tovThenExpr = tovTracker.get(thenExpr);
                            sb.append(toCode(graph, thenExpr, tovThenExpr));
                            sb.append(" else ");
                            tovTracker.putIfAbsent(elseExpr, 0);
                            tovTracker.put(elseExpr, tovTracker.get(elseExpr) + 1);
                            int tovElseExpr = tovTracker.get(elseExpr);
                            sb.append(toCode(graph, elseExpr, tovElseExpr));
                            break;
                        case 3:
                        case -3:
                            // QtExprOrFormula
                            List<MASGEdge> downlinksQT = root.getDownlinksAtTimeOfVisit(graph, tov);
                            if (root.getSyntactic() == 3) {
                                switch ((int) Math.round(root.getSemantic())) {
                                    case 1:
                                        // summation
                                        sb.append("all ");
                                        break;
                                    case 2:
                                        // comprehension
                                        sb.append("some ");
                                        break;
                                    default:
                                        break;
                                }
                            } else {
                                switch ((int) Math.round(root.getSemantic())) {
                                    case 1:
                                        // all
                                        sb.append("all ");
                                        break;
                                    case 2:
                                        // some
                                        sb.append("some ");
                                        break;
                                    case 3:
                                        // no
                                        sb.append("no ");
                                        break;
                                    case 4:
                                        // lone
                                        sb.append("lone ");
                                        break;
                                    case 5:
                                        // one
                                        sb.append("one ");
                                        break;
                                    default:
                                        break;
                                }
                            }
                            int iter = 0;
                            for (iter = 0; iter < downlinksQT.size() - 1; ++iter) {
                                MASGEdge e = downlinksQT.get(iter);
                                AugmentedNode QtVar = e.getTarget();
                                tovTracker.putIfAbsent(QtVar, 0);
                                tovTracker.put(QtVar, tovTracker.get(QtVar) + 1);
                                int tovQtVar = tovTracker.get(QtVar);
                                sb.append(toCode(graph, QtVar, tovQtVar));
                                if (iter < downlinksQT.size() - 3) {
                                    sb.append(", ");
                                }
                            }
                            AugmentedNode QtBody = downlinksQT.get(iter).getTarget();
                            sb.append(" |\n ");
                            tovTracker.putIfAbsent(QtBody, 0);
                            tovTracker.put(QtBody, tovTracker.get(QtBody) + 1);
                            int tovQtBody = tovTracker.get(QtBody);
                            sb.append(toCode(graph, QtBody, tovQtBody));
                            break;
                        case 7:
                        case -7:
                            // CallExprOrFormula
                            List<MASGEdge> downlinksCall = root.getDownlinksAtTimeOfVisit(graph, tov);
                            AugmentedNode calledNode = downlinksCall.get(0).getTarget();
                            tovTracker.putIfAbsent(calledNode, 0);
                            tovTracker.put(calledNode, tovTracker.get(calledNode) + 1);
                            int tovCalledNode = tovTracker.get(calledNode);
                            sb.append(toCode(graph, calledNode, tovCalledNode));
                            sb.append("[");
                            for (int i = 1; i < downlinksCall.size(); ++i) {
                                MASGEdge e = downlinksCall.get(i);
                                AugmentedNode callParam = e.getTarget();
                                tovTracker.putIfAbsent(callParam, 0);
                                tovTracker.put(callParam, tovTracker.get(callParam) + 1);
                                int tovCallParam = tovTracker.get(callParam);
                                sb.append(toCode(graph, callParam, tovCallParam));
                                if (i < downlinksCall.size() - 2) {
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
                            List<MASGEdge> downlinksList = root.getDownlinksAtTimeOfVisit(graph, tov);
                            for (int i = 0; i < downlinksList.size(); ++i) {
                                MASGEdge e = downlinksList.get(i);
                                AugmentedNode listElem = e.getTarget();
                                tovTracker.putIfAbsent(listElem, 0);
                                tovTracker.put(listElem, tovTracker.get(listElem) + 1);
                                int tovListElem = tovTracker.get(listElem);
                                sb.append(toCode(graph, listElem, tovListElem));
                                if (i < downlinksList.size() - 2) {
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
                            List<MASGEdge> downlinksListFormula = root.getDownlinksAtTimeOfVisit(graph, tov);
                            for (int i = 0; i < downlinksListFormula.size(); ++i) {
                                MASGEdge e = downlinksListFormula.get(i);
                                AugmentedNode listElemFormula = e.getTarget();
                                tovTracker.putIfAbsent(listElemFormula, 0);
                                tovTracker.put(listElemFormula, tovTracker.get(listElemFormula) + 1);
                                int tovListElemFormula = tovTracker.get(listElemFormula);
                                sb.append(toCode(graph, listElemFormula, tovListElemFormula));
                                if (i < downlinksListFormula.size() - 2) {
                                    sb.append(listOp);
                                }
                            }
                            break;
                        case 5:
                            // BinaryExpr
                            List<MASGEdge> downlinksBin = root.getDownlinksAtTimeOfVisit(graph, tov);
                            AugmentedNode leftExpr = downlinksBin.get(0).getTarget();
                            AugmentedNode rightExpr = downlinksBin.get(1).getTarget();
                            tovTracker.putIfAbsent(leftExpr, 0);
                            tovTracker.put(leftExpr, tovTracker.get(leftExpr) + 1);
                            int tovLeftExpr = tovTracker.get(leftExpr);
                            tovTracker.putIfAbsent(rightExpr, 0);
                            tovTracker.put(rightExpr, tovTracker.get(rightExpr) + 1);
                            int tovRightExpr = tovTracker.get(rightExpr);
                            switch ((int) Math.round(root.getSemantic())) {
                                case 1:
                                    // ARROW
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" -> ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 2:
                                    // ANY_ARROW_SOME
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" ->some ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 3:
                                    // ANY_ARROW_ONE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" ->one ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 4:
                                    // ANY_ARROW_LONE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" ->lone ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 5:
                                    // SOME_ARROW_ANY
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" some-> ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 6:
                                    // SOME_ARROW_SOME
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" some->some ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 7:
                                    // SOME_ARROW_ONE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" some->one ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 8:
                                    // SOME_ARROW_LONE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" some->lone ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 9:
                                    // ONE_ARROW_ANY
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" one-> ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 10:
                                    // ONE_ARROW_SOME
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" one->some ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 11:
                                    // ONE_ARROW_ONE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" one->one ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 12:
                                    // ONE_ARROW_LONE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" one->lone ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 13:
                                    // LONE_ARROW_ANY
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" lone-> ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 14:
                                    // LONE_ARROW_SOME
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" lone->some ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 15:
                                    // LONE_ARROW_ONE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" lone->one ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 16:
                                    // LONE_ARROW_LONE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" lone->lone ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 17:
                                    // ISSEQ_ARROW_LONE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" isSeq->lone ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 18:
                                    // JOIN
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(".");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 19:
                                    // DOMAIN
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append("<:");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 20:
                                    // RANGE
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(":>");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 21:
                                    // INTERSECT
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" & ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 22:
                                    // PLUSPLUS
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" ++ ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 23:
                                    // PLUS
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" + ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 24:
                                    // IPLUS
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" @+ ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 25:
                                    // MINUS
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" - ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 26:
                                    // IMINUS
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" @- ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 27:
                                    // MUL
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" * ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 28:
                                    // DIV
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" / ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 29:
                                    // REM
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" % ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 30:
                                    // SHL
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" << ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 31:
                                    // SHA
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" >> ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                case 32:
                                    // SHR
                                    sb.append(toCode(graph, leftExpr, tovLeftExpr));
                                    sb.append(" >>> ");
                                    sb.append(toCode(graph, rightExpr, tovRightExpr));
                                    break;
                                default:
                                    break;
                            }
                            break;
                        case -5:
                            // BinaryFormula
                            List<MASGEdge> downlinksBinFormula = root.getDownlinksAtTimeOfVisit(graph, tov);
                            AugmentedNode leftFormula = downlinksBinFormula.get(0).getTarget();
                            AugmentedNode rightFormula = downlinksBinFormula.get(1).getTarget();
                            tovTracker.putIfAbsent(leftFormula, 0);
                            tovTracker.put(leftFormula, tovTracker.get(leftFormula) + 1);
                            int tovLeftFormula = tovTracker.get(leftFormula);
                            tovTracker.putIfAbsent(rightFormula, 0);
                            tovTracker.put(rightFormula, tovTracker.get(rightFormula) + 1);
                            int tovRightFormula = tovTracker.get(rightFormula);
                            switch ((int) Math.round(root.getSemantic())) {
                                case 1:
                                    // EQUALS
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" = ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 2:
                                    // NOT_EQUALS
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" != ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 3:
                                    // AND
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" && ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 4:
                                    // GT
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" > ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 5:
                                    // GTE
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" >= ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 6:
                                    // IFF
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" <=> ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 7:
                                    // IMPLIES
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" => ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 8:
                                    // IN
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" in ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 9:
                                    // LT
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" < ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 10:
                                    // LTE
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" <= ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 11:
                                    // NOT_GT
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" !> ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 12:
                                    // NOT_GTE
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" !>= ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 13:
                                    // NOT_IN
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" !in ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 14:
                                    // NOT_LT
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" !< ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 15:
                                    // NOT_LTE
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" !<= ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 16:
                                    // OR
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" || ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 17:
                                    // RELEASES
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" releases ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 18:
                                    // SINCE
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" since ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 19:
                                    // TRIGGERED
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" triggered ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                case 20:
                                    // UNTIL
                                    sb.append(toCode(graph, leftFormula, tovLeftFormula));
                                    sb.append(" until ");
                                    sb.append(toCode(graph, rightFormula, tovRightFormula));
                                    break;
                                default:
                                    break;
                            }
                            break;
                        case 6:
                            // UnaryExpr
                            List<MASGEdge> downlinksUnary = root.getDownlinksAtTimeOfVisit(graph, tov);
                            AugmentedNode unaryExprSub = downlinksUnary.get(0).getTarget();
                            tovTracker.putIfAbsent(unaryExprSub, 0);
                            tovTracker.put(unaryExprSub, tovTracker.get(unaryExprSub) + 1);
                            int tovUnaryExprSub = tovTracker.get(unaryExprSub);
                            switch ((int) Math.round(root.getSemantic())) {
                                case 1:
                                    // SET
                                    sb.append("set ");
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 2:
                                    // lone
                                    sb.append("lone ");
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 3:
                                    // one
                                    sb.append("one ");
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 4:
                                    // some
                                    sb.append("some ");
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 5:
                                    // exactlyof
                                    sb.append("exactly ");
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 6:
                                    // transpose
                                    sb.append('~');
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 7:
                                    // Rclosure
                                    sb.append('*');
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 8:
                                    // closure
                                    sb.append('^');
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 9:
                                    // cardinality
                                    sb.append("#");
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 10:
                                    // cast2int
                                    sb.append("Int->int ");
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 11:
                                    // cast2sigint
                                    sb.append("int->Int ");
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    break;
                                case 12:
                                    // prime
                                    sb.append(toCode(graph, unaryExprSub, tovUnaryExprSub));
                                    sb.append("\'");
                                    break;
                                default:
                                    break;
                            }
                            break;
                        case -6:
                            // UnaryFormula
                            List<MASGEdge> downlinksUnaryFormula = root.getDownlinksAtTimeOfVisit(graph, tov);
                            AugmentedNode unaryFormulaSub = downlinksUnaryFormula.get(0).getTarget();
                            tovTracker.putIfAbsent(unaryFormulaSub, 0);
                            tovTracker.put(unaryFormulaSub, tovTracker.get(unaryFormulaSub) + 1);
                            int tovUnaryFormulaSub = tovTracker.get(unaryFormulaSub);
                            switch ((int) Math.round(root.getSemantic())) {
                                case 1:
                                    // lone
                                    sb.append("lone ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 2:
                                    // one
                                    sb.append("one ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 3:
                                    // some
                                    sb.append("some ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 4:
                                    // no
                                    sb.append("no ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 5:
                                    // not
                                    sb.append("!");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 6:
                                    // before
                                    sb.append("before ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 7:
                                    // historically
                                    sb.append("historically ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 8:
                                    // once
                                    sb.append("once ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 9:
                                    // always
                                    sb.append("always ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 10:
                                    // eventually
                                    sb.append("eventually ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                case 11:
                                    // after
                                    sb.append("after ");
                                    sb.append(toCode(graph, unaryFormulaSub, tovUnaryFormulaSub));
                                    break;
                                default:
                                    break;
                            }
                            break;
                        case -128:
                            // handle the shadow
                        default:
                            break;
                    }
                    break;
                default:
                    break;
            }
            return sb.toString();
        } catch (Exception e) {
            System.out.println("Error in generating code for " + root.getSymbol().getName() + " at " + tov);
            e.printStackTrace();
            return "<ERROR>";
        }
    }
}
