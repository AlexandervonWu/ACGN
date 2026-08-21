package is.fivefivefive.CanDis.core;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import is.fivefivefive.CanDis.core.NormalForm.TemporalOp;

/**
 * Specification and reference implementation of the CanDis repair metric over
 * repaired normal forms. Its decomposition, edit units, alpha minimization,
 * and unordered matching are metric semantics, not approximation heuristics.
 */
public final class CanonicalDistance {
    private static final ThreadLocal<MutableAllocationStats> ALLOCATION_TRACKER = new ThreadLocal<>();
    private static final OrderedTreeEditDistance.Adapter<TemporalTree> TEMPORAL_ADAPTER =
            new OrderedTreeEditDistance.Adapter<>() {
                @Override
                public String label(TemporalTree node) {
                    return node.label;
                }

                @Override
                public List<? extends TemporalTree> children(TemporalTree node) {
                    return node.children;
                }
            };

    private CanonicalDistance() {
    }

    public static void beginAllocationTracking() {
        ALLOCATION_TRACKER.set(new MutableAllocationStats());
    }

    public static AllocationStats endAllocationTracking() {
        MutableAllocationStats mutable = ALLOCATION_TRACKER.get();
        ALLOCATION_TRACKER.remove();
        return mutable == null ? new AllocationStats(0, 0, 0, 0)
                : new AllocationStats(mutable.bytes, mutable.peakBytes, mutable.arrays, mutable.matrices);
    }

    public static int distance(Prepared left, Prepared right) {
        return evaluate(left, right).distance();
    }

    /** Exposes the normative metric decomposition without changing its units. */
    public static DistanceBreakdown evaluate(Prepared left, Prepared right) {
        int temporalDistance = treeDistance(left.temporalTree, right.temporalTree);
        int quantificationDistance = quantificationDistance(left.normalForms, right.normalForms);
        int matrixDistance = matrixDistance(left.normalForms, right.normalForms, left.metadata, right.metadata);
        return new DistanceBreakdown(
                temporalDistance, quantificationDistance, matrixDistance);
    }

    public static final class DistanceBreakdown {
        private final int temporalDistance;
        private final int quantifierDistance;
        private final int matrixDistance;

        private DistanceBreakdown(
                int temporalDistance,
                int quantifierDistance,
                int matrixDistance) {
            this.temporalDistance = temporalDistance;
            this.quantifierDistance = quantifierDistance;
            this.matrixDistance = matrixDistance;
        }

        public int temporalDistance() {
            return temporalDistance;
        }

        public int quantifierDistance() {
            return quantifierDistance;
        }

        public int matrixDistance() {
            return matrixDistance;
        }

        public int distance() {
            return temporalDistance + quantifierDistance + matrixDistance;
        }
    }

    public static List<String> edits(Prepared left, Prepared right) {
        if (distance(left, right) == 0) {
            return java.util.Collections.singletonList("no-op");
        }
        List<String> edits = new ArrayList<>();
        temporalEdits(left.temporalTree, right.temporalTree, "temporal", edits);
        quantificationEdits(left.normalForms, right.normalForms, edits);
        matrixEdits(left.normalForms, right.normalForms, edits);
        if (edits.isEmpty()) {
            edits.add("no-op");
        }
        return edits;
    }

    public static List<String> irTemporalFol(Prepared prepared) {
        List<String> formulas = new ArrayList<>();
        for (int i = 0; i < prepared.normalForms.size(); i++) {
            NormalForm normalForm = prepared.normalForms.get(i);
            formulas.add(normalFormPath(normalForm, i) + " := " + quantifierPrefix(normalForm.getMatrixQuantiVars())
                    + eGraphFormula(normalForm.getMatrixEGraph()));
        }
        return formulas;
    }

    public static int canonicalFormSize(Prepared prepared) {
        return prepared.size;
    }

    public static Prepared prepare(List<NormalForm> normalForms) {
        if (normalForms == null) {
            throw new IllegalArgumentException("Normal forms cannot be null");
        }
        List<NormalForm> snapshot = new ArrayList<>(normalForms);
        validateCalls(snapshot);
        return new Prepared(snapshot, temporalTree(snapshot), canonicalFormSize(snapshot));
    }

    private static void validateCalls(List<NormalForm> normalForms) {
        Set<EGraphNode> seen = java.util.Collections.newSetFromMap(new IdentityHashMap<>());
        java.util.ArrayDeque<EGraphNode> pending = new java.util.ArrayDeque<>();
        for (NormalForm normalForm : normalForms) {
            if (normalForm != null && normalForm.getMatrixEGraph() != null) {
                pending.add(normalForm.getMatrixEGraph());
            }
        }
        while (!pending.isEmpty()) {
            EGraphNode node = pending.removeFirst();
            if (!seen.add(node)) {
                continue;
            }
            if (node.getOpcode() == EGraphNode.Opcode.CALL) {
                CallMetadata.require(node);
            }
            pending.addAll(node.getChildren());
        }
    }

    private static int canonicalFormSize(List<NormalForm> nfs) {
        int size = nfs.size();
        for (NormalForm nf : nfs) {
            size += eGraphSize(nf.getMatrixEGraph());
            size += quantificationSize(nf.getMatrixQuantiVars());
        }
        return size;
    }

    public static final class Prepared {
        private final List<NormalForm> normalForms;
        private final TemporalTree temporalTree;
        private final int size;
        private final EGraphMetadata metadata;
        private final EGraphNode.ReachabilityStats eGraphStats;

        private Prepared(List<NormalForm> normalForms, TemporalTree temporalTree, int size) {
            this.normalForms = normalForms;
            this.temporalTree = temporalTree;
            this.size = size;
            this.metadata = new EGraphMetadata(normalForms);
            List<EGraphNode> roots = new ArrayList<>(normalForms.size());
            for (NormalForm normalForm : normalForms) {
                if (normalForm.getMatrixEGraph() != null) {
                    roots.add(normalForm.getMatrixEGraph());
                }
            }
            this.eGraphStats = EGraphNode.countReachable(roots);
        }

        public long eclassCount() {
            return eGraphStats.eclasses;
        }

        public long enodeCount() {
            return eGraphStats.enodes;
        }

        public int canonicalSize() {
            return size;
        }

        public int normalFormCount() {
            return normalForms.size();
        }

        public int quantifierCount() {
            int count = 0;
            for (NormalForm normalForm : normalForms) {
                count += normalForm.getParams().size();
                count += normalForm.getMatrixQuantiVars().size();
                count += normalForm.getInheritedQuantiVars().size();
            }
            return count;
        }

        public int temporalNodeCount() {
            return temporalSize(temporalTree);
        }

        public int metadataEntryCount() {
            return metadata.sizes.size();
        }
    }

    private static int quantificationDistance(List<NormalForm> left, List<NormalForm> right) {
        int size = Math.max(left.size(), right.size());
        int distance = 0;
        for (int i = 0; i < size; i++) {
            if (i >= left.size()) {
                distance += quantificationSize(right.get(i).getMatrixQuantiVars());
            } else if (i >= right.size()) {
                distance += quantificationSize(left.get(i).getMatrixQuantiVars());
            } else {
                distance += bindingListDistance(left.get(i).getMatrixQuantiVars(), right.get(i).getMatrixQuantiVars());
            }
        }
        return distance;
    }

