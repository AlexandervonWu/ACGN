package is.fivefivefive.CanDis.ablation;

import is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter;
import is.fivefivefive.CanDis.core.egraph.AlloyTerm;
import is.fivefivefive.CanDis.core.egraph.SlottedEGraph;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Evaluate original Slotted on each pair from the archived correct-reference inventory. */
public final class SlottedReferencePoolReplay {
    private record Reference(int id, AlloyTerm term) {}

    public static void main(String[] args) throws Exception {
        Path corpus = Path.of(args[0]);
        Map<List<String>, List<Reference>> groups = new LinkedHashMap<>();
        MessageDigest sha = MessageDigest.getInstance("SHA-256");
        try (var in = new BufferedReader(new InputStreamReader(
                new GZIPInputStream(Files.newInputStream(Path.of(args[1]))), StandardCharsets.UTF_8))) {
            for (String line; (line = in.readLine()) != null;) {
                JSONObject row = new JSONObject(line);
                Path file = corpus.resolve(row.getString("source"));
                if (!row.getString("sha").equals(HexFormat.of().formatHex(sha.digest(Files.readAllBytes(file))))) {
                    throw new IllegalStateException("Reference source changed: " + file);
                }
                var module = new ModelUnit(null, AlloyUtil.compileAlloyModule(file.toString()));
                var predicates = module.getPredDeclList().stream()
                        .filter(p -> p.getName().equals(row.getString("operator"))).toList();
                if (predicates.size() != 1) throw new IllegalStateException("Ambiguous reference: " + file);
                var ref = new Reference(row.getInt("id"), AlloyAstTermAdapter.fromPredicate(predicates.get(0)));
                var group = row.getJSONArray("group");
                groups.computeIfAbsent(List.of(group.getString(0), group.getString(1)), k -> new ArrayList<>()).add(ref);
            }
        }
        try (var out = new BufferedWriter(new OutputStreamWriter(
                new GZIPOutputStream(Files.newOutputStream(Path.of(args[2]))), StandardCharsets.UTF_8))) {
            out.write("left,right,distance\n");
            for (var group : groups.values()) {
                for (int i = 0; i < group.size(); i++) {
                    var a = group.get(i);
                    for (int j = i + 1; j < group.size(); j++) {
                        var b = group.get(j);
                        var result = new SlottedEGraph().compare(a.term(), b.term());
                        if (result.distance < 0 || (result.distance == 0) != result.equivalent) {
                            throw new IllegalStateException("Inconsistent Slotted result for " + a.id() + " and " + b.id());
                        }
                        out.write(a.id() + "," + b.id() + "," + result.distance + "\n");
                    }
                }
            }
        }
        System.out.println(SlottedEGraph.VERSION);
    }
}
