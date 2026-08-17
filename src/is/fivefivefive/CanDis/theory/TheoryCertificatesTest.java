package is.fivefivefive.CanDis.theory;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

/** Deterministic Phase F certificate and certified-transition gate. */
public final class TheoryCertificatesTest {
    private static final long SEED = 555_202_608_21L;
    private static final GraphType USER = GraphType.constructor("User");
    private static final GraphType USER_REL = GraphType.relation(USER);
    private static int checks;

    private TheoryCertificatesTest() {
    }

    public static void main(String[] args) {
        testCertificateAlgebra();
        testCertifiedUnionAndFindReplay();
        testCertifiedSymmetryAdmission();
        testForwardCongruenceOnly();
        testContainerLawProvenance();
        testBinderAutomorphismProvenance();
        testInterfaceRestrictionCertificate();
        testGeneratedCertifiedChains();
        testMutationBoundary();
        System.out.println("TheoryCertificatesTest passed: " + checks
                + " checks; deterministic seed=" + SEED);
    }

    /** Definition 7 and Theorem 1: typed endpoints and valid proof composition. */
    private static void testCertificateAlgebra() {
        TypedEClassInterface left = emptyClass(1, GraphType.BOOL);
        TypedEClassInterface right = emptyClass(2, GraphType.BOOL);
        InputEquationCertificate input = inputEquation(
                left, TypedInvocation.identity(right), "eq", 0);
        CertificateVerifier.verify(input);
        check(input.category() == CertificateCategory.INPUT_EQUATION,
                "Input equation retains its proof category");
        check(input.endpointTypeCheck() != null,
                "Every certificate retains its successful endpoint type check");

        TypedEqualityCertificate symmetric = EqualityCertificates.symmetric(input);
        TypedEqualityCertificate roundTrip = EqualityCertificates.transitive(
                input, symmetric);
        CertificateVerifier.verify(roundTrip);
        check(roundTrip.leftEndpoint().equals(roundTrip.rightEndpoint()),
                "Typed symmetry and transitivity compose at exact endpoints");

        TypedSlot source = TypedSlot.source(USER, 0);
        TypedSlot target = TypedSlot.source(USER, 1);
        TypedSlotContext sourceContext = TypedSlotContext.singleton(source);
        TypedSlotContext targetContext = TypedSlotContext.singleton(target);
        TypedEClassInterface sourceClass = new TypedEClassInterface(
                EClassId.of(3), USER_REL, sourceContext);
        TypedEClassInterface targetClass = new TypedEClassInterface(
                EClassId.of(4), USER_REL, sourceContext);
        InputEquationCertificate contextual = inputEquation(
                sourceClass, TypedInvocation.identity(targetClass), "contextual", 1);
        TypedRenaming renaming = TypedRenaming.of(
                sourceContext, targetContext, mapOf(source, target));
        TypedEqualityCertificate renamed = EqualityCertificates.rename(
                contextual, renaming);
        CertificateVerifier.verify(renamed);
        check(renamed.context().equals(targetContext),
                "Typed renaming transports both certificate endpoints");

        expectThrows(IllegalArgumentException.class, () -> EqualityCertificates.transitive(
                input, contextual));
        expectThrows(IllegalArgumentException.class, () -> new InputEquationCertificate(
                CertificateOrigin.containerLaw("sig", "bad", 0),
                input.leftEndpoint(),
                input.rightEndpoint()));
        expectThrows(IllegalArgumentException.class, () -> new InputEquationCertificate(
                CertificateOrigin.inputEquation("model", "ill-typed", 0),
                TypedCertificateEndpoint.eclassWitness(left),
                TypedCertificateEndpoint.eclassWitness(sourceClass)));
    }