    private static int bindingListDistance(List<QuantiVar> left, List<QuantiVar> right) {
        left = canonicalQuantifierOrder(left);
        right = canonicalQuantifierOrder(right);
        int[][] dp = intMatrix(left.size() + 1, right.size() + 1);
        for (int i = 1; i <= left.size(); i++) {
            dp[i][0] = dp[i - 1][0] + 1;
        }
        for (int j = 1; j <= right.size(); j++) {
            dp[0][j] = dp[0][j - 1] + 1;
        }
        for (int i = 1; i <= left.size(); i++) {
            for (int j = 1; j <= right.size(); j++) {
                int delete = dp[i - 1][j] + 1;
                int insert = dp[i][j - 1] + 1;
                int update = dp[i - 1][j - 1] + quantifierUpdateCost(left.get(i - 1), right.get(j - 1));
                dp[i][j] = Math.min(update, Math.min(delete, insert));
            }
        }
        return dp[left.size()][right.size()];
    }

    private static int quantifierUpdateCost(QuantiVar left, QuantiVar right) {
        if (left.getQuantifier() == right.getQuantifier()
                && sameType(typeKey(left), typeKey(right))
                && left.getCardinality() == right.getCardinality()
                && left.getDisjointnessClass() == right.getDisjointnessClass()) {
            return 0;
        }
        return 1;
    }

    private static List<QuantiVar> canonicalQuantifierOrder(List<QuantiVar> variables) {
        List<QuantiVar> ordered = new ArrayList<>(variables);
        for (int start = 0; start < ordered.size();) {
            QuantiVar.Quantifier quantifier = ordered.get(start).getQuantifier();
            int end = start + 1;
            if (quantifier == QuantiVar.Quantifier.ALL || quantifier == QuantiVar.Quantifier.SOME) {
                while (end < ordered.size() && ordered.get(end).getQuantifier() == quantifier) {
                    end++;
                }
                ordered.subList(start, end).sort(CanonicalDistance::compareQuantifierTuple);
            }
            start = end;
        }
        return ordered;
    }

    private static int compareQuantifierTuple(QuantiVar left, QuantiVar right) {
        int comparison = normalizeType(typeKey(left)).compareTo(normalizeType(typeKey(right)));
        if (comparison != 0) {
            return comparison;
        }
        comparison = left.getCardinality().compareTo(right.getCardinality());
        if (comparison != 0) {
            return comparison;
        }
        return Integer.compare(left.getDisjointnessClass(), right.getDisjointnessClass());
    }

    private static int quantificationSize(List<QuantiVar> vars) {
        return vars == null ? 0 : vars.size();
    }

    private static void quantificationEdits(List<NormalForm> left, List<NormalForm> right, List<String> edits) {
        int size = Math.max(left.size(), right.size());
        for (int i = 0; i < size; i++) {
            NormalForm pathSource = i < left.size() ? left.get(i) : right.get(i);
            String path = normalFormPath(pathSource, i) + ".quantifier";
            if (i >= left.size()) {
                collectInsertedQuantifiers(right.get(i).getMatrixQuantiVars(), path, edits);
            } else if (i >= right.size()) {
                collectDeletedQuantifiers(left.get(i).getMatrixQuantiVars(), path, edits);
            } else {
                quantificationEdits(left.get(i).getMatrixQuantiVars(), right.get(i).getMatrixQuantiVars(), path, edits);
            }
        }
    }

    private static void quantificationEdits(
            List<QuantiVar> left,
            List<QuantiVar> right,
            String path,
            List<String> edits) {
        left = canonicalQuantifierOrder(left);
        right = canonicalQuantifierOrder(right);
        int[][] dp = quantificationDp(left, right);
        int i = left.size();
        int j = right.size();
        List<String> reversed = new ArrayList<>();
        while (i > 0 || j > 0) {
            if (i > 0 && dp[i][j] == dp[i - 1][j] + 1) {
                reversed.add(path + "[" + (i - 1) + "]: delete " + quantifierFormula(left.get(i - 1)));
                i--;
            } else if (j > 0 && dp[i][j] == dp[i][j - 1] + 1) {
                reversed.add(path + "[" + j + "]: insert " + quantifierFormula(right.get(j - 1)));
                j--;
            } else {
                if (quantifierUpdateCost(left.get(i - 1), right.get(j - 1)) != 0) {
                    reversed.add(path + "[" + (i - 1) + "]: modify "
                            + quantifierFormula(left.get(i - 1)) + " -> " + quantifierFormula(right.get(j - 1)));
                }
                i--;
                j--;
            }
        }
        appendReverse(reversed, edits);
    }

    private static int[][] quantificationDp(List<QuantiVar> left, List<QuantiVar> right) {
        int[][] dp = intMatrix(left.size() + 1, right.size() + 1);
        for (int i = 1; i <= left.size(); i++) {
            dp[i][0] = dp[i - 1][0] + 1;
        }
        for (int j = 1; j <= right.size(); j++) {
            dp[0][j] = dp[0][j - 1] + 1;
        }
        for (int i = 1; i <= left.size(); i++) {
            for (int j = 1; j <= right.size(); j++) {
                int delete = dp[i - 1][j] + 1;
                int insert = dp[i][j - 1] + 1;
                int update = dp[i - 1][j - 1] + quantifierUpdateCost(left.get(i - 1), right.get(j - 1));
                dp[i][j] = Math.min(update, Math.min(delete, insert));
            }
        }
        return dp;
    }

    private static void collectInsertedQuantifiers(List<QuantiVar> vars, String path, List<String> edits) {
        for (int i = 0; i < vars.size(); i++) {
            edits.add(path + "[" + i + "]: insert " + quantifierFormula(vars.get(i)));
        }
    }

    private static void collectDeletedQuantifiers(List<QuantiVar> vars, String path, List<String> edits) {
        for (int i = 0; i < vars.size(); i++) {
            edits.add(path + "[" + i + "]: delete " + quantifierFormula(vars.get(i)));
        }
    }

    private static int matrixDistance(List<NormalForm> left, List<NormalForm> right) {
        return matrixDistance(left, right, null, null);
    }

    private static int matrixDistance(
            List<NormalForm> left,
            List<NormalForm> right,
            EGraphMetadata leftMetadata,
            EGraphMetadata rightMetadata) {
        int size = Math.max(left.size(), right.size());
        int distance = 0;
        for (int i = 0; i < size; i++) {
            if (i >= left.size()) {
                distance += eGraphSize(right.get(i).getMatrixEGraph(), rightMetadata);
            } else if (i >= right.size()) {
                distance += eGraphSize(left.get(i).getMatrixEGraph(), leftMetadata);
            } else {
                distance += matrixDistance(left.get(i), right.get(i), leftMetadata, rightMetadata);
            }
        }
        return distance;
    }

    private static int matrixDistance(NormalForm left, NormalForm right) {
        return matrixDistance(left, right, null, null);
    }

