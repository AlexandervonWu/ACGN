package is.fivefivefive.CanDis.metric;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.EGraphNode.Metatype;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.core.OrderedTreeEditDistance;
import is.fivefivefive.CanDis.metric.RepairView.Binding;
import is.fivefivefive.CanDis.metric.RepairView.BindingRole;
import is.fivefivefive.CanDis.metric.RepairView.ContainerKind;
import is.fivefivefive.CanDis.metric.RepairView.Declaration;
import is.fivefivefive.CanDis.metric.RepairView.Node;
import is.fivefivefive.CanDis.metric.RepairView.Phase;
import is.fivefivefive.CanDis.metric.RepairView.TemporalNode;
import is.fivefivefive.CanDis.theory.GraphType;
import is.fivefivefive.CanDis.theory.SemanticProfile;
import is.fivefivefive.CanDis.theory.StructuralKey;

/** Focused executable checks for the certificate-backed Fast Rewrite metric port. */
public final class QuotientRepairDistanceTest {
    private static int checks;
    private static final StructuralKey TEST_OBSERVATION =
            StructuralKey.leaf("test-certified-observation", "shared");
    private static final SemanticProfile TEST_PROFILE =
            SemanticProfile.alloyOverflowForbidding();
    private static final OrderedTreeEditDistance.Adapter<TemporalNode> TEMPORAL_ADAPTER =
            new OrderedTreeEditDistance.Adapter<>() {
                @Override
                public String label(TemporalNode node) {
                    return node.label();
                }

                @Override
                public List<? extends TemporalNode> children(TemporalNode node) {
                    return node.children();
                }
            };

    private QuotientRepairDistanceTest() {
    }

    public static void main(String[] args) {
        EGraphNode untypedRelation = new EGraphNode(
                900_001,
                Opcode.GLOBALBINDING,
                List.of(),
                false,
                0,
                false,
                Metatype.SET);
        untypedRelation.setSourceName("R");
        untypedRelation.setSourceType("Rel(A->B)");
        expectThrows(IllegalStateException.class,
                () -> RepairProjection.requireExactResultType(untypedRelation));
        untypedRelation.setExactAlloyType(
                ExactAlloyType.relation(List.of("A", "B")));
        GraphType exactRelation = RepairProjection.requireExactResultType(untypedRelation);
        check(exactRelation.kind() == GraphType.Kind.RELATION
                        && exactRelation.arguments().size() == 2,
                "repair projection consumes the exact ordered relation type");

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
                semantic.temporalRoot(),
                semantic.phases(),
                TEST_PROFILE,
                StructuralKey.leaf("test-certified-observation", "different"));
        check(distance(semantic, proofPresentation) == 0,
                "proof and serialization identity are not repair edits");
        expectThrows(IllegalStateException.class, () ->
                QuotientRepairDistance.evaluate(semantic, proofPresentation));

        check(distance(
                        view(certifiedAtom("this/S", "identity=S;type=Rel(AlloySig:S)")),
                        view(certifiedAtom("S", "identity=S;type=Rel(AlloySig:S)"))) == 0,
                "readable source spelling must not override certified atom identity");
        check(distance(
                        view(certifiedAtom("same", "identity=same;type=Rel(AlloySig:S)")),
                        view(certifiedAtom("same", "identity=same;type=Rel(AlloySig:T)"))) == 1,
                "one exact atom-type change must remain one matrix-node edit");

        RepairView after = new RepairView(
                new TemporalNode("NONE", List.of(new TemporalNode("AFTER", List.of()))),
                semantic.phases(),
                TEST_PROFILE,
                StructuralKey.leaf("test-certified-observation", "after"));
        check(distance(semantic, after) == 1,
                "temporal edits remain a separate ordered-tree component");

