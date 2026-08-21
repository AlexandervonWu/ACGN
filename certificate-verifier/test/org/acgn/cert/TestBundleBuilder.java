package org.acgn.cert;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Direct DTO/byte builder used only by adversarial verifier tests. */
final class TestBundleBuilder {
    private static final String ZERO_SHA256 = "0".repeat(64);
    private static final String ONE_SHA256 = "1".repeat(64);
    private final List<Wire.Node> contexts = new ArrayList<>();
    private final List<Wire.Node> embeddings = new ArrayList<>();
    private final List<Wire.Node> terms = new ArrayList<>();
    private final List<Wire.Node> proofs = new ArrayList<>();
    private final List<Wire.Node> witnesses = new ArrayList<>();
    private final List<Wire.Node> snapshots = new ArrayList<>();
    private final List<Wire.Node> events = new ArrayList<>();
    private final List<Wire.Node> canonicalRecords = new ArrayList<>();
    private final List<Wire.Node> unfoldings = new ArrayList<>();
    private final List<Wire.Node> schemas = new ArrayList<>();
    private final List<Wire.Node> operators = new ArrayList<>();
    private final List<Wire.Node> binders = new ArrayList<>();
    private final List<Wire.Node> axioms = new ArrayList<>();
    private final Map<String, Wire.Node> exactTypes = new java.util.TreeMap<>();
    private final List<Wire.Node> lawCertificates = new ArrayList<>();
    private final Map<String, Map<String, String>> shapeAliasesBySnapshot =
            new LinkedHashMap<>();
    private List<String> semanticScalars;
    private String metadataMode = "TEST_ONLY";
    private boolean metadataDirty = true;
    private boolean deriveShapeIds = true;
    private boolean omitShapeOwnerProof;
    private Wire.Node publication;

    void preserveProvidedShapeIdsForNegativeTest() {
        deriveShapeIds = false;
    }

    void omitShapeOwnerProofForNegativeTest() {
        omitShapeOwnerProof = true;
    }

    Wire.Node context(List<Wire.Node> slots) {
        Wire.Node record = Bundle.withContentId("context", List.of(), slots);
        addContentAddressed(contexts, record);
        return record;
    }

    Wire.Node embedding(
            String kind,
            Wire.Node source,
            Wire.Node target,
            Map<String, String> images) {
        List<Wire.Node> children = new ArrayList<>();
        for (Wire.Node slot : source.children()) {
            children.add(Wire.leaf("image", slot.scalar(0), images.get(slot.scalar(0))));
        }
        Wire.Node record = Bundle.withContentId(
                "embedding",
                List.of(kind, source.scalar(0), target.scalar(0)),
                children);
        addContentAddressed(embeddings, record);
        return record;
    }

    Wire.Node identity(Wire.Node context) {
        Map<String, String> images = new LinkedHashMap<>();
        for (Wire.Node slot : context.children()) {
            images.put(slot.scalar(0), slot.scalar(0));
        }
        return embedding("BIJECTION", context, context, images);
    }

    Wire.Node schema(String id, String kind, String value, String child) {
        boolean container = kind.equals("SEQ") || kind.equals("BAG") || kind.equals("SET");
        String quotient = switch (kind) {
            case "SEQ" -> "ORDERED_SEQUENCE";
            case "BAG" -> "COMMUTATIVE_BAG";
            case "SET" -> "COMMUTATIVE_IDEMPOTENT_SET";
            default -> "RIGID";
        };
        return schema(
                id, kind, value, child,
                container ? "AT_LEAST:0" : "FINITE:1", quotient);
    }

    Wire.Node schema(
            String id,
            String kind,
            String value,
            String child,
            String arity,
            String quotient) {
        Wire.Node record = Wire.node(
                "schema",
                List.of(id, kind, value, arity, quotient),
                child.isEmpty() ? List.of() : List.of(Wire.leaf("schema-ref", child)));
        schemas.add(record);
        return record;
    }

    Wire.Node operator(String id, String outputType, String... portSchemas) {
        return operator(id, outputType, id, "none", portSchemas);
    }

