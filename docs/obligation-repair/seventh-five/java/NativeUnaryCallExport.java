package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.List;
import java.util.Set;
import org.acgn.cert.FailureCode;
import org.acgn.cert.Outcome;
import org.acgn.cert.UnaryCallSequence;
import org.acgn.cert.UnaryCallSequence.Endpoint;
import org.acgn.cert.VerificationResult;
import org.json.JSONArray;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;

/** Export the ordered native trace actually computed for two source-bound TEST_ONLY endpoints. */
public final class NativeUnaryCallExport {
    private NativeUnaryCallExport() {}

    private record Input(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified) {}

    private static Input prepare(Endpoint endpoint) throws Exception {
        byte[] bytes = endpoint.sourceBytes();
        String source = StandardCharsets.UTF_8.newDecoder().decode(ByteBuffer.wrap(bytes)).toString();
        var parsed = CompUtil.parseEverything_fromString(A4Reporter.NOP, source);
        String name = endpoint.root().substring(endpoint.root().lastIndexOf('/') + 1);
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of(name), parsed);
        visitor.visit(new ModelUnit(null, parsed), null);
        var graph = visitor.getForest().get(visitor.getForestId(name));
        return new Input(Canonical.prepare(graph),
                CanonicalAlloyPipeline.prepareCompatibilityForVerification(graph, endpoint.root(), bytes));
    }

    private static final class Refused extends Exception {
        private static final long serialVersionUID = 1L;
        final VerificationResult result;
        Refused(VerificationResult result) {
            super(result.code() + " " + result.detail());
            this.result = result;
        }
    }

    private static void requireVerified(VerificationResult result) throws Refused {
        if (result.outcome() != Outcome.VERIFIED) throw new Refused(result);
    }

    private static void agreement(boolean matches, String field) throws Refused {
        if (!matches) throw new Refused(VerificationResult.rejected(FailureCode.ENDPOINT_CLAIM_MISMATCH,
                "Native trace disagreement: " + field));
    }

    public static JSONObject capture(String theory, Endpoint left, Endpoint right) throws Exception {
        requireVerified(UnaryCallSequence.checkEndpoints(theory, left, right));
        Input a = prepare(left);
        Input b = prepare(right);
        var nativeResult = NativeOperationComparison.compare(a.fast(), b.fast(), a.certified(), b.certified());
        if (nativeResult.status() != NativeOperationComparison.Status.MATCHED) {
            String detail = "Native operation comparison " + nativeResult.status() + ": " + nativeResult.reason();
            throw new Refused(switch (nativeResult.status()) {
                case UNCHECKABLE -> VerificationResult.uncheckable(FailureCode.MISSING_EVIDENCE, detail);
                case ERROR -> VerificationResult.rejected(FailureCode.INTERNAL_ERROR, detail);
                default -> VerificationResult.rejected(FailureCode.ENDPOINT_CLAIM_MISMATCH, detail);
            });
        }
        JSONObject evidence = nativeResult.evidence();
        JSONArray actions = evidence.getJSONArray("fastActions");
        agreement(actions.similar(evidence.getJSONArray("certifiedActions")), "ordered actions");
        JSONObject diagnostic = evidence.getJSONObject("diagnostic");
        JSONObject fast = diagnostic.getJSONObject("fast");
        JSONObject certified = diagnostic.getJSONObject("certified");
        for (String key : List.of("distance", "temporalDistance", "quantifierDistance", "matrixDistance",
                "orderedDiagnosticCost", "replayedMatrixCost")) {
            agreement(fast.get(key) instanceof Integer && fast.get(key).equals(certified.get(key)), key);
        }
        int distance = certified.getInt("distance");
        int cost = 0;
        for (int i = 0; i < actions.length(); i++)
            cost = Math.addExact(cost, actions.getJSONObject(i).getInt("cost"));
        agreement(cost == distance && cost == certified.getInt("orderedDiagnosticCost"), "total cost");
        JSONObject receipt = UnaryCallSequence.envelope(left, right, actions, distance);
        requireVerified(UnaryCallSequence.verify(theory, left, right,
                receipt.toString().getBytes(StandardCharsets.UTF_8)));
        return receipt;
    }

    public static void main(String[] args) {
        if (args.length != 8) {
            System.err.println("Usage: THEORY LEFT.als LEFT_ROOT LEFT.cert RIGHT.als RIGHT_ROOT RIGHT.cert NEW.json");
            System.exit(64);
        }
        VerificationResult result;
        try {
            Endpoint left = Endpoint.read(Path.of(args[1]), args[2], Path.of(args[3]));
            Endpoint right = Endpoint.read(Path.of(args[4]), args[5], Path.of(args[6]));
            JSONObject receipt = capture(args[0], left, right);
            Files.writeString(Path.of(args[7]), receipt + "\n", StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE_NEW, StandardOpenOption.WRITE);
            result = VerificationResult.verified("Wrote independently checked native action receipt");
        } catch (Refused e) {
            result = e.result;
        } catch (IOException e) {
            result = VerificationResult.uncheckable(FailureCode.IO_ERROR, e.toString());
        } catch (Exception e) {
            result = VerificationResult.rejected(FailureCode.INTERNAL_ERROR, e.toString());
        }
        System.out.println(new JSONObject().put("outcome", result.outcome().name())
                .put("code", result.code().name()).put("detail", result.detail()));
        System.exit(switch (result.outcome()) {
            case VERIFIED -> 0;
            case REJECTED -> 2;
            case UNCHECKABLE -> 3;
        });
    }
}
