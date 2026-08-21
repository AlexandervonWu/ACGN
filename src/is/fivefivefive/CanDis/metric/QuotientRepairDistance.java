package is.fivefivefive.CanDis.metric;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import is.fivefivefive.CanDis.core.OrderedTreeEditDistance;
import is.fivefivefive.CanDis.metric.RepairView.Binding;
import is.fivefivefive.CanDis.metric.RepairView.BindingRole;
import is.fivefivefive.CanDis.metric.RepairView.Declaration;
import is.fivefivefive.CanDis.metric.RepairView.Node;
import is.fivefivefive.CanDis.metric.RepairView.Phase;
import is.fivefivefive.CanDis.metric.RepairView.TemporalNode;

/**
 * The established {@code CanonicalDistance} repair geometry evaluated over a
 * certificate-producing {@link RepairView}. Its decomposition and edit units
 * are metric semantics, while Layer 1 supplies admissible scope symmetries.
 * This in-process evaluator checks producer consistency only. It does not by
 * itself grant independent certificate authority.
 */
public final class QuotientRepairDistance {
    public static final String VERSION = "certified-fast-rewrite-repair-distance-v6";

    private QuotientRepairDistance() {
    }

    private static final OrderedTreeEditDistance.Adapter<TemporalNode> TEMPORAL_ADAPTER =
            new OrderedTreeEditDistance.Adapter<>() {
                @Override
                public String label(TemporalNode node) {
                    return node.label();
                }

                @Override
                public List<? extends TemporalNode> children(TemporalNode node) {
                    return node.children();
                }
            };

    public static int distance(RepairView left, RepairView right) {
        return evaluate(left, right).distance();
    }

    public static Result evaluate(RepairView left, RepairView right) {
        Objects.requireNonNull(left, "left");
        Objects.requireNonNull(right, "right");
        if (!left.semanticProfile().equals(right.semanticProfile())) {
            throw new IllegalArgumentException(
                    "Repair views from different semantic profiles cannot be compared");
        }
        Result candidate = evaluateUnchecked(left, right);
        boolean sameProducerObservation = left.hasSameProducerObservation(right);
        if (sameProducerObservation != (candidate.distance == 0)) {
            throw new IllegalStateException(sameProducerObservation
                    ? "Equal producer observations have nonzero repair distance"
                    : "A zero repair distance lacks producer-observation equality");
        }
        return candidate;
    }

    static Result evaluateUncheckedForTesting(RepairView left, RepairView right) {
        return evaluateUnchecked(left, right);
    }

    private static Result evaluateUnchecked(RepairView left, RepairView right) {
        Objects.requireNonNull(left, "left");
        Objects.requireNonNull(right, "right");
        MutableStats stats = new MutableStats();
        int temporal = temporalDistance(left.temporalRoot(), right.temporalRoot());
        int quantifiers = quantificationDistance(left.phases(), right.phases());
        int matrix = matrixDistance(left.phases(), right.phases(), stats);
        return new Result(
                Math.addExact(temporal, Math.addExact(quantifiers, matrix)),
                temporal,
                quantifiers,
                matrix,
                true,
                KernelAuthority.IN_PROCESS_PRODUCER_CONSISTENCY,
                stats.alphaAlignments);
    }

    public enum KernelAuthority {
        /** Both sides of the zero-kernel check were produced in one trust domain. */
        IN_PROCESS_PRODUCER_CONSISTENCY
    }

    public static final class Result {
        private final int distance;
        private final int temporalDistance;
        private final int quantifierDistance;
        private final int matrixDistance;
        private final boolean exactForStoredOrbits;
        private final KernelAuthority kernelAuthority;
        private final long binderAlignments;

        private Result(
                int distance,
                int temporalDistance,
                int quantifierDistance,
                int matrixDistance,
                boolean exactForStoredOrbits,
                KernelAuthority kernelAuthority,
                long binderAlignments) {
            this.distance = distance;
            this.temporalDistance = temporalDistance;
            this.quantifierDistance = quantifierDistance;
            this.matrixDistance = matrixDistance;
            this.exactForStoredOrbits = exactForStoredOrbits;
            this.kernelAuthority = Objects.requireNonNull(
                    kernelAuthority, "kernelAuthority");
            this.binderAlignments = binderAlignments;
        }

