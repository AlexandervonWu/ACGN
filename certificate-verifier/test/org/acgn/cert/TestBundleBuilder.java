package org.acgn.cert;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Direct DTO/byte builder used only by adversarial verifier tests. */
final class TestBundleBuilder {
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
    private Wire.Node publication;

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
        Wire.Node record = Wire.node(
                "schema",
                List.of(id, kind, value),
                child.isEmpty() ? List.of() : List.of(Wire.leaf("schema-ref", child)));
        schemas.add(record);
        return record;
    }

    Wire.Node operator(String id, String outputType, String... portSchemas) {
        Wire.Node record = Wire.node(
                "operator",
                List.of(id, outputType),
                java.util.Arrays.stream(portSchemas)
                        .map(schema -> Wire.leaf("schema-ref", schema)).toList());
        operators.add(record);
        return record;
    }

    Wire.Node binder(
            String id,
            List<Wire.Node> coordinates,
            List<Wire.Node> generators) {
        List<Wire.Node> children = new ArrayList<>(coordinates);
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
        Wire.Node record = Bundle.withContentId(
                "snapshot",
                List.of(Long.toString(revision), status),
                List.of(
                        sortedSection("classes", classes),
                        sortedSection("parents", parents),
                        sortedSection("shapes", shapes),
                        sortedSection("hash-cons", hashes),
                        sortedSection("parent-uses", parentUses),
                        sortedSection("symmetries", symmetries),
                        sortedSection("dirty", dirty)));
        addContentAddressed(snapshots, record);
        return record;
    }

    void event(
            int sequence,
            String kind,
            Wire.Node before,
            Wire.Node after,
            Wire.Node payload) {
        events.add(Wire.node(
                "event",
                List.of(Integer.toString(sequence), kind,
                        before.scalar(0), after.scalar(0)),
                List.of(payload)));
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
        Wire.Node record = Bundle.withContentId(
                "unfolding",
                List.of(root.scalar(0), Integer.toString(height),
                        normalized.scalar(0), snapshot.scalar(0)),
                List.of(rep));
        addContentAddressed(unfoldings, record);
        return record;
    }

    void publication(Wire.Node node) {
        publication = node;
    }

    Encoded build() {
        if (publication == null) {
            throw new IllegalStateException("Fixture has no publication");
        }
        sortManifest(schemas);
        sortManifest(operators);
        sortManifest(binders);
        sortManifest(axioms);
        Wire.Node theory = Wire.node(
                "theory",
                List.of("test-alloy-theory", "test-rules-v1"),
                List.of(
                        Wire.node("schemas", schemas),
                        Wire.node("operators", operators),
                        Wire.node("binders", binders),
                        Wire.node("axioms", axioms)));
        String digest = Wire.contentId(theory);
        Wire.Node root = Wire.node(
                "acgncert-bundle",
                List.of(Bundle.SCHEMA_VERSION),
                List.of(
                        Wire.leaf("metadata", "test-commit", "false",
                                "test-producer-v1", "test-components-v1",
                                "test-run", "2026-08-17T00:00:00Z"),
                        Wire.node("manifest", List.of(digest), List.of(theory)),
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

    record Encoded(byte[] bytes, Wire.Node root, String theoryDigest) {
    }
}
