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
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/** Separately parsed source, ordinary producer, real wire bytes and standalone FULL replay. */
public final class RawCallAuthorityRegressionTest {
    private static final String MODEL = """
            module callscope
            sig A {}
            fun f[x:A]: A { x }
            fun g[x:A]: A { x }
            fun h[x,y:A]: A { x }
            fun firstArg: A { A }
            fun secondArg: A { A }
            pred mixed { some f[g[A]] }
            pred repeated { some f[f[A]] }
            pred ordered { some h[firstArg[],secondArg[]] }
            pred reversed { some h[secondArg[],firstArg[]] }
            pred unsupported { no f[A] }
            """;
    private static final byte[] SOURCE = MODEL.getBytes(StandardCharsets.UTF_8);
    private static final String EMPTY_THEORY =
            "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";

    private final Path directory, verifier;
    private final List<String> results = new ArrayList<>(List.of("case\toutcome\tcode"));

    private RawCallAuthorityRegressionTest(Path directory, Path verifier) {
        this.directory = directory;
        this.verifier = verifier;
    }

    private Path export(String actual, String recorded) throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, MODEL);
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of(actual), module);
        visitor.visit(new ModelUnit(null, module), null);
        var graph = visitor.getForest().get(visitor.getForestId(actual));
        var prepared = CanonicalAlloyPipeline.prepareCompatibilityForVerification(
                graph, "callscope/" + recorded, SOURCE);
        Path path = directory.resolve(actual + "-as-" + recorded + ".acgncert");
        prepared.certificateExportSession().write(path);
        return path;
    }

    private static RawCallSourceAuthority authority(String name) throws Exception {
        return RawCallSourceAuthority.fromSource(SOURCE, "callscope/" + name);
    }

    private void standalone(String label, Path bundle, CallOccurrenceCommitment pin,
            int expectedExit, String outcome, String code, String diagnostic) throws Exception {
        var cmd = new ArrayList<>(List.of(Path.of(System.getProperty("java.home"), "bin", "java").toString(),
                "-Xmx384m", "-jar", verifier.toString(), "--profile", "full", "--theory-digest", EMPTY_THEORY));
        if (pin != null) cmd.addAll(List.of("--call-occurrence-commitment", pin.assignment()));
        cmd.add(bundle.toString());
        Path log = directory.resolve(label + ".log");
        var process = new ProcessBuilder(cmd).redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if (!process.waitFor(60, TimeUnit.SECONDS)) {
            process.destroyForcibly();
            process.waitFor();
            throw new AssertionError(label + " verifier timed out");
        }
        String output = Files.readString(log);
        var json = new JSONObject(output);
        if (process.exitValue() != expectedExit || !json.getString("outcome").equals(outcome)
                || !json.getString("code").equals(code) || !json.getString("detail").contains(diagnostic)) {
            throw new AssertionError(label + " unexpected standalone result " + output);
        }
        results.add(label + "\t" + outcome + "\t" + code);
    }

    @FunctionalInterface private interface Check { void run() throws Exception; }

    private void refusal(String label, String reason, Check check) throws Exception {
        try {
            check.run();
        } catch (IllegalArgumentException error) {
            if (!reason.equals(error.getMessage())) throw error;
            results.add(label + "\tSOURCE_REFUSAL\t" + reason);
            return;
        }
        throw new AssertionError(label + " accepted unexpectedly");
    }

    private void run() throws Exception {
        // Derive all three complete source inventories before creating any candidate.
        var mixed = authority("mixed");
        var repeated = authority("repeated");
        var ordered = authority("ordered");
        Path first = export("mixed", "mixed"), second = export("repeated", "repeated");
        Path binary = export("ordered", "ordered");
        var firstPin = mixed.commitment(Files.readAllBytes(first));
        byte[] secondBytes = Files.readAllBytes(second);
        var secondPin = repeated.commitment(secondBytes);
        standalone("mixed", first, firstPin, 0, "VERIFIED", "NONE", "full profile");
        standalone("same-callee", second, secondPin, 0, "VERIFIED", "NONE", "full profile");
        standalone("binary-roles", binary, ordered.commitment(Files.readAllBytes(binary)),
                0, "VERIFIED", "NONE", "full profile");
        standalone("missing-pin", second, null, 3, "UNCHECKABLE", "MISSING_EVIDENCE", "caller-pinned");
        standalone("wrong-root-pin", second, firstPin, 3, "UNCHECKABLE", "MISSING_EVIDENCE", "caller-pinned");

        // Both rows name f: deleting one row AND its self-declared anchor leaves the same set of operators.
        Path omitted = directory.resolve("coordinated-omission.acgncert");
        byte[] omission = ProducerSemanticEvidenceMutationTest.coordinatedCallOmission(secondBytes, 0);
        Files.write(omitted, omission);
        if (!secondPin.equals(repeated.commitment(omission))) {
            throw new AssertionError("candidate CALL inventory influenced independent expected set");
        }
        standalone("coordinated-omission", omitted, secondPin, 2, "REJECTED", "MISSING_EVIDENCE",
                "differs from the caller-pinned source commitment");
        refusal("foreign-root", "different selected source or root",
                () -> mixed.commitment(secondBytes));
        refusal("different-bytes", "different selected source or root",
                () -> RawCallSourceAuthority.fromSource((MODEL + "\n").getBytes(StandardCharsets.UTF_8),
                        "callscope/mixed").commitment(Files.readAllBytes(first)));
        refusal("relabelled-callee", "different typed CALL endpoint",
                () -> mixed.commitment(Files.readAllBytes(export("repeated", "mixed"))));
        refusal("relabelled-role-order", "different typed CALL endpoint",
                () -> ordered.commitment(Files.readAllBytes(export("reversed", "ordered"))));
        refusal("unsupported-root", "unsupported root body", () -> authority("unsupported"));
    }

    public static void main(String[] args) throws Exception {
        if (args.length > 1) throw new IllegalArgumentException("usage: RawCallAuthorityRegressionTest [OUTPUT.tsv]");
        Path jar = Path.of(System.getenv().getOrDefault("ACGN_SIXTH_VERIFIER_JAR",
                "certificate-verifier/build/acgn-certificate-verifier.jar")).toAbsolutePath();
        if (!Files.isRegularFile(jar)) throw new IllegalArgumentException("missing standalone verifier " + jar);
        Path temp = Files.createTempDirectory("acgn-sixth-raw-call-");
        var test = new RawCallAuthorityRegressionTest(temp, jar);
        try {
            test.run();
            if (args.length == 1) Files.write(Path.of(args[0]), test.results, StandardCharsets.UTF_8);
            System.out.println("RawCallAuthorityRegressionTest passed: cases=" + (test.results.size() - 1));
        } finally {
            try (var paths = Files.walk(temp)) {
                for (Path path : paths.sorted(Comparator.reverseOrder()).toList()) Files.delete(path);
            }
        }
    }
}
