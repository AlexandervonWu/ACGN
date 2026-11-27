package is.fivefivefive.CanDis.core;

import java.util.*;
import is.fivefivefive.CanDis.theory.GraphType;
import is.fivefivefive.CanDis.theory.StructuralKey;
import is.fivefivefive.CanDis.theory.TheoryAlloyAdapter;

/** Source authority for outer-prefix exchange; does not certify matrix rewrites. */
final class FastPrefixSource {
    private FastPrefixSource() { }

    /** A source-issued counting binder for the single-phase paid matrix prior. */
    static final class CountingCoordinate {
        private final QuantiVar variable;
        private final GraphType type;
        private final StructuralKey domain;

        private CountingCoordinate(QuantiVar variable, GraphType type, StructuralKey domain) {
            this.variable = variable;
            this.type = type;
            this.domain = domain;
        }

        boolean licenses(QuantiVar source, QuantiVar target, CountingCoordinate other) {
            return variable == source && other != null && other.variable == target
                    && variable.getQuantifier() == other.variable.getQuantifier()
                    && variable.getCardinality() == other.variable.getCardinality()
                    && variable.getDisjointnessClass() == other.variable.getDisjointnessClass()
                    && type.equals(other.type) && domain.equals(other.domain);
        }
    }

    static boolean countingBinder(QuantiVar q) {
        return q.getQuantifier() == QuantiVar.Quantifier.ONE || q.getQuantifier() == QuantiVar.Quantifier.LONE;
    }

    static Map<QuantiVar, CountingCoordinate> countingPrior(NormalForm source, NormalForm comparison) {
        if (comparison.comparisonSource() != source || !comparison.matrixDeclarationsMatchSource()) return Map.of();
        final TheoryAlloyAdapter.PrefixBinderPlan plan;
        try {
            plan = checkedPlan(source, comparison);
        } catch (IllegalArgumentException unsupported) {
            return Map.of();
        }
        var result = new IdentityHashMap<QuantiVar, CountingCoordinate>();
        var prefix = comparison.getMatrixQuantiVars();
        for (int i = 0; i < prefix.size(); i++) {
            var q = prefix.get(i);
            var frames = q.getDeclarationFrames();
            if (!countingBinder(q) || frames.size() != 1) continue;
            var frame = frames.get(0);
            var coordinate = plan.descriptor().coordinates().get(plan.sourceToCoordinate().get(i));
            if (comparison.authenticDeclarationFrame(frame) && frame.dependencies().isEmpty()
                    && coordinate.dependencies().isEmpty() && coordinate.quantifier().equals(q.getQuantifier().name())
                    && coordinate.multiplicity().equals(q.getCardinality().name())) {
                // The prefix descriptor uses a lowered carrier. Equal original domains
                // must also be witnessed by the exact pre-lowering parser frames.
                result.put(q, new CountingCoordinate(q, coordinate.type(), frame.domain()));
            }
        }
        // QuantiVar equality compares IDs. A binder from another endpoint with
        // the same numeric ID must never retrieve this occurrence's authority.
        return Collections.unmodifiableMap(result);
    }

