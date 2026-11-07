package is.fivefivefive.CanDis.metric;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import org.json.JSONArray;
import org.json.JSONObject;

/** Fixed-native-order declaration edits. Admission of that order is a separate obligation. */
public final class DeclarationReplay {
    public record Atom(String occurrence, List<String> tuple, String admission) {
        public Atom {
            Objects.requireNonNull(occurrence);
            tuple = List.copyOf(tuple);
            Objects.requireNonNull(admission);
            if (tuple.size() != 4) throw new IllegalArgumentException("Expected four repair-tuple fields");
            long length = occurrence.length() + (long) admission.length();
            for (String field : tuple) length += field.length();
            if (length > 16_384) throw new IllegalArgumentException("DECLARATION_REPLAY_ATOM_BUDGET");
        }
        public JSONObject json() {
            return new JSONObject().put("occurrence", occurrence).put("tuple", new JSONArray(tuple))
                    .put("admission", admission);
        }
    }

    @FunctionalInterface
    public interface AllowedMove {
        boolean test(int leftIndex, int rightIndex);
    }

    private DeclarationReplay() { }

    public static void requireBounded(int leftSize, int rightSize) {
        if (leftSize < 0 || rightSize < 0 || leftSize > 256 || rightSize > 256
                || ((long)leftSize + 1) * ((long)rightSize + 1) > 65_536)
            throw new IllegalStateException("DECLARATION_REPLAY_CELL_BUDGET");
    }

    /** Backtraces the arm's actual DP, optionally constrained to its selected paid correspondences. */
    public static JSONObject capture(List<Atom> source, List<Atom> target, int[][] nativeDp,
            AllowedMove allowed) {
        source = List.copyOf(source); target = List.copyOf(target);
        int n = source.size(), m = target.size();
        requireBounded(n,m);
        require(nativeDp.length == n + 1, "DP source dimension");
        for (int[] row : nativeDp) require(row != null && row.length == m + 1, "DP target dimension");
        require(nativeDp[0][0] == 0, "DP origin");
        byte[][] moves = new byte[n + 1][m + 1];
        moves[0][0] = 4;
        for (int i = 0; i <= n; i++) for (int j = 0; j <= m; j++) {
            if (i == 0 && j == 0) continue;
            if (i > 0 && j > 0 && moves[i-1][j-1] != 0 && allowed.test(i-1,j-1)
                    && nativeDp[i][j] == Math.addExact(nativeDp[i-1][j-1], update(source.get(i-1),target.get(j-1))))
                moves[i][j] = 1;
            else if (i > 0 && moves[i-1][j] != 0 && allowed.test(i-1,-1)
                    && nativeDp[i][j] == Math.addExact(nativeDp[i-1][j],1)) moves[i][j] = 2;
            else if (j > 0 && moves[i][j-1] != 0 && allowed.test(-1,j-1)
                    && nativeDp[i][j] == Math.addExact(nativeDp[i][j-1],1)) moves[i][j] = 3;
        }
        require(moves[n][m] != 0, "No minimum path matches selected correspondence");
        List<JSONObject> reversed = new ArrayList<>();
        int i = n, j = m;
        while (i > 0 || j > 0) {
            byte move = moves[i][j];
            int l = move == 3 ? -1 : --i, r = move == 2 ? -1 : --j;
            int cost = l < 0 || r < 0 ? 1 : update(source.get(l),target.get(r));
            reversed.add(new JSONObject().put("kind", l < 0 ? "insert" : r < 0 ? "delete" : cost == 0 ? "keep" : "update")
                    .put("leftIndex",l).put("rightIndex",r).put("cost",cost)
                    .put("source",l < 0 ? JSONObject.NULL : source.get(l).json())
                    .put("target",r < 0 ? JSONObject.NULL : target.get(r).json()));
        }
        Collections.reverse(reversed);
        JSONObject receipt = new JSONObject().put("source",snapshot(source)).put("target",snapshot(target))
                .put("operations",new JSONArray(reversed)).put("cost",nativeDp[n][m])
                .put("replayedCost",nativeDp[n][m]).put("orderingAdmissionChecked",false)
                .put("complete",false);
        int checked = verify(source,target,receipt);
        require(checked == nativeDp[n][m], "Native cost mismatch");
        return receipt.put("sliceReplayChecked",true);
    }

    /** Independent of the DP and AllowedMove callback; verifies the fixed-list edit derivation. */
    public static int verify(List<Atom> source, List<Atom> target, JSONObject receipt) {
        requireBounded(source.size(),target.size());
        require(snapshot(source).similar(receipt.getJSONArray("source")), "Substituted source/order/context");
        require(snapshot(target).similar(receipt.getJSONArray("target")), "Substituted target/order/context");
        JSONArray operations = receipt.getJSONArray("operations");
        require(operations.length() <= source.size() + target.size(), "Operation budget");
        int i = 0, j = 0, total = 0;
        for (int k = 0; k < operations.length(); k++) {
            JSONObject op = operations.getJSONObject(k);
            int l = integer(op,"leftIndex"), r = integer(op,"rightIndex");
            require(l >= -1 && r >= -1 && (l >= 0 || r >= 0), "Invalid indices");
            require(l < 0 || (l == i && i < source.size()), "Source occurrence/order");
            require(r < 0 || (r == j && j < target.size()), "Target occurrence/order");
            if (l < 0) require(op.isNull("source"), "Insertion source");
            else require(source.get(i).json().similar(op.getJSONObject("source")), "Source atom");
            if (r < 0) require(op.isNull("target"), "Deletion target");
            else require(target.get(j).json().similar(op.getJSONObject("target")), "Target atom");
            int cost = l < 0 || r < 0 ? 1 : update(source.get(i),target.get(j));
            require(op.getString("kind").equals(l < 0 ? "insert" : r < 0 ? "delete" : cost == 0 ? "keep" : "update"), "Operation kind");
            require(integer(op,"cost") == cost, "Operation cost");
            total = Math.addExact(total,cost);
            if (l >= 0) i++;
            if (r >= 0) j++;
        }
        require(i == source.size() && j == target.size(), "Unconsumed/unproduced occurrences");
        require(integer(receipt,"cost") == total && integer(receipt,"replayedCost") == total, "Total cost");
        return total;
    }

    private static int update(Atom left, Atom right) { return left.tuple.equals(right.tuple) ? 0 : 1; }
    private static JSONArray snapshot(List<Atom> atoms) {
        JSONArray out = new JSONArray();
        for (Atom atom : atoms) out.put(atom.json());
        return out;
    }
    static int integer(JSONObject object, String key) {
        Object value = object.get(key);
        require(value instanceof Number, "Non-numeric " + key);
        try { return new java.math.BigDecimal(value.toString()).intValueExact(); }
        catch (ArithmeticException | NumberFormatException ex) { throw new IllegalArgumentException("Non-integral/out-of-range " + key,ex); }
    }
    static void require(boolean yes, String message) {
        if (!yes) throw new IllegalArgumentException("DECLARATION_REPLAY_INVALID: " + message);
    }
}
