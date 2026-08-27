package org.acgn.cert;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HexFormat;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.TreeSet;

/** Caller-pinned authority for the complete CALL-occurrence set of one input scope. */
public record CallOccurrenceCommitment(
        String subjectDigest,
        String occurrenceDigest) {
    public static final String VERSION = "call-occurrence-commitment-v1";

    public CallOccurrenceCommitment {
        subjectDigest = requireDigest(subjectDigest, "subjectDigest");
        occurrenceDigest = requireDigest(occurrenceDigest, "occurrenceDigest");
    }

    /**
     * Extracts an untrusted candidate from a bundle for out-of-band review and
     * pinning. Passing this result straight back does not create authority.
     */
    public static CallOccurrenceCommitment inspect(
            byte[] encoded,
            Limits limits) {
        Objects.requireNonNull(encoded, "encoded");
        Bundle bundle = Bundle.parse(Codec.decode(encoded, limits));
        Wire.Node evidence = bundle.semanticEvidence().requireShape(
                "semantic-evidence", 8, 6);
        Wire.Node section = evidence.child(5);
        section.requireTag("call-occurrences");
        List<String> keys = new ArrayList<>(section.children().size());
        for (Wire.Node record : section.children()) {
            record.requireTag("call-occurrence");
            if (record.scalars().isEmpty()) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE,
                        "CALL occurrence record has no structural key");
            }
            keys.add(record.scalar(0));
        }
        String subject = subjectDigest(bundle.metadata());
        return new CallOccurrenceCommitment(subject, digest(subject, keys));
    }

    public String assignment() {
        return subjectDigest + "=" + occurrenceDigest;
    }

    public static CallOccurrenceCommitment parseAssignment(String value) {
        Objects.requireNonNull(value, "value");
        int separator = value.indexOf('=');
        if (separator <= 0 || separator != value.lastIndexOf('=')) {
            throw new IllegalArgumentException(
                    "CALL occurrence commitment must be <subject-sha256>=<digest>");
        }
        return new CallOccurrenceCommitment(
                value.substring(0, separator), value.substring(separator + 1));
    }

    static String subjectDigest(Bundle.Metadata metadata) {
        Objects.requireNonNull(metadata, "metadata");
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            update(digest, VERSION + "/subject");
            update(digest, metadata.inputIdentifier());
            update(digest, metadata.inputSha256());
            return HexFormat.of().formatHex(digest.digest());
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is unavailable", exception);
        }
    }

    static String digest(String subjectDigest, Collection<String> occurrenceKeys) {
        requireDigest(subjectDigest, "subjectDigest");
        Objects.requireNonNull(occurrenceKeys, "occurrenceKeys");
        Set<String> ordered = new TreeSet<>();
        for (String key : occurrenceKeys) {
            String checked = Objects.requireNonNull(key, "occurrence key");
            if (checked.isEmpty() || !ordered.add(checked)) {
                throw new IllegalArgumentException(
                        "CALL occurrence keys must be nonempty and unique");
            }
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            update(digest, VERSION);
            update(digest, subjectDigest);
            for (String key : ordered) {
                update(digest, key);
            }
            return HexFormat.of().formatHex(digest.digest());
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is unavailable", exception);
        }
    }

    private static void update(MessageDigest digest, String value) {
        byte[] bytes = value.getBytes(StandardCharsets.UTF_8);
        digest.update(ByteBuffer.allocate(Integer.BYTES).putInt(bytes.length).array());
        digest.update(bytes);
    }

    private static String requireDigest(String value, String label) {
        Objects.requireNonNull(value, label);
        if (!value.matches("[0-9a-f]{64}")) {
            throw new IllegalArgumentException(
                    label + " must be a lowercase SHA-256 digest");
        }
        return value;
    }
}
