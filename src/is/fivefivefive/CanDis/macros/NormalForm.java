package is.fivefivefive.CanDis.macros;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Collections;
import java.util.Comparator;

import is.fivefivefive.CanDis.macros.EGraphNode.Metatype;
import is.fivefivefive.CanDis.macros.EGraphNode.Opcode;
import is.fivefivefive.CanDis.macros.QuantificationTreeNode.Quantifier;

import java.util.HashMap;

/**
 * This class encodes the normal form of a formula or function, which consists of a quantification tree and a matrix e-graph representation of the formula. 
 * The quantification tree captures the structure of the quantifiers in the formula, while the matrix e-graph captures the structure of the formula itself. 
 * The normal form can be used for distance calculation, as well as for other analyses and transformations on the formula.
 * It is the locus of control for the visitor that generates the normal form from the original formula. 
 */
public class NormalForm {
    private QuantificationTreeNode quantificationTreeRoot;
    // matrix e-graph representation of the formula, where each node is a subformula, and edges represent the structure of the formula.
    private EGraphNode matrixEGraphRoot;
    private List<QuantiVar> params; // the parameters of the formula or function, in the order they appear in the original formula or function declaration.
    private List<QuantiVar> matrixQuantiVars; // the quantified variables in the matrix, in the order they appear in the formula.
    private Map<QuantiVar, QuantificationTreeNode> correspondingQuantificationTreeNodes; // a mapping from quantified variables in the matrix to their corresponding quantification tree nodes, for easy access.
    private TemporalOp temporalOp; // the temporal operator of the formula, if any, e.g., "before", "historically", "once", "always", "eventually", "until", "releases", "since", "triggered". If none, then it is a non-temporal formula.
    public enum TemporalOp {
        NONE,
        BEFORE,
        HISTORICALLY,
        ONCE,
        ALWAYS,
        EVENTUALLY,
        UNTILL,
        UNTILR,
        RELEASESL,
        RELEASESR,
        SINCEL,
        SINCER,
        TRIGGEREDL,
        TRIGGEREDR
    }
    public NormalForm() {
        // initialize the normal form with empty quantification tree and matrix e-graph, and empty parameter list and quantified variable list.
        this.quantificationTreeRoot = null;
        this.matrixEGraphRoot = null;
        this.params = new ArrayList<>();
        this.matrixQuantiVars = new ArrayList<>();
        this.correspondingQuantificationTreeNodes = new HashMap<>();
        this.temporalOp = TemporalOp.NONE;
    }

    public NormalForm(NormalForm parent, TemporalOp temporalOp, int egid) {
        this.quantificationTreeRoot = null;
        this.matrixEGraphRoot = new EGraphNode(egid, Opcode.TEMPORALROOT, new ArrayList<>(), false, 1, false, Metatype.BOOLEAN);
        this.params = parent.params;
        this.matrixQuantiVars = new ArrayList<>();
        this.correspondingQuantificationTreeNodes = new HashMap<>();
        this.temporalOp = temporalOp;
    }

