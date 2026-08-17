package is.fivefivefive.CanDis.ir;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.Set;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.core.QuantiVar;
import is.fivefivefive.CanDis.core.EGraphNode.Metatype;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.core.NormalForm.TemporalOp;

public class IRAgent {
    @FunctionalInterface
    public interface DiagnosticsObserver {
        void onStage(String stage, NormalForm activeNormalForm, List<NormalForm> normalForms);
    }

    private static final DiagnosticsObserver NO_OBSERVER = (stage, active, normalForms) -> { };

    private Multigraph graph;
    
    private List<NormalForm> nfs; // the normal forms from the graph in temporal logical operators order; 
    // try to normalize as much as possible from MASG to the normal form. Try prenexing. 

    public IRAgent(Multigraph graph) {
        this.graph = graph;
        this.nfs = new ArrayList<>();
    }

    public List<NormalForm> normalForms() {
        return nfs;
    }

    public void computeNormalForm() {
        computeNormalForm(NO_OBSERVER);
    }

    public void computeNormalForm(DiagnosticsObserver observer) {
        DiagnosticsObserver stages = observer == null ? NO_OBSERVER : observer;
        nfs.clear();
        AugmentedNode root = graph.getRoot();
        if (root == null) {
            return;
        }
        EGraphNode.beginGraph();
        try {
            NormalForm rootNf = new NormalForm();
            nfs.add(rootNf);
            Map<AugmentedNode, Integer> tovTracker = new HashMap<>();
            int[] nextId = new int[] { 0 };
            stages.onStage("begin-temporal-skeleton", rootNf, nfs);
            rootNf.addEClass(buildEGraph(root, nextTov(tovTracker, root), rootNf, tovTracker, nextId, new HashSet<>()));
            stages.onStage("temporal-skeleton", rootNf, nfs);
            normalizeTemporalTree(rootNf, new HashMap<>(), new int[] { 0 }, stages);
        } finally {
            stages.onStage("begin-reachable-egraph", null, nfs);
            List<EGraphNode> roots = new ArrayList<>();
            for (NormalForm normalForm : nfs) {
                if (normalForm.getMatrixEGraph() != null) {
                    roots.add(normalForm.getMatrixEGraph());
                }
            }
            EGraphNode.retainReachable(roots);
            stages.onStage("reachable-egraph", null, nfs);
            EGraphNode.endGraph();
        }
    }

    private EGraphNode buildEGraph(
            AugmentedNode node,
            int tov,
            NormalForm nf,
            Map<AugmentedNode, Integer> tovTracker,
            int[] nextId,
            Set<String> activePath) {
        Opcode opcode = opcodeOf(node);
        String activeKey = node.hashCode() + "@" + tov;
        List<MASGEdge> downlinks = downlinksFor(node, tov, opcode);
        EGraphNode current = new EGraphNode(nextId[0]++, opcode, new ArrayList<>(), isCommutative(opcode), maxArity(opcode), isFlexibleArity(opcode), metatypeOf(node, opcode));
        attachSourceMetadata(current, node);

        if (!activePath.add(activeKey)) {
            return current;
        }
        try {
        if (downlinks == null || downlinks.isEmpty()) {
            return current;
        }

        TemporalOp[] temporalOps = temporalOpsOf(node);
        if (temporalOps != null && downlinks.size() >= 2) {
            int temporalIndex = nf.getTemporalChildren().size();
            NormalForm leftNf = new NormalForm(nf, temporalOps[0], nextId[0]++);
            NormalForm rightNf = new NormalForm(nf, temporalOps[1], nextId[0]++);
            nf.addTemporalChild(leftNf);
            nf.addTemporalChild(rightNf);
            nfs.add(leftNf);
            nfs.add(rightNf);
            addTemporalChild(leftNf, downlinks.get(0).getTarget(), tovTracker, nextId, activePath);
            addTemporalChild(rightNf, downlinks.get(1).getTarget(), tovTracker, nextId, activePath);
            return temporalReference(current, temporalIndex, 2);
        }
        TemporalOp unaryTemporalOp = unaryTemporalOpOf(opcode);
        if (unaryTemporalOp != null && !downlinks.isEmpty()) {
            int temporalIndex = nf.getTemporalChildren().size();
            NormalForm temporalNf = new NormalForm(nf, unaryTemporalOp, nextId[0]++);
            nf.addTemporalChild(temporalNf);
            nfs.add(temporalNf);
            addTemporalChild(temporalNf, downlinks.get(0).getTarget(), tovTracker, nextId, activePath);
            return temporalReference(current, temporalIndex, 1);
        }

        for (MASGEdge downlink : downlinks) {
            AugmentedNode child = downlink.getTarget();
            current.addChild(buildEGraph(child, nextTov(tovTracker, child), nf, tovTracker, nextId, activePath));
        }
        return current;
        } finally {
            activePath.remove(activeKey);
        }
    }

