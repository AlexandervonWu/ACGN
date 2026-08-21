package is.fivefivefive.ACGN.alloy;

import java.io.IOException;
import java.io.InvalidObjectException;
import java.io.ObjectInputStream;
import java.io.ObjectStreamException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;

import edu.mit.csail.sdg.ast.Sig.PrimSig;
import edu.mit.csail.sdg.ast.Type;

/** Serializable occurrence-level image of Alloy's exact expression type. */
public final class ExactAlloyType implements Serializable {
    private static final long serialVersionUID = 2L;

    public enum Kind {
        BOOL,
        INT,
        RELATION,
        EMPTY_RELATION,
        UNKNOWN
    }

    private final Kind kind;
    private final List<List<String>> alternatives;
    private final int relationArity;
    private final String stableString;

    private ExactAlloyType(
            Kind kind,
            List<? extends List<String>> alternatives,
            int relationArity) {
        this.kind = Objects.requireNonNull(kind, "kind");
        List<List<String>> copied = new ArrayList<>();
        for (List<String> alternative : alternatives) {
            List<String> columns = new ArrayList<>();
            for (String column : alternative) {
                String checked = Objects.requireNonNull(column, "column").trim();
                if (checked.isEmpty()) {
                    throw new IllegalArgumentException("An Alloy type column must not be blank");
                }
                columns.add(checked);
            }
            copied.add(Collections.unmodifiableList(columns));
        }
        copied.sort(Comparator.comparing(ExactAlloyType::tupleKey));
        this.alternatives = Collections.unmodifiableList(copied);
        this.relationArity = relationArity;
        validateShape();
        this.stableString = buildStableString();
    }

    public static ExactAlloyType from(Type type) {
        if (type == null) {
            return unknownType();
        }
        if (type.is_bool) {
            return boolType();
        }
        if (type.is_int()) {
            return intType();
        }
        LinkedHashSet<List<String>> tuples = new LinkedHashSet<>();
        java.util.Set<Integer> emptyArities = new java.util.TreeSet<>();
        for (Type.ProductType product : type) {
            if (product.isEmpty()) {
                if (product.arity() > 0) {
                    emptyArities.add(product.arity());
                }
                continue;
            }
            List<String> columns = new ArrayList<>(product.arity());
            for (int index = 0; index < product.arity(); index++) {
                PrimSig column = product.get(index);
                columns.add(normalizeColumn(column.label));
            }
            tuples.add(Collections.unmodifiableList(columns));
        }
        if (tuples.isEmpty()) {
            return type.hasNoTuple() && emptyArities.size() == 1
                    ? emptyRelation(emptyArities.iterator().next())
                    : unknownType();
        }
        int arity = tuples.iterator().next().size();
        for (List<String> tuple : tuples) {
            if (tuple.size() != arity) {
                return unknownType();
            }
        }
        return new ExactAlloyType(Kind.RELATION, new ArrayList<>(tuples), arity);
    }

    public static ExactAlloyType boolType() {
        return new ExactAlloyType(Kind.BOOL, Collections.emptyList(), -1);
    }

    public static ExactAlloyType intType() {
        return new ExactAlloyType(Kind.INT, Collections.emptyList(), -1);
    }

    public static ExactAlloyType unaryRelation(String column) {
        return relation(Collections.singletonList(column));
    }

    public static ExactAlloyType relation(List<String> columns) {
        Objects.requireNonNull(columns, "columns");
        if (columns.isEmpty()) {
            throw new IllegalArgumentException(
                    "An exact Alloy relation type requires at least one column");
        }
        return new ExactAlloyType(
                Kind.RELATION,
                Collections.singletonList(columns),
                columns.size());
    }

    public static ExactAlloyType emptyRelation(int arity) {
        if (arity <= 0) {
            throw new IllegalArgumentException(
                    "An empty Alloy relation requires positive arity");
        }
        return new ExactAlloyType(
                Kind.EMPTY_RELATION, Collections.emptyList(), arity);
    }

    public Kind kind() {
        return kind;
    }