    /** Definition 5, Lemma 5, and Theorem 1 obligations 4, 7, and 9. */
    private static void testCertifiedUnionAndFindReplay() {
        TypedSlot ax = TypedSlot.source(USER, 10);
        TypedSlot ay = TypedSlot.source(USER, 11);
        TypedSlot bx = TypedSlot.source(USER, 20);
        TypedSlot cx = TypedSlot.source(USER, 30);
        TypedEClassInterface child = new TypedEClassInterface(
                EClassId.of(10), USER_REL, TypedSlotContext.of(ax, ay));
        TypedEClassInterface middle = new TypedEClassInterface(
                EClassId.of(11), USER_REL, TypedSlotContext.singleton(bx));
        TypedEClassInterface leader = new TypedEClassInterface(
                EClassId.of(12), USER_REL, TypedSlotContext.singleton(cx));

        TypedInvocation middleInChild = new TypedInvocation(
                middle,
                TypedEmbedding.of(
                        middle.exposedSlots(), child.exposedSlots(), mapOf(bx, ay)));
        TypedInvocation leaderInMiddle = new TypedInvocation(
                leader,
                TypedEmbedding.of(
                        leader.exposedSlots(), middle.exposedSlots(), mapOf(cx, bx)));
        ParentEdgeCertificate first = new ParentEdgeCertificate(
                child,
                middleInChild,
                inputEquation(child, middleInChild, "proper-parent", 0));
        ParentEdgeCertificate second = new ParentEdgeCertificate(
                middle,
                leaderInMiddle,
                inputEquation(middle, leaderInMiddle, "parent", 1));

        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        graph.registerEmptyClassForPhaseF(child);
        graph.registerEmptyClassForPhaseF(middle);
        graph.registerEmptyClassForPhaseF(leader);
        graph.unionCertified(first);
        graph.unionCertified(second);
        check(graph.status() == GraphStatus.DIRTY,
                "A certified union dirties the graph for Phase G rebuilding");
        check(graph.eclass(child.id()).symmetryGroup().elements().size() == 1,
                "A union never infers a symmetry from endpoint images");

        TypedSlot gx = TypedSlot.source(USER, 40);
        TypedSlot gy = TypedSlot.source(USER, 41);
        TypedSlotContext caller = TypedSlotContext.of(gx, gy);
        TypedInvocation source = new TypedInvocation(
                child,
                TypedEmbedding.of(
                        child.exposedSlots(), caller, mapOf(ax, gx, ay, gy)));
        TypedFindResult result = graph.findWithProvenance(source);
        check(result.hasParentCertificate(),
                "Certified find retains a replayable primitive proof path");
        TypedEqualityCertificate replay = result.parentCertificate();
        CertificateVerifier.verify(replay);
        check(replay.leftEndpoint().equals(
                    TypedCertificateEndpoint.invocation(source))
                && replay.rightEndpoint().equals(
                        TypedCertificateEndpoint.invocation(result.leaderInvocation())),
                "Compressed find proof has exactly the returned invocation endpoints");
        check(graph.parentAssignments().get(child.id())
                        .provenancePath().steps().size() == 2,
                "Path compression retains both primitive parent certificates");

        TypedEqualityCertificate reflexivity = EqualityCertificates.reflexive(
                TypedCertificateEndpoint.eclassWitness(leader));
        expectThrows(IllegalArgumentException.class, () -> new ParentEdgeCertificate(
                child, middleInChild, reflexivity));
        expectThrows(IllegalArgumentException.class, () -> new ParentEdgeCertificate(
                leader, TypedInvocation.identity(leader), reflexivity));
    }

