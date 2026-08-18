package is.fivefivefive.CanDis.core;

import java.util.AbstractList;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.ArrayDeque;
import java.util.HashSet;
import java.util.IdentityHashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;

import is.fivefivefive.CanDis.core.RenamedIdUnionFind.RenamedId;


/**
 * This class represents a node in the slotted e-graph of the matrix of the normal form.
 * The e-graph is a graph representation of the formula, where each node represents a subformula, and edges represent the structure of the formula.
 * For example, for a formula like "P(x) and Q(y)", the e-graph would have a node for "P(x)", a node for "Q(y)", and an edge between them representing the "and" operator. 
 * The e-graph shall be used to make the distance minimal, to capture the symmetry, associativity, commutativity, and other properties of the formula, 
 * which can help to make the distance calculation more accurate and efficient.
 * Operands are slotted e-class invocations rather than embedded subtrees. Each
 * invocation maps the slots exposed by the referenced e-class into the caller's
 * slots. The current implementation keeps canonical representatives for Fast Rewrite IR
 * consumers and retains rewrite alternatives in their shared e-class.
 */
public class EGraphNode {
    private static final AtomicInteger NEXT_ECLASS_ID = new AtomicInteger();
    private static final ThreadLocal<EGraphArena> CURRENT_ARENA = ThreadLocal.withInitial(EGraphArena::new);

    private int id;
    private Opcode opcode; // the semantic operator of this node with a corresponding opcode
    private List<EClassRef> childClasses;
    private final List<EGraphNode> childrenView;
    private EClass eClass;
    private EGraphArena arena;
    private boolean isCommutative; // whether the operator of this node is commutative, which can help to capture the symmetry of the formula
    private int maxArity; // the maximum arity of this node, which is the maximum number of children this node can have, and it is determined by the operator of this node
    private boolean flexibleArity; // whether this node has flexible arity, which is determined by the operator of this node, e.g., "and" and "or" have flexible arity, while "implies" and "iff" have fixed arity of 2.
    private String sourceName;
    private String sourceType;
    private String alphaName;
    public enum Metatype {
        ATOMIC, 
        SET, 
        BOOLEAN,
        CONTROL
    }
    public enum FlexibleArityKind {
        FIXED,
        SET,
        BAG,
        SEQUENCE
    }
    public enum Opcode {
        AND,
        OR,
        NOT,
        IMPLIES,
        IFF,
        PREDICATE,
        FUNCTION,
        VARIABLE,
        GLOBALBINDING,
        CONSTANT,
        TEMPORALROOT,
        ASSERTION,
        CHECK,
        RUN,
        FACT,
        LET,
        DUMMY,
        REF,
        SHADOW,
        END,

        // STRUCTURAL IR NODES
        ITE,
        CALL,
        LIST,
        DISJOINT_LIST,
        TOTALORDER_LIST,
        COMPREHENSION,
        SUM,

        // TEMPORAL LEAVES
        RELEASES,
        SINCE,
        TRIGGERED,
        UNTIL,
        BEFORE,
        HISTORICALLY,
        ONCE,
        ALWAYS,
        EVENTUALLY,
        AFTER,

        // FORMULA OPERATORS
        EQUALS,
        NOT_EQUALS,
        GT,
        GTE,
        IN,
        LT,
        LTE,
        NOT_GT,
        NOT_GTE,
        NOT_IN,
        NOT_LT,
        NOT_LTE,
        SOME,
        NO,

        // EXPRESSION OPERATORS
        ARROW,
        ANY_ARROW_SOME,
        ANY_ARROW_ONE,
        ANY_ARROW_LONE,
        SOME_ARROW_ANY,
        SOME_ARROW_SOME,
        SOME_ARROW_ONE,
        SOME_ARROW_LONE,
        ONE_ARROW_ANY,
        ONE_ARROW_SOME,
        ONE_ARROW_ONE,
        ONE_ARROW_LONE,
        LONE_ARROW_ANY,
        LONE_ARROW_SOME,
        LONE_ARROW_ONE,
        LONE_ARROW_LONE,
        ISSEQ_ARROW_LONE,
        JOIN,
        DOMAIN,
        RANGE,
        INTERSECT,
        PLUSPLUS,
        PLUS,
        IPLUS,
        MINUS,
        IMINUS,
        MUL,
        DIV,
        REM,
        SHL,
        SHA,
        SHR,
        SETOF,
        EXACTLY,
        TRANSPOSE,
        RCLOSURE,
        CLOSURE,
        CARDINALITY,
        CAST2INT,
        CAST2SIGINT,
        PRIME,
        
        // QUANTIFIER IR NODES TO BE ELIMINATED
        FORALL,
        EXISTS,
        LONE,
        ONE,

