package is.fivefivefive.CanDis;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.ir.IRAgent;
import is.fivefivefive.CanDis.macros.EGraphNode;
import is.fivefivefive.CanDis.macros.NormalForm;
import is.fivefivefive.CanDis.macros.QuantiVar;
import is.fivefivefive.CanDis.macros.QuantificationTreeNode;
import is.fivefivefive.CanDis.macros.NormalForm.TemporalOp;

public class Canonical {

    public static int distance(Multigraph left, Multigraph right) {
        List<NormalForm> leftNfs = normalForms(left);
        List<NormalForm> rightNfs = normalForms(right);
        int temporalDistance = treeDistance(temporalTree(leftNfs), temporalTree(rightNfs));
        int quantificationDistance = quantificationDistance(leftNfs, rightNfs);
        int matrixDistance = matrixDistance(leftNfs, rightNfs);
        return temporalDistance + quantificationDistance + matrixDistance;
    }

    public static List<String> edits(Multigraph left, Multigraph right) {
        List<NormalForm> leftNfs = normalForms(left);
        List<NormalForm> rightNfs = normalForms(right);
        List<String> edits = new ArrayList<>();
        temporalEdits(temporalTree(leftNfs), temporalTree(rightNfs), "temporal", edits);
        quantificationEdits(leftNfs, rightNfs, edits);
        matrixEdits(leftNfs, rightNfs, edits);
        if (edits.isEmpty()) {
            edits.add("no-op");
        }
        return edits;
    }

    public static List<String> irTemporalFol(Multigraph graph) {
        List<NormalForm> nfs = normalForms(graph);
        List<String> formulas = new ArrayList<>();
        for (int i = 0; i < nfs.size(); i++) {
            formulas.add(normalFormPath(nfs.get(i), i) + " := " + quantifierPrefix(nfs.get(i).getQuantificationTree())
                    + eGraphFormula(nfs.get(i).getMatrixEGraph()));
        }
        return formulas;
    }

    public static int canonicalFormSize(Multigraph graph) {
        List<NormalForm> nfs = normalForms(graph);
        int size = nfs.size();
        for (NormalForm nf : nfs) {
            size += eGraphSize(nf.getMatrixEGraph());
            size += quantificationSize(nf.getQuantificationTree());
        }
        return size;
    }

    private static List<NormalForm> normalForms(Multigraph graph) {
        IRAgent agent = new IRAgent(graph);
        agent.computeNormalForm();
        return agent.normalForms();
    }

    private static int quantificationDistance(List<NormalForm> left, List<NormalForm> right) {
        int size = Math.max(left.size(), right.size());
        int distance = 0;
        for (int i = 0; i < size; i++) {
            if (i >= left.size()) {
                distance += quantificationSize(right.get(i).getQuantificationTree());
            } else if (i >= right.size()) {
                distance += quantificationSize(left.get(i).getQuantificationTree());
            } else {
                distance += quantificationDistance(left.get(i).getQuantificationTree(), right.get(i).getQuantificationTree());
            }
        }
        return distance;
    }

    private static int quantificationDistance(QuantificationTreeNode left, QuantificationTreeNode right) {
        if (left == null) {
            return quantificationSize(right);
        }
        if (right == null) {
            return quantificationSize(left);
        }
        int distance = left.getQuantifier() == right.getQuantifier() ? 0 : 1;
        if (left.isDisj() != right.isDisj()) {
            distance++;
        }
        if (!safeEquals(bindingPathKey(left), bindingPathKey(right))) {
            distance++;
        }
        distance += variableTypeDelta(left.getQuantiVars(), right.getQuantiVars());
        distance += orderedForestDistance(left.getChildren(), right.getChildren());
        return distance;
    }

