package is.fivefivefive.CanDis.theory;

import java.util.List;

/** Axiomatic regressions for the ordered dependent JOIN/ARROW Seq carrier. */
public final class TheoryDependentChainTest {
    private static int checks;

    private TheoryDependentChainTest() {
    }

    public static void main(String[] args) {
        runAssertions();
        System.out.println("TheoryDependentChainTest passed: " + checks + " checks");
    }

    static int runAssertions() {
        checks = 0;
        testJoinReassociation();
        testJoinMultiplicity();
        testUnaryInteriorJoinHasNoReassociationLicense();
        testArrowReassociationAndMultiplicity();
        testExactTypingRejectsUnsoundChains();
        return checks;
    }

    private static void testJoinReassociation() {
        GraphType a = GraphType.constructor("A");
        GraphType b = GraphType.constructor("B");
        GraphType c = GraphType.constructor("C");
        GraphType d = GraphType.constructor("D");
        ChainFixture fixture = fixture(
                GraphType.relation(a, b),
                GraphType.relation(b, c),
                GraphType.relation(c, d));

        DependentChainApplication leftAssociated = new DependentChainApplication(
                DependentChainKind.JOIN,
                new DependentChainApplication(
                        DependentChainKind.JOIN,
                        fixture.first(),
                        fixture.second()),
                fixture.third());
        DependentChainApplication rightAssociated = new DependentChainApplication(
                DependentChainKind.JOIN,
                fixture.first(),
                new DependentChainApplication(
                        DependentChainKind.JOIN,
                        fixture.second(),
                        fixture.third()));

        check(leftAssociated.outputType().equals(GraphType.relation(a, d)),
                "JOIN derives the exact outer relation columns");
        check(leftAssociated.outputType().equals(rightAssociated.outputType()),
                "Both JOIN associations derive one exact result type");
        CertifiedDependentChainConstruction left = construct(leftAssociated);
        CertifiedDependentChainConstruction right = construct(rightAssociated);
        check(left.node().equals(right.node()),
                "JOIN reassociation reaches one ordered dependent Seq node");
        check(!left.certificate().leftEndpoint().equals(
                        right.certificate().leftEndpoint())
                        && left.certificate().rightEndpoint().equals(
                                right.certificate().rightEndpoint()),
                "Distinct source associations retain distinct proofs to one target");
        assertDependentSequence(left, fixture.ports());
        check(left.certificate().theoryIndex().equals(
                        DependentChainTheory.proofIndex(
                                DependentChainKind.JOIN,
                                fixture.types(),
                                GraphType.relation(a, d))),
                "JOIN certificate is indexed by every operand and result type");
    }

    private static void testArrowReassociationAndMultiplicity() {
        GraphType a = GraphType.constructor("A");
        GraphType b = GraphType.constructor("B");
        ChainFixture fixture = fixture(
                GraphType.relation(a),
                GraphType.relation(b),
                GraphType.relation(b));
        DependentChainApplication leftAssociated = new DependentChainApplication(
                DependentChainKind.ARROW,
                new DependentChainApplication(
                        DependentChainKind.ARROW,
                        fixture.first(),
                        fixture.second()),
                fixture.second());
        DependentChainApplication rightAssociated = new DependentChainApplication(
                DependentChainKind.ARROW,
                fixture.first(),
                new DependentChainApplication(
                        DependentChainKind.ARROW,
                        fixture.second(),
                        fixture.second()));
        CertifiedDependentChainConstruction left = construct(leftAssociated);
        CertifiedDependentChainConstruction right = construct(rightAssociated);
        check(left.node().equals(right.node()),
                "ARROW reassociation reaches one ordered dependent Seq node");
        check(left.node().outputType().equals(GraphType.relation(a, b, b)),
                "ARROW concatenates exact relation columns in source order");
        SeqPort sequence = (SeqPort) left.node().ports().get(0);
        check(sequence.elements().size() == 3
                        && sequence.elements().get(1).equals(
                                sequence.elements().get(2)),
                "Dependent Seq retains repeated operand occurrences");
        check(!left.node().operator().usesFlatConstruction(),
                "Dependent ARROW does not claim a homogeneous flat license");
        ContainerLawDeclaration declaration = left.node().operator()
                .lawForPath(PortPath.at(0));
        check(declaration.kind() == ContainerLawDeclaration.Kind.SEQ
                        && !declaration.associative()
                        && !declaration.commutative()
                        && !declaration.idempotent()
                        && !declaration.hasUnit(),
                "The Seq carrier itself has no generic A/C/I/U authority");
    }

