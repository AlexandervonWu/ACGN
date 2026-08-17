package is.fivefivefive.CanDis.theory;

import java.util.Collections;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Schema {@code Set^epsilon(kappa)}. */
public final class SetPortSchema implements PortSchema {
    private final ContainerEmptiness emptiness;
    private final PortSchema elementSchema;

    /** Shorthand for the nonempty schema {@code Set+(kappa)}. */
    public SetPortSchema(PortSchema elementSchema) {
        this(ContainerEmptiness.K_PLUS, elementSchema);
    }

    public SetPortSchema(ContainerEmptiness emptiness, PortSchema elementSchema) {
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
        return Kind.SET;
    }

    @Override
    public Set<String> typeVariables() {
        return elementSchema.typeVariables();
    }

    @Override
    public SetPortSchema substitute(Map<String, GraphType> substitution) {
        return new SetPortSchema(emptiness, elementSchema.substitute(substitution));
    }

    @Override
    public StructuralKey structuralKey() {
        return StructuralKey.of(
                "schema/set",
                Collections.singletonList(emptiness.name()),
                Collections.singletonList(elementSchema.structuralKey()));
    }

    @Override
    public boolean equals(Object other) {
        return other instanceof SetPortSchema
                && emptiness == ((SetPortSchema) other).emptiness
                && elementSchema.equals(((SetPortSchema) other).elementSchema);
    }

    @Override
    public int hashCode() {
        return Objects.hash(kind(), emptiness, elementSchema);
    }

    @Override
    public String toString() {
        return "Set" + emptiness.symbol() + "(" + elementSchema + ")";
    }
}