    Wire.Node operator(
            String id,
            String outputType,
            String semanticIdentity,
            String flatPath,
            String... portSchemas) {
        Wire.Node record = Wire.node(
                "operator",
                List.of(id, outputType, semanticIdentity, flatPath),
                java.util.Arrays.stream(portSchemas)
                        .map(schema -> Wire.leaf("schema-ref", schema)).toList());
        operators.add(record);
        return record;
    }

    void publicationSemanticEvidence(List<String> scalars) {
        if (scalars.size() != 8) {
            throw new IllegalArgumentException("Semantic evidence requires eight scalars");
        }
        semanticScalars = List.copyOf(scalars);
        metadataMode = "PUBLICATION";
        metadataDirty = false;
    }

    void lawCertificate(Wire.Node certificate) {
        lawCertificates.add(certificate.requireShape("law-certificate", 17, 0));
    }

    String exactType(String kind, String symbol, String... argumentIds) {
        Wire.Node record = Bundle.withContentId(
                "exact-type",
                List.of(kind, symbol),
                java.util.Arrays.stream(argumentIds)
                        .map(id -> Wire.leaf("type-ref", id)).toList());
        Wire.Node prior = exactTypes.putIfAbsent(record.scalar(0), record);
        if (prior != null && !prior.equals(record)) {
            throw new AssertionError("test exact-type content-ID collision");
        }
        return record.scalar(0);
    }

    String runtimeType(String display, String kind, String symbol) {
        return metadataMode.equals("PUBLICATION")
                ? exactType(kind, symbol) : display;
    }

    Wire.Node binder(
            String id,
            List<Wire.Node> coordinates,
            List<Wire.Node> generators) {
        List<Wire.Node> normalized = new ArrayList<>();
        for (Wire.Node coordinate : coordinates) {
            if (coordinate.tag().equals("coordinate")
                    && coordinate.scalars().size() == 6
                    && coordinate.children().isEmpty()) {
                normalized.add(Wire.node(
                        "coordinate",
                        List.of(
                                coordinate.scalar(0), coordinate.scalar(1),
                                coordinate.scalar(2), coordinate.scalar(3),
                                coordinate.scalar(4), coordinate.scalar(5),
                                "SET", "0"),
                        List.of(Wire.node("dependencies", List.of(), List.of()))));
            } else {
                normalized.add(coordinate);
            }
        }
        List<Wire.Node> children = new ArrayList<>(normalized);
        children.addAll(generators);
        Wire.Node record = Wire.node("binder", List.of(id), children);
        binders.add(record);
        return record;
    }

    Wire.Node axiom(
            String id,
            Wire.Node left,
            Wire.Node right,
            List<String> typeVariables,
            List<Wire.Node> termVariables,
            List<Wire.Node> sideConditions) {
        Wire.Node record = Wire.node(
                "axiom",
                List.of(id),
                List.of(
                        left,
                        right,
                        Wire.node("type-variables", typeVariables, List.of()),
                        Wire.node("term-variables", termVariables),
                        Wire.node("side-conditions", sideConditions)));
        axioms.add(record);
        return record;
    }

    Wire.Node term(
            String kind,
            Wire.Node context,
            String sortKind,
            String sortValue,
            String symbol,
            List<String> attributes,
            Wire.Node... children) {
        List<String> scalars = new ArrayList<>(List.of(
                kind, context.scalar(0), sortKind, sortValue, symbol));
        scalars.addAll(attributes);
        Wire.Node record = Bundle.withContentId(
                "term",
                scalars,
                java.util.Arrays.stream(children)
                        .map(child -> Wire.leaf("term-ref", child.scalar(0))).toList());
        addContentAddressed(terms, record);
        return record;
    }

    Wire.Node proof(
            String variant,
            Wire.Node context,
            String sortKind,
            String sortValue,
            Wire.Node left,
            Wire.Node right,
            List<Wire.Node> premiseProofs,
            Wire.Node payload) {
        return proof(
                variant,
                context,
                sortKind,
                sortValue,
                left,
                right,
                premiseProofs,
                payload,
                true);
    }

