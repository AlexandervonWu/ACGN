package org.acgn.cert;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/** Verifies explicit finite Rep trees; no cutoff marker is a valid leaf. */
final class UnfoldProfileVerifier {
    private final KernelModel model;
    private final KernelVerifier kernel;
    private final CheckpointVerifier.Snapshot snapshot;
    private final Limits limits;
    private final TermOps terms;
    private int visited;

    UnfoldProfileVerifier(
            KernelModel model,
            KernelVerifier kernel,
            CheckpointVerifier.Snapshot snapshot,
            Limits limits) {
        this.model = model;
        this.kernel = kernel;
        this.snapshot = snapshot;
        this.limits = limits;
        this.terms = kernel.termOps();
    }

    void verifyAll() {
        for (Wire.Node record : model.bundle().unfoldings().values()) {
            record.requireShape("unfolding", 5, 1);
            if (!record.scalar(4).equals(snapshot.id())) {
                throw new FormatException(
                        FailureCode.STALE_WITNESS_REVISION,
                        "Unfolding uses another graph snapshot");
            }
            KernelModel.Term root = model.term(record.scalar(1));
            int claimedHeight = parseInt(record.scalar(2), "unfolding height");
            KernelModel.Term claimedNormalized = model.term(record.scalar(3));
            RepResult result = verifyRep(record.child(0), new HashSet<>());
            if (!result.invocation().id().equals(root.id())
                    || result.height() != claimedHeight
                    || !result.normalized().id().equals(claimedNormalized.id())) {
                throw new FormatException(
                        FailureCode.INVALID_UNFOLDING,
                        "Unfolding header differs from its explicit Rep tree");
            }
        }
    }

    private RepResult verifyRep(Wire.Node node, Set<String> activeInvocations) {
        consumeNode();
        node.requireShape("rep", 4, 3);
        KernelModel.Term invocation = model.term(node.scalar(0));
        String shapeId = node.scalar(1);
        KernelModel.Term claimedRestored = model.term(node.scalar(2));
        int claimedHeight = parseInt(node.scalar(3), "Rep height");
        if (invocation.kind() != KernelModel.TermKind.INVOKE) {
            throw new FormatException(
                    FailureCode.INVALID_UNFOLDING,
                    "Rep root is not an explicit e-class invocation");
        }
        String recursionKey = invocation.id() + "\u0000" + shapeId;
        if (!activeInvocations.add(recursionKey)) {
            throw new FormatException(
                    FailureCode.INCOMPLETE_UNFOLDING,
                    "Finite Rep tree contains an unresolved recursive cycle");
        }
        try {
            CheckpointVerifier.ShapeState shape = snapshot.shapes().get(shapeId);
            if (shape == null) {
                throw new FormatException(
                        FailureCode.DANGLING_REFERENCE,
                        "Rep selects missing shape " + shapeId);
            }
            String leader = leaderOf(model.witness(invocation.symbol()).eclass());
            if (!shape.owner().equals(leader)) {
                throw new FormatException(
                        FailureCode.INVALID_UNFOLDING,
                        "Rep shape is not owned by the invocation's current leader");
            }
            KernelModel.Term shapeTerm = model.term(shape.termId());
            kernel.verify(shape.replayProofId());

            Wire.Node extensionNode = node.child(0)
                    .requireShape("ambient-extension", 1, 0);
            KernelModel.Embedding extension = model.embedding(extensionNode.scalar(0));
            if (!extension.source().equals(shapeTerm.context())
                    || !extension.target().equals(invocation.context())) {
                throw new FormatException(
                        FailureCode.INVALID_UNFOLDING,
                        "Rep ambient extension has the wrong typed contexts");
            }
            verifyFreshAssignments(node.child(1), extension, shapeTerm, invocation);
            KernelModel.Term restored = terms.act(shapeTerm, extension);
            if (!restored.id().equals(claimedRestored.id())) {
                throw new FormatException(
                        FailureCode.INVALID_UNFOLDING,
                        "Ambient extension does not reconstruct the claimed stored node");
            }

            Wire.Node childrenNode = node.child(2).requireTag("rep-children");
            if (!childrenNode.scalars().isEmpty()) {
                throw malformed("Rep children");
            }
            List<List<Integer>> invocationPaths = terms.termPaths(
                    restored, KernelModel.TermKind.INVOKE);
            if (childrenNode.children().size() != invocationPaths.size()) {
                throw new FormatException(
                        FailureCode.INCOMPLETE_UNFOLDING,
                        "Every restored invocation must have an explicit finite child Rep");
            }

            KernelModel.Term expanded = restored;
            int height = 1;
            List<Replacement> replacements = new ArrayList<>();
            for (int index = 0; index < invocationPaths.size(); index++) {
                Wire.Node childRecord = childrenNode.child(index)
                        .requireTag("rep-child");
                if (childRecord.scalars().size() != 1
                        || childRecord.children().size() != 1) {
                    throw malformed("Rep child");
                }
                List<Integer> path = SourceToKernelVerifier.parsePath(
                        childRecord.scalar(0));
                if (!path.equals(invocationPaths.get(index))) {
                    throw new FormatException(
                            FailureCode.INVALID_UNFOLDING,
                            "Rep children are not in complete invocation-path order");
                }
                KernelModel.Term expectedInvocation = terms.atPath(restored, path);
                RepResult child = verifyRep(childRecord.child(0), activeInvocations);
                if (!child.invocation().id().equals(expectedInvocation.id())) {
                    throw new FormatException(
                            FailureCode.INVALID_UNFOLDING,
                            "Child Rep expands another invocation");
                }
                replacements.add(new Replacement(path, child.normalized()));
                height = Math.max(height, Math.incrementExact(child.height()));
            }
            // Deepest paths first keeps paths stable if a future format permits nesting.
            replacements.sort((left, right) ->
                    SourceToKernelVerifier.comparePaths(right.path(), left.path()));
            for (Replacement replacement : replacements) {
                expanded = terms.replaceAtPath(
                        expanded, replacement.path(), replacement.term());
            }
            KernelModel.Term normalized = terms.normalizeContainers(expanded);
            if (height != claimedHeight) {
                throw new FormatException(
                        FailureCode.INVALID_UNFOLDING,
                        "Rep height is not recursively exact");
            }
            return new RepResult(invocation, normalized, height);
        } finally {
            activeInvocations.remove(recursionKey);
        }
    }

