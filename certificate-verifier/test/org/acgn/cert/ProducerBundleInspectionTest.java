package org.acgn.cert;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.Comparator;
import java.util.HexFormat;
import java.util.List;
import java.util.Set;
import java.util.stream.Stream;

/** Strict parsed-bundle checks over producer-generated bridge fixtures. */
public final class ProducerBundleInspectionTest {
    private static int checks;

    private ProducerBundleInspectionTest() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 14) {
            throw new IllegalArgumentException(
                    "usage: ProducerBundleInspectionTest "
                            + "<nullary-a> <nullary-b> <slot-a> <slot-b> "
                            + "<parent-a> <parent-b> <equivalent-left> "
                            + "<equivalent-right> <non-equivalent> "
                            + "<repo-root> <producer-jar> <verifier-jar> "
                            + "<empty-theory-digest> <parent-theory-digest>");
        }
        byte[] nullaryA = Files.readAllBytes(Path.of(args[0]));
        byte[] nullaryB = Files.readAllBytes(Path.of(args[1]));
        byte[] slotA = Files.readAllBytes(Path.of(args[2]));
        byte[] slotB = Files.readAllBytes(Path.of(args[3]));
        byte[] parentA = Files.readAllBytes(Path.of(args[4]));
        byte[] parentB = Files.readAllBytes(Path.of(args[5]));
        byte[] equivalentLeft = Files.readAllBytes(Path.of(args[6]));
        byte[] equivalentRight = Files.readAllBytes(Path.of(args[7]));
        byte[] nonEquivalent = Files.readAllBytes(Path.of(args[8]));
        check(java.util.Arrays.equals(nullaryA, nullaryB),
                "nullary export is byte deterministic");
        check(java.util.Arrays.equals(slotA, slotB),
                "slot export is byte deterministic");
        check(java.util.Arrays.equals(parentA, parentB),
                "parent export is byte deterministic");

        IndependentVerifier verifier = new IndependentVerifier();
        Bundle nullary = decode(nullaryA);
        Bundle slot = decode(slotA);
        Bundle parent = decode(parentA);
        String emptyTheoryDigest = args[12];
        String parentTheoryDigest = args[13];
        check(nullary.theoryDigest().equals(emptyTheoryDigest)
                        && slot.theoryDigest().equals(emptyTheoryDigest),
                "nullary and slot fixtures match the external empty-theory pin");
        check(parent.theoryDigest().equals(parentTheoryDigest),
                "parent fixture matches its external input-specific pin");
        assertVerified(verifier.verify(
                nullaryA, Profile.FULL,
                VerificationPolicy.trust(emptyTheoryDigest)), "nullary FULL");
        assertVerified(verifier.verify(
                slotA, Profile.FULL,
                VerificationPolicy.trust(emptyTheoryDigest)), "slot FULL");
        assertVerified(verifier.verify(
                parentA, Profile.FULL,
                VerificationPolicy.trust(parentTheoryDigest)), "parent FULL");
        Bundle bundlePairLeft = decode(equivalentLeft);
        Bundle bundlePairRight = decode(equivalentRight);
        Path repo = Path.of(args[9]).toAbsolutePath().normalize();
        String expectedCommit = command(repo, "git", "rev-parse", "HEAD");
        boolean expectedDirty = !command(
                repo, "git", "status", "--porcelain", "--untracked-files=all").isEmpty();
        String sourceHash = fingerprint(repo.resolve("src"), ".java");
        String producerJarHash = sha256(Path.of(args[10]));
        String verifierJarHash = sha256(Path.of(args[11]));
        String dependencyHashes = dependencyHashes(repo.resolve("lib"));
        for (Bundle bundle : List.of(
                nullary, slot, parent, bundlePairLeft, bundlePairRight)) {
            Bundle.Metadata metadata = bundle.metadata();
            check(metadata.producerCommit().equals(expectedCommit),
                    "producer provenance uses the current Git commit");
            check(metadata.dirty() == expectedDirty,
                    "producer provenance uses the current Git cleanliness");
            check(metadata.mode().equals("TEST_ONLY"),
                    "fixture provenance is visibly test-only");
            check(metadata.javaSourceSha256().equals(sourceHash),
                    "producer provenance binds current Java sources");
            check(metadata.producerJarSha256().equals(producerJarHash),
                    "producer provenance binds the compiled producer JAR");
            check(metadata.verifierJarSha256().equals(verifierJarHash),
                    "producer provenance binds the standalone verifier JAR");
            check(metadata.dependencyHashes().equals(dependencyHashes),
                    "producer provenance binds every dependency JAR");
        }
        check(!java.util.Arrays.equals(equivalentLeft, equivalentRight),
                "bundle-level PAIR fixtures have distinct encoded bytes");
        check(!bundlePairLeft.metadata().inputIdentifier().equals(
                        bundlePairRight.metadata().inputIdentifier()),
                "bundle-level PAIR fixtures retain distinct metadata identities");
        check(bundlePairLeft.metadata().inputSha256().equals(
                        sha256("pred left { pair_equivalent }")),
                "bundle-level left metadata hash is exact");
        check(bundlePairRight.metadata().inputSha256().equals(
                        sha256("pred right { pair_equivalent }")),
                "bundle-level right metadata hash is exact");
        check(bundlePairLeft.theoryDigest().equals(emptyTheoryDigest)
                        && bundlePairRight.theoryDigest().equals(emptyTheoryDigest),
                "bundle-level PAIR fixtures match the external empty-theory pin");
        assertVerified(verifier.verifyPair(
                equivalentLeft,
                equivalentRight,
                VerificationPolicy.trust(emptyTheoryDigest)),
                "manually constructed bundle-level equivalent PAIR");

        VerificationResult nonEquivalentResult = verifier.verifyPair(
                equivalentLeft,
                nonEquivalent,
                VerificationPolicy.trust(emptyTheoryDigest));
        check(nonEquivalentResult.outcome() == Outcome.UNCHECKABLE
                        && nonEquivalentResult.code()
                                == FailureCode.MISSING_PAIR_DERIVATION,
                "distinct non-equivalent PAIR has the justified non-success status");

        byte[] incompatible = withIncompatibleTheory(equivalentRight);
        VerificationResult incompatibleResult = verifier.verifyPair(
                equivalentLeft,
                incompatible,
                VerificationPolicy.trust(emptyTheoryDigest));
        check(incompatibleResult.outcome() == Outcome.REJECTED
                        && incompatibleResult.code() == FailureCode.THEORY_MISMATCH,
                "an incompatible producer theory is rejected before trust elevation");

        check(slot.contexts().values().stream()
                        .anyMatch(context -> context.children().size() == 1),
                "slot fixture contains a nonempty typed context");
        check(slot.terms().values().stream()
                        .anyMatch(term -> "ONE_SLOT".equals(term.scalar(1))),
                "slot fixture contains ONE_SLOT");

        Wire.Node schemaSection = parent.vocabulary().child(0);
        check(schemaSection.children().stream().anyMatch(schema ->
                        "ONE".equals(schema.scalar(1))
                                && ("T".equals(schema.scalar(2))
                                || "Bool".equals(schema.scalar(2)))),
                "parent fixture declares verifier ONE schemas");
        java.util.Map<String, String> schemaTypes = schemaSection.children().stream()
                .collect(java.util.stream.Collectors.toMap(
                        schema -> schema.scalar(0), schema -> schema.scalar(2)));
        Wire.Node operatorSection = parent.vocabulary().child(1);
        check(operatorSection.children().size() == 3,
                "parent fixture declares left, right, and wrap operators");
        List<String> operatorInputTypes = operatorSection.children().stream()
                .map(operator -> schemaTypes.get(operator.child(0).scalar(0)))
                .sorted()
                .toList();
        check(operatorInputTypes.equals(List.of("Bool", "T", "T")),
                "operator references are exactly One(Bool), One(T), One(T)");
        check(parent.theory().child(0).children().size() == 1,
                "parent fixture registers exactly one ground axiom");
        Set<String> termKinds = parent.terms().values().stream()
                .map(term -> term.scalar(1)).collect(java.util.stream.Collectors.toSet());
        check(termKinds.containsAll(Set.of("APP", "INVOKE", "ONE_SLOT", "ONE_TERM")),
                "parent fixture contains complete recursive APP/INVOKE/ONE terms");
        Set<String> proofKinds = parent.proofs().values().stream()
                .map(proof -> proof.scalar(1)).collect(java.util.stream.Collectors.toSet());
        check(proofKinds.containsAll(Set.of(
                        "AXIOM", "PARENT_EDGE", "CONGRUENCE", "TRANS",
                        "KERNEL_REPLAY", "CANONICAL_ORBIT", "FRESH_WITNESS")),
                "parent fixture contains ground, edge, lifted, and replay proofs");

        List<Wire.Node> nonemptyPaths = parent.proofs().values().stream()
                .filter(proof -> "KERNEL_REPLAY".equals(proof.scalar(1)))
                .map(proof -> proof.child(1).child(0))
                .filter(paths -> !paths.children().isEmpty())
                .toList();
        check(nonemptyPaths.size() == 1,
                "exactly one replay requires a parent path");
        Wire.Node path = nonemptyPaths.get(0).child(0);
        check("0/0".equals(path.scalar(0)) && path.children().size() >= 1,
                "wrapper path is 0/0 and contains a certified edge reference");
        check(!path.scalar(1).equals(path.scalar(2)),
                "wrapper path changes from nonleader to leader witness");
        Wire.Node finalInvocation = parent.terms().get(path.scalar(3));
        check(finalInvocation != null
                        && "INVOKE".equals(finalInvocation.scalar(1))
                        && path.scalar(2).equals(finalInvocation.scalar(5)),
                "parent path resolves to its declared leader invocation");

        List<String> events = parent.events().stream()
                .map(event -> event.scalar(1)).toList();
        check(events.equals(List.of(
                        "INSERT_FRESH",
                        "INSERT_FRESH",
                        "UNION",
                        "REBUILD_COMPLETE",
                        "INSERT_FRESH")),
                "parent fixture has the exact accepted event sequence");
        check(parent.snapshots().size() == 6,
                "five transitions retain all six exact snapshots");
        Wire.Node unfolding = parent.unfoldings().values().iterator().next();
        check("2".equals(unfolding.scalar(2)),
                "parent unfolding has exact height two");
        Wire.Node rootRep = unfolding.child(0);
        Wire.Node repChildren = rootRep.child(2);
        check(repChildren.children().size() == 1
                        && "0/0".equals(repChildren.child(0).scalar(0))
                        && "1".equals(repChildren.child(0).child(0).scalar(3)),
                "height-two unfolding contains the exact leaf representative");

        System.out.println("ProducerBundleInspectionTest: " + checks
                + " checks passed");
    }

    private static Bundle decode(byte[] bytes) {
        return Bundle.parse(Codec.decode(bytes, Limits.defaults()));
    }

    private static byte[] withIncompatibleTheory(byte[] bytes) {
        Wire.Node root = Codec.decode(bytes, Limits.defaults());
        Wire.Node manifest = root.child(1);
        Wire.Node incompatibleTheory = Wire.node(
                "theory",
                List.of("incompatible-test-theory", Bundle.RULE_SET,
                        Bundle.VOCABULARY_POLICY),
                List.of(manifest.child(0).child(0)));
        String digest = Wire.contentId(incompatibleTheory);
        Wire.Node replacement = Wire.node(
                "manifest",
                List.of(digest, manifest.scalar(1)),
                List.of(incompatibleTheory, manifest.child(1)));
        List<Wire.Node> children = new java.util.ArrayList<>(root.children());
        children.set(1, replacement);
        return Codec.encode(Wire.node(root.tag(), root.scalars(), children));
    }

    private static String command(Path directory, String... command) throws Exception {
        Process process = new ProcessBuilder(command)
                .directory(directory.toFile())
                .redirectErrorStream(true)
                .start();
        String output = new String(
                process.getInputStream().readAllBytes(), StandardCharsets.UTF_8).trim();
        if (process.waitFor() != 0) {
            throw new AssertionError("provenance command failed: " + output);
        }
        return output;
    }

    private static String dependencyHashes(Path directory) throws Exception {
        List<Path> jars;
        try (Stream<Path> stream = Files.walk(directory)) {
            jars = stream.filter(Files::isRegularFile)
                    .filter(path -> path.getFileName().toString().endsWith(".jar"))
                    .sorted(Comparator.comparing(path -> directory.relativize(path).toString()))
                    .toList();
        }
        List<String> entries = new java.util.ArrayList<>();
        for (Path jar : jars) {
            entries.add(directory.relativize(jar).toString().replace('\\', '/')
                    + "=" + sha256(jar));
        }
        return String.join(";", entries);
    }

    private static String fingerprint(Path root, String suffix) throws Exception {
        List<Path> files;
        try (Stream<Path> stream = Files.walk(root)) {
            files = stream.filter(Files::isRegularFile)
                    .filter(path -> path.getFileName().toString().endsWith(suffix))
                    .sorted(Comparator.comparing(path -> root.relativize(path).toString()))
                    .toList();
        }
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        for (Path file : files) {
            digest.update(root.relativize(file).toString().replace('\\', '/')
                    .getBytes(StandardCharsets.UTF_8));
            digest.update((byte) 0);
            update(digest, file);
            digest.update((byte) 0xff);
        }
        return HexFormat.of().formatHex(digest.digest());
    }

    private static String sha256(Path path) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        update(digest, path);
        return HexFormat.of().formatHex(digest.digest());
    }

    private static String sha256(String value) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                .digest(value.getBytes(StandardCharsets.UTF_8)));
    }

    private static void update(MessageDigest digest, Path path) throws Exception {
        byte[] buffer = new byte[64 * 1024];
        try (InputStream input = Files.newInputStream(path)) {
            int read;
            while ((read = input.read(buffer)) >= 0) {
                if (read > 0) {
                    digest.update(buffer, 0, read);
                }
            }
        }
    }

    private static void assertVerified(VerificationResult result, String label) {
        check(result.outcome() == Outcome.VERIFIED,
                label + " expected VERIFIED but got " + result);
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
