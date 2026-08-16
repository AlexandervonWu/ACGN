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

/** Deterministic Phase C schema, port, flatness, and structural-key tests. */
public final class TheoryPortsTest {
    private static final long SEED = 555_202_608_17L;
    private static final GraphType USER = GraphType.constructor("User");
    private static final GraphType USER_REL = GraphType.relation(USER);
    private static int checks;

    private TheoryPortsTest() {
    }

    public static void main(String[] args) {
        testSchemasAndPolymorphicSignatures();
        testOnePortTypingAndAction();
        testSeqBagSetSemantics();
        testCaptureAvoidingBinderAction();
        testTypedNodeConstructionAndUnits();
        testVisibleOnlyFlatConstruction();
        testStructuralOrderLaws();
        testGeneratedContainerProperties();
        testConstructionBoundary();
        System.out.println("TheoryPortsTest passed: " + checks
                + " checks; deterministic seed=" + SEED);
    }

    private static void testSchemasAndPolymorphicSignatures() {
        GraphType alpha = GraphType.typeVariable("a");
        OnePortSchema oneAlpha = new OnePortSchema(alpha);
        PortSchema nested = new BindPortSchema(
                alpha, new BagPortSchema(new SetPortSchema(oneAlpha)));
        PortSchema substituted = nested.substitute(Collections.singletonMap("a", USER_REL));
        check(substituted.equals(new BindPortSchema(
                        USER_REL,
                        new BagPortSchema(new SetPortSchema(new OnePortSchema(USER_REL))))),
                "Port-schema substitution is structural and recursive");
        check(nested.typeVariables().equals(Collections.singleton("a")),
                "Port schema reports every nested type variable");
        Map<String, GraphType> nullType = new LinkedHashMap<>();
        nullType.put("a", null);
        expectThrows(NullPointerException.class, () -> alpha.substitute(nullType));

        OperatorDeclaration declaration = new OperatorDeclaration(
                "union",
                Collections.singletonList("a"),
                Collections.singletonList(new SetPortSchema(oneAlpha)),
                alpha,
                lawMap(0, laws(ContainerLawDeclaration.Kind.SET, true, true, true, false)),
                0);
        InstantiatedOperator union = declaration.instantiate(
                Collections.singletonMap("a", USER_REL));
        check(union.outputType().equals(USER_REL), "Operator output is instantiated");
        check(union.portSchemas().equals(Collections.singletonList(
                        new SetPortSchema(new OnePortSchema(USER_REL)))),
                "Operator port schemas are instantiated");
        check(union.usesFlatConstruction(), "Recursive variadic operator retains flat marker");
        check(union.lawForPort(0).idempotent(), "Set law is explicit on the declaration");

        expectThrows(IllegalArgumentException.class, () -> declaration.instantiate(Collections.emptyMap()));
        Map<String, GraphType> extra = new LinkedHashMap<>();
        extra.put("a", USER_REL);
        extra.put("b", GraphType.BOOL);
        expectThrows(IllegalArgumentException.class, () -> declaration.instantiate(extra));
        expectThrows(IllegalArgumentException.class, () -> new OperatorDeclaration(
                "bad",
                Collections.singletonList("a"),
                Collections.singletonList(new OnePortSchema(GraphType.typeVariable("b"))),
                alpha,
                Collections.emptyMap(),
                null));
        expectThrows(IllegalArgumentException.class, () -> new OperatorDeclaration(
                "bad",
                Arrays.asList("a", "a"),
                Collections.singletonList(oneAlpha),
                alpha,
                Collections.emptyMap(),
                null));
        expectThrows(IllegalArgumentException.class, () -> OperatorDeclaration.monomorphic(
                "missing-law",
                Collections.singletonList(new BagPortSchema(new OnePortSchema(GraphType.INT))),
                GraphType.BOOL,
                Collections.emptyMap(),
                null));
        BindPortSchema nestedContainer = new BindPortSchema(
                USER, new SeqPortSchema(new OnePortSchema(USER)));
        expectThrows(IllegalArgumentException.class, () -> OperatorDeclaration.monomorphic(
                "missing-nested-law",
                Collections.singletonList(nestedContainer),
                GraphType.BOOL,
                Collections.emptyMap(),
                null));
        expectThrows(IllegalArgumentException.class, () -> OperatorDeclaration.monomorphic(
                "law-at-wrong-depth",
                Collections.singletonList(nestedContainer),
                GraphType.BOOL,
                lawMap(0, laws(ContainerLawDeclaration.Kind.SEQ, true, false, false, false)),
                null));
        expectThrows(IllegalArgumentException.class, () -> OperatorDeclaration.monomorphic(
                "wrong-kind",
                Collections.singletonList(new SeqPortSchema(new OnePortSchema(GraphType.INT))),
                GraphType.BOOL,
                lawMap(0, laws(ContainerLawDeclaration.Kind.BAG, true, true, false, false)),
                null));
        expectThrows(IllegalArgumentException.class, () -> OperatorDeclaration.monomorphic(
                "wrong-flags",
                Collections.singletonList(new SeqPortSchema(new OnePortSchema(GraphType.INT))),
                GraphType.BOOL,
                lawMap(0, laws(ContainerLawDeclaration.Kind.SEQ, true, true, false, false)),
                null));
        expectThrows(IllegalArgumentException.class, () -> OperatorDeclaration.monomorphic(
                "fixed-with-laws",
                Collections.singletonList(new OnePortSchema(GraphType.INT)),
                GraphType.INT,
                lawMap(0, ContainerLawDeclaration.none()),
                null));
        expectThrows(IllegalArgumentException.class, () -> OperatorDeclaration.monomorphic(
                "nonrecursive-flat",
                Collections.singletonList(new SeqPortSchema(new OnePortSchema(GraphType.INT))),
                GraphType.BOOL,
                lawMap(0, laws(ContainerLawDeclaration.Kind.SEQ, true, false, false, false)),
                0));
        expectThrows(IllegalArgumentException.class, () -> OperatorDeclaration.monomorphic(
                "multiport-flat",
                Arrays.asList(
                        new SeqPortSchema(new OnePortSchema(GraphType.INT)),
                        new OnePortSchema(GraphType.BOOL)),
                GraphType.INT,
                lawMap(0, laws(ContainerLawDeclaration.Kind.SEQ, true, false, false, false)),
                0));
    }

