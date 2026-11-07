package is.fivefivefive.CanDis.core;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;

/** Unit-cost Zhang-Shasha distance for finite, rooted, ordered trees. */
public final class OrderedTreeEditDistance {
    /** Supplies the label and ordered children without changing tree ownership. */
    public interface Adapter<T> {
        String label(T node);

        List<? extends T> children(T node);
    }

    private OrderedTreeEditDistance() {
    }

    public record Match(int leftPostorder, int rightPostorder) { }

    public record Alignment(int cost, List<Match> matches) {
        public Alignment { matches = List.copyOf(matches); }
    }

    /** Bounded backtrace of the same Zhang-Shasha recurrence, not subtree edits. */
    public static <T> Alignment alignment(T left, T right, Adapter<T> adapter) {
        Objects.requireNonNull(adapter,"tree adapter");
        IndexedTree<T> a = IndexedTree.create(left, adapter, 256, 128);
        IndexedTree<T> b = IndexedTree.create(right, adapter, 256, 128);
        int[][] distance = new int[a.size() + 1][b.size() + 1];
        for (int i : a.keyroots) for (int j : b.keyroots)
            computeForestDistance(a, b, i, j, distance, adapter);
        List<Match> matches = new ArrayList<>();
        backtrace(a, b, a.size(), b.size(), distance, adapter, matches);
        matches.sort(Comparator.comparingInt(Match::leftPostorder));
        return new Alignment(distance[a.size()][b.size()], matches);
    }

    private static <T> void backtrace(IndexedTree<T> a, IndexedTree<T> b,
            int aRoot, int bRoot, int[][] distance, Adapter<T> adapter, List<Match> matches) {
        int aBase = a.leftmost[aRoot], bBase = b.leftmost[bRoot];
        int[][] forest = computeForestDistance(a, b, aRoot, bRoot, distance, adapter);
        int row = aRoot - aBase + 1, col = bRoot - bBase + 1;
        while (row > 0 || col > 0) {
            int i = row + aBase - 1, j = col + bBase - 1;
            if (row > 0 && col > 0) {
                if (a.leftmost[i] == aBase && b.leftmost[j] == bBase) {
                    int cost = Objects.equals(adapter.label(a.node(i)), adapter.label(b.node(j))) ? 0 : 1;
                    if (forest[row][col] == forest[row - 1][col - 1] + cost) {
                        matches.add(new Match(i, j));
                        row--; col--; continue;
                    }
                } else {
                    int prefixA = a.leftmost[i] - aBase, prefixB = b.leftmost[j] - bBase;
                    if (forest[row][col] == forest[prefixA][prefixB] + distance[i][j]) {
                        backtrace(a, b, i, j, distance, adapter, matches);
                        row = prefixA; col = prefixB; continue;
                    }
                }
            }
            if (row > 0 && forest[row][col] == forest[row - 1][col] + 1) row--;
            else if (col > 0 && forest[row][col] == forest[row][col - 1] + 1) col--;
            else throw new IllegalStateException("TEMPORAL_BACKTRACE_INVALID");
        }
    }

    public static <T> int distance(T left, T right, Adapter<T> adapter) {
        Objects.requireNonNull(left, "left tree");
        Objects.requireNonNull(right, "right tree");
        Objects.requireNonNull(adapter, "tree adapter");
        IndexedTree<T> leftTree = IndexedTree.create(left, adapter);
        IndexedTree<T> rightTree = IndexedTree.create(right, adapter);
        int[][] treeDistance = new int[leftTree.size() + 1][rightTree.size() + 1];

        for (int leftRoot : leftTree.keyroots) {
            for (int rightRoot : rightTree.keyroots) {
                computeForestDistance(
                        leftTree, rightTree, leftRoot, rightRoot, treeDistance, adapter);
            }
        }
        return treeDistance[leftTree.size()][rightTree.size()];
    }