    private Wire.Node proof(
            String variant,
            Wire.Node context,
            String sortKind,
            String sortValue,
            Wire.Node left,
            Wire.Node right,
            List<Wire.Node> premiseProofs,
            Wire.Node payload,
            boolean add) {
        payload = completePhaseThreePayload(variant, payload);
        Wire.Node record = Bundle.withContentId(
                "proof",
                List.of(variant, context.scalar(0), sortKind, sortValue,
                        left.scalar(0), right.scalar(0)),
                List.of(
                        Wire.node("premises", premiseProofs.stream()
                                .map(proof -> Wire.leaf("proof-ref", proof.scalar(0)))
                                .toList()),
                        payload));
        if (add) {
            addContentAddressed(proofs, record);
        }
        return record;
    }

    private Wire.Node completePhaseThreePayload(
            String variant,
            Wire.Node payload) {
        if (variant.equals("KERNEL_REPLAY")
                && payload.tag().equals("kernel-replay")
                && payload.scalars().size() == 7
                && payload.children().size() == 4) {
            List<Wire.Node> children = new ArrayList<>(payload.children());
            children.add(Wire.leaf(
                    "source-construction", "NONE", "", "", ""));
            return Wire.node(payload.tag(), payload.scalars(), children);
        }
        if (variant.equals("CANONICAL_ORBIT")
                && payload.tag().equals("canonical-orbit")
                && payload.scalars().size() == 4
                && payload.children().size() == 3) {
            String targetContext = payload.scalar(1);
            String identity = embeddings.stream()
                    .filter(embedding -> embedding.scalar(1).equals("BIJECTION"))
                    .filter(embedding -> embedding.scalar(2).equals(targetContext))
                    .filter(embedding -> embedding.scalar(3).equals(targetContext))
                    .filter(TestBundleBuilder::isIdentityEmbedding)
                    .map(embedding -> embedding.scalar(0))
                    .findFirst()
                    .orElseThrow(() -> new AssertionError(
                            "Canonical test fixture lacks its identity witness"));
            List<Wire.Node> children = new ArrayList<>(payload.children());
            Wire.Node oldMinimum = children.get(2).requireTag("orbit-minimum");
            if (!oldMinimum.scalars().isEmpty()
                    || oldMinimum.children().size() != 1) {
                throw new AssertionError("Malformed legacy canonical test minimum");
            }
            children.set(2, Wire.node(
                    "orbit-minimum",
                    List.of(
                            oldMinimum.child(0),
                            Wire.leaf("embedding-ref", identity))));
            children.add(Wire.node("binder-occurrence-refs", List.of()));
            return Wire.node(
                    payload.tag(),
                    List.of(
                            payload.scalar(0),
                            payload.scalar(0),
                            targetContext,
                            payload.scalar(2),
                            identity,
                            payload.scalar(3)),
                    children);
        }
        if (variant.equals("CONTAINER_NORMALIZE")
                && payload.tag().equals("container-normalization")
                && payload.scalars().size() == 3) {
            List<String> scalars = new ArrayList<>(payload.scalars());
            scalars.add("test-only/operator");
            scalars.add("0/0");
            return Wire.node(payload.tag(), scalars, payload.children());
        }
        return payload;
    }

    private static boolean isIdentityEmbedding(Wire.Node embedding) {
        for (Wire.Node image : embedding.children()) {
            image.requireShape("image", 2, 0);
            if (!image.scalar(0).equals(image.scalar(1))) {
                return false;
            }
        }
        return true;
    }

    Wire.Node witness(
            String id,
            long revision,
            String eclass,
            Wire.Node context,
            String type,
            Wire.Node definition) {
        Wire.Node record = Wire.leaf(
                "witness", id, Long.toString(revision), eclass,
                context.scalar(0), type, definition.scalar(0));
        witnesses.add(record);
        return record;
    }

