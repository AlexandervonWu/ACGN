package org.acgn.cert;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.CanonicalAlloyPipeline;
import is.fivefivefive.CanDis.theory.CertificateExportSession;
import parser.ast.nodes.ModelUnit;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.security.MessageDigestSpi;
import java.security.Provider;
import java.security.Security;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.List;
import java.util.Set;

/** Runs in a fresh test JVM. The production entry points receive ordinary JCA SHA-256. */
public final class P411ShapeIdentityTest {
    private static final String MODEL = "module shapes\nsig A,B {} pred p { A in B }";
    private static final String ROOT = "shapes/p";
    private static final String THEORY = "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";
    private static final String ALIAS = "shape/" + "00".repeat(32);
    private static final List<String> rows = new ArrayList<>(List.of("case\toutcome"));

    private static MessageDigest stock() {
        try { return MessageDigest.getInstance("SHA-256", "SUN"); }
        catch (Exception e) { throw new AssertionError(e); }
    }

    private static String hex(byte[] bytes) { return HexFormat.of().formatHex(bytes); }

    private static byte[] frame(String owner, String term) throws IOException {
        var bytes = new ByteArrayOutputStream();
        try (var out = new DataOutputStream(bytes)) {
            byte[] tag = "producer-shape-id".getBytes(StandardCharsets.UTF_8);
            out.writeInt(tag.length); out.write(tag);
            out.writeInt(2);
            for (String field : List.of(owner, term)) {
                byte[] value = field.getBytes(StandardCharsets.UTF_8);
                out.writeInt(value.length); out.write(value);
            }
            out.writeInt(0);
        }
        return bytes.toByteArray();
    }

    // Only exact, pre-enumerated shape preimages can receive the synthetic common digest.
    // All other digests, including file envelopes, still use the stock implementation.
    public static final class ShapeDigest extends MessageDigestSpi {
        private static Set<String> selected = Set.of();
        private static final Set<String> observed = new HashSet<>();
        private static boolean collide;
        private final MessageDigest delegate = stock();
        private final byte[] prefix = new byte[256];
        private int used;
        private boolean tooLong;
        @Override protected void engineUpdate(byte value) {
            delegate.update(value);
            if (used < prefix.length) prefix[used++] = value; else tooLong = true;
        }
        @Override protected void engineUpdate(byte[] bytes, int off, int len) {
            delegate.update(bytes, off, len);
            int copy = Math.min(prefix.length - used, len);
            System.arraycopy(bytes, off, prefix, used, copy);
            used += copy;
            if (copy < len) tooLong = true;
        }
        @Override protected byte[] engineDigest() {
            byte[] real = delegate.digest();
            if (!tooLong) {
                String current = hex(Arrays.copyOf(prefix, used));
                if (selected.contains(current)) {
                    observed.add(current);
                    if (collide) real = new byte[32];
                }
            }
            engineReset();
            return real;
        }
        @Override protected void engineReset() { delegate.reset(); used = 0; tooLong = false; }
        @Override protected int engineGetDigestLength() { return 32; }
    }

    private static Provider provider() {
        return new Provider("P411ShapeFixture", "1.0", "isolated shape-preimage test") {{
            put("MessageDigest.SHA-256", ShapeDigest.class.getName());
        }};
    }

    private static void require(boolean ok, String message) {
        if (!ok) throw new AssertionError(message);
    }

