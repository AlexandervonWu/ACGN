package is.fivefivefive.CanDis.adapter;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.IdentityHashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.NavigableSet;
import java.util.Objects;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.EGraphNode.EClassRef;
import is.fivefivefive.CanDis.core.EGraphNode.FlexibleArityKind;
import is.fivefivefive.CanDis.core.EGraphNode.Metatype;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.core.NormalForm.TemporalOp;
import is.fivefivefive.CanDis.core.QuantiVar;
import is.fivefivefive.CanDis.theory.BagPortSchema;
import is.fivefivefive.CanDis.theory.BagPort;
import is.fivefivefive.CanDis.theory.BindBlockPort;
import is.fivefivefive.CanDis.theory.BindBlockPortSchema;
import is.fivefivefive.CanDis.theory.BinderAutomorphismCertificate;
import is.fivefivefive.CanDis.theory.BinderBlockDescriptor;
import is.fivefivefive.CanDis.theory.BinderCoordinateDescriptor;
import is.fivefivefive.CanDis.theory.BoundedFiniteUnfoldingOracle;
import is.fivefivefive.CanDis.theory.CanonicalShape;
import is.fivefivefive.CanDis.theory.CertificateOrigin;
import is.fivefivefive.CanDis.theory.CertifiedInsertionResult;
import is.fivefivefive.CanDis.theory.CertifiedSemanticArtifact;
import is.fivefivefive.CanDis.theory.CoherentWitnessFamily;
import is.fivefivefive.CanDis.theory.ContainerEmptiness;
import is.fivefivefive.CanDis.theory.ContainerLawCertificate;
import is.fivefivefive.CanDis.theory.ContainerLawDeclaration;
import is.fivefivefive.CanDis.theory.FiniteUnfoldingBounds;
import is.fivefivefive.CanDis.theory.FiniteUnfoldingTree;
import is.fivefivefive.CanDis.theory.FlatApplication;
import is.fivefivefive.CanDis.theory.FlatInput;
import is.fivefivefive.CanDis.theory.FlatLeaf;
import is.fivefivefive.CanDis.theory.GraphStatus;
import is.fivefivefive.CanDis.theory.GraphType;
import is.fivefivefive.CanDis.theory.InstantiatedOperator;
import is.fivefivefive.CanDis.theory.OnePort;
import is.fivefivefive.CanDis.theory.OnePortSchema;
import is.fivefivefive.CanDis.theory.OperatorDeclaration;
import is.fivefivefive.CanDis.theory.PortPath;
import is.fivefivefive.CanDis.theory.PortSchema;
import is.fivefivefive.CanDis.theory.PortValue;
import is.fivefivefive.CanDis.theory.SeqPortSchema;
import is.fivefivefive.CanDis.theory.SetPortSchema;
import is.fivefivefive.CanDis.theory.SlotAlphabet;
import is.fivefivefive.CanDis.theory.StructuralKey;
import is.fivefivefive.CanDis.theory.TypedEClassRecord;
import is.fivefivefive.CanDis.theory.TypedENode;
import is.fivefivefive.CanDis.theory.TypedEmbedding;
import is.fivefivefive.CanDis.theory.TypedInvocation;
import is.fivefivefive.CanDis.theory.TypedPermutation;
import is.fivefivefive.CanDis.theory.TypedRenaming;
import is.fivefivefive.CanDis.theory.TypedSlot;
import is.fivefivefive.CanDis.theory.TypedSlotContext;
import is.fivefivefive.CanDis.theory.TypedSlottedPortEGraph;

/** Converts normalized Alloy temporal phases into the exact typed graph. */
public final class TheoryAlloyAdapter {
    public static final String ADAPTER_VERSION = "typed-alloy-normal-form-adapter-v7";
    public static final String SIGNATURE_VERSION = "canonical-alloy-signature-v6";
    public static final String INVARIANT_MODE = "strict-every-transition";
    private static final GraphType REL = GraphType.constructor("AlloyRel");

    private TheoryAlloyAdapter() {
    }

    public static Result adapt(List<NormalForm> normalForms) {
        return new Builder(normalForms).build();
    }

    public static final class Result {
        private final CertifiedSemanticArtifact semanticArtifact;
        private final StructuralKey canonicalKey;
        private final List<BinderBlockDescriptor> phaseBinderDescriptors;
        private final List<List<Integer>> phaseSourceCoordinates;
        private final Map<EGraphNode, BinderBlockDescriptor> localBinderDescriptors;
        private final Map<EGraphNode, Map<String, Integer>> localBinderSourceCoordinates;
        private final long eclasses;
        private final long enodes;
        private final long slots;
        private final long rebuilds;
        private final long estimatedBytes;
        private final long constructionNanos;
        private final long unfoldingNanos;
        private final long observationNanos;

        private Result(
                CertifiedSemanticArtifact semanticArtifact,
                StructuralKey canonicalKey,
                List<? extends BinderBlockDescriptor> phaseBinderDescriptors,
                List<? extends List<Integer>> phaseSourceCoordinates,
                Map<EGraphNode, BinderBlockDescriptor> localBinderDescriptors,
                Map<EGraphNode, Map<String, Integer>> localBinderSourceCoordinates,
                long eclasses,
                long enodes,
                long slots,
                long rebuilds,
                long estimatedBytes,
                long constructionNanos,
                long unfoldingNanos,
                long observationNanos) {
            this.semanticArtifact = Objects.requireNonNull(
                    semanticArtifact, "semanticArtifact");
            this.canonicalKey = canonicalKey;
            this.phaseBinderDescriptors = Collections.unmodifiableList(
                    new ArrayList<>(phaseBinderDescriptors));
            List<List<Integer>> coordinateCopies = new ArrayList<>(
                    phaseSourceCoordinates.size());
            for (List<Integer> coordinates : phaseSourceCoordinates) {
                coordinateCopies.add(Collections.unmodifiableList(
                        new ArrayList<>(coordinates)));
            }
            this.phaseSourceCoordinates = Collections.unmodifiableList(coordinateCopies);
            this.localBinderDescriptors = Collections.unmodifiableMap(
                    new IdentityHashMap<>(localBinderDescriptors));
            IdentityHashMap<EGraphNode, Map<String, Integer>> localCoordinateCopies =
                    new IdentityHashMap<>();
            for (Map.Entry<EGraphNode, Map<String, Integer>> entry
                    : localBinderSourceCoordinates.entrySet()) {
                localCoordinateCopies.put(
                        entry.getKey(),
                        Collections.unmodifiableMap(new LinkedHashMap<>(entry.getValue())));
            }
            this.localBinderSourceCoordinates = Collections.unmodifiableMap(
                    localCoordinateCopies);
            this.eclasses = eclasses;
            this.enodes = enodes;
            this.slots = slots;
            this.rebuilds = rebuilds;
            this.estimatedBytes = estimatedBytes;
            this.constructionNanos = constructionNanos;
            this.unfoldingNanos = unfoldingNanos;
            this.observationNanos = observationNanos;
        }

        public StructuralKey canonicalKey() {
            return canonicalKey;
        }