    Wire.Node snapshot(
            long revision,
            String status,
            List<Wire.Node> classes,
            List<Wire.Node> parents,
            List<Wire.Node> shapes,
            List<Wire.Node> hashes,
            List<Wire.Node> parentUses,
            List<Wire.Node> symmetries,
            List<Wire.Node> dirty) {
        return snapshot(
                revision, status, classes, parents, shapes, hashes, parentUses,
                symmetries, List.of(), dirty);
    }

    Wire.Node snapshot(
            long revision,
            String status,
            List<Wire.Node> classes,
            List<Wire.Node> parents,
            List<Wire.Node> shapes,
            List<Wire.Node> hashes,
            List<Wire.Node> parentUses,
            List<Wire.Node> symmetries,
            List<Wire.Node> retirements,
            List<Wire.Node> dirty) {
        Map<String, String> shapeAliases = new LinkedHashMap<>();
        List<Wire.Node> normalizedShapes = new ArrayList<>();
        for (Wire.Node shape : shapes) {
            if (!shape.tag().equals("shape")
                    || (shape.scalars().size() != 4
                            && shape.scalars().size() != 5
                            && shape.scalars().size() != 7)
                    || !shape.children().isEmpty()) {
                throw new AssertionError("malformed fixture shape");
            }
            String expected = deriveShapeIds
                    ? shapeId(shape.scalar(1), shape.scalar(2))
                    : shape.scalar(0);
            String prior = shapeAliases.put(shape.scalar(0), expected);
            if (prior != null && !prior.equals(expected)) {
                throw new AssertionError("one fixture shape alias names two records");
            }
            String occurrence = shape.scalars().size() >= 5
                    ? shape.scalar(4)
                    : identity(contextForTerm(shape.scalar(2))).scalar(0);
            Wire.Node occurrenceEmbedding = embeddingById(occurrence);
            Wire.Node ownerContext = ownerContext(classes, shape.scalar(1));
            String ownerAmbient = shape.scalars().size() == 7
                    ? shape.scalar(5)
                    : inclusionByName(ownerContext, contextById(
                            occurrenceEmbedding.scalar(3))).scalar(0);
            String ownerProof = shape.scalars().size() == 7
                    ? shape.scalar(6)
                    : defaultShapeOwnerProof(
                            shape.scalar(1), shape.scalar(2), occurrence,
                            ownerAmbient, classes).scalar(0);
            normalizedShapes.add(omitShapeOwnerProof
                    ? Wire.leaf(
                            "shape", expected, shape.scalar(1), shape.scalar(2),
                            shape.scalar(3), occurrence, ownerAmbient)
                    : Wire.leaf(
                            "shape", expected, shape.scalar(1), shape.scalar(2),
                            shape.scalar(3), occurrence, ownerAmbient, ownerProof));
        }
        List<Wire.Node> normalizedParentUses = rewriteScalars(parentUses, shapeAliases);
        List<Wire.Node> normalizedRetirements = rewriteScalars(retirements, shapeAliases);
        List<Wire.Node> normalizedDirty = rewriteScalars(dirty, shapeAliases);
        Wire.Node record = Bundle.withContentId(
                "snapshot",
                List.of(Long.toString(revision), status),
                List.of(
                        sortedSection("classes", classes),
                        sortedSection("parents", parents),
                        sortedSection("shapes", normalizedShapes),
                        sortedPairSection("hash-cons", hashes),
                        sortedSection("parent-uses", normalizedParentUses),
                        sortedSection("symmetries", symmetries),
                        Wire.node(
                                "maintenance",
                                List.of(
                                        sortedSection("retirements", normalizedRetirements),
                                        sortedSection("dirty", normalizedDirty)))));
        addContentAddressed(snapshots, record);
        shapeAliasesBySnapshot.put(record.scalar(0), Map.copyOf(shapeAliases));
        return record;
    }

