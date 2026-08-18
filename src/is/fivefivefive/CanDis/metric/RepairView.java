package is.fivefivefive.CanDis.metric;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/**
 * Immutable repair-domain observation of a certified, repaired normal form.
 * Temporal topology, phase quantifiers, and matrices remain separate because
 * that decomposition is part of the established {@code CanonicalDistance}
 * semantics. Certificate-derived scope data is metadata, never an edit node.
 */
public final class RepairView {
    public enum ContainerKind {
        ONE,
        SEQUENCE,
        BAG,
        SET
    }

    public enum BindingRole {
        PARAMETER,
        MATRIX,
        INHERITED
    }

    public static final class TemporalNode {
        private final String label;
        private final List<TemporalNode> children;
        private final int size;

        public TemporalNode(String label, List<? extends TemporalNode> children) {
            this.label = requireText(label, "temporal label");
            this.children = immutable(children, "temporal child");
            int computed = 1;
            for (TemporalNode child : this.children) {
                computed = Math.addExact(computed, child.size);
            }
            this.size = computed;
        }

        public String label() {
            return label;
        }

        public List<TemporalNode> children() {
            return children;
        }

        public int size() {
            return size;
        }
    }

    /** One source-level quantifier repair tuple plus non-editable legality data. */
    public static final class Declaration {
        private final String quantifier;
        private final String type;
        private final String cardinality;
        private final int disjointnessClass;
        private final String certifiedDomain;
        private final int exchangeClass;
        private final List<Integer> dependencies;

        public Declaration(
                String quantifier,
                String type,
                String cardinality,
                int disjointnessClass,
                String certifiedDomain,
                int exchangeClass,
                List<Integer> dependencies) {
            this.quantifier = requireText(quantifier, "quantifier");
            this.type = requireText(type, "type");
            this.cardinality = requireText(cardinality, "cardinality");
            this.disjointnessClass = disjointnessClass;
            this.certifiedDomain = requireText(certifiedDomain, "certified domain");
            this.exchangeClass = exchangeClass;
            this.dependencies = immutableIntegers(dependencies);
        }

        public String quantifier() {
            return quantifier;
        }

        public String type() {
            return type;
        }

        public String cardinality() {
            return cardinality;
        }

        public int disjointnessClass() {
            return disjointnessClass;
        }

        public String certifiedDomain() {
            return certifiedDomain;
        }

        public int exchangeClass() {
            return exchangeClass;
        }

        public List<Integer> dependencies() {
            return dependencies;
        }

        /** The Fast Rewrite conceptual edit unit: any tuple modification costs one. */
        public boolean sameRepairTuple(Declaration other) {
            return other != null
                    && quantifier.equals(other.quantifier)
                    && type.equals(other.type)
                    && cardinality.equals(other.cardinality)
                    && disjointnessClass == other.disjointnessClass;
        }

        /** Fields used to establish a certificate-backed zero-cost alpha edge. */
        public boolean sameCertifiedPayload(Declaration other) {
            return sameRepairTuple(other)
                    && certifiedDomain.equals(other.certifiedDomain)
                    && dependencies.equals(other.dependencies);
        }
    }

    public static final class Binding {
        private final BindingRole role;
        private final int ordinal;
        private final int ownerPhase;
        private final int coordinate;
        private final Declaration declaration;
        private final String bindingPath;
        private final List<Integer> certifiedOrbit;

        public Binding(
                BindingRole role,
                int ordinal,
                int ownerPhase,
                int coordinate,
                Declaration declaration,
                String bindingPath,
                List<Integer> certifiedOrbit) {
            this.role = Objects.requireNonNull(role, "role");
            if (ordinal < 0) {
                throw new IllegalArgumentException("Binding ordinal must be non-negative");
            }
            this.ordinal = ordinal;
            this.ownerPhase = ownerPhase;
            this.coordinate = coordinate;
            this.declaration = Objects.requireNonNull(declaration, "declaration");
            this.bindingPath = bindingPath == null ? "" : bindingPath;
            this.certifiedOrbit = immutableIntegers(certifiedOrbit);
            if (role == BindingRole.PARAMETER && (ownerPhase != -1 || coordinate != -1)) {
                throw new IllegalArgumentException(
                        "Parameter bindings cannot claim a binder coordinate");
            }
            if (role != BindingRole.PARAMETER
                    && (ownerPhase < 0 || coordinate < 0
                            || !this.certifiedOrbit.contains(coordinate))) {
                throw new IllegalArgumentException(
                        "Quantified bindings require a certified owner coordinate and orbit");
            }
        }

        public BindingRole role() {
            return role;
        }

        public int ordinal() {
            return ordinal;
        }

        public int ownerPhase() {
            return ownerPhase;
        }

        public int coordinate() {
            return coordinate;
        }

        public Declaration declaration() {
            return declaration;
        }

        public String bindingPath() {
            return bindingPath;
        }

        public List<Integer> certifiedOrbit() {
            return certifiedOrbit;
        }
    }

    /** One Fast Rewrite matrix e-node with certified flexible-container semantics. */
    public static final class Node {
        private final String operator;
        private final String payload;
        private final String lexicalVariable;
        private final int bindingIndex;
        private final ContainerKind containerKind;
        private final boolean orderInsensitive;
        private final List<Node> children;
        private final List<Node> alphaAlternatives;
        private final int size;

