package is.fivefivefive.ACGN.alloy;

import edu.mit.csail.sdg.ast.Decl;
import edu.mit.csail.sdg.ast.ExprBinary;
import edu.mit.csail.sdg.ast.ExprCall;
import edu.mit.csail.sdg.ast.ExprQt;
import edu.mit.csail.sdg.ast.ExprUnary;
import edu.mit.csail.sdg.ast.Func;
import edu.mit.csail.sdg.ast.Sig;
import edu.mit.csail.sdg.parser.CompModule;
import parser.ast.nodes.Call;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.Node;

/** A local predicate whose complete typed body tests one endpoint of a binary field. */
public final class RelationEndpointPredicate {
    private final SigSymbol domain;
    private final String moduleName;
    private final Sig.Field field;
    private final boolean incoming;
    private final ExactAlloyType fieldType;

    private RelationEndpointPredicate(SigSymbol domain, Sig.Field field, boolean incoming, CompModule module) {
        this.domain = domain;
        this.moduleName = module.getModuleName();
        this.field = field;
        this.incoming = incoming;
        this.fieldType = ExactAlloyType.fromParser(field.type(), module);
    }

    public static RelationEndpointPredicate resolve(CompModule module, String name, Call call) {
        Node owner = call;
        while (owner != null && !(owner instanceof ModelUnit)) owner = owner.getParent();
        if (!(owner instanceof ModelUnit tree) || !tree.wasParsedFrom(module)) return null;
        String label = name.startsWith("this/") ? name : "this/" + name;
        Func found = null;
        for (var function : module.getAllFunc()) {
            if (!function.label.equals(label)) continue;
            if (found != null) return null;
            found = function;
        }
        if (call.getNodeMap() != null && (!(call.getNodeMap().findSrc(call) instanceof ExprCall original)
                || original.fun != found)) return null;
        if (found == null || !found.isPred || found.decls.size() != 1 || found.count() != 1
                || !(found.getBody().deNOP() instanceof ExprQt witness) || witness.op != ExprQt.Op.SOME
                || witness.count() != 1 || witness.decls.size() != 1
                || !(witness.sub.deNOP() instanceof ExprBinary test) || test.op != ExprBinary.Op.IN
                || !(test.right.deNOP() instanceof Sig.Field field) || field.isVariable != null
                || !(test.left.deNOP() instanceof ExprBinary tuple) || tuple.op != ExprBinary.Op.ARROW) return null;
        var formal = found.decls.get(0);
        var carrier = formal.expr.deNOP() instanceof Sig.PrimSig sig && !sig.builtin
                && formal.disjoint == null && formal.disjoint2 == null ? sig : singletonDomain(formal);
        if (carrier == null || singletonDomain(witness.decls.get(0)) != carrier || field.sig != carrier
                || carrier.isVariable != null || !field.type().equals(carrier.type().product(carrier.type()))) return null;
        for (var sig : module.getAllReachableSigs()) {
            for (var other : sig.getFields()) {
                if (other != field && other.label.equals(field.label)) return null;
            }
        }
        var x = found.get(0);
        var y = witness.get(0);
        boolean incoming = tuple.left.deNOP() == y && tuple.right.deNOP() == x;
        if (!incoming && !(tuple.left.deNOP() == x && tuple.right.deNOP() == y)) return null;
        return new RelationEndpointPredicate(SigSymbol.fromParser(carrier, module), field, incoming, module);
    }

    private static Sig.PrimSig singletonDomain(Decl declaration) {
        if (declaration.names.size() != 1 || declaration.disjoint != null || declaration.disjoint2 != null
                || !(declaration.expr.deNOP() instanceof ExprUnary unary) || unary.op != ExprUnary.Op.ONEOF
                || !(unary.sub.deNOP() instanceof Sig.PrimSig domain) || domain.builtin) return null;
        return domain;
    }

    public SigSymbol domain() { return domain; }
    public boolean incoming() { return incoming; }
    public boolean matchesField(String name, ExactAlloyType type) {
        return field.label.equals(name) && fieldType.sameOccurrenceEvidenceAs(type);
    }
    public boolean sameDirectedField(RelationEndpointPredicate other) {
        return other != null && field == other.field && incoming == other.incoming;
    }
    public String canonicalIdentity(boolean incomingDirection) {
        return "@endpoint/" + moduleName + "/" + domain.getSemanticIdentity() + "/" + field.label + "/"
                + (incomingDirection ? "incoming" : "outgoing");
    }
}
