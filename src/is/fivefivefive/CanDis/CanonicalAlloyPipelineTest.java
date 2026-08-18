package is.fivefivefive.CanDis;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import edu.mit.csail.sdg.parser.CompModule;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.CanonicalDistance;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.core.QuantiVar;
import is.fivefivefive.CanDis.metric.QuotientRepairDistance;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Fast Alloy-to-exact-engine Phase I conformance checks. */
public final class CanonicalAlloyPipelineTest {
    private static int checks;

    private CanonicalAlloyPipelineTest() {
    }

    public static void main(String[] args) throws Exception {
        Path directory = Files.createTempDirectory("candis-phase-i-");
        Path modelPath = directory.resolve("phase_i.als");
        try {
            Files.writeString(modelPath, source(), StandardCharsets.UTF_8);
            CompModule module = AlloyUtil.compileAlloyModule(modelPath.toString());
            check(module != null, "self-contained Alloy fixture must parse");
            ModelUnit model = new ModelUnit(null, module);
            MASGVisitor visitor = new MASGVisitor(new GlobalVariables());
            visitor.visit(model, null);

            CanonicalAlloyPipeline.Prepared alphaLeft = prepare(visitor, "alphaLeft");
            CanonicalAlloyPipeline.Prepared alphaRight = prepare(visitor, "alphaRight");
            CanonicalAlloyPipeline.Prepared aciLeft = prepare(visitor, "aciLeft");
            CanonicalAlloyPipeline.Prepared aciRight = prepare(visitor, "aciRight");
            CanonicalAlloyPipeline.Prepared positive = prepare(visitor, "positive");
            CanonicalAlloyPipeline.Prepared negative = prepare(visitor, "negative");
            CanonicalAlloyPipeline.Prepared shadowLeft = prepare(visitor, "shadowLeft");
            CanonicalAlloyPipeline.Prepared shadowRight = prepare(visitor, "shadowRight");
            CanonicalAlloyPipeline.Prepared disjoint = prepare(visitor, "disjointPred");
            CanonicalAlloyPipeline.Prepared nondisjoint = prepare(visitor, "nondisjoint");
            CanonicalAlloyPipeline.Prepared temporalLeft = prepare(visitor, "temporalLeft");
            CanonicalAlloyPipeline.Prepared temporalRight = prepare(visitor, "temporalRight");
            CanonicalAlloyPipeline.Prepared mixedCarrierLeft = prepare(visitor, "mixedCarrierLeft");
            CanonicalAlloyPipeline.Prepared mixedCarrierRight = prepare(visitor, "mixedCarrierRight");
            CanonicalAlloyPipeline.Prepared heterogeneousOrderLeft =
                    prepare(visitor, "heterogeneousOrderLeft");
            CanonicalAlloyPipeline.Prepared heterogeneousOrderRight =
                    prepare(visitor, "heterogeneousOrderRight");
            CanonicalAlloyPipeline.Prepared domainAciLeft = prepare(visitor, "domainAciLeft");
            CanonicalAlloyPipeline.Prepared domainAciRight = prepare(visitor, "domainAciRight");
            CanonicalAlloyPipeline.Prepared localGroupingLeft =
                    prepare(visitor, "localGroupingLeft");
            CanonicalAlloyPipeline.Prepared localGroupingRight =
                    prepare(visitor, "localGroupingRight");
            CanonicalAlloyPipeline.Prepared alphaNearLeft = prepare(visitor, "alphaNearLeft");
            CanonicalAlloyPipeline.Prepared alphaNearRight = prepare(visitor, "alphaNearRight");
            CanonicalAlloyPipeline.Prepared aciNearLeft = prepare(visitor, "aciNearLeft");
            CanonicalAlloyPipeline.Prepared aciNearRight = prepare(visitor, "aciNearRight");
            CanonicalAlloyPipeline.Prepared binderAll = prepare(visitor, "binderAll");
            CanonicalAlloyPipeline.Prepared binderSome = prepare(visitor, "binderSome");
            CanonicalAlloyPipeline.Prepared nestedSubtypeLeft =
                    prepare(visitor, "nestedSubtypeLeft");
            CanonicalAlloyPipeline.Prepared nestedSubtypeRight =
                    prepare(visitor, "nestedSubtypeRight");
            CanonicalAlloyPipeline.Prepared redundantDomainGuardLeft =
                    prepare(visitor, "redundantDomainGuardLeft");
            CanonicalAlloyPipeline.Prepared redundantDomainGuardRight =
                    prepare(visitor, "redundantDomainGuardRight");
            CanonicalAlloyPipeline.Prepared witnessedCarrierLeft =
                    prepare(visitor, "witnessedCarrierLeft");
            CanonicalAlloyPipeline.Prepared witnessedCarrierRight =
                    prepare(visitor, "witnessedCarrierRight");
            CanonicalAlloyPipeline.Prepared commutativeBinderLeft =
                    prepare(visitor, "commutativeBinderLeft");
            CanonicalAlloyPipeline.Prepared commutativeBinderRight =
                    prepare(visitor, "commutativeBinderRight");
            CanonicalAlloyPipeline.Prepared localComprehensionLeft =
                    prepare(visitor, "localComprehensionLeft");
            CanonicalAlloyPipeline.Prepared localComprehensionRight =
                    prepare(visitor, "localComprehensionRight");
            CanonicalAlloyPipeline.Prepared localPermutationLeft =
                    prepare(visitor, "localPermutationLeft");
            CanonicalAlloyPipeline.Prepared localPermutationRight =
                    prepare(visitor, "localPermutationRight");
            CanonicalAlloyPipeline.Prepared namedRefFirst =
                    prepare(visitor, "namedRefFirst");
            CanonicalAlloyPipeline.Prepared namedRefLast =
                    prepare(visitor, "namedRefLast");
            CanonicalAlloyPipeline.Prepared temporalBinderTarget =
                    prepare(visitor, "temporalBinderTarget");
            CanonicalAlloyPipeline.Prepared temporalBinderWrongTarget =
                    prepare(visitor, "temporalBinderWrongTarget");
            CanonicalAlloyPipeline.Prepared temporalBinderRenamed =
                    prepare(visitor, "temporalBinderRenamed");

            CanonicalAlloyPipeline.Prepared compactPositive =
                    positive.compactForComparison();
            CanonicalAlloyPipeline.Prepared compactNegative =
                    negative.compactForComparison();
            check(positive.retainsSemanticArtifact(),
                    "ordinary preparation must retain its certified construction artifact");
            check(!compactPositive.retainsSemanticArtifact(),
                    "comparison compaction must release the proof-heavy construction artifact");
            check(compactPositive.digest().equals(positive.digest()),
                    "comparison compaction must preserve the canonical digest");
            check(compactPositive.repairObservationSize() == positive.repairObservationSize(),
                    "comparison compaction must preserve the repair observation size");
            check(CanonicalAlloyPipeline.distance(compactPositive, compactNegative)
                            == CanonicalAlloyPipeline.distance(positive, negative),
                    "comparison compaction must preserve repair distance");
            boolean compactArtifactRejected = false;
            try {
                compactPositive.semanticArtifact();
            } catch (IllegalStateException expected) {
                compactArtifactRejected = true;
            }
            check(compactArtifactRejected,
                    "compact comparison values must fail closed for certificate replay");

            check(alphaLeft.equivalentTo(alphaRight),
                    "same-descriptor binder permutation must be alpha-equivalent");
            check(CanonicalAlloyPipeline.distance(alphaLeft, alphaRight) == 0,
                    "alpha-equivalent binders must have exact distance zero");
            check(aciLeft.equivalentTo(aciRight),
                    "ACI boolean operands must share the exact canonical key");
            check(CanonicalAlloyPipeline.distance(aciLeft, aciRight) == 0,
                    "ACI-equivalent matrices must have exact distance zero");
            check(CanonicalAlloyPipeline.distance(positive, negative) > 0,
                    "semantically opposed atoms must remain distinguishable");
            check(shadowLeft.equivalentTo(shadowRight),
                    "shadowed binders must remain alpha-equivalent without alias capture");
            check(CanonicalAlloyPipeline.distance(disjoint, nondisjoint) > 0,
                    "disjointness classes must remain part of the binder descriptor");
            check(CanonicalAlloyPipeline.distance(temporalLeft, temporalRight) > 0,
                    "different temporal-phase matrices must remain distinguishable");
            check(mixedCarrierLeft.equivalentTo(mixedCarrierRight),
                    "alpha-equivalence must preserve distinct primitive carrier blocks");
            check(heterogeneousOrderLeft.equivalentTo(heterogeneousOrderRight),
                    "independent heterogeneous binder order must not affect semantic equality");
            check(CanonicalAlloyPipeline.distance(
                            heterogeneousOrderLeft, heterogeneousOrderRight) == 0,
                    "independent heterogeneous binder reordering must retain distance zero");
            check(domainAciLeft.equivalentTo(domainAciRight),
                    "ACI-equivalent guarded binder domains must have certified equality: "
                            + domainAciLeft.digest() + " != " + domainAciRight.digest());
            check(CanonicalAlloyPipeline.distance(domainAciLeft, domainAciRight) == 0,
                    "ACI-equivalent guarded binder domains must retain distance zero");
            check(localGroupingLeft.equivalentTo(localGroupingRight),
                    "equivalent local declaration groupings must have certified equality");
            QuotientRepairDistance.Result localGroupingRepair =
                    QuotientRepairDistance.evaluate(
                            localGroupingLeft.repairView(), localGroupingRight.repairView());
            int localGroupingLegacy = legacyDistance(
                    visitor, "localGroupingLeft", "localGroupingRight");
            check(localGroupingLegacy > 0,
                    "the local-grouping fixture must expose the documented Fast Rewrite ambiguity");
            check(localGroupingRepair.distance() == 0,
                    "equivalent local declaration grouping must lie in the repair zero kernel");
            check(CanonicalAlloyPipeline.distance(alphaNearLeft, alphaNearRight) == 1,
                    "pairwise binder-orbit alignment must retain one-edit alpha locality");
            check(CanonicalAlloyPipeline.canonicalRepresentativeTreeDistance(
                            alphaNearLeft, alphaNearRight)
                            > CanonicalAlloyPipeline.distance(alphaNearLeft, alphaNearRight),
                    "independent canonical alpha representatives must expose their discontinuity baseline");
            check(CanonicalAlloyPipeline.distance(aciNearLeft, aciNearRight) == 1,
                    "ACI assignment must find the single changed operand");
            check(CanonicalAlloyPipeline.canonicalRepresentativeTreeDistance(
                            aciNearLeft, aciNearRight)
                            > CanonicalAlloyPipeline.distance(aciNearLeft, aciNearRight),
                    "independently sorted ACI representatives must not define repair geometry");
            check(CanonicalAlloyPipeline.distance(binderAll, binderSome) == 1,
                    "one quantifier declaration change must cost one repair");
            check(nestedSubtypeLeft.equivalentTo(nestedSubtypeRight),
                    "binder permutations must re-normalize ACI operands after acting");
            check(CanonicalAlloyPipeline.distance(
                            nestedSubtypeLeft, nestedSubtypeRight) == 0,
                    "nested and grouped subtype binders must retain distance zero");
            check(redundantDomainGuardLeft.equivalentTo(redundantDomainGuardRight),
                    "ACI projection must preserve certified idempotence of a repeated domain guard");
            check(CanonicalAlloyPipeline.distance(
                            redundantDomainGuardLeft, redundantDomainGuardRight) == 0,
                    "a repeated domain guard under implication rewriting must remain in the zero kernel");
            check(witnessedCarrierLeft.equivalentTo(witnessedCarrierRight),
                    "a preceding primitive binder must discharge an unnecessary relativized carrier: "
                            + witnessedCarrierLeft.digest() + " != "
                            + witnessedCarrierRight.digest());
            check(CanonicalAlloyPipeline.distance(
                            witnessedCarrierLeft, witnessedCarrierRight) == 0,
                    "equivalent implication-prenex forms must remain in the certified zero kernel");
            check(matrixBinderCount(
                            visitor, "witnessedCarrierLeft", QuantiVar.Quantifier.SOME, "Person")
                            == 1,
                    "the witnessed existential must retain its primitive Person repair type");
            check(commutativeBinderLeft.equivalentTo(commutativeBinderRight),
                    "binary inequality commutativity must survive a certified binder permutation: "
                            + commutativeBinderLeft.digest() + " != "
                            + commutativeBinderRight.digest());
            check(CanonicalAlloyPipeline.distance(
                            commutativeBinderLeft, commutativeBinderRight) == 0,
                    "commutative inequality and alpha alignment must share the zero kernel");
            check(localComprehensionLeft.equivalentTo(localComprehensionRight),
                    "beta-expanded repeated comprehensions must retain certified equality");
            check(CanonicalAlloyPipeline.distance(
                            localComprehensionLeft, localComprehensionRight) == 0,
                    "certified local comprehension alpha names must not cost matrix edits");
            check(!localPermutationLeft.equivalentTo(localPermutationRight),
                    "comprehension result columns must retain their positional identities");
            check(CanonicalAlloyPipeline.distance(
                            localPermutationLeft, localPermutationRight) > 0,
                    "swapping comprehension columns must remain outside the zero kernel");
            check(!namedRefFirst.equivalentTo(namedRefLast),
                    "distinct non-temporal reference symbols must not share a certified observation");
            check(CanonicalAlloyPipeline.distance(namedRefFirst, namedRefLast) == 1,
                    "changing ordering/first to ordering/last must cost one matrix edit");
            check(CanonicalAlloyPipeline.distance(
                            temporalBinderTarget, temporalBinderWrongTarget) > 0,
                    "an inherited temporal variable must reuse its owner's alpha mapping");
            check(temporalBinderTarget.equivalentTo(temporalBinderRenamed),
                    "a consistent binder permutation across temporal phases must remain certified");
            check(CanonicalAlloyPipeline.distance(
                            temporalBinderTarget, temporalBinderRenamed) == 0,
                    "consistent temporal alpha-renaming must retain repair distance zero");
            check(CanonicalAlloyPipeline.distance(alphaLeft, positive)
                            == CanonicalAlloyPipeline.distance(alphaRight, positive),
                    "repair distance must be invariant under certified alpha equivalence");
            check(CanonicalAlloyPipeline.distance(aciLeft, negative)
                            == CanonicalAlloyPipeline.distance(aciRight, negative),
                    "repair distance must be invariant under certified ACI equivalence");
            checkMetricParity(visitor, "alphaNearLeft", "alphaNearRight");
            checkMetricParity(visitor, "aciNearLeft", "aciNearRight");
            checkMetricParity(visitor, "binderAll", "binderSome");
            checkMetricParity(visitor, "temporalLeft", "temporalRight");
            checkMetricParity(visitor, "unequalAlphaLeft", "unequalAlphaRight");
            checkMetricParity(
                    visitor, "heterogeneousOrderLeft", "heterogeneousOrderRight");
            checkMetricParity(visitor, "domainAciLeft", "domainAciRight");
            checkMetricParity(
                    visitor, "redundantDomainGuardLeft", "redundantDomainGuardRight");
            long scopedMaximumS = matrixBinderCount(
                    visitor, "scopedMaximum", QuantiVar.Quantifier.ALL, "S");
            check(scopedMaximumS == 3,
                    "five sibling universal scopes need only three S coordinates; found "
                            + scopedMaximumS);
            check(matrixBinderCount(visitor, "scopedMaximum", QuantiVar.Quantifier.ALL, "T") == 1,
                    "the nested differently typed coordinate must remain live");
            check(matrixBinderCount(visitor, "nestedAll", QuantiVar.Quantifier.ALL, "S") == 2,
                    "continuously nested universal declarations must not reuse a live coordinate");
            check(matrixBinderCount(visitor, "allUnderOr", QuantiVar.Quantifier.ALL, "S") == 2,
                    "universal scopes in disjunction branches are not reusable lanes");
            check(matrixBinderCount(visitor, "someUnderOr", QuantiVar.Quantifier.SOME, "S") == 1,
                    "existential scopes in disjunction branches must reuse their lane");
            check(matrixBinderCount(visitor, "nestedSomeUnderOr", QuantiVar.Quantifier.SOME, "S") == 2,
                    "nested existential chains in sibling disjunctions use maximum live arity");
            check(matrixBinderCount(visitor, "someUnderAnd", QuantiVar.Quantifier.SOME, "S") == 2,
                    "existential scopes in conjunction branches are not reusable lanes");
            check(matrixBinderCount(visitor, "quantifierBarrier", QuantiVar.Quantifier.ALL, "S") == 2,
                    "a different nested quantifier must close the reusable universal frontier");
            check(hasInheritedAlias(visitor, "scopedTemporal", "b"),
                    "a reused slot must retain aliases needed by a temporal child");
            check(alphaLeft.eclassCount() > 0 && alphaLeft.enodeCount() > 0,
                    "exact graph statistics must be populated");
            check(alphaLeft.digest().length() == 64,
                    "canonical digest must be a SHA-256 hex string");
            check(alphaLeft.digest().equals(prepare(visitor, "alphaLeft").digest()),
                    "repeated adaptation must be deterministic");

            System.out.println("CanonicalAlloyPipelineTest passed: " + checks + " checks");
        } finally {
            Files.deleteIfExists(modelPath);
            Files.deleteIfExists(directory);
        }
    }

