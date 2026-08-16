package is.fivefivefive.CanDis.theory;

import java.util.Arrays;
import java.util.Objects;

/** Leader invocation and retained primitive parent path returned by typed find. */
public final class TypedFindResult {
    private final TypedInvocation originalInvocation;
    private final TypedInvocation leaderInvocation;
    private final ParentPath parentPath;
    private final StructuralKey structuralKey;

    public TypedFindResult(
            TypedInvocation originalInvocation,
            TypedInvocation leaderInvocation,
            ParentPath parentPath) {
        this.originalInvocation = Objects.requireNonNull(
                originalInvocation, "originalInvocation");
        this.leaderInvocation = Objects.requireNonNull(
                leaderInvocation, "leaderInvocation");
        this.parentPath = Objects.requireNonNull(parentPath, "parentPath");
        if (!originalInvocation.eclass().equals(parentPath.start())) {
            throw new IllegalArgumentException("Find path must start at the original e-class");
        }
        if (!leaderInvocation.eclass().equals(parentPath.end())) {
            throw new IllegalArgumentException("Find path must end at the returned leader");
        }
        TypedEmbedding expected = parentPath.compositeEmbedding()
                .andThen(originalInvocation.embedding());
        if (!expected.equals(leaderInvocation.embedding())) {
            throw new IllegalArgumentException(
                    "Find result embedding must be caller embedding composed with the parent path");
        }
        if (!originalInvocation.outputType().equals(leaderInvocation.outputType())) {
            throw new IllegalArgumentException("Find must preserve invocation output type");
        }
        if (!originalInvocation.callerContext().equals(leaderInvocation.callerContext())) {
            throw new IllegalArgumentException("Find must preserve the invocation caller context");
        }
        this.structuralKey = StructuralKey.branch(
                "typed-find-result",
                Arrays.asList(
                        TheoryKeys.invocation(originalInvocation),
                        TheoryKeys.invocation(leaderInvocation),
                        parentPath.structuralKey()));
    }

    public TypedInvocation originalInvocation() {
        return originalInvocation;
    }

    public TypedInvocation leaderInvocation() {
        return leaderInvocation;
    }

    public TypedEmbedding composedEmbedding() {
        return leaderInvocation.embedding();
    }

    public ParentPath parentPath() {
        return parentPath;
    }

    public StructuralKey structuralKey() {
        return structuralKey;
    }

    @Override
    public boolean equals(Object other) {
        if (!(other instanceof TypedFindResult)) {
            return false;
        }
        TypedFindResult result = (TypedFindResult) other;
        return originalInvocation.equals(result.originalInvocation)
                && leaderInvocation.equals(result.leaderInvocation)
                && parentPath.equals(result.parentPath);
    }

    @Override
    public int hashCode() {
        return Objects.hash(originalInvocation, leaderInvocation, parentPath);
    }

    @Override
    public String toString() {
        return originalInvocation + " => " + leaderInvocation;
    }
}
