package is.fivefivefive.ACGN.alloy;

/*
 * A signature in the Alloy model as a set. 
 * One of the symbols in the AAME.
 */
public class SigSymbol extends SetSymbol {
    public static final String BUILTIN_NONE_IDENTITY = "alloy/builtin/none";
    public static final String BUILTIN_UNIV_IDENTITY = "alloy/builtin/univ";

    public enum Kind {
        USER,
        BUILTIN_NONE,
        BUILTIN_UNIV
    }

    private final String name;
    private final Kind kind;

    public SigSymbol(String n) {
        this(n, Kind.USER);
    }

    private SigSymbol(String name, Kind kind) {
        this.name = java.util.Objects.requireNonNull(name, "signature name");
        this.kind = java.util.Objects.requireNonNull(kind, "signature kind");
    }

    public static SigSymbol builtinNone() {
        return new SigSymbol("none", Kind.BUILTIN_NONE);
    }

    public static SigSymbol builtinUniv() {
        return new SigSymbol("univ", Kind.BUILTIN_UNIV);
    }

    public Kind getKind() {
        return kind;
    }

    public String getSemanticIdentity() {
        switch (kind) {
            case BUILTIN_NONE:
                return BUILTIN_NONE_IDENTITY;
            case BUILTIN_UNIV:
                return BUILTIN_UNIV_IDENTITY;
            case USER:
            default:
                return "alloy/signature/" + name;
        }
    }
    @Override
    public String getName() {
        return name;
    }
    @Override
    public String getType() {
        return "Signature";
    }
    @Override
    public boolean isEndSymbol() {
        return false;
    }
    @Override
    public int hashCode() {
        return java.util.Objects.hash(name, kind);
    }
    @Override
    public boolean equals(Object o) {
        if (o instanceof SigSymbol) {
            SigSymbol other = (SigSymbol) o;
            return this.name.equals(other.getName()) && this.kind == other.kind;
        } else {
            return false;
        }
    }
    @Override
    public int getMaxDownlinks() {
        return 0; // SigSymbol does not have downlinks
    }
    @Override
    public void setMaxDownlinks(int maxDownlinks) {
        // SigSymbol does not have downlinks, so this method does nothing
    }
}