        public int distance() {
            return distance;
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

        public boolean exactForStoredOrbits() {
            return exactForStoredOrbits;
        }

        public KernelAuthority kernelAuthority() {
            return kernelAuthority;
        }

        public long binderAlignments() {
            return binderAlignments;
        }
    }

    private static int temporalDistance(TemporalNode left, TemporalNode right) {
        return OrderedTreeEditDistance.distance(left, right, TEMPORAL_ADAPTER);
    }

    private static int quantificationDistance(List<Phase> left, List<Phase> right) {
        int count = Math.max(left.size(), right.size());
        int result = 0;
        for (int index = 0; index < count; index++) {
            if (index >= left.size()) {
                result = Math.addExact(result, right.get(index).quantifiers().size());
            } else if (index >= right.size()) {
                result = Math.addExact(result, left.get(index).quantifiers().size());
            } else {
                result = Math.addExact(result, bindingListDistance(
                        left.get(index).quantifiers(), right.get(index).quantifiers()));
            }
        }
        return result;
    }

    private static int bindingListDistance(
            List<Declaration> leftSource,
            List<Declaration> rightSource) {
        List<Declaration> left = canonicalQuantifierOrder(leftSource);
        List<Declaration> right = canonicalQuantifierOrder(rightSource);
        int[] previous = new int[right.size() + 1];
        int[] current = new int[right.size() + 1];
        for (int j = 1; j <= right.size(); j++) {
            previous[j] = previous[j - 1] + 1;
        }
        for (int i = 1; i <= left.size(); i++) {
            current[0] = previous[0] + 1;
            for (int j = 1; j <= right.size(); j++) {
                int delete = previous[j] + 1;
                int insert = current[j - 1] + 1;
                int update = previous[j - 1]
                        + (left.get(i - 1).sameRepairTuple(right.get(j - 1)) ? 0 : 1);
                current[j] = Math.min(update, Math.min(delete, insert));
            }
            int[] swap = previous;
            previous = current;
            current = swap;
        }
        return previous[right.size()];
    }

    private static List<Declaration> canonicalQuantifierOrder(List<Declaration> source) {
        List<Declaration> result = new ArrayList<>(source);
        for (int start = 0; start < result.size();) {
            String quantifier = result.get(start).quantifier();
            int end = start + 1;
            if ("ALL".equals(quantifier) || "SOME".equals(quantifier)) {
                while (end < result.size()
                        && quantifier.equals(result.get(end).quantifier())) {
                    end++;
                }
                result.subList(start, end).sort(QuotientRepairDistance::compareTuple);
            }
            start = end;
        }
        return result;
    }

    private static int compareTuple(Declaration left, Declaration right) {
        int comparison = left.type().compareTo(right.type());
        if (comparison != 0) {
            return comparison;
        }
        comparison = left.cardinality().compareTo(right.cardinality());
        if (comparison != 0) {
            return comparison;
        }
        return Integer.compare(left.disjointnessClass(), right.disjointnessClass());
    }

    private static int matrixDistance(
            List<Phase> left,
            List<Phase> right,
            MutableStats stats) {
        // One owner-coordinate mapping must govern its matrix and every temporal heir.
        int aligned = Math.min(left.size(), right.size());
        int result = 0;
        for (int index = aligned; index < left.size(); index++) {
            result = Math.addExact(result, nodeSize(left.get(index).matrix()));
        }
        for (int index = aligned; index < right.size(); index++) {
            result = Math.addExact(result, nodeSize(right.get(index).matrix()));
        }
        if (aligned == 0) {
            return result;
        }

        GlobalBindingIndex leftBindings = GlobalBindingIndex.create(left, aligned);
        GlobalBindingIndex rightBindings = GlobalBindingIndex.create(right, aligned);
        int maximumMatches = -1;
        int best = Integer.MAX_VALUE;
        for (ScopeAlignment scope : globalScopeAlignments(leftBindings, rightBindings)) {
            List<Integer> leftOrder = new ArrayList<>(leftBindings.used);
            leftOrder.sort((first, second) -> Integer.compare(
                    globalCandidateCount(
                            leftBindings.binding(first), rightBindings, scope),
                    globalCandidateCount(
                            leftBindings.binding(second), rightBindings, scope)));
            int requiredMatches = maximumGlobalCompatibleMatches(
                    leftBindings, rightBindings, leftOrder, scope);
            if (requiredMatches < maximumMatches) {
                continue;
            }
            if (requiredMatches > maximumMatches) {
                maximumMatches = requiredMatches;
                best = Integer.MAX_VALUE;
            }
            int[] mapping = new int[leftBindings.bindings.size()];
            Arrays.fill(mapping, -1);
            best = searchGlobalMappings(
                    leftBindings,
                    rightBindings,
                    leftOrder,
                    scope,
                    mapping,
                    new boolean[rightBindings.bindings.size()],
                    0,
                    0,
                    requiredMatches,
                    best,
                    stats);
        }
        if (best == Integer.MAX_VALUE) {
            throw new IllegalStateException(
                    "No certified global alpha alignment was evaluated");
        }
        return Math.addExact(result, best);
    }