    public QuantificationTreeNode getQuantificationTree() {
        return this.quantificationTreeRoot;
    }
    public EGraphNode getMatrixEGraph() {
        return this.matrixEGraphRoot;
    }
    public List<QuantiVar> getParams() {
        return this.params;
    }
    public List<QuantiVar> getMatrixQuantiVars() {
        return this.matrixQuantiVars;
    }
    public Map<QuantiVar, QuantificationTreeNode> getCorrespondingQuantificationTreeNodes() {
        return this.correspondingQuantificationTreeNodes;
    }
    public void addNode(QuantificationTreeNode node) {
        if (this.quantificationTreeRoot == null) {
            this.quantificationTreeRoot = node;
        } else {
            this.quantificationTreeRoot.addChild(node);
            node.setParent(this.quantificationTreeRoot);
        }
    }
    public void addEClass(EGraphNode node) {
        if (this.matrixEGraphRoot == null) {
            this.matrixEGraphRoot = node;
        } else {
            this.matrixEGraphRoot.addChild(node);
        }
    }
    public void addParam(QuantiVar param) {
        this.params.add(param);
    }
    public void addMatrixQuantiVar(QuantificationTreeNode qtNode, QuantiVar quantiVar) {
        this.matrixQuantiVars.add(quantiVar);
        this.correspondingQuantificationTreeNodes.put(quantiVar, qtNode);
        qtNode.addQuantiVar(quantiVar);
    }
    public TemporalOp getTemporalOp() {
        return this.temporalOp;
    }
    public void prenex() {
        if (matrixEGraphRoot == null) {
            return;
        }
        matrixQuantiVars.clear();
        correspondingQuantificationTreeNodes.clear();
        quantificationTreeRoot = null;
        matrixEGraphRoot = betaRewriteLet(matrixEGraphRoot, new HashMap<>());
        matrixEGraphRoot = prenex(matrixEGraphRoot, null, new HashMap<>(), new int[] { 0 }, false);
        matrixEGraphRoot = toNNF(matrixEGraphRoot, false);
        matrixEGraphRoot = normalizeAssociativeCommutative(matrixEGraphRoot);
    }

    private static EGraphNode betaRewriteLet(EGraphNode node, Map<String, EGraphNode> bindings) {
        if (node == null) {
            return null;
        }
        if (node.getOpcode() == Opcode.VARIABLE) {
            EGraphNode replacement = bindings.get(node.getSourceName());
            return replacement == null ? node : cloneEGraph(replacement);
        }
        if (node.getOpcode() == Opcode.LET && node.getChildren().size() >= 2) {
            EGraphNode bound = betaRewriteLet(node.getChildren().get(0), bindings);
            Map<String, EGraphNode> scopedBindings = new HashMap<>(bindings);
            if (node.getSourceName() != null) {
                scopedBindings.put(node.getSourceName(), bound);
            }
            return betaRewriteLet(node.getChildren().get(1), scopedBindings);
        }
        if (isQuantifier(node.getOpcode())) {
            Map<String, EGraphNode> scopedBindings = new HashMap<>(bindings);
            for (EGraphNode child : node.getChildren()) {
                if (isRelDecl(child.getOpcode())) {
                    removeDeclaredVariables(child, scopedBindings);
                }
            }
            EGraphNode rewritten = copyShallow(node, node.getOpcode());
            for (EGraphNode child : node.getChildren()) {
                EGraphNode rewrittenChild = betaRewriteLet(child, isRelDecl(child.getOpcode()) ? bindings : scopedBindings);
                if (rewrittenChild != null) {
                    rewritten.addChild(rewrittenChild);
                }
            }
            return rewritten;
        }

        Map<String, EGraphNode> scopedBindings = shadowsLetBindings(node) ? new HashMap<>(bindings) : bindings;
        if (shadowsLetBindings(node)) {
            for (EGraphNode child : node.getChildren()) {
                if (isRelDecl(child.getOpcode())) {
                    removeDeclaredVariables(child, scopedBindings);
                }
            }
        }

        EGraphNode rewritten = copyShallow(node, node.getOpcode());
        for (EGraphNode child : node.getChildren()) {
            EGraphNode rewrittenChild = betaRewriteLet(child, scopedBindings);
            if (rewrittenChild != null) {
                rewritten.addChild(rewrittenChild);
            }
        }
        return rewritten;
    }

    private static boolean shadowsLetBindings(EGraphNode node) {
        return isQuantifier(node.getOpcode()) || node.getOpcode() == Opcode.PREDICATE
                || node.getOpcode() == Opcode.FUNCTION || node.getOpcode() == Opcode.TEMPORALROOT;
    }