    private static CanonicalAlloyPipeline.Prepared prepare(
            MASGVisitor visitor,
            String predicate) {
        Integer id = visitor.getForestId(predicate);
        check(id != null, "missing MASG predicate " + predicate);
        Multigraph graph = visitor.getForest().get(id);
        check(graph != null, "missing MASG graph " + predicate);
        return CanonicalAlloyPipeline.prepare(graph);
    }

    private static void checkMetricParity(
            MASGVisitor visitor,
            String leftName,
            String rightName) {
        Multigraph leftGraph = visitor.getForest().get(visitor.getForestId(leftName));
        Multigraph rightGraph = visitor.getForest().get(visitor.getForestId(rightName));
        Canonical.Prepared left = Canonical.prepare(leftGraph);
        Canonical.Prepared right = Canonical.prepare(rightGraph);
        CanonicalDistance.DistanceBreakdown expected =
                Canonical.distanceBreakdown(left, right);
        QuotientRepairDistance.Result actual = CanonicalAlloyPipeline.distanceEvaluation(
                CanonicalAlloyPipeline.prepare(left),
                CanonicalAlloyPipeline.prepare(right));
        check(actual.distance() == expected.distance()
                        && actual.temporalDistance() == expected.temporalDistance()
                        && actual.quantifierDistance() == expected.quantifierDistance()
                        && actual.matrixDistance() == expected.matrixDistance(),
                "faithful metric port must preserve every reference metric component for "
                        + leftName + " versus " + rightName);
    }

