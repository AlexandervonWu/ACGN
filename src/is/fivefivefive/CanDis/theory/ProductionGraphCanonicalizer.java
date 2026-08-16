package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/** Streaming production implementation of the exact finite canon_G orbit. */
public final class ProductionGraphCanonicalizer implements TypedGraphCanonicalizer {
    public static final String VERSION = "canon-g-production-v1";
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
            TypedENode leaderNormalized = LeaderNormalizer.normalize(graph, node);
            requireLeaderNormalizationPreservesSupport(node, leaderNormalized);
            BestCandidate best = new BestCandidate();
            TypedSlotContext canonicalContext = leaderNormalized.support().canonicalFreeContext();
            TypedRenamingEnumerator.forEach(
                    canonicalContext,
                    leaderNormalized.support(),
                    witness -> considerRenaming(
                            graph, leaderNormalized, canonicalContext, witness, best));
            CanonicalizationResult result = best.result(node);
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
            ports.add(canonicalPort(graph, port, sourceToCanonical));
        }
        TypedENode candidate = node.rebuildCanonicalCandidate(canonicalContext, ports);
        requireCanonicalSupport(candidate, canonicalContext);
        best.consider(CanonicalShape.of(candidate), witness);
    }

    private static void requireLeaderNormalizationPreservesSupport(
            TypedENode source,
            TypedENode normalized) {
        if (!source.support().equals(normalized.support())) {
            throw new CanonicalizationDomainException(
                    "Leader normalization changed exact support from "
                            + source.support() + " to " + normalized.support()
                            + "; Figure 4 cannot provide its required bijective witness");
        }
    }

    private static PortValue canonicalPort(
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
            List<PortValue> elements = canonicalElements(
                    graph, sequence.elements(), renaming);
            return new SeqPort(sequence.schema(), renaming.codomain(), elements);
        }
        if (port instanceof BagPort) {
            BagPort bag = (BagPort) port;
            List<PortValue> occurrences = canonicalElements(
                    graph, bag.occurrences(), renaming);
            return new BagPort(bag.schema(), renaming.codomain(), occurrences);
        }
        if (port instanceof SetPort) {
            SetPort set = (SetPort) port;
            List<PortValue> elements = canonicalElements(
                    graph, set.elements(), renaming);
            return new SetPort(set.schema(), renaming.codomain(), elements);
        }
        BindPort binder = (BindPort) port;
        TypedSlot canonicalBound = CanonicalSlotAlphabet.fresh(
                binder.schema().boundType(),
                SlotAlphabet.CANONICAL_BOUND,
                renaming.codomain());
        TypedRenaming extended = renaming.disjointExtension(
                binder.boundSlot(), canonicalBound).asRenaming();
        PortValue body = canonicalPort(graph, binder.body(), extended);
        return new BindPort(
                binder.schema(), renaming.codomain(), canonicalBound, body);
    }

    private static List<PortValue> canonicalElements(
            TypedSlottedPortEGraph graph,
            List<PortValue> elements,
            TypedRenaming renaming) {
        List<PortValue> result = new ArrayList<>(elements.size());
        for (PortValue element : elements) {
            result.add(canonicalPort(graph, element, renaming));
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

        TypedInvocation invocation = ((InvocationPortLeaf) leaf).invocation();
        TypedFindResult find = graph.findForCanonicalization(invocation);
        TypedInvocation leader = find.leaderInvocation();
        TypedSymmetryGroup group = graph.eclass(leader.eclass().id()).symmetryGroup();
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
            if (best == null
                    || candidate.structuralKey().compareTo(best.structuralKey()) < 0) {
                best = candidate;
            }
        }
        if (best == null) {
            throw new IllegalStateException("A typed symmetry group must contain identity");
        }
        return best;
    }

    private static void requireCanonicalSupport(
            TypedENode candidate,
            TypedSlotContext canonicalContext) {
        if (!candidate.support().equals(canonicalContext)) {
            throw new CanonicalizationDomainException(
                    "Leader normalization changed exact support from "
                            + canonicalContext + " to " + candidate.support()
                            + "; Figure 4 cannot provide its required bijective witness");
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

        CanonicalizationResult result(TypedENode source) {
            if (shape == null || witness == null) {
                throw new IllegalStateException(
                        "No typed free-slot bijection was available to canon_G");
            }
            return new CanonicalizationResult(source, shape, witness);
        }
    }
}
