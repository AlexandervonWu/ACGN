package is.fivefivefive.CanDis.theory;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Objects;

/** Independently fixed exact-column theory for guarded JOIN and ARROW reassociation. */
public final class DependentChainTheory {
    public enum LeafTypeRule {
        EXACT_RELATION,
        PRIMITIVE_SET_SINGLETON
    }

    public static final String VERSION = "alloy-dependent-chain-theory-v4";
    public static final String SOURCE_TEXT = String.join("\n",
            "JOIN:ordered;boundary=last(left)==first(right);result=init(left)++tail(right)",
            "JOIN-FLAT-GUARD:every interior source operand has at least two columns",
            "ARROW:ordered;result=columns(left)++columns(right)",
            "LEAF:exact relation or Int/AlloyCarrier primitive singleton; no name-based parameter authority",
            "POLYMORPHIC-UNIV:no dependent-chain reassociation certificate",
            "laws=guarded-associativity-only;no-commutativity;no-idempotency;no-unit");
    public static final String DIGEST = sha256(VERSION + "\n" + SOURCE_TEXT);

    private DependentChainTheory() {
    }

    /** Signals a valid expression whose source types do not license reassociation. */
    public static final class UnsupportedFlattening extends IllegalArgumentException {
        private UnsupportedFlattening(String message) {
            super(message);
        }
    }

    public static void requireSoundFlattening(
            DependentChainKind kind,
            List<GraphType> operandTypes) {
        Objects.requireNonNull(kind, "kind");
        Objects.requireNonNull(operandTypes, "operandTypes");
        if (operandTypes.size() < 2) {
            throw new IllegalArgumentException(
                    "A dependent chain requires at least two operands");
        }
        for (GraphType operand : operandTypes) {
            GraphType checked = Objects.requireNonNull(operand, "operand type");
            if (checked.kind()
                    != GraphType.Kind.RELATION) {
                throw new IllegalArgumentException(
                        "A dependent-chain operand is not an exact relation type");
            }
            if (containsAlloyUniv(checked)) {
                throw new UnsupportedFlattening(
                        "A polymorphic univ operand has no dependent-chain license");
            }
        }
        if (kind == DependentChainKind.JOIN && operandTypes.size() > 2) {
            for (int index = 1; index + 1 < operandTypes.size(); index++) {
                if (operandTypes.get(index).arguments().size() < 2) {
                    throw new UnsupportedFlattening(
                            "JOIN reassociation requires every interior operand "
                                    + "to retain distinct left and right boundary columns");
                }
            }
        }
    }

    public static StructuralKey proofIndex(
            DependentChainKind kind,
            List<GraphType> operandTypes,
            GraphType resultType) {
        List<StructuralKey> children = new ArrayList<>();
        requireSoundFlattening(kind, operandTypes);
        for (GraphType operand : operandTypes) {
            children.add(TheoryKeys.type(operand));
        }
        children.add(TheoryKeys.type(resultType));
        return StructuralKey.of(
                "dependent-chain-theory-index-v1",
                List.of(VERSION, DIGEST, kind.name()),
                children);
    }

    public static LeafTypeRule requireLeafTypeProof(
            GraphType storedType,
            GraphType relationType) {
        if (relationType.kind() != GraphType.Kind.RELATION) {
            throw new IllegalArgumentException(
                    "A dependent-chain relation view is not a relation: "
                            + relationType);
        }
        if (storedType.equals(relationType)) {
            return LeafTypeRule.EXACT_RELATION;
        }
        if (relationType.arguments().size() != 1) {
            throw new IllegalArgumentException(
                    "A primitive set slot can justify only a unary relation view");
        }
        GraphType expectedColumn = primitiveRelationColumn(storedType);
        if (expectedColumn == null
                || !expectedColumn.equals(relationType.arguments().get(0))) {
            throw new IllegalArgumentException(
                    "Stored primitive type " + storedType
                            + " does not justify relation view " + relationType);
        }
        return LeafTypeRule.PRIMITIVE_SET_SINGLETON;
    }

    public static GraphType relationViewFromStoredType(GraphType storedType) {
        Objects.requireNonNull(storedType, "storedType");
        if (storedType.kind() == GraphType.Kind.RELATION) {
            return storedType;
        }
        GraphType column = primitiveRelationColumn(storedType);
        if (column == null) {
            throw new IllegalArgumentException(
                    "No fixed unary relation view for stored type " + storedType);
        }
        return GraphType.relation(column);
    }

    public static StructuralKey leafTypeProof(
            LeafTypeRule rule,
            GraphType storedType,
            GraphType relationType) {
        LeafTypeRule checked = requireLeafTypeProof(storedType, relationType);
        if (rule != checked) {
            throw new IllegalArgumentException(
                    "Dependent-chain leaf proof names another typing rule");
        }
        return StructuralKey.of(
                "dependent-chain-leaf-type-proof-v1",
                List.of(rule.name()),
                List.of(TheoryKeys.type(storedType), TheoryKeys.type(relationType)));
    }

    private static GraphType primitiveRelationColumn(GraphType storedType) {
        if (storedType.equals(GraphType.INT)) {
            return GraphType.INT;
        }
        if (storedType.kind() != GraphType.Kind.CONSTRUCTOR
                || !"AlloyCarrier".equals(storedType.symbol())
                || storedType.arguments().size() != 1) {
            return null;
        }
        GraphType carrier = storedType.arguments().get(0);
        if (carrier.kind() != GraphType.Kind.CONSTRUCTOR
                || !carrier.arguments().isEmpty()) {
            return null;
        }
        return carrier.symbol().startsWith("AlloySig:")
                ? carrier
                : GraphType.constructor("AlloySig:" + carrier.symbol());
    }

    private static boolean containsAlloyUniv(GraphType type) {
        if (type.kind() == GraphType.Kind.CONSTRUCTOR
                && "AlloySig:univ".equals(type.symbol())) {
            return true;
        }
        for (GraphType argument : type.arguments()) {
            if (containsAlloyUniv(argument)) {
                return true;
            }
        }
        return false;
    }

    private static String sha256(String text) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(text.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new ExceptionInInitializerError(exception);
        }
    }
}
