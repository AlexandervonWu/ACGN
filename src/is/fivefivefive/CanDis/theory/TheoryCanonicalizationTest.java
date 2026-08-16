package is.fivefivefive.CanDis.theory;

import java.lang.reflect.Constructor;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

/** Deterministic Phase E alpha, canon_G, and differential tests. */
public final class TheoryCanonicalizationTest {
    private static final long SEED = 555_202_608_19L;
    private static final GraphType USER = GraphType.constructor("User");
    private static int checks;

    private TheoryCanonicalizationTest() {
    }

    public static void main(String[] args) {
        testUncappedTypedRenamingEnumeration();
        testStructuralAlphaGroupoidAndBinders();
        testGraphRelativeRelationDistinctions();
        testContainerCanonicalizationAndGlobalSetRenaming();
        testLeaderNormalizationAndSymmetry();
        testGeneratedSymmetryDifferential();
        testGeneratedDifferentialCanonicalization();
        testDeterminismAndIdempotence();
        testDirtyAndSupportShrinkRejection();
        testCanonicalizerBoundary();
        System.out.println("TheoryCanonicalizationTest passed: " + checks
                + " checks; deterministic seed=" + SEED);
    }

    private static void testUncappedTypedRenamingEnumeration() {
        List<TypedSlot> sourceSlots = new ArrayList<>();
        for (int index = 0; index < 7; index++) {
            sourceSlots.add(TypedSlot.source(USER, index + 20));
        }
        TypedSlotContext source = TypedSlotContext.of(sourceSlots);
        TypedSlotContext canonical = source.canonicalFreeContext();
        long[] count = {0L};
        TypedRenamingEnumerator.forEach(canonical, source, renaming -> {
            check(renaming.isRenaming(), "Every enumerated map is a renaming");
            check(renaming.isTypePreserving(), "Every enumerated map preserves types");
            count[0]++;
        });
        check(count[0] == 5_040L, "Seven same-typed slots enumerate all 7! bijections");

        long[] impossible = {0L};
        TypedRenamingEnumerator.forEach(
                TypedSlotContext.singleton(TypedSlot.source(GraphType.INT, 0)),
                TypedSlotContext.singleton(TypedSlot.source(GraphType.BOOL, 0)),
                ignored -> impossible[0]++);
        check(impossible[0] == 0L, "Cross-type contexts have no typed renaming");

        SeqPortSchema schema = new SeqPortSchema(new OnePortSchema(USER));
        InstantiatedOperator operator = operator(
                "seven", Collections.singletonList(schema), GraphType.BOOL);
        List<PortValue> elements = new ArrayList<>();
        for (TypedSlot slot : sourceSlots) {
            elements.add(OnePort.slot(source, slot));
        }
        TypedENode node = TypedENode.construct(
                operator,
                source,
                Collections.singletonList(new SeqPort(schema, source, elements)));
        assertDifferential(new TypedSlottedPortEGraph(), node);
    }