    private static void removeDeclaredVariables(EGraphNode relDecl, Map<String, EGraphNode> bindings) {
        List<EGraphNode> children = relDecl.getChildren();
        for (int i = 1; i < children.size(); i++) {
            EGraphNode candidate = children.get(i);
            if (candidate.getOpcode() == Opcode.VARIABLE && candidate.getSourceName() != null) {
                bindings.remove(candidate.getSourceName());
            }
        }
    }

    private EGraphNode prenex(EGraphNode node, QuantificationTreeNode scope, Map<String, QuantiVar> env, int[] nextVarId, boolean negated) {
        if (node == null) {
            return null;
        }
        if (node.getOpcode() == Opcode.VARIABLE) {
            QuantiVar qv = env.get(node.getSourceName());
            if (qv != null) {
                node.setAlphaName(qv.getName());
            }
            return node;
        }
        if (node.getOpcode() == Opcode.IFF && node.getChildren().size() == 2) {
            return prenex(expandIff(node, negated), scope, env, nextVarId, false);
        }
        if (node.getOpcode() == Opcode.NOT) {
            if (node.getChildren().size() == 1 && consumesMatrixNegation(node.getChildren().get(0).getOpcode())) {
                return prenex(node.getChildren().get(0), scope, env, nextVarId, true);
            }
            List<EGraphNode> rewritten = new ArrayList<>();
            for (EGraphNode child : node.getChildren()) {
                EGraphNode rewrittenChild = prenex(child, scope, env, nextVarId, !negated);
                if (rewrittenChild != null && rewrittenChild.getOpcode() != Opcode.END) {
                    rewritten.add(rewrittenChild);
                }
            }
            node.setChildren(rewritten);
            return node;
        }
        if (isQuantifier(node.getOpcode())) {
            QuantificationTreeNode nextScope = scope;
            Map<String, QuantiVar> scopedEnv = new HashMap<>(env);
            EGraphNode body = null;
            List<EGraphNode> children = node.getChildren();
            for (int i = 0; i < children.size(); i++) {
                EGraphNode child = children.get(i);
                if (isRelDecl(child.getOpcode())) {
                    nextScope = prenexRelDecl(node.getOpcode(), child, nextScope, scopedEnv, nextVarId, false, negated);
                } else {
                    EGraphNode rewrittenChild = prenex(child, nextScope, scopedEnv, nextVarId, negated);
                    if (rewrittenChild != null) {
                        body = rewrittenChild;
                    }
                }
            }
            return body == null ? node : body;
        }

        List<EGraphNode> children = node.getChildren();
        List<EGraphNode> rewritten = new ArrayList<>();
        for (int i = 0; i < children.size(); i++) {
            EGraphNode child = children.get(i);
            if (isRelDecl(child.getOpcode())) {
                scope = prenexRelDecl(Opcode.FORALL, child, scope, env, nextVarId, true, false);
                continue;
            }
            EGraphNode rewrittenChild = prenex(child, scope, env, nextVarId, childNegated(node.getOpcode(), i, negated));
            if (rewrittenChild != null && rewrittenChild.getOpcode() != Opcode.END) {
                rewritten.add(rewrittenChild);
            }
        }
        node.setChildren(rewritten);
        return node;
    }

    private QuantificationTreeNode prenexRelDecl(Opcode quantifierOpcode, EGraphNode relDecl, QuantificationTreeNode parent, Map<String, QuantiVar> env, int[] nextVarId, boolean parameterDecl, boolean negated) {
        if (!relDecl.getChildren().isEmpty()) {
            prenex(relDecl.getChildren().get(0), parent, env, nextVarId, false);
        }
        String typeName = relDeclType(relDecl);
        List<QuantiVar> quantiVars = new ArrayList<>();
        QuantificationTreeNode qtNode = new QuantificationTreeNode(quantifierOf(quantifierOpcode, negated), quantiVars, parent, isDisj(relDecl.getOpcode()), typeName);
        if (parent == null) {
            addNode(qtNode);
        } else {
            parent.addChild(qtNode);
            qtNode.setParent(parent);
        }

        List<EGraphNode> children = relDecl.getChildren();
        for (int i = 1; i < children.size(); i++) {
            EGraphNode candidate = children.get(i);
            if (candidate.getOpcode() != Opcode.VARIABLE) {
                continue;
            }
            String originalName = candidate.getSourceName();
            String alphaName = "_q" + nextVarId[0];
            String varType = checkedVarType(candidate.getSourceType(), typeName);
            QuantiVar qv = new QuantiVar(nextVarId[0]++, alphaName, varType);
            candidate.setAlphaName(alphaName);
            quantiVars.add(qv);
            if (parameterDecl) {
                params.add(qv);
            } else {
                matrixQuantiVars.add(qv);
            }
            correspondingQuantificationTreeNodes.put(qv, qtNode);
            if (originalName != null) {
                env.put(originalName, qv);
            }
        }
        return qtNode;
    }

