package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import java.util.*;
import static edu.mit.csail.sdg.ast.ExprBinary.Op.*;
import static is.fivefivefive.CanDis.augmentation.ScopedOperands.*;
import static is.fivefivefive.CanDis.augmentation.SplitClassifier.*;

/** Projection and relative complement of a typed comprehension. */
final class ClassifiedSet {
    private ClassifiedSet() {}
    static Arm read(Expr source,int width) {
        var eq=binary(source,EQUALS); if(eq==null) return null;
        Expr s=eq.left.deNOP(), body=eq.right.deNOP();
        if(!(s instanceof Sig)) {var swap=s; s=body; body=swap;}
        if(!(s instanceof Sig selected) || selected.builtin) return null;
        var minus=binary(body,MINUS);
        if(minus!=null && minus.left.deNOP() instanceof Sig d &&
                minus.right.deNOP() instanceof ExprQt q && q.op==ExprQt.Op.COMPREHENSION &&
                q.decls.size()==1 && ScopedOperands.singletonDomain(q.decls.get(0))==d &&
                !d.builtin && ScopedOperands.contained(selected,d)) {
            var r=ScopedClassifier.test(q.sub,q.decls.get(0).names.get(0),d,selected,true,width);
            return r==null?null:new Arm(Role.BOTH,source,q.decls,r,Shape.DIFFERENCE);
        }
        var join=binary(body,JOIN); if(join==null) return null;
        boolean left=join.left.deNOP() instanceof Sig;
        Expr project=(left?join.left:join.right).deNOP(), relation=(left?join.right:join.left).deNOP();
        if(!(project instanceof Sig outer) || outer.builtin || !(relation instanceof ExprQt q) ||
                q.op!=ExprQt.Op.COMPREHENSION) return null;
        var slots=new ArrayList<ExprVar>(2); var domains=new ArrayList<Sig>(2);
        for(var decl:q.decls) {
            if(decl.disjoint!=null || decl.disjoint2!=null || decl.isVar!=null ||
                    !(sub(decl.expr,ExprUnary.Op.ONEOF) instanceof Sig d) || d.builtin) return null;
            for(var name:decl.names) {
                if(!(name instanceof ExprVar v) || slots.size()==2 || slots.contains(v)) return null;
                slots.add(v); domains.add(d);
            }
        }
        if(slots.size()!=2) return null;
        int wi=left?0:1, oi=1-wi;
        var w=slots.get(wi); var x=slots.get(oi); var d=domains.get(oi);
        var parts=halves(q.sub.deNOP());
        if(!ScopedOperands.contained(selected,d) || parts.size()!=2) return null;
        for(int i=0;i<2;i++) {
            var in=binary(parts.get(i),IN); if(in==null) continue;
            var pair=binary(in.left,ARROW); if(pair==null) continue;
            boolean column=pair.left.deNOP()==w && pair.right.deNOP()==x;
            if(!column && !(pair.left.deNOP()==x && pair.right.deNOP()==w)) continue;
            var converse=sub(in.right,ExprUnary.Op.TRANSPOSE); column^=converse!=null;
            if(!((converse==null?in.right.deNOP():converse) instanceof Sig.Field f)) continue;
            var r=ScopedClassifier.test(parts.get(1-i),x,d,selected,false,width);
            if(r==null || r.key().field()!=f || r.key().column()!=column || !rejectsZero(r.key())) continue;
            var products=f.type().fold(); if(products.size()!=1 || products.get(0).size()!=2) continue;
            var varying=products.get(0).get(column?0:1);
            if(ScopedOperands.contained(varying,outer) && ScopedOperands.contained(varying,domains.get(wi)))
                return new Arm(Role.BOTH,source,q.decls,r,Shape.PROJECTION);
        }
        return null;
    }
    static boolean rejectsZero(ScopedClassifier.Key k) {
        int n=k.literal();
        return switch(k.op()) {
            case EQUALS -> n!=0; case NOT_EQUALS -> n==0;
            case GT -> 0<=n; case GTE -> 0<n;
            case LT -> 0>=n; case LTE -> 0>n;
            default -> throw new IllegalArgumentException("non-comparison "+k.op());
        };
    }
}