    private void normalizeTemporalTree(
            NormalForm normalForm,
            Map<String, QuantiVar> inherited,
            int[] nextVarId,
            DiagnosticsObserver observer) {
        normalForm.normalize(inherited, nextVarId,
                (stage, active) -> observer.onStage(stage, active, nfs));
        observer.onStage("begin-temporal-negation", normalForm, nfs);
        normalForm.pushTemporalNegations();
        observer.onStage("temporal-negation", normalForm, nfs);
        Map<String, QuantiVar> descendants = new HashMap<>(inherited);
        for (QuantiVar variable : normalForm.getParams()) {
            for (String alias : variable.getOriginalNames()) {
                descendants.put(alias, variable);
            }
        }
        for (QuantiVar variable : normalForm.getMatrixQuantiVars()) {
            for (String alias : variable.getOriginalNames()) {
                descendants.put(alias, variable);
            }
        }
        for (NormalForm child : normalForm.getTemporalChildren()) {
            normalizeTemporalTree(child, descendants, nextVarId, observer);
        }
    }

    private static EGraphNode temporalReference(EGraphNode source, int childIndex, int arity) {
        EGraphNode reference = new EGraphNode(
                source.getId(), Opcode.REF, new ArrayList<>(), false, 0, false, Metatype.BOOLEAN);
        reference.setSourceName("temporal[" + childIndex + ":" + arity + "]");
        reference.setSourceType("Bool");
        return reference;
    }

    private List<MASGEdge> downlinksFor(AugmentedNode node, int tov, Opcode opcode) {
        int maxTov = graph.getTimeOfVisitMap().getOrDefault(node, tov);
        if (tov > maxTov) {
            return null;
        }
        List<MASGEdge> downlinks = node.getDownlinksAtTimeOfVisit(graph, tov);
        int expected = expectedDownlinkCount(opcode);
        if (isQuantifierOpcode(opcode) && hasQuantifierBodyEdge(downlinks)) {
            return downlinks;
        }
        if (isQuantifierOpcode(opcode)) {
            List<MASGEdge> candidate = nearestQuantifierVisitWithBody(node, tov, maxTov);
            if (candidate != null) {
                return candidate;
            }
            return downlinks;
        }
        if (expected <= 0 || (downlinks != null && downlinks.size() >= expected)) {
            return downlinks;
        }
        for (int candidateTov = Math.max(1, tov); candidateTov <= maxTov; candidateTov++) {
            List<MASGEdge> candidate = node.getDownlinksAtTimeOfVisit(graph, candidateTov);
            if (candidate != null && candidate.size() >= expected) {
                return candidate;
            }
        }
        for (int candidateTov = Math.min(tov - 1, maxTov); candidateTov >= 1; candidateTov--) {
            List<MASGEdge> candidate = node.getDownlinksAtTimeOfVisit(graph, candidateTov);
            if (candidate != null && candidate.size() >= expected) {
                return candidate;
            }
        }
        return downlinks;
    }

    private List<MASGEdge> nearestQuantifierVisitWithBody(AugmentedNode node, int tov, int maxTov) {
        List<MASGEdge> best = null;
        int bestScore = -1;
        int bestDistance = Integer.MAX_VALUE;
        for (int candidateTov = 1; candidateTov <= maxTov; candidateTov++) {
            List<MASGEdge> candidate = node.getDownlinksAtTimeOfVisit(graph, candidateTov);
            int score = quantifierBodyScore(candidate);
            if (score <= 0) {
                continue;
            }
            int distance = Math.abs(candidateTov - tov);
            if (score > bestScore || (score == bestScore && distance < bestDistance)) {
                best = candidate;
                bestScore = score;
                bestDistance = distance;
            }
        }
        return best;
    }

    private static boolean hasQuantifierBodyEdge(List<MASGEdge> downlinks) {
        return quantifierBodyScore(downlinks) > 0;
    }

