package is.fivefivefive.CanDis;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import org.json.JSONObject;

/** Runs potentially non-terminating Alloy analyses behind a killable JVM boundary. */
final class VisualizationProcessRunner implements AutoCloseable {
    private static final String WORKER_CLASS = "is.fivefivefive.CanDis.VisualizationWorker";
    private static final long TERMINATION_GRACE_MILLIS = 2_000L;
    private static final long PENDING_CANCEL_TTL_MILLIS = 30_000L;
    private static final int MAX_PENDING_CANCELLATIONS = 4_096;

    private final long timeoutMillis;
    private final String workerHeap;
    private final Semaphore capacity;
    private final ConcurrentMap<String, RunningJob> jobs = new ConcurrentHashMap<>();
    private final Object registrationLock = new Object();
    private final Map<String, Long> pendingCancellations = Collections.synchronizedMap(
            new LinkedHashMap<String, Long>(128, 0.75f, true) {
                private static final long serialVersionUID = 1L;

                @Override
                protected boolean removeEldestEntry(Map.Entry<String, Long> eldest) {
                    return size() > MAX_PENDING_CANCELLATIONS;
                }
            });
    private final AtomicBoolean closed = new AtomicBoolean();

    VisualizationProcessRunner(int workers, long timeoutMillis, String workerHeap) {
        if (workers <= 0) {
            throw new IllegalArgumentException("workers must be positive");
        }
        if (timeoutMillis <= 0) {
            throw new IllegalArgumentException("timeoutMillis must be positive");
        }
        this.timeoutMillis = timeoutMillis;
        this.workerHeap = Objects.requireNonNull(workerHeap, "workerHeap");
        this.capacity = new Semaphore(workers, true);
    }

    ExecutionResult execute(String requestId, String operation, JSONObject request) throws IOException {
        Objects.requireNonNull(requestId, "requestId");
        Objects.requireNonNull(operation, "operation");
        Objects.requireNonNull(request, "request");
        if (closed.get()) {
            return error(503, "service_stopping", "The visualization service is stopping.");
        }
        if (!capacity.tryAcquire()) {
            return error(503, "analysis_capacity", "All analysis workers are currently busy.");
        }

        RunningJob job = new RunningJob();
        boolean duplicate;
        boolean cancelledBeforeRegistration;
        synchronized (registrationLock) {
            duplicate = jobs.putIfAbsent(requestId, job) != null;
            cancelledBeforeRegistration = !duplicate && consumePendingCancellation(requestId);
        }
        if (duplicate) {
            capacity.release();
            return error(409, "duplicate_request", "The request ID is already running.");
        }

        Path directory = null;
        Process process = null;
        try {
            if (cancelledBeforeRegistration) {
                job.cancel();
                return terminalResult(job.cause());
            }
            directory = Files.createTempDirectory("acgn-visualization-job-");
            Path input = directory.resolve("request.json");
            Path output = directory.resolve("response.json");
            JSONObject command = new JSONObject()
                    .put("operation", operation)
                    .put("request", request);
            Files.writeString(input, command.toString(), StandardCharsets.UTF_8);

            ProcessBuilder builder = new ProcessBuilder(command(input, output));
            builder.redirectOutput(ProcessBuilder.Redirect.DISCARD);
            builder.redirectError(ProcessBuilder.Redirect.INHERIT);
            process = builder.start();
            job.attach(process);
            if (job.cause() != TerminalCause.RUNNING) {
                terminate(process);
                return terminalResult(job.cause());
            }

            boolean completed;
            try {
                completed = process.waitFor(timeoutMillis, TimeUnit.MILLISECONDS);
            } catch (InterruptedException exception) {
                Thread.currentThread().interrupt();
                TerminalCause cause = job.cancel();
                terminate(process);
                return terminalResult(cause);
            }
            if (!completed) {
                TerminalCause cause = job.timeout();
                terminate(process);
                return terminalResult(cause);
            }
            TerminalCause cause = job.complete();
            if (cause != TerminalCause.COMPLETED) {
                return terminalResult(cause);
            }
            if (!Files.isRegularFile(output)) {
                return error(500, "worker_failure",
                        "The isolated analysis worker exited without a response.");
            }
            JSONObject envelope = new JSONObject(Files.readString(output, StandardCharsets.UTF_8));
            int status = envelope.optInt("status", 500);
            JSONObject body = envelope.optJSONObject("body");
            if (body == null) {
                return error(500, "worker_failure", "The isolated analysis response was malformed.");
            }
            return new ExecutionResult(status, body);
        } finally {
            if (process != null && process.isAlive()) {
                terminate(process);
            }
            jobs.remove(requestId, job);
            capacity.release();
            deleteJobDirectory(directory);
        }
    }

