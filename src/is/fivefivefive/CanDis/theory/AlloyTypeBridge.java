package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.TreeSet;

import is.fivefivefive.ACGN.alloy.ExactAlloyType;

/** Total conversion from occurrence-level Alloy types into structural graph types. */
public final class AlloyTypeBridge {
    private static final String EMPTY_RELATION_PREFIX =
            "AlloyEmptyRelation$arity=";

    private AlloyTypeBridge() {
    }

    public static GraphType graphType(ExactAlloyType type) {
        Objects.requireNonNull(type, "type");
        switch (type.kind()) {
            case BOOL:
                return GraphType.BOOL;
            case INT:
                return GraphType.INT;
            case EMPTY_RELATION:
                return emptyRelation(type.relationArity());
            case RELATION:
                TreeSet<GraphType> sortedAlternatives = new TreeSet<>();
                for (List<String> tuple : type.alternatives()) {
                    List<GraphType> columns = new ArrayList<>(tuple.size());
                    for (String column : tuple) {
                        columns.add(alloyColumn(column));
                    }
                    sortedAlternatives.add(GraphType.relation(columns));
                }
                List<GraphType> alternatives = List.copyOf(sortedAlternatives);
                if (alternatives.size() == 1) {
                    return alternatives.get(0);
                }
                return GraphType.constructor("AlloyRelationUnion", alternatives);
            case UNKNOWN:
            default:
                throw new IllegalStateException("An exact Alloy expression type is unavailable");
        }
    }

    /** Proof-only column ancestry for one exact, non-union relation occurrence. */
    public static List<DependentColumnEvidence> dependentColumns(
            ExactAlloyType type) {
        Objects.requireNonNull(type, "type");
        if (type.kind() != ExactAlloyType.Kind.RELATION
                || type.alternatives().size() != 1
                || type.ancestryAlternatives().size() != 1) {
            throw new IllegalArgumentException(
                    "A dependent chain leaf requires one exact relation alternative");
        }
        List<String> columns = type.alternatives().get(0);
        List<List<String>> ancestries = type.ancestryAlternatives().get(0);
        if (columns.size() != ancestries.size()) {
            throw new IllegalArgumentException(
                    "Exact Alloy columns and ancestry proofs differ in arity");
        }
        if (!type.hasParserAuthenticatedAncestry()
                && ancestries.stream().anyMatch(path -> path.size() > 1)) {
            throw new DependentChainTheory.UnsupportedFlattening(
                    "Nontrivial dependent ancestry requires live parser authority");
        }
        List<DependentColumnEvidence> result = new ArrayList<>(columns.size());
        for (int index = 0; index < columns.size(); index++) {
            result.add(DependentColumnEvidence.fromExactAlloyType(type, index));
        }
        return Collections.unmodifiableList(result);
    }

    /** Authenticated correlated alternatives for one exact Alloy relation type. */
    public static DependentTypeDag dependentTypeDag(ExactAlloyType type) {
        return DependentTypeDag.fromExactAlloyType(type);
    }

    public static GraphType commutativeCarrier(List<GraphType> operandTypes) {
        Objects.requireNonNull(operandTypes, "operandTypes");
        if (operandTypes.isEmpty()) {
            throw new IllegalArgumentException("A commutative carrier requires operands");
        }
        TreeSet<GraphType> unique = new TreeSet<>();
        for (GraphType type : operandTypes) {
            unique.add(Objects.requireNonNull(type, "operand type"));
        }
        if (unique.size() == 1) {
            return unique.first();
        }
        return GraphType.constructor(
                "AlloyComparableCarrier", Collections.unmodifiableList(new ArrayList<>(unique)));
    }

    static GraphType alloyColumn(String name) {
        String checked = normalizeAlloyIdentity(name);
        return "Int".equals(checked)
                ? GraphType.INT
                : GraphType.constructor("AlloySig:" + checked);
    }