    private static int matrixDistance(
            NormalForm left,
            NormalForm right,
            EGraphMetadata leftMetadata,
            EGraphMetadata rightMetadata) {
        Map<String, BindingDescriptor> leftBindings = variableBindings(left);
        Map<String, BindingDescriptor> rightBindings = variableBindings(right);
        leftBindings.keySet().retainAll(matrixVariableNames(left.getMatrixEGraph()));
        rightBindings.keySet().retainAll(matrixVariableNames(right.getMatrixEGraph()));
        List<String> leftNames = new ArrayList<>(leftBindings.keySet());
        leftNames.sort((a, b) -> Integer.compare(
                candidateCount(a, leftBindings, rightBindings),
                candidateCount(b, leftBindings, rightBindings)));
        Map<String, String> mapping = new HashMap<>();
        int requiredMatches = maximumCompatibleMatches(
                leftNames, leftBindings, rightBindings);
        return bestMappedDistance(
                left.getMatrixEGraph(),
                right.getMatrixEGraph(),
                leftNames,
                leftBindings,
                rightBindings,
                mapping,
                new HashSet<>(),
                0,
                0,
                requiredMatches,
                Integer.MAX_VALUE,
                leftMetadata,
                rightMetadata);
    }

    private static void matrixEdits(List<NormalForm> left, List<NormalForm> right, List<String> edits) {
        int size = Math.max(left.size(), right.size());
        for (int i = 0; i < size; i++) {
            NormalForm pathSource = i < left.size() ? left.get(i) : right.get(i);
            String path = normalFormPath(pathSource, i) + ".matrix";
            if (i >= left.size()) {
                collectInsertedEGraph(right.get(i).getMatrixEGraph(), path, edits);
            } else if (i >= right.size()) {
                collectDeletedEGraph(left.get(i).getMatrixEGraph(), path, edits);
            } else {
                matrixEdits(left.get(i), right.get(i), path, edits);
            }
        }
    }

    private static void matrixEdits(NormalForm left, NormalForm right, String path, List<String> edits) {
        Map<String, String> mapping = bestVariableMapping(left, right);
        eGraphEdits(left.getMatrixEGraph(), right.getMatrixEGraph(), mapping, path, edits);
    }

    private static Map<String, String> bestVariableMapping(NormalForm left, NormalForm right) {
        Map<String, BindingDescriptor> leftBindings = variableBindings(left);
        Map<String, BindingDescriptor> rightBindings = variableBindings(right);
        leftBindings.keySet().retainAll(matrixVariableNames(left.getMatrixEGraph()));
        rightBindings.keySet().retainAll(matrixVariableNames(right.getMatrixEGraph()));
        List<String> leftNames = new ArrayList<>(leftBindings.keySet());
        leftNames.sort((a, b) -> Integer.compare(
                candidateCount(a, leftBindings, rightBindings),
                candidateCount(b, leftBindings, rightBindings)));
        BestMapping best = new BestMapping();
        int requiredMatches = maximumCompatibleMatches(
                leftNames, leftBindings, rightBindings);
        searchBestMapping(
                left.getMatrixEGraph(),
                right.getMatrixEGraph(),
                leftNames,
                leftBindings,
                rightBindings,
                new HashMap<>(),
                new HashSet<>(),
                0,
                0,
                requiredMatches,
                best);
        return best.mapping;
    }

    private static void searchBestMapping(
            EGraphNode left,
            EGraphNode right,
            List<String> leftNames,
            Map<String, BindingDescriptor> leftBindings,
            Map<String, BindingDescriptor> rightBindings,
            Map<String, String> mapping,
            Set<String> usedRightNames,
            int index,
            int matched,
            int requiredMatches,
            BestMapping best) {
        if (index == leftNames.size()) {
            if (matched != requiredMatches) {
                return;
            }
            int distance = eGraphDistance(left, right, mapping);
            if (distance < best.distance) {
                best.distance = distance;
                best.mapping = new HashMap<>(mapping);
            }
            return;
        }
        String leftName = leftNames.get(index);
        BindingDescriptor leftBinding = leftBindings.get(leftName);
        boolean mapped = false;
        for (Map.Entry<String, BindingDescriptor> rightEntry : rightBindings.entrySet()) {
            if (usedRightNames.contains(rightEntry.getKey())
                    || !leftBinding.compatibleWith(rightEntry.getValue())) {
                continue;
            }
            mapped = true;
            mapping.put(leftName, rightEntry.getKey());
            usedRightNames.add(rightEntry.getKey());
            searchBestMapping(left, right, leftNames, leftBindings, rightBindings,
                    mapping, usedRightNames, index + 1,
                    matched + 1, requiredMatches, best);
            usedRightNames.remove(rightEntry.getKey());
            mapping.remove(leftName);
            if (best.distance == 0) {
                return;
            }
        }
        if (!mapped || matched + leftNames.size() - index - 1 >= requiredMatches) {
            searchBestMapping(left, right, leftNames, leftBindings, rightBindings,
                    mapping, usedRightNames, index + 1,
                    matched, requiredMatches, best);
        }
    }

    private static int candidateCount(
            String leftName,
            Map<String, BindingDescriptor> leftBindings,
            Map<String, BindingDescriptor> rightBindings) {
        int count = 0;
        BindingDescriptor leftBinding = leftBindings.get(leftName);
        for (BindingDescriptor rightBinding : rightBindings.values()) {
            if (leftBinding.compatibleWith(rightBinding)) {
                count++;
            }
        }
        return count;
    }

    private static int bestMappedDistance(
            EGraphNode left,
            EGraphNode right,
            List<String> leftNames,
            Map<String, BindingDescriptor> leftBindings,
            Map<String, BindingDescriptor> rightBindings,
            Map<String, String> mapping,
            Set<String> usedRightNames,
            int index,
            int matched,
            int requiredMatches,
            int best,
            EGraphMetadata leftMetadata,
            EGraphMetadata rightMetadata) {
        if (index == leftNames.size()) {
            if (matched != requiredMatches) {
                return best;
            }
            return Math.min(best, eGraphDistance(left, right, mapping, leftMetadata, rightMetadata));
        }
        String leftName = leftNames.get(index);
        BindingDescriptor leftBinding = leftBindings.get(leftName);
        boolean mapped = false;
        for (Map.Entry<String, BindingDescriptor> rightEntry : rightBindings.entrySet()) {
            if (usedRightNames.contains(rightEntry.getKey())
                    || !leftBinding.compatibleWith(rightEntry.getValue())) {
                continue;
            }
            mapped = true;
            mapping.put(leftName, rightEntry.getKey());
            usedRightNames.add(rightEntry.getKey());
            best = bestMappedDistance(
                    left,
                    right,
                    leftNames,
                    leftBindings,
                    rightBindings,
                    mapping,
                    usedRightNames,
                    index + 1,
                    matched + 1,
                    requiredMatches,
                    best,
                    leftMetadata,
                    rightMetadata);
            usedRightNames.remove(rightEntry.getKey());
            mapping.remove(leftName);
            if (best == 0) {
                return 0;
            }
        }
        if (!mapped || matched + leftNames.size() - index - 1 >= requiredMatches) {
            best = bestMappedDistance(
                    left,
                    right,
                    leftNames,
                    leftBindings,
                    rightBindings,
                    mapping,
                    usedRightNames,
                    index + 1,
                    matched,
                    requiredMatches,
                    best,
                    leftMetadata,
                    rightMetadata);
        }
        return best;
    }

