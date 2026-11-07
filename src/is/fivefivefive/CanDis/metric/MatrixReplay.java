package is.fivefivefive.CanDis.metric;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HexFormat;
import java.util.IdentityHashMap;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

/** Diagnostic matrix derivations at fixed native bindings, not public repair plans. */
public final class MatrixReplay<N> {
    public interface NativeCost<N> {
        /** Complete immutable head identity, including the selected binding context. */
        String label(N node);
        List<N> children(N node);
        List<N> alternatives(N node);
        boolean unordered(N left, N right);
        int size(N node);
        int update(N left, N right);
        int distance(N left, N right);
    }

    private static final int MAX_DEPTH = 128;
    private static final int MAX_ASSIGNMENT_DIMENSION = 16;
    private final NativeCost<N> nativeCost;
    private final IdentityHashMap<N, JSONArray> snapshots = new IdentityHashMap<>();
    private final IdentityHashMap<N, String> hashes = new IdentityHashMap<>();
    private final IdentityHashMap<N, Long> encodedLengths = new IdentityHashMap<>();
    private long remaining;

    public MatrixReplay(NativeCost<N> nativeCost) { this(nativeCost, 1_000_000); }

    public MatrixReplay(NativeCost<N> nativeCost, long budget) {
        if (budget <= 0) throw new IllegalArgumentException("Replay budget must be positive");
        this.nativeCost = java.util.Objects.requireNonNull(nativeCost);
        remaining = budget;
    }

    private void spend(long amount) {
        if (amount < 0 || amount > remaining) throw new IllegalStateException("MATRIX_REPLAY_BUDGET");
        remaining -= amount;
    }

    private void enter(int depth) {
        spend(1);
        if (depth > MAX_DEPTH) throw new IllegalStateException("MATRIX_REPLAY_DEPTH");
    }

    private JSONArray snapshot(N node, int depth) {
        enter(depth);
        if (node == null) return new JSONArray();
        JSONArray known = snapshots.get(node);
        if (known != null) return known;
        String label = nativeCost.label(node);
        spend(label.length());
        // JSONArray serializes shared references by value. Charge the expanded
        // length for every occurrence BEFORE putting it in a parent or encoding it.
        String encodedLabel = JSONObject.quote(label);
        long length = Math.addExact(encodedLabel.length(), 8L); // [label,[],[]]
        spend(length);
        JSONArray children = new JSONArray();
        for (N child : nativeCost.children(node)) {
            JSONArray value = snapshot(child, depth + 1);
            long added = Math.addExact(child == null ? 2L : encodedLengths.get(child), children.isEmpty() ? 0L : 1L);
            spend(added); length = Math.addExact(length, added); children.put(value);
        }
        JSONArray alternatives = new JSONArray();
        for (N alternative : nativeCost.alternatives(node)) {
            JSONArray value = snapshot(alternative, depth + 1);
            long added = Math.addExact(alternative == null ? 2L : encodedLengths.get(alternative), alternatives.isEmpty() ? 0L : 1L);
            spend(added); length = Math.addExact(length, added); alternatives.put(value);
        }
        JSONArray result = new JSONArray().put(label).put(children).put(alternatives);
        String encoded = result.toString();
        require(encoded.length() == length, "Snapshot encoded-length accounting");
        snapshots.put(node, result);
        encodedLengths.put(node, length);
        hashes.put(node, sha256(encoded));
        return result;
    }