    private static int quantifierBodyScore(List<MASGEdge> downlinks) {
        if (downlinks == null) {
            return 0;
        }
        int score = 0;
        for (MASGEdge edge : downlinks) {
            Opcode childOpcode = opcodeOf(edge.getTarget());
            if (childOpcode != Opcode.END && !isRelDeclOpcode(childOpcode)) {
                score = Math.max(score, quantifierBodyOpcodeScore(childOpcode));
            }
        }
        return score;
    }

    private static int quantifierBodyOpcodeScore(Opcode opcode) {
        switch (opcode) {
            case IMPLIES:
            case IFF:
            case AND:
            case OR:
            case FORALL:
            case EXISTS:
            case NO:
            case ONE:
            case LONE:
                return 4;
            case NOT:
            case SOME:
            case IN:
            case NOT_IN:
            case EQUALS:
            case NOT_EQUALS:
            case GT:
            case GTE:
            case LT:
            case LTE:
                return 2;
            default:
                return 1;
        }
    }

    private static boolean isQuantifierOpcode(Opcode opcode) {
        return opcode == Opcode.FORALL || opcode == Opcode.EXISTS || opcode == Opcode.NO
                || opcode == Opcode.LONE || opcode == Opcode.ONE || opcode == Opcode.SUM
                || opcode == Opcode.COMPREHENSION;
    }

    private static int expectedDownlinkCount(Opcode opcode) {
        if (opcode == Opcode.ITE) {
            return 3;
        }
        if (isFormulaBinary(opcode)) {
            return 2;
        }
        return -1;
    }

    private static void attachSourceMetadata(EGraphNode eGraphNode, AugmentedNode sourceNode) {
        Symbol symbol = sourceNode.getSymbol();
        if (symbol == null) {
            return;
        }
        eGraphNode.setSourceName(symbol.getName());
        eGraphNode.setSourceType(symbol.getType());
        if (eGraphNode.getOpcode() == Opcode.VARIABLE) {
            eGraphNode.setAlphaName(symbol.getName());
        }
    }

    private void addTemporalChild(
            NormalForm nf,
            AugmentedNode child,
            Map<AugmentedNode, Integer> tovTracker,
            int[] nextId,
            Set<String> activePath) {
        nf.getMatrixEGraph().addChild(buildEGraph(child, nextTov(tovTracker, child), nf, tovTracker, nextId, activePath));
    }

    private static int nextTov(Map<AugmentedNode, Integer> tovTracker, AugmentedNode node) {
        int tov = tovTracker.getOrDefault(node, 0) + 1;
        tovTracker.put(node, tov);
        return tov;
    }

    private static Opcode opcodeOf(AugmentedNode node) {
        Symbol symbol = node.getSymbol();
        if (symbol != null) {
            switch (symbol.getClass().getSimpleName()) {
                case "AssertSymbol":
                    return Opcode.ASSERTION;
                case "CheckSymbol":
                    return Opcode.CHECK;
                case "RunSymbol":
                    return Opcode.RUN;
                case "FactSymbol":
                case "ExtFact":
                    return Opcode.FACT;
                case "LetSymbol":
                    return Opcode.LET;
                case "PredRootSymbol":
                    return Opcode.PREDICATE;
                case "FunRootSymbol":
                    return Opcode.FUNCTION;
                case "SigSymbol":
                case "FieldRelation":
                case "SubsetRelation":
                    return Opcode.GLOBALBINDING;
                case "VarSymbol":
                    return Opcode.VARIABLE;
                case "ConstSymbol":
                    return Opcode.CONSTANT;
                case "DummySymbol":
                    return Opcode.DUMMY;
                case "RefSymbol":
                    return Opcode.REF;
                case "ShadowSymbol":
                    return Opcode.SHADOW;
                case "EndSymbol":
                    return Opcode.END;
                case "DeclRootSymbol":
                    return relDeclOpcode(node);
                default:
                    break;
            }
        }

        if (node.getSyntactic() == -127) {
            return relDeclOpcode(node);
        }

        if (node.getSyntactic() == 2 || node.getSyntactic() == -2) {
            return Opcode.ITE;
        }

        if (node.getSyntactic() == 3) {
            switch ((int) Math.round(node.getSemantic())) {
                case 1:
                    return Opcode.SUM;
                case 2:
                    return Opcode.COMPREHENSION;
                default:
                    return Opcode.COMPREHENSION;
            }
        }

        if (node.getSyntactic() == -3) {
            switch ((int) Math.round(node.getSemantic())) {
                case 1:
                    return Opcode.FORALL;
                case 2:
                    return Opcode.EXISTS;
                case 3:
                    return Opcode.NO;
                case 4:
                    return Opcode.LONE;
                case 5:
                    return Opcode.ONE;
                default:
                    return Opcode.FORALL;
            }
        }

        if (node.getSyntactic() == 7 || node.getSyntactic() == -7) {
            return Opcode.CALL;
        }

        if (node.getSyntactic() == 4) {
            switch ((int) Math.round(node.getSemantic())) {
                case 1:
                    return Opcode.DISJOINT_LIST;
                case 2:
                    return Opcode.TOTALORDER_LIST;
                default:
                    return Opcode.LIST;
            }
        }

        if (node.getSyntactic() == -4) {
            return ((int) Math.round(node.getSemantic())) == 2 ? Opcode.OR : Opcode.AND;
        }

        if (node.getSyntactic() == 5 || node.getSyntactic() == 15) {
            return binaryExprOpcode(node);
        }

        if (node.getSyntactic() == -5) {
            return binaryFormulaOpcode(node);
        }

        if (node.getSyntactic() == 6 || node.getSyntactic() == 16) {
            return unaryExprOpcode(node);
        }

        if (node.getSyntactic() == -6) {
            return unaryFormulaOpcode(node);
        }

        if (node.getSyntactic() == -128) {
            return Opcode.SHADOW;
        }

        return Opcode.PREDICATE;
    }