    /** Definition 7 (SC) and Theorem 1 obligation 5: separately proved symmetry. */
    private static void testCertifiedSymmetryAdmission() {
        TypedSlot x = TypedSlot.source(USER, 50);
        TypedSlot y = TypedSlot.source(USER, 51);
        TypedSlotContext context = TypedSlotContext.of(x, y);
        TypedEClassInterface eclass = new TypedEClassInterface(
                EClassId.of(20), USER_REL, context);
        TypedPermutation swap = TypedPermutation.of(context, mapOf(x, y, y, x));
        TypedInvocation left = TypedInvocation.identity(eclass);
        TypedInvocation right = new TypedInvocation(eclass, swap);
        InputEquationCertificate origin = InputEquationCertificate.betweenInvocations(
                CertificateOrigin.rewriteAxiom("rules", "swap-proof", 0),
                left,
                right);
        SymmetryCertificate certificate = new SymmetryCertificate(left, right, origin);
        check(certificate.inducedPermutation().equals(swap),
                "Symmetry certificate records the induced typed permutation");
        check(certificate.provenanceKind()
                        == SymmetryCertificate.ProvenanceKind.REWRITE_AXIOM,
                "Symmetry certificate records its explicit provenance category");

        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        graph.registerEmptyClassForPhaseF(eclass);
        check(graph.addSymmetryCertified(eclass.id(), certificate),
                "A verified symmetry generator is admitted");
        check(graph.eclass(eclass.id()).symmetryGroup().contains(swap),
                "The certified group closes over the admitted generator");
        check(!graph.addSymmetryCertified(eclass.id(), certificate),
                "An already generated symmetry is not inserted twice");

        TypedSlot z = TypedSlot.source(USER, 52);
        TypedSlotContext three = TypedSlotContext.of(x, y, z);
        TypedEClassInterface s3Class = new TypedEClassInterface(
                EClassId.of(21), USER_REL, three);
        TypedPermutation swapXy = TypedPermutation.of(
                three, mapOf(x, y, y, x, z, z));
        TypedPermutation swapYz = TypedPermutation.of(
                three, mapOf(x, x, y, z, z, y));
        SymmetryCertificate xyCertificate = symmetryAxiom(
                s3Class, swapXy, "s3-xy", 1);
        SymmetryCertificate yzCertificate = symmetryAxiom(
                s3Class, swapYz, "s3-yz", 2);
        TypedSymmetryGroup s3 = TypedSymmetryGroup.certified(
                s3Class, Arrays.asList(xyCertificate, yzCertificate));
        check(s3.elements().size() == 6,
                "Two certified transpositions generate the complete S3 closure");
        for (TypedPermutation element : s3.elements()) {
            CertificateVerifier.verify(s3.derivationFor(s3Class, element));
            check(true,
                    "Every derived e-class symmetry has reconstructible provenance");
        }

        TypedSlotContext larger = TypedSlotContext.of(x, y, z);
        TypedEmbedding proper = TypedEmbedding.of(
                context, larger, mapOf(x, x, y, y));
        TypedInvocation properEndpoint = new TypedInvocation(eclass, proper);
        InputEquationCertificate properOrigin = InputEquationCertificate.betweenInvocations(
                CertificateOrigin.inputEquation("model", "proper", 0),
                properEndpoint,
                properEndpoint);
        expectThrows(IllegalArgumentException.class,
                () -> new SymmetryCertificate(
                        properEndpoint, properEndpoint, properOrigin));
    }

