package is.fivefivefive.CanDis;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.metric.QuotientRepairDistance;
import is.fivefivefive.CanDis.metric.RepairView;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;

/** A temporal declaration tie retains its ordinary typed alignment when that path attains the minimum. */
public final class TemporalDeclarationWitnessTest {
    private static final String MODEL = """
            sig Track {} sig Train { var pos: lone Track }
            var sig A { var r: set A }
            pred source { always all t:Train | some k:Track | t in k implies t' in k }
            pred target { always all t:Train,k:Track |
                (t->k in pos implies always t->k in pos) and (t->k not in pos implies always t->k not in pos) }
            pred pastSource { once all t:Train | some k:Track | t in k implies t' in k }
            pred pastTarget { once all t:Train,k:Track |
                (t->k in pos implies once t->k in pos) and (t->k not in pos implies once t->k not in pos) }
            pred paidSource { always all a:A | some b:A | eventually a->b in r }
            pred paidTarget { always some a:A | all b:A | eventually a->b in r }
            pred roleSource { always all a:A | some b:A | once a->b in r }
            pred roleTarget { once some a:A | all b:A | always a->b in r }
            pred future { always eventually some r }
            pred past { always once some r }
            """;

    private record Endpoint(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified) {}

    private static Endpoint prepare(MASGVisitor visitor, String name) {
        var fast = Canonical.prepare(visitor.getForest().get(visitor.getForestId(name)));
        return new Endpoint(fast,CanonicalAlloyPipeline.prepare(fast));
    }

    private static void require(boolean ok, String reason) {
        if (!ok) throw new AssertionError(reason);
    }

    private static List<String> declarationMoves(JSONObject trace) {
        var result = new ArrayList<String>();
        for (var component : trace.getJSONObject("declarationSlice").getJSONArray("components")) {
            var operations = ((JSONObject)component).getJSONObject("receipt").getJSONArray("operations");
            for (var move : operations) result.add(((JSONObject)move).getString("kind"));
        }
        return result;
    }

    // Use the real captured temporal payments and original global indices to
    // score both admitted declaration alternatives, including the losing one.
    private static void checkCompetingCosts(RepairView left, RepairView right,
            int expectedUnpaid, int expectedPaid) throws ReflectiveOperationException {
        var capture = QuotientRepairDistance.class.getDeclaredMethod("captureDecisions",RepairView.class,RepairView.class);
        capture.setAccessible(true);
        var captured = capture.invoke(null,left,right);
        var getDecisions = captured.getClass().getDeclaredMethod("decisions");
        getDecisions.setAccessible(true);
        var stats = getDecisions.invoke(captured);
        var captureFlag = stats.getClass().getDeclaredField("capture");
        captureFlag.setAccessible(true);
        captureFlag.setBoolean(stats,false);
        var source = stats.getClass().getDeclaredField("selectedLeft");
        var target = stats.getClass().getDeclaredField("selectedRight");
        source.setAccessible(true);
        target.setAccessible(true);
        var fixed = QuotientRepairDistance.class.getDeclaredMethod("matrixDistanceForAlignment",
                source.getType(),target.getType(),Map.class,stats.getClass());
        fixed.setAccessible(true);
        int unpaid = (int)fixed.invoke(null,source.get(stats),target.get(stats),Map.of(),stats);
        int paid = (int)fixed.invoke(null,source.get(stats),target.get(stats),Map.of(0,0,1,1),stats);
        require(unpaid == expectedUnpaid && paid == expectedPaid,
                "Independent aligned matrix costs for the two original declaration paths");
    }

    private static JSONObject compare(Endpoint a, Endpoint b, int temporal, int matrix,
            List<String> moves, int unpaid, int paid) throws ReflectiveOperationException {
        int expected = temporal + 2 + matrix;
        require(Canonical.distance(a.fast,b.fast) == expected
                && CanonicalAlloyPipeline.distance(a.certified,b.certified) == expected,"Both scalar minima");
        var comparison = NativeOperationComparison.compare(a.fast,b.fast,a.certified,b.certified);
        require(comparison.status() == NativeOperationComparison.Status.MATCHED,comparison.reason());
        var e = comparison.evidence();
        require(e.getBoolean("endpointCorrespondenceChecked") && e.getBoolean("sourceCertificatesChecked")
                && e.getBoolean("fixedChoiceReplaysChecked") && e.getBoolean("orderedBlockEffectsEqual"),
                "Original source-bound temporal operation blocks");
        var report = e.getJSONObject("diagnostic");
        for (var arm : List.of("fast","certified")) {
            var trace = report.getJSONObject(arm);
            require(trace.getInt("distance") == expected && trace.getInt("temporalDistance") == temporal
                    && trace.getInt("quantifierDistance") == 2 && trace.getInt("matrixDistance") == matrix,
                    "Replay each native cost component");
            require(declarationMoves(trace).equals(moves),"Original selected temporal declaration program");
        }
        checkCompetingCosts(a.certified.repairView(),b.certified.repairView(),unpaid,paid);
        return report;
    }

    public static void main(String[] args) throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP,MODEL);
        var visitor = new MASGVisitor(new GlobalVariables(),module);
        visitor.visit(new ModelUnit(null,module),null);
        var a = prepare(visitor,"source");
        var b = prepare(visitor,"target");
        var pastA = prepare(visitor,"pastSource");
        var pastB = prepare(visitor,"pastTarget");
        var forward = List.of("insert","keep","delete");
        var reverse = List.of("delete","keep","insert");
        var report = compare(a,b,2,27,forward,15,15);
        compare(b,a,2,27,reverse,15,15);
        compare(pastA,pastB,2,27,forward,15,15);
        compare(pastB,pastA,2,27,reverse,15,15);
        var sourceTrace = CanonicalRepairTraces.fast(a.fast,b.fast);
        var certifiedTrace = CanonicalRepairTraces.certified(a.certified,b.certified);
        require(NativeOperationComparison.compareCaptured(pastA.fast,b.fast,sourceTrace,certifiedTrace,report).status()
                == NativeOperationComparison.Status.INVALID_REPLAY,"Reject a report from a different temporal owner");

        var updates = List.of("update","update");
        for (var names : List.of(List.of("paidSource","paidTarget"),List.of("roleSource","roleTarget"))) {
            var source = prepare(visitor,names.get(0));
            var target = prepare(visitor,names.get(1));
            int temporal = names.get(0).equals("paidSource") ? 0 : 2;
            compare(source,target,temporal,0,updates,2,0);
            compare(target,source,temporal,0,updates,2,0);
        }
        var future = prepare(visitor,"future");
        var past = prepare(visitor,"past");
        for (var pair : List.of(List.of(future,past), List.of(past,future))) {
            var left = pair.get(0);
            var right = pair.get(1);
            var comparison = NativeOperationComparison.compare(left.fast,right.fast,left.certified,right.certified);
            require(comparison.status() == NativeOperationComparison.Status.MATCHED,comparison.reason());
            var evidence = comparison.evidence();
            require(evidence.getBoolean("orderedBlockEffectsEqual"),"Both unchanged zero-declaration programs");
            for (var arm : List.of("fast","certified")) {
                var trace = evidence.getJSONObject("diagnostic").getJSONObject(arm);
                require(declarationMoves(trace).isEmpty() && trace.getInt("quantifierDistance")==0
                        && trace.getInt("temporalDistance")==1 && trace.getInt("matrixDistance")==0,
                        "A zero-declaration comparison preserves its original nonzero temporal payment");
            }
        }
        System.out.println("TemporalDeclarationWitnessTest: ten checked temporal programs");
    }
}
