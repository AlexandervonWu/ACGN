package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import static edu.mit.csail.sdg.ast.ExprBinary.Op.*;
import static edu.mit.csail.sdg.ast.ExprUnary.Op.CARDINALITY;
import static is.fivefivefive.CanDis.augmentation.ScopedOperands.*;
import static is.fivefivefive.CanDis.augmentation.ScopedRoleSupport.GuardedPolicy.*;
import is.fivefivefive.CanDis.augmentation.ScopedRoleSupport.GuardedPolicy;

/** The entire one-owner implication from AdaptiveMixedRowCounting.guarded_source. */
final class GuardedRow {
    private GuardedRow() {}
    private record Read(RoleSupport.Anchor k, ExprVar owner) {
        boolean full(Expr e) {return row(e,owner)==k.field();}
        boolean slice(Expr e,ExprBinary.Op op) {
            var p=binary(e,op);
            return p!=null && (full(p.left) && p.right.deNOP()==k.role() ||
                    op==INTERSECT && p.left.deNOP()==k.role() && full(p.right));
        }
        boolean member(Expr e,ExprVar p,boolean selected) {
            var in=binary(e,IN);
            return in!=null && in.left.deNOP()==p && (selected ? in.right.deNOP()==k.role() : full(in.right));
        }
        boolean witness(Expr e,ExprVar p,Sig domain) {
            if(domain==k.role())return member(e,p,false);
            Expr first,second;
            if(e.deNOP() instanceof ExprList l && l.op==ExprList.Op.AND && l.args.size()==2) {
                first=l.args.get(0); second=l.args.get(1);
            } else {
                var and=binary(e,AND); if(and==null)return false;
                first=and.left;second=and.right;
            }
            return member(first,p,true) && member(second,p,false) || member(second,p,true) && member(first,p,false);
        }
        boolean totals(Expr a,Expr b) {
            return slice(sub(a,CARDINALITY),INTERSECT) && full(sub(b,CARDINALITY));
        }
    }

    static GuardedPolicy read(Expr a,Expr b,Sig target,int width) {
        var k=RoleSupport.mixedAnchor(b); Expr source=a;
        if(k==null) {k=RoleSupport.mixedAnchor(source);source=b;}
        if(k==null || k.target()!=target)return null;
        ExprVar owner=null,p=null; Sig domain=null;
        while(source.deNOP() instanceof ExprQt q && q.op==ExprQt.Op.ALL) {
            for(var d:q.decls) {
                if(!(ScopedOperands.singletonDomain(d) instanceof Sig s))return null;
                var v=(ExprVar)d.names.get(0);
                if(s==k.field().sig && owner==null)owner=v;
                else if((s==k.target() || s==k.role()) && p==null){p=v;domain=s;}
                else return null;
            }
            source=q.sub;
        }
        var imp=binary(source,IMPLIES);
        if(owner==null || imp==null)return null;
        var r=new Read(k,owner);
        if(p!=null) {
            var c=CardinalityThreshold.inclusiveAtom(imp.right,width).orElse(null);
            return c!=null && c.comparison()==EQUALS && c.literal()==0 && r.slice(c.relation(),MINUS)
                    && r.witness(imp.left,p,domain) ? DIFFERENCE_ZERO : null;
        }
        var c=CardinalityThreshold.inclusiveAtom(imp.left,width).orElse(null);
        if(c==null || !r.slice(c.relation(),INTERSECT))return null;
        var in=binary(imp.right,IN);
        if(c.comparison()==NOT_EQUALS && c.literal()==0 && in!=null && r.full(in.left)
                && in.right.deNOP()==k.role())return SELECTED_NONZERO;
        var eq=binary(imp.right,EQUALS);
        return c.comparison()==GTE && c.literal()==1 && eq!=null &&
                (r.totals(eq.left,eq.right) || r.totals(eq.right,eq.left)) ? POSITIVE_AND_TOTAL : null;
    }
}
