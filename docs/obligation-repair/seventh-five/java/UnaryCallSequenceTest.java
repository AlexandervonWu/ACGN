package org.acgn.cert;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.CanonicalAlloyPipeline;
import is.fivefivefive.CanDis.NativeUnaryCallExport;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.acgn.cert.UnaryCallSequence.Endpoint;
import org.json.JSONArray;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;

/** Executable cross-check of source reconstruction against real native actions and two FULL exports. */
public final class UnaryCallSequenceTest {
    private static final String THEORY = "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";
    private static final String DECLS = "module roots\nsig A {}\nfun f[x:A]:A{x}\nfun g[x:A]:A{x}\nfun h[x:A]:A{x}\n";
    private static final FailureCode MISMATCH = FailureCode.ENDPOINT_CLAIM_MISMATCH;
    private final List<String> rows = new ArrayList<>(List.of("case\toutcome\tcode"));
    private final Path work;

    private UnaryCallSequenceTest(Path work) { this.work = work; }

    private record Side(Path raw, String root, Path cert, Endpoint endpoint) {}

    private Side export(String file, String predicate, String term, String prefix) throws Exception {
        String text = prefix + "pred " + predicate + " {some " + term + "}\n";
        Path raw = work.resolve(file + ".als"), cert = work.resolve(file + ".acgncert");
        Files.writeString(raw, text);
        String root = "roots/" + predicate;
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, text);
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of(predicate), module);
        visitor.visit(new ModelUnit(null, module), null);
        var graph = visitor.getForest().get(visitor.getForestId(predicate));
        var prepared = CanonicalAlloyPipeline.prepareCompatibilityForVerification(graph, root, text.getBytes(StandardCharsets.UTF_8));
        prepared.certificateExportSession().write(cert);
        return new Side(raw, root, cert, Endpoint.read(raw, root, cert));
    }

    private void check(String name, VerificationResult actual, Outcome outcome, FailureCode code) {
        if (actual.outcome() != outcome || actual.code() != code)
            throw new AssertionError(name + " " + actual);
        rows.add(name + "\t" + outcome + "\t" + code);
    }

    private void text(String name, String theory, Endpoint left, Endpoint right, String json,
            Outcome outcome, FailureCode code) {
        check(name, UnaryCallSequence.verify(theory, left, right, json.getBytes(StandardCharsets.UTF_8)), outcome, code);
    }

    private void bad(String name, Side a, Side b, JSONObject receipt, java.util.function.Consumer<JSONObject> change) {
        JSONObject edited = new JSONObject(receipt.toString());
        change.accept(edited);
        text(name, THEORY, a.endpoint, b.endpoint, edited.toString(), Outcome.REJECTED, MISMATCH);
    }

    private JSONObject capture(String name, Side a, Side b) throws Exception {
        JSONObject receipt = NativeUnaryCallExport.capture(THEORY, a.endpoint, b.endpoint);
        text(name, THEORY, a.endpoint, b.endpoint, receipt.toString(), Outcome.VERIFIED, FailureCode.NONE);
        Files.writeString(work.resolve(name + ".json"), receipt + "\n");
        return receipt;
    }

    private void run(Path output) throws Exception {
        Side a = export("left", "left", "f[g[A]]", DECLS);
        Side b = export("right", "right", "f[h[A]]", DECLS + "// separate source file\n");
        Side c = export("changed-outer", "outer", "h[g[A]]", DECLS);
        Side d = export("short", "shallow", "g[A]", DECLS);
        Side alternate = export("alternate", "left", "f[g[A]]", DECLS + "// same selector, distinct bytes\n");
        Side differentBody = export("other-function", "other", "f[h[A]]", DECLS.replace("h[x:A]:A{x}", "h[x:A]:A{A}"));
        JSONObject good = capture("native-inner-edit", a, b);
        JSONObject outer = capture("native-outer-edit", a, c);
        capture("native-reverse-edit", b, a);
        JSONArray innerRows = good.getJSONArray("actions"), outerRows = outer.getJSONArray("actions");
        if (innerRows.length() != 6 || outerRows.length() != 6 || good.getInt("distance") != 1
                || innerRows.getJSONObject(4).getInt("cost") != 1 || outerRows.getJSONObject(3).getInt("cost") != 1)
            throw new AssertionError("Expected distinct inner and outer operations");
        bad("distance", a, b, good, r -> r.put("distance", 0));
        bad("extra-key", a, b, good, r -> r.put("unexpected", 0));
        bad("fractional-cost", a, b, good, r -> r.getJSONArray("actions").getJSONObject(4).put("cost", 1.5));
        bad("omitted-free-step", a, b, good, r -> r.getJSONArray("actions").remove(1));
        bad("surplus-step", a, b, good, r -> r.getJSONArray("actions").put(innerRows.getJSONObject(0)));
        bad("reordered-steps", a, b, good, r -> {
            r.getJSONArray("actions").put(2, innerRows.get(3)).put(3, innerRows.get(2));
        });
        bad("misplaced-unit-cost", a, b, good, r -> {
            r.getJSONArray("actions").getJSONObject(4).put("cost", 0);
            r.getJSONArray("actions").getJSONObject(3).put("cost", 1);
        });
        bad("wrong-target-address", a, b, good, r -> r.getJSONArray("actions")
                .getJSONObject(4).put("target", "$/other"));
        bad("foreign-cert-digest", a, b, good, r -> r.getJSONObject("target")
                .put("certificateSha256", good.getJSONObject("source").getString("certificateSha256")));
        text("other-raw-source", THEORY, alternate.endpoint, b.endpoint, good.toString(), Outcome.REJECTED, MISMATCH);
        text("reversed-owners", THEORY, b.endpoint, a.endpoint, good.toString(), Outcome.REJECTED, MISMATCH);
        text("foreign-certificate", THEORY, Endpoint.read(a.raw, a.root, alternate.cert), b.endpoint,
                good.toString(), Outcome.REJECTED, MISMATCH);
        text("trailing-data", THEORY, a.endpoint, b.endpoint, good + "#", Outcome.REJECTED, FailureCode.INVALID_RECORD_SHAPE);
        text("malformed", THEORY, a.endpoint, b.endpoint, "{", Outcome.REJECTED, FailureCode.INVALID_RECORD_SHAPE);
        text("wrong-theory", "0".repeat(64), a.endpoint, b.endpoint, good.toString(), Outcome.REJECTED, FailureCode.UNTRUSTED_THEORY);
        text("zero-edits", THEORY, a.endpoint, alternate.endpoint, good.toString(), Outcome.UNCHECKABLE, FailureCode.MISSING_EVIDENCE);
        text("two-edits", THEORY, b.endpoint, c.endpoint, good.toString(), Outcome.UNCHECKABLE, FailureCode.MISSING_EVIDENCE);
        text("different-depth", THEORY, a.endpoint, d.endpoint, good.toString(), Outcome.UNCHECKABLE, FailureCode.MISSING_EVIDENCE);
        text("unsupported-function-body", THEORY, a.endpoint, differentBody.endpoint, good.toString(), Outcome.UNCHECKABLE, FailureCode.MISSING_EVIDENCE);
        check("receipt-cap", UnaryCallSequence.verify(THEORY, a.endpoint, b.endpoint, new byte[65537]),
                Outcome.UNCHECKABLE, FailureCode.RESOURCE_LIMIT);
        Files.write(output, rows, StandardCharsets.UTF_8);
        System.out.println("UnaryCallSequenceTest passed: cases=" + (rows.size() - 1));
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) throw new IllegalArgumentException("usage: UnaryCallSequenceTest OUTPUT.tsv");
        Path output = Path.of(args[0]);
        new UnaryCallSequenceTest(Files.createDirectory(output.toAbsolutePath().resolveSibling("unary-inputs"))).run(output);
    }
}