    private static String sha256(String value) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException ex) { throw new IllegalStateException(ex); }
    }

    private String hash(N node) { return node == null ? sha256("[]") : hashes.get(node); }

    public JSONObject capture(N left, N right) {
        JSONArray source = snapshot(left, 0), target = snapshot(right, 0);
        JSONObject derivation = trace(left, right, 0);
        int expected = nativeCost.distance(left, right);
        int replayed = verifyNode(left, right, derivation, 0);
        require(expected == replayed, "Native matrix cost disagrees with replay");
        // Do not expose cached snapshots: callers may edit their receipt before replay.
        return new JSONObject().put("source", new JSONArray(source.toString()))
                .put("target", new JSONArray(target.toString()))
                .put("sourceSha256", hash(left)).put("targetSha256", hash(right))
                .put("cost", expected).put("replayedCost", replayed)
                .put("matrixReplayChecked", true).put("derivation", derivation);
    }

    /** Does not call NativeCost.distance or solve an assignment/sequence DP. */
    public int verify(N left, N right, JSONObject receipt) {
        require(snapshot(left, 0).similar(receipt.getJSONArray("source")), "Wrong source snapshot");
        require(snapshot(right, 0).similar(receipt.getJSONArray("target")), "Wrong target snapshot");
        require(hash(left).equals(receipt.getString("sourceSha256")), "Wrong source hash");
        require(hash(right).equals(receipt.getString("targetSha256")), "Wrong target hash");
        int result = verifyNode(left, right, receipt.getJSONObject("derivation"), 0);
        require(result == integer(receipt, "cost") && result == integer(receipt, "replayedCost"),
                "Wrong receipt charge");
        return result;
    }

    private JSONObject base(N left, N right, String kind, int cost) {
        return new JSONObject().put("kind", kind).put("cost", cost)
                .put("sourceSha256", hash(left)).put("targetSha256", hash(right))
                .put("sourceHead", left == null ? "" : nativeCost.label(left))
                .put("targetHead", right == null ? "" : nativeCost.label(right));
    }

    private JSONObject trace(N left, N right, int depth) {
        enter(depth);
        if (left == null || right == null) {
            N present = left == null ? right : left;
            // Whole-phase null roots with alternative-minimum charging need a
            // different selection receipt. Child deletion always charges raw size.
            if (present != null && nativeCost.distance(left, right) != nativeCost.size(present))
                throw new IllegalStateException("MATRIX_REPLAY_NULL_ALTERNATIVE_ROOT");
            return base(left, right, left == null ? "insert" : "delete",
                    present == null ? 0 : nativeCost.size(present));
        }
        int cost = nativeCost.distance(left, right);
        List<N> la = nativeCost.alternatives(left), ra = nativeCost.alternatives(right);
        if (!la.isEmpty() || !ra.isEmpty()) {
            List<N> ls = la.isEmpty() ? List.of(left) : la;
            List<N> rs = ra.isEmpty() ? List.of(right) : ra;
            for (int i = 0; i < ls.size(); i++) for (int j = 0; j < rs.size(); j++) {
                spend(1);
                if (nativeCost.distance(ls.get(i), rs.get(j)) == cost)
                    return base(left, right, "select", cost)
                            .put("leftAlternative", la.isEmpty() ? -1 : i)
                            .put("rightAlternative", ra.isEmpty() ? -1 : j)
                            .put("selected", trace(ls.get(i), rs.get(j), depth + 1));
            }
            throw new IllegalStateException("No native alternative attains cost");
        }
        List<N> ls = nativeCost.children(left), rs = nativeCost.children(right);
        boolean unordered = nativeCost.unordered(left, right);
        List<int[]> pairs = unordered ? assignment(ls, rs) : sequence(ls, rs);
        JSONArray edges = new JSONArray();
        int charge = nativeCost.update(left, right);
        for (int[] pair : pairs) {
            int i = pair[0], j = pair[1];
            N l = i < 0 ? null : ls.get(i), r = j < 0 ? null : rs.get(j);
            JSONObject child;
            if (i < 0 || j < 0) {
                child = base(l, r, i < 0 ? "insert" : "delete", nativeCost.size(i < 0 ? r : l));
            } else child = trace(l, r, depth + 1);
            charge = Math.addExact(charge, child.getInt("cost"));
            edges.put(new JSONObject().put("leftIndex", i).put("rightIndex", j).put("edit", child));
        }
        require(charge == cost, "Backtrace does not attain native cost");
        return base(left, right, "node", cost).put("unordered", unordered)
                .put("headCost", nativeCost.update(left, right)).put("children", edges);
    }

    private List<int[]> sequence(List<N> left, List<N> right) {
        int n = left.size(), m = right.size();
        spend(Math.multiplyExact((long)n + 1, (long)m + 1));
        int[][] dp = new int[n + 1][m + 1];
        for (int i = 1; i <= n; i++) dp[i][0] = Math.addExact(dp[i-1][0], nativeCost.size(left.get(i-1)));
        for (int j = 1; j <= m; j++) dp[0][j] = Math.addExact(dp[0][j-1], nativeCost.size(right.get(j-1)));
        for (int i = 1; i <= n; i++) for (int j = 1; j <= m; j++)
            dp[i][j] = Math.min(Math.addExact(dp[i-1][j-1], nativeCost.distance(left.get(i-1), right.get(j-1))),
                    Math.min(Math.addExact(dp[i-1][j], nativeCost.size(left.get(i-1))),
                            Math.addExact(dp[i][j-1], nativeCost.size(right.get(j-1)))));
        List<int[]> pairs = new ArrayList<>();
        int i = n, j = m;
        while (i > 0 || j > 0) {
            if (i > 0 && j > 0 && dp[i][j] == Math.addExact(dp[i-1][j-1], nativeCost.distance(left.get(i-1), right.get(j-1)))) {
                pairs.add(new int[]{--i, --j});
            } else if (i > 0 && dp[i][j] == Math.addExact(dp[i-1][j], nativeCost.size(left.get(i-1)))) {
                pairs.add(new int[]{--i, -1});
            } else pairs.add(new int[]{-1, --j});
        }
        java.util.Collections.reverse(pairs);
        return pairs;
    }

    private List<int[]> assignment(List<N> left, List<N> right) {
        int n = left.size(), m = right.size(), dimension = Math.addExact(n, m);
        if (n == 0 || m == 0) return sequence(left, right);
        if (dimension > MAX_ASSIGNMENT_DIMENSION) throw new IllegalStateException("MATRIX_REPLAY_ASSIGNMENT_BUDGET");
        int count = 1 << dimension;
        spend(Math.multiplyExact((long)count, dimension));
        int[][] costs = new int[dimension][dimension];
        for (int i = 0; i < dimension; i++) for (int j = 0; j < dimension; j++)
            costs[i][j] = i < n && j < m ? nativeCost.distance(left.get(i), right.get(j))
                    : i < n ? nativeCost.size(left.get(i)) : j < m ? nativeCost.size(right.get(j)) : 0;
        int[] dp = new int[count], chosen = new int[count];
        Arrays.fill(dp, Integer.MAX_VALUE); dp[0] = 0;
        for (int mask = 1; mask < count; mask++) {
            int row = Integer.bitCount(mask) - 1;
            for (int col = 0; col < dimension; col++) if ((mask & (1 << col)) != 0) {
                int previous = mask ^ (1 << col);
                int candidate = Math.addExact(dp[previous], costs[row][col]);
                if (candidate < dp[mask]) { dp[mask] = candidate; chosen[mask] = col; }
            }
        }
        int[] columns = new int[dimension];
        for (int mask = count - 1, row = dimension - 1; row >= 0; row--) {
            columns[row] = chosen[mask]; mask ^= 1 << columns[row];
        }
        List<int[]> pairs = new ArrayList<>();
        for (int i = 0; i < dimension; i++) {
            int j = columns[i];
            if (i < n || j < m) pairs.add(new int[]{i < n ? i : -1, j < m ? j : -1});
        }
        return pairs;
    }

    private int verifyNode(N left, N right, JSONObject proof, int depth) {
        enter(depth);
        require(hash(left).equals(proof.getString("sourceSha256"))
                && hash(right).equals(proof.getString("targetSha256")), "Substituted occurrence");
        require((left == null ? "" : nativeCost.label(left)).equals(proof.getString("sourceHead"))
                && (right == null ? "" : nativeCost.label(right)).equals(proof.getString("targetHead")), "Substituted head");
        String kind = proof.getString("kind");
        int cost;
        if (left == null || right == null) {
            require(kind.equals(left == null ? "insert" : "delete"), "Wrong whole-subtree edit");
            cost = left == null && right == null ? 0 : nativeCost.size(left == null ? right : left);
        } else if (kind.equals("select")) {
            N l = select(left, integer(proof, "leftAlternative"));
            N r = select(right, integer(proof, "rightAlternative"));
            require(l != left || r != right, "Empty alternative selection");
            cost = verifyNode(l, r, proof.getJSONObject("selected"), depth + 1);
        } else {
            require(kind.equals("node") && nativeCost.alternatives(left).isEmpty()
                    && nativeCost.alternatives(right).isEmpty(), "Missing alternative selection");
            boolean unordered = nativeCost.unordered(left, right);
            require(proof.getBoolean("unordered") == unordered, "Changed sequence semantics");
            cost = nativeCost.update(left, right);
            require(cost == integer(proof, "headCost"), "Wrong head charge/binding");
            List<N> ls = nativeCost.children(left), rs = nativeCost.children(right);
            boolean[] usedLeft = new boolean[ls.size()], usedRight = new boolean[rs.size()];
            int priorLeft = -1, priorRight = -1;
            JSONArray children = proof.getJSONArray("children");
            for (int k = 0; k < children.length(); k++) {
                JSONObject edge = children.getJSONObject(k);
                int i = integer(edge, "leftIndex"), j = integer(edge, "rightIndex");
                require(i >= -1 && j >= -1 && (i >= 0 || j >= 0), "Invalid child indices");
                require(i < ls.size() && j < rs.size(), "Child index out of bounds");
                if (i >= 0) {
                    require(!usedLeft[i] && (unordered || i > priorLeft), "Source multiplicity/order violation");
                    usedLeft[i] = true; priorLeft = i;
                }
                if (j >= 0) {
                    require(!usedRight[j] && (unordered || j > priorRight), "Target multiplicity/order violation");
                    usedRight[j] = true; priorRight = j;
                }
                cost = Math.addExact(cost, verifyNode(i < 0 ? null : ls.get(i), j < 0 ? null : rs.get(j),
                        edge.getJSONObject("edit"), depth + 1));
            }
            for (boolean used : usedLeft) require(used, "Unconsumed source occurrence");
            for (boolean used : usedRight) require(used, "Unproduced target occurrence");
        }
        require(cost == integer(proof, "cost"), "Wrong derivation charge");
        return cost;
    }

    private N select(N node, int index) {
        List<N> alternatives = nativeCost.alternatives(node);
        if (alternatives.isEmpty()) { require(index == -1, "Spurious selection"); return node; }
        require(index >= 0 && index < alternatives.size(), "Invalid alternative index");
        return alternatives.get(index);
    }

    private static void require(boolean condition, String message) {
        if (!condition) throw new IllegalArgumentException("MATRIX_REPLAY_INVALID: " + message);
    }

    private static int integer(JSONObject value, String key) {
        Object number = value.get(key);
        require(number instanceof Number, "Non-numeric " + key);
        try { return new java.math.BigDecimal(number.toString()).intValueExact(); }
        catch (ArithmeticException | NumberFormatException ex) {
            throw new IllegalArgumentException("MATRIX_REPLAY_INVALID: Non-integral/out-of-range " + key, ex);
        }
    }
}