    private static int maximumCompatibleMatches(
            List<String> leftNames,
            Map<String, BindingDescriptor> leftBindings,
            Map<String, BindingDescriptor> rightBindings) {
        Map<String, String> matchedLeftByRight = new HashMap<>();
        int result = 0;
        for (String leftName : leftNames) {
            if (augmentCompatibleMatching(
                    leftName,
                    leftBindings,
                    rightBindings,
                    matchedLeftByRight,
                    new HashSet<>())) {
                result++;
            }
        }
        return result;
    }

    private static boolean augmentCompatibleMatching(
            String leftName,
            Map<String, BindingDescriptor> leftBindings,
            Map<String, BindingDescriptor> rightBindings,
            Map<String, String> matchedLeftByRight,
            Set<String> visitedRight) {
        BindingDescriptor left = leftBindings.get(leftName);
        for (Map.Entry<String, BindingDescriptor> right : rightBindings.entrySet()) {
            if (!visitedRight.add(right.getKey())
                    || !left.compatibleWith(right.getValue())) {
                continue;
            }
            String previousLeft = matchedLeftByRight.get(right.getKey());
            if (previousLeft == null
                    || augmentCompatibleMatching(
                            previousLeft,
                            leftBindings,
                            rightBindings,
                            matchedLeftByRight,
                            visitedRight)) {
                matchedLeftByRight.put(right.getKey(), leftName);
                return true;
            }
        }
        return false;
    }

    private static Map<String, BindingDescriptor> variableBindings(NormalForm nf) {
        Map<String, BindingDescriptor> bindings = new HashMap<>();
        addBindings(bindings, nf.getParams(), BindingRole.PARAMETER);
        addBindings(bindings, nf.getMatrixQuantiVars(), BindingRole.MATRIX);
        addBindings(bindings, nf.getInheritedQuantiVars(), BindingRole.INHERITED);
        return bindings;
    }

    private static void addBindings(
            Map<String, BindingDescriptor> bindings,
            List<QuantiVar> variables,
            BindingRole role) {
        for (int i = 0; i < variables.size(); i++) {
            QuantiVar variable = variables.get(i);
            bindings.put(variable.getName(), new BindingDescriptor(variable, role, i));
        }
    }

    private static Set<String> matrixVariableNames(EGraphNode node) {
        Set<String> names = new HashSet<>();
        collectMatrixVariableNames(node, names);
        return names;
    }

    private static void collectMatrixVariableNames(EGraphNode node, Set<String> names) {
        if (node == null) {
            return;
        }
        if (node.getOpcode() == EGraphNode.Opcode.VARIABLE) {
            names.add(variableName(node));
        }
        for (EGraphNode child : node.getChildren()) {
            collectMatrixVariableNames(child, names);
        }
    }

    private static void eGraphEdits(
            EGraphNode left,
            EGraphNode right,
            Map<String, String> variableMapping,
            String path,
            List<String> edits) {
        if (left == null) {
            collectInsertedEGraph(right, path, edits);
            return;
        }
        if (right == null) {
            collectDeletedEGraph(left, path, edits);
            return;
        }
        if (left.getOpcode() == right.getOpcode()
                && left.isOrderInsensitive()
                && right.isOrderInsensitive()
                && eGraphDistance(left, right, variableMapping) == 0) {
            return;
        }
        if (left.getOpcode() != right.getOpcode()) {
            edits.add(path + ": replace " + nodeSummary(left) + " -> " + nodeSummary(right));
        } else if (left.getOpcode() == EGraphNode.Opcode.VARIABLE) {
            String leftName = variableName(left);
            String rightName = variableName(right);
            String mappedName = variableMapping.get(leftName);
            if (mappedName != null && !mappedName.equals(rightName)) {
                edits.add(path + ": replace variable " + nodeVariableDisplay(left) + " -> " + nodeVariableDisplay(right));
            } else if (mappedName == null && !leftName.equals(rightName)) {
                edits.add(path + ": replace variable " + nodeVariableDisplay(left) + " -> " + nodeVariableDisplay(right));
            }
        } else if ((left.getOpcode() == EGraphNode.Opcode.GLOBALBINDING
                || left.getOpcode() == EGraphNode.Opcode.CONSTANT
                || left.getOpcode() == EGraphNode.Opcode.REF)
                && !safeEquals(left.getSourceName(), right.getSourceName())) {
            edits.add(path + ": replace binding " + display(left.getSourceName()) + " -> " + display(right.getSourceName()));
        }
        List<EGraphNode> leftChildren = left.getChildren();
        List<EGraphNode> rightChildren = right.getChildren();
        if (left.getOpcode() == right.getOpcode() && left.isOrderInsensitive() && right.isOrderInsensitive()) {
            leftChildren = sortedForMapping(leftChildren, variableMapping);
            rightChildren = sortedForMapping(rightChildren, java.util.Collections.emptyMap());
        }
        eGraphChildEdits(leftChildren, rightChildren, variableMapping, path + ".child", edits);
    }

    private static void eGraphChildEdits(
            List<EGraphNode> left,
            List<EGraphNode> right,
            Map<String, String> variableMapping,
            String path,
            List<String> edits) {
        int[][] dp = eGraphChildDp(left, right, variableMapping);
        int i = left.size();
        int j = right.size();
        List<String> reversed = new ArrayList<>();
        while (i > 0 || j > 0) {
            if (i > 0 && dp[i][j] == dp[i - 1][j] + eGraphSize(left.get(i - 1))) {
                collectDeletedEGraph(left.get(i - 1), path + "[" + (i - 1) + "]", reversed);
                i--;
            } else if (j > 0 && dp[i][j] == dp[i][j - 1] + eGraphSize(right.get(j - 1))) {
                collectInsertedEGraph(right.get(j - 1), path + "[" + j + "]", reversed);
                j--;
            } else {
                eGraphEdits(left.get(i - 1), right.get(j - 1), variableMapping, path + "[" + (i - 1) + "]", reversed);
                i--;
                j--;
            }
        }
        appendReverse(reversed, edits);
    }

    private static int[][] eGraphChildDp(
            List<EGraphNode> left,
            List<EGraphNode> right,
            Map<String, String> variableMapping) {
        int[][] dp = intMatrix(left.size() + 1, right.size() + 1);
        for (int i = 1; i <= left.size(); i++) {
            dp[i][0] = dp[i - 1][0] + eGraphSize(left.get(i - 1));
        }
        for (int j = 1; j <= right.size(); j++) {
            dp[0][j] = dp[0][j - 1] + eGraphSize(right.get(j - 1));
        }
        for (int i = 1; i <= left.size(); i++) {
            for (int j = 1; j <= right.size(); j++) {
                int delete = dp[i - 1][j] + eGraphSize(left.get(i - 1));
                int insert = dp[i][j - 1] + eGraphSize(right.get(j - 1));
                int update = dp[i - 1][j - 1] + eGraphDistance(left.get(i - 1), right.get(j - 1), variableMapping);
                dp[i][j] = Math.min(update, Math.min(delete, insert));
            }
        }
        return dp;
    }

