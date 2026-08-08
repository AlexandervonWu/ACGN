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
import is.fivefivefive.CanDis.macros.NormalForm.TemporalOp;
import is.fivefivefive.CanDis.macros.QuantiVar;
import is.fivefivefive.CanDis.macros.QuantiVar.Cardinality;
import is.fivefivefive.CanDis.macros.QuantiVar.Quantifier;

public final class EGraphSaturationTest {
    private EGraphSaturationTest() {
    }

    public static void main(String[] args) {
        testAssociativeCommutativeSaturation();
        testDeMorganSaturation();
        testAssociativeNoncommutativeJoin();
        testSetOperatorsUseSetFlexibleArity();
        testRenamedIdUnionFind();
        testDoubleNegationAndIdempotence();
        testAllNoNotQuantifierEquivalence();
        testBooleanIdentitySaturation();
        testSetIdentitySaturation();
        testImplicationSaturation();
        testEmptyDomainQuantifierRewrite();
        testIteEliminatedFromNormalForm();
        testEndEliminatedFromNormalForm();
        testLetReferenceSurvivesEndCleanupUntilBetaReduction();
        testNegatedRelationDoesNotNegateSetOperands();
        testPrimitiveDomainConstraintNotDuplicatedInMatrix();
        testCommutingPrenexBindingsIgnoreBranchOrder();
        testNegatedSomeAndNoBindingPathsAreEquivalent();
        testCommutativeComplexDomainsUseCanonicalCarrier();
        testComplementEliminatesRedundantSlot();
        testSlotPermutationGroups();
        testDisjModifierIsPreserved();
        testDisjClassesDistinguishDeclarationGroups();
        testDisjModifierAffectsCanonicalDistance();
        testBagMultiplicityPreservedUntilExplicitRewrite();
        testImplicationPrenexPolarityDoesNotDoubleNegate();
        testImplicationScopeAffectsCanonicalDistance();
        testIffPrenexPolarity();
        testAlphaRenamingKeepsCanonicalDistanceZero();
        testOneAndLoneQuantifierNegation();
        testQuantifierPolarityRules();
        testCommutativeDistanceUsesUnorderedMatching();
        testTemporalNegationCrossesPhaseBoundary();
        System.out.println("EGraphSaturationTest passed");
    }

    private static void testAssociativeCommutativeSaturation() {
        EGraphNode nested = node(Opcode.AND, true, true, variable("b"), variable("a"));
        EGraphNode root = node(Opcode.AND, true, true, variable("c"), nested);

        root.saturate();

        assertTrue(root.isSetFlexibleArity(), "AND must use set flexible arity");
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

        EGraphNode disjunction = node(Opcode.OR, true, true, variable("z"), variable("y"), variable("x"));
        disjunction.saturate();
        assertTrue(disjunction.isSetFlexibleArity(), "OR must use set flexible arity");
        assertEquals(Arrays.asList("x", "y", "z"), variableNames(disjunction.getChildren()),
                "OR set operands must be canonicalized without preserving source order");
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
        assertTrue(join.isSequenceFlexibleArity(), "JOIN must use sequence flexible arity");
        assertEquals(Arrays.asList("a", "b", "c"), variableNames(join.getChildren()),
                "JOIN must flatten without reordering operands");
        assertTrue(join.getEClass().getNodes().size() >= 2,
                "associated JOIN terms must share an e-class");
    }