    private static EGraphNode toNNF(EGraphNode node, boolean negated) {
        if (node == null) {
            return null;
        }
        Opcode opcode = node.getOpcode();
        if (opcode == Opcode.NOT && node.getChildren().size() == 1) {
            return toNNF(node.getChildren().get(0), !negated);
        }
        if (opcode == Opcode.IFF && node.getChildren().size() == 2) {
            return toNNF(expandIff(node, negated), false);
        }
        if (opcode == Opcode.IMPLIES && node.getChildren().size() == 2) {
            EGraphNode left = node.getChildren().get(0);
            EGraphNode right = node.getChildren().get(1);
            if (negated) {
                EGraphNode conjunction = syntheticNode(node, Opcode.AND, -1);
                conjunction.addChild(toNNF(left, false));
                conjunction.addChild(toNNF(right, true));
                return conjunction;
            }
            EGraphNode disjunction = syntheticNode(node, Opcode.OR, -1);
            disjunction.addChild(toNNF(left, true));
            disjunction.addChild(toNNF(right, false));
            return disjunction;
        }
        if (opcode == Opcode.ITE && node.getMetatype() == Metatype.BOOLEAN && node.getChildren().size() == 3) {
            return toNNF(expandIte(node, negated), false);
        }
        if (opcode == Opcode.AND || opcode == Opcode.OR) {
            EGraphNode rewritten = copyShallow(node, negated ? dualBooleanOpcode(opcode) : opcode);
            for (EGraphNode child : node.getChildren()) {
                rewritten.addChild(toNNF(child, negated));
            }
            return rewritten;
        }
        Opcode dual = negated ? dualOpcode(opcode) : opcode;
        if (dual != null) {
            EGraphNode rewritten = copyShallow(node, dual);
            for (EGraphNode child : node.getChildren()) {
                rewritten.addChild(toNNF(child, negated && dualNegatesChildren(opcode)));
            }
            return rewritten;
        }
        if (negated) {
            return syntheticUnary(node, Opcode.NOT, toNNF(node, false), -1);
        }
        EGraphNode rewritten = copyShallow(node, opcode);
        for (EGraphNode child : node.getChildren()) {
            rewritten.addChild(toNNF(child, false));
        }
        return rewritten;
    }

    private static EGraphNode normalizeAssociativeCommutative(EGraphNode node) {
        if (node == null) {
            return null;
        }
        EGraphNode rewritten = copyShallow(node, node.getOpcode());
        for (EGraphNode child : node.getChildren()) {
            EGraphNode normalizedChild = normalizeAssociativeCommutative(child);
            if (normalizedChild == null) {
                continue;
            }
            if (isAssociative(node.getOpcode()) && normalizedChild.getOpcode() == node.getOpcode()) {
                rewritten.getChildren().addAll(normalizedChild.getChildren());
            } else {
                rewritten.addChild(normalizedChild);
            }
        }
        if (isCommutative(rewritten.getOpcode())) {
            Collections.sort(rewritten.getChildren(), Comparator.comparing(NormalForm::sortKey));
        }
        return rewritten;
    }