    private static void testStructuralAlphaGroupoidAndBinders() {
        TypedSlot x = TypedSlot.source(USER, 0);
        TypedSlot y = TypedSlot.source(USER, 1);
        TypedSlot a = TypedSlot.source(USER, 10);
        TypedSlot b = TypedSlot.source(USER, 11);
        TypedSlot u = TypedSlot.source(USER, 20);
        TypedSlot v = TypedSlot.source(USER, 21);
        TypedSlotContext first = TypedSlotContext.of(x, y);
        TypedSlotContext second = TypedSlotContext.of(a, b);
        TypedSlotContext third = TypedSlotContext.of(u, v);
        SeqPortSchema schema = new SeqPortSchema(new OnePortSchema(USER));
        InstantiatedOperator operator = operator(
                "ordered-pair", Collections.singletonList(schema), GraphType.BOOL);
        TypedENode n1 = sequenceNode(operator, schema, first, Arrays.asList(x, y));
        TypedRenaming rho1 = TypedRenaming.of(first, second, mapOf(x, b, y, a));
        TypedRenaming rho2 = TypedRenaming.of(second, third, mapOf(a, v, b, u));
        TypedENode n2 = n1.act(rho1);
        TypedENode n3 = n2.act(rho2);

        check(TypedAlphaEquivalence.structuralNodes(
                        n1, n1, TypedRenaming.identity(first)),
                "Structural alpha is reflexive");
        check(TypedAlphaEquivalence.structuralNodes(n1, n2, rho1),
                "Structural alpha applies one indexed free renaming");
        check(TypedAlphaEquivalence.structuralNodes(n2, n1, rho1.inverse()),
                "Structural alpha is symmetric with inverse index");
        check(TypedAlphaEquivalence.structuralNodes(n1, n3, rho1.andThen(rho2)),
                "Structural alpha composes its typed indices");

        TypedSlot free = TypedSlot.source(USER, 30);
        TypedSlot renamedFree = TypedSlot.source(USER, 31);
        TypedSlot bound = TypedSlot.source(USER, 90);
        TypedSlot renamedBound = TypedSlot.source(USER, 91);
        TypedSlotContext freeContext = TypedSlotContext.singleton(free);
        TypedSlotContext renamedContext = TypedSlotContext.singleton(renamedFree);
        SeqPortSchema bodySchema = new SeqPortSchema(new OnePortSchema(USER));
        BindPortSchema bindSchema = new BindPortSchema(USER, bodySchema);
        InstantiatedOperator binderOperator = operator(
                "binder", Collections.singletonList(bindSchema), GraphType.BOOL);
        BindPort leftBinder = binder(
                bindSchema, freeContext, free, bound, bodySchema);
        BindPort rightBinder = binder(
                bindSchema, renamedContext, renamedFree, renamedBound, bodySchema);
        TypedENode leftNode = TypedENode.construct(
                binderOperator, freeContext, Collections.singletonList(leftBinder));
        TypedENode rightNode = TypedENode.construct(
                binderOperator, renamedContext, Collections.singletonList(rightBinder));
        TypedRenaming freeRename = TypedRenaming.of(
                freeContext, renamedContext, mapOf(free, renamedFree));
        check(TypedAlphaEquivalence.structuralNodes(
                        leftNode, rightNode, freeRename),
                "Binder alpha accepts a fresh same-typed bound coordinate");
        CanonicalizationResult leftCanonical = assertDifferential(
                new TypedSlottedPortEGraph(), leftNode);
        CanonicalizationResult rightCanonical = assertDifferential(
                new TypedSlottedPortEGraph(), rightNode);
        check(leftCanonical.shape().equals(rightCanonical.shape()),
                "Alpha-renamed binders have one canonical shape");
        BindPort canonicalBinder = (BindPort) leftCanonical.shape().node().ports().get(0);
        check(canonicalBinder.boundSlot().equals(TypedSlot.canonicalBound(USER, 0)),
                "Canonical binders use the least fresh typed bound coordinate");

        InstantiatedOperator different = operator(
                "different-binder", Collections.singletonList(bindSchema), GraphType.BOOL);
        TypedENode differentNode = TypedENode.construct(
                different, renamedContext, Collections.singletonList(rightBinder));
        check(!TypedAlphaEquivalence.structuralNodes(
                        leftNode, differentNode, freeRename),
                "Different operator symbols are not structural alpha equivalents");
    }