    private static int legacyDistance(
            MASGVisitor visitor,
            String leftName,
            String rightName) {
        Multigraph leftGraph = visitor.getForest().get(visitor.getForestId(leftName));
        Multigraph rightGraph = visitor.getForest().get(visitor.getForestId(rightName));
        return Canonical.distance(
                Canonical.prepare(leftGraph), Canonical.prepare(rightGraph));
    }

    private static long matrixBinderCount(
            MASGVisitor visitor,
            String predicate,
            QuantiVar.Quantifier quantifier,
            String type) {
        Integer id = visitor.getForestId(predicate);
        check(id != null, "missing MASG predicate " + predicate);
        Multigraph graph = visitor.getForest().get(id);
        check(graph != null, "missing MASG graph " + predicate);
        Canonical.Prepared prepared = Canonical.prepare(graph);
        check(!prepared.normalizedForms().isEmpty(),
                "missing normalized form for " + predicate);
        NormalForm root = prepared.normalizedForms().get(0);
        return root.getMatrixQuantiVars().stream()
                .filter(variable -> variable.getQuantifier() == quantifier)
                .filter(variable -> type.equals(variable.getTypeName()))
                .count();
    }

    private static boolean hasInheritedAlias(
            MASGVisitor visitor,
            String predicate,
            String alias) {
        Integer id = visitor.getForestId(predicate);
        check(id != null, "missing MASG predicate " + predicate);
        Multigraph graph = visitor.getForest().get(id);
        check(graph != null, "missing MASG graph " + predicate);
        Canonical.Prepared prepared = Canonical.prepare(graph);
        for (NormalForm form : prepared.normalizedForms()) {
            for (QuantiVar variable : form.getInheritedQuantiVars()) {
                if (variable.getOriginalNames().contains(alias)) {
                    return true;
                }
            }
        }
        return false;
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private static String source() {
        return "module phase_i\n"
                + "open util/ordering[S] as orderingS\n"
                + "sig S { r: set S }\n"
                + "sig T {}\n"
                + "sig Protected, Trash in S {}\n"
                + "sig State { trans: Event -> State }\n"
                + "sig Init in State {}\n"
                + "sig Event {}\n"
                + "sig Person { Teaches: set Class }\n"
                + "sig Group {}\n"
                + "sig Class { Groups: Person -> Group }\n"
                + "sig Teacher in Person {}\n"
                + "sig Student in Person {}\n"
                + "pred alphaLeft { all x, y: S | y in x.r }\n"
                + "pred alphaRight { all a, b: S | a in b.r }\n"
                + "pred aciLeft { (some S and lone S) and one S }\n"
                + "pred aciRight { one S and (lone S and some S) }\n"
                + "pred positive { some S }\n"
                + "pred negative { no S }\n"
                + "pred shadowLeft { all x: S | some x: S | x in S }\n"
                + "pred shadowRight { all a: S | some b: S | b in S }\n"
                + "pred disjointPred { all disj x, y: S | y in x.r }\n"
                + "pred nondisjoint { all x, y: S | y in x.r }\n"
                + "pred temporalLeft { after some S }\n"
                + "pred temporalRight { after no S }\n"
                + "pred mixedCarrierLeft { all x: S, y: T | x in S and y in T }\n"
                + "pred mixedCarrierRight { all a: S, b: T | a in S and b in T }\n"
                + "pred heterogeneousOrderLeft { all s: S, t: T | s in S and t in T }\n"
                + "pred heterogeneousOrderRight { all t: T, s: S | s in S and t in T }\n"
                + "pred domainAciLeft { always all x: Protected & Trash | x in S }\n"
                + "pred domainAciRight { always all x: Trash & Protected | x in S }\n"
                + "pred localGroupingLeft {\n"
                + "  let t = { x: State, y: State | some e: Event | x->e->y in trans } |\n"
                + "  all s: State | some i: Init | s in i.^t\n"
                + "}\n"
                + "pred localGroupingRight {\n"
                + "  let t = { x, y: State | some e: Event | x->e->y in trans } |\n"
                + "  all s: State | some i: Init | s in i.^t\n"
                + "}\n"
                + "pred alphaNearLeft { all x,y:S | x in y.r and some x.r and no y.r.r }\n"
                + "pred alphaNearRight { all x,y:S | x in y.r and no x.r and no y.r.r }\n"
                + "pred aciNearLeft { some S and no S.r and one S.r.r and lone S.r.r.r }\n"
                + "pred aciNearRight { some S and no S.r and one S.r.r and some S.r.r.r }\n"
                + "pred binderAll { all x:S | x in x.*r }\n"
                + "pred binderSome { some x:S | x in x.*r }\n"
                + "pred nestedSubtypeLeft {\n"
                + "  all p: Protected | all t: Trash | p in t.*r\n"
                + "}\n"
                + "pred nestedSubtypeRight {\n"
                + "  all t: Trash, p: Protected | p in t.*r\n"
                + "}\n"
                + "pred redundantDomainGuardLeft {\n"
                + "  always all p: Protected |\n"
                + "    p in Protected implies historically p in Protected\n"
                + "}\n"
                + "pred redundantDomainGuardRight {\n"
                + "  always all p: Protected | historically p in Protected\n"
                + "}\n"
                + "pred witnessedCarrierLeft {\n"
                + "  all c: Class |\n"
                + "    (some s: Person, g: Group | c->s->g in Groups)\n"
                + "    implies (some t: Teacher | t->c in Teaches)\n"
                + "}\n"
                + "pred witnessedCarrierRight {\n"
                + "  all c: Class, s: Person, g: Group | some t: Person |\n"
                + "    c->s->g in Groups implies t->c in Teaches and t in Teacher\n"
                + "}\n"
                + "pred commutativeBinderLeft {\n"
                + "  all p, q: Person | p in Teacher and q in Student implies p != q\n"
                + "}\n"
                + "pred commutativeBinderRight {\n"
                + "  no p: Student, q: Teacher | p = q\n"
                + "}\n"
                + "pred localComprehensionLeft {\n"
                + "  all s: State |\n"
                + "    s in Init.^{s1, s2: State | some s1.trans.s2}\n"
                + "    implies some (Init & s.^{s1, s2: State | some s1.trans.s2})\n"
                + "}\n"
                + "pred localComprehensionRight {\n"
                + "  let t = {x: State, y: State | some (x.trans).y} |\n"
                + "  all s: Init.^t | some s.^t & Init\n"
                + "}\n"
                + "pred localPermutationLeft {\n"
                + "  some {x, y: S | x in y.r}\n"
                + "}\n"
                + "pred localPermutationRight {\n"
                + "  some {a, b: S | b in a.r}\n"
                + "}\n"
                + "pred namedRefFirst { orderingS/first in S }\n"
                + "pred namedRefLast { orderingS/last in S }\n"
                + "pred temporalBinderTarget {\n"
                + "  always all x, y: S | x->y in r implies eventually y in S\n"
                + "}\n"
                + "pred temporalBinderWrongTarget {\n"
                + "  always all x, y: S | x->y in r implies eventually x in S\n"
                + "}\n"
                + "pred temporalBinderRenamed {\n"
                + "  always all a, b: S | b->a in r implies eventually a in S\n"
                + "}\n"
                + "pred unequalAlphaLeft {\n"
                + "  all x0, x1, x2: S | some x0.r and no x1.r and one x2.r\n"
                + "}\n"
                + "pred unequalAlphaRight { all y: S | no y.r }\n"
                + "pred scopedMaximum {\n"
                + "  all a, b, c: S | a in S and b in S and c in S\n"
                + "  all d: S | d in S\n"
                + "  all e, f: S | e in S and f in S\n"
                + "  all g: S | g in S\n"
                + "  all h: S | all i: T | h in S and i in T\n"
                + "}\n"
                + "pred nestedAll { all a: S | all b: S | a in S and b in S }\n"
                + "pred allUnderOr { (all a: S | a in S) or (all b: S | b in S) }\n"
                + "pred someUnderOr { (some a: S | a in S) or (some b: S | b in S) }\n"
                + "pred nestedSomeUnderOr {\n"
                + "  (some a: S | some b: S | a in S and b in S)\n"
                + "  or (some c: S | some d: S | c in S and d in S)\n"
                + "}\n"
                + "pred someUnderAnd { (some a: S | a in S) and (some b: S | b in S) }\n"
                + "pred quantifierBarrier {\n"
                + "  (all x: S | x in S)\n"
                + "  and (some y: T | all z: S | y in T and z in S)\n"
                + "}\n"
                + "pred scopedTemporal {\n"
                + "  all a: S | a in S\n"
                + "  all b: S | after b in S\n"
                + "}\n";
    }
}
