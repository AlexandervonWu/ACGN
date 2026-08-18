package is.fivefivefive.CanDis.metric;

import java.util.Collections;
import java.util.List;

import is.fivefivefive.CanDis.metric.RepairView.Binding;
import is.fivefivefive.CanDis.metric.RepairView.BindingRole;
import is.fivefivefive.CanDis.metric.RepairView.ContainerKind;
import is.fivefivefive.CanDis.metric.RepairView.Declaration;
import is.fivefivefive.CanDis.metric.RepairView.Node;
import is.fivefivefive.CanDis.metric.RepairView.Phase;
import is.fivefivefive.CanDis.metric.RepairView.TemporalNode;

/** Focused executable checks for the certificate-backed Fast Rewrite metric port. */
public final class QuotientRepairDistanceTest {
    private static int checks;

    private QuotientRepairDistanceTest() {
    }

    public static void main(String[] args) {
        Node a = atom("A");
        Node b = atom("B");
        Node c = atom("C");

        check(distance(view(node("SEQ", ContainerKind.SEQUENCE, a, b)),
                view(node("SEQ", ContainerKind.SEQUENCE, b, a))) > 0,
                "sequence order remains editable");
        check(distance(view(node("AND", ContainerKind.SET, a, b)),
                view(node("AND", ContainerKind.SET, b, c))) == 1,
                "ACI operands use minimum-cost assignment");
        check(distance(view(node("BAG", ContainerKind.BAG, a, a)),
                view(node("BAG", ContainerKind.BAG, a))) == 1,
                "bag matching preserves multiplicity");

        Declaration all = declaration("ALL", 0);
        Declaration some = declaration("SOME", 0);
        check(distance(view(List.of(all), Collections.emptyList(), a),
                view(List.of(some), Collections.emptyList(), a)) == 1,
                "one quantifier tuple modification costs one");

        Binding x = binding(all, "root", 0);
        Binding y = binding(all, "root", 0);
        check(distance(
                view(List.of(all), List.of(x), variable("x", 0)),
                view(List.of(all), List.of(y), variable("renamed", 0))) == 0,
                "pairwise alpha alignment uses a certified scope orbit");

        Declaration blockZero = declaration("ALL", 0);
        Declaration blockOne = declaration("ALL", 1);
        Binding leftZero = binding(blockZero, "left/zero", 0);
        Binding leftOne = binding(blockOne, "left/one", 1);
        Binding rightZero = binding(blockZero, "right/zero", 0);
        Binding rightOne = binding(blockOne, "right/one", 1);
        check(distance(
                view(List.of(blockZero, blockOne), List.of(leftZero, leftOne),
                        node("PAIR", ContainerKind.SEQUENCE,
                                variable("x", 0), variable("y", 1))),
                view(List.of(blockZero, blockOne), List.of(rightZero, rightOne),
                        node("PAIR", ContainerKind.SEQUENCE,
                                variable("b", 1), variable("a", 0)))) > 0,
                "separate certified scope blocks cannot cross-permute");

        Binding x0 = binding(all, "same-block", 0, List.of(0, 1, 2));
        Binding x1 = binding(all, "same-block", 1, List.of(0, 1, 2));
        Binding x2 = binding(all, "same-block", 2, List.of(0, 1, 2));
        Binding only = binding(all, "same-block", 0, List.of(0));
        Node partialLeft = node("ROOT", ContainerKind.SET,
                node("P", ContainerKind.ONE, variable("x0", 0)),
                node("Q", ContainerKind.ONE, variable("x1", 1)),
                node("R", ContainerKind.ONE, variable("x2", 2)));
        Node partialRight = node("ROOT", ContainerKind.SET,
                node("Q", ContainerKind.ONE, variable("y", 0)));
        check(distance(
                view(List.of(all, all, all), List.of(x0, x1, x2), partialLeft),
                view(List.of(all), List.of(only), partialRight)) == 6,
                "unequal-arity alpha alignment minimizes over every maximum partial mapping");

        Binding ownerLeft0 = binding(all, "temporal-owner", 0, List.of(0, 1));
        Binding ownerLeft1 = binding(all, "temporal-owner", 1, List.of(0, 1));
        Binding ownerRight0 = binding(all, "temporal-owner", 0, List.of(0, 1));
        Binding ownerRight1 = binding(all, "temporal-owner", 1, List.of(0, 1));
        Binding inheritedLeft0 = inherited(all, "temporal-owner", 0, List.of(0, 1));
        Binding inheritedLeft1 = inherited(all, "temporal-owner", 1, List.of(0, 1));
        Binding inheritedRight0 = inherited(all, "temporal-owner", 0, List.of(0, 1));
        Binding inheritedRight1 = inherited(all, "temporal-owner", 1, List.of(0, 1));
        RepairView temporalTarget = multiPhaseView(
                new Phase(
                        List.of(all, all),
                        List.of(ownerLeft0, ownerLeft1),
                        node("ARROW", ContainerKind.SEQUENCE,
                                variable("x", 0), variable("y", 1))),
                new Phase(
                        Collections.emptyList(),
                        List.of(inheritedLeft0, inheritedLeft1),
                        node("TARGET", ContainerKind.ONE, variable("y", 1))));
        RepairView wrongTemporalTarget = multiPhaseView(
                new Phase(
                        List.of(all, all),
                        List.of(ownerRight0, ownerRight1),
                        node("ARROW", ContainerKind.SEQUENCE,
                                variable("a", 0), variable("b", 1))),
                new Phase(
                        Collections.emptyList(),
                        List.of(inheritedRight0, inheritedRight1),
                        node("TARGET", ContainerKind.ONE, variable("a", 0))));
        RepairView consistentlyPermutedTarget = multiPhaseView(
                new Phase(
                        List.of(all, all),
                        List.of(ownerRight0, ownerRight1),
                        node("ARROW", ContainerKind.SEQUENCE,
                                variable("b", 1), variable("a", 0))),
                new Phase(
                        Collections.emptyList(),
                        List.of(inheritedRight0, inheritedRight1),
                        node("TARGET", ContainerKind.ONE, variable("a", 0))));
        check(distance(temporalTarget, wrongTemporalTarget) == 1,
                "one binder owner cannot choose inconsistent alpha mappings across temporal phases");
        check(distance(temporalTarget, consistentlyPermutedTarget) == 0,
                "one certified binder permutation must apply consistently to every inherited phase");

        RepairView semantic = view(a);
        RepairView proofPresentation = new RepairView(
                semantic.temporalRoot(), semantic.phases(), "different-proof-digest");
        check(distance(semantic, proofPresentation) == 0,
                "proof and serialization identity are not repair edits");

        RepairView after = new RepairView(
                new TemporalNode("NONE", List.of(new TemporalNode("AFTER", List.of()))),
                semantic.phases(),
                "after-digest");
        check(distance(semantic, after) == 1,
                "temporal edits remain a separate ordered-tree component");

        QuotientRepairDistance.Result components = QuotientRepairDistance.evaluate(
                view(List.of(all), Collections.emptyList(), a),
                view(List.of(some), Collections.emptyList(), c));
        check(components.distance() == components.temporalDistance()
                        + components.quantifierDistance() + components.matrixDistance(),
                "reported temporal, quantifier, and matrix components sum exactly");

        expectThrows(IllegalStateException.class, () ->
                QuotientRepairDistance.enforceCertifiedKernel(
                        QuotientRepairDistance.evaluate(semantic, semantic), false));

        System.out.println("QuotientRepairDistanceTest passed: " + checks + " checks");
    }

