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

    private static void replay(Endpoint source, Endpoint target, int expected) {
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
    }

    private static void bothDirections(MASGVisitor visitor, String left, String right, int expected) {
        var a = prepare(visitor, left);
        var b = prepare(visitor, right);
        replay(a, b, expected);
        replay(b, a, expected);
    }

    public static void main(String[] args) throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, SOURCE);
        var visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null, module), null);
        bothDirections(visitor, "chain", "either", 10);    // Partial map gains an extra zero-cost keep.
        bothDirections(visitor, "repeated", "mixed", 8);   // Both endpoint orbits can move.
        bothDirections(visitor, "paired", "longer", 8);    // A later existing map ties an earlier identity.
        System.out.println("DeclarationOrbitWitnessTest: six native ordered action programs matched");
    }
}