    private static int searchGlobalMappings(
            GlobalBindingIndex left,
            GlobalBindingIndex right,
            List<Integer> leftOrder,
            ScopeAlignment scope,
            int[] mapping,
            boolean[] usedRight,
            int index,
            int matched,
            int requiredMatches,
            int best,
            MutableStats stats) {
        if (index == leftOrder.size()) {
            if (matched != requiredMatches) {
                return best;
            }
            stats.alphaAlignments++;
            return Math.min(best, globallyMappedMatrixDistance(left, right, mapping));
        }
        int leftIndex = leftOrder.get(index);
        GlobalBinding leftBinding = left.binding(leftIndex);
        boolean mapped = false;
        for (int rightIndex : right.used) {
            if (usedRight[rightIndex]
                    || !globalCompatible(
                            leftBinding, right.binding(rightIndex), scope)) {
                continue;
            }
            mapped = true;
            mapping[leftIndex] = rightIndex;
            usedRight[rightIndex] = true;
            best = searchGlobalMappings(
                    left,
                    right,
                    leftOrder,
                    scope,
                    mapping,
                    usedRight,
                    index + 1,
                    matched + 1,
                    requiredMatches,
                    best,
                    stats);
            usedRight[rightIndex] = false;
            mapping[leftIndex] = -1;
            if (best == 0) {
                return 0;
            }
        }
        if (!mapped || matched + leftOrder.size() - index - 1 >= requiredMatches) {
            best = searchGlobalMappings(
                    left,
                    right,
                    leftOrder,
                    scope,
                    mapping,
                    usedRight,
                    index + 1,
                    matched,
                    requiredMatches,
                    best,
                    stats);
        }
        return best;
    }

    private static int globallyMappedMatrixDistance(
            GlobalBindingIndex left,
            GlobalBindingIndex right,
            int[] globalMapping) {
        int result = 0;
        boolean[] explicitlyMappedRight = new boolean[right.bindings.size()];
        for (int mapped : globalMapping) {
            if (mapped >= 0) {
                explicitlyMappedRight[mapped] = true;
            }
        }
        for (int phaseIndex = 0; phaseIndex < left.phaseCount; phaseIndex++) {
            Phase leftPhase = left.phases.get(phaseIndex);
            Phase rightPhase = right.phases.get(phaseIndex);
            int[] localMapping = new int[leftPhase.bindings().size()];
            Arrays.fill(localMapping, -1);
            int[] localToGlobal = left.localToGlobal.get(phaseIndex);
            for (int local = 0; local < localToGlobal.length; local++) {
                int leftGlobal = localToGlobal[local];
                int rightGlobal = globalMapping[leftGlobal];
                if (rightGlobal < 0) {
                    // A tuple modification is already charged by D_quantifiers.
                    Integer sameCoordinate = right.indices.get(
                            left.binding(leftGlobal).identity);
                    if (sameCoordinate != null
                            && !explicitlyMappedRight[sameCoordinate]) {
                        rightGlobal = sameCoordinate;
                    }
                }
                if (rightGlobal >= 0) {
                    Integer rightLocal = right.usedLocalByGlobal
                            .get(phaseIndex).get(rightGlobal);
                    if (rightLocal != null) {
                        localMapping[local] = rightLocal;
                    }
                }
            }
            result = Math.addExact(
                    result,
                    new MatrixDistanceContext(localMapping).distance(
                            leftPhase.matrix(), rightPhase.matrix()));
        }
        return result;
    }

