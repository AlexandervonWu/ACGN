package org.acgn.cert;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Independent graph-state, transition, EC/PC/SC, and quiescence verifier. */
final class CheckpointVerifier {
    enum Status {
        QUIESCENT,
        DIRTY
    }

    enum EventKind {
        INSERT_FRESH,
        INSERT_COLLISION,
        UNION,
        ADD_SYMMETRY,
        RESTRICT_INTERFACE,
        REBUILD_RECORD,
        PATH_COMPRESS,
        REBUILD_COMPLETE
    }

    record ClassState(String id, String witnessId, String contextId, String type) {
    }

    record ParentState(
            String edgeId,
            String child,
            String parent,
            String embeddingId,
            String proofId) {
    }

    record ShapeState(String id, String owner, String termId, String replayProofId) {
    }

    record SymmetryState(String eclass, String embeddingId, String proofId) {
        String key() {
            return eclass + "\u0000" + embeddingId;
        }
    }

    record Snapshot(
            String id,
            long revision,
            Status status,
            Map<String, ClassState> classes,
            Map<String, ParentState> parents,
            Map<String, ShapeState> shapes,
            Map<String, String> hashOwners,
            Set<String> parentUses,
            Map<String, SymmetryState> symmetries,
            Set<String> dirty) {
    }

    private final KernelModel model;
    private final KernelVerifier kernel;
    private final Map<String, Snapshot> snapshots;

    CheckpointVerifier(KernelModel model, KernelVerifier kernel) {
        this.model = Objects.requireNonNull(model, "model");
        this.kernel = Objects.requireNonNull(kernel, "kernel");
        snapshots = parseSnapshots();
    }

    Map<String, Snapshot> snapshots() {
        return snapshots;
    }