    private static void testGraphRelativeRelationDistinctions() {
        TypedSlot x = TypedSlot.source(USER, 40);
        TypedSlot y = TypedSlot.source(USER, 41);
        TypedSlotContext context = TypedSlotContext.of(x, y);
        TypedEClassInterface parent = new TypedEClassInterface(
                EClassId.of(100), GraphType.BOOL, context);
        TypedEClassInterface child = new TypedEClassInterface(
                EClassId.of(101), GraphType.BOOL, context);
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        graph.registerRecordForPhaseD(TypedEClassRecord.empty(parent));
        graph.registerRecordForPhaseD(TypedEClassRecord.empty(child));
        graph.linkLeadersForPhaseD(new ParentStep(
                child,
                new TypedInvocation(parent, TypedRenaming.identity(context))));
        graph.sealEmptyShapeFixtureForPhaseE();

        OnePortSchema oneBool = new OnePortSchema(GraphType.BOOL);
        InstantiatedOperator wrapper = operator(
                "wrapper", Collections.singletonList(oneBool), GraphType.BOOL);
        TypedENode childNode = TypedENode.construct(
                wrapper,
                context,
                Collections.singletonList(OnePort.invocation(
                        context, TypedInvocation.identity(child))));
        TypedENode parentNode = TypedENode.construct(
                wrapper,
                context,
                Collections.singletonList(OnePort.invocation(
                        context, TypedInvocation.identity(parent))));
        TypedRenaming identity = TypedRenaming.identity(context);
        check(!TypedAlphaEquivalence.structuralNodes(childNode, parentNode, identity),
                "Structural alpha keeps different e-class identifiers distinct");
        check(TypedAlphaEquivalence.graphRelativeNodes(graph, childNode, parentNode, identity),
                "Graph-relative alpha uses a shared leader");
        check(childNode.ports().get(0).equals(childNode.ports().get(0)),
                "Java equals remains structural and graph independent");

        TypedEClassInterface unsymmetric = new TypedEClassInterface(
                EClassId.of(102), GraphType.BOOL, context);
        TypedSlottedPortEGraph identityGraph = new TypedSlottedPortEGraph();
        identityGraph.registerRecordForPhaseD(TypedEClassRecord.empty(unsymmetric));
        TypedInvocation direct = TypedInvocation.identity(unsymmetric);
        TypedInvocation swapped = new TypedInvocation(
                unsymmetric,
                TypedPermutation.of(context, mapOf(x, y, y, x)));
        TypedENode directNode = TypedENode.construct(
                wrapper, context, Collections.singletonList(OnePort.invocation(context, direct)));
        TypedENode swappedNode = TypedENode.construct(
                wrapper, context, Collections.singletonList(OnePort.invocation(context, swapped)));
        check(!TypedAlphaEquivalence.graphRelativeNodes(
                        identityGraph, directNode, swappedNode, identity),
                "Same e-class membership alone does not equate different invocations");
    }

    private static void testContainerCanonicalizationAndGlobalSetRenaming() {
        TypedSlot x = TypedSlot.source(USER, 50);
        TypedSlot y = TypedSlot.source(USER, 51);
        TypedSlot a = TypedSlot.source(USER, 60);
        TypedSlot b = TypedSlot.source(USER, 61);
        TypedSlotContext source = TypedSlotContext.of(x, y);
        TypedSlotContext renamed = TypedSlotContext.of(a, b);
        OnePortSchema one = new OnePortSchema(USER);
        SeqPortSchema tuple = new SeqPortSchema(one);
        SetPortSchema setSchema = new SetPortSchema(tuple);
        InstantiatedOperator setOperator = operator(
                "set-of-pairs", Collections.singletonList(setSchema), GraphType.BOOL);

        SeqPort xy = sequence(tuple, source, x, y);
        SeqPort yx = sequence(tuple, source, y, x);
        SetPort pairSet = new SetPort(setSchema, source, Arrays.asList(xy, yx));
        TypedENode sourceNode = TypedENode.construct(
                setOperator, source, Collections.singletonList(pairSet));

        SeqPort ab = sequence(tuple, renamed, a, b);
        SeqPort ba = sequence(tuple, renamed, b, a);
        SetPort renamedSet = new SetPort(setSchema, renamed, Arrays.asList(ba, ab));
        TypedENode renamedNode = TypedENode.construct(
                setOperator, renamed, Collections.singletonList(renamedSet));

        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        CanonicalizationResult left = assertDifferential(graph, sourceNode);
        CanonicalizationResult right = assertDifferential(graph, renamedNode);
        check(left.shape().equals(right.shape()),
                "One global free renaming gives alpha-equivalent sets one shape");
        SetPort canonicalSet = (SetPort) left.shape().node().ports().get(0);
        check(canonicalSet.elements().size() == 2,
                "Set elements are not independently alpha-normalized into a false duplicate");

        BagPortSchema bagSchema = new BagPortSchema(one);
        InstantiatedOperator bagOperator = operator(
                "bag", Collections.singletonList(bagSchema), GraphType.BOOL);
        BagPort bag = new BagPort(
                bagSchema,
                source,
                Arrays.asList(
                        OnePort.slot(source, y),
                        OnePort.slot(source, x),
                        OnePort.slot(source, x)));
        CanonicalizationResult bagResult = assertDifferential(
                graph,
                TypedENode.construct(
                        bagOperator, source, Collections.singletonList(bag)));
        BagPort canonicalBag = (BagPort) bagResult.shape().node().ports().get(0);
        check(canonicalBag.occurrences().size() == 3,
                "Canonical bags retain multiplicity");

        SetPortSchema flatSchema = new SetPortSchema(one);
        Map<PortPath, ContainerLawDeclaration> flatLaws = new LinkedHashMap<>();
        flatLaws.put(PortPath.at(0), ContainerLawDeclaration.of(
                ContainerLawDeclaration.Kind.SET, true, true, true, false));
        InstantiatedOperator flatOperator = OperatorDeclaration.monomorphic(
                "flat-union",
                Collections.singletonList(flatSchema),
                USER,
                flatLaws,
                0).instantiateMonomorphic();
        FlatApplication flatSource = new FlatApplication(
                flatOperator,
                source,
                Arrays.asList(
                        new FlatLeaf(OnePort.slot(source, x)),
                        new FlatLeaf(OnePort.slot(source, y)),
                        new FlatLeaf(OnePort.slot(source, x))));
        TypedENode flatNode = TypedENode.flatConstruct(
                flatSource,
                ignored -> {
                    throw new AssertionError("A leaf-only flat source needs no sealer");
                });
        CanonicalizationResult flatResult = assertDifferential(graph, flatNode);
        check(flatResult.shape().node().operator().equals(flatOperator),
                "Canonical reconstruction retains the flat operator declaration");
        check(((SetPort) flatResult.shape().node().ports().get(0)).elements().size() == 2,
                "Canonical reconstruction retains already-flat ACI semantics");
    }

