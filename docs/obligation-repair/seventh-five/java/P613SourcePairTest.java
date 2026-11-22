package org.acgn.cert;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.CanonicalAlloyPipeline;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/** Finite public CLI and source-bound PAIR witnesses. Theory authority is TEST_ONLY. */
public final class P613SourcePairTest {
    private static final String THEORY =
            "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";
    private static final String DECLARATIONS = """
            module paircalls
            sig A {}
            sig B {}
            fun f[x:A]: A { x }
            fun g[x:B]: B { x }
            """;

    private record Side(String label, String selected, Path source, Path certificate,
            CallOccurrenceCommitment pin, Endpoint endpoint) {}
    private record Endpoint(String root, String replay, String middle, String orbit,
            String representative, String sort, String shape, String count) {}

    private final Path jar, dir;
    private final List<String> cases = new ArrayList<>(List.of("case\toutcome\tcode"));
    private final List<String> owners = new ArrayList<>(List.of(
            "case\tselector\tsourceSha256\tsubject\troot\treplayProof\tkernel\torbitProof\trepresentative\tsort\tshapeSha256\torbitCount"));

    private P613SourcePairTest(Path jar, Path dir) {
        this.jar = jar;
        this.dir = dir;
    }

    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    private static String hash(byte[] bytes) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
    }

    private Side export(String label, String predicate, String body) throws Exception {
        String text = DECLARATIONS + "pred " + predicate + " { " + body + " }\n";
        Path source = dir.resolve(label + ".als");
        Files.writeString(source, text, StandardCharsets.UTF_8);
        byte[] raw = Files.readAllBytes(source);
        String selected = "paircalls/" + predicate;
        RawCallSourceAuthority authority = RawCallSourceAuthority.fromSource(raw, selected);
        var parsed = CompUtil.parseEverything_fromString(A4Reporter.NOP, text);
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of(predicate), parsed);
        visitor.visit(new ModelUnit(null, parsed), null);
        var graph = visitor.getForest().get(visitor.getForestId(predicate));
        var prepared = CanonicalAlloyPipeline.prepareCompatibilityForVerification(graph, selected, raw);
        Path certificate = dir.resolve(label + ".acgncert");
        prepared.certificateExportSession().write(certificate);
        byte[] bytes = Files.readAllBytes(certificate);
        var pin = authority.commitment(bytes);
        var policy = VerificationPolicy.trust(THEORY).withCallOccurrenceCommitment(pin);
        var full = new IndependentVerifier().verify(bytes, Profile.FULL, policy);
        require(full.outcome() == Outcome.VERIFIED, label + ": " + full);
        Endpoint e = observe(bytes, policy);
        owners.add(String.join("\t", label, selected, hash(raw), pin.subjectDigest(), e.root,
                e.replay, e.middle, e.orbit, e.representative, e.sort,
                hash(e.shape.getBytes(StandardCharsets.UTF_8)), e.count));
        return new Side(label, selected, source, certificate, pin, e);
    }

    private static Endpoint observe(byte[] bytes, VerificationPolicy policy) {
        Bundle bundle = Bundle.parse(Codec.decode(bytes, policy.limits()));
        KernelModel model = new KernelModel(bundle, policy.limits());
        var auth = new SemanticEvidenceVerifier(bundle, model, policy).verify();
        var kernel = new KernelVerifier(model, policy.limits(), auth);
        kernel.verifyAll();
        new CanonicalProfileVerifier(model, kernel, policy.limits()).verifyAllRecords();
        List<Endpoint> candidates = new ArrayList<>();
        for (var row : bundle.canonicalRecords().values()) {
            String replayId = row.child(0).scalar(0);
            var replay = kernel.verify(replayId);
            if (!bundle.publication().scalar(2).equals(replay.left().id())) continue;
            String orbitId = row.scalar(1);
            var orbit = kernel.verify(orbitId);
            require(replay.right().id().equals(orbit.left().id()), "side-local replay/orbit endpoint");
            require(row.scalar(2).equals(orbit.right().id()), "published representative endpoint");
            var rep = orbit.right();
            candidates.add(new Endpoint(replay.left().id(), replayId, replay.right().id(), orbitId,
                    rep.id(), rep.sort().kind() + "/" + rep.sort().value(), kernel.canonicalTermKey(rep),
                    kernel.proofRecord(orbitId).payload().scalar(5)));
        }
        require(candidates.size() == 1, "unique published-root judgment per bundle");
        return candidates.get(0);
    }

    private static List<String> javaCommand() {
        return new ArrayList<>(List.of(Path.of(System.getProperty("java.home"), "bin", "java").toString(),
                "-Xmx384m"));
    }

    private void command(String label, List<String> args, int expectedExit, String outcome, String code)
            throws Exception {
        Path log = dir.resolve(label + ".log");
        var p = new ProcessBuilder(args).redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if (!p.waitFor(60, TimeUnit.SECONDS)) {
            p.destroyForcibly();
            p.waitFor();
            throw new AssertionError(label + " timeout");
        }
        String text = Files.readString(log).trim();
        var result = new JSONObject(text);
        require(p.exitValue() == expectedExit && result.getString("outcome").equals(outcome)
                && result.getString("code").equals(code), label + " exit " + p.exitValue() + " " + text);
        cases.add(label + "\t" + outcome + "\t" + code);
    }

    private void bound(String label, String theory, Side a, Side b, Path candidateA, Path candidateB,
            int status, String outcome, String code) throws Exception {
        var args = javaCommand();
        args.addAll(List.of("-cp", System.getProperty("java.class.path"), P613SourcePair.class.getName(),
                theory, a.source.toString(), a.selected, candidateA.toString(),
                b.source.toString(), b.selected, candidateB.toString()));
        command(label, args, status, outcome, code);
    }

    private void wire(String label, Side a, Side b, List<CallOccurrenceCommitment> pins,
            int status, String outcome, String code) throws Exception {
        var args = javaCommand();
        args.addAll(List.of("-jar", jar.toString(), "--profile", b == null ? "full" : "pair",
                "--theory-digest", THEORY));
        for (var pin : pins) args.addAll(List.of("--call-occurrence-commitment", pin.assignment()));
        args.add(a.certificate.toString());
        if (b != null) args.add(b.certificate.toString());
        command(label, args, status, outcome, code);
    }

    private void sourceFull(String label, Side source, String selected, Side candidate,
            Outcome outcome, FailureCode code) throws Exception {
        var result = P613SourcePair.verifyFull(THEORY, Files.readAllBytes(source.source), selected,
                Files.readAllBytes(candidate.certificate));
        require(result.outcome() == outcome && result.code() == code, label + ": " + result);
        cases.add(label + "\t" + result.outcome() + "\t" + result.code());
    }

    private void run() throws Exception {
        Side a = export("left", "first", "some f[A]");
        Side b = export("right", "second", "some (f[A])");
        Side c = export("unequal", "first", "some g[B]");
        Side d = export("same-name", "first", "some (f[A])");
        for (Side s : List.of(a, b, c, d)) wire("full-" + s.label, s, null, List.of(s.pin), 0, "VERIFIED", "NONE");
        require(a.selected.equals(d.selected) && !a.pin.subjectDigest().equals(d.pin.subjectDigest())
                && !a.pin.subjectDigest().equals(b.pin.subjectDigest()), "separate source scopes");
        require(a.endpoint.shape.equals(b.endpoint.shape) && a.endpoint.sort.equals(b.endpoint.sort)
                && a.endpoint.shape.equals(d.endpoint.shape) && a.endpoint.sort.equals(d.endpoint.sort),
                "exact typed representative equality");
        require(!a.endpoint.shape.equals(c.endpoint.shape) || !a.endpoint.sort.equals(c.endpoint.sort),
                "expected different typed representative");
        bound("equivalent", THEORY, a, b, a.certificate, b.certificate, 0, "VERIFIED", "NONE");
        bound("reversed", THEORY, b, a, b.certificate, a.certificate, 0, "VERIFIED", "NONE");
        bound("same-name-distinct-bytes", THEORY, a, d, a.certificate, d.certificate, 0, "VERIFIED", "NONE");
        bound("identical-source", THEORY, a, a, a.certificate, a.certificate, 0, "VERIFIED", "NONE");
        bound("unequal", THEORY, a, c, a.certificate, c.certificate, 3, "UNCHECKABLE", "MISSING_PAIR_DERIVATION");
        bound("foreign-right-owner", THEORY, a, b, a.certificate, a.certificate, 2,
                "REJECTED", "ENDPOINT_CLAIM_MISMATCH");
        bound("same-name-foreign-bytes", THEORY, a, c, a.certificate, a.certificate, 2,
                "REJECTED", "ENDPOINT_CLAIM_MISMATCH");
        bound("foreign-theory", "0".repeat(64), a, b, a.certificate, b.certificate, 2, "REJECTED", "UNTRUSTED_THEORY");
        wire("wire-equivalent", a, b, List.of(a.pin, b.pin), 0, "VERIFIED", "NONE");
        wire("wire-unequal", a, c, List.of(a.pin, c.pin), 3, "UNCHECKABLE", "MISSING_PAIR_DERIVATION");
        wire("wire-foreign-pin", a, b, List.of(a.pin, c.pin), 3, "UNCHECKABLE", "MISSING_EVIDENCE");
        sourceFull("source-full", a, a.selected, a, Outcome.VERIFIED, FailureCode.NONE);
        sourceFull("source-full-foreign-owner", d, d.selected, a, Outcome.REJECTED,
                FailureCode.ENDPOINT_CLAIM_MISMATCH);
        sourceFull("source-full-absent-selector", a, "paircalls/absent", a, Outcome.UNCHECKABLE,
                FailureCode.MISSING_EVIDENCE);
        Files.write(dir.resolve("p613-cases.tsv"), cases, StandardCharsets.UTF_8);
        Files.write(dir.resolve("p613-owners.tsv"), owners, StandardCharsets.UTF_8);
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("usage: P613SourcePairTest VERIFIER_JAR FRESH_DIR");
        var test = new P613SourcePairTest(Path.of(args[0]).toAbsolutePath(), Files.createDirectory(Path.of(args[1])));
        test.run();
        System.out.println("P613SourcePairTest passed: cases=" + (test.cases.size() - 1)
                + " owners=" + (test.owners.size() - 1));
    }
}
