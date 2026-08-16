package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/** Well-typed flexible-arity e-node with a private, invariant-preserving constructor. */
public final class TypedENode implements HasSlotSupport {
    private final InstantiatedOperator operator;
    private final TypedSlotContext context;
    private final List<PortValue> ports;
    private final TypedSlotContext support;
    private final StructuralKey structuralKey;

    private TypedENode(
            InstantiatedOperator operator,
            TypedSlotContext context,
            List<? extends PortValue> ports) {
        this.operator = Objects.requireNonNull(operator, "operator");
        this.context = Objects.requireNonNull(context, "context");
        Objects.requireNonNull(ports, "ports");
        if (ports.size() != operator.portSchemas().size()) {
            throw new IllegalArgumentException("Node port count does not match its signature");
        }
        List<PortValue> copied = new ArrayList<>(ports.size());
        TypedSlotContext computedSupport = TypedSlotContext.empty();
        for (int index = 0; index < ports.size(); index++) {
            PortValue port = Objects.requireNonNull(ports.get(index), "port");
            if (!operator.portSchemas().get(index).equals(port.schema())) {
                throw new IllegalArgumentException("Node port schema mismatch at index " + index);
            }
            if (!context.equals(port.context())) {
                throw new IllegalArgumentException("Every node port must use the node caller context");
            }
            rejectUncertifiedEmpty(PortPath.at(index), port);
            computedSupport = computedSupport.union(port.support());
            copied.add(port);
        }
        this.ports = Collections.unmodifiableList(copied);
        this.support = computedSupport;
        this.structuralKey = buildStructuralKey();
    }

    /** Constructs an operator that has no recursive associative flat port. */
    public static TypedENode construct(
            InstantiatedOperator operator,
            TypedSlotContext context,
            List<? extends PortValue> ports) {
        Objects.requireNonNull(operator, "operator");
        if (operator.usesFlatConstruction()) {
            throw new IllegalArgumentException(
                    "Associative operators must be constructed through flatConstruct");
        }
        return new TypedENode(operator, context, ports);
    }

    /**
     * Flattens only visible same-headed source applications. Opaque invocation
     * leaves are copied without inspecting their e-classes.
     */
    public static TypedENode flatConstruct(
            FlatApplication source,
            NodeSealer sealer) {
        Objects.requireNonNull(source, "source");
        Objects.requireNonNull(sealer, "sealer");
        InstantiatedOperator operator = source.operator();
        if (!operator.usesFlatConstruction()) {
            throw new IllegalArgumentException("Operator is not declared for flat construction");
        }
        PortSchema containerSchema = operator.portSchemas().get(0);
        OnePortSchema elementSchema = (OnePortSchema) OperatorDeclaration.elementSchema(containerSchema);
        List<PortValue> elements = new ArrayList<>();
        collectVisibleElements(source, operator, elementSchema, sealer, elements);
        PortValue container = makeContainer(containerSchema, source.context(), elements);
        return new TypedENode(operator, source.context(), Collections.singletonList(container));
    }

    private static void collectVisibleElements(
            FlatApplication source,
            InstantiatedOperator rootOperator,
            OnePortSchema elementSchema,
            NodeSealer sealer,
            List<PortValue> output) {
        for (FlatInput input : source.operands()) {
            if (input instanceof FlatApplication) {
                FlatApplication application = (FlatApplication) input;
                if (rootOperator.equals(application.operator())) {
                    collectVisibleElements(application, rootOperator, elementSchema, sealer, output);
                    continue;
                }
                TypedENode nested = flatConstruct(application, sealer);
                TypedInvocation invocation = Objects.requireNonNull(
                        sealer.seal(nested), "sealed invocation");
                validateSealedInvocation(nested, invocation);
                output.add(new OnePort(
                        elementSchema,
                        source.context(),
                        new InvocationPortLeaf(invocation)));
                continue;
            }
            OnePort port = ((FlatLeaf) input).port();
            if (!elementSchema.equals(port.schema()) || !source.context().equals(port.context())) {
                throw new IllegalArgumentException("Flat leaf does not match the operator element port");
            }
            output.add(port);
        }
    }