    public List<List<String>> alternatives() {
        return alternatives;
    }

    public int relationArity() {
        if (kind != Kind.RELATION && kind != Kind.EMPTY_RELATION) {
            throw new IllegalStateException(
                    "A non-relation Alloy type has no relation arity");
        }
        return relationArity;
    }

    public String stableString() {
        return stableString;
    }

    private String buildStableString() {
        StringBuilder result = new StringBuilder(kind.name());
        if (kind == Kind.EMPTY_RELATION) {
            result.append("[arity=").append(relationArity).append(']');
        }
        for (List<String> tuple : alternatives) {
            result.append('[');
            for (String column : tuple) {
                result.append(column.length()).append(':').append(column);
            }
            result.append(']');
        }
        return result.toString();
    }

    private void validateShape() {
        if (kind == Kind.RELATION) {
            if (relationArity <= 0 || alternatives.isEmpty()) {
                throw new IllegalArgumentException(
                        "An exact relation requires alternatives and positive arity");
            }
            for (List<String> alternative : alternatives) {
                if (alternative.size() != relationArity) {
                    throw new IllegalArgumentException(
                            "Relation alternatives must have one exact arity");
                }
            }
            return;
        }
        if (kind == Kind.EMPTY_RELATION) {
            if (relationArity <= 0 || !alternatives.isEmpty()) {
                throw new IllegalArgumentException(
                        "An empty relation requires only a positive arity");
            }
            return;
        }
        if (relationArity != -1 || !alternatives.isEmpty()) {
            throw new IllegalArgumentException(
                    kind + " must not carry relation shape");
        }
    }

    private static ExactAlloyType unknownType() {
        return new ExactAlloyType(Kind.UNKNOWN, Collections.emptyList(), -1);
    }

    private static String tupleKey(List<String> tuple) {
        StringBuilder result = new StringBuilder();
        for (String column : tuple) {
            result.append(column.length()).append(':').append(column);
        }
        return result.toString();
    }

    private static String normalizeColumn(String value) {
        String checked = Objects.requireNonNull(value, "column").trim();
        return checked.startsWith("this/") ? checked.substring(5) : checked;
    }

    private void readObject(ObjectInputStream input)
            throws IOException, ClassNotFoundException {
        input.defaultReadObject();
        try {
            Objects.requireNonNull(kind, "kind");
            Objects.requireNonNull(alternatives, "alternatives");
            for (List<String> alternative : alternatives) {
                Objects.requireNonNull(alternative, "alternative");
                for (String column : alternative) {
                    if (Objects.requireNonNull(column, "column").trim().isEmpty()) {
                        throw new IllegalArgumentException(
                                "An Alloy type column must not be blank");
                    }
                }
            }
            validateShape();
            if (!Objects.equals(stableString, buildStableString())) {
                throw new IllegalArgumentException(
                        "Serialized Alloy type stable key is inconsistent");
            }
        } catch (NullPointerException | IllegalArgumentException exception) {
            InvalidObjectException invalid = new InvalidObjectException(
                    "Invalid serialized exact Alloy type: " + exception.getMessage());
            invalid.initCause(exception);
            throw invalid;
        }
    }

    private Object readResolve() throws ObjectStreamException {
        try {
            return new ExactAlloyType(kind, alternatives, relationArity);
        } catch (NullPointerException | IllegalArgumentException exception) {
            InvalidObjectException invalid = new InvalidObjectException(
                    "Invalid serialized exact Alloy type: " + exception.getMessage());
            invalid.initCause(exception);
            throw invalid;
        }
    }

    @Override
    public boolean equals(Object other) {
        return other instanceof ExactAlloyType
                && kind == ((ExactAlloyType) other).kind
                && relationArity == ((ExactAlloyType) other).relationArity
                && alternatives.equals(((ExactAlloyType) other).alternatives);
    }

    @Override
    public int hashCode() {
        return Objects.hash(kind, alternatives, relationArity);
    }

    @Override
    public String toString() {
        return stableString;
    }
}
