package is.fivefivefive.CanDis.theory;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Deque;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.TreeMap;

/** Immutable finite typed permutation subgroup on one exposed e-class interface. */
public final class TypedSymmetryGroup {
    private final TypedSlotContext context;
    private final List<TypedPermutation> generators;
    private final List<TypedPermutation> elements;
    private final StructuralKey structuralKey;

    private TypedSymmetryGroup(
            TypedSlotContext context,
            List<? extends TypedPermutation> generators) {
        this.context = Objects.requireNonNull(context, "context");
        Objects.requireNonNull(generators, "generators");
        TypedPermutation identity = TypedPermutation.identity(context);
        Map<StructuralKey, TypedPermutation> normalizedGenerators = new TreeMap<>();
        for (TypedPermutation generator : generators) {
            TypedPermutation permutation = Objects.requireNonNull(generator, "generator");
            requireContext(permutation);
            if (!identity.equals(permutation)) {
                putUnique(normalizedGenerators, permutation);
            }
        }
        this.generators = Collections.unmodifiableList(
                new ArrayList<>(normalizedGenerators.values()));
        this.elements = close(identity, this.generators);

        List<StructuralKey> children = new ArrayList<>();
        children.add(TheoryKeys.context(context));
        for (TypedPermutation generator : this.generators) {
            children.add(StructuralKey.branch(
                    "symmetry-generator",
                    Collections.singletonList(TheoryKeys.embedding(generator))));
        }
        for (TypedPermutation element : elements) {
            children.add(StructuralKey.branch(
                    "symmetry-element",
                    Collections.singletonList(TheoryKeys.embedding(element))));
        }
        this.structuralKey = StructuralKey.branch("typed-symmetry-group", children);
    }

    public static TypedSymmetryGroup identity(TypedSlotContext context) {
        return new TypedSymmetryGroup(context, Collections.emptyList());
    }

    /* Phase F will be the sole caller after checking each generator certificate. */
    static TypedSymmetryGroup generatedForPhaseD(
            TypedSlotContext context,
            List<? extends TypedPermutation> generators) {
        return new TypedSymmetryGroup(context, generators);
    }

    private List<TypedPermutation> close(
            TypedPermutation identity,
            List<TypedPermutation> sourceGenerators) {
        Map<StructuralKey, TypedPermutation> closure = new TreeMap<>();
        Deque<TypedPermutation> pending = new ArrayDeque<>();
        putUnique(closure, identity);
        pending.add(identity);

        List<TypedPermutation> steps = new ArrayList<>(sourceGenerators.size() * 2);
        for (TypedPermutation generator : sourceGenerators) {
            steps.add(generator);
            steps.add(generator.inverse());
        }
        while (!pending.isEmpty()) {
            TypedPermutation current = pending.removeFirst();
            for (TypedPermutation step : steps) {
                TypedPermutation candidate = current.andThen(step);
                StructuralKey key = TheoryKeys.embedding(candidate);
                TypedPermutation prior = closure.putIfAbsent(key, candidate);
                if (prior == null) {
                    pending.addLast(candidate);
                } else if (!prior.equals(candidate)) {
                    throw new IllegalStateException(
                            "Structural key collision between unequal typed permutations");
                }
            }
        }
        return Collections.unmodifiableList(new ArrayList<>(closure.values()));
    }

    private void requireContext(TypedPermutation permutation) {
        if (!context.equals(permutation.source())
                || !context.equals(permutation.codomain())) {
            throw new IllegalArgumentException(
                    "Every symmetry must be a permutation of the declared interface");
        }
    }

    private static void putUnique(
            Map<StructuralKey, TypedPermutation> target,
            TypedPermutation permutation) {
        StructuralKey key = TheoryKeys.embedding(permutation);
        TypedPermutation prior = target.putIfAbsent(key, permutation);
        if (prior != null && !prior.equals(permutation)) {
            throw new IllegalStateException(
                    "Structural key collision between unequal typed permutations");
        }
    }

    public TypedSlotContext context() {
        return context;
    }

    public List<TypedPermutation> generators() {
        return generators;
    }

    public List<TypedPermutation> elements() {
        return elements;
    }

    public boolean contains(TypedPermutation permutation) {
        Objects.requireNonNull(permutation, "permutation");
        if (!context.equals(permutation.source())
                || !context.equals(permutation.codomain())) {
            return false;
        }
        StructuralKey key = TheoryKeys.embedding(permutation);
        for (TypedPermutation element : elements) {
            int comparison = TheoryKeys.embedding(element).compareTo(key);
            if (comparison == 0) {
                return element.equals(permutation);
            }
            if (comparison > 0) {
                return false;
            }
        }
        return false;
    }

    public StructuralKey structuralKey() {
        return structuralKey;
    }

    @Override
    public boolean equals(Object other) {
        if (!(other instanceof TypedSymmetryGroup)) {
            return false;
        }
        TypedSymmetryGroup group = (TypedSymmetryGroup) other;
        return context.equals(group.context)
                && generators.equals(group.generators)
                && elements.equals(group.elements);
    }

    @Override
    public int hashCode() {
        return Objects.hash(context, generators, elements);
    }

    @Override
    public String toString() {
        return "G(" + context + ")=" + elements;
    }
}
