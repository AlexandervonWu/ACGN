package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.CompUtil;
import java.util.*;

public final class ScopedRoleSupport {
    private ScopedRoleSupport() {}
    public record Bound(Sig carrier,int cap,boolean signed) {}
    public enum GuardedPolicy { DIFFERENCE_ZERO, SELECTED_NONZERO, POSITIVE_AND_TOTAL }
    public record Match(Command command, Sig target, int cap, int width, RoleSupport.Result result,List<Bound> bounds,
                        Optional<GuardedPolicy> guardedPolicy,List<ExprUnary.Op> frames,
                        Map<Func,List<ExprUnary.Op>> sourceFrames) {}

    public static Optional<Match> match(ScopedFiberRun run, Func a, Func b) {
        return match(run,a,b,false);
    }
    public static Optional<Match> matchMixed(ScopedFiberRun run, Func a, Func b) {
        return match(run,a,b,true);
    }
    private static Optional<Match> match(ScopedFiberRun run, Func a, Func b,boolean mixed) {
        int width=run.solution().getBitwidth();
        if(width<2 || width>32) return Optional.empty();
        var ends=run.atSameFrame(a,b).orElse(null);
        if(ends==null)return Optional.empty();
        var c=(mixed?RoleSupport.mixedBodies(ends.left(),ends.right(),width):RoleSupport.read(a,b,width)).orElse(null);
        if(c==null || c.limits().isEmpty() || !c.result().matches()) return Optional.empty();
        var full=run.targetBound(a,b,c.target()).orElse(null);
        if(full==null)return Optional.empty();
        var bounds=new ArrayList<Bound>();
        for(var lim:c.limits()) {
            // Every selected class is a checked direct child of the target carrier.
            var specific=run.targetBound(a,b,lim.carrier()).orElse(null);
            boolean tighter=specific!=null && specific.cap()<full.cap();
            int cap=tighter?specific.cap():full.cap();
            if((lim.signed()?2L*cap:cap)>=(1L<<width)) {
                var policy=mixed?GuardedRow.read(ends.left(),ends.right(),c.target(),width):null;
                if(policy==null || full.cap()>(1L<<(policy==GuardedPolicy.POSITIVE_AND_TOTAL?width-1:width)))
                    return Optional.empty();
                return Optional.of(new Match(full.command(),c.target(),full.cap(),width,c.result(),List.of(),Optional.of(policy),ends.frames(),ends.sourceFrames()));
            }
            bounds.add(new Bound(tighter?lim.carrier():c.target(),cap,lim.signed()));
        }
        return Optional.of(new Match(full.command(),c.target(),full.cap(),width,c.result(),List.copyOf(bounds),Optional.empty(),ends.frames(),ends.sourceFrames()));
    }

    public static void main(String[] args) throws Exception {
        if(args.length<4 || args.length%2!=0)
            throw new IllegalArgumentException("Expected: module.als command-index predicate reference [predicate reference ...]");
        var module=CompUtil.parseEverything_fromFile(A4Reporter.NOP,null,args[0]);
        var run=ScopedFiberRun.execute(module,Integer.parseInt(args[1]));
        for(int i=2;i<args.length;i+=2) {
            var a=ScopedFiberRun.predicate(module,args[i]);var b=ScopedFiberRun.predicate(module,args[i+1]);
            String result=match(run,a,b).map(v -> "SCOPED_ROLE_SUPPORT target="+v.target().label+
                    " cap="+v.cap()+" width="+v.width()).orElseGet(()->matchMixed(run,a,b)
                    .map(v->"SCOPED_HOMOGENEOUS_ROWS width="+v.width()+" targetCap="+v.cap()+" bounds="+v.bounds()+
                            " guardedPolicy="+v.guardedPolicy()+" frames="+v.frames()+
                            " "+a.label+"="+v.sourceFrames().get(a)+" "+b.label+"="+v.sourceFrames().get(b)).orElse("NO_SCOPED_RULE"));
            System.out.println(args[i]+" / "+args[i+1]+": "+result);
        }
    }
}
