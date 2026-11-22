package is.fivefivefive.CanDis;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/** Exercise the real adapter, its retained construction certificates and its immutable ledger. */
public final class RawArrowCensusTest {
    private static int cases;

    private static void check(boolean value, String message) {
        if (!value) throw new AssertionError(message);
    }

    private static void observed(String name, String outcome) {
        System.out.println("A2-15\t" + name + "\t" + outcome);
        cases++;
    }

    private interface Checked { void run() throws Exception; }

    private static void rejected(String name, String expected, Checked test) throws Exception {
        try {
            test.run();
        } catch (IllegalArgumentException e) {
            check(expected.equals(e.getMessage()), name + " unexpected rejection: " + e);
            observed(name, "REJECT " + expected);
            return;
        }
        throw new AssertionError(name + " unexpectedly accepted");
    }

    private static List<String> leafNames(RawArrowOccurrenceAuthority.Occurrence row) {
        return row.leaves().stream().map(RawArrowOccurrenceAuthority.Leaf::name).toList();
    }

    public static void main(String[] args) throws Exception {
        check(args.length == 0, "usage: RawArrowCensusTest");
        byte[] bytes = RawArrowOccurrenceAuthority.fixtureBytes();
        String selected = "arrows/selected";
        var raw = RawArrowOccurrenceAuthority.parse(bytes, selected);
        var candidate = RawArrowOccurrenceAuthority.produce(bytes, selected);
        raw.verify(candidate);

        var rows = raw.occurrences();
        check(rows.size() == 2 && leafNames(rows.get(0)).equals(List.of("r", "s"))
                && leafNames(rows.get(1)).equals(List.of("s", "r")), "two ordered field pairs");
        for (int i = 0; i < 2; i++) {
            check(rows.get(i).path().equals("phase/0/matrix/child/0/child/" + i), "selected role");
            for (var leaf : rows.get(i).leaves()) {
                check(leaf.kind().equals("field") && leaf.owner().equals("A")
                        && leaf.columns().equals(List.of("A", "A")), "typed field owner");
            }
        }

        var artifact = candidate.result().semanticArtifact();
        var actual = artifact.dependentChainConstructions().stream()
                .map(c -> c.leftEndpoint().structuralKey()).toList();
        var ledger = artifact.constructionSources().dependentChainSources();
        check(actual.size() == 2 && !actual.get(0).equals(actual.get(1))
                && ledger.size() == 2 && ledger.values().stream().allMatch(n -> n == 1),
                "distinct retained source endpoints");
        observed("two-same-type-arrows", "ACCEPT 2 paths, 4 typed field leaves, 2 ledger keys");
        var reverse = RawArrowOccurrenceAuthority.produce(bytes, "arrows/reversed");
        RawArrowOccurrenceAuthority.parse(bytes, "arrows/reversed").verify(reverse);
        observed("reversed-predicate", "ACCEPT independently selected reverse order");

        var missing = new HashMap<>(ledger);
        missing.remove(actual.get(0));
        rejected("missing-ledger-row", "different construction ledger multiset",
                () -> raw.verifyInventories(candidate, actual, missing));
        rejected("coordinated-omission", "different retained construction multiset",
                () -> raw.verifyInventories(candidate, actual.subList(1, 2), missing));
        var extra = new HashMap<>(ledger);
        extra.merge(actual.get(0), 1, Integer::sum);
        rejected("extra-ledger-count", "different construction ledger multiset",
                () -> raw.verifyInventories(candidate, actual, extra));
        var extraRows = new ArrayList<>(actual);
        extraRows.add(actual.get(0));
        rejected("coordinated-extra", "different retained construction multiset",
                () -> raw.verifyInventories(candidate, extraRows, extra));
        var exchanged = new HashMap<>(missing);
        exchanged.put(actual.get(1), 2);
        rejected("same-size-coordinated-substitution", "different retained construction multiset",
                () -> raw.verifyInventories(candidate, List.of(actual.get(1), actual.get(1)), exchanged));
        // Discard the source digest and selector to test the remaining structural defenses directly.
        rejected("foreign-retained-matrix", "different selected predicate",
                () -> raw.verifyRetained(reverse.prepared(), reverse.result()));
        byte[] transposed = new String(bytes, StandardCharsets.UTF_8)
                .replace("pred selected { r->s in s->r }", "pred selected { s->r in r->s }")
                .getBytes(StandardCharsets.UTF_8);
        var sameName = RawArrowOccurrenceAuthority.produce(transposed, selected);
        rejected("same-root-typed-operand-swap", "different ordered typed ARROW leaves",
                () -> raw.verifyRetained(sameName.prepared(), sameName.result()));
        rejected("foreign-selected-predicate", "different source bytes or selected predicate",
                () -> raw.verify(reverse));
        byte[] changed = (new String(bytes, StandardCharsets.UTF_8) + "\n").getBytes(StandardCharsets.UTF_8);
        rejected("different-original-bytes", "different source bytes or selected predicate",
                () -> RawArrowOccurrenceAuthority.parse(changed, selected).verify(candidate));

        byte[] nested = """
                module nested
                sig A {r,s: set A}
                pred assoc { (r->s)->r in r->(s->r) }
                """.getBytes(StandardCharsets.UTF_8);
        var assoc = RawArrowOccurrenceAuthority.parse(nested, "nested/assoc");
        assoc.verify(RawArrowOccurrenceAuthority.produce(nested, "nested/assoc"));
        var left = assoc.occurrences().get(0);
        var right = assoc.occurrences().get(1);
        check(leafNames(left).equals(List.of("r", "s", "r")) && leafNames(right).equals(leafNames(left))
                && left.leaves().get(0).path().equals(left.path() + "/child/0/child/0")
                && right.leaves().get(0).path().equals(right.path() + "/child/0"),
                "association survives flattening of repeated equal frontier");
        observed("nested-repeated-leaves", "ACCEPT 2 distinct associations, 6 typed field leaves");

        byte[] signatures = """
                module signatures
                sig A {} sig B {} sig C {}
                pred assoc { some ((A->B)->C) }
                """.getBytes(StandardCharsets.UTF_8);
        var some = RawArrowOccurrenceAuthority.parse(signatures, "signatures/assoc");
        some.verify(RawArrowOccurrenceAuthority.produce(signatures, "signatures/assoc"));
        check(leafNames(some.occurrences().get(0)).equals(List.of("A", "B", "C")),
                "ordered signature frontier");
        observed("some-signature-product", "ACCEPT 1 path, 3 typed signature leaves");
        byte[] unsupported = "module outside\nsig A {}\npred p { no A }"
                .getBytes(StandardCharsets.UTF_8);
        rejected("unsupported-body", "unsupported predicate body",
                () -> RawArrowOccurrenceAuthority.parse(unsupported, "outside/p"));
        System.out.println("RawArrowCensusTest: PASS (" + cases + " cases)");
    }
}
