package is.fivefivefive.CanDis.theory;

import java.util.List;
import java.util.Objects;

/** Ordered typed leaf of a dependent chain. */
public final class DependentChainLeaf implements DependentChainInput {
    private final OnePort port;
    private final GraphType relationType;
    private final DependentChainTheory.LeafTypeRule typeRule;
    private final StructuralKey typeProof;
    private final StructuralKey structuralKey;

    public DependentChainLeaf(OnePort port) {
        this(port, Objects.requireNonNull(port, "port").schema().type());
    }

    public DependentChainLeaf(OnePort port, GraphType relationType) {
        this.port = Objects.requireNonNull(port, "port");
        this.relationType = Objects.requireNonNull(relationType, "relationType");
        this.typeRule = DependentChainTheory.requireLeafTypeProof(
                port.schema().type(), relationType);
        this.typeProof = DependentChainTheory.leafTypeProof(
                typeRule, port.schema().type(), relationType);
        this.structuralKey = StructuralKey.branch(
                "dependent-chain-leaf-v1",
                List.of(port.structuralKey(), typeProof));
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
    public GraphType outputType() {
        return relationType;
    }

    @Override
    public List<OnePort> leaves() {
        return List.of(port);
    }

    @Override
    public DependentChainLeaf act(TypedEmbedding embedding) {
        return new DependentChainLeaf(port.act(embedding), relationType);
    }

    @Override
    public StructuralKey structuralKey() {
        return structuralKey;
    }
}
