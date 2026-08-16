package is.fivefivefive.CanDis.theory;

import java.util.Arrays;
import java.util.Objects;

/** One historical non-root assignment {@code U(a)=m*b}, without a Phase F proof. */
public final class ParentStep {
    private final TypedEClassInterface child;
    private final TypedInvocation parentInvocation;
    private final StructuralKey structuralKey;

    public ParentStep(
            TypedEClassInterface child,
            TypedInvocation parentInvocation) {
        this.child = Objects.requireNonNull(child, "child");
        this.parentInvocation = Objects.requireNonNull(
                parentInvocation, "parentInvocation");
        if (child.id().equals(parentInvocation.eclass().id())) {
            throw new IllegalArgumentException("A non-root parent step must change e-class id");
        }
        if (!child.outputType().equals(parentInvocation.outputType())) {
            throw new IllegalArgumentException("A parent step must preserve the e-class output type");
        }
        if (!child.exposedSlots().equals(parentInvocation.callerContext())) {
            throw new IllegalArgumentException(
                    "A parent embedding must map the parent interface into the child interface");
        }
        this.structuralKey = StructuralKey.branch(
                "parent-step",
                Arrays.asList(
                        TheoryKeys.eclass(child),
                        TheoryKeys.invocation(parentInvocation)));
    }

    public TypedEClassInterface child() {
        return child;
    }

    public TypedInvocation parentInvocation() {
        return parentInvocation;
    }

    public TypedEClassInterface parent() {
        return parentInvocation.eclass();
    }

    public TypedEmbedding embedding() {
        return parentInvocation.embedding();
    }

    public StructuralKey structuralKey() {
        return structuralKey;
    }

    @Override
    public boolean equals(Object other) {
        if (!(other instanceof ParentStep)) {
            return false;
        }
        ParentStep step = (ParentStep) other;
        return child.equals(step.child)
                && parentInvocation.equals(step.parentInvocation);
    }

    @Override
    public int hashCode() {
        return Objects.hash(child, parentInvocation);
    }

    @Override
    public String toString() {
        return "U(" + child.id() + ")=" + parentInvocation;
    }
}