    private static int orderedForestDistance(List<QuantificationTreeNode> left, List<QuantificationTreeNode> right) {
        int[][] dp = new int[left.size() + 1][right.size() + 1];
        for (int i = 1; i <= left.size(); i++) {
            dp[i][0] = dp[i - 1][0] + quantificationSize(left.get(i - 1));
        }
        for (int j = 1; j <= right.size(); j++) {
            dp[0][j] = dp[0][j - 1] + quantificationSize(right.get(j - 1));
        }
        for (int i = 1; i <= left.size(); i++) {
            for (int j = 1; j <= right.size(); j++) {
                int delete = dp[i - 1][j] + quantificationSize(left.get(i - 1));
                int insert = dp[i][j - 1] + quantificationSize(right.get(j - 1));
                int update = dp[i - 1][j - 1] + quantificationDistance(left.get(i - 1), right.get(j - 1));
                dp[i][j] = Math.min(update, Math.min(delete, insert));
            }
        }
        return dp[left.size()][right.size()];
    }

    private static int variableTypeDelta(List<QuantiVar> left, List<QuantiVar> right) {
        Map<String, Integer> counts = new HashMap<>();
        for (QuantiVar qv : left) {
            counts.put(typeKey(qv), counts.getOrDefault(typeKey(qv), 0) + 1);
        }
        for (QuantiVar qv : right) {
            counts.put(typeKey(qv), counts.getOrDefault(typeKey(qv), 0) - 1);
        }
        int delta = 0;
        for (int count : counts.values()) {
            delta += Math.abs(count);
        }
        return delta;
    }

    private static int quantificationSize(QuantificationTreeNode node) {
        if (node == null) {
            return 0;
        }
        int size = 1 + node.getQuantiVars().size();
        if (node.isDisj()) {
            size++;
        }
        if (bindingPathKey(node) != null) {
            size++;
        }
        for (QuantificationTreeNode child : node.getChildren()) {
            size += quantificationSize(child);
        }
        return size;
    }

    private static void quantificationEdits(List<NormalForm> left, List<NormalForm> right, List<String> edits) {
        int size = Math.max(left.size(), right.size());
        for (int i = 0; i < size; i++) {
            NormalForm pathSource = i < left.size() ? left.get(i) : right.get(i);
            String path = normalFormPath(pathSource, i) + ".quantifier";
            if (i >= left.size()) {
                collectInsertedQuantifiers(right.get(i).getQuantificationTree(), path, edits);
            } else if (i >= right.size()) {
                collectDeletedQuantifiers(left.get(i).getQuantificationTree(), path, edits);
            } else {
                quantificationEdits(left.get(i).getQuantificationTree(), right.get(i).getQuantificationTree(), path, edits);
            }
        }
    }

    private static void quantificationEdits(
            QuantificationTreeNode left,
            QuantificationTreeNode right,
            String path,
            List<String> edits) {
        if (left == null) {
            collectInsertedQuantifiers(right, path, edits);
            return;
        }
        if (right == null) {
            collectDeletedQuantifiers(left, path, edits);
            return;
        }
        if (left.getQuantifier() != right.getQuantifier()) {
            edits.add(path + ": replace quantifier " + left.getQuantifier() + " -> " + right.getQuantifier());
        }
        if (left.isDisj() != right.isDisj()) {
            edits.add(path + ": " + (right.isDisj() ? "add" : "remove") + " disj declaration modifier");
        }
        if (!safeEquals(bindingPathKey(left), bindingPathKey(right))) {
            edits.add(path + ": move binding scope " + display(bindingPathKey(left))
                    + " -> " + display(bindingPathKey(right)));
        }
        variableTypeEdits(left.getQuantiVars(), right.getQuantiVars(), path, edits);
        quantificationForestEdits(left.getChildren(), right.getChildren(), path + ".child", edits);
    }

    private static void quantificationForestEdits(
            List<QuantificationTreeNode> left,
            List<QuantificationTreeNode> right,
            String path,
            List<String> edits) {
        int[][] dp = quantificationForestDp(left, right);
        int i = left.size();
        int j = right.size();
        List<String> reversed = new ArrayList<>();
        while (i > 0 || j > 0) {
            if (i > 0 && dp[i][j] == dp[i - 1][j] + quantificationSize(left.get(i - 1))) {
                collectDeletedQuantifiers(left.get(i - 1), path + "[" + (i - 1) + "]", reversed);
                i--;
            } else if (j > 0 && dp[i][j] == dp[i][j - 1] + quantificationSize(right.get(j - 1))) {
                collectInsertedQuantifiers(right.get(j - 1), path + "[" + j + "]", reversed);
                j--;
            } else {
                quantificationEdits(left.get(i - 1), right.get(j - 1), path + "[" + (i - 1) + "]", reversed);
                i--;
                j--;
            }
        }
        appendReverse(reversed, edits);
    }

