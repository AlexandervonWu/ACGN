package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import java.util.*;

/** A conjunction excluding every residue from zero through k on exactly one fiber. */
record ExcludedFiber(ScopedFiberRun.Fiber fiber,int k,List<Integer> literals) {
    static ExcludedFiber read(Expr source,Expr owner,int width) {
        var pending=new ArrayDeque<Expr>(); pending.push(source);
        var literals=new ArrayList<Integer>(); var values=new HashSet<Integer>();
        ScopedFiberRun.Fiber fiber=null; int max=-1;
        while(!pending.isEmpty()) {
            Expr e=pending.pop().deNOP();
            if(e instanceof ExprList l && l.op==ExprList.Op.AND && !l.args.isEmpty()) {
                for(int i=l.args.size()-1;i>=0;i--) pending.push(l.args.get(i));
            } else if(e instanceof ExprBinary b && b.op==ExprBinary.Op.AND) {
                pending.push(b.right); pending.push(b.left);
            } else {
                var q=CardinalityThreshold.read(e,width).orElse(null);
                if(q==null || q.comparison()!=ExprBinary.Op.NOT_EQUALS || q.literal()<0 ||
                        !(q.relation().deNOP() instanceof ExprBinary j)) return null;
                var f=ScopedFiberRun.join(j,owner);
                if(f==null || fiber!=null && !fiber.equals(f)) return null;
                fiber=f; literals.add(q.literal()); values.add(q.literal()); max=Math.max(max,q.literal());
            }
        }
        return max>=1 && values.size()-1==max ? new ExcludedFiber(fiber,max,List.copyOf(literals)) : null;
    }
}
