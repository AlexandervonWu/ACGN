package is.fivefivefive.CanDis.theory;

import java.util.Arrays;
import java.util.Objects;

/** Least graph-relative shape and its canonical-to-source instantiating renaming. */
public final class CanonicalizationResult {
    private final TypedENode source;
    private final CanonicalShape shape;
    private final TypedRenaming witness;
    private final StructuralKey structuralKey;

    CanonicalizationResult(
            TypedENode source,
            CanonicalShape shape,
            TypedRenaming witness) {
        this.source = Objects.requireNonNull(source, "source");
        this.shape = Objects.requireNonNull(shape, "shape");
        this.witness = Objects.requireNonNull(witness, "witness");
        if (!source.context().equals(source.support())) {
            throw new IllegalArgumentException(
                    "Canonicalization source must use its exact free-slot support");
        }
        if (!shape.exactSlots().equals(witness.source())) {
            throw new IllegalArgumentException(
                    "Canonical shape slots must equal the witness source");
        }
        if (!source.support().equals(witness.codomain())) {
            throw new IllegalArgumentException(
                    "Canonical witness must instantiate into the source support");
        }
        if (!source.outputType().equals(shape.outputType())) {
            throw new IllegalArgumentException("Canonicalization must preserve output type");
        }
        this.structuralKey = StructuralKey.branch(
                "canonicalization-result",
                Arrays.asList(
                        source.structuralKey(),
                        shape.structuralKey(),
                        TheoryKeys.embedding(witness)));
    }

    public TypedENode source() {
        return source;
    }

    public CanonicalShape shape() {
        return shape;
    }

    public TypedRenaming witness() {
        return witness;
    }

    public boolean verifyWitness(TypedSlottedPortEGraph graph) {
        return TypedAlphaEquivalence.graphRelativeNodes(
                graph, shape.node(), source, witness);
    }

    public StructuralKey structuralKey() {
        return structuralKey;
    }

    @Override
    public boolean equals(Object other) {
        if (!(other instanceof CanonicalizationResult)) {
            return false;
        }
        CanonicalizationResult result = (CanonicalizationResult) other;
        return source.equals(result.source)
                && shape.equals(result.shape)
                && witness.equals(result.witness);
    }

    @Override
    public int hashCode() {
        return Objects.hash(source, shape, witness);
    }

    @Override
    public String toString() {
        return shape + " instantiated by " + witness;
    }
}