    /** Lemma 4 and Theorem 1 obligation 8: congruence is forward only. */
    private static void testForwardCongruenceOnly() {
        TypedEClassInterface leftClass = emptyClass(30, GraphType.BOOL);
        TypedEClassInterface rightClass = emptyClass(31, GraphType.BOOL);
        OnePortSchema oneBool = new OnePortSchema(GraphType.BOOL);
        OnePort leftPort = OnePort.invocation(
                TypedSlotContext.empty(), TypedInvocation.identity(leftClass));
        OnePort rightPort = OnePort.invocation(
                TypedSlotContext.empty(), TypedInvocation.identity(rightClass));
        InputEquationCertificate childEquation = inputEquation(
                leftClass, TypedInvocation.identity(rightClass), "child", 0);
        CongruenceCertificate portCongruence = CongruenceCertificate.ports(
                leftPort, rightPort, Collections.singletonList(childEquation));

        OperatorDeclaration operator = OperatorDeclaration.monomorphic(
                "opaque-f",
                Collections.singletonList(oneBool),
                GraphType.BOOL,
                Collections.emptyMap(),
                null);
        TypedENode leftNode = TypedENode.construct(
                operator.instantiateMonomorphic(),
                TypedSlotContext.empty(),
                Collections.singletonList(leftPort));
        TypedENode rightNode = TypedENode.construct(
                operator.instantiateMonomorphic(),
                TypedSlotContext.empty(),
                Collections.singletonList(rightPort));
        CongruenceCertificate nodeCongruence = CongruenceCertificate.nodes(
                leftNode, rightNode, Collections.singletonList(portCongruence));
        CertificateVerifier.verify(nodeCongruence);
        check(nodeCongruence.category() == CertificateCategory.FORWARD_CONGRUENCE,
                "Child equality lifts through the parent operator");

        InputEquationCertificate leftCoherence = new InputEquationCertificate(
                CertificateOrigin.inputEquation("model", "left-coherence", 2),
                TypedCertificateEndpoint.eclassWitness(leftClass),
                TypedCertificateEndpoint.node(leftNode));
        InputEquationCertificate rightCoherence = new InputEquationCertificate(
                CertificateOrigin.inputEquation("model", "right-coherence", 3),
                TypedCertificateEndpoint.node(rightNode),
                TypedCertificateEndpoint.eclassWitness(rightClass));
        TypedEqualityCertificate congruenceDerived = EqualityCertificates.transitive(
                EqualityCertificates.transitive(leftCoherence, nodeCongruence),
                rightCoherence);
        ParentEdgeCertificate congruenceParent = new ParentEdgeCertificate(
                leftClass,
                TypedInvocation.identity(rightClass),
                congruenceDerived);
        CertificateVerifier.verifyParentEdge(congruenceParent);
        check(CertificateVerifier.containsCategory(
                        congruenceParent,
                        CertificateCategory.FORWARD_CONGRUENCE),
                "A parent edge can retain a forward-congruence derivation");

        InputEquationCertificate parentOnly = new InputEquationCertificate(
                CertificateOrigin.inputEquation("model", "noninjective-parent", 1),
                TypedCertificateEndpoint.node(leftNode),
                TypedCertificateEndpoint.node(rightNode));
        expectThrows(IllegalArgumentException.class, () -> new ParentEdgeCertificate(
                leftClass, TypedInvocation.identity(rightClass), parentOnly));
        check(parentOnly.premises().isEmpty(),
                "A parent equation exposes no inverse child-equality operation");
    }

    /** Section 4: Seq=A, Bag=AC, Set=ACI, with explicit unit provenance. */
    private static void testContainerLawProvenance() {
        OnePortSchema element = new OnePortSchema(USER);
        SetPortSchema setSchema = new SetPortSchema(
                ContainerEmptiness.K_PLUS, element);
        CertificateOrigin origin = CertificateOrigin.containerLaw(
                "test-signature", "aci-set", 0);
        List<ContainerLawCertificate> certificates = Arrays.asList(
                new ContainerLawCertificate(
                        setSchema, ContainerLawCertificate.Law.ASSOCIATIVITY, origin),
                new ContainerLawCertificate(
                        setSchema, ContainerLawCertificate.Law.COMMUTATIVITY, origin),
                new ContainerLawCertificate(
                        setSchema, ContainerLawCertificate.Law.IDEMPOTENCY, origin));
        ContainerLawDeclaration certified = ContainerLawDeclaration.certified(
                setSchema, certificates);
        check(certified.hasCertifiedLaws(),
                "Set declaration retains ACI provenance separately from its schema");

        TypedSlot x = TypedSlot.source(USER, 60);
        TypedSlot y = TypedSlot.source(USER, 61);
        TypedSlotContext context = TypedSlotContext.of(x, y);
        SetPort set = new SetPort(
                setSchema,
                context,
                Arrays.asList(OnePort.slot(context, y), OnePort.slot(context, x)));
        OperatorDeclaration certifiedOperator = OperatorDeclaration.monomorphic(
                "certified-set",
                Collections.singletonList(setSchema),
                GraphType.BOOL,
                lawMap(certified),
                null);
        TypedENode certifiedNode = TypedENode.construct(
                certifiedOperator.instantiateMonomorphic(),
                context,
                Collections.singletonList(set));
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        check(graph.canonicalize(certifiedNode).shape() != null,
                "Strict canonicalization accepts certified Set laws");

        ContainerLawDeclaration raw = ContainerLawDeclaration.of(
                ContainerLawDeclaration.Kind.SET, true, true, true, false);
        OperatorDeclaration rawOperator = OperatorDeclaration.monomorphic(
                "raw-set",
                Collections.singletonList(setSchema),
                GraphType.BOOL,
                lawMap(raw),
                null);
        TypedENode rawNode = TypedENode.construct(
                rawOperator.instantiateMonomorphic(),
                context,
                Collections.singletonList(set));
        expectThrows(IllegalStateException.class, () -> graph.canonicalize(rawNode));

        BagPortSchema bagSchema = new BagPortSchema(
                ContainerEmptiness.K_PLUS, element);
        expectThrows(IllegalStateException.class, () -> new ContainerLawCertificate(
                bagSchema,
                ContainerLawCertificate.Law.IDEMPOTENCY,
                origin));
        SeqPortSchema emptySequence = new SeqPortSchema(
                ContainerEmptiness.K_ZERO, element);
        ContainerLawCertificate sequenceAssociativity = new ContainerLawCertificate(
                emptySequence,
                ContainerLawCertificate.Law.ASSOCIATIVITY,
                origin);
        expectThrows(IllegalStateException.class, () -> ContainerLawDeclaration.certified(
                emptySequence, Collections.singletonList(sequenceAssociativity)));
    }

