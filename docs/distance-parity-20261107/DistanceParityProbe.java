package is.fivefivefive.CanDis;

import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.Set;
import org.json.JSONArray;
import org.json.JSONObject;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.Command;
import edu.mit.csail.sdg.parser.CompUtil;
import edu.mit.csail.sdg.translator.A4Options;
import edu.mit.csail.sdg.translator.TranslateAlloyToKodkod;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.metric.RepairView;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Read-only source-to-distance diagnostic, not an authority or a rewrite. */
public final class DistanceParityProbe {
    public static void main(String[] args) throws Exception {
        Path source = Path.of(args[0]);
        var module = AlloyUtil.compileAlloyModule(source.toString());
        if (module == null) throw new IllegalArgumentException("Source failed to parse: " + source);
        Path other = args.length > 4 ? Path.of(args[4]) : source;
        var rightModule = other.equals(source) ? module : AlloyUtil.compileAlloyModule(other.toString());
        if (rightModule == null) throw new IllegalArgumentException("Source failed to parse: " + other);
        var left = prepare(module, args[1]);
        var right = prepare(rightModule, args[2]);
        var a = CanonicalAlloyPipeline.prepare(left);
        var b = CanonicalAlloyPipeline.prepare(right);
        var fast = Canonical.distanceBreakdown(left, right);
        var certified = CanonicalAlloyPipeline.distanceEvaluation(a, b);
        JSONObject result = new JSONObject().put("source", args[0])
                .put("sourceSha256", HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                        .digest(Files.readAllBytes(source))))
                .put("rightSource", other.toString())
                .put("rightSourceSha256", HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                        .digest(Files.readAllBytes(other))))
                .put("leftPredicate", args[1]).put("rightPredicate", args[2])
                .put("fast", new JSONArray(new int[]{fast.distance(), fast.temporalDistance(),
                        fast.quantifierDistance(), fast.matrixDistance()}))
                .put("certified", new JSONArray(new int[]{certified.distance(), certified.temporalDistance(),
                        certified.quantifierDistance(), certified.matrixDistance()}))
                .put("fastReverse", Canonical.distance(right, left))
                .put("certifiedReverse", CanonicalAlloyPipeline.distance(b, a))
                .put("leftFastIr", Canonical.irTemporalFol(left))
                .put("rightFastIr", Canonical.irTemporalFol(right))
                .put("leftRetained", retained(left)).put("rightRetained", retained(right))
                .put("leftProjection", projection(a.repairView()))
                .put("rightProjection", projection(b.repairView()))
                .put("observationsEqual", a.canonicalObservation().equivalentTo(b.canonicalObservation()));
        if (args.length > 3 && args[3].equals("solve")) {
            var solverModule = module;
            String rightName = args[2];
            if (!other.equals(source)) {
                if (args.length < 6) throw new IllegalArgumentException("Cross-source solver needs archived right body");
                rightName = "audit_rhs";
                solverModule = CompUtil.parseEverything_fromString(A4Reporter.NOP,
                        Files.readString(source) + "\npred audit_rhs {\n" + args[5] + "\n}\n");
                result.put("solverRightBody", args[5]);
                result.put("solverContext", "left source declarations plus archived right predicate body");
            }
            var formula = CompUtil.parseOneExpression_fromString(solverModule,
                    "not (" + args[1] + " iff " + rightName + ")");
            var command = new Command(false, 4, 4, 4, null, formula);
            var options = new A4Options();
            options.solver = kodkod.engine.satlab.SATFactory.get("sat4j");
            result.put("counterexampleAtScope4", TranslateAlloyToKodkod.execute_command(
                    A4Reporter.NOP, solverModule.getAllReachableSigs(), command, options).satisfiable());
        }
        System.out.println("AUDIT_JSON " + result);
    }

    private static Canonical.Prepared prepare(edu.mit.csail.sdg.parser.CompModule module, String name) {
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of(name), module);
        visitor.visit(new ModelUnit(null, module), null);
        return Canonical.prepare(visitor.getForest().get(visitor.getForestId(name)));
    }

    private static JSONArray retained(Canonical.Prepared prepared) {
        JSONArray out = new JSONArray();
        for (var form : prepared.normalizedForms()) out.put(retainedNode(form.getMatrixEGraph()));
        return out;
    }

    private static JSONObject retainedNode(EGraphNode node) {
        if (node == null) return new JSONObject();
        JSONArray children = new JSONArray();
        for (var child : node.getChildren()) children.put(retainedNode(child));
        return new JSONObject().put("operator", node.getOpcode()).put("name", node.getSourceName())
                .put("type", String.valueOf(node.getExactAlloyType()))
                .put("container", node.getFlexibleArityKind())
                .put("children", children);
    }

    private static JSONArray projection(RepairView view) {
        JSONArray out = new JSONArray();
        for (var phase : view.phases()) {
            JSONArray declarations = new JSONArray();
            for (var d : phase.quantifiers()) declarations.put(d.quantifier() + " " + d.type());
            out.put(new JSONObject().put("declarations", declarations).put("matrix", node(phase.matrix())));
        }
        return out;
    }

    private static JSONObject node(RepairView.Node node) {
        if (node == null) return new JSONObject();
        JSONArray children = new JSONArray();
        for (var child : node.children()) children.put(node(child));
        return new JSONObject().put("operator", node.operator()).put("payload", node.semanticPayload())
                .put("binding", node.bindingIndex()).put("lexical", node.lexicalVariable())
                .put("children", children);
    }
}