        TemporalNode xTemporal = temporal("X");
        TemporalNode yTemporal = temporal("Y");
        TemporalNode internalDeletionLeft = temporal(
                "R", temporal("A", xTemporal));
        TemporalNode internalDeletionRight = temporal("R", xTemporal);
        check(temporalDistance(internalDeletionLeft, internalDeletionRight) == 1,
                "ordered TED deletes an internal node and promotes its child");
        check(temporalDistance(internalDeletionRight, internalDeletionLeft) == 1,
                "ordered TED inserts an internal node around an existing child");
        check(temporalDistance(temporal("R", xTemporal, yTemporal),
                temporal("R", yTemporal, xTemporal)) == 2,
                "ordered TED does not silently commute temporal siblings");
        check(temporalDistance(xTemporal, yTemporal) == 1,
                "ordered TED leaf relabeling is one boundary edit");
        expectThrows(NullPointerException.class, () ->
                OrderedTreeEditDistance.distance(null, xTemporal, TEMPORAL_ADAPTER));

        List<TemporalNode> boundedTrees = List.of(
                xTemporal,
                yTemporal,
                temporal("A", xTemporal),
                temporal("R", xTemporal, yTemporal),
                internalDeletionLeft,
                temporal("R", temporal("A", xTemporal), yTemporal),
                temporal("R", xTemporal, temporal("A", yTemporal)));
        for (TemporalNode leftTree : boundedTrees) {
            for (TemporalNode rightTree : boundedTrees) {
                int expected = exhaustiveOrderedMappingDistance(leftTree, rightTree);
                int actual = temporalDistance(leftTree, rightTree);
                check(actual == expected,
                        "Zhang-Shasha result must equal the independent bounded mapping oracle"
                                + " (expected=" + expected + ", actual=" + actual + ")");
            }
        }

        QuotientRepairDistance.Result components =
                QuotientRepairDistance.evaluateUncheckedForTesting(
                view(List.of(all), Collections.emptyList(), a),
                view(List.of(some), Collections.emptyList(), c));
        check(components.distance() == components.temporalDistance()
                        + components.quantifierDistance() + components.matrixDistance(),
                "reported temporal, quantifier, and matrix components sum exactly");

        RepairView falseSameObservation = new RepairView(
                semantic.temporalRoot(),
                List.of(new Phase(
                        Collections.emptyList(),
                        Collections.emptyList(),
                        atom("DIFFERENT"))),
                TEST_PROFILE,
                TEST_OBSERVATION);
        expectThrows(IllegalStateException.class, () ->
                QuotientRepairDistance.evaluate(semantic, falseSameObservation));
        check(QuotientRepairDistance.evaluate(semantic, semantic).distance() == 0,
                "the public fast metric accepts zero only for the same producer observation");
        check(QuotientRepairDistance.evaluate(semantic, semantic).kernelAuthority()
                        == QuotientRepairDistance.KernelAuthority
                                .IN_PROCESS_PRODUCER_CONSISTENCY,
                "the fast metric cannot advertise independent verifier authority");
        RepairView modular = new RepairView(
                semantic.temporalRoot(),
                semantic.phases(),
                SemanticProfile.alloyModular(),
                TEST_OBSERVATION);
        expectThrows(IllegalArgumentException.class, () ->
                QuotientRepairDistance.evaluate(semantic, modular));

