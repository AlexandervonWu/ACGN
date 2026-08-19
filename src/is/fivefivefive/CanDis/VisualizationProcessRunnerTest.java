package is.fivefivefive.CanDis;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.json.JSONObject;

/** Regression checks for worker completion, hard timeout, and explicit cancellation. */
public final class VisualizationProcessRunnerTest {
    private VisualizationProcessRunnerTest() {
    }

    public static void main(String[] args) throws Exception {
        inspectCompletesInWorker();
        standardExampleIsStableAcrossWorkers();
        timeoutKillsWorker();
        cancellationKillsWorker();
        cancellationBeforeRegistrationPreventsWorkerStart();
        System.out.println("VisualizationProcessRunnerTest passed");
    }

    private static void standardExampleIsStableAcrossWorkers() throws Exception {
        JSONObject request = new JSONObject()
                .put("model", "sig Item {}\npred simple { some Item }")
                .put("callable", new JSONObject().put("name", "simple").put("kind", "predicate"));
        try (VisualizationProcessRunner runner = new VisualizationProcessRunner(1, 30_000L, "256m")) {
            JSONObject first = runner.execute("stable-1", "analyze", request).body();
            JSONObject second = runner.execute("stable-2", "analyze", request).body();
            String firstCanonical = first.getJSONObject("callable").getString("canonicalText");
            String secondCanonical = second.getJSONObject("callable").getString("canonicalText");
            if (!firstCanonical.equals(secondCanonical)
                    || !first.getJSONObject("graph").toString()
                            .equals(second.getJSONObject("graph").toString())) {
                throw new AssertionError("Standard example changed across isolated workers");
            }
            if (!firstCanonical.equals("(some Item)")) {
                throw new AssertionError("Unexpected standard-example presentation: " + firstCanonical);
            }
        }
    }

    private static void inspectCompletesInWorker() throws Exception {
        try (VisualizationProcessRunner runner = new VisualizationProcessRunner(1, 30_000L, "256m")) {
            VisualizationProcessRunner.ExecutionResult result = runner.execute(
                    "inspect-test",
                    "inspect",
                    new JSONObject().put("model", "sig Item {}\npred simple { some Item }"));
            if (result.status() != 200
                    || result.body().getJSONArray("callables").length() != 1
                    || runner.activeJobCount() != 0) {
                throw new AssertionError("Isolated inspection failed: " + result.body());
            }
        }
    }

    private static void timeoutKillsWorker() throws Exception {
        try (VisualizationProcessRunner runner = new VisualizationProcessRunner(1, 500L, "128m")) {
            VisualizationProcessRunner.ExecutionResult result = runner.execute(
                    "timeout-test",
                    "test-sleep",
                    new JSONObject().put("milliseconds", 30_000L));
            if (result.status() != 504 || runner.activeJobCount() != 0) {
                throw new AssertionError("Timed-out worker was not reclaimed: " + result.body());
            }
            assertSuccessfulFollowUp(runner, "after-timeout");
        }
    }

    private static void cancellationKillsWorker() throws Exception {
        try (VisualizationProcessRunner runner = new VisualizationProcessRunner(1, 30_000L, "128m")) {
            ExecutorService executor = Executors.newSingleThreadExecutor();
            try {
                Future<VisualizationProcessRunner.ExecutionResult> pending = executor.submit(() -> runner.execute(
                        "cancel-test",
                        "test-sleep",
                        new JSONObject().put("milliseconds", 30_000L)));
                long deadline = System.nanoTime() + 5_000_000_000L;
                while (runner.activeJobCount() == 0 && System.nanoTime() < deadline) {
                    Thread.sleep(10L);
                }
                if (!runner.cancel("cancel-test")) {
                    throw new AssertionError("Running worker could not be cancelled");
                }
                VisualizationProcessRunner.ExecutionResult result = pending.get();
                if (result.status() != 499 || runner.activeJobCount() != 0) {
                    throw new AssertionError("Cancelled worker was not reclaimed: " + result.body());
                }
                assertSuccessfulFollowUp(runner, "after-running-cancel");
            } finally {
                executor.shutdownNow();
            }
        }
    }

    private static void cancellationBeforeRegistrationPreventsWorkerStart() throws Exception {
        try (VisualizationProcessRunner runner = new VisualizationProcessRunner(1, 30_000L, "128m")) {
            if (!runner.cancel("cancel-before-start")) {
                throw new AssertionError("Cancellation was not recorded");
            }

            VisualizationProcessRunner.ExecutionResult cancelled = runner.execute(
                    "cancel-before-start",
                    "test-sleep",
                    new JSONObject().put("milliseconds", 30_000L));
            if (cancelled.status() != 499 || runner.activeJobCount() != 0) {
                throw new AssertionError("Pre-registration cancellation was lost");
            }

            assertSuccessfulFollowUp(runner, "after-pre-registration-cancel");
        }
    }

    private static void assertSuccessfulFollowUp(
            VisualizationProcessRunner runner,
            String requestId) throws Exception {
        VisualizationProcessRunner.ExecutionResult next = runner.execute(
                requestId,
                "test-sleep",
                new JSONObject().put("milliseconds", 0L));
        if (next.status() != 200 || runner.activeJobCount() != 0) {
            throw new AssertionError("Worker capacity was not reusable: " + next.body());
        }
    }
}
