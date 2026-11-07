package is.fivefivefive.CanDis.core;

import java.util.*;
import java.util.function.Consumer;
import java.util.function.ToIntBiFunction;

/** Paid edit links, never free alpha equivalences or certified source rewrites. */
final class FastPaidDeclarationAlignment {
    static final int MAX_DECLARATIONS = 64;
    static final long MAX_VISITS = 100_000;

    private FastPaidDeclarationAlignment() { }

    static boolean supportsPair(List<NormalForm> left,List<NormalForm> right) {
        if(!supports(left) || !supports(right)) return false;
        // No new cross-owner local/local alignment is admitted by this slice.
        return left.get(0).getLocalQuantiVars().isEmpty() || right.get(0).getLocalQuantiVars().isEmpty();
    }

    static boolean supports(List<NormalForm> forms) {
        if (forms.size() != 1) return false;
        NormalForm f = forms.get(0);
        if (!f.isFrozenForCertification() || f.getMatrixEGraph() == null
                || f.getTemporalOp() != NormalForm.TemporalOp.NONE || !f.getTemporalChildren().isEmpty()
                || !f.getParams().isEmpty() || !f.getInheritedQuantiVars().isEmpty()
                || !f.getPhaseLocalBindingImports().isEmpty()) return false;
        List<QuantiVar> qs = f.getMatrixQuantiVars();
        if (qs.isEmpty()) return false;
        Set<String> names = new HashSet<>(), paths = new HashSet<>();
        var firstType = qs.get(0).getExactAlloyType();
        for (QuantiVar q : qs) {
            var type = q.getExactAlloyType();
            // Paid diagonals are edits, not exchanges across quantifier blocks.
            // CanonicalDistance retains each contiguous ALL/SOME run in place.
            if (!q.isFrozenForCertification()
                    || (q.getQuantifier() != QuantiVar.Quantifier.ALL && q.getQuantifier() != QuantiVar.Quantifier.SOME)
                    || q.getCardinality() != QuantiVar.Cardinality.ONE || q.getDisjointnessClass() != 0
                    || q.getBindingPath().isEmpty() || !paths.add(q.getBindingPath())
                    || !names.add(q.getName()) || type == null || !type.hasParserAuthenticatedAncestry()
                    || !type.sharesParserModuleAuthorityWith(firstType)) return false;
        }
        if(!f.getLocalQuantiVars().isEmpty()) return FastLocalPaidScope.supports(f);
        Set<EGraphNode> seen = Collections.newSetFromMap(new IdentityHashMap<>());
        ArrayDeque<EGraphNode> pending = new ArrayDeque<>();
        pending.add(f.getMatrixEGraph());
        while (!pending.isEmpty()) {
            EGraphNode node = pending.removeFirst();
            if (!seen.add(node)) continue;
            if (seen.size() > 4096) throw new IllegalStateException("PAID_DECLARATION_GRAPH_BUDGET");
            if (node.getOpcode() == EGraphNode.Opcode.REF || node.getOpcode() == EGraphNode.Opcode.CALL) return false;
            if (node.getOpcode() == EGraphNode.Opcode.VARIABLE) {
                String name = node.getAlphaName() == null ? node.getSourceName() : node.getAlphaName();
                if (!names.contains(name)) return false;
            }
            pending.addAll(node.getChildren());
        }
        return true;
    }

    static void enumerate(List<QuantiVar> left, List<QuantiVar> right, int[][] dp,
            ToIntBiFunction<QuantiVar,QuantiVar> update, Consumer<Map<String,String>> accept) {
        if (left.size() > MAX_DECLARATIONS || right.size() > MAX_DECLARATIONS)
            throw new IllegalStateException("PAID_DECLARATION_SIZE_BUDGET");
        walk(left,right,dp,update,accept,left.size(),right.size(),new LinkedHashMap<>(),new long[1]);
    }

    private static void walk(List<QuantiVar> a,List<QuantiVar> b,int[][] dp,
            ToIntBiFunction<QuantiVar,QuantiVar> update,Consumer<Map<String,String>> accept,
            int i,int j,Map<String,String> paid,long[] visits) {
        if (visits[0] >= MAX_VISITS) throw new IllegalStateException("PAID_DECLARATION_PATH_BUDGET");
        visits[0]++;
        if (i == 0 && j == 0) { accept.accept(Map.copyOf(paid)); return; }
        if (i > 0 && j > 0) {
            int cost = update.applyAsInt(a.get(i-1),b.get(j-1));
            if (dp[i][j] == dp[i-1][j-1] + cost) {
                String x = a.get(i-1).getName(), y = b.get(j-1).getName();
                if (cost != 0) {
                    if (paid.containsKey(x) || paid.containsValue(y))
                        throw new IllegalStateException("PAID_DECLARATION_NONINJECTIVE");
                    paid.put(x,y);
                }
                walk(a,b,dp,update,accept,i-1,j-1,paid,visits);
                if (cost != 0) paid.remove(x);
            }
        }
        if (i > 0 && dp[i][j] == dp[i-1][j] + 1)
            walk(a,b,dp,update,accept,i-1,j,paid,visits);
        if (j > 0 && dp[i][j] == dp[i][j-1] + 1)
            walk(a,b,dp,update,accept,i,j-1,paid,visits);
    }
}
