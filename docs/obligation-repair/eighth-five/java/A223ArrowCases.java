package is.fivefivefive.CanDis.theory;

/** Independent admission of an actual ARROW case matrix and normalized family
 * against the input occurrences. Works for any public admitted DAG inputs; the
 * caller supplies a result, so the check does not call combine or normalize. */
public final class A223ArrowCases {
    private A223ArrowCases() {}

    public static void verify(DependentTypeDag left, DependentTypeDag right, DependentTypeDag.ChainCombination combination) {
        var lhs = left.alternatives();
        var rhs = right.alternatives();
        var result = combination.result();
        int width = Math.addExact(left.arity(), right.arity());
        int pairs = Math.multiplyExact(lhs.size(), rhs.size());
        require(result.arity() == width && result.alternatives().size() == pairs && combination.cases().size() == pairs,
                "typed matrix dimensions");
        for (int k = 0; k < pairs; k++) {
            int i = k / rhs.size();
            int j = k % rhs.size();
            var entry = combination.cases().get(k);
            require(entry.leftAlternative() == i && entry.rightAlternative() == j
                    && entry.decision() == DependentTypeDag.CombinationDecision.ARROW_PRODUCT
                    && entry.boundary().isEmpty(), "case address or decision");
            var stated = entry.resultAlternative().orElseThrow();
            var actual = result.alternatives().get(k);
            require(stated.size() == width && actual.size() == width, "product width");
            for (int column = 0; column < width; column++) {
                var owner = column < left.arity() ? lhs.get(i).get(column) : rhs.get(j).get(column - left.arity());
                require(stated.get(column) == owner && actual.get(column) == owner, "foreign column occurrence");
            }
        }
    }

    private static void require(boolean ok, String reason) {
        if (!ok) throw new IllegalArgumentException(reason);
    }
}
