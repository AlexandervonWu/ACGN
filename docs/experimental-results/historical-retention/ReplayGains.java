import is.fivefivefive.CanDis.augmentation.ProvenRulesCommand;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import org.json.JSONObject;

/** Run each archived Alloy command and bind the outcome to the bytes actually parsed. */
public final class ReplayGains {
    public static void main(String[] args) throws Exception {
        Path model = Path.of(args[1]);
        try (var input = Files.newBufferedReader(Path.of(args[0]));
             var output = Files.newBufferedWriter(Path.of(args[2]), StandardOpenOption.CREATE_NEW)) {
            for (String line; (line = input.readLine()) != null;) {
                var row = new JSONObject(line);
                Files.writeString(model, row.getString("source"));
                var checked = ProvenRulesCommand.check(model, "correct");
                var digest = checked.getJSONObject("parsedSourceHashes").getString(model.toRealPath().toString());
                if (!digest.equals(row.getString("sha256"))) throw new IllegalStateException("Parsed input differs");
                var receipt = new JSONObject().put("ids", row.getJSONArray("ids")).put("sha256", digest);
                for (var key : new String[]{"native", "bitwidth", "traceMin", "traceMax"}) {
                    receipt.put(key, checked.get(key));
                }
                output.write(receipt.toString());
                output.newLine();
                if (!"UNSAT".equals(checked.getString("native"))) {
                    throw new IllegalStateException("Disagreement on reference pair " + row.getJSONArray("ids"));
                }
            }
        }
    }
}
