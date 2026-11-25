package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import java.util.*;
import static edu.mit.csail.sdg.ast.ExprBinary.Op.*;
import static edu.mit.csail.sdg.ast.ExprUnary.Op.*;
import static is.fivefivefive.CanDis.augmentation.ScopedOperands.binary;
import static is.fivefivefive.CanDis.augmentation.ScopedOperands.sub;
import is.fivefivefive.CanDis.augmentation.ScopedFiberRun.Fiber;

/** Source-side correspondence for AdaptiveFiberWitness, at a single fixed owner and instant. */
public final class FiberWitness {
    private FiberWitness() {}
    public enum Need { FIRST, SECOND, APART }
    public enum Form { GROUPED, SOME_NOT_ONE }
    public record Proof(Form form,Expr source,List<Need> needs) {}
    record Term(Fiber fiber,Proof proof) {}

    static Term read(Expr e,Expr owner) {
        if(e instanceof ExprQt q && q.op==ExprQt.Op.SOME) return grouped(q.decls,q.sub,q,owner,false);
        if(e instanceof ExprList l && l.op==ExprList.Op.AND && l.args.size()==2)
            return someNotOne(e,owner,l.args.get(0),l.args.get(1));
        var b=binary(e,AND);
        return b==null?null:someNotOne(e,owner,b.left,b.right);
    }
    private static Fiber join(Expr e,Expr x) {
        var j=binary(e,JOIN);
        return j==null?null:ScopedFiberRun.join(j,x);
    }
    private static Term someNotOne(Expr source,Expr x,Expr a,Expr b) {
        var some=sub(a,SOME);
        if(some==null) {some=sub(b,SOME); b=a;}
        var f=join(some,x);
        return f!=null && f.equals(join(sub(sub(b,NOT),ONE),x)) ?
                new Term(f,new Proof(Form.SOME_NOT_ONE,source,List.of())) : null;
    }
    static Term grouped(Iterable<Decl> decls,Expr body,Expr source,Expr owner,boolean includesOwner) {
        var slots=new ArrayList<ExprVar>(2); var domains=new ArrayList<Expr>(2);
        boolean disjoint=false;
        for(var d:decls) {
            var domain=sub(d.expr,ONEOF);
            if(domain==null || d.names.isEmpty() || d.isVar!=null || d.disjoint2!=null) return null;
            // A grouped "disj" involving the owner is an extra premise, not witness apartness.
            if(d.disjoint!=null && d.names.size()>1 && d.names.contains(owner)) return null;
            if(d.disjoint!=null && d.names.size()==2) disjoint=true;
            for(var name:d.names) {
                if(name==owner && includesOwner) continue;
                if(!(name instanceof ExprVar v) || v==owner || slots.contains(v) || slots.size()==2) return null;
                slots.add(v); domains.add(domain);
            }
        }
        if(slots.size()!=2) return null;
        var g=new Group(owner,slots.get(0),slots.get(1));
        if(disjoint) g.needs.add(Need.APART);
        for(int i=0;i<2;i++) {
            var bound=domains.get(i);
            if(!(bound instanceof Sig) && !g.add(join(bound,owner),slots.get(i))) return null;
        }
        if(!g.body(body.deNOP()) || !g.needs.containsAll(EnumSet.allOf(Need.class))) return null;
        var products=g.fiber.field().type().fold();
        if(products.size()!=1 || products.get(0).size()!=2) return null;
        var varying=products.get(0).get(g.fiber.column()?0:1);
        for(var domain:domains) if(domain instanceof Sig s && !ScopedOperands.contained(varying,s)) return null;
        return new Term(g.fiber,new Proof(Form.GROUPED,source,List.copyOf(g.needs)));
    }
    private static final class Group {
        final Expr owner,a,b;
        final List<Need> needs=new ArrayList<>();
        Fiber fiber;
        Group(Expr owner,Expr a,Expr b){this.owner=owner;this.a=a;this.b=b;}
        boolean slot(Expr x){return x==a || x==b;}
        boolean add(Fiber f,Expr x) {
            if(f==null || !slot(x) || fiber!=null && !fiber.equals(f)) return false;
            fiber=f; needs.add(x==a?Need.FIRST:Need.SECOND); return true;
        }
        boolean body(Expr e) {
            if(e instanceof ExprList l && l.op==ExprList.Op.AND) {
                for(var arg:l.args) if(!body(arg.deNOP())) return false;
                return true;
            }
            var and=binary(e,AND);
            if(and!=null) return body(and.left.deNOP()) && body(and.right.deNOP());
            var ne=binary(e,NOT_EQUALS);
            if(ne==null) ne=binary(sub(e,NOT),EQUALS);
            if(ne!=null && slot(ne.left.deNOP()) && slot(ne.right.deNOP()) && ne.left.deNOP()!=ne.right.deNOP()) {
                needs.add(Need.APART); return true;
            }
            if(e instanceof ExprConstant c && c.op==ExprConstant.Op.TRUE) return true;
            var in=binary(e,IN);
            if(in==null) return false;
            return member(in.left.deNOP(),in.right.deNOP());
        }
        boolean member(Expr l,Expr r) {
            var inter=binary(r,INTERSECT);
            if(inter!=null && l==owner) return member(l,inter.left.deNOP()) && member(l,inter.right.deNOP());
            if(slot(l)) return add(join(r,owner),l);
            var union=binary(l,PLUS);
            if(union!=null) {
                var f=join(r,owner);
                return add(f,union.left.deNOP()) && add(f,union.right.deNOP());
            }
            if(l==owner && r instanceof ExprBinary j && j.op==JOIN) {
                Expr w=slot(j.left.deNOP())?j.left.deNOP():j.right.deNOP();
                var f=ScopedFiberRun.join(j,w);
                return f!=null && add(new Fiber(f.field(),!f.column(),null),w);
            }
            var pair=binary(l,ARROW);
            if(pair==null) return false;
            boolean column=pair.right.deNOP()==owner;
            if(!column && pair.left.deNOP()!=owner) return false;
            var trans=sub(r,TRANSPOSE);
            return (trans==null?r:trans) instanceof Sig.Field f &&
                    add(new Fiber(f,column^(trans!=null),null),(column?pair.left:pair.right).deNOP());
        }
    }
}
