package is.fivefivefive.CanDis;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.core.QuantiVar;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Regression for one normalized representative with different slots in two original declarations. */
public final class CoalescedDeclarationWitnessTest {
    private record Endpoint(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified) {}

    private static Endpoint load(String path) throws Exception {
        var root = Path.of(System.getProperty("acgn.test.repoRoot", "."), "classified-data/socialMedia");
        var module = AlloyUtil.compileAlloyModule(root.resolve(path + "_inv7.als").toString());
        var visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null, module), null);
        var prepared = Canonical.prepare(visitor.getForest().get(visitor.getForestId("inv7")));
        return new Endpoint(prepared, CanonicalAlloyPipeline.prepare(prepared));
    }

    private static void check(boolean ok, String why) {
        if (!ok) throw new AssertionError(why);
    }

    private static void compare(Endpoint a, Endpoint b, int cost, List<Integer> source, List<Integer> target) {
        check(Canonical.distance(a.fast, b.fast) == cost && CanonicalAlloyPipeline.distance(a.certified, b.certified) == cost,
                "Both original numeric minima");
        var comparison = NativeOperationComparison.compare(a.fast, b.fast, a.certified, b.certified);
        check(comparison.status() == NativeOperationComparison.Status.MATCHED, comparison.reason());
        var evidence = comparison.evidence();
        check(evidence.getBoolean("sourceCertificatesChecked") && evidence.getBoolean("fixedChoiceReplaysChecked")
                && evidence.getBoolean("endpointCorrespondenceChecked"), "Native source and fixed-choice replay");
        var actions = evidence.getJSONArray("fastActions");
        check(actions.similar(evidence.getJSONArray("certifiedActions")), "Every ordered native action");
        var first = actions.getJSONObject(0);
        check(first.getString("stage").equals("declarationPermutation")
                && first.getJSONArray("source").toList().equals(source)
                && first.getJSONArray("target").toList().equals(target), "Original-coordinate permutations");

        for (String arm : List.of("fast", "certified")) {
            JSONObject trace = evidence.getJSONObject("diagnostic").getJSONObject(arm);
            check(trace.getInt("matrixDistance") == cost - 1 && trace.getInt("quantifierDistance") == 1
                    && trace.getInt("temporalDistance") == 0, "The chosen declaration costs exactly one");
        }
    }

    private static void sourceControls(Endpoint independent, Endpoint dependent, Endpoint reference) throws Exception {
        var scope = Class.forName("is.fivefivefive.CanDis.core.FastPaidDeclarationAlignment");
        var completion = scope.getDeclaredMethod("supportsCoalescedPair", List.class, List.class);
        var exchange = scope.getDeclaredMethod("supportsPrefixScope", NormalForm.class);
        var ordinary = scope.getDeclaredMethod("supportsDirectEndpoint", List.class);
        completion.setAccessible(true);
        exchange.setAccessible(true);
        ordinary.setAccessible(true);

        var original = independent.fast.normalizedForms();
        var restricted = dependent.fast.normalizedForms();
        var target = reference.fast.normalizedForms();
        var form = original.get(0);
        check(!(boolean)ordinary.invoke(null, original) && !(boolean)ordinary.invoke(null, restricted),
                "Coalesced completion does not enter the ordinary numerical paid route");
        check((boolean)completion.invoke(null, original, target) && (boolean)completion.invoke(null, restricted, target),
                "Independently authenticated representatives support completion");
        check((boolean)exchange.invoke(null, form) && !(boolean)exchange.invoke(null, restricted.get(0)),
                "Only the independent homogeneous source admits an exchange");
        check(restricted.get(0).getMatrixQuantiVars().stream().flatMap(q -> q.getDeclarationFrames().stream())
                .anyMatch(frame -> !frame.dependencies().isEmpty()), "The restricted source really has a dependent domain");

        var q = form.getMatrixQuantiVars().get(1);
        var frames = q.getDeclarationFrames();
        check(frames.size() == 2 && frames.get(0).tupleSlot() == 0 && frames.get(1).tupleSlot() == 1
                && frames.get(0).declarationOccurrence() != frames.get(1).declarationOccurrence(),
                "One normalized binder retains two separately issued source slots");
        var ledger = QuantiVar.class.getDeclaredField("declarationFrames");
        ledger.setAccessible(true);
        @SuppressWarnings("unchecked")
        var writable = (List<NormalForm.DeclarationFrame>)ledger.get(q);
        var saved = new ArrayList<>(writable);
        try {
            writable.remove(0);
            check(!(boolean)completion.invoke(null, original, target), "Missing source occurrence rejected");
            writable.add(0, restricted.get(0).getMatrixQuantiVars().get(1).getDeclarationFrames().get(0));
            check(!(boolean)completion.invoke(null, original, target) && !(boolean)exchange.invoke(null, form),
                    "A genuine same-position frame from a foreign endpoint cannot authorize a path");
        } finally {
            writable.clear();
            writable.addAll(saved);
        }
        var slot = NormalForm.DeclarationFrame.class.getDeclaredField("tupleSlot");
        slot.setAccessible(true);
        try {
            slot.setInt(frames.get(1), 0);
            check(!(boolean)completion.invoke(null, original, target), "Reusing the representative slot fails issuance");
        } finally {
            slot.setInt(frames.get(1), 1);
        }
        check((boolean)completion.invoke(null, original, target), "Restored original source authority");
    }

    private static void searchLimits(Endpoint a, Endpoint b) {
        for (String key : List.of("acgn.maxGroupElements", "acgn.maxGroupPresentationWork")) {
            String old = System.getProperty(key);
            try {
                System.setProperty(key, "1");
                check(Canonical.distance(a.fast, b.fast) == 71 && Canonical.distance(b.fast, a.fast) == 71,
                        "An exhausted optional orbit preserves the attained matrix score");
                System.setProperty(key, "0");
                try {
                    Canonical.distance(a.fast, b.fast);
                    throw new AssertionError("Invalid resource settings must fail");
                } catch (IllegalStateException expected) {
                    check(expected.getMessage().contains("must be positive"), "Preserve mandatory preconditions");
                }
            } finally {
                if (old == null) System.clearProperty(key);
                else System.setProperty(key, old);
            }
        }
    }

    public static void main(String[] args) throws Exception {
        var independent = load("both/ai3mThxjTprs65TWj");
        var dependent = load("under/KZ8wbD5EDKWRZPPvy");
        var ref52 = load("correct/B3fvfwqR2CiTKhBbJ");
        var ref63 = load("correct/uDNrKeeuQgSgoabDT");
        var ref71 = load("correct/yzxz4a5t24fGTfv4k");
        var ref75 = load("correct/9GyCi669znXEy6DL3");
        var identity = List.of(0, 1);
        var reverse = List.of(2, 1, 0);
        sourceControls(independent, dependent, ref52);
        searchLimits(independent, ref71);
        compare(dependent, ref52, 52, identity, reverse);
        compare(ref52, dependent, 52, reverse, identity);
        compare(independent, ref63, 63, identity, reverse);
        compare(ref63, independent, 63, reverse, identity);
        compare(independent, ref71, 71, identity, List.of(1, 2, 0));
        compare(ref71, independent, 71, List.of(1, 0, 2), List.of(1, 0));
        compare(independent, ref75, 75, identity, reverse);
        compare(ref75, independent, 75, reverse, identity);
        System.out.println("CoalescedDeclarationWitnessTest: eight paid source programs and issued-frame controls");
    }
}