    /** Section 3.6 and Lemma 3: Aut(beta) preserves the complete descriptor. */
    private static void testBinderAutomorphismProvenance() {
        TypedSlot x = TypedSlot.canonicalBound(USER, 0);
        TypedSlot y = TypedSlot.canonicalBound(USER, 1);
        StructuralKey domain = StructuralKey.leaf("domain", "User");
        List<BinderCoordinateDescriptor> compatible = Arrays.asList(
                coordinate(x, domain, "all", "one", -1),
                coordinate(y, domain, "all", "one", -1));
        TypedSlotContext context = TypedSlotContext.of(x, y);
        TypedPermutation swap = TypedPermutation.of(context, mapOf(x, y, y, x));
        BinderAutomorphismCertificate certificate = new BinderAutomorphismCertificate(
                compatible,
                swap,
                CertificateOrigin.binderAutomorphism(
                        "test-signature", "all-user-pair", 0));
        BinderBlockDescriptor certified = BinderBlockDescriptor.certified(
                compatible, Collections.singletonList(certificate));
        check(certified.hasCertifiedAutomorphisms()
                        && certified.automorphisms().contains(swap),
                "Complete descriptor admits its certified permutation group");

        TypedSlot z = TypedSlot.canonicalBound(USER, 2);
        List<BinderCoordinateDescriptor> compatibleThree = Arrays.asList(
                coordinate(x, domain, "all", "one", -1),
                coordinate(y, domain, "all", "one", -1),
                coordinate(z, domain, "all", "one", -1));
        TypedSlotContext contextThree = TypedSlotContext.of(x, y, z);
        TypedPermutation swapXy = TypedPermutation.of(
                contextThree, mapOf(x, y, y, x, z, z));
        TypedPermutation swapYz = TypedPermutation.of(
                contextThree, mapOf(x, x, y, z, z, y));
        BinderAutomorphismCertificate binderXy = new BinderAutomorphismCertificate(
                compatibleThree,
                swapXy,
                CertificateOrigin.binderAutomorphism(
                        "test-signature", "all-user-triple-xy", 1));
        BinderAutomorphismCertificate binderYz = new BinderAutomorphismCertificate(
                compatibleThree,
                swapYz,
                CertificateOrigin.binderAutomorphism(
                        "test-signature", "all-user-triple-yz", 2));
        BinderBlockDescriptor certifiedThree = BinderBlockDescriptor.certified(
                compatibleThree, Arrays.asList(binderXy, binderYz));
        check(certifiedThree.automorphisms().elements().size() == 6,
                "Certified binder generators close to the full descriptor S3");
        for (TypedPermutation element : certifiedThree.automorphisms().elements()) {
            CertificateVerifier.verify(
                    certifiedThree.automorphisms().derivationFor(
                            certifiedThree, element));
            check(true,
                    "Every derived binder automorphism has reconstructible provenance");
        }

        List<BinderCoordinateDescriptor> incompatible = Arrays.asList(
                coordinate(x, domain, "all", "one", -1),
                coordinate(y, domain, "some", "one", -1));
        expectThrows(IllegalArgumentException.class, () -> new BinderAutomorphismCertificate(
                incompatible,
                swap,
                CertificateOrigin.binderAutomorphism(
                        "test-signature", "incompatible", 1)));

        BindBlockPortSchema certifiedSchema = new BindBlockPortSchema(
                certified, new OnePortSchema(USER));
        TypedRenaming occurrence = certified.freshOccurrenceRenaming(
                TypedSlotContext.empty());
        BindBlockPort certifiedPort = new BindBlockPort(
                certifiedSchema,
                TypedSlotContext.empty(),
                occurrence,
                OnePort.slot(occurrence.codomain(), occurrence.apply(x)));
        OperatorDeclaration certifiedOperator = OperatorDeclaration.monomorphic(
                "certified-block",
                Collections.singletonList(certifiedSchema),
                GraphType.BOOL,
                Collections.emptyMap(),
                null);
        TypedENode certifiedNode = TypedENode.construct(
                certifiedOperator.instantiateMonomorphic(),
                TypedSlotContext.empty(),
                Collections.singletonList(certifiedPort));
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        check(graph.canonicalize(certifiedNode).shape() != null,
                "Strict canonicalization uses a certified Aut(beta)");

        BinderBlockDescriptor raw = new BinderBlockDescriptor(
                compatible, Collections.singletonList(swap));
        BindBlockPortSchema rawSchema = new BindBlockPortSchema(
                raw, new OnePortSchema(USER));
        TypedRenaming rawOccurrence = raw.freshOccurrenceRenaming(
                TypedSlotContext.empty());
        BindBlockPort rawPort = new BindBlockPort(
                rawSchema,
                TypedSlotContext.empty(),
                rawOccurrence,
                OnePort.slot(rawOccurrence.codomain(), rawOccurrence.apply(x)));
        OperatorDeclaration rawOperator = OperatorDeclaration.monomorphic(
                "raw-block",
                Collections.singletonList(rawSchema),
                GraphType.BOOL,
                Collections.emptyMap(),
                null);
        TypedENode rawNode = TypedENode.construct(
                rawOperator.instantiateMonomorphic(),
                TypedSlotContext.empty(),
                Collections.singletonList(rawPort));
        expectThrows(IllegalStateException.class, () -> graph.canonicalize(rawNode));
    }

