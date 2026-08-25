package org.acgn.cert;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.EOFException;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/** Deterministic length-prefixed binary codec for `.acgncert`. */
public final class Codec {
    public static final int FORMAT_VERSION = 1;
    private static final byte[] MAGIC = new byte[] {
            'A', 'C', 'G', 'N', 'C', 'E', 'R', 'T'
    };
    private static final int DIGEST_BYTES = 32;

    private Codec() {
    }

    public static byte[] encode(Wire.Node root) {
        byte[] payload = encodeNode(root);
        try {
            ByteArrayOutputStream bytes = new ByteArrayOutputStream(
                    MAGIC.length + 2 + 8 + payload.length + DIGEST_BYTES);
            DataOutputStream output = new DataOutputStream(bytes);
            output.write(MAGIC);
            output.writeShort(FORMAT_VERSION);
            output.writeLong(payload.length);
            output.write(payload);
            output.write(sha256(payload));
            output.flush();
            return bytes.toByteArray();
        } catch (IOException exception) {
            throw new AssertionError("Byte-array encoding cannot fail", exception);
        }
    }

    static byte[] encodeNode(Wire.Node root) {
        try {
            ByteArrayOutputStream bytes = new ByteArrayOutputStream();
            DataOutputStream output = new DataOutputStream(bytes);
            writeNode(output, root);
            output.flush();
            return bytes.toByteArray();
        } catch (IOException exception) {
            throw new AssertionError("Byte-array encoding cannot fail", exception);
        }
    }

    private static void writeNode(DataOutputStream output, Wire.Node node)
            throws IOException {
        writeString(output, node.tag());
        output.writeInt(node.scalars().size());
        for (String scalar : node.scalars()) {
            writeString(output, scalar);
        }
        output.writeInt(node.children().size());
        for (Wire.Node child : node.children()) {
            writeNode(output, child);
        }
    }

    private static void writeString(DataOutputStream output, String value)
            throws IOException {
        byte[] encoded = encodeCanonicalUtf8(value);
        output.writeInt(encoded.length);
        output.write(encoded);
    }

    static byte[] encodeCanonicalUtf8(String value) {
        try {
            ByteBuffer encoded = StandardCharsets.UTF_8.newEncoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .encode(CharBuffer.wrap(value));
            byte[] bytes = new byte[encoded.remaining()];
            encoded.get(bytes);
            return bytes;
        } catch (CharacterCodingException exception) {
            throw new IllegalArgumentException(
                    "Canonical wire strings must be well-formed Unicode", exception);
        }
    }

