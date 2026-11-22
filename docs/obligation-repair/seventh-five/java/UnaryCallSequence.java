package org.acgn.cert;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.Expr;
import edu.mit.csail.sdg.ast.ExprCall;
import edu.mit.csail.sdg.ast.ExprUnary;
import edu.mit.csail.sdg.ast.Func;
import edu.mit.csail.sdg.ast.Sig;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONParserConfiguration;

/** Source and wire replay of an exported, ordered, single unary CALL substitution. */
public final class UnaryCallSequence {
    static final String SCHEMA = "acgn-source-unary-call-edit-v1";
    private static final int SOURCE_LIMIT = 65_536;
    private static final int CERTIFICATE_LIMIT = 4 * 1024 * 1024;
    private static final int RECEIPT_LIMIT = 65_536;
    private static final JSONParserConfiguration JSON = new JSONParserConfiguration()
            .withStrictMode().withMaxNestingDepth(12).withOverwriteDuplicateKey(false);

    private UnaryCallSequence() {}

    /** Immutable input bytes. Both independent checks observe the same snapshot. */
    public static final class Endpoint {
        private final byte[] source;
        private final String root;
        private final byte[] certificate;

        private Endpoint(byte[] source, String root, byte[] certificate) {
            this.source = source;
            this.root = root;
            this.certificate = certificate;
        }

        public static Endpoint read(Path source, String root, Path certificate) throws IOException {
            return new Endpoint(readBounded(source, SOURCE_LIMIT), root,
                    readBounded(certificate, CERTIFICATE_LIMIT));
        }

        public byte[] sourceBytes() { return source.clone(); }
        public String root() { return root; }

        private JSONObject identity() {
            return new JSONObject().put("sourceSha256", hash(source)).put("declaration", root)
                    .put("certificateSha256", hash(certificate));
        }

        private VerificationResult full(String theory) {
            return P613SourcePair.verifyFull(theory, source, root, certificate);
        }
    }

    static byte[] readBounded(Path file, int limit) throws IOException {
        try (var in = Files.newInputStream(file)) {
            byte[] bytes = in.readNBytes(limit + 1);
            if (bytes.length > limit) throw new IOException("Input exceeds byte limit " + limit);
            return bytes;
        }
    }

