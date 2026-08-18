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
import java.util.Set;

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
        payload.requireShape("canonical-orbit", 4, 3);
        KernelModel.Term source = model.term(payload.scalar(0));
        KernelModel.Context targetContext = model.context(payload.scalar(1));
        KernelModel.Term representative = model.term(payload.scalar(2));
        long claimedCount = Bundle.parseUnsignedLong(payload.scalar(3), "orbit size");
        if (!source.id().equals(claimedSource.id())
                || !representative.id().equals(claimedRepresentative.id())) {
            throw new FormatException(
                    FailureCode.ENDPOINT_CLAIM_MISMATCH,
                    "Canonical orbit endpoints differ from the proof claims");
        }

        List<KernelModel.Embedding> freeRenamings = verifyFreeRenamings(
                source.context(), targetContext, payload.child(0));
        Map<List<Integer>, LeaderGroup> leaderGroups = verifyLeaderGroups(
                source, payload.child(1));

        java.util.NavigableMap<Wire.Node, KernelModel.Term> orbit =
                new java.util.TreeMap<>();
        for (KernelModel.Embedding free : freeRenamings) {
            KernelModel.Term globallyRenamed = terms.act(source, free);
            List<KernelModel.Term> leaderAlternatives = expandLeaderGroups(
                    globallyRenamed, leaderGroups);
            for (KernelModel.Term leaderAlternative : leaderAlternatives) {
                for (KernelModel.Term binderAlternative : expandBinders(leaderAlternative)) {
                    KernelModel.Term normalized = terms.normalizeContainers(binderAlternative);
                    orbit.putIfAbsent(terms.structuralNode(normalized), normalized);
                    consumeOrbitMember();
                }
            }
        }
        if (orbit.isEmpty()) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT, "Canonical orbit is empty");
        }
        if (orbit.size() != claimedCount) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT,
                    "Claimed orbit size differs from exhaustive reconstruction");
        }

        Wire.Node membersNode = payload.child(2).requireTag("orbit-members");
        if (!membersNode.scalars().isEmpty()) {
            throw malformed("orbit members");
        }
        List<String> expectedMembers = orbit.values().stream()
                .map(KernelModel.Term::id).toList();
        List<String> claimedMembers = new ArrayList<>();
        for (Wire.Node member : membersNode.children()) {
            claimedMembers.add(member.requireShape("term-ref", 1, 0).scalar(0));
        }
        if (!claimedMembers.equals(expectedMembers)) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT,
                    "Supplied orbit is incomplete, duplicated, or not in complete-key order");
        }
        KernelModel.Term minimum = orbit.firstEntry().getValue();
        if (!minimum.id().equals(representative.id())) {
            throw new FormatException(
                    FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                    "A smaller complete structural key exists in the admissible orbit");
        }
    }

    private List<KernelModel.Embedding> verifyFreeRenamings(
            KernelModel.Context source,
            KernelModel.Context target,
            Wire.Node suppliedNode) {
        suppliedNode.requireTag("free-renamings");
        if (!suppliedNode.scalars().isEmpty()) {
            throw malformed("free renamings");
        }
        List<KernelModel.Embedding> expected = enumerateTypedBijections(source, target);
        expected.sort(Comparator.comparing(KernelModel.Embedding::id));
        List<String> supplied = new ArrayList<>();
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
        List<String> expectedIds = expected.stream()
                .map(KernelModel.Embedding::id).toList();
        if (!supplied.equals(expectedIds)) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT,
                    "Free-slot orbit is not the complete global typed-bijection set");
        }
        return expected;
    }

    private List<KernelModel.Embedding> enumerateTypedBijections(
            KernelModel.Context source,
            KernelModel.Context target) {
        Map<String, List<KernelModel.Slot>> sourceByType = byType(source);
        Map<String, List<KernelModel.Slot>> targetByType = byType(target);
        if (!sourceByType.keySet().equals(targetByType.keySet())) {
            throw new FormatException(
                    FailureCode.NON_BIJECTIVE_RENAMING,
                    "Canonical contexts have different type alphabets");
        }
        List<Map<String, String>> mappings = List.of(new LinkedHashMap<>());
        for (String type : sourceByType.keySet()) {
            List<KernelModel.Slot> left = sourceByType.get(type);
            List<KernelModel.Slot> right = targetByType.get(type);
            if (left.size() != right.size()) {
                throw new FormatException(
                        FailureCode.NON_BIJECTIVE_RENAMING,
                        "Canonical contexts have different typed cardinalities");
            }
            List<List<KernelModel.Slot>> permutations = permutations(right);
            List<Map<String, String>> next = new ArrayList<>();
            for (Map<String, String> mapping : mappings) {
                for (List<KernelModel.Slot> permutation : permutations) {
                    Map<String, String> extended = new LinkedHashMap<>(mapping);
                    for (int index = 0; index < left.size(); index++) {
                        extended.put(left.get(index).name(), permutation.get(index).name());
                    }
                    next.add(extended);
                    consumeOrbitMember();
                }
            }
            mappings = next;
        }
        List<KernelModel.Embedding> result = new ArrayList<>();
        for (Map<String, String> mapping : mappings) {
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
            result.add(embedding);
        }
        return result;
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
            List<KernelModel.Embedding> generators = new ArrayList<>();
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
                generators.add(generator);
            }
            result.put(path, new LeaderGroup(witness, closeEmbeddings(
                    witness.context(), generators)));
        }
        if (!result.keySet().equals(new LinkedHashSet<>(paths))) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_ORBIT,
                    "Every leader occurrence needs its complete current group");
        }
        return result;
    }

    private List<KernelModel.Embedding> closeEmbeddings(
            KernelModel.Context context,
            List<KernelModel.Embedding> generators) {
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
        Map<String, KernelModel.Embedding> seen = new LinkedHashMap<>();
        List<KernelModel.Embedding> queue = new ArrayList<>();
        seen.put(identity.id(), identity);
        queue.add(identity);
        for (int cursor = 0; cursor < queue.size(); cursor++) {
            KernelModel.Embedding current = queue.get(cursor);
            for (KernelModel.Embedding generator : generators) {
                KernelModel.Embedding composed;
                try {
                    composed = terms.compose(current, generator);
                } catch (FormatException exception) {
                    throw new UncheckableException(
                            FailureCode.MISSING_EVIDENCE,
                            "Leader closure omits a composed embedding");
                }
                if (seen.putIfAbsent(composed.id(), composed) == null) {
                    queue.add(composed);
                    consumeOrbitMember();
                }
            }
        }
        return List.copyOf(seen.values());
    }

    private List<KernelModel.Term> expandLeaderGroups(
            KernelModel.Term globallyRenamed,
            Map<List<Integer>, LeaderGroup> groups) {
        List<KernelModel.Term> alternatives = List.of(globallyRenamed);
        for (Map.Entry<List<Integer>, LeaderGroup> entry : groups.entrySet()) {
            List<KernelModel.Term> next = new ArrayList<>();
            for (KernelModel.Term alternative : alternatives) {
                KernelModel.Term invocation = terms.atPath(alternative, entry.getKey());
                KernelModel.Embedding invocationEmbedding = model.embedding(
                        invocation.attributes().get(0));
                for (KernelModel.Embedding symmetry : entry.getValue().elements) {
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
                    next.add(terms.replaceAtPath(
                            alternative, entry.getKey(), movedInvocation));
                    consumeOrbitMember();
                }
            }
            alternatives = deduplicate(next);
        }
        return alternatives;
    }

    private List<KernelModel.Term> expandBinders(KernelModel.Term source) {
        List<List<KernelModel.Term>> childAlternatives = new ArrayList<>();
        for (String child : source.children()) {
            childAlternatives.add(expandBinders(terms.term(child)));
        }
        List<List<KernelModel.Term>> products = cartesian(childAlternatives);
        List<KernelModel.Term> bases = new ArrayList<>();
        for (List<KernelModel.Term> children : products) {
            bases.add(terms.intern(
                    source.kind(), source.context(), source.sort(), source.symbol(),
                    source.attributes(), children));
        }
        if (source.kind() != KernelModel.TermKind.BIND_BLOCK) {
            return deduplicate(bases);
        }
        KernelModel.Schema schema = model.schema(source.symbol());
        KernelModel.Binder binder = model.binder(schema.value());
        List<List<Integer>> group = terms.closure(
                binder.coordinates().size(), binder.generators(), limits.maxOrbitMembers());
        List<KernelModel.Term> result = new ArrayList<>();
        for (KernelModel.Term base : bases) {
            for (List<Integer> permutation : group) {
                result.add(terms.permuteBinderBlock(base, permutation));
                consumeOrbitMember();
            }
        }
        return deduplicate(result);
    }

    private List<List<KernelModel.Term>> cartesian(
            List<List<KernelModel.Term>> alternatives) {
        List<List<KernelModel.Term>> result = List.of(List.of());
        for (List<KernelModel.Term> choices : alternatives) {
            List<List<KernelModel.Term>> next = new ArrayList<>();
            for (List<KernelModel.Term> prefix : result) {
                for (KernelModel.Term choice : choices) {
                    List<KernelModel.Term> extended = new ArrayList<>(prefix);
                    extended.add(choice);
                    next.add(List.copyOf(extended));
                    consumeOrbitMember();
                }
            }
            result = next;
        }
        return result;
    }

    private static List<KernelModel.Term> deduplicate(List<KernelModel.Term> terms) {
        Map<String, KernelModel.Term> result = new LinkedHashMap<>();
        for (KernelModel.Term term : terms) {
            result.putIfAbsent(term.id(), term);
        }
        return List.copyOf(result.values());
    }

    private static Map<String, List<KernelModel.Slot>> byType(
            KernelModel.Context context) {
        Map<String, List<KernelModel.Slot>> result = new java.util.TreeMap<>();
        for (KernelModel.Slot slot : context.slots()) {
            result.computeIfAbsent(slot.type(), ignored -> new ArrayList<>()).add(slot);
        }
        return result;
    }

    private List<List<KernelModel.Slot>> permutations(List<KernelModel.Slot> values) {
        List<List<KernelModel.Slot>> result = new ArrayList<>();
        permute(values, new boolean[values.size()], new ArrayList<>(), result);
        return result;
    }

    private void permute(
            List<KernelModel.Slot> values,
            boolean[] used,
            List<KernelModel.Slot> prefix,
            List<List<KernelModel.Slot>> target) {
        if (prefix.size() == values.size()) {
            target.add(List.copyOf(prefix));
            consumeOrbitMember();
            return;
        }
        for (int index = 0; index < values.size(); index++) {
            if (used[index]) {
                continue;
            }
            used[index] = true;
            prefix.add(values.get(index));
            permute(values, used, prefix, target);
            prefix.remove(prefix.size() - 1);
            used[index] = false;
        }
    }

    private void consumeOrbitMember() {
        generated++;
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
            List<KernelModel.Embedding> elements) {
    }
}
