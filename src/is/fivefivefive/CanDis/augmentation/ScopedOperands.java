package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import java.util.IdentityHashMap;

/** Source guards shared by the isolated command readers. Compare parser objects by identity. */
final class ScopedOperands {
    private ScopedOperands() {}

    static Expr sub(Expr e, ExprUnary.Op op) {
        return e != null && e.deNOP() instanceof ExprUnary u && u.op == op ? u.sub.deNOP() : null;
    }
    static ExprBinary binary(Expr e, ExprBinary.Op op) {
        return e != null && e.deNOP() instanceof ExprBinary b && b.op == op ? b : null;
    }
    static Sig.Field row(Expr e, ExprVar x) {
        var j = binary(e, ExprBinary.Op.JOIN);
        return j != null && j.left.deNOP() == x && j.right.deNOP() instanceof Sig.Field f ? f : null;
    }
    static Expr singletonDomain(Decl d) {
        return d.names.size()==1 && d.names.get(0) instanceof ExprVar && d.disjoint==null
                && d.disjoint2==null && d.isVar==null && d.expr.deNOP() instanceof ExprUnary u
                && u.op==ExprUnary.Op.ONEOF && u.sub.type().arity()==1 ? u.sub.deNOP() : null;
    }
    private static boolean staticCarrier(Sig sig) {
        return sig instanceof Sig.PrimSig prim && !sig.builtin && prim.parent==Sig.UNIV
                && sig.isVariable==null && sig.type().arity()==1;
    }
    static Sig target(Sig.Field f) {
        return !f.defined && f.type().arity()==2 && staticCarrier(f.sig)
                && sub(f.decl().expr,ExprUnary.Op.SETOF) instanceof Sig r && staticCarrier(r) ? r : null;
    }
    static boolean contained(Sig s, Sig d) {
        return contained(s,d,new IdentityHashMap<>());
    }
    private static boolean contained(Sig s, Sig d, IdentityHashMap<Sig,Boolean> memo) {
        if (s==d) return true;
        if (s==null || s.builtin) return false;
        var known=memo.get(s);
        if (known!=null) return known;
        // An Alloy subset signature may have a union of parents; all must be contained.
        boolean result=s instanceof Sig.PrimSig p ? contained(p.parent,d,memo)
                : s instanceof Sig.SubsetSig u && !u.parents.isEmpty()
                    && u.parents.stream().allMatch(p -> contained(p,d,memo));
        memo.put(s,result);
        return result;
    }
}