    private static <T> int[][] computeForestDistance(
            IndexedTree<T> left,
            IndexedTree<T> right,
            int leftRoot,
            int rightRoot,
            int[][] treeDistance,
            Adapter<T> adapter) {
        int leftBase = left.leftmost[leftRoot];
        int rightBase = right.leftmost[rightRoot];
        int[][] forestDistance = new int[
                leftRoot - leftBase + 2][rightRoot - rightBase + 2];

        for (int leftIndex = leftBase; leftIndex <= leftRoot; leftIndex++) {
            int row = leftIndex - leftBase + 1;
            forestDistance[row][0] = Math.addExact(forestDistance[row - 1][0], 1);
        }
        for (int rightIndex = rightBase; rightIndex <= rightRoot; rightIndex++) {
            int column = rightIndex - rightBase + 1;
            forestDistance[0][column] = Math.addExact(forestDistance[0][column - 1], 1);
        }

        for (int leftIndex = leftBase; leftIndex <= leftRoot; leftIndex++) {
            int row = leftIndex - leftBase + 1;
            for (int rightIndex = rightBase; rightIndex <= rightRoot; rightIndex++) {
                int column = rightIndex - rightBase + 1;
                int delete = Math.addExact(forestDistance[row - 1][column], 1);
                int insert = Math.addExact(forestDistance[row][column - 1], 1);
                int replace;
                if (left.leftmost[leftIndex] == leftBase
                        && right.leftmost[rightIndex] == rightBase) {
                    int update = Objects.equals(
                            adapter.label(left.node(leftIndex)),
                            adapter.label(right.node(rightIndex))) ? 0 : 1;
                    replace = Math.addExact(forestDistance[row - 1][column - 1], update);
                    forestDistance[row][column] = Math.min(replace, Math.min(delete, insert));
                    treeDistance[leftIndex][rightIndex] = forestDistance[row][column];
                } else {
                    int leftPrefix = left.leftmost[leftIndex] - leftBase;
                    int rightPrefix = right.leftmost[rightIndex] - rightBase;
                    replace = Math.addExact(
                            forestDistance[leftPrefix][rightPrefix],
                            treeDistance[leftIndex][rightIndex]);
                    forestDistance[row][column] = Math.min(replace, Math.min(delete, insert));
                }
            }
        }
        return forestDistance;
    }

    private static final class IndexedTree<T> {
        private final List<T> postorder;
        private final int[] leftmost;
        private final List<Integer> keyroots;

        private IndexedTree(
                List<T> postorder,
                int[] leftmost,
                List<Integer> keyroots) {
            this.postorder = postorder;
            this.leftmost = leftmost;
            this.keyroots = keyroots;
        }

        private static <T> IndexedTree<T> create(T root, Adapter<T> adapter) {
            return create(root,adapter,Integer.MAX_VALUE,Integer.MAX_VALUE);
        }

        private static <T> IndexedTree<T> create(T root, Adapter<T> adapter,int maxNodes,int maxDepth) {
            List<T> postorder = new ArrayList<>();
            List<Integer> leftmost = new ArrayList<>();
            leftmost.add(0);
            appendPostorder(root, adapter, postorder, leftmost,new int[]{maxNodes},maxDepth);

            int[] leftmostArray = new int[leftmost.size()];
            int[] lastRootForLeaf = new int[leftmost.size()];
            for (int index = 1; index < leftmost.size(); index++) {
                leftmostArray[index] = leftmost.get(index);
                lastRootForLeaf[leftmostArray[index]] = index;
            }
            List<Integer> keyroots = new ArrayList<>();
            for (int rootIndex : lastRootForLeaf) {
                if (rootIndex != 0) {
                    keyroots.add(rootIndex);
                }
            }
            keyroots.sort(Comparator.naturalOrder());
            return new IndexedTree<>(List.copyOf(postorder), leftmostArray,
                    List.copyOf(keyroots));
        }

        private static <T> int appendPostorder(
                T node,
                Adapter<T> adapter,
                List<T> postorder,
                List<Integer> leftmost,int[] budget,int depthRemaining) {
            if (--budget[0] < 0 || depthRemaining < 0)
                throw new IllegalStateException("TEMPORAL_REPLAY_NODE_OR_DEPTH_BUDGET");
            Objects.requireNonNull(node, "tree node");
            List<? extends T> children = Objects.requireNonNull(
                    adapter.children(node), "ordered children");
            int firstLeaf = 0;
            for (T child : children) {
                int childLeaf = appendPostorder(child, adapter, postorder, leftmost,budget,depthRemaining-1);
                if (firstLeaf == 0) {
                    firstLeaf = childLeaf;
                }
            }
            Objects.requireNonNull(adapter.label(node), "tree label");
            postorder.add(node);
            int index = postorder.size();
            int nodeLeftmost = firstLeaf == 0 ? index : firstLeaf;
            leftmost.add(nodeLeftmost);
            return nodeLeftmost;
        }

        private int size() {
            return postorder.size();
        }

        private T node(int oneBasedPostorderIndex) {
            return postorder.get(oneBasedPostorderIndex - 1);
        }
    }
}