    private static void testSetOperatorsUseSetFlexibleArity() {
        EGraphNode nestedUnion = node(Opcode.PLUS, true, true, variable("b"), variable("a"));
        EGraphNode union = node(Opcode.PLUS, true, true, variable("c"), nestedUnion);
        union.saturate();

        assertTrue(union.isSetFlexibleArity(), "set union PLUS must use set flexible arity");
        assertEquals(Arrays.asList("a", "b", "c"), variableNames(union.getChildren()),
                "set flexible arity must canonicalize set union operands without preserving source order");

        EGraphNode nestedIntersection = node(Opcode.INTERSECT, true, true, variable("right"), variable("left"));
        EGraphNode intersection = node(Opcode.INTERSECT, true, true, variable("tail"), nestedIntersection);
        intersection.saturate();

        assertTrue(intersection.isSetFlexibleArity(), "set intersection must use set flexible arity");
        assertEquals(Arrays.asList("left", "right", "tail"), variableNames(intersection.getChildren()),
                "set flexible arity must canonicalize set intersection operands");

        EGraphNode arrow = node(Opcode.ARROW, false, true, variable("a"), node(Opcode.ARROW, false, true, variable("b"), variable("c")));
        arrow.saturate();

        assertTrue(arrow.isSequenceFlexibleArity(), "relational product ARROW must use sequence flexible arity");
        assertEquals(Arrays.asList("a", "b", "c"), variableNames(arrow.getChildren()),
                "sequence flexible arity must preserve relational product order");
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

        EGraphNode duplicateAnd = variable("duplicateAndX");
        EGraphNode conjunction = node(Opcode.AND, true, true, duplicateAnd, duplicateAnd);
        conjunction.saturate();
        assertEquals(Opcode.VARIABLE, conjunction.getOpcode(), "A AND A must collapse to A");

        EGraphNode duplicateUnion = variable("duplicateUnionX");
        EGraphNode union = node(Opcode.PLUS, true, true, duplicateUnion, duplicateUnion);
        union.saturate();
        assertEquals(Opcode.VARIABLE, union.getOpcode(), "A + A must collapse to A");

        EGraphNode duplicateIntersection = variable("duplicateIntersectionX");
        EGraphNode intersection = node(Opcode.INTERSECT, true, true, duplicateIntersection, duplicateIntersection);
        intersection.saturate();
        assertEquals(Opcode.VARIABLE, intersection.getOpcode(), "A & A must collapse to A");
    }

    private static void testAllNoNotQuantifierEquivalence() {
        NormalForm all = new NormalForm();
        all.addEClass(node(Opcode.FORALL, false, false, relDecl("x"), predicate("P", variable("x"))));
        all.normalize();

        NormalForm noNot = new NormalForm();
        noNot.addEClass(node(
                Opcode.NO,
                false,
                false,
                relDecl("x"),
                node(Opcode.NOT, false, false, predicate("P", variable("x")))));
        noNot.normalize();

        assertEquals(0, normalFormDistance(all, noNot),
                "all x:S | P must be equivalent to no x:S | not P");
    }

    private static void testBooleanIdentitySaturation() {
        EGraphNode andTrue = node(Opcode.AND, true, true, variable("andTrueX"), bool(true));
        andTrue.saturate();
        assertEquals(Opcode.VARIABLE, andTrue.getOpcode(), "A AND true must collapse to A");

        EGraphNode orFalse = node(Opcode.OR, true, true, variable("orFalseX"), bool(false));
        orFalse.saturate();
        assertEquals(Opcode.VARIABLE, orFalse.getOpcode(), "A OR false must collapse to A");

        EGraphNode andFalse = node(Opcode.AND, true, true, variable("andFalseX"), bool(false));
        andFalse.saturate();
        assertEquals(Opcode.CONSTANT, andFalse.getOpcode(), "A AND false must collapse to false");
        assertEquals("false", andFalse.getSourceName(), "A AND false must collapse to false");

        EGraphNode orTrue = node(Opcode.OR, true, true, variable("orTrueX"), bool(true));
        orTrue.saturate();
        assertEquals(Opcode.CONSTANT, orTrue.getOpcode(), "A OR true must collapse to true");
        assertEquals("true", orTrue.getSourceName(), "A OR true must collapse to true");
    }

    private static void testSetIdentitySaturation() {
        EGraphNode inNone = node(Opcode.IN, false, false, variable("inNoneX"), global("none"));
        inNone.saturate();
        assertEquals(Opcode.CONSTANT, inNone.getOpcode(), "x in none must collapse to false");
        assertEquals("false", inNone.getSourceName(), "x in none must collapse to false");

        EGraphNode inUniv = node(Opcode.IN, false, false, variable("inUnivX"), global("univ"));
        inUniv.saturate();
        assertEquals(Opcode.CONSTANT, inUniv.getOpcode(), "x in univ must collapse to true");
        assertEquals("true", inUniv.getSourceName(), "x in univ must collapse to true");

        EGraphNode intersectNone = node(Opcode.INTERSECT, true, true, global("R"), global("none"));
        intersectNone.saturate();
        assertEquals(Opcode.GLOBALBINDING, intersectNone.getOpcode(), "R & none must collapse to none");
        assertEquals("none", intersectNone.getSourceName(), "R & none must collapse to none");

        EGraphNode plusNone = node(Opcode.PLUS, true, true, global("R"), global("none"));
        plusNone.saturate();
        assertEquals(Opcode.GLOBALBINDING, plusNone.getOpcode(), "R + none must collapse to R");
        assertEquals("R", plusNone.getSourceName(), "R + none must collapse to R");
    }