    private static void testOnePortTypingAndAction() {
        TypedSlot x = TypedSlot.source(USER, 0);
        TypedSlot y = TypedSlot.source(USER, 1);
        TypedSlot flag = TypedSlot.source(GraphType.BOOL, 0);
        TypedSlotContext context = TypedSlotContext.of(x, flag);
        OnePort one = OnePort.slot(context, x);
        check(one.schema().equals(new OnePortSchema(USER)), "Slot determines One schema type");
        check(one.support().equals(TypedSlotContext.singleton(x)), "One(slot) support is singleton");

        TypedSlotContext target = TypedSlotContext.of(y, flag);
        TypedEmbedding action = TypedRenaming.of(
                context, target, mapOf(x, y, flag, flag));
        OnePort acted = one.act(action);
        check(((SlotPortLeaf) acted.leaf()).slot().equals(y), "One slot action applies embedding");
        check(acted.support().equals(action.imageOf(one.support())),
                "One slot support is equivariant");
        expectThrows(IllegalArgumentException.class,
                () -> new OnePort(new OnePortSchema(GraphType.BOOL), context, new SlotPortLeaf(x)));
        expectThrows(IllegalArgumentException.class,
                () -> OnePort.slot(context, TypedSlot.source(USER, 99)));

        TypedEClassInterface eclass = new TypedEClassInterface(
                EClassId.of(1), USER, TypedSlotContext.singleton(x));
        TypedInvocation invocation = new TypedInvocation(
                eclass, TypedEmbedding.inclusion(eclass.exposedSlots(), context));
        OnePort opaque = OnePort.invocation(context, invocation);
        check(opaque.support().equals(TypedSlotContext.singleton(x)),
                "One(invocation) support is its embedding image");
        TypedInvocation wrongCaller = TypedInvocation.identity(eclass);
        expectThrows(IllegalArgumentException.class,
                () -> OnePort.invocation(context, wrongCaller));
    }