    private static int[][] quantificationForestDp(List<QuantificationTreeNode> left, List<QuantificationTreeNode> right) {
        int[][] dp = new int[left.size() + 1][right.size() + 1];
        for (int i = 1; i <= left.size(); i++) {
            dp[i][0] = dp[i - 1][0] + quantificationSize(left.get(i - 1));
        }
        for (int j = 1; j <= right.size(); j++) {
            dp[0][j] = dp[0][j - 1] + quantificationSize(right.get(j - 1));
        }
        for (int i = 1; i <= left.size(); i++) {
            for (int j = 1; j <= right.size(); j++) {
                int delete = dp[i - 1][j] + quantificationSize(left.get(i - 1));
                int insert = dp[i][j - 1] + quantificationSize(right.get(j - 1));
                int update = dp[i - 1][j - 1] + quantificationDistance(left.get(i - 1), right.get(j - 1));
                dp[i][j] = Math.min(update, Math.min(delete, insert));
            }
        }
        return dp;
    }

    private static void variableTypeEdits(List<QuantiVar> left, List<QuantiVar> right, String path, List<String> edits) {
        Map<String, Integer> leftCounts = typeCounts(left);
        Map<String, Integer> rightCounts = typeCounts(right);
        Set<String> types = new HashSet<>();
        types.addAll(leftCounts.keySet());
        types.addAll(rightCounts.keySet());
        for (String type : types) {
            int leftCount = leftCounts.getOrDefault(type, 0);
            int rightCount = rightCounts.getOrDefault(type, 0);
            if (leftCount < rightCount) {
                edits.add(path + ": add " + (rightCount - leftCount) + " quantified variable(s) of type " + display(type));
            } else if (leftCount > rightCount) {
                edits.add(path + ": remove " + (leftCount - rightCount) + " quantified variable(s) of type " + display(type));
            }
        }
    }

    private static Map<String, Integer> typeCounts(List<QuantiVar> vars) {
        Map<String, Integer> counts = new HashMap<>();
        for (QuantiVar qv : vars) {
            counts.put(typeKey(qv), counts.getOrDefault(typeKey(qv), 0) + 1);
        }
        return counts;
    }

    private static void collectInsertedQuantifiers(QuantificationTreeNode node, String path, List<String> edits) {
        if (node == null) {
            return;
        }
        edits.add(path + ": insert " + node.getQuantifier() + " quantifier : " + display(node.getType())
                + bindingPathDisplay(node));
        for (QuantiVar qv : node.getQuantiVars()) {
            edits.add(path + ": add quantified variable " + quantiVarName(qv) + " : " + display(qv.getTypeName()));
        }
        for (int i = 0; i < node.getChildren().size(); i++) {
            collectInsertedQuantifiers(node.getChildren().get(i), path + ".child[" + i + "]", edits);
        }
    }

    private static void collectDeletedQuantifiers(QuantificationTreeNode node, String path, List<String> edits) {
        if (node == null) {
            return;
        }
        edits.add(path + ": delete " + node.getQuantifier() + " quantifier : " + display(node.getType())
                + bindingPathDisplay(node));
        for (QuantiVar qv : node.getQuantiVars()) {
            edits.add(path + ": remove quantified variable " + quantiVarName(qv) + " : " + display(qv.getTypeName()));
        }
        for (int i = 0; i < node.getChildren().size(); i++) {
            collectDeletedQuantifiers(node.getChildren().get(i), path + ".child[" + i + "]", edits);
        }
    }