    private Wire.Node defaultShapeOwnerProof(
            String owner,
            String termId,
            String occurrenceId,
            String ownerAmbientId,
            List<Wire.Node> classes) {
        Wire.Node shapeTerm = termById(termId);
        Wire.Node occurrence = embeddingById(occurrenceId);
        Wire.Node ownerAmbient = embeddingById(ownerAmbientId);
        if (!isIdentityEmbedding(occurrence)) {
            throw new AssertionError(
                    "nonidentity fixture occurrence requires an explicit owner proof");
        }
        Wire.Node ownerWitness = witnessById(ownerWitnessId(classes, owner));
        Wire.Node ownerDefinition = termById(ownerWitness.scalar(5));
        Wire.Node installedOwner = actedNullary(ownerDefinition, ownerAmbient);
        if (!shapeTerm.scalar(0).equals(installedOwner.scalar(0))) {
            throw new AssertionError(
                    "nontrivial fixture shape ownership requires an explicit proof: shape="
                            + shapeTerm + ", owner=" + installedOwner);
        }
        return proof(
                "REFL",
                contextById(shapeTerm.scalar(2)),
                shapeTerm.scalar(3),
                shapeTerm.scalar(4),
                shapeTerm,
                shapeTerm,
                List.of(),
                Wire.leaf("refl", shapeTerm.scalar(0)));
    }

    private Wire.Node actedNullary(Wire.Node source, Wire.Node embedding) {
        if (embedding.scalar(2).equals(embedding.scalar(3))
                && isIdentityEmbedding(embedding)) {
            return source;
        }
        if (!source.scalar(1).equals("APP") || !source.children().isEmpty()) {
            throw new AssertionError(
                    "non-nullary fixture owner action requires an explicit proof");
        }
        return term(
                "APP",
                contextById(embedding.scalar(3)),
                source.scalar(3),
                source.scalar(4),
                source.scalar(5),
                source.scalars().subList(6, source.scalars().size()));
    }

    private Wire.Node inclusionByName(Wire.Node source, Wire.Node target) {
        Map<String, String> images = new LinkedHashMap<>();
        for (Wire.Node slot : source.children()) {
            String name = slot.scalar(0);
            boolean present = target.children().stream().anyMatch(candidate ->
                    candidate.scalar(0).equals(name)
                            && candidate.scalar(1).equals(slot.scalar(1)));
            if (!present) {
                throw new AssertionError(
                        "fixture owner context does not embed by name into shape ambient context");
            }
            images.put(name, name);
        }
        String kind = source.children().size() == target.children().size()
                ? "BIJECTION" : "INJECTION";
        return embedding(kind, source, target, images);
    }

    private Wire.Node ownerContext(List<Wire.Node> classes, String owner) {
        for (Wire.Node eclass : classes) {
            if (eclass.scalar(0).equals(owner)) {
                return contextById(eclass.scalar(2));
            }
        }
        throw new AssertionError("fixture shape owner has no class record");
    }

    private static String ownerWitnessId(List<Wire.Node> classes, String owner) {
        for (Wire.Node eclass : classes) {
            if (eclass.scalar(0).equals(owner)) {
                return eclass.scalar(1);
            }
        }
        throw new AssertionError("fixture shape owner has no witness record");
    }

    private Wire.Node witnessById(String id) {
        return witnesses.stream()
                .filter(node -> node.scalar(0).equals(id))
                .findFirst()
                .orElseThrow(() -> new AssertionError("missing fixture witness " + id));
    }

    private Wire.Node termById(String id) {
        return terms.stream()
                .filter(node -> node.scalar(0).equals(id))
                .findFirst()
                .orElseThrow(() -> new AssertionError("missing fixture term " + id));
    }

    private Wire.Node embeddingById(String id) {
        return embeddings.stream()
                .filter(node -> node.scalar(0).equals(id))
                .findFirst()
                .orElseThrow(() -> new AssertionError("missing fixture embedding " + id));
    }

    private Wire.Node contextById(String id) {
        return contexts.stream()
                .filter(node -> node.scalar(0).equals(id))
                .findFirst()
                .orElseThrow(() -> new AssertionError("missing fixture context " + id));
    }

