package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/** Binary source association whose flattening is justified by exact relation columns. */
public final class DependentChainApplication implements DependentChainInput {
    private final DependentChainKind kind;
    private final DependentChainInput left;
    private final DependentChainInput right;
    private final TypedSlotContext context;
    private final GraphType outputType;
    private final List<OnePort> leaves;
    private final StructuralKey structuralKey;

    public DependentChainApplication(
            DependentChainKind kind,
            DependentChainInput left,
            DependentChainInput right) {
        this.kind = Objects.requireNonNull(kind, "kind");
        this.left = Objects.requireNonNull(left, "left");
        this.right = Objects.requireNonNull(right, "right");
        if (!left.context().equals(right.context())) {
            throw new IllegalArgumentException(
                    "Dependent chain branches use different caller contexts");
        }
        this.context = left.context();
        this.outputType = kind.combine(left.outputType(), right.outputType());
        List<OnePort> ordered = new ArrayList<>();
        ordered.addAll(left.leaves());
        ordered.addAll(right.leaves());
        this.leaves = Collections.unmodifiableList(ordered);
        List<GraphType> operandTypes = new ArrayList<>();
        collectLeafTypes(left, operandTypes);
        collectLeafTypes(right, operandTypes);
        DependentChainTheory.requireSoundFlattening(kind, operandTypes);
        GraphType flattened = kind.fold(operandTypes);
        if (!outputType.equals(flattened)) {
            throw new IllegalArgumentException(
                    "Binary association and dependent-chain fold have different types: "
                            + outputType + " != " + flattened);
        }
        this.structuralKey = StructuralKey.of(
                "dependent-chain-application-v1",
                List.of(kind.name()),
                List.of(
                        TheoryKeys.context(context),
                        TheoryKeys.type(outputType),
                        left.structuralKey(),
                        right.structuralKey()));
    }

    public DependentChainKind kind() {
        return kind;
    }

    public DependentChainInput left() {
        return left;
    }

    public DependentChainInput right() {
        return right;
    }

    @Override
    public TypedSlotContext context() {
        return context;
    }

    @Override
    public GraphType outputType() {
        return outputType;
    }

    @Override
    public List<OnePort> leaves() {
        return leaves;
    }

    public List<GraphType> leafTypes() {
        List<GraphType> result = new ArrayList<>();
        collectLeafTypes(this, result);
        return Collections.unmodifiableList(result);
    }

    private static void collectLeafTypes(
            DependentChainInput input,
            List<GraphType> output) {
        if (input instanceof DependentChainLeaf) {
            output.add(input.outputType());
            return;
        }
        DependentChainApplication application =
                (DependentChainApplication) input;
        collectLeafTypes(application.left(), output);
        collectLeafTypes(application.right(), output);
    }

    @Override
    public DependentChainApplication act(TypedEmbedding embedding) {
        Objects.requireNonNull(embedding, "embedding");
        if (!context.equals(embedding.source())) {
            throw new IllegalArgumentException(
                    "Dependent chain action starts at another context");
        }
        return new DependentChainApplication(
                kind, left.act(embedding), right.act(embedding));
    }

    @Override
    public StructuralKey structuralKey() {
        return structuralKey;
    }
}
