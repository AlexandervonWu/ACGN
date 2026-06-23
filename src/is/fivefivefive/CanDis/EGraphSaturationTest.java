package is.fivefivefive.CanDis;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import is.fivefivefive.CanDis.macros.EGraphNode;
import is.fivefivefive.CanDis.macros.EGraphNode.Metatype;
import is.fivefivefive.CanDis.macros.EGraphNode.Opcode;
import is.fivefivefive.CanDis.macros.NormalForm;
import is.fivefivefive.CanDis.macros.QuantificationTreeNode;
import is.fivefivefive.CanDis.macros.QuantificationTreeNode.Quantifier;

public final class EGraphSaturationTest {
    private EGraphSaturationTest() {
    }

    public static void main(String[] args) {
        testAssociativeCommutativeSaturation();
        testDeMorganSaturation();
        testAssociativeNoncommutativeJoin();
        testRenamedIdUnionFind();
        testDoubleNegationAndIdempotence();
        testComplementEliminatesRedundantSlot();
        testSlotPermutationGroups();
        testDisjModifierIsPreserved();
        testDisjModifierAffectsCanonicalDistance();
        testImplicationPrenexPolarityDoesNotDoubleNegate();
        testImplicationScopeAffectsCanonicalDistance();
        testIffPrenexPolarity();
        testAlphaRenamingKeepsCanonicalDistanceZero();
        testOneAndLoneQuantifierNegation();
        testQuantifierPolarityRules();
        System.out.println("EGraphSaturationTest passed");
    }

    private static void testAssociativeCommutativeSaturation() {
        EGraphNode nested = node(Opcode.AND, true, true, variable("b"), variable("a"));
        EGraphNode root = node(Opcode.AND, true, true, variable("c"), nested);

        root.saturate();

        assertEquals(3, root.getChildren().size(), "AND must flatten to flexible arity");
        assertEquals(Arrays.asList("a", "b", "c"), variableNames(root.getChildren()),
                "commutative children must be canonicalized");
        assertTrue(root.getEClass().getNodes().size() >= 2,
                "the original and flattened terms must share an e-class");
        assertEquals(3, root.getChildClasses().size(), "an e-node must reference one e-class per operand");
        for (EGraphNode.EClassRef child : root.getChildClasses()) {
            assertEquals(1, child.getEClass().getSlots().size(), "variable e-class must expose one slot");
            assertEquals(1, child.getSlotMap().size(), "e-class invocation must map its slot");
        }
    }

    private static void testDeMorganSaturation() {
        EGraphNode conjunction = node(Opcode.AND, true, true, variable("x"), variable("y"));
        EGraphNode negation = node(Opcode.NOT, false, false, conjunction);

        negation.saturate();

        assertEquals(Opcode.OR, negation.getOpcode(), "De Morgan must rewrite NOT(AND) to OR");
        assertEquals(2, negation.getChildren().size(), "De Morgan must preserve operand count");
        for (EGraphNode child : negation.getChildren()) {
            assertEquals(Opcode.NOT, child.getOpcode(), "De Morgan must negate every operand");
        }
        assertTrue(negation.getEClass().getNodes().size() >= 2,
                "De Morgan alternatives must remain in one e-class");
    }

    private static void testAssociativeNoncommutativeJoin() {
        EGraphNode nested = node(Opcode.JOIN, false, true, variable("b"), variable("c"));
        EGraphNode join = node(Opcode.JOIN, false, true, variable("a"), nested);

        join.saturate();

        assertTrue(join.isFlexibleArity(), "JOIN must have flexible arity");
        assertEquals(Arrays.asList("a", "b", "c"), variableNames(join.getChildren()),
                "JOIN must flatten without reordering operands");
        assertTrue(join.getEClass().getNodes().size() >= 2,
                "associated JOIN terms must share an e-class");
    }