    static String normalizeAlloyIdentity(String value) {
        if (!isAdmittedIdentity(value)) {
            throw new IllegalArgumentException(
                    "An Alloy column must be a well-formed visible identity");
        }
        String normalized = value.startsWith("this/")
                ? value.substring("this/".length()) : value;
        if (normalized.isEmpty() || normalized.startsWith("this/")) {
            throw new IllegalArgumentException(
                    "An Alloy column must have one canonical identity after its module prefix");
        }
        return normalized;
    }

    public static boolean isAdmittedIdentity(String value) {
        return ExactAlloyType.isAdmittedIdentity(value);
    }

    /** True only for an exact relation or a validated same-arity relation family. */
    public static boolean isCommutativeRelationCarrier(GraphType type) {
        return relationArityOrNull(Objects.requireNonNull(type, "type")) != null;
    }

    /** True for an exact product, typed empty family, or correlated family. */
    public static boolean isRelationFamily(GraphType type) {
        Objects.requireNonNull(type, "type");
        if (type.kind() == GraphType.Kind.RELATION) {
            return true;
        }
        if (emptyRelationArity(type) != null) {
            return true;
        }
        if (type.kind() != GraphType.Kind.CONSTRUCTOR
                || !"AlloyRelationUnion".equals(type.symbol())
                || type.arguments().size() < 2) {
            return false;
        }
        Integer arity = null;
        GraphType previous = null;
        for (GraphType alternative : type.arguments()) {
            if (alternative.kind() != GraphType.Kind.RELATION
                    || (arity != null
                            && arity.intValue() != alternative.arguments().size())
                    || previous != null && previous.compareTo(alternative) >= 0) {
                return false;
            }
            arity = alternative.arguments().size();
            previous = alternative;
        }
        return true;
    }

    /** Ordered nonempty product alternatives; typed empty families have none. */
    public static List<GraphType> relationAlternatives(GraphType type) {
        Objects.requireNonNull(type, "type");
        if (type.kind() == GraphType.Kind.RELATION) {
            return List.of(type);
        }
        if (emptyRelationArity(type) != null) {
            return List.of();
        }
        if (!isRelationFamily(type)) {
            throw new IllegalArgumentException(
                    "Not an exact correlated relation family: " + type);
        }
        return type.arguments();
    }

    public static int relationArity(GraphType type) {
        Integer arity = relationArityOrNull(Objects.requireNonNull(type, "type"));
        if (arity == null) {
            throw new IllegalArgumentException(
                    "Not a same-arity relation family: " + type);
        }
        return arity;
    }

    public static GraphType emptyRelation(int arity) {
        if (arity <= 0) {
            throw new IllegalArgumentException(
                    "An empty relation requires positive arity");
        }
        return GraphType.constructor(EMPTY_RELATION_PREFIX + arity);
    }

    private static Integer relationArityOrNull(GraphType type) {
        if (type.kind() == GraphType.Kind.RELATION) {
            return type.arguments().size();
        }
        Integer emptyArity = emptyRelationArity(type);
        if (emptyArity != null) {
            return emptyArity;
        }
        if (type.kind() != GraphType.Kind.CONSTRUCTOR
                || !("AlloyComparableCarrier".equals(type.symbol())
                        || "AlloyRelationUnion".equals(type.symbol()))
                || type.arguments().isEmpty()) {
            return null;
        }
        Integer arity = null;
        for (GraphType alternative : type.arguments()) {
            Integer next = relationArityOrNull(alternative);
            if (next == null || (arity != null && !arity.equals(next))) {
                return null;
            }
            arity = next;
        }
        return arity;
    }

    public static Integer emptyRelationArity(GraphType type) {
        Objects.requireNonNull(type, "type");
        if (type.kind() != GraphType.Kind.CONSTRUCTOR
                || !type.arguments().isEmpty()
                || !type.symbol().startsWith(EMPTY_RELATION_PREFIX)) {
            return null;
        }
        String encoded = type.symbol().substring(EMPTY_RELATION_PREFIX.length());
        try {
            int arity = Integer.parseInt(encoded);
            return arity > 0 && Integer.toString(arity).equals(encoded)
                    ? arity : null;
        } catch (NumberFormatException exception) {
            return null;
        }
    }
}
