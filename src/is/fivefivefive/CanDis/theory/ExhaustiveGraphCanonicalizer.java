package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.NavigableMap;
import java.util.Objects;
import java.util.TreeMap;

/** Slow independent specification implementation of quotient-first {@code canon_G}. */
public final class ExhaustiveGraphCanonicalizer implements TypedGraphCanonicalizer {
    public static final String VERSION = "canon-g-exhaustive-v2";
    private static final ExhaustiveGraphCanonicalizer INSTANCE =
            new ExhaustiveGraphCanonicalizer();

    private ExhaustiveGraphCanonicalizer() {
    }

    public static ExhaustiveGraphCanonicalizer instance() {
        return INSTANCE;
    }

    @Override
    public CanonicalizationResult canonicalize(
            TypedSlottedPortEGraph graph,
            TypedENode node) {
        Objects.requireNonNull(graph, "graph");
        Objects.requireNonNull(node, "node");
        synchronized (graph) {
            graph.requireQuiescentForCanonicalization();
            if (!node.context().equals(node.support())) {
                throw new IllegalArgumentException(
                        "canon_G requires a node whose context is its exact support");
            }
            LeaderKernelResult leaderKernel = graph.extractLeaderKernel(node);
            TypedENode kernel = leaderKernel.kernel();
            TypedSlotContext canonicalContext = kernel.context().canonicalFreeContext();
            BestCandidate best = new BestCandidate();
            TypedRenamingEnumerator.forEach(
                    canonicalContext,
                    kernel.context(),
                    witness -> enumerateFreeCandidate(
                            graph, kernel, canonicalContext, witness, best));
            CanonicalizationResult result = best.result(leaderKernel);
            if (!result.verifyWitness(graph)) {
                throw new IllegalStateException(
                        "Exhaustive canon_G returned a witness that does not replay");
            }
            graph.checkInvariants();
            return result;
        }
    }

    private static void enumerateFreeCandidate(
            TypedSlottedPortEGraph graph,
            TypedENode kernel,
            TypedSlotContext canonicalContext,
            TypedRenaming witness,
            BestCandidate best) {
        TypedRenaming sourceToCanonical = witness.inverse();
        List<PortValue> ports = new ArrayList<>(kernel.ports().size());
        for (PortValue port : kernel.ports()) {
            ports.add(referenceQuotient(graph, port, sourceToCanonical));
        }
        TypedENode candidate = kernel.rebuildCanonicalCandidate(
                canonicalContext, ports);
        if (!candidate.support().equals(canonicalContext)) {
            throw new CanonicalizationDomainException(
                    "Reference quotient changed exact kernel support from "
                            + canonicalContext + " to " + candidate.support());
        }
        best.consider(CanonicalShape.of(candidate), witness);
    }

    /**
     * Materializes every candidate in each local leader or binder orbit, then
     * returns its least member before the enclosing container is constructed.
     */
    private static PortValue referenceQuotient(
            TypedSlottedPortEGraph graph,
            PortValue port,
            TypedRenaming renaming) {
        if (!port.context().equals(renaming.source())) {
            throw new IllegalArgumentException(
                    "Reference port renaming must start at the port context");
        }
        if (port instanceof OnePort) {
            return least(enumerateOneOrbit(graph, (OnePort) port, renaming));
        }
        if (port instanceof SeqPort) {
            SeqPort sequence = (SeqPort) port;
            return new SeqPort(
                    sequence.schema(),
                    renaming.codomain(),
                    referenceElements(graph, sequence.elements(), renaming));
        }
        if (port instanceof BagPort) {
            BagPort bag = (BagPort) port;
            return new BagPort(
                    bag.schema(),
                    renaming.codomain(),
                    referenceElements(graph, bag.occurrences(), renaming));
        }
        if (port instanceof SetPort) {
            SetPort set = (SetPort) port;
            return new SetPort(
                    set.schema(),
                    renaming.codomain(),
                    referenceElements(graph, set.elements(), renaming));
        }
        if (port instanceof BindBlockPort) {
            return least(enumerateBlockOrbit(
                    graph, (BindBlockPort) port, renaming));
        }

        BindPort binder = (BindPort) port;
        TypedSlot canonicalBound = CanonicalSlotAlphabet.fresh(
                binder.schema().boundType(),
                SlotAlphabet.CANONICAL_BOUND,
                renaming.codomain());
        TypedRenaming bodyRenaming = renaming.disjointExtension(
                binder.boundSlot(), canonicalBound).asRenaming();
        return new BindPort(
                binder.schema(),
                renaming.codomain(),
                canonicalBound,
                referenceQuotient(graph, binder.body(), bodyRenaming));
    }

    private static List<PortValue> referenceElements(
            TypedSlottedPortEGraph graph,
            List<PortValue> source,
            TypedRenaming renaming) {
        List<PortValue> result = new ArrayList<>(source.size());
        for (PortValue value : source) {
            result.add(referenceQuotient(graph, value, renaming));
        }
        return result;
    }

