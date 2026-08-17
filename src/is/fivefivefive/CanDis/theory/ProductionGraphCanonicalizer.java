package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/** Streaming production implementation of quotient-first {@code canon_G}. */
public final class ProductionGraphCanonicalizer implements TypedGraphCanonicalizer {
    public static final String VERSION = "canon-g-production-v2";
    private static final ProductionGraphCanonicalizer INSTANCE =
            new ProductionGraphCanonicalizer();

    private ProductionGraphCanonicalizer() {
    }

    public static ProductionGraphCanonicalizer instance() {
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
            requireExactSource(node);
            LeaderKernelResult leaderKernel = graph.extractLeaderKernel(node);
            TypedENode kernel = leaderKernel.kernel();
            BestCandidate best = new BestCandidate();
            TypedSlotContext canonicalContext = kernel.context().canonicalFreeContext();
            TypedRenamingEnumerator.forEach(
                    canonicalContext,
                    kernel.context(),
                    witness -> considerRenaming(
                            graph, kernel, canonicalContext, witness, best));
            CanonicalizationResult result = best.result(leaderKernel);
            if (!result.verifyWitness(graph)) {
                throw new IllegalStateException(
                        "Production canon_G returned a witness that does not replay");
            }
            graph.checkInvariants();
            return result;
        }
    }

    private static void requireExactSource(TypedENode node) {
        if (!node.context().equals(node.support())) {
            throw new IllegalArgumentException(
                    "canon_G requires a node whose context is its exact support");
        }
    }

    private static void considerRenaming(
            TypedSlottedPortEGraph graph,
            TypedENode node,
            TypedSlotContext canonicalContext,
            TypedRenaming witness,
            BestCandidate best) {
        TypedRenaming sourceToCanonical = witness.inverse();
        List<PortValue> ports = new ArrayList<>(node.ports().size());
        for (PortValue port : node.ports()) {
            ports.add(quotientPort(graph, port, sourceToCanonical));
        }
        TypedENode candidate = node.rebuildCanonicalCandidate(canonicalContext, ports);
        requireCanonicalSupport(candidate, canonicalContext);
        best.consider(CanonicalShape.of(candidate), witness);
    }

    private static PortValue quotientPort(
            TypedSlottedPortEGraph graph,
            PortValue port,
            TypedRenaming renaming) {
        if (!port.context().equals(renaming.source())) {
            throw new IllegalArgumentException(
                    "Canonical port renaming must start at the port context");
        }
        if (port instanceof OnePort) {
            return canonicalOne(graph, (OnePort) port, renaming);
        }
        if (port instanceof SeqPort) {
            SeqPort sequence = (SeqPort) port;
            List<PortValue> elements = quotientElements(
                    graph, sequence.elements(), renaming);
            return new SeqPort(sequence.schema(), renaming.codomain(), elements);
        }
        if (port instanceof BagPort) {
            BagPort bag = (BagPort) port;
            List<PortValue> occurrences = quotientElements(
                    graph, bag.occurrences(), renaming);
            return new BagPort(bag.schema(), renaming.codomain(), occurrences);
        }
        if (port instanceof SetPort) {
            SetPort set = (SetPort) port;
            List<PortValue> elements = quotientElements(
                    graph, set.elements(), renaming);
            return new SetPort(set.schema(), renaming.codomain(), elements);
        }
        if (port instanceof BindBlockPort) {
            return quotientBlock(graph, (BindBlockPort) port, renaming);
        }
        BindPort binder = (BindPort) port;
        TypedSlot canonicalBound = CanonicalSlotAlphabet.fresh(
                binder.schema().boundType(),
                SlotAlphabet.CANONICAL_BOUND,
                renaming.codomain());
        TypedRenaming extended = renaming.disjointExtension(
                binder.boundSlot(), canonicalBound).asRenaming();
        PortValue body = quotientPort(graph, binder.body(), extended);
        return new BindPort(
                binder.schema(), renaming.codomain(), canonicalBound, body);
    }

    private static BindBlockPort quotientBlock(
            TypedSlottedPortEGraph graph,
            BindBlockPort block,
            TypedRenaming freeRenaming) {
        BinderBlockDescriptor descriptor = block.schema().descriptor();
        TypedRenaming targetOccurrence = descriptor.freshOccurrenceRenaming(
                freeRenaming.codomain());
        BindBlockPort best = null;
        for (TypedPermutation permutation
                : graph.binderGroupForCanonicalization(descriptor).elements()) {
            TypedRenaming boundRenaming = block.descriptorToOccurrence()
                    .inverse()
                    .andThen(permutation)
                    .andThen(targetOccurrence);
            TypedRenaming bodyRenaming = freeRenaming
                    .disjointUnion(boundRenaming)
                    .asRenaming();
            PortValue body = quotientPort(graph, block.body(), bodyRenaming);
            BindBlockPort candidate = new BindBlockPort(
                    block.schema(),
                    freeRenaming.codomain(),
                    targetOccurrence,
                    body);
            best = least(best, candidate);
        }
        if (best == null) {
            throw new IllegalStateException(
                    "A binder automorphism group must contain identity");
        }
        return best;
    }

    private static List<PortValue> quotientElements(
            TypedSlottedPortEGraph graph,
            List<PortValue> elements,
            TypedRenaming renaming) {
        List<PortValue> result = new ArrayList<>(elements.size());
        for (PortValue element : elements) {
            result.add(quotientPort(graph, element, renaming));
        }
        return result;
    }

    private static OnePort canonicalOne(
            TypedSlottedPortEGraph graph,
            OnePort port,
            TypedRenaming renaming) {
        PortLeaf leaf = port.leaf();
        if (leaf instanceof SlotPortLeaf) {
            return new OnePort(
                    port.schema(),
                    renaming.codomain(),
                    new SlotPortLeaf(renaming.apply(((SlotPortLeaf) leaf).slot())));
        }

        TypedInvocation leader = ((InvocationPortLeaf) leaf).invocation();
        if (!graph.isLeader(leader.eclass().id())) {
            throw new IllegalStateException(
                    "Quotient normalization requires leader-kernel invocations");
        }
        TypedSymmetryGroup group = graph.symmetryGroupForCanonicalization(
                leader.eclass());
        OnePort best = null;
        for (TypedPermutation permutation : group.elements()) {
            TypedEmbedding embedding = permutation
                    .andThen(leader.embedding())
                    .andThen(renaming);
            OnePort candidate = new OnePort(
                    port.schema(),
                    renaming.codomain(),
                    new InvocationPortLeaf(new TypedInvocation(
                            leader.eclass(), embedding)));
            best = least(best, candidate);
        }
        if (best == null) {
            throw new IllegalStateException("A typed symmetry group must contain identity");
        }
        return best;
    }

    private static <T extends PortValue> T least(T current, T candidate) {
        if (current == null) {
            return candidate;
        }
        int comparison = candidate.structuralKey().compareTo(current.structuralKey());
        if (comparison == 0 && !candidate.equals(current)) {
            throw new IllegalStateException(
                    "Structural key collision between unequal canonical ports");
        }
        return comparison < 0 ? candidate : current;
    }

    private static void requireCanonicalSupport(
            TypedENode candidate,
            TypedSlotContext canonicalContext) {
        if (!candidate.support().equals(canonicalContext)) {
            throw new CanonicalizationDomainException(
                    "Quotient normalization changed exact kernel support from "
                            + canonicalContext + " to " + candidate.support());
        }
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