    private static EGraphNode expandIff(EGraphNode node, boolean negated) {
        EGraphNode left = node.getChildren().get(0);
        EGraphNode right = node.getChildren().get(1);
        if (negated) {
            EGraphNode leftAndNotRight = syntheticNode(node, Opcode.AND, -1);
            leftAndNotRight.addChild(cloneEGraph(left));
            leftAndNotRight.addChild(syntheticUnary(node, Opcode.NOT, cloneEGraph(right), -2));

            EGraphNode rightAndNotLeft = syntheticNode(node, Opcode.AND, -3);
            rightAndNotLeft.addChild(cloneEGraph(right));
            rightAndNotLeft.addChild(syntheticUnary(node, Opcode.NOT, cloneEGraph(left), -4));

            EGraphNode disjunction = syntheticNode(node, Opcode.OR, -5);
            disjunction.addChild(leftAndNotRight);
            disjunction.addChild(rightAndNotLeft);
            return disjunction;
        }

        EGraphNode leftImpliesRight = syntheticNode(node, Opcode.IMPLIES, -1);
        leftImpliesRight.addChild(cloneEGraph(left));
        leftImpliesRight.addChild(cloneEGraph(right));

        EGraphNode rightImpliesLeft = syntheticNode(node, Opcode.IMPLIES, -2);
        rightImpliesLeft.addChild(cloneEGraph(right));
        rightImpliesLeft.addChild(cloneEGraph(left));

        EGraphNode conjunction = syntheticNode(node, Opcode.AND, -3);
        conjunction.addChild(leftImpliesRight);
        conjunction.addChild(rightImpliesLeft);
        return conjunction;
    }

    private static EGraphNode expandIte(EGraphNode node, boolean negated) {
        EGraphNode condition = node.getChildren().get(0);
        EGraphNode thenBranch = node.getChildren().get(1);
        EGraphNode elseBranch = node.getChildren().get(2);

        EGraphNode thenCase = syntheticNode(node, Opcode.AND, -1);
        thenCase.addChild(cloneEGraph(condition));
        thenCase.addChild(cloneEGraph(thenBranch));

        EGraphNode elseCase = syntheticNode(node, Opcode.AND, -2);
        elseCase.addChild(syntheticUnary(node, Opcode.NOT, cloneEGraph(condition), -3));
        elseCase.addChild(cloneEGraph(elseBranch));

        EGraphNode expanded = syntheticNode(node, Opcode.OR, -4);
        expanded.addChild(thenCase);
        expanded.addChild(elseCase);
        if (negated) {
            return syntheticUnary(node, Opcode.NOT, expanded, -5);
        }
        return expanded;
    }

    private static EGraphNode syntheticUnary(EGraphNode source, Opcode opcode, EGraphNode child, int offset) {
        EGraphNode node = syntheticNode(source, opcode, offset);
        node.addChild(child);
        return node;
    }

    private static EGraphNode syntheticNode(EGraphNode source, Opcode opcode, int offset) {
        return new EGraphNode(syntheticId(source, offset), opcode, new ArrayList<>(), isCommutative(opcode), maxArity(opcode), isFlexibleArity(opcode), Metatype.BOOLEAN);
    }

    private static EGraphNode copyShallow(EGraphNode source, Opcode opcode) {
        boolean sameOpcode = source.getOpcode() == opcode;
        EGraphNode copy = new EGraphNode(
                source.getId(),
                opcode,
                new ArrayList<>(),
                sameOpcode ? source.isCommutative() : isCommutative(opcode),
                sameOpcode ? source.getMaxArity() : maxArity(opcode),
                sameOpcode ? source.isFlexibleArity() : isFlexibleArity(opcode),
                source.getMetatype());
        copy.setSourceName(source.getSourceName());
        copy.setSourceType(source.getSourceType());
        copy.setAlphaName(source.getAlphaName());
        return copy;
    }

