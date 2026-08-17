package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.NavigableMap;
import java.util.Objects;
import java.util.TreeMap;

/** Structurally checked law declaration with optional Phase F certificates. */
public final class ContainerLawDeclaration {
    public enum Kind {
        NONE,
        SEQ,
        BAG,
        SET
    }

    private static final ContainerLawDeclaration NONE = new ContainerLawDeclaration(
            Kind.NONE,
            false,
            false,
            false,
            false,
            Collections.emptyMap());

    private final Kind kind;
    private final boolean associative;
    private final boolean commutative;
    private final boolean idempotent;
    private final boolean hasUnit;
    private final NavigableMap<ContainerLawCertificate.Law, ContainerLawCertificate>
            certificates;

    private ContainerLawDeclaration(
            Kind kind,
            boolean associative,
            boolean commutative,
            boolean idempotent,
            boolean hasUnit,
            Map<ContainerLawCertificate.Law, ContainerLawCertificate> certificates) {
        this.kind = Objects.requireNonNull(kind, "kind");
        this.associative = associative;
        this.commutative = commutative;
        this.idempotent = idempotent;
        this.hasUnit = hasUnit;
        Objects.requireNonNull(certificates, "certificates");
        NavigableMap<ContainerLawCertificate.Law, ContainerLawCertificate> copied =
                new TreeMap<>();
        for (Map.Entry<ContainerLawCertificate.Law, ContainerLawCertificate> entry
                : certificates.entrySet()) {
            ContainerLawCertificate certificate = Objects.requireNonNull(
                    entry.getValue(), "container law certificate");
            if (entry.getKey() != certificate.law()) {
                throw new IllegalArgumentException(
                        "Container certificate is stored under the wrong law");
            }
            CertificateVerifier.verifyContainerLaw(certificate);
            copied.put(entry.getKey(), certificate);
        }
        this.certificates = Collections.unmodifiableNavigableMap(copied);
    }

    public static ContainerLawDeclaration none() {
        return NONE;
    }

    /** Structural Phase C/E declaration; strict Phase F use rejects missing proofs. */
    public static ContainerLawDeclaration of(
            Kind kind,
            boolean associative,
            boolean commutative,
            boolean idempotent,
            boolean hasUnit) {
        return new ContainerLawDeclaration(
                kind,
                associative,
                commutative,
                idempotent,
                hasUnit,
                Collections.emptyMap());
    }

    public static ContainerLawDeclaration certified(
            PortSchema schema,
            List<? extends ContainerLawCertificate> sourceCertificates) {
        Objects.requireNonNull(schema, "schema");
        Objects.requireNonNull(sourceCertificates, "certificates");
        NavigableMap<ContainerLawCertificate.Law, ContainerLawCertificate> indexed =
                new TreeMap<>();
        for (ContainerLawCertificate certificate : sourceCertificates) {
            ContainerLawCertificate checked = Objects.requireNonNull(
                    certificate, "container law certificate");
            CertificateVerifier.verifyContainerLaw(checked);
            if (!checked.appliesTo(schema)) {
                throw new IllegalArgumentException(
                        "Container certificate names a different schema");
            }
            if (indexed.putIfAbsent(checked.law(), checked) != null) {
                throw new IllegalArgumentException(
                        "Duplicate certificate for " + checked.law());
            }
        }
        Kind kind = kindFor(schema);
        boolean associative = kind != Kind.NONE;
        boolean commutative = kind == Kind.BAG || kind == Kind.SET;
        boolean idempotent = kind == Kind.SET;
        boolean hasUnit = containerEmptiness(schema) == ContainerEmptiness.K_ZERO;
        ContainerLawDeclaration declaration = new ContainerLawDeclaration(
                kind,
                associative,
                commutative,
                idempotent,
                hasUnit,
                indexed);
        declaration.validateAgainst(schema);
        declaration.requireCertified();
        return declaration;
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

    public Map<ContainerLawCertificate.Law, ContainerLawCertificate> certificates() {
        return certificates;
    }

    public boolean hasCertifiedLaws() {
        try {
            requireCertified();
            return true;
        } catch (IllegalStateException exception) {
            return false;
        }
    }

    void requireCertified() {
        if (kind == Kind.NONE) {
            return;
        }
        requireCertificate(ContainerLawCertificate.Law.ASSOCIATIVITY, associative);
        requireCertificate(ContainerLawCertificate.Law.COMMUTATIVITY, commutative);
        requireCertificate(ContainerLawCertificate.Law.IDEMPOTENCY, idempotent);
        requireCertificate(ContainerLawCertificate.Law.UNIT, hasUnit);
        int expected = (associative ? 1 : 0)
                + (commutative ? 1 : 0)
                + (idempotent ? 1 : 0)
                + (hasUnit ? 1 : 0);
        if (certificates.size() != expected) {
            throw new IllegalStateException(
                    "Container declaration contains an undeclared law certificate");
        }
    }

    private void requireCertificate(
            ContainerLawCertificate.Law law,
            boolean required) {
        if (certificates.containsKey(law) != required) {
            throw new IllegalStateException(
                    "Container declaration certificate mismatch for " + law);
        }
    }

    void validateAgainst(PortSchema schema) {
        Objects.requireNonNull(schema, "schema");
        Kind expected = kindFor(schema);
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
            throw new IllegalArgumentException(
                    "A fixed port cannot declare a container unit");
        }
        ContainerEmptiness emptiness = containerEmptiness(schema);
        if (emptiness == ContainerEmptiness.K_ZERO && !hasUnit) {
            throw new IllegalArgumentException(
                    "A K0 container schema requires an explicit unit-law declaration");
        }
        for (ContainerLawCertificate certificate : certificates.values()) {
            if (!certificate.appliesTo(schema)) {
                throw new IllegalArgumentException(
                        "Container certificate names a different schema");
            }
        }
    }

    private static Kind kindFor(PortSchema schema) {
        switch (schema.kind()) {
            case SEQ:
                return Kind.SEQ;
            case BAG:
                return Kind.BAG;
            case SET:
                return Kind.SET;
            default:
                return Kind.NONE;
        }
    }

    private static ContainerEmptiness containerEmptiness(PortSchema schema) {
        if (schema instanceof SeqPortSchema) {
            return ((SeqPortSchema) schema).emptiness();
        }
        if (schema instanceof BagPortSchema) {
            return ((BagPortSchema) schema).emptiness();
        }
        if (schema instanceof SetPortSchema) {
            return ((SetPortSchema) schema).emptiness();
        }
        return null;
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
                Collections.emptyList());
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
                + ",I=" + idempotent + ",unit=" + hasUnit
                + ",certs=" + certificates.size() + "]";
    }
}