    private static Opcode relDeclOpcode(AugmentedNode node) {
        switch ((int) Math.round(node.getSemantic())) {
            case 1:
                return Opcode.DISJ;
            case 2:
                return Opcode.VAR;
            case 3:
                return Opcode.DISJVAR;
            default:
                return Opcode.GENERICRELDECL;
        }
    }

    private static Opcode binaryFormulaOpcode(AugmentedNode node) {
        switch ((int) Math.round(node.getSemantic())) {
            case 1:
                return Opcode.EQUALS;
            case 2:
                return Opcode.NOT_EQUALS;
            case 3:
                return Opcode.AND;
            case 4:
                return Opcode.GT;
            case 5:
                return Opcode.GTE;
            case 6:
                return Opcode.IFF;
            case 7:
                return Opcode.IMPLIES;
            case 8:
                return Opcode.IN;
            case 9:
                return Opcode.LT;
            case 10:
                return Opcode.LTE;
            case 11:
                return Opcode.NOT_GT;
            case 12:
                return Opcode.NOT_GTE;
            case 13:
                return Opcode.NOT_IN;
            case 14:
                return Opcode.NOT_LT;
            case 15:
                return Opcode.NOT_LTE;
            case 16:
                return Opcode.OR;
            case 17:
                return Opcode.RELEASES;
            case 18:
                return Opcode.SINCE;
            case 19:
                return Opcode.TRIGGERED;
            case 20:
                return Opcode.UNTIL;
            default:
                return Opcode.PREDICATE;
        }
    }

    private static Opcode binaryExprOpcode(AugmentedNode node) {
        switch ((int) Math.round(node.getSemantic())) {
            case 1:
                return Opcode.ARROW;
            case 2:
                return Opcode.ANY_ARROW_SOME;
            case 3:
                return Opcode.ANY_ARROW_ONE;
            case 4:
                return Opcode.ANY_ARROW_LONE;
            case 5:
                return Opcode.SOME_ARROW_ANY;
            case 6:
                return Opcode.SOME_ARROW_SOME;
            case 7:
                return Opcode.SOME_ARROW_ONE;
            case 8:
                return Opcode.SOME_ARROW_LONE;
            case 9:
                return Opcode.ONE_ARROW_ANY;
            case 10:
                return Opcode.ONE_ARROW_SOME;
            case 11:
                return Opcode.ONE_ARROW_ONE;
            case 12:
                return Opcode.ONE_ARROW_LONE;
            case 13:
                return Opcode.LONE_ARROW_ANY;
            case 14:
                return Opcode.LONE_ARROW_SOME;
            case 15:
                return Opcode.LONE_ARROW_ONE;
            case 16:
                return Opcode.LONE_ARROW_LONE;
            case 17:
                return Opcode.ISSEQ_ARROW_LONE;
            case 18:
                return Opcode.JOIN;
            case 19:
                return Opcode.DOMAIN;
            case 20:
                return Opcode.RANGE;
            case 21:
                return Opcode.INTERSECT;
            case 22:
                return Opcode.PLUSPLUS;
            case 23:
                return Opcode.PLUS;
            case 24:
                return Opcode.IPLUS;
            case 25:
                return Opcode.MINUS;
            case 26:
                return Opcode.IMINUS;
            case 27:
                return Opcode.MUL;
            case 28:
                return Opcode.DIV;
            case 29:
                return Opcode.REM;
            case 30:
                return Opcode.SHL;
            case 31:
                return Opcode.SHA;
            case 32:
                return Opcode.SHR;
            default:
                return Opcode.FUNCTION;
        }
    }