    static TheoryAlloyAdapter.PrefixBinderPlan checkedPlan(NormalForm source, NormalForm comparison) {
        require(FastPaidDeclarationAlignment.supportsPrefixScope(source)
                && FastPaidDeclarationAlignment.supportsPrefixScope(comparison), "Unadmitted prefix scope");
        require(source.getCertificationMatrixEGraph() == comparison.getCertificationMatrixEGraph(),
                "Foreign prefix source");
        var bindings = new HashMap<String,QuantiVar>();
        for (var q : source.getMatrixQuantiVars()) {
            require(bindings.put(q.getName(), q) == null, "Duplicate prefix slot");
        }
        for (var q : source.getLocalQuantiVars()) {
            require(bindings.put(q.getName(), q) == null, "Capturing local slot");
        }
        var occurrences = new HashMap<Long,QuantiVar>();
        var locals = Collections.newSetFromMap(new IdentityHashMap<QuantiVar,Boolean>());
        locals.addAll(source.getLocalQuantiVars());
        boolean checkedLocals = !locals.isEmpty() && FastLocalPaidScope.supports(source)
                && FastLocalPaidScope.supports(comparison);
        var paths = new IdentityHashMap<EGraphNode,String>();
        var active = Collections.newSetFromMap(new IdentityHashMap<EGraphNode,Boolean>());
        var profile = source.getCertificationMatrixEGraph().getSemanticProfile();
        walk(source.getCertificationMatrixEGraph(), "matrix", bindings, occurrences,
                paths, active, locals, checkedLocals, profile, true);
        paths.clear();
        walk(comparison.getMatrixEGraph(), "matrix", bindings, occurrences,
                paths, active, locals, checkedLocals, profile, false);
        return TheoryAlloyAdapter.prefixBinderPlan(source);
    }

    private static void walk(EGraphNode node, String path, Map<String,QuantiVar> bindings,
            Map<Long,QuantiVar> occurrences, IdentityHashMap<EGraphNode,String> paths,
            Set<EGraphNode> active, Set<QuantiVar> locals, boolean checkedLocals,
            is.fivefivefive.CanDis.theory.SemanticProfile profile,
            boolean source) {
        require(node != null && node.isFrozenForCertification(), "Unfrozen prefix occurrence");
        require(active.add(node), "Recursive prefix occurrence");
        try {
            String priorPath = paths.putIfAbsent(node, path);
            if (source) {
                require(priorPath == null || priorPath.equals(path), "Ambiguous prefix source path");
                node.requirePristineCertificationSource();
            } else if (priorPath != null) {
                return;
            }
            require(profile.equals(node.getSemanticProfile()), "Cross-profile prefix occurrence");
            node.requireAdmittedArity();
            // Only the checked local-owner traversal licenses a declaration
            // container without an expression result type, never its opcode.
            if (node.getOpcode() == EGraphNode.Opcode.GENERICRELDECL
                    || node.getOpcode() == EGraphNode.Opcode.DISJ) {
                require(checkedLocals, "Unowned prefix declaration");
            } else {
                TheoryAlloyAdapter.requireOccurrenceOutputType(node);
            }
            if (node.getOpcode() == EGraphNode.Opcode.VARIABLE) {
                // FastLocalPaidScope has already checked the concrete local
                // owner and its renamed declaration/body occurrences.
                var q = source ? bindings.get(node.getAlphaName())
                        : occurrences.get(node.getSourceOccurrenceLineage());
                require(q != null && node.getChildren().isEmpty(), "Unbound prefix occurrence");
                require(!source && locals.contains(q) || bindings.get(node.getAlphaName()) == q,
                        "Changed outer prefix slot");
                var type = q.getExactAlloyType();
                require(type != null && type.hasParserAuthenticatedAncestry()
                        && type.sameOccurrenceEvidenceAs(node.getExactAlloyType())
                        && q.getOriginalNames().contains(node.getSourceName())
                        && q.getOriginalNames().contains(node.getSemanticIdentity()),
                        "Foreign prefix occurrence type or alias");
                if (source) {
                    var previous = occurrences.putIfAbsent(node.getSourceOccurrenceLineage(), q);
                    require(previous == null || previous == q, "Conflicting prefix occurrence owner");
                } else {
                    require(occurrences.get(node.getSourceOccurrenceLineage()) == q,
                            "Changed prefix occurrence owner");
                }
            }
            var children = node.getChildren();
            for (int i=0; i<children.size(); i++) {
                walk(children.get(i), path + "/" + i, bindings, occurrences, paths, active, locals, checkedLocals, profile, source);
            }
        } finally {
            active.remove(node);
        }
    }

    private static void require(boolean condition, String message) {
        if (!condition) throw new IllegalArgumentException(message);
    }
}
