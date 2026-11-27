package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Replay measured cross-file ranking witnesses with the frozen experiment JAR. */
public final class HistoricalRankTraceReplay {
    private record Endpoint(String source, String predicate, String sha, boolean reference) {}
    private record Prepared(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified) {}

    private static Prepared prepare(Path dataset, Endpoint endpoint, Map<Endpoint, Prepared> cache) throws Exception {
        Prepared cached = cache.get(endpoint);
        if (cached != null) return cached;
        Path file = dataset.resolve(endpoint.source()).normalize();
        if (!file.startsWith(dataset) || !HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                .digest(Files.readAllBytes(file))).equals(endpoint.sha())) {
            throw new IllegalArgumentException("Original source differs: " + endpoint.source());
        }
        var module = endpoint.reference()
                ? CompUtil.parseEverything_fromFile(A4Reporter.NOP, new HashMap<>(), file.toRealPath().toString())
                : AlloyUtil.compileAlloyModule(file.toString());
        var visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null, module), null);
        Integer forestId = visitor.getForestId(endpoint.predicate());
        if (forestId == null || visitor.getForest().get(forestId) == null) {
            throw new IllegalArgumentException("Missing original predicate: " + endpoint);
        }
        var fast = Canonical.prepare(visitor.getForest().get(forestId));
        var result = new Prepared(fast, CanonicalAlloyPipeline.prepare(fast));
        cache.put(endpoint, result);
        return result;
    }

    /** Preserve the native order while projecting temporal blocks to their checked effects. */
    private static JSONArray program(JSONObject evidence, String arm, boolean temporal) {
        if (!temporal) return evidence.optJSONArray(arm + "Actions");
        JSONArray blocks = evidence.optJSONArray(arm + "Blocks");
        if (blocks == null) return null;
        var result = new JSONArray();
        for (int i = 0; i < blocks.length(); i++) {
            JSONObject block = blocks.getJSONObject(i);
            result.put(new JSONArray().put(block.getString("component")).put(block.get("effect")));
        }
        return result;
    }

    private static JSONObject replay(Prepared a, Prepared b, int expected) {
        var fast = CanonicalRepairTraces.fast(a.fast(), b.fast());
        var certified = CanonicalRepairTraces.certified(a.certified(), b.certified());
        int fastCost = fast.replay(fast.json());
        int certifiedCost = certified.replay(certified.json());
        var comparison = NativeOperationComparison.compare(a.fast(), b.fast(), fast, certified);
        var evidence = comparison.evidence();
        boolean sources = evidence.optBoolean("sourceCertificatesChecked");
        boolean choices = evidence.optBoolean("fixedChoiceReplaysChecked");
        boolean endpoints = evidence.optBoolean("endpointCorrespondenceChecked");
        boolean temporal = evidence.has("fastBlocks") || evidence.has("certifiedBlocks");
        JSONArray fastProgram = program(evidence, "fast", temporal);
        JSONArray certifiedProgram = program(evidence, "certified", temporal);
        boolean equal = fastProgram != null && certifiedProgram != null && fastProgram.similar(certifiedProgram);
        boolean valid = comparison.status() == NativeOperationComparison.Status.MATCHED
                && comparison.reason().equals("CHECKED_NATIVE_ACTIONS_EQUAL") && equal
                && (!temporal || evidence.optBoolean("orderedBlockEffectsEqual"))
                && !evidence.has("firstDifference") && sources && choices && endpoints && fastCost == expected && certifiedCost == expected;
        var row = new JSONObject().put("passed", valid).put("status", comparison.status().name())
                .put("reason", comparison.reason()).put("fastDistance", fastCost).put("certifiedDistance", certifiedCost)
                .put("sourceCertificatesChecked", sources).put("fixedChoiceReplaysChecked", choices)
                .put("endpointCorrespondenceChecked", endpoints).put("nativeSequencesEqual", equal)
                .put("sequenceKind", temporal ? "TEMPORAL_BLOCK_EFFECTS" : "FLAT_ACTIONS");
        String suffix = temporal ? "BlockCount" : "ActionCount";
        if (fastProgram != null) row.put("fast" + suffix, fastProgram.length());
        if (certifiedProgram != null) row.put("certified" + suffix, certifiedProgram.length());
        if (temporal) row.put("orderedBlockEffectsEqual", evidence.optBoolean("orderedBlockEffectsEqual"));
        for (String key : List.of("firstDifference", "fastFirst", "certifiedFirst")) {
            if (evidence.has(key)) row.put(key, evidence.get(key));
        }
        return row;
    }

    public static void main(String[] args) throws Exception {
        Path dataset = Path.of(args[0]).toRealPath();
        var cache = new LinkedHashMap<Endpoint, Prepared>(4, 0.75f, true) {
            @Override protected boolean removeEldestEntry(Map.Entry<Endpoint, Prepared> entry) {
                return size() > 4;
            }
        };
        try (var input = Files.newBufferedReader(Path.of(args[1]));
                var output = Files.newBufferedWriter(Path.of(args[2]), StandardOpenOption.CREATE_NEW)) {
            for (String line; (line = input.readLine()) != null;) {
                var job = new JSONObject(line);
                var student = prepare(dataset, new Endpoint(job.getString("submission"), job.getString("predicate"),
                        job.getString("sourceSha256"), false), cache);
                var reference = prepare(dataset, new Endpoint(job.getString("reference"), job.getString("referencePredicate"),
                        job.getString("referenceSha256"), true), cache);
                for (boolean reverse : List.of(false, true)) {
                    var row = replay(reverse ? reference : student, reverse ? student : reference, job.getInt("expected"));
                    row.put("submission", job.getString("submission")).put("predicate", job.getString("predicate"))
                            .put("reference", job.getString("reference")).put("referencePredicate", job.getString("referencePredicate"))
                            .put("direction", reverse ? "reverse" : "forward").put("expected", job.getInt("expected"));
                    output.write(row.toString());
                    output.newLine();
                }
                output.flush();
            }
        }
    }
}
