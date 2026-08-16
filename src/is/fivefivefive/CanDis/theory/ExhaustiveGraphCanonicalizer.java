package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.NavigableMap;
import java.util.Objects;
import java.util.TreeMap;

/** Slow specification implementation that enumerates the complete finite orbit. */
public final class ExhaustiveGraphCanonicalizer implements TypedGraphCanonicalizer {
    public static final String VERSION = "canon-g-exhaustive-v1";
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
            TypedENode leaderNormalized = LeaderNormalizer.normalize(graph, node);
            requireLeaderNormalizationPreservesSupport(node, leaderNormalized);
            BestCandidate best = new BestCandidate();
            TypedSlotContext canonicalContext = leaderNormalized.support().canonicalFreeContext();
            TypedRenamingEnumerator.forEach(
                    canonicalContext,
                    leaderNormalized.support(),
                    witness -> enumerateForRenaming(
                            graph, leaderNormalized, canonicalContext, witness, best));
            CanonicalizationResult result = best.result(node);
            if (!result.verifyWitness(graph)) {
                throw new IllegalStateException(
                        "Exhaustive canon_G returned a witness that does not replay");
            }
            graph.checkInvariants();
            return result;
        }
    }

    private static void enumerateForRenaming(
            TypedSlottedPortEGraph graph,
            TypedENode node,
            TypedSlotContext canonicalContext,
            TypedRenaming witness,
            BestCandidate best) {
        TypedRenaming sourceToCanonical = witness.inverse();
        List<List<PortValue>> alternatives = new ArrayList<>(node.ports().size());
        for (PortValue port : node.ports()) {
            alternatives.add(enumeratePort(graph, port, sourceToCanonical));
        }
        enumerateNodeProducts(
                node,
                canonicalContext,
                alternatives,
                0,
                new ArrayList<>(),
                witness,
                best);
    }

    private static void enumerateNodeProducts(
            TypedENode source,
            TypedSlotContext canonicalContext,
            List<List<PortValue>> alternatives,
            int index,
            List<PortValue> selected,
            TypedRenaming witness,
            BestCandidate best) {
        if (index == alternatives.size()) {
            TypedENode candidate = source.rebuildCanonicalCandidate(
                    canonicalContext, selected);
            requireCanonicalSupport(candidate, canonicalContext);
            best.consider(CanonicalShape.of(candidate), witness);
            return;
        }
        for (PortValue value : alternatives.get(index)) {
            selected.add(value);
            enumerateNodeProducts(
                    source,
                    canonicalContext,
                    alternatives,
                    index + 1,
                    selected,
                    witness,
                    best);
            selected.remove(selected.size() - 1);
        }
    }

    private static List<PortValue> enumeratePort(
            TypedSlottedPortEGraph graph,
            PortValue port,
            TypedRenaming renaming) {
        if (!port.context().equals(renaming.source())) {
            throw new IllegalArgumentException(
                    "Canonical port renaming must start at the port context");
        }
        if (port instanceof OnePort) {
            return enumerateOne(graph, (OnePort) port, renaming);
        }
        if (port instanceof SeqPort) {
            SeqPort sequence = (SeqPort) port;
            return enumerateContainer(
                    graph,
                    sequence.elements(),
                    renaming,
                    values -> new SeqPort(
                            sequence.schema(), renaming.codomain(), values));
        }
        if (port instanceof BagPort) {
            BagPort bag = (BagPort) port;
            return enumerateContainer(
                    graph,
                    bag.occurrences(),
                    renaming,
                    values -> new BagPort(
                            bag.schema(), renaming.codomain(), values));
        }
        if (port instanceof SetPort) {
            SetPort set = (SetPort) port;
            return enumerateContainer(
                    graph,
                    set.elements(),
                    renaming,
                    values -> new SetPort(
                            set.schema(), renaming.codomain(), values));
        }
        BindPort binder = (BindPort) port;
        TypedSlot canonicalBound = CanonicalSlotAlphabet.fresh(
                binder.schema().boundType(),
                SlotAlphabet.CANONICAL_BOUND,
                renaming.codomain());
        TypedRenaming extended = renaming.disjointExtension(
                binder.boundSlot(), canonicalBound).asRenaming();
        NavigableMap<StructuralKey, PortValue> results = new TreeMap<>();
        for (PortValue body : enumeratePort(graph, binder.body(), extended)) {
            putUnique(
                    results,
                    new BindPort(
                            binder.schema(), renaming.codomain(), canonicalBound, body));
        }
        return immutableValues(results);
    }

    private static List<PortValue> enumerateOne(
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

        TypedInvocation invocation = ((InvocationPortLeaf) leaf).invocation();
        TypedFindResult find = graph.findForCanonicalization(invocation);
        TypedInvocation leader = find.leaderInvocation();
        TypedSymmetryGroup group = graph.eclass(leader.eclass().id()).symmetryGroup();
        NavigableMap<StructuralKey, PortValue> results = new TreeMap<>();
        for (TypedPermutation permutation : group.elements()) {
            TypedEmbedding embedding = permutation
                    .andThen(leader.embedding())
                    .andThen(renaming);
            putUnique(
                    results,
                    new OnePort(
                            port.schema(),
                            renaming.codomain(),
                            new InvocationPortLeaf(new TypedInvocation(
                                    leader.eclass(), embedding))));
        }
        return immutableValues(results);
    }

    private static List<PortValue> enumerateContainer(
            TypedSlottedPortEGraph graph,
            List<PortValue> source,
            TypedRenaming renaming,
            ContainerFactory factory) {
        List<List<PortValue>> alternatives = new ArrayList<>(source.size());
        for (PortValue element : source) {
            alternatives.add(enumeratePort(graph, element, renaming));
        }
        NavigableMap<StructuralKey, PortValue> results = new TreeMap<>();
        enumerateContainerProducts(
                alternatives, 0, new ArrayList<>(), factory, results);
        return immutableValues(results);
    }

    private static void enumerateContainerProducts(
            List<List<PortValue>> alternatives,
            int index,
            List<PortValue> selected,
            ContainerFactory factory,
            NavigableMap<StructuralKey, PortValue> results) {
        if (index == alternatives.size()) {
            putUnique(results, factory.create(new ArrayList<>(selected)));
            return;
        }
        for (PortValue value : alternatives.get(index)) {
            selected.add(value);
            enumerateContainerProducts(
                    alternatives, index + 1, selected, factory, results);
            selected.remove(selected.size() - 1);
        }
    }

    private static void putUnique(
            NavigableMap<StructuralKey, PortValue> target,
            PortValue value) {
        StructuralKey key = value.structuralKey();
        PortValue prior = target.putIfAbsent(key, value);
        if (prior != null && !prior.equals(value)) {
            throw new IllegalStateException(
                    "Structural key collision between unequal canonical ports");
        }
    }

    private static List<PortValue> immutableValues(
            NavigableMap<StructuralKey, PortValue> values) {
        return Collections.unmodifiableList(new ArrayList<>(values.values()));
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

    @Override
    public String version() {
        return VERSION;
    }

    private interface ContainerFactory {
        PortValue create(List<PortValue> values);
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
