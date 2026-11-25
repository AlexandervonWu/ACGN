package is.fivefivefive.CanDis.augmentation;

import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import org.json.JSONObject;

/** Check the packaged command against the original positive and SAT-control modules. */
public final class PooledReplay {
    public static void main(String[] args) throws Exception {
        var path = Path.of(args[1]).toAbsolutePath();
        var deadline = Executors.newSingleThreadScheduledExecutor();
        int n = 0;
        try (var input = Files.newBufferedReader(Path.of(args[0]))) {
            for (String line; (line=input.readLine()) != null; ) {
                var x = new JSONObject(line);
                var pair = x.getJSONArray("pair").toString();
                var timer = deadline.schedule(() -> {
                    System.err.println("Timed out on pair " + pair);
                    Runtime.getRuntime().halt(124);
                }, 60, TimeUnit.SECONDS);
                try {
                    Files.writeString(path, x.getString("source"));
                    var result = ProvenRulesCommand.check(path, "correct");
                    if (!x.getString("native").equals(result.getString("native"))
                            || !new HashSet<>(x.getJSONArray("rules").toList())
                                .equals(new HashSet<>(result.getJSONArray("rules").toList())))
                        throw new AssertionError("Mismatch for " + pair + ": " + result);
                    n++;
                } finally {
                    timer.cancel(false);
                }
            }
        } finally {
            deadline.shutdownNow();
        }
        if (n != 1339) throw new AssertionError("Expected 1,234 positives and 105 native SAT controls, saw " + n);
        System.out.println("PASS: packaged readers reproduced all 1,234 rule matches and 105 SAT controls.");
    }
}