    private static void testSeqBagSetSemantics() {
        TypedSlot x = TypedSlot.source(USER, 0);
        TypedSlot y = TypedSlot.source(USER, 1);
        TypedSlotContext context = TypedSlotContext.of(x, y);
        OnePort px = OnePort.slot(context, x);
        OnePort py = OnePort.slot(context, y);
        OnePortSchema element = new OnePortSchema(USER);

        SeqPortSchema seqSchema = new SeqPortSchema(element);
        SeqPort seqXY = new SeqPort(seqSchema, context, Arrays.asList(px, py, px));
        SeqPort seqYX = new SeqPort(seqSchema, context, Arrays.asList(py, px, px));
        check(seqXY.elements().size() == 3, "Sequence retains multiplicity");
        check(!seqXY.equals(seqYX), "Sequence retains order");
        check(!seqXY.structuralKey().equals(seqYX.structuralKey()),
                "Sequence key retains position");

        BagPortSchema bagSchema = new BagPortSchema(element);
        BagPort bagXY = new BagPort(bagSchema, context, Arrays.asList(px, py, px));
        BagPort bagYX = new BagPort(bagSchema, context, Arrays.asList(py, px, px));
        BagPort bagWithoutDuplicate = new BagPort(bagSchema, context, Arrays.asList(px, py));
        check(bagXY.equals(bagYX), "Bag discards order");
        check(bagXY.structuralKey().equals(bagYX.structuralKey()),
                "Bag key discards order");
        check(bagXY.occurrences().size() == 3, "Bag retains duplicate occurrences");
        check(!bagXY.equals(bagWithoutDuplicate), "Bag multiplicity is structural");

        SetPortSchema setSchema = new SetPortSchema(element);
        SetPort setXY = new SetPort(setSchema, context, Arrays.asList(px, py, px));
        SetPort setYX = new SetPort(setSchema, context, Arrays.asList(py, px));
        check(setXY.equals(setYX), "Set discards order and duplicate structural values");
        check(setXY.elements().size() == 2, "Set stores each structural class once");
        check(setXY.structuralKey().equals(setYX.structuralKey()),
                "Set key implements ACI representation");

        expectThrows(UnsupportedOperationException.class, () -> seqXY.elements().add(px));
        expectThrows(UnsupportedOperationException.class, () -> bagXY.occurrences().clear());
        expectThrows(UnsupportedOperationException.class, () -> setXY.elements().clear());
        OnePort wrongType = OnePort.slot(
                context.plus(TypedSlot.source(GraphType.BOOL, 0)),
                TypedSlot.source(GraphType.BOOL, 0));
        expectThrows(IllegalArgumentException.class,
                () -> new SeqPort(seqSchema, wrongType.context(), Collections.singletonList(wrongType)));
        expectThrows(IllegalArgumentException.class,
                () -> new BagPort(bagSchema, context, Collections.singletonList(
                        OnePort.slot(TypedSlotContext.singleton(x), x))));
    }

    private static void testCaptureAvoidingBinderAction() {
        TypedSlot free = TypedSlot.source(USER, 0);
        TypedSlot bound = TypedSlot.source(USER, 99);
        TypedSlotContext context = TypedSlotContext.singleton(free);
        TypedSlotContext bodyContext = context.plus(bound);
        OnePortSchema oneUser = new OnePortSchema(USER);
        BagPortSchema bodySchema = new BagPortSchema(oneUser);
        BagPort body = new BagPort(
                bodySchema,
                bodyContext,
                Arrays.asList(OnePort.slot(bodyContext, free), OnePort.slot(bodyContext, bound)));
        BindPortSchema schema = new BindPortSchema(USER, bodySchema);
        BindPort binder = new BindPort(schema, context, bound, body);
        check(binder.support().equals(TypedSlotContext.singleton(free)),
                "Binder support removes only its bound coordinate");

        TypedSlot mappedFree = TypedSlot.source(USER, 10);
        TypedSlot occupiedBound = TypedSlot.canonicalBound(USER, 0);
        TypedSlotContext target = TypedSlotContext.of(mappedFree, occupiedBound, bound);
        TypedEmbedding action = TypedEmbedding.of(context, target, mapOf(free, mappedFree));
        BindPort acted = binder.act(action);
        check(acted.boundSlot().equals(TypedSlot.canonicalBound(USER, 1)),
                "Binder action chooses the least fresh canonical bound coordinate");
        check(!target.contains(acted.boundSlot()), "Renamed binder coordinate is capture-free");
        check(acted.support().equals(action.imageOf(binder.support())),
                "Binder support is equivariant under capture-avoiding action");
        check(acted.body().context().equals(target.plus(acted.boundSlot())),
                "Binder body uses the disjointly extended target context");

        expectThrows(IllegalArgumentException.class,
                () -> new BindPort(schema, context.plus(bound), bound, body));
        expectThrows(IllegalArgumentException.class,
                () -> new BindPort(
                        new BindPortSchema(GraphType.BOOL, bodySchema), context, bound, body));
        expectThrows(IllegalArgumentException.class,
                () -> new BindPort(schema, context, bound,
                        new BagPort(bodySchema, context, Collections.singletonList(
                                OnePort.slot(context, free)))));
    }

