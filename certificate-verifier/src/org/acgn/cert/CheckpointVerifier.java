package org.acgn.cert;

import java.util.ArrayList;
import java.util.Collections;
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
        REBUILD_START,
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

    record ShapeState(
            String id,
            String owner,
            String termId,
            String replayProofId,
            String occurrenceEmbeddingId,
            String ownerAmbientEmbeddingId,
            String ownerProofId) {
    }

    record RetirementState(
            String retiredShapeId,
            String retiredOwner,
            String retiredTermId,
            String retiredReplayProofId,
            String retiredOccurrenceEmbeddingId,
            String retainedShapeId,
            String causeProofId,
            String transferredOwnerAmbientEmbeddingId,
            String transferredOwnerProofId,
            String retainedOwnerProofId) {
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
            Map<String, Set<String>> hashOwners,
            Set<String> parentUses,
            Map<String, SymmetryState> symmetries,
            Map<String, RetirementState> retirements,
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
        long expectedSequence = 0;
        boolean rebuildOpen = false;
        for (Wire.Node event : model.bundle().events()) {
            if (event.scalars().size() != 4 || event.children().size() != 1) {
                throw malformed("event");
            }
            long sequence = Bundle.parseUnsignedLong(
                    event.scalar(0), "event sequence");
            if (sequence != expectedSequence) {
                throw new FormatException(
                        FailureCode.SNAPSHOT_DISCONTINUITY,
                        "Event sequence does not start at zero and increase consecutively");
            }
            EventKind kind = enumValue(EventKind.class, event.scalar(1));
            if (kind == EventKind.REBUILD_START) {
                if (rebuildOpen) {
                    throw new FormatException(
                            FailureCode.INVALID_REBUILD,
                            "A rebuild start cannot nest inside an open rebuild interval");
                }
                rebuildOpen = true;
            } else if (rebuildOpen) {
                if (kind != EventKind.REBUILD_RECORD
                        && kind != EventKind.UNION
                        && kind != EventKind.REBUILD_COMPLETE) {
                    throw new FormatException(
                            FailureCode.INVALID_REBUILD,
                            "An unrelated event interrupts the open rebuild interval");
                }
            } else if (kind == EventKind.REBUILD_RECORD
                    || kind == EventKind.REBUILD_COMPLETE) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "A rebuild record or completion lacks its retained start boundary");
            }
            Snapshot before = snapshot(event.scalar(2));
            Snapshot after = snapshot(event.scalar(3));
            if (prior == null) {
                requireEmptyGenesis(before);
            } else if (!prior.id().equals(before.id())) {
                throw new FormatException(
                        FailureCode.SNAPSHOT_DISCONTINUITY,
                        "Event pre-state is not the prior event post-state");
            }
            verifyEvent(kind, before, after, event.child(0), rebuildOpen);
            if (kind == EventKind.REBUILD_COMPLETE) {
                rebuildOpen = false;
            }
            prior = after;
            expectedSequence = Math.incrementExact(expectedSequence);
        }
        if (prior == null) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Checkpoint profile requires ordered transition events");
        }
        if (rebuildOpen) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Transition history ends with an incomplete rebuild interval");
        }
        return prior;
    }

    private static void requireEmptyGenesis(Snapshot snapshot) {
        if (snapshot.revision() != 0
                || snapshot.status() != Status.QUIESCENT
                || !snapshot.classes().isEmpty()
                || !snapshot.parents().isEmpty()
                || !snapshot.shapes().isEmpty()
                || !snapshot.hashOwners().isEmpty()
                || !snapshot.parentUses().isEmpty()
                || !snapshot.symmetries().isEmpty()
                || !snapshot.retirements().isEmpty()
                || !snapshot.dirty().isEmpty()) {
            throw new FormatException(
                    FailureCode.SNAPSHOT_DISCONTINUITY,
                    "Transition history does not begin at the exact empty revision-zero genesis");
        }
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
            Map<String, Set<String>> hashOwners = parseHashOwners(node.child(3));
            Set<String> parentUses = parsePairSet(
                    node.child(4), "parent-uses", "parent-use");
            Map<String, SymmetryState> symmetries = parseSymmetries(node.child(5));
            Wire.Node maintenance = node.child(6).requireShape("maintenance", 0, 2);
            Map<String, RetirementState> retirements = parseRetirements(
                    maintenance.child(0));
            Set<String> dirty = parseScalarSet(
                    maintenance.child(1), "dirty", "dirty-shape");
            Snapshot snapshot = new Snapshot(
                    node.scalar(0),
                    Bundle.parseUnsignedLong(node.scalar(1), "snapshot revision"),
                    enumValue(Status.class, node.scalar(2)),
                    classes, parents, shapes, hashOwners, parentUses, symmetries,
                    retirements, dirty);
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
            node.requireShape("shape", 7, 0);
            prior = increasing(prior, node.scalar(0), "shape");
            result.put(node.scalar(0), new ShapeState(
                    node.scalar(0), node.scalar(1), node.scalar(2), node.scalar(3),
                    node.scalar(4), node.scalar(5), node.scalar(6)));
        }
        return Collections.unmodifiableMap(result);
    }

    private Map<String, Set<String>> parseHashOwners(Wire.Node section) {
        requireSection(section, "hash-cons");
        Map<String, Set<String>> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node node : section.children()) {
            node.requireShape("hash-owner", 2, 0);
            String pair = node.scalar(0) + "\u0000" + node.scalar(1);
            prior = increasing(prior, pair, "hash owner");
            result.computeIfAbsent(
                    node.scalar(0), ignored -> new LinkedHashSet<>())
                    .add(node.scalar(1));
        }
        Map<String, Set<String>> frozen = new LinkedHashMap<>();
        for (Map.Entry<String, Set<String>> entry : result.entrySet()) {
            if (entry.getValue().isEmpty()) {
                throw malformed("hash-cons");
            }
            frozen.put(entry.getKey(), Collections.unmodifiableSet(
                    new LinkedHashSet<>(entry.getValue())));
        }
        return Collections.unmodifiableMap(frozen);
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

    private Map<String, RetirementState> parseRetirements(Wire.Node section) {
        requireSection(section, "retirements");
        Map<String, RetirementState> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node node : section.children()) {
            node.requireShape("retirement", 10, 0);
            prior = increasing(prior, node.scalar(0), "retirement");
            RetirementState state = new RetirementState(
                    node.scalar(0), node.scalar(1), node.scalar(2), node.scalar(3),
                    node.scalar(4), node.scalar(5), node.scalar(6), node.scalar(7),
                    node.scalar(8), node.scalar(9));
            if (result.put(state.retiredShapeId(), state) != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Duplicate retirement for " + state.retiredShapeId());
            }
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
                    || !witness.type().equals(eclass.type())
                    || witness.revision() > snapshot.revision()) {
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
            Wire.Node payload = proof.payload().requireShape("parent-edge", 3, 0);
            if (!payload.scalar(0).equals(child.witnessId())
                    || !payload.scalar(1).equals(target.witnessId())
                    || !payload.scalar(2).equals(parent.embeddingId())) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "Parent assignment and parent-edge proof disagree");
            }
            kernel.verify(parent.proofId());
        }
        rejectParentCycles(snapshot.parents());

        for (ShapeState shape : snapshot.shapes().values()) {
            ClassState owner = requireClass(snapshot, shape.owner());
            KernelModel.Term term = model.term(shape.termId());
            if (!shape.id().equals(shapeId(shape.owner(), shape.termId()))) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Shape identity is not derived from its exact owner and term");
            }
            KernelVerifier.ProofRecord replay = kernel.proofRecord(shape.replayProofId());
            KernelModel.Embedding occurrence = model.embedding(
                    shape.occurrenceEmbeddingId());
            KernelModel.Embedding ownerAmbient = model.embedding(
                    shape.ownerAmbientEmbeddingId());
            KernelModel.Context ownerContext = model.context(owner.contextId());
            if (occurrence.kind() != KernelModel.EmbeddingKind.BIJECTION
                    || !occurrence.source().equals(term.context())
                    || !ownerAmbient.source().equals(ownerContext)
                    || !ownerAmbient.target().equals(occurrence.target())) {
                throw new FormatException(
                        FailureCode.INVALID_COLLISION,
                        "Stored shape does not carry exact occurrence and owner ambient embeddings");
            }
            if (replay.variant() != KernelVerifier.Variant.KERNEL_REPLAY
                    && replay.variant() != KernelVerifier.Variant.REBUILD_CONGRUENCE) {
                throw new FormatException(
                        FailureCode.INVALID_KERNEL_REPLAY,
                        "Stored shape lacks source-to-kernel/rebuild evidence");
            }
            KernelVerifier.Judgment replayed = kernel.verify(shape.replayProofId());
            if (!replayed.right().id().equals(term.id())) {
                throw new FormatException(
                        FailureCode.INVALID_KERNEL_REPLAY,
                        "Stored shape differs from its replay result");
            }
            if (!term.sort().kind().equals(KernelModel.SortKind.TERM)) {
                throw new FormatException(
                        FailureCode.ILL_TYPED_TERM, "Stored shape is not a term");
            }
            requireExactShapeOwnerEquation(
                    owner, term, occurrence, ownerAmbient, shape.ownerProofId());
        }
        validateRetirements(snapshot);
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

    private void requireExactShapeOwnerEquation(
            ClassState owner,
            KernelModel.Term shape,
            KernelModel.Embedding occurrence,
            KernelModel.Embedding ownerAmbient,
            String proofId) {
        KernelModel.Witness ownerWitness = model.witness(owner.witnessId());
        if (occurrence.kind() != KernelModel.EmbeddingKind.BIJECTION
                || !occurrence.source().equals(shape.context())
                || !ownerAmbient.source().equals(ownerWitness.context())
                || !ownerAmbient.target().equals(occurrence.target())) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Shape-owner equation uses inconsistent ambient embeddings");
        }
        KernelModel.Term installedShape = kernel.termOps().act(shape, occurrence);
        KernelModel.Term installedOwner = kernel.termOps().act(
                ownerWitness.definition(), ownerAmbient);
        requireOrientedProof(
                proofId,
                installedShape,
                installedOwner,
                FailureCode.INVALID_COLLISION,
                "Shape-owner EC proof does not have the exact oriented current-owner endpoints");
    }

    private void validateRetirements(Snapshot snapshot) {
        for (RetirementState retirement : snapshot.retirements().values()) {
            if (!retirement.retiredShapeId().equals(shapeId(
                    retirement.retiredOwner(), retirement.retiredTermId()))) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Retirement identity is not derived from its retired owner and term");
            }
            requireClass(snapshot, retirement.retiredOwner());
            ShapeState retained = resolveRetainedShape(snapshot, retirement.retainedShapeId());
            RetirementState retainedRetirement = snapshot.retirements().get(
                    retirement.retainedShapeId());
            String immediateRetainedOwner = retainedRetirement == null
                    ? retained.owner() : retainedRetirement.retiredOwner();
            String immediateRetainedTerm = retainedRetirement == null
                    ? retained.termId() : retainedRetirement.retiredTermId();
            String immediateRetainedOwnerProof = retainedRetirement == null
                    ? retained.ownerProofId()
                    : retainedRetirement.transferredOwnerProofId();
            KernelModel.Term retiredTerm = model.term(retirement.retiredTermId());
            KernelVerifier.Judgment replay = kernel.verify(
                    retirement.retiredReplayProofId());
            if (!replay.right().id().equals(retiredTerm.id())) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Retirement replay does not reach the retired term");
            }
            KernelModel.Embedding occurrence = model.embedding(
                    retirement.retiredOccurrenceEmbeddingId());
            KernelModel.Embedding ownerAmbient = model.embedding(
                    retirement.transferredOwnerAmbientEmbeddingId());
            ClassState retainedOwner = requireClass(snapshot, immediateRetainedOwner);
            if (occurrence.kind() != KernelModel.EmbeddingKind.BIJECTION
                    || !occurrence.source().equals(retiredTerm.context())
                    || !ownerAmbient.source().id().equals(retainedOwner.contextId())
                    || !ownerAmbient.target().equals(occurrence.target())) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Retirement transfer embeddings do not share the exact ambient context");
            }
            KernelModel.Term transferredLeft = kernel.termOps().act(
                    retiredTerm, occurrence);
            KernelModel.Term transferredRight = kernel.termOps().act(
                    model.witness(retainedOwner.witnessId()).definition(), ownerAmbient);
            requireOrientedProof(
                    retirement.transferredOwnerProofId(),
                    transferredLeft,
                    transferredRight,
                    FailureCode.INVALID_REBUILD,
                    "Retirement transfer proof does not bind the retired record to its retained owner");
            if (!retirement.retainedOwnerProofId().equals(immediateRetainedOwnerProof)) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Retirement does not preserve the retained live record's owner proof");
            }
            KernelVerifier.ProofRecord cause = kernel.proofRecord(
                    retirement.causeProofId());
            if (cause.variant() == KernelVerifier.Variant.PARENT_EDGE) {
                Wire.Node edge = cause.payload().requireShape("parent-edge", 3, 0);
                KernelModel.Witness child = model.witness(edge.scalar(0));
                KernelModel.Witness parent = model.witness(edge.scalar(1));
                ParentState installed = snapshot.parents().get(retirement.retiredOwner());
                if (!child.eclass().equals(retirement.retiredOwner())
                        || !parent.eclass().equals(immediateRetainedOwner)
                        || installed == null
                        || !installed.proofId().equals(retirement.causeProofId())
                        || !retiredTerm.id().equals(model.term(immediateRetainedTerm).id())) {
                    throw new FormatException(
                            FailureCode.INVALID_UNION,
                            "Union retirement cause or exact retained shape is unrelated");
                }
            } else if (cause.variant() == KernelVerifier.Variant.REBUILD_CONGRUENCE) {
                if (!retirement.retiredOwner().equals(immediateRetainedOwner)) {
                    throw new FormatException(
                            FailureCode.INVALID_REBUILD,
                            "Rebuild retirement changed owner without a parent edge");
                }
                requireOrientedProof(
                        retirement.causeProofId(),
                        retiredTerm,
                        model.term(immediateRetainedTerm),
                        FailureCode.INVALID_REBUILD,
                        "Rebuild retirement cause has unrelated root endpoints");
            } else {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Retirement cause is neither an installed parent edge nor rebuild root proof");
            }
        }
    }

    private ShapeState resolveRetainedShape(Snapshot snapshot, String id) {
        Set<String> seen = new HashSet<>();
        String cursor = id;
        while (true) {
            if (!seen.add(cursor)) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD, "Retirement ledger contains a cycle");
            }
            ShapeState live = snapshot.shapes().get(cursor);
            if (live != null) {
                return live;
            }
            RetirementState next = snapshot.retirements().get(cursor);
            if (next == null) {
                throw new FormatException(
                        FailureCode.DANGLING_REFERENCE,
                        "Retirement does not resolve to a live shape: " + id);
            }
            cursor = next.retainedShapeId();
        }
    }

    private void requireOrientedProof(
            String proofId,
            KernelModel.Term left,
            KernelModel.Term right,
            FailureCode code,
            String message) {
        KernelVerifier.Judgment proof = kernel.verify(proofId);
        if (!proof.context().equals(left.context())
                || !proof.sort().equals(left.sort())
                || !left.context().equals(right.context())
                || !left.sort().equals(right.sort())
                || !proof.left().id().equals(left.id())
                || !proof.right().id().equals(right.id())) {
            throw new FormatException(code, message);
        }
    }

    private void validateHashes(Snapshot snapshot) {
        Map<String, Set<String>> expected = exactHashOwners(snapshot);
        if (snapshot.status() == Status.QUIESCENT
                && !snapshot.hashOwners().equals(expected)) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Quiescent hash-cons is not exact");
        }
        for (Map.Entry<String, Set<String>> entry : snapshot.hashOwners().entrySet()) {
            if (entry.getValue().isEmpty()) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Hash-cons contains an empty owner bucket");
            }
            for (String owner : entry.getValue()) {
                if (!snapshot.classes().containsKey(owner)
                        || !isLeader(snapshot, owner)) {
                    throw new FormatException(
                            FailureCode.INVALID_REBUILD,
                            "Hash-cons names a missing or nonleader owner");
                }
            }
            List<String> owners = new ArrayList<>(entry.getValue());
            for (int left = 0; left < owners.size(); left++) {
                for (int right = left + 1; right < owners.size(); right++) {
                    ShapeState leftShape = shapeForOwnerAndKey(
                            snapshot, owners.get(left), entry.getKey());
                    ShapeState rightShape = shapeForOwnerAndKey(
                            snapshot, owners.get(right), entry.getKey());
                    if (hasExactShapeEmbedding(snapshot, leftShape, rightShape)
                            || hasExactShapeEmbedding(snapshot, rightShape, leftShape)) {
                        throw new FormatException(
                                FailureCode.INVALID_COLLISION,
                                "One hash bucket retains compatible leader interfaces");
                    }
                }
            }
        }
    }

    private Map<String, Set<String>> exactHashOwners(Snapshot snapshot) {
        Map<String, Set<String>> expected = new LinkedHashMap<>();
        for (ShapeState shape : snapshot.shapes().values()) {
            if (!isLeader(snapshot, shape.owner())) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "A nonleader retains a stored shape");
            }
            String key = termsKey(model.term(shape.termId()));
            expected.computeIfAbsent(key, ignored -> new LinkedHashSet<>())
                    .add(shape.owner());
        }
        return expected;
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
            Wire.Node payload,
            boolean rebuildOpen) {
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
            case UNION -> verifyUnion(
                    before, after, payload, difference, !rebuildOpen);
            case ADD_SYMMETRY -> verifyAddSymmetry(before, after, payload, difference);
            case RESTRICT_INTERFACE -> verifyRestriction(
                    before, after, payload, difference);
            case REBUILD_RECORD -> verifyRebuildRecord(
                    before, after, payload, difference);
            case PATH_COMPRESS -> verifyPathCompression(
                    before, after, payload, difference);
            case REBUILD_START -> verifyRebuildStart(before, after, payload);
            case REBUILD_COMPLETE -> verifyRebuildComplete(
                    before, after, payload, difference);
        }
    }

    private void verifyRebuildStart(
            Snapshot before,
            Snapshot after,
            Wire.Node payload) {
        payload.requireShape("rebuild-start", 1, 0);
        if (!payload.scalar(0).equals(before.id())
                || before.status() != Status.DIRTY
                || !before.equals(after)) {
            throw unexplained("rebuild start");
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
                || !difference.changedClasses.isEmpty()
                || !difference.removedShapes.isEmpty()
                || !difference.changedShapes.isEmpty()
                || !difference.addedParents.isEmpty()
                || !difference.changedParents.isEmpty()
                || !difference.removedParents.isEmpty()
                || difference.hasSymmetryMutation()
                || difference.hasRetirementMutation()
                || !before.dirty().equals(after.dirty())
                || before.status() != Status.QUIESCENT
                || after.revision() != before.revision() + 1
                || after.status() != Status.QUIESCENT) {
            throw unexplained("fresh insertion");
        }
        requireVariant(payload.scalar(2), KernelVerifier.Variant.KERNEL_REPLAY);
        requireVariant(payload.scalar(3), KernelVerifier.Variant.CANONICAL_ORBIT);
        requireVariant(payload.scalar(4), KernelVerifier.Variant.FRESH_WITNESS);
        ShapeState inserted = after.shapes().get(payload.scalar(1));
        ClassState insertedClass = requireClass(after, payload.scalar(0));
        KernelModel.Witness insertedWitness = model.witness(
                insertedClass.witnessId());
        if (!inserted.owner().equals(insertedClass.id())
                || !inserted.replayProofId().equals(payload.scalar(2))
                || insertedWitness.revision() != after.revision()) {
            throw new FormatException(
                    FailureCode.INVALID_FRESH_WITNESS,
                    "Fresh insertion payload does not name the installed class and shape replay");
        }

        KernelVerifier.ProofRecord orbitRecord = kernel.proofRecord(payload.scalar(3));
        Wire.Node orbitPayload = orbitRecord.payload().requireShape(
                "canonical-orbit", 6, 4);
        if (!orbitPayload.scalar(1).equals(inserted.termId())
                || !orbitPayload.scalar(2).equals(insertedClass.contextId())
                || !orbitPayload.scalar(3).equals(insertedWitness.definition().id())
                || !orbitPayload.scalar(4).equals(inserted.occurrenceEmbeddingId())) {
            throw new FormatException(
                    FailureCode.INVALID_FRESH_WITNESS,
                    "Fresh insertion orbit does not install the named shape and witness");
        }

        KernelVerifier.ProofRecord freshRecord = kernel.proofRecord(payload.scalar(4));
        Wire.Node freshPayload = freshRecord.payload().requireShape(
                "fresh-witness", 4, 0);
        if (!freshRecord.premises().equals(List.of(payload.scalar(2)))
                || !freshPayload.scalar(0).equals(insertedClass.witnessId())
                || !freshPayload.scalar(1).equals(insertedWitness.definition().id())
                || !freshPayload.scalar(3).equals(payload.scalar(2))) {
            throw new FormatException(
                    FailureCode.INVALID_FRESH_WITNESS,
                    "Fresh insertion proof trio belongs to another insertion diagram");
        }

        KernelVerifier.Judgment replay = kernel.verify(payload.scalar(2));
        KernelVerifier.Judgment orbit = kernel.verify(payload.scalar(3));
        KernelVerifier.Judgment fresh = kernel.verify(payload.scalar(4));
        if (!replay.right().id().equals(inserted.termId())
                || !orbit.left().id().equals(insertedWitness.definition().id())
                || !orbit.right().id().equals(insertedWitness.definition().id())
                || !fresh.left().id().equals(insertedWitness.definition().id())
                || !fresh.right().id().equals(insertedWitness.definition().id())) {
            throw new FormatException(
                    FailureCode.INVALID_FRESH_WITNESS,
                    "Fresh insertion proofs do not establish the installed witness state");
        }
        String key = termsKey(model.term(inserted.termId()));
        for (String priorOwner : before.hashOwners().getOrDefault(key, Set.of())) {
            ShapeState priorShape = shapeForOwnerAndKey(before, priorOwner, key);
            if (hasExactShapeEmbedding(after, inserted, priorShape)
                    || hasExactShapeEmbedding(after, priorShape, inserted)) {
                throw new FormatException(
                        FailureCode.INVALID_COLLISION,
                        "A compatible equal-shape owner was retained without a certified union");
            }
        }
    }

    private void verifyCollisionInsertion(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireShape("insert-collision", 11, 0);
        if (!difference.addedClasses.equals(Set.of(payload.scalar(0)))
                || !difference.addedParents.equals(Set.of(payload.scalar(0)))
                || !difference.removedClasses.isEmpty()
                || !difference.changedClasses.isEmpty()
                || !difference.removedParents.isEmpty()
                || !difference.changedParents.isEmpty()
                || !difference.addedShapes.isEmpty()
                || !difference.removedShapes.isEmpty()
                || !difference.changedShapes.isEmpty()
                || difference.hasSymmetryMutation()
                || difference.hasRetirementMutation()
                || !before.dirty().equals(after.dirty())
                || !before.hashOwners().equals(after.hashOwners())
                || !before.parentUses().equals(after.parentUses())
                || before.status() != Status.QUIESCENT
                || after.revision() != before.revision() + 1
                || after.status() != Status.DIRTY) {
            throw unexplained("collision insertion");
        }
        requireVariant(payload.scalar(3), KernelVerifier.Variant.KERNEL_REPLAY);
        requireVariant(payload.scalar(4), KernelVerifier.Variant.FRESH_WITNESS);
        requireVariant(payload.scalar(9), KernelVerifier.Variant.COLLISION);
        requireVariant(payload.scalar(10), KernelVerifier.Variant.PARENT_EDGE);
        ClassState inserted = requireClass(after, payload.scalar(0));
        KernelModel.Witness insertedWitness = model.witness(inserted.witnessId());
        KernelModel.Term source = model.term(payload.scalar(1));
        KernelModel.Term shape = model.term(payload.scalar(2));
        KernelVerifier.Judgment sourceReplay = kernel.verify(payload.scalar(3));
        if (!sourceReplay.left().id().equals(source.id())
                || !sourceReplay.right().id().equals(shape.id())) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Collision insertion source replay is unrelated to its source and shape");
        }
        KernelVerifier.ProofRecord freshRecord = kernel.proofRecord(payload.scalar(4));
        Wire.Node freshPayload = freshRecord.payload().requireShape(
                "fresh-witness", 4, 0);
        if (!freshRecord.premises().equals(List.of(payload.scalar(3)))
                || !freshPayload.scalar(0).equals(inserted.witnessId())
                || !freshPayload.scalar(1).equals(shape.id())
                || !freshPayload.scalar(3).equals(payload.scalar(3))) {
            throw new FormatException(
                    FailureCode.INVALID_FRESH_WITNESS,
                    "Collision insertion fresh proof is not the named source replay allocation");
        }
        requireOrientedProof(
                payload.scalar(4), shape, insertedWitness.definition(),
                FailureCode.INVALID_FRESH_WITNESS,
                "Collision insertion fresh proof has unrelated endpoints");
        requireExactShapeOwnerEquation(
                inserted,
                shape,
                model.embedding(payload.scalar(5)),
                model.embedding(payload.scalar(6)),
                payload.scalar(7));

        ShapeState collidedShape = before.shapes().get(payload.scalar(8));
        if (collidedShape == null || !isLeader(before, collidedShape.owner())) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Collision insertion does not name an existing leader shape");
        }
        if (!shape.id().equals(collidedShape.termId())) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Collision sides do not reach the exact same stored shape term");
        }
        ParentState installed = after.parents().get(payload.scalar(0));
        if (installed == null
                || !installed.parent().equals(collidedShape.owner())
                || !installed.proofId().equals(payload.scalar(10))
                || insertedWitness.revision() != after.revision()
                || !isLeader(before, installed.parent())) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Collision insertion names another installed parent edge");
        }
        KernelVerifier.ProofRecord collisionRecord = kernel.proofRecord(payload.scalar(9));
        Wire.Node collisionPayload = collisionRecord.payload().requireShape(
                "collision", 4, 0);
        String exactKey = termsKey(shape);
        if (collisionRecord.premises().size() != 2
                || !collisionPayload.scalars().equals(List.of(
                        collisionRecord.premises().get(0),
                        collisionRecord.premises().get(1), exactKey, exactKey))) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Collision proof does not consume the two exact replay/key sides");
        }
        for (String sideProofId : collisionRecord.premises()) {
            KernelVerifier.Judgment side = kernel.verify(sideProofId);
            if (!side.right().id().equals(shape.id())) {
                throw new FormatException(
                        FailureCode.INVALID_COLLISION,
                        "Collision side proof does not reach the exact stored shape term");
            }
        }
        KernelVerifier.ProofRecord edgeRecord = kernel.proofRecord(payload.scalar(10));
        if (!edgeRecord.premises().equals(List.of(payload.scalar(9)))) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Installed parent edge does not consume the exact collision proof");
        }
        KernelVerifier.Judgment collision = kernel.verify(payload.scalar(9));
        KernelVerifier.Judgment edge = kernel.verify(payload.scalar(10));
        if (!sameJudgment(collision, edge)) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Collision proof and installed parent edge have different judgments");
        }
        if (!before.shapes().equals(after.shapes())
                || !before.symmetries().equals(after.symmetries())) {
            throw unexplained("collision insertion");
        }
    }

    private static boolean sameJudgment(
            KernelVerifier.Judgment left,
            KernelVerifier.Judgment right) {
        return left.context().equals(right.context())
                && left.sort().equals(right.sort())
                && left.left().id().equals(right.left().id())
                && left.right().id().equals(right.right().id());
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
                || !difference.changedClasses.isEmpty()
                || !difference.removedParents.isEmpty()
                || !difference.changedParents.isEmpty()
                || difference.hasSymmetryMutation()
                || before.status() != (publicRevision
                        ? Status.QUIESCENT : Status.DIRTY)
                || after.status() != Status.DIRTY
                || after.revision() != before.revision() + (publicRevision ? 1 : 0)) {
            throw unexplained("union");
        }
        String child = difference.addedParents.iterator().next();
        ParentState installed = after.parents().get(child);
        if (installed == null
                || !installed.proofId().equals(payload.scalar(0))
                || !isLeader(before, child)
                || !isLeader(before, installed.parent())) {
            throw new FormatException(
                    FailureCode.INVALID_UNION,
                    "Union payload does not name the uniquely installed parent edge");
        }
        requireExactUnionTransfer(before, after, child, installed);
    }

    private void requireExactUnionTransfer(
            Snapshot before,
            Snapshot after,
            String child,
            ParentState edge) {
        if (!before.symmetries().equals(after.symmetries())) {
            throw unexplained("union symmetry frame");
        }
        Set<String> absorbed = new LinkedHashSet<>();
        for (String eclass : before.classes().keySet()) {
            if (leaderOf(before, eclass).equals(child)) {
                absorbed.add(eclass);
            }
        }
        for (SymmetryState symmetry : before.symmetries().values()) {
            if (absorbed.contains(symmetry.eclass())) {
                throw new UncheckableException(
                        FailureCode.MISSING_EVIDENCE,
                        "Union cannot transport an absorbed symmetry without an explicit SC ledger");
            }
        }

        Map<String, ShapeState> expectedUnchangedShapes = new LinkedHashMap<>();
        Map<String, String> rehomedIds = new LinkedHashMap<>();
        Set<String> expectedNewRetirements = new LinkedHashSet<>();
        for (ShapeState shape : before.shapes().values()) {
            if (!shape.owner().equals(child)) {
                expectedUnchangedShapes.put(shape.id(), shape);
                continue;
            }
            String movedId = shapeId(edge.parent(), shape.termId());
            rehomedIds.put(shape.id(), movedId);
            ShapeState moved = after.shapes().get(movedId);
            if (moved == null
                    || !moved.owner().equals(edge.parent())
                    || !moved.termId().equals(shape.termId())
                    || !moved.replayProofId().equals(shape.replayProofId())
                    || !moved.occurrenceEmbeddingId().equals(
                            shape.occurrenceEmbeddingId())) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "Union omitted or altered the conserved fields of an exact rehome target");
            }
            if (before.shapes().containsKey(movedId)) {
                expectedNewRetirements.add(shape.id());
                if (!moved.equals(before.shapes().get(movedId))) {
                    throw new FormatException(
                            FailureCode.INVALID_UNION,
                            "Union duplicate-retirement branch mutated its retained record");
                }
            } else if (after.retirements().containsKey(shape.id())) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "Ordinary union rehome also claimed the mutually exclusive retirement branch");
            }
        }
        Set<String> expectedShapeIds = new LinkedHashSet<>(
                expectedUnchangedShapes.keySet());
        expectedShapeIds.addAll(rehomedIds.values());
        if (!after.shapes().keySet().equals(expectedShapeIds)) {
            throw new FormatException(
                    FailureCode.INVALID_UNION,
                    "Union live-shape state is not the exact rehome/retention result");
        }
        for (Map.Entry<String, ShapeState> unchanged : expectedUnchangedShapes.entrySet()) {
            if (!after.shapes().get(unchanged.getKey()).equals(unchanged.getValue())) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "Union changed an unrelated live shape record");
            }
        }

        Map<String, RetirementState> expectedRetirements = new LinkedHashMap<>(
                before.retirements());
        for (String retiredId : expectedNewRetirements) {
            RetirementState retirement = after.retirements().get(retiredId);
            ShapeState old = before.shapes().get(retiredId);
            if (retirement == null
                    || !retirement.retiredOwner().equals(child)
                    || !retirement.retiredTermId().equals(old.termId())
                    || !retirement.retiredReplayProofId().equals(old.replayProofId())
                    || !retirement.retiredOccurrenceEmbeddingId().equals(
                            old.occurrenceEmbeddingId())
                    || !retirement.retainedShapeId().equals(rehomedIds.get(retiredId))
                    || !retirement.causeProofId().equals(edge.proofId())) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "Union retirement ledger does not conserve the removed live record");
            }
            expectedRetirements.put(retiredId, retirement);
        }
        if (!after.retirements().equals(expectedRetirements)) {
            throw new FormatException(
                    FailureCode.INVALID_UNION,
                    "Union retirement ledger has an unexplained addition, removal, or mutation");
        }
        if (!after.hashOwners().equals(exactHashOwners(after))) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Union hash-cons is not the exact index of its rehomed shape state");
        }

        Set<String> expectedDirty = new LinkedHashSet<>();
        for (String oldDirty : before.dirty()) {
            expectedDirty.add(rehomedIds.getOrDefault(oldDirty, oldDirty));
        }
        for (String use : before.parentUses()) {
            int separator = use.indexOf('\u0000');
            String invokedClass = use.substring(0, separator);
            if (absorbed.contains(invokedClass)) {
                String oldShape = use.substring(separator + 1);
                expectedDirty.add(rehomedIds.getOrDefault(oldShape, oldShape));
            }
        }
        if (!after.dirty().equals(expectedDirty)) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Union dirty queue is not the exact set of affected parent records");
        }
    }

    private void verifyAddSymmetry(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireShape("add-symmetry", 3, 0);
        String key = payload.scalar(0) + "\u0000" + payload.scalar(1);
        if (!difference.addedSymmetries.equals(Set.of(key))
                || !difference.removedSymmetries.isEmpty()
                || !difference.changedSymmetries.isEmpty()
                || after.revision() != before.revision() + 1
                || before.status() != Status.QUIESCENT
                || after.status() != Status.DIRTY
                || difference.hasCoreMutation()
                || difference.hashChanged
                || difference.parentUsesChanged
                || difference.dirtyChanged) {
            throw unexplained("symmetry addition");
        }
        requireVariant(payload.scalar(2), KernelVerifier.Variant.FULL_INTERFACE_SYMMETRY);
        SymmetryState installed = after.symmetries().get(key);
        if (installed == null
                || !installed.eclass().equals(payload.scalar(0))
                || !installed.embeddingId().equals(payload.scalar(1))
                || !installed.proofId().equals(payload.scalar(2))) {
            throw new FormatException(
                    FailureCode.INVALID_SYMMETRY,
                    "ADD_SYMMETRY payload is not the exact installed SC record");
        }
        ClassState owner = requireClass(after, installed.eclass());
        KernelModel.Witness witness = model.witness(owner.witnessId());
        KernelModel.Embedding permutation = model.embedding(installed.embeddingId());
        requireOrientedProof(
                installed.proofId(),
                witness.definition(),
                kernel.termOps().act(witness.definition(), permutation),
                FailureCode.INVALID_SYMMETRY,
                "ADD_SYMMETRY proof does not act on the current owner witness");
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
                || !difference.addedClasses.isEmpty()
                || !difference.removedClasses.isEmpty()
                || !difference.addedParents.isEmpty()
                || !difference.removedParents.isEmpty()
                || !difference.addedShapes.isEmpty()
                || !difference.removedShapes.isEmpty()
                || !difference.addedSymmetries.isEmpty()
                || !difference.removedSymmetries.isEmpty()
                || difference.hasRetirementMutation()
                || difference.hashChanged
                || difference.parentUsesChanged
                || difference.dirtyChanged
                || after.revision() != before.revision() + 1
                || before.status() != Status.QUIESCENT
                || after.status() != Status.DIRTY
                || !payload.child(0).tag().equals("transported-evidence")
                || !payload.child(0).scalars().isEmpty()) {
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
        Set<String> supplied = new LinkedHashSet<>();
        for (Wire.Node transport : payload.child(0).children()) {
            String key;
            switch (transport.tag()) {
                case "transported-parent" -> {
                    transport.requireShape("transported-parent", 5, 0);
                    ParentState oldParent = before.parents().get(transport.scalar(0));
                    ParentState newParent = after.parents().get(transport.scalar(0));
                    if (oldParent == null || newParent == null
                            || (!oldParent.child().equals(eclass)
                                    && !oldParent.parent().equals(eclass))
                            || !oldParent.edgeId().equals(newParent.edgeId())
                            || !oldParent.child().equals(newParent.child())
                            || !oldParent.parent().equals(newParent.parent())
                            || !List.of(
                                    oldParent.embeddingId(), oldParent.proofId(),
                                    newParent.embeddingId(), newParent.proofId())
                                    .equals(transport.scalars().subList(1, 5))) {
                        throw new FormatException(
                                FailureCode.INVALID_RESTRICTION,
                                "Restriction parent transport is not exact");
                    }
                    key = "P\u0000" + transport.scalar(0);
                }
                case "transported-shape" -> {
                    transport.requireShape("transported-shape", 5, 0);
                    ShapeState oldShape = before.shapes().get(transport.scalar(0));
                    ShapeState newShape = after.shapes().get(transport.scalar(0));
                    if (oldShape == null || newShape == null
                            || !oldShape.owner().equals(eclass)
                            || !sameShapeStructure(oldShape, newShape)
                            || !List.of(
                                    oldShape.ownerAmbientEmbeddingId(), oldShape.ownerProofId(),
                                    newShape.ownerAmbientEmbeddingId(), newShape.ownerProofId())
                                    .equals(transport.scalars().subList(1, 5))) {
                        throw new FormatException(
                                FailureCode.INVALID_RESTRICTION,
                                "Restriction shape transport is not exact");
                    }
                    key = "H\u0000" + transport.scalar(0);
                }
                case "transported-symmetry" -> {
                    transport.requireShape("transported-symmetry", 5, 0);
                    String oldKey = transport.scalar(0) + "\u0000" + transport.scalar(1);
                    SymmetryState oldSymmetry = before.symmetries().get(oldKey);
                    String newKey = transport.scalar(0) + "\u0000" + transport.scalar(3);
                    SymmetryState newSymmetry = after.symmetries().get(newKey);
                    if (oldSymmetry == null || newSymmetry == null
                            || !transport.scalar(0).equals(eclass)
                            || !oldSymmetry.proofId().equals(transport.scalar(2))
                            || !newSymmetry.proofId().equals(transport.scalar(4))) {
                        throw new FormatException(
                                FailureCode.INVALID_RESTRICTION,
                                "Restriction symmetry transport is not exact");
                    }
                    key = "S\u0000" + oldKey;
                }
                default -> throw malformed("restriction transported evidence");
            }
            if (!supplied.add(key)) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Duplicate restriction transport " + key);
            }
        }
        Set<String> expected = new LinkedHashSet<>();
        difference.changedParents.forEach(id -> expected.add("P\u0000" + id));
        difference.changedShapes.forEach(id -> expected.add("H\u0000" + id));
        difference.changedSymmetries.forEach(id -> expected.add("S\u0000" + id));
        if (!supplied.equals(expected)) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Restriction transport ledger is incomplete or contains unrelated records");
        }
    }

    private static boolean sameShapeStructure(ShapeState left, ShapeState right) {
        return left.id().equals(right.id())
                && left.owner().equals(right.owner())
                && left.termId().equals(right.termId())
                && left.replayProofId().equals(right.replayProofId())
                && left.occurrenceEmbeddingId().equals(right.occurrenceEmbeddingId());
    }

    private void verifyRebuildRecord(
            Snapshot before,
            Snapshot after,
            Wire.Node payload,
            Difference difference) {
        payload.requireShape("rebuild-record", 3, 1);
        String oldShapeId = payload.scalar(0);
        String newShapeId = payload.scalar(1);
        ShapeState beforeShape = before.shapes().get(oldShapeId);
        ShapeState afterShape = after.shapes().get(newShapeId);
        if (beforeShape == null
                || afterShape == null
                || oldShapeId.equals(newShapeId)
                || !before.dirty().contains(oldShapeId)
                || before.status() != Status.DIRTY
                || after.status() != Status.DIRTY
                || after.revision() != before.revision()
                || !before.classes().equals(after.classes())
                || !before.parents().equals(after.parents())
                || !before.symmetries().equals(after.symmetries())
                || !difference.removedShapes.equals(Set.of(oldShapeId))
                || !difference.changedShapes.isEmpty()
                || !difference.removedRetirements.isEmpty()
                || !difference.changedRetirements.isEmpty()) {
            throw unexplained("rebuild record");
        }
        Set<String> expectedDirty = new LinkedHashSet<>(before.dirty());
        expectedDirty.remove(oldShapeId);
        if (!after.dirty().equals(expectedDirty)) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Rebuild record does not consume exactly its named dirty record");
        }
        requireVariant(payload.scalar(2), KernelVerifier.Variant.REBUILD_CONGRUENCE);
        KernelModel.Term oldTerm = model.term(beforeShape.termId());
        KernelModel.Term newTerm = model.term(afterShape.termId());
        requireOrientedProof(
                payload.scalar(2), oldTerm, newTerm,
                FailureCode.INVALID_REBUILD,
                "Rebuild root proof is not the exact old-to-new replacement equation");
        ShapeState priorTarget = before.shapes().get(newShapeId);
        if (!beforeShape.owner().equals(afterShape.owner())
                || (priorTarget == null
                        && !afterShape.replayProofId().equals(payload.scalar(2)))) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Rebuild replacement changed owner or omitted its checked root proof");
        }
        if (priorTarget != null && !priorTarget.equals(afterShape)) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Rebuild mutated an already retained target record");
        }
        Wire.Node branch = payload.child(0);
        Map<String, RetirementState> expectedRetirements = new LinkedHashMap<>(
                before.retirements());
        if (branch.tag().equals("replace")) {
            branch.requireShape("replace", 0, 0);
            if (priorTarget != null
                    || !difference.addedShapes.equals(Set.of(newShapeId))
                    || difference.hasRetirementMutation()) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Rebuild replacement branch is not exclusive or did not add its target");
            }
        } else if (branch.tag().equals("retire")) {
            branch.requireShape("retire", 1, 0);
            if (priorTarget == null
                    || !difference.addedShapes.isEmpty()
                    || !difference.addedRetirements.equals(Set.of(oldShapeId))) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Rebuild retirement branch is not exclusive or lacks a prior target");
            }
            RetirementState retirement = after.retirements().get(branch.scalar(0));
            if (retirement == null
                    || !retirement.retiredShapeId().equals(oldShapeId)
                    || !retirement.retiredOwner().equals(beforeShape.owner())
                    || !retirement.retiredTermId().equals(beforeShape.termId())
                    || !retirement.retiredReplayProofId().equals(
                            beforeShape.replayProofId())
                    || !retirement.retiredOccurrenceEmbeddingId().equals(
                            beforeShape.occurrenceEmbeddingId())
                    || !retirement.retainedShapeId().equals(newShapeId)
                    || !retirement.causeProofId().equals(payload.scalar(2))) {
                throw new FormatException(
                        FailureCode.INVALID_REBUILD,
                        "Rebuild retirement does not conserve its exact removed record");
            }
            expectedRetirements.put(oldShapeId, retirement);
        } else {
            throw malformed("rebuild replacement-or-retirement branch");
        }
        if (!after.retirements().equals(expectedRetirements)
                || !after.hashOwners().equals(exactHashOwners(after))) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Rebuild index or retirement delta is not exact");
        }
        for (Map.Entry<String, ShapeState> prior : before.shapes().entrySet()) {
            if (!prior.getKey().equals(oldShapeId)
                    && !prior.getKey().equals(newShapeId)
                    && !prior.getValue().equals(after.shapes().get(prior.getKey()))) {
                throw unexplained("rebuild unrelated shape frame");
            }
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
        if (changed
                || before.status() != Status.DIRTY
                || !before.dirty().isEmpty()
                || after.status() != Status.QUIESCENT
                || !after.dirty().isEmpty()
                || !difference.sameSemanticStateExceptIndexesAndDirty()
                || difference.hashChanged
                || difference.parentUsesChanged
                || after.revision() != before.revision()) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Rebuild completion is not the exact no-change quiescence transition");
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

    private static String leaderOf(Snapshot snapshot, String id) {
        String cursor = id;
        while (snapshot.parents().containsKey(cursor)) {
            cursor = snapshot.parents().get(cursor).parent();
        }
        return cursor;
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

    private ShapeState shapeForOwnerAndKey(
            Snapshot snapshot,
            String owner,
            String key) {
        ShapeState found = null;
        for (ShapeState shape : snapshot.shapes().values()) {
            if (!shape.owner().equals(owner)
                    || !termsKey(model.term(shape.termId())).equals(key)) {
                continue;
            }
            if (found != null) {
                throw new FormatException(
                        FailureCode.INVALID_COLLISION,
                        "One owner has duplicate records for an exact shape key");
            }
            found = shape;
        }
        if (found == null) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Hash owner lacks its exact shape witness record");
        }
        return found;
    }

    private boolean hasExactShapeEmbedding(
            Snapshot snapshot,
            ShapeState parent,
            ShapeState child) {
        KernelModel.Context parentContext = model.context(
                requireClass(snapshot, parent.owner()).contextId());
        KernelModel.Context childContext = model.context(
                requireClass(snapshot, child.owner()).contextId());
        KernelModel.Embedding parentOccurrence = model.embedding(
                parent.occurrenceEmbeddingId());
        KernelModel.Embedding childOccurrence = model.embedding(
                child.occurrenceEmbeddingId());
        KernelModel.Embedding parentAmbient = model.embedding(
                parent.ownerAmbientEmbeddingId());
        KernelModel.Embedding childAmbient = model.embedding(
                child.ownerAmbientEmbeddingId());
        if (!parentOccurrence.source().equals(childOccurrence.source())) {
            return false;
        }
        Map<String, String> parentOccurrenceInverse = inverseImages(parentOccurrence);
        Map<String, String> childAmbientInverse = inverseImages(childAmbient);
        for (KernelModel.Slot slot : parentContext.slots()) {
            String parentAmbientSlot = parentAmbient.images().get(slot.name());
            String canonical = parentOccurrenceInverse.get(parentAmbientSlot);
            if (canonical == null) {
                return false;
            }
            String childAmbientSlot = childOccurrence.images().get(canonical);
            String target = childAmbientInverse.get(childAmbientSlot);
            if (target == null
                    || !childContext.contains(target)
                    || !childContext.slot(target).type().equals(slot.type())) {
                return false;
            }
        }
        return true;
    }

    private static Map<String, String> inverseImages(KernelModel.Embedding embedding) {
        Map<String, String> inverse = new LinkedHashMap<>();
        for (Map.Entry<String, String> image : embedding.images().entrySet()) {
            if (inverse.put(image.getValue(), image.getKey()) != null) {
                throw new FormatException(
                        FailureCode.ILL_TYPED_EMBEDDING,
                        "Shape ambient embedding is not injective");
            }
        }
        return inverse;
    }

    private static String shapeId(String owner, String termId) {
        return "shape/" + Wire.contentId(Wire.leaf(
                "producer-shape-id", owner, termId));
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
        private final Set<String> addedSymmetries;
        private final Set<String> removedSymmetries;
        private final Set<String> changedSymmetries;
        private final Set<String> addedRetirements;
        private final Set<String> removedRetirements;
        private final Set<String> changedRetirements;
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
            addedSymmetries = added(before.symmetries(), after.symmetries());
            removedSymmetries = added(after.symmetries(), before.symmetries());
            changedSymmetries = changed(before.symmetries(), after.symmetries());
            addedRetirements = added(before.retirements(), after.retirements());
            removedRetirements = added(after.retirements(), before.retirements());
            changedRetirements = changed(before.retirements(), after.retirements());
            hashChanged = !before.hashOwners().equals(after.hashOwners());
            parentUsesChanged = !before.parentUses().equals(after.parentUses());
            dirtyChanged = !before.dirty().equals(after.dirty());
        }

        private boolean hasCoreMutation() {
            return !addedClasses.isEmpty() || !removedClasses.isEmpty()
                    || !changedClasses.isEmpty() || !addedParents.isEmpty()
                    || !removedParents.isEmpty() || !changedParents.isEmpty()
                    || !addedShapes.isEmpty() || !removedShapes.isEmpty()
                    || !changedShapes.isEmpty() || !addedRetirements.isEmpty()
                    || !removedRetirements.isEmpty() || !changedRetirements.isEmpty();
        }

        private boolean hasSymmetryMutation() {
            return !addedSymmetries.isEmpty() || !removedSymmetries.isEmpty()
                    || !changedSymmetries.isEmpty();
        }

        private boolean hasRetirementMutation() {
            return !addedRetirements.isEmpty() || !removedRetirements.isEmpty()
                    || !changedRetirements.isEmpty();
        }

        private boolean hasNonParentMutation() {
            return !addedClasses.isEmpty() || !removedClasses.isEmpty()
                    || !changedClasses.isEmpty() || !addedParents.isEmpty()
                    || !removedParents.isEmpty() || !addedShapes.isEmpty()
                    || !removedShapes.isEmpty() || !changedShapes.isEmpty()
                    || !addedSymmetries.isEmpty() || !removedSymmetries.isEmpty()
                    || !changedSymmetries.isEmpty() || !addedRetirements.isEmpty()
                    || !removedRetirements.isEmpty() || !changedRetirements.isEmpty() || hashChanged
                    || parentUsesChanged || dirtyChanged;
        }

        private boolean sameSemanticStateExceptIndexesAndDirty() {
            return addedClasses.isEmpty() && removedClasses.isEmpty()
                    && changedClasses.isEmpty() && addedParents.isEmpty()
                    && removedParents.isEmpty() && changedParents.isEmpty()
                    && addedShapes.isEmpty() && removedShapes.isEmpty()
                    && changedShapes.isEmpty() && addedSymmetries.isEmpty()
                    && removedSymmetries.isEmpty() && changedSymmetries.isEmpty()
                    && addedRetirements.isEmpty() && removedRetirements.isEmpty()
                    && changedRetirements.isEmpty();
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