    private static void collectInsertedEGraph(EGraphNode node, String path, List<String> edits) {
        if (node == null) {
            return;
        }
        edits.add(path + ": insert " + nodeSummary(node));
        for (int i = 0; i < node.getChildren().size(); i++) {
            collectInsertedEGraph(node.getChildren().get(i), path + ".child[" + i + "]", edits);
        }
    }

    private static void collectDeletedEGraph(EGraphNode node, String path, List<String> edits) {
        if (node == null) {
            return;
        }
        edits.add(path + ": delete " + nodeSummary(node));
        for (int i = 0; i < node.getChildren().size(); i++) {
            collectDeletedEGraph(node.getChildren().get(i), path + ".child[" + i + "]", edits);
        }
    }

    private static int eGraphDistance(EGraphNode left, EGraphNode right, Map<String, String> variableMapping) {
        return eGraphDistance(left, right, variableMapping, null, null);
    }

    private static int eGraphDistance(
            EGraphNode left,
            EGraphNode right,
            Map<String, String> variableMapping,
            EGraphMetadata leftMetadata,
            EGraphMetadata rightMetadata) {
        return new EGraphDistanceContext(variableMapping, leftMetadata, rightMetadata).distance(left, right);
    }

    private static List<EGraphNode> sortedForMapping(
            List<EGraphNode> children,
            Map<String, String> variableMapping) {
        List<EGraphNode> sorted = new ArrayList<>(children);
        Map<EGraphNode, String> keys = new IdentityHashMap<>();
        for (EGraphNode child : sorted) {
            keys.put(child, mappedSortKey(child, variableMapping));
        }
        sorted.sort((left, right) -> keys.get(left).compareTo(keys.get(right)));
        return sorted;
    }

    private static String mappedSortKey(EGraphNode node, Map<String, String> variableMapping) {
        StringBuilder key = new StringBuilder(node.getOpcode().toString())
                .append('{').append(node.getFlexibleArityKind()).append("}:");
        if (node.getOpcode() == EGraphNode.Opcode.VARIABLE) {
            String name = variableName(node);
            key.append(variableMapping.getOrDefault(name, name));
        } else if (node.getOpcode() == EGraphNode.Opcode.CALL) {
            key.append(callIdentity(node));
        } else if (node.getSourceName() != null) {
            key.append(atomIdentity(node));
        }
        key.append('[');
        List<EGraphNode> children = new ArrayList<>(node.getChildren());
        if (node.isOrderInsensitive()) {
            children = sortedForMapping(children, variableMapping);
        }
        if (node.isSetFlexibleArity()) {
            java.util.Set<String> members = new java.util.TreeSet<>();
            for (EGraphNode child : children) {
                members.add(mappedSortKey(child, variableMapping));
            }
            for (String member : members) {
                key.append(member).append(',');
            }
        } else if (node.isBagFlexibleArity()) {
            Map<String, Integer> multiplicities = new java.util.TreeMap<>();
            for (EGraphNode child : children) {
                String childKey = mappedSortKey(child, variableMapping);
                multiplicities.put(childKey, multiplicities.getOrDefault(childKey, 0) + 1);
            }
            for (Map.Entry<String, Integer> entry : multiplicities.entrySet()) {
                key.append(entry.getKey());
                if (entry.getValue() > 1) {
                    key.append('^').append(entry.getValue());
                }
                key.append(',');
            }
        } else {
            for (EGraphNode child : children) {
                key.append(mappedSortKey(child, variableMapping)).append(',');
            }
        }
        return key.append(']').toString();
    }

    private static int nodeUpdateCost(EGraphNode left, EGraphNode right, Map<String, String> variableMapping) {
        if (left.getOpcode() != right.getOpcode()) {
            return 1;
        }
        if (left.getOpcode() == EGraphNode.Opcode.VARIABLE) {
            String leftName = variableName(left);
            String rightName = variableName(right);
            String mappedName = variableMapping.get(leftName);
            if (mappedName != null) {
                return mappedName.equals(rightName) ? 0 : 1;
            }
            return leftName.equals(rightName) ? 0 : 1;
        }
        if (left.getOpcode() == EGraphNode.Opcode.GLOBALBINDING
                || left.getOpcode() == EGraphNode.Opcode.CONSTANT
                || left.getOpcode() == EGraphNode.Opcode.REF) {
            return safeEquals(atomIdentity(left), atomIdentity(right)) ? 0 : 1;
        }
        if (left.getOpcode() == EGraphNode.Opcode.CALL) {
            return safeEquals(callIdentity(left), callIdentity(right)) ? 0 : 1;
        }
        return 0;
    }

    private static String callIdentity(EGraphNode node) {
        return CallMetadata.semanticKey(node);
    }

    private static String atomIdentity(EGraphNode node) {
        return node.getSemanticIdentity() == null
                ? node.getSourceName()
                : node.getSemanticIdentity();
    }

    private static final class EGraphMetadata {
        private final IdentityHashMap<EGraphNode, Integer> sizes = new IdentityHashMap<>();

        private EGraphMetadata(List<NormalForm> normalForms) {
            for (NormalForm normalForm : normalForms) {
                prepare(normalForm.getMatrixEGraph());
            }
        }

        private void prepare(EGraphNode node) {
            if (node == null || sizes.containsKey(node)) {
                return;
            }
            List<EGraphNode> children = node.getChildren();
            int size = 1;
            for (int i = 0; i < children.size(); i++) {
                EGraphNode child = children.get(i);
                prepare(child);
                size += sizes.get(child);
            }
            sizes.put(node, size);
        }

        private int size(EGraphNode node) {
            if (node == null) {
                return 0;
            }
            Integer size = sizes.get(node);
            if (size == null) {
                prepare(node);
                size = sizes.get(node);
            }
            return size;
        }

    }

    private static final class EGraphDistanceContext {
        private final Map<String, String> variableMapping;
        private final EGraphMetadata leftMetadata;
        private final EGraphMetadata rightMetadata;

        private EGraphDistanceContext(
                Map<String, String> variableMapping,
                EGraphMetadata leftMetadata,
                EGraphMetadata rightMetadata) {
            this.variableMapping = variableMapping;
            this.leftMetadata = leftMetadata;
            this.rightMetadata = rightMetadata;
        }

        private int distance(EGraphNode left, EGraphNode right) {
            if (left == null) {
                return nodeSize(right, false);
            }
            if (right == null) {
                return nodeSize(left, true);
            }

            List<EGraphNode> leftChildren = left.getChildren();
            List<EGraphNode> rightChildren = right.getChildren();
            int childCost = left.getOpcode() == right.getOpcode()
                    && left.isOrderInsensitive()
                    && right.isOrderInsensitive()
                    ? unorderedChildDistance(leftChildren, rightChildren)
                    : childDistance(leftChildren, rightChildren);
            return nodeUpdateCost(left, right, variableMapping) + childCost;
        }

