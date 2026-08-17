package is.fivefivefive.CanDis;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import edu.mit.csail.sdg.parser.CompModule;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Fast Alloy-to-exact-engine Phase I conformance checks. */
public final class CanonicalAlloyPipelineTest {
    private static int checks;

    private CanonicalAlloyPipelineTest() {
    }

    public static void main(String[] args) throws Exception {
        Path directory = Files.createTempDirectory("candis-phase-i-");
        Path modelPath = directory.resolve("phase_i.als");
        try {
            Files.writeString(modelPath, source(), StandardCharsets.UTF_8);
            CompModule module = AlloyUtil.compileAlloyModule(modelPath.toString());
            check(module != null, "self-contained Alloy fixture must parse");
            ModelUnit model = new ModelUnit(null, module);
            MASGVisitor visitor = new MASGVisitor(new GlobalVariables());
            visitor.visit(model, null);

            CanonicalAlloyPipeline.Prepared alphaLeft = prepare(visitor, "alphaLeft");
            CanonicalAlloyPipeline.Prepared alphaRight = prepare(visitor, "alphaRight");
            CanonicalAlloyPipeline.Prepared aciLeft = prepare(visitor, "aciLeft");
            CanonicalAlloyPipeline.Prepared aciRight = prepare(visitor, "aciRight");
            CanonicalAlloyPipeline.Prepared positive = prepare(visitor, "positive");
            CanonicalAlloyPipeline.Prepared negative = prepare(visitor, "negative");
            CanonicalAlloyPipeline.Prepared shadowLeft = prepare(visitor, "shadowLeft");
            CanonicalAlloyPipeline.Prepared shadowRight = prepare(visitor, "shadowRight");
            CanonicalAlloyPipeline.Prepared disjoint = prepare(visitor, "disjointPred");
            CanonicalAlloyPipeline.Prepared nondisjoint = prepare(visitor, "nondisjoint");
            CanonicalAlloyPipeline.Prepared temporalLeft = prepare(visitor, "temporalLeft");
            CanonicalAlloyPipeline.Prepared temporalRight = prepare(visitor, "temporalRight");

            check(alphaLeft.equivalentTo(alphaRight),
                    "same-descriptor binder permutation must be alpha-equivalent");
            check(CanonicalAlloyPipeline.distance(alphaLeft, alphaRight) == 0,
                    "alpha-equivalent binders must have exact distance zero");
            check(aciLeft.equivalentTo(aciRight),
                    "ACI boolean operands must share the exact canonical key");
            check(CanonicalAlloyPipeline.distance(aciLeft, aciRight) == 0,
                    "ACI-equivalent matrices must have exact distance zero");
            check(CanonicalAlloyPipeline.distance(positive, negative) > 0,
                    "semantically opposed atoms must remain distinguishable");
            check(shadowLeft.equivalentTo(shadowRight),
                    "shadowed binders must remain alpha-equivalent without alias capture");
            check(CanonicalAlloyPipeline.distance(disjoint, nondisjoint) > 0,
                    "disjointness classes must remain part of the binder descriptor");
            check(CanonicalAlloyPipeline.distance(temporalLeft, temporalRight) > 0,
                    "different temporal-phase matrices must remain distinguishable");
            check(alphaLeft.eclassCount() > 0 && alphaLeft.enodeCount() > 0,
                    "exact graph statistics must be populated");
            check(alphaLeft.digest().length() == 64,
                    "canonical digest must be a SHA-256 hex string");
            check(alphaLeft.digest().equals(prepare(visitor, "alphaLeft").digest()),
                    "repeated adaptation must be deterministic");

            System.out.println("CanonicalAlloyPipelineTest passed: " + checks + " checks");
        } finally {
            Files.deleteIfExists(modelPath);
            Files.deleteIfExists(directory);
        }
    }

    private static CanonicalAlloyPipeline.Prepared prepare(
            MASGVisitor visitor,
            String predicate) {
        Integer id = visitor.getForestId(predicate);
        check(id != null, "missing MASG predicate " + predicate);
        Multigraph graph = visitor.getForest().get(id);
        check(graph != null, "missing MASG graph " + predicate);
        return CanonicalAlloyPipeline.prepare(graph);
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private static String source() {
        return "module phase_i\n"
                + "sig S { r: set S }\n"
                + "pred alphaLeft { all x, y: S | y in x.r }\n"
                + "pred alphaRight { all a, b: S | a in b.r }\n"
                + "pred aciLeft { (some S and lone S) and one S }\n"
                + "pred aciRight { one S and (lone S and some S) }\n"
                + "pred positive { some S }\n"
                + "pred negative { no S }\n"
                + "pred shadowLeft { all x: S | some x: S | x in S }\n"
                + "pred shadowRight { all a: S | some b: S | b in S }\n"
                + "pred disjointPred { all disj x, y: S | y in x.r }\n"
                + "pred nondisjoint { all x, y: S | y in x.r }\n"
                + "pred temporalLeft { after some S }\n"
                + "pred temporalRight { after no S }\n";
    }
}
