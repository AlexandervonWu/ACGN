package is.fivefivefive.CanDis.core;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Collections;
import java.util.Comparator;

import is.fivefivefive.CanDis.core.EGraphNode.Metatype;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.core.QuantiVar.Cardinality;
import is.fivefivefive.CanDis.core.QuantiVar.Quantifier;

import java.util.HashMap;

/**
 * This class encodes the normal form of a formula or function, which consists of a flat prenex binding list and a matrix e-graph representation of the formula. 
 * The normal form can be used for distance calculation, as well as for other analyses and transformations on the formula.
 * It is the locus of control for the visitor that generates the normal form from the original formula. 
 */
public class NormalForm {
    // matrix e-graph representation of the formula, where each node is a subformula, and edges represent the structure of the formula.
    private EGraphNode matrixEGraphRoot;
    private List<QuantiVar> params; // the parameters of the formula or function, in the order they appear in the original formula or function declaration.
    private List<QuantiVar> matrixQuantiVars; // the quantified variables in the matrix, in the order they appear in the formula.
    private List<QuantiVar> inheritedQuantiVars; // bindings owned by ancestor temporal phases and visible in this matrix.
    private List<NormalForm> temporalChildren;
    private TemporalOp temporalOp; // the temporal operator of the formula, if any, e.g., "before", "historically", "once", "always", "eventually", "until", "releases", "since", "triggered". If none, then it is a non-temporal formula.
    private int nextDisjointnessClass;
    public enum TemporalOp {
        NONE,
        BEFORE,
        HISTORICALLY,
        ONCE,
        ALWAYS,
        EVENTUALLY,
        AFTER,
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
        this.matrixEGraphRoot = null;
        this.params = new ArrayList<>();
        this.matrixQuantiVars = new ArrayList<>();
        this.inheritedQuantiVars = new ArrayList<>();
        this.temporalChildren = new ArrayList<>();
        this.temporalOp = TemporalOp.NONE;
        this.nextDisjointnessClass = 1;
    }