        public CertifiedSemanticArtifact semanticArtifact() {
            return semanticArtifact;
        }

        /** Certified binder carrier for each repaired normal-form phase, in phase order. */
        public List<BinderBlockDescriptor> phaseBinderDescriptors() {
            return phaseBinderDescriptors;
        }

        /** Source NormalForm binding index to certified descriptor coordinate. */
        public List<List<Integer>> phaseSourceCoordinates() {
            return phaseSourceCoordinates;
        }

        /** Certified descriptors for source binders retained inside a phase matrix. */
        public Map<EGraphNode, BinderBlockDescriptor> localBinderDescriptors() {
            return localBinderDescriptors;
        }

        /** Source local-variable name to certified descriptor coordinate. */
        public Map<EGraphNode, Map<String, Integer>> localBinderSourceCoordinates() {
            return localBinderSourceCoordinates;
        }

        public long eclasses() {
            return eclasses;
        }

        public long enodes() {
            return enodes;
        }

        public long slots() {
            return slots;
        }

        public long rebuilds() {
            return rebuilds;
        }

        public long estimatedBytes() {
            return estimatedBytes;
        }

        public long constructionNanos() {
            return constructionNanos;
        }

        public long unfoldingNanos() {
            return unfoldingNanos;
        }

        public long observationNanos() {
            return observationNanos;
        }
    }

    private static final class Builder {
        private final List<NormalForm> normalForms;
        private final Set<NormalForm> declaredForms;
        private final Set<NormalForm> builtForms = Collections.newSetFromMap(new IdentityHashMap<>());
        private final Map<NormalForm, BinderBlockDescriptor> phaseBinderDescriptors =
                new IdentityHashMap<>();
        private final Map<NormalForm, List<Integer>> phaseSourceCoordinates =
                new IdentityHashMap<>();
        private final Map<EGraphNode, BinderBlockDescriptor> localBinderDescriptors =
                new IdentityHashMap<>();
        private final Map<EGraphNode, Map<String, Integer>> localBinderSourceCoordinates =
                new IdentityHashMap<>();
        private final TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        private final Map<InvocationKey, TypedInvocation> memo = new HashMap<>();
        private final Map<OnePort, TypedInvocation> relationalCoercions = new HashMap<>();
        private final Map<String, List<ContainerLawDeclaration>> certifiedContainerLaws =
                new LinkedHashMap<>();
        private final Set<InvocationKey> active = new HashSet<>();
        private long rebuilds;

        private Builder(List<NormalForm> normalForms) {
            Objects.requireNonNull(normalForms, "normalForms");
            this.normalForms = Collections.unmodifiableList(new ArrayList<>(normalForms));
            this.declaredForms = Collections.newSetFromMap(new IdentityHashMap<>());
            this.declaredForms.addAll(normalForms);
            certifySourceContainerLaws();
        }

        private void certifySourceContainerLaws() {
            Set<EGraphNode> visited = Collections.newSetFromMap(new IdentityHashMap<>());
            for (NormalForm normalForm : normalForms) {
                certifySourceContainerLaws(normalForm.getMatrixEGraph(), visited);
            }
        }

        private void certifySourceContainerLaws(
                EGraphNode node,
                Set<EGraphNode> visited) {
            if (node == null || !visited.add(node)) {
                return;
            }
            if (node.isFlexibleArity()) {
                PortSchema schema = containerSchema(
                        node.getFlexibleArityKind(),
                        new OnePortSchema(outputType(node)));
                String operator = semanticHead(node);
                recordContainerLaws(operator, certifiedLaws(schema, operator));
            }
            for (EGraphNode child : node.getChildren()) {
                certifySourceContainerLaws(child, visited);
            }
        }

        private Result build() {
            long phaseStarted = System.nanoTime();
            TypedInvocation root;
            if (normalForms.isEmpty()) {
                root = insert(constantNode("empty-normal-form", GraphType.BOOL, TypedSlotContext.empty()));
            } else {
                NormalForm rootForm = normalForms.get(0);
                Map<String, TypedSlot> bindings = new LinkedHashMap<>();
                TypedSlotContext context = addParameters(
                        TypedSlotContext.empty(), bindings, rootForm.getParams());
                root = buildPhase(rootForm, context, bindings);
                if (!builtForms.containsAll(declaredForms)) {
                    throw new IllegalStateException(
                            "The temporal normal-form list contains a phase unreachable from its root");
                }
            }
            long constructionNanos = System.nanoTime() - phaseStarted;
            phaseStarted = System.nanoTime();
            ensureQuiescent();
            graph.checkInvariants();
            CoherentWitnessFamily family = graph.coherentWitnessFamily();
            int depth = Math.max(1, graph.classes().size() + 1);
            BoundedFiniteUnfoldingOracle oracle = graph.finiteUnfoldingOracle(
                    family, new FiniteUnfoldingBounds(depth, 64));
            List<FiniteUnfoldingTree> unfoldings = oracle.enumerate(root);
            long unfoldingNanos = System.nanoTime() - phaseStarted;
            phaseStarted = System.nanoTime();
            if (unfoldings.isEmpty()) {
                throw new IllegalStateException(
                        "The acyclic Alloy adapter produced no complete finite unfolding");
            }
            NavigableSet<StructuralKey> normalized = new TreeSet<>();
            for (FiniteUnfoldingTree tree : unfoldings) {
                normalized.add(tree.normalizedTermKey());
            }
            StructuralKey key = StructuralKey.branch(
                    "canonical-alloy-form", new ArrayList<>(normalized));
            long observationNanos = System.nanoTime() - phaseStarted;

            long enodes = 0;
            long slots = 0;
            for (TypedEClassRecord record : graph.classes().values()) {
                enodes += record.shapeWitnesses().size();
                slots += record.exposedSlots().size();
            }
            long eclasses = graph.classes().size();
            long estimatedBytes = 64L * eclasses + 112L * enodes + 32L * slots;
            CertifiedSemanticArtifact semanticArtifact = new CertifiedSemanticArtifact(
                    root, graph.classes(), family, unfoldings, certifiedContainerLaws);
            List<BinderBlockDescriptor> orderedPhaseDescriptors = new ArrayList<>(normalForms.size());
            List<List<Integer>> orderedSourceCoordinates = new ArrayList<>(normalForms.size());
            for (NormalForm normalForm : normalForms) {
                BinderBlockDescriptor descriptor = phaseBinderDescriptors.get(normalForm);
                List<Integer> sourceCoordinates = phaseSourceCoordinates.get(normalForm);
                if (descriptor == null || sourceCoordinates == null) {
                    throw new IllegalStateException(
                            "A normalized temporal phase has no certified binder plan");
                }
                orderedPhaseDescriptors.add(descriptor);
                orderedSourceCoordinates.add(sourceCoordinates);
            }
            return new Result(
                    semanticArtifact,
                    key,
                    orderedPhaseDescriptors,
                    orderedSourceCoordinates,
                    localBinderDescriptors,
                    localBinderSourceCoordinates,
                    eclasses,
                    enodes,
                    slots,
                    rebuilds,
                    estimatedBytes,
                    constructionNanos,
                    unfoldingNanos,
                    observationNanos);
        }