    private static void testLeaderNormalizationAndSymmetry() {
        TypedSlot x = TypedSlot.source(USER, 70);
        TypedSlot y = TypedSlot.source(USER, 71);
        TypedSlotContext context = TypedSlotContext.of(x, y);
        TypedPermutation swap = TypedPermutation.of(context, mapOf(x, y, y, x));
        TypedSymmetryGroup symmetry = TypedSymmetryGroup.generatedForPhaseD(
                context, Collections.singletonList(swap));
        TypedEClassInterface leader = new TypedEClassInterface(
                EClassId.of(200), GraphType.BOOL, context);
        TypedEClassInterface child = new TypedEClassInterface(
                EClassId.of(201), GraphType.BOOL, context);
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        graph.registerRecordForPhaseD(TypedEClassRecord.of(
                leader, Collections.emptyMap(), symmetry));
        graph.registerRecordForPhaseD(TypedEClassRecord.empty(child));
        graph.linkLeadersForPhaseD(new ParentStep(
                child,
                new TypedInvocation(leader, TypedRenaming.identity(context))));
        graph.sealEmptyShapeFixtureForPhaseE();

        OnePortSchema oneBool = new OnePortSchema(GraphType.BOOL);
        SeqPortSchema sequence = new SeqPortSchema(oneBool);
        InstantiatedOperator operator = operator(
                "invocations", Collections.singletonList(sequence), GraphType.BOOL);
        TypedInvocation childIdentity = TypedInvocation.identity(child);
        TypedInvocation leaderSwapped = new TypedInvocation(leader, swap);
        SeqPort leftPort = new SeqPort(
                sequence,
                context,
                Arrays.asList(
                        OnePort.invocation(context, childIdentity),
                        OnePort.invocation(context, leaderSwapped)));
        SeqPort rightPort = new SeqPort(
                sequence,
                context,
                Arrays.asList(
                        OnePort.invocation(context, TypedInvocation.identity(leader)),
                        OnePort.invocation(context, TypedInvocation.identity(leader))));
        TypedENode left = TypedENode.construct(
                operator, context, Collections.singletonList(leftPort));
        TypedENode right = TypedENode.construct(
                operator, context, Collections.singletonList(rightPort));

        CanonicalizationResult leftResult = assertDifferential(graph, left);
        CanonicalizationResult rightResult = assertDifferential(graph, right);
        check(leftResult.shape().equals(rightResult.shape()),
                "Canonicalization combines leader normalization and recorded symmetry");
        check(leftResult.verifyWitness(graph),
                "Leader and symmetry witness replays graph-relatively");
        for (PortValue value : ((SeqPort) leftResult.shape().node().ports().get(0)).elements()) {
            TypedInvocation invocation = ((InvocationPortLeaf) ((OnePort) value).leaf()).invocation();
            check(invocation.eclass().equals(leader),
                    "Canonical invocation leaves reference only their leader");
        }

        SetPortSchema setSchema = new SetPortSchema(oneBool);
        InstantiatedOperator setOperator = operator(
                "invocation-set", Collections.singletonList(setSchema), GraphType.BOOL);
        SetPort invocationSet = new SetPort(
                setSchema,
                context,
                Arrays.asList(
                        OnePort.invocation(context, TypedInvocation.identity(leader)),
                        OnePort.invocation(context, leaderSwapped)));
        CanonicalizationResult setResult = assertDifferential(
                graph,
                TypedENode.construct(
                        setOperator, context, Collections.singletonList(invocationSet)));
        check(((SetPort) setResult.shape().node().ports().get(0)).elements().size() == 1,
                "Set removes graph-relative duplicate symmetry-orbit elements");

        BagPortSchema bagSchema = new BagPortSchema(oneBool);
        InstantiatedOperator bagOperator = operator(
                "invocation-bag", Collections.singletonList(bagSchema), GraphType.BOOL);
        BagPort invocationBag = new BagPort(
                bagSchema,
                context,
                Arrays.asList(
                        OnePort.invocation(context, TypedInvocation.identity(leader)),
                        OnePort.invocation(context, leaderSwapped)));
        CanonicalizationResult bagResult = assertDifferential(
                graph,
                TypedENode.construct(
                        bagOperator, context, Collections.singletonList(invocationBag)));
        check(((BagPort) bagResult.shape().node().ports().get(0)).occurrences().size() == 2,
                "Bag retains both occurrences after symmetry-orbit minimization");
    }