    private static int globalCandidateCount(
            GlobalBinding left,
            GlobalBindingIndex right,
            ScopeAlignment scope) {
        int result = 0;
        for (int rightIndex : right.used) {
            if (globalCompatible(left, right.binding(rightIndex), scope)) {
                result++;
            }
        }
        return result;
    }

    private static int maximumGlobalCompatibleMatches(
            GlobalBindingIndex left,
            GlobalBindingIndex right,
            List<Integer> leftOrder,
            ScopeAlignment scope) {
        int[] matchedLeftByRight = new int[right.bindings.size()];
        Arrays.fill(matchedLeftByRight, -1);
        int result = 0;
        for (int leftIndex : leftOrder) {
            if (augmentGlobalMatching(
                    leftIndex,
                    left,
                    right,
                    scope,
                    matchedLeftByRight,
                    new boolean[right.bindings.size()])) {
                result++;
            }
        }
        return result;
    }

    private static boolean augmentGlobalMatching(
            int leftIndex,
            GlobalBindingIndex left,
            GlobalBindingIndex right,
            ScopeAlignment scope,
            int[] matchedLeftByRight,
            boolean[] visitedRight) {
        for (int rightIndex : right.used) {
            if (visitedRight[rightIndex]
                    || !globalCompatible(
                            left.binding(leftIndex), right.binding(rightIndex), scope)) {
                continue;
            }
            visitedRight[rightIndex] = true;
            if (matchedLeftByRight[rightIndex] < 0
                    || augmentGlobalMatching(
                            matchedLeftByRight[rightIndex],
                            left,
                            right,
                            scope,
                            matchedLeftByRight,
                            visitedRight)) {
                matchedLeftByRight[rightIndex] = leftIndex;
                return true;
            }
        }
        return false;
    }

    private static boolean globalCompatible(
            GlobalBinding left,
            GlobalBinding right,
            ScopeAlignment scope) {
        if (!globalBaseCompatible(left, right)) {
            return false;
        }
        if (left.identity.parameter) {
            return left.identity.coordinate == right.identity.coordinate;
        }
        ScopeOwner owner = globalScopeOwner(left);
        ScopeCoordinate target = scope.mappings.get(new ScopeCoordinate(
                owner, left.binding.declaration().exchangeClass()));
        return target != null && target.equals(new ScopeCoordinate(
                globalScopeOwner(right), right.binding.declaration().exchangeClass()));
    }

    private static boolean globalBaseCompatible(
            GlobalBinding left,
            GlobalBinding right) {
        if (left.identity.parameter != right.identity.parameter
                || !left.binding.declaration().sameCertifiedPayload(
                        right.binding.declaration())) {
            return false;
        }
        if (left.identity.parameter) {
            return true;
        }
        if (left.identity.ownerPhase != right.identity.ownerPhase) {
            return false;
        }
        String quantifier = left.binding.declaration().quantifier();
        if ("ALL".equals(quantifier) || "SOME".equals(quantifier)) {
            return true;
        }
        return left.binding.bindingPath().equals(right.binding.bindingPath());
    }

    private static List<ScopeAlignment> globalScopeAlignments(
            GlobalBindingIndex left,
            GlobalBindingIndex right) {
        Map<ScopeOwner, Map<Integer, List<Integer>>> leftBlocks =
                globalScopeBlocks(left);
        Map<ScopeOwner, Map<Integer, List<Integer>>> rightBlocks =
                globalScopeBlocks(right);
        List<ScopeOwner> owners = new ArrayList<>(leftBlocks.keySet());
        owners.sort(ScopeOwner::compareTo);
        List<ScopeAlignment> result = new ArrayList<>();
        result.add(ScopeAlignment.EMPTY);
        for (ScopeOwner owner : owners) {
            List<Map<Integer, Integer>> blockMappings = enumerateGlobalBlockMappings(
                    left,
                    right,
                    leftBlocks.get(owner),
                    rightBlocks.getOrDefault(owner, java.util.Collections.emptyMap()));
            List<ScopeAlignment> expanded = new ArrayList<>();
            for (ScopeAlignment prefix : result) {
                for (Map<Integer, Integer> mapping : blockMappings) {
                    expanded.add(prefix.extend(owner, mapping));
                }
            }
            result = expanded;
        }
        return result;
    }

