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
import java.util.function.Supplier;

import org.json.JSONObject;

/** First-incident latch: mismatches are fatal, never ordinary retryable file errors. */
final class BatchParityGate {
    enum Mode { STRICT_CERTIFIED, DIAGNOSTIC_COMPONENTS }
    private final Path incidentPath;
    private final Mode mode;
    private volatile Violation first;

    BatchParityGate(Path output) {
        this(output, Mode.STRICT_CERTIFIED);
    }

    BatchParityGate(Path output, Mode mode) {
        this.mode = java.util.Objects.requireNonNull(mode);
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
        requireParity(source, left, right, fast, certified, null);
    }

    void requireParity(Path source, String left, String right, int[] fast, int[] certified,
            Supplier<JSONObject> nativeReplay) {
        checkRunning();
        if (fast.length != 4 || certified.length != 4) {
            throw new IllegalArgumentException("Expected total, temporal, quantifier, matrix distances");
        }
        if (!java.util.Arrays.equals(fast, certified)) {
            stop(source, left, right, fast, certified, "DISTANCE_MISMATCH", nativeReplay);
        }
        // Legacy diagnostic strings are not DP backtraces and cannot grant replay authority.
        // Remove this blocker only when both engines emit independently replay-checked plans.
        if (mode == Mode.STRICT_CERTIFIED)
            stop(source, left, right, fast, certified, "REPLAY_WITNESS_UNAVAILABLE", nativeReplay);
    }

    void requireSoundObservation(Path source, String left, String right, int[] fast, int[] certified,
            boolean nonCorrect, boolean exactSearch, Supplier<JSONObject> nativeReplay) {
        checkRunning();
        if (nonCorrect && (fast[0] == 0 || certified[0] == 0))
            stop(source, left, right, fast, certified, "INCORRECT_ZERO", nativeReplay);
        if (!exactSearch)
            stop(source, left, right, fast, certified, "INEXACT_SEARCH", nativeReplay);
    }

    private synchronized void stop(Path source, String left, String right,
            int[] fast, int[] certified, String reason, Supplier<JSONObject> nativeReplay) {
        if (first != null) throw first;
        Violation failure = new Violation(reason + ": " + source + " (" + left + ", " + right + ")");
        // Publish the latch before IO or replay work so other workers stop immediately.
        first = failure;
        JSONObject incident = new JSONObject()
                .put("schema", "acgn-parity-incident-v1")
                .put("status", "STOPPED")
                .put("scanMode", mode.name()).put("publicationAllowed", false)
                .put("certificationStatus", "BLOCKED")
                .put("reason", reason)
                .put("observedAt", Instant.now().toString())
                .put("source", source.toAbsolutePath().normalize().toString())
                .put("leftPredicate", left).put("rightPredicate", right)
                .put("distanceOrder", new String[]{"total", "temporal", "quantifier", "matrix"})
                .put("fast", fast).put("certified", certified)
                .put("fastReplayPlan", JSONObject.NULL)
                .put("certifiedReplayPlan", JSONObject.NULL)
                .put("replayStatus", "UNAVAILABLE")
                .put("nativeReplayFile", nativeReplay == null ? JSONObject.NULL : "parity-native-replay.json")
                .put("nextAction", "Inspect this source pair; do not retry or restart unchanged.");
        try {
            byte[] contents = Files.readAllBytes(source);
            incident.put("sourceSha256", HexFormat.of().formatHex(
                    MessageDigest.getInstance("SHA-256").digest(contents)));
            // Retain the exact source, including declarations needed to replay this pair.
            incident.put("sourceText", new String(contents, StandardCharsets.UTF_8));
            Files.writeString(incidentPath, incident.toString(2) + "\n", StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE_NEW, StandardOpenOption.WRITE);
            // The small immutable incident survives even if bounded diagnostic capture fails.
            if (nativeReplay != null) retainNativeReplay(source, contents, incident, nativeReplay);
        } catch (IOException | NoSuchAlgorithmException error) {
            failure.addSuppressed(error);
        }
        throw failure;
    }

    private void retainNativeReplay(Path source, byte[] original, JSONObject incident,
            Supplier<JSONObject> capture) throws IOException {
        JSONObject evidence = new JSONObject().put("schema", "acgn-incident-native-replay-v1")
                .put("status", "BLOCKED").put("complete", false).put("parityAuthority", false)
                .put("source", incident.getString("source"))
                .put("sourceSha256", incident.getString("sourceSha256"))
                .put("leftPredicate", incident.getString("leftPredicate"))
                .put("rightPredicate", incident.getString("rightPredicate"))
                .put("incidentReason", incident.getString("reason"));
        try {
            JSONObject report = capture.get();
            if (!java.util.Arrays.equals(original, Files.readAllBytes(source)))
                throw new IllegalStateException("Source changed during native replay capture");
            if (report == null) throw new IllegalStateException("Native replay capture returned null");
            evidence.put("captureStatus", "CAPTURED").put("diagnostic", report);
        } catch (RuntimeException error) {
            evidence.put("captureStatus", "FAILED").put("errorType", error.getClass().getName())
                    .put("error", String.valueOf(error.getMessage()));
        }
        Files.writeString(incidentPath.resolveSibling("parity-native-replay.json"), evidence.toString(2) + "\n",
                StandardCharsets.UTF_8, StandardOpenOption.CREATE_NEW, StandardOpenOption.WRITE);
    }

    static final class Violation extends RuntimeException {
        private static final long serialVersionUID = 1L;

        private Violation(String message) {
            super(message);
        }
    }
}
