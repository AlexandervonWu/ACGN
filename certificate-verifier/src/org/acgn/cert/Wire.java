package org.acgn.cert;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HexFormat;
import java.util.List;
import java.util.Objects;

/** Canonical, language-neutral tree used by the ACGN certificate format. */
public final class Wire {
    private Wire() {
    }

    public static Node node(String tag, List<String> scalars, List<Node> children) {
        return new Node(tag, scalars, children);
    }

    public static Node node(String tag, List<Node> children) {
        return new Node(tag, List.of(), children);
    }

    public static Node leaf(String tag, String... scalars) {
        return new Node(tag, Arrays.asList(scalars), List.of());
    }

    public static String contentId(Node value) {
        Objects.requireNonNull(value, "value");
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(Codec.encodeNode(value)));
        } catch (NoSuchAlgorithmException exception) {
            throw new AssertionError("JDK 17 must provide SHA-256", exception);
        }
    }

    public static String utf8Length(String value) {
        return Integer.toString(value.getBytes(StandardCharsets.UTF_8).length);
    }

    /** Immutable tree with a total ordering identical to its canonical encoding. */
    public static final class Node implements Comparable<Node> {
        private final String tag;
        private final List<String> scalars;
        private final List<Node> children;

        public Node(String tag, List<String> scalars, List<Node> children) {
            this.tag = requireText(tag, "tag");
            Objects.requireNonNull(scalars, "scalars");
            Objects.requireNonNull(children, "children");
            List<String> scalarCopy = new ArrayList<>(scalars.size());
            for (String scalar : scalars) {
                scalarCopy.add(Objects.requireNonNull(scalar, "scalar"));
            }
            List<Node> childCopy = new ArrayList<>(children.size());
            for (Node child : children) {
                childCopy.add(Objects.requireNonNull(child, "child"));
            }
            this.scalars = Collections.unmodifiableList(scalarCopy);
            this.children = Collections.unmodifiableList(childCopy);
        }

        private static String requireText(String value, String name) {
            Objects.requireNonNull(value, name);
            if (value.isEmpty()) {
                throw new IllegalArgumentException(name + " must not be empty");
            }
            return value;
        }

        public String tag() {
            return tag;
        }

        public List<String> scalars() {
            return scalars;
        }

        public List<Node> children() {
            return children;
        }

        public String scalar(int index) {
            return scalars.get(index);
        }

        public Node child(int index) {
            return children.get(index);
        }

        public Node requireShape(String expectedTag, int scalarCount, int childCount) {
            if (!tag.equals(expectedTag)
                    || scalars.size() != scalarCount
                    || children.size() != childCount) {
                throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE,
                        "Expected " + expectedTag + "(" + scalarCount + ","
                                + childCount + ") but found " + tag + "("
                                + scalars.size() + "," + children.size() + ")");
            }
            return this;
        }

        public Node requireTag(String expectedTag) {
            if (!tag.equals(expectedTag)) {
                throw new FormatException(
                        FailureCode.UNKNOWN_VARIANT,
                        "Expected tag " + expectedTag + " but found " + tag);
            }
            return this;
        }

        @Override
        public int compareTo(Node other) {
            int compared = tag.compareTo(other.tag);
            if (compared != 0) {
                return compared;
            }
            compared = compareLists(scalars, other.scalars);
            if (compared != 0) {
                return compared;
            }
            int shared = Math.min(children.size(), other.children.size());
            for (int index = 0; index < shared; index++) {
                compared = children.get(index).compareTo(other.children.get(index));
                if (compared != 0) {
                    return compared;
                }
            }
            return Integer.compare(children.size(), other.children.size());
        }

        private static int compareLists(List<String> left, List<String> right) {
            int shared = Math.min(left.size(), right.size());
            for (int index = 0; index < shared; index++) {
                int compared = left.get(index).compareTo(right.get(index));
                if (compared != 0) {
                    return compared;
                }
            }
            return Integer.compare(left.size(), right.size());
        }

        @Override
        public boolean equals(Object other) {
            return other instanceof Node node
                    && tag.equals(node.tag)
                    && scalars.equals(node.scalars)
                    && children.equals(node.children);
        }

        @Override
        public int hashCode() {
            return Objects.hash(tag, scalars, children);
        }

        @Override
        public String toString() {
            return tag + scalars + children;
        }
    }
}
