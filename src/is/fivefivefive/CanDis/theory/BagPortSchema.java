package is.fivefivefive.CanDis.theory;

import java.util.Collections;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Schema {@code Bag^epsilon(kappa)}. */
public final class BagPortSchema implements PortSchema {
    private final ContainerEmptiness emptiness;
    private final PortSchema elementSchema;

    /** Shorthand for the nonempty schema {@code Bag+(kappa)}. */
    public BagPortSchema(PortSchema elementSchema) {
        this(ContainerEmptiness.K_PLUS, elementSchema);
    }

    public BagPortSchema(ContainerEmptiness emptiness, PortSchema elementSchema) {
        this.emptiness = Objects.requireNonNull(emptiness, "emptiness");
        this.elementSchema = Objects.requireNonNull(elementSchema, "elementSchema");
    }

    public ContainerEmptiness emptiness() {
        return emptiness;
    }

    public PortSchema elementSchema() {
        return elementSchema;
    }

    @Override
    public Kind kind() {
        return Kind.BAG;
    }

    @Override
    public Set<String> typeVariables() {
        return elementSchema.typeVariables();
    }

    @Override
    public BagPortSchema substitute(Map<String, GraphType> substitution) {
        return new BagPortSchema(emptiness, elementSchema.substitute(substitution));
    }

    @Override
    public StructuralKey structuralKey() {
        return StructuralKey.of(
                "schema/bag",
                Collections.singletonList(emptiness.name()),
                Collections.singletonList(elementSchema.structuralKey()));
    }

    @Override
    public boolean equals(Object other) {
        return other instanceof BagPortSchema
                && emptiness == ((BagPortSchema) other).emptiness
                && elementSchema.equals(((BagPortSchema) other).elementSchema);
    }

    @Override
    public int hashCode() {
        return Objects.hash(kind(), emptiness, elementSchema);
    }

    @Override
    public String toString() {
        return "Bag" + emptiness.symbol() + "(" + elementSchema + ")";
    }
}
