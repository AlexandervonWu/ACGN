package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.CompUtil;
import java.util.*;

/** Optional command-local classification of atoms by the size of one field row or column. */
public final class ScopedClassifier {
    private ScopedClassifier() {}
    public enum Observation { SIGNED, TUPLES, RESIDUE }
    public record Key(Sig domain,Sig selected,Sig.Field field,boolean column,ExprBinary.Op op,int literal) {}
    public record Read(Key key,ExprBinary.Op operandFirstOp,int sourceLiteral,boolean complemented,
                       Optional<ExprUnary.Op> multiplicity,Optional<FiberWitness.Proof> witness,List<Integer> excluded) {
        public Observation observation() {
            return !excluded.isEmpty()?Observation.RESIDUE:multiplicity.isPresent()?Observation.TUPLES:Observation.SIGNED;
        }
    }
    public record Match(Command command,Sig.PrimSig varying,int cap,int width,Key key,
                        Map<Func,List<SplitClassifier.Arm>> arms,Map<Func,List<ExprUnary.Op>> frames) {
        Read first(Func f) {return arms.get(f).get(0).read();}
    }

    static Read read(Expr body,int width) {
        if(width<2 || width>32) return null;
        Expr e=body.deNOP();
        if(e instanceof ExprQt q && q.op==ExprQt.Op.ALL && q.sub.deNOP() instanceof ExprBinary b && b.op==ExprBinary.Op.IFF) {
            var first=iff(q,b.left,b.right,width);
            return first!=null ? first : iff(q,b.right,b.left,width);
        }
        if(e instanceof ExprBinary b && b.op==ExprBinary.Op.EQUALS) {
            var first=comprehension(b.left,b.right,width);
            return first!=null ? first : comprehension(b.right,b.left,width);
        }
        return null;
    }
    private static Sig domain(ExprQt q) {
        return q.decls.size()==1 && ScopedOperands.singletonDomain(q.decls.get(0)) instanceof Sig s && !s.builtin ? s : null;
    }
    private static Read comprehension(Expr name,Expr set,int width) {
        if(!(name.deNOP() instanceof Sig s) || s.builtin || !(set.deNOP() instanceof ExprQt q) ||
                q.op!=ExprQt.Op.COMPREHENSION) return null;
        var d=domain(q);
        return d!=null && ScopedOperands.contained(s,d) ?
                test(q.sub,q.decls.get(0).names.get(0),d,s,false,width) : null;
    }
    private static Read iff(ExprQt q,Expr membership,Expr test,int width) {
        var d=domain(q); if(d==null) return null;
        Expr x=q.decls.get(0).names.get(0), e=membership.deNOP();
        boolean neg=false;
        while(e instanceof ExprUnary u && u.op==ExprUnary.Op.NOT) {neg=!neg; e=u.sub.deNOP();}
        if(!(e instanceof ExprBinary b) || (b.op!=ExprBinary.Op.IN && b.op!=ExprBinary.Op.NOT_IN) ||
                b.left.deNOP()!=x || !(b.right.deNOP() instanceof Sig s) || s.builtin) return null;
        return test(test,x,d,s,neg^(b.op==ExprBinary.Op.NOT_IN),width);
    }
    static Read test(Expr source,Expr x,Sig d,Sig s,boolean neg,int width) {
        Expr e=source.deNOP();
        while(e instanceof ExprUnary u && u.op==ExprUnary.Op.NOT) {neg=!neg; e=u.sub.deNOP();}
        var count=CardinalityThreshold.read(e,width).orElse(null);
        ExprUnary.Op mult=null;
        if(count==null) {
            if(!(e instanceof ExprUnary u)) {
                var term=FiberWitness.read(e,x);
                if(term!=null) return witness(d,s,term,neg,width);
                var omitted=ExcludedFiber.read(e,x,width);
                return omitted==null ? null : finish(d,s,omitted.fiber(),ExprBinary.Op.GT,omitted.k(),neg,width,
                        null,null,omitted.literals());
            }
            mult=u.op;
            count=switch(mult) {
                case NO, ONE -> new CardinalityThreshold.Read(u.sub,ExprBinary.Op.EQUALS,mult==ExprUnary.Op.NO?0:1,width);
                case LONE -> new CardinalityThreshold.Read(u.sub,ExprBinary.Op.LTE,1,width);
                case SOME -> new CardinalityThreshold.Read(u.sub,ExprBinary.Op.GT,0,width);
                default -> null;
            };
        }
        if(count==null || !(count.relation().deNOP() instanceof ExprBinary j)) return null;
        var fiber=ScopedFiberRun.join(j,x);
        return fiber==null?null:finish(d,s,fiber,count.comparison(),count.literal(),neg,width,mult,null,List.of());
    }
    static Read witness(Sig d,Sig s,FiberWitness.Term term,boolean neg,int width) {
        return finish(d,s,term.fiber(),ExprBinary.Op.LTE,1,!neg,width,ExprUnary.Op.LONE,term.proof(),List.of());
    }
    private static Read finish(Sig d,Sig s,ScopedFiberRun.Fiber fiber,ExprBinary.Op op,int k,boolean neg,
                               int width,ExprUnary.Op mult,FiberWitness.Proof witness,List<Integer> excluded) {
        var bound=CardinalityThreshold.inclusive(neg?CardinalityThreshold.complement(op):op,k,width);
        return new Read(new Key(d,s,fiber.field(),fiber.column(),bound.comparison(),bound.literal()),
                op,k,neg,Optional.ofNullable(mult),Optional.ofNullable(witness),excluded);
    }
    private static boolean safe(ExprUnary.Op mult,int cap,int width) {
        long modulus=1L<<width;
        return switch(mult) {
            case NO -> cap<modulus;
            case ONE -> cap<=modulus;
            case SOME,LONE -> 2L*cap<modulus;
            default -> false;
        };
    }
    private static boolean compatible(Read a,Read b,int cap,int width) {
        var x=a.observation(); var y=b.observation();
        if(x==y) return true;
        if(x==Observation.RESIDUE || y==Observation.RESIDUE) {
            boolean signed=x==Observation.SIGNED || y==Observation.SIGNED;
            return (signed?2L*cap:cap)<(1L<<width);
        }
        return safe(a.multiplicity.or(()->b.multiplicity).orElseThrow(),cap,width);
    }
    public static Optional<Match> match(ScopedFiberRun run,Func a,Func b) {
        var ends=run.atSameFrame(a,b).orElse(null);
        if(ends==null) return Optional.empty();
        int width=run.solution().getBitwidth();
        var l=SplitClassifier.read(ends.left(),width); var r=SplitClassifier.read(ends.right(),width);
        if(l.isEmpty() || r.isEmpty()) return Optional.empty();
        var k=l.get(0).read().key; var products=k.field.type().fold();
        if(products.size()!=1 || products.get(0).size()!=2) return Optional.empty();
        var varying=products.get(0).get(k.column?0:1);
        var bound=run.targetBound(a,b,varying).orElse(null);
        if(varying.builtin || bound==null) return Optional.empty();
        var arms=new ArrayList<>(l); arms.addAll(r);
        for(int i=0;i<arms.size();i++) {
            var read=arms.get(i).read();
            if(!k.equals(read.key)) return Optional.empty();
            for(int j=0;j<i;j++) if(!compatible(read,arms.get(j).read(),bound.cap(),width)) return Optional.empty();
        }
        return Optional.of(new Match(bound.command(),varying,bound.cap(),width,k,
                a==b?Map.of(a,l):Map.of(a,l,b,r),ends.sourceFrames()));
    }
    public static void main(String[] args) throws Exception {
        if(args.length<4 || args.length%2!=0) throw new IllegalArgumentException("module.als command-index predicate reference [predicate reference ...]");
        var m=CompUtil.parseEverything_fromFile(A4Reporter.NOP,null,args[0]);
        var run=ScopedFiberRun.execute(m,Integer.parseInt(args[1]));
        for(int i=2;i<args.length;i+=2) {
            var a=ScopedFiberRun.predicate(m,args[i]); var b=ScopedFiberRun.predicate(m,args[i+1]);
            var result=match(run,a,b).map(v->"SCOPED_CLASSIFIER "+v.key+" varying="+v.varying.label+" cap="+v.cap+
                    " width="+v.width+" command="+v.command+" "+a.label+"="+v.arms.get(a)+" "+b.label+"="+v.arms.get(b))
                    .orElse("NO_CLASSIFIER_RULE");
            System.out.println(args[i]+" / "+args[i+1]+": "+result);
        }
    }
}