        private int unorderedChildDistance(List<EGraphNode> left, List<EGraphNode> right) {
            if (left.isEmpty() || right.isEmpty()) {
                return childDistance(left, right);
            }
            int leftSize = left.size();
            int rightSize = right.size();
            int dimension = leftSize + rightSize;
            int[][] costs = intMatrix(dimension, dimension);
            for (int i = 0; i < dimension; i++) {
                for (int j = 0; j < dimension; j++) {
                    if (i < leftSize && j < rightSize) {
                        costs[i][j] = distance(left.get(i), right.get(j));
                    } else if (i < leftSize) {
                        costs[i][j] = nodeSize(left.get(i), true);
                    } else if (j < rightSize) {
                        costs[i][j] = nodeSize(right.get(j), false);
                    }
                }
            }
            return minimumAssignmentCost(costs);
        }

        private static int minimumAssignmentCost(int[][] costs) {
            int size = costs.length;
            int[] rowPotential = intArray(size + 1);
            int[] columnPotential = intArray(size + 1);
            int[] columnMatch = intArray(size + 1);
            int[] predecessor = intArray(size + 1);
            for (int row = 1; row <= size; row++) {
                columnMatch[0] = row;
                int column = 0;
                int[] minimum = intArray(size + 1);
                java.util.Arrays.fill(minimum, Integer.MAX_VALUE);
                boolean[] used = booleanArray(size + 1);
                do {
                    used[column] = true;
                    int matchedRow = columnMatch[column];
                    int delta = Integer.MAX_VALUE;
                    int nextColumn = 0;
                    for (int candidate = 1; candidate <= size; candidate++) {
                        if (used[candidate]) {
                            continue;
                        }
                        int reduced = costs[matchedRow - 1][candidate - 1]
                                - rowPotential[matchedRow] - columnPotential[candidate];
                        if (reduced < minimum[candidate]) {
                            minimum[candidate] = reduced;
                            predecessor[candidate] = column;
                        }
                        if (minimum[candidate] < delta) {
                            delta = minimum[candidate];
                            nextColumn = candidate;
                        }
                    }
                    for (int candidate = 0; candidate <= size; candidate++) {
                        if (used[candidate]) {
                            rowPotential[columnMatch[candidate]] += delta;
                            columnPotential[candidate] -= delta;
                        } else {
                            minimum[candidate] -= delta;
                        }
                    }
                    column = nextColumn;
                } while (columnMatch[column] != 0);
                do {
                    int previous = predecessor[column];
                    columnMatch[column] = columnMatch[previous];
                    column = previous;
                } while (column != 0);
            }
            return -columnPotential[0];
        }

        private int childDistance(List<EGraphNode> left, List<EGraphNode> right) {
            if (left.isEmpty()) {
                int distance = 0;
                for (int i = 0; i < right.size(); i++) {
                    distance += nodeSize(right.get(i), false);
                }
                return distance;
            }
            if (right.isEmpty()) {
                int distance = 0;
                for (int i = 0; i < left.size(); i++) {
                    distance += nodeSize(left.get(i), true);
                }
                return distance;
            }
            if (left.size() == 1 && right.size() == 1) {
                return distance(left.get(0), right.get(0));
            }

            int[] previous = intArray(right.size() + 1);
            int[] current = intArray(right.size() + 1);
            for (int j = 1; j <= right.size(); j++) {
                previous[j] = previous[j - 1] + nodeSize(right.get(j - 1), false);
            }
            for (int i = 1; i <= left.size(); i++) {
                current[0] = previous[0] + nodeSize(left.get(i - 1), true);
                for (int j = 1; j <= right.size(); j++) {
                    int delete = previous[j] + nodeSize(left.get(i - 1), true);
                    int insert = current[j - 1] + nodeSize(right.get(j - 1), false);
                    int update = previous[j - 1] + distance(left.get(i - 1), right.get(j - 1));
                    current[j] = Math.min(update, Math.min(delete, insert));
                }
                int[] swap = previous;
                previous = current;
                current = swap;
            }
            return previous[right.size()];
        }

        private int nodeSize(EGraphNode node, boolean leftSide) {
            EGraphMetadata metadata = leftSide ? leftMetadata : rightMetadata;
            return metadata == null ? eGraphSize(node) : metadata.size(node);
        }

    }

    private static int eGraphSize(EGraphNode node) {
        if (node == null) {
            return 0;
        }
        int size = 1;
        List<EGraphNode> children = node.getChildren();
        for (int i = 0; i < children.size(); i++) {
            size += eGraphSize(children.get(i));
        }
        return size;
    }

    private static int eGraphSize(EGraphNode node, EGraphMetadata metadata) {
        return metadata == null ? eGraphSize(node) : metadata.size(node);
    }

    private static TemporalTree temporalTree(List<NormalForm> nfs) {
        TemporalTree root = new TemporalTree(naturalTemporalLabel(TemporalOp.NONE));
        if (nfs.isEmpty()) {
            return root;
        }
        appendTemporalChildren(root, nfs.get(0).getTemporalChildren());
        return root;
    }

    private static TemporalTree temporalTree(NormalForm nf) {
        TemporalTree tree = new TemporalTree(naturalTemporalLabel(nf.getTemporalOp()));
        appendTemporalChildren(tree, nf.getTemporalChildren());
        return tree;
    }

    private static void appendTemporalChildren(TemporalTree parent, List<NormalForm> children) {
        for (int i = 0; i < children.size(); i++) {
            NormalForm child = children.get(i);
            if (isLeftBinaryTemporal(child.getTemporalOp())
                    && i + 1 < children.size()
                    && matchingRightBinaryTemporal(child.getTemporalOp()) == children.get(i + 1).getTemporalOp()) {
                TemporalTree binary = new TemporalTree(naturalTemporalLabel(child.getTemporalOp()));
                appendTemporalChildren(binary, child.getTemporalChildren());
                appendTemporalChildren(binary, children.get(i + 1).getTemporalChildren());
                parent.children.add(binary);
                i++;
            } else {
                parent.children.add(temporalTree(child));
            }
        }
    }

    private static boolean isLeftBinaryTemporal(TemporalOp op) {
        return op == TemporalOp.UNTILL || op == TemporalOp.RELEASESL
                || op == TemporalOp.SINCEL || op == TemporalOp.TRIGGEREDL;
    }

    private static TemporalOp matchingRightBinaryTemporal(TemporalOp op) {
        switch (op) {
            case UNTILL:
                return TemporalOp.UNTILR;
            case RELEASESL:
                return TemporalOp.RELEASESR;
            case SINCEL:
                return TemporalOp.SINCER;
            case TRIGGEREDL:
                return TemporalOp.TRIGGEREDR;
            default:
                return op;
        }
    }

    private static String naturalTemporalLabel(TemporalOp op) {
        switch (op) {
            case UNTILL:
            case UNTILR:
                return "UNTIL";
            case RELEASESL:
            case RELEASESR:
                return "RELEASES";
            case SINCEL:
            case SINCER:
                return "SINCE";
            case TRIGGEREDL:
            case TRIGGEREDR:
                return "TRIGGERED";
            default:
                return op.toString();
        }
    }

    private static int treeDistance(TemporalTree left, TemporalTree right) {
        return OrderedTreeEditDistance.distance(left, right, TEMPORAL_ADAPTER);
    }