    private static String hash(byte[] bytes) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException(ex);
        }
    }

    private record Chain(String module, String signature, Set<String> functions, List<String> calls) {}
    private static final class OutsideFragment extends Exception {
        private static final long serialVersionUID = 1L;
        OutsideFragment(String reason) { super(reason); }
    }

    private static void supported(boolean condition, String reason) throws OutsideFragment {
        if (!condition) throw new OutsideFragment(reason);
    }

    private static Chain parse(Endpoint endpoint) throws Exception {
        String text = StandardCharsets.UTF_8.newDecoder().decode(ByteBuffer.wrap(endpoint.source)).toString();
        CompModule module = CompUtil.parseEverything_fromString(A4Reporter.NOP, text);
        var sigs = module.getAllSigs().makeCopy();
        supported(sigs.size() == 1 && sigs.get(0) instanceof Sig.PrimSig, "one local signature required");
        Sig.PrimSig sig = (Sig.PrimSig) sigs.get(0);
        supported(sig.parent == Sig.UNIV && sig.isAbstract == null && sig.isEnum == null
                && sig.isVariable == null && sig.isOne == null && sig.isLone == null
                && sig.isSome == null && sig.isPrivate == null && sig.getFields().isEmpty()
                && sig.getFacts().isEmpty() && module.getAllFacts().isEmpty(), "plain static signature required");
        Func selected = null;
        Map<String, Func> declarations = new TreeMap<>();
        for (Func f : module.getAllFunc()) {
            if (f.isPred) {
                if ((module.getModuleName() + "/" + f.label.substring(f.label.lastIndexOf('/') + 1))
                        .equals(endpoint.root)) {
                    supported(selected == null && f.count() == 0, "unique nullary predicate required");
                    selected = f;
                }
                continue;
            }
            supported(f.label.matches("this/[A-Za-z_][A-Za-z0-9_]*") && f.isPrivate == null
                    && declarations.putIfAbsent(f.label, f) == null, "distinct public local functions required");
            supported(f.count() == 1 && f.decls.size() == 1 && f.decls.get(0).expr.deNOP() == sig
                    && f.getBody().deNOP() == f.get(0)
                    && f.returnDecl.deNOP() instanceof ExprUnary result
                    && result.op == ExprUnary.Op.ONEOF && result.sub.deNOP() == sig,
                    "expected unary functions with one signature and identity bodies");
        }
        supported(selected != null && selected.getBody().deNOP() instanceof ExprUnary,
                "selected SOME predicate required");
        ExprUnary some = (ExprUnary) selected.getBody().deNOP();
        supported(some.op == ExprUnary.Op.SOME, "selected SOME predicate required");
        List<String> calls = new ArrayList<>();
        Expr term = some.sub.deNOP();
        while (term instanceof ExprCall call) {
            supported(calls.size() < 16 && declarations.get(call.fun.label) == call.fun
                    && call.args.size() == 1, "unsupported CALL occurrence");
            calls.add(call.fun.label);
            term = call.args.get(0).deNOP();
        }
        supported(term == sig && !calls.isEmpty(), "the final operand must be the declared signature");
        return new Chain(module.getModuleName(), sig.label, Set.copyOf(declarations.keySet()), List.copyOf(calls));
    }

    private static JSONObject matrix(String address, int cost) {
        return new JSONObject().put("stage", "matrix").put("kind", "node")
                .put("source", address).put("target", address).put("cost", cost);
    }

    private static JSONArray expected(Chain left, Chain right) throws OutsideFragment {
        supported(left.module.equals(right.module) && left.signature.equals(right.signature)
                && left.functions.equals(right.functions), "different declared vocabularies");
        supported(left.calls.size() == right.calls.size(), "different unary depths");
        JSONArray rows = new JSONArray();
        rows.put(new JSONObject().put("stage", "declarationPermutation").put("source", new JSONArray())
                .put("target", new JSONArray()).put("cost", 0));
        rows.put(matrix("$", 0));
        String address = "$/0";
        rows.put(matrix(address, 0));
        int distance = 0;
        for (int i = 0; i < left.calls.size(); i++) {
            address += "/0";
            int cost = left.calls.get(i).equals(right.calls.get(i)) ? 0 : 1;
            distance += cost;
            rows.put(matrix(address, cost));
        }
        rows.put(matrix(address + "/0", 0));
        supported(distance == 1, "one changed callee required");
        return rows;
    }

    /** Wrap the submitted native action array. Verification recomputes the whole sequence. */
    public static JSONObject envelope(Endpoint left, Endpoint right, JSONArray actions, int distance) {
        return new JSONObject().put("schema", SCHEMA).put("source", left.identity())
                .put("target", right.identity()).put("distance", distance).put("actions", actions);
    }

    private record Admission(VerificationResult result, JSONArray rows) {}

    private static Admission admit(String theory, Endpoint left, Endpoint right) {
        for (Endpoint e : List.of(left, right)) {
            VerificationResult side = e.full(theory);
            if (side.outcome() != Outcome.VERIFIED) return new Admission(side, null);
        }
        try {
            JSONArray rows = expected(parse(left), parse(right));
            return new Admission(VerificationResult.verified("Both input certificates and source fragments checked"), rows);
        } catch (OutsideFragment e) {
            return new Admission(VerificationResult.uncheckable(FailureCode.MISSING_EVIDENCE, e.getMessage()), null);
        } catch (Exception e) {
            return new Admission(VerificationResult.uncheckable(FailureCode.MISSING_EVIDENCE, "Source parse failed"), null);
        }
    }

    public static VerificationResult checkEndpoints(String theory, Endpoint left, Endpoint right) {
        return admit(theory, left, right).result();
    }

    public static VerificationResult verify(String theory, Endpoint left, Endpoint right, byte[] receipt) {
        if (receipt.length > RECEIPT_LIMIT) {
            return VerificationResult.uncheckable(FailureCode.RESOURCE_LIMIT, "Sequence byte limit");
        }
        byte[] snapshot = receipt.clone();
        Admission admission = admit(theory, left, right);
        if (admission.result().outcome() != Outcome.VERIFIED) return admission.result();
        JSONArray required = admission.rows();
        try {
            String text = StandardCharsets.UTF_8.newDecoder().decode(ByteBuffer.wrap(snapshot)).toString();
            JSONObject supplied = new JSONObject(text, JSON);
            JSONArray actions = supplied.getJSONArray("actions");
            boolean integral = supplied.opt("distance") instanceof Integer;
            for (Object action : actions) {
                integral &= action instanceof JSONObject row && row.opt("cost") instanceof Integer;
            }
            if (!integral || !envelope(left, right, required, 1).similar(supplied)) {
                return VerificationResult.rejected(FailureCode.ENDPOINT_CLAIM_MISMATCH,
                        "Ordered actions, cost or endpoints disagree with the two sources");
            }
            return VerificationResult.verified("One typed unary CALL substitution with two source-bound FULL endpoints");
        } catch (JSONException | java.nio.charset.CharacterCodingException e) {
            return VerificationResult.rejected(FailureCode.INVALID_RECORD_SHAPE, "Malformed sequence receipt");
        }
    }

    public static void main(String[] args) throws IOException {
        if (args.length != 8) {
            System.err.println("Usage: THEORY LEFT.als LEFT_ROOT LEFT.cert RIGHT.als RIGHT_ROOT RIGHT.cert SEQUENCE.json");
            System.exit(64);
        }
        Endpoint left = Endpoint.read(Path.of(args[1]), args[2], Path.of(args[3]));
        Endpoint right = Endpoint.read(Path.of(args[4]), args[5], Path.of(args[6]));
        VerificationResult result = verify(args[0], left, right, readBounded(Path.of(args[7]), RECEIPT_LIMIT));
        System.out.println(new JSONObject().put("outcome", result.outcome().name())
                .put("code", result.code().name()).put("detail", result.detail()));
        System.exit(switch (result.outcome()) { case VERIFIED -> 0; case REJECTED -> 2; case UNCHECKABLE -> 3; });
    }
}
