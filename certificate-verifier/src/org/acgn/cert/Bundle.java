package org.acgn.cert;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/** Strict structural view of one decoded certificate bundle. */
public final class Bundle {
    public static final String SCHEMA_VERSION = "acgncert-schema-v2";
    public static final String THEORY_ID = "acgn-exact-alloy-theory-v2";
    public static final String RULE_SET = "phase-j-proof-kernel-v3";
    public static final String VOCABULARY_POLICY =
            "typed-content-addressed-uninterpreted-vocabulary-v1";
    private static final List<String> SECTION_TAGS = List.of(
            "metadata",
            "manifest",
            "contexts",
            "embeddings",
            "terms",
            "proofs",
            "witnesses",
            "snapshots",
            "events",
            "canonical-records",
            "unfoldings",
            "publication");

    private final Wire.Node root;
    private final Metadata metadata;
    private final Wire.Node theory;
    private final String theoryDigest;
    private final Wire.Node vocabulary;
    private final String vocabularyDigest;
    private final Map<String, Wire.Node> contexts;
    private final Map<String, Wire.Node> embeddings;
    private final Map<String, Wire.Node> terms;
    private final Map<String, Wire.Node> proofs;
    private final Map<String, Wire.Node> witnesses;
    private final Map<String, Wire.Node> snapshots;
    private final List<Wire.Node> events;
    private final Map<String, Wire.Node> canonicalRecords;
    private final Map<String, Wire.Node> unfoldings;
    private final Wire.Node publication;

    private Bundle(Wire.Node root) {
        this.root = Objects.requireNonNull(root, "root");
        root.requireShape("acgncert-bundle", 1, SECTION_TAGS.size());
        if (!SCHEMA_VERSION.equals(root.scalar(0))) {
            throw new FormatException(
                    FailureCode.UNSUPPORTED_FORMAT_VERSION,
                    "Unsupported bundle schema " + root.scalar(0));
        }
        for (int index = 0; index < SECTION_TAGS.size(); index++) {
            root.child(index).requireTag(SECTION_TAGS.get(index));
        }

        Wire.Node metadataNode = root.child(0).requireShape("metadata", 18, 0);
        metadata = new Metadata(
                metadataNode.scalar(0),
                parseBoolean(metadataNode.scalar(1), "dirty flag"),
                metadataNode.scalar(2),
                metadataNode.scalar(3),
                metadataNode.scalar(4),
                metadataNode.scalar(5),
                metadataNode.scalar(6),
                metadataNode.scalar(7),
                metadataNode.scalar(8),
                metadataNode.scalar(9),
                metadataNode.scalar(10),
                metadataNode.scalar(11),
                metadataNode.scalar(12),
                metadataNode.scalar(13),
                metadataNode.scalar(14),
                metadataNode.scalar(15),
                metadataNode.scalar(16),
                metadataNode.scalar(17));

        Wire.Node manifest = root.child(1).requireShape("manifest", 2, 2);
        theory = manifest.child(0).requireShape("theory", 3, 1);
        if (!List.of(THEORY_ID, RULE_SET, VOCABULARY_POLICY)
                .equals(theory.scalars())) {
            throw new FormatException(
                    FailureCode.THEORY_MISMATCH,
                    "Bundle does not declare the reviewed schema-v2 theory");
        }
        theory.child(0).requireTag("axioms");
        theoryDigest = Wire.contentId(theory);
        if (!theoryDigest.equals(manifest.scalar(0))) {
            throw new FormatException(
                    FailureCode.DIGEST_MISMATCH,
                    "Theory manifest digest does not match its complete content");
        }
        vocabulary = manifest.child(1).requireShape("vocabulary", 1, 3);
        if (!VOCABULARY_POLICY.equals(vocabulary.scalar(0))) {
            throw new FormatException(
                    FailureCode.THEORY_MISMATCH,
                    "Bundle vocabulary does not use the reviewed declaration policy");
        }
        vocabulary.child(0).requireTag("schemas");
        vocabulary.child(1).requireTag("operators");
        vocabulary.child(2).requireTag("binders");
        vocabularyDigest = Wire.contentId(vocabulary);
        if (!vocabularyDigest.equals(manifest.scalar(1))) {
            throw new FormatException(
                    FailureCode.DIGEST_MISMATCH,
                    "Vocabulary digest does not match its complete content");
        }

        contexts = indexedTable(root.child(2), "contexts", "context", true);
        embeddings = indexedTable(root.child(3), "embeddings", "embedding", true);
        terms = indexedTable(root.child(4), "terms", "term", true);
        proofs = indexedTable(root.child(5), "proofs", "proof", true);
        witnesses = indexedTable(root.child(6), "witnesses", "witness", false);
        snapshots = indexedTable(root.child(7), "snapshots", "snapshot", true);
        events = orderedEvents(root.child(8));
        canonicalRecords = indexedTable(
                root.child(9), "canonical-records", "canonical-record", true);
        unfoldings = indexedTable(root.child(10), "unfoldings", "unfolding", true);
        publication = root.child(11).requireTag("publication");
    }