        private TypedSlotContext addParameters(
                TypedSlotContext context,
                Map<String, TypedSlot> bindings,
                List<QuantiVar> parameters) {
            Map<GraphType, Integer> ordinals = new TreeMap<>();
            TypedSlotContext result = context;
            for (int index = 0; index < parameters.size(); index++) {
                QuantiVar parameter = parameters.get(index);
                GraphType carrier = GraphType.constructor(
                        "Parameter" + index,
                        Collections.singletonList(bindingType(parameter)));
                int ordinal = ordinals.getOrDefault(carrier, 0);
                ordinals.put(carrier, ordinal + 1);
                TypedSlot slot = TypedSlot.of(carrier, SlotAlphabet.SOURCE, ordinal);
                result = result.plus(slot);
                registerBinding(bindings, parameter, slot);
            }
            return result;
        }

        private TypedInvocation buildPhase(
                NormalForm phase,
                TypedSlotContext ambient,
                Map<String, TypedSlot> inheritedBindings) {
            if (!declaredForms.contains(phase)) {
                throw new IllegalStateException("Temporal child is absent from IRAgent.normalForms()");
            }
            if (!builtForms.add(phase)) {
                throw new IllegalStateException("A temporal phase is reachable through two structural parents");
            }

            BinderPlan plan = binderPlan(phase.getMatrixQuantiVars(), ambient);
            if (phaseBinderDescriptors.put(phase, plan.descriptor) != null) {
                throw new IllegalStateException(
                        "A temporal phase received two certified binder descriptors");
            }
            if (phaseSourceCoordinates.put(phase, plan.sourceToCoordinate) != null) {
                throw new IllegalStateException(
                        "A temporal phase received two certified coordinate maps");
            }
            TypedSlotContext bodyContext = ambient.union(plan.occurrence.codomain());
            Map<String, TypedSlot> bodyBindings = new LinkedHashMap<>(inheritedBindings);
            for (int index = 0; index < plan.variables.size(); index++) {
                TypedSlot descriptorSlot = plan.coordinates.get(index).canonicalSlot();
                registerBinding(
                        bodyBindings,
                        plan.variables.get(index),
                        plan.occurrence.apply(descriptorSlot));
            }
            for (QuantiVar inherited : phase.getInheritedQuantiVars()) {
                if (!hasBinding(bodyBindings, inherited)) {
                    throw new IllegalStateException(
                            "Temporal phase lost inherited binder " + inherited.getDeBruijnKey());
                }
            }

            Map<String, TypedInvocation> temporalReferences = buildTemporalReferences(
                    phase, bodyContext, bodyBindings);
            EGraphNode matrix = phase.getMatrixEGraph();
            OnePort matrixValue = matrix == null
                    ? OnePort.invocation(bodyContext, insert(constantNode(
                            "true", GraphType.BOOL, bodyContext)))
                    : buildMatrixOperand(
                            phase,
                            matrix,
                            bodyContext,
                            bodyBindings,
                            temporalReferences);
            TypedInvocation matrixInvocation = asInvocation(matrixValue, bodyContext, "phase-matrix");
            if (plan.variables.isEmpty()) {
                return matrixInvocation;
            }

            BindBlockPortSchema schema = new BindBlockPortSchema(
                    plan.descriptor, new OnePortSchema(matrixInvocation.outputType()));
            BindBlockPort block = new BindBlockPort(
                    schema,
                    ambient,
                    plan.occurrence,
                    OnePort.invocation(bodyContext, matrixInvocation));
            OperatorDeclaration declaration = OperatorDeclaration.monomorphic(
                    "ALLOY/QT",
                    Collections.singletonList(schema),
                    matrixInvocation.outputType(),
                    Collections.emptyMap(),
                    null);
            return insert(TypedENode.construct(
                    declaration.instantiateMonomorphic(),
                    ambient,
                    Collections.singletonList(block)));
        }

        private OnePort buildMatrixOperand(
                NormalForm phase,
                EGraphNode matrix,
                TypedSlotContext context,
                Map<String, TypedSlot> bindings,
                Map<String, TypedInvocation> temporalReferences) {
            Map<String, String> rootNames = identitySlotNames(matrix);
            if (phase == normalForms.get(0)
                    && (matrix.getOpcode() == Opcode.PREDICATE
                            || matrix.getOpcode() == Opcode.CALL)
                    && matrix.getSourceName() != null
                    && matrix.getChildClasses().size() == 1) {
                return buildChildOperand(
                        matrix.getChildClasses().get(0),
                        rootNames,
                        context,
                        bindings,
                        temporalReferences);
            }
            return buildOperand(
                    matrix,
                    rootNames,
                    context,
                    bindings,
                    temporalReferences);
        }

        private Map<String, TypedInvocation> buildTemporalReferences(
                NormalForm phase,
                TypedSlotContext context,
                Map<String, TypedSlot> bindings) {
            Map<String, TypedInvocation> result = new HashMap<>();
            List<NormalForm> children = phase.getTemporalChildren();
            for (int index = 0; index < children.size();) {
                NormalForm first = children.get(index);
                TemporalOp operation = first.getTemporalOp();
                if (isBinaryLeft(operation)) {
                    if (index + 1 >= children.size()
                            || !isMatchingBinaryRight(operation, children.get(index + 1).getTemporalOp())) {
                        throw new IllegalStateException(
                                "Malformed binary temporal phase pair at index " + index);
                    }
                    TypedInvocation left = buildPhase(
                            first, context, new LinkedHashMap<>(bindings));
                    TypedInvocation right = buildPhase(
                            children.get(index + 1), context, new LinkedHashMap<>(bindings));
                    result.put(
                            temporalReference(index, 2),
                            temporalNode(binaryBase(operation), context, List.of(left, right)));
                    index += 2;
                } else {
                    TypedInvocation child = buildPhase(
                            first, context, new LinkedHashMap<>(bindings));
                    result.put(
                            temporalReference(index, 1),
                            temporalNode(operation.name(), context, Collections.singletonList(child)));
                    index++;
                }
            }
            return result;
        }

        private TypedInvocation temporalNode(
                String operation,
                TypedSlotContext context,
                List<TypedInvocation> children) {
            List<PortSchema> schemas = new ArrayList<>(children.size());
            List<PortValue> ports = new ArrayList<>(children.size());
            for (TypedInvocation child : children) {
                schemas.add(new OnePortSchema(child.outputType()));
                ports.add(OnePort.invocation(context, child));
            }
            OperatorDeclaration declaration = OperatorDeclaration.monomorphic(
                    "ALLOY/TEMPORAL/" + operation,
                    schemas,
                    GraphType.BOOL,
                    Collections.emptyMap(),
                    null);
            return insert(TypedENode.construct(
                    declaration.instantiateMonomorphic(), context, ports));
        }