    private static void testRenamedIdUnionFind() {
        EGraphNode x = variable("x");
        EGraphNode y = variable("y");
        EGraphNode z = variable("z");
        EGraphNode.EClassRef xAtA = x.getEClass().invoke(rename("x", "a"));
        EGraphNode.EClassRef yAtA = y.getEClass().invoke(rename("y", "a"));
        EGraphNode.EClassRef zAtA = z.getEClass().invoke(rename("z", "a"));

        EGraphNode.union(xAtA, yAtA);
        EGraphNode.union(yAtA, zAtA);

        assertTrue(xAtA.equivalentTo(yAtA), "alpha-equivalent invocations must be unioned");
        assertTrue(xAtA.equivalentTo(zAtA), "renamed-ID union must be transitive");
        assertEquals(xAtA.canonical().getEClass().getId(), zAtA.canonical().getEClass().getId(),
                "path compression must find one leader e-class");

        EGraphNode.EClassRef yAtB = y.getEClass().invoke(rename("y", "b"));
        assertTrue(!xAtA.equivalentTo(yAtB),
                "the same e-class under a different caller-slot renaming is not automatically equivalent");
    }

    private static void testDoubleNegationAndIdempotence() {
        EGraphNode x = variable("doubleNegationX");
        EGraphNode innerNot = node(Opcode.NOT, false, false, x);
        EGraphNode outerNot = node(Opcode.NOT, false, false, innerNot);
        outerNot.saturate();

        assertEquals(Opcode.VARIABLE, outerNot.getOpcode(), "double negation must collapse to its operand");
        assertEquals("doubleNegationX", outerNot.getAlphaName(), "double negation must preserve the slot");
        assertTrue(outerNot.getEClass().getNodes().size() >= 2,
                "double negation and its operand must remain equivalent alternatives");

        EGraphNode duplicate = variable("duplicateX");
        EGraphNode disjunction = node(Opcode.OR, true, true, duplicate, duplicate);
        disjunction.saturate();
        assertEquals(Opcode.VARIABLE, disjunction.getOpcode(), "A OR A must collapse to A");
    }

    private static void testComplementEliminatesRedundantSlot() {
        EGraphNode proposition = variable("tautologyX");
        EGraphNode negated = node(Opcode.NOT, false, false, proposition);
        EGraphNode tautology = node(Opcode.OR, true, true, proposition, negated);
        EGraphNode.EClassRef beforeSaturation = tautology.getEClassRef();

        tautology.saturate();

        assertEquals(Opcode.CONSTANT, tautology.getOpcode(), "A OR NOT A must collapse to a constant");
        assertEquals("true", tautology.getSourceName(), "A OR NOT A must collapse to true");
        assertTrue(tautology.getEClass().getSlots().isEmpty(),
                "a slot unused by an equivalent constant must become redundant");
        assertTrue(beforeSaturation.canonical().getSlotMap().isEmpty(),
                "path-compressed renamed IDs must drop redundant slot bindings");
        assertTrue(tautology.getEClass().getNodes().size() >= 2,
                "the original tautology and true must remain in one e-class");

        EGraphNode contradictionX = variable("contradictionX");
        EGraphNode contradiction = node(
                Opcode.AND,
                true,
                true,
                contradictionX,
                node(Opcode.NOT, false, false, contradictionX));
        contradiction.saturate();
        assertEquals("false", contradiction.getSourceName(), "A AND NOT A must collapse to false");
        assertTrue(contradiction.getEClass().getSlots().isEmpty(),
                "contradiction elimination must also remove the unused slot");

        EGraphNode member = variable("memberX");
        EGraphNode set = variable("setS");
        EGraphNode membership = node(Opcode.IN, false, false, member, set);
        EGraphNode nonMembership = node(Opcode.NOT_IN, false, false, member, set);
        EGraphNode nnfTautology = node(Opcode.OR, true, true, membership, nonMembership);
        nnfTautology.saturate();
        assertEquals("true", nnfTautology.getSourceName(),
                "dual NNF atoms must be recognized as complements");
        assertTrue(nnfTautology.getEClass().getSlots().isEmpty(),
                "dual-atom tautology must eliminate all unused slots");
    }

