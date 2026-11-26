package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.CanDis.ProvenRewriteRule;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import org.json.*;

public final class ProvenRulesCommand {
    private ProvenRulesCommand() {}

    private static Optional<?> match(ProvenRewriteRule rule, ScopedFiberRun run, Func a, Func b) {
        return switch (rule) {
            case FIBER -> run.match(a,b);
            case DIFFERENCE -> run.matchDifference(a,b);
            case ROLE -> ScopedRoleSupport.match(run,a,b);
            case MIXED_ROLE -> ScopedRoleSupport.matchMixed(run,a,b);
            case CLASSIFIER -> ScopedClassifier.match(run,a,b);
            case STATIC_ALL_ALWAYS -> throw new IllegalArgumentException("R0-BIND-003 runs inside NormalForm.moveStaticUniversals");
        };
    }
    static Func endpoint(Expr expr) {
        if (expr.deNOP() instanceof ExprCall c && c.args.isEmpty() && c.fun.isPred && c.fun.decls.isEmpty()) return c.fun;
        return null;
    }
    public static JSONObject check(Path source, String label) throws Exception {
        var path=source.toRealPath(); var files=new HashMap<String,String>();
        var module=CompUtil.parseEverything_fromFile(A4Reporter.NOP,files,path.toString());
        int ordinal=-1;
        for (int i=0; i<module.getAllCommands().size(); i++) {
            var c=module.getAllCommands().get(i);
            if (c.check && c.label.equals(label)) {
                if (ordinal>=0) throw new IllegalArgumentException("Ambiguous check: "+label);
                ordinal=i;
            }
        }
        if (ordinal<0) throw new IllegalArgumentException("No such check: "+label);
        var c=module.getAllCommands().get(ordinal);
        if (c.nameExpr==null || !(c.nameExpr.referenced() instanceof Assert assertion)
                || !(assertion.expr.deNOP() instanceof ExprBinary iff) || iff.op!=ExprBinary.Op.IFF)
            throw new IllegalArgumentException("Expected the selected check to assert a predicate equivalence");
        Func a=endpoint(iff.left), b=endpoint(iff.right);
        if (a==null || b==null || a==b || !module.getAllFunc().contains(a) || !module.getAllFunc().contains(b))
            throw new IllegalArgumentException("Expected two different local predicates");
        var run=ScopedFiberRun.execute(module,ordinal);
        boolean sat=run.solution().satisfiable();
        var hits=rules(run,a,b);
        if (sat && !hits.isEmpty()) throw new IllegalStateException("Native counterexample to "+hits);
        var hashes=new JSONObject();
        for (var f:files.entrySet()) hashes.put(f.getKey(),HexFormat.of().formatHex(
                MessageDigest.getInstance("SHA-256").digest(f.getValue().getBytes(StandardCharsets.UTF_8))));
        return new JSONObject().put("scope","FIXED_COMMAND").put("check",label).put("ordinal",ordinal)
            .put("left",a.label).put("right",b.label).put("native",sat?"SAT":"UNSAT")
            .put("bitwidth",run.solution().getBitwidth()).put("traceMin",run.solution().getMinTrace())
            .put("traceMax",run.solution().getMaxTrace()).put("parsedSourceHashes",hashes)
            .put("result",hits.isEmpty()?"NO_RULE_MATCH":"SCOPED_EQUIVALENCE").put("rules",hits);
    }

    static List<String> rules(ScopedFiberRun run, Func a, Func b) {
        var hits=new ArrayList<String>();
        for (var rule:ProvenRewriteRule.values()) {
            if (rule.scope()!=ProvenRewriteRule.Scope.FIXED_COMMAND) continue;
            var forward=match(rule,run,a,b);
            if (!forward.equals(match(rule,run,b,a))) throw new IllegalStateException("Asymmetric reader: "+rule.id());
            if (forward.isPresent()) {
                hits.add(rule.id());
            }
        }
        return List.copyOf(hits);
    }
    public static void main(String[] args) throws Exception {
        if (args.length==1 && args[0].equals("list")) {
            for (var r:ProvenRewriteRule.values())
                System.out.println(r.id()+"\t"+r.scope()+"\t"+String.join(", ",r.proofAnchors()));
        } else if (args.length==3 && args[0].equals("check")) {
            System.out.println(check(Path.of(args[1]),args[2]).toString());
        } else throw new IllegalArgumentException("Usage: proven-rules list | check MODEL.als CHECK_NAME");
    }
}