    private static void validateSealedInvocation(
            TypedENode node,
            TypedInvocation invocation) {
        if (!node.outputType().equals(invocation.outputType())) {
            throw new IllegalArgumentException("Node sealer changed the nested node output type");
        }
        if (!node.context().equals(invocation.callerContext())) {
            throw new IllegalArgumentException("Node sealer changed the nested caller context");
        }
        if (!node.support().equals(invocation.support())) {
            throw new IllegalArgumentException("Node sealer changed the nested node support");
        }
    }

    private static PortValue makeContainer(
            PortSchema schema,
            TypedSlotContext context,
            List<PortValue> elements) {
        if (schema instanceof SeqPortSchema) {
            return new SeqPort((SeqPortSchema) schema, context, elements);
        }
        if (schema instanceof BagPortSchema) {
            return new BagPort((BagPortSchema) schema, context, elements);
        }
        if (schema instanceof SetPortSchema) {
            return new SetPort((SetPortSchema) schema, context, elements);
        }
        throw new IllegalStateException("Flat operator port is not a container");
    }

    private void rejectUncertifiedEmpty(PortPath path, PortValue port) {
        boolean empty = (port instanceof SeqPort && ((SeqPort) port).isEmpty())
                || (port instanceof BagPort && ((BagPort) port).isEmpty())
                || (port instanceof SetPort && ((SetPort) port).isEmpty());
        if (empty && !operator.lawForPath(path).hasUnit()) {
            throw new IllegalArgumentException(
                    "Empty variadic port at " + path
                            + " requires an explicit unit-law declaration");
        }
        PortPath childPath = path.child();
        if (port instanceof SeqPort) {
            for (PortValue element : ((SeqPort) port).elements()) {
                rejectUncertifiedEmpty(childPath, element);
            }
        } else if (port instanceof BagPort) {
            for (PortValue element : ((BagPort) port).occurrences()) {
                rejectUncertifiedEmpty(childPath, element);
            }
        } else if (port instanceof SetPort) {
            for (PortValue element : ((SetPort) port).elements()) {
                rejectUncertifiedEmpty(childPath, element);
            }
        } else if (port instanceof BindPort) {
            rejectUncertifiedEmpty(childPath, ((BindPort) port).body());
        }
    }

    public InstantiatedOperator operator() {
        return operator;
    }

    public TypedSlotContext context() {
        return context;
    }

    public List<PortValue> ports() {
        return ports;
    }

    public GraphType outputType() {
        return operator.outputType();
    }

    @Override
    public TypedSlotContext support() {
        return support;
    }

    public TypedENode act(TypedEmbedding embedding) {
        Objects.requireNonNull(embedding, "embedding");
        if (!context.equals(embedding.source())) {
            throw new IllegalArgumentException("Node action source must equal its caller context");
        }
        List<PortValue> acted = new ArrayList<>(ports.size());
        for (PortValue port : ports) {
            acted.add(port.act(embedding));
        }
        return new TypedENode(operator, embedding.codomain(), acted);
    }

    /**
     * Rebuilds this already-flat node after graph-relative leaf and port
     * normalization. The input is port syntax, so this operation cannot expose
     * or flatten an opaque invocation.
     */
    TypedENode rebuildCanonicalCandidate(
            TypedSlotContext targetContext,
            List<? extends PortValue> normalizedPorts) {
        return new TypedENode(operator, targetContext, normalizedPorts);
    }

    public StructuralKey structuralKey() {
        return structuralKey;
    }

    private StructuralKey buildStructuralKey() {
        List<StructuralKey> children = new ArrayList<>(ports.size() + 2);
        children.add(operator.structuralKey());
        children.add(TheoryKeys.context(context));
        for (PortValue port : ports) {
            children.add(port.structuralKey());
        }
        return StructuralKey.branch("e-node", children);
    }

    @Override
    public boolean equals(Object other) {
        if (!(other instanceof TypedENode)) {
            return false;
        }
        TypedENode node = (TypedENode) other;
        return operator.equals(node.operator)
                && context.equals(node.context)
                && ports.equals(node.ports);
    }

    @Override
    public int hashCode() {
        return Objects.hash(operator, context, ports);
    }

    @Override
    public String toString() {
        return operator.operator() + ports;
    }
}