    private static Opcode unaryExprOpcode(AugmentedNode node) {
        switch ((int) Math.round(node.getSemantic())) {
            case 1:
                return Opcode.SETOF;
            case 2:
                return Opcode.LONE;
            case 3:
                return Opcode.ONE;
            case 4:
                return Opcode.SOME;
            case 5:
                return Opcode.EXACTLY;
            case 6:
                return Opcode.TRANSPOSE;
            case 7:
                return Opcode.RCLOSURE;
            case 8:
                return Opcode.CLOSURE;
            case 9:
                return Opcode.CARDINALITY;
            case 10:
                return Opcode.CAST2INT;
            case 11:
                return Opcode.CAST2SIGINT;
            case 12:
                return Opcode.PRIME;
            default:
                return Opcode.FUNCTION;
        }
    }

    private static Opcode unaryFormulaOpcode(AugmentedNode node) {
        switch ((int) Math.round(node.getSemantic())) {
            case 1:
                return Opcode.LONE;
            case 2:
                return Opcode.ONE;
            case 3:
                return Opcode.SOME;
            case 4:
                return Opcode.NO;
            case 5:
                return Opcode.NOT;
            case 6:
                return Opcode.BEFORE;
            case 7:
                return Opcode.HISTORICALLY;
            case 8:
                return Opcode.ONCE;
            case 9:
                return Opcode.ALWAYS;
            case 10:
                return Opcode.EVENTUALLY;
            case 11:
                return Opcode.AFTER;
            default:
                return Opcode.PREDICATE;
        }
    }

    private static TemporalOp[] temporalOpsOf(AugmentedNode node) {
        if (node.getSyntactic() != -5) {
            return null;
        }
        switch ((int) Math.round(node.getSemantic())) {
            case 17:
                return new TemporalOp[] { TemporalOp.RELEASESL, TemporalOp.RELEASESR };
            case 18:
                return new TemporalOp[] { TemporalOp.SINCEL, TemporalOp.SINCER };
            case 19:
                return new TemporalOp[] { TemporalOp.TRIGGEREDL, TemporalOp.TRIGGEREDR };
            case 20:
                return new TemporalOp[] { TemporalOp.UNTILL, TemporalOp.UNTILR };
            default:
                return null;
        }
    }

    private static TemporalOp unaryTemporalOpOf(Opcode opcode) {
        switch (opcode) {
            case BEFORE:
                return TemporalOp.BEFORE;
            case HISTORICALLY:
                return TemporalOp.HISTORICALLY;
            case ONCE:
                return TemporalOp.ONCE;
            case ALWAYS:
                return TemporalOp.ALWAYS;
            case EVENTUALLY:
                return TemporalOp.EVENTUALLY;
            case AFTER:
                return TemporalOp.AFTER;
            default:
                return null;
        }
    }

    private static boolean isCommutative(Opcode opcode) {
        return opcode == Opcode.AND || opcode == Opcode.OR || opcode == Opcode.IFF
                || opcode == Opcode.EQUALS || opcode == Opcode.NOT_EQUALS
                || opcode == Opcode.INTERSECT || opcode == Opcode.PLUS || opcode == Opcode.MUL
                || opcode == Opcode.IPLUS
                || isRelDeclOpcode(opcode);
    }

    private static int maxArity(Opcode opcode) {
        if (isFlexibleArity(opcode)) {
            return -1;
        }
        if (isUnary(opcode)) {
            return 1;
        }
        if (opcode == Opcode.ITE) {
            return 3;
        }
        return 2;
    }

