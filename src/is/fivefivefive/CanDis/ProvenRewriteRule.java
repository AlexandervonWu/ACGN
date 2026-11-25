package is.fivefivefive.CanDis;

import java.util.List;

/** Catalog of proved laws, not an allowlist for erasing a predicate or assigning a distance. */
public enum ProvenRewriteRule {
    STATIC_ALL_ALWAYS("R0-BIND-003", Scope.SOURCE_NORMALIZATION, "Phase5SourceRules.static_all_commutes_with_always"),
    FIBER("fiber", Scope.FIXED_COMMAND, "AdaptiveCountingFiber.scoped_fiber_test"),
    DIFFERENCE("difference", Scope.FIXED_COMMAND, "AdaptiveDifferenceCount.bounded_difference"),
    ROLE("role", Scope.FIXED_COMMAND, "AdaptiveRoleSupport.sandwich"),
    MIXED_ROLE("mixedRole", Scope.FIXED_COMMAND, "AdaptiveHomogeneousRows.sandwich", "AdaptiveMixedRowCounting.guarded_source"),
    CLASSIFIER("classifier", Scope.FIXED_COMMAND, "AdaptiveClassifierArms.classify_split",
            "AdaptiveClassifierProjection.project", "AdaptiveClassifierProjection.subtract");

    public enum Scope { SOURCE_NORMALIZATION, FIXED_COMMAND }
    private final String id;
    private final Scope scope;
    private final List<String> proofAnchors;

    ProvenRewriteRule(String id, Scope scope, String... anchors) {
        this.id = id;
        this.scope = scope;
        this.proofAnchors = List.of(anchors);
    }
    public String id() { return id; }
    public Scope scope() { return scope; }
    /** Module and theorem source anchors; not a proof receipt for a Java invocation. */
    public List<String> proofAnchors() { return proofAnchors; }
}
