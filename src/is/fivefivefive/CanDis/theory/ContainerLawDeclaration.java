package is.fivefivefive.CanDis.theory;

import java.util.Arrays;
import java.util.Objects;

/** Explicit, structurally checked law declaration; semantic certificates arrive in Phase F. */
public final class ContainerLawDeclaration {
    public enum Kind {
        NONE,
        SEQ,
        BAG,
        SET
    }

    private static final ContainerLawDeclaration NONE = new ContainerLawDeclaration(
            Kind.NONE, false, false, false, false);

    private final Kind kind;
    private final boolean associative;
    private final boolean commutative;
    private final boolean idempotent;
    private final boolean hasUnit;

    private ContainerLawDeclaration(
            Kind kind,
            boolean associative,
            boolean commutative,
            boolean idempotent,
            boolean hasUnit) {
        this.kind = Objects.requireNonNull(kind, "kind");
        this.associative = associative;
        this.commutative = commutative;
        this.idempotent = idempotent;
        this.hasUnit = hasUnit;
    }

    public static ContainerLawDeclaration none() {
        return NONE;
    }

    public static ContainerLawDeclaration of(
            Kind kind,
            boolean associative,
            boolean commutative,
            boolean idempotent,
            boolean hasUnit) {
        return new ContainerLawDeclaration(
                kind, associative, commutative, idempotent, hasUnit);
    }

    public Kind kind() {
        return kind;
    }

    public boolean associative() {
        return associative;
    }

    public boolean commutative() {
        return commutative;
    }

    public boolean idempotent() {
        return idempotent;
    }

    public boolean hasUnit() {
        return hasUnit;
    }

    void validateAgainst(PortSchema schema) {
        Objects.requireNonNull(schema, "schema");
        Kind expected;
        switch (schema.kind()) {
            case SEQ:
                expected = Kind.SEQ;
                break;
            case BAG:
                expected = Kind.BAG;
                break;
            case SET:
                expected = Kind.SET;
                break;
            default:
                expected = Kind.NONE;
        }
        if (kind != expected) {
            throw new IllegalArgumentException(
                    "Container law kind " + kind + " does not match schema " + schema.kind());
        }
        boolean expectedAssociative = expected != Kind.NONE;
        boolean expectedCommutative = expected == Kind.BAG || expected == Kind.SET;
        boolean expectedIdempotent = expected == Kind.SET;
        if (associative != expectedAssociative
                || commutative != expectedCommutative
                || idempotent != expectedIdempotent) {
            throw new IllegalArgumentException(
                    "Container law flags do not match " + expected
                            + " semantics (Seq=A, Bag=AC, Set=ACI)");
        }
        if (expected == Kind.NONE && hasUnit) {
            throw new IllegalArgumentException("A fixed port cannot declare a container unit");
        }
    }

    public StructuralKey structuralKey() {
        return StructuralKey.of(
                "container-laws",
                Arrays.asList(
                        kind.name(),
                        Boolean.toString(associative),
                        Boolean.toString(commutative),
                        Boolean.toString(idempotent),
                        Boolean.toString(hasUnit)),
                java.util.Collections.emptyList());
    }

    @Override
    public boolean equals(Object other) {
        if (!(other instanceof ContainerLawDeclaration)) {
            return false;
        }
        ContainerLawDeclaration laws = (ContainerLawDeclaration) other;
        return kind == laws.kind
                && associative == laws.associative
                && commutative == laws.commutative
                && idempotent == laws.idempotent
                && hasUnit == laws.hasUnit;
    }

    @Override
    public int hashCode() {
        return Objects.hash(kind, associative, commutative, idempotent, hasUnit);
    }

    @Override
    public String toString() {
        return kind + "[A=" + associative + ",C=" + commutative
                + ",I=" + idempotent + ",unit=" + hasUnit + "]";
    }
}