    private static int distance(RepairView left, RepairView right) {
        return QuotientRepairDistance.distance(left, right);
    }

    private static RepairView view(Node matrix) {
        return view(Collections.emptyList(), Collections.emptyList(), matrix);
    }

    private static RepairView view(
            List<Declaration> declarations,
            List<Binding> bindings,
            Node matrix) {
        return new RepairView(
                new TemporalNode("NONE", Collections.emptyList()),
                List.of(new Phase(declarations, bindings, matrix)),
                "certified-test-digest");
    }

    private static RepairView multiPhaseView(Phase... phases) {
        return new RepairView(
                new TemporalNode("NONE", Collections.emptyList()),
                List.of(phases),
                "certified-test-digest");
    }

    private static Declaration declaration(String quantifier, int exchangeClass) {
        return new Declaration(
                quantifier,
                "S",
                "ONE",
                0,
                "S",
                exchangeClass,
                Collections.emptyList());
    }

    private static Binding binding(
            Declaration declaration,
            String path,
            int coordinate) {
        return binding(declaration, path, coordinate, List.of(coordinate));
    }

    private static Binding binding(
            Declaration declaration,
            String path,
            int coordinate,
            List<Integer> orbit) {
        return new Binding(
                BindingRole.MATRIX,
                coordinate,
                0,
                coordinate,
                declaration,
                path,
                orbit);
    }

    private static Binding inherited(
            Declaration declaration,
            String path,
            int coordinate,
            List<Integer> orbit) {
        return new Binding(
                BindingRole.INHERITED,
                coordinate,
                0,
                coordinate,
                declaration,
                path,
                orbit);
    }

    private static Node variable(String name, int binding) {
        return new Node(
                "VARIABLE", null, name, binding,
                ContainerKind.SEQUENCE, false, Collections.emptyList());
    }

    private static Node atom(String symbol) {
        return new Node(
                symbol, null, null, -1,
                ContainerKind.SEQUENCE, false, Collections.emptyList());
    }

    private static Node node(
            String symbol,
            ContainerKind kind,
            Node... children) {
        return new Node(
                symbol, null, null, -1, kind,
                kind == ContainerKind.BAG || kind == ContainerKind.SET,
                List.of(children));
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private static void expectThrows(
            Class<? extends Throwable> expected,
            Runnable action) {
        checks++;
        try {
            action.run();
        } catch (Throwable failure) {
            if (expected.isInstance(failure)) {
                return;
            }
            throw new AssertionError(
                    "Expected " + expected.getSimpleName() + " but got " + failure, failure);
        }
        throw new AssertionError("Expected " + expected.getSimpleName());
    }
}
