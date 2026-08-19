package org.acgn.cert;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Deque;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Independently decoded finite typed language and source-term store. */
final class KernelModel {
    enum SortKind {
        TERM,
        PORT,
        BINDER
    }

    enum EmbeddingKind {
        INJECTION,
        BIJECTION
    }

    enum SchemaKind {
        ONE,
        ONE_SLOT,
        ONE_TERM,
        SEQ,
        BAG,
        SET,
        BIND,
        BIND_BLOCK
    }

    enum TermKind {
        SLOT,
        BOUND,
        APP,
        INVOKE,
        ONE_SLOT,
        ONE_TERM,
        SEQ,
        BAG,
        SET,
        BIND,
        BIND_BLOCK,
        META
    }

    record Sort(SortKind kind, String value) {
        Sort {
            Objects.requireNonNull(kind, "kind");
            requireText(value, "sort value");
        }
    }

    record Slot(String name, String type) {
        Slot {
            requireText(name, "slot name");
            requireText(type, "slot type");
        }
    }

    record Context(String id, List<Slot> slots) {
        Context {
            requireText(id, "context id");
            slots = List.copyOf(slots);
        }

        Slot slot(String name) {
            for (Slot slot : slots) {
                if (slot.name().equals(name)) {
                    return slot;
                }
            }
            throw new FormatException(
                    FailureCode.INVALID_CONTEXT,
                    "Context " + id + " has no slot " + name);
        }

        boolean contains(String name) {
            return slots.stream().anyMatch(slot -> slot.name().equals(name));
        }
    }

    record Embedding(
            String id,
            EmbeddingKind kind,
            Context source,
            Context target,
            Map<String, String> images) {
        Embedding {
            requireText(id, "embedding id");
            Objects.requireNonNull(kind, "embedding kind");
            Objects.requireNonNull(source, "embedding source");
            Objects.requireNonNull(target, "embedding target");
            images = Collections.unmodifiableMap(new LinkedHashMap<>(images));
        }

        String apply(String slot) {
            String image = images.get(slot);
            if (image == null) {
                throw new FormatException(
                        FailureCode.ILL_TYPED_EMBEDDING,
                        "Embedding " + id + " has no image for " + slot);
            }
            return image;
        }
    }

    record Schema(String id, SchemaKind kind, String value, String childSchema) {
        Schema {
            requireText(id, "schema id");
            Objects.requireNonNull(kind, "schema kind");
            Objects.requireNonNull(value, "schema value");
            Objects.requireNonNull(childSchema, "child schema");
        }
    }

    record Operator(String id, String outputType, List<String> schemas) {
        Operator {
            requireText(id, "operator id");
            requireText(outputType, "operator output type");
            schemas = List.copyOf(schemas);
        }
    }

    record BinderCoordinate(
            int index,
            String slotName,
            String type,
            String quantifier,
            String disjointClass,
            String scope) {
        BinderCoordinate {
            if (index < 0) {
                throw new IllegalArgumentException("Negative binder coordinate");
            }
            requireText(slotName, "binder slot name");
            requireText(type, "binder type");
            requireText(quantifier, "binder quantifier");
            Objects.requireNonNull(disjointClass, "disjoint class");
            requireText(scope, "binder scope");
        }
    }

    record Binder(
            String id,
            List<BinderCoordinate> coordinates,
            List<List<Integer>> generators) {
        Binder {
            requireText(id, "binder id");
            coordinates = List.copyOf(coordinates);
            List<List<Integer>> copies = new ArrayList<>();
            for (List<Integer> generator : generators) {
                copies.add(List.copyOf(generator));
            }
            generators = List.copyOf(copies);
        }
    }

    record Pattern(
            TermKind kind,
            Sort sort,
            String symbol,
            List<String> attributes,
            List<Pattern> children) {
        Pattern {
            Objects.requireNonNull(kind, "pattern kind");
            Objects.requireNonNull(sort, "pattern sort");
            Objects.requireNonNull(symbol, "pattern symbol");
            attributes = List.copyOf(attributes);
            children = List.copyOf(children);
        }
    }