    private static void testJoinMultiplicity() {
        GraphType atom = GraphType.constructor("A");
        GraphType binary = GraphType.relation(atom, atom);
        ChainFixture fixture = fixture(binary, binary, binary);
        DependentChainApplication repeated = new DependentChainApplication(
                DependentChainKind.JOIN,
                fixture.first(),
                fixture.first());
        CertifiedDependentChainConstruction construction = construct(repeated);
        SeqPort sequence = (SeqPort) construction.node().ports().get(0);
        check(sequence.elements().equals(List.of(
                        fixture.first().port(), fixture.first().port())),
                "Dependent JOIN Seq retains a repeated source occurrence");
        check(construction.node().outputType().equals(binary),
                "Repeated binary JOIN derives the exact boundary result type");
    }

    private static void testUnaryInteriorJoinHasNoReassociationLicense() {
        GraphType x = GraphType.constructor("X");
        ChainFixture fixture = fixture(
                GraphType.relation(x, x),
                GraphType.relation(x),
                GraphType.relation(x, x));
        DependentChainApplication leftInner = new DependentChainApplication(
                DependentChainKind.JOIN,
                fixture.first(),
                fixture.second());
        DependentChainApplication rightInner = new DependentChainApplication(
                DependentChainKind.JOIN,
                fixture.second(),
                fixture.third());
        expectThrows(DependentChainTheory.UnsupportedFlattening.class, () ->
                new DependentChainApplication(
                        DependentChainKind.JOIN,
                        leftInner,
                        fixture.third()));
        expectThrows(DependentChainTheory.UnsupportedFlattening.class, () ->
                new DependentChainApplication(
                        DependentChainKind.JOIN,
                        fixture.first(),
                        rightInner));
    }

    private static void testExactTypingRejectsUnsoundChains() {
        GraphType a = GraphType.constructor("A");
        GraphType b = GraphType.constructor("B");
        GraphType c = GraphType.constructor("C");
        ChainFixture mismatch = fixture(
                GraphType.relation(a, b),
                GraphType.relation(c, a),
                GraphType.relation(a));
        expectThrows(IllegalArgumentException.class, () ->
                new DependentChainApplication(
                        DependentChainKind.JOIN,
                        mismatch.first(),
                        mismatch.second()));

        ChainFixture roles = fixture(
                GraphType.relation(a, b),
                GraphType.relation(b, c),
                GraphType.relation(c));
        DependentChainApplication ordered = new DependentChainApplication(
                DependentChainKind.JOIN,
                roles.first(),
                roles.second());
        expectThrows(IllegalArgumentException.class, () ->
                new DependentChainApplication(
                        DependentChainKind.JOIN,
                        roles.second(),
                        roles.first()));
        CertifiedDependentChainConstruction construction = construct(ordered);
        SeqPortSchema schema = (SeqPortSchema) construction.node().operator()
                .portSchemas().get(0);
        expectThrows(IllegalArgumentException.class, () -> new SeqPort(
                schema,
                roles.context(),
                List.of(roles.second().port(), roles.first().port())));
        GraphType x = GraphType.constructor("AlloySig:X");
        GraphType parameterType = GraphType.constructor("AlloyCarrier", x);
        TypedSlot parameterSlot = TypedSlot.source(parameterType, 70_010);
        TypedSlotContext parameterContext = TypedSlotContext.of(parameterSlot);
        DependentChainLeaf parameterLeaf = new DependentChainLeaf(
                OnePort.slot(parameterContext, parameterSlot),
                GraphType.relation(x));
        check(parameterLeaf.typeRule()
                        == DependentChainTheory.LeafTypeRule.PRIMITIVE_SET_SINGLETON,
                "a parameter uses its exact underlying carrier proof");
        GraphType forgedParameter = GraphType.constructor(
                "Parameter0",
                GraphType.constructor("AlloyCarrier", x));
        TypedSlot forgedSlot = TypedSlot.source(forgedParameter, 70_011);
        TypedSlotContext forgedContext = TypedSlotContext.of(forgedSlot);
        expectThrows(IllegalArgumentException.class, () ->
                new DependentChainLeaf(
                        OnePort.slot(forgedContext, forgedSlot),
                        GraphType.relation(x)));
        expectThrows(DependentChainTheory.UnsupportedFlattening.class, () ->
                DependentChainTheory.requireSoundFlattening(
                        DependentChainKind.ARROW,
                        List.of(
                                GraphType.relation(
                                        GraphType.constructor("AlloySig:univ")),
                                GraphType.relation(x))));
        check(DependentChainTheory.DIGEST.length() == 64,
                "Dependent-chain source theory has a fixed SHA-256 identity");
    }