    private static void testGeneratedDifferentialCanonicalization() {
        Random random = new Random(SEED);
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        for (int trial = 0; trial < 160; trial++) {
            int slotCount = 1 + random.nextInt(4);
            List<TypedSlot> slots = new ArrayList<>();
            for (int index = 0; index < slotCount; index++) {
                slots.add(TypedSlot.source(USER, 1_000 + trial * 8L + index));
            }
            TypedSlotContext context = TypedSlotContext.of(slots);
            List<PortValue> occurrences = new ArrayList<>();
            for (TypedSlot slot : slots) {
                occurrences.add(OnePort.slot(context, slot));
            }
            int extras = random.nextInt(4);
            for (int index = 0; index < extras; index++) {
                occurrences.add(OnePort.slot(
                        context, slots.get(random.nextInt(slots.size()))));
            }
            Collections.shuffle(occurrences, random);

            OnePortSchema element = new OnePortSchema(USER);
            int kind = random.nextInt(3);
            PortSchema schema;
            PortValue value;
            if (kind == 0) {
                schema = new SeqPortSchema(element);
                value = new SeqPort((SeqPortSchema) schema, context, occurrences);
            } else if (kind == 1) {
                schema = new BagPortSchema(element);
                value = new BagPort((BagPortSchema) schema, context, occurrences);
            } else {
                schema = new SetPortSchema(element);
                value = new SetPort((SetPortSchema) schema, context, occurrences);
            }
            InstantiatedOperator operator = operator(
                    "generated-" + kind,
                    Collections.singletonList(schema),
                    GraphType.BOOL);
            TypedENode node = TypedENode.construct(
                    operator, context, Collections.singletonList(value));
            CanonicalizationResult result = assertDifferential(graph, node);
            check(result.verifyWitness(graph), "Generated canonical witness replays");

            List<TypedSlot> targets = new ArrayList<>();
            for (int index = 0; index < slotCount; index++) {
                targets.add(TypedSlot.source(USER, 10_000 + trial * 8L + index));
            }
            Collections.shuffle(targets, random);
            TypedSlotContext targetContext = TypedSlotContext.of(targets);
            Map<TypedSlot, TypedSlot> mapping = new LinkedHashMap<>();
            for (int index = 0; index < slots.size(); index++) {
                mapping.put(slots.get(index), targets.get(index));
            }
            TypedRenaming alpha = TypedRenaming.of(context, targetContext, mapping);
            TypedENode renamed = node.act(alpha);
            CanonicalizationResult renamedResult = assertDifferential(graph, renamed);
            check(result.shape().equals(renamedResult.shape()),
                    "Generated alpha variants share one canonical shape");
        }


        TypedSlot x = TypedSlot.source(USER, 50_000);
        TypedSlot y = TypedSlot.source(USER, 50_001);
        TypedSlotContext context = TypedSlotContext.of(x, y);
        SeqPortSchema sequence = new SeqPortSchema(new OnePortSchema(USER));
        InstantiatedOperator pattern = operator(
                "pattern", Collections.singletonList(sequence), GraphType.BOOL);
        TypedENode first = sequenceNode(
                pattern, sequence, context, Arrays.asList(x, x, y));
        TypedENode second = sequenceNode(
                pattern, sequence, context, Arrays.asList(x, y, x));
        CanonicalizationResult firstResult = assertDifferential(graph, first);
        CanonicalizationResult secondResult = assertDifferential(graph, second);
        check(!firstResult.shape().equals(secondResult.shape()),
                "Non-alpha-equivalent occurrence patterns retain different shapes");
        check(!existsGraphRelativeRenaming(graph, first, second),
                "Different canonical patterns have no graph-relative typed renaming");
    }

