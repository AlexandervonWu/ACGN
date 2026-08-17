package is.fivefivefive.CanDis.theory;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Deque;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeMap;

/** Finite typed subgroup declared by one complete binder descriptor. */
public final class BinderAutomorphismGroup {
    private final TypedSlotContext context;
    private final List<TypedPermutation> generators;
    private final List<BinderAutomorphismCertificate> generatorCertificates;
    private final List<TypedPermutation> elements;
    private final StructuralKey structuralKey;
    // Positive memo only; descriptors and their certificate groups are immutable.
    private final Set<BinderBlockDescriptor> certifiedDescriptors =
            Collections.newSetFromMap(new java.util.IdentityHashMap<>());

    BinderAutomorphismGroup(
            TypedSlotContext context,
            List<? extends TypedPermutation> generators) {
        this(context, generators, Collections.emptyList());
    }

    static BinderAutomorphismGroup certified(
            TypedSlotContext context,
            List<? extends BinderAutomorphismCertificate> certificates) {
        Objects.requireNonNull(certificates, "certificates");
        List<TypedPermutation> generators = new ArrayList<>(certificates.size());
        for (BinderAutomorphismCertificate certificate : certificates) {
            BinderAutomorphismCertificate checked = Objects.requireNonNull(
                    certificate, "binder automorphism certificate");
            CertificateVerifier.verifyBinderAutomorphism(checked);
            generators.add(checked.permutation());
        }
        return new BinderAutomorphismGroup(context, generators, certificates);
    }

