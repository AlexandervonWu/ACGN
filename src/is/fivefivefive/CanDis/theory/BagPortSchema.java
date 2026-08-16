package is.fivefivefive.CanDis.theory;

import java.util.Collections;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Schema {@code Bag(kappa)}. */
public final class BagPortSchema implements PortSchema {
    private final PortSchema elementSchema;

    public BagPortSchema(PortSchema elementSchema) {
        this.elementSchema = Objects.requireNonNull(elementSchema, "elementSchema");
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
        return new BagPortSchema(elementSchema.substitute(substitution));
    }

    @Override
    public StructuralKey structuralKey() {
        return StructuralKey.branch(
                "schema/bag", Collections.singletonList(elementSchema.structuralKey()));
    }

    @Override
    public boolean equals(Object other) {
        return other instanceof BagPortSchema
                && elementSchema.equals(((BagPortSchema) other).elementSchema);
    }

    @Override
    public int hashCode() {
        return Objects.hash(kind(), elementSchema);
    }

    @Override
    public String toString() {
        return "Bag(" + elementSchema + ")";
    }
}