    public NormalForm(NormalForm parent, TemporalOp temporalOp, int egid) {
        this.matrixEGraphRoot = new EGraphNode(egid, Opcode.TEMPORALROOT, new ArrayList<>(), false, 1, false, Metatype.BOOLEAN);
        this.params = new ArrayList<>(parent.params);
        this.matrixQuantiVars = new ArrayList<>();
        this.inheritedQuantiVars = new ArrayList<>();
        this.temporalChildren = new ArrayList<>();
        this.temporalOp = temporalOp;
        this.nextDisjointnessClass = 1;
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
    public List<QuantiVar> getInheritedQuantiVars() {
        return this.inheritedQuantiVars;
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
    public void addMatrixQuantiVar(QuantiVar quantiVar) {
        this.matrixQuantiVars.add(quantiVar);
    }
    public TemporalOp getTemporalOp() {
        return this.temporalOp;
    }
    public List<NormalForm> getTemporalChildren() {
        return this.temporalChildren;
    }
    public void addTemporalChild(NormalForm child) {
        this.temporalChildren.add(child);
    }

    public void pushTemporalNegations() {
        if (matrixEGraphRoot == null || temporalChildren.isEmpty()) {
            return;
        }
        boolean[] changed = new boolean[1];
        matrixEGraphRoot = pushTemporalNegations(matrixEGraphRoot, changed);
        if (changed[0] && matrixEGraphRoot != null) {
            matrixEGraphRoot.saturate();
        }
    }

    private EGraphNode pushTemporalNegations(EGraphNode node, boolean[] changed) {
        if (node == null) {
            return null;
        }
        if (node.getOpcode() == Opcode.NOT && node.getChildren().size() == 1) {
            EGraphNode reference = node.getChildren().get(0);
            int[] target = temporalReferenceTarget(reference);
            if (target != null && dualizeTemporalChildren(target[0], target[1])) {
                changed[0] = true;
                return cloneEGraph(reference);
            }
        }
        EGraphNode rewritten = copyShallow(node, node.getOpcode());
        for (EGraphNode child : node.getChildren()) {
            EGraphNode rewrittenChild = pushTemporalNegations(child, changed);
            if (rewrittenChild != null) {
                rewritten.addChild(rewrittenChild);
            }
        }
        return rewritten;
    }

    private boolean dualizeTemporalChildren(int index, int arity) {
        if (index < 0 || arity < 1 || index + arity > temporalChildren.size()) {
            return false;
        }
        List<TemporalOp> duals = new ArrayList<>(arity);
        for (int i = 0; i < arity; i++) {
            TemporalOp dual = temporalNegationDual(temporalChildren.get(index + i).temporalOp);
            if (dual == null) {
                return false;
            }
            duals.add(dual);
        }
        for (int i = 0; i < arity; i++) {
            NormalForm child = temporalChildren.get(index + i);
            child.temporalOp = duals.get(i);
            child.negateMatrixBeforeNormalization();
        }
        return true;
    }

    private void negateMatrixBeforeNormalization() {
        if (matrixEGraphRoot == null) {
            return;
        }
        if (matrixEGraphRoot.getOpcode() != Opcode.TEMPORALROOT) {
            matrixEGraphRoot = syntheticUnary(matrixEGraphRoot, Opcode.NOT, matrixEGraphRoot, -11);
            return;
        }
        EGraphNode root = copyShallow(matrixEGraphRoot, Opcode.TEMPORALROOT);
        List<EGraphNode> body = new ArrayList<>();
        for (EGraphNode child : matrixEGraphRoot.getChildren()) {
            if (isRelDecl(child.getOpcode())) {
                root.addChild(child);
            } else {
                body.add(child);
            }
        }
        if (!body.isEmpty()) {
            EGraphNode matrix = body.size() == 1 ? body.get(0) : conjoin(null, body);
            root.addChild(syntheticUnary(matrix, Opcode.NOT, matrix, -12));
        }
        matrixEGraphRoot = root;
    }

    private static int[] temporalReferenceTarget(EGraphNode node) {
        if (node.getOpcode() != Opcode.REF || node.getSourceName() == null) {
            return null;
        }
        String source = node.getSourceName();
        if (!source.startsWith("temporal[") || !source.endsWith("]")) {
            return null;
        }
        int colon = source.indexOf(':', 9);
        if (colon < 0) {
            return null;
        }
        try {
            int index = Integer.parseInt(source.substring(9, colon));
            int arity = Integer.parseInt(source.substring(colon + 1, source.length() - 1));
            return new int[] { index, arity };
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private static TemporalOp temporalNegationDual(TemporalOp op) {
        switch (op) {
            case ALWAYS:
                return TemporalOp.EVENTUALLY;
            case EVENTUALLY:
                return TemporalOp.ALWAYS;
            case HISTORICALLY:
                return TemporalOp.ONCE;
            case ONCE:
                return TemporalOp.HISTORICALLY;
            case UNTILL:
                return TemporalOp.RELEASESL;
            case UNTILR:
                return TemporalOp.RELEASESR;
            case RELEASESL:
                return TemporalOp.UNTILL;
            case RELEASESR:
                return TemporalOp.UNTILR;
            case SINCEL:
                return TemporalOp.TRIGGEREDL;
            case SINCER:
                return TemporalOp.TRIGGEREDR;
            case TRIGGEREDL:
                return TemporalOp.SINCEL;
            case TRIGGEREDR:
                return TemporalOp.SINCER;
            default:
                return null;
        }
    }
    public void prenex() {
        normalize();
    }
    public void normalize() {
        normalize(new HashMap<>(), new int[] { 0 });
    }
    public void normalize(Map<String, QuantiVar> inheritedBindings, int[] nextVarId) {
        if (matrixEGraphRoot == null) {
            return;
        }
        matrixQuantiVars.clear();
        inheritedQuantiVars = new ArrayList<>(new java.util.LinkedHashSet<>(inheritedBindings.values()));
        inheritedQuantiVars.sort(java.util.Comparator.comparingInt(QuantiVar::getId));
        nextDisjointnessClass = 1;
        matrixEGraphRoot = removeEndNodes(matrixEGraphRoot);
        Map<String, String> inheritedAlphaNames = new HashMap<>();
        for (Map.Entry<String, QuantiVar> entry : inheritedBindings.entrySet()) {
            inheritedAlphaNames.put(entry.getKey(), entry.getValue().getName());
        }
        matrixEGraphRoot = alphaRenameBoundVariables(
                matrixEGraphRoot, inheritedAlphaNames, new int[] { 0 });
        matrixEGraphRoot = betaRewriteLet(matrixEGraphRoot, new HashMap<>());
        matrixEGraphRoot = removeEndNodes(matrixEGraphRoot);
        matrixEGraphRoot = removeEndNodes(rewriteBranchConnectives(matrixEGraphRoot));
        matrixEGraphRoot = removeEndNodes(toNNF(matrixEGraphRoot, false));
        List<EGraphNode> constraints = new ArrayList<>();
        Map<String, QuantiVar> prenexBindings = new HashMap<>(inheritedBindings);
        for (QuantiVar inherited : inheritedBindings.values()) {
            prenexBindings.put(inherited.getName(), inherited);
        }
        matrixEGraphRoot = prenex(matrixEGraphRoot, prenexBindings, nextVarId, false, constraints, "root",
                true, true, true);
        matrixEGraphRoot = removeEndNodes(conjoin(matrixEGraphRoot, constraints));
        matrixEGraphRoot = removeEndNodes(rewriteBranchConnectives(matrixEGraphRoot));
        matrixEGraphRoot = removeEndNodes(toNNF(matrixEGraphRoot, false));
        matrixEGraphRoot = normalizeAssociativeCommutative(matrixEGraphRoot);
        matrixEGraphRoot = removeEndNodes(matrixEGraphRoot);
        if (matrixEGraphRoot == null) {
            return;
        }
        matrixEGraphRoot.saturate();
        registerQuantifierSymmetries();
    }

    private static EGraphNode alphaRenameBoundVariables(
            EGraphNode node,
            Map<String, String> scope,
            int[] nextBinderId) {
        if (node == null) {
            return null;
        }
        if (node.getOpcode() == Opcode.VARIABLE
                || (node.getOpcode() == Opcode.LET && node.getChildren().isEmpty())) {
            EGraphNode renamed = copyShallow(node, node.getOpcode());
            String alphaName = scope.get(node.getSourceName());
            if (alphaName != null) {
                renamed.setAlphaName(alphaName);
            }
            return renamed;
        }
        if (node.getOpcode() == Opcode.LET && node.getChildren().size() >= 2) {
            EGraphNode renamed = copyShallow(node, Opcode.LET);
            renamed.addChild(alphaRenameBoundVariables(node.getChildren().get(0), scope, nextBinderId));
            String alphaName = "@let:" + nextBinderId[0]++;
            renamed.setAlphaName(alphaName);
            Map<String, String> bodyScope = new HashMap<>(scope);
            if (node.getSourceName() != null) {
                bodyScope.put(node.getSourceName(), alphaName);
            }
            for (int i = 1; i < node.getChildren().size(); i++) {
                renamed.addChild(alphaRenameBoundVariables(node.getChildren().get(i), bodyScope, nextBinderId));
            }
            return renamed;
        }
        if (bindsRelDeclarations(node)) {
            EGraphNode renamed = copyShallow(node, node.getOpcode());
            Map<String, String> bodyScope = new HashMap<>(scope);
            Map<Integer, EGraphNode> declarations = new HashMap<>();
            for (int i = 0; i < node.getChildren().size(); i++) {
                EGraphNode child = node.getChildren().get(i);
                if (isRelDecl(child.getOpcode())) {
                    declarations.put(i, alphaRenameRelDecl(child, bodyScope, nextBinderId));
                }
            }
            for (int i = 0; i < node.getChildren().size(); i++) {
                EGraphNode declaration = declarations.get(i);
                renamed.addChild(declaration == null
                        ? alphaRenameBoundVariables(node.getChildren().get(i), bodyScope, nextBinderId)
                        : declaration);
            }
            return renamed;
        }
        EGraphNode renamed = copyShallow(node, node.getOpcode());
        for (EGraphNode child : node.getChildren()) {
            renamed.addChild(alphaRenameBoundVariables(child, scope, nextBinderId));
        }
        return renamed;
    }

    private static EGraphNode alphaRenameRelDecl(
            EGraphNode declaration,
            Map<String, String> bodyScope,
            int[] nextBinderId) {
        EGraphNode renamed = copyShallow(declaration, declaration.getOpcode());
        List<EGraphNode> children = declaration.getChildren();
        if (!children.isEmpty()) {
            renamed.addChild(alphaRenameBoundVariables(children.get(0), bodyScope, nextBinderId));
        }
        for (int i = 1; i < children.size(); i++) {
            EGraphNode child = children.get(i);
            if (child.getOpcode() != Opcode.VARIABLE) {
                renamed.addChild(alphaRenameBoundVariables(child, bodyScope, nextBinderId));
                continue;
            }
            EGraphNode variable = copyShallow(child, Opcode.VARIABLE);
            String alphaName = "@bind:" + nextBinderId[0]++;
            variable.setAlphaName(alphaName);
            renamed.addChild(variable);
            if (child.getSourceName() != null) {
                bodyScope.put(child.getSourceName(), alphaName);
            }
        }
        return renamed;
    }

    private static boolean bindsRelDeclarations(EGraphNode node) {
        if (node.getOpcode() != Opcode.PREDICATE && node.getOpcode() != Opcode.FUNCTION
                && node.getOpcode() != Opcode.TEMPORALROOT && !isQuantifierNode(node)) {
            return false;
        }
        for (EGraphNode child : node.getChildren()) {
            if (isRelDecl(child.getOpcode())) {
                return true;
            }
        }
        return false;
    }

    private static String bindingKey(EGraphNode node) {
        return firstNonEmpty(node.getAlphaName(), node.getSourceName());
    }

    private void registerQuantifierSymmetries() {
        if (matrixEGraphRoot == null) {
            return;
        }
        for (int i = 1; i < matrixQuantiVars.size(); i++) {
            QuantiVar left = matrixQuantiVars.get(i - 1);
            QuantiVar right = matrixQuantiVars.get(i);
            if (isSymmetricBooleanQuantifier(left.getQuantifier())
                    && left.getQuantifier() == right.getQuantifier()
                    && left.getCardinality() == right.getCardinality()
                    && left.getDisjointnessClass() == right.getDisjointnessClass()
                    && normalizeType(left.getTypeName()).equals(normalizeType(right.getTypeName()))) {
                matrixEGraphRoot.getEClass().addSlotSwap(left.getName(), right.getName());
            }
        }
    }

    private static boolean isSymmetricBooleanQuantifier(Quantifier quantifier) {
        return quantifier == Quantifier.ALL || quantifier == Quantifier.SOME
                || quantifier == Quantifier.NO || quantifier == Quantifier.ONE
                || quantifier == Quantifier.LONE || quantifier == Quantifier.NOTONE
                || quantifier == Quantifier.NOTLONE;
    }

    private static EGraphNode rewriteBranchConnectives(EGraphNode node) {
        if (node == null) {
            return null;
        }
        if (node.getOpcode() == Opcode.IMPLIES && node.getChildren().size() == 2) {
            EGraphNode left = rewriteBranchConnectives(node.getChildren().get(0));
            EGraphNode right = rewriteBranchConnectives(node.getChildren().get(1));
            EGraphNode disjunction = syntheticNode(node, Opcode.OR, -1);
            disjunction.addChild(syntheticUnary(node, Opcode.NOT, left, -2));
            disjunction.addChild(right);
            return disjunction;
        }
        if (node.getOpcode() == Opcode.IFF && node.getChildren().size() == 2) {
            EGraphNode left = rewriteBranchConnectives(node.getChildren().get(0));
            EGraphNode right = rewriteBranchConnectives(node.getChildren().get(1));

            EGraphNode leftImpliesRight = syntheticNode(node, Opcode.OR, -1);
            leftImpliesRight.addChild(syntheticUnary(node, Opcode.NOT, cloneEGraph(left), -2));
            leftImpliesRight.addChild(cloneEGraph(right));

            EGraphNode rightImpliesLeft = syntheticNode(node, Opcode.OR, -3);
            rightImpliesLeft.addChild(syntheticUnary(node, Opcode.NOT, cloneEGraph(right), -4));
            rightImpliesLeft.addChild(cloneEGraph(left));

            EGraphNode conjunction = syntheticNode(node, Opcode.AND, -5);
            conjunction.addChild(leftImpliesRight);
            conjunction.addChild(rightImpliesLeft);
            return conjunction;
        }
        if (node.getOpcode() == Opcode.ITE && node.getMetatype() == Metatype.BOOLEAN
                && node.getChildren().size() == 3) {
            EGraphNode condition = rewriteBranchConnectives(node.getChildren().get(0));
            EGraphNode thenBranch = rewriteBranchConnectives(node.getChildren().get(1));
            EGraphNode elseBranch = rewriteBranchConnectives(node.getChildren().get(2));

            EGraphNode thenCase = syntheticNode(node, Opcode.AND, -1);
            thenCase.addChild(cloneEGraph(condition));
            thenCase.addChild(thenBranch);

            EGraphNode elseCase = syntheticNode(node, Opcode.AND, -2);
            elseCase.addChild(syntheticUnary(node, Opcode.NOT, condition, -3));
            elseCase.addChild(elseBranch);

            EGraphNode disjunction = syntheticNode(node, Opcode.OR, -4);
            disjunction.addChild(thenCase);
            disjunction.addChild(elseCase);
            return disjunction;
        }
        EGraphNode rewritten = copyShallow(node, node.getOpcode());
        for (EGraphNode child : node.getChildren()) {
            EGraphNode rewrittenChild = rewriteBranchConnectives(child);
            if (rewrittenChild != null) {
                rewritten.addChild(rewrittenChild);
            }
        }
        return rewritten;
    }

    private static EGraphNode betaRewriteLet(EGraphNode node, Map<String, EGraphNode> bindings) {
        if (node == null) {
            return null;
        }
        if (node.getOpcode() == Opcode.VARIABLE) {
            EGraphNode replacement = bindings.get(bindingKey(node));
            return replacement == null ? node : cloneEGraph(replacement);
        }
        if (node.getOpcode() == Opcode.LET && node.getChildren().isEmpty()) {
            EGraphNode replacement = bindings.get(bindingKey(node));
            return replacement == null ? node : cloneEGraph(replacement);
        }
        if (node.getOpcode() == Opcode.LET && node.getChildren().size() >= 2) {
            EGraphNode bound = betaRewriteLet(node.getChildren().get(0), bindings);
            Map<String, EGraphNode> scopedBindings = new HashMap<>(bindings);
            String key = bindingKey(node);
            if (key != null) {
                scopedBindings.put(key, bound);
            }
            return betaRewriteLet(node.getChildren().get(1), scopedBindings);
        }
        if (isQuantifierNode(node)) {
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
        return isQuantifierNode(node) || node.getOpcode() == Opcode.PREDICATE
                || node.getOpcode() == Opcode.FUNCTION || node.getOpcode() == Opcode.TEMPORALROOT;
    }

    private static void removeDeclaredVariables(EGraphNode relDecl, Map<String, EGraphNode> bindings) {
        List<EGraphNode> children = relDecl.getChildren();
        for (int i = 1; i < children.size(); i++) {
            EGraphNode candidate = children.get(i);
            if (candidate.getOpcode() == Opcode.VARIABLE && bindingKey(candidate) != null) {
                bindings.remove(bindingKey(candidate));
            }
        }
    }

    private EGraphNode prenex(
            EGraphNode node,
            Map<String, QuantiVar> env,
            int[] nextVarId,
            boolean negated,
            List<EGraphNode> constraints,
            String bindingPath,
            boolean canLiftSome,
            boolean canLiftAll,
            boolean globalLift) {
        if (node == null) {
            return null;
        }
        if (node.getOpcode() == Opcode.VARIABLE) {
            QuantiVar qv = env.get(bindingKey(node));
            if (qv != null) {
                node.setAlphaName(qv.getName());
            }
            return node;
        }
        if (node.getOpcode() == Opcode.IFF && node.getChildren().size() == 2) {
            return prenex(expandIff(node, negated), env, nextVarId, false, constraints, bindingPath + "/iff",
                    canLiftSome, canLiftAll, globalLift);
        }
        if (node.getOpcode() == Opcode.NOT) {
            List<EGraphNode> rewritten = new ArrayList<>();
            for (EGraphNode child : node.getChildren()) {
                EGraphNode rewrittenChild = prenex(child, env, nextVarId, !negated, constraints, bindingPath + "/not",
                        canLiftSome, canLiftAll, globalLift);
                if (rewrittenChild != null && rewrittenChild.getOpcode() != Opcode.END) {
                    rewritten.add(rewrittenChild);
                }
            }
            if (rewritten.isEmpty()) {
                return null;
            }
            return rewritten.size() == 1 ? rewritten.get(0) : conjoin(null, rewritten);
        }
        if (isQuantifierNode(node)) {
            if (node.getOpcode() == Opcode.COMPREHENSION || node.getOpcode() == Opcode.SUM) {
                return localQuantifier(node, env, nextVarId, negated, bindingPath);
            }
            Quantifier quantifier = quantifierOf(node.getOpcode(), negated);
            if (!globalLift) {
                return localQuantifier(node, env, nextVarId, negated, bindingPath);
            }
            boolean relativizeCarrier = !canLiftQuantifier(quantifier, canLiftSome, canLiftAll, true);
            Map<String, QuantiVar> scopedEnv = new HashMap<>(env);
            List<EGraphNode> localConstraints = new ArrayList<>();
            List<EGraphNode> bodyParts = new ArrayList<>();
            List<EGraphNode> children = node.getChildren();
            boolean bodyNegated = (node.getOpcode() == Opcode.NO && !negated)
                    || (negated && !consumesMatrixNegation(node.getOpcode()));
            Boolean emptyDomainValue = null;
            for (int i = 0; i < children.size(); i++) {
                EGraphNode child = children.get(i);
                if (isRelDecl(child.getOpcode())) {
                    RelDeclResult relDecl = prenexRelDecl(node.getOpcode(), child, scopedEnv, nextVarId, false, negated, localConstraints,
                            bindingPath + "/decl[" + i + "]", relativizeCarrier);
                    if (relDecl.emptyDomainValue != null) {
                        emptyDomainValue = relDecl.emptyDomainValue;
                    }
                } else {
                    EGraphNode rewrittenChild = prenex(child, scopedEnv, nextVarId, bodyNegated, constraints,
                            bindingPath + "/body[" + i + "]", canLiftSome, canLiftAll, globalLift);
                    if (rewrittenChild != null) {
                        bodyParts.add(rewrittenChild);
                    }
                }
            }
            if (emptyDomainValue != null) {
                return booleanConstant(node, emptyDomainValue);
            }
            EGraphNode body = conjoin(null, bodyParts);
            body = applyDomainConstraints(body, localConstraints, quantifierOf(node.getOpcode(), negated));
            return body == null ? booleanConstant(node, true) : body;
        }
        if (negated) {
            return prenexNegatedNonQuantifier(node, env, nextVarId, constraints, bindingPath,
                    canLiftSome, canLiftAll, globalLift);
        }

        List<EGraphNode> children = node.getChildren();
        List<EGraphNode> rewritten = new ArrayList<>();
        for (int i = 0; i < children.size(); i++) {
            EGraphNode child = children.get(i);
            if (isRelDecl(child.getOpcode())) {
                prenexRelDecl(Opcode.FORALL, child, env, nextVarId, true, false, constraints,
                        bindingPath + "/param[" + i + "]", false);
                continue;
            }
            boolean childNegated = childNegated(node.getOpcode(), i, negated);
            boolean childCanLiftSome = childCanLiftSome(node.getOpcode(), canLiftSome);
            boolean childCanLiftAll = childCanLiftAll(node.getOpcode(), canLiftAll);
            EGraphNode rewrittenChild = prenex(child, env, nextVarId, childNegated, constraints,
                    childBindingPath(bindingPath, node.getOpcode(), i, childNegated),
                    childCanLiftSome, childCanLiftAll, globalLift);
            if (rewrittenChild != null && rewrittenChild.getOpcode() != Opcode.END) {
                rewritten.add(rewrittenChild);
            }
        }
        node.setChildren(rewritten);
        return node;
    }

    private EGraphNode prenexNegatedNonQuantifier(
            EGraphNode node,
            Map<String, QuantiVar> env,
            int[] nextVarId,
            List<EGraphNode> constraints,
            String bindingPath,
            boolean canLiftSome,
            boolean canLiftAll,
            boolean globalLift) {
        Opcode opcode = node.getOpcode();
        if (opcode == Opcode.AND || opcode == Opcode.OR) {
            Opcode rewrittenOpcode = dualBooleanOpcode(opcode);
            boolean childCanLiftSome = childCanLiftSome(rewrittenOpcode, canLiftSome);
            boolean childCanLiftAll = childCanLiftAll(rewrittenOpcode, canLiftAll);
            EGraphNode rewritten = copyShallow(node, dualBooleanOpcode(opcode));
            for (int i = 0; i < node.getChildren().size(); i++) {
                EGraphNode child = prenex(node.getChildren().get(i), env, nextVarId, true, constraints,
                        childBindingPath(bindingPath, opcode, i, true), childCanLiftSome, childCanLiftAll, globalLift);
                if (child != null && child.getOpcode() != Opcode.END) {
                    rewritten.addChild(child);
                }
            }
            return rewritten;
        }
        if (opcode == Opcode.IMPLIES && node.getChildren().size() == 2) {
            EGraphNode conjunction = syntheticNode(node, Opcode.AND, -1);
            boolean childCanLiftSome = childCanLiftSome(Opcode.AND, canLiftSome);
            boolean childCanLiftAll = childCanLiftAll(Opcode.AND, canLiftAll);
            EGraphNode left = prenex(node.getChildren().get(0), env, nextVarId, false, constraints,
                    bindingPath + "/implies[0]", childCanLiftSome, childCanLiftAll, globalLift);
            EGraphNode right = prenex(node.getChildren().get(1), env, nextVarId, true, constraints,
                    bindingPath + "/implies[1]/not", childCanLiftSome, childCanLiftAll, globalLift);
            if (left != null && left.getOpcode() != Opcode.END) {
                conjunction.addChild(left);
            }
            if (right != null && right.getOpcode() != Opcode.END) {
                conjunction.addChild(right);
            }
            return conjunction;
        }
        if (opcode == Opcode.ITE && node.getMetatype() == Metatype.BOOLEAN && node.getChildren().size() == 3) {
            return prenex(expandIte(node, true), env, nextVarId, false, constraints, bindingPath + "/ite",
                    canLiftSome, canLiftAll, globalLift);
        }
        Opcode dual = dualOpcode(opcode);
        if (dual != null) {
            EGraphNode rewritten = copyShallow(node, dual);
            boolean negateChildren = dualNegatesChildren(opcode);
            for (int i = 0; i < node.getChildren().size(); i++) {
                EGraphNode child = prenex(node.getChildren().get(i), env, nextVarId, negateChildren, constraints,
                        childBindingPath(bindingPath, opcode, i, negateChildren), canLiftSome, canLiftAll, globalLift);
                if (child != null && child.getOpcode() != Opcode.END) {
                    rewritten.addChild(child);
                }
            }
            return rewritten;
        }
        EGraphNode positive = prenex(node, env, nextVarId, false, constraints, bindingPath + "/positive",
                canLiftSome, canLiftAll, globalLift);
        return positive == null ? null : syntheticUnary(node, Opcode.NOT, positive, -1);
    }

    private static boolean canLiftQuantifier(
            Quantifier quantifier,
            boolean canLiftSome,
            boolean canLiftAll,
            boolean globalLift) {
        if (!globalLift) {
            return false;
        }
        switch (quantifier) {
            case ALL:
            case NO:
                return canLiftAll;
            case SOME:
                return canLiftSome;
            default:
                return canLiftSome && canLiftAll;
        }
    }

    private static boolean childCanLiftSome(Opcode opcode, boolean current) {
        switch (opcode) {
            case AND:
            case PREDICATE:
            case FUNCTION:
            case TEMPORALROOT:
                return current;
            default:
                return false;
        }
    }

    private static boolean childCanLiftAll(Opcode opcode, boolean current) {
        switch (opcode) {
            case OR:
            case PREDICATE:
            case FUNCTION:
            case TEMPORALROOT:
                return current;
            default:
                return false;
        }
    }

    private EGraphNode localQuantifier(
            EGraphNode node,
            Map<String, QuantiVar> env,
            int[] nextVarId,
            boolean negated,
            String bindingPath) {
        EGraphNode quantifier = copyShallow(node, node.getOpcode());
        Map<String, QuantiVar> scopedEnv = new HashMap<>(env);
        List<EGraphNode> bodyParts = new ArrayList<>();
        List<EGraphNode> localConstraints = new ArrayList<>();
        List<EGraphNode> children = node.getChildren();
        for (int i = 0; i < children.size(); i++) {
            EGraphNode child = children.get(i);
            if (isRelDecl(child.getOpcode())) {
                quantifier.addChild(localRelDecl(node.getOpcode(), child, scopedEnv, nextVarId, negated,
                        localConstraints, bindingPath + "/local-decl[" + i + "]"));
            } else {
                EGraphNode rewrittenChild = prenex(child, scopedEnv, nextVarId, false, localConstraints,
                        bindingPath + "/local-body[" + i + "]", true, true, false);
                if (rewrittenChild != null && rewrittenChild.getOpcode() != Opcode.END) {
                    bodyParts.add(rewrittenChild);
                }
            }
        }
        EGraphNode body = conjoin(null, bodyParts);
        body = applyDomainConstraints(body, localConstraints, quantifierOf(node.getOpcode(), false));
        if (body != null) {
            quantifier.addChild(body);
        }
        return negated ? syntheticUnary(node, Opcode.NOT, quantifier, -1) : quantifier;
    }

    private EGraphNode localRelDecl(
            Opcode quantifierOpcode,
            EGraphNode relDecl,
            Map<String, QuantiVar> env,
            int[] nextVarId,
            boolean negated,
            List<EGraphNode> constraints,
            String bindingPath) {
        EGraphNode copy = copyShallow(relDecl, relDecl.getOpcode());
        EGraphNode typeEGraph = null;
        if (!relDecl.getChildren().isEmpty()) {
            typeEGraph = prenex(relDecl.getChildren().get(0), env, nextVarId, false, constraints,
                    bindingPath + "/type", true, true, false);
            copy.addChild(typeEGraph == null ? relDecl.getChildren().get(0) : typeEGraph);
        }
        EGraphNode normalizedTypeEGraph = typeEGraph == null ? null : normalizeAssociativeCommutative(toNNF(typeEGraph, false));
        DomainDescriptor domain = domainDescriptor(normalizedTypeEGraph);
        boolean disj = isDisj(relDecl.getOpcode());
        int disjointnessClass = disj ? nextDisjointnessClass++ : 0;
        List<EGraphNode> children = relDecl.getChildren();
        for (int i = 1; i < children.size(); i++) {
            EGraphNode candidate = children.get(i);
            EGraphNode candidateCopy = cloneEGraph(candidate);
            if (candidate.getOpcode() == Opcode.VARIABLE) {
                String originalName = candidate.getSourceName();
                String alphaName = "_q" + nextVarId[0];
                String varType = primitiveVarType(candidate.getSourceType());
                QuantiVar qv = new QuantiVar(nextVarId[0]++, alphaName, originalName, varType);
                qv.setQuantifier(quantifierOf(quantifierOpcode, negated));
                qv.setCardinality(domain.cardinality);
                qv.setDisjointnessClass(disjointnessClass);
                qv.setBindingPath(bindingPath);
                qv.setDeBruijnKey(bindingPath + "#" + (i - 1) + ":" + qv.getCardinality()
                        + ":" + normalizeType(varType));
                candidateCopy.setAlphaName(alphaName);
                if (needsDomainConstraint(domain, varType)) {
                    constraints.add(domainConstraint(qv, candidateCopy, domain.domain));
                }
                String key = bindingKey(candidate);
                if (key != null) {
                    env.put(key, qv);
                }
            }
            copy.addChild(candidateCopy);
        }
        return copy;
    }

    private RelDeclResult prenexRelDecl(
            Opcode quantifierOpcode,
            EGraphNode relDecl,
            Map<String, QuantiVar> env,
            int[] nextVarId,
            boolean parameterDecl,
            boolean negated,
            List<EGraphNode> constraints,
            String bindingPath,
            boolean relativizeCarrier) {
        EGraphNode typeEGraph = null;
        if (!relDecl.getChildren().isEmpty()) {
            typeEGraph = prenex(relDecl.getChildren().get(0), env, nextVarId, false, constraints,
                    bindingPath + "/type", true, true, true);
        }
        EGraphNode normalizedTypeEGraph = typeEGraph == null ? null : normalizeAssociativeCommutative(toNNF(typeEGraph, false));
        DomainDescriptor domain = domainDescriptor(normalizedTypeEGraph);
        List<QuantiVar> quantiVars = new ArrayList<>();
        Quantifier quantifier = quantifierOf(quantifierOpcode, negated);
        if (isNone(domain.domain)) {
            return new RelDeclResult(quantiVars, emptyDomainValue(quantifier));
        }
        boolean disj = isDisj(relDecl.getOpcode());
        int disjointnessClass = disj ? nextDisjointnessClass++ : 0;
        String deBruijnBase = bindingPath + (negated ? "@neg" : "@pos");

        List<EGraphNode> children = relDecl.getChildren();
        for (int i = 1; i < children.size(); i++) {
            EGraphNode candidate = children.get(i);
            if (candidate.getOpcode() != Opcode.VARIABLE) {
                continue;
            }
            String key = bindingKey(candidate);
            String originalName = candidate.getSourceName();
            String alphaName = "_q" + nextVarId[0];
            String varType = primitiveVarType(candidate.getSourceType());
            QuantiVar qv = new QuantiVar(nextVarId[0]++, alphaName, originalName, varType);
            qv.setQuantifier(quantifier);
            qv.setCardinality(domain.cardinality);
            boolean guardedDomain = domain.domain != null
                    && (relativizeCarrier || needsDomainConstraint(domain, varType));
            if (guardedDomain) {
                qv.setCarrierTypeName("univ");
            }
            qv.setDisjointnessClass(disjointnessClass);
            qv.setBindingPath(deBruijnBase);
            qv.setDeBruijnKey(deBruijnBase + "#" + (i - 1) + ":" + qv.getCardinality()
                    + ":" + normalizeType(varType));
            candidate.setAlphaName(alphaName);
            quantiVars.add(qv);
            if (guardedDomain) {
                constraints.add(domainConstraint(qv, candidate, domain.domain));
            }
            if (parameterDecl) {
                params.add(qv);
            } else {
                matrixQuantiVars.add(qv);
            }
            if (key != null) {
                env.put(key, qv);
            }
        }
        return new RelDeclResult(quantiVars, null);
    }

    private static Boolean emptyDomainValue(Quantifier quantifier) {
        switch (quantifier) {
            case ALL:
            case NO:
            case LONE:
                return true;
            case SOME:
            case ONE:
            case NOTONE:
            case NOTLONE:
                return false;
            default:
                return null;
        }
    }

    private static EGraphNode applyDomainConstraints(EGraphNode body, List<EGraphNode> constraints, Quantifier quantifier) {
        if (constraints.isEmpty()) {
            return body;
        }
        EGraphNode domain = conjoin(null, constraints);
        if (quantifier == Quantifier.ALL) {
            if (body == null) {
                return domain;
            }
            EGraphNode implication = syntheticNode(domain, Opcode.IMPLIES, -1);
            implication.addChild(domain);
            implication.addChild(body);
            return implication;
        }
        return conjoin(body, constraints);
    }

    private static EGraphNode conjoin(EGraphNode body, List<EGraphNode> constraints) {
        if (constraints.isEmpty()) {
            return body;
        }
        if (body == null && constraints.size() == 1) {
            return constraints.get(0);
        }
        EGraphNode source = body == null ? constraints.get(0) : body;
        EGraphNode conjunction = syntheticNode(source, Opcode.AND, -1);
        if (body != null) {
            conjunction.addChild(body);
        }
        for (EGraphNode constraint : constraints) {
            conjunction.addChild(constraint);
        }
        return conjunction;
    }

    private static EGraphNode booleanConstant(EGraphNode source, boolean value) {
        EGraphNode constant = syntheticNode(source, Opcode.CONSTANT, value ? -7 : -8);
        constant.setSourceName(Boolean.toString(value));
        constant.setSourceType("Bool");
        return constant;
    }

    private static String primitiveVarType(String type) {
        String normalized = normalizeType(type);
        return normalized.isEmpty() ? type : normalized;
    }

    private static boolean needsDomainConstraint(DomainDescriptor domain, String primitiveType) {
        if (domain == null || domain.domain == null) {
            return false;
        }
        String primitiveDomain = primitiveDomainName(domain.domain);
        if (primitiveDomain != null && primitiveType != null) {
            return !normalizeType(primitiveDomain).equals(normalizeType(primitiveType));
        }
        return true;
    }

    private static DomainDescriptor domainDescriptor(EGraphNode typeEGraph) {
        if (typeEGraph == null) {
            return new DomainDescriptor(null, Cardinality.SET);
        }
        Cardinality cardinality = cardinalityOf(typeEGraph.getOpcode());
        if (cardinality != null && typeEGraph.getChildren().size() == 1) {
            return new DomainDescriptor(typeEGraph.getChildren().get(0), cardinality);
        }
        return new DomainDescriptor(typeEGraph, Cardinality.SET);
    }

    private static String primitiveDomainName(EGraphNode typeEGraph) {
        if (typeEGraph == null) {
            return null;
        }
        if (typeEGraph.getOpcode() == Opcode.GLOBALBINDING || typeEGraph.getOpcode() == Opcode.CONSTANT) {
            return firstNonEmpty(typeEGraph.getSourceName(), typeEGraph.getSourceType());
        }
        return null;
    }

    private static Cardinality cardinalityOf(Opcode opcode) {
        switch (opcode) {
            case ONE:
                return Cardinality.ONE;
            case SOME:
                return Cardinality.SOME;
            case LONE:
                return Cardinality.LONE;
            case EXACTLY:
                return Cardinality.EXACTLY;
            case SETOF:
                return Cardinality.SET;
            default:
                return null;
        }
    }

    private static boolean isNone(EGraphNode node) {
        return node != null
                && (node.getOpcode() == Opcode.GLOBALBINDING || node.getOpcode() == Opcode.CONSTANT)
                && node.getSourceName() != null
                && "none".equalsIgnoreCase(node.getSourceName());
    }

    private static EGraphNode domainConstraint(QuantiVar qv, EGraphNode sourceVariable, EGraphNode domain) {
        EGraphNode constraint = syntheticNode(sourceVariable, Opcode.IN, -1);
        EGraphNode variable = new EGraphNode(sourceVariable.getId(), Opcode.VARIABLE, new ArrayList<>(), false, 0, false, Metatype.ATOMIC);
        variable.setSourceName(sourceVariable.getSourceName());
        variable.setSourceType(qv.getTypeName());
        variable.setAlphaName(qv.getName());
        constraint.addChild(variable);
        constraint.addChild(cloneEGraph(domain));
        return constraint;
    }

    private static EGraphNode toNNF(EGraphNode node, boolean negated) {
        if (node == null) {
            return null;
        }
        Opcode opcode = node.getOpcode();
        if (opcode == Opcode.END) {
            return null;
        }
        if (opcode == Opcode.NOT && node.getChildren().size() == 1) {
            return toNNF(node.getChildren().get(0), !negated);
        }
        if (isQuantifierNode(node)) {
            EGraphNode rewritten = copyShallow(node, opcode);
            for (EGraphNode child : node.getChildren()) {
                EGraphNode rewrittenChild = toNNF(child, false);
                if (rewrittenChild != null) {
                    rewritten.addChild(rewrittenChild);
                }
            }
            return negated ? syntheticUnary(node, Opcode.NOT, rewritten, -1) : rewritten;
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
                EGraphNode rewrittenChild = toNNF(child, negated);
                if (rewrittenChild != null) {
                    rewritten.addChild(rewrittenChild);
                }
            }
            return rewritten;
        }
        Opcode dual = negated ? dualOpcode(opcode) : opcode;
        if (dual != null) {
            EGraphNode rewritten = copyShallow(node, dual);
            for (EGraphNode child : node.getChildren()) {
                EGraphNode rewrittenChild = toNNF(child, negated && dualNegatesChildren(opcode));
                if (rewrittenChild != null) {
                    rewritten.addChild(rewrittenChild);
                }
            }
            return rewritten;
        }
        if (negated) {
            return syntheticUnary(node, Opcode.NOT, toNNF(node, false), -1);
        }
        EGraphNode rewritten = copyShallow(node, opcode);
        for (EGraphNode child : node.getChildren()) {
            EGraphNode rewrittenChild = toNNF(child, false);
            if (rewrittenChild != null) {
                rewritten.addChild(rewrittenChild);
            }
        }
        return rewritten;
    }

    private static EGraphNode removeEndNodes(EGraphNode node) {
        if (node == null || node.getOpcode() == Opcode.END) {
            return null;
        }
        List<EGraphNode> rewrittenChildren = new ArrayList<>();
        for (EGraphNode child : node.getChildren()) {
            EGraphNode rewrittenChild = removeEndNodes(child);
            if (rewrittenChild != null) {
                rewrittenChildren.add(rewrittenChild);
            }
        }
        node.setChildren(rewrittenChildren);
        if (isAssociative(node.getOpcode()) && node.getChildren().size() == 1) {
            return node.getChildren().get(0);
        }
        if (isUnaryOperator(node.getOpcode()) && node.getChildren().isEmpty()) {
            return null;
        }
        if (isBinaryOperator(node.getOpcode()) && node.getChildren().size() < 2) {
            return null;
        }
        if (isDanglingStructuralMarker(node)) {
            return null;
        }
        return node;
    }

    private static boolean isDanglingStructuralMarker(EGraphNode node) {
        if (!node.getChildren().isEmpty()) {
            return false;
        }
        switch (node.getOpcode()) {
            case VARIABLE:
            case GLOBALBINDING:
            case CONSTANT:
            case CALL:
            case REF:
            case LET:
            case PREDICATE:
            case FUNCTION:
                return false;
            default:
                return true;
        }
    }

    private static boolean isUnaryOperator(Opcode opcode) {
        return opcode == Opcode.NOT || opcode == Opcode.SOME || opcode == Opcode.NO || opcode == Opcode.LONE
                || opcode == Opcode.ONE || opcode == Opcode.SETOF || opcode == Opcode.EXACTLY
                || opcode == Opcode.TRANSPOSE || opcode == Opcode.RCLOSURE || opcode == Opcode.CLOSURE
                || opcode == Opcode.CARDINALITY || opcode == Opcode.CAST2INT || opcode == Opcode.CAST2SIGINT
                || opcode == Opcode.PRIME || opcode == Opcode.BEFORE || opcode == Opcode.HISTORICALLY
                || opcode == Opcode.ONCE || opcode == Opcode.ALWAYS || opcode == Opcode.EVENTUALLY
                || opcode == Opcode.AFTER;
    }

    private static boolean isBinaryOperator(Opcode opcode) {
        switch (opcode) {
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
            case JOIN:
            case ARROW:
            case ANY_ARROW_SOME:
            case ANY_ARROW_ONE:
            case ANY_ARROW_LONE:
            case SOME_ARROW_ANY:
            case SOME_ARROW_SOME:
            case SOME_ARROW_ONE:
            case SOME_ARROW_LONE:
            case ONE_ARROW_ANY:
            case ONE_ARROW_SOME:
            case ONE_ARROW_ONE:
            case ONE_ARROW_LONE:
            case LONE_ARROW_ANY:
            case LONE_ARROW_SOME:
            case LONE_ARROW_ONE:
            case LONE_ARROW_LONE:
            case ISSEQ_ARROW_LONE:
            case DOMAIN:
            case RANGE:
            case PLUSPLUS:
            case MINUS:
            case IMINUS:
            case DIV:
            case REM:
            case SHL:
            case SHA:
            case SHR:
            case UNTIL:
            case RELEASES:
            case SINCE:
            case TRIGGERED:
                return true;
            default:
                return false;
        }
    }

    private static EGraphNode normalizeAssociativeCommutative(EGraphNode node) {
        if (node == null) {
            return null;
        }
        List<EGraphNode> rewrittenChildren = new ArrayList<>();
        for (EGraphNode child : node.getChildren()) {
            EGraphNode normalizedChild = normalizeAssociativeCommutative(child);
            if (normalizedChild == null) {
                continue;
            }
            if (isAssociative(node.getOpcode()) && normalizedChild.getOpcode() == node.getOpcode()) {
                rewrittenChildren.addAll(normalizedChild.getChildren());
            } else {
                rewrittenChildren.add(normalizedChild);
            }
        }
        if (node.isOrderInsensitive()) {
            Collections.sort(rewrittenChildren, Comparator.comparing(NormalForm::sortKey));
        }
        node.setChildren(rewrittenChildren);
        return node;
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
        } else if (node.getChildren().isEmpty()) {
            sb.append(node.getSourceType() == null ? "" : node.getSourceType());
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

    private static boolean isQuantifierNode(EGraphNode node) {
        if (!isQuantifier(node.getOpcode())) {
            return false;
        }
        for (EGraphNode child : node.getChildren()) {
            if (isRelDecl(child.getOpcode())) {
                return true;
            }
        }
        return false;
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
                return negated;
        }
    }

    private static String childBindingPath(String parentPath, Opcode opcode, int childIndex, boolean childNegated) {
        StringBuilder path = new StringBuilder(parentPath);
        path.append('/').append(opcode.name().toLowerCase()).append('[').append(childIndex).append(']');
        if (childNegated) {
            path.append("/not");
        }
        return path.toString();
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
                return negated ? Quantifier.SOME : Quantifier.ALL;
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

    private static String firstNonEmpty(String... values) {
        for (String value : values) {
            if (value != null && !value.isEmpty()) {
                return value;
            }
        }
        return null;
    }

    private static final class RelDeclResult {
        private final List<QuantiVar> quantiVars;
        private final Boolean emptyDomainValue;

        private RelDeclResult(List<QuantiVar> quantiVars, Boolean emptyDomainValue) {
            this.quantiVars = quantiVars;
            this.emptyDomainValue = emptyDomainValue;
        }
    }

    private static final class DomainDescriptor {
        private final EGraphNode domain;
        private final Cardinality cardinality;

        private DomainDescriptor(EGraphNode domain, Cardinality cardinality) {
            this.domain = domain;
            this.cardinality = cardinality == null ? Cardinality.SET : cardinality;
        }
    }
}