    private static void testTypedNodeConstructionAndUnits() {
        TypedSlot x = TypedSlot.source(USER, 0);
        TypedSlot y = TypedSlot.source(USER, 1);
        TypedSlotContext context = TypedSlotContext.of(x, y);
        OnePort px = OnePort.slot(context, x);
        OnePort py = OnePort.slot(context, y);
        OperatorDeclaration pairDeclaration = OperatorDeclaration.monomorphic(
                "pair",
                Arrays.asList(new OnePortSchema(USER), new OnePortSchema(USER)),
                GraphType.relation(USER, USER),
                Collections.emptyMap(),
                null);
        TypedENode pair = TypedENode.construct(
                pairDeclaration.instantiateMonomorphic(), context, Arrays.asList(px, py));
        check(pair.outputType().equals(GraphType.relation(USER, USER)),
                "Node output is derived from instantiated signature");
        check(pair.support().equals(context), "Node support is the union of port supports");

        TypedSlot x2 = TypedSlot.source(USER, 10);
        TypedSlot y2 = TypedSlot.source(USER, 11);
        TypedSlotContext target = TypedSlotContext.of(x2, y2);
        TypedRenaming action = TypedRenaming.of(context, target, mapOf(x, y2, y, x2));
        TypedENode acted = pair.act(action);
        check(acted.outputType().equals(pair.outputType()), "Node action preserves output type");
        check(acted.support().equals(action.imageOf(pair.support())),
                "Node support is equivariant");
        expectThrows(IllegalArgumentException.class,
                () -> TypedENode.construct(
                        pairDeclaration.instantiateMonomorphic(), context, Collections.singletonList(px)));
        expectThrows(IllegalArgumentException.class,
                () -> TypedENode.construct(
                        pairDeclaration.instantiateMonomorphic(), context, Arrays.asList(px,
                                OnePort.slot(TypedSlotContext.singleton(y), y))));

        SeqPortSchema inputs = new SeqPortSchema(new OnePortSchema(GraphType.INT));
        OperatorDeclaration noUnit = OperatorDeclaration.monomorphic(
                "nonempty-test",
                Collections.singletonList(inputs),
                GraphType.BOOL,
                lawMap(0, laws(ContainerLawDeclaration.Kind.SEQ, true, false, false, false)),
                null);
        SeqPort empty = new SeqPort(inputs, TypedSlotContext.empty(), Collections.emptyList());
        expectThrows(IllegalArgumentException.class,
                () -> TypedENode.construct(
                        noUnit.instantiateMonomorphic(), TypedSlotContext.empty(),
                        Collections.singletonList(empty)));

        OperatorDeclaration withUnit = OperatorDeclaration.monomorphic(
                "empty-test",
                Collections.singletonList(inputs),
                GraphType.BOOL,
                lawMap(0, laws(ContainerLawDeclaration.Kind.SEQ, true, false, false, true)),
                null);
        TypedENode unitNode = TypedENode.construct(
                withUnit.instantiateMonomorphic(), TypedSlotContext.empty(),
                Collections.singletonList(empty));
        check(unitNode.support().isEmpty(), "Certified unit permits an empty variadic port");

        TypedSlot bound = TypedSlot.source(USER, 99);
        TypedSlotContext bodyContext = TypedSlotContext.singleton(bound);
        SeqPortSchema nestedInputs = new SeqPortSchema(new OnePortSchema(USER));
        BindPortSchema binderSchema = new BindPortSchema(USER, nestedInputs);
        BindPort emptyBinder = new BindPort(
                binderSchema,
                TypedSlotContext.empty(),
                bound,
                new SeqPort(nestedInputs, bodyContext, Collections.emptyList()));
        PortPath nestedPath = PortPath.at(0).child();
        OperatorDeclaration nestedNoUnit = OperatorDeclaration.monomorphic(
                "nested-nonempty-test",
                Collections.singletonList(binderSchema),
                GraphType.BOOL,
                lawMap(nestedPath,
                        laws(ContainerLawDeclaration.Kind.SEQ, true, false, false, false)),
                null);
        expectThrows(IllegalArgumentException.class,
                () -> TypedENode.construct(
                        nestedNoUnit.instantiateMonomorphic(),
                        TypedSlotContext.empty(),
                        Collections.singletonList(emptyBinder)));
        OperatorDeclaration nestedWithUnit = OperatorDeclaration.monomorphic(
                "nested-empty-test",
                Collections.singletonList(binderSchema),
                GraphType.BOOL,
                lawMap(nestedPath,
                        laws(ContainerLawDeclaration.Kind.SEQ, true, false, false, true)),
                null);
        TypedENode nestedUnitNode = TypedENode.construct(
                nestedWithUnit.instantiateMonomorphic(),
                TypedSlotContext.empty(),
                Collections.singletonList(emptyBinder));
        check(nestedUnitNode.support().isEmpty(),
                "Unit declarations are checked at the exact nested schema path");
    }