    private static List<PortValue> enumerateOneOrbit(
            TypedSlottedPortEGraph graph,
            OnePort port,
            TypedRenaming renaming) {
        PortLeaf leaf = port.leaf();
        if (leaf instanceof SlotPortLeaf) {
            return Collections.singletonList(new OnePort(
                    port.schema(),
                    renaming.codomain(),
                    new SlotPortLeaf(renaming.apply(((SlotPortLeaf) leaf).slot()))));
        }

        TypedInvocation leader = ((InvocationPortLeaf) leaf).invocation();
        if (!graph.isLeader(leader.eclass().id())) {
            throw new IllegalStateException(
                    "Reference quotient requires leader-kernel invocations");
        }
        TypedSymmetryGroup group = graph.symmetryGroupForCanonicalization(
                leader.eclass());
        List<PortValue> orbit = new ArrayList<>(group.elements().size());
        for (TypedPermutation permutation : group.elements()) {
            TypedEmbedding embedding = permutation
                    .andThen(leader.embedding())
                    .andThen(renaming);
            orbit.add(new OnePort(
                    port.schema(),
                    renaming.codomain(),
                    new InvocationPortLeaf(new TypedInvocation(
                            leader.eclass(), embedding))));
        }
        return uniqueOrbit(orbit);
    }

    private static List<PortValue> enumerateBlockOrbit(
            TypedSlottedPortEGraph graph,
            BindBlockPort block,
            TypedRenaming freeRenaming) {
        BinderBlockDescriptor descriptor = block.schema().descriptor();
        TypedRenaming targetOccurrence = descriptor.freshOccurrenceRenaming(
                freeRenaming.codomain());
        BinderAutomorphismGroup automorphisms =
                graph.binderGroupForCanonicalization(descriptor);
        List<PortValue> orbit = new ArrayList<>(automorphisms.elements().size());
        for (TypedPermutation permutation : automorphisms.elements()) {
            TypedRenaming occurrenceRenaming = block.descriptorToOccurrence()
                    .inverse()
                    .andThen(permutation)
                    .andThen(targetOccurrence);
            TypedRenaming bodyRenaming = freeRenaming
                    .disjointUnion(occurrenceRenaming)
                    .asRenaming();
            PortValue body = referenceQuotient(graph, block.body(), bodyRenaming);
            orbit.add(new BindBlockPort(
                    block.schema(),
                    freeRenaming.codomain(),
                    targetOccurrence,
                    body));
        }
        return uniqueOrbit(orbit);
    }

    private static List<PortValue> uniqueOrbit(List<PortValue> source) {
        NavigableMap<StructuralKey, PortValue> unique = new TreeMap<>();
        for (PortValue value : source) {
            PortValue previous = unique.putIfAbsent(value.structuralKey(), value);
            if (previous != null && !previous.equals(value)) {
                throw new IllegalStateException(
                        "Structural key collision between unequal orbit members");
            }
        }
        return Collections.unmodifiableList(new ArrayList<>(unique.values()));
    }

    private static PortValue least(List<PortValue> orbit) {
        if (orbit.isEmpty()) {
            throw new IllegalStateException("A local quotient orbit must contain identity");
        }
        PortValue least = orbit.get(0);
        for (int index = 1; index < orbit.size(); index++) {
            PortValue candidate = orbit.get(index);
            int comparison = candidate.structuralKey().compareTo(least.structuralKey());
            if (comparison == 0 && !candidate.equals(least)) {
                throw new IllegalStateException(
                        "Structural key collision between unequal canonical ports");
            }
            if (comparison < 0) {
                least = candidate;
            }
        }
        return least;
    }

    @Override
    public String version() {
        return VERSION;
    }

    private static final class BestCandidate {
        private CanonicalShape shape;
        private TypedRenaming witness;

        void consider(CanonicalShape candidateShape, TypedRenaming candidateWitness) {
            if (shape == null) {
                shape = candidateShape;
                witness = candidateWitness;
                return;
            }
            int compared = candidateShape.compareTo(shape);
            if (compared == 0 && !candidateShape.equals(shape)) {
                throw new IllegalStateException(
                        "Structural key collision between unequal canonical shapes");
            }
            if (compared < 0
                    || (compared == 0
                            && TheoryKeys.embedding(candidateWitness)
                                    .compareTo(TheoryKeys.embedding(witness)) < 0)) {
                shape = candidateShape;
                witness = candidateWitness;
            }
        }

        CanonicalizationResult result(LeaderKernelResult leaderKernel) {
            if (shape == null || witness == null) {
                throw new IllegalStateException(
                        "No typed free-slot bijection was available to canon_G");
            }
            return new CanonicalizationResult(leaderKernel, shape, witness);
        }
    }
}