        private OnePort buildOperand(
                EGraphNode node,
                Map<String, String> slotNames,
                TypedSlotContext context,
                Map<String, TypedSlot> bindings,
                Map<String, TypedInvocation> temporalReferences) {
            if (node.getOpcode() == Opcode.END) {
                throw new IllegalStateException("END survived normal-form cleanup");
            }
            if (node.getOpcode() == Opcode.REF
                    && node.getSourceName() != null
                    && node.getSourceName().startsWith("temporal[")) {
                TypedInvocation temporal = temporalReferences.get(node.getSourceName());
                if (temporal == null) {
                    throw new IllegalStateException(
                            "Unresolved temporal reference " + node.getSourceName());
                }
                return OnePort.invocation(context, temporal);
            }
            if (node.getOpcode() == Opcode.VARIABLE) {
                String local = firstNonempty(node.getAlphaName(), node.getSourceName());
                String resolved = slotNames.getOrDefault(local, local);
                TypedSlot slot = bindings.get(resolved);
                if (slot == null) {
                    slot = bindings.get(node.getSourceName());
                }
                if (slot == null) {
                    throw new IllegalStateException(
                            "Unbound normalized variable " + local + " in " + node.getOpcode());
                }
                return OnePort.slot(context, slot);
            }
            if (isLocalBinder(node)) {
                return OnePort.invocation(
                        context,
                        buildLocalBinder(node, slotNames, context, bindings, temporalReferences));
            }

            InvocationKey key = new InvocationKey(
                    node.getEClass().getId(), slotNames, context, semanticHead(node));
            TypedInvocation remembered = memo.get(key);
            if (remembered != null) {
                return OnePort.invocation(context, remembered);
            }
            if (!active.add(key)) {
                throw new IllegalStateException(
                        "Normalized source contains a recursive e-class invocation at " + semanticHead(node));
            }
            try {
                List<OnePort> operands = new ArrayList<>();
                if (node.isFlexibleArity()) {
                    for (EClassRef child : node.getChildClasses()) {
                        collectFlatOperands(
                                node,
                                child,
                                slotNames,
                                context,
                                bindings,
                                temporalReferences,
                                operands,
                                new HashSet<>());
                    }
                } else {
                    for (EClassRef child : node.getChildClasses()) {
                        operands.add(buildChildOperand(
                                child, slotNames, context, bindings, temporalReferences));
                    }
                }
                TypedENode typed = constructNode(node, context, operands);
                TypedInvocation invocation = insert(typed);
                memo.put(key, invocation);
                return OnePort.invocation(context, invocation);
            } finally {
                active.remove(key);
            }
        }

        private OnePort buildChildOperand(
                EClassRef child,
                Map<String, String> outerNames,
                TypedSlotContext context,
                Map<String, TypedSlot> bindings,
                Map<String, TypedInvocation> temporalReferences) {
            EClassRef canonical = child.canonical();
            return buildOperand(
                    canonical.getEClass().getRepresentative(),
                    composeSlotNames(canonical.getSlotMap(), outerNames),
                    context,
                    bindings,
                    temporalReferences);
        }

        private void collectFlatOperands(
                EGraphNode parent,
                EClassRef child,
                Map<String, String> outerNames,
                TypedSlotContext context,
                Map<String, TypedSlot> bindings,
                Map<String, TypedInvocation> temporalReferences,
                List<OnePort> output,
                Set<Integer> flattening) {
            EClassRef canonical = child.canonical();
            EGraphNode representative = canonical.getEClass().getRepresentative();
            Map<String, String> names = composeSlotNames(
                    canonical.getSlotMap(), outerNames);
            if (representative.getOpcode() == parent.getOpcode()
                    && representative.isFlexibleArity()
                    && semanticHead(representative).equals(semanticHead(parent))
                    && flattening.add(canonical.getEClass().getId())) {
                try {
                    for (EClassRef grandchild : representative.getChildClasses()) {
                        collectFlatOperands(
                                parent,
                                grandchild,
                                names,
                                context,
                                bindings,
                                temporalReferences,
                                output,
                                flattening);
                    }
                    return;
                } finally {
                    flattening.remove(canonical.getEClass().getId());
                }
            }
            output.add(buildOperand(
                    representative, names, context, bindings, temporalReferences));
        }

        private TypedENode constructNode(
                EGraphNode source,
                TypedSlotContext context,
                List<OnePort> operands) {
            GraphType output = outputType(source);
            List<OnePort> typedOperands = operands;
            if (!source.isFlexibleArity() && source.isOrderInsensitive()) {
                if (!isCertifiedFixedCommutative(source.getOpcode())) {
                    throw new IllegalStateException(
                            "No Alloy signature certificate for fixed commutativity of "
                                    + source.getOpcode());
                }
                typedOperands = fixedCommutativeOperands(source, context, operands);
                if (typedOperands.isEmpty()) {
                    throw new IllegalStateException(
                            "A fixed commutative Alloy operator has no operands");
                }
                PortSchema element = typedOperands.get(0).schema();
                if (!typedOperands.stream().allMatch(
                        operand -> operand.schema().equals(element))) {
                    throw new IllegalStateException(
                            "A fixed commutative Alloy operator has heterogeneous operands");
                }
                BagPortSchema container = new BagPortSchema(
                        ContainerEmptiness.K_PLUS, element);
                String operator = semanticHead(source);
                ContainerLawDeclaration laws = certifiedLaws(container, operator);
                recordContainerLaws(operator, laws);
                OperatorDeclaration declaration = OperatorDeclaration.monomorphic(
                        operator,
                        Collections.singletonList(container),
                        output,
                        Collections.singletonMap(PortPath.at(0), laws),
                        null);
                return TypedENode.construct(
                        declaration.instantiateMonomorphic(),
                        context,
                        Collections.singletonList(
                                new BagPort(container, context, typedOperands)));
            }
            if (source.isFlexibleArity() && output.equals(REL)) {
                typedOperands = new ArrayList<>(operands.size());
                for (OnePort operand : operands) {
                    typedOperands.add(asRelationalOperand(operand, context));
                }
            }
            if (source.isFlexibleArity()
                    && typedOperands.stream().allMatch(
                            port -> port.schema().type().equals(output))) {
                PortSchema container = containerSchema(
                        source.getFlexibleArityKind(), new OnePortSchema(output));
                String operator = semanticHead(source);
                ContainerLawDeclaration laws = certifiedLaws(container, operator);
                recordContainerLaws(operator, laws);
                if (!typedOperands.isEmpty()) {
                    OperatorDeclaration declaration = OperatorDeclaration.monomorphic(
                            operator,
                            Collections.singletonList(container),
                            output,
                            Collections.singletonMap(PortPath.at(0), laws),
                            0);
                    InstantiatedOperator instantiated = declaration.instantiateMonomorphic();
                    List<FlatInput> leaves = new ArrayList<>(typedOperands.size());
                    for (OnePort operand : typedOperands) {
                        leaves.add(new FlatLeaf(operand));
                    }
                    FlatApplication application = new FlatApplication(
                            instantiated, context, leaves);
                    return TypedENode.flatConstruct(application, this::insert);
                }
            }

            List<PortSchema> schemas = new ArrayList<>(typedOperands.size());
            List<PortValue> ports = new ArrayList<>(typedOperands.size());
            for (OnePort operand : typedOperands) {
                schemas.add(operand.schema());
                ports.add(operand);
            }
            OperatorDeclaration declaration = OperatorDeclaration.monomorphic(
                    semanticHead(source), schemas, output, Collections.emptyMap(), null);
            return TypedENode.construct(
                    declaration.instantiateMonomorphic(), context, ports);
        }