    /** Theorem 1 obligation 6: restriction requires typed factorization evidence. */
    private static void testInterfaceRestrictionCertificate() {
        TypedSlot x = TypedSlot.source(USER, 70);
        TypedSlot y = TypedSlot.source(USER, 71);
        TypedEClassInterface original = new TypedEClassInterface(
                EClassId.of(40), USER_REL, TypedSlotContext.of(x, y));
        TypedSlot canonicalX = TypedSlot.canonicalFree(USER, 0);
        TypedSlot canonicalY = TypedSlot.canonicalFree(USER, 1);
        TypedSlotContext exactContext = TypedSlotContext.of(canonicalX, canonicalY);
        OnePortSchema oneUser = new OnePortSchema(USER);
        OperatorDeclaration operator = OperatorDeclaration.monomorphic(
                "restriction-shape",
                Arrays.asList(oneUser, oneUser),
                USER_REL,
                Collections.emptyMap(),
                null);
        CanonicalShape shape = CanonicalShape.of(TypedENode.construct(
                operator.instantiateMonomorphic(),
                exactContext,
                Arrays.asList(
                        OnePort.slot(exactContext, canonicalX),
                        OnePort.slot(exactContext, canonicalY))));
        TypedRenaming instantiation = TypedRenaming.of(
                exactContext,
                original.exposedSlots(),
                mapOf(canonicalX, x, canonicalY, y));
        ShapeWitness witness = new ShapeWitness(
                exactContext,
                original.exposedSlots(),
                original.exposedSlots(),
                instantiation);
        TypedEClassRecord record = TypedEClassRecord.of(
                original,
                Collections.singletonMap(shape, witness),
                TypedSymmetryGroup.identity(original.exposedSlots()));
        TypedSlotContext restrictedContext = TypedSlotContext.singleton(x);
        TypedCertificateEndpoint restricted = TypedCertificateEndpoint.restrictedWitness(
                original, restrictedContext);
        TypedEmbedding inclusion = TypedEmbedding.inclusion(
                restrictedContext, original.exposedSlots());
        InputEquationCertificate factorization = new InputEquationCertificate(
                CertificateOrigin.inputEquation("model", "independence", 0),
                TypedCertificateEndpoint.eclassWitness(original),
                restricted.act(inclusion));
        InterfaceRestrictionCertificate certificate =
                new InterfaceRestrictionCertificate(
                        record, restrictedContext, factorization);
        CertificateVerifier.verifyInterfaceRestriction(certificate);
        check(certificate.inclusion().equals(inclusion)
                        && certificate.restrictedInterface().exposedSlots()
                                .equals(restrictedContext),
                "Restriction certificate records the exact typed factorization");
        ShapeWitness transported = certificate.transportedShapeWitnesses().get(shape);
        check(transported != null
                        && transported.exactSlots().equals(witness.exactSlots())
                        && transported.ambientSupport().equals(witness.ambientSupport())
                        && transported.instantiatingRenaming().equals(
                                witness.instantiatingRenaming())
                        && transported.exposedInterface().equals(restrictedContext),
                "Restriction transport preserves each witness field except its interface");

        TypedSlottedPortEGraph graph = TypedSlottedPortEGraph.structuralFixture();
        graph.registerRecordForPhaseD(record);
        graph.verifyInterfaceRestriction(certificate);
        check(graph.eclass(original.id()).interfaceView().equals(original),
                "Phase F verification does not perform the Phase G restriction transaction");
        expectThrows(IllegalArgumentException.class,
                () -> new InterfaceRestrictionCertificate(
                        record, original.exposedSlots(), factorization));
        expectThrows(IllegalArgumentException.class,
                () -> new InterfaceRestrictionCertificate(
                        record,
                        restrictedContext,
                        EqualityCertificates.reflexive(
                                TypedCertificateEndpoint.eclassWitness(original))));
    }

