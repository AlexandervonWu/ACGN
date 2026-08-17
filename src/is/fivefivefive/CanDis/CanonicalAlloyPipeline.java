package is.fivefivefive.CanDis;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.IdentityHashMap;
import java.util.Map;
import java.util.Objects;

import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.adapter.TheoryAlloyAdapter;
import is.fivefivefive.CanDis.theory.StructuralKey;

/**
 * Complete Alloy normalization followed by the exact typed slotted-port
 * e-graph boundary. The legacy {@link Canonical} result remains available for
 * compatibility measurements.
 */
public final class CanonicalAlloyPipeline {
    public static final String PIPELINE_VERSION = "canonical-alloy-pipeline-v1";
    public static final String MEASUREMENT_PROJECTION_VERSION =
            "finite-term-semantic-projection-v1";

    private CanonicalAlloyPipeline() {
    }

    public static Prepared prepare(Multigraph graph) {
        return prepare(Canonical.prepare(graph));
    }

    public static Prepared prepare(Canonical.Prepared normalized) {
        Objects.requireNonNull(normalized, "normalized");
        return new Prepared(TheoryAlloyAdapter.adapt(normalized.normalizedForms()));
    }

    public static int distance(Prepared left, Prepared right) {
        Objects.requireNonNull(left, "left");
        Objects.requireNonNull(right, "right");
        if (left.canonicalKey.equals(right.canonicalKey)) {
            return 0;
        }
        return treeDistance(
                left.distanceKey,
                right.distanceKey,
                new IdentityHashMap<>(),
                new IdentityHashMap<>());
    }

    private static StructuralKey semanticProjection(StructuralKey key) {
        if (!"canonical-alloy-form".equals(key.tag())
                && !key.tag().startsWith("finite-term/")) {
            throw new IllegalArgumentException(
                    "Semantic projection requires a finite-term key, found " + key.tag());
        }
        java.util.List<String> scalars = new java.util.ArrayList<>(key.scalars());
        StringBuilder layout = new StringBuilder(key.children().size());
        java.util.List<StructuralKey> children = new java.util.ArrayList<>();
        for (int index = 0; index < key.children().size(); index++) {
            StructuralKey child = key.children().get(index);
            if ("canonical-alloy-form".equals(child.tag())
                    || child.tag().startsWith("finite-term/")) {
                layout.append('T');
                children.add(semanticProjection(child));
            } else {
                layout.append('M');
                scalars.add(index + ":" + child.stableString());
            }
        }
        scalars.add("layout=" + layout);
        return StructuralKey.of(key.tag(), scalars, children);
    }

    private static int treeDistance(
            StructuralKey left,
            StructuralKey right,
            Map<StructuralKey, IdentityHashMap<StructuralKey, Integer>> memo,
            Map<StructuralKey, Integer> sizes) {
        IdentityHashMap<StructuralKey, Integer> rightMemo = memo.get(left);
        Integer remembered = rightMemo == null ? null : rightMemo.get(right);
        if (remembered != null) {
            return remembered;
        }
        int distance = left.tag().equals(right.tag())
                && left.scalars().equals(right.scalars()) ? 0 : 1;
        int leftCount = left.children().size();
        int rightCount = right.children().size();
        int[][] forest = new int[leftCount + 1][rightCount + 1];
        for (int i = 1; i <= leftCount; i++) {
            forest[i][0] = Math.addExact(
                    forest[i - 1][0], treeSize(left.children().get(i - 1), sizes));
        }
        for (int j = 1; j <= rightCount; j++) {
            forest[0][j] = Math.addExact(
                    forest[0][j - 1], treeSize(right.children().get(j - 1), sizes));
        }
        for (int i = 1; i <= leftCount; i++) {
            StructuralKey leftChild = left.children().get(i - 1);
            for (int j = 1; j <= rightCount; j++) {
                StructuralKey rightChild = right.children().get(j - 1);
                int delete = Math.addExact(forest[i - 1][j], treeSize(leftChild, sizes));
                int insert = Math.addExact(forest[i][j - 1], treeSize(rightChild, sizes));
                int update = Math.addExact(
                        forest[i - 1][j - 1],
                        treeDistance(leftChild, rightChild, memo, sizes));
                forest[i][j] = Math.min(update, Math.min(delete, insert));
            }
        }
        distance = Math.addExact(distance, forest[leftCount][rightCount]);
        if (rightMemo == null) {
            rightMemo = new IdentityHashMap<>();
            memo.put(left, rightMemo);
        }
        rightMemo.put(right, distance);
        return distance;
    }

    private static int treeSize(
            StructuralKey key,
            Map<StructuralKey, Integer> sizes) {
        Integer remembered = sizes.get(key);
        if (remembered != null) {
            return remembered;
        }
        int size = 1;
        for (StructuralKey child : key.children()) {
            size = Math.addExact(size, treeSize(child, sizes));
        }
        sizes.put(key, size);
        return size;
    }

    private static String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder result = new StringBuilder(digest.length * 2);
            for (byte item : digest) {
                result.append(String.format(java.util.Locale.ROOT, "%02x", item & 0xff));
            }
            return result.toString();
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is unavailable", exception);
        }
    }

    public static final class Prepared {
        private final StructuralKey canonicalKey;
        private final StructuralKey distanceKey;
        private final int representationSize;
        private final long eclasses;
        private final long enodes;
        private final long slots;
        private final long rebuilds;
        private final long estimatedBytes;
        private final String digest;
        private final long constructionNanos;
        private final long unfoldingNanos;
        private final long observationNanos;

        private Prepared(TheoryAlloyAdapter.Result result) {
            canonicalKey = result.canonicalKey();
            distanceKey = semanticProjection(canonicalKey);
            representationSize = treeSize(distanceKey, new IdentityHashMap<>());
            eclasses = result.eclasses();
            enodes = result.enodes();
            slots = result.slots();
            rebuilds = result.rebuilds();
            estimatedBytes = result.estimatedBytes();
            constructionNanos = result.constructionNanos();
            unfoldingNanos = result.unfoldingNanos();
            observationNanos = result.observationNanos();
            digest = sha256(canonicalKey.stableString());
        }

        public int representationSize() {
            return representationSize;
        }

        public long eclassCount() {
            return eclasses;
        }

        public long enodeCount() {
            return enodes;
        }

        public long slotCount() {
            return slots;
        }

        public long rebuildCount() {
            return rebuilds;
        }

        public long estimatedBytes() {
            return estimatedBytes;
        }

        public long constructionNanos() {
            return constructionNanos;
        }

        public long unfoldingNanos() {
            return unfoldingNanos;
        }

        public long observationNanos() {
            return observationNanos;
        }

        public String digest() {
            return digest;
        }

        public String stableForm() {
            return canonicalKey.stableString();
        }

        public String measurementForm() {
            return distanceKey.stableString();
        }

        public boolean equivalentTo(Prepared other) {
            return other != null && canonicalKey.equals(other.canonicalKey);
        }
    }
}
