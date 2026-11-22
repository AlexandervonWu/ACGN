package is.fivefivefive.CanDis.core.egraph;

import parser.ast.nodes.ResolvedBindingOrigins;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/** Immutable, parser-independent representation of a raw Alloy AST term. */
public final class AlloyTerm implements Comparable<AlloyTerm> {
    private final String head;
    private final String atom;
    private final String slotType;
    private final List<AlloyTerm> children;
    private final int hashCode;
    private final int size;
    private final ResolvedBindingOrigins.Slot binding;
    private final List<ResolvedBindingOrigins.Slot> declaration;

    private AlloyTerm(String head, String atom, List<AlloyTerm> children) {
        this(head, atom, children, "");
    }

    private AlloyTerm(String head, String atom, List<AlloyTerm> children, String slotType) {
        this(head, atom, children, slotType, null, List.of());
    }

    private AlloyTerm(String head, String atom, List<AlloyTerm> children, String slotType,
            ResolvedBindingOrigins.Slot binding,
            List<ResolvedBindingOrigins.Slot> declaration) {
        this.binding = binding;
        this.declaration = declaration;
        this.head = Objects.requireNonNull(head, "head");
        this.atom = atom == null ? "" : atom;
        this.slotType = Objects.requireNonNull(slotType, "slotType");
        this.children = Collections.unmodifiableList(new ArrayList<>(children));
        int structuralHash = Objects.hash(this.head, this.atom, this.children);
        this.hashCode = slotType.isEmpty() ? structuralHash : 31 * structuralHash + slotType.hashCode();
        int nodeCount = 1;
        for (AlloyTerm child : this.children) {
            nodeCount += child.size;
        }
        this.size = nodeCount;
    }

    public static AlloyTerm node(String head, AlloyTerm... children) {
        List<AlloyTerm> childList = new ArrayList<>(children.length);
        Collections.addAll(childList, children);
        return new AlloyTerm(head, "", childList);
    }

    public static AlloyTerm node(String head, List<AlloyTerm> children) {
        return new AlloyTerm(head, "", children);
    }

    public static AlloyTerm atom(String head, String value) {
        return new AlloyTerm(head, value, Collections.emptyList());
    }

    public static AlloyTerm of(String head, String atom, List<AlloyTerm> children) {
        return new AlloyTerm(head, atom, children);
    }

    public static AlloyTerm typedVariable(String name, String type) {
        if (type == null || type.isEmpty()) {
            throw new IllegalArgumentException("A typed slot requires an exact type");
        }
        return new AlloyTerm("VAR", name, Collections.emptyList(), type);
    }

    public static AlloyTerm parsedVariable(parser.ast.nodes.VarExpr original, String slotType) {
        return new AlloyTerm("VAR", original.getName(), List.of(), slotType,
                ResolvedBindingOrigins.read(original), List.of());
    }

    public static AlloyTerm parsedDeclaration(
            is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter.ParsedDeclaration original) {
        return new AlloyTerm(original.head(), "", original.children(), "", null, original.slots());
    }

    ResolvedBindingOrigins.Slot binding() { return binding; }

    boolean owns(ResolvedBindingOrigins.Slot slot) {
        return slot != null && declaration.contains(slot);
    }

    public String slotType() {
        return slotType;
    }

    public AlloyTerm renameVariable(String name) {
        if (!isVariable()) {
            throw new IllegalArgumentException("Only variable leaves can be renamed");
        }
        return new AlloyTerm(head, name, children, slotType, binding, List.of());
    }

    public AlloyTerm eraseSlotTypes() {
        if (isVariable() && !slotType.isEmpty()) {
            return new AlloyTerm(head, atom, List.of(), "", binding, List.of());
        }
        List<AlloyTerm> erased = new ArrayList<>(children.size());
        for (AlloyTerm child : children) {
            erased.add(child.eraseSlotTypes());
        }
        return rewrittenChildren(erased);
    }

    public String head() {
        return head;
    }

    public String atom() {
        return atom;
    }

    public List<AlloyTerm> children() {
        return children;
    }

    public int size() {
        return size;
    }

    public boolean isVariable() {
        return "VAR".equals(head);
    }

    public AlloyTerm withChildren(List<AlloyTerm> replacement) {
        if (children.equals(replacement)) {
            return this;
        }
        return new AlloyTerm(head, atom, replacement, slotType);
    }

    /** Only trusted source-preserving rewrites may transport a declaration. */
    AlloyTerm rewrittenChildren(List<AlloyTerm> replacement) {
        if (children.equals(replacement)) return this;
        return new AlloyTerm(head, atom, replacement, slotType, binding, declaration);
    }

    @Override
    public int compareTo(AlloyTerm other) {
        if (this == other) {
            return 0;
        }
        int comparison = head.compareTo(other.head);
        if (comparison != 0) {
            return comparison;
        }
        comparison = atom.compareTo(other.atom);
        if (comparison != 0) {
            return comparison;
        }
        comparison = slotType.compareTo(other.slotType);
        if (comparison != 0) {
            return comparison;
        }
        comparison = Integer.compare(children.size(), other.children.size());
        if (comparison != 0) {
            return comparison;
        }
        for (int i = 0; i < children.size(); i++) {
            comparison = children.get(i).compareTo(other.children.get(i));
            if (comparison != 0) {
                return comparison;
            }
        }
        return 0;
    }

    @Override
    public boolean equals(Object other) {
        if (this == other) {
            return true;
        }
        if (!(other instanceof AlloyTerm)) {
            return false;
        }
        AlloyTerm term = (AlloyTerm) other;
        return head.equals(term.head) && atom.equals(term.atom)
                && slotType.equals(term.slotType) && children.equals(term.children);
    }

    @Override
    public int hashCode() {
        return hashCode;
    }

    @Override
    public String toString() {
        if (children.isEmpty()) {
            return atom.isEmpty() ? head : head + "(" + atom
                    + (slotType.isEmpty() ? "" : ":" + slotType) + ")";
        }
        StringBuilder builder = new StringBuilder(head).append('(');
        for (int i = 0; i < children.size(); i++) {
            if (i > 0) {
                builder.append(',');
            }
            builder.append(children.get(i));
        }
        return builder.append(')').toString();
    }
}