    private static void testGeneratedSymmetryDifferential() {
        TypedSlot x = TypedSlot.source(USER, 700);
        TypedSlot y = TypedSlot.source(USER, 701);
        TypedSlot z = TypedSlot.source(USER, 702);
        TypedSlotContext context = TypedSlotContext.of(x, y, z);
        TypedPermutation xy = TypedPermutation.of(
                context, mapOf(x, y, y, x, z, z));
        TypedPermutation yz = TypedPermutation.of(
                context, mapOf(x, x, y, z, z, y));
        TypedSymmetryGroup group = TypedSymmetryGroup.generatedForPhaseD(
                context, Arrays.asList(xy, yz));
        check(group.elements().size() == 6,
                "Two adjacent swaps generate the full typed S3 orbit");
        TypedEClassInterface eclass = new TypedEClassInterface(
                EClassId.of(250), GraphType.BOOL, context);
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        graph.registerRecordForPhaseD(TypedEClassRecord.of(
                eclass, Collections.emptyMap(), group));

        Random random = new Random(SEED ^ 0x5A5A5A5AL);
        OnePortSchema element = new OnePortSchema(GraphType.BOOL);
        List<TypedPermutation> permutations = group.elements();
        for (int trial = 0; trial < 18; trial++) {
            List<PortValue> values = new ArrayList<>();
            int occurrences = 1 + random.nextInt(3);
            for (int index = 0; index < occurrences; index++) {
                TypedPermutation permutation = permutations.get(
                        random.nextInt(permutations.size()));
                values.add(OnePort.invocation(
                        context, new TypedInvocation(eclass, permutation)));
            }

            int kind = trial % 3;
            PortSchema schema;
            PortValue port;
            if (kind == 0) {
                schema = new SeqPortSchema(element);
                port = new SeqPort((SeqPortSchema) schema, context, values);
            } else if (kind == 1) {
                schema = new BagPortSchema(element);
                port = new BagPort((BagPortSchema) schema, context, values);
            } else {
                schema = new SetPortSchema(element);
                port = new SetPort((SetPortSchema) schema, context, values);
            }
            InstantiatedOperator operator = operator(
                    "symmetry-generated-" + kind,
                    Collections.singletonList(schema),
                    GraphType.BOOL);
            CanonicalizationResult result = assertDifferential(
                    graph,
                    TypedENode.construct(
                            operator, context, Collections.singletonList(port)));
            check(result.verifyWitness(graph),
                    "Generated S3 symmetry witness replays");
        }
    }

