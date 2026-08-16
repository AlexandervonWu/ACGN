package is.fivefivefive.CanDis.theory;

import java.util.Collections;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Schema {@code Set(kappa)}. */
public final class SetPortSchema implements PortSchema {
    private final PortSchema elementSchema;

    public SetPortSchema(PortSchema elementSchema) {
        this.elementSchema = Objects.requireNonNull(elementSchema, "elementSchema");
    }

    public PortSchema elementSchema() {
        return elementSchema;
    }

    @Override
    public Kind kind() {
        return Kind.SET;
    }

    @Override
    public Set<String> typeVariables() {
        return elementSchema.typeVariables();
    }

    @Override
    public SetPortSchema substitute(Map<String, GraphType> substitution) {
        return new SetPortSchema(elementSchema.substitute(substitution));
    }

    @Override
    public StructuralKey structuralKey() {
        return StructuralKey.branch(
                "schema/set", Collections.singletonList(elementSchema.structuralKey()));
    }

    @Override
    public boolean equals(Object other) {
        return other instanceof SetPortSchema
                && elementSchema.equals(((SetPortSchema) other).elementSchema);
    }

    @Override
    public int hashCode() {
        return Objects.hash(kind(), elementSchema);
    }

    @Override
    public String toString() {
        return "Set(" + elementSchema + ")";
    }
}