    private static CertifiedDependentChainConstruction construct(
            DependentChainApplication application) {
        CertifiedDependentChainConstruction construction =
                TypedENode.constructDependentChainCertified(
                        application,
                        SemanticProfile.alloyOverflowForbidding());
        CertificateVerifier.verify(construction.certificate());
        return construction;
    }

    private static void assertDependentSequence(
            CertifiedDependentChainConstruction construction,
            List<OnePort> expected) {
        check(construction.node().ports().size() == 1
                        && construction.node().ports().get(0) instanceof SeqPort,
                "Dependent chain has exactly one Seq carrier");
        SeqPort sequence = (SeqPort) construction.node().ports().get(0);
        check(sequence.schema().isDependent()
                        && sequence.schema().positionalElementSchemas().size()
                                == expected.size(),
                "Seq carries one exact schema per operand position");
        check(sequence.elements().equals(expected),
                "Seq preserves every operand in source order");
        for (int index = 0; index < expected.size(); index++) {
            check(sequence.schema().schemaAt(index).equals(
                            expected.get(index).schema()),
                    "Position " + index + " retains its independent type proof");
        }
    }

    private static ChainFixture fixture(
            GraphType first,
            GraphType second,
            GraphType third) {
        TypedSlot a = TypedSlot.source(first, 70_001);
        TypedSlot b = TypedSlot.source(second, 70_002);
        TypedSlot c = TypedSlot.source(third, 70_003);
        TypedSlotContext context = TypedSlotContext.of(a, b, c);
        OnePort pa = OnePort.slot(context, a);
        OnePort pb = OnePort.slot(context, b);
        OnePort pc = OnePort.slot(context, c);
        return new ChainFixture(
                context,
                new DependentChainLeaf(pa),
                new DependentChainLeaf(pb),
                new DependentChainLeaf(pc),
                List.of(pa, pb, pc),
                List.of(first, second, third));
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
        } catch (Throwable thrown) {
            if (expected.isInstance(thrown)) {
                return;
            }
            throw new AssertionError(
                    "Expected " + expected.getSimpleName() + " but got " + thrown,
                    thrown);
        }
        throw new AssertionError("Expected " + expected.getSimpleName());
    }

    private record ChainFixture(
            TypedSlotContext context,
            DependentChainLeaf first,
            DependentChainLeaf second,
            DependentChainLeaf third,
            List<OnePort> ports,
            List<GraphType> types) {
    }
}