        // DECLS IR NODES TO BE ELIMINATED
        GENERICRELDECL,
        DISJ,
        VAR,
        DISJVAR,
        
        // ... other operators can be added here
        MODULEDECL,
        OPEN,
        PARAMDECL,
        SIGDECL,
        FIELDDECL
    }
    private Metatype metatype; // the metatype of this node, which can be used to capture the type of the formula, e.g., atomic formula, set formula, boolean formula, etc.
    public EGraphNode(int id, Opcode opcode, List<EGraphNode> children, boolean isCommutative, int maxArity, boolean flexibleArity, Metatype metatype) {
        this(id, opcode, children, isCommutative, maxArity, flexibleArity, metatype, true);
    }

    private EGraphNode(int id, Opcode opcode, List<EGraphNode> children, boolean isCommutative,
            int maxArity, boolean flexibleArity, Metatype metatype, boolean createEClass) {
        this.id = id;
        this.opcode = opcode;
        this.arena = CURRENT_ARENA.get();
        this.childClasses = new ArrayList<>();
        this.childrenView = new AbstractList<EGraphNode>() {
            @Override
            public EGraphNode get(int index) {
                return childClasses.get(index).getEClass().getRepresentative();
            }

            @Override
            public int size() {
                return childClasses.size();
            }
        };
        this.isCommutative = isCommutative;
        this.maxArity = maxArity;
        this.flexibleArity = flexibleArity;
        this.metatype = metatype;
        if (children != null) {
            for (EGraphNode child : children) {
                appendChild(child);
            }
        }
        if (createEClass) {
            this.eClass = new EClass(NEXT_ECLASS_ID.getAndIncrement(), this);
        }
    }
    public int getId() {
        return id;
    }
    public Opcode getOpcode() {
        return opcode;
    }
    public List<EGraphNode> getChildren() {
        return childrenView;
    }
    public void setChildren(List<EGraphNode> children) {
        childClasses.clear();
        if (children != null) {
            for (EGraphNode child : children) {
                appendChild(child);
            }
        }
        refreshEClassSlots();
    }
    public boolean isCommutative() {
        return isCommutative;
    }
    public int getMaxArity() {
        return maxArity;
    }
    public boolean isFlexibleArity() {
        return flexibleArity;
    }
    public FlexibleArityKind getFlexibleArityKind() {
        if (!flexibleArity) {
            return FlexibleArityKind.FIXED;
        }
        if (isSetFlexibleArityOperator(opcode)) {
            return FlexibleArityKind.SET;
        }
        return isCommutative ? FlexibleArityKind.BAG : FlexibleArityKind.SEQUENCE;
    }
    public boolean isSetFlexibleArity() {
        return getFlexibleArityKind() == FlexibleArityKind.SET;
    }
    public boolean isBagFlexibleArity() {
        return getFlexibleArityKind() == FlexibleArityKind.BAG;
    }
    public boolean isSequenceFlexibleArity() {
        return getFlexibleArityKind() == FlexibleArityKind.SEQUENCE;
    }
    public boolean isOrderInsensitive() {
        return isCommutative;
    }
    public void addChild(EGraphNode child) {
        if (child == null) {
            return;
        }
        appendChild(child);
        refreshEClassSlots();
    }