    public static Wire.Node decode(byte[] encoded, Limits limits) {
        if (encoded.length > limits.maxBundleBytes()) {
            throw new FormatException(
                    FailureCode.RESOURCE_LIMIT, "Bundle exceeds byte limit");
        }
        try {
            DataInputStream input = new DataInputStream(new ByteArrayInputStream(encoded));
            byte[] magic = input.readNBytes(MAGIC.length);
            if (!Arrays.equals(magic, MAGIC)) {
                throw new FormatException(FailureCode.BAD_MAGIC, "Bad ACGNCERT magic");
            }
            int version = input.readUnsignedShort();
            if (version != FORMAT_VERSION) {
                throw new FormatException(
                        FailureCode.UNSUPPORTED_FORMAT_VERSION,
                        "Unsupported format version " + version);
            }
            long payloadLength = input.readLong();
            if (payloadLength < 0 || payloadLength > Integer.MAX_VALUE) {
                throw new FormatException(
                        FailureCode.INTEGER_OVERFLOW, "Invalid payload length");
            }
            long expectedTotal = MAGIC.length + 2L + 8L + payloadLength + DIGEST_BYTES;
            if (expectedTotal != encoded.length) {
                FailureCode code = expectedTotal < encoded.length
                        ? FailureCode.TRAILING_BYTES : FailureCode.TRUNCATED_INPUT;
                throw new FormatException(code, "Envelope length disagreement");
            }
            byte[] payload = input.readNBytes((int) payloadLength);
            byte[] claimedDigest = input.readNBytes(DIGEST_BYTES);
            if (!MessageDigest.isEqual(sha256(payload), claimedDigest)) {
                throw new FormatException(
                        FailureCode.DIGEST_MISMATCH, "Payload digest disagreement");
            }
            NodeCounter counter = new NodeCounter(limits);
            DataInputStream payloadInput = new DataInputStream(
                    new ByteArrayInputStream(payload));
            Wire.Node root = readNode(payloadInput, counter, 0);
            if (payloadInput.available() != 0) {
                throw new FormatException(
                        FailureCode.TRAILING_BYTES, "Trailing bytes in payload");
            }
            if (!Arrays.equals(payload, encodeNode(root))) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "Decoded tree does not reproduce the payload bytes");
            }
            return root;
        } catch (EOFException exception) {
            throw new FormatException(
                    FailureCode.TRUNCATED_INPUT, "Truncated bundle", exception);
        } catch (IOException exception) {
            throw new FormatException(FailureCode.IO_ERROR, exception.getMessage(), exception);
        }
    }

    private static Wire.Node readNode(
            DataInputStream input,
            NodeCounter counter,
            int depth) throws IOException {
        counter.consume(depth);
        String tag = readString(input, counter.limits);
        int scalarCount = readCount(input, counter.limits.maxTableEntries());
        List<String> scalars = new ArrayList<>(scalarCount);
        for (int index = 0; index < scalarCount; index++) {
            scalars.add(readString(input, counter.limits));
        }
        int childCount = readCount(input, counter.limits.maxTableEntries());
        List<Wire.Node> children = new ArrayList<>(childCount);
        for (int index = 0; index < childCount; index++) {
            children.add(readNode(input, counter, depth + 1));
        }
        return Wire.node(tag, scalars, children);
    }

    private static int readCount(DataInputStream input, int limit) throws IOException {
        int count = input.readInt();
        if (count < 0) {
            throw new FormatException(
                    FailureCode.INTEGER_OVERFLOW, "Negative collection length");
        }
        if (count > limit) {
            throw new FormatException(
                    FailureCode.RESOURCE_LIMIT, "Collection exceeds configured limit");
        }
        return count;
    }

    private static String readString(DataInputStream input, Limits limits)
            throws IOException {
        int length = input.readInt();
        if (length < 0) {
            throw new FormatException(FailureCode.INTEGER_OVERFLOW, "Negative string length");
        }
        if (length > limits.maxStringBytes()) {
            throw new FormatException(
                    FailureCode.RESOURCE_LIMIT, "String exceeds configured limit");
        }
        byte[] bytes = input.readNBytes(length);
        if (bytes.length != length) {
            throw new EOFException("Truncated UTF-8 string");
        }
        try {
            return StandardCharsets.UTF_8.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .decode(ByteBuffer.wrap(bytes))
                    .toString();
        } catch (CharacterCodingException exception) {
            throw new FormatException(
                    FailureCode.INVALID_UTF8, "Invalid UTF-8", exception);
        }
    }

    private static byte[] sha256(byte[] value) {
        try {
            return MessageDigest.getInstance("SHA-256").digest(value);
        } catch (NoSuchAlgorithmException exception) {
            throw new AssertionError("JDK 17 must provide SHA-256", exception);
        }
    }

    private static final class NodeCounter {
        private final Limits limits;
        private int count;

        private NodeCounter(Limits limits) {
            this.limits = limits;
        }

        private void consume(int depth) {
            if (depth > limits.maxDepth()) {
                throw new FormatException(
                        FailureCode.RESOURCE_LIMIT, "Tree depth exceeds configured limit");
            }
            count++;
            if (count > limits.maxNodes()) {
                throw new FormatException(
                        FailureCode.RESOURCE_LIMIT, "Node count exceeds configured limit");
            }
        }
    }
}