    private static void testVisibleOnlyFlatConstruction() {
        TypedSlot a = TypedSlot.source(USER_REL, 0);
        TypedSlot b = TypedSlot.source(USER_REL, 1);
        TypedSlot c = TypedSlot.source(USER_REL, 2);
        TypedSlotContext context = TypedSlotContext.of(a, b, c);
        FlatLeaf fa = new FlatLeaf(OnePort.slot(context, a));
        FlatLeaf fb = new FlatLeaf(OnePort.slot(context, b));
        FlatLeaf fc = new FlatLeaf(OnePort.slot(context, c));

        InstantiatedOperator join = flatOperator(
                "join", USER_REL, PortSchema.Kind.SEQ, false);
        FlatApplication rightNested = new FlatApplication(
                join, context, Arrays.asList(fa, new FlatApplication(join, context, Arrays.asList(fb, fc))));
        FlatApplication leftNested = new FlatApplication(
                join, context, Arrays.asList(new FlatApplication(join, context, Arrays.asList(fa, fb)), fc));
        CountingSealer unused = new CountingSealer();
        TypedENode right = TypedENode.flatConstruct(rightNested, unused);
        TypedENode left = TypedENode.flatConstruct(leftNested, unused);
        check(right.equals(left), "Visible associative nesting flattens to one sequence");
        check(((SeqPort) right.ports().get(0)).elements().size() == 3,
                "Visible same-headed node contributes all direct children");
        check(unused.calls == 0, "Visible same-headed nodes are spliced before sealing");
        TypedENode reordered = TypedENode.flatConstruct(
                new FlatApplication(join, context, Arrays.asList(fa, fc, fb)), unused);
        check(!right.equals(reordered), "Sequence flat operator remains noncommutative");

        InstantiatedOperator bag = flatOperator(
                "bag-plus", USER_REL, PortSchema.Kind.BAG, false);
        TypedENode bagOne = TypedENode.flatConstruct(
                new FlatApplication(bag, context, Arrays.asList(fa, fb, fa)), unused);
        TypedENode bagTwo = TypedENode.flatConstruct(
                new FlatApplication(bag, context, Arrays.asList(fb, fa, fa)), unused);
        check(bagOne.equals(bagTwo), "Visible bag construction is commutative");
        check(((BagPort) bagOne.ports().get(0)).occurrences().size() == 3,
                "Visible bag construction retains multiplicity");

        InstantiatedOperator set = flatOperator(
                "set-union", USER_REL, PortSchema.Kind.SET, false);
        TypedENode setOne = TypedENode.flatConstruct(
                new FlatApplication(set, context, Arrays.asList(fa, fb, fa)), unused);
        TypedENode setTwo = TypedENode.flatConstruct(
                new FlatApplication(set, context, Arrays.asList(fb, fa)), unused);
        check(setOne.equals(setTwo), "Visible set construction implements ACI");
        check(((SetPort) setOne.ports().get(0)).elements().size() == 2,
                "Visible set construction removes exact structural duplicates");

        TypedEClassInterface hiddenClass = new TypedEClassInterface(
                EClassId.of(100), USER_REL, TypedSlotContext.of(b, c));
        TypedInvocation hiddenInvocation = new TypedInvocation(
                hiddenClass, TypedEmbedding.inclusion(hiddenClass.exposedSlots(), context));
        FlatLeaf hiddenSameHead = new FlatLeaf(OnePort.invocation(context, hiddenInvocation));
        TypedENode opaque = TypedENode.flatConstruct(
                new FlatApplication(set, context, Arrays.asList(fa, hiddenSameHead)), unused);
        check(((SetPort) opaque.ports().get(0)).elements().size() == 2,
                "Opaque invocation is retained as one flat element");
        check(unused.calls == 0, "Flat construction never opens an opaque invocation");

        InstantiatedOperator other = flatOperator(
                "set-intersection", USER_REL, PortSchema.Kind.SET, false);
        CountingSealer sealer = new CountingSealer();
        TypedENode mixed = TypedENode.flatConstruct(
                new FlatApplication(set, context, Arrays.asList(
                        fa, new FlatApplication(other, context, Arrays.asList(fb, fc)))),
                sealer);
        check(sealer.calls == 1, "Different visible operator is recursively sealed once");
        check(((SetPort) mixed.ports().get(0)).elements().size() == 2,
                "Sealed different operator remains one opaque element");

        SetPort directContainer = new SetPort(
                (SetPortSchema) set.portSchemas().get(0), context, Arrays.asList(fa.port(), fb.port()));
        expectThrows(IllegalArgumentException.class,
                () -> TypedENode.construct(set, context, Collections.singletonList(directContainer)));
        expectThrows(IllegalArgumentException.class, () -> TypedENode.flatConstruct(
                new FlatApplication(set, context, Arrays.asList(fa,
                        new FlatApplication(other, context, Arrays.asList(fb, fc)))),
                node -> {
                    TypedEClassInterface wrong = new TypedEClassInterface(
                            EClassId.of(999), node.outputType(), TypedSlotContext.empty());
                    return new TypedInvocation(
                            wrong, TypedEmbedding.inclusion(TypedSlotContext.empty(), node.context()));
                }));
    }

