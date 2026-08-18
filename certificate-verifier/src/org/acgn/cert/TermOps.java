package org.acgn.cert;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Capture-avoiding source-term action and independent normal forms. */
final class TermOps {
    private final KernelModel model;
    private final Map<String, KernelModel.Term> known = new HashMap<>();

    TermOps(KernelModel model) {
        this.model = Objects.requireNonNull(model, "model");
        known.putAll(model.terms());
    }

    KernelModel.Term term(String id) {
        KernelModel.Term term = known.get(id);
        if (term == null) {
            throw new FormatException(
                    FailureCode.DANGLING_REFERENCE, "Unknown synthesized term " + id);
        }
        return term;
    }

    KernelModel.Term act(KernelModel.Term source, KernelModel.Embedding action) {
        if (!source.context().equals(action.source())) {
            throw new FormatException(
                    FailureCode.ILL_TYPED_EMBEDDING,
                    "Term action does not begin at the term context");
        }
        Map<String, KernelModel.Term> memo = new HashMap<>();
        return act(source, action, memo);
    }

    private KernelModel.Term act(
            KernelModel.Term source,
            KernelModel.Embedding action,
            Map<String, KernelModel.Term> memo) {
        String memoKey = source.id() + "\u0000" + action.id();
        KernelModel.Term prior = memo.get(memoKey);
        if (prior != null) {
            return prior;
        }
        String symbol = source.symbol();
        List<String> attributes = new ArrayList<>(source.attributes());
        List<KernelModel.Term> children = new ArrayList<>();
        if (source.kind() == KernelModel.TermKind.BIND) {
            if (attributes.size() != 1 || source.children().size() != 1) {
                throw malformedAction(source);
            }
            KernelModel.Term body = term(source.children().get(0));
            String bound = attributes.get(0);
            KernelModel.Slot boundSlot = body.context().slot(bound);
            KernelModel.Context targetBody = extendedContext(
                    action.target(), List.of(boundSlot));
            Map<String, String> images = new LinkedHashMap<>(action.images());
            images.put(bound, bound);
            KernelModel.Embedding extended = declaredEmbedding(
                    action.kind(), body.context(), targetBody, images);
            children.add(act(body, extended, memo));
        } else if (source.kind() == KernelModel.TermKind.BIND_BLOCK) {
            if (attributes.size() != 1 || source.children().size() != 1) {
                throw malformedAction(source);
            }
            KernelModel.Term body = term(source.children().get(0));
            KernelModel.Embedding occurrence = model.embedding(attributes.get(0));
            KernelModel.Context targetBody = extendedContext(
                    action.target(), occurrence.target().slots());
            Map<String, String> images = new LinkedHashMap<>(action.images());
            for (KernelModel.Slot bound : occurrence.target().slots()) {
                images.put(bound.name(), bound.name());
            }
            KernelModel.Embedding extended = declaredEmbedding(
                    action.kind(), body.context(), targetBody, images);
            children.add(act(body, extended, memo));
        } else {
            for (String child : source.children()) {
                children.add(act(term(child), action, memo));
            }
        }
        switch (source.kind()) {
            case SLOT -> symbol = action.apply(source.symbol());
            case ONE_SLOT -> {
                if (attributes.size() != 1) {
                    throw malformedAction(source);
                }
                attributes.set(0, action.apply(attributes.get(0)));
            }
            case INVOKE -> {
                if (attributes.size() != 1) {
                    throw malformedAction(source);
                }
                KernelModel.Embedding invocation = model.embedding(attributes.get(0));
                KernelModel.Embedding composed = compose(invocation, action);
                attributes.set(0, composed.id());
            }
            default -> {
                // De Bruijn BOUND coordinates and constructor metadata are invariant.
            }
        }
        KernelModel.Term result = intern(
                source.kind(), action.target(), source.sort(), symbol, attributes, children);
        memo.put(memoKey, result);
        return result;
    }

