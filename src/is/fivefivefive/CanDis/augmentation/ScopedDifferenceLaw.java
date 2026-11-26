package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import java.util.Map;
import java.util.Optional;

/** Command-local reading of #(R-S) = #R iff no R & S. Never consults a SAT instance. */
public final class ScopedDifferenceLaw {
    private ScopedDifferenceLaw() {}

    public record Operand(Sig.Field field, boolean transposed) {}
    public record Bound(Operand operand, Sig.PrimSig first, int firstCap, Sig.PrimSig second, int secondCap) {
        public long product() { return (long)firstCap*secondCap; }
    }
    public record Match(Command command, Func counted, Func reference, Operand r, Operand s,
                        int bitwidth, Bound bound) {}

    private static Expr unary(Expr e,ExprUnary.Op op) {
        return e!=null && e.deNOP() instanceof ExprUnary u && u.op==op ? u.sub.deNOP() : null;
    }
    private static ExprBinary binary(Expr e,ExprBinary.Op op) {
        return e!=null && e.deNOP() instanceof ExprBinary b && b.op==op ? b : null;
    }
    private static Operand operand(Expr e) {
        if(e==null) return null;
        Expr trans=unary(e,ExprUnary.Op.TRANSPOSE);
        Expr base=trans!=null ? trans : e.deNOP();
        return base instanceof Sig.Field f && f.type().arity()==2 ? new Operand(f,trans!=null) : null;
    }
    private static Bound bound(Operand arg,Map<Sig.PrimSig,Integer> caps) {
        var types=arg.field.type().fold();
        if(types.size()!=1 || types.get(0).size()!=2) return null;
        var first=types.get(0).get(arg.transposed?1:0); var second=types.get(0).get(arg.transposed?0:1);
        Integer a=caps.get(first), b=caps.get(second);
        return a==null || b==null || first.builtin || second.builtin || a<0 || b<0 ? null :
                new Bound(arg,first,a,second,b);
    }

    static Optional<Match> match(Command cmd,int width,Map<Sig.PrimSig,Integer> caps,
                                 Func a,Func b,Expr x,Expr y) {
        if(width<1 || width>32) return Optional.empty();
        if(unary(x,ExprUnary.Op.NO)!=null) return read(cmd,width,caps,b,a,y,x);
        return read(cmd,width,caps,a,b,x,y);
    }
    private static Optional<Match> read(Command cmd,int width,Map<Sig.PrimSig,Integer> caps,
                                        Func a,Func b,Expr counted,Expr reference) {
        var eq=binary(counted,ExprBinary.Op.EQUALS);
        var meet=binary(unary(reference,ExprUnary.Op.NO),ExprBinary.Op.INTERSECT);
        if(eq==null || meet==null) return Optional.empty();
        var left=unary(eq.left,ExprUnary.Op.CARDINALITY); var right=unary(eq.right,ExprUnary.Op.CARDINALITY);
        var sub=binary(left,ExprBinary.Op.MINUS); var whole=operand(right);
        if(sub==null) { sub=binary(right,ExprBinary.Op.MINUS); whole=operand(left); }
        if(sub==null || whole==null) return Optional.empty();
        var r=operand(sub.left); var s=operand(sub.right);
        var u=operand(meet.left); var v=operand(meet.right);
        if(!whole.equals(r) || s==null || !(r.equals(u) && s.equals(v) || r.equals(v) && s.equals(u)))
            return Optional.empty();
        var cap=bound(r,caps); var other=bound(s,caps);
        if(cap==null || other!=null && other.product()<cap.product()) cap=other;
        return cap!=null && cap.product()<(1L<<width) ?
                Optional.of(new Match(cmd,a,b,r,s,width,cap)) : Optional.empty();
    }
}