    record SideCondition(String kind, List<String> arguments) {
        SideCondition {
            requireText(kind, "side-condition kind");
            arguments = List.copyOf(arguments);
        }
    }

    record Axiom(
            String id,
            Pattern left,
            Pattern right,
            Set<String> typeVariables,
            Map<String, Sort> termVariables,
            List<SideCondition> sideConditions) {
        Axiom {
            requireText(id, "axiom id");
            Objects.requireNonNull(left, "axiom left");
            Objects.requireNonNull(right, "axiom right");
            typeVariables = Set.copyOf(typeVariables);
            termVariables = Map.copyOf(termVariables);
            sideConditions = List.copyOf(sideConditions);
        }
    }

    record Term(
            String id,
            TermKind kind,
            Context context,
            Sort sort,
            String symbol,
            List<String> attributes,
            List<String> children) {
        Term {
            requireText(id, "term id");
            Objects.requireNonNull(kind, "term kind");
            Objects.requireNonNull(context, "term context");
            Objects.requireNonNull(sort, "term sort");
            Objects.requireNonNull(symbol, "term symbol");
            attributes = List.copyOf(attributes);
            children = List.copyOf(children);
        }
    }

    record Witness(
            String id,
            long revision,
            String eclass,
            Context context,
            String type,
            Term definition) {
        Witness {
            requireText(id, "witness id");
            if (revision < 0) {
                throw new IllegalArgumentException("Negative witness revision");
            }
            requireText(eclass, "witness e-class");
            Objects.requireNonNull(context, "witness context");
            requireText(type, "witness type");
            Objects.requireNonNull(definition, "witness definition");
        }
    }

    private final Bundle bundle;
    private final Map<String, Context> contexts;
    private final Map<String, Schema> schemas;
    private final Map<String, Operator> operators;
    private final Map<String, Binder> binders;
    private final Map<String, Axiom> axioms;
    private final Map<String, Embedding> embeddings;
    private final Map<String, Term> terms;
    private final Map<String, Witness> witnesses;

    KernelModel(Bundle bundle) {
        this.bundle = Objects.requireNonNull(bundle, "bundle");
        contexts = parseContexts(bundle.contexts());
        Theory vocabulary = parseVocabulary(bundle.vocabulary(), bundle.theory());
        schemas = vocabulary.schemas;
        operators = vocabulary.operators;
        binders = vocabulary.binders;
        axioms = vocabulary.axioms;
        embeddings = parseEmbeddings(bundle.embeddings());
        terms = parseTerms(bundle.terms());
        witnesses = parseWitnesses(bundle.witnesses());
        validateTerms();
    }

    Bundle bundle() {
        return bundle;
    }

    Context context(String id) {
        Context value = contexts.get(id);
        if (value == null) {
            throw dangling("context", id);
        }
        return value;
    }

    Schema schema(String id) {
        Schema value = schemas.get(id);
        if (value == null) {
            throw dangling("schema", id);
        }
        return value;
    }

    Operator operator(String id) {
        Operator value = operators.get(id);
        if (value == null) {
            throw dangling("operator", id);
        }
        return value;
    }

    Binder binder(String id) {
        Binder value = binders.get(id);
        if (value == null) {
            throw dangling("binder", id);
        }
        return value;
    }

    Axiom axiom(String id) {
        Axiom value = axioms.get(id);
        if (value == null) {
            throw new FormatException(
                    FailureCode.UNREGISTERED_AXIOM, "Unregistered axiom " + id);
        }
        return value;
    }

    Embedding embedding(String id) {
        Embedding value = embeddings.get(id);
        if (value == null) {
            throw dangling("embedding", id);
        }
        return value;
    }

    Term term(String id) {
        Term value = terms.get(id);
        if (value == null) {
            throw dangling("term", id);
        }
        return value;
    }

    Witness witness(String id) {
        Witness value = witnesses.get(id);
        if (value == null) {
            throw dangling("witness", id);
        }
        return value;
    }

    Map<String, Context> contexts() {
        return contexts;
    }

    Map<String, Term> terms() {
        return terms;
    }

    Map<String, Embedding> embeddings() {
        return embeddings;
    }

    Map<String, Binder> binders() {
        return binders;
    }