    private static int matrixDistance(List<NormalForm> left, List<NormalForm> right) {
        int size = Math.max(left.size(), right.size());
        int distance = 0;
        for (int i = 0; i < size; i++) {
            if (i >= left.size()) {
                distance += eGraphSize(right.get(i).getMatrixEGraph());
            } else if (i >= right.size()) {
                distance += eGraphSize(left.get(i).getMatrixEGraph());
            } else {
                distance += matrixDistance(left.get(i), right.get(i));
            }
        }
        return distance;
    }

    private static int matrixDistance(NormalForm left, NormalForm right) {
        Map<String, String> leftTypes = variableTypes(left);
        Map<String, String> rightTypes = variableTypes(right);
        leftTypes.keySet().retainAll(matrixVariableNames(left.getMatrixEGraph()));
        rightTypes.keySet().retainAll(matrixVariableNames(right.getMatrixEGraph()));
        List<String> leftNames = new ArrayList<>(leftTypes.keySet());
        leftNames.sort((a, b) -> Integer.compare(
                candidateCount(a, leftTypes, rightTypes),
                candidateCount(b, leftTypes, rightTypes)));
        Map<String, String> mapping = new HashMap<>();
        return bestMappedDistance(
                left.getMatrixEGraph(),
                right.getMatrixEGraph(),
                leftNames,
                leftTypes,
                rightTypes,
                mapping,
                new HashSet<>(),
                0,
                Integer.MAX_VALUE);
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
        Map<String, String> leftTypes = variableTypes(left);
        Map<String, String> rightTypes = variableTypes(right);
        leftTypes.keySet().retainAll(matrixVariableNames(left.getMatrixEGraph()));
        rightTypes.keySet().retainAll(matrixVariableNames(right.getMatrixEGraph()));
        List<String> leftNames = new ArrayList<>(leftTypes.keySet());
        leftNames.sort((a, b) -> Integer.compare(
                candidateCount(a, leftTypes, rightTypes),
                candidateCount(b, leftTypes, rightTypes)));
        BestMapping best = new BestMapping();
        searchBestMapping(
                left.getMatrixEGraph(),
                right.getMatrixEGraph(),
                leftNames,
                leftTypes,
                rightTypes,
                new HashMap<>(),
                new HashSet<>(),
                0,
                best);
        return best.mapping;
    }

    private static void searchBestMapping(
            EGraphNode left,
            EGraphNode right,
            List<String> leftNames,
            Map<String, String> leftTypes,
            Map<String, String> rightTypes,
            Map<String, String> mapping,
            Set<String> usedRightNames,
            int index,
            BestMapping best) {
        if (index == leftNames.size()) {
            int distance = eGraphDistance(left, right, mapping);
            if (distance < best.distance) {
                best.distance = distance;
                best.mapping = new HashMap<>(mapping);
            }
            return;
        }
        String leftName = leftNames.get(index);
        String leftType = leftTypes.get(leftName);
        boolean mapped = false;
        for (Map.Entry<String, String> rightEntry : rightTypes.entrySet()) {
            if (usedRightNames.contains(rightEntry.getKey()) || !sameType(leftType, rightEntry.getValue())) {
                continue;
            }
            mapped = true;
            mapping.put(leftName, rightEntry.getKey());
            usedRightNames.add(rightEntry.getKey());
            searchBestMapping(left, right, leftNames, leftTypes, rightTypes, mapping, usedRightNames, index + 1, best);
            usedRightNames.remove(rightEntry.getKey());
            mapping.remove(leftName);
            if (best.distance == 0) {
                return;
            }
        }
        if (!mapped) {
            searchBestMapping(left, right, leftNames, leftTypes, rightTypes, mapping, usedRightNames, index + 1, best);
        }
    }

    private static int candidateCount(String leftName, Map<String, String> leftTypes, Map<String, String> rightTypes) {
        int count = 0;
        String leftType = leftTypes.get(leftName);
        for (String rightType : rightTypes.values()) {
            if (sameType(leftType, rightType)) {
                count++;
            }
        }
        return count;
    }

