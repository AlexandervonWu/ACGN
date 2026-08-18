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

/** Bottom-up dependent equality kernel with no inverse congruence rule. */
final class KernelVerifier {
    enum Variant {
        REFL,
        SYM,
        TRANS,
        TRANSPORT,
        AXIOM,
        CONGRUENCE,
        RESTRICT,
        PARENT_EDGE,
        CONTAINER_NORMALIZE,
        STRUCTURAL_ALPHA,
        FULL_INTERFACE_SYMMETRY,
        KERNEL_REPLAY,
        FRESH_WITNESS,
        CANONICAL_ORBIT,
        COLLISION,
        REBUILD_CONGRUENCE
    }

    record Judgment(
            KernelModel.Context context,
            KernelModel.Sort sort,
            KernelModel.Term left,
            KernelModel.Term right) {
        Judgment {
            Objects.requireNonNull(context, "context");
            Objects.requireNonNull(sort, "sort");
            Objects.requireNonNull(left, "left");
            Objects.requireNonNull(right, "right");
            if (!left.context().equals(context) || !right.context().equals(context)
                    || !left.sort().equals(sort) || !right.sort().equals(sort)) {
                throw new FormatException(
                        FailureCode.ILL_TYPED_TERM,
                        "Synthesized equality has inconsistent context or sort");
            }
        }

        Judgment symmetric() {
            return new Judgment(context, sort, right, left);
        }
    }

    record ProofRecord(
            String id,
            Variant variant,
            KernelModel.Context claimedContext,
            KernelModel.Sort claimedSort,
            KernelModel.Term claimedLeft,
            KernelModel.Term claimedRight,
            List<String> premises,
            Wire.Node payload) {
    }

    private final KernelModel model;
    private final Limits limits;
    private final TermOps terms;
    private final Map<String, ProofRecord> records;
    private final Map<String, Judgment> checked = new HashMap<>();
    private final Set<String> active = new HashSet<>();

    KernelVerifier(KernelModel model, Limits limits) {
        this.model = Objects.requireNonNull(model, "model");
        this.limits = Objects.requireNonNull(limits, "limits");
        terms = new TermOps(model);
        records = parseProofs(model.bundle().proofs());
    }

    TermOps termOps() {
        return terms;
    }

    ProofRecord proofRecord(String id) {
        ProofRecord record = records.get(id);
        if (record == null) {
            throw new FormatException(
                    FailureCode.DANGLING_REFERENCE, "Unknown proof " + id);
        }
        return record;
    }

    Map<String, Judgment> verifyAll() {
        for (String id : records.keySet()) {
            verify(id);
        }
        return Collections.unmodifiableMap(new LinkedHashMap<>(checked));
    }

    Judgment verify(String id) {
        Judgment prior = checked.get(id);
        if (prior != null) {
            return prior;
        }
        ProofRecord record = records.get(id);
        if (record == null) {
            throw new FormatException(
                    FailureCode.DANGLING_REFERENCE, "Unknown proof " + id);
        }
        if (!active.add(id)) {
            throw new FormatException(
                    FailureCode.CYCLIC_PROOF_DAG, "Cyclic proof DAG at " + id);
        }
        try {
            List<Judgment> premises = record.premises().stream()
                    .map(this::verify).toList();
            Judgment synthesized = synthesize(record, premises);
            requireClaim(record, synthesized);
            checked.put(id, synthesized);
            return synthesized;
        } finally {
            active.remove(id);
        }
    }

    private Judgment synthesize(ProofRecord proof, List<Judgment> premises) {
        return switch (proof.variant()) {
            case REFL -> reflexivity(proof, premises);
            case SYM -> symmetry(proof, premises);
            case TRANS -> transitivity(proof, premises);
            case TRANSPORT -> transport(proof, premises);
            case AXIOM -> axiom(proof, premises);
            case CONGRUENCE -> congruence(proof, premises);
            case RESTRICT -> restrict(proof, premises);
            case PARENT_EDGE -> parentEdge(proof, premises);
            case CONTAINER_NORMALIZE -> containerNormalize(proof, premises);
            case STRUCTURAL_ALPHA -> structuralAlpha(proof, premises);
            case FULL_INTERFACE_SYMMETRY -> fullInterfaceSymmetry(proof, premises);
            case KERNEL_REPLAY -> kernelReplay(proof, premises);
            case FRESH_WITNESS -> freshWitness(proof, premises);
            case CANONICAL_ORBIT -> canonicalOrbit(proof, premises);
            case COLLISION -> collision(proof, premises);
            case REBUILD_CONGRUENCE -> rebuildCongruence(proof, premises);
        };
    }