        public Node(
                String operator,
                String payload,
                String lexicalVariable,
                int bindingIndex,
                ContainerKind containerKind,
                boolean orderInsensitive,
                List<? extends Node> children) {
            this(
                    operator,
                    payload,
                    lexicalVariable,
                    bindingIndex,
                    containerKind,
                    orderInsensitive,
                    children,
                    Collections.emptyList());
        }

        public Node(
                String operator,
                String payload,
                String lexicalVariable,
                int bindingIndex,
                ContainerKind containerKind,
                boolean orderInsensitive,
                List<? extends Node> children,
                List<? extends Node> alphaAlternatives) {
            this.operator = requireText(operator, "operator");
            this.payload = payload;
            this.lexicalVariable = lexicalVariable;
            this.bindingIndex = bindingIndex;
            this.containerKind = Objects.requireNonNull(containerKind, "containerKind");
            this.orderInsensitive = orderInsensitive;
            this.children = immutable(children, "matrix child");
            this.alphaAlternatives = immutable(
                    alphaAlternatives, "matrix alpha alternative");
            if ("VARIABLE".equals(operator)) {
                if (lexicalVariable == null) {
                    throw new IllegalArgumentException(
                            "A variable must retain its readable lexical identity");
                }
            } else if (bindingIndex >= 0 || lexicalVariable != null) {
                throw new IllegalArgumentException(
                        "Only VARIABLE nodes may carry a variable identity");
            }
            int computed = 1;
            for (Node child : this.children) {
                computed = Math.addExact(computed, child.size);
            }
            this.size = computed;
            for (Node alternative : this.alphaAlternatives) {
                if (!operator.equals(alternative.operator)
                        || computed != alternative.size) {
                    throw new IllegalArgumentException(
                            "A local alpha alternative must preserve operator and size");
                }
            }
        }

        public String operator() {
            return operator;
        }

        public String payload() {
            return payload;
        }

        public boolean isVariable() {
            return "VARIABLE".equals(operator);
        }

        public String lexicalVariable() {
            return lexicalVariable;
        }

        public int bindingIndex() {
            return bindingIndex;
        }

        public ContainerKind containerKind() {
            return containerKind;
        }

        public boolean orderInsensitive() {
            return orderInsensitive;
        }

        public List<Node> children() {
            return children;
        }

        /** Certified local-binder orbit representatives, excluding this wrapper. */
        public List<Node> alphaAlternatives() {
            return alphaAlternatives;
        }

        public int size() {
            return size;
        }
    }

    public static final class Phase {
        private final List<Declaration> quantifiers;
        private final List<Binding> bindings;
        private final Node matrix;

        public Phase(
                List<? extends Declaration> quantifiers,
                List<? extends Binding> bindings,
                Node matrix) {
            this.quantifiers = immutable(quantifiers, "quantifier");
            this.bindings = immutable(bindings, "binding");
            this.matrix = matrix;
        }

        public List<Declaration> quantifiers() {
            return quantifiers;
        }

        public List<Binding> bindings() {
            return bindings;
        }

        public Node matrix() {
            return matrix;
        }
    }

    private final TemporalNode temporalRoot;
    private final List<Phase> phases;
    private final String certifiedArtifactDigest;
    private final int semanticSize;

    public RepairView(
            TemporalNode temporalRoot,
            List<? extends Phase> phases,
            String certifiedArtifactDigest) {
        this.temporalRoot = Objects.requireNonNull(temporalRoot, "temporalRoot");
        this.phases = immutable(phases, "phase");
        this.certifiedArtifactDigest = requireText(
                certifiedArtifactDigest, "certifiedArtifactDigest");
        int computed = this.phases.size();
        for (Phase phase : this.phases) {
            computed = Math.addExact(computed, phase.quantifiers.size());
            if (phase.matrix != null) {
                computed = Math.addExact(computed, phase.matrix.size());
            }
        }
        this.semanticSize = computed;
    }

    public TemporalNode temporalRoot() {
        return temporalRoot;
    }

    public List<Phase> phases() {
        return phases;
    }

    public String certifiedArtifactDigest() {
        return certifiedArtifactDigest;
    }

    /** Exactly the established normal-form representation-size denominator. */
    public int semanticSize() {
        return semanticSize;
    }

    private static String requireText(String value, String label) {
        Objects.requireNonNull(value, label);
        if (value.isBlank()) {
            throw new IllegalArgumentException(label + " must not be blank");
        }
        return value;
    }

    private static List<Integer> immutableIntegers(List<Integer> source) {
        Objects.requireNonNull(source, "integer list");
        List<Integer> result = new ArrayList<>(source.size());
        for (Integer value : source) {
            result.add(Objects.requireNonNull(value, "integer"));
        }
        return Collections.unmodifiableList(result);
    }

    private static <T> List<T> immutable(List<? extends T> source, String label) {
        Objects.requireNonNull(source, label + "s");
        List<T> result = new ArrayList<>(source.size());
        for (T value : source) {
            result.add(Objects.requireNonNull(value, label));
        }
        return Collections.unmodifiableList(result);
    }
}
