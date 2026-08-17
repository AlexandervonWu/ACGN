package is.fivefivefive.CanDis.theory;

import java.util.Collections;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Schema {@code Seq^epsilon(kappa)}. */
public final class SeqPortSchema implements PortSchema {
    private final ContainerEmptiness emptiness;
    private final PortSchema elementSchema;

    /** Shorthand for the nonempty schema {@code Seq+(kappa)}. */
    public SeqPortSchema(PortSchema elementSchema) {
        this(ContainerEmptiness.K_PLUS, elementSchema);
    }

    public SeqPortSchema(ContainerEmptiness emptiness, PortSchema elementSchema) {
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
        return Kind.SEQ;
    }

    @Override
    public Set<String> typeVariables() {
        return elementSchema.typeVariables();
    }

    @Override
    public SeqPortSchema substitute(Map<String, GraphType> substitution) {
        return new SeqPortSchema(emptiness, elementSchema.substitute(substitution));
    }

    @Override
    public StructuralKey structuralKey() {
        return StructuralKey.of(
                "schema/seq",
                Collections.singletonList(emptiness.name()),
                Collections.singletonList(elementSchema.structuralKey()));
    }

    @Override
    public boolean equals(Object other) {
        return other instanceof SeqPortSchema
                && emptiness == ((SeqPortSchema) other).emptiness
                && elementSchema.equals(((SeqPortSchema) other).elementSchema);
    }

    @Override
    public int hashCode() {
        return Objects.hash(kind(), emptiness, elementSchema);
    }

    @Override
    public String toString() {
        return "Seq" + emptiness.symbol() + "(" + elementSchema + ")";
    }
}