    private static void testStructuralOrderLaws() {
        TypedSlot x = TypedSlot.source(USER, 0);
        TypedSlot y = TypedSlot.source(USER, 1);
        TypedSlotContext context = TypedSlotContext.of(x, y);
        OnePort px = OnePort.slot(context, x);
        OnePort py = OnePort.slot(context, y);
        List<PortValue> values = Arrays.asList(
                px,
                py,
                new SeqPort(new SeqPortSchema(new OnePortSchema(USER)), context, Arrays.asList(px, py)),
                new BagPort(new BagPortSchema(new OnePortSchema(USER)), context, Arrays.asList(px, py)),
                new SetPort(new SetPortSchema(new OnePortSchema(USER)), context, Arrays.asList(px, py)));
        for (PortValue left : values) {
            for (PortValue right : values) {
                int forward = Integer.signum(left.structuralKey().compareTo(right.structuralKey()));
                int backward = Integer.signum(right.structuralKey().compareTo(left.structuralKey()));
                check(forward == -backward, "Structural-key order is antisymmetric");
                check((forward == 0) == left.equals(right),
                        "Structural-key comparison agrees with structural equality");
                check(left.structuralKey().stableString()
                                .equals(left.structuralKey().stableString()),
                        "Structural-key serialization is deterministic");
            }
        }
        for (PortValue first : values) {
            for (PortValue second : values) {
                for (PortValue third : values) {
                    if (first.structuralKey().compareTo(second.structuralKey()) <= 0
                            && second.structuralKey().compareTo(third.structuralKey()) <= 0) {
                        check(first.structuralKey().compareTo(third.structuralKey()) <= 0,
                                "Structural-key order is transitive");
                    }
                }
            }
        }
    }

