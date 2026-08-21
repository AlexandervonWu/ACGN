package is.fivefivefive.ACGN.alloy;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * Independently fixed callable signatures for Alloy library modules accepted
 * by the source adapter. Unknown modules and members are intentionally absent.
 */
public final class AlloyLibraryCallableLedger {
    public static final String VERSION = "alloy-library-callables-v1";

    private static final Map<String, Signature> SIGNATURES = signatures();

    private AlloyLibraryCallableLedger() {
    }

    public static Signature require(
            String module,
            String member,
            CallSymbol.Kind expectedKind) {
        Signature signature = SIGNATURES.get(key(module, member));
        if (signature == null) {
            throw new IllegalStateException(
                    "Imported call lacks an independently pinned declaration: "
                            + module + "/" + member);
        }
        if (signature.kind != expectedKind) {
            throw new IllegalStateException(
                    "Imported call kind disagrees with pinned declaration for "
                            + module + "/" + member);
        }
        return signature;
    }

    private static Map<String, Signature> signatures() {
        Map<String, Signature> signatures = new HashMap<>();
        expression(signatures, "util/ordering", "first", 0);
        expression(signatures, "util/ordering", "last", 0);
        expression(signatures, "util/ordering", "prev", 0);
        expression(signatures, "util/ordering", "next", 0);
        expression(signatures, "util/ordering", "prevs", 1);
        expression(signatures, "util/ordering", "nexts", 1);
        formula(signatures, "util/ordering", "lt", 2);
        formula(signatures, "util/ordering", "gt", 2);
        formula(signatures, "util/ordering", "lte", 2);
        formula(signatures, "util/ordering", "gte", 2);
        expression(signatures, "util/ordering", "larger", 2);
        expression(signatures, "util/ordering", "smaller", 2);
        expression(signatures, "util/ordering", "max", 1);
        expression(signatures, "util/ordering", "min", 1);
        return Collections.unmodifiableMap(signatures);
    }

    private static void expression(
            Map<String, Signature> signatures,
            String module,
            String member,
            int arity) {
        put(signatures, module, member, arity, CallSymbol.Kind.EXPRESSION);
    }

    private static void formula(
            Map<String, Signature> signatures,
            String module,
            String member,
            int arity) {
        put(signatures, module, member, arity, CallSymbol.Kind.FORMULA);
    }

    private static void put(
            Map<String, Signature> signatures,
            String module,
            String member,
            int arity,
            CallSymbol.Kind kind) {
        Signature previous = signatures.put(
                key(module, member), new Signature(arity, kind));
        if (previous != null) {
            throw new IllegalStateException(
                    "Duplicate imported callable signature: " + module + "/" + member);
        }
    }

    private static String key(String module, String member) {
        return Objects.requireNonNull(module, "module") + "/"
                + Objects.requireNonNull(member, "member");
    }

    public static final class Signature {
        private final int arity;
        private final CallSymbol.Kind kind;

        private Signature(int arity, CallSymbol.Kind kind) {
            this.arity = arity;
            this.kind = kind;
        }

        public int arity() {
            return arity;
        }

        public CallSymbol.Kind kind() {
            return kind;
        }
    }
}
