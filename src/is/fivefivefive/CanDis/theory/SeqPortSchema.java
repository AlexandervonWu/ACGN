package is.fivefivefive.CanDis.theory;

import java.util.Collections;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Schema {@code Seq(kappa)}. */
public final class SeqPortSchema implements PortSchema {
    private final PortSchema elementSchema;

    public SeqPortSchema(PortSchema elementSchema) {
        this.elementSchema = Objects.requireNonNull(elementSchema, "elementSchema");
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
        return new SeqPortSchema(elementSchema.substitute(substitution));
    }

    @Override
    public StructuralKey structuralKey() {
        return StructuralKey.branch(
                "schema/seq", Collections.singletonList(elementSchema.structuralKey()));
    }

    @Override
    public boolean equals(Object other) {
        return other instanceof SeqPortSchema
                && elementSchema.equals(((SeqPortSchema) other).elementSchema);
    }

    @Override
    public int hashCode() {
        return Objects.hash(kind(), elementSchema);
    }

    @Override
    public String toString() {
        return "Seq(" + elementSchema + ")";
    }
}