    private static Map<ScopeOwner, Map<Integer, List<Integer>>> globalScopeBlocks(
            GlobalBindingIndex bindings) {
        Map<ScopeOwner, Map<Integer, List<Integer>>> result = new LinkedHashMap<>();
        for (int index : bindings.used) {
            GlobalBinding binding = bindings.binding(index);
            if (binding.identity.parameter) {
                continue;
            }
            result.computeIfAbsent(
                            globalScopeOwner(binding), ignored -> new LinkedHashMap<>())
                    .computeIfAbsent(
                            binding.binding.declaration().exchangeClass(),
                            ignored -> new ArrayList<>())
                    .add(index);
        }
        return result;
    }

    private static ScopeOwner globalScopeOwner(GlobalBinding binding) {
        return new ScopeOwner(BindingRole.MATRIX, binding.identity.ownerPhase);
    }

    private static List<Map<Integer, Integer>> enumerateGlobalBlockMappings(
            GlobalBindingIndex left,
            GlobalBindingIndex right,
            Map<Integer, List<Integer>> leftBlocks,
            Map<Integer, List<Integer>> rightBlocks) {
        List<Integer> leftClasses = new ArrayList<>(leftBlocks.keySet());
        List<Integer> rightClasses = new ArrayList<>(rightBlocks.keySet());
        leftClasses.sort(Integer::compareTo);
        rightClasses.sort(Integer::compareTo);
        List<Map<Integer, Integer>> result = new ArrayList<>();
        enumerateGlobalBlockMappings(
                left,
                right,
                leftBlocks,
                rightBlocks,
                leftClasses,
                rightClasses,
                0,
                0,
                new LinkedHashMap<>(),
                result);
        return result;
    }

    private static void enumerateGlobalBlockMappings(
            GlobalBindingIndex left,
            GlobalBindingIndex right,
            Map<Integer, List<Integer>> leftBlocks,
            Map<Integer, List<Integer>> rightBlocks,
            List<Integer> leftClasses,
            List<Integer> rightClasses,
            int leftPosition,
            int minimumRightPosition,
            Map<Integer, Integer> current,
            List<Map<Integer, Integer>> output) {
        if (leftPosition == leftClasses.size()) {
            output.add(new LinkedHashMap<>(current));
            return;
        }
        int leftClass = leftClasses.get(leftPosition);
        enumerateGlobalBlockMappings(
                left,
                right,
                leftBlocks,
                rightBlocks,
                leftClasses,
                rightClasses,
                leftPosition + 1,
                minimumRightPosition,
                current,
                output);
        for (int rightPosition = minimumRightPosition;
                rightPosition < rightClasses.size(); rightPosition++) {
            int rightClass = rightClasses.get(rightPosition);
            if (!globalBlocksCompatible(
                    left,
                    right,
                    leftBlocks.get(leftClass),
                    rightBlocks.get(rightClass))) {
                continue;
            }
            current.put(leftClass, rightClass);
            enumerateGlobalBlockMappings(
                    left,
                    right,
                    leftBlocks,
                    rightBlocks,
                    leftClasses,
                    rightClasses,
                    leftPosition + 1,
                    rightPosition + 1,
                    current,
                    output);
            current.remove(leftClass);
        }
    }

    private static boolean globalBlocksCompatible(
            GlobalBindingIndex left,
            GlobalBindingIndex right,
            List<Integer> leftBlock,
            List<Integer> rightBlock) {
        for (int leftIndex : leftBlock) {
            for (int rightIndex : rightBlock) {
                if (globalBaseCompatible(
                        left.binding(leftIndex), right.binding(rightIndex))) {
                    return true;
                }
            }
        }
        return false;
    }

    private static Set<Integer> usedBindings(Node root) {
        Set<Integer> result = new HashSet<>();
        collectUsedBindings(root, result);
        return result;
    }

