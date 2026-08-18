package is.fivefivefive.CanDis;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.Objects;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.json.JSONException;
import org.json.JSONObject;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;

/** Minimal JSON/HTTP boundary for the Alloy e-graph explorer. */
public final class VisualizationServer {
    private static final int DEFAULT_PORT = 8080;
    private static final int MAX_REQUEST_BYTES = VisualizationAnalysisService.MAX_MODEL_CHARS * 4 + 65_536;

    private VisualizationServer() {
    }

    public static void main(String[] args) throws IOException {
        Configuration configuration = Configuration.parse(args);
        VisualizationAnalysisService service = new VisualizationAnalysisService();
        HttpServer server = HttpServer.create(
                new InetSocketAddress(configuration.bindAddress, configuration.port), 32);
        ExecutorService executor = Executors.newFixedThreadPool(configuration.workers);
        server.setExecutor(executor);
        server.createContext("/api/v1/health", new Endpoint(configuration, exchange -> {
            requireMethod(exchange, "GET");
            return new Response(200, new JSONObject()
                    .put("status", "ok")
                    .put("version", VisualizationAnalysisService.SERVICE_VERSION)
                    .put("visualizationSchemaVersion", VisualizationAnalysisService.SCHEMA_VERSION)
                    .put("serviceVersion", VisualizationAnalysisService.SERVICE_VERSION)
                    .put("schemaVersion", VisualizationAnalysisService.SCHEMA_VERSION));
        }));
        server.createContext("/api/v1/model/inspect", new Endpoint(configuration, exchange -> {
            requireMethod(exchange, "POST");
            JSONObject request = requestJson(exchange);
            return new Response(200, service.inspect(request.optString("model", "")));
        }));
        server.createContext("/api/v1/egraph/analyze", new Endpoint(configuration, exchange -> {
            requireMethod(exchange, "POST");
            JSONObject request = requestJson(exchange);
            CallableRequest callable = CallableRequest.from(request);
            return new Response(200, service.analyze(
                    request.optString("model", ""), callable.name, callable.kind));
        }));
        server.createContext("/api/v1/egraph/compare", new Endpoint(configuration, exchange -> {
            requireMethod(exchange, "POST");
            JSONObject request = requestJson(exchange);
            CallableRequest left = CallableRequest.from(request, "leftCallable");
            CallableRequest right = CallableRequest.from(request, "rightCallable");
            return new Response(200, service.compare(
                    request.optString("model", ""),
                    left.name,
                    left.kind,
                    right.name,
                    right.kind));
        }));
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            server.stop(1);
            executor.shutdownNow();
        }, "visualization-server-shutdown"));
        server.start();
        System.out.printf(
                Locale.ROOT,
                "Alloy e-graph visualization API listening at http://%s:%d/api/v1/%n",
                configuration.bindAddress,
                configuration.port);
    }

    private static JSONObject requestJson(HttpExchange exchange) throws IOException {
        String contentType = exchange.getRequestHeaders().getFirst("Content-Type");
        if (contentType != null
                && !contentType.toLowerCase(Locale.ROOT).startsWith("application/json")) {
            throw new HttpFailure(415, "unsupported_media_type", "Content-Type must be application/json.");
        }
        byte[] bytes = readBounded(exchange.getRequestBody());
        if (bytes.length == 0) {
            throw new HttpFailure(400, "invalid_request", "A JSON request body is required.");
        }
        try {
            return new JSONObject(new String(bytes, StandardCharsets.UTF_8));
        } catch (JSONException exception) {
            throw new HttpFailure(400, "invalid_request", "The request body is not valid JSON.");
        }
    }

    private static byte[] readBounded(InputStream input) throws IOException {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buffer = new byte[8192];
        int total = 0;
        int read;
        while ((read = input.read(buffer)) >= 0) {
            total += read;
            if (total > MAX_REQUEST_BYTES) {
                throw new HttpFailure(413, "request_too_large", "The request body exceeds the service limit.");
            }
            output.write(buffer, 0, read);
        }
        return output.toByteArray();
    }

    private static void requireMethod(HttpExchange exchange, String expected) {
        if (!expected.equalsIgnoreCase(exchange.getRequestMethod())) {
            exchange.getResponseHeaders().set("Allow", expected + ", OPTIONS");
            throw new HttpFailure(405, "method_not_allowed", "Use " + expected + " for this endpoint.");
        }
    }

    private interface EndpointBody {
        Response handle(HttpExchange exchange) throws IOException;
    }

    private static final class Endpoint implements HttpHandler {
        private final Configuration configuration;
        private final EndpointBody body;

        private Endpoint(Configuration configuration, EndpointBody body) {
            this.configuration = configuration;
            this.body = body;
        }

        @Override
        public void handle(HttpExchange exchange) throws IOException {
            applyCommonHeaders(exchange.getResponseHeaders(), configuration.allowOrigin);
            if ("OPTIONS".equalsIgnoreCase(exchange.getRequestMethod())) {
                exchange.sendResponseHeaders(204, -1);
                exchange.close();
                return;
            }
            Response response;
            try {
                response = body.handle(exchange);
            } catch (VisualizationAnalysisService.AnalysisException exception) {
                response = error(exception.status(), exception.code(), exception.getMessage());
            } catch (HttpFailure exception) {
                response = error(exception.status, exception.code, exception.getMessage());
            } catch (Exception exception) {
                exception.printStackTrace(System.err);
                response = error(500, "internal_error", "The visualization service could not complete the request.");
            }
            writeJson(exchange, response);
        }
    }

    private static void applyCommonHeaders(Headers headers, String allowOrigin) {
        headers.set("Access-Control-Allow-Origin", allowOrigin);
        headers.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        headers.set("Access-Control-Allow-Headers", "Content-Type");
        headers.set("Cache-Control", "no-store");
        headers.set("X-Content-Type-Options", "nosniff");
    }

    private static void writeJson(HttpExchange exchange, Response response) throws IOException {
        byte[] payload = response.body.toString().getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().set("Content-Type", "application/json; charset=utf-8");
        exchange.sendResponseHeaders(response.status, payload.length);
        exchange.getResponseBody().write(payload);
        exchange.close();
    }

    private static Response error(int status, String code, String message) {
        return new Response(status, new JSONObject()
                .put("code", code)
                .put("message", message));
    }

    private static final class Response {
        private final int status;
        private final JSONObject body;

        private Response(int status, JSONObject body) {
            this.status = status;
            this.body = Objects.requireNonNull(body, "body");
        }
    }

    private static final class CallableRequest {
        private final String name;
        private final String kind;

        private CallableRequest(String name, String kind) {
            this.name = name;
            this.kind = kind;
        }

        private static CallableRequest from(JSONObject request) {
            JSONObject callable = request.optJSONObject("callable");
            String name = callable == null
                    ? request.optString("predicate", "")
                    : callable.optString("name", "");
            String kind = callable == null
                    ? "predicate"
                    : callable.optString("kind", "callable");
            if (name.trim().isEmpty()) {
                throw new HttpFailure(
                        400,
                        "callable_required",
                        "Select a predicate or function to analyze.");
            }
            if (!kind.equals("predicate") && !kind.equals("function") && !kind.equals("callable")) {
                throw new HttpFailure(
                        400,
                        "invalid_callable_kind",
                        "Callable kind must be predicate or function.");
            }
            return new CallableRequest(name, kind);
        }

        private static CallableRequest from(JSONObject request, String field) {
            JSONObject callable = request.optJSONObject(field);
            if (callable == null) {
                throw new HttpFailure(
                        400,
                        "callable_required",
                        field + " must identify a predicate or function.");
            }
            JSONObject wrapper = new JSONObject().put("callable", callable);
            return from(wrapper);
        }
    }

    private static final class HttpFailure extends RuntimeException {
        private final int status;
        private final String code;

        private HttpFailure(int status, String code, String message) {
            super(message);
            this.status = status;
            this.code = code;
        }
    }

    private static final class Configuration {
        private final String bindAddress;
        private final int port;
        private final String allowOrigin;
        private final int workers;

        private Configuration(String bindAddress, int port, String allowOrigin, int workers) {
            this.bindAddress = bindAddress;
            this.port = port;
            this.allowOrigin = allowOrigin;
            this.workers = workers;
        }

        private static Configuration parse(String[] args) {
            String bind = "127.0.0.1";
            int port = DEFAULT_PORT;
            String origin = "http://localhost:5173";
            int workers = Math.max(2, Math.min(8, Runtime.getRuntime().availableProcessors()));
            for (int index = 0; index < args.length; index++) {
                String argument = args[index];
                if ("--bind".equals(argument)) {
                    bind = value(args, ++index, argument);
                } else if ("--port".equals(argument)) {
                    port = positiveInt(value(args, ++index, argument), argument);
                } else if ("--allow-origin".equals(argument)) {
                    origin = value(args, ++index, argument);
                } else if ("--workers".equals(argument)) {
                    workers = positiveInt(value(args, ++index, argument), argument);
                } else if ("--help".equals(argument) || "-h".equals(argument)) {
                    System.out.println("Usage: VisualizationServer [--bind HOST] [--port PORT]"
                            + " [--allow-origin ORIGIN] [--workers N]");
                    System.exit(0);
                } else {
                    throw new IllegalArgumentException("Unknown argument: " + argument);
                }
            }
            return new Configuration(bind, port, origin, workers);
        }

        private static String value(String[] args, int index, String flag) {
            if (index >= args.length || args[index].trim().isEmpty()) {
                throw new IllegalArgumentException(flag + " requires a value");
            }
            return args[index];
        }

        private static int positiveInt(String value, String flag) {
            try {
                int parsed = Integer.parseInt(value);
                if (parsed > 0 && parsed <= 65_535) {
                    return parsed;
                }
            } catch (NumberFormatException ignored) {
                // Report a uniform command-line error below.
            }
            throw new IllegalArgumentException(flag + " requires a positive integer up to 65535");
        }
    }
}