    void event(
            int sequence,
            String kind,
            Wire.Node before,
            Wire.Node after,
            Wire.Node payload) {
        Map<String, String> aliases = new LinkedHashMap<>();
        boolean afterIdentity = kind.equals("INSERT_FRESH")
                || kind.equals("INSERT_COLLISION");
        Map<String, String> primary = shapeAliasesBySnapshot.getOrDefault(
                afterIdentity ? after.scalar(0) : before.scalar(0), Map.of());
        Map<String, String> secondary = shapeAliasesBySnapshot.getOrDefault(
                afterIdentity ? before.scalar(0) : after.scalar(0), Map.of());
        aliases.putAll(secondary);
        aliases.putAll(primary);
        events.add(Wire.node(
                "event",
                List.of(Integer.toString(sequence), kind,
                        before.scalar(0), after.scalar(0)),
                List.of(rewriteScalars(payload, aliases))));
    }

    Wire.Node canonicalRecord(
            Wire.Node orbitProof,
            Wire.Node representative,
            Wire.Node replayProof) {
        Wire.Node record = Bundle.withContentId(
                "canonical-record",
                List.of(orbitProof.scalar(0), representative.scalar(0)),
                List.of(Wire.leaf("source-replay-ref", replayProof.scalar(0))));
        addContentAddressed(canonicalRecords, record);
        return record;
    }

    Wire.Node unfolding(
            Wire.Node root,
            int height,
            Wire.Node normalized,
            Wire.Node snapshot,
            Wire.Node rep) {
        Wire.Node normalizedRep = rewriteScalars(
                rep,
                shapeAliasesBySnapshot.getOrDefault(snapshot.scalar(0), Map.of()));
        Wire.Node record = Bundle.withContentId(
                "unfolding",
                List.of(root.scalar(0), Integer.toString(height),
                        normalized.scalar(0), snapshot.scalar(0)),
                List.of(normalizedRep));
        addContentAddressed(unfoldings, record);
        return record;
    }

    void publication(Wire.Node node) {
        publication = node;
    }

    Encoded build() {
        return buildWithTheory(Bundle.THEORY_ID);
    }

    Encoded buildWithTheory(String theoryId) {
        if (publication == null) {
            throw new IllegalStateException("Fixture has no publication");
        }
        sortManifest(schemas);
        sortManifest(operators);
        sortManifest(binders);
        sortManifest(axioms);
        Wire.Node theory = Wire.node(
                "theory",
                List.of(theoryId, Bundle.RULE_SET, Bundle.VOCABULARY_POLICY),
                List.of(Wire.node("axioms", axioms)));
        List<Wire.Node> sortedLaws = new ArrayList<>(lawCertificates);
        sortedLaws.sort(Comparator.comparing(node -> node.scalar(0)));
        List<String> evidenceScalars = semanticScalars == null
                ? List.of(
                        "4", "FORBID", "test-only-temporal",
                        "test-only-rewrite", "test-only-signature",
                        ZERO_SHA256, "test-only-law-theory-v1", ZERO_SHA256)
                : semanticScalars;
        Wire.Node vocabulary = Wire.node(
                "vocabulary",
                List.of(Bundle.VOCABULARY_POLICY),
                List.of(
                        Wire.node("schemas", schemas),
                        Wire.node("operators", operators),
                        Wire.node("binders", binders),
                        Wire.node(
                                "semantic-evidence",
                                evidenceScalars,
                                List.of(
                                        Wire.node("law-certificates", sortedLaws),
                                        Wire.node("flat-constructions", List.of()),
                                        Wire.node("container-constructions", List.of()),
                                        Wire.node("binder-occurrences", List.of()),
                                        Wire.node("exact-types",
                                                new ArrayList<>(exactTypes.values())),
                                        Wire.node("call-occurrences", List.of())))));
        String digest = Wire.contentId(theory);
        String vocabularyDigest = Wire.contentId(vocabulary);
        Wire.Node root = Wire.node(
                "acgncert-bundle",
                List.of(Bundle.SCHEMA_VERSION),
                List.of(
                        Wire.leaf(
                                "metadata",
                                "TEST_ONLY-NO-GIT-COMMIT",
                                Boolean.toString(metadataDirty),
                                "test-producer-v2",
                                "test-components-v2",
                                "test-run",
                                "1970-01-01T00:00:00Z",
                                metadataMode,
                                ZERO_SHA256,
                                ZERO_SHA256,
                                "TEST_ONLY:none=" + ZERO_SHA256,
                                "test-fixture",
                                ONE_SHA256,
                                ZERO_SHA256,
                                "test-verifier-v2",
                                ZERO_SHA256,
                                ZERO_SHA256,
                                "test-only=true",
                                sha256("test-only=true")),
                        Wire.node(
                                "manifest",
                                List.of(digest, vocabularyDigest),
                                List.of(theory, vocabulary)),
                        sortedSection("contexts", contexts),
                        sortedSection("embeddings", embeddings),
                        sortedSection("terms", terms),
                        sortedSection("proofs", proofs),
                        sortedSection("witnesses", witnesses),
                        sortedSection("snapshots", snapshots),
                        Wire.node("events", events),
                        sortedSection("canonical-records", canonicalRecords),
                        sortedSection("unfoldings", unfoldings),
                        publication));
        return new Encoded(Codec.encode(root), root, digest);
    }

