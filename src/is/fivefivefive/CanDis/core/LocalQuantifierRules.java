package is.fivefivefive.CanDis.core;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import is.fivefivefive.CanDis.theory.LeanVerifiedRewrite;
import is.fivefivefive.ACGN.alloy.SigSymbol;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;

/** Source rules for quantifiers that can remain below a Boolean connective during prenexing. */
final class LocalQuantifierRules {
    private LocalQuantifierRules() { }

    private record Slot(EGraphNode declaration, EGraphNode variable, SigSymbol domain) {
        String key() { return variable.getAlphaName(); }
    }

    private record Block(EGraphNode root, List<Slot> slots, EGraphNode body) {
        EGraphNode withBody(EGraphNode newBody) {
            var children = new ArrayList<>(root.getChildren());
            children.set(children.size() - 1, newBody);
            return rebuild(root, children);
        }
    }

    static EGraphNode normalize(EGraphNode node) {
        return orderIndependentBlock(pullLocalQuantifier(fuseSharedUniversal(node)));
    }

    private static EGraphNode rebuild(EGraphNode original, List<EGraphNode> children) {
        var result = NormalForm.copyShallow(original, original.getOpcode());
        children.forEach(result::addNormalizedChild);
        return result;
    }

    /** Only ordinary singleton slots over parser-authenticated nominal ranges can commute here. */
    private static Block readBlock(EGraphNode root, Opcode kind, boolean includeNested) {
        return readBlock(root, kind, includeNested, false);
    }

    private static boolean closedSignatureDifference(EGraphNode range) {
        var sides = range.getChildren();
        return range.getOpcode() == Opcode.MINUS && "BOPEXPR_MINUS".equals(range.getSourceName())
                && range.getExactAlloyType() != null && range.getExactAlloyType().hasParserAuthenticatedAncestry()
                && sides.size() == 2 && sides.get(0).authenticatedSignature() != null
                && sides.get(1).authenticatedSignature() != null;
    }

    private static Block readBlock(EGraphNode root, Opcode kind, boolean includeNested, boolean keepDifference) {
        EGraphNode current = root;
        var slots = new ArrayList<Slot>();
        var keys = new HashSet<String>();
        while (current.getOpcode() == kind && EGraphNode.hasParserQuantifierSourceAuthority(current, kind)) {
            var parts = current.getChildren();
            if (parts.size() < 2 || !EGraphNode.hasBooleanFormulaType(current)) return null;
            for (var decl : parts.subList(0, parts.size() - 1)) {
                var fields = decl.getChildren();
                // An issued descope receipt binds every surviving slot to its original tuple position.
                if (decl.getOpcode() != Opcode.GENERICRELDECL || fields.size() < 2
                        || decl.unusedBindingReduction() != null) return null;
                var range = fields.get(0);
                if (range.getOpcode() == Opcode.ONE && range.getChildren().size() == 1)
                    range = range.getChildren().get(0);
                var signature = range.authenticatedSignature();
                if (signature == null && !(keepDifference && closedSignatureDifference(range))) return null;
                for (var variable : fields.subList(1, fields.size())) {
                    var key = variable.getAlphaName();
                    if (variable.getOpcode() != Opcode.VARIABLE || !variable.getChildren().isEmpty()
                            || key == null || !key.startsWith("@bind:") || !keys.add(key)
                            || variable.getExactAlloyType() == null
                            || !variable.getExactAlloyType().sameOccurrenceEvidenceAs(range.getExactAlloyType())) return null;
                    slots.add(new Slot(decl, variable, signature));
                }
            }
            current = parts.get(parts.size() - 1);
            if (!includeNested) break;
        }
        return !slots.isEmpty() && EGraphNode.hasBooleanFormulaType(current)
                ? new Block(root, slots, current) : null;
    }

    /** Check lexical reads. A REF can hide a bound read in a separate temporal phase body. */
    private static boolean independent(EGraphNode node, List<Slot> slots) {
        if (node.getOpcode() == Opcode.REF || node.getOpcode() == Opcode.SHADOW) return false;
        if (node.getOpcode() == Opcode.VARIABLE)
            for (var slot : slots) if (slot.key().equals(node.getAlphaName())) return false;
        for (var child : node.getChildren()) if (!independent(child, slots)) return false;
        return true;
    }

    /** Existentials move across conjunction and universals across disjunction even at an empty range. */
    @LeanVerifiedRewrite({"R0-CORE-015", "R0-CORE-016"})
    private static EGraphNode pullLocalQuantifier(EGraphNode node) {
        var kind = node.getOpcode();
        if (kind != Opcode.AND && kind != Opcode.OR || !EGraphNode.hasBooleanRewriteAuthority(node)) return node;
        var terms = node.getChildren();
        if (terms.size() < 2) return node;
        for (int i = 0; i < terms.size(); i++) {
            var local = readBlock(terms.get(i), kind == Opcode.AND ? Opcode.EXISTS : Opcode.FORALL, false);
            if (local == null) continue;
            boolean safe = true;
            for (int j = 0; j < terms.size(); j++)
                if (j != i && !independent(terms.get(j), local.slots)) { safe = false; break; }
            if (safe) {
                var body = new ArrayList<>(terms);
                body.set(i, local.body);
                return local.withBody(rebuild(node, body));
            }
        }
        return node;
    }