    Snapshot verifyTransitions() {
        Snapshot prior = null;
        for (Wire.Node event : model.bundle().events()) {
            if (event.scalars().size() != 4 || event.children().size() != 1) {
                throw malformed("event");
            }
            EventKind kind = enumValue(EventKind.class, event.scalar(1));
            Snapshot before = snapshot(event.scalar(2));
            Snapshot after = snapshot(event.scalar(3));
            if (prior != null && !prior.id().equals(before.id())) {
                throw new FormatException(
                        FailureCode.SNAPSHOT_DISCONTINUITY,
                        "Event pre-state is not the prior event post-state");
            }
            verifyEvent(kind, before, after, event.child(0));
            prior = after;
        }
        if (prior == null) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Checkpoint profile requires ordered transition events");
        }
        return prior;
    }

    Snapshot verifyPublication(Snapshot transitionFinal) {
        Wire.Node publication = model.bundle().publication()
                .requireShape("publication", 5, 5);
        Snapshot snapshot = snapshot(publication.scalar(0));
        long revision = Bundle.parseUnsignedLong(
                publication.scalar(1), "publication revision");
        if (!snapshot.id().equals(transitionFinal.id())) {
            throw new FormatException(
                    FailureCode.SNAPSHOT_DISCONTINUITY,
                    "Publication does not use the final transition snapshot");
        }
        if (snapshot.status() != Status.QUIESCENT || !snapshot.dirty().isEmpty()) {
            throw new FormatException(
                    FailureCode.DIRTY_PUBLICATION,
                    "Semantic artifact was published while dirty");
        }
        if (snapshot.revision() != revision) {
            throw new FormatException(
                    FailureCode.STALE_WITNESS_REVISION,
                    "Published witness family has a stale revision");
        }
        if (!publication.scalar(4).equals(model.bundle().theoryDigest())) {
            throw new FormatException(
                    FailureCode.DIGEST_MISMATCH,
                    "Publication uses another theory digest");
        }
        model.term(publication.scalar(2));
        model.term(publication.scalar(3));
        verifyEc(publication.child(0), snapshot);
        verifyPc(publication.child(1), snapshot);
        verifySc(publication.child(2), snapshot);
        verifyReferences(publication.child(3), "canonical-refs",
                model.bundle().canonicalRecords().keySet(), "canonical-ref");
        verifyReferences(publication.child(4), "unfolding-refs",
                model.bundle().unfoldings().keySet(), "unfolding-ref");
        return snapshot;
    }

    private Map<String, Snapshot> parseSnapshots() {
        Map<String, Snapshot> result = new LinkedHashMap<>();
        for (Wire.Node node : model.bundle().snapshots().values()) {
            if (node.scalars().size() != 3 || node.children().size() != 7) {
                throw malformed("snapshot");
            }
            Map<String, ClassState> classes = parseClasses(node.child(0));
            Map<String, ParentState> parents = parseParents(node.child(1));
            Map<String, ShapeState> shapes = parseShapes(node.child(2));
            Map<String, String> hashOwners = parseHashOwners(node.child(3));
            Set<String> parentUses = parsePairSet(
                    node.child(4), "parent-uses", "parent-use");
            Map<String, SymmetryState> symmetries = parseSymmetries(node.child(5));
            Set<String> dirty = parseScalarSet(node.child(6), "dirty", "dirty-shape");
            Snapshot snapshot = new Snapshot(
                    node.scalar(0),
                    Bundle.parseUnsignedLong(node.scalar(1), "snapshot revision"),
                    enumValue(Status.class, node.scalar(2)),
                    classes, parents, shapes, hashOwners, parentUses, symmetries, dirty);
            validateSnapshot(snapshot);
            result.put(snapshot.id(), snapshot);
        }
        return Collections.unmodifiableMap(result);
    }

    private Map<String, ClassState> parseClasses(Wire.Node section) {
        requireSection(section, "classes");
        Map<String, ClassState> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node node : section.children()) {
            node.requireShape("class", 4, 0);
            prior = increasing(prior, node.scalar(0), "class");
            result.put(node.scalar(0), new ClassState(
                    node.scalar(0), node.scalar(1), node.scalar(2), node.scalar(3)));
        }
        return Collections.unmodifiableMap(result);
    }

    private Map<String, ParentState> parseParents(Wire.Node section) {
        requireSection(section, "parents");
        Map<String, ParentState> byChild = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node node : section.children()) {
            node.requireShape("parent", 5, 0);
            prior = increasing(prior, node.scalar(0), "parent edge");
            ParentState state = new ParentState(
                    node.scalar(0), node.scalar(1), node.scalar(2),
                    node.scalar(3), node.scalar(4));
            if (byChild.put(state.child(), state) != null) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "An e-class has two current parent assignments");
            }
        }
        return Collections.unmodifiableMap(byChild);
    }

    private Map<String, ShapeState> parseShapes(Wire.Node section) {
        requireSection(section, "shapes");
        Map<String, ShapeState> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node node : section.children()) {
            node.requireShape("shape", 4, 0);
            prior = increasing(prior, node.scalar(0), "shape");
            result.put(node.scalar(0), new ShapeState(
                    node.scalar(0), node.scalar(1), node.scalar(2), node.scalar(3)));
        }
        return Collections.unmodifiableMap(result);
    }

    private Map<String, String> parseHashOwners(Wire.Node section) {
        requireSection(section, "hash-cons");
        Map<String, String> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node node : section.children()) {
            node.requireShape("hash-owner", 2, 0);
            prior = increasing(prior, node.scalar(0), "hash owner");
            result.put(node.scalar(0), node.scalar(1));
        }
        return Collections.unmodifiableMap(result);
    }

    private Map<String, SymmetryState> parseSymmetries(Wire.Node section) {
        requireSection(section, "symmetries");
        Map<String, SymmetryState> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node node : section.children()) {
            node.requireShape("symmetry", 3, 0);
            SymmetryState state = new SymmetryState(
                    node.scalar(0), node.scalar(1), node.scalar(2));
            prior = increasing(prior, state.key(), "symmetry");
            result.put(state.key(), state);
        }
        return Collections.unmodifiableMap(result);
    }

    private Set<String> parsePairSet(
            Wire.Node section,
            String sectionTag,
            String recordTag) {
        requireSection(section, sectionTag);
        Set<String> result = new LinkedHashSet<>();
        String prior = null;
        for (Wire.Node node : section.children()) {
            node.requireShape(recordTag, 2, 0);
            String key = node.scalar(0) + "\u0000" + node.scalar(1);
            prior = increasing(prior, key, recordTag);
            result.add(key);
        }
        return Collections.unmodifiableSet(result);
    }

    private Set<String> parseScalarSet(
            Wire.Node section,
            String sectionTag,
            String recordTag) {
        requireSection(section, sectionTag);
        Set<String> result = new LinkedHashSet<>();
        String prior = null;
        for (Wire.Node node : section.children()) {
            node.requireShape(recordTag, 1, 0);
            prior = increasing(prior, node.scalar(0), recordTag);
            result.add(node.scalar(0));
        }
        return Collections.unmodifiableSet(result);
    }

    private void validateSnapshot(Snapshot snapshot) {
        for (ClassState eclass : snapshot.classes().values()) {
            KernelModel.Witness witness = model.witness(eclass.witnessId());
            if (!witness.eclass().equals(eclass.id())
                    || !witness.context().id().equals(eclass.contextId())
                    || !witness.type().equals(eclass.type())) {
                throw new FormatException(
                        FailureCode.STALE_WITNESS_REVISION,
                        "Class state and versioned witness disagree");
            }
            model.context(eclass.contextId());
        }
        for (ParentState parent : snapshot.parents().values()) {
            ClassState child = requireClass(snapshot, parent.child());
            ClassState target = requireClass(snapshot, parent.parent());
            KernelModel.Embedding embedding = model.embedding(parent.embeddingId());
            if (!embedding.source().id().equals(target.contextId())
                    || !embedding.target().id().equals(child.contextId())) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "Parent assignment has the wrong typed embedding");
            }
            KernelVerifier.ProofRecord proof = kernel.proofRecord(parent.proofId());
            if (proof.variant() != KernelVerifier.Variant.PARENT_EDGE) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "Parent assignment lacks a parent-edge proof");
            }
            kernel.verify(parent.proofId());
        }
        rejectParentCycles(snapshot.parents());

        for (ShapeState shape : snapshot.shapes().values()) {
            requireClass(snapshot, shape.owner());
            KernelModel.Term term = model.term(shape.termId());
            KernelVerifier.ProofRecord replay = kernel.proofRecord(shape.replayProofId());
            if (replay.variant() != KernelVerifier.Variant.KERNEL_REPLAY
                    && replay.variant() != KernelVerifier.Variant.REBUILD_CONGRUENCE) {
                throw new FormatException(
                        FailureCode.INVALID_KERNEL_REPLAY,
                        "Stored shape lacks source-to-kernel/rebuild evidence");
            }
            kernel.verify(shape.replayProofId());
            if (!term.sort().kind().equals(KernelModel.SortKind.TERM)) {
                throw new FormatException(
                        FailureCode.ILL_TYPED_TERM, "Stored shape is not a term");
            }
        }
        validateHashes(snapshot);
        validateParentUses(snapshot);
        for (SymmetryState symmetry : snapshot.symmetries().values()) {
            ClassState eclass = requireClass(snapshot, symmetry.eclass());
            KernelModel.Embedding embedding = model.embedding(symmetry.embeddingId());
            KernelVerifier.ProofRecord proof = kernel.proofRecord(symmetry.proofId());
            if (!embedding.source().id().equals(eclass.contextId())
                    || !embedding.target().id().equals(eclass.contextId())
                    || embedding.kind() != KernelModel.EmbeddingKind.BIJECTION
                    || proof.variant() != KernelVerifier.Variant.FULL_INTERFACE_SYMMETRY) {
                throw new FormatException(
                        FailureCode.INVALID_SYMMETRY,
                        "SC entry is not a certified full-interface symmetry");
            }
            kernel.verify(symmetry.proofId());
        }
        if (snapshot.status() == Status.QUIESCENT && !snapshot.dirty().isEmpty()) {
            throw new FormatException(
                    FailureCode.DIRTY_PUBLICATION,
                    "A quiescent snapshot retains dirty parent records");
        }
        for (String dirty : snapshot.dirty()) {
            if (!snapshot.shapes().containsKey(dirty)) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Dirty queue references a missing shape");
            }
        }
    }

    private void validateHashes(Snapshot snapshot) {
        Map<String, String> expected = new LinkedHashMap<>();
        for (ShapeState shape : snapshot.shapes().values()) {
            if (!isLeader(snapshot, shape.owner())) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "A nonleader retains a stored shape");
            }
            String key = termsKey(model.term(shape.termId()));
            String prior = expected.putIfAbsent(key, shape.owner());
            if (prior != null && !prior.equals(shape.owner())) {
                throw new FormatException(
                        FailureCode.INVALID_COLLISION,
                        "Two leaders own one complete structural key");
            }
        }
        if (snapshot.status() == Status.QUIESCENT
                && !snapshot.hashOwners().equals(expected)) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Quiescent hash-cons is not exact");
        }
        for (Map.Entry<String, String> entry : snapshot.hashOwners().entrySet()) {
            if (!snapshot.classes().containsKey(entry.getValue())) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Hash-cons names a missing owner");
            }
        }
    }

    private void validateParentUses(Snapshot snapshot) {
        Set<String> expected = new LinkedHashSet<>();
        for (ShapeState shape : snapshot.shapes().values()) {
            KernelModel.Term term = model.term(shape.termId());
            for (List<Integer> path : kernel.termOps().termPaths(
                    term, KernelModel.TermKind.INVOKE)) {
                KernelModel.Term invocation = kernel.termOps().atPath(term, path);
                KernelModel.Witness witness = model.witness(invocation.symbol());
                expected.add(witness.eclass() + "\u0000" + shape.id());
            }
        }
        if (!snapshot.parentUses().equals(expected)) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Reverse parent-use index is not exact");
        }
    }

    private void verifyEvent(
            EventKind kind,
            Snapshot before,
            Snapshot after,
            Wire.Node payload) {
        Difference difference = new Difference(before, after);
        if (kind != EventKind.RESTRICT_INTERFACE
                && !difference.changedClasses.isEmpty()) {
            throw new FormatException(
                    FailureCode.IMPLICIT_INTERFACE_CONTRACTION,
                    "Only an explicit restriction event may change an e-class interface");
        }
        switch (kind) {
            case INSERT_FRESH -> verifyFreshInsertion(before, after, payload, difference);
            case INSERT_COLLISION -> verifyCollisionInsertion(
                    before, after, payload, difference);
            case UNION -> verifyUnion(before, after, payload, difference, true);
            case ADD_SYMMETRY -> verifyAddSymmetry(before, after, payload, difference);
            case RESTRICT_INTERFACE -> verifyRestriction(
                    before, after, payload, difference);
            case REBUILD_RECORD -> verifyRebuildRecord(
                    before, after, payload, difference);
            case PATH_COMPRESS -> verifyPathCompression(
                    before, after, payload, difference);
            case REBUILD_COMPLETE -> verifyRebuildComplete(
                    before, after, payload, difference);
        }
    }

    private void verifyFreshInsertion(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireShape("insert-fresh", 5, 0);
        if (!difference.addedClasses.equals(Set.of(payload.scalar(0)))
                || !difference.addedShapes.equals(Set.of(payload.scalar(1)))
                || !difference.removedClasses.isEmpty()
                || !difference.removedShapes.isEmpty()
                || !difference.changedShapes.isEmpty()
                || !difference.addedParents.isEmpty()
                || !difference.changedParents.isEmpty()
                || !difference.removedParents.isEmpty()
                || !difference.changedSymmetries.isEmpty()
                || after.revision() != before.revision() + 1
                || after.status() != before.status()) {
            throw unexplained("fresh insertion");
        }
        requireVariant(payload.scalar(2), KernelVerifier.Variant.KERNEL_REPLAY);
        requireVariant(payload.scalar(3), KernelVerifier.Variant.CANONICAL_ORBIT);
        requireVariant(payload.scalar(4), KernelVerifier.Variant.FRESH_WITNESS);
        kernel.verify(payload.scalar(2));
        kernel.verify(payload.scalar(3));
        kernel.verify(payload.scalar(4));
    }

    private void verifyCollisionInsertion(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireShape("insert-collision", 5, 0);
        if (!difference.addedClasses.equals(Set.of(payload.scalar(0)))
                || difference.addedParents.size() != 1
                || after.revision() != before.revision() + 1
                || after.status() != Status.DIRTY) {
            throw unexplained("collision insertion");
        }
        requireVariant(payload.scalar(2), KernelVerifier.Variant.KERNEL_REPLAY);
        requireVariant(payload.scalar(3), KernelVerifier.Variant.COLLISION);
        requireVariant(payload.scalar(4), KernelVerifier.Variant.PARENT_EDGE);
        kernel.verify(payload.scalar(2));
        kernel.verify(payload.scalar(3));
        kernel.verify(payload.scalar(4));
        requireUnionShapeTransfer(before, after, difference);
    }

    private void verifyUnion(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference,
            boolean publicRevision) {
        payload.requireShape("union", 1, 0);
        requireVariant(payload.scalar(0), KernelVerifier.Variant.PARENT_EDGE);
        kernel.verify(payload.scalar(0));
        if (difference.addedParents.size() != 1
                || !difference.addedClasses.isEmpty()
                || !difference.removedClasses.isEmpty()
                || after.status() != Status.DIRTY
                || after.revision() != before.revision() + (publicRevision ? 1 : 0)) {
            throw unexplained("union");
        }
        requireUnionShapeTransfer(before, after, difference);
    }

    private void requireUnionShapeTransfer(
            Snapshot before,
            Snapshot after,
            Difference difference) {
        String child = difference.addedParents.iterator().next();
        ParentState edge = after.parents().get(child);
        for (ShapeState shape : before.shapes().values()) {
            if (!shape.owner().equals(child)) {
                continue;
            }
            ShapeState moved = after.shapes().get(shape.id());
            if (moved != null && !moved.owner().equals(edge.parent())) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "Union did not transfer a child-owned shape to the parent");
            }
        }
    }

    private void verifyAddSymmetry(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireShape("add-symmetry", 3, 0);
        String key = payload.scalar(0) + "\u0000" + payload.scalar(1);
        if (!difference.changedSymmetries.equals(Set.of(key))
                || after.revision() != before.revision() + 1
                || after.status() != Status.DIRTY
                || difference.hasCoreMutation()) {
            throw unexplained("symmetry addition");
        }
        requireVariant(payload.scalar(2), KernelVerifier.Variant.FULL_INTERFACE_SYMMETRY);
        kernel.verify(payload.scalar(2));
    }

    private void verifyRestriction(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireShape("restrict-interface", 4, 1);
        String eclass = payload.scalar(0);
        ClassState oldState = requireClass(before, eclass);
        ClassState newState = requireClass(after, eclass);
        KernelModel.Context oldContext = model.context(payload.scalar(1));
        KernelModel.Context newContext = model.context(payload.scalar(2));
        if (!oldState.contextId().equals(oldContext.id())
                || !newState.contextId().equals(newContext.id())
                || newContext.slots().size() >= oldContext.slots().size()
                || !isTypedSubcontext(newContext, oldContext)
                || !difference.changedClasses.equals(Set.of(eclass))
                || after.revision() != before.revision() + 1
                || after.status() != Status.DIRTY
                || !payload.child(0).tag().equals("transported-evidence")) {
            throw new FormatException(
                    FailureCode.INVALID_RESTRICTION,
                    "Interface restriction is not an explicit strict typed contraction");
        }
        requireVariant(payload.scalar(3), KernelVerifier.Variant.RESTRICT);
        KernelVerifier.ProofRecord restriction = kernel.proofRecord(payload.scalar(3));
        Wire.Node restrictionPayload = restriction.payload().requireShape(
                "restriction", 3, 0);
        if (!restrictionPayload.scalar(0).equals(oldState.witnessId())
                || !restrictionPayload.scalar(1).equals(newState.witnessId())) {
            throw new FormatException(
                    FailureCode.INVALID_RESTRICTION,
                    "Restriction proof names stale or unrelated witness versions");
        }
        KernelModel.Embedding inclusion = model.embedding(
                restrictionPayload.scalar(2));
        if (!inclusion.source().equals(newContext)
                || !inclusion.target().equals(oldContext)) {
            throw new FormatException(
                    FailureCode.INVALID_RESTRICTION,
                    "Restriction proof carries another interface inclusion");
        }
        kernel.verify(payload.scalar(3));
        Set<String> transported = new LinkedHashSet<>(payload.child(0).scalars());
        Set<String> affected = new LinkedHashSet<>();
        affected.addAll(difference.changedParents);
        affected.addAll(difference.changedShapes);
        affected.addAll(difference.changedSymmetries);
        if (!transported.equals(affected)) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Restriction does not identify every transported EC/PC/SC member");
        }
    }

    private void verifyRebuildRecord(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireShape("rebuild-record", 3, 0);
        if (after.revision() != before.revision()
                || difference.addedShapes.size() + difference.changedShapes.size() > 1
                || difference.removedShapes.size() > 1
                || difference.addedParents.size() > 1
                || !difference.addedClasses.isEmpty()
                || !difference.removedClasses.isEmpty()) {
            throw unexplained("rebuild record");
        }
        requireVariant(payload.scalar(1), KernelVerifier.Variant.REBUILD_CONGRUENCE);
        kernel.verify(payload.scalar(1));
        if (!payload.scalar(2).isEmpty()) {
            requireVariant(payload.scalar(2), KernelVerifier.Variant.COLLISION);
            kernel.verify(payload.scalar(2));
        } else if (!difference.addedParents.isEmpty()) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Rebuild collision union lacks both replay certificates");
        }
    }

    private void verifyPathCompression(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireTag("path-compress");
        if (payload.scalars().size() != 2
                || !difference.changedParents.equals(Set.of(payload.scalar(0)))
                || after.revision() != before.revision()
                || before.status() != after.status()
                || difference.hasNonParentMutation()) {
            throw unexplained("path compression");
        }
        requireVariant(payload.scalar(1), KernelVerifier.Variant.PARENT_EDGE);
        KernelVerifier.Judgment compressed = kernel.verify(payload.scalar(1));
        if (payload.children().isEmpty()) {
            throw new UncheckableException(
                    FailureCode.INVALID_PATH_COMPRESSION,
                    "Path compression omits original edge IDs");
        }
        String child = payload.scalar(0);
        String cursor = child;
        for (Wire.Node edgeRef : payload.children()) {
            String edgeId = edgeRef.requireShape("original-edge", 1, 0).scalar(0);
            ParentState edge = before.parents().get(cursor);
            if (edge == null || !edge.edgeId().equals(edgeId)) {
                throw new FormatException(
                        FailureCode.INVALID_PATH_COMPRESSION,
                        "Compression path does not use the original current edges");
            }
            cursor = edge.parent();
        }
        ParentState replacement = after.parents().get(child);
        if (!replacement.parent().equals(cursor)
                || !replacement.proofId().equals(payload.scalar(1))) {
            throw new FormatException(
                    FailureCode.INVALID_PATH_COMPRESSION,
                    "Compressed map/proof differs from composed original path");
        }
    }

    private void verifyRebuildComplete(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireShape("rebuild-complete", 1, 0);
        boolean changed = Bundle.parseBoolean(payload.scalar(0), "rebuild changed flag");
        if (after.status() != Status.QUIESCENT || !after.dirty().isEmpty()
                || !difference.sameSemanticStateExceptIndexesAndDirty()
                || after.revision() != before.revision() + (changed ? 1 : 0)) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Rebuild completion is not quiescent/exact");
        }
    }

    private void verifyEc(Wire.Node node, Snapshot snapshot) {
        requireSection(node, "ec-evidence");
        Map<String, String> supplied = new LinkedHashMap<>();
        for (Wire.Node child : node.children()) {
            child.requireShape("ec", 2, 0);
            supplied.put(child.scalar(0), child.scalar(1));
        }
        Map<String, String> expected = new LinkedHashMap<>();
        for (ClassState eclass : snapshot.classes().values()) {
            expected.put(eclass.id(), eclass.witnessId());
        }
        if (!supplied.equals(expected)) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE, "EC family is incomplete or stale");
        }
    }

    private void verifyPc(Wire.Node node, Snapshot snapshot) {
        requireSection(node, "pc-evidence");
        Map<String, String> supplied = new LinkedHashMap<>();
        for (Wire.Node child : node.children()) {
            child.requireShape("pc", 2, 0);
            supplied.put(child.scalar(0), child.scalar(1));
        }
        Map<String, String> expected = new LinkedHashMap<>();
        for (ParentState parent : snapshot.parents().values()) {
            expected.put(parent.edgeId(), parent.proofId());
        }
        if (!supplied.equals(expected)) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE, "PC family is incomplete or stale");
        }
    }

    private void verifySc(Wire.Node node, Snapshot snapshot) {
        requireSection(node, "sc-evidence");
        Map<String, String> supplied = new LinkedHashMap<>();
        for (Wire.Node child : node.children()) {
            child.requireShape("sc", 3, 0);
            supplied.put(child.scalar(0) + "\u0000" + child.scalar(1), child.scalar(2));
        }
        Map<String, String> expected = new LinkedHashMap<>();
        for (SymmetryState symmetry : snapshot.symmetries().values()) {
            expected.put(symmetry.key(), symmetry.proofId());
        }
        if (!supplied.equals(expected)) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE, "SC family is incomplete or stale");
        }
    }

    private static void verifyReferences(
            Wire.Node node,
            String sectionTag,
            Set<String> available,
            String refTag) {
        requireSection(node, sectionTag);
        Set<String> supplied = new LinkedHashSet<>();
        for (Wire.Node child : node.children()) {
            supplied.add(child.requireShape(refTag, 1, 0).scalar(0));
        }
        if (!supplied.equals(available)) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    sectionTag + " is incomplete or references absent records");
        }
    }

    private Snapshot snapshot(String id) {
        Snapshot snapshot = snapshots.get(id);
        if (snapshot == null) {
            throw new FormatException(
                    FailureCode.DANGLING_REFERENCE, "Unknown snapshot " + id);
        }
        return snapshot;
    }

    private void requireVariant(String proofId, KernelVerifier.Variant variant) {
        if (kernel.proofRecord(proofId).variant() != variant) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE,
                    "Expected " + variant + " proof " + proofId);
        }
    }

    private static ClassState requireClass(Snapshot snapshot, String id) {
        ClassState eclass = snapshot.classes().get(id);
        if (eclass == null) {
            throw new FormatException(
                    FailureCode.DANGLING_REFERENCE, "Unknown graph e-class " + id);
        }
        return eclass;
    }

    private static void rejectParentCycles(Map<String, ParentState> parents) {
        for (String child : parents.keySet()) {
            Set<String> seen = new HashSet<>();
            String cursor = child;
            while (parents.containsKey(cursor)) {
                if (!seen.add(cursor)) {
                    throw new FormatException(
                            FailureCode.INVALID_UNION, "Parent assignment cycle");
                }
                cursor = parents.get(cursor).parent();
            }
        }
    }

    private static boolean isLeader(Snapshot snapshot, String id) {
        return !snapshot.parents().containsKey(id);
    }

    private String termsKey(KernelModel.Term term) {
        return Wire.contentId(kernel.termOps().structuralNode(term));
    }

    private static boolean isTypedSubcontext(
            KernelModel.Context smaller,
            KernelModel.Context larger) {
        for (KernelModel.Slot slot : smaller.slots()) {
            if (!larger.contains(slot.name())
                    || !larger.slot(slot.name()).type().equals(slot.type())) {
                return false;
            }
        }
        return true;
    }

    private static void requireSection(Wire.Node node, String tag) {
        node.requireTag(tag);
        if (!node.scalars().isEmpty()) {
            throw malformed(tag);
        }
    }

    private static String increasing(String prior, String next, String kind) {
        if (prior != null && prior.compareTo(next) >= 0) {
            throw new FormatException(
                    prior.equals(next) ? FailureCode.DUPLICATE_ID
                            : FailureCode.NONCANONICAL_ENCODING,
                    kind + " records are duplicated or unsorted");
        }
        return next;
    }

    private static <T extends Enum<T>> T enumValue(Class<T> type, String value) {
        try {
            return Enum.valueOf(type, value);
        } catch (IllegalArgumentException exception) {
            throw new FormatException(
                    FailureCode.UNKNOWN_VARIANT,
                    "Unknown " + type.getSimpleName() + " " + value,
                    exception);
        }
    }

    private static FormatException malformed(String value) {
        return new FormatException(
                FailureCode.INVALID_RECORD_SHAPE, "Malformed " + value);
    }

    private static FormatException unexplained(String event) {
        return new FormatException(
                FailureCode.UNEXPLAINED_STATE_DELTA,
                "Unexplained graph-state delta in " + event);
    }

    private static final class Difference {
        private final Set<String> addedClasses;
        private final Set<String> removedClasses;
        private final Set<String> changedClasses;
        private final Set<String> addedParents;
        private final Set<String> removedParents;
        private final Set<String> changedParents;
        private final Set<String> addedShapes;
        private final Set<String> removedShapes;
        private final Set<String> changedShapes;
        private final Set<String> changedSymmetries;
        private final boolean hashChanged;
        private final boolean parentUsesChanged;
        private final boolean dirtyChanged;

        private Difference(Snapshot before, Snapshot after) {
            addedClasses = added(before.classes(), after.classes());
            removedClasses = added(after.classes(), before.classes());
            changedClasses = changed(before.classes(), after.classes());
            addedParents = added(before.parents(), after.parents());
            removedParents = added(after.parents(), before.parents());
            changedParents = changed(before.parents(), after.parents());
            addedShapes = added(before.shapes(), after.shapes());
            removedShapes = added(after.shapes(), before.shapes());
            changedShapes = changed(before.shapes(), after.shapes());
            Set<String> beforeSym = before.symmetries().keySet();
            Set<String> afterSym = after.symmetries().keySet();
            Set<String> sym = new LinkedHashSet<>(afterSym);
            sym.removeAll(beforeSym);
            Set<String> removedSym = new LinkedHashSet<>(beforeSym);
            removedSym.removeAll(afterSym);
            sym.addAll(removedSym);
            sym.addAll(changed(before.symmetries(), after.symmetries()));
            changedSymmetries = Collections.unmodifiableSet(sym);
            hashChanged = !before.hashOwners().equals(after.hashOwners());
            parentUsesChanged = !before.parentUses().equals(after.parentUses());
            dirtyChanged = !before.dirty().equals(after.dirty());
        }

        private boolean hasCoreMutation() {
            return !addedClasses.isEmpty() || !removedClasses.isEmpty()
                    || !changedClasses.isEmpty() || !addedParents.isEmpty()
                    || !removedParents.isEmpty() || !changedParents.isEmpty()
                    || !addedShapes.isEmpty() || !removedShapes.isEmpty()
                    || !changedShapes.isEmpty();
        }

        private boolean hasNonParentMutation() {
            return !addedClasses.isEmpty() || !removedClasses.isEmpty()
                    || !changedClasses.isEmpty() || !addedParents.isEmpty()
                    || !removedParents.isEmpty() || !addedShapes.isEmpty()
                    || !removedShapes.isEmpty() || !changedShapes.isEmpty()
                    || !changedSymmetries.isEmpty() || hashChanged
                    || parentUsesChanged || dirtyChanged;
        }

        private boolean sameSemanticStateExceptIndexesAndDirty() {
            return addedClasses.isEmpty() && removedClasses.isEmpty()
                    && changedClasses.isEmpty() && addedParents.isEmpty()
                    && removedParents.isEmpty() && changedParents.isEmpty()
                    && addedShapes.isEmpty() && removedShapes.isEmpty()
                    && changedShapes.isEmpty() && changedSymmetries.isEmpty();
        }

        private static <T> Set<String> added(Map<String, T> before, Map<String, T> after) {
            Set<String> result = new LinkedHashSet<>(after.keySet());
            result.removeAll(before.keySet());
            return Collections.unmodifiableSet(result);
        }

        private static <T> Set<String> changed(Map<String, T> before, Map<String, T> after) {
            Set<String> result = new LinkedHashSet<>();
            for (String key : before.keySet()) {
                if (after.containsKey(key)
                        && !Objects.equals(before.get(key), after.get(key))) {
                    result.add(key);
                }
            }
            return Collections.unmodifiableSet(result);
        }
    }
}
