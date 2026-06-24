package is.fivefivefive.CanDis.macros;

import edu.mit.csail.sdg.ast.Type;

/**
 * This class encodes quantified variables. They are defined as "slots" in the quantification system
 * invariants: variables are up to De Bruijn indices, but still have names; most importantly, encoding types.
 */
public class QuantiVar {
    public enum Quantifier {
        SUM,
        COMPREHENSION,
        ALL,
        SOME,
        NO,
        ONE,
        LONE,
        NOTONE,
        NOTLONE
    }

    private int id;
    private String name;
    private String originalName;
    private Type type;
    private String typeName;
    private String deBruijnKey;
    private Quantifier quantifier;
    private boolean disj;
    private String bindingPath;
    public QuantiVar(int id, String name, Type type) {
        this.id = id;
        this.name = name;
        this.originalName = name;
        this.type = type;
        this.typeName = type == null ? null : type.toString();
        this.deBruijnKey = name;
        this.quantifier = Quantifier.SOME;
        this.disj = false;
        this.bindingPath = "";
    }
    public QuantiVar(int id, String name, String typeName) {
        this(id, name, name, typeName);
    }
    public QuantiVar(int id, String name, String originalName, String typeName) {
        this.id = id;
        this.name = name;
        this.originalName = originalName;
        this.type = null;
        this.typeName = typeName;
        this.deBruijnKey = name;
        this.quantifier = Quantifier.SOME;
        this.disj = false;
        this.bindingPath = "";
    }
    public int getId() {
        return id;
    }
    public String getName() {
        return name;
    }
    public String getOriginalName() {
        return originalName;
    }
    public Type getType() {
        return type;
    }
    public String getTypeName() {
        return typeName;
    }
    public String getDeBruijnKey() {
        return deBruijnKey == null ? name : deBruijnKey;
    }
    public void setDeBruijnKey(String deBruijnKey) {
        this.deBruijnKey = deBruijnKey;
    }
    public Quantifier getQuantifier() {
        return quantifier;
    }
    public void setQuantifier(Quantifier quantifier) {
        this.quantifier = quantifier == null ? Quantifier.SOME : quantifier;
    }
    public boolean isDisj() {
        return disj;
    }
    public void setDisj(boolean disj) {
        this.disj = disj;
    }
    public String getBindingPath() {
        return bindingPath == null ? "" : bindingPath;
    }
    public void setBindingPath(String bindingPath) {
        this.bindingPath = bindingPath == null ? "" : bindingPath;
    }
    public boolean equals(Object o) {
        if (o == this) return true;
        if (!(o instanceof QuantiVar)) return false;
        QuantiVar qv = (QuantiVar) o;
        return this.id == qv.id;
    }
    public int hashCode() {
        return id;
    }
    public boolean sameType(QuantiVar qv) {
        if (this.typeName != null) {
            return this.typeName.equals(qv.typeName);
        }
        return this.type != null && this.type.equals(qv.type);
    }
    public String toString() {
        // in JSON form
        return "{\"id\": " + id + ", \"name\": \"" + name + "\", \"originalName\": \"" + originalName
                + "\", \"type\": \"" + typeName + "\", \"quantifier\": \"" + quantifier
                + "\", \"disj\": " + disj + ", \"deBruijnKey\": \"" + getDeBruijnKey() + "\"}";
    }
}