    private static void testDeterminismAndIdempotence() {
        TypedSlot x = TypedSlot.source(USER, 80);
        TypedSlot y = TypedSlot.source(USER, 81);
        TypedSlotContext context = TypedSlotContext.of(x, y);
        BagPortSchema schema = new BagPortSchema(new OnePortSchema(USER));
        InstantiatedOperator operator = operator(
                "deterministic", Collections.singletonList(schema), GraphType.BOOL);
        TypedENode node = TypedENode.construct(
                operator,
                context,
                Collections.singletonList(new BagPort(
                        schema,
                        context,
                        Arrays.asList(
                                OnePort.slot(context, y),
                                OnePort.slot(context, x),
                                OnePort.slot(context, y)))));
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        CanonicalizationResult first = graph.canonicalize(node);
        CanonicalizationResult second = graph.canonicalize(node);
        check(first.equals(second), "Repeated production canonicalization is deterministic");

        CanonicalizationResult idempotent = graph.canonicalize(first.shape().node());
        check(first.shape().equals(idempotent.shape()),
                "Canonicalizing a canonical shape is shape-idempotent");
        check(idempotent.witness().equals(TypedRenaming.identity(first.shape().exactSlots())),
                "An already least shape receives the identity witness");
        check(ProductionGraphCanonicalizer.VERSION.equals(
                        ProductionGraphCanonicalizer.instance().version()),
                "Production canonicalizer exposes a stable version identifier");
        check(ExhaustiveGraphCanonicalizer.VERSION.equals(
                        ExhaustiveGraphCanonicalizer.instance().version()),
                "Reference canonicalizer exposes a stable version identifier");
    }

    private static void testDirtyAndSupportShrinkRejection() {
        TypedSlot x = TypedSlot.source(USER, 90);
        TypedSlot y = TypedSlot.source(USER, 91);
        TypedSlotContext twoSlots = TypedSlotContext.of(x, y);
        TypedSlotContext oneSlot = TypedSlotContext.singleton(x);
        TypedEClassInterface parent = new TypedEClassInterface(
                EClassId.of(300), GraphType.BOOL, oneSlot);
        TypedEClassInterface child = new TypedEClassInterface(
                EClassId.of(301), GraphType.BOOL, twoSlots);
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        graph.registerRecordForPhaseD(TypedEClassRecord.empty(parent));
        graph.registerRecordForPhaseD(TypedEClassRecord.empty(child));
        graph.linkLeadersForPhaseD(new ParentStep(
                child,
                new TypedInvocation(
                        parent, TypedEmbedding.inclusion(oneSlot, twoSlots))));

        InstantiatedOperator wrapper = operator(
                "shrinking-wrapper",
                Collections.singletonList(new OnePortSchema(GraphType.BOOL)),
                GraphType.BOOL);
        TypedENode node = TypedENode.construct(
                wrapper,
                twoSlots,
                Collections.singletonList(OnePort.invocation(
                        twoSlots, TypedInvocation.identity(child))));
        expectThrows(IllegalStateException.class, () -> graph.canonicalize(node));
        graph.sealEmptyShapeFixtureForPhaseE();
        expectThrows(CanonicalizationDomainException.class, () -> graph.canonicalize(node));
        expectThrows(CanonicalizationDomainException.class,
                () -> ExhaustiveGraphCanonicalizer.instance().canonicalize(graph, node));
    }

    private static void testCanonicalizerBoundary() {
        check(TypedGraphCanonicalizer.class.isInterface(),
                "Canonicalizer integration boundary is an interface");
        for (Constructor<?> constructor : ProductionGraphCanonicalizer.class
                .getDeclaredConstructors()) {
            check(Modifier.isPrivate(constructor.getModifiers()),
                    "Production canonicalizer construction is controlled");
        }
        for (Constructor<?> constructor : ExhaustiveGraphCanonicalizer.class
                .getDeclaredConstructors()) {
            check(Modifier.isPrivate(constructor.getModifiers()),
                    "Reference canonicalizer construction is controlled");
        }
        check(!CanonicalizationResult.class.isAssignableFrom(CanonicalShape.class),
                "A canonical shape is distinct from its instantiating witness result");
        TypedSlottedPortEGraph graph = new TypedSlottedPortEGraph();
        check("typed-slotted-port-egraph".equals(graph.engineIdentifier()),
                "Exact engine exposes an unambiguous integration identifier");
        check(ProductionGraphCanonicalizer.VERSION.equals(graph.canonicalizerVersion()),
                "Exact engine exposes the production canonicalizer version");
    }