    private static boolean isFlexibleArity(Opcode opcode) {
        return isAssociative(opcode) || opcode == Opcode.CALL || opcode == Opcode.LIST
                || opcode == Opcode.DISJOINT_LIST || opcode == Opcode.TOTALORDER_LIST
                || opcode == Opcode.FORALL || opcode == Opcode.EXISTS || opcode == Opcode.NO
                || opcode == Opcode.LONE || opcode == Opcode.ONE || opcode == Opcode.COMPREHENSION
                || opcode == Opcode.SUM
                || isRelDeclOpcode(opcode);
    }

    private static boolean isAssociative(Opcode opcode) {
        return opcode == Opcode.AND || opcode == Opcode.OR
                || opcode == Opcode.INTERSECT || opcode == Opcode.PLUS || opcode == Opcode.MUL
                || opcode == Opcode.IPLUS || opcode == Opcode.JOIN || opcode == Opcode.ARROW;
    }

    private static boolean isUnary(Opcode opcode) {
        return opcode == Opcode.NOT || opcode == Opcode.SOME || opcode == Opcode.NO || opcode == Opcode.LONE
                || opcode == Opcode.ONE || opcode == Opcode.SETOF || opcode == Opcode.EXACTLY
                || opcode == Opcode.TRANSPOSE || opcode == Opcode.RCLOSURE || opcode == Opcode.CLOSURE
                || opcode == Opcode.CARDINALITY || opcode == Opcode.CAST2INT || opcode == Opcode.CAST2SIGINT
                || opcode == Opcode.PRIME || opcode == Opcode.BEFORE || opcode == Opcode.HISTORICALLY
                || opcode == Opcode.ONCE || opcode == Opcode.ALWAYS || opcode == Opcode.EVENTUALLY
                || opcode == Opcode.AFTER;
    }

    private static boolean isFormulaBinary(Opcode opcode) {
        switch (opcode) {
            case AND:
            case OR:
            case IMPLIES:
            case IFF:
            case EQUALS:
            case NOT_EQUALS:
            case IN:
            case NOT_IN:
            case GT:
            case GTE:
            case LT:
            case LTE:
            case NOT_GT:
            case NOT_GTE:
            case NOT_LT:
            case NOT_LTE:
            case RELEASES:
            case SINCE:
            case TRIGGERED:
            case UNTIL:
                return true;
            default:
                return false;
        }
    }

    private static boolean isRelDeclOpcode(Opcode opcode) {
        return opcode == Opcode.DISJ || opcode == Opcode.VAR || opcode == Opcode.DISJVAR
                || opcode == Opcode.GENERICRELDECL;
    }

    private static Metatype metatypeOf(AugmentedNode node, Opcode opcode) {
        if (opcode == Opcode.VARIABLE || opcode == Opcode.GLOBALBINDING || opcode == Opcode.CONSTANT) {
            return Metatype.ATOMIC;
        }
        if (isRelDeclOpcode(opcode)) {
            return Metatype.CONTROL;
        }
        if (opcode == Opcode.EQUALS || opcode == Opcode.NOT_EQUALS || opcode == Opcode.GT || opcode == Opcode.GTE
                || opcode == Opcode.IN || opcode == Opcode.LT || opcode == Opcode.LTE || opcode == Opcode.NOT_GT
                || opcode == Opcode.NOT_GTE || opcode == Opcode.NOT_IN || opcode == Opcode.NOT_LT
                || opcode == Opcode.NOT_LTE || opcode == Opcode.SOME || opcode == Opcode.NO || opcode == Opcode.NOT
                || opcode == Opcode.BEFORE || opcode == Opcode.HISTORICALLY || opcode == Opcode.ONCE
                || opcode == Opcode.ALWAYS || opcode == Opcode.EVENTUALLY || opcode == Opcode.AFTER
                || opcode == Opcode.AND || opcode == Opcode.OR || opcode == Opcode.IMPLIES || opcode == Opcode.IFF
                || opcode == Opcode.RELEASES || opcode == Opcode.SINCE || opcode == Opcode.TRIGGERED
                || opcode == Opcode.UNTIL || opcode == Opcode.PREDICATE) {
            return Metatype.BOOLEAN;
        }
        return node.getSyntactic() > 0 ? Metatype.SET : Metatype.BOOLEAN;
    }
}
