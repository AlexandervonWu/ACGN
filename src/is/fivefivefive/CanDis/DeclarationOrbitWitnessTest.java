package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.CanonicalDistance;
import is.fivefivefive.CanDis.core.NormalForm;
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

            sig Person { projects: set Project }
            sig Student in Person {}
            sig Project {}
            pred incomplete { all a:Person,p:Project |
                no (a & Student) implies p not in a.projects and some p & a.projects }
            pred guarded { all a:Person-Student,p:Project | p not in a.projects
                           all p:Project | some a:Student | p in a.projects }
            pred assigned { all a:Person,p:Project | p in a.projects implies a in Student
                            all p:Project | some a:Person | a->p in projects }
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

    private static void declarationMoves(Endpoint source, Endpoint target, int cost, String... expected) {
        var actions = replay(source,target,cost).getJSONArray("fastActions");
        var moves = new java.util.ArrayList<String>();
        for (var value : actions) {
            var action = (JSONObject)value;
            if ("declaration".equals(action.getString("stage"))) {
                moves.add(action.getString("kind") + "/" + action.get("source") + "/" + action.get("target"));
            }
        }
        check(moves.equals(java.util.List.of(expected)), "Keep the attaining original declaration coordinates");
    }

    private static void singleSourceBlock(MASGVisitor visitor) {
        var incomplete = prepare(visitor,"incomplete");
        var guarded = prepare(visitor,"guarded");
        var assigned = prepare(visitor,"assigned");
        declarationMoves(incomplete,guarded,25,"delete/0/null","keep/1/0","insert/null/1","insert/null/2");
        declarationMoves(guarded,incomplete,25,"insert/null/0","keep/0/1","delete/1/null","delete/2/null");
        // The same declaration prefixes also admit an attaining paid update
        // for this different matrix. Preserve its two actual update operations.
        declarationMoves(incomplete,assigned,24,"update/0/0","update/1/1","insert/null/2");
        declarationMoves(assigned,incomplete,24,"update/0/0","update/1/1","delete/2/null");
    }

    private static Object field(Object owner, String name) throws ReflectiveOperationException {
        var field = owner.getClass().getDeclaredField(name);
        field.setAccessible(true);
        return field.get(owner);
    }

    // Inspect the prior independently of the final paid path, which can
    // legitimately choose a lower matrix cost with charged declaration edits.
    private static void originalPrior(Endpoint source, Endpoint target, int cost, int matches,
            String competingTarget, int competingCost)
            throws ReflectiveOperationException {
        var a = (CanonicalDistance.Prepared)field(source.fast(),"delegate");
        var b = (CanonicalDistance.Prepared)field(target.fast(),"delegate");
        var left = a.comparisonForms().get(0);
        var right = b.comparisonForms().get(0);
        var owner = CanonicalDistance.class;
        var admits = owner.getDeclaredMethod("hasSplitTargetPrior",NormalForm.class,NormalForm.class);
        admits.setAccessible(true);
        check((boolean)admits.invoke(null,left,right),"A genuine split target from the prepared original source");
        var leftMeta = field(a,"metadata");
        var rightMeta = field(b,"metadata");
        var resultType = Class.forName(owner.getName()+"$BestMapping");
        var constructor = resultType.getDeclaredConstructor();
        constructor.setAccessible(true);
        var result = constructor.newInstance();
        var prior = owner.getDeclaredMethod("paidPriorDistance",NormalForm.class,NormalForm.class,
                java.util.Map.class,leftMeta.getClass(),rightMeta.getClass(),resultType,boolean.class);
        prior.setAccessible(true);
        int actual = (int)prior.invoke(null,left,right,java.util.Map.of(),leftMeta,rightMeta,result,true);
        check(actual == cost && ((java.util.Map<?,?>)field(result,"mapping")).size() == matches,
                "Rank the original residual matches before their matrix cost and target block order");
        var from = new java.util.HashMap<String,String>();
        var to = new java.util.HashMap<String,String>();
        left.getMatrixQuantiVars().forEach(q -> from.put(q.getOriginalName(),q.getName()));
        right.getMatrixQuantiVars().forEach(q -> to.put(q.getOriginalName(),q.getName()));
        var alternative = java.util.Map.of(from.get("a"),to.get(competingTarget));
        var fixed = owner.getDeclaredMethod("matrixDistance",NormalForm.class,NormalForm.class,
                java.util.Map.class,java.util.Set.class,java.util.Set.class,leftMeta.getClass(),rightMeta.getClass());
        fixed.setAccessible(true);
        int other = (int)fixed.invoke(null,left,right,alternative,java.util.Set.copyOf(from.values()),
                java.util.Set.copyOf(to.values()),leftMeta,rightMeta);
        check(other == competingCost,"Retain the independently scored competing one-link path");
    }

    private static void scopeQualityControls() throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP,"""
                sig A {r,s,t,u,v:set A}
                pred source { all a,b:A | a->a in r and a->a in s and a->a in t and a->b in u }
                pred wider { all p,q:A | some k:A | all z:A |
                    z->z in r and z->z in s and z->z in t and z->q in u and p->k in u and q->k in v }
                pred later { all p:A | some k:A | all z:A |
                    z->z in r and z->z in s and z->z in t and z->p in u and p->k in u }
                """);
        var visitor = new MASGVisitor(new GlobalVariables(),module);
        visitor.visit(new ModelUnit(null,module),null);
        var source = prepare(visitor,"source");
        // Block zero keeps two links at cost 17. Block two costs 11 but keeps only one.
        originalPrior(source,prepare(visitor,"wider"),17,2,"z",11);
        // One link in either block. Block two costs 6 against block zero's 12.
        originalPrior(source,prepare(visitor,"later"),6,1,"p",12);
        bothDirections(visitor,"source","wider",12);
        bothDirections(visitor,"source","later",6);
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
        singleSourceBlock(visitor);
        scopeQualityControls();
        System.out.println("DeclarationOrbitWitnessTest: twenty-four native ordered action programs matched");
    }
}
