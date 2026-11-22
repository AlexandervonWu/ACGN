package org.acgn.cert;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/** External authority for a closed SOME over one binary ARROW tree of primitive signatures. */
public record ArrowSourceCommitment(String subject, String digest) {
    public record Leaf(String path, String signature) {}
    private static final String VERSION = "alloy-primitive-arrow-source-v1";

    public ArrowSourceCommitment {
        if (!hex(subject) || !hex(digest)) throw new IllegalArgumentException("invalid ARROW source commitment");
    }

    private static boolean hex(String value) {
        return value != null && value.matches("[0-9a-f]{64}");
    }

    public String assignment() { return subject + "=" + digest; }

    public static ArrowSourceCommitment parse(String assignment) {
        String[] parts = assignment.split("=", -1);
        if (parts.length != 2) throw new IllegalArgumentException("expected ARROW subject=digest");
        return new ArrowSourceCommitment(parts[0], parts[1]);
    }

    public static String subject(String root, String rawSha256) {
        if (!hex(rawSha256)) throw new IllegalArgumentException("invalid ARROW source hash");
        MessageDigest md = sha();
        field(md, VERSION + "/subject"); field(md, root); field(md, rawSha256);
        return HexFormat.of().formatHex(md.digest());
    }

    /** Callers obtain roles and complete declaration ancestry independently from original source. */
    public static ArrowSourceCommitment from(String root, String rawSha256, List<Leaf> leaves,
            Map<String,List<String>> ancestry) {
        String subject = subject(root, rawSha256);
        MessageDigest md = sha();
        field(md, VERSION); field(md, subject); field(md, Integer.toString(leaves.size()));
        for (Leaf leaf : leaves) { field(md, leaf.path()); field(md, leaf.signature()); }
        field(md, Integer.toString(ancestry.size()));
        new TreeMap<>(ancestry).forEach((column, path) -> {
            field(md, column); field(md, Integer.toString(path.size()));
            for (String step : path) field(md, step);
        });
        return new ArrowSourceCommitment(subject, HexFormat.of().formatHex(md.digest()));
    }

    private static void field(MessageDigest md, String value) {
        byte[] bytes = value.getBytes(StandardCharsets.UTF_8);
        md.update(ByteBuffer.allocate(4).putInt(bytes.length).array());
        md.update(bytes);
    }

    private static MessageDigest sha() {
        try { return MessageDigest.getInstance("SHA-256"); }
        catch (NoSuchAlgorithmException e) { throw new AssertionError(e); }
    }
}
