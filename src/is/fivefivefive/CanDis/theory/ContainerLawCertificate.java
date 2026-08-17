package is.fivefivefive.CanDis.theory;

import java.util.Arrays;
import java.util.Collections;
import java.util.Objects;

/** Signature provenance for one exact Seq/Bag/Set algebraic law. */
public final class ContainerLawCertificate extends TypedEqualityCertificate {
    public enum Law {
        ASSOCIATIVITY,
        COMMUTATIVITY,
        IDEMPOTENCY,
        UNIT
    }

    private final PortSchema schema;
    private final Law law;
    private final CertificateOrigin origin;

    public ContainerLawCertificate(
            PortSchema schema,
            Law law,
            CertificateOrigin origin) {
        super(
                CertificateCategory.CONTAINER_LAW,
                TypedCertificateEndpoint.containerPattern(
                        Objects.requireNonNull(schema, "schema"),
                        Objects.requireNonNull(law, "law"),
                        "left"),
                TypedCertificateEndpoint.containerPattern(schema, law, "right"),
                Collections.emptyList(),
                Arrays.asList(
                        schema.structuralKey(),
                        Objects.requireNonNull(origin, "origin").structuralKey(),
                        StructuralKey.leaf("container-law", law.name())));
        this.schema = schema;
        this.law = law;
        this.origin = origin;
        verifyLocal();
    }

    public PortSchema schema() {
        return schema;
    }

    public Law law() {
        return law;
    }

    public CertificateOrigin origin() {
        return origin;
    }

    public boolean appliesTo(PortSchema candidate) {
        return schema.equals(candidate);
    }

    @Override
    void verifyLocal() {
        if (origin.kind() != CertificateOrigin.Kind.SIGNATURE_CONTAINER_LAW) {
            throw new IllegalStateException(
                    "Container law requires signature-law provenance");
        }
        boolean allowed;
        switch (law) {
            case ASSOCIATIVITY:
                allowed = isContainer(schema);
                break;
            case COMMUTATIVITY:
                allowed = schema instanceof BagPortSchema || schema instanceof SetPortSchema;
                break;
            case IDEMPOTENCY:
                allowed = schema instanceof SetPortSchema;
                break;
            case UNIT:
                allowed = emptiness(schema) == ContainerEmptiness.K_ZERO;
                break;
            default:
                allowed = false;
        }
        if (!allowed) {
            throw new IllegalStateException(
                    "Container law is incompatible with its port schema");
        }
    }

    private static boolean isContainer(PortSchema schema) {
        return schema instanceof SeqPortSchema
                || schema instanceof BagPortSchema
                || schema instanceof SetPortSchema;
    }

    private static ContainerEmptiness emptiness(PortSchema schema) {
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
}
