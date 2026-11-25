package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.alloy4.Err;
import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import edu.mit.csail.sdg.translator.*;
import kodkod.engine.satlab.SATFactory;
import java.util.*;

/** Standalone analysis worker, deliberately outside the production validator classpath. */
public final class ScopedFiberRun {
    public record Match(Command command, Expr countedPredicate, Expr referencePredicate,
                        Sig.Field field, Sig.PrimSig varyingCarrier, int cap, int bitwidth,
                        boolean column, ExprUnary.Op multiplicity) {}

    private final Command command;
    private final A4Solution solution;
    private final Map<Func,Expr> bodies;
    private final Map<Sig.PrimSig,Integer> caps;

    private ScopedFiberRun(Command command, A4Solution solution, Map<Func,Expr> bodies, Map<Sig.PrimSig,Integer> caps) {
        this.command=command; this.solution=solution; this.bodies=bodies; this.caps=caps;
    }

    public A4Solution solution() { return solution; }

    /** One ordinary Analyzer execution, regardless of how many predicate pairs are subsequently read. */
    public static ScopedFiberRun execute(CompModule module, int ordinal) throws Err {
        Command cmd=module.getAllCommands().get(ordinal);
        if(cmd.parent!=null || !cmd.getGrowableSigs().isEmpty())
            throw new IllegalArgumentException("A scoped fiber run requires a single fixed command");
        var bodies=new IdentityHashMap<Func,Expr>();
        for (Func f:module.getAllFunc()) if (f.isPred && f.decls.isEmpty()) bodies.put(f,f.getBody().deNOP());
        class Bounds extends A4Reporter {
            Map<Sig.PrimSig,Integer> caps=Map.of();
            int callbacks;
            @Override public void actualScopes(Iterable<Sig> sigs, Map<Sig.PrimSig,Integer> sizes, Set<Sig> exact) {
                callbacks++;
                caps=new IdentityHashMap<>(sizes);
            }
        }
        var bounds=new Bounds();
        var opts=new A4Options(); opts.solver=SATFactory.DEFAULT; opts.noOverflow=false;
        var result=TranslateAlloyToKodkod.execute_command(bounds,module.getAllReachableSigs(),cmd,opts);
        if(result==null) throw new IllegalStateException("No Alloy solution object for source command");
        return new ScopedFiberRun(cmd,result,bodies,bounds.callbacks==1?bounds.caps:Map.of());
    }

    record Endpoints(Expr left, Expr right, List<ExprUnary.Op> frames, Map<Func,List<ExprUnary.Op>> sourceFrames) {}

    Optional<Endpoints> atSameFrame(Func a, Func b) {
        Expr x=bodies.get(a), y=bodies.get(b);
        if(x==null || y==null || x!=a.getBody().deNOP() || y!=b.getBody().deNOP() || caps.isEmpty()) return Optional.empty();
        var left=FutureFrames.read(x); var right=FutureFrames.read(y);
        if(!left.key().equals(right.key())) return Optional.empty();
        if(!left.written().isEmpty() && (command.minprefix<1 || command.maxprefix<2 ||
                solution.getMinTrace()!=command.minprefix || solution.getMaxTrace()!=command.maxprefix)) return Optional.empty();
        var frames=left.written().equals(right.written()) ? left.written() : left.key().word();
        var sources=a==b ? Map.of(a,left.written()) : Map.of(a,left.written(),b,right.written());
        return Optional.of(new Endpoints(left.body(),right.body(),frames,sources));
    }

    /** Both arguments must belong to this run; SAT versus UNSAT is not a rule premise. */
    public Optional<Match> match(Func a, Func b) {
        var ends=atSameFrame(a,b).orElse(null);
        if(ends==null || !(ends.left instanceof ExprQt l) || !(ends.right instanceof ExprQt r) ||
                domain(l)==null || domain(l)!=domain(r))
            return Optional.empty();
        var found=pair(l,r,bodies.get(a),bodies.get(b));
        return found.isPresent()?found:pair(r,l,bodies.get(b),bodies.get(a));
    }

    public Optional<ScopedDifferenceLaw.Match> matchDifference(Func a, Func b) {
        return atSameFrame(a,b).flatMap(e -> ScopedDifferenceLaw.match(command,solution.getBitwidth(),
                caps,a,b,e.left,e.right));
    }

    record TargetBound(Command command, int cap, int width) {}
    Optional<TargetBound> targetBound(Func a, Func b, Sig target) {
        if(bodies.get(a)!=a.getBody().deNOP() || bodies.get(b)!=b.getBody().deNOP()) return Optional.empty();
        int width=solution.getBitwidth();
        Integer cap=caps.get(target);
        return width>=2 && width<=32 && cap!=null && cap>=0 ?
                Optional.of(new TargetBound(command,cap,width)) : Optional.empty();
    }

    private static Sig domain(ExprQt q) {
        if(q.op!=ExprQt.Op.ALL || q.decls.size()!=1) return null;
        var d=q.decls.get(0);
        return d.names.size()==1 && d.expr.deNOP() instanceof ExprUnary u && u.op==ExprUnary.Op.ONEOF &&
                u.sub.deNOP() instanceof Sig s ? s : null;
    }