    Map<String, Witness> witnesses() {
        return witnesses;
    }

    private Map<String, Context> parseContexts(Map<String, Wire.Node> records) {
        Map<String, Context> result = new LinkedHashMap<>();
        for (Wire.Node record : records.values()) {
            if (record.scalars().size() != 1) {
                throw shape("context");
            }
            List<Slot> slots = new ArrayList<>();
            Set<String> names = new HashSet<>();
            String prior = null;
            for (Wire.Node slot : record.children()) {
                slot.requireShape("slot", 2, 0);
                if (!names.add(slot.scalar(0))) {
                    throw new FormatException(
                            FailureCode.INVALID_CONTEXT,
                            "Duplicate slot " + slot.scalar(0));
                }
                String key = slot.scalar(1) + "\u0000" + slot.scalar(0);
                if (prior != null && prior.compareTo(key) >= 0) {
                    throw new FormatException(
                            FailureCode.NONCANONICAL_ENCODING,
                            "Context slots are not in canonical type/name order");
                }
                prior = key;
                slots.add(new Slot(slot.scalar(0), slot.scalar(1)));
            }
            result.put(record.scalar(0), new Context(record.scalar(0), slots));
        }
        return Collections.unmodifiableMap(result);
    }

    private Theory parseVocabulary(Wire.Node vocabulary, Wire.Node theory) {
        vocabulary.requireShape("vocabulary", 1, 3);
        theory.requireShape("theory", 3, 1);
        Wire.Node schemaSection = vocabulary.child(0).requireTag("schemas");
        Wire.Node operatorSection = vocabulary.child(1).requireTag("operators");
        Wire.Node binderSection = vocabulary.child(2).requireTag("binders");
        Wire.Node axiomSection = theory.child(0).requireTag("axioms");
        Map<String, Schema> parsedSchemas = parseSchemas(schemaSection);
        Map<String, Operator> parsedOperators = parseOperators(
                operatorSection, parsedSchemas);
        Map<String, Binder> parsedBinders = parseBinders(binderSection);
        Map<String, Axiom> parsedAxioms = parseAxioms(axiomSection);
        return new Theory(parsedSchemas, parsedOperators, parsedBinders, parsedAxioms);
    }