        private List<OnePort> fixedCommutativeOperands(
                EGraphNode source,
                TypedSlotContext context,
                List<OnePort> operands) {
            if (source.getOpcode() != Opcode.EQUALS
                    && source.getOpcode() != Opcode.NOT_EQUALS) {
                return operands;
            }
            List<OnePort> relational = new ArrayList<>(operands.size());
            for (OnePort operand : operands) {
                relational.add(asRelationalOperand(operand, context));
            }
            return relational;
        }

        private static boolean isCertifiedFixedCommutative(Opcode opcode) {
            return opcode == Opcode.IFF
                    || opcode == Opcode.EQUALS
                    || opcode == Opcode.NOT_EQUALS;
        }

        private void recordContainerLaws(
                String operator,
                ContainerLawDeclaration laws) {
            List<ContainerLawDeclaration> declarations = certifiedContainerLaws
                    .computeIfAbsent(operator, ignored -> new ArrayList<>());
            for (ContainerLawDeclaration existing : declarations) {
                if (existing.kind() == laws.kind()) {
                    return;
                }
            }
            declarations.add(laws);
        }

        private OnePort asRelationalOperand(OnePort operand, TypedSlotContext context) {
            if (operand.schema().type().equals(REL)) {
                return operand;
            }
            TypedInvocation invocation = relationalCoercions.get(operand);
            if (invocation == null) {
                invocation = insert(fixedNode(
                        "ALLOY/RELATIONAL-VARIABLE",
                        REL,
                        context,
                        Collections.singletonList(operand)));
                relationalCoercions.put(operand, invocation);
            } else if (!invocation.callerContext().equals(context)) {
                throw new IllegalStateException("Relational coercion key lost its caller context");
            }
            return OnePort.invocation(context, invocation);
        }

        private TypedInvocation buildLocalBinder(
                EGraphNode source,
                Map<String, String> outerNames,
                TypedSlotContext context,
                Map<String, TypedSlot> bindings,
                Map<String, TypedInvocation> temporalReferences) {
            List<LocalCoordinate> locals = new ArrayList<>();
            int nextDisjointnessClass = 1;
            for (EClassRef childRef : source.getChildClasses()) {
                EClassRef canonical = childRef.canonical();
                EGraphNode child = canonical.getEClass().getRepresentative();
                if (!isRelDecl(child.getOpcode())) {
                    continue;
                }
                Map<String, String> declarationNames = composeSlotNames(
                        canonical.getSlotMap(), outerNames);
                List<EGraphNode> declarationChildren = child.getChildren();
                EGraphNode domain = declarationChildren.isEmpty() ? null : declarationChildren.get(0);
                StructuralKey domainKey = domainKey(domain, declarationNames, locals);
                String multiplicity = domainMultiplicity(domain);
                int disjointnessClass = isDisjointDecl(child.getOpcode())
                        ? nextDisjointnessClass++
                        : BinderCoordinateDescriptor.NO_DISJOINTNESS_CLASS;
                for (int index = 1; index < declarationChildren.size(); index++) {
                    EGraphNode variable = declarationChildren.get(index);
                    if (variable.getOpcode() != Opcode.VARIABLE) {
                        continue;
                    }
                    String localName = firstNonempty(variable.getAlphaName(), variable.getSourceName());
                    String resolved = declarationNames.getOrDefault(localName, localName);
                    locals.add(new LocalCoordinate(
                            resolved,
                            domainKey,
                            source.getOpcode().name(),
                            multiplicity,
                            disjointnessClass,
                            bindingType(variable)));
                }
            }
            BinderPlan plan = localBinderPlan(locals, context);
            if (localBinderDescriptors.put(source, plan.descriptor) != null) {
                throw new IllegalStateException(
                        "A local matrix binder received two certified descriptors");
            }
            Map<String, Integer> sourceCoordinates = new LinkedHashMap<>();
            for (int index = 0; index < locals.size(); index++) {
                sourceCoordinates.put(
                        locals.get(index).name,
                        plan.sourceToCoordinate.get(index));
            }
            if (localBinderSourceCoordinates.put(source, sourceCoordinates) != null) {
                throw new IllegalStateException(
                        "A local matrix binder received two source-coordinate maps");
            }
            TypedSlotContext bodyContext = context.union(plan.occurrence.codomain());
            Map<String, TypedSlot> bodyBindings = new LinkedHashMap<>(bindings);
            for (int index = 0; index < locals.size(); index++) {
                TypedSlot occurrence = plan.occurrence.apply(
                        plan.coordinates.get(index).canonicalSlot());
                bodyBindings.put(locals.get(index).name, occurrence);
            }

            List<OnePort> bodies = new ArrayList<>();
            for (EClassRef childRef : source.getChildClasses()) {
                EClassRef canonical = childRef.canonical();
                EGraphNode child = canonical.getEClass().getRepresentative();
                if (isRelDecl(child.getOpcode())) {
                    continue;
                }
                bodies.add(buildOperand(
                        child,
                        composeSlotNames(canonical.getSlotMap(), outerNames),
                        bodyContext,
                        bodyBindings,
                        temporalReferences));
            }
            TypedInvocation body = bodies.isEmpty()
                    ? insert(constantNode("true", GraphType.BOOL, bodyContext))
                    : bodies.size() == 1
                            ? asInvocation(bodies.get(0), bodyContext, "local-binder-body")
                            : insert(fixedNode(
                                    "ALLOY/LOCAL-BODY/" + source.getOpcode(),
                                    outputType(source),
                                    bodyContext,
                                    bodies));
            BindBlockPortSchema schema = new BindBlockPortSchema(
                    plan.descriptor, new OnePortSchema(body.outputType()));
            BindBlockPort block = new BindBlockPort(
                    schema,
                    context,
                    plan.occurrence,
                    OnePort.invocation(bodyContext, body));
            OperatorDeclaration declaration = OperatorDeclaration.monomorphic(
                    "ALLOY/LOCAL-BIND/" + source.getOpcode(),
                    Collections.singletonList(schema),
                    outputType(source),
                    Collections.emptyMap(),
                    null);
            return insert(TypedENode.construct(
                    declaration.instantiateMonomorphic(),
                    context,
                    Collections.singletonList(block)));
        }