    private static CanonicalizationResult assertDifferential(
            TypedSlottedPortEGraph graph,
            TypedENode node) {
        CanonicalizationResult reference = ExhaustiveGraphCanonicalizer.instance()
                .canonicalize(graph, node);
        CanonicalizationResult production = ProductionGraphCanonicalizer.instance()
                .canonicalize(graph, node);
        check(reference.equals(production),
                "Reference and production canon_G return the same shape and witness");
        check(production.equals(graph.canonicalize(node)),
                "Graph canonicalization delegates to the production canon_G");
        return production;
    }

    private static boolean existsGraphRelativeRenaming(
            TypedSlottedPortEGraph graph,
            TypedENode left,
            TypedENode right) {
        boolean[] found = {false};
        TypedRenamingEnumerator.forEach(
                left.context(),
                right.context(),
                renaming -> {
                    if (!found[0] && TypedAlphaEquivalence.graphRelativeNodes(
                            graph, left, right, renaming)) {
                        found[0] = true;
                    }
                });
        return found[0];
    }

    private static TypedENode sequenceNode(
            InstantiatedOperator operator,
            SeqPortSchema schema,
            TypedSlotContext context,
            List<TypedSlot> slots) {
        List<PortValue> ports = new ArrayList<>();
        for (TypedSlot slot : slots) {
            ports.add(OnePort.slot(context, slot));
        }
        return TypedENode.construct(
                operator,
                context,
                Collections.singletonList(new SeqPort(schema, context, ports)));
    }

    private static SeqPort sequence(
            SeqPortSchema schema,
            TypedSlotContext context,
            TypedSlot... slots) {
        List<PortValue> elements = new ArrayList<>();
        for (TypedSlot slot : slots) {
            elements.add(OnePort.slot(context, slot));
        }
        return new SeqPort(schema, context, elements);
    }

    private static BindPort binder(
            BindPortSchema schema,
            TypedSlotContext context,
            TypedSlot free,
            TypedSlot bound,
            SeqPortSchema bodySchema) {
        TypedSlotContext bodyContext = context.plus(bound);
        SeqPort body = new SeqPort(
                bodySchema,
                bodyContext,
                Arrays.asList(
                        OnePort.slot(bodyContext, free),
                        OnePort.slot(bodyContext, bound)));
        return new BindPort(schema, context, bound, body);
    }

    private static InstantiatedOperator operator(
            String name,
            List<PortSchema> schemas,
            GraphType output) {
        Map<PortPath, ContainerLawDeclaration> laws = new LinkedHashMap<>();
        for (int index = 0; index < schemas.size(); index++) {
            collectLaws(schemas.get(index), PortPath.at(index), laws);
        }
        return OperatorDeclaration.monomorphic(
                name, schemas, output, laws, null).instantiateMonomorphic();
    }

    private static void collectLaws(
            PortSchema schema,
            PortPath path,
            Map<PortPath, ContainerLawDeclaration> laws) {
        PortSchema child = null;
        if (schema instanceof SeqPortSchema) {
            laws.put(path, ContainerLawDeclaration.of(
                    ContainerLawDeclaration.Kind.SEQ, true, false, false, true));
            child = ((SeqPortSchema) schema).elementSchema();
        } else if (schema instanceof BagPortSchema) {
            laws.put(path, ContainerLawDeclaration.of(
                    ContainerLawDeclaration.Kind.BAG, true, true, false, true));
            child = ((BagPortSchema) schema).elementSchema();
        } else if (schema instanceof SetPortSchema) {
            laws.put(path, ContainerLawDeclaration.of(
                    ContainerLawDeclaration.Kind.SET, true, true, true, true));
            child = ((SetPortSchema) schema).elementSchema();
        } else if (schema instanceof BindPortSchema) {
            child = ((BindPortSchema) schema).bodySchema();
        }
        if (child != null) {
            collectLaws(child, path.child(), laws);
        }
    }

    private static Map<TypedSlot, TypedSlot> mapOf(TypedSlot... entries) {
        if (entries.length % 2 != 0) {
            throw new IllegalArgumentException("Slot mapping requires source/target pairs");
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
        } catch (Throwable thrown) {
            if (expected.isInstance(thrown)) {
                return;
            }
            throw new AssertionError(
                    "Expected " + expected.getSimpleName() + " but saw " + thrown,
                    thrown);
        }
        throw new AssertionError("Expected " + expected.getSimpleName());
    }
}
