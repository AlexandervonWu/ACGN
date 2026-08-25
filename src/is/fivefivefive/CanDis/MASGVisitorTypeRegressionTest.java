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
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import is.fivefivefive.ACGN.alloy.FieldRelation;
import is.fivefivefive.ACGN.alloy.SigSymbol;
import is.fivefivefive.ACGN.alloy.VarSymbol;
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
                "open util/time",
                "sig User { follows: set User }",
                "sig Photo {}",
                "sig File {}",
                "sig Owner { x: set File }",
                "sig A {}",
                "sig B { A: set B }",
                "sig C { dup: set File }",
                "sig D { dup: set File }",
                "sig Protected, Trash in File {}",
                "pred candidate {",
                "  all x: univ | x in User implies x in User",
                "  all u: User | all f: u - u.follows | f in User",
                "  all y: User | some z: y | z in User",
                "  all n: none | n = n",
                "  all pt: Protected & Trash | pt in File",
                "}",
                "pred direct { all pt: Protected & Trash | pt in File }",
                "pred signatureShadow { all Trash: File | File in Trash }",
                "pred signatureReference { File in Trash }",
                "pred qualifiedSignature { all Trash: File | File in this/Trash }",
                "pred qualifiedSignatureReference { all t: File | File in Trash }",
                "pred qualifiedField { all x: File | some @x }",
                "pred qualifiedFieldReference { all y: File | some x }",
                "pred collidingSignature { some this/A }",
                "pred fieldC { some C.dup }",
                "pred fieldD { some D.dup }",
                "pred importedSignature { some Time }",
                "pred nestedQuantifierShadow {",
                "  all x: File | (all x: File | no x) and some x",
                "}",
                "pred nestedQuantifierRenamed {",
                "  all outer: File | (all inner: File | no inner) and some outer",
                "}",
                "pred nestedLetShadow {",
                "  let x = File | (let x = none | no x) and some x",
                "}",
                "pred nestedLetRenamed {",
                "  let outer = File | (let inner = none | no inner) and some outer",
                "}",
                "sig A_B {}",
                "pred delimiterCollision {",
                "  all C: A_B, B_C: this/A | no C and no B_C",
                "}",
                "pred delimiterRenamed {",
                "  all left: A_B, right: this/A | no left and no right",
                "}",
                "pred duplicateBinder {",
                "  all x, x, y: File | no x and no y",
                "}",
                "pred duplicateBinderRenamed {",
                "  all unused, x, y: File | no x and no y",
                "}",
                "pred oracle { no none }",
                "assert quantified {",
                "  all p: Photo, u1, u2: User | u1 = u2 implies p = p",
                "}");

        CompModule module = CompUtil.parseEverything_fromString(A4Reporter.NOP, source);
        MASGVisitor visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null, module), null);

        Multigraph candidate = graph(visitor, "candidate");
        Multigraph direct = graph(visitor, "direct");
        Multigraph signatureShadow = graph(visitor, "signatureShadow");
        Multigraph signatureReference = graph(visitor, "signatureReference");
        Multigraph qualifiedSignature = graph(visitor, "qualifiedSignature");
        Multigraph qualifiedSignatureReference =
                graph(visitor, "qualifiedSignatureReference");
        Multigraph qualifiedField = graph(visitor, "qualifiedField");
        Multigraph qualifiedFieldReference = graph(visitor, "qualifiedFieldReference");
        Multigraph collidingSignature = graph(visitor, "collidingSignature");
        Multigraph fieldC = graph(visitor, "fieldC");
        Multigraph fieldD = graph(visitor, "fieldD");
        Multigraph importedSignature = graph(visitor, "importedSignature");
        Multigraph nestedQuantifierShadow = graph(visitor, "nestedQuantifierShadow");
        Multigraph nestedQuantifierRenamed = graph(visitor, "nestedQuantifierRenamed");
        Multigraph nestedLetShadow = graph(visitor, "nestedLetShadow");
        Multigraph nestedLetRenamed = graph(visitor, "nestedLetRenamed");
        Multigraph delimiterCollision = graph(visitor, "delimiterCollision");
        Multigraph delimiterRenamed = graph(visitor, "delimiterRenamed");
        Multigraph duplicateBinder = graph(visitor, "duplicateBinder");
        Multigraph duplicateBinderRenamed = graph(visitor, "duplicateBinderRenamed");
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

        Canonical.Prepared preparedSignatureShadow = Canonical.prepare(signatureShadow);
        Canonical.Prepared preparedSignatureReference = Canonical.prepare(signatureReference);
        if (Canonical.distance(preparedSignatureShadow, preparedSignatureReference) == 0) {
            throw new AssertionError(
                    "A local binder named like a signature was resolved as the signature");
        }
        CanonicalAlloyPipeline.Prepared certifiedSignatureShadow =
                CanonicalAlloyPipeline.prepare(signatureShadow);
        CanonicalAlloyPipeline.Prepared certifiedSignatureReference =
                CanonicalAlloyPipeline.prepare(signatureReference);
        if (certifiedSignatureShadow.equivalentTo(certifiedSignatureReference)) {
            throw new AssertionError(
                    "Certified equality erased a local binder that shadows a signature");
        }
        CanonicalAlloyPipeline.Prepared certifiedQualifiedSignature =
                CanonicalAlloyPipeline.prepare(qualifiedSignature);
        CanonicalAlloyPipeline.Prepared certifiedQualifiedSignatureReference =
                CanonicalAlloyPipeline.prepare(qualifiedSignatureReference);
        if (!certifiedQualifiedSignature.equivalentTo(
                certifiedQualifiedSignatureReference)) {
            throw new AssertionError(
                    "An explicitly qualified signature was captured by a local binder");
        }
        if (!CanonicalAlloyPipeline.prepare(qualifiedField).equivalentTo(
                CanonicalAlloyPipeline.prepare(qualifiedFieldReference))) {
            throw new AssertionError(
                    "An explicitly qualified field was captured by a local binder");
        }
        boolean collidingGraphHasSignature = collidingSignature.getVertices().stream()
                .anyMatch(node -> node.getSymbol() instanceof SigSymbol
                        && "A".equals(node.getSymbol().getName()));
        boolean collidingGraphHasField = collidingSignature.getVertices().stream()
                .anyMatch(node -> node.getSymbol() instanceof FieldRelation
                        && "A".equals(node.getSymbol().getName()));
        if (!collidingGraphHasSignature || collidingGraphHasField) {
            throw new AssertionError(
                    "A field spelling collision changed an explicit signature leaf");
        }
        if (CanonicalAlloyPipeline.prepare(fieldC).equivalentTo(
                CanonicalAlloyPipeline.prepare(fieldD))) {
            throw new AssertionError(
                    "Same-named fields from distinct owners lost parser type identity");
        }
        if (importedSignature.getVertices().stream().noneMatch(
                node -> node.getSymbol() instanceof SigSymbol
                        && "time/Time".equals(node.getSymbol().getName()))) {
            throw new AssertionError(
                    "A reachable imported signature was absent from the global namespace");
        }
        if (Canonical.distance(nestedQuantifierShadow, nestedQuantifierRenamed) != 0
                || !CanonicalAlloyPipeline.prepare(nestedQuantifierShadow).equivalentTo(
                        CanonicalAlloyPipeline.prepare(nestedQuantifierRenamed))) {
            throw new AssertionError(
                    "A nested same-spelled quantifier captured the outer occurrence");
        }
        if (Canonical.distance(nestedLetShadow, nestedLetRenamed) != 0
                || !CanonicalAlloyPipeline.prepare(nestedLetShadow).equivalentTo(
                        CanonicalAlloyPipeline.prepare(nestedLetRenamed))) {
            throw new AssertionError(
                    "A nested same-spelled let captured the outer occurrence");
        }
        if (Canonical.distance(delimiterCollision, delimiterRenamed) != 0
                || !CanonicalAlloyPipeline.prepare(delimiterCollision).equivalentTo(
                        CanonicalAlloyPipeline.prepare(delimiterRenamed))) {
            throw new AssertionError(
                    "Presentation-derived variable keys collided within one lexical scope");
        }
        long duplicateBinderSlots = duplicateBinder.getVertices().stream()
                .filter(node -> node.getSymbol() instanceof VarSymbol)
                .map(node -> ((VarSymbol) node.getSymbol()).getHashName())
                .distinct()
                .count();
        boolean duplicateBinderHasX = duplicateBinder.getVertices().stream()
                .anyMatch(node -> node.getSymbol() instanceof VarSymbol
                        && "x".equals(node.getSymbol().getName()));
        boolean duplicateBinderHasY = duplicateBinder.getVertices().stream()
                .anyMatch(node -> node.getSymbol() instanceof VarSymbol
                        && "y".equals(node.getSymbol().getName()));
        int duplicateBinderDistance = Canonical.distance(
                duplicateBinder, duplicateBinderRenamed);
        boolean duplicateBinderEquivalent = CanonicalAlloyPipeline.prepare(
                duplicateBinder).equivalentTo(
                        CanonicalAlloyPipeline.prepare(duplicateBinderRenamed));
        if (duplicateBinderSlots != 2
                || !duplicateBinderHasX
                || !duplicateBinderHasY
                || duplicateBinderDistance != 0
                || !duplicateBinderEquivalent) {
            throw new AssertionError(
                    "Repeated binder spellings reused a lexical slot after scope-map overwrite: "
                            + "slots=" + duplicateBinderSlots
                            + ", distance=" + duplicateBinderDistance
                            + ", equivalent=" + duplicateBinderEquivalent);
        }
        AugmentedNode ownerDeclaration = visitor.getUniqueNode().get(new SigSymbol("Owner"));
        if (ownerDeclaration == null || ownerDeclaration.getMaxDownlinks() != 2) {
            throw new AssertionError(
                    "A preindexed signature retained leaf arity after one field and END were attached");
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