    private Judgment reflexivity(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 0);
        proof.payload().requireShape("refl", 1, 0);
        KernelModel.Term term = model.term(proof.payload().scalar(0));
        return equality(term, term);
    }

    private Judgment symmetry(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 1);
        proof.payload().requireShape("sym", 0, 0);
        return premises.get(0).symmetric();
    }

    private Judgment transitivity(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 2);
        proof.payload().requireShape("trans", 0, 0);
        Judgment first = premises.get(0);
        Judgment second = premises.get(1);
        if (!first.context().equals(second.context())
                || !first.sort().equals(second.sort())
                || !first.right().id().equals(second.left().id())) {
            throw new FormatException(
                    FailureCode.TRANSITIVITY_MIDDLE_MISMATCH,
                    "Transitivity does not have an exact synthesized middle endpoint");
        }
        return new Judgment(first.context(), first.sort(), first.left(), second.right());
    }

    private Judgment transport(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 1);
        proof.payload().requireShape("transport", 1, 0);
        KernelModel.Embedding embedding = model.embedding(proof.payload().scalar(0));
        Judgment premise = premises.get(0);
        if (!premise.context().equals(embedding.source())) {
            throw new FormatException(
                    FailureCode.ILL_TYPED_EMBEDDING,
                    "Proof transport starts from the wrong context");
        }
        return new Judgment(
                embedding.target(),
                premise.sort(),
                terms.act(premise.left(), embedding),
                terms.act(premise.right(), embedding));
    }

    private Judgment axiom(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 0);
        Wire.Node payload = proof.payload().requireShape("axiom-instance", 2, 3);
        KernelModel.Axiom axiom = model.axiom(payload.scalar(0));
        KernelModel.Context context = model.context(payload.scalar(1));
        Map<String, String> typeSubstitution = parseTypeSubstitution(
                payload.child(0), axiom);
        Map<String, KernelModel.Term> termSubstitution = parseTermSubstitution(
                payload.child(1), axiom, typeSubstitution, context);
        checkSideConditions(
                payload.child(2), axiom, typeSubstitution, termSubstitution, context);
        KernelModel.Term left = terms.instantiate(
                axiom.left(), context, typeSubstitution, termSubstitution);
        KernelModel.Term right = terms.instantiate(
                axiom.right(), context, typeSubstitution, termSubstitution);
        return equality(left, right);
    }

    private Map<String, String> parseTypeSubstitution(
            Wire.Node node,
            KernelModel.Axiom axiom) {
        node.requireTag("type-substitution");
        if (!node.scalars().isEmpty()) {
            throw malformed("type substitution");
        }
        Map<String, String> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node child : node.children()) {
            child.requireShape("type-entry", 2, 0);
            prior = requireIncreasing(prior, child.scalar(0), "type substitution");
            if (result.put(child.scalar(0), child.scalar(1)) != null) {
                throw duplicate(child.scalar(0));
            }
        }
        if (!result.keySet().equals(axiom.typeVariables())) {
            throw new FormatException(
                    FailureCode.INVALID_SUBSTITUTION,
                    "Type substitution is not total and exact");
        }
        return result;
    }

    private Map<String, KernelModel.Term> parseTermSubstitution(
            Wire.Node node,
            KernelModel.Axiom axiom,
            Map<String, String> typeSubstitution,
            KernelModel.Context context) {
        node.requireTag("term-substitution");
        if (!node.scalars().isEmpty()) {
            throw malformed("term substitution");
        }
        Map<String, KernelModel.Term> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node child : node.children()) {
            child.requireShape("term-entry", 2, 0);
            prior = requireIncreasing(prior, child.scalar(0), "term substitution");
            KernelModel.Term term = model.term(child.scalar(1));
            KernelModel.Sort declared = axiom.termVariables().get(child.scalar(0));
            if (declared == null) {
                throw new FormatException(
                        FailureCode.INVALID_SUBSTITUTION,
                        "Unknown term variable " + child.scalar(0));
            }
            String expectedValue = declared.value().startsWith("$")
                    ? typeSubstitution.get(declared.value().substring(1))
                    : declared.value();
            if (!term.context().equals(context)
                    || !term.sort().equals(new KernelModel.Sort(
                            declared.kind(), expectedValue))) {
                throw new FormatException(
                        FailureCode.INVALID_SUBSTITUTION,
                        "Substitution for " + child.scalar(0) + " is ill typed");
            }
            if (result.put(child.scalar(0), term) != null) {
                throw duplicate(child.scalar(0));
            }
        }
        if (!result.keySet().equals(axiom.termVariables().keySet())) {
            throw new FormatException(
                    FailureCode.INVALID_SUBSTITUTION,
                    "Term substitution is not total and exact");
        }
        return result;
    }

    private void checkSideConditions(
            Wire.Node node,
            KernelModel.Axiom axiom,
            Map<String, String> typeSubstitution,
            Map<String, KernelModel.Term> termSubstitution,
            KernelModel.Context context) {
        node.requireTag("side-evidence");
        if (!node.scalars().isEmpty()
                || node.children().size() != axiom.sideConditions().size()) {
            throw new FormatException(
                    FailureCode.FAILED_SIDE_CONDITION,
                    "Side-condition evidence is incomplete");
        }
        for (int index = 0; index < axiom.sideConditions().size(); index++) {
            KernelModel.SideCondition condition = axiom.sideConditions().get(index);
            Wire.Node evidence = node.child(index).requireTag("evidence");
            if (evidence.scalars().isEmpty() || !evidence.children().isEmpty()
                    || !evidence.scalar(0).equals(condition.kind())
                    || !evidence.scalars().subList(1, evidence.scalars().size())
                            .equals(condition.arguments())) {
                throw new FormatException(
                        FailureCode.FAILED_SIDE_CONDITION,
                        "Side-condition evidence does not name the registered condition");
            }
            switch (condition.kind()) {
                case "DISTINCT_TERMS" -> {
                    requireArguments(condition, 2);
                    KernelModel.Term left = termSubstitution.get(condition.arguments().get(0));
                    KernelModel.Term right = termSubstitution.get(condition.arguments().get(1));
                    if (left == null || right == null || left.id().equals(right.id())) {
                        throw failedSide(condition);
                    }
                }
                case "NONEMPTY_CONTEXT" -> {
                    requireArguments(condition, 0);
                    if (context.slots().isEmpty()) {
                        throw failedSide(condition);
                    }
                }
                case "TYPE_EQUALS" -> {
                    requireArguments(condition, 2);
                    if (!Objects.equals(
                            typeSubstitution.get(condition.arguments().get(0)),
                            condition.arguments().get(1))) {
                        throw failedSide(condition);
                    }
                }
                default -> throw new FormatException(
                        FailureCode.UNKNOWN_VARIANT,
                        "Unknown side condition " + condition.kind());
            }
        }
    }

    private Judgment congruence(ProofRecord proof, List<Judgment> premises) {
        Wire.Node payload = proof.payload().requireShape("congruence", 2, 0);
        KernelModel.Term left = model.term(payload.scalar(0));
        KernelModel.Term right = model.term(payload.scalar(1));
        if (left.id().equals(right.id())) {
            throw new FormatException(
                    FailureCode.INVERSE_CONGRUENCE,
                    "Reflexivity must not be encoded as congruence");
        }
        if (left.kind() != right.kind()
                || !left.context().equals(right.context())
                || !left.sort().equals(right.sort())
                || !left.symbol().equals(right.symbol())
                || !left.attributes().equals(right.attributes())
                || left.children().size() != right.children().size()) {
            throw new FormatException(
                    FailureCode.INVERSE_CONGRUENCE,
                    "Forward congruence cannot change a constructor, slot, or binder descriptor");
        }
        List<TermPair> changed = new ArrayList<>();
        for (int index = 0; index < left.children().size(); index++) {
            KernelModel.Term leftChild = model.term(left.children().get(index));
            KernelModel.Term rightChild = model.term(right.children().get(index));
            if (!leftChild.id().equals(rightChild.id())) {
                changed.add(new TermPair(leftChild, rightChild));
            }
        }
        if (changed.isEmpty() || changed.size() != premises.size()) {
            throw new FormatException(
                    FailureCode.MISSING_CONGRUENCE_PREMISE,
                    "Congruence needs exactly one premise per changed direct child");
        }
        for (int index = 0; index < changed.size(); index++) {
            requireExact(premises.get(index), changed.get(index).left, changed.get(index).right,
                    FailureCode.MISSING_CONGRUENCE_PREMISE);
        }
        return equality(left, right);
    }

    private Judgment restrict(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 1);
        Wire.Node payload = proof.payload().requireShape("restriction", 3, 0);
        KernelModel.Witness oldWitness = model.witness(payload.scalar(0));
        KernelModel.Witness newWitness = model.witness(payload.scalar(1));
        KernelModel.Embedding inclusion = model.embedding(payload.scalar(2));
        KernelModel.Term left = oldWitness.definition();
        KernelModel.Term right = terms.act(newWitness.definition(), inclusion);
        if (inclusion.kind() != KernelModel.EmbeddingKind.INJECTION
                || !oldWitness.eclass().equals(newWitness.eclass())
                || !oldWitness.type().equals(newWitness.type())
                || !inclusion.source().equals(newWitness.context())
                || !inclusion.target().equals(oldWitness.context())
                || inclusion.source().slots().size()
                        >= inclusion.target().slots().size()) {
            throw new FormatException(
                    FailureCode.INVALID_CONTEXT_RESTRICTION,
                    "Restriction does not connect two versions through a strict inclusion");
        }
        for (KernelModel.Slot slot : inclusion.source().slots()) {
            if (!inclusion.apply(slot.name()).equals(slot.name())) {
                throw new FormatException(
                        FailureCode.INVALID_CONTEXT_RESTRICTION,
                        "Restriction embedding is not the literal inclusion");
            }
        }
        requireExact(premises.get(0), left, right,
                FailureCode.INVALID_CONTEXT_RESTRICTION);
        return equality(left, right);
    }

    private Judgment parentEdge(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 1);
        Wire.Node payload = proof.payload().requireShape("parent-edge", 3, 0);
        KernelModel.Witness child = model.witness(payload.scalar(0));
        KernelModel.Witness parent = model.witness(payload.scalar(1));
        KernelModel.Embedding embedding = model.embedding(payload.scalar(2));
        if (!embedding.source().equals(parent.context())
                || !embedding.target().equals(child.context())) {
            throw new FormatException(
                    FailureCode.INVALID_UNION, "Parent edge has the wrong typed embedding");
        }
        KernelModel.Embedding childIdentity = identityEmbedding(child.context());
        KernelModel.Term left = terms.intern(
                KernelModel.TermKind.INVOKE,
                child.context(),
                new KernelModel.Sort(KernelModel.SortKind.TERM, child.type()),
                child.id(),
                List.of(childIdentity.id()),
                List.of());
        KernelModel.Term right = terms.intern(
                KernelModel.TermKind.INVOKE,
                child.context(),
                new KernelModel.Sort(KernelModel.SortKind.TERM, parent.type()),
                parent.id(),
                List.of(embedding.id()),
                List.of());
        requireExact(premises.get(0), left, right, FailureCode.INVALID_UNION);
        return equality(left, right);
    }

    private Judgment containerNormalize(ProofRecord proof, List<Judgment> premises) {
        Wire.Node payload = proof.payload().requireTag("container-normalization");
        if (payload.scalars().size() != 3) {
            throw malformed("container normalization");
        }
        KernelModel.Term source = model.term(payload.scalar(1));
        KernelModel.Term target = model.term(payload.scalar(2));
        KernelModel.TermKind expectedKind = switch (payload.scalar(0)) {
            case "SEQ" -> KernelModel.TermKind.SEQ;
            case "BAG" -> KernelModel.TermKind.BAG;
            case "SET" -> KernelModel.TermKind.SET;
            default -> throw new FormatException(
                    FailureCode.UNKNOWN_VARIANT,
                    "Unknown container normalization " + payload.scalar(0));
        };
        if (source.kind() != expectedKind || target.kind() != expectedKind
                || !source.context().equals(target.context())
                || !source.sort().equals(target.sort())
                || !source.symbol().equals(target.symbol())
                || payload.children().size() != source.children().size()
                || premises.size() != source.children().size()) {
            throw new FormatException(
                    FailureCode.INVALID_CONTAINER_NORMALIZATION,
                    "Container occurrence evidence is incomplete");
        }
        List<KernelModel.Term> normalized = new ArrayList<>();
        Set<Integer> seen = new HashSet<>();
        for (int index = 0; index < payload.children().size(); index++) {
            Wire.Node occurrence = payload.child(index).requireShape("occurrence", 2, 0);
            int sourceIndex = parseIndex(occurrence.scalar(0), "occurrence index");
            if (sourceIndex >= source.children().size() || !seen.add(sourceIndex)
                    || !proof.premises().get(index).equals(occurrence.scalar(1))) {
                throw new FormatException(
                        FailureCode.INVALID_CONTAINER_NORMALIZATION,
                        "Container occurrence map is not total and unique");
            }
            KernelModel.Term sourceChild = model.term(source.children().get(sourceIndex));
            Judgment premise = premises.get(index);
            if (!premise.left().id().equals(sourceChild.id())) {
                throw new FormatException(
                        FailureCode.INVALID_CONTAINER_NORMALIZATION,
                        "Occurrence proof starts at another child");
            }
            normalized.add(premise.right());
        }
        if (expectedKind == KernelModel.TermKind.BAG
                || expectedKind == KernelModel.TermKind.SET) {
            normalized.sort(java.util.Comparator.comparing(KernelModel.Term::id));
        }
        if (expectedKind == KernelModel.TermKind.SET) {
            List<KernelModel.Term> unique = new ArrayList<>();
            String prior = null;
            for (KernelModel.Term term : normalized) {
                if (!term.id().equals(prior)) {
                    unique.add(term);
                    prior = term.id();
                }
            }
            normalized = unique;
        }
        KernelModel.Term synthesized = terms.intern(
                source.kind(), source.context(), source.sort(), source.symbol(),
                source.attributes(), normalized);
        if (!synthesized.id().equals(target.id())) {
            throw new FormatException(
                    FailureCode.INVALID_CONTAINER_NORMALIZATION,
                    expectedKind + " result differs from occurrence normalization");
        }
        return equality(source, target);
    }

    private Judgment structuralAlpha(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 0);
        Wire.Node payload = proof.payload().requireShape("structural-alpha", 2, 0);
        KernelModel.Term left = model.term(payload.scalar(0));
        KernelModel.Term right = model.term(payload.scalar(1));
        if (!terms.alphaKey(left).equals(terms.alphaKey(right))) {
            throw new FormatException(
                    FailureCode.INVALID_STRUCTURAL_ALPHA,
                    "Endpoints are not independently alpha equivalent");
        }
        return equality(left, right);
    }

    private Judgment fullInterfaceSymmetry(
            ProofRecord proof,
            List<Judgment> premises) {
        requirePremiseCount(proof, premises, 0);
        Wire.Node payload = proof.payload().requireShape(
                "full-interface-symmetry", 2, 0);
        KernelModel.Embedding permutation = model.embedding(payload.scalar(0));
        KernelModel.Term left = model.term(payload.scalar(1));
        if (permutation.kind() != KernelModel.EmbeddingKind.BIJECTION
                || !permutation.source().equals(permutation.target())
                || !permutation.source().equals(left.context())) {
            throw new FormatException(
                    FailureCode.INVALID_SYMMETRY,
                    "SC evidence is not a full-interface typed permutation");
        }
        KernelModel.Term acted = terms.act(left, permutation);
        if (!terms.alphaKey(left).equals(terms.alphaKey(acted))) {
            throw new FormatException(
                    FailureCode.INVALID_SYMMETRY,
                    "Full-interface action does not synthesize the claimed endpoint");
        }
        return equality(left, acted);
    }

    private Judgment kernelReplay(ProofRecord proof, List<Judgment> premises) {
        return new SourceToKernelVerifier(model, this, limits).verify(proof, premises);
    }

    private Judgment freshWitness(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 1);
        Wire.Node payload = proof.payload().requireShape("fresh-witness", 4, 0);
        KernelModel.Witness fresh = model.witness(payload.scalar(0));
        KernelModel.Term kernel = model.term(payload.scalar(1));
        KernelModel.Embedding inclusion = model.embedding(payload.scalar(2));
        if (!proof.premises().get(0).equals(payload.scalar(3))) {
            throw new FormatException(
                    FailureCode.INVALID_FRESH_WITNESS,
                    "Fresh witness names another kernel replay");
        }
        ProofRecord replayRecord = proofRecord(payload.scalar(3));
        if (replayRecord.variant() != Variant.KERNEL_REPLAY) {
            throw new FormatException(
                    FailureCode.INVALID_FRESH_WITNESS,
                    "Fresh witness premise is not a typed kernel replay");
        }
        Wire.Node replay = replayRecord.payload().requireShape(
                "kernel-replay", 7, 4);
        if (!kernel.id().equals(replay.scalar(2))
                || !fresh.context().id().equals(replay.scalar(3))
                || !inclusion.id().equals(replay.scalar(4))) {
            throw new FormatException(
                    FailureCode.INVALID_FRESH_WITNESS,
                    "Fresh class does not use the replay's exact K, Delta, and iota");
        }
        if (!fresh.definition().id().equals(kernel.id())
                || !fresh.context().equals(kernel.context())
                || !inclusion.source().equals(kernel.context())
                || !inclusion.target().equals(premises.get(0).context())) {
            throw new FormatException(
                    FailureCode.INVALID_FRESH_WITNESS,
                    "Fresh class is not allocated exactly at effective support");
        }
        return equality(kernel, fresh.definition());
    }

    private Judgment canonicalOrbit(ProofRecord proof, List<Judgment> premises) {
        requirePremiseCount(proof, premises, 0);
        new CanonicalProfileVerifier(model, this, limits)
                .verifyOrbitPayload(proof.payload(), proof.claimedLeft(), proof.claimedRight());
        return equality(
                model.term(proof.payload().scalar(0)),
                model.term(proof.payload().scalar(2)));
    }

    private Judgment collision(ProofRecord proof, List<Judgment> premises) {
        if (premises.size() < 2) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Collision requires independent replay evidence for both sides");
        }
        requirePremiseCount(proof, premises, 2);
        Wire.Node payload = proof.payload().requireShape("collision", 4, 0);
        if (!proof.premises().get(0).equals(payload.scalar(0))
                || !proof.premises().get(1).equals(payload.scalar(1))
                || !payload.scalar(2).equals(payload.scalar(3))) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Collision lacks both replay proofs or complete equal shape keys");
        }
        Judgment leftReplay = premises.get(0);
        Judgment rightReplay = premises.get(1);
        if (!leftReplay.right().id().equals(rightReplay.right().id())) {
            throw new FormatException(
                    FailureCode.INVALID_COLLISION,
                    "Collision replay proofs do not reach a common exact kernel");
        }
        return equality(leftReplay.left(), rightReplay.left());
    }

    private Judgment rebuildCongruence(ProofRecord proof, List<Judgment> premises) {
        Wire.Node payload = proof.payload().requireShape("rebuild-congruence", 1, 0);
        if (premises.isEmpty()) {
            throw new UncheckableException(
                    FailureCode.MISSING_EVIDENCE,
                    "Rebuild congruence has no child/path evidence");
        }
        // Rebuild is forward only: the supplied first premise must be exact endpoint
        // congruence, and the remaining premises are replay/orbit obligations.
        if (!payload.scalar(0).equals(proof.premises().get(0))) {
            throw new FormatException(
                    FailureCode.INVALID_REBUILD,
                    "Rebuild forward-congruence premise is not identified explicitly");
        }
        return premises.get(0);
    }

    private Map<String, ProofRecord> parseProofs(Map<String, Wire.Node> nodes) {
        Map<String, ProofRecord> result = new LinkedHashMap<>();
        for (Wire.Node node : nodes.values()) {
            if (node.scalars().size() != 7 || node.children().size() != 2) {
                throw malformed("proof");
            }
            Wire.Node premiseList = node.child(0).requireTag("premises");
            if (!premiseList.scalars().isEmpty()) {
                throw malformed("proof premises");
            }
            List<String> premises = new ArrayList<>();
            for (Wire.Node premise : premiseList.children()) {
                premises.add(premise.requireShape("proof-ref", 1, 0).scalar(0));
            }
            ProofRecord record = new ProofRecord(
                    node.scalar(0),
                    enumValue(Variant.class, node.scalar(1)),
                    model.context(node.scalar(2)),
                    new KernelModel.Sort(
                            enumValue(KernelModel.SortKind.class, node.scalar(3)),
                            node.scalar(4)),
                    model.term(node.scalar(5)),
                    model.term(node.scalar(6)),
                    List.copyOf(premises),
                    node.child(1));
            result.put(record.id(), record);
        }
        for (ProofRecord record : result.values()) {
            for (String premise : record.premises()) {
                if (!result.containsKey(premise)) {
                    throw new FormatException(
                            FailureCode.DANGLING_REFERENCE,
                            "Proof " + record.id() + " references missing " + premise);
                }
            }
        }
        return Collections.unmodifiableMap(result);
    }

    private void requireClaim(ProofRecord proof, Judgment synthesized) {
        if (!proof.claimedContext().equals(synthesized.context())
                || !proof.claimedSort().equals(synthesized.sort())
                || !proof.claimedLeft().id().equals(synthesized.left().id())
                || !proof.claimedRight().id().equals(synthesized.right().id())) {
            throw new FormatException(
                    FailureCode.ENDPOINT_CLAIM_MISMATCH,
                    "Producer endpoint claim differs from synthesized judgment for "
                            + proof.id());
        }
    }

    private static Judgment equality(KernelModel.Term left, KernelModel.Term right) {
        if (!left.context().equals(right.context()) || !left.sort().equals(right.sort())) {
            throw new FormatException(
                    FailureCode.ILL_TYPED_TERM,
                    "Equality endpoints have different context or sort");
        }
        return new Judgment(left.context(), left.sort(), left, right);
    }

    private static void requireExact(
            Judgment judgment,
            KernelModel.Term left,
            KernelModel.Term right,
            FailureCode code) {
        if (!judgment.left().id().equals(left.id())
                || !judgment.right().id().equals(right.id())) {
            throw new FormatException(code, "Proof endpoints do not match required equation");
        }
    }

    private static void requirePremiseCount(
            ProofRecord proof,
            List<Judgment> premises,
            int expected) {
        if (premises.size() != expected) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE,
                    proof.variant() + " requires " + expected + " premises");
        }
    }

    private KernelModel.Embedding identityEmbedding(KernelModel.Context context) {
        Map<String, String> images = new LinkedHashMap<>();
        for (KernelModel.Slot slot : context.slots()) {
            images.put(slot.name(), slot.name());
        }
        String id = TermOps.embeddingId(
                KernelModel.EmbeddingKind.BIJECTION, context, context, images);
        KernelModel.Embedding identity = model.embedding(id);
        if (identity.kind() != KernelModel.EmbeddingKind.BIJECTION
                || !identity.images().equals(images)) {
            throw new FormatException(
                    FailureCode.INVALID_UNION,
                    "Parent edge omits the exact child-interface identity");
        }
        return identity;
    }

    private void requireInvocation(
            KernelModel.Term term,
            String witness,
            KernelModel.Context context,
            boolean identity) {
        if (term.kind() != KernelModel.TermKind.INVOKE
                || !term.symbol().equals(witness)
                || !term.context().equals(context)
                || term.attributes().size() != 1) {
            throw new FormatException(
                    FailureCode.INVALID_UNION, "Parent edge endpoint is not an invocation");
        }
        if (identity) {
            KernelModel.Embedding embedding = model.embedding(term.attributes().get(0));
            if (embedding.kind() != KernelModel.EmbeddingKind.BIJECTION
                    || !embedding.source().equals(context)
                    || !embedding.target().equals(context)) {
                throw new FormatException(
                        FailureCode.INVALID_UNION,
                        "Child endpoint is not an identity-context witness");
            }
            for (KernelModel.Slot slot : context.slots()) {
                if (!embedding.apply(slot.name()).equals(slot.name())) {
                    throw new FormatException(
                            FailureCode.INVALID_UNION,
                            "Child witness invocation is not identity");
                }
            }
        }
    }

    private static void requireArguments(KernelModel.SideCondition condition, int count) {
        if (condition.arguments().size() != count) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE,
                    "Side condition " + condition.kind() + " has wrong arity");
        }
    }

    private static FormatException failedSide(KernelModel.SideCondition condition) {
        return new FormatException(
                FailureCode.FAILED_SIDE_CONDITION,
                "Side condition failed: " + condition.kind());
    }

    private static int parseIndex(String text, String field) {
        long value = Bundle.parseUnsignedLong(text, field);
        if (value > Integer.MAX_VALUE) {
            throw new FormatException(FailureCode.INTEGER_OVERFLOW, field + " too large");
        }
        return (int) value;
    }

    private static String requireIncreasing(String prior, String next, String field) {
        if (prior != null && prior.compareTo(next) >= 0) {
            throw new FormatException(
                    prior.equals(next) ? FailureCode.DUPLICATE_ID
                            : FailureCode.NONCANONICAL_ENCODING,
                    field + " is duplicated or unsorted");
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

    private static FormatException duplicate(String value) {
        return new FormatException(FailureCode.DUPLICATE_ID, "Duplicate " + value);
    }

    private record TermPair(KernelModel.Term left, KernelModel.Term right) {
    }
}