        private BinderPlan binderPlan(List<QuantiVar> variables, TypedSlotContext ambient) {
            List<BindingPayload> payloads = new ArrayList<>(variables.size());
            int exchangeClass = -1;
            QuantiVar previous = null;
            for (QuantiVar variable : variables) {
                if (previous == null || !sameExchangeRun(previous, variable)) {
                    exchangeClass++;
                }
                payloads.add(new BindingPayload(
                        variable.getQuantifier().name(),
                        variable.getCardinality().name(),
                        variable.getDisjointnessClass() > 0
                                ? variable.getDisjointnessClass()
                                : BinderCoordinateDescriptor.NO_DISJOINTNESS_CLASS,
                        StructuralKey.of(
                                "alloy-binder-domain",
                                List.of(normalizeType(variable.getCarrierTypeName())),
                                Collections.emptyList()),
                        bindingType(variable),
                        exchangeClass));
                previous = variable;
            }
            return binderPlan(variables, payloads, ambient, true);
        }

        private static boolean sameExchangeRun(QuantiVar left, QuantiVar right) {
            if (left.getQuantifier() != right.getQuantifier()) {
                return false;
            }
            if (left.getQuantifier() == QuantiVar.Quantifier.ALL
                    || left.getQuantifier() == QuantiVar.Quantifier.SOME) {
                return true;
            }
            return left.getBindingPath().equals(right.getBindingPath());
        }

        private BinderPlan localBinderPlan(
                List<LocalCoordinate> locals,
                TypedSlotContext ambient) {
            List<QuantiVar> variables = new ArrayList<>(locals.size());
            List<BindingPayload> payloads = new ArrayList<>(locals.size());
            for (int index = 0; index < locals.size(); index++) {
                LocalCoordinate local = locals.get(index);
                QuantiVar placeholder = new QuantiVar(index, local.name, "", local.type.toString());
                variables.add(placeholder);
                payloads.add(new BindingPayload(
                        local.quantifier,
                        local.multiplicity,
                        local.disjointnessClass,
                        local.domain,
                        local.type,
                        0));
            }
            return binderPlan(variables, payloads, ambient, false);
        }

        private BinderPlan binderPlan(
                List<QuantiVar> variables,
                List<BindingPayload> payloads,
                TypedSlotContext ambient,
                boolean canonicalizeIndependentOrder) {
            if (variables.size() != payloads.size()) {
                throw new IllegalArgumentException(
                        "Binder variables and payloads must have equal arity");
            }
            List<Integer> order = new ArrayList<>(variables.size());
            for (int index = 0; index < variables.size(); index++) {
                order.add(index);
            }
            if (canonicalizeIndependentOrder) {
                order.sort((left, right) -> compareBindingPayloads(
                        payloads.get(left), payloads.get(right), left, right));
            }
            List<QuantiVar> orderedVariables = new ArrayList<>(variables.size());
            List<BindingPayload> orderedPayloads = new ArrayList<>(payloads.size());
            List<Integer> sourceToCoordinate = new ArrayList<>(
                    Collections.nCopies(variables.size(), -1));
            for (int coordinate = 0; coordinate < order.size(); coordinate++) {
                int source = order.get(coordinate);
                orderedVariables.add(variables.get(source));
                orderedPayloads.add(payloads.get(source));
                sourceToCoordinate.set(source, coordinate);
            }

            Map<GraphType, Integer> ordinals = new TreeMap<>();
            List<BinderCoordinateDescriptor> coordinates = new ArrayList<>(variables.size());
            for (BindingPayload payload : orderedPayloads) {
                int ordinal = ordinals.getOrDefault(payload.type, 0);
                ordinals.put(payload.type, ordinal + 1);
                coordinates.add(new BinderCoordinateDescriptor(
                        TypedSlot.canonicalBound(payload.type, ordinal),
                        payload.domain,
                        payload.quantifier,
                        payload.multiplicity,
                        payload.disjointnessClass,
                        payload.exchangeClass,
                        TypedSlotContext.empty()));
            }
            TypedSlotContext descriptorContext = TypedSlotContext.of(
                    coordinates.stream()
                            .map(BinderCoordinateDescriptor::canonicalSlot)
                            .toList());
            List<BinderAutomorphismCertificate> certificates = new ArrayList<>();
            int certificateOrdinal = 0;
            Map<BindingPayload, Integer> previousByPayload = new LinkedHashMap<>();
            for (int index = 0; index < orderedPayloads.size(); index++) {
                Integer previousIndex = previousByPayload.put(
                        orderedPayloads.get(index), index);
                if (previousIndex == null) {
                    continue;
                }
                Map<TypedSlot, TypedSlot> swap = new LinkedHashMap<>();
                for (TypedSlot slot : descriptorContext) {
                    swap.put(slot, slot);
                }
                TypedSlot left = coordinates.get(previousIndex).canonicalSlot();
                TypedSlot right = coordinates.get(index).canonicalSlot();
                swap.put(left, right);
                swap.put(right, left);
                TypedPermutation permutation = TypedPermutation.of(descriptorContext, swap);
                certificates.add(new BinderAutomorphismCertificate(
                        coordinates,
                        permutation,
                        CertificateOrigin.binderAutomorphism(
                                SIGNATURE_VERSION,
                                "alloy-binder-block",
                                certificateOrdinal++)));
            }
            BinderBlockDescriptor descriptor = BinderBlockDescriptor.certified(
                    coordinates, certificates);
            return new BinderPlan(
                    orderedVariables,
                    coordinates,
                    descriptor,
                    descriptor.freshOccurrenceRenaming(ambient),
                    sourceToCoordinate);
        }

        private static int compareBindingPayloads(
                BindingPayload left,
                BindingPayload right,
                int leftSource,
                int rightSource) {
            int comparison = Integer.compare(left.exchangeClass, right.exchangeClass);
            if (comparison != 0) {
                return comparison;
            }
            comparison = left.type.compareTo(right.type);
            if (comparison != 0) {
                return comparison;
            }
            comparison = left.domain.compareTo(right.domain);
            if (comparison != 0) {
                return comparison;
            }
            comparison = left.quantifier.compareTo(right.quantifier);
            if (comparison != 0) {
                return comparison;
            }
            comparison = left.multiplicity.compareTo(right.multiplicity);
            if (comparison != 0) {
                return comparison;
            }
            comparison = Integer.compare(
                    left.disjointnessClass, right.disjointnessClass);
            return comparison != 0
                    ? comparison
                    : Integer.compare(leftSource, rightSource);
        }

        private TypedInvocation asInvocation(
                OnePort value,
                TypedSlotContext context,
                String label) {
            if (value.leaf() instanceof is.fivefivefive.CanDis.theory.InvocationPortLeaf) {
                return ((is.fivefivefive.CanDis.theory.InvocationPortLeaf) value.leaf()).invocation();
            }
            return insert(fixedNode(
                    "ALLOY/VALUE/" + label,
                    value.schema().type(),
                    context,
                    Collections.singletonList(value)));
        }

        private TypedENode fixedNode(
                String head,
                GraphType output,
                TypedSlotContext context,
                List<OnePort> operands) {
            List<PortSchema> schemas = new ArrayList<>(operands.size());
            List<PortValue> ports = new ArrayList<>(operands.size());
            for (OnePort operand : operands) {
                schemas.add(operand.schema());
                ports.add(operand);
            }
            OperatorDeclaration declaration = OperatorDeclaration.monomorphic(
                    head, schemas, output, Collections.emptyMap(), null);
            return TypedENode.construct(
                    declaration.instantiateMonomorphic(), context, ports);
        }

