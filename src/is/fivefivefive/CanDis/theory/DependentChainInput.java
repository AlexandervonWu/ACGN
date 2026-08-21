package is.fivefivefive.CanDis.theory;

import java.util.List;

/** One leaf or binary source association in a dependent JOIN/ARROW chain. */
public sealed interface DependentChainInput permits
        DependentChainLeaf, DependentChainApplication {
    TypedSlotContext context();

    GraphType outputType();

    List<OnePort> leaves();

    DependentChainInput act(TypedEmbedding embedding);

    StructuralKey structuralKey();
}