    private static int bestMappedDistance(
            EGraphNode left,
            EGraphNode right,
            List<String> leftNames,
            Map<String, String> leftTypes,
            Map<String, String> rightTypes,
            Map<String, String> mapping,
            Set<String> usedRightNames,
            int index,
            int best) {
        if (index == leftNames.size()) {
            return Math.min(best, eGraphDistance(left, right, mapping));
        }
        String leftName = leftNames.get(index);
        String leftType = leftTypes.get(leftName);
        boolean mapped = false;
        for (Map.Entry<String, String> rightEntry : rightTypes.entrySet()) {
            if (usedRightNames.contains(rightEntry.getKey()) || !sameType(leftType, rightEntry.getValue())) {
                continue;
            }
            mapped = true;
            mapping.put(leftName, rightEntry.getKey());
            usedRightNames.add(rightEntry.getKey());
            best = bestMappedDistance(left, right, leftNames, leftTypes, rightTypes, mapping, usedRightNames, index + 1, best);
            usedRightNames.remove(rightEntry.getKey());
            mapping.remove(leftName);
            if (best == 0) {
                return 0;
            }
        }
        if (!mapped) {
            best = bestMappedDistance(left, right, leftNames, leftTypes, rightTypes, mapping, usedRightNames, index + 1, best);
        }
        return best;
    }

    private static Map<String, String> variableTypes(NormalForm nf) {
        Map<String, String> types = new HashMap<>();
        for (QuantiVar qv : nf.getParams()) {
            types.put(qv.getName(), typeKey(qv));
        }
        for (QuantiVar qv : nf.getMatrixQuantiVars()) {
            types.put(qv.getName(), typeKey(qv));
        }
        return types;
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
        if (left.getOpcode() != right.getOpcode()) {
            edits.add(path + ": replace " + nodeSummary(left) + " -> " + nodeSummary(right));
        } else if (left.getOpcode() == EGraphNode.Opcode.VARIABLE) {
            String leftName = variableName(left);
            String rightName = variableName(right);
            String mappedName = variableMapping.get(leftName);
            if (mappedName != null && !mappedName.equals(rightName)) {
                edits.add(path + ": replace variable " + nodeVariableDisplay(left) + " -> " + nodeVariableDisplay(right));
            } else if (mappedName == null && !sameType(left.getSourceType(), right.getSourceType())) {
                edits.add(path + ": replace variable type " + display(left.getSourceType()) + " -> " + display(right.getSourceType()));
            }
        } else if ((left.getOpcode() == EGraphNode.Opcode.GLOBALBINDING || left.getOpcode() == EGraphNode.Opcode.CONSTANT)
                && !safeEquals(left.getSourceName(), right.getSourceName())) {
            edits.add(path + ": replace binding " + display(left.getSourceName()) + " -> " + display(right.getSourceName()));
        }
        List<EGraphNode> leftChildren = left.getChildren();
        List<EGraphNode> rightChildren = right.getChildren();
        if (left.getOpcode() == right.getOpcode() && left.isCommutative() && right.isCommutative()) {
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
        int[][] dp = new int[left.size() + 1][right.size() + 1];
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
        if (left == null) {
            return eGraphSize(right);
        }
        if (right == null) {
            return eGraphSize(left);
        }
        int distance = nodeUpdateCost(left, right, variableMapping);
        List<EGraphNode> leftChildren = left.getChildren();
        List<EGraphNode> rightChildren = right.getChildren();
        if (left.getOpcode() == right.getOpcode() && left.isCommutative() && right.isCommutative()) {
            leftChildren = sortedForMapping(leftChildren, variableMapping);
            rightChildren = sortedForMapping(rightChildren, java.util.Collections.emptyMap());
        }
        distance += childDistance(leftChildren, rightChildren, variableMapping);
        return distance;
    }

    private static List<EGraphNode> sortedForMapping(
            List<EGraphNode> children,
            Map<String, String> variableMapping) {
        List<EGraphNode> sorted = new ArrayList<>(children);
        sorted.sort((left, right) -> mappedSortKey(left, variableMapping)
                .compareTo(mappedSortKey(right, variableMapping)));
        return sorted;
    }

    private static String mappedSortKey(EGraphNode node, Map<String, String> variableMapping) {
        StringBuilder key = new StringBuilder(node.getOpcode().toString()).append(':');
        if (node.getOpcode() == EGraphNode.Opcode.VARIABLE) {
            String name = variableName(node);
            key.append(variableMapping.getOrDefault(name, name));
        } else if (node.getSourceName() != null) {
            key.append(node.getSourceName());
        }
        key.append('[');
        List<EGraphNode> children = new ArrayList<>(node.getChildren());
        if (node.isCommutative()) {
            children = sortedForMapping(children, variableMapping);
        }
        for (EGraphNode child : children) {
            key.append(mappedSortKey(child, variableMapping)).append(',');
        }
        return key.append(']').toString();
    }

    private static int childDistance(List<EGraphNode> left, List<EGraphNode> right, Map<String, String> variableMapping) {
        int[][] dp = new int[left.size() + 1][right.size() + 1];
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
        return dp[left.size()][right.size()];
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
            return sameType(left.getSourceType(), right.getSourceType()) ? 0 : 1;
        }
        if (left.getOpcode() == EGraphNode.Opcode.GLOBALBINDING || left.getOpcode() == EGraphNode.Opcode.CONSTANT) {
            return safeEquals(left.getSourceName(), right.getSourceName()) ? 0 : 1;
        }
        return 0;
    }