    private static boolean isCommutative(Opcode opcode) {
        return opcode == Opcode.AND || opcode == Opcode.OR || opcode == Opcode.IFF
                || opcode == Opcode.EQUALS || opcode == Opcode.NOT_EQUALS
                || opcode == Opcode.INTERSECT || opcode == Opcode.PLUS || opcode == Opcode.MUL
                || opcode == Opcode.IPLUS;
    }

    private static boolean isAssociative(Opcode opcode) {
        return opcode == Opcode.AND || opcode == Opcode.OR
                || opcode == Opcode.INTERSECT || opcode == Opcode.PLUS || opcode == Opcode.MUL
                || opcode == Opcode.IPLUS || opcode == Opcode.JOIN || opcode == Opcode.ARROW;
    }

    private static int maxArity(Opcode opcode) {
        if (opcode == Opcode.NOT) {
            return 1;
        }
        return isFlexibleArity(opcode) ? -1 : 2;
    }

    private static boolean isFlexibleArity(Opcode opcode) {
        return isAssociative(opcode);
    }

    private static String sortKey(EGraphNode node) {
        StringBuilder sb = new StringBuilder();
        appendSortKey(node, sb);
        return sb.toString();
    }

    private static void appendSortKey(EGraphNode node, StringBuilder sb) {
        sb.append(node.getOpcode()).append(':');
        if (node.getAlphaName() != null) {
            sb.append(node.getAlphaName());
        } else if (node.getSourceName() != null) {
            sb.append(node.getSourceName());
        } else {
            sb.append(node.getId());
        }
        sb.append('[');
        for (EGraphNode child : node.getChildren()) {
            appendSortKey(child, sb);
            sb.append(',');
        }
        sb.append(']');
    }

    private static Opcode dualBooleanOpcode(Opcode opcode) {
        return opcode == Opcode.AND ? Opcode.OR : Opcode.AND;
    }

    private static Opcode dualOpcode(Opcode opcode) {
        switch (opcode) {
            case EQUALS:
                return Opcode.NOT_EQUALS;
            case NOT_EQUALS:
                return Opcode.EQUALS;
            case GT:
                return Opcode.LTE;
            case GTE:
                return Opcode.LT;
            case IN:
                return Opcode.NOT_IN;
            case LT:
                return Opcode.GTE;
            case LTE:
                return Opcode.GT;
            case NOT_GT:
                return Opcode.GT;
            case NOT_GTE:
                return Opcode.GTE;
            case NOT_IN:
                return Opcode.IN;
            case NOT_LT:
                return Opcode.LT;
            case NOT_LTE:
                return Opcode.LTE;
            case SOME:
                return Opcode.NO;
            case NO:
                return Opcode.SOME;
            case ALWAYS:
                return Opcode.EVENTUALLY;
            case EVENTUALLY:
                return Opcode.ALWAYS;
            case HISTORICALLY:
                return Opcode.ONCE;
            case ONCE:
                return Opcode.HISTORICALLY;
            case UNTIL:
                return Opcode.RELEASES;
            case RELEASES:
                return Opcode.UNTIL;
            case SINCE:
                return Opcode.TRIGGERED;
            case TRIGGERED:
                return Opcode.SINCE;
            default:
                return null;
        }
    }

    private static boolean dualNegatesChildren(Opcode opcode) {
        return opcode == Opcode.ALWAYS || opcode == Opcode.EVENTUALLY
                || opcode == Opcode.HISTORICALLY || opcode == Opcode.ONCE
                || opcode == Opcode.UNTIL || opcode == Opcode.RELEASES
                || opcode == Opcode.SINCE || opcode == Opcode.TRIGGERED;
    }

    private static int syntheticId(EGraphNode source, int offset) {
        return -Math.abs(source.getId()) * 16 + offset;
    }

