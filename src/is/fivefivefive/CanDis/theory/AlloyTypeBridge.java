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
                List<GraphType> alternatives = new ArrayList<>();
                for (List<String> tuple : type.alternatives()) {
                    List<GraphType> columns = new ArrayList<>(tuple.size());
                    for (String column : tuple) {
                        columns.add(GraphType.constructor("AlloySig:" + column));
                    }
                    alternatives.add(GraphType.relation(columns));
                }
                if (alternatives.size() == 1) {
                    return alternatives.get(0);
                }
                return GraphType.constructor("AlloyRelationUnion", alternatives);
            case UNKNOWN:
            default:
                throw new IllegalStateException("An exact Alloy expression type is unavailable");
        }
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

    /** True only for an exact relation or a validated same-arity relation family. */
    public static boolean isCommutativeRelationCarrier(GraphType type) {
        return relationArity(Objects.requireNonNull(type, "type")) != null;
    }

    public static GraphType emptyRelation(int arity) {
        if (arity <= 0) {
            throw new IllegalArgumentException(
                    "An empty relation requires positive arity");
        }
        return GraphType.constructor(EMPTY_RELATION_PREFIX + arity);
    }

    private static Integer relationArity(GraphType type) {
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
            Integer next = relationArity(alternative);
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