    /** Lemma 5: generated parent paths compose embeddings and PC derivations. */
    private static void testGeneratedCertifiedChains() {
        Random random = new Random(SEED);
        for (int round = 0; round < 64; round++) {
            int length = 2 + random.nextInt(6);
            List<TypedEClassInterface> classes = new ArrayList<>(length);
            List<TypedSlot> slots = new ArrayList<>(length);
            TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
            for (int index = 0; index < length; index++) {
                TypedSlot slot = TypedSlot.source(
                        USER, 10_000L + round * 20L + index);
                slots.add(slot);
                TypedEClassInterface eclass = new TypedEClassInterface(
                        EClassId.of(10_000L + round * 20L + index),
                        USER_REL,
                        TypedSlotContext.singleton(slot));
                classes.add(eclass);
                graph.registerEmptyClassForPhaseF(eclass);
            }
            for (int index = 0; index + 1 < length; index++) {
                TypedEClassInterface child = classes.get(index);
                TypedEClassInterface parent = classes.get(index + 1);
                TypedInvocation parentInvocation = new TypedInvocation(
                        parent,
                        TypedRenaming.of(
                                parent.exposedSlots(),
                                child.exposedSlots(),
                                mapOf(slots.get(index + 1), slots.get(index))));
                ParentEdgeCertificate certificate = new ParentEdgeCertificate(
                        child,
                        parentInvocation,
                        inputEquation(child, parentInvocation, "generated", index));
                graph.unionCertified(certificate);
            }
            TypedFindResult result = graph.findWithProvenance(
                    TypedInvocation.identity(classes.get(0)));
            TypedEqualityCertificate replay = result.parentCertificate();
            CertificateVerifier.verify(replay);
            check(result.leaderInvocation().eclass().equals(classes.get(length - 1)),
                    "Generated certified chain reaches its final leader");
            check(result.parentPath().steps().size() == length - 1,
                    "Generated compressed path retains every primitive proof");
            check(replay.leftEndpoint().equals(
                        TypedCertificateEndpoint.eclassWitness(classes.get(0)))
                    && replay.rightEndpoint().equals(
                            TypedCertificateEndpoint.invocation(
                                    result.leaderInvocation())),
                    "Generated path replay has exact endpoints");
        }
    }

