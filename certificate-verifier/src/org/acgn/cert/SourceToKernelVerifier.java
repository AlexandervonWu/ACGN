package org.acgn.cert;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Dedicated independent replay of d_n^w; it is not a trusted proof rule. */
final class SourceToKernelVerifier {
    private final KernelModel model;
    private final KernelVerifier kernel;
    private final Limits limits;
    private final TermOps terms;

    SourceToKernelVerifier(KernelModel model, KernelVerifier kernel, Limits limits) {
        this.model = model;
        this.kernel = kernel;
        this.limits = limits;
        this.terms = kernel.termOps();
    }

    KernelVerifier.Judgment verify(
            KernelVerifier.ProofRecord proof,
            List<KernelVerifier.Judgment> premises) {
        Wire.Node payload = proof.payload().requireShape("kernel-replay", 7, 5);
        KernelModel.Term source = model.term(payload.scalar(0));
        KernelModel.Context gamma = model.context(payload.scalar(1));
        KernelModel.Term leaderKernel = model.term(payload.scalar(2));
        KernelModel.Context delta = model.context(payload.scalar(3));
        KernelModel.Embedding inclusion = model.embedding(payload.scalar(4));
        KernelModel.Embedding sigma = model.embedding(payload.scalar(5));
        KernelModel.Embedding omega = model.embedding(payload.scalar(6));

        if (!source.id().equals(proof.claimedLeft().id())
                || !source.context().equals(gamma)
                || !terms.support(source).equals(slotNames(gamma))) {
            throw new FormatException(
                    FailureCode.INVALID_KERNEL_REPLAY,
                    "Gamma_0 is not the independently recomputed source support");
        }

        List<String> consumedPremises = new ArrayList<>();
        KernelModel.Term replayed = replayParentPaths(
                source, payload.child(0), consumedPremises);
        KernelModel.Term normalized = replayContainers(
                replayed, payload.child(1), consumedPremises);

        Wire.Node structural = payload.child(2).requireShape("structural-proof", 1, 0);
        consumedPremises.add(structural.scalar(0));

        Wire.Node supportRecord = payload.child(3).requireTag("effective-support");
        if (!supportRecord.children().isEmpty()) {
            throw malformed("effective support");
        }
        List<String> supportInContextOrder = new ArrayList<>();
        Set<String> normalizedSupport = terms.support(normalized);
        for (KernelModel.Slot slot : gamma.slots()) {
            if (normalizedSupport.contains(slot.name())) {
                supportInContextOrder.add(slot.name());
            }
        }
        if (!supportRecord.scalars().equals(supportInContextOrder)
                || !slotNames(delta).equals(new LinkedHashSet<>(supportInContextOrder))) {
            throw new FormatException(
                    FailureCode.INVALID_EFFECTIVE_SUPPORT,
                    "Delta differs from post-find effective support");
        }
        payload.child(4).requireShape("source-construction", 4, 0);
        for (int index = 0; index < delta.slots().size(); index++) {
            KernelModel.Slot deltaSlot = delta.slots().get(index);
            KernelModel.Slot gammaSlot = gamma.slot(deltaSlot.name());
            if (!deltaSlot.type().equals(gammaSlot.type())) {
                throw new FormatException(
                        FailureCode.INVALID_EFFECTIVE_SUPPORT,
                        "Delta is not a typed subcontext of Gamma_0");
            }
        }
        requireLiteralInclusion(inclusion, delta, gamma);
        if (sigma.kind() != KernelModel.EmbeddingKind.BIJECTION
                || !sigma.source().equals(leaderKernel.context())
                || !sigma.target().equals(delta)) {
            throw new FormatException(
                    FailureCode.NON_BIJECTIVE_RENAMING,
                    "Sigma is not a typed renaming C_Delta -> Delta");
        }
        if (!omega.source().equals(leaderKernel.context())
                || !omega.target().equals(gamma)) {
            throw new FormatException(
                    FailureCode.INVALID_OMEGA, "Omega has the wrong endpoints");
        }
        KernelModel.Embedding composed = terms.compose(sigma, inclusion);
        if (!composed.id().equals(omega.id())
                || !composed.images().equals(omega.images())) {
            throw new FormatException(
                    FailureCode.INVALID_OMEGA,
                    "Omega is not exactly iota composed after sigma");
        }

        KernelModel.Term expected = terms.act(leaderKernel, omega);
        if (!expected.id().equals(proof.claimedRight().id())) {
            throw new FormatException(
                    FailureCode.INVALID_KERNEL_REPLAY,
                    "Kernel replay right endpoint is not omega.K");
        }
        KernelVerifier.Judgment structuralProof = kernel.verify(structural.scalar(0));
        requireExact(structuralProof, normalized, expected,
                FailureCode.INVALID_KERNEL_REPLAY);

        if (!consumedPremises.equals(proof.premises())) {
            throw new FormatException(
                    FailureCode.INVALID_KERNEL_REPLAY,
                    "Kernel replay premise list is incomplete, duplicated, or reordered");
        }
        if (premises.size() != consumedPremises.size()) {
            throw new FormatException(
                    FailureCode.INVALID_KERNEL_REPLAY,
                    "Kernel replay did not consume every premise");
        }
        return new KernelVerifier.Judgment(
                gamma, source.sort(), source, expected);
    }