    private static int eGraphSize(EGraphNode node) {
        if (node == null) {
            return 0;
        }
        int size = 1;
        for (EGraphNode child : node.getChildren()) {
            size += eGraphSize(child);
        }
        return size;
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
        int cost = safeEquals(left.label, right.label) ? 0 : 1;
        int[][] dp = new int[left.children.size() + 1][right.children.size() + 1];
        for (int i = 1; i <= left.children.size(); i++) {
            dp[i][0] = dp[i - 1][0] + temporalSize(left.children.get(i - 1));
        }
        for (int j = 1; j <= right.children.size(); j++) {
            dp[0][j] = dp[0][j - 1] + temporalSize(right.children.get(j - 1));
        }
        for (int i = 1; i <= left.children.size(); i++) {
            for (int j = 1; j <= right.children.size(); j++) {
                int delete = dp[i - 1][j] + temporalSize(left.children.get(i - 1));
                int insert = dp[i][j - 1] + temporalSize(right.children.get(j - 1));
                int update = dp[i - 1][j - 1] + treeDistance(left.children.get(i - 1), right.children.get(j - 1));
                dp[i][j] = Math.min(update, Math.min(delete, insert));
            }
        }
        return cost + dp[left.children.size()][right.children.size()];
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
        int[][] dp = new int[left.size() + 1][right.size() + 1];
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
        String name = firstNonEmpty(node.getAlphaName(), node.getSourceName());
        if (name == null) {
            return node.getOpcode().toString();
        }
        return node.getOpcode() + "(" + name + ")";
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

    private static String quantifierPrefix(QuantificationTreeNode root) {
        List<String> parts = new ArrayList<>();
        collectQuantifierPrefixes(root, parts);
        if (parts.isEmpty()) {
            return "";
        }
        return String.join(" ", parts) + " . ";
    }

    private static void collectQuantifierPrefixes(QuantificationTreeNode node, List<String> parts) {
        if (node == null) {
            return;
        }
        parts.add(quantifierFormula(node));
        for (QuantificationTreeNode child : node.getChildren()) {
            collectQuantifierPrefixes(child, parts);
        }
    }

    private static String quantifierFormula(QuantificationTreeNode node) {
        List<String> names = new ArrayList<>();
        for (QuantiVar qv : node.getQuantiVars()) {
            names.add(quantiVarName(qv));
        }
        String disj = node.isDisj() ? " disj" : "";
        return node.getQuantifier() + disj + " " + String.join(", ", names) + " : " + display(node.getType());
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

    private static String bindingPathKey(QuantificationTreeNode node) {
        if (node == null || node.getBindingPath() == null || node.getBindingPath().isEmpty()) {
            return null;
        }
        return node.getBindingPath();
    }

    private static String bindingPathDisplay(QuantificationTreeNode node) {
        String path = bindingPathKey(node);
        return path == null ? "" : " at " + path;
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
        return qv.getTypeName() == null ? "" : qv.getTypeName();
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
