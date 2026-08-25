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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import edu.mit.csail.sdg.ast.Sig.PrimSig;
import edu.mit.csail.sdg.ast.Sig;
import edu.mit.csail.sdg.ast.Type;
import edu.mit.csail.sdg.alloy4.Pos;
import edu.mit.csail.sdg.parser.CompModule;

/** Serializable occurrence-level image of Alloy's exact expression type. */
public final class ExactAlloyType implements Serializable {
    private static final long serialVersionUID = 3L;

    public enum Kind {
        BOOL,
        INT,
        RELATION,
        EMPTY_RELATION,
        UNKNOWN
    }

    private final Kind kind;
    private final List<List<String>> alternatives;
    private final List<List<List<String>>> ancestryAlternatives;
    private final int relationArity;
    private final String stableString;
    private final transient CompModule parserModuleAuthority;

    private ExactAlloyType(
            Kind kind,
            List<? extends List<String>> alternatives,
            int relationArity) {
        this(kind, alternatives, singletonAncestries(alternatives), relationArity, null);
    }

    private ExactAlloyType(
            Kind kind,
            List<? extends List<String>> alternatives,
            List<? extends List<? extends List<String>>> ancestryAlternatives,
            int relationArity) {
        this(kind, alternatives, ancestryAlternatives, relationArity, null);
    }

    private ExactAlloyType(
            Kind kind,
            List<? extends List<String>> alternatives,
            List<? extends List<? extends List<String>>> ancestryAlternatives,
            int relationArity,
            CompModule parserModuleAuthority) {
        this.kind = Objects.requireNonNull(kind, "kind");
        Objects.requireNonNull(alternatives, "alternatives");
        Objects.requireNonNull(ancestryAlternatives, "ancestryAlternatives");
        if (alternatives.size() != ancestryAlternatives.size()) {
            throw new IllegalArgumentException(
                    "Alloy type alternatives and ancestry proofs differ in arity");
        }
        List<AlternativeShape> shapes = new ArrayList<>();
        for (int alternativeIndex = 0;
                alternativeIndex < alternatives.size();
                alternativeIndex++) {
            List<String> alternative = alternatives.get(alternativeIndex);
            List<String> columns = new ArrayList<>();
            for (String column : alternative) {
                columns.add(normalizeColumn(column));
            }
            List<? extends List<String>> ancestry = ancestryAlternatives.get(
                    alternativeIndex);
            if (ancestry.size() != columns.size()) {
                throw new IllegalArgumentException(
                        "Every Alloy relation column requires one ancestry proof");
            }
            List<List<String>> copiedAncestry = new ArrayList<>();
            for (int columnIndex = 0; columnIndex < columns.size(); columnIndex++) {
                copiedAncestry.add(copyAncestry(
                        columns.get(columnIndex), ancestry.get(columnIndex)));
            }
            shapes.add(new AlternativeShape(
                    Collections.unmodifiableList(columns),
                    Collections.unmodifiableList(copiedAncestry)));
        }
        shapes.sort(Comparator.comparing(shape -> tupleKey(shape.columns)));
        validateAncestryLedger(shapes);
        List<List<String>> copied = new ArrayList<>(shapes.size());
        List<List<List<String>>> copiedAncestries = new ArrayList<>(shapes.size());
        for (AlternativeShape shape : shapes) {
            copied.add(shape.columns);
            copiedAncestries.add(shape.ancestries);
        }
        this.alternatives = Collections.unmodifiableList(copied);
        this.ancestryAlternatives = Collections.unmodifiableList(copiedAncestries);
        this.relationArity = relationArity;
        this.parserModuleAuthority = parserModuleAuthority;
        validateShape();
        this.stableString = buildStableString();
    }

    public static ExactAlloyType from(Type type) {
        return from(type, Collections.emptySet(), null);
    }

    /** Convert a type while binding nontrivial ancestry to one parsed module. */
    public static ExactAlloyType fromParser(Type type, CompModule sourceModule) {
        CompModule checkedModule = Objects.requireNonNull(
                sourceModule, "sourceModule");
        return from(type, parserSignatures(checkedModule), checkedModule);
    }