    private KernelModel.Term replayParentPaths(
            KernelModel.Term source,
            Wire.Node pathsNode,
            List<String> consumedPremises) {
        pathsNode.requireTag("parent-paths");
        if (!pathsNode.scalars().isEmpty()) {
            throw malformed("parent paths");
        }
        List<List<Integer>> expectedPaths = terms.termPaths(
                source, KernelModel.TermKind.INVOKE);
        Map<List<Integer>, Wire.Node> records = new LinkedHashMap<>();
        List<Integer> prior = null;
        for (Wire.Node pathRecord : pathsNode.children()) {
            pathRecord.requireTag("parent-path");
            if (pathRecord.scalars().size() != 4) {
                throw malformed("parent path");
            }
            List<Integer> path = parsePath(pathRecord.scalar(0));
            if (prior != null && comparePaths(prior, path) >= 0) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Parent paths are duplicated or unsorted");
            }
            prior = path;
            records.put(path, pathRecord);
        }
        Set<List<Integer>> expected = new LinkedHashSet<>(expectedPaths);
        if (!records.keySet().equals(expected)) {
            if (expected.containsAll(records.keySet())) {
                throw new UncheckableException(
                        FailureCode.INCOMPLETE_PARENT_PATH,
                        "Every invocation occurrence needs a complete current parent path");
            }
            throw new FormatException(
                    FailureCode.INCOMPLETE_PARENT_PATH,
                    "A supplied parent path names no invocation occurrence");
        }