    boolean cancel(String requestId) {
        RunningJob job;
        synchronized (registrationLock) {
            job = jobs.get(requestId);
            if (job == null) {
                synchronized (pendingCancellations) {
                    pendingCancellations.put(
                            requestId,
                            System.currentTimeMillis() + PENDING_CANCEL_TTL_MILLIS);
                }
                return true;
            }
        }
        job.cancel();
        return true;
    }

    private boolean consumePendingCancellation(String requestId) {
        synchronized (pendingCancellations) {
            Long deadline = pendingCancellations.remove(requestId);
            return deadline != null && deadline >= System.currentTimeMillis();
        }
    }

    int activeJobCount() {
        return jobs.size();
    }

    @Override
    public void close() {
        if (!closed.compareAndSet(false, true)) {
            return;
        }
        for (RunningJob job : jobs.values()) {
            job.cancel();
        }
        pendingCancellations.clear();
    }

    private List<String> command(Path input, Path output) {
        List<String> command = new ArrayList<>();
        command.add(javaExecutable());
        command.add("-Dfile.encoding=UTF-8");
        command.add("-Xmx" + workerHeap);
        command.add("-cp");
        command.add(System.getProperty("java.class.path"));
        command.add(WORKER_CLASS);
        command.add(input.toString());
        command.add(output.toString());
        return command;
    }

    private static String javaExecutable() {
        String executable = System.getProperty("os.name", "")
                .toLowerCase(java.util.Locale.ROOT).contains("win") ? "java.exe" : "java";
        return Path.of(System.getProperty("java.home"), "bin", executable).toString();
    }

    private static void terminate(Process process) {
        if (!process.isAlive()) {
            return;
        }
        process.destroy();
        try {
            if (!process.waitFor(TERMINATION_GRACE_MILLIS, TimeUnit.MILLISECONDS)) {
                process.destroyForcibly();
                process.waitFor(TERMINATION_GRACE_MILLIS, TimeUnit.MILLISECONDS);
            }
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            process.destroyForcibly();
        }
    }

    private static void deleteJobDirectory(Path directory) {
        if (directory == null) {
            return;
        }
        try {
            Files.deleteIfExists(directory.resolve("request.json"));
            Files.deleteIfExists(directory.resolve("response.json"));
            Files.deleteIfExists(directory);
        } catch (IOException ignored) {
            // The operating system will eventually reclaim an exceptional worker's tiny files.
        }
    }

    private static ExecutionResult error(int status, String code, String message) {
        return new ExecutionResult(status, new JSONObject().put("code", code).put("message", message));
    }

    static ExecutionResult terminalResult(TerminalCause cause) {
        if (cause == TerminalCause.CANCELLED) {
            return error(499, "request_cancelled", "The analysis request was cancelled.");
        }
        if (cause == TerminalCause.TIMED_OUT) {
            return error(504, "analysis_timeout",
                    "The analysis exceeded the server timeout and was terminated.");
        }
        throw new IllegalArgumentException("Not a terminal failure cause: " + cause);
    }

    static final class ExecutionResult {
        private final int status;
        private final JSONObject body;

        private ExecutionResult(int status, JSONObject body) {
            this.status = status;
            this.body = body;
        }

        int status() {
            return status;
        }

        JSONObject body() {
            return body;
        }
    }

    enum TerminalCause {
        RUNNING,
        COMPLETED,
        CANCELLED,
        TIMED_OUT
    }

    static final class TerminalCauseLatch {
        private final AtomicReference<TerminalCause> cause =
                new AtomicReference<>(TerminalCause.RUNNING);

        TerminalCause complete() {
            return settle(TerminalCause.COMPLETED);
        }

        TerminalCause cancel() {
            return settle(TerminalCause.CANCELLED);
        }

        TerminalCause timeout() {
            return settle(TerminalCause.TIMED_OUT);
        }

        TerminalCause cause() {
            return cause.get();
        }

        private TerminalCause settle(TerminalCause next) {
            cause.compareAndSet(TerminalCause.RUNNING, next);
            return cause.get();
        }
    }

    private static final class RunningJob {
        private final TerminalCauseLatch terminal = new TerminalCauseLatch();
        private volatile Process process;

        private void attach(Process value) {
            process = value;
            if (terminal.cause() != TerminalCause.RUNNING) {
                terminate(value);
            }
        }

        private TerminalCause cancel() {
            TerminalCause cause = terminal.cancel();
            Process value = process;
            if (cause == TerminalCause.CANCELLED && value != null) {
                terminate(value);
            }
            return cause;
        }

        private TerminalCause timeout() {
            return terminal.timeout();
        }

        private TerminalCause complete() {
            return terminal.complete();
        }

        private TerminalCause cause() {
            return terminal.cause();
        }
    }
}