    /** Mission sections 16 and 25: proof algebra and raw mutation paths stay closed. */
    private static void testMutationBoundary() {
        check(TypedEqualityCertificate.class.isSealed(),
                "Certificate implementations form a closed derivation algebra");
        for (Constructor<?> constructor : ParentStep.class.getDeclaredConstructors()) {
            check(!Modifier.isPublic(constructor.getModifiers()),
                    "No public ParentStep constructor bypasses parent-edge certification");
        }
        for (Method method : TypedSlottedPortEGraph.class.getDeclaredMethods()) {
            if (method.getName().equals("linkLeadersForPhaseD")
                    || method.getName().equals("registerRecordForPhaseD")) {
                check(!Modifier.isPublic(method.getModifiers()),
                        "Structural setup mutation is not a public graph transition");
            }
        }
        check(new TypedSlottedPortEGraph().certificateMode()
                        == GraphCertificateMode.REQUIRED,
                "The public graph defaults to certificate-enforcing mode");
    }

    private static BinderCoordinateDescriptor coordinate(
            TypedSlot slot,
            StructuralKey domain,
            String quantifier,
            String multiplicity,
            int disjointnessClass) {
        return new BinderCoordinateDescriptor(
                slot,
                domain,
                quantifier,
                multiplicity,
                disjointnessClass,
                TypedSlotContext.empty());
    }

    private static TypedEClassInterface emptyClass(long id, GraphType outputType) {
        return new TypedEClassInterface(
                EClassId.of(id), outputType, TypedSlotContext.empty());
    }

    private static InputEquationCertificate inputEquation(
            TypedEClassInterface child,
            TypedInvocation parent,
            String equationId,
            int ordinal) {
        return new InputEquationCertificate(
                CertificateOrigin.inputEquation("test-model", equationId, ordinal),
                TypedCertificateEndpoint.eclassWitness(child),
                TypedCertificateEndpoint.invocation(parent));
    }

    private static SymmetryCertificate symmetryAxiom(
            TypedEClassInterface eclass,
            TypedPermutation permutation,
            String equationId,
            int ordinal) {
        TypedInvocation left = TypedInvocation.identity(eclass);
        TypedInvocation right = new TypedInvocation(eclass, permutation);
        return new SymmetryCertificate(
                left,
                right,
                InputEquationCertificate.betweenInvocations(
                        CertificateOrigin.rewriteAxiom(
                                "test-rules", equationId, ordinal),
                        left,
                        right));
    }

    private static Map<PortPath, ContainerLawDeclaration> lawMap(
            ContainerLawDeclaration declaration) {
        Map<PortPath, ContainerLawDeclaration> result = new LinkedHashMap<>();
        result.put(PortPath.at(0), declaration);
        return result;
    }

    private static Map<TypedSlot, TypedSlot> mapOf(TypedSlot... entries) {
        if ((entries.length & 1) != 0) {
            throw new IllegalArgumentException("mapOf requires key/value pairs");
        }
        Map<TypedSlot, TypedSlot> result = new LinkedHashMap<>();
        for (int index = 0; index < entries.length; index += 2) {
            result.put(entries[index], entries[index + 1]);
        }
        return result;
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
        } catch (Throwable throwable) {
            if (expected.isInstance(throwable)) {
                return;
            }
            throw new AssertionError(
                    "Expected " + expected.getSimpleName()
                            + " but got " + throwable,
                    throwable);
        }
        throw new AssertionError("Expected " + expected.getSimpleName());
    }
}