    KernelModel.Embedding compose(
            KernelModel.Embedding first,
            KernelModel.Embedding second) {
        if (!first.target().equals(second.source())) {
            throw new FormatException(
                    FailureCode.ILL_TYPED_EMBEDDING,
                    "Embedding composition has a context mismatch");
        }
        Map<String, String> images = new LinkedHashMap<>();
        for (KernelModel.Slot slot : first.source().slots()) {
            images.put(slot.name(), second.apply(first.apply(slot.name())));
        }
        KernelModel.EmbeddingKind kind = first.kind() == KernelModel.EmbeddingKind.BIJECTION
                && second.kind() == KernelModel.EmbeddingKind.BIJECTION
                ? KernelModel.EmbeddingKind.BIJECTION
                : KernelModel.EmbeddingKind.INJECTION;
        String id = embeddingId(kind, first.source(), second.target(), images);
        KernelModel.Embedding declared;
        try {
            declared = model.embedding(id);
        } catch (FormatException exception) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Composed embedding " + id + " is absent from the bundle");
        }
        if (declared.kind() != kind
                || !declared.source().equals(first.source())
                || !declared.target().equals(second.target())
                || !declared.images().equals(images)) {
            throw new FormatException(
                    FailureCode.ILL_TYPED_EMBEDDING,
                    "Declared composed embedding differs from its synthesis");
        }
        return declared;
    }

    static String embeddingId(
            KernelModel.EmbeddingKind kind,
            KernelModel.Context source,
            KernelModel.Context target,
            Map<String, String> images) {
        List<Wire.Node> imageNodes = new ArrayList<>();
        for (KernelModel.Slot slot : source.slots()) {
            imageNodes.add(Wire.leaf("image", slot.name(), images.get(slot.name())));
        }
        Wire.Node record = Bundle.withContentId(
                "embedding",
                List.of(kind.name(), source.id(), target.id()),
                imageNodes);
        return record.scalar(0);
    }

    KernelModel.Term normalizeContainers(KernelModel.Term source) {
        Map<String, KernelModel.Term> memo = new HashMap<>();
        return normalizeContainers(source, memo);
    }

    private KernelModel.Term normalizeContainers(
            KernelModel.Term source,
            Map<String, KernelModel.Term> memo) {
        KernelModel.Term prior = memo.get(source.id());
        if (prior != null) {
            return prior;
        }
        List<KernelModel.Term> children = new ArrayList<>();
        for (String child : source.children()) {
            children.add(normalizeContainers(term(child), memo));
        }
        if (source.kind() == KernelModel.TermKind.BAG) {
            children.sort(Comparator.comparing(KernelModel.Term::id));
        } else if (source.kind() == KernelModel.TermKind.SET) {
            children.sort(Comparator.comparing(KernelModel.Term::id));
            List<KernelModel.Term> unique = new ArrayList<>();
            String priorId = null;
            for (KernelModel.Term child : children) {
                if (!child.id().equals(priorId)) {
                    unique.add(child);
                    priorId = child.id();
                }
            }
            children = unique;
        }
        KernelModel.Term result = intern(
                source.kind(), source.context(), source.sort(), source.symbol(),
                source.attributes(), children);
        memo.put(source.id(), result);
        return result;
    }

    KernelModel.Term permuteBinderBlock(
            KernelModel.Term source,
            List<Integer> permutation) {
        if (source.kind() != KernelModel.TermKind.BIND_BLOCK) {
            throw new IllegalArgumentException("Expected a BIND_BLOCK term");
        }
        KernelModel.Schema schema = model.schema(source.symbol());
        KernelModel.Binder binder = model.binder(schema.value());
        if (permutation.size() != binder.coordinates().size()) {
            throw new FormatException(
                    FailureCode.INVALID_SYMMETRY, "Binder permutation has wrong arity");
        }
        KernelModel.Term body;
        if (source.attributes().size() == 1) {
            KernelModel.Embedding occurrence = model.embedding(source.attributes().get(0));
            KernelModel.Term originalBody = term(source.children().get(0));
            Map<String, String> images = new LinkedHashMap<>();
            for (KernelModel.Slot free : source.context().slots()) {
                images.put(free.name(), free.name());
            }
            for (int index = 0; index < binder.coordinates().size(); index++) {
                String descriptorSource = binder.coordinates().get(index).slotName();
                String descriptorTarget = binder.coordinates()
                        .get(permutation.get(index)).slotName();
                images.put(
                        occurrence.apply(descriptorSource),
                        occurrence.apply(descriptorTarget));
            }
            KernelModel.Embedding action = declaredEmbedding(
                    KernelModel.EmbeddingKind.BIJECTION,
                    originalBody.context(), originalBody.context(), images);
            body = act(originalBody, action);
        } else {
            body = rewriteBoundCoordinates(
                    term(source.children().get(0)), 0, permutation);
        }
        return intern(
                source.kind(), source.context(), source.sort(), source.symbol(),
                source.attributes(), List.of(body));
    }

    private KernelModel.Context extendedContext(
            KernelModel.Context base,
            List<KernelModel.Slot> extra) {
        Map<String, KernelModel.Slot> slots = new java.util.TreeMap<>();
        for (KernelModel.Slot slot : base.slots()) {
            slots.put(slot.type() + "\u0000" + slot.name(), slot);
        }
        for (KernelModel.Slot slot : extra) {
            String key = slot.type() + "\u0000" + slot.name();
            if (slots.putIfAbsent(key, slot) != null) {
                throw new FormatException(
                        FailureCode.ILL_TYPED_EMBEDDING,
                        "Binder action captures an existing target slot");
            }
        }
        List<Wire.Node> wireSlots = slots.values().stream()
                .map(slot -> Wire.leaf("slot", slot.name(), slot.type())).toList();
        Wire.Node record = Bundle.withContentId("context", List.of(), wireSlots);
        try {
            return model.context(record.scalar(0));
        } catch (FormatException exception) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Bundle omits a capture-avoiding extended binder context");
        }
    }

    private KernelModel.Embedding declaredEmbedding(
            KernelModel.EmbeddingKind kind,
            KernelModel.Context source,
            KernelModel.Context target,
            Map<String, String> images) {
        String id = embeddingId(kind, source, target, images);
        try {
            return model.embedding(id);
        } catch (FormatException exception) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Bundle omits required binder action embedding " + id);
        }
    }

    private KernelModel.Term rewriteBoundCoordinates(
            KernelModel.Term source,
            int depth,
            List<Integer> permutation) {
        if (source.kind() == KernelModel.TermKind.BOUND
                && source.attributes().size() == 2
                && Integer.toString(depth).equals(source.attributes().get(0))) {
            int coordinate = Integer.parseInt(source.attributes().get(1));
            return intern(
                    source.kind(), source.context(), source.sort(), source.symbol(),
                    List.of(source.attributes().get(0),
                            Integer.toString(permutation.get(coordinate))),
                    List.of());
        }
        int childDepth = depth;
        if (source.kind() == KernelModel.TermKind.BIND
                || source.kind() == KernelModel.TermKind.BIND_BLOCK) {
            childDepth = Math.incrementExact(depth);
        }
        List<KernelModel.Term> children = new ArrayList<>();
        for (String child : source.children()) {
            children.add(rewriteBoundCoordinates(term(child), childDepth, permutation));
        }
        return intern(
                source.kind(), source.context(), source.sort(), source.symbol(),
                source.attributes(), children);
    }

    KernelModel.Term instantiate(
            KernelModel.Pattern pattern,
            KernelModel.Context context,
            Map<String, String> typeSubstitution,
            Map<String, KernelModel.Term> termSubstitution) {
        if (pattern.kind() == KernelModel.TermKind.META) {
            KernelModel.Term replacement = termSubstitution.get(pattern.symbol());
            if (replacement == null) {
                throw new FormatException(
                        FailureCode.INVALID_SUBSTITUTION,
                        "Missing term substitution for " + pattern.symbol());
            }
            KernelModel.Sort expected = substituteSort(pattern.sort(), typeSubstitution);
            if (!replacement.context().equals(context)
                    || !replacement.sort().equals(expected)) {
                throw new FormatException(
                        FailureCode.INVALID_SUBSTITUTION,
                        "Ill-typed substitution for " + pattern.symbol());
            }
            return replacement;
        }
        List<KernelModel.Term> children = new ArrayList<>();
        for (KernelModel.Pattern child : pattern.children()) {
            children.add(instantiate(child, context, typeSubstitution, termSubstitution));
        }
        KernelModel.Sort sort = substituteSort(pattern.sort(), typeSubstitution);
        String symbol = substituteText(pattern.symbol(), typeSubstitution);
        List<String> attributes = pattern.attributes().stream()
                .map(value -> substituteText(value, typeSubstitution)).toList();
        return intern(pattern.kind(), context, sort, symbol, attributes, children);
    }

    private static KernelModel.Sort substituteSort(
            KernelModel.Sort sort,
            Map<String, String> substitution) {
        return new KernelModel.Sort(
                sort.kind(), substituteText(sort.value(), substitution));
    }

    private static String substituteText(String value, Map<String, String> substitution) {
        if (value.startsWith("$") && substitution.containsKey(value.substring(1))) {
            return substitution.get(value.substring(1));
        }
        return value;
    }

    String alphaKey(KernelModel.Term source) {
        Map<String, String> free = new LinkedHashMap<>();
        Map<String, Integer> typeOrdinals = new HashMap<>();
        for (KernelModel.Slot slot : source.context().slots()) {
            int ordinal = typeOrdinals.getOrDefault(slot.type(), 0);
            typeOrdinals.put(slot.type(), ordinal + 1);
            free.put(slot.name(), slot.type() + "#" + ordinal);
        }
        return alphaKey(normalizeContainers(source), free, 0, true);
    }

    private String alphaKey(
            KernelModel.Term source,
            Map<String, String> free,
            int depth,
            boolean includeCurrentBinderOrbit) {
        Map<String, String> childNames = free;
        int childDepth = depth;
        if (source.kind() == KernelModel.TermKind.BIND
                && source.attributes().size() == 1) {
            childNames = new LinkedHashMap<>(free);
            childNames.put(source.attributes().get(0), "@bound:" + depth + ":0");
            childDepth++;
        } else if (source.kind() == KernelModel.TermKind.BIND_BLOCK
                && source.attributes().size() == 1) {
            childNames = new LinkedHashMap<>(free);
            KernelModel.Embedding occurrence = model.embedding(source.attributes().get(0));
            KernelModel.Schema schema = model.schema(source.symbol());
            KernelModel.Binder binder = model.binder(schema.value());
            for (int index = 0; index < binder.coordinates().size(); index++) {
                String descriptor = binder.coordinates().get(index).slotName();
                childNames.put(
                        occurrence.apply(descriptor),
                        "@bound:" + depth + ":" + index);
            }
            childDepth++;
        }
        List<String> childKeys = new ArrayList<>();
        for (String child : source.children()) {
            childKeys.add(alphaKey(term(child), childNames, childDepth, true));
        }
        if (source.kind() == KernelModel.TermKind.BAG) {
            Collections.sort(childKeys);
        } else if (source.kind() == KernelModel.TermKind.SET) {
            childKeys = new ArrayList<>(new LinkedHashSet<>(childKeys.stream()
                    .sorted().toList()));
        } else if (source.kind() == KernelModel.TermKind.BIND_BLOCK
                && includeCurrentBinderOrbit) {
            KernelModel.Schema schema = model.schema(source.symbol());
            KernelModel.Binder binder = model.binder(schema.value());
            String minimum = encodeAlpha(source, free, childKeys);
            for (List<Integer> permutation : closure(
                    binder.coordinates().size(), binder.generators(), Long.MAX_VALUE)) {
                KernelModel.Term moved = normalizeContainers(
                        permuteBinderBlock(source, permutation));
                String key = alphaKey(moved, free, depth, false);
                if (key.compareTo(minimum) < 0) {
                    minimum = key;
                }
            }
            return minimum;
        }
        return encodeAlpha(source, free, childKeys);
    }

    Wire.Node structuralNode(KernelModel.Term source) {
        List<Wire.Node> children = new ArrayList<>();
        for (String child : source.children()) {
            children.add(structuralNode(term(child)));
        }
        List<String> scalars = new ArrayList<>();
        scalars.add(source.context().id());
        scalars.add(source.sort().kind().name());
        scalars.add(source.sort().value());
        scalars.add(source.symbol());
        scalars.addAll(source.attributes());
        return Wire.node("term-key/" + source.kind().name(), scalars, children);
    }

    KernelModel.Term replaceAtPath(
            KernelModel.Term root,
            List<Integer> path,
            KernelModel.Term replacement) {
        return replaceAtPath(root, path, 0, replacement);
    }

    private KernelModel.Term replaceAtPath(
            KernelModel.Term current,
            List<Integer> path,
            int depth,
            KernelModel.Term replacement) {
        if (depth == path.size()) {
            if (!current.context().equals(replacement.context())
                    || !current.sort().equals(replacement.sort())) {
                throw new FormatException(
                        FailureCode.ILL_TYPED_TERM,
                        "Path replacement changes context or sort");
            }
            return replacement;
        }
        int childIndex = path.get(depth);
        if (childIndex < 0 || childIndex >= current.children().size()) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE, "Term path is out of range");
        }
        List<KernelModel.Term> children = new ArrayList<>();
        for (int index = 0; index < current.children().size(); index++) {
            KernelModel.Term child = term(current.children().get(index));
            children.add(index == childIndex
                    ? replaceAtPath(child, path, depth + 1, replacement)
                    : child);
        }
        return intern(
                current.kind(), current.context(), current.sort(), current.symbol(),
                current.attributes(), children);
    }

    List<List<Integer>> termPaths(KernelModel.Term root, KernelModel.TermKind kind) {
        List<List<Integer>> result = new ArrayList<>();
        collectPaths(root, kind, new ArrayList<>(), result);
        return result;
    }

    private void collectPaths(
            KernelModel.Term current,
            KernelModel.TermKind kind,
            List<Integer> path,
            List<List<Integer>> target) {
        if (current.kind() == kind) {
            target.add(List.copyOf(path));
        }
        for (int index = 0; index < current.children().size(); index++) {
            path.add(index);
            collectPaths(term(current.children().get(index)), kind, path, target);
            path.remove(path.size() - 1);
        }
    }

    KernelModel.Term atPath(KernelModel.Term root, List<Integer> path) {
        KernelModel.Term current = root;
        for (int index : path) {
            if (index < 0 || index >= current.children().size()) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE, "Term path is out of range");
            }
            current = term(current.children().get(index));
        }
        return current;
    }

    Set<String> support(KernelModel.Term source) {
        Set<String> result = new LinkedHashSet<>();
        collectSupport(source, result);
        return result;
    }

    private void collectSupport(KernelModel.Term source, Set<String> result) {
        if (source.kind() == KernelModel.TermKind.SLOT) {
            result.add(source.symbol());
        } else if (source.kind() == KernelModel.TermKind.ONE_SLOT
                && source.attributes().size() == 1) {
            result.add(source.attributes().get(0));
        } else if (source.kind() == KernelModel.TermKind.INVOKE
                && source.attributes().size() == 1) {
            result.addAll(model.embedding(source.attributes().get(0)).images().values());
        }
        Set<String> childSupport = new LinkedHashSet<>();
        for (String child : source.children()) {
            collectSupport(term(child), childSupport);
        }
        if (source.kind() == KernelModel.TermKind.BIND
                && source.attributes().size() == 1) {
            childSupport.remove(source.attributes().get(0));
        } else if (source.kind() == KernelModel.TermKind.BIND_BLOCK
                && source.attributes().size() == 1) {
            childSupport.removeAll(model.embedding(
                    source.attributes().get(0)).images().values());
        }
        result.addAll(childSupport);
    }

    private static String encodeAlpha(
            KernelModel.Term source,
            Map<String, String> free,
            List<String> childKeys) {
        String symbol = source.kind() == KernelModel.TermKind.SLOT
                ? free.getOrDefault(source.symbol(), "@unbound:" + source.symbol())
                : source.symbol();
        List<String> attributes = new ArrayList<>(source.attributes());
        if (source.kind() == KernelModel.TermKind.ONE_SLOT && attributes.size() == 1) {
            attributes.set(0, free.getOrDefault(
                    attributes.get(0), "@unbound:" + attributes.get(0)));
        } else if (source.kind() == KernelModel.TermKind.BIND
                && attributes.size() == 1) {
            attributes.set(0, "@binder-slot");
        } else if (source.kind() == KernelModel.TermKind.BIND_BLOCK
                && attributes.size() == 1) {
            attributes.set(0, "@binder-occurrence");
        }
        StringBuilder key = new StringBuilder()
                .append(source.kind()).append('|')
                .append(source.sort().kind()).append(':').append(source.sort().value())
                .append('|').append(symbol).append('|').append(attributes);
        for (String child : childKeys) {
            key.append('{').append(child.length()).append(':').append(child).append('}');
        }
        return key.toString();
    }

    List<List<Integer>> closure(
            int size,
            List<List<Integer>> generators,
            long limit) {
        List<Integer> identity = new ArrayList<>(size);
        for (int index = 0; index < size; index++) {
            identity.add(index);
        }
        Set<List<Integer>> seen = new LinkedHashSet<>();
        List<List<Integer>> queue = new ArrayList<>();
        seen.add(List.copyOf(identity));
        queue.add(List.copyOf(identity));
        for (int cursor = 0; cursor < queue.size(); cursor++) {
            List<Integer> current = queue.get(cursor);
            for (List<Integer> generator : generators) {
                List<Integer> composed = composePermutation(current, generator);
                if (seen.add(composed)) {
                    if (seen.size() > limit) {
                        throw new ResourceLimitException(
                                "Permutation closure exceeds configured orbit limit");
                    }
                    queue.add(composed);
                }
            }
        }
        return List.copyOf(seen);
    }

    private static List<Integer> composePermutation(
            List<Integer> first,
            List<Integer> second) {
        List<Integer> result = new ArrayList<>(first.size());
        for (int index = 0; index < first.size(); index++) {
            result.add(second.get(first.get(index)));
        }
        return List.copyOf(result);
    }

    KernelModel.Term intern(
            KernelModel.TermKind kind,
            KernelModel.Context context,
            KernelModel.Sort sort,
            String symbol,
            List<String> attributes,
            List<KernelModel.Term> children) {
        List<String> scalars = new ArrayList<>();
        scalars.add(kind.name());
        scalars.add(context.id());
        scalars.add(sort.kind().name());
        scalars.add(sort.value());
        scalars.add(symbol);
        scalars.addAll(attributes);
        List<Wire.Node> childRefs = children.stream()
                .map(child -> Wire.leaf("term-ref", child.id())).toList();
        Wire.Node record = Bundle.withContentId("term", scalars, childRefs);
        KernelModel.Term term = new KernelModel.Term(
                record.scalar(0), kind, context, sort, symbol,
                attributes, children.stream().map(KernelModel.Term::id).toList());
        known.putIfAbsent(term.id(), term);
        return known.get(term.id());
    }

    private static FormatException malformedAction(KernelModel.Term source) {
        return new FormatException(
                FailureCode.ILL_TYPED_TERM,
                "Malformed action payload on term " + source.id());
    }

    static final class ResourceLimitException extends RuntimeException {
        private static final long serialVersionUID = 1L;

        ResourceLimitException(String message) {
            super(message);
        }
    }
}
