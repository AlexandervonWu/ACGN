package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import java.util.*;
import static edu.mit.csail.sdg.ast.ExprBinary.Op.*;
import static is.fivefivefive.CanDis.augmentation.ScopedOperands.binary;

/** Source obligations of AdaptiveClassifierArms; never manufacture an IFF from one arm. */
public final class SplitClassifier {
    private SplitClassifier() {}
    public enum Role { BOTH, NECESSARY, SUFFICIENT }
    public enum Shape { DIRECT, PROJECTION, DIFFERENCE }
    public record Arm(Role role,Expr source,List<Decl> declarations,ScopedClassifier.Read read,Shape shape) {
        Arm(Role role,Expr source,List<Decl> ds,ScopedClassifier.Read r) {this(role,source,ds,r,Shape.DIRECT);}
    }
    private record Part(Expr source,List<Decl> decls,Expr body) {
        static Part of(Expr expr,List<Decl> outer) {
            var ds=new ArrayList<>(outer); Expr body=expr.deNOP();
            while(body instanceof ExprQt q && q.op==ExprQt.Op.ALL) {
                ds.addAll(q.decls); body=q.sub.deNOP();
            }
            return new Part(expr,List.copyOf(ds),body);
        }
        Arm arm(Role role,ScopedClassifier.Read r) {return r==null?null:new Arm(role,source,decls,r);}
    }
    static List<Expr> halves(Expr e) {
        if(e instanceof ExprList l && l.op==ExprList.Op.AND && l.args.size()==2) return l.args;
        var b=binary(e,AND); return b==null?List.of():List.of(b.left,b.right);
    }
    static List<Arm> read(Expr e,int width) {
        if(width<2 || width>32) return List.of();
        var ordinary=ScopedClassifier.read(e,width);
        if(ordinary!=null) return List.of(new Arm(Role.BOTH,e,List.of(),ordinary));
        var set=ClassifiedSet.read(e,width);
        if(set!=null) return List.of(set);
        var parts=halves(e); List<Decl> outer=List.of();
        if(parts.isEmpty() && e instanceof ExprQt q && q.op==ExprQt.Op.ALL) {
            parts=halves(q.sub.deNOP()); outer=q.decls;
        }
        if(parts.size()!=2) return List.of();
        if(outer.isEmpty()) {
            var a=ScopedClassifier.read(parts.get(0),width); var b=ScopedClassifier.read(parts.get(1),width);
            if(a!=null && b!=null) return List.of(new Arm(Role.BOTH,parts.get(0),outer,a),
                    new Arm(Role.BOTH,parts.get(1),outer,b));
        }
        var p=Part.of(parts.get(0),outer); var q=Part.of(parts.get(1),outer);
        for(int i=0;i<2;i++) {
            var s=sufficient(i==0?p:q,width);
            if(s==null) continue;
            var n=necessary(i==0?q:p,s.read.key(),width);
            if(n!=null) return List.of(n,s);
        }
        return List.of();
    }
    private static Arm sufficient(Part p,int w) {
        var arrow=binary(p.body,IMPLIES); if(arrow==null) return null;
        var in=binary(arrow.right,IN);
        if(in==null || !(in.left.deNOP() instanceof ExprVar x) ||
                !(in.right.deNOP() instanceof Sig s) || s.builtin) return null;
        for(var decl:p.decls) if(decl.names.contains(x)) {
            var ty=ScopedOperands.sub(decl.expr,ExprUnary.Op.ONEOF);
            if(!(ty instanceof Sig d) || d.builtin || decl.isVar!=null || decl.disjoint2!=null) return null;
            if(p.decls.size()==1 && ScopedOperands.singletonDomain(decl)==d)
                return p.arm(Role.SUFFICIENT,ScopedClassifier.test(arrow.left,x,d,s,false,w));
            var wit=FiberWitness.grouped(p.decls,arrow.left,p.source,x,true);
            return wit==null?null:p.arm(Role.SUFFICIENT,ScopedClassifier.witness(d,s,wit,false,w));
        }
        return null;
    }
    private static Arm necessary(Part p,ScopedClassifier.Key key,int w) {
        if(p.decls.size()!=1) return null;
        var decl=p.decls.get(0); var d=ScopedOperands.singletonDomain(decl);
        if(d==null) return null;
        var x=decl.names.get(0); var selected=key.selected(); Expr test=p.body;
        var arrow=binary(test,IMPLIES);
        if(arrow!=null) {
            var in=binary(arrow.left,IN);
            if(d!=key.domain() || in==null || in.left.deNOP()!=x || in.right.deNOP()!=selected) return null;
            test=arrow.right;
        } else if(d!=selected || !ScopedOperands.contained(selected,key.domain())) return null;
        return p.arm(Role.NECESSARY,ScopedClassifier.test(test,x,key.domain(),selected,false,w));
    }
}