    private static int temporalSize(TemporalTree node) {
        int size = 1;
        for (TemporalTree child : node.children) {
            size += temporalSize(child);
        }
        return size;
    }

    private static void temporalEdits(TemporalTree left, TemporalTree right, String path, List<String> edits) {
        if (!safeEquals(left.label, right.label)) {
            edits.add(path + ": replace " + left.label + " -> " + right.label);
        }
        int[][] dp = temporalForestDp(left.children, right.children);
        int i = left.children.size();
        int j = right.children.size();
        List<String> reversed = new ArrayList<>();
        while (i > 0 || j > 0) {
            if (i > 0 && dp[i][j] == dp[i - 1][j] + temporalSize(left.children.get(i - 1))) {
                collectDeletedTemporal(left.children.get(i - 1), path + ".child[" + (i - 1) + "]", reversed);
                i--;
            } else if (j > 0 && dp[i][j] == dp[i][j - 1] + temporalSize(right.children.get(j - 1))) {
                collectInsertedTemporal(right.children.get(j - 1), path + ".child[" + j + "]", reversed);
                j--;
            } else {
                temporalEdits(left.children.get(i - 1), right.children.get(j - 1), path + ".child[" + (i - 1) + "]", reversed);
                i--;
                j--;
            }
        }
        appendReverse(reversed, edits);
    }

    private static int[][] temporalForestDp(List<TemporalTree> left, List<TemporalTree> right) {
        int[][] dp = intMatrix(left.size() + 1, right.size() + 1);
        for (int i = 1; i <= left.size(); i++) {
            dp[i][0] = dp[i - 1][0] + temporalSize(left.get(i - 1));
        }
        for (int j = 1; j <= right.size(); j++) {
            dp[0][j] = dp[0][j - 1] + temporalSize(right.get(j - 1));
        }
        for (int i = 1; i <= left.size(); i++) {
            for (int j = 1; j <= right.size(); j++) {
                int delete = dp[i - 1][j] + temporalSize(left.get(i - 1));
                int insert = dp[i][j - 1] + temporalSize(right.get(j - 1));
                int update = dp[i - 1][j - 1] + treeDistance(left.get(i - 1), right.get(j - 1));
                dp[i][j] = Math.min(update, Math.min(delete, insert));
            }
        }
        return dp;
    }

    private static void collectInsertedTemporal(TemporalTree node, String path, List<String> edits) {
        edits.add(path + ": insert temporal " + node.label);
        for (int i = 0; i < node.children.size(); i++) {
            collectInsertedTemporal(node.children.get(i), path + ".child[" + i + "]", edits);
        }
    }

    private static void collectDeletedTemporal(TemporalTree node, String path, List<String> edits) {
        edits.add(path + ": delete temporal " + node.label);
        for (int i = 0; i < node.children.size(); i++) {
            collectDeletedTemporal(node.children.get(i), path + ".child[" + i + "]", edits);
        }
    }

    private static String variableName(EGraphNode node) {
        return node.getAlphaName() == null ? node.getSourceName() : node.getAlphaName();
    }

    private static String nodeSummary(EGraphNode node) {
        if (node.getOpcode() == EGraphNode.Opcode.VARIABLE) {
            return node.getOpcode() + "(" + nodeVariableDisplay(node) + ")";
        }
        String opcode = node.isFlexibleArity()
                ? node.getOpcode() + "<" + node.getFlexibleArityKind().name().toLowerCase(java.util.Locale.ROOT) + ">"
                : node.getOpcode().toString();
        String name = firstNonEmpty(node.getAlphaName(), node.getSourceName());
        if (name == null) {
            return opcode;
        }
        return opcode + "(" + name + ")";
    }

    private static String nodeVariableDisplay(EGraphNode node) {
        return display(firstNonEmpty(node.getSourceName(), node.getAlphaName()));
    }

    private static String quantiVarName(QuantiVar qv) {
        return display(firstNonEmpty(qv.getOriginalName(), qv.getName()));
    }

    private static String normalFormPath(NormalForm nf, int index) {
        String label = normalFormLabel(nf);
        if (nf.getTemporalOp() == TemporalOp.NONE && index == 0) {
            return "root normal form";
        }
        return label + " normal form";
    }

    private static String normalFormLabel(NormalForm nf) {
        switch (nf.getTemporalOp()) {
            case UNTILL:
                return "left branch of UNTIL";
            case UNTILR:
                return "right branch of UNTIL";
            case RELEASESL:
                return "left branch of RELEASES";
            case RELEASESR:
                return "right branch of RELEASES";
            case SINCEL:
                return "left branch of SINCE";
            case SINCER:
                return "right branch of SINCE";
            case TRIGGEREDL:
                return "left branch of TRIGGERED";
            case TRIGGEREDR:
                return "right branch of TRIGGERED";
            default:
                return naturalTemporalLabel(nf.getTemporalOp());
        }
    }

    private static String quantifierPrefix(List<QuantiVar> bindings) {
        List<String> parts = new ArrayList<>();
        for (QuantiVar binding : bindings) {
            parts.add(quantifierFormula(binding));
        }
        if (parts.isEmpty()) {
            return "";
        }
        return String.join(" ", parts) + " . ";
    }

    private static String quantifierFormula(QuantiVar qv) {
        String disj = qv.isDisj() ? " disj#" + qv.getDisjointnessClass() : "";
        String cardinality = cardinalityPrefix(qv);
        return qv.getQuantifier() + disj + " " + quantiVarName(qv) + " : "
                + cardinality + display(qv.getTypeName());
    }

    private static String cardinalityPrefix(QuantiVar qv) {
        switch (qv.getCardinality()) {
            case SOME:
                return "some ";
            case ONE:
                return "one ";
            case LONE:
                return "lone ";
            case EXACTLY:
                return "exactly ";
            case SET:
            default:
                return "";
        }
    }

    private static String eGraphFormula(EGraphNode node) {
        if (node == null) {
            return "<empty>";
        }
        switch (node.getOpcode()) {
            case VARIABLE:
                return nodeVariableDisplay(node);
            case GLOBALBINDING:
            case CONSTANT:
                return display(node.getSourceName());
            case TEMPORALROOT:
                if (node.getChildren().size() == 1) {
                    return eGraphFormula(node.getChildren().get(0));
                }
                return operatorFormula(node);
            case NOT:
            case SOME:
            case NO:
            case LONE:
            case ONE:
            case SETOF:
            case EXACTLY:
            case TRANSPOSE:
            case RCLOSURE:
            case CLOSURE:
            case CARDINALITY:
            case CAST2INT:
            case CAST2SIGINT:
            case PRIME:
            case BEFORE:
            case HISTORICALLY:
            case ONCE:
            case ALWAYS:
            case EVENTUALLY:
            case AFTER:
                return unaryFormula(node);
            case AND:
                return infixFormula(node, "&&");
            case OR:
                return infixFormula(node, "||");
            case IMPLIES:
                return infixFormula(node, "=>");
            case IFF:
                return infixFormula(node, "<=>");
            case EQUALS:
                return infixFormula(node, "=");
            case NOT_EQUALS:
                return infixFormula(node, "!=");
            case IN:
                return infixFormula(node, "in");
            case NOT_IN:
                return infixFormula(node, "!in");
            case GT:
                return infixFormula(node, ">");
            case GTE:
                return infixFormula(node, ">=");
            case LT:
                return infixFormula(node, "<");
            case LTE:
                return infixFormula(node, "<=");
            case JOIN:
                return infixFormula(node, ".");
            case ARROW:
                return infixFormula(node, "->");
            case INTERSECT:
                return infixFormula(node, "&");
            case PLUS:
                return infixFormula(node, "+");
            case PLUSPLUS:
                return infixFormula(node, "++");
            case MINUS:
                return infixFormula(node, "-");
            case UNTIL:
                return infixFormula(node, "until");
            case RELEASES:
                return infixFormula(node, "releases");
            case SINCE:
                return infixFormula(node, "since");
            case TRIGGERED:
                return infixFormula(node, "triggered");
            case ITE:
                return iteFormula(node);
            case CALL:
                CallMetadata.require(node);
                return operatorFormula(node);
            default:
                return operatorFormula(node);
        }
    }

