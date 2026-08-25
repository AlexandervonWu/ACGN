package is.fivefivefive.CanDis.theory;

import java.util.List;
import java.util.Objects;

/** Ordered typed leaf of a dependent chain. */
public final class DependentChainLeaf implements DependentChainInput {
    private final OnePort port;
    private final DependentTypeDag outputTypeDag;
    private final DependentChainTheory.LeafTypeRule typeRule;
    private final StructuralKey typeProof;
    private final StructuralKey structuralKey;

    public DependentChainLeaf(OnePort port) {
        this(port, Objects.requireNonNull(port, "port").schema().type());
    }

    public DependentChainLeaf(OnePort port, GraphType relationType) {
        this(port, DependentTypeDag.fromRelationFamilyType(
                Objects.requireNonNull(relationType, "relationType")));
    }

    public DependentChainLeaf(
            OnePort port,
            GraphType relationType,
            List<DependentColumnEvidence> outputColumns) {
        this(
                port,
                DependentTypeDag.exactAlternative(
                        relationType, outputColumns));
    }

    public DependentChainLeaf(
            OnePort port,
            DependentTypeDag outputTypeDag) {
        this.port = Objects.requireNonNull(port, "port");
        this.outputTypeDag = Objects.requireNonNull(outputTypeDag, "outputTypeDag");
        GraphType relationType = outputTypeDag.relationType();
        this.typeRule = DependentChainTheory.requireLeafTypeProof(
                port.schema().type(), relationType);
        this.typeProof = DependentChainTheory.leafTypeProof(
                typeRule, port.schema().type(), relationType);
        this.structuralKey = StructuralKey.branch(
                "dependent-chain-leaf-v3",
                List.of(
                        port.structuralKey(),
                        typeProof,
                        outputTypeDag.structuralKey()));
    }

    public OnePort port() {
        return port;
    }

    public DependentChainTheory.LeafTypeRule typeRule() {
        return typeRule;
    }

    public StructuralKey typeProof() {
        return typeProof;
    }

    @Override
    public TypedSlotContext context() {
        return port.context();
    }

    @Override
    public DependentTypeDag outputTypeDag() {
        return outputTypeDag;
    }

    @Override
    public List<OnePort> leaves() {
        return List.of(port);
    }

    @Override
    public DependentChainLeaf act(TypedEmbedding embedding) {
        return new DependentChainLeaf(
                port.act(embedding), outputTypeDag);
    }

    @Override
    public StructuralKey structuralKey() {
        return structuralKey;
    }

    StructuralKey columnEvidenceKey() {
        return outputTypeDag.structuralKey();
    }

    static StructuralKey columnEvidenceKey(
            List<DependentColumnEvidence> columns) {
        return StructuralKey.branch(
                "dependent-chain-column-evidence-v1",
                columns.stream()
                        .map(DependentColumnEvidence::structuralKey)
                        .toList());
    }
}