    private BinderAutomorphismGroup(
            TypedSlotContext context,
            List<? extends TypedPermutation> sourceGenerators,
            List<? extends BinderAutomorphismCertificate> certificates) {
        this.context = Objects.requireNonNull(context, "context");
        Objects.requireNonNull(sourceGenerators, "generators");
        TypedPermutation identity = TypedPermutation.identity(context);
        Map<StructuralKey, TypedPermutation> normalized = new TreeMap<>();
        for (TypedPermutation generator : sourceGenerators) {
            TypedPermutation permutation = Objects.requireNonNull(generator, "generator");
            requireContext(permutation);
            if (!identity.equals(permutation)) {
                putUnique(normalized, permutation);
            }
        }
        this.generators = Collections.unmodifiableList(new ArrayList<>(normalized.values()));

        Objects.requireNonNull(certificates, "certificates");
        Map<StructuralKey, BinderAutomorphismCertificate> certifiedByGenerator = new TreeMap<>();
        for (BinderAutomorphismCertificate certificate : certificates) {
            BinderAutomorphismCertificate checked = Objects.requireNonNull(
                    certificate, "binder automorphism certificate");
            CertificateVerifier.verifyBinderAutomorphism(checked);
            if (!context.equals(checked.boundContext())) {
                throw new IllegalArgumentException(
                        "Binder certificate acts on a different bound context");
            }
            StructuralKey key = actionKey(checked.permutation());
            BinderAutomorphismCertificate prior = certifiedByGenerator.putIfAbsent(
                    key, checked);
            if (prior != null && !prior.equals(checked)) {
                throw new IllegalArgumentException(
                        "One binder generator cannot carry two certificates");
            }
        }
        List<BinderAutomorphismCertificate> orderedCertificates = new ArrayList<>();
        for (TypedPermutation generator : this.generators) {
            BinderAutomorphismCertificate certificate = certifiedByGenerator.get(
                    actionKey(generator));
            if (certificate != null) {
                orderedCertificates.add(certificate);
            }
        }
        if (orderedCertificates.size() != certifiedByGenerator.size()) {
            throw new IllegalArgumentException(
                    "A binder certificate does not name a retained nonidentity generator");
        }
        this.generatorCertificates = Collections.unmodifiableList(orderedCertificates);
        this.elements = close(identity, this.generators);

        List<StructuralKey> children = new ArrayList<>();
        children.add(TheoryKeys.context(context));
        for (TypedPermutation element : elements) {
            children.add(StructuralKey.branch(
                    "binder-automorphism-element",
                    Collections.singletonList(actionKey(element))));
        }
        this.structuralKey = StructuralKey.branch("binder-automorphism-group", children);
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
                StructuralKey key = actionKey(candidate);
                TypedPermutation prior = closure.putIfAbsent(key, candidate);
                if (prior == null) {
                    pending.addLast(candidate);
                } else if (!prior.equals(candidate)) {
                    throw new IllegalStateException(
                            "Structural key collision between unequal binder automorphisms");
                }
            }
        }
        return Collections.unmodifiableList(new ArrayList<>(closure.values()));
    }

    private void requireContext(TypedPermutation permutation) {
        if (!context.equals(permutation.source())
                || !context.equals(permutation.codomain())) {
            throw new IllegalArgumentException(
                    "Every binder automorphism must permute its descriptor context");
        }
    }

    private void putUnique(
            Map<StructuralKey, TypedPermutation> target,
            TypedPermutation permutation) {
        StructuralKey key = actionKey(permutation);
        TypedPermutation prior = target.putIfAbsent(key, permutation);
        if (prior != null && !prior.equals(permutation)) {
            throw new IllegalStateException(
                    "Structural key collision between unequal binder automorphisms");
        }
    }

    public TypedSlotContext context() {
        return context;
    }

    public List<TypedPermutation> generators() {
        return generators;
    }

    public List<BinderAutomorphismCertificate> generatorCertificates() {
        return generatorCertificates;
    }

    public boolean hasCertifiedGenerators() {
        return generatorCertificates.size() == generators.size();
    }

    /** Reconstructs a proof for any closure element from certified generators. */
    public TypedEqualityCertificate derivationFor(
            BinderBlockDescriptor descriptor,
            TypedPermutation permutation) {
        Objects.requireNonNull(permutation, "permutation");
        validateCertificates(descriptor);
        if (!contains(permutation)) {
            throw new IllegalArgumentException(
                    "Permutation is outside this binder automorphism group");
        }
        TypedPermutation identity = TypedPermutation.identity(context);
        TypedCertificateEndpoint identityEndpoint = TypedCertificateEndpoint.binderPattern(
                descriptor.payloadKey(), context, identity);
        if (identity.equals(permutation)) {
            return EqualityCertificates.reflexive(identityEndpoint);
        }

        List<CertifiedStep> steps = certifiedSteps();
        Map<StructuralKey, DerivationLink> predecessors = new TreeMap<>();
        Deque<TypedPermutation> pending = new ArrayDeque<>();
        StructuralKey identityKey = actionKey(identity);
        StructuralKey targetKey = actionKey(permutation);
        predecessors.put(identityKey, null);
        pending.add(identity);
        while (!pending.isEmpty() && !predecessors.containsKey(targetKey)) {
            TypedPermutation current = pending.removeFirst();
            StructuralKey currentKey = actionKey(current);
            for (CertifiedStep step : steps) {
                TypedPermutation candidate = current.andThen(step.permutation);
                StructuralKey candidateKey = actionKey(candidate);
                if (predecessors.containsKey(candidateKey)) {
                    continue;
                }
                predecessors.put(
                        candidateKey, new DerivationLink(currentKey, step));
                pending.addLast(candidate);
            }
        }
        if (!predecessors.containsKey(targetKey)) {
            throw new IllegalStateException(
                    "Certified generators did not reconstruct a retained group element");
        }
        List<CertifiedStep> word = new ArrayList<>();
        StructuralKey cursor = targetKey;
        while (!cursor.equals(identityKey)) {
            DerivationLink link = predecessors.get(cursor);
            if (link == null) {
                throw new IllegalStateException("Broken binder derivation predecessor chain");
            }
            word.add(link.step);
            cursor = link.previous;
        }
        Collections.reverse(word);
        TypedPermutation current = identity;
        TypedEqualityCertificate result = EqualityCertificates.reflexive(identityEndpoint);
        for (CertifiedStep step : word) {
            TypedEqualityCertificate transportedCurrent = EqualityCertificates.rename(
                    result, step.permutation);
            result = EqualityCertificates.transitive(
                    step.certificate, transportedCurrent);
            current = current.andThen(step.permutation);
        }
        if (!current.equals(permutation)) {
            throw new IllegalStateException(
                    "Reconstructed binder derivation reaches the wrong permutation");
        }
        TypedCertificateEndpoint expectedRight = TypedCertificateEndpoint.binderPattern(
                descriptor.payloadKey(), context, permutation);
        if (!result.leftEndpoint().equals(identityEndpoint)
                || !result.rightEndpoint().equals(expectedRight)) {
            throw new IllegalStateException(
                    "Reconstructed binder derivation has incorrect endpoints");
        }
        CertificateVerifier.verify(result);
        return result;
    }

    synchronized void requireCertifiedFor(BinderBlockDescriptor descriptor) {
        if (certifiedDescriptors.contains(Objects.requireNonNull(descriptor, "descriptor"))) {
            return;
        }
        validateCertificates(descriptor);
        certifiedDescriptors.add(descriptor);
    }

    private void validateCertificates(
            BinderBlockDescriptor descriptor) {
        Objects.requireNonNull(descriptor, "descriptor");
        if (!context.equals(descriptor.boundContext())
                || !hasCertifiedGenerators()) {
            throw new IllegalStateException(
                    "Binder group lacks certificates for this descriptor");
        }
        for (BinderAutomorphismCertificate certificate : generatorCertificates) {
            CertificateVerifier.verifyBinderAutomorphism(certificate);
            if (!descriptor.payloadKey().equals(certificate.descriptorKey())) {
                throw new IllegalStateException(
                        "Binder certificate belongs to a different descriptor");
            }
        }
    }

    private List<CertifiedStep> certifiedSteps() {
        List<CertifiedStep> steps = new ArrayList<>(generators.size() * 2);
        for (int index = 0; index < generators.size(); index++) {
            TypedPermutation generator = generators.get(index);
            TypedEqualityCertificate proof = generatorCertificates.get(index);
            steps.add(new CertifiedStep(generator, proof));
            TypedPermutation inverse = generator.inverse();
            TypedEqualityCertificate inverseProof = EqualityCertificates.symmetric(
                    EqualityCertificates.rename(proof, inverse));
            steps.add(new CertifiedStep(inverse, inverseProof));
        }
        return steps;
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
        StructuralKey key = actionKey(permutation);
        for (TypedPermutation element : elements) {
            int comparison = actionKey(element).compareTo(key);
            if (comparison == 0) {
                return element.equals(permutation);
            }
            if (comparison > 0) {
                return false;
            }
        }
        return false;
    }

    private StructuralKey actionKey(TypedPermutation permutation) {
        return TheoryKeys.permutationAction(context, permutation);
    }

    public StructuralKey structuralKey() {
        return structuralKey;
    }

    @Override
    public boolean equals(Object other) {
        if (!(other instanceof BinderAutomorphismGroup)) {
            return false;
        }
        BinderAutomorphismGroup group = (BinderAutomorphismGroup) other;
        return context.equals(group.context)
                && elements.equals(group.elements);
    }

    @Override
    public int hashCode() {
        return Objects.hash(context, elements);
    }

    @Override
    public String toString() {
        return "Aut(" + context + ")=" + elements;
    }

    private static final class CertifiedStep {
        private final TypedPermutation permutation;
        private final TypedEqualityCertificate certificate;

        private CertifiedStep(
                TypedPermutation permutation,
                TypedEqualityCertificate certificate) {
            this.permutation = permutation;
            this.certificate = certificate;
        }
    }

    private static final class DerivationLink {
        private final StructuralKey previous;
        private final CertifiedStep step;

        private DerivationLink(StructuralKey previous, CertifiedStep step) {
            this.previous = previous;
            this.step = step;
        }
    }
}
