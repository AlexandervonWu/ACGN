package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.CompModule;
import java.util.*;
import org.json.JSONObject;

/** A pair-level equality in a single command, never a replacement global canonical key. */
public final class CommandComparison {
    private CommandComparison() {}
    public static final String VERSION = "fixed-command-source-v1";

    public record Decision(String check, int ordinal, int bitwidth, int traceMin, int traceMax,
                           Map<String,Integer> carrierBounds, List<String> rules) {
        public Decision { carrierBounds=Map.copyOf(carrierBounds); rules=List.copyOf(rules); }
        public boolean matched() { return !rules.isEmpty(); }
        public JSONObject json(int structuralDistance) {
            if (structuralDistance < 0) throw new IllegalArgumentException("missing structural comparison");
            return new JSONObject().put("check",check).put("ordinal",ordinal).put("bitwidth",bitwidth)
                .put("traceMin",traceMin).put("traceMax",traceMax).put("rules",rules)
                .put("comparisonVersion",VERSION).put("carrierBounds",carrierBounds)
                .put("basis",matched()?"FIXED_COMMAND_RULE":"STRUCTURAL_DISTANCE")
                .put("native",matched()?"UNSAT":"NOT_RUN")
                .put("equivalent",matched() || structuralDistance==0)
                .put("comparisonDistance",matched()?0:structuralDistance);
        }
    }

    static Func[] assertionPair(CompModule module, Command c) {
        if (!c.check || c.parent!=null || !c.getGrowableSigs().isEmpty() || c.nameExpr==null
                || !(c.nameExpr.referenced() instanceof Assert ass)
                || !(ass.expr.deNOP() instanceof ExprBinary iff) || iff.op!=ExprBinary.Op.IFF) return null;
        var a=ProvenRulesCommand.endpoint(iff.left); var b=ProvenRulesCommand.endpoint(iff.right);
        if (a==null || b==null || a==b || !module.getAllFunc().contains(a) || !module.getAllFunc().contains(b))
            return null;
        return new Func[]{a,b};
    }

    /** No decision for an unrelated check, a growable command, or a pair without a common module. */
    public static List<Decision> compare(CompModule module, String left, String right) {
        var decisions=new ArrayList<Decision>();
        for (int i=0; i<module.getAllCommands().size(); i++) {
            var pair=assertionPair(module,module.getAllCommands().get(i));
            if (pair==null) continue;
            var l=pair[0].label; var r=pair[1].label;
            if (l.equals("this/"+left) && r.equals("this/"+right) ||
                    l.equals("this/"+right) && r.equals("this/"+left)) {
                decisions.add(evaluate(module,i,pair,ScopedFiberRun.prepare(module,i,false)));
            }
        }
        return List.copyOf(decisions);
    }

    static Decision evaluate(CompModule module, int index, Func[] pair, ScopedFiberRun frame) {
        var hits=ProvenRulesCommand.rules(frame,pair[0],pair[1]);
        if (!hits.isEmpty()) {
            var nativeRun=ScopedFiberRun.execute(module,index);
            if (nativeRun.solution().satisfiable() || !hits.equals(ProvenRulesCommand.rules(nativeRun,pair[0],pair[1]))
                    || !frame.carrierBounds().equals(nativeRun.carrierBounds())
                    || frame.solution().getBitwidth()!=nativeRun.solution().getBitwidth()
                    || frame.solution().getMinTrace()!=nativeRun.solution().getMinTrace()
                    || frame.solution().getMaxTrace()!=nativeRun.solution().getMaxTrace())
                throw new IllegalStateException("Native check or command scope contradicts "+hits);
        }
        return new Decision(module.getAllCommands().get(index).label,index,frame.solution().getBitwidth(),
                frame.solution().getMinTrace(),frame.solution().getMaxTrace(),frame.carrierBounds(),hits);
    }
}