    private void verifyFreshAssignments(
            Wire.Node node,
            KernelModel.Embedding extension,
            KernelModel.Term shape,
            KernelModel.Term invocation) {
        node.requireTag("redundant-assignments");
        if (!node.scalars().isEmpty()) {
            throw malformed("redundant assignments");
        }
        Set<String> retained = terms.support(shape);
        Set<String> expectedRedundant = new LinkedHashSet<>();
        for (KernelModel.Slot slot : shape.context().slots()) {
            if (!retained.contains(slot.name())) {
                expectedRedundant.add(slot.name());
            }
        }
        Set<String> supplied = new LinkedHashSet<>();
        Set<String> assignedTargets = new HashSet<>();
        Set<String> retainedTargets = new HashSet<>();
        for (String slot : retained) {
            retainedTargets.add(extension.apply(slot));
        }
        String prior = null;
        for (Wire.Node assignment : node.children()) {
            assignment.requireShape("fresh", 2, 0);
            if (prior != null && prior.compareTo(assignment.scalar(0)) >= 0) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Fresh assignments are duplicated or unsorted");
            }
            prior = assignment.scalar(0);
            supplied.add(assignment.scalar(0));
            if (!extension.apply(assignment.scalar(0)).equals(assignment.scalar(1))
                    || retainedTargets.contains(assignment.scalar(1))
                    || !assignedTargets.add(assignment.scalar(1))) {
                throw new FormatException(
                        FailureCode.INVALID_UNFOLDING,
                        "Redundant coordinate is not assigned a distinct typed fresh value");
            }
        }
        if (!supplied.equals(expectedRedundant)) {
            throw new UncheckableException(
                    FailureCode.INCOMPLETE_UNFOLDING,
                    "Redundant-coordinate assignments are incomplete");
        }
    }

    private String leaderOf(String eclass) {
        String cursor = eclass;
        Set<String> seen = new HashSet<>();
        while (snapshot.parents().containsKey(cursor)) {
            if (!seen.add(cursor)) {
                throw new FormatException(
                        FailureCode.INVALID_UNION, "Parent cycle during unfolding");
            }
            cursor = snapshot.parents().get(cursor).parent();
        }
        return cursor;
    }

    private void consumeNode() {
        visited++;
        if (visited > limits.maxUnfoldNodes()) {
            throw new UncheckableException(
                    FailureCode.RESOURCE_LIMIT,
                    "Finite unfolding exceeds configured node limit");
        }
    }

    private static int parseInt(String value, String field) {
        long parsed = Bundle.parseUnsignedLong(value, field);
        if (parsed > Integer.MAX_VALUE) {
            throw new FormatException(FailureCode.INTEGER_OVERFLOW, field + " too large");
        }
        return (int) parsed;
    }

    private static FormatException malformed(String value) {
        return new FormatException(
                FailureCode.INVALID_RECORD_SHAPE, "Malformed " + value);
    }

    private record RepResult(
            KernelModel.Term invocation,
            KernelModel.Term normalized,
            int height) {
    }

    private record Replacement(List<Integer> path, KernelModel.Term term) {
    }
}
