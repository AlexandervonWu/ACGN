package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Immutable read-only boundary for one quiescent, certificate-checked semantic
 * graph and its complete bounded observations.
 */
public final class CertifiedSemanticArtifact {
    private final TypedInvocation root;
    private final Map<EClassId, TypedEClassRecord> classes;
    private final CoherentWitnessFamily witnesses;
    private final List<FiniteUnfoldingTree> unfoldings;
    private final Map<String, List<ContainerLawDeclaration>> containerLaws;

    public CertifiedSemanticArtifact(
            TypedInvocation root,
            Map<EClassId, TypedEClassRecord> classes,
            CoherentWitnessFamily witnesses,
            List<? extends FiniteUnfoldingTree> unfoldings,
            Map<String, ? extends List<? extends ContainerLawDeclaration>> containerLaws) {
        this.root = Objects.requireNonNull(root, "root");
        Objects.requireNonNull(classes, "classes");
        this.classes = Collections.unmodifiableMap(new LinkedHashMap<>(classes));
        this.witnesses = Objects.requireNonNull(witnesses, "witnesses");
        Objects.requireNonNull(unfoldings, "unfoldings");
        List<FiniteUnfoldingTree> copied = new ArrayList<>(unfoldings.size());
        for (FiniteUnfoldingTree unfolding : unfoldings) {
            FiniteUnfoldingTree checked = Objects.requireNonNull(unfolding, "unfolding");
            if (!root.equals(checked.rootInvocation())) {
                throw new IllegalArgumentException(
                        "Every semantic observation must unfold the artifact root");
            }
            copied.add(checked);
        }
        if (copied.isEmpty()) {
            throw new IllegalArgumentException(
                    "A certified semantic artifact requires at least one complete unfolding");
        }
        this.unfoldings = Collections.unmodifiableList(copied);

        Objects.requireNonNull(containerLaws, "containerLaws");
        Map<String, List<ContainerLawDeclaration>> copiedLaws = new LinkedHashMap<>();
        for (Map.Entry<String, ? extends List<? extends ContainerLawDeclaration>> entry
                : containerLaws.entrySet()) {
            String operator = Objects.requireNonNull(entry.getKey(), "container operator");
            if (operator.trim().isEmpty()) {
                throw new IllegalArgumentException("Container operator must not be blank");
            }
            List<ContainerLawDeclaration> declarations = new ArrayList<>();
            for (ContainerLawDeclaration declaration : Objects.requireNonNull(
                    entry.getValue(), "container declarations")) {
                ContainerLawDeclaration checked = Objects.requireNonNull(
                        declaration, "container declaration");
                checked.requireCertified();
                if (checked.kind() == ContainerLawDeclaration.Kind.NONE) {
                    throw new IllegalArgumentException(
                            "A certified container registry cannot contain NONE");
                }
                declarations.add(checked);
            }
            if (declarations.isEmpty()) {
                throw new IllegalArgumentException(
                        "A certified container registry entry cannot be empty");
            }
            copiedLaws.put(operator, Collections.unmodifiableList(declarations));
        }
        this.containerLaws = Collections.unmodifiableMap(copiedLaws);
    }

    public TypedInvocation root() {
        return root;
    }

    public Map<EClassId, TypedEClassRecord> classes() {
        return classes;
    }

    public CoherentWitnessFamily witnesses() {
        return witnesses;
    }

    public List<FiniteUnfoldingTree> unfoldings() {
        return unfoldings;
    }

    /** All source operator laws admitted with signature certificates. */
    public Map<String, List<ContainerLawDeclaration>> containerLaws() {
        return containerLaws;
    }
}