    private static boolean containsNestedJoin(EGraphNode node, boolean insideJoin) {
        boolean join = node.getOpcode() == Opcode.JOIN;
        if (join && insideJoin) return true;
        for (var child : node.getChildren()) if (containsNestedJoin(child, insideJoin || join)) return true;
        return false;
    }

    @LeanVerifiedRewrite("R0-STRUCT-001")
    private static EGraphNode orderIndependentBlock(EGraphNode node) {
        var kind = node.getOpcode();
        if (kind != Opcode.FORALL && kind != Opcode.EXISTS) return node;
        var block = readBlock(node, kind, true);
        if (block == null || block.slots.size() < 2) return node;
        // Keep grouped declarations intact until unused-slot elimination can see
        // the surviving sibling that already witnesses the same nonempty range.
        for (var slot : block.slots) {
            if (independent(block.body, List.of(slot))) return node;
        }
        var sorted = new ArrayList<>(block.slots);
        sorted.sort(Comparator.comparing(slot -> slot.domain.getSemanticIdentity()));
        // A nested JOIN carries occurrence-specific erasure evidence when two conjuncts coalesce.
        if (sorted.get(0).domain.isSameParserSignatureAs(sorted.get(sorted.size() - 1).domain)
                || containsNestedJoin(block.body, false)) return node;
        var children = new ArrayList<EGraphNode>();
        // A grouped declaration owns one range occurrence. Both repair views must
        // charge that range once when the quantifier remains inside the matrix.
        for (var slot : sorted) {
            if (!children.contains(slot.declaration)) children.add(slot.declaration);
        }
        children.add(block.body);
        return rebuild(node, children);
    }

    private record SharedCondition(Slot domainSlot, List<Slot> remaining, EGraphNode formula) { }

    private static SharedCondition commonCondition(Block other, SigSymbol domain) {
        var remaining = new ArrayList<Slot>();
        Slot selected = null;
        for (var slot : other.slots) {
            if (slot.domain != null && slot.domain.isSameParserSignatureAs(domain)) {
                if (selected != null || slot.declaration.getChildren().size() != 2) return null;
                selected = slot;
            } else remaining.add(slot);
        }
        if (selected != null) return new SharedCondition(selected, remaining, other.body);
        // In an implication, an independent existential premise can supply the universal slot.
        var terms = other.body.getChildren();
        if (other.body.getOpcode() != Opcode.IMPLIES || terms.size() != 2
                || !EGraphNode.hasBooleanRewriteAuthority(other.body)) return null;
        var premise = readBlock(terms.get(0), Opcode.EXISTS, false);
        if (premise == null || premise.slots.size() != 1 || !premise.slots.get(0).domain.isSameParserSignatureAs(domain)
                || !independent(terms.get(1), premise.slots)) return null;
        return new SharedCondition(premise.slots.get(0), remaining,
                rebuild(other.body, List.of(premise.body, terms.get(1))));
    }

    private static Block universalCondition(EGraphNode term) {
        var direct = readBlock(term, Opcode.FORALL, true, true);
        if (direct != null || term.getOpcode() != Opcode.NOT || term.getChildren().size() != 1
                || !EGraphNode.hasBooleanRewriteAuthority(term)) return direct;
        var complement = readBlock(term.getChildren().get(0), Opcode.EXISTS, true, true);
        if (complement == null) return null;
        return new Block(NormalForm.copyQuantifierShallow(complement.root, Opcode.FORALL),
                complement.slots, rebuild(term, List.of(complement.body)));
    }

    /** Keep a single shared universal range when an existence clause and its side condition use the same atom. */
    @LeanVerifiedRewrite("R0-STRUCT-002")
    private static EGraphNode fuseSharedUniversal(EGraphNode node) {
        var terms = node.getChildren();
        if (node.getOpcode() != Opcode.AND || terms.size() != 2 || !EGraphNode.hasBooleanRewriteAuthority(node)) return node;
        for (int i = 0; i < 2; i++) {
            var outer = readBlock(terms.get(i), Opcode.FORALL, false);
            if (outer == null || outer.slots.size() != 1) continue;
            var witness = readBlock(outer.body, Opcode.EXISTS, false);
            var other = universalCondition(terms.get(1 - i));
            if (other == null || witness == null || witness.slots.size() != 1) continue;
            var shared = outer.slots.get(0);
            var condition = commonCondition(other, shared.domain);
            if (condition == null || !independent(condition.formula, List.of(shared, witness.slots.get(0)))) continue;
            var aligned = NormalForm.betaRewriteLet(condition.formula, Map.of(condition.domainSlot.key(), shared.variable));
            if (!condition.remaining.isEmpty()) {
                var remaining = new ArrayList<EGraphNode>();
                for (var slot : condition.remaining)
                    if (!remaining.contains(slot.declaration)) remaining.add(slot.declaration);
                remaining.add(aligned);
                aligned = rebuild(other.root, remaining);
            }
            return outer.withBody(witness.withBody(rebuild(node, List.of(witness.body, aligned))));
        }
        return node;
    }
}
