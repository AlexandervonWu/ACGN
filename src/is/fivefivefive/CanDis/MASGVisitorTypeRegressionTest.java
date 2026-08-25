package is.fivefivefive.CanDis;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import edu.mit.csail.sdg.translator.A4Options;
import edu.mit.csail.sdg.translator.A4Solution;
import edu.mit.csail.sdg.translator.TranslateAlloyToKodkod;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.core.QuantiVar;
import parser.ast.nodes.ModelUnit;

public final class MASGVisitorTypeRegressionTest {
    private MASGVisitorTypeRegressionTest() {
    }

    public static void main(String[] args) throws Exception {
        String source = String.join("\n",
                "sig User { follows: set User }",
                "sig Photo {}",
                "sig File {}",
                "sig Protected, Trash in File {}",
                "pred candidate {",
                "  all x: univ | x in User implies x in User",
                "  all u: User | all f: u - u.follows | f in User",
                "  all y: User | some z: y | z in User",
                "  all n: none | n = n",
                "  all pt: Protected & Trash | pt in File",
                "}",
                "pred direct { all pt: Protected & Trash | pt in File }",
                "pred oracle { no none }",
                "assert quantified {",
                "  all p: Photo, u1, u2: User | u1 = u2 implies p = p",
                "}");

        CompModule module = CompUtil.parseEverything_fromString(A4Reporter.NOP, source);
        MASGVisitor visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null, module), null);

        Multigraph candidate = graph(visitor, "candidate");
        Multigraph direct = graph(visitor, "direct");
        Multigraph oracle = graph(visitor, "oracle");
        if (candidate == null || oracle == null) {
            throw new AssertionError("Expected both predicate graphs");
        }
        int graphSize = Canonical.canonicalFormSize(candidate);
        int graphDistance = Canonical.distance(candidate, oracle);
        Canonical.Prepared preparedCandidate = Canonical.prepare(candidate);
        Canonical.Prepared preparedOracle = Canonical.prepare(oracle);
        if (graphSize != Canonical.canonicalFormSize(preparedCandidate)
                || graphDistance != Canonical.distance(preparedCandidate, preparedOracle)
                || !Canonical.irTemporalFol(candidate).equals(Canonical.irTemporalFol(preparedCandidate))
                || !Canonical.edits(candidate, oracle).equals(Canonical.edits(preparedCandidate, preparedOracle))) {
            throw new AssertionError("Prepared canonical form changed graph-based results");
        }
        long eclasses = Canonical.eclassCount(preparedCandidate);
        long enodes = Canonical.enodeCount(preparedCandidate);
        if (eclasses <= 0 || enodes < eclasses) {
            throw new AssertionError("Prepared canonical form did not retain valid e-graph counts");
        }
        Canonical.Prepared preparedDirect = Canonical.prepare(direct);
        boolean directPrimitiveCarrier = false;
        for (NormalForm form : preparedDirect.normalizedForms()) {
            for (QuantiVar variable : form.getMatrixQuantiVars()) {
                if (variable.getOriginalNames().contains("pt")) {
                    directPrimitiveCarrier = "File".equals(variable.getTypeName())
                            && "File".equals(variable.getCarrierTypeName());
                }
            }
        }
        if (!directPrimitiveCarrier) {
            throw new AssertionError(
                    "A directly liftable guarded binder lost its primitive File carrier");
        }

        boolean matrixContainsPt = false;
        boolean localContainsTypedPt = false;
        for (NormalForm form : preparedCandidate.normalizedForms()) {
            for (QuantiVar variable : form.getMatrixQuantiVars()) {
                matrixContainsPt |= variable.getOriginalNames().contains("pt");
            }
            localContainsTypedPt |= containsTypedLocalBinder(
                    form.getCertificationMatrixEGraph(), "pt", "File");
        }
        if (matrixContainsPt || !localContainsTypedPt) {
            throw new AssertionError(
                    "An unsafe cross-conjunction binder must remain local with exact File type");
        }

        checkBoundedSemantics(preparedCandidate, preparedDirect);
        System.out.println("MASGVisitorTypeRegressionTest passed");
    }

    private static Multigraph graph(MASGVisitor visitor, String name) {
        Integer id = visitor.getForestId(name);
        if (id == null || visitor.getForest().get(id) == null) {
            throw new AssertionError("Missing predicate graph: " + name);
        }
        return visitor.getForest().get(id);
    }

    private static boolean containsTypedLocalBinder(
            EGraphNode node,
            String sourceName,
            String primitiveType) {
        if (node == null) {
            return false;
        }
        if (node.getOpcode() == EGraphNode.Opcode.VARIABLE
                && sourceName.equals(node.getSourceName())) {
            ExactAlloyType exact = node.getExactAlloyType();
            if (exact != null
                    && exact.kind() == ExactAlloyType.Kind.RELATION
                    && exact.relationArity() == 1
                    && exact.alternatives().stream().allMatch(
                            columns -> columns.size() == 1
                                    && primitiveType.equals(columns.get(0)))) {
                return true;
            }
        }
        for (EGraphNode child : node.getChildren()) {
            if (containsTypedLocalBinder(child, sourceName, primitiveType)) {
                return true;
            }
        }
        return false;
    }

    private static void checkBoundedSemantics(
            Canonical.Prepared candidate,
            Canonical.Prepared direct) throws Exception {
        String candidateNormalized = CanonicalBacktranslator.formula(
                candidate.normalizedForms());
        String directNormalized = CanonicalBacktranslator.formula(
                direct.normalizedForms());
        String comparison = String.join("\n",
                "module guarded_binder_semantics",
                "sig User { follows: set User }",
                "sig Photo {}",
                "sig File {}",
                "sig Protected, Trash in File {}",
                "pred candidateOriginal {",
                "  all x: univ | x in User implies x in User",
                "  all u: User | all f: u - u.follows | f in User",
                "  all y: User | some z: y | z in User",
                "  all n: none | n = n",
                "  all pt: Protected & Trash | pt in File",
                "}",
                "pred candidateNormalized { " + candidateNormalized + " }",
                "pred directOriginal { all pt: Protected & Trash | pt in File }",
                "pred directNormalized { " + directNormalized + " }",
                "pred guardedOriginal {",
                "  some File and (all pt: Protected & Trash | pt = pt)",
                "}",
                "pred liftedOverFile {",
                "  all pt: File | some File and",
                "    (pt in (Protected & Trash) implies pt = pt)",
                "}",
                "pred liftedOverUniv {",
                "  all pt: univ | some File and",
                "    (pt in (Protected & Trash) implies pt = pt)",
                "}",
                "assert CandidateZero { candidateOriginal[] iff candidateNormalized[] }",
                "assert CandidateThree { candidateOriginal[] iff candidateNormalized[] }",
                "assert DirectSame { directOriginal[] iff directNormalized[] }",
                "run { not (guardedOriginal[] iff liftedOverFile[]) } for 0 but 0 Int",
                "run { not (guardedOriginal[] iff liftedOverUniv[]) } for 0 but 0 Int",
                "check CandidateZero for 0 but 0 Int",
                "check CandidateThree for 3 but 0 Int",
                "check DirectSame for 3 but 0 Int",
                "");
        Path file = Files.createTempFile("guarded-binder-semantics-", ".als");
        try {
            Files.writeString(file, comparison, StandardCharsets.UTF_8);
            CompModule module = CompUtil.parseEverything_fromFile(
                    A4Reporter.NOP, null, file.toString());
            A4Options options = new A4Options();
            options.solver = A4Options.SatSolver.SAT4J;
            for (int index = 0; index < module.getAllCommands().size(); index++) {
                A4Solution result = TranslateAlloyToKodkod.execute_command(
                        A4Reporter.NOP,
                        module.getAllReachableSigs(),
                        module.getAllCommands().get(index),
                        options);
                boolean expectedSatisfiable = index < 2;
                if (result == null || result.satisfiable() != expectedSatisfiable) {
                    throw new AssertionError(
                            "Guarded-binder SAT expectation failed for command " + index);
                }
            }
        } finally {
            Files.deleteIfExists(file);
        }
    }
}
