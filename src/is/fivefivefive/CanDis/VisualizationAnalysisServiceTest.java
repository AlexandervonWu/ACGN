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
        assertComparison(service.compare(
                MODEL, "neighbors", "function", "hasNeighbor", "predicate"), false);
        assertComparison(service.compare(
                MODEL, "neighbors", "function", "neighbors", "function"), true);
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
        if (callable.getString("canonicalText").contains("canonical-alloy-form")
                || !callable.has("certifiedStableForm")) {
            throw new AssertionError("Certified machine form leaked into presentation text: " + callable);
        }
        JSONObject graph = analysis.getJSONObject("graph");
        JSONArray classes = graph.getJSONArray("eclasses");
        if (classes.length() == 0) {
            throw new AssertionError("Visualization graph has no e-classes for " + name);
        }
        String root = graph.getString("rootEClassId");
        for (int index = 0; index < classes.length(); index++) {
            JSONObject eclass = classes.getJSONObject(index);
            JSONArray nodes = eclass.getJSONArray("nodes");
            for (int nodeIndex = 0; nodeIndex < nodes.length(); nodeIndex++) {
                JSONObject node = nodes.getJSONObject(nodeIndex);
                if (node.getString("displayName").startsWith("ALLOY/")) {
                    throw new AssertionError("Certified operator leaked into graph label: " + node);
                }
                if (!node.getJSONObject("attributes").has("certifiedOperator")) {
                    throw new AssertionError("Graph presentation discarded certified operator: " + node);
                }
            }
            if (root.equals(eclass.getString("id"))) {
                return;
            }
        }
        throw new AssertionError("Visualization root " + root + " is absent for " + name);
    }

    private static void assertComparison(JSONObject comparison, boolean equivalent) {
        if (!comparison.getJSONObject("left").has("canonicalText")
                || !comparison.getJSONObject("right").has("canonicalText")) {
            throw new AssertionError("Comparison omitted callable representations: " + comparison);
        }
        if (!comparison.getJSONObject("left").has("certifiedStableForm")
                || comparison.getJSONObject("left").getString("canonicalText")
                        .contains("canonical-alloy-form")) {
            throw new AssertionError("Comparison representation is not presentation-safe: " + comparison);
        }
        JSONObject distance = comparison.getJSONObject("distance");
        int total = distance.getInt("total");
        if (total != distance.getInt("temporal")
                        + distance.getInt("quantifier")
                        + distance.getInt("matrix")) {
            throw new AssertionError("Distance components do not sum to total: " + distance);
        }
        int operationCost = 0;
        JSONArray operations = comparison.getJSONArray("operations");
        for (int index = 0; index < operations.length(); index++) {
            operationCost += operations.getJSONObject(index).getInt("cost");
        }
        if (operationCost != total) {
            throw new AssertionError("Operation costs do not witness the distance: " + comparison);
        }
        if (comparison.getBoolean("certifiedEquivalent") != equivalent
                || (total == 0) != equivalent) {
            throw new AssertionError("Certified zero kernel mismatch: " + comparison);
        }
    }
}