        private TypedENode constantNode(
                String value,
                GraphType output,
                TypedSlotContext context) {
            OperatorDeclaration declaration = OperatorDeclaration.monomorphic(
                    "ALLOY/CONSTANT/" + value,
                    Collections.emptyList(),
                    output,
                    Collections.emptyMap(),
                    null);
            return TypedENode.construct(
                    declaration.instantiateMonomorphic(), context, Collections.emptyList());
        }

        private TypedInvocation insert(TypedENode node) {
            TypedSlotContext callerContext = node.context();
            TypedENode exact = node.inExactSupportContext();
            ensureQuiescent();
            CertifiedInsertionResult insertion = graph.insertNode(
                    exact, graph.coherentWitnessFamily());
            ensureQuiescent();
            TypedInvocation normalized = graph.findWithProvenance(
                    insertion.returnedInvocation()).leaderInvocation();
            if (!normalized.callerContext().equals(callerContext)) {
                normalized = normalized.act(TypedEmbedding.inclusion(
                        normalized.callerContext(), callerContext));
            }
            return normalized;
        }

        private void ensureQuiescent() {
            if (graph.status() == GraphStatus.DIRTY) {
                graph.rebuild();
                rebuilds++;
            }
            if (graph.status() != GraphStatus.QUIESCENT) {
                throw new IllegalStateException(
                        "Exact Alloy graph did not reach quiescence: " + graph.status());
            }
        }
    }

    private static PortSchema containerSchema(
            FlexibleArityKind kind,
            OnePortSchema element) {
        switch (kind) {
            case SET:
                return new SetPortSchema(ContainerEmptiness.K_PLUS, element);
            case BAG:
                return new BagPortSchema(ContainerEmptiness.K_PLUS, element);
            case SEQUENCE:
                return new SeqPortSchema(ContainerEmptiness.K_PLUS, element);
            default:
                throw new IllegalArgumentException("FIXED is not a flexible port kind");
        }
    }

    private static ContainerLawDeclaration certifiedLaws(
            PortSchema schema,
            String operator) {
        List<ContainerLawCertificate> certificates = new ArrayList<>();
        int ordinal = 0;
        certificates.add(new ContainerLawCertificate(
                schema,
                ContainerLawCertificate.Law.ASSOCIATIVITY,
                CertificateOrigin.containerLaw(SIGNATURE_VERSION, operator, ordinal++)));
        if (schema instanceof BagPortSchema || schema instanceof SetPortSchema) {
            certificates.add(new ContainerLawCertificate(
                    schema,
                    ContainerLawCertificate.Law.COMMUTATIVITY,
                    CertificateOrigin.containerLaw(SIGNATURE_VERSION, operator, ordinal++)));
        }
        if (schema instanceof SetPortSchema) {
            certificates.add(new ContainerLawCertificate(
                    schema,
                    ContainerLawCertificate.Law.IDEMPOTENCY,
                    CertificateOrigin.containerLaw(SIGNATURE_VERSION, operator, ordinal)));
        }
        return ContainerLawDeclaration.certified(schema, certificates);
    }

    private static GraphType outputType(EGraphNode node) {
        if (node.getMetatype() == Metatype.BOOLEAN) {
            return GraphType.BOOL;
        }
        String type = normalizeType(node.getSourceType());
        if ("int".equalsIgnoreCase(type) || node.getOpcode() == Opcode.CARDINALITY
                || node.getOpcode() == Opcode.CAST2INT) {
            return GraphType.INT;
        }
        return REL;
    }

    private static GraphType bindingType(QuantiVar variable) {
        String type = normalizeType(variable.getTypeName());
        return bindingType(type);
    }

    private static GraphType bindingType(EGraphNode variable) {
        return bindingType(normalizeType(variable.getSourceType()));
    }

    private static GraphType bindingType(String type) {
        String normalized = type.startsWith("VAR_") ? type.substring(4) : type;
        if ("int".equalsIgnoreCase(normalized)) {
            return GraphType.INT;
        }
        return GraphType.constructor(
                "AlloyCarrier",
                Collections.singletonList(GraphType.constructor(normalized)));
    }

    private static String semanticHead(EGraphNode node) {
        StringBuilder head = new StringBuilder("ALLOY/").append(node.getOpcode());
        switch (node.getOpcode()) {
            case CONSTANT:
            case GLOBALBINDING:
            case CALL:
            case REF:
            case SHADOW:
                head.append('/').append(normalizeAtom(node.getSourceName()));
                break;
            default:
                break;
        }
        return head.toString();
    }

    private static String normalizeAtom(String value) {
        return value == null ? "" : value.replace("this/", "").replaceAll("\\s+", "").trim();
    }

    private static String normalizeType(String value) {
        String normalized = normalizeAtom(value);
        return normalized.isEmpty() ? "univ" : normalized;
    }

    private static void registerBinding(
            Map<String, TypedSlot> bindings,
            QuantiVar variable,
            TypedSlot slot) {
        putBinding(bindings, variable.getName(), slot);
        for (String alias : variable.getOriginalNames()) {
            putBinding(bindings, alias, slot);
        }
        putBinding(bindings, variable.getDeBruijnKey(), slot);
    }

    private static void putBinding(
            Map<String, TypedSlot> bindings,
            String name,
            TypedSlot slot) {
        if (name == null || name.isEmpty()) {
            return;
        }
        bindings.put(name, slot);
    }

    private static boolean hasBinding(
            Map<String, TypedSlot> bindings,
            QuantiVar variable) {
        if (bindings.containsKey(variable.getName())
                || bindings.containsKey(variable.getDeBruijnKey())) {
            return true;
        }
        for (String alias : variable.getOriginalNames()) {
            if (bindings.containsKey(alias)) {
                return true;
            }
        }
        return false;
    }

    private static Map<String, String> identitySlotNames(EGraphNode node) {
        Map<String, String> result = new LinkedHashMap<>();
        for (String slot : node.getEClass().getSlots()) {
            result.put(slot, slot);
        }
        return result;
    }

    private static Map<String, String> composeSlotNames(
            Map<String, String> childToParent,
            Map<String, String> parentToAmbient) {
        Map<String, String> result = new LinkedHashMap<>();
        List<String> keys = new ArrayList<>(childToParent.keySet());
        Collections.sort(keys);
        for (String child : keys) {
            String parent = childToParent.get(child);
            result.put(child, parentToAmbient.getOrDefault(parent, parent));
        }
        return result;
    }

    private static boolean isLocalBinder(EGraphNode node) {
        if (node.getOpcode() != Opcode.SUM && node.getOpcode() != Opcode.COMPREHENSION
                && node.getOpcode() != Opcode.FORALL && node.getOpcode() != Opcode.EXISTS
                && node.getOpcode() != Opcode.NO && node.getOpcode() != Opcode.ONE
                && node.getOpcode() != Opcode.LONE) {
            return false;
        }
        for (EGraphNode child : node.getChildren()) {
            if (isRelDecl(child.getOpcode())) {
                return true;
            }
        }
        return false;
    }