    private void appendChild(EGraphNode child) {
        if (child != null) {
            childClasses.add(new EClassRef(child.getEClass(), identitySlotMap(child.getEClass())));
        }
    }
    public List<EClassRef> getChildClasses() {
        return Collections.unmodifiableList(childClasses);
    }
    public Map<String, Integer> getChildClassCardinalities() {
        Map<String, Integer> cardinalities = new LinkedHashMap<>();
        for (EClassRef child : childClasses) {
            String key = child.getEClass().getId() + child.getSlotMap().toString();
            cardinalities.put(key, cardinalities.getOrDefault(key, 0) + 1);
        }
        return Collections.unmodifiableMap(cardinalities);
    }
    public EClass getEClass() {
        return eClass;
    }
    public EClassRef getEClassRef() {
        return eClass.invoke(identitySlotMap(eClass));
    }
    public static EClassRef union(EClassRef left, EClassRef right) {
        if (left.eClass.arena != right.eClass.arena) {
            throw new IllegalArgumentException("Cannot union e-classes from different e-graphs");
        }
        EGraphArena arena = left.eClass.arena;
        EClassRef canonicalLeft = left.canonical();
        EClassRef canonicalRight = right.canonical();
        if (canonicalLeft.eClass.id == canonicalRight.eClass.id) {
            canonicalLeft.eClass.addInvocationEquivalence(
                    canonicalLeft.slotMap,
                    canonicalRight.slotMap);
            return canonicalLeft;
        }
        canonicalLeft.eClass.ensureRegistered();
        canonicalRight.eClass.ensureRegistered();
        RenamedId leader = arena.unionFind.union(left.asRenamedId(), right.asRenamedId());
        EClass leaderClass = arena.classes.get(leader.getId());
        return new EClassRef(leaderClass, leader.getRenaming());
    }
    public static void beginGraph() {
        CURRENT_ARENA.set(new EGraphArena());
    }
    public static void endGraph() {
        CURRENT_ARENA.remove();
    }
    public static void retainReachable(List<EGraphNode> roots) {
        if (roots == null || roots.isEmpty()) {
            return;
        }
        Map<EGraphArena, Set<Integer>> reachableByArena = new LinkedHashMap<>();
        Map<EGraphArena, ArrayDeque<EClass>> pendingByArena = new LinkedHashMap<>();
        for (EGraphNode root : roots) {
            if (root == null || root.eClass == null) {
                continue;
            }
            pendingByArena.computeIfAbsent(root.arena, ignored -> new ArrayDeque<>()).add(root.eClass);
            reachableByArena.computeIfAbsent(root.arena, ignored -> new HashSet<>());
        }
        for (Map.Entry<EGraphArena, ArrayDeque<EClass>> entry : pendingByArena.entrySet()) {
            EGraphArena arena = entry.getKey();
            Set<Integer> reachable = reachableByArena.get(arena);
            ArrayDeque<EClass> pending = entry.getValue();
            while (!pending.isEmpty()) {
                EClass current = pending.removeFirst();
                if (!reachable.add(current.id)) {
                    continue;
                }
                for (EGraphNode node : current.nodes) {
                    for (EClassRef child : node.childClasses) {
                        pending.addLast(child.eClass);
                    }
                }
            }
            // Registered classes may participate in a union-find path not visible as a child edge.
            for (EClass eClass : arena.classes.values()) {
                if (eClass.registered) {
                    reachable.add(eClass.id);
                }
            }
            arena.classes.keySet().retainAll(reachable);
        }
    }
    public static ReachabilityStats countReachable(List<EGraphNode> roots) {
        if (roots == null || roots.isEmpty()) {
            return new ReachabilityStats(0, 0);
        }
        Set<EClass> classes = Collections.newSetFromMap(new IdentityHashMap<>());
        Set<EGraphNode> nodes = Collections.newSetFromMap(new IdentityHashMap<>());
        ArrayDeque<EClass> pending = new ArrayDeque<>();
        for (EGraphNode root : roots) {
            if (root != null && root.eClass != null) {
                pending.addLast(root.eClass);
            }
        }
        while (!pending.isEmpty()) {
            EClass eClass = pending.removeFirst();
            if (!classes.add(eClass)) {
                continue;
            }
            for (EGraphNode node : eClass.nodes) {
                nodes.add(node);
                for (EClassRef child : node.childClasses) {
                    pending.addLast(child.eClass);
                }
            }
        }
        return new ReachabilityStats(classes.size(), nodes.size());
    }
    public Metatype getMetatype() {
        return metatype;
    }
    public String getSourceName() {
        return sourceName;
    }
    public void setSourceName(String sourceName) {
        this.sourceName = sourceName;
        if (opcode == Opcode.VARIABLE) {
            refreshEClassSlots();
        }
    }
    public String getSourceType() {
        return sourceType;
    }
    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }
    public String getAlphaName() {
        return alphaName;
    }
    public void setAlphaName(String alphaName) {
        this.alphaName = alphaName;
        refreshEClassSlots();
    }

    /**
     * Rewrite the e-graph with regard to rewriting rules; canonicalize the formula with equality saturation. 
     */
    public void saturate() {
        Set<Integer> active = new HashSet<>();
        saturate(active);
    }

    private void saturate(Set<Integer> active) {
        if (!active.add(eClass.getId())) {
            return;
        }
        for (EClassRef child : new ArrayList<>(childClasses)) {
            child.getEClass().getRepresentative().saturate(active);
        }
        boolean changed;
        int iterations = 0;
        do {
            changed = saturateOnce();
            iterations++;
        } while (changed && iterations < 32);
        active.remove(eClass.getId());
    }

    private boolean saturateOnce() {
        List<EClassRef> canonicalChildren = null;
        for (int i = 0; i < childClasses.size(); i++) {
            EClassRef child = childClasses.get(i);
            EClassRef canonical = child.canonical();
            if (!child.equals(canonical)) {
                if (canonicalChildren == null) {
                    canonicalChildren = new ArrayList<>(childClasses);
                }
                canonicalChildren.set(i, canonical);
            }
        }
        if (canonicalChildren != null) {
            childClasses = canonicalChildren;
            refreshEClassSlots();
        }

        if (opcode == Opcode.NOT && childClasses.size() == 1) {
            EGraphNode child = childClasses.get(0).getEClass().getRepresentative();
            if (isBooleanConstant(child, true) || isBooleanConstant(child, false)) {
                eClass.preserveSnapshot(snapshot());
                collapseToBooleanConstant(isBooleanConstant(child, false));
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
            if (child.getOpcode() == Opcode.NOT && child.childClasses.size() == 1) {
                eClass.preserveSnapshot(snapshot());
                adopt(child.childClasses.get(0).getEClass().getRepresentative());
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
        }

        List<EClassRef> rewrittenChildren = new ArrayList<>();
        for (EClassRef childRef : childClasses) {
            EGraphNode child = childRef.getEClass().getRepresentative();
            if (flexibleArity && isAssociative(opcode) && child.getOpcode() == opcode) {
                rewrittenChildren.addAll(child.childClasses);
            } else {
                rewrittenChildren.add(childRef);
            }
        }
        if (isOrderInsensitive()) {
            rewrittenChildren.sort(Comparator.comparing(ref -> ref.getEClass().getRepresentative().sortKey()));
        }

        if (isSetFlexibleArityOperator(opcode)) {
            rewrittenChildren = removeDuplicateInvocations(rewrittenChildren);
        }

        if (opcode == Opcode.AND || opcode == Opcode.OR) {
            Boolean constantValue = booleanConstantIn(rewrittenChildren, opcode == Opcode.AND ? false : true);
            if (constantValue != null) {
                eClass.preserveSnapshot(snapshot());
                collapseToBooleanConstant(constantValue);
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
            List<EClassRef> withoutNeutral = removeBooleanConstant(
                    rewrittenChildren,
                    opcode == Opcode.AND);
            if (withoutNeutral.size() != rewrittenChildren.size()) {
                rewrittenChildren = withoutNeutral;
            }
            if (containsComplement(rewrittenChildren)) {
                eClass.preserveSnapshot(snapshot());
                collapseToBooleanConstant(opcode == Opcode.OR);
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
            if (rewrittenChildren.size() == 1) {
                eClass.preserveSnapshot(snapshot());
                adopt(rewrittenChildren.get(0).getEClass().getRepresentative());
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
        }

        if (isSetFlexibleArityOperator(opcode) && rewrittenChildren.size() == 1 && childClasses.size() != 1) {
            eClass.preserveSnapshot(snapshot());
            adopt(rewrittenChildren.get(0).getEClass().getRepresentative());
            refreshEClassSlots();
            eClass.recordShape(this);
            return true;
        }

        if (!sameChildren(childClasses, rewrittenChildren)) {
            eClass.preserveSnapshot(snapshot());
            childClasses = rewrittenChildren;
            refreshEClassSlots();
            eClass.recordShape(this);
            return true;
        }

        if (opcode == Opcode.NOT && childClasses.size() == 1) {
            EGraphNode child = childClasses.get(0).getEClass().getRepresentative();
            if (child.getOpcode() == Opcode.AND || child.getOpcode() == Opcode.OR) {
                eClass.preserveSnapshot(snapshot());
                opcode = child.getOpcode() == Opcode.AND ? Opcode.OR : Opcode.AND;
                isCommutative = true;
                flexibleArity = true;
                maxArity = -1;
                childClasses = new ArrayList<>();
                for (EClassRef grandchild : child.childClasses) {
                    EGraphNode negated = new EGraphNode(
                            -Math.abs(grandchild.getEClass().getId()) - 1,
                            Opcode.NOT,
                            new ArrayList<>(),
                            false,
                            1,
                            false,
                            Metatype.BOOLEAN);
                    negated.addChild(grandchild.getEClass().getRepresentative());
                    negated.saturate();
                    addChild(negated);
                }
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
        }

        if (opcode == Opcode.IN && childClasses.size() == 2) {
            EGraphNode rhs = childClasses.get(1).getEClass().getRepresentative();
            if (isNone(rhs) || isUniv(rhs)) {
                eClass.preserveSnapshot(snapshot());
                collapseToBooleanConstant(isUniv(rhs));
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
        }

        if (opcode == Opcode.IMPLIES && childClasses.size() == 2) {
            EGraphNode left = childClasses.get(0).getEClass().getRepresentative();
            EGraphNode right = childClasses.get(1).getEClass().getRepresentative();
            if (!isBooleanConstant(left, false) && !isBooleanConstant(left, true)
                    && !isBooleanConstant(right, false) && !isBooleanConstant(right, true)) {
                eClass.preserveSnapshot(snapshot());
                EGraphNode negatedLeft = new EGraphNode(
                        -Math.abs(left.getId()) - 11,
                        Opcode.NOT,
                        new ArrayList<>(),
                        false,
                        1,
                        false,
                        Metatype.BOOLEAN);
                negatedLeft.addChild(left);
                opcode = Opcode.OR;
                childClasses = new ArrayList<>();
                isCommutative = true;
                maxArity = -1;
                flexibleArity = true;
                addChild(negatedLeft);
                addChild(right);
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
            if (isBooleanConstant(left, false) || isBooleanConstant(right, true)) {
                eClass.preserveSnapshot(snapshot());
                collapseToBooleanConstant(true);
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
            if (isBooleanConstant(left, true)) {
                eClass.preserveSnapshot(snapshot());
                adopt(right);
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
            if (isBooleanConstant(right, false)) {
                eClass.preserveSnapshot(snapshot());
                opcode = Opcode.NOT;
                childClasses = new ArrayList<>();
                isCommutative = false;
                maxArity = 1;
                flexibleArity = false;
                addChild(left);
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
        }

        if ((opcode == Opcode.INTERSECT || opcode == Opcode.PLUS) && childClasses.size() >= 2) {
            if (opcode == Opcode.INTERSECT && containsSetConstant(childClasses, "none")) {
                eClass.preserveSnapshot(snapshot());
                collapseToSetConstant("none");
                refreshEClassSlots();
                eClass.recordShape(this);
                return true;
            }
            if (opcode == Opcode.PLUS) {
                List<EClassRef> withoutNone = removeSetConstant(childClasses, "none");
                if (withoutNone.size() != childClasses.size()) {
                    if (withoutNone.isEmpty()) {
                        eClass.preserveSnapshot(snapshot());
                        collapseToSetConstant("none");
                    } else if (withoutNone.size() == 1) {
                        eClass.preserveSnapshot(snapshot());
                        adopt(withoutNone.get(0).getEClass().getRepresentative());
                    } else {
                        eClass.preserveSnapshot(snapshot());
                        childClasses = withoutNone;
                    }
                    refreshEClassSlots();
                    eClass.recordShape(this);
                    return true;
                }
            }
        }
        return false;
    }

    private void adopt(EGraphNode replacement) {
        opcode = replacement.opcode;
        childClasses = new ArrayList<>(replacement.childClasses);
        isCommutative = replacement.isCommutative;
        maxArity = replacement.maxArity;
        flexibleArity = replacement.flexibleArity;
        sourceName = replacement.sourceName;
        sourceType = replacement.sourceType;
        alphaName = replacement.alphaName;
        metatype = replacement.metatype;
    }

    private void collapseToBooleanConstant(boolean value) {
        opcode = Opcode.CONSTANT;
        childClasses = new ArrayList<>();
        isCommutative = false;
        maxArity = 0;
        flexibleArity = false;
        sourceName = Boolean.toString(value);
        sourceType = "Bool";
        alphaName = null;
        metatype = Metatype.BOOLEAN;
    }

    private void collapseToSetConstant(String name) {
        opcode = Opcode.GLOBALBINDING;
        childClasses = new ArrayList<>();
        isCommutative = false;
        maxArity = 0;
        flexibleArity = false;
        sourceName = name;
        sourceType = name;
        alphaName = null;
        metatype = Metatype.SET;
    }

    private static Boolean booleanConstantIn(List<EClassRef> children, boolean value) {
        for (EClassRef child : children) {
            EGraphNode representative = child.getEClass().getRepresentative();
            if (isBooleanConstant(representative, value)) {
                return value;
            }
        }
        return null;
    }

    private static List<EClassRef> removeBooleanConstant(List<EClassRef> children, boolean value) {
        List<EClassRef> filtered = new ArrayList<>();
        for (EClassRef child : children) {
            EGraphNode representative = child.getEClass().getRepresentative();
            if (!isBooleanConstant(representative, value)) {
                filtered.add(child);
            }
        }
        return filtered;
    }

    private static boolean isBooleanConstant(EGraphNode node, boolean value) {
        return node.getOpcode() == Opcode.CONSTANT && Boolean.toString(value).equals(node.getSourceName());
    }

    private static boolean containsSetConstant(List<EClassRef> children, String name) {
        for (EClassRef child : children) {
            if (isSetConstant(child.getEClass().getRepresentative(), name)) {
                return true;
            }
        }
        return false;
    }

    private static List<EClassRef> removeSetConstant(List<EClassRef> children, String name) {
        List<EClassRef> filtered = new ArrayList<>();
        for (EClassRef child : children) {
            if (!isSetConstant(child.getEClass().getRepresentative(), name)) {
                filtered.add(child);
            }
        }
        return filtered;
    }

    private static boolean isNone(EGraphNode node) {
        return isSetConstant(node, "none");
    }

    private static boolean isUniv(EGraphNode node) {
        return isSetConstant(node, "univ");
    }

    private static boolean isSetConstant(EGraphNode node, String name) {
        if (node == null) {
            return false;
        }
        String source = node.getSourceName();
        return (node.getOpcode() == Opcode.GLOBALBINDING || node.getOpcode() == Opcode.CONSTANT)
                && source != null
                && name.equalsIgnoreCase(source);
    }

    private static List<EClassRef> removeDuplicateInvocations(List<EClassRef> children) {
        List<EClassRef> unique = new ArrayList<>();
        Set<String> seen = new LinkedHashSet<>();
        for (EClassRef child : children) {
            String key = invocationKey(child);
            if (seen.add(key)) {
                unique.add(child);
            }
        }
        return unique;
    }

    private static boolean containsComplement(List<EClassRef> children) {
        for (int i = 0; i < children.size(); i++) {
            for (int j = i + 1; j < children.size(); j++) {
                if (areComplements(children.get(i), children.get(j))) {
                    return true;
                }
            }
        }
        return false;
    }

    private static boolean areComplements(EClassRef left, EClassRef right) {
        EGraphNode leftNode = left.getEClass().getRepresentative();
        EGraphNode rightNode = right.getEClass().getRepresentative();
        if (leftNode.opcode == Opcode.NOT && leftNode.childClasses.size() == 1) {
            return sameInvocation(leftNode.childClasses.get(0), right);
        }
        if (rightNode.opcode == Opcode.NOT && rightNode.childClasses.size() == 1) {
            return sameInvocation(left, rightNode.childClasses.get(0));
        }
        return dualOf(leftNode.opcode) == rightNode.opcode && sameOperands(leftNode, rightNode);
    }

    private static boolean sameOperands(EGraphNode left, EGraphNode right) {
        if (left.childClasses.size() != right.childClasses.size()) {
            return false;
        }
        if (left.sourceName != null ? !left.sourceName.equals(right.sourceName) : right.sourceName != null) {
            return false;
        }
        for (int i = 0; i < left.childClasses.size(); i++) {
            if (!sameInvocation(left.childClasses.get(i), right.childClasses.get(i))) {
                return false;
            }
        }
        return true;
    }

    private static Opcode dualOf(Opcode opcode) {
        switch (opcode) {
            case EQUALS:
                return Opcode.NOT_EQUALS;
            case NOT_EQUALS:
                return Opcode.EQUALS;
            case GT:
                return Opcode.LTE;
            case LTE:
                return Opcode.GT;
            case GTE:
                return Opcode.LT;
            case LT:
                return Opcode.GTE;
            case IN:
                return Opcode.NOT_IN;
            case NOT_IN:
                return Opcode.IN;
            case SOME:
                return Opcode.NO;
            case NO:
                return Opcode.SOME;
            default:
                return null;
        }
    }

    private static boolean sameInvocation(EClassRef left, EClassRef right) {
        if (left.equivalentTo(right)) {
            return true;
        }
        return invocationKey(left).equals(invocationKey(right));
    }

    private static String invocationKey(EClassRef invocation) {
        EClassRef canonical = invocation.canonical();
        return canonical.getEClass().getRepresentative().sortKey() + canonical.getSlotMap();
    }

    private static boolean isAssociative(Opcode opcode) {
        return opcode == Opcode.AND || opcode == Opcode.OR
                || opcode == Opcode.INTERSECT || opcode == Opcode.PLUS || opcode == Opcode.MUL
                || opcode == Opcode.IPLUS || opcode == Opcode.JOIN || opcode == Opcode.ARROW;
    }

    private static boolean isSetFlexibleArityOperator(Opcode opcode) {
        return opcode == Opcode.AND || opcode == Opcode.OR
                || opcode == Opcode.INTERSECT || opcode == Opcode.PLUS;
    }

    private String sortKey() {
        StringBuilder sb = new StringBuilder();
        appendSortKey(this, sb);
        return sb.toString();
    }

    private static void appendSortKey(EGraphNode node, StringBuilder sb) {
        sb.append(node.opcode).append('{').append(node.getFlexibleArityKind()).append("}:");
        if (node.alphaName != null) {
            sb.append(node.alphaName);
        } else if (node.sourceName != null) {
            sb.append(node.sourceName);
        } else if (node.childClasses == null || node.childClasses.isEmpty()) {
            sb.append(node.sourceType == null ? "" : node.sourceType);
        }
        sb.append('[');
        if (node.childClasses != null) {
            if (node.isSetFlexibleArity()) {
                Set<String> members = new java.util.TreeSet<>();
                for (EClassRef childRef : node.childClasses) {
                    members.add(invocationSortKey(childRef));
                }
                for (String member : members) {
                    sb.append(member).append(',');
                }
            } else if (node.isBagFlexibleArity()) {
                Map<String, Integer> multiplicities = new java.util.TreeMap<>();
                for (EClassRef childRef : node.childClasses) {
                    String key = invocationSortKey(childRef);
                    multiplicities.put(key, multiplicities.getOrDefault(key, 0) + 1);
                }
                for (Map.Entry<String, Integer> entry : multiplicities.entrySet()) {
                    sb.append(entry.getKey());
                    if (entry.getValue() > 1) {
                        sb.append('^').append(entry.getValue());
                    }
                    sb.append(',');
                }
            } else {
                for (EClassRef childRef : node.childClasses) {
                    sb.append(invocationSortKey(childRef)).append(',');
                }
            }
        }
        sb.append(']');
    }

    private static String invocationSortKey(EClassRef childRef) {
        StringBuilder key = new StringBuilder();
        appendSortKey(childRef.getEClass().getRepresentative(), key);
        key.append('@').append(childRef.getSlotMap());
        return key.toString();
    }

    private EGraphNode snapshot() {
        EGraphNode copy = new EGraphNode(
                id, opcode, Collections.emptyList(), isCommutative, maxArity, flexibleArity, metatype, false);
        copy.sourceName = sourceName;
        copy.sourceType = sourceType;
        copy.alphaName = alphaName;
        copy.childClasses = new ArrayList<>(childClasses);
        copy.eClass = eClass;
        return copy;
    }

    private void refreshEClassSlots() {
        if (eClass != null) {
            eClass.markSlotsDirty();
        }
    }

    private static Map<String, String> identitySlotMap(EClass eClass) {
        if (eClass.getSlots().isEmpty()) {
            return Collections.emptyMap();
        }
        Map<String, String> mapping = new LinkedHashMap<>();
        for (String slot : eClass.getSlots()) {
            mapping.put(slot, slot);
        }
        return mapping;
    }

    private static boolean sameChildren(List<EClassRef> left, List<EClassRef> right) {
        if (left.size() != right.size()) {
            return false;
        }
        for (int i = 0; i < left.size(); i++) {
            if (!left.get(i).equals(right.get(i))) {
                return false;
            }
        }
        return true;
    }

    private Set<String> slots() {
        Set<String> exposed = null;
        if (opcode == Opcode.VARIABLE) {
            String slot = alphaName != null ? alphaName : sourceName;
            if (slot != null) {
                exposed = new LinkedHashSet<>();
                exposed.add(slot);
            }
        }
        for (EClassRef child : childClasses) {
            if (!child.getSlotMap().isEmpty()) {
                if (exposed == null) {
                    exposed = new LinkedHashSet<>();
                }
                exposed.addAll(child.getSlotMap().values());
            }
        }
        return exposed == null ? Collections.emptySet() : exposed;
    }

    public static final class ReachabilityStats {
        public final long eclasses;
        public final long enodes;

        private ReachabilityStats(long eclasses, long enodes) {
            this.eclasses = eclasses;
            this.enodes = enodes;
        }
    }

    public static final class EClassRef {
        private final EClass eClass;
        private final Map<String, String> slotMap;

        private EClassRef(EClass eClass, Map<String, String> slotMap) {
            this.eClass = eClass;
            this.slotMap = slotMap.isEmpty()
                    ? Collections.emptyMap()
                    : Collections.unmodifiableMap(new LinkedHashMap<>(slotMap));
        }

        public EClass getEClass() {
            return eClass;
        }

        public Map<String, String> getSlotMap() {
            return slotMap;
        }

        public EClassRef canonical() {
            if (!eClass.registered) {
                Set<String> exposedSlots = eClass.getSlots();
                if (slotMap.keySet().equals(exposedSlots)) {
                    return this;
                }
                Map<String, String> restricted = new LinkedHashMap<>();
                for (String slot : exposedSlots) {
                    String callerSlot = slotMap.get(slot);
                    if (callerSlot != null) {
                        restricted.put(slot, callerSlot);
                    }
                }
                return new EClassRef(eClass, restricted);
            }
            RenamedId leader = eClass.arena.unionFind.find(asRenamedId());
            return new EClassRef(eClass.arena.classes.get(leader.getId()), leader.getRenaming());
        }

        public boolean equivalentTo(EClassRef other) {
            if (eClass.arena != other.eClass.arena) {
                return false;
            }
            EClassRef left = canonical();
            EClassRef right = other.canonical();
            return left.eClass.id == right.eClass.id
                    && left.eClass.equivalentInvocations(left.slotMap, right.slotMap);
        }

        private RenamedId asRenamedId() {
            return new RenamedId(eClass.getId(), slotMap);
        }

        @Override
        public boolean equals(Object other) {
            if (!(other instanceof EClassRef)) {
                return false;
            }
            EClassRef ref = (EClassRef) other;
            return eClass.getId() == ref.eClass.getId() && slotMap.equals(ref.slotMap);
        }

        @Override
        public int hashCode() {
            return 31 * eClass.getId() + slotMap.hashCode();
        }
    }

    public static final class EClass {
        private final int id;
        private final EGraphArena arena;
        private final List<EGraphNode> nodes = new ArrayList<>();
        private Set<String> slots = Collections.emptySet();
        private Set<String> shapes;
        private SlotPermutationGroup symmetries;
        private boolean registered;
        private boolean slotsDirty = true;

        private EClass(int id, EGraphNode head) {
            this.id = id;
            this.arena = head.arena;
            nodes.add(head);
        }

        public int getId() {
            return id;
        }

        public List<EGraphNode> getNodes() {
            return Collections.unmodifiableList(nodes);
        }

        public EGraphNode getRepresentative() {
            return nodes.get(0);
        }

        public Set<String> getSlots() {
            ensureSlots();
            return Collections.unmodifiableSet(slots);
        }

        public EClassRef invoke(Map<String, String> slotMap) {
            ensureSlots();
            if (!slotMap.keySet().equals(slots)) {
                throw new IllegalArgumentException("Invocation must map every exposed e-class slot");
            }
            return new EClassRef(this, slotMap);
        }

        public void addSlotSwap(String left, String right) {
            ensureSlots();
            symmetryGroup().addSwap(left, right);
        }

        public int symmetryCount() {
            ensureSlots();
            return symmetries == null ? 1 : symmetries.size();
        }

        private void addEquivalentNode(EGraphNode node) {
            String shape = node.sortKey();
            if (shapes == null) {
                shapes = new HashSet<>();
                for (EGraphNode existing : nodes) {
                    shapes.add(existing.sortKey());
                }
            }
            if (!shapes.add(shape)) {
                return;
            }
            node.eClass = this;
            nodes.add(node);
            recomputeSlots();
        }

        private void preserveSnapshot(EGraphNode node) {
            node.eClass = this;
            nodes.add(node);
        }

        private void recordShape(EGraphNode node) {
            if (shapes != null) {
                shapes.add(node.sortKey());
            }
        }

        private void recomputeSlots() {
            if (nodes.isEmpty()) {
                slots = Collections.emptySet();
                slotsDirty = false;
                return;
            }
            Set<String> common;
            if (nodes.size() == 1) {
                common = nodes.get(0).slots();
            } else if (slots.isEmpty()) {
                slotsDirty = false;
                return;
            } else {
                Set<String> representativeSlots = nodes.get(0).slots();
                if (representativeSlots.containsAll(slots)) {
                    slotsDirty = false;
                    return;
                }
                common = new LinkedHashSet<>(slots);
                common.retainAll(representativeSlots);
            }
            if (slots.equals(common)) {
                slotsDirty = false;
                return;
            }
            slots = common;
            slotsDirty = false;
            if (symmetries != null) {
                symmetries.setSlots(slots);
            }
            if (registered) {
                arena.unionFind.updateSlots(id, slots);
            }
        }

        private SlotPermutationGroup symmetryGroup() {
            ensureSlots();
            if (symmetries == null) {
                symmetries = new SlotPermutationGroup(slots);
            }
            return symmetries;
        }

        private void addInvocationEquivalence(Map<String, String> left, Map<String, String> right) {
            if (left.equals(right)) {
                return;
            }
            symmetryGroup().addInvocationEquivalence(left, right);
        }

        private boolean equivalentInvocations(Map<String, String> left, Map<String, String> right) {
            ensureSlots();
            return symmetries == null ? left.equals(right) : symmetries.equivalentInvocations(left, right);
        }

        private void ensureRegistered() {
            if (!registered) {
                ensureSlots();
                arena.classes.put(id, this);
                arena.unionFind.register(id, slots);
                registered = true;
            }
        }

        private void markSlotsDirty() {
            slotsDirty = true;
        }

        private void ensureSlots() {
            if (slotsDirty) {
                recomputeSlots();
            }
        }
    }

    private static final class EGraphArena {
        private final Map<Integer, EClass> classes = new LinkedHashMap<>();
        private final RenamedIdUnionFind unionFind = new RenamedIdUnionFind();
    }

}
