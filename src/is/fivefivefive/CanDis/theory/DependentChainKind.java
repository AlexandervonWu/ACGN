package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/** Closed family of ordered, heterogeneously typed associative Alloy chains. */
public enum DependentChainKind {
    JOIN,
    ARROW;

    public String operatorIdentity() {
        return "ALLOY/DEPENDENT-CHAIN/" + name();
    }

    public GraphType combine(GraphType left, GraphType right) {
        List<GraphType> leftColumns = columns(left, "left");
        List<GraphType> rightColumns = columns(right, "right");
        List<GraphType> result = new ArrayList<>();
        if (this == ARROW) {
            result.addAll(leftColumns);
            result.addAll(rightColumns);
        } else {
            GraphType leftBoundary = leftColumns.get(leftColumns.size() - 1);
            GraphType rightBoundary = rightColumns.get(0);
            if (!leftBoundary.equals(rightBoundary)) {
                throw new IllegalArgumentException(
                        "JOIN boundary mismatch: " + leftBoundary
                                + " != " + rightBoundary);
            }
            result.addAll(leftColumns.subList(0, leftColumns.size() - 1));
            result.addAll(rightColumns.subList(1, rightColumns.size()));
            if (result.isEmpty()) {
                throw new IllegalArgumentException(
                        "The certified Alloy relation slice has no nullary relation type");
            }
        }
        return GraphType.relation(result);
    }

    public GraphType fold(List<GraphType> operands) {
        Objects.requireNonNull(operands, "operands");
        if (operands.size() < 2) {
            throw new IllegalArgumentException(
                    "A dependent chain requires at least two operands");
        }
        GraphType result = Objects.requireNonNull(operands.get(0), "operand type");
        columns(result, "first");
        for (int index = 1; index < operands.size(); index++) {
            result = combine(
                    result,
                    Objects.requireNonNull(operands.get(index), "operand type"));
        }
        return result;
    }

    private static List<GraphType> columns(GraphType type, String role) {
        Objects.requireNonNull(type, role + " type");
        if (type.kind() != GraphType.Kind.RELATION) {
            throw new IllegalArgumentException(
                    "Dependent " + role + " operand is not an exact relation type: "
                            + type);
        }
        return type.arguments();
    }
}