    private static EGraphNode cloneEGraph(EGraphNode node) {
        EGraphNode clone = new EGraphNode(node.getId(), node.getOpcode(), new ArrayList<>(), node.isCommutative(), node.getMaxArity(), node.isFlexibleArity(), node.getMetatype());
        clone.setSourceName(node.getSourceName());
        clone.setSourceType(node.getSourceType());
        clone.setAlphaName(node.getAlphaName());
        for (EGraphNode child : node.getChildren()) {
            clone.addChild(cloneEGraph(child));
        }
        return clone;
    }

    private static String checkedVarType(String variableType, String declarationType) {
        String resolved = firstNonEmpty(variableType, declarationType);
        if (variableType == null || declarationType == null) {
            return resolved;
        }
        String normalizedVariableType = normalizeType(variableType);
        String normalizedDeclarationType = normalizeType(declarationType);
        if (!normalizedVariableType.isEmpty() && !normalizedDeclarationType.isEmpty()
                && !normalizedVariableType.equals(normalizedDeclarationType)) {
            return resolved;
        }
        return resolved;
    }

    private static String normalizeType(String type) {
        if (type == null) {
            return "";
        }
        if (type.startsWith("VAR_")) {
            return type.substring(4);
        }
        return type;
    }

    private static boolean isQuantifier(Opcode opcode) {
        return opcode == Opcode.FORALL || opcode == Opcode.EXISTS || opcode == Opcode.NO
                || opcode == Opcode.LONE || opcode == Opcode.ONE || opcode == Opcode.SUM
                || opcode == Opcode.COMPREHENSION;
    }

    private static boolean consumesMatrixNegation(Opcode opcode) {
        return opcode == Opcode.NO || opcode == Opcode.ONE || opcode == Opcode.LONE;
    }

    private static boolean childNegated(Opcode opcode, int childIndex, boolean negated) {
        switch (opcode) {
            case IMPLIES:
                return childIndex == 0 ? !negated : negated;
            case ITE:
                return childIndex == 0 ? !negated : negated;
            default:
                return isNegatedFormulaOpcode(opcode) ? !negated : negated;
        }
    }

    private static boolean isNegatedFormulaOpcode(Opcode opcode) {
        return opcode == Opcode.NOT_EQUALS || opcode == Opcode.NOT_GT || opcode == Opcode.NOT_GTE
                || opcode == Opcode.NOT_IN || opcode == Opcode.NOT_LT || opcode == Opcode.NOT_LTE;
    }

    private static boolean isRelDecl(Opcode opcode) {
        return opcode == Opcode.DISJ || opcode == Opcode.VAR || opcode == Opcode.DISJVAR
                || opcode == Opcode.GENERICRELDECL;
    }

    private static boolean isDisj(Opcode opcode) {
        return opcode == Opcode.DISJ || opcode == Opcode.DISJVAR;
    }

    private static Quantifier quantifierOf(Opcode opcode, boolean negated) {
        switch (opcode) {
            case FORALL:
                return negated ? Quantifier.SOME : Quantifier.ALL;
            case EXISTS:
                return negated ? Quantifier.ALL : Quantifier.SOME;
            case NO:
                return negated ? Quantifier.SOME : Quantifier.NO;
            case LONE:
                return negated ? Quantifier.NOTLONE : Quantifier.LONE;
            case ONE:
                return negated ? Quantifier.NOTONE : Quantifier.ONE;
            case SUM:
                return Quantifier.SUM;
            case COMPREHENSION:
                return Quantifier.COMPREHENSION;
            default:
                return Quantifier.SOME;
        }
    }

    private static String relDeclType(EGraphNode relDecl) {
        if (relDecl.getChildren().isEmpty()) {
            return relDecl.getSourceType();
        }
        EGraphNode typeNode = relDecl.getChildren().get(0);
        return firstNonEmpty(typeNode.getSourceName(), typeNode.getSourceType(), relDecl.getSourceType());
    }

    private static String firstNonEmpty(String... values) {
        for (String value : values) {
            if (value != null && !value.isEmpty()) {
                return value;
            }
        }
        return null;
    }
}
