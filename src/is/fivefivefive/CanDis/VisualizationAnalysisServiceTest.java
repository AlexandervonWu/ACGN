package is.fivefivefive.CanDis;

import org.json.JSONArray;
import org.json.JSONObject;

/** Focused end-to-end smoke checks for predicate and function visualization. */
public final class VisualizationAnalysisServiceTest {
    private static final String MODEL = String.join("\n",
            "sig User { follows: set User }",
            "fun neighbors[u: User]: set User { u.follows }",
            "pred hasNeighbor[u: User] { some neighbors[u] }");

    private VisualizationAnalysisServiceTest() {
    }

    public static void main(String[] args) {
        VisualizationAnalysisService service = new VisualizationAnalysisService();
        JSONObject inspection = service.inspect(MODEL);
        JSONArray callables = inspection.getJSONArray("callables");
        if (callables.length() != 2) {
            throw new AssertionError("Inspection leaked parser-internal callables: " + callables);
        }
        assertCallable(callables, "neighbors", "function");
        assertCallable(callables, "hasNeighbor", "predicate");

        assertAnalysis(service.analyze(MODEL, "neighbors", "function"), "neighbors", "function");
        assertAnalysis(service.analyze(MODEL, "hasNeighbor", "predicate"), "hasNeighbor", "predicate");
        System.out.println("VisualizationAnalysisServiceTest passed");
    }

    private static void assertCallable(JSONArray values, String name, String kind) {
        for (int index = 0; index < values.length(); index++) {
            JSONObject callable = values.getJSONObject(index);
            if (name.equals(callable.getString("name")) && kind.equals(callable.getString("kind"))) {
                if (kind.equals("function")
                        && callable.optString("returnType", "").contains("parser.ast.nodes")) {
                    throw new AssertionError("Function return type is not presentation-ready: " + callable);
                }
                return;
            }
        }
        throw new AssertionError("Missing " + kind + " " + name + " in inspection response: " + values);
    }

    private static void assertAnalysis(JSONObject analysis, String name, String kind) {
        JSONObject callable = analysis.getJSONObject("callable");
        if (!name.equals(callable.getString("name")) || !kind.equals(callable.getString("kind"))) {
            throw new AssertionError("Unexpected callable metadata: " + callable);
        }
        JSONObject graph = analysis.getJSONObject("graph");
        JSONArray classes = graph.getJSONArray("eclasses");
        if (classes.length() == 0) {
            throw new AssertionError("Visualization graph has no e-classes for " + name);
        }
        String root = graph.getString("rootEClassId");
        for (int index = 0; index < classes.length(); index++) {
            if (root.equals(classes.getJSONObject(index).getString("id"))) {
                return;
            }
        }
        throw new AssertionError("Visualization root " + root + " is absent for " + name);
    }
}