    private static CertificateExportSession session() throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, MODEL);
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of("p"), module);
        visitor.visit(new ModelUnit(null, module), null);
        return CanonicalAlloyPipeline.prepareCompatibilityForVerification(
                visitor.getForest().get(visitor.getForestId("p")), ROOT,
                MODEL.getBytes(StandardCharsets.UTF_8)).certificateExportSession();
    }

    private static VerificationPolicy policy() {
        String sourceHash = hex(stock().digest(MODEL.getBytes(StandardCharsets.UTF_8)));
        String subject = CallOccurrenceCommitment.subjectDigest(ROOT, sourceHash);
        return VerificationPolicy.trust(THEORY).withCallOccurrenceCommitment(
                new CallOccurrenceCommitment(subject, CallOccurrenceCommitment.digest(subject, List.of())));
    }

    private static void verify(String name, byte[] bytes, Profile profile, Outcome outcome,
            FailureCode expected, String detail) {
        var result = new IndependentVerifier().verify(bytes, profile, policy());
        require(result.outcome() == outcome && result.code() == expected && result.detail().contains(detail),
                name + " unexpected " + result);
        rows.add(name + "\t" + outcome + "/" + expected);
    }

    private static Wire.Node singleton(Wire.Node base, Wire.Node shape, String earliest) {
        String owner = shape.scalar(1);
        Wire.Node classRow = base.child(0).children().stream().filter(r -> r.scalar(0).equals(owner)).findFirst().orElseThrow();
        Wire.Node hash = base.child(3).children().stream().filter(r -> r.scalar(1).equals(owner)).findFirst().orElseThrow();
        var fields = new ArrayList<>(shape.scalars()); fields.set(0, ALIAS);
        var sections = List.of(
                Wire.node("classes", List.of(classRow)), Wire.node("parents", List.of()),
                Wire.node("shapes", List.of(Wire.node("shape", fields, List.of()))),
                Wire.node("hash-cons", List.of(hash)), Wire.node("parent-uses", List.of()),
                Wire.node("symmetries", List.of()), base.child(6));
        // Place both isolated controls first in the canonical snapshot table. Original
        // snapshots must remain available to the independent semantic orbit replay.
        long revision = Long.parseLong(base.scalar(1));
        for (int offset = 0; offset < 16384; offset++) {
            var snap = Bundle.withContentId("snapshot", List.of(Long.toString(revision + offset), base.scalar(2)), sections);
            if (snap.scalar(0).compareTo(earliest) < 0) return snap;
        }
        throw new AssertionError("could not order controlled singleton before baseline snapshots");
    }

    private static byte[] withSnapshots(Bundle bundle, List<Wire.Node> snapshots) {
        var children = new ArrayList<>(bundle.root().children());
        var records = new ArrayList<>(bundle.snapshots().values());
        records.addAll(snapshots);
        children.set(7, Wire.node("snapshots", records.stream().sorted(Comparator.comparing(n -> n.scalar(0))).toList()));
        return Codec.encode(Wire.node(bundle.root().tag(), bundle.root().scalars(), children));
    }

    /** Runs the real CLI in a child VM with the selected JAR first on its class path. */
    public static final class JarReplay {
        public static void main(String[] args) throws Exception {
            Path jar = Path.of(args[0]).toRealPath();
            for (Class<?> type : List.of(Main.class, IndependentVerifier.class, CheckpointVerifier.class)) {
                Path origin = Path.of(type.getProtectionDomain().getCodeSource().getLocation().toURI()).toRealPath();
                require(jar.equals(origin), "verifier class did not come from the requested JAR: " + type);
            }
            ShapeDigest.selected = Set.of(args[1], args[2]);
            ShapeDigest.collide = true;
            require(Security.insertProviderAt(provider(), 1) == 1, "child provider installation");
            Main.main(Arrays.copyOfRange(args, 3, args.length));
        }
    }

    private static void jarCollision(Path tmp, Path jar, String label, byte[] encoded,
            String frameA, String frameB) throws Exception {
        Path artifact = tmp.resolve("disjoint.acgncert");
        Files.write(artifact, encoded);
        Path probes = Path.of(P411ShapeIdentityTest.class.getProtectionDomain().getCodeSource().getLocation().toURI());
        Path log = tmp.resolve(label + ".log");
        String pin = policy().trustedCallOccurrenceDigests().entrySet().iterator().next().toString();
        var process = new ProcessBuilder(Path.of(System.getProperty("java.home"), "bin", "java").toString(),
                "-Xmx256m", "-cp", jar + java.io.File.pathSeparator + probes,
                JarReplay.class.getName(), jar.toString(), frameA, frameB, "--profile", "checkpoint",
                "--theory-digest", THEORY, "--call-occurrence-commitment", pin, artifact.toString())
                .redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if (!process.waitFor(60, java.util.concurrent.TimeUnit.SECONDS)) {
            process.destroyForcibly(); process.waitFor(); throw new AssertionError("CLI timed out");
        }
        String output = Files.readString(log);
        require(process.exitValue() == 2 && output.contains("\"outcome\":\"REJECTED\",\"code\":\"DUPLICATE_ID\"")
                && output.contains("Shape ID collision between distinct owner and term preimages"),
                "unexpected " + label + " CLI outcome " + output);
        rows.add(label + "\tREJECTED/DUPLICATE_ID");
    }

    private static void run(Path tmp, Path fresh, Path distributed) throws Exception {
        var session = session();
        Path first = tmp.resolve("normal.acgncert"), second = tmp.resolve("repeat.acgncert");
        session.write(first);
        byte[] encoded = Files.readAllBytes(first);
        var bundle = Bundle.parse(Codec.decode(encoded, Limits.defaults()));
        Wire.Node base = bundle.snapshots().get(bundle.publication().scalar(0));
        require(base != null && base.child(2).children().size() == 3, "expected two leaves and inclusion root");
        var model = new KernelModel(bundle, Limits.defaults());
        var leaves = base.child(2).children().stream()
                .filter(r -> model.term(r.scalar(2)).children().isEmpty()).toList();
        require(leaves.size() == 2, "expected two independently valid nullary shape owners");
        var frames = new HashSet<String>();
        for (var snap : bundle.snapshots().values()) {
            for (var shape : snap.child(2).children()) {
                byte[] raw = frame(shape.scalar(1), shape.scalar(2));
                require(shape.scalar(0).equals("shape/" + hex(stock().digest(raw))), "noncanonical producer shape ID");
                require(Arrays.equals(raw, Codec.encodeNode(Wire.leaf("producer-shape-id", shape.scalar(1),
                        shape.scalar(2)))), "wire framing differs from the producer preimage");
                frames.add(hex(raw));
            }
        }
        require(frames.size() == 3, "expected three exact preimages");
        rows.add("snapshot-preimages\tTHREE_EXACT_OWNER_TERM_FRAMES");
        verify("ordinary-full", encoded, Profile.FULL, Outcome.VERIFIED, FailureCode.NONE, "full profile");
        Provider provider = provider();
        require(Security.insertProviderAt(provider, 1) == 1, "isolated provider installation");
        try {
            ShapeDigest.selected = Set.copyOf(frames);
            session.write(second);
            require(ShapeDigest.observed.equals(frames) && Arrays.equals(encoded, Files.readAllBytes(second)),
                    "writer changed bytes or failed to hash the exact frames");
            rows.add("writer-trace\tALL_FRAMES_IDENTICAL_BYTES");
            ShapeDigest.observed.clear();
            verify("verifier-trace", encoded, Profile.CHECKPOINT, Outcome.VERIFIED, FailureCode.NONE, "checkpoint");
            require(ShapeDigest.observed.equals(frames), "checkpoint did not observe the exact same preimages");
            ShapeDigest.collide = true;
            try {
                session.write(first);
                throw new AssertionError("writer accepted colliding preimages");
            } catch (IOException e) {
                require(e.getMessage().contains("UNCHECKABLE: shape ID collision")
                        && Arrays.equals(encoded, Files.readAllBytes(first)), "wrong writer collision outcome: " + e);
            }
            rows.add("writer-collision\tREFUSED_DESTINATION_PRESERVED");
            String earliest = bundle.snapshots().keySet().stream().min(String::compareTo).orElseThrow();
            var a = singleton(base, leaves.get(0), earliest);
            var b = singleton(base, leaves.get(1), earliest);
            String frameA = hex(frame(leaves.get(0).scalar(1), leaves.get(0).scalar(2)));
            String frameB = hex(frame(leaves.get(1).scalar(1), leaves.get(1).scalar(2)));
            // A singleton validates first. Replaying the unchanged original then finds that
            // its historical SHA identifier no longer agrees with this test digest.
            ShapeDigest.selected = Set.of(frameA);
            verify("one-frame-a", withSnapshots(bundle, List.of(a)), Profile.CHECKPOINT, Outcome.REJECTED,
                    FailureCode.NONCANONICAL_ENCODING, "Shape identity is not derived");
            ShapeDigest.selected = Set.of(frameB);
            verify("one-frame-b", withSnapshots(bundle, List.of(b)), Profile.CHECKPOINT, Outcome.REJECTED,
                    FailureCode.NONCANONICAL_ENCODING, "Shape identity is not derived");
            ShapeDigest.selected = Set.of(frameA, frameB);
            byte[] disjoint = withSnapshots(bundle, List.of(a,b));
            verify("disjoint-snapshot-alias", disjoint, Profile.CHECKPOINT,
                    Outcome.REJECTED, FailureCode.DUPLICATE_ID, "distinct owner and term preimages");
            require(Files.mismatch(fresh, distributed) == -1, "distributed verifier differs from the fresh build");
            jarCollision(tmp, fresh, "fresh-jar-alias", disjoint, frameA, frameB);
            jarCollision(tmp, distributed, "distributed-jar-alias", disjoint, frameA, frameB);
        } finally {
            Security.removeProvider(provider.getName());
            ShapeDigest.selected = Set.of(); ShapeDigest.observed.clear(); ShapeDigest.collide = false;
        }
        verify("fresh-replay", encoded, Profile.CHECKPOINT, Outcome.VERIFIED, FailureCode.NONE, "checkpoint");
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("usage: P411ShapeIdentityTest OUTPUT.tsv FRESH_VERIFIER_JAR");
        Path temp = Files.createTempDirectory("acgn-eighth-p411-");
        try {
            run(temp, Path.of(args[1]).toAbsolutePath(),
                    Path.of("certificate-verifier/build/acgn-certificate-verifier.jar").toAbsolutePath());
            Files.write(Path.of(args[0]), rows, StandardCharsets.UTF_8);
            System.out.println("P411ShapeIdentityTest passed: cases=" + (rows.size() - 1));
        } finally {
            try (var paths = Files.walk(temp)) {
                for (var path : paths.sorted(Comparator.reverseOrder()).toList()) Files.delete(path);
            }
        }
    }
}
