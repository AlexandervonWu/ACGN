package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;

/** Equal scalar minima must preserve the actual declaration and matrix edits in both arms. */
public final class DeclarationOrbitWitnessTest {
    private static final String SOURCE = """
            sig A { r, s, t: set A }
            sig B { sees: set A }
            pred oneFirst { one a:A | all b:B | b->a in sees }
            pred oneLast { all b:B | one a:A | b->a in sees }
            pred loneFirst { lone a:A | all b:B | b->a in sees }
            pred loneLast { all b:B | lone a:A | b->a in sees }
            pred wider { all x,y:univ, z:A | x->z in r and y->z in r implies x=y }
            pred typed { all z,x,y:A | z->x in r and z->y in r implies x=y }
            pred sortedWider { all z:A, x,y:univ | x->z in r and y->z in r implies x=y }
            pred middleWider { all x:univ, z:A, y:univ | x->z in r and y->z in r implies x=y }
            pred chain { all x,y,z:A | x->y in r and y->z in s }
            pred either { all a,b:A | some k:A | all c:A | b->a in r or a->c in s or k->a in t }

            pred repeated { all x,y,z:A | x->y in r and y->z in r }
            pred mixed { all a,b:A | some k:A | all c:A | b->a in r and c->a in s and k->a in t }

            pred paired { all x,y:A | x->y in r and x->y in s }
            pred longer { all a,b:A | some k:A | all c:A | b->a in r and b->c in s and k->a in t }
            """;

    private record Endpoint(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified) {}

    private static Endpoint prepare(MASGVisitor visitor, String predicate) {
        var fast = Canonical.prepare(visitor.getForest().get(visitor.getForestId(predicate)));
        return new Endpoint(fast, CanonicalAlloyPipeline.prepare(fast));
    }

    private static void check(boolean condition, String reason) {
        if (!condition) throw new AssertionError(reason);
    }

    private static JSONObject replay(Endpoint source, Endpoint target, int expected) {
        check(Canonical.distance(source.fast(), target.fast()) == expected, "Fast scalar minimum");
        check(CanonicalAlloyPipeline.distance(source.certified(), target.certified()) == expected,
                "Certified scalar minimum");
        var comparison = NativeOperationComparison.compare(source.fast(), target.fast(),
                source.certified(), target.certified());
        check(comparison.status() == NativeOperationComparison.Status.MATCHED, comparison.reason());
        var evidence = comparison.evidence();
        check(evidence.getBoolean("endpointCorrespondenceChecked") && evidence.getBoolean("sourceCertificatesChecked")
                && evidence.getBoolean("fixedChoiceReplaysChecked"), "Source-bound fixed-choice replays");
        var actions = evidence.getJSONArray("fastActions");
        check(actions.similar(evidence.getJSONArray("certifiedActions")), "Every selected native action");
        check(actions.getJSONObject(0).getString("stage").equals("declarationPermutation"), "Source and target orders");
        var diagnostic = evidence.getJSONObject("diagnostic");
        check(diagnostic.getJSONObject("fast").getInt("distance") == expected
                && diagnostic.getJSONObject("certified").getInt("distance") == expected, "Replayed scalar");

        // A foreign original coordinate must still fail the regular fixed-choice verifier.
        var forged = new JSONObject(diagnostic.toString());
        var order = forged.getJSONObject("certified").getJSONObject("selectedDeclarationPermutation")
                .getJSONArray("left");
        order.put(0, order.length());
        check(NativeOperationComparison.compareCaptured(source.fast(), target.fast(), forged).status()
                == NativeOperationComparison.Status.INVALID_REPLAY, "Reject substituted declaration witness");
        return evidence;
    }

    private static void bothDirections(MASGVisitor visitor, String left, String right, int expected) {
        var a = prepare(visitor, left);
        var b = prepare(visitor, right);
        replay(a, b, expected);
        replay(b, a, expected);
    }

    private static void crossingCountingPrefix(MASGVisitor visitor, String earlier, String later) {
        var a = prepare(visitor, earlier);
        var b = prepare(visitor, later);
        for (var evidence : java.util.List.of(replay(a,b,3), replay(b,a,3))) {
            var actions = evidence.getJSONArray("fastActions");
            check(actions.getJSONObject(1).getString("kind").equals("insert")
                    && actions.getJSONObject(2).getString("kind").equals("keep")
                    && actions.getJSONObject(2).getInt("source") == 0
                    && actions.getJSONObject(2).getInt("target") == 1
                    && actions.getJSONObject(3).getString("kind").equals("delete"),
                    "Keep the earlier source block on a crossing tie");
        }
    }

    private static void checkedOrder(JSONObject evidence, java.util.List<Integer> source,
            java.util.List<Integer> target) {
        var chosen = evidence.getJSONArray("fastActions").getJSONObject(0);
        check(chosen.getJSONArray("source").toList().equals(source)
                && chosen.getJSONArray("target").toList().equals(target),
                "Replay original occurrence coordinates for both endpoints");
    }

    private static void originalCoordinateOrder(MASGVisitor visitor) {
        var wider = prepare(visitor,"wider");
        var typed = prepare(visitor,"typed");
        checkedOrder(replay(wider,typed,7),java.util.List.of(2,0,1),java.util.List.of(2,1,0));
        checkedOrder(replay(typed,wider,7),java.util.List.of(1,0,2),java.util.List.of(2,0,1));
        bothDirections(visitor,"sortedWider","typed",7);
        bothDirections(visitor,"middleWider","typed",7);
    }

    public static void main(String[] args) throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, SOURCE);
        var visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null, module), null);
        bothDirections(visitor, "chain", "either", 10);    // Partial map gains an extra zero-cost keep.
        bothDirections(visitor, "repeated", "mixed", 8);   // Both endpoint orbits can move.
        bothDirections(visitor, "paired", "longer", 8);    // A later existing map ties an earlier identity.
        crossingCountingPrefix(visitor, "oneFirst", "oneLast");
        crossingCountingPrefix(visitor, "loneFirst", "loneLast");
        originalCoordinateOrder(visitor);
        System.out.println("DeclarationOrbitWitnessTest: sixteen native ordered action programs matched");
    }
}