    private static void testGeneratedContainerProperties() {
        Random random = new Random(SEED);
        for (int round = 0; round < 128; round++) {
            int distinct = 1 + random.nextInt(6);
            List<TypedSlot> slots = new ArrayList<>();
            for (int index = 0; index < distinct; index++) {
                slots.add(TypedSlot.source(USER, round * 100L + index));
            }
            TypedSlotContext context = TypedSlotContext.of(slots);
            List<PortValue> occurrences = new ArrayList<>();
            int occurrenceCount = 1 + random.nextInt(12);
            for (int index = 0; index < occurrenceCount; index++) {
                occurrences.add(OnePort.slot(context, slots.get(random.nextInt(slots.size()))));
            }
            List<PortValue> shuffled = new ArrayList<>(occurrences);
            Collections.shuffle(shuffled, random);
            OnePortSchema element = new OnePortSchema(USER);
            BagPort bag = new BagPort(new BagPortSchema(element), context, occurrences);
            BagPort shuffledBag = new BagPort(new BagPortSchema(element), context, shuffled);
            SetPort set = new SetPort(new SetPortSchema(element), context, occurrences);
            SetPort shuffledSet = new SetPort(new SetPortSchema(element), context, shuffled);
            check(bag.equals(shuffledBag), "Generated bag ignores occurrence order");
            check(bag.occurrences().size() == occurrenceCount,
                    "Generated bag retains every occurrence");
            check(set.equals(shuffledSet), "Generated set ignores order");
            check(set.elements().size() <= distinct, "Generated set removes duplicates");

            List<TypedSlot> targets = new ArrayList<>();
            Map<TypedSlot, TypedSlot> renamingMap = new LinkedHashMap<>();
            for (int index = 0; index < slots.size(); index++) {
                TypedSlot target = TypedSlot.source(USER, 100_000L + round * 100L + index);
                targets.add(target);
                renamingMap.put(slots.get(index), target);
            }
            TypedRenaming action = TypedRenaming.of(
                    context, TypedSlotContext.of(targets), renamingMap);
            check(bag.act(action).support().equals(action.imageOf(bag.support())),
                    "Generated bag support is equivariant");
            check(set.act(action).support().equals(action.imageOf(set.support())),
                    "Generated set support is equivariant under one global action");
        }
    }

    private static void testConstructionBoundary() {
        for (Constructor<?> constructor : TypedENode.class.getDeclaredConstructors()) {
            check(Modifier.isPrivate(constructor.getModifiers()),
                    "Typed e-node constructors are private; public construction cannot bypass checks");
        }
        check(PortValue.class.isSealed(), "Port-value grammar is sealed");
        check(PortSchema.class.isSealed(), "Port-schema grammar is sealed");
        check(FlatInput.class.isSealed(), "Visible flat-input grammar is sealed");
    }

    private static InstantiatedOperator flatOperator(
            String name,
            GraphType output,
            PortSchema.Kind kind,
            boolean unit) {
        OnePortSchema element = new OnePortSchema(output);
        PortSchema schema;
        ContainerLawDeclaration law;
        switch (kind) {
            case SEQ:
                schema = new SeqPortSchema(element);
                law = laws(ContainerLawDeclaration.Kind.SEQ, true, false, false, unit);
                break;
            case BAG:
                schema = new BagPortSchema(element);
                law = laws(ContainerLawDeclaration.Kind.BAG, true, true, false, unit);
                break;
            case SET:
                schema = new SetPortSchema(element);
                law = laws(ContainerLawDeclaration.Kind.SET, true, true, true, unit);
                break;
            default:
                throw new IllegalArgumentException("Not a flexible container kind: " + kind);
        }
        return OperatorDeclaration.monomorphic(
                name,
                Collections.singletonList(schema),
                output,
                lawMap(0, law),
                0).instantiateMonomorphic();
    }

    private static ContainerLawDeclaration laws(
            ContainerLawDeclaration.Kind kind,
            boolean associative,
            boolean commutative,
            boolean idempotent,
            boolean unit) {
        return ContainerLawDeclaration.of(
                kind, associative, commutative, idempotent, unit);
    }

    private static Map<PortPath, ContainerLawDeclaration> lawMap(
            int index,
            ContainerLawDeclaration law) {
        return lawMap(PortPath.at(index), law);
    }

    private static Map<PortPath, ContainerLawDeclaration> lawMap(
            PortPath path,
            ContainerLawDeclaration law) {
        Map<PortPath, ContainerLawDeclaration> result = new LinkedHashMap<>();
        result.put(path, law);
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
            ThrowingRunnable operation) {
        checks++;
        try {
            operation.run();
        } catch (Throwable failure) {
            if (expected.isInstance(failure)) {
                return;
            }
            throw new AssertionError(
                    "Expected " + expected.getSimpleName() + " but got " + failure, failure);
        }
        throw new AssertionError("Expected " + expected.getSimpleName());
    }

    private interface ThrowingRunnable {
        void run() throws Exception;
    }

    private static final class CountingSealer implements NodeSealer {
        private long nextId = 10_000;
        private int calls;

        @Override
        public TypedInvocation seal(TypedENode node) {
            calls++;
            TypedEClassInterface eclass = new TypedEClassInterface(
                    EClassId.of(nextId++), node.outputType(), node.support());
            return new TypedInvocation(
                    eclass, TypedEmbedding.inclusion(node.support(), node.context()));
        }
    }
}