    public static Bundle parse(Wire.Node root) {
        return new Bundle(root);
    }

    private static Map<String, Wire.Node> indexedTable(
            Wire.Node section,
            String sectionTag,
            String recordTag,
            boolean contentAddressed) {
        section.requireTag(sectionTag);
        if (!section.scalars().isEmpty()) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE,
                    sectionTag + " section must not have scalars");
        }
        Map<String, Wire.Node> result = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node record : section.children()) {
            record.requireTag(recordTag);
            if (record.scalars().isEmpty()) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE,
                        recordTag + " has no ID");
            }
            String id = record.scalar(0);
            if (id.isEmpty()) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE,
                        recordTag + " has an empty ID");
            }
            if (prior != null && prior.compareTo(id) >= 0) {
                FailureCode code = prior.equals(id)
                        ? FailureCode.DUPLICATE_ID : FailureCode.NONCANONICAL_ENCODING;
                throw new FormatException(
                        code, sectionTag + " records are duplicated or unsorted");
            }
            prior = id;
            if (contentAddressed && !id.equals(contentId(record))) {
                throw new FormatException(
                        FailureCode.CONTENT_ID_MISMATCH,
                        recordTag + " content ID mismatch: " + id);
            }
            if (result.put(id, record) != null) {
                throw new FormatException(FailureCode.DUPLICATE_ID, "Duplicate ID " + id);
            }
        }
        return Collections.unmodifiableMap(result);
    }

    public static String contentId(Wire.Node identifiedRecord) {
        if (identifiedRecord.scalars().isEmpty()) {
            throw new IllegalArgumentException("Identified record has no ID scalar");
        }
        Wire.Node content = Wire.node(
                identifiedRecord.tag() + "/content",
                identifiedRecord.scalars().subList(1, identifiedRecord.scalars().size()),
                identifiedRecord.children());
        return Wire.contentId(content);
    }

    public static Wire.Node withContentId(
            String tag,
            List<String> contentScalars,
            List<Wire.Node> children) {
        Wire.Node provisional = Wire.node(tag, prepend("", contentScalars), children);
        String id = contentId(provisional);
        return Wire.node(tag, prepend(id, contentScalars), children);
    }

    private static List<String> prepend(String first, List<String> rest) {
        List<String> result = new ArrayList<>(rest.size() + 1);
        result.add(first);
        result.addAll(rest);
        return result;
    }

    private static List<Wire.Node> orderedEvents(Wire.Node section) {
        section.requireTag("events");
        if (!section.scalars().isEmpty()) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE,
                    "events section must not have scalars");
        }
        List<Wire.Node> result = new ArrayList<>(section.children().size());
        long expected = 0;
        for (Wire.Node event : section.children()) {
            event.requireTag("event");
            if (event.scalars().isEmpty()) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE, "Event has no sequence number");
            }
            long sequence = parseUnsignedLong(event.scalar(0), "event sequence");
            if (sequence != expected) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Expected event " + expected + " but found " + sequence);
            }
            expected = Math.incrementExact(expected);
            result.add(event);
        }
        return Collections.unmodifiableList(result);
    }

    static boolean parseBoolean(String text, String field) {
        if ("true".equals(text)) {
            return true;
        }
        if ("false".equals(text)) {
            return false;
        }
        throw new FormatException(
                FailureCode.INVALID_RECORD_SHAPE,
                "Invalid " + field + ": " + text);
    }

    static long parseUnsignedLong(String text, String field) {
        if (text.isEmpty() || (text.length() > 1 && text.charAt(0) == '0')) {
            throw new FormatException(
                    FailureCode.NONCANONICAL_ENCODING,
                    "Noncanonical " + field + ": " + text);
        }
        try {
            long value = Long.parseLong(text);
            if (value < 0) {
                throw new NumberFormatException("negative");
            }
            return value;
        } catch (NumberFormatException exception) {
            throw new FormatException(
                    FailureCode.INTEGER_OVERFLOW,
                    "Invalid " + field + ": " + text,
                    exception);
        }
    }

    public Wire.Node root() {
        return root;
    }

    public Metadata metadata() {
        return metadata;
    }

    public Wire.Node theory() {
        return theory;
    }

    public String theoryDigest() {
        return theoryDigest;
    }

    public Wire.Node vocabulary() {
        return vocabulary;
    }

    public String vocabularyDigest() {
        return vocabularyDigest;
    }

    public Map<String, Wire.Node> contexts() {
        return contexts;
    }

    public Map<String, Wire.Node> embeddings() {
        return embeddings;
    }

    public Map<String, Wire.Node> terms() {
        return terms;
    }

    public Map<String, Wire.Node> proofs() {
        return proofs;
    }

    public Map<String, Wire.Node> witnesses() {
        return witnesses;
    }

    public Map<String, Wire.Node> snapshots() {
        return snapshots;
    }

    public List<Wire.Node> events() {
        return events;
    }

    public Map<String, Wire.Node> canonicalRecords() {
        return canonicalRecords;
    }

    public Map<String, Wire.Node> unfoldings() {
        return unfoldings;
    }

    public Wire.Node publication() {
        return publication;
    }

    public record Metadata(
            String producerCommit,
            boolean dirty,
            String producerVersion,
            String componentVersions,
            String runId,
            String createdAt,
            String mode,
            String javaSourceSha256,
            String producerJarSha256,
            String dependencyHashes,
            String inputIdentifier,
            String inputSha256,
            String exporterSourceSha256,
            String verifierVersion,
            String verifierSourceSha256,
            String verifierJarSha256,
            String configuration,
            String configurationSha256) {
        public Metadata {
            requireMetadataText(producerCommit, "producer commit");
            requireMetadataText(producerVersion, "producer version");
            requireMetadataText(componentVersions, "component versions");
            requireMetadataText(runId, "run ID");
            requireMetadataText(createdAt, "creation time");
            requireMetadataText(mode, "provenance mode");
            requireDigest(javaSourceSha256, "Java source hash");
            requireDigest(producerJarSha256, "producer JAR hash");
            requireMetadataText(dependencyHashes, "dependency hashes");
            requireMetadataText(inputIdentifier, "input identifier");
            requireDigest(inputSha256, "input hash");
            requireDigest(exporterSourceSha256, "exporter source hash");
            requireMetadataText(verifierVersion, "verifier version");
            requireDigest(verifierSourceSha256, "verifier source hash");
            requireDigest(verifierJarSha256, "verifier JAR hash");
            requireMetadataText(configuration, "configuration");
            requireDigest(configurationSha256, "configuration hash");
            if (!configurationSha256.equals(sha256(configuration))) {
                throw new FormatException(
                        FailureCode.DIGEST_MISMATCH,
                        "Configuration provenance hash is stale");
            }
            if (!mode.equals("PUBLICATION") && !mode.equals("TEST_ONLY")) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE,
                        "Unknown provenance mode " + mode);
            }
            if (mode.equals("PUBLICATION") && dirty) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE,
                        "Publication provenance cannot describe a dirty worktree");
            }
        }
    }

    private static String requireMetadataText(String value, String label) {
        if (value == null || value.isEmpty()) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE, label + " must be nonempty");
        }
        return value;
    }

    private static void requireDigest(String value, String label) {
        requireMetadataText(value, label);
        if (value.length() != 64) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE,
                    label + " must be a SHA-256 digest");
        }
        for (int index = 0; index < value.length(); index++) {
            char character = value.charAt(index);
            if (!((character >= '0' && character <= '9')
                    || (character >= 'a' && character <= 'f'))) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE,
                        label + " must be lowercase hexadecimal");
            }
        }
    }

    private static String sha256(String value) {
        try {
            return java.util.HexFormat.of().formatHex(
                    MessageDigest.getInstance("SHA-256").digest(
                            value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new AssertionError("JDK 17 must provide SHA-256", exception);
        }
    }
}