    private static void collectUsedBindings(Node node, Set<Integer> output) {
        if (node == null) {
            return;
        }
        if (node.isVariable() && node.bindingIndex() >= 0) {
            output.add(node.bindingIndex());
        }
        for (Node child : node.children()) {
            collectUsedBindings(child, output);
        }
    }

    private static int nodeSize(Node node) {
        return node == null ? 0 : node.size();
    }

    private static final class MatrixDistanceContext {
        private final int[] mapping;
        private final Map<NodePair, Integer> memo = new HashMap<>();

        private MatrixDistanceContext(int[] mapping) {
            this.mapping = mapping.clone();
        }

        private int distance(Node left, Node right) {
            if (left == null) {
                return nodeSize(right);
            }
            if (right == null) {
                return nodeSize(left);
            }
            NodePair key = new NodePair(left, right);
            Integer remembered = memo.get(key);
            if (remembered != null) {
                return remembered;
            }
            if (!left.alphaAlternatives().isEmpty()
                    || !right.alphaAlternatives().isEmpty()) {
                List<Node> leftAlternatives = left.alphaAlternatives().isEmpty()
                        ? List.of(left)
                        : left.alphaAlternatives();
                List<Node> rightAlternatives = right.alphaAlternatives().isEmpty()
                        ? List.of(right)
                        : right.alphaAlternatives();
                int best = Integer.MAX_VALUE;
                for (Node leftAlternative : leftAlternatives) {
                    for (Node rightAlternative : rightAlternatives) {
                        best = Math.min(
                                best, distance(leftAlternative, rightAlternative));
                        if (best == 0) {
                            memo.put(key, 0);
                            return 0;
                        }
                    }
                }
                memo.put(key, best);
                return best;
            }
            int children = left.operator().equals(right.operator())
                    && left.orderInsensitive()
                    && right.orderInsensitive()
                    ? unorderedDistance(left.children(), right.children())
                    : sequenceDistance(left.children(), right.children());
            int result = Math.addExact(updateCost(left, right), children);
            memo.put(key, result);
            return result;
        }

        private int updateCost(Node left, Node right) {
            if (!left.operator().equals(right.operator())) {
                return 1;
            }
            if (left.isVariable()) {
                if (left.bindingIndex() >= 0) {
                    int mapped = mapping[left.bindingIndex()];
                    return mapped >= 0 && mapped == right.bindingIndex() ? 0 : 1;
                }
                return Objects.equals(
                        left.lexicalVariable(), right.lexicalVariable()) ? 0 : 1;
            }
            return Objects.equals(
                    left.semanticPayload(), right.semanticPayload()) ? 0 : 1;
        }

        private int sequenceDistance(List<Node> left, List<Node> right) {
            if (left.size() == 1 && right.size() == 1) {
                return distance(left.get(0), right.get(0));
            }
            int[] previous = new int[right.size() + 1];
            int[] current = new int[right.size() + 1];
            for (int j = 1; j <= right.size(); j++) {
                previous[j] = previous[j - 1] + right.get(j - 1).size();
            }
            for (int i = 1; i <= left.size(); i++) {
                current[0] = previous[0] + left.get(i - 1).size();
                for (int j = 1; j <= right.size(); j++) {
                    int delete = previous[j] + left.get(i - 1).size();
                    int insert = current[j - 1] + right.get(j - 1).size();
                    int update = previous[j - 1]
                            + distance(left.get(i - 1), right.get(j - 1));
                    current[j] = Math.min(update, Math.min(delete, insert));
                }
                int[] swap = previous;
                previous = current;
                current = swap;
            }
            return previous[right.size()];
        }

        private int unorderedDistance(List<Node> left, List<Node> right) {
            if (left.isEmpty() || right.isEmpty()) {
                return sequenceDistance(left, right);
            }
            int dimension = left.size() + right.size();
            int[][] costs = new int[dimension][dimension];
            for (int i = 0; i < dimension; i++) {
                for (int j = 0; j < dimension; j++) {
                    if (i < left.size() && j < right.size()) {
                        costs[i][j] = distance(left.get(i), right.get(j));
                    } else if (i < left.size()) {
                        costs[i][j] = left.get(i).size();
                    } else if (j < right.size()) {
                        costs[i][j] = right.get(j).size();
                    }
                }
            }
            return minimumAssignmentCost(costs);
        }
    }