    private static void testImplicationSaturation() {
        EGraphNode implication = node(Opcode.IMPLIES, false, false, variable("impliesA"), variable("impliesB"));
        implication.saturate();
        assertEquals(Opcode.OR, implication.getOpcode(), "A implies B must become not A or B");
        assertTrue(containsOpcode(implication, Opcode.NOT), "A implies B must negate the antecedent");

        EGraphNode falseAntecedent = node(Opcode.IMPLIES, false, false, bool(false), variable("impliesX"));
        falseAntecedent.saturate();
        assertEquals(Opcode.CONSTANT, falseAntecedent.getOpcode(), "false implies A must collapse to true");
        assertEquals("true", falseAntecedent.getSourceName(), "false implies A must collapse to true");
    }

    private static void testEmptyDomainQuantifierRewrite() {
        NormalForm existential = new NormalForm();
        existential.addEClass(node(Opcode.EXISTS, false, false, relDeclOfType("none", "x"), predicate("P", variable("x"))));
        existential.normalize();
        assertEquals(Opcode.CONSTANT, existential.getMatrixEGraph().getOpcode(), "some x: none | P must be false");
        assertEquals("false", existential.getMatrixEGraph().getSourceName(), "some x: none | P must be false");
        assertEquals(0, existential.getMatrixQuantiVars().size(), "empty-domain existential must not retain a binding");

        NormalForm universal = new NormalForm();
        universal.addEClass(node(Opcode.FORALL, false, false, relDeclOfType("none", "x"), predicate("P", variable("x"))));
        universal.normalize();
        assertEquals(Opcode.CONSTANT, universal.getMatrixEGraph().getOpcode(), "all x: none | P must be true");
        assertEquals("true", universal.getMatrixEGraph().getSourceName(), "all x: none | P must be true");
        assertEquals(0, universal.getMatrixQuantiVars().size(), "empty-domain universal must not retain a binding");
    }

    private static void testIteEliminatedFromNormalForm() {
        NormalForm normalForm = new NormalForm();
        normalForm.addEClass(node(
                Opcode.ITE,
                false,
                false,
                predicate("C"),
                predicate("T"),
                predicate("E")));
        normalForm.normalize();

        assertTrue(!containsOpcode(normalForm.getMatrixEGraph(), Opcode.ITE),
                "boolean ITE must be expanded out of the normal-form matrix");
        assertEquals(Opcode.OR, normalForm.getMatrixEGraph().getOpcode(),
                "boolean ITE must normalize to disjunction of guarded branches");
    }

    private static void testEndEliminatedFromNormalForm() {
        NormalForm normalForm = new NormalForm();
        normalForm.addEClass(node(
                Opcode.AND,
                true,
                true,
                variable("x"),
                node(Opcode.END, false, false)));
        normalForm.normalize();

        assertTrue(!containsOpcode(normalForm.getMatrixEGraph(), Opcode.END),
                "normal-form matrix must not retain flexible-arity END sentinels");
        assertEquals(Opcode.VARIABLE, normalForm.getMatrixEGraph().getOpcode(),
                "AND with only a real operand after END pruning must collapse to that operand");
    }

    private static void testLetReferenceSurvivesEndCleanupUntilBetaReduction() {
        EGraphNode comprehension = node(
                Opcode.COMPREHENSION,
                false,
                true,
                relDeclOfType("State", "x", "y"),
                predicate("edge", variable("x"), variable("y")));
        EGraphNode letReference = node(Opcode.LET, false, false);
        letReference.setSourceName("t");
        EGraphNode closure = node(Opcode.CLOSURE, false, false, letReference);
        EGraphNode join = node(Opcode.JOIN, false, true, variable("i"), closure);
        EGraphNode let = node(Opcode.LET, false, false, comprehension, join);
        let.setSourceName("t");

        NormalForm normalForm = new NormalForm();
        normalForm.addEClass(let);
        normalForm.normalize();

        assertTrue(containsOpcode(normalForm.getMatrixEGraph(), Opcode.COMPREHENSION),
                "END cleanup must not erase a bound LET reference before beta reduction");
        assertTrue(containsOpcode(normalForm.getMatrixEGraph(), Opcode.CLOSURE),
                "beta reduction must retain operators surrounding the LET reference");
        assertTrue(!containsOpcode(normalForm.getMatrixEGraph(), Opcode.LET),
                "normalization must eliminate the LET binder and all bound references");
    }