        KernelModel.Term result = source;
        // Invocation terms are leaves; reverse order also makes nested formats robust.
        List<List<Integer>> reversed = new ArrayList<>(expectedPaths);
        java.util.Collections.reverse(reversed);
        for (List<Integer> path : reversed) {
            Wire.Node record = records.get(path);
            KernelModel.Term original = terms.atPath(source, path);
            if (!original.symbol().equals(record.scalar(1))
                    || original.attributes().size() != 1) {
                throw new FormatException(
                        FailureCode.INCOMPLETE_PARENT_PATH,
                        "Parent path starts at another invocation");
            }
            KernelModel.Witness currentWitness = model.witness(record.scalar(1));
            KernelModel.Embedding currentEmbedding = model.embedding(
                    original.attributes().get(0));
            for (Wire.Node edgeRef : record.children()) {
                String proofId = edgeRef.requireShape("edge-ref", 1, 0).scalar(0);
                KernelVerifier.ProofRecord edgeRecord = kernel.proofRecord(proofId);
                if (edgeRecord.variant() != KernelVerifier.Variant.PARENT_EDGE) {
                    throw new FormatException(
                            FailureCode.INCOMPLETE_PARENT_PATH,
                            "Parent path contains a non-parent-edge proof");
                }
                KernelVerifier.Judgment edge = kernel.verify(proofId);
                KernelModel.Term childEndpoint = edge.left();
                KernelModel.Term parentEndpoint = edge.right();
                if (childEndpoint.kind() != KernelModel.TermKind.INVOKE
                        || parentEndpoint.kind() != KernelModel.TermKind.INVOKE
                        || !childEndpoint.symbol().equals(currentWitness.id())
                        || parentEndpoint.attributes().size() != 1) {
                    throw new FormatException(
                            FailureCode.INCOMPLETE_PARENT_PATH,
                            "Parent path edge does not continue from the current witness");
                }
                KernelModel.Embedding parentInChild = model.embedding(
                        parentEndpoint.attributes().get(0));
                currentEmbedding = terms.compose(parentInChild, currentEmbedding);
                currentWitness = model.witness(parentEndpoint.symbol());
                consumedPremises.add(proofId);
            }
            if (!currentWitness.id().equals(record.scalar(2))) {
                throw new FormatException(
                        FailureCode.INCOMPLETE_PARENT_PATH,
                        "Parent path does not end at its claimed leader witness");
            }
            KernelModel.Term finalInvocation = model.term(record.scalar(3));
            if (finalInvocation.kind() != KernelModel.TermKind.INVOKE
                    || !finalInvocation.symbol().equals(currentWitness.id())
                    || finalInvocation.attributes().size() != 1
                    || !finalInvocation.attributes().get(0).equals(currentEmbedding.id())) {
                throw new FormatException(
                        FailureCode.INCOMPLETE_PARENT_PATH,
                        "Composed parent path differs from final invocation");
            }
            result = terms.replaceAtPath(result, path, finalInvocation);
        }
        return result;
    }

    private KernelModel.Term replayContainers(
            KernelModel.Term replayed,
            Wire.Node normalizationNode,
            List<String> consumedPremises) {
        normalizationNode.requireTag("port-normalizations");
        if (!normalizationNode.scalars().isEmpty()) {
            throw malformed("port normalizations");
        }
        List<List<Integer>> paths = new ArrayList<>();
        paths.addAll(terms.termPaths(replayed, KernelModel.TermKind.SEQ));
        paths.addAll(terms.termPaths(replayed, KernelModel.TermKind.BAG));
        paths.addAll(terms.termPaths(replayed, KernelModel.TermKind.SET));
        paths.sort(SourceToKernelVerifier::comparePaths);
        if (normalizationNode.children().size() != paths.size()) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Every Seq/Bag/Set occurrence needs normalization evidence");
        }
        for (int index = 0; index < paths.size(); index++) {
            Wire.Node record = normalizationNode.child(index)
                    .requireShape("port-normalization", 2, 0);
            List<Integer> path = parsePath(record.scalar(0));
            if (!path.equals(paths.get(index))) {
                throw new FormatException(
                        FailureCode.INVALID_CONTAINER_NORMALIZATION,
                        "Container normalization path is missing or reordered");
            }
            String proofId = record.scalar(1);
            KernelVerifier.Judgment judgment = kernel.verify(proofId);
            KernelModel.Term sourceContainer = terms.atPath(replayed, path);
            KernelModel.Term normalizedContainer = terms.normalizeContainers(sourceContainer);
            requireExact(judgment, sourceContainer, normalizedContainer,
                    FailureCode.INVALID_CONTAINER_NORMALIZATION);
            consumedPremises.add(proofId);
        }
        return terms.normalizeContainers(replayed);
    }

    private static void requireLiteralInclusion(
            KernelModel.Embedding inclusion,
            KernelModel.Context source,
            KernelModel.Context target) {
        if (!inclusion.source().equals(source)
                || !inclusion.target().equals(target)) {
            throw new FormatException(
                    FailureCode.INVALID_EFFECTIVE_SUPPORT,
                    "Iota is not Delta -> Gamma_0");
        }
        for (KernelModel.Slot slot : source.slots()) {
            if (!inclusion.apply(slot.name()).equals(slot.name())) {
                throw new FormatException(
                        FailureCode.INVALID_EFFECTIVE_SUPPORT,
                        "Iota is not the literal inclusion");
            }
        }
    }

    private static Set<String> slotNames(KernelModel.Context context) {
        Set<String> result = new LinkedHashSet<>();
        for (KernelModel.Slot slot : context.slots()) {
            result.add(slot.name());
        }
        return result;
    }

    static List<Integer> parsePath(String text) {
        if (text.isEmpty()) {
            return List.of();
        }
        String[] parts = text.split("/", -1);
        List<Integer> result = new ArrayList<>(parts.length);
        for (String part : parts) {
            if (part.isEmpty()) {
                throw malformed("term path");
            }
            long value = Bundle.parseUnsignedLong(part, "term path component");
            if (value > Integer.MAX_VALUE) {
                throw new FormatException(
                        FailureCode.INTEGER_OVERFLOW, "Term path component is too large");
            }
            result.add((int) value);
        }
        return List.copyOf(result);
    }

    static String encodePath(List<Integer> path) {
        return String.join("/", path.stream().map(Object::toString).toList());
    }

    static int comparePaths(List<Integer> left, List<Integer> right) {
        int shared = Math.min(left.size(), right.size());
        for (int index = 0; index < shared; index++) {
            int compared = Integer.compare(left.get(index), right.get(index));
            if (compared != 0) {
                return compared;
            }
        }
        return Integer.compare(left.size(), right.size());
    }

    private static void requireExact(
            KernelVerifier.Judgment proof,
            KernelModel.Term left,
            KernelModel.Term right,
            FailureCode code) {
        if (!proof.left().id().equals(left.id())
                || !proof.right().id().equals(right.id())) {
            throw new FormatException(code, "Dedicated replay proof has wrong endpoints");
        }
    }

    private static FormatException malformed(String record) {
        return new FormatException(
                FailureCode.INVALID_RECORD_SHAPE, "Malformed " + record);
    }
}