    private static void testSlotPermutationGroups() {
        EGraphNode pair = node(Opcode.CALL, false, true, variable("groupX"), variable("groupY"));
        EGraphNode.EClassRef identity = pair.getEClass().invoke(rename(
                "groupX", "left",
                "groupY", "right"));
        EGraphNode.EClassRef swapped = pair.getEClass().invoke(rename(
                "groupX", "right",
                "groupY", "left"));
        assertTrue(!identity.equivalentTo(swapped),
                "slot order must matter before a binder symmetry is registered");

        pair.getEClass().addSlotSwap("groupX", "groupY");
        assertTrue(identity.equivalentTo(swapped),
                "all x,y:S must identify f[x,y] with the consistently renamed f[y,x]");
        assertEquals(2, pair.getEClass().symmetryCount(), "one transposition must generate S2");

        EGraphNode triple = node(
                Opcode.CALL,
                false,
                true,
                variable("groupA"),
                variable("groupB"),
                variable("groupC"));
        triple.getEClass().addSlotSwap("groupA", "groupB");
        triple.getEClass().addSlotSwap("groupB", "groupC");
        assertEquals(6, triple.getEClass().symmetryCount(),
                "adjacent binder swaps must generate the full S3 group");
    }

    private static void testDisjModifierIsPreserved() {
        NormalForm disjoint = new NormalForm();
        disjoint.addEClass(node(Opcode.FORALL, false, false, disjRelDecl("x", "y"),
                predicate("P", variable("x"), variable("y"))));
        disjoint.normalize();
        assertTrue(disjoint.getQuantificationTree().isDisj(),
                "disj declaration modifier must survive prenexing");

        NormalForm plain = new NormalForm();
        plain.addEClass(node(Opcode.FORALL, false, false, relDecl("x", "y"),
                predicate("P", variable("x"), variable("y"))));
        plain.normalize();
        assertTrue(!plain.getQuantificationTree().isDisj(),
                "plain declaration must not be marked disj");
    }

    private static void testDisjModifierAffectsCanonicalDistance() {
        QuantificationTreeNode disjoint = new QuantificationTreeNode(
                Quantifier.ALL,
                new ArrayList<>(),
                true,
                "S");
        QuantificationTreeNode plain = new QuantificationTreeNode(
                Quantifier.ALL,
                new ArrayList<>(),
                false,
                "S");
        try {
            java.lang.reflect.Method distance = Canonical.class.getDeclaredMethod(
                    "quantificationDistance",
                    QuantificationTreeNode.class,
                    QuantificationTreeNode.class);
            distance.setAccessible(true);
            int value = (int) distance.invoke(null, disjoint, plain);
            assertTrue(value > 0, "disj vs non-disj quantifier nodes must have nonzero canonical distance");
        } catch (ReflectiveOperationException e) {
            throw new AssertionError("could not validate disj quantification distance", e);
        }
    }