    private static ExactAlloyType from(
            Type type,
            java.util.Set<PrimSig> parserSignatures,
            CompModule sourceModule) {
        if (type == null) {
            return unknownType();
        }
        if (type.is_bool) {
            return boolType();
        }
        if (type.is_int()) {
            return intType();
        }
        Map<String, AlternativeShape> tuples = new LinkedHashMap<>();
        java.util.Set<Integer> emptyArities = new java.util.TreeSet<>();
        boolean parserAuthenticatedAncestry = !parserSignatures.isEmpty();
        for (Type.ProductType product : type) {
            if (product.isEmpty()) {
                if (product.arity() > 0) {
                    emptyArities.add(product.arity());
                }
                continue;
            }
            List<String> columns = new ArrayList<>(product.arity());
            List<List<String>> ancestries = new ArrayList<>(product.arity());
            for (int index = 0; index < product.arity(); index++) {
                PrimSig column = product.get(index);
                columns.add(normalizeColumn(column.label));
                ancestries.add(ancestryOf(column));
                parserAuthenticatedAncestry &= hasParserAuthenticatedParents(
                        column, parserSignatures);
            }
            AlternativeShape shape = new AlternativeShape(
                    Collections.unmodifiableList(columns),
                    Collections.unmodifiableList(ancestries));
            AlternativeShape previous = tuples.putIfAbsent(tupleKey(columns), shape);
            if (previous != null && !previous.equals(shape)) {
                throw new IllegalStateException(
                        "One Alloy type tuple has conflicting primitive-signature ancestry");
            }
        }
        if (tuples.isEmpty()) {
            return type.hasNoTuple() && emptyArities.size() == 1
                    ? emptyRelation(emptyArities.iterator().next())
                    : unknownType();
        }
        int arity = tuples.values().iterator().next().columns.size();
        for (AlternativeShape tuple : tuples.values()) {
            if (tuple.columns.size() != arity) {
                return unknownType();
            }
        }
        List<List<String>> alternatives = new ArrayList<>();
        List<List<List<String>>> ancestry = new ArrayList<>();
        for (AlternativeShape tuple : tuples.values()) {
            alternatives.add(tuple.columns);
            ancestry.add(tuple.ancestries);
        }
        return new ExactAlloyType(
                Kind.RELATION,
                alternatives,
                ancestry,
                arity,
                parserAuthenticatedAncestry ? sourceModule : null);
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

    /** Per-alternative, per-column paths from the exact PrimSig to its ancestors. */
    public List<List<List<String>>> ancestryAlternatives() {
        return ancestryAlternatives;
    }

    /** True only for module-owned, parser-positioned parent evidence; never survives serialization. */
    public boolean hasParserAuthenticatedAncestry() {
        return parserModuleAuthority != null;
    }

    /**
     * Runtime-only proof that two exact types came from the identical parser
     * module object. This capability is deliberately absent from value
     * equality, stable keys, and serialized state.
     */
    public boolean sharesParserModuleAuthorityWith(ExactAlloyType other) {
        return other != null
                && parserModuleAuthority != null
                && parserModuleAuthority == other.parserModuleAuthority;
    }

    /**
     * Equality for one source occurrence. Value equality deliberately omits
     * runtime parser authority, but an occurrence store must not merge two
     * equal-looking types whose ancestry came from different parser modules.
     */
    public boolean sameOccurrenceEvidenceAs(ExactAlloyType other) {
        return other != null
                && equals(other)
                && ancestryAlternatives.equals(other.ancestryAlternatives)
                && parserModuleAuthority == other.parserModuleAuthority;
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
            if (ancestryAlternatives.size() != alternatives.size()) {
                throw new IllegalArgumentException(
                        "Relation alternatives and ancestry proofs differ in arity");
            }
            for (int alternativeIndex = 0;
                    alternativeIndex < alternatives.size();
                    alternativeIndex++) {
                List<String> alternative = alternatives.get(alternativeIndex);
                List<List<String>> ancestry = ancestryAlternatives.get(alternativeIndex);
                if (ancestry.size() != alternative.size()) {
                    throw new IllegalArgumentException(
                            "Every relation column requires one ancestry proof");
                }
                for (int columnIndex = 0;
                        columnIndex < alternative.size();
                        columnIndex++) {
                    copyAncestry(
                            alternative.get(columnIndex), ancestry.get(columnIndex));
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
        if (relationArity != -1 || !alternatives.isEmpty()
                || !ancestryAlternatives.isEmpty()) {
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

    static String normalizeColumn(String value) {
        String checked = requireAdmittedIdentity(value, "column");
        String normalized = checked.startsWith("this/")
                ? checked.substring(5) : checked;
        if (normalized.isEmpty() || normalized.startsWith("this/")) {
            throw new IllegalArgumentException(
                    "An Alloy type column must have one canonical identity after its module prefix");
        }
        return normalized;
    }

    private static List<String> ancestryOf(PrimSig column) {
        List<String> result = new ArrayList<>();
        java.util.Set<PrimSig> seen = Collections.newSetFromMap(
                new java.util.IdentityHashMap<>());
        PrimSig current = Objects.requireNonNull(column, "column");
        while (current != null) {
            if (!seen.add(current)) {
                throw new IllegalStateException(
                        "Alloy primitive-signature ancestry contains a cycle");
            }
            result.add(normalizeColumn(current.label));
            current = current.parent;
        }
        return Collections.unmodifiableList(result);
    }

    private static java.util.Set<PrimSig> parserSignatures(CompModule sourceModule) {
        java.util.Set<PrimSig> result = Collections.newSetFromMap(
                new java.util.IdentityHashMap<>());
        for (Sig signature : sourceModule.getAllReachableSigs()) {
            if (!(signature instanceof PrimSig)) {
                continue;
            }
            PrimSig current = (PrimSig) signature;
            while (current != null && result.add(current)) {
                current = current.parent;
            }
        }
        result.add(Sig.UNIV);
        result.add(Sig.SIGINT);
        result.add(Sig.SEQIDX);
        result.add(Sig.STRING);
        result.add(Sig.NONE);
        return result;
    }

    private static boolean hasParserAuthenticatedParents(
            PrimSig column,
            java.util.Set<PrimSig> parserSignatures) {
        PrimSig current = Objects.requireNonNull(column, "column");
        if (!parserSignatures.contains(current)) {
            return false;
        }
        java.util.Set<PrimSig> seen = Collections.newSetFromMap(
                new java.util.IdentityHashMap<>());
        while (current.parent != null && current.parent != Sig.UNIV) {
            if (!seen.add(current)) {
                throw new IllegalStateException(
                        "Alloy primitive-signature ancestry contains a cycle");
            }
            Pos declaration = current.isSubsig;
            if (!parserSignatures.contains(current.parent)
                    || (!isTrustedBuiltinParentEdge(current, current.parent)
                            && (declaration == null
                                    || Pos.UNKNOWN.equals(declaration)
                                    || declaration.filename == null
                                    || declaration.filename.isBlank()))) {
                return false;
            }
            current = current.parent;
        }
        return true;
    }

    private static boolean isTrustedBuiltinParentEdge(
            PrimSig child,
            PrimSig parent) {
        return child == Sig.SEQIDX && parent == Sig.SIGINT;
    }

    private static List<String> copyAncestry(
            String exactColumn,
            List<String> ancestry) {
        Objects.requireNonNull(ancestry, "ancestry");
        if (ancestry.isEmpty()) {
            throw new IllegalArgumentException(
                    "An Alloy relation column ancestry must not be empty");
        }
        List<String> copied = new ArrayList<>(ancestry.size());
        java.util.Set<String> seen = new LinkedHashSet<>();
        for (String ancestor : ancestry) {
            String checked = normalizeColumn(ancestor);
            if (!seen.add(checked)) {
                throw new IllegalArgumentException(
                        "An Alloy relation ancestry must be nonblank and acyclic");
            }
            copied.add(checked);
        }
        if (!exactColumn.equals(copied.get(0))) {
            throw new IllegalArgumentException(
                    "An Alloy relation ancestry must start at its exact column");
        }
        int univ = copied.indexOf("univ");
        if (univ >= 0 && univ + 1 != copied.size()) {
            throw new IllegalArgumentException(
                    "Alloy univ must terminate a relation ancestry");
        }
        return Collections.unmodifiableList(copied);
    }

    static String requireAdmittedIdentity(
            String value,
            String role) {
        String checked = Objects.requireNonNull(value, role);
        if (!isAdmittedIdentity(checked)) {
            throw new IllegalArgumentException(
                    "An Alloy type " + role + " must be a well-formed visible identity");
        }
        return checked;
    }

    public static boolean isAdmittedIdentity(String value) {
        return value != null
                && !value.isEmpty()
                && value.codePoints().noneMatch(
                        ExactAlloyType::isForbiddenIdentityCodePoint);
    }

    private static boolean isForbiddenIdentityCodePoint(int codePoint) {
        int type = Character.getType(codePoint);
        return Character.isWhitespace(codePoint)
                || Character.isSpaceChar(codePoint)
                || Character.isISOControl(codePoint)
                || type == Character.FORMAT
                || type == Character.SURROGATE
                || type == Character.PRIVATE_USE
                || type == Character.UNASSIGNED;
    }

    private static void validateAncestryLedger(List<AlternativeShape> shapes) {
        Map<String, String> directParents = new LinkedHashMap<>();
        for (AlternativeShape shape : shapes) {
            for (List<String> path : shape.ancestries) {
                for (int index = 1; index < path.size(); index++) {
                    String child = path.get(index - 1);
                    String parent = path.get(index);
                    String previous = directParents.putIfAbsent(child, parent);
                    if (previous != null && !previous.equals(parent)) {
                        throw new IllegalArgumentException(
                                "One Alloy signature has conflicting direct parents");
                    }
                }
            }
        }
        for (String start : directParents.keySet()) {
            java.util.Set<String> seen = new LinkedHashSet<>();
            String current = start;
            while (current != null) {
                if (!seen.add(current)) {
                    throw new IllegalArgumentException(
                            "Alloy relation ancestry contains a cross-path cycle");
                }
                current = directParents.get(current);
            }
        }
    }

    private static List<List<List<String>>> singletonAncestries(
            List<? extends List<String>> alternatives) {
        Objects.requireNonNull(alternatives, "alternatives");
        List<List<List<String>>> result = new ArrayList<>();
        for (List<String> alternative : alternatives) {
            List<List<String>> tuple = new ArrayList<>();
            for (String column : alternative) {
                tuple.add(Collections.singletonList(column));
            }
            result.add(tuple);
        }
        return result;
    }

    private void readObject(ObjectInputStream input)
            throws IOException, ClassNotFoundException {
        input.defaultReadObject();
        try {
            Objects.requireNonNull(kind, "kind");
            Objects.requireNonNull(alternatives, "alternatives");
            Objects.requireNonNull(ancestryAlternatives, "ancestryAlternatives");
            for (List<String> alternative : alternatives) {
                Objects.requireNonNull(alternative, "alternative");
                for (String column : alternative) {
                    requireAdmittedIdentity(column, "column");
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
            return new ExactAlloyType(
                    kind, alternatives, ancestryAlternatives, relationArity, null);
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

    private static final class AlternativeShape {
        private final List<String> columns;
        private final List<List<String>> ancestries;

        private AlternativeShape(
                List<String> columns,
                List<List<String>> ancestries) {
            this.columns = columns;
            this.ancestries = ancestries;
        }

        @Override
        public boolean equals(Object other) {
            return other instanceof AlternativeShape
                    && columns.equals(((AlternativeShape) other).columns)
                    && ancestries.equals(((AlternativeShape) other).ancestries);
        }

        @Override
        public int hashCode() {
            return Objects.hash(columns, ancestries);
        }
    }
}