    private static String unaryFormula(EGraphNode node) {
        if (node.getChildren().isEmpty()) {
            return node.getOpcode().toString();
        }
        return "(" + node.getOpcode() + " " + eGraphFormula(node.getChildren().get(0)) + ")";
    }

    private static String infixFormula(EGraphNode node, String op) {
        if (node.getChildren().isEmpty()) {
            return node.getOpcode().toString();
        }
        List<String> children = new ArrayList<>();
        for (EGraphNode child : node.getChildren()) {
            children.add(eGraphFormula(child));
        }
        return "(" + String.join(" " + op + " ", children) + ")";
    }

    private static String iteFormula(EGraphNode node) {
        if (node.getChildren().size() != 3) {
            return operatorFormula(node);
        }
        return "(if " + eGraphFormula(node.getChildren().get(0)) + " then "
                + eGraphFormula(node.getChildren().get(1)) + " else "
                + eGraphFormula(node.getChildren().get(2)) + ")";
    }

    private static String operatorFormula(EGraphNode node) {
        List<String> children = new ArrayList<>();
        for (EGraphNode child : node.getChildren()) {
            children.add(eGraphFormula(child));
        }
        String name = firstNonEmpty(node.getSourceName(), node.getOpcode().toString());
        if (children.isEmpty()) {
            return name;
        }
        return name + "(" + String.join(", ", children) + ")";
    }

    private static String firstNonEmpty(String... values) {
        for (String value : values) {
            if (value != null && !value.isEmpty()) {
                return value;
            }
        }
        return null;
    }

    private static String display(String value) {
        return value == null || value.isEmpty() ? "<unknown>" : value;
    }

    private static void appendReverse(List<String> reversed, List<String> edits) {
        for (int i = reversed.size() - 1; i >= 0; i--) {
            edits.add(reversed.get(i));
        }
    }

    private static String typeKey(QuantiVar qv) {
        String type = qv.getTypeName();
        return type == null ? "" : type;
    }

    private static boolean sameType(String left, String right) {
        return safeEquals(normalizeType(left), normalizeType(right));
    }

    private static String normalizeType(String type) {
        if (type == null) {
            return "";
        }
        return type.startsWith("VAR_") ? type.substring(4) : type;
    }

    private static boolean safeEquals(String left, String right) {
        return left == null ? right == null : left.equals(right);
    }

    private static int[][] intMatrix(int rows, int columns) {
        long bytes = alignedArrayBytes(rows, 8) + (long) rows * alignedArrayBytes(columns, 4);
        recordAllocation(bytes, rows + 1L, true);
        return new int[rows][columns];
    }

    private static int[] intArray(int length) {
        recordAllocation(alignedArrayBytes(length, 4), 1, false);
        return new int[length];
    }

    private static boolean[] booleanArray(int length) {
        recordAllocation(alignedArrayBytes(length, 1), 1, false);
        return new boolean[length];
    }

    private static long alignedArrayBytes(int length, int elementBytes) {
        long bytes = 16L + (long) Math.max(0, length) * elementBytes;
        return (bytes + 7L) & ~7L;
    }

    private static void recordAllocation(long bytes, long arrays, boolean matrix) {
        MutableAllocationStats tracker = ALLOCATION_TRACKER.get();
        if (tracker == null) {
            return;
        }
        tracker.bytes += bytes;
        tracker.peakBytes = Math.max(tracker.peakBytes, bytes);
        tracker.arrays += arrays;
        if (matrix) {
            tracker.matrices++;
        }
    }

    public static final class AllocationStats {
        private final long estimatedBytes;
        private final long largestBufferBytes;
        private final long arrayCount;
        private final long matrixCount;

        private AllocationStats(long estimatedBytes, long largestBufferBytes, long arrayCount, long matrixCount) {
            this.estimatedBytes = estimatedBytes;
            this.largestBufferBytes = largestBufferBytes;
            this.arrayCount = arrayCount;
            this.matrixCount = matrixCount;
        }

        public long estimatedBytes() {
            return estimatedBytes;
        }

        public long largestBufferBytes() {
            return largestBufferBytes;
        }

        public long arrayCount() {
            return arrayCount;
        }

        public long matrixCount() {
            return matrixCount;
        }
    }

    private static final class MutableAllocationStats {
        private long bytes;
        private long peakBytes;
        private long arrays;
        private long matrices;
    }

    private enum BindingRole {
        PARAMETER,
        MATRIX,
        INHERITED
    }

    private static final class BindingDescriptor {
        private final QuantiVar variable;
        private final BindingRole role;
        private final int ordinal;

        private BindingDescriptor(QuantiVar variable, BindingRole role, int ordinal) {
            this.variable = variable;
            this.role = role;
            this.ordinal = ordinal;
        }

        private boolean compatibleWith(BindingDescriptor other) {
            if (other == null || role != other.role
                    || variable.getQuantifier() != other.variable.getQuantifier()
                    || variable.getCardinality() != other.variable.getCardinality()
                    || variable.getDisjointnessClass() != other.variable.getDisjointnessClass()
                    || !sameType(typeKey(variable), typeKey(other.variable))) {
                return false;
            }
            if (role == BindingRole.PARAMETER) {
                return ordinal == other.ordinal;
            }
            if (variable.getQuantifier() == QuantiVar.Quantifier.COMPREHENSION
                    || variable.getQuantifier() == QuantiVar.Quantifier.SUM) {
                return safeEquals(variable.getDeBruijnKey(), other.variable.getDeBruijnKey());
            }
            if (variable.getQuantifier() == QuantiVar.Quantifier.ALL
                    || variable.getQuantifier() == QuantiVar.Quantifier.SOME) {
                return true;
            }
            return safeEquals(variable.getBindingPath(), other.variable.getBindingPath());
        }
    }

    private static class BestMapping {
        private int distance = Integer.MAX_VALUE;
        private Map<String, String> mapping = new HashMap<>();
    }

    private static class TemporalTree {
        private String label;
        private List<TemporalTree> children;

        private TemporalTree(String label) {
            this.label = label;
            this.children = new ArrayList<>();
        }
    }
}