    private static int minimumAssignmentCost(int[][] costs) {
        int size = costs.length;
        int[] rowPotential = new int[size + 1];
        int[] columnPotential = new int[size + 1];
        int[] columnMatch = new int[size + 1];
        int[] predecessor = new int[size + 1];
        for (int row = 1; row <= size; row++) {
            columnMatch[0] = row;
            int column = 0;
            int[] minimum = new int[size + 1];
            Arrays.fill(minimum, Integer.MAX_VALUE);
            boolean[] used = new boolean[size + 1];
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

    private static final class ScopeOwner implements Comparable<ScopeOwner> {
        private final BindingRole role;
        private final int phase;

        private ScopeOwner(BindingRole role, int phase) {
            this.role = role;
            this.phase = phase;
        }

        @Override
        public int compareTo(ScopeOwner other) {
            int comparison = role.compareTo(other.role);
            return comparison != 0 ? comparison : Integer.compare(phase, other.phase);
        }

        @Override
        public boolean equals(Object other) {
            return other instanceof ScopeOwner
                    && role == ((ScopeOwner) other).role
                    && phase == ((ScopeOwner) other).phase;
        }

        @Override
        public int hashCode() {
            return 31 * role.hashCode() + phase;
        }
    }

    private static final class ScopeCoordinate {
        private final ScopeOwner owner;
        private final int exchangeClass;

        private ScopeCoordinate(ScopeOwner owner, int exchangeClass) {
            this.owner = owner;
            this.exchangeClass = exchangeClass;
        }

        @Override
        public boolean equals(Object other) {
            return other instanceof ScopeCoordinate
                    && owner.equals(((ScopeCoordinate) other).owner)
                    && exchangeClass == ((ScopeCoordinate) other).exchangeClass;
        }

        @Override
        public int hashCode() {
            return 31 * owner.hashCode() + exchangeClass;
        }
    }

    private static final class ScopeAlignment {
        private static final ScopeAlignment EMPTY = new ScopeAlignment(
                java.util.Collections.emptyMap());

        private final Map<ScopeCoordinate, ScopeCoordinate> mappings;

        private ScopeAlignment(Map<ScopeCoordinate, ScopeCoordinate> mappings) {
            this.mappings = mappings;
        }

        private ScopeAlignment extend(
                ScopeOwner owner,
                Map<Integer, Integer> blockMapping) {
            Map<ScopeCoordinate, ScopeCoordinate> result = new LinkedHashMap<>(mappings);
            for (Map.Entry<Integer, Integer> entry : blockMapping.entrySet()) {
                result.put(
                        new ScopeCoordinate(owner, entry.getKey()),
                        new ScopeCoordinate(owner, entry.getValue()));
            }
            return new ScopeAlignment(result);
        }
    }

    private static final class GlobalBindingIdentity {
        private final boolean parameter;
        private final int ownerPhase;
        private final int coordinate;

        private GlobalBindingIdentity(
                boolean parameter,
                int ownerPhase,
                int coordinate) {
            this.parameter = parameter;
            this.ownerPhase = ownerPhase;
            this.coordinate = coordinate;
        }

        private static GlobalBindingIdentity from(Binding binding) {
            if (binding.role() == BindingRole.PARAMETER) {
                return new GlobalBindingIdentity(true, -1, binding.ordinal());
            }
            return new GlobalBindingIdentity(
                    false, binding.ownerPhase(), binding.coordinate());
        }

        @Override
        public boolean equals(Object other) {
            if (!(other instanceof GlobalBindingIdentity)) {
                return false;
            }
            GlobalBindingIdentity identity = (GlobalBindingIdentity) other;
            return parameter == identity.parameter
                    && ownerPhase == identity.ownerPhase
                    && coordinate == identity.coordinate;
        }

        @Override
        public int hashCode() {
            int result = Boolean.hashCode(parameter);
            result = 31 * result + ownerPhase;
            return 31 * result + coordinate;
        }
    }

    private static final class GlobalBinding {
        private final GlobalBindingIdentity identity;
        private final Binding binding;

        private GlobalBinding(GlobalBindingIdentity identity, Binding binding) {
            this.identity = identity;
            this.binding = binding;
        }
    }

    private static final class GlobalBindingIndex {
        private final List<Phase> phases;
        private final int phaseCount;
        private final List<GlobalBinding> bindings;
        private final Map<GlobalBindingIdentity, Integer> indices;
        private final List<int[]> localToGlobal;
        private final List<Map<Integer, Integer>> usedLocalByGlobal;
        private final Set<Integer> used;

        private GlobalBindingIndex(
                List<Phase> phases,
                int phaseCount,
                List<GlobalBinding> bindings,
                Map<GlobalBindingIdentity, Integer> indices,
                List<int[]> localToGlobal,
                List<Map<Integer, Integer>> usedLocalByGlobal,
                Set<Integer> used) {
            this.phases = phases;
            this.phaseCount = phaseCount;
            this.bindings = bindings;
            this.indices = indices;
            this.localToGlobal = localToGlobal;
            this.usedLocalByGlobal = usedLocalByGlobal;
            this.used = used;
        }

        private static GlobalBindingIndex create(
                List<Phase> phases,
                int phaseCount) {
            Map<GlobalBindingIdentity, Integer> indices = new LinkedHashMap<>();
            List<GlobalBinding> bindings = new ArrayList<>();
            List<int[]> localToGlobal = new ArrayList<>(phaseCount);
            for (int phaseIndex = 0; phaseIndex < phaseCount; phaseIndex++) {
                Phase phase = phases.get(phaseIndex);
                int[] local = new int[phase.bindings().size()];
                for (int bindingIndex = 0;
                        bindingIndex < phase.bindings().size(); bindingIndex++) {
                    Binding binding = phase.bindings().get(bindingIndex);
                    GlobalBindingIdentity identity = GlobalBindingIdentity.from(binding);
                    Integer global = indices.get(identity);
                    if (global == null) {
                        global = bindings.size();
                        indices.put(identity, global);
                        bindings.add(new GlobalBinding(identity, binding));
                    } else {
                        requireConsistentGlobalBinding(
                                bindings.get(global).binding, binding);
                    }
                    local[bindingIndex] = global;
                }
                localToGlobal.add(local);
            }

            Set<Integer> used = new java.util.TreeSet<>();
            List<Map<Integer, Integer>> usedLocalByGlobal =
                    new ArrayList<>(phaseCount);
            for (int phaseIndex = 0; phaseIndex < phaseCount; phaseIndex++) {
                Phase phase = phases.get(phaseIndex);
                Map<Integer, Integer> usedLocals = new HashMap<>();
                for (int local : usedBindings(phase.matrix())) {
                    int global = localToGlobal.get(phaseIndex)[local];
                    Integer previous = usedLocals.put(global, local);
                    if (previous != null && previous != local) {
                        throw new IllegalStateException(
                                "One certified binder coordinate has multiple matrix indices in a phase");
                    }
                    used.add(global);
                }
                usedLocalByGlobal.add(usedLocals);
            }
            return new GlobalBindingIndex(
                    phases,
                    phaseCount,
                    bindings,
                    indices,
                    localToGlobal,
                    usedLocalByGlobal,
                    used);
        }

        private GlobalBinding binding(int index) {
            return bindings.get(index);
        }

        private static void requireConsistentGlobalBinding(
                Binding first,
                Binding repeated) {
            if (!first.declaration().sameCertifiedPayload(repeated.declaration())
                    || first.declaration().exchangeClass()
                            != repeated.declaration().exchangeClass()
                    || !first.certifiedOrbit().equals(repeated.certifiedOrbit())) {
                throw new IllegalStateException(
                        "Inherited binder metadata disagrees with its owning coordinate");
            }
        }
    }

    private static final class MutableStats {
        private long alphaAlignments;
    }

    private static final class NodePair {
        private final Node left;
        private final Node right;

        private NodePair(Node left, Node right) {
            this.left = left;
            this.right = right;
        }

        @Override
        public boolean equals(Object other) {
            return other instanceof NodePair
                    && left == ((NodePair) other).left
                    && right == ((NodePair) other).right;
        }

        @Override
        public int hashCode() {
            return 31 * System.identityHashCode(left) + System.identityHashCode(right);
        }
    }
}