    record Fiber(Sig.Field field, boolean column, Sig mask) {}

    private static Fiber masked(Expr mask, Expr relation, Expr binder, boolean allowTuple) {
        if(mask instanceof Sig s && relation instanceof ExprBinary j && j.op==ExprBinary.Op.JOIN) {
            var side=join(j,binder);
            if(side!=null && side.column) return new Fiber(side.field,true,s);
        }
        if(allowTuple && relation instanceof Sig.Field f && mask instanceof ExprBinary p && p.op==ExprBinary.Op.ARROW &&
                p.left.deNOP() instanceof Sig s && p.right.deNOP()==binder) return new Fiber(f,true,s);
        return null;
    }

    static Fiber join(ExprBinary j, Expr binder) {
        if(j.op!=ExprBinary.Op.JOIN) return null;
        Expr l=j.left.deNOP(), r=j.right.deNOP();
        if(l!=binder && r!=binder) return null;
        Expr edge=l==binder?r:l;
        boolean converse=edge instanceof ExprUnary u && u.op==ExprUnary.Op.TRANSPOSE;
        if(converse) edge=((ExprUnary)edge).sub.deNOP();
        return edge instanceof Sig.Field f?new Fiber(f,(r==binder)!=converse,null):null;
    }

    private static Fiber fiber(Expr expr, Expr binder, boolean allowTuple) {
        if(!(expr.deNOP() instanceof ExprBinary b)) return null;
        Expr l=b.left.deNOP(), r=b.right.deNOP();
        if(b.op==ExprBinary.Op.JOIN) {
            return join(b,binder);
        } else if(b.op==ExprBinary.Op.INTERSECT) {
            var direct=masked(l,r,binder,allowTuple);
            return direct!=null ? direct : masked(r,l,binder,allowTuple);
        }
        return null;
    }

    static Func predicate(CompModule module,String name) {
        for(var f:module.getAllFunc()) if(f.isPred && f.label.equals("this/"+name)) return f;
        throw new IllegalArgumentException("Missing local predicate: "+name);
    }

    public static void main(String[] args) throws Exception {
        if(args.length<4 || args.length%2!=0) throw new IllegalArgumentException(
                "Expected: module.als command-index counted reference [counted reference ...]");
        var module=CompUtil.parseEverything_fromFile(A4Reporter.NOP,null,args[0]);
        int ordinal=Integer.parseInt(args[1]);
        var run=execute(module,ordinal);
        System.out.printf("command=%d native=%s bitwidth=%d%n",ordinal,
                run.solution.satisfiable()?"SAT":"UNSAT",run.solution.getBitwidth());
        for(int i=2;i<args.length;i+=2) {
            var a=predicate(module,args[i]); var b=predicate(module,args[i+1]);
            var law=run.match(a,b);
            System.out.println(args[i]+" / "+args[i+1]+": "+law.map(v ->
                    "SCOPED_MATCH "+v.multiplicity+" carrier="+v.varyingCarrier.label+" cap="+v.cap)
                    .orElseGet(() -> run.matchDifference(a,b).map(v ->
                            "SCOPED_DIFFERENCE_MATCH overlapCap="+v.bound().product()).orElse("NO_SCOPED_RULE")));
        }
    }

    private Optional<Match> pair(ExprQt count, ExprQt reference, Expr countRoot, Expr referenceRoot) {
        int width=solution.getBitwidth();
        if(width<2 || width>32 || !(reference.sub.deNOP() instanceof ExprUnary mult)) return Optional.empty();
        var read=CardinalityThreshold.readInterval(count.sub,width);
        if(read==null) return Optional.empty();
        Fiber source=fiber(read.relation(),count.decls.get(0).names.get(0),true);
        Fiber dest=fiber(mult.sub,reference.decls.get(0).names.get(0),false);
        if(source==null || dest==null || source.field!=dest.field || source.mask!=dest.mask ||
                source.column!=dest.column || source.field.type().arity()!=2) return Optional.empty();
        var f=source.field;
        var products=f.type().fold();
        if(products.size()!=1 || products.get(0).size()!=2) return Optional.empty();
        Sig.PrimSig varying=products.get(0).get(source.column?0:1);
        Integer cap=caps.get(varying);
        if(varying.builtin || cap==null || cap<0) return Optional.empty();
        long modulus=1L<<width;
        boolean valid=switch(mult.op) {
            case NO -> read.is(0,0) && cap<modulus;
            case ONE -> read.is(1,1) && cap<=modulus;
            case SOME -> read.is(1,modulus/2-1) && 2L*cap<modulus;
            case LONE -> read.is(0,1) && cap<modulus || read.is(-modulus/2,1) && 2L*cap<modulus;
            default -> false;
        };
        return valid?Optional.of(new Match(command,countRoot,referenceRoot,f,varying,cap,width,source.column,mult.op)):Optional.empty();
    }
}