        System.out.println("QuotientRepairDistanceTest passed: " + checks + " checks");
    }

    private static int distance(RepairView left, RepairView right) {
        return QuotientRepairDistance.evaluateUncheckedForTesting(
                left, right).distance();
    }

    private static int temporalDistance(TemporalNode left, TemporalNode right) {
        RepairView leftView = new RepairView(
                left,
                List.of(new Phase(Collections.emptyList(), Collections.emptyList(), atom("M"))),
                TEST_PROFILE,
                StructuralKey.leaf("test-certified-observation", "left-temporal"));
        RepairView rightView = new RepairView(
                right,
                List.of(new Phase(Collections.emptyList(), Collections.emptyList(), atom("M"))),
                TEST_PROFILE,
                StructuralKey.leaf("test-certified-observation", "right-temporal"));
        return QuotientRepairDistance.evaluateUncheckedForTesting(
                leftView, rightView).temporalDistance();
    }

    private static TemporalNode temporal(String label, TemporalNode... children) {
        return new TemporalNode(label, List.of(children));
    }

    private static int exhaustiveOrderedMappingDistance(
            TemporalNode left,
            TemporalNode right) {
        List<OracleNode> leftNodes = flatten(left);
        List<OracleNode> rightNodes = flatten(right);
        int[] mapping = new int[leftNodes.size()];
        Arrays.fill(mapping, -1);
        int[] best = {leftNodes.size() + rightNodes.size()};
        enumerateMappings(
                leftNodes, rightNodes, mapping, new boolean[rightNodes.size()], 0, best);
        return best[0];
    }

    private static void enumerateMappings(
            List<OracleNode> left,
            List<OracleNode> right,
            int[] mapping,
            boolean[] usedRight,
            int leftIndex,
            int[] best) {
        if (leftIndex == left.size()) {
            int mapped = 0;
            int updates = 0;
            for (int index = 0; index < mapping.length; index++) {
                if (mapping[index] >= 0) {
                    mapped++;
                    if (!left.get(index).label.equals(right.get(mapping[index]).label)) {
                        updates++;
                    }
                }
            }
            best[0] = Math.min(
                    best[0], left.size() + right.size() - 2 * mapped + updates);
            return;
        }

        mapping[leftIndex] = -1;
        enumerateMappings(left, right, mapping, usedRight, leftIndex + 1, best);
        for (int rightIndex = 0; rightIndex < right.size(); rightIndex++) {
            if (usedRight[rightIndex]
                    || !mappingCompatible(
                            left, right, mapping, leftIndex, rightIndex)) {
                continue;
            }
            mapping[leftIndex] = rightIndex;
            usedRight[rightIndex] = true;
            enumerateMappings(left, right, mapping, usedRight, leftIndex + 1, best);
            usedRight[rightIndex] = false;
            mapping[leftIndex] = -1;
        }
    }

    private static boolean mappingCompatible(
            List<OracleNode> left,
            List<OracleNode> right,
            int[] mapping,
            int newLeft,
            int newRight) {
        for (int oldLeft = 0; oldLeft < newLeft; oldLeft++) {
            int oldRight = mapping[oldLeft];
            if (oldRight < 0) {
                continue;
            }
            boolean leftAncestor = ancestor(left, oldLeft, newLeft);
            boolean leftDescendant = ancestor(left, newLeft, oldLeft);
            boolean rightAncestor = ancestor(right, oldRight, newRight);
            boolean rightDescendant = ancestor(right, newRight, oldRight);
            if (leftAncestor != rightAncestor || leftDescendant != rightDescendant) {
                return false;
            }
            if (!leftAncestor && !leftDescendant
                    && Integer.compare(oldLeft, newLeft)
                            != Integer.compare(oldRight, newRight)) {
                return false;
            }
        }
        return true;
    }

    private static boolean ancestor(
            List<OracleNode> nodes,
            int possibleAncestor,
            int possibleDescendant) {
        int parent = nodes.get(possibleDescendant).parent;
        while (parent >= 0) {
            if (parent == possibleAncestor) {
                return true;
            }
            parent = nodes.get(parent).parent;
        }
        return false;
    }

    private static List<OracleNode> flatten(TemporalNode root) {
        List<OracleNode> result = new ArrayList<>();
        flatten(root, -1, result);
        return result;
    }

    private static void flatten(
            TemporalNode node,
            int parent,
            List<OracleNode> result) {
        int current = result.size();
        result.add(new OracleNode(node.label(), parent));
        for (TemporalNode child : node.children()) {
            flatten(child, current, result);
        }
    }

    private static final class OracleNode {
        private final String label;
        private final int parent;

        private OracleNode(String label, int parent) {
            this.label = label;
            this.parent = parent;
        }
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
                TEST_PROFILE,
                TEST_OBSERVATION);
    }

    private static RepairView multiPhaseView(Phase... phases) {
        return new RepairView(
                new TemporalNode("NONE", Collections.emptyList()),
                List.of(phases),
                TEST_PROFILE,
                TEST_OBSERVATION);
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

    private static Node certifiedAtom(String display, String semanticIdentity) {
        return new Node(
                "GLOBALBINDING", display, semanticIdentity, null, -1,
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