    private static Wire.Node sortedSection(String tag, List<Wire.Node> values) {
        List<Wire.Node> copy = new ArrayList<>(values);
        copy.sort(Comparator.comparing(node -> node.scalar(0)));
        return Wire.node(tag, copy);
    }

    private static Wire.Node sortedPairSection(String tag, List<Wire.Node> values) {
        List<Wire.Node> copy = new ArrayList<>(values);
        copy.sort(Comparator
                .comparing((Wire.Node node) -> node.scalar(0))
                .thenComparing(node -> node.scalar(1)));
        return Wire.node(tag, copy);
    }

    private static void sortManifest(List<Wire.Node> values) {
        values.sort(Comparator.comparing(node -> node.scalar(0)));
    }

    private static void addContentAddressed(
            List<Wire.Node> records,
            Wire.Node record) {
        for (Wire.Node existing : records) {
            if (existing.scalar(0).equals(record.scalar(0))) {
                if (!existing.equals(record)) {
                    throw new AssertionError("test content-ID collision");
                }
                return;
            }
        }
        records.add(record);
    }

    private static String shapeId(String owner, String termId) {
        return "shape/" + Wire.contentId(Wire.leaf(
                "producer-shape-id", owner, termId));
    }

    private Wire.Node contextForTerm(String termId) {
        for (Wire.Node term : terms) {
            if (term.scalar(0).equals(termId)) {
                String contextId = term.scalar(2);
                for (Wire.Node context : contexts) {
                    if (context.scalar(0).equals(contextId)) {
                        return context;
                    }
                }
                throw new AssertionError("fixture term references a missing context");
            }
        }
        throw new AssertionError("fixture shape references a missing term");
    }

    private static List<Wire.Node> rewriteScalars(
            List<Wire.Node> nodes,
            Map<String, String> aliases) {
        List<Wire.Node> rewritten = new ArrayList<>(nodes.size());
        for (Wire.Node node : nodes) {
            rewritten.add(rewriteScalars(node, aliases));
        }
        return rewritten;
    }

    private static Wire.Node rewriteScalars(
            Wire.Node node,
            Map<String, String> aliases) {
        List<String> scalars = new ArrayList<>(node.scalars().size());
        for (String scalar : node.scalars()) {
            scalars.add(aliases.getOrDefault(scalar, scalar));
        }
        return Wire.node(node.tag(), scalars,
                rewriteScalars(node.children(), aliases));
    }

    private static String sha256(String value) {
        try {
            return java.util.HexFormat.of().formatHex(
                    java.security.MessageDigest.getInstance("SHA-256").digest(
                            value.getBytes(java.nio.charset.StandardCharsets.UTF_8)));
        } catch (java.security.NoSuchAlgorithmException exception) {
            throw new AssertionError(exception);
        }
    }

    record Encoded(byte[] bytes, Wire.Node root, String theoryDigest) {
    }
}