    private static boolean isRelDecl(Opcode opcode) {
        return opcode == Opcode.GENERICRELDECL || opcode == Opcode.DISJ
                || opcode == Opcode.VAR || opcode == Opcode.DISJVAR;
    }

    private static boolean isDisjointDecl(Opcode opcode) {
        return opcode == Opcode.DISJ || opcode == Opcode.DISJVAR;
    }

    private static StructuralKey domainKey(
            EGraphNode domain,
            Map<String, String> names,
            List<LocalCoordinate> preceding) {
        if (domain == null) {
            return StructuralKey.leaf("alloy-local-domain", "univ");
        }
        if (domain.getOpcode() == Opcode.VARIABLE) {
            String local = firstNonempty(domain.getAlphaName(), domain.getSourceName());
            String resolved = names.getOrDefault(local, local);
            for (int index = 0; index < preceding.size(); index++) {
                if (preceding.get(index).name.equals(resolved)) {
                    return StructuralKey.leaf("alloy-local-domain-bound", Integer.toString(index));
                }
            }
            return StructuralKey.leaf("alloy-local-domain-free", normalizeAtom(resolved));
        }
        List<StructuralKey> children = new ArrayList<>();
        for (EGraphNode child : domain.getChildren()) {
            children.add(domainKey(child, names, preceding));
        }
        if (domain.isOrderInsensitive()) {
            children.sort(Comparator.naturalOrder());
        }
        return StructuralKey.of(
                "alloy-local-domain-node",
                List.of(semanticHead(domain), normalizeAtom(domain.getSourceName())),
                children);
    }

    private static String domainMultiplicity(EGraphNode domain) {
        if (domain == null) {
            return QuantiVar.Cardinality.SET.name();
        }
        switch (domain.getOpcode()) {
            case SOME:
                return QuantiVar.Cardinality.SOME.name();
            case ONE:
                return QuantiVar.Cardinality.ONE.name();
            case LONE:
                return QuantiVar.Cardinality.LONE.name();
            case EXACTLY:
                return QuantiVar.Cardinality.EXACTLY.name();
            default:
                return QuantiVar.Cardinality.SET.name();
        }
    }

    private static boolean isBinaryLeft(TemporalOp operation) {
        return operation == TemporalOp.UNTILL || operation == TemporalOp.RELEASESL
                || operation == TemporalOp.SINCEL || operation == TemporalOp.TRIGGEREDL;
    }

    private static boolean isMatchingBinaryRight(TemporalOp left, TemporalOp right) {
        return left == TemporalOp.UNTILL && right == TemporalOp.UNTILR
                || left == TemporalOp.RELEASESL && right == TemporalOp.RELEASESR
                || left == TemporalOp.SINCEL && right == TemporalOp.SINCER
                || left == TemporalOp.TRIGGEREDL && right == TemporalOp.TRIGGEREDR;
    }

    private static String binaryBase(TemporalOp operation) {
        switch (operation) {
            case UNTILL:
                return "UNTIL";
            case RELEASESL:
                return "RELEASES";
            case SINCEL:
                return "SINCE";
            case TRIGGEREDL:
                return "TRIGGERED";
            default:
                throw new IllegalArgumentException("Not a binary-left temporal phase: " + operation);
        }
    }

    private static String temporalReference(int index, int arity) {
        return "temporal[" + index + ":" + arity + "]";
    }

    private static String firstNonempty(String first, String second) {
        return first != null && !first.isEmpty() ? first : second;
    }

    private static final class BinderPlan {
        private final List<QuantiVar> variables;
        private final List<BinderCoordinateDescriptor> coordinates;
        private final BinderBlockDescriptor descriptor;
        private final TypedRenaming occurrence;
        private final List<Integer> sourceToCoordinate;

        private BinderPlan(
                List<QuantiVar> variables,
                List<BinderCoordinateDescriptor> coordinates,
                BinderBlockDescriptor descriptor,
                TypedRenaming occurrence,
                List<Integer> sourceToCoordinate) {
            this.variables = Collections.unmodifiableList(new ArrayList<>(variables));
            this.coordinates = Collections.unmodifiableList(new ArrayList<>(coordinates));
            this.descriptor = descriptor;
            this.occurrence = occurrence;
            this.sourceToCoordinate = Collections.unmodifiableList(
                    new ArrayList<>(sourceToCoordinate));
        }
    }

    private static final class BindingPayload {
        private final String quantifier;
        private final String multiplicity;
        private final int disjointnessClass;
        private final StructuralKey domain;
        private final GraphType type;
        private final int exchangeClass;

        private BindingPayload(
                String quantifier,
                String multiplicity,
                int disjointnessClass,
                StructuralKey domain,
                GraphType type,
                int exchangeClass) {
            this.quantifier = quantifier;
            this.multiplicity = multiplicity;
            this.disjointnessClass = disjointnessClass;
            this.domain = domain;
            this.type = type;
            this.exchangeClass = exchangeClass;
        }

        @Override
        public boolean equals(Object other) {
            if (!(other instanceof BindingPayload)) {
                return false;
            }
            BindingPayload payload = (BindingPayload) other;
            return quantifier.equals(payload.quantifier)
                    && multiplicity.equals(payload.multiplicity)
                    && disjointnessClass == payload.disjointnessClass
                    && exchangeClass == payload.exchangeClass
                    && domain.equals(payload.domain)
                    && type.equals(payload.type);
        }

        @Override
        public int hashCode() {
            return Objects.hash(
                    quantifier, multiplicity, disjointnessClass,
                    domain, type, exchangeClass);
        }
    }

    private static final class LocalCoordinate {
        private final String name;
        private final StructuralKey domain;
        private final String quantifier;
        private final String multiplicity;
        private final int disjointnessClass;
        private final GraphType type;

        private LocalCoordinate(
                String name,
                StructuralKey domain,
                String quantifier,
                String multiplicity,
                int disjointnessClass,
                GraphType type) {
            this.name = name;
            this.domain = domain;
            this.quantifier = quantifier;
            this.multiplicity = multiplicity;
            this.disjointnessClass = disjointnessClass;
            this.type = type;
        }
    }

    private static final class InvocationKey {
        private final int eclass;
        private final Map<String, String> slots;
        private final TypedSlotContext context;
        private final String head;

        private InvocationKey(
                int eclass,
                Map<String, String> slots,
                TypedSlotContext context,
                String head) {
            this.eclass = eclass;
            this.slots = Collections.unmodifiableMap(new TreeMap<>(slots));
            this.context = context;
            this.head = head;
        }

        @Override
        public boolean equals(Object other) {
            if (!(other instanceof InvocationKey)) {
                return false;
            }
            InvocationKey key = (InvocationKey) other;
            return eclass == key.eclass
                    && slots.equals(key.slots)
                    && context.equals(key.context)
                    && head.equals(key.head);
        }

        @Override
        public int hashCode() {
            return Objects.hash(eclass, slots, context, head);
        }
    }
}