    private static void testNegatedRelationDoesNotNegateSetOperands() {
        NormalForm normalForm = new NormalForm();
        normalForm.addEClass(node(
                Opcode.NOT_IN,
                false,
                false,
                node(Opcode.ARROW, false, true, variable("c"), variable("s"), variable("g")),
                global("Groups")));
        normalForm.normalize();

        assertEquals(Opcode.NOT_IN, normalForm.getMatrixEGraph().getOpcode(),
                "negated membership must stay a negated relation");
        assertTrue(!containsOpcode(normalForm.getMatrixEGraph(), Opcode.NOT),
                "negated membership must not push NOT into set or relation operands");
    }

    private static void testPrimitiveDomainConstraintNotDuplicatedInMatrix() {
        NormalForm primitiveDomain = new NormalForm();
        primitiveDomain.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                relDeclWithDomain(node(Opcode.ONE, false, false, global("Person")), "Person", "x"),
                predicate("P", variable("x"))));
        primitiveDomain.normalize();

        assertEquals(Quantifier.ALL, primitiveDomain.getMatrixQuantiVars().get(0).getQuantifier(),
                "quantifier must stay encoded in QuantiVar");
        assertEquals("Person", primitiveDomain.getMatrixQuantiVars().get(0).getTypeName(),
                "primitive type must stay encoded in QuantiVar");
        assertEquals(Cardinality.ONE, primitiveDomain.getMatrixQuantiVars().get(0).getCardinality(),
                "primitive cardinality must stay encoded in QuantiVar");
        assertEquals(Opcode.CALL, primitiveDomain.getMatrixEGraph().getOpcode(),
                "primitive one Person domain must not add x in one Person to the matrix");
        assertTrue(!containsOpcode(primitiveDomain.getMatrixEGraph(), Opcode.IN),
                "primitive domain constraint already encoded by QuantiVar must not be duplicated");
        assertTrue(!containsOpcode(primitiveDomain.getMatrixEGraph(), Opcode.ONE),
                "primitive multiplicity wrapper already encoded by QuantiVar must not be duplicated");

        NormalForm complexDomain = new NormalForm();
        complexDomain.addEClass(node(
                Opcode.EXISTS,
                false,
                false,
                relDeclWithDomain(
                        node(Opcode.ONE, false, false,
                                node(Opcode.JOIN, false, true, global("Field"), variable("owner"))),
                        "Person",
                        "x"),
                predicate("P", variable("x"))));
        complexDomain.normalize();

        assertEquals(Cardinality.ONE, complexDomain.getMatrixQuantiVars().get(0).getCardinality(),
                "complex-domain cardinality must stay encoded in QuantiVar");
        assertEquals("univ", complexDomain.getMatrixQuantiVars().get(0).getCarrierTypeName(),
                "a matrix guard must replace the arbitrary inferred carrier with univ");
        assertTrue(containsOpcode(complexDomain.getMatrixEGraph(), Opcode.IN),
                "non-primitive domain must still be pushed down into the matrix");
        assertTrue(!containsOpcode(complexDomain.getMatrixEGraph(), Opcode.ONE),
                "pushed-down complex domain must not duplicate cardinality already encoded in QuantiVar");

        NormalForm plainPrimitiveDomain = new NormalForm();
        plainPrimitiveDomain.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                relDeclWithDomain(global("Person"), "Person", "x"),
                predicate("P", variable("x"))));
        plainPrimitiveDomain.normalize();

        assertTrue(normalFormDistance(primitiveDomain, plainPrimitiveDomain) > 0,
                "one Person vs Person binding cardinality must affect quantifier distance");
    }

    private static void testCommutingPrenexBindingsIgnoreBranchOrder() {
        NormalForm left = new NormalForm();
        left.addEClass(node(
                Opcode.AND,
                true,
                true,
                quantifiedOver("Material", "m", "NoParts"),
                quantifiedOver("Component", "c", "SomeParts")));
        left.normalize();

        NormalForm right = new NormalForm();
        right.addEClass(node(
                Opcode.AND,
                true,
                true,
                quantifiedOver("Component", "c", "SomeParts"),
                quantifiedOver("Material", "m", "NoParts")));
        right.normalize();

        assertEquals(0, normalFormDistance(left, right),
                "commutative branches must permit the corresponding ALL bindings to commute");
    }

    private static void testNegatedSomeAndNoBindingPathsAreEquivalent() {
        NormalForm negatedSome = new NormalForm();
        negatedSome.addEClass(node(
                Opcode.NOT,
                false,
                false,
                node(Opcode.EXISTS, false, false, relDecl("t"), predicate("Cycle", variable("t")))));
        negatedSome.normalize();

        NormalForm no = new NormalForm();
        no.addEClass(node(Opcode.NO, false, false, relDecl("t"), predicate("Cycle", variable("t"))));
        no.normalize();

        assertEquals(0, normalFormDistance(negatedSome, no),
                "not some and no must not differ only because one binding came through a negated path");
    }

    private static void testCommutativeComplexDomainsUseCanonicalCarrier() {
        NormalForm left = quantifiedIntersectionDomain("Protected", "Trash", "Protected");
        NormalForm right = quantifiedIntersectionDomain("Trash", "Protected", "Trash");

        assertEquals("univ", left.getMatrixQuantiVars().get(0).getCarrierTypeName(),
                "a complex intersection domain must use the canonical univ carrier");
        assertEquals("univ", right.getMatrixQuantiVars().get(0).getCarrierTypeName(),
                "commuting an intersection must not change its effective carrier");
        assertEquals(0, normalFormDistance(left, right),
                "A & B and B & A domains must produce the same guarded quantifier form");
    }

    private static EGraphNode quantifiedOver(String type, String variable, String predicate) {
        return node(
                Opcode.FORALL,
                false,
                false,
                relDeclWithDomain(global(type), type, variable),
                predicate(predicate, variable(variable)));
    }

    private static NormalForm quantifiedIntersectionDomain(String left, String right, String inferredType) {
        NormalForm normalForm = new NormalForm();
        normalForm.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                relDeclWithDomain(
                        node(Opcode.INTERSECT, true, true, global(left), global(right)),
                        inferredType,
                        "f"),
                predicate("P", variable("f"))));
        normalForm.normalize();
        return normalForm;
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
        assertTrue(disjoint.getMatrixQuantiVars().get(0).isDisj(),
                "disj declaration modifier must survive prenexing");

        NormalForm plain = new NormalForm();
        plain.addEClass(node(Opcode.FORALL, false, false, relDecl("x", "y"),
                predicate("P", variable("x"), variable("y"))));
        plain.normalize();
        assertTrue(!plain.getMatrixQuantiVars().get(0).isDisj(),
                "plain declaration must not be marked disj");
    }

    private static void testDisjModifierAffectsCanonicalDistance() {
        NormalForm disjoint = new NormalForm();
        disjoint.addEClass(node(Opcode.FORALL, false, false, disjRelDecl("x", "y"),
                predicate("P", variable("x"), variable("y"))));
        disjoint.normalize();

        NormalForm plain = new NormalForm();
        plain.addEClass(node(Opcode.FORALL, false, false, relDecl("x", "y"),
                predicate("P", variable("x"), variable("y"))));
        plain.normalize();

        assertTrue(normalFormDistance(disjoint, plain) > 0,
                "disj vs non-disj bindings must have nonzero canonical distance");
    }

    private static void testDisjClassesDistinguishDeclarationGroups() {
        NormalForm grouped = new NormalForm();
        grouped.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                disjRelDecl("x1", "x2"),
                node(
                        Opcode.EXISTS,
                        false,
                        false,
                        disjRelDecl("x3", "x4"),
                        predicate("P", variable("x1"), variable("x2"), variable("x3"), variable("x4")))));
        grouped.normalize();

        List<QuantiVar> bindings = grouped.getMatrixQuantiVars();
        assertEquals(4, bindings.size(), "two disj declarations must produce four bindings");
        assertEquals(Quantifier.ALL, bindings.get(0).getQuantifier(), "first group must stay universal");
        assertEquals(Quantifier.SOME, bindings.get(2).getQuantifier(), "second group must stay existential");
        assertTrue(bindings.get(0).isDisj(), "first disj group must be marked disj");
        assertEquals(bindings.get(0).getDisjointnessClass(), bindings.get(1).getDisjointnessClass(),
                "variables from the same disj declaration must share a class");
        assertEquals(bindings.get(2).getDisjointnessClass(), bindings.get(3).getDisjointnessClass(),
                "variables from the second disj declaration must share a class");
        assertTrue(bindings.get(0).getDisjointnessClass() != bindings.get(2).getDisjointnessClass(),
                "separate disj declarations must not be merged into one global disjointness class");
    }

    private static void testBagMultiplicityPreservedUntilExplicitRewrite() {
        EGraphNode duplicate = variable("bagDuplicateX");
        EGraphNode product = node(Opcode.MUL, true, true, duplicate, duplicate);
        product.saturate();
        assertTrue(product.isBagFlexibleArity(), "MUL must be represented as a bag flexible-arity node");
        assertEquals(2, product.getChildClasses().size(),
                "non-Boolean bag nodes must retain duplicate e-class invocations until an explicit rewrite removes them");
        assertEquals(1, product.getChildClassCardinalities().size(),
                "duplicate bag invocations should be grouped by e-class identity");
        assertEquals(Integer.valueOf(2), product.getChildClassCardinalities().values().iterator().next(),
                "duplicate bag invocations must expose cardinality two");
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

        assertEquals(Quantifier.SOME, antecedentQuantifier.getMatrixQuantiVars().get(0).getQuantifier(),
                "forall in an implication antecedent must become some after branch rewriting and NNF");
        assertEquals("univ", antecedentQuantifier.getMatrixQuantiVars().get(0).getCarrierTypeName(),
                "unsafe existential lift across OR must use a nonempty carrier");
        assertTrue(containsOpcode(antecedentQuantifier.getMatrixEGraph(), Opcode.IN),
                "unsafe existential lift across OR must guard the original domain in the matrix");
        assertTrue(containsOpcode(antecedentQuantifier.getMatrixEGraph(), Opcode.NOT),
                "the antecedent matrix must remain negated exactly once after strict prenexing");

        NormalForm scopedImplication = new NormalForm();
        scopedImplication.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                relDecl("a"),
                node(Opcode.IMPLIES, false, false, predicate("A", variable("a")), predicate("B"))));
        scopedImplication.normalize();

        assertEquals(Quantifier.ALL, scopedImplication.getMatrixQuantiVars().get(0).getQuantifier(),
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

        assertTrue(hasQuantifier(iff.getMatrixQuantiVars(), Quantifier.ALL),
                "IFF expansion must account for the implicit negated implication branch");
        assertTrue(hasQuantifier(iff.getMatrixQuantiVars(), Quantifier.SOME),
                "IFF expansion must retain the positive implication branch");
        assertTrue(containsOpcode(iff.getMatrixEGraph(), Opcode.NOT),
                "IFF expansion must account for the implicit negated implication branch");
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

        assertEquals(Quantifier.NOTONE, quantified.getMatrixQuantiVars().get(0).getQuantifier(),
                "not one x must become a NOTONE quantifier");
        assertEquals(Quantifier.ALL, quantified.getMatrixQuantiVars().get(1).getQuantifier(),
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
        assertEquals(Quantifier.NOTLONE, loneQuantified.getMatrixQuantiVars().get(0).getQuantifier(),
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

        assertAntecedentQuantifierLifted(Opcode.FORALL, Quantifier.SOME, true, "univ",
                "ALL in an implication antecedent must become SOME with a relativized matrix");
        assertAntecedentQuantifierLifted(Opcode.EXISTS, Quantifier.ALL, true, "S",
                "SOME in an implication antecedent may become ALL and cross OR safely");
        assertAntecedentQuantifierLifted(Opcode.NO, Quantifier.SOME, false, "univ",
                "NO in an implication antecedent must become SOME with a relativized matrix");
        assertAntecedentQuantifierLifted(Opcode.ONE, Quantifier.NOTONE, false, "univ",
                "ONE in an implication antecedent must become NOTONE with a relativized matrix");
        assertAntecedentQuantifierLifted(Opcode.LONE, Quantifier.NOTLONE, false, "univ",
                "LONE in an implication antecedent must become NOTLONE with a relativized matrix");
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
        assertEquals(expectedQuantifier, normalForm.getMatrixQuantiVars().get(0).getQuantifier(), message);
        assertEquals(expectedMatrixRoot, normalForm.getMatrixEGraph().getOpcode(), message);
    }

    private static void assertAntecedentQuantifierLifted(
            Opcode source,
            Quantifier expectedQuantifier,
            boolean expectedMatrixNegation,
            String expectedCarrierType,
            String message) {
        NormalForm normalForm = new NormalForm();
        EGraphNode quantified = node(source, false, false, relDecl("a"), predicate("P", variable("a")));
        normalForm.addEClass(node(Opcode.IMPLIES, false, false, quantified, predicate("Q")));
        normalForm.normalize();
        assertEquals(expectedQuantifier, normalForm.getMatrixQuantiVars().get(0).getQuantifier(), message);
        assertEquals(expectedCarrierType, normalForm.getMatrixQuantiVars().get(0).getCarrierTypeName(), message);
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

    private static void testCommutativeDistanceUsesUnorderedMatching() {
        NormalForm left = new NormalForm();
        left.addEClass(node(Opcode.OR, true, true,
                predicate("P", global("Human")), predicate("P", global("Robot"))));
        left.normalize();

        NormalForm right = new NormalForm();
        right.addEClass(node(Opcode.OR, true, true,
                predicate("P", global("Robot")), predicate("P", global("Human"))));
        right.normalize();

        assertEquals(0, normalFormDistance(left, right),
                "commutative matrix distance must minimize over child permutations");
    }

    private static void testTemporalNegationCrossesPhaseBoundary() {
        NormalForm parent = new NormalForm();
        NormalForm left = new NormalForm(parent, TemporalOp.TRIGGEREDL, 101);
        left.addEClass(node(Opcode.NOT_IN, false, false, variable("f"), global("Trash")));
        NormalForm right = new NormalForm(parent, TemporalOp.TRIGGEREDR, 102);
        right.addEClass(node(Opcode.IN, false, false, variable("f"), global("Protected")));
        parent.addTemporalChild(left);
        parent.addTemporalChild(right);

        EGraphNode reference = node(Opcode.REF, false, false);
        reference.setSourceName("temporal[0:2]");
        parent.addEClass(node(Opcode.NOT, false, false, reference));
        parent.normalize();
        parent.pushTemporalNegations();
        left.normalize();
        right.normalize();

        assertEquals(TemporalOp.SINCEL, left.getTemporalOp(),
                "negated TRIGGERED left phase must become SINCE");
        assertEquals(TemporalOp.SINCER, right.getTemporalOp(),
                "negated TRIGGERED right phase must become SINCE");
        assertTrue(containsOpcode(left.getMatrixEGraph(), Opcode.IN)
                        && !containsOpcode(left.getMatrixEGraph(), Opcode.NOT_IN),
                "temporal dualization must negate the left phase matrix");
        assertTrue(containsOpcode(right.getMatrixEGraph(), Opcode.NOT_IN)
                        && !containsOpcode(right.getMatrixEGraph(), Opcode.IN),
                "temporal dualization must negate the right phase matrix");
        assertTrue(!containsOpcode(parent.getMatrixEGraph(), Opcode.NOT),
                "the parent phase must retain only the dualized temporal reference");
    }

    private static boolean hasQuantifier(List<QuantiVar> bindings, Quantifier quantifier) {
        for (QuantiVar binding : bindings) {
            if (binding.getQuantifier() == quantifier) {
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

    private static EGraphNode bool(boolean value) {
        EGraphNode constant = new EGraphNode(Boolean.hashCode(value), Opcode.CONSTANT, new ArrayList<>(), false, 0,
                false, Metatype.BOOLEAN);
        constant.setSourceName(Boolean.toString(value));
        constant.setSourceType("Bool");
        return constant;
    }

    private static EGraphNode relDecl(String... variableNames) {
        return relDeclOfType("S", variableNames);
    }

    private static EGraphNode relDeclOfType(String typeName, String... variableNames) {
        EGraphNode[] children = new EGraphNode[variableNames.length + 1];
        children[0] = global(typeName);
        for (int i = 0; i < variableNames.length; i++) {
            EGraphNode declared = variable(variableNames[i]);
            declared.setSourceType(typeName);
            children[i + 1] = declared;
        }
        return node(Opcode.GENERICRELDECL, true, true, children);
    }

    private static EGraphNode relDeclWithDomain(EGraphNode domain, String primitiveTypeName, String... variableNames) {
        EGraphNode[] children = new EGraphNode[variableNames.length + 1];
        children[0] = domain;
        for (int i = 0; i < variableNames.length; i++) {
            EGraphNode declared = variable(variableNames[i]);
            declared.setSourceType(primitiveTypeName);
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
