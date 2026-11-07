package is.fivefivefive.CanDis;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.HexFormat;
import java.util.concurrent.CancellationException;

import org.json.JSONObject;

/** First-incident latch: mismatches are fatal, never ordinary retryable file errors. */
final class BatchParityGate {
    private final Path incidentPath;
    private volatile Violation first;

    BatchParityGate(Path output) {
        incidentPath = output.resolve("parity-incident.json");
        if (Files.exists(incidentPath)) {
            throw new IllegalStateException("Refusing to overwrite an unresolved parity incident: " + incidentPath);
        }
    }

    void checkRunning() {
        Violation failure = first;
        if (failure != null) throw failure;
        if (Thread.currentThread().isInterrupted()) throw new CancellationException("Batch cancelled");
    }

    void requireParity(Path source, String left, String right, int[] fast, int[] certified) {
        checkRunning();
        if (fast.length != 4 || certified.length != 4) {
            throw new IllegalArgumentException("Expected total, temporal, quantifier, matrix distances");
        }
        if (!java.util.Arrays.equals(fast, certified)) {
            stop(source, left, right, fast, certified, "DISTANCE_MISMATCH");
        }
        // Legacy diagnostic strings are not DP backtraces and cannot grant replay authority.
        // Remove this blocker only when both engines emit independently replay-checked plans.
        stop(source, left, right, fast, certified, "REPLAY_WITNESS_UNAVAILABLE");
    }

    private synchronized void stop(Path source, String left, String right,
            int[] fast, int[] certified, String reason) {
        if (first != null) throw first;
        JSONObject incident = new JSONObject()
                .put("schema", "acgn-parity-incident-v1")
                .put("status", "STOPPED")
                .put("reason", reason)
                .put("observedAt", Instant.now().toString())
                .put("source", source.toAbsolutePath().normalize().toString())
                .put("leftPredicate", left).put("rightPredicate", right)
                .put("distanceOrder", new String[]{"total", "temporal", "quantifier", "matrix"})
                .put("fast", fast).put("certified", certified)
                .put("fastReplayPlan", JSONObject.NULL)
                .put("certifiedReplayPlan", JSONObject.NULL)
                .put("replayStatus", "UNAVAILABLE")
                .put("nextAction", "Inspect this source pair; do not retry or restart unchanged.");
        Violation failure = new Violation(reason + ": " + source + " (" + left + ", " + right + ")");
        try {
            byte[] contents = Files.readAllBytes(source);
            incident.put("sourceSha256", HexFormat.of().formatHex(
                    MessageDigest.getInstance("SHA-256").digest(contents)));
            // Retain the exact source, including declarations needed to replay this pair.
            incident.put("sourceText", new String(contents, StandardCharsets.UTF_8));
            Files.writeString(incidentPath, incident.toString(2) + "\n", StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE_NEW, StandardOpenOption.WRITE);
        } catch (IOException | NoSuchAlgorithmException error) {
            failure.addSuppressed(error);
        } finally {
            // Also stop on failed evidence persistence; never continue silently.
            first = failure;
        }
        throw failure;
    }

    static final class Violation extends RuntimeException {
        private static final long serialVersionUID = 1L;

        private Violation(String message) {
            super(message);
        }
    }
}
