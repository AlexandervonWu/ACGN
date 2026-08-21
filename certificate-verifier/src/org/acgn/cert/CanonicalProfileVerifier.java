package org.acgn.cert;

import java.util.ArrayList;
import java.util.ArrayDeque;
import java.util.Collections;
import java.util.Comparator;
import java.util.Deque;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Consumer;

/** Exhaustive finite canonical-orbit reconstruction. */
final class CanonicalProfileVerifier {
    private final KernelModel model;
    private final KernelVerifier kernel;
    private final Limits limits;
    private final TermOps terms;
    private long generated;

    CanonicalProfileVerifier(KernelModel model, KernelVerifier kernel, Limits limits) {
        this.model = model;
        this.kernel = kernel;
        this.limits = limits;
        this.terms = kernel.termOps();
    }

    void verifyAllRecords() {
        for (Wire.Node record : model.bundle().canonicalRecords().values()) {
            record.requireShape("canonical-record", 3, 1);
            String proofId = record.scalar(1);
            KernelVerifier.ProofRecord proof = kernel.proofRecord(proofId);
            if (proof.variant() != KernelVerifier.Variant.CANONICAL_ORBIT) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE,
                        "Canonical record does not reference a canonical-orbit proof");
            }
            KernelVerifier.Judgment judgment = kernel.verify(proofId);
            if (!judgment.right().id().equals(record.scalar(2))) {
                throw new FormatException(
                        FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                        "Canonical record and proof representatives differ");
            }
            Wire.Node sourceReplay = record.child(0)
                    .requireShape("source-replay-ref", 1, 0);
            KernelVerifier.ProofRecord replay = kernel.proofRecord(sourceReplay.scalar(0));
            if (replay.variant() != KernelVerifier.Variant.KERNEL_REPLAY) {
                throw new FormatException(
                        FailureCode.INVALID_KERNEL_REPLAY,
                        "Canonical record lacks its source-to-kernel certificate");
            }
            kernel.verify(sourceReplay.scalar(0));
        }
    }

    void verifyOrbitPayload(
            Wire.Node payload,
            KernelModel.Term claimedSource,
            KernelModel.Term claimedRepresentative) {
        payload.requireShape("canonical-orbit", 6, 4);
        KernelModel.Term source = model.term(payload.scalar(0));
        KernelModel.Term base = model.term(payload.scalar(1));
        KernelModel.Context targetContext = model.context(payload.scalar(2));
        KernelModel.Term representative = model.term(payload.scalar(3));
        KernelModel.Embedding selectedWitness = model.embedding(payload.scalar(4));
        long claimedCount = Bundle.parseUnsignedLong(
                payload.scalar(5), "orbit candidate count");
        if (!source.id().equals(claimedSource.id())
                || !representative.id().equals(claimedRepresentative.id())) {
            throw new FormatException(
                    FailureCode.ENDPOINT_CLAIM_MISMATCH,
                    "Canonical orbit endpoints differ from the proof claims");
        }
        if (selectedWitness.kind() != KernelModel.EmbeddingKind.BIJECTION
                || !selectedWitness.source().equals(base.context())
                || !selectedWitness.target().equals(targetContext)
                || !terms.act(base, selectedWitness).id().equals(source.id())) {
            throw new FormatException(
                    FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                    "Selected canonical witness does not instantiate the declared base term");
        }

        Map<List<Integer>, LeaderGroup> leaderGroups = verifyLeaderGroups(
                base, payload.child(1));
        Wire.Node binderReferences = payload.child(3)
                .requireTag("binder-occurrence-refs");
        if (!binderReferences.scalars().isEmpty()) {
            throw malformed("binder occurrence references");
        }
        String priorBinderReference = null;
        for (Wire.Node reference : binderReferences.children()) {
            reference.requireShape("binder-occurrence-ref", 1, 0);
            if (priorBinderReference != null
                    && priorBinderReference.compareTo(reference.scalar(0)) >= 0) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Binder occurrence references are not strictly ordered");
            }
            priorBinderReference = reference.scalar(0);
        }

        OrbitMinimum minimum = new OrbitMinimum();
        verifyFreeRenamings(
                base.context(),
                targetContext,
                payload.child(0),
                free -> {
            KernelModel.Term globallyRenamed = terms.act(base, free);
            forEachLeaderAlternative(
                    globallyRenamed,
                    leaderGroups,
                    leaderAlternative -> forEachBinderAlternative(
                            leaderAlternative,
                            binderAlternative -> {
                    consumeOrbitMember();
                    KernelModel.Term normalized = terms.normalizeContainers(binderAlternative);
                    minimum.consider(normalized, free);
                            }));
                });
        if (minimum.isEmpty()) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT, "Canonical orbit is empty");
        }
        if (minimum.count() != claimedCount) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT,
                    "Claimed candidate count differs from exhaustive reconstruction");
        }

        Wire.Node minimumNode = payload.child(2).requireTag("orbit-minimum");
        if (!minimumNode.scalars().isEmpty()
                || minimumNode.children().size() != 2) {
            throw malformed("orbit minimum");
        }
        String claimedMinimum = minimumNode.child(0)
                .requireShape("term-ref", 1, 0).scalar(0);
        String claimedWitness = minimumNode.child(1)
                .requireShape("embedding-ref", 1, 0).scalar(0);
        if (!claimedMinimum.equals(representative.id())
                || !claimedWitness.equals(selectedWitness.id())) {
            throw new FormatException(
                    FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                    "Serialized streaming minimum differs from the representative pair");
        }
        OrbitCandidate reconstructedMinimum = minimum.orElseThrow();
        if (!reconstructedMinimum.term().id().equals(representative.id())
                || !reconstructedMinimum.witness().id().equals(selectedWitness.id())) {
            throw new FormatException(
                    FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                    "A smaller complete (term,witness) pair exists in the admissible orbit");
        }
    }

    private int compareCandidates(OrbitCandidate left, OrbitCandidate right) {
        int compared = kernel.compareCanonicalTerms(left.term(), right.term());
        return compared != 0
                ? compared
                : compareWitnesses(left.witness(), right.witness());
    }

    private static int compareWitnesses(
            KernelModel.Embedding left,
            KernelModel.Embedding right) {
        if (!left.source().equals(right.source())
                || !left.target().equals(right.target())) {
            throw new FormatException(
                    FailureCode.NONCANONICAL_ENCODING,
                    "Canonical witness comparison crossed endpoint contexts");
        }
        List<KernelModel.Slot> sources = new ArrayList<>(left.source().slots());
        sources.sort(Comparator.comparing(KernelModel.Slot::name));
        for (KernelModel.Slot source : sources) {
            int compared = left.apply(source.name()).compareTo(
                    right.apply(source.name()));
            if (compared != 0) {
                return compared;
            }
        }
        return 0;
    }

    private void verifyFreeRenamings(
            KernelModel.Context source,
            KernelModel.Context target,
            Wire.Node suppliedNode,
            Consumer<KernelModel.Embedding> consumer) {
        suppliedNode.requireTag("free-renamings");
        if (!suppliedNode.scalars().isEmpty()) {
            throw malformed("free renamings");
        }
        Set<String> supplied = new LinkedHashSet<>();
        String prior = null;
        for (Wire.Node child : suppliedNode.children()) {
            String id = child.requireShape("embedding-ref", 1, 0).scalar(0);
            if (prior != null && prior.compareTo(id) >= 0) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Free renamings are duplicated or unsorted");
            }
            prior = id;
            supplied.add(id);
        }
        forEachTypedBijection(source, target, embedding -> {
            if (!supplied.remove(embedding.id())) {
                throw new UncheckableException(
                        FailureCode.INCOMPLETE_ORBIT,
                        "Bundle omits admissible free renaming " + embedding.id());
            }
            consumer.accept(embedding);
        });
        if (!supplied.isEmpty()) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT,
                    "Free-slot orbit contains nonadmissible renamings");
        }
    }

    private void forEachTypedBijection(
            KernelModel.Context source,
            KernelModel.Context target,
            Consumer<KernelModel.Embedding> consumer) {
        if (source.slots().size() > limits.maxDepth()
                || target.slots().size() > limits.maxDepth()) {
            throw new UncheckableException(
                    FailureCode.RESOURCE_LIMIT,
                    "Typed-renaming recursion exceeds the configured depth");
        }
        Map<String, List<KernelModel.Slot>> sourceByType = byType(source);
        Map<String, List<KernelModel.Slot>> targetByType = byType(target);
        if (!sourceByType.keySet().equals(targetByType.keySet())) {
            throw new FormatException(
                    FailureCode.NON_BIJECTIVE_RENAMING,
                    "Canonical contexts have different type alphabets");
        }
        List<String> types = new ArrayList<>(sourceByType.keySet());
        for (String type : types) {
            if (sourceByType.get(type).size() != targetByType.get(type).size()) {
                throw new FormatException(
                        FailureCode.NON_BIJECTIVE_RENAMING,
                        "Canonical contexts have different typed cardinalities");
            }
        }
        forEachTypedBijectionGroup(
                source,
                target,
                sourceByType,
                targetByType,
                types,
                0,
                new LinkedHashMap<>(),
                mapping -> {
            String id = TermOps.embeddingId(
                    KernelModel.EmbeddingKind.BIJECTION, source, target, mapping);
            KernelModel.Embedding embedding;
            try {
                embedding = model.embedding(id);
            } catch (FormatException exception) {
                throw new UncheckableException(
                        FailureCode.MISSING_EVIDENCE,
                        "Bundle omits admissible free renaming " + id);
            }
            consumer.accept(embedding);
        });
    }

    private void forEachTypedBijectionGroup(
            KernelModel.Context source,
            KernelModel.Context target,
            Map<String, List<KernelModel.Slot>> sourceByType,
            Map<String, List<KernelModel.Slot>> targetByType,
            List<String> types,
            int typeIndex,
            Map<String, String> mapping,
            Consumer<Map<String, String>> consumer) {
        if (typeIndex == types.size()) {
            consumeOrbitMember();
            consumer.accept(Map.copyOf(mapping));
            return;
        }
        String type = types.get(typeIndex);
        List<KernelModel.Slot> left = sourceByType.get(type);
        forEachPermutation(targetByType.get(type), permutation -> {
            for (int index = 0; index < left.size(); index++) {
                mapping.put(left.get(index).name(), permutation.get(index).name());
            }
            forEachTypedBijectionGroup(
                    source,
                    target,
                    sourceByType,
                    targetByType,
                    types,
                    typeIndex + 1,
                    mapping,
                    consumer);
            for (KernelModel.Slot slot : left) {
                mapping.remove(slot.name());
            }
        });
    }

    private Map<List<Integer>, LeaderGroup> verifyLeaderGroups(
            KernelModel.Term source,
            Wire.Node groupsNode) {
        groupsNode.requireTag("leader-groups");
        if (groupsNode.scalars().size() != 2 || !"complete".equals(groupsNode.scalar(1))) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT,
                    "Leader groups lack a complete snapshot/revision assertion");
        }
        SnapshotGroupLedger snapshot = snapshotGroupLedger(groupsNode.scalar(0));
        List<List<Integer>> paths = terms.termPaths(source, KernelModel.TermKind.INVOKE);
        Map<List<Integer>, LeaderGroup> result = new LinkedHashMap<>();
        List<Integer> prior = null;
        for (Wire.Node groupNode : groupsNode.children()) {
            groupNode.requireTag("leader-group");
            if (groupNode.scalars().size() != 2) {
                throw malformed("leader group");
            }
            List<Integer> path = SourceToKernelVerifier.parsePath(groupNode.scalar(0));
            if (prior != null && SourceToKernelVerifier.comparePaths(prior, path) >= 0) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Leader groups are duplicated or unsorted");
            }
            prior = path;
            KernelModel.Term invocation = terms.atPath(source, path);
            if (invocation.kind() != KernelModel.TermKind.INVOKE
                    || !invocation.symbol().equals(groupNode.scalar(1))) {
                throw new FormatException(
                        FailureCode.INVALID_SYMMETRY,
                        "Leader group names another invocation occurrence");
            }
            KernelModel.Witness witness = model.witness(invocation.symbol());
            if (!witness.id().equals(snapshot.witnessByClass().get(witness.eclass()))
                    || snapshot.parentChildren().contains(witness.eclass())) {
                throw new FormatException(
                        FailureCode.INVALID_SYMMETRY,
                        "Leader group occurrence is not the named snapshot's current leader witness");
            }
            List<KernelModel.Embedding> generators = new ArrayList<>();
            Map<String, String> suppliedGenerators = new LinkedHashMap<>();
            for (Wire.Node generatorNode : groupNode.children()) {
                generatorNode.requireShape("generator", 2, 0);
                KernelModel.Embedding generator = model.embedding(generatorNode.scalar(0));
                String proofId = generatorNode.scalar(1);
                KernelVerifier.ProofRecord certificate = kernel.proofRecord(proofId);
                if (certificate.variant() != KernelVerifier.Variant.FULL_INTERFACE_SYMMETRY
                        || !certificate.payload().scalar(0).equals(generator.id())) {
                    throw new FormatException(
                            FailureCode.INVALID_SYMMETRY,
                            "Leader generator lacks independent full-interface SC proof");
                }
                kernel.verify(proofId);
                if (generator.kind() != KernelModel.EmbeddingKind.BIJECTION
                        || !generator.source().equals(witness.context())
                        || !generator.target().equals(witness.context())) {
                    throw new FormatException(
                            FailureCode.INVALID_SYMMETRY,
                            "Leader generator has the wrong interface");
                }
                if (suppliedGenerators.put(generator.id(), proofId) != null) {
                    throw new FormatException(
                            FailureCode.NONCANONICAL_ENCODING,
                            "Leader group repeats a generator");
                }
                generators.add(generator);
            }
            Map<String, String> expectedGenerators = snapshot.symmetriesByClass()
                    .getOrDefault(witness.eclass(), Map.of());
            if (!suppliedGenerators.equals(expectedGenerators)) {
                throw new UncheckableException(
                        FailureCode.INCOMPLETE_ORBIT,
                        "Leader group differs from the named snapshot's exact SC ledger");
            }
            result.put(path, new LeaderGroup(witness, List.copyOf(generators)));
        }
        if (!result.keySet().equals(new LinkedHashSet<>(paths))) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT,
                    "Every leader occurrence needs its complete current group");
        }
        return result;
    }

    private SnapshotGroupLedger snapshotGroupLedger(String snapshotId) {
        Wire.Node snapshot = model.bundle().snapshots().get(snapshotId);
        if (snapshot == null) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Leader-group evidence names an absent snapshot");
        }
        if (snapshot.scalars().size() != 3
                || snapshot.children().size() != 7
                || !snapshot.scalar(0).equals(snapshotId)
                || !snapshot.scalar(2).equals("QUIESCENT")) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE,
                    "Leader-group evidence requires its exact quiescent snapshot");
        }
        Map<String, String> witnessByClass = new LinkedHashMap<>();
        Wire.Node classes = snapshot.child(0).requireTag("classes");
        for (Wire.Node eclass : classes.children()) {
            eclass.requireShape("class", 4, 0);
            if (witnessByClass.put(eclass.scalar(0), eclass.scalar(1)) != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Snapshot repeats an e-class in its leader ledger");
            }
        }
        Set<String> parentChildren = new LinkedHashSet<>();
        Wire.Node parents = snapshot.child(1).requireTag("parents");
        for (Wire.Node parent : parents.children()) {
            parent.requireShape("parent", 5, 0);
            parentChildren.add(parent.scalar(1));
        }
        Map<String, Map<String, String>> symmetriesByClass = new LinkedHashMap<>();
        Wire.Node symmetries = snapshot.child(5).requireTag("symmetries");
        for (Wire.Node symmetry : symmetries.children()) {
            symmetry.requireShape("symmetry", 3, 0);
            Map<String, String> group = symmetriesByClass.computeIfAbsent(
                    symmetry.scalar(0), ignored -> new LinkedHashMap<>());
            if (group.put(symmetry.scalar(1), symmetry.scalar(2)) != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Snapshot repeats an SC generator for one e-class");
            }
        }
        Map<String, Map<String, String>> frozenSymmetries = new LinkedHashMap<>();
        for (Map.Entry<String, Map<String, String>> entry
                : symmetriesByClass.entrySet()) {
            frozenSymmetries.put(entry.getKey(), Map.copyOf(entry.getValue()));
        }
        return new SnapshotGroupLedger(
                Map.copyOf(witnessByClass),
                Set.copyOf(parentChildren),
                Map.copyOf(frozenSymmetries));
    }

    private void forEachClosedEmbedding(
            KernelModel.Context context,
            List<KernelModel.Embedding> generators,
            Consumer<KernelModel.Embedding> consumer) {
        Map<String, String> identityMap = new LinkedHashMap<>();
        for (KernelModel.Slot slot : context.slots()) {
            identityMap.put(slot.name(), slot.name());
        }
        String identityId = TermOps.embeddingId(
                KernelModel.EmbeddingKind.BIJECTION, context, context, identityMap);
        KernelModel.Embedding identity;
        try {
            identity = model.embedding(identityId);
        } catch (FormatException exception) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Leader group omits its identity embedding");
        }
        Set<String> seen = new LinkedHashSet<>();
        Deque<KernelModel.Embedding> queue = new ArrayDeque<>();
        seen.add(identity.id());
        queue.addLast(identity);
        while (!queue.isEmpty()) {
            KernelModel.Embedding current = queue.removeFirst();
            consumer.accept(current);
            for (KernelModel.Embedding generator : generators) {
                KernelModel.Embedding composed;
                try {
                    composed = terms.compose(current, generator);
                } catch (FormatException exception) {
                    throw new UncheckableException(
                            FailureCode.MISSING_EVIDENCE,
                            "Leader closure omits a composed embedding");
                }
                if (!seen.contains(composed.id())) {
                    consumeOrbitMember();
                    seen.add(composed.id());
                    queue.addLast(composed);
                }
            }
        }
    }

    private void forEachLeaderAlternative(
            KernelModel.Term globallyRenamed,
            Map<List<Integer>, LeaderGroup> groups,
            Consumer<KernelModel.Term> consumer) {
        List<Map.Entry<List<Integer>, LeaderGroup>> ordered =
                new ArrayList<>(groups.entrySet());
        if (ordered.size() > limits.maxDepth()) {
            throw new UncheckableException(
                    FailureCode.RESOURCE_LIMIT,
                    "Leader-product recursion exceeds the configured depth");
        }
        List<Set<String>> seenAtDepth = new ArrayList<>();
        for (int index = 0; index < ordered.size(); index++) {
            seenAtDepth.add(new LinkedHashSet<>());
        }
        forEachLeaderAlternative(
                globallyRenamed, ordered, seenAtDepth, 0, consumer);
    }

    private void forEachLeaderAlternative(
            KernelModel.Term alternative,
            List<Map.Entry<List<Integer>, LeaderGroup>> groups,
            List<Set<String>> seenAtDepth,
            int index,
            Consumer<KernelModel.Term> consumer) {
        if (index == groups.size()) {
            consumer.accept(alternative);
            return;
        }
        Map.Entry<List<Integer>, LeaderGroup> entry = groups.get(index);
        KernelModel.Term invocation = terms.atPath(alternative, entry.getKey());
        KernelModel.Embedding invocationEmbedding = model.embedding(
                invocation.attributes().get(0));
        forEachClosedEmbedding(
                entry.getValue().witness().context(),
                entry.getValue().generators(),
                symmetry -> {
                    consumeOrbitMember();
                    KernelModel.Embedding composed;
                    try {
                        composed = terms.compose(symmetry, invocationEmbedding);
                    } catch (FormatException exception) {
                        throw new UncheckableException(
                                FailureCode.MISSING_EVIDENCE,
                                "Orbit omits a leader-action embedding composition");
                    }
                    KernelModel.Term movedInvocation = terms.intern(
                            KernelModel.TermKind.INVOKE,
                            invocation.context(), invocation.sort(), invocation.symbol(),
                            List.of(composed.id()), List.of());
                    KernelModel.Term moved = terms.replaceAtPath(
                            alternative, entry.getKey(), movedInvocation);
                    if (seenAtDepth.get(index).add(moved.id())) {
                        forEachLeaderAlternative(
                                moved, groups, seenAtDepth, index + 1, consumer);
                    }
                });
    }

    private void forEachBinderAlternative(
            KernelModel.Term source,
            Consumer<KernelModel.Term> consumer) {
        if (source.children().size() > limits.maxDepth()) {
            throw new UncheckableException(
                    FailureCode.RESOURCE_LIMIT,
                    "Binder-product arity exceeds the configured depth");
        }
        forEachBinderChildren(source, 0, new ArrayList<>(), children -> {
            KernelModel.Term base = terms.intern(
                    source.kind(), source.context(), source.sort(), source.symbol(),
                    source.attributes(), children);
            if (source.kind() != KernelModel.TermKind.BIND_BLOCK) {
                consumer.accept(base);
                return;
            }
            KernelModel.Schema schema = model.schema(source.symbol());
            KernelModel.Binder binder = model.binder(schema.value());
            terms.forEachClosure(
                    binder.coordinates().size(),
                    binder.generators(),
                    limits.maxOrbitMembers(),
                    permutation -> {
                consumeOrbitMember();
                consumer.accept(terms.permuteBinderBlock(base, permutation));
                    });
        });
    }

    private void forEachBinderChildren(
            KernelModel.Term source,
            int childIndex,
            List<KernelModel.Term> prefix,
            Consumer<List<KernelModel.Term>> consumer) {
        if (childIndex == source.children().size()) {
            consumer.accept(List.copyOf(prefix));
            return;
        }
        KernelModel.Term child = terms.term(source.children().get(childIndex));
        forEachBinderAlternative(child, alternative -> {
            prefix.add(alternative);
            consumeOrbitMember();
            forEachBinderChildren(
                    source, childIndex + 1, prefix, consumer);
            prefix.remove(prefix.size() - 1);
        });
    }

    private static Map<String, List<KernelModel.Slot>> byType(
            KernelModel.Context context) {
        Map<String, List<KernelModel.Slot>> result = new java.util.TreeMap<>();
        for (KernelModel.Slot slot : context.slots()) {
            result.computeIfAbsent(slot.type(), ignored -> new ArrayList<>()).add(slot);
        }
        return result;
    }

    private void forEachPermutation(
            List<KernelModel.Slot> values,
            Consumer<List<KernelModel.Slot>> consumer) {
        if (values.size() > limits.maxDepth()) {
            throw new UncheckableException(
                    FailureCode.RESOURCE_LIMIT,
                    "Permutation recursion exceeds the configured depth");
        }
        permute(values, new boolean[values.size()], new ArrayList<>(), consumer);
    }

    private void permute(
            List<KernelModel.Slot> values,
            boolean[] used,
            List<KernelModel.Slot> prefix,
            Consumer<List<KernelModel.Slot>> consumer) {
        if (prefix.size() == values.size()) {
            consumeOrbitMember();
            consumer.accept(List.copyOf(prefix));
            return;
        }
        for (int index = 0; index < values.size(); index++) {
            if (used[index]) {
                continue;
            }
            used[index] = true;
            prefix.add(values.get(index));
            permute(values, used, prefix, consumer);
            prefix.remove(prefix.size() - 1);
            used[index] = false;
        }
    }

    private void consumeOrbitMember() {
        generated = Math.addExact(generated, 1L);
        kernel.consumeCanonicalOrbitWork();
        if (generated > limits.maxOrbitMembers()) {
            throw new UncheckableException(
                    FailureCode.RESOURCE_LIMIT,
                    "Canonical orbit exceeds configured exhaustive limit");
        }
    }

    private static FormatException malformed(String value) {
        return new FormatException(
                FailureCode.INVALID_RECORD_SHAPE, "Malformed " + value);
    }

    private record LeaderGroup(
            KernelModel.Witness witness,
            List<KernelModel.Embedding> generators) {
    }

    private record SnapshotGroupLedger(
            Map<String, String> witnessByClass,
            Set<String> parentChildren,
            Map<String, Map<String, String>> symmetriesByClass) {
    }

    private final class OrbitMinimum {
        private Optional<OrbitCandidate> minimum = Optional.empty();
        private long count;

        private void consider(
                KernelModel.Term term,
                KernelModel.Embedding witness) {
            count = Math.addExact(count, 1L);
            OrbitCandidate candidate = new OrbitCandidate(term, witness);
            if (minimum.isEmpty()) {
                minimum = Optional.of(candidate);
                return;
            }
            OrbitCandidate current = minimum.orElseThrow();
            int compared = compareCandidates(candidate, current);
            if (kernel.compareCanonicalTerms(term, current.term()) == 0
                    && !term.id().equals(current.term().id())) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Orbit ordering equates unequal terms");
            }
            if (compared < 0) {
                minimum = Optional.of(candidate);
            }
        }

        private boolean isEmpty() {
            return minimum.isEmpty();
        }

        private long count() {
            return count;
        }

        private OrbitCandidate orElseThrow() {
            return minimum.orElseThrow();
        }
    }

    private record OrbitCandidate(
            KernelModel.Term term,
            KernelModel.Embedding witness) {
        private OrbitCandidate {
            java.util.Objects.requireNonNull(term, "term");
            java.util.Objects.requireNonNull(witness, "witness");
        }
    }
}