    private static void testImplicationPrenexPolarityDoesNotDoubleNegate() {
        NormalForm antecedentQuantifier = new NormalForm();
        antecedentQuantifier.addEClass(node(
                Opcode.IMPLIES,
                false,
                false,
                node(Opcode.FORALL, false, false, relDecl("a"), predicate("A", variable("a"))),
                predicate("B")));
        antecedentQuantifier.normalize();

        assertEquals(Quantifier.SOME, antecedentQuantifier.getQuantificationTree().getQuantifier(),
                "forall in an implication antecedent must become some after NNF");
        assertTrue(containsOpcode(antecedentQuantifier.getMatrixEGraph(), Opcode.NOT),
                "the antecedent matrix must remain negated exactly once after prenexing");

        NormalForm scopedImplication = new NormalForm();
        scopedImplication.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                relDecl("a"),
                node(Opcode.IMPLIES, false, false, predicate("A", variable("a")), predicate("B"))));
        scopedImplication.normalize();

        assertEquals(Quantifier.ALL, scopedImplication.getQuantificationTree().getQuantifier(),
                "all a | A(a) => B must keep universal quantification over the implication body");
    }

    private static void testImplicationScopeAffectsCanonicalDistance() {
        NormalForm antecedentQuantifier = new NormalForm();
        antecedentQuantifier.addEClass(node(
                Opcode.IMPLIES,
                false,
                false,
                node(Opcode.FORALL, false, false, relDecl("a"), predicate("A", variable("a"))),
                predicate("B")));
        antecedentQuantifier.normalize();

        NormalForm outerQuantifier = new NormalForm();
        outerQuantifier.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                relDecl("a"),
                node(Opcode.IMPLIES, false, false, predicate("A", variable("a")), predicate("B"))));
        outerQuantifier.normalize();

        assertTrue(normalFormDistance(antecedentQuantifier, outerQuantifier) > 0,
                "a quantifier scoped only over an implication antecedent must not collapse with an outer quantifier");
    }

    private static void testIffPrenexPolarity() {
        NormalForm iff = new NormalForm();
        iff.addEClass(node(
                Opcode.IFF,
                false,
                false,
                node(Opcode.EXISTS, false, false, relDecl("x"), predicate("P", variable("x"))),
                predicate("Q")));
        iff.normalize();

        assertTrue(hasQuantifier(iff.getQuantificationTree(), Quantifier.ALL),
                "IFF expansion must account for the implicit negated implication branch");
        assertTrue(hasQuantifier(iff.getQuantificationTree(), Quantifier.SOME),
                "IFF expansion must retain the positive implication branch");
    }

    private static void testAlphaRenamingKeepsCanonicalDistanceZero() {
        NormalForm left = new NormalForm();
        left.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                relDecl("x", "y"),
                predicate("F", variable("x"), variable("y"))));
        left.normalize();

        NormalForm right = new NormalForm();
        right.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                relDecl("a", "b"),
                predicate("F", variable("a"), variable("b"))));
        right.normalize();

        assertEquals(0, normalFormDistance(left, right),
                "alpha-renamed binders with the same De Bruijn structure must remain equivalent");
    }

    private static void testOneAndLoneQuantifierNegation() {
        EGraphNode nestedAll = node(
                Opcode.FORALL,
                false,
                false,
                relDecl("y"),
                node(Opcode.CALL, false, true, variable("x"), variable("y")));
        EGraphNode one = node(Opcode.ONE, false, false, relDecl("x"), nestedAll);
        NormalForm quantified = new NormalForm();
        quantified.addEClass(node(Opcode.NOT, false, false, one));
        quantified.normalize();

        QuantificationTreeNode root = quantified.getQuantificationTree();
        assertEquals(Quantifier.NOTONE, root.getQuantifier(),
                "not one x must become a NOTONE quantifier");
        assertEquals(Quantifier.ALL, root.getChildren().get(0).getQuantifier(),
                "a negation consumed by NOTONE must not flip nested quantifiers");
        assertEquals(Opcode.CALL, quantified.getMatrixEGraph().getOpcode(),
                "a negation consumed by NOTONE must not negate its matrix");

        NormalForm loneQuantified = new NormalForm();
        loneQuantified.addEClass(node(
                Opcode.NOT,
                false,
                false,
                node(Opcode.LONE, false, false, relDecl("z"), node(Opcode.CALL, false, true, variable("z")))));
        loneQuantified.normalize();
        assertEquals(Quantifier.NOTLONE, loneQuantified.getQuantificationTree().getQuantifier(),
                "not lone z must become a NOTLONE quantifier");

        NormalForm unaryMultiplicity = new NormalForm();
        unaryMultiplicity.addEClass(node(
                Opcode.NOT,
                false,
                false,
                node(Opcode.LONE, false, false, global("S"))));
        unaryMultiplicity.normalize();
        assertEquals(Opcode.NOT, unaryMultiplicity.getMatrixEGraph().getOpcode(),
                "not lone S is a multiplicity test and must retain its negation");
        assertEquals(Opcode.LONE, unaryMultiplicity.getMatrixEGraph().getChildren().get(0).getOpcode(),
                "the retained negation must wrap the unary LONE test");
    }

    private static void testQuantifierPolarityRules() {
        assertNegatedQuantifier(Opcode.FORALL, Quantifier.SOME, Opcode.NOT,
                "not all x must become some x with a negated matrix");
        assertNegatedQuantifier(Opcode.EXISTS, Quantifier.ALL, Opcode.NOT,
                "not some x must become all x with a negated matrix");
        assertNegatedQuantifier(Opcode.NO, Quantifier.SOME, Opcode.CALL,
                "not no x must become some x without negating the matrix");

        assertAntecedentQuantifier(Opcode.FORALL, Quantifier.SOME, true,
                "ALL in an implication antecedent must become SOME with a negated matrix");
        assertAntecedentQuantifier(Opcode.EXISTS, Quantifier.ALL, true,
                "SOME in an implication antecedent must become ALL with a negated matrix");
        assertAntecedentQuantifier(Opcode.NO, Quantifier.SOME, false,
                "NO in an implication antecedent must become SOME without negating the matrix");
        assertAntecedentQuantifier(Opcode.ONE, Quantifier.NOTONE, false,
                "ONE in an implication antecedent must become NOTONE without negating the matrix");
        assertAntecedentQuantifier(Opcode.LONE, Quantifier.NOTLONE, false,
                "LONE in an implication antecedent must become NOTLONE without negating the matrix");
    }

    private static void assertNegatedQuantifier(
            Opcode source,
            Quantifier expectedQuantifier,
            Opcode expectedMatrixRoot,
            String message) {
        NormalForm normalForm = new NormalForm();
        EGraphNode quantified = node(source, false, false, relDecl("v"), predicate("P", variable("v")));
        normalForm.addEClass(node(Opcode.NOT, false, false, quantified));
        normalForm.normalize();
        assertEquals(expectedQuantifier, normalForm.getQuantificationTree().getQuantifier(), message);
        assertEquals(expectedMatrixRoot, normalForm.getMatrixEGraph().getOpcode(), message);
    }

    private static void assertAntecedentQuantifier(
            Opcode source,
            Quantifier expectedQuantifier,
            boolean expectedMatrixNegation,
            String message) {
        NormalForm normalForm = new NormalForm();
        EGraphNode quantified = node(source, false, false, relDecl("a"), predicate("P", variable("a")));
        normalForm.addEClass(node(Opcode.IMPLIES, false, false, quantified, predicate("Q")));
        normalForm.normalize();
        assertEquals(expectedQuantifier, normalForm.getQuantificationTree().getQuantifier(), message);
        assertEquals(expectedMatrixNegation, containsOpcode(normalForm.getMatrixEGraph(), Opcode.NOT), message);
    }

    private static boolean containsOpcode(EGraphNode node, Opcode opcode) {
        if (node.getOpcode() == opcode) {
            return true;
        }
        for (EGraphNode child : node.getChildren()) {
            if (containsOpcode(child, opcode)) {
                return true;
            }
        }
        return false;
    }

    private static boolean hasQuantifier(QuantificationTreeNode node, Quantifier quantifier) {
        if (node == null) {
            return false;
        }
        if (node.getQuantifier() == quantifier) {
            return true;
        }
        for (QuantificationTreeNode child : node.getChildren()) {
            if (hasQuantifier(child, quantifier)) {
                return true;
            }
        }
        return false;
    }

    private static int normalFormDistance(NormalForm left, NormalForm right) {
        try {
            java.lang.reflect.Method quantification = Canonical.class.getDeclaredMethod(
                    "quantificationDistance",
                    List.class,
                    List.class);
            java.lang.reflect.Method matrix = Canonical.class.getDeclaredMethod(
                    "matrixDistance",
                    List.class,
                    List.class);
            quantification.setAccessible(true);
            matrix.setAccessible(true);
            List<NormalForm> leftList = Arrays.asList(left);
            List<NormalForm> rightList = Arrays.asList(right);
            return (int) quantification.invoke(null, leftList, rightList)
                    + (int) matrix.invoke(null, leftList, rightList);
        } catch (ReflectiveOperationException e) {
            throw new AssertionError("could not validate normal-form distance", e);
        }
    }

    private static Map<String, String> rename(String from, String to) {
        Map<String, String> renaming = new LinkedHashMap<>();
        renaming.put(from, to);
        return renaming;
    }

    private static Map<String, String> rename(String from1, String to1, String from2, String to2) {
        Map<String, String> renaming = new LinkedHashMap<>();
        renaming.put(from1, to1);
        renaming.put(from2, to2);
        return renaming;
    }

    private static EGraphNode variable(String name) {
        EGraphNode variable = new EGraphNode(name.hashCode(), Opcode.VARIABLE, new ArrayList<>(), false, 0, false,
                Metatype.ATOMIC);
        variable.setSourceName(name);
        variable.setAlphaName(name);
        return variable;
    }

    private static EGraphNode global(String name) {
        EGraphNode binding = new EGraphNode(name.hashCode(), Opcode.GLOBALBINDING, new ArrayList<>(), false, 0,
                false, Metatype.SET);
        binding.setSourceName(name);
        binding.setSourceType(name);
        return binding;
    }

    private static EGraphNode relDecl(String... variableNames) {
        EGraphNode[] children = new EGraphNode[variableNames.length + 1];
        children[0] = global("S");
        for (int i = 0; i < variableNames.length; i++) {
            EGraphNode declared = variable(variableNames[i]);
            declared.setSourceType("S");
            children[i + 1] = declared;
        }
        return node(Opcode.GENERICRELDECL, true, true, children);
    }

    private static EGraphNode disjRelDecl(String... variableNames) {
        EGraphNode[] children = new EGraphNode[variableNames.length + 1];
        children[0] = global("S");
        for (int i = 0; i < variableNames.length; i++) {
            EGraphNode declared = variable(variableNames[i]);
            declared.setSourceType("S");
            children[i + 1] = declared;
        }
        return node(Opcode.DISJ, true, true, children);
    }

    private static EGraphNode predicate(String name, EGraphNode... arguments) {
        EGraphNode predicate = node(Opcode.CALL, false, true, arguments);
        predicate.setSourceName(name);
        return predicate;
    }

    private static EGraphNode node(
            Opcode opcode,
            boolean commutative,
            boolean flexible,
            EGraphNode... children) {
        return new EGraphNode(
                opcode.hashCode(),
                opcode,
                new ArrayList<>(Arrays.asList(children)),
                commutative,
                flexible ? -1 : children.length,
                flexible,
                Metatype.BOOLEAN);
    }

    private static List<String> variableNames(List<EGraphNode> nodes) {
        List<String> names = new ArrayList<>();
        for (EGraphNode node : nodes) {
            if (node.getOpcode() == Opcode.VARIABLE) {
                names.add(node.getAlphaName());
            }
        }
        return names;
    }

    private static void assertTrue(boolean value, String message) {
        if (!value) {
            throw new AssertionError(message);
        }
    }

    private static void assertEquals(Object expected, Object actual, String message) {
        if (!expected.equals(actual)) {
            throw new AssertionError(message + ": expected " + expected + ", got " + actual);
        }
    }
}