    private Map<String, Schema> parseSchemas(Wire.Node section) {
        requireEmptyScalars(section);
        Map<String, Schema> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node record : section.children()) {
            record.requireTag("schema");
            if (record.scalars().size() != 3 || record.children().size() > 1) {
                throw shape("schema");
            }
            String id = record.scalar(0);
            prior = requireIncreasing(prior, id, "schema");
            SchemaKind kind = enumValue(SchemaKind.class, record.scalar(1));
            String child = "";
            if (record.children().size() == 1) {
                child = record.child(0).requireShape("schema-ref", 1, 0).scalar(0);
            }
            Schema schema = new Schema(id, kind, record.scalar(2), child);
            if (result.put(id, schema) != null) {
                throw duplicate(id);
            }
        }
        for (Schema schema : result.values()) {
            boolean container = switch (schema.kind()) {
                case SEQ, BAG, SET, BIND, BIND_BLOCK -> true;
                default -> false;
            };
            if (container != !schema.childSchema().isEmpty()) {
                throw shape("schema child");
            }
            if (container && !result.containsKey(schema.childSchema())) {
                throw dangling("schema", schema.childSchema());
            }
        }
        return Collections.unmodifiableMap(result);
    }

    private Map<String, Operator> parseOperators(
            Wire.Node section,
            Map<String, Schema> parsedSchemas) {
        requireEmptyScalars(section);
        Map<String, Operator> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node record : section.children()) {
            record.requireTag("operator");
            if (record.scalars().size() != 2) {
                throw shape("operator");
            }
            String id = record.scalar(0);
            prior = requireIncreasing(prior, id, "operator");
            List<String> ports = new ArrayList<>();
            for (Wire.Node child : record.children()) {
                String schemaId = child.requireShape("schema-ref", 1, 0).scalar(0);
                if (!parsedSchemas.containsKey(schemaId)) {
                    throw dangling("schema", schemaId);
                }
                ports.add(schemaId);
            }
            if (result.put(id, new Operator(id, record.scalar(1), ports)) != null) {
                throw duplicate(id);
            }
        }
        return Collections.unmodifiableMap(result);
    }

    private Map<String, Binder> parseBinders(Wire.Node section) {
        requireEmptyScalars(section);
        Map<String, Binder> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node record : section.children()) {
            record.requireTag("binder");
            if (record.scalars().size() != 1) {
                throw shape("binder");
            }
            String id = record.scalar(0);
            prior = requireIncreasing(prior, id, "binder");
            List<BinderCoordinate> coordinates = new ArrayList<>();
            List<List<Integer>> generators = new ArrayList<>();
            boolean generatorsStarted = false;
            for (Wire.Node child : record.children()) {
                if (child.tag().equals("coordinate")) {
                    if (generatorsStarted || child.scalars().size() != 6
                            || !child.children().isEmpty()) {
                        throw shape("binder coordinate");
                    }
                    int index = parseIndex(child.scalar(0), "binder coordinate");
                    if (index != coordinates.size()) {
                        throw new FormatException(
                                FailureCode.NONCANONICAL_ENCODING,
                                "Binder coordinates must be consecutive");
                    }
                    coordinates.add(new BinderCoordinate(
                            index, child.scalar(1), child.scalar(2), child.scalar(3),
                            child.scalar(4), child.scalar(5)));
                } else if (child.tag().equals("generator")) {
                    generatorsStarted = true;
                    if (!child.children().isEmpty()
                            || child.scalars().size() != coordinates.size()) {
                        throw shape("binder generator");
                    }
                    List<Integer> image = new ArrayList<>();
                    Set<Integer> seen = new HashSet<>();
                    for (String scalar : child.scalars()) {
                        int value = parseIndex(scalar, "binder generator image");
                        if (value >= coordinates.size() || !seen.add(value)) {
                            throw new FormatException(
                                    FailureCode.NON_BIJECTIVE_RENAMING,
                                    "Binder generator is not a permutation");
                        }
                        image.add(value);
                    }
                    for (int source = 0; source < image.size(); source++) {
                        BinderCoordinate left = coordinates.get(source);
                        BinderCoordinate right = coordinates.get(image.get(source));
                        if (!descriptorCompatible(left, right)) {
                            throw new FormatException(
                                    FailureCode.INVALID_SYMMETRY,
                                    "Binder generator crosses descriptor classes");
                        }
                    }
                    generators.add(image);
                } else {
                    throw new FormatException(
                            FailureCode.UNKNOWN_VARIANT,
                            "Unknown binder child " + child.tag());
                }
            }
            result.put(id, new Binder(id, coordinates, generators));
        }
        return Collections.unmodifiableMap(result);
    }

    private static boolean descriptorCompatible(
            BinderCoordinate left,
            BinderCoordinate right) {
        return left.type().equals(right.type())
                && left.quantifier().equals(right.quantifier())
                && left.disjointClass().equals(right.disjointClass())
                && left.scope().equals(right.scope());
    }

    private Map<String, Axiom> parseAxioms(Wire.Node section) {
        requireEmptyScalars(section);
        Map<String, Axiom> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node record : section.children()) {
            record.requireShape("axiom", 1, 5);
            String id = record.scalar(0);
            prior = requireIncreasing(prior, id, "axiom");
            Pattern left = parsePattern(record.child(0));
            Pattern right = parsePattern(record.child(1));
            Wire.Node typeVars = record.child(2).requireTag("type-variables");
            requireEmptyChildren(typeVars);
            Set<String> types = new LinkedHashSet<>(typeVars.scalars());
            if (types.size() != typeVars.scalars().size()) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID, "Duplicate axiom type variable");
            }
            Wire.Node termVars = record.child(3).requireTag("term-variables");
            requireEmptyScalars(termVars);
            Map<String, Sort> variables = new LinkedHashMap<>();
            for (Wire.Node variable : termVars.children()) {
                variable.requireShape("term-variable", 3, 0);
                if (variables.put(
                        variable.scalar(0),
                        parseSort(variable.scalar(1), variable.scalar(2))) != null) {
                    throw duplicate(variable.scalar(0));
                }
            }
            Wire.Node side = record.child(4).requireTag("side-conditions");
            requireEmptyScalars(side);
            List<SideCondition> conditions = new ArrayList<>();
            for (Wire.Node condition : side.children()) {
                condition.requireTag("side-condition");
                if (condition.scalars().isEmpty() || !condition.children().isEmpty()) {
                    throw shape("side condition");
                }
                conditions.add(new SideCondition(
                        condition.scalar(0), condition.scalars().subList(
                                1, condition.scalars().size())));
            }
            result.put(id, new Axiom(
                    id, left, right, types, variables, conditions));
        }
        return Collections.unmodifiableMap(result);
    }

    private Pattern parsePattern(Wire.Node node) {
        node.requireTag("pattern");
        if (node.scalars().size() < 4) {
            throw shape("pattern");
        }
        List<Pattern> children = new ArrayList<>();
        for (Wire.Node child : node.children()) {
            children.add(parsePattern(child));
        }
        return new Pattern(
                enumValue(TermKind.class, node.scalar(0)),
                parseSort(node.scalar(1), node.scalar(2)),
                node.scalar(3),
                node.scalars().subList(4, node.scalars().size()),
                children);
    }

    private Map<String, Embedding> parseEmbeddings(Map<String, Wire.Node> records) {
        Map<String, Embedding> result = new LinkedHashMap<>();
        for (Wire.Node record : records.values()) {
            if (record.scalars().size() != 4) {
                throw shape("embedding");
            }
            Context source = context(record.scalar(2));
            Context target = context(record.scalar(3));
            if (record.children().size() != source.slots().size()) {
                throw new FormatException(
                        FailureCode.ILL_TYPED_EMBEDDING,
                        "Embedding is not total on its source context");
            }
            Map<String, String> images = new LinkedHashMap<>();
            Set<String> targets = new HashSet<>();
            for (int index = 0; index < source.slots().size(); index++) {
                Wire.Node image = record.child(index).requireShape("image", 2, 0);
                Slot sourceSlot = source.slots().get(index);
                if (!image.scalar(0).equals(sourceSlot.name())) {
                    throw new FormatException(
                            FailureCode.NONCANONICAL_ENCODING,
                            "Embedding images are not in source-context order");
                }
                Slot targetSlot = target.slot(image.scalar(1));
                if (!sourceSlot.type().equals(targetSlot.type())
                        || !targets.add(targetSlot.name())) {
                    throw new FormatException(
                            FailureCode.ILL_TYPED_EMBEDDING,
                            "Embedding is not a typed injection");
                }
                images.put(sourceSlot.name(), targetSlot.name());
            }
            EmbeddingKind kind = enumValue(EmbeddingKind.class, record.scalar(1));
            if (kind == EmbeddingKind.BIJECTION
                    && (source.slots().size() != target.slots().size()
                            || targets.size() != target.slots().size())) {
                throw new FormatException(
                        FailureCode.NON_BIJECTIVE_RENAMING,
                        "Value labeled BIJECTION is not onto");
            }
            result.put(record.scalar(0), new Embedding(
                    record.scalar(0), kind, source, target, images));
        }
        return Collections.unmodifiableMap(result);
    }

    private Map<String, Term> parseTerms(Map<String, Wire.Node> records) {
        Map<String, Term> result = new LinkedHashMap<>();
        for (Wire.Node record : records.values()) {
            if (record.scalars().size() < 6) {
                throw shape("term");
            }
            Context context = context(record.scalar(2));
            List<String> children = new ArrayList<>();
            for (Wire.Node child : record.children()) {
                children.add(child.requireShape("term-ref", 1, 0).scalar(0));
            }
            result.put(record.scalar(0), new Term(
                    record.scalar(0),
                    enumValue(TermKind.class, record.scalar(1)),
                    context,
                    parseSort(record.scalar(3), record.scalar(4)),
                    record.scalar(5),
                    record.scalars().subList(6, record.scalars().size()),
                    children));
        }
        for (Term term : result.values()) {
            for (String child : term.children()) {
                if (!result.containsKey(child)) {
                    throw dangling("term", child);
                }
            }
        }
        rejectTermCycles(result);
        return Collections.unmodifiableMap(result);
    }

    private Map<String, Witness> parseWitnesses(Map<String, Wire.Node> records) {
        Map<String, Witness> result = new LinkedHashMap<>();
        for (Wire.Node record : records.values()) {
            record.requireShape("witness", 6, 0);
            Context context = context(record.scalar(3));
            Term definition = term(record.scalar(5));
            if (!definition.context().equals(context)
                    || !definition.sort().equals(new Sort(SortKind.TERM, record.scalar(4)))) {
                throw new FormatException(
                        FailureCode.ILL_TYPED_TERM,
                        "Witness definition has the wrong context or type");
            }
            result.put(record.scalar(0), new Witness(
                    record.scalar(0),
                    Bundle.parseUnsignedLong(record.scalar(1), "witness revision"),
                    record.scalar(2),
                    context,
                    record.scalar(4),
                    definition));
        }
        return Collections.unmodifiableMap(result);
    }

    private void validateTerms() {
        for (Term term : terms.values()) {
            validateTerm(term, new ArrayDeque<>());
        }
    }

    private void validateTerm(Term term, Deque<List<String>> boundTypes) {
        List<Term> children = term.children().stream().map(this::term).toList();
        switch (term.kind()) {
            case SLOT -> {
                requireArity(term, children, 0);
                Slot slot = term.context().slot(term.symbol());
                requireSort(term, SortKind.TERM, slot.type());
            }
            case BOUND -> {
                requireArity(term, children, 0);
                if (term.attributes().size() != 2) {
                    throw illTyped(term, "BOUND requires depth and coordinate");
                }
                int depth = parseIndex(term.attributes().get(0), "bound depth");
                int coordinate = parseIndex(term.attributes().get(1), "bound coordinate");
                if (depth >= boundTypes.size()) {
                    // A shared bound leaf is checked precisely when reached below a binder.
                    return;
                }
                List<List<String>> stack = new ArrayList<>(boundTypes);
                List<String> frame = stack.get(depth);
                if (coordinate >= frame.size()) {
                    throw illTyped(term, "Bound coordinate is out of range");
                }
                requireSort(term, SortKind.TERM, frame.get(coordinate));
            }
            case APP -> {
                Operator operator = operator(term.symbol());
                requireSort(term, SortKind.TERM, operator.outputType());
                if (children.size() != operator.schemas().size()) {
                    throw illTyped(term, "Operator arity mismatch");
                }
                for (int index = 0; index < children.size(); index++) {
                    requireSameContext(term, children.get(index));
                    requireSort(children.get(index), SortKind.PORT,
                            operator.schemas().get(index));
                    validateTerm(children.get(index), boundTypes);
                }
            }
            case INVOKE -> {
                requireArity(term, children, 0);
                if (term.attributes().size() != 1) {
                    throw illTyped(term, "INVOKE requires one embedding");
                }
                Witness witness = witness(term.symbol());
                Embedding embedding = embedding(term.attributes().get(0));
                if (!embedding.source().equals(witness.context())
                        || !embedding.target().equals(term.context())) {
                    throw illTyped(term, "Invocation embedding has wrong contexts");
                }
                requireSort(term, SortKind.TERM, witness.type());
            }
            case ONE_SLOT -> {
                requireArity(term, children, 0);
                Schema schema = schema(term.symbol());
                if ((schema.kind() != SchemaKind.ONE_SLOT
                            && schema.kind() != SchemaKind.ONE)
                        || term.attributes().size() != 1) {
                    throw illTyped(term, "Malformed ONE_SLOT");
                }
                Slot slot = term.context().slot(term.attributes().get(0));
                if (!slot.type().equals(schema.value())) {
                    throw illTyped(term, "Slot leaf type differs from schema");
                }
                requireSort(term, SortKind.PORT, schema.id());
            }
            case ONE_TERM -> {
                requireArity(term, children, 1);
                Schema schema = schema(term.symbol());
                if (schema.kind() != SchemaKind.ONE_TERM
                        && schema.kind() != SchemaKind.ONE) {
                    throw illTyped(term, "Malformed ONE_TERM");
                }
                requireSort(term, SortKind.PORT, schema.id());
                requireSameContext(term, children.get(0));
                requireSort(children.get(0), SortKind.TERM, schema.value());
                validateTerm(children.get(0), boundTypes);
            }
            case SEQ, BAG, SET -> validateContainer(term, children, boundTypes);
            case BIND -> {
                requireArity(term, children, 1);
                Schema schema = schema(term.symbol());
                if (schema.kind() != SchemaKind.BIND
                        || term.attributes().size() != 1) {
                    throw illTyped(term, "Malformed BIND");
                }
                requireSort(term, SortKind.PORT, schema.id());
                String boundSlot = term.attributes().get(0);
                Context bodyContext = children.get(0).context();
                if (term.context().contains(boundSlot)
                        || !bodyContext.contains(boundSlot)
                        || !bodyContext.slot(boundSlot).type().equals(schema.value())
                        || !isContextExtension(term.context(), bodyContext,
                                Set.of(boundSlot))) {
                    throw illTyped(term, "Binder body context is not Gamma plus its slot");
                }
                requireSort(children.get(0), SortKind.PORT, schema.childSchema());
                boundTypes.addFirst(List.of(schema.value()));
                validateTerm(children.get(0), boundTypes);
                boundTypes.removeFirst();
            }
            case BIND_BLOCK -> {
                requireArity(term, children, 1);
                Schema schema = schema(term.symbol());
                if (schema.kind() != SchemaKind.BIND_BLOCK
                        || term.attributes().size() != 1) {
                    throw illTyped(term, "Malformed BIND_BLOCK");
                }
                Binder binder = binder(schema.value());
                requireSort(term, SortKind.PORT, schema.id());
                Embedding occurrence = embedding(term.attributes().get(0));
                if (occurrence.source().slots().size() != binder.coordinates().size()
                        || !isDescriptorContext(occurrence.source(), binder)
                        || !isContextExtension(
                                term.context(), children.get(0).context(),
                                new LinkedHashSet<>(occurrence.images().values()))) {
                    throw illTyped(term,
                            "Binder-block body/context occurrence map is malformed");
                }
                for (String image : occurrence.images().values()) {
                    if (term.context().contains(image)) {
                        throw illTyped(term, "Binder occurrence captures a free slot");
                    }
                }
                requireSort(children.get(0), SortKind.PORT, schema.childSchema());
                boundTypes.addFirst(binder.coordinates().stream()
                        .map(BinderCoordinate::type).toList());
                validateTerm(children.get(0), boundTypes);
                boundTypes.removeFirst();
            }
            case META -> throw illTyped(term, "META is permitted only inside axiom patterns");
        }
    }

    private void validateContainer(
            Term term,
            List<Term> children,
            Deque<List<String>> boundTypes) {
        Schema schema = schema(term.symbol());
        SchemaKind expected = switch (term.kind()) {
            case SEQ -> SchemaKind.SEQ;
            case BAG -> SchemaKind.BAG;
            case SET -> SchemaKind.SET;
            default -> throw new AssertionError();
        };
        if (schema.kind() != expected) {
            throw illTyped(term, "Container constructor/schema mismatch");
        }
        requireSort(term, SortKind.PORT, schema.id());
        for (Term child : children) {
            requireSameContext(term, child);
            requireSort(child, SortKind.PORT, schema.childSchema());
            validateTerm(child, boundTypes);
        }
    }

    private static void requireArity(Term term, List<Term> children, int expected) {
        if (children.size() != expected) {
            throw illTyped(term, "Expected " + expected + " children");
        }
    }

    private static void requireSameContext(Term parent, Term child) {
        if (!parent.context().equals(child.context())) {
            throw illTyped(parent, "Child has a different free context");
        }
    }

    private static void requireSort(Term term, SortKind kind, String value) {
        if (!term.sort().equals(new Sort(kind, value))) {
            throw illTyped(term, "Expected sort " + kind + ":" + value);
        }
    }

    private static boolean isContextExtension(
            Context base,
            Context extended,
            Set<String> added) {
        if (extended.slots().size() != base.slots().size() + added.size()) {
            return false;
        }
        for (Slot slot : base.slots()) {
            if (!extended.contains(slot.name())
                    || !extended.slot(slot.name()).type().equals(slot.type())) {
                return false;
            }
        }
        for (String name : added) {
            if (!extended.contains(name) || base.contains(name)) {
                return false;
            }
        }
        return true;
    }

    private static boolean isDescriptorContext(Context context, Binder binder) {
        if (context.slots().size() != binder.coordinates().size()) {
            return false;
        }
        for (int index = 0; index < context.slots().size(); index++) {
            Slot slot = context.slots().get(index);
            BinderCoordinate coordinate = binder.coordinates().get(index);
            if (!slot.name().equals(coordinate.slotName())
                    || !slot.type().equals(coordinate.type())) {
                return false;
            }
        }
        return true;
    }

    private static FormatException illTyped(Term term, String detail) {
        return new FormatException(
                FailureCode.ILL_TYPED_TERM, "Term " + term.id() + ": " + detail);
    }

    private static void rejectTermCycles(Map<String, Term> terms) {
        Set<String> done = new HashSet<>();
        Set<String> active = new HashSet<>();
        for (String id : terms.keySet()) {
            visitTerm(id, terms, done, active);
        }
    }

    private static void visitTerm(
            String id,
            Map<String, Term> terms,
            Set<String> done,
            Set<String> active) {
        if (done.contains(id)) {
            return;
        }
        if (!active.add(id)) {
            throw new FormatException(
                    FailureCode.DANGLING_REFERENCE, "Cyclic source-term DAG at " + id);
        }
        for (String child : terms.get(id).children()) {
            visitTerm(child, terms, done, active);
        }
        active.remove(id);
        done.add(id);
    }

    private static Sort parseSort(String kind, String value) {
        return new Sort(enumValue(SortKind.class, kind), value);
    }

    private static int parseIndex(String text, String field) {
        long value = Bundle.parseUnsignedLong(text, field);
        if (value > Integer.MAX_VALUE) {
            throw new FormatException(
                    FailureCode.INTEGER_OVERFLOW, field + " exceeds int range");
        }
        return (int) value;
    }

    private static <T extends Enum<T>> T enumValue(Class<T> type, String value) {
        try {
            return Enum.valueOf(type, value);
        } catch (IllegalArgumentException exception) {
            throw new FormatException(
                    FailureCode.UNKNOWN_VARIANT,
                    "Unknown " + type.getSimpleName() + " value " + value,
                    exception);
        }
    }

    private static void requireEmptyScalars(Wire.Node node) {
        if (!node.scalars().isEmpty()) {
            throw shape(node.tag());
        }
    }

    private static void requireEmptyChildren(Wire.Node node) {
        if (!node.children().isEmpty()) {
            throw shape(node.tag());
        }
    }

    private static String requireIncreasing(String prior, String next, String kind) {
        requireText(next, kind + " id");
        if (prior != null && prior.compareTo(next) >= 0) {
            throw new FormatException(
                    prior.equals(next) ? FailureCode.DUPLICATE_ID
                            : FailureCode.NONCANONICAL_ENCODING,
                    kind + " records are duplicated or unsorted");
        }
        return next;
    }

    private static FormatException shape(String record) {
        return new FormatException(
                FailureCode.INVALID_RECORD_SHAPE, "Malformed " + record + " record");
    }

    private static FormatException duplicate(String id) {
        return new FormatException(FailureCode.DUPLICATE_ID, "Duplicate ID " + id);
    }

    private static FormatException dangling(String kind, String id) {
        return new FormatException(
                FailureCode.DANGLING_REFERENCE, "Unknown " + kind + " " + id);
    }

    private static String requireText(String value, String name) {
        Objects.requireNonNull(value, name);
        if (value.isEmpty()) {
            throw new IllegalArgumentException(name + " must not be empty");
        }
        return value;
    }

    private record Theory(
            Map<String, Schema> schemas,
            Map<String, Operator> operators,
            Map<String, Binder> binders,
            Map<String, Axiom> axioms) {
    }
}
