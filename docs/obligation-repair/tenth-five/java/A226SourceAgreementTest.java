package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import edu.mit.csail.sdg.translator.A4Options;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.theory.*;
import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;
import parser.ast.nodes.ModelUnit;

/** Real parser-command sources, normal adapter, plus one direct private cycle-sentinel unit control. */
public final class A226SourceAgreementTest {
    private static final String ROOT = "phase/0/matrix/child/0/child/0";
    private static final String PREAMBLE = "module leaves\nabstract sig P {}\nsig A,B extends P {}\nsig Q {}\n"
            + "sig X { f,g,h: set P, fa: set A, fb: set B }\n";
    private static final String THREE_SIBLINGS = PREAMBLE.replace("sig A,B", "sig A,B,C")
            .replace("fb: set B }", "fb: set B, fc: set C, fd: set Q }");
    private record Input(CompModule module, Canonical.Prepared compiled, ExprBinary expression) {}
    private final List<String> rows = new ArrayList<>(List.of("case\tentry\tobservation\tdetail"));
    private static void require(boolean ok, String message) { if (!ok) throw new AssertionError(message); }
    private static Input parse(String expression) throws Exception {
        return parse(PREAMBLE,expression);
    }
    private static Input parse(String declarations, String expression) throws Exception {
        String source = declarations + "pred selected { some (" + expression + ") }\nrun selected for 4\n";
        var parsed = CompUtil.parseEverything_fromString(A4Reporter.NOP, source);
        var fn = parsed.getAllFunc().makeCopy().stream().filter(f -> f.label.equals("this/selected")).findFirst().orElseThrow();
        Expr body = fn.getBody().deNOP();
        require(body instanceof ExprUnary u && u.op == ExprUnary.Op.SOME, "predicate body");
        var binary = ((ExprUnary) body).sub.deNOP();
        require(binary instanceof ExprBinary, "binary root");
        var profile = AlloySemanticProfileFactory.fromExactlyOne(parsed, parsed.getAllCommands(), new A4Options());
        require(profile.isAuthorizedAlloyProfile(), "expected a parsed command");
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of("selected"), parsed);
        visitor.visit(new ModelUnit(null, parsed), null);
        var graph = visitor.getForest().get(visitor.getForestId("selected"));
        return new Input(parsed, Canonical.prepare(graph, profile), (ExprBinary) binary);
    }
    private static TheoryAlloyAdapter.Result adapt(Input in) {
        return TheoryAlloyAdapter.adapt(in.compiled().normalizedForms(), in.compiled().semanticProfile());
    }
    private static List<EGraphNode> children(EGraphNode node) {
        return node.getChildClasses().stream().map(c -> c.canonical().getEClass().getRepresentative()).toList();
    }
    private static EGraphNode outer(Input in) {
        var matrix = in.compiled().normalizedForms().get(0).getMatrixEGraph();
        var some = children(matrix).get(0);
        require(some.getOpcode() == EGraphNode.Opcode.SOME, "normalized root");
        return children(some).get(0);
    }
    private static String setTree(EGraphNode node) {
        if (node.getOpcode() != EGraphNode.Opcode.PLUS && node.getOpcode() != EGraphNode.Opcode.INTERSECT) return ".";
        return node.getOpcode().name() + "(" + String.join(",", children(node).stream().map(A226SourceAgreementTest::setTree).sorted().toList()) + ")";
    }
    private static DependentTypeDag parserDag(Input in, Expr e) {
        return AlloyTypeBridge.dependentTypeDag(ExactAlloyType.fromParser(e.type(), in.module()));
    }
    private static boolean same(DependentTypeDag a, DependentTypeDag b) throws Exception {
        var method = DependentTypeDag.class.getDeclaredMethod("sameOccurrenceEvidenceAs", DependentTypeDag.class);
        method.setAccessible(true);
        return (boolean) method.invoke(a, b);
    }
    private void record(String name, String entry, String outcome, String detail) {
        rows.add(String.join("\t", name, entry, outcome, detail));
    }
    private void leaf(String name, String expression, String tree, int arity, int products) throws Exception {
        leaf(PREAMBLE, name, expression, tree, arity, products);
    }
    private void leaf(String declarations, String name, String expression, String tree, int arity, int products) throws Exception {
        Input in = parse(declarations, expression);
        EGraphNode left = children(outer(in)).get(0);
        require(tree.equals(setTree(left)), name + " normalized set syntax " + setTree(left));
        var result = adapt(in);
        var binding = result.dependentChainSourceBindings().values().stream()
                .filter(b -> b.sourceOccurrencePath().equals(ROOT)).findFirst().orElseThrow();
        var leaf = binding.certificate().source().leafInputs().get(0);
        var actual = leaf.outputTypeDag();
        require(actual.arity() == arity && actual.alternatives().size() == products, "result arity/family");
        require(same(actual, parserDag(in, in.expression().left.deNOP())), "parser authority or DAG differs");
        if (products != 0) {
            var other = parse(declarations, expression);
            require(!same(actual, parserDag(other, other.expression().left.deNOP())), "different live source authority");
        }
        record(name, "ordinary-parse-and-adapt", "MATCHED", tree + " arity=" + arity + " products=" + products);
    }
    private void intLeaf(String name, String expression, ExprBinary.Op parserOp, String tree) throws Exception {
        Input in = parse(expression);
        var set = (ExprBinary) in.expression().left.deNOP();
        require(set.op == parserOp && set.type().is_int(), "expected Alloy set operation with exact Int");
        int count = 0;
        for (var pt : set.type()) { require(!pt.isEmpty() && pt.arity() == 1 && pt.get(0) == Sig.SIGINT, "Int parser type"); count++; }
        require(count == 1, "ambiguous Int carrier");
        var normalized = children(outer(in)).get(0);
        require(normalized.getExactAlloyType().kind() == ExactAlloyType.Kind.INT && setTree(normalized).equals(tree), "Int set tree");
        var result = adapt(in);
        var binding = result.dependentChainSourceBindings().values().stream()
                .filter(b -> b.sourceOccurrencePath().equals(ROOT)).findFirst().orElseThrow();
        var leaf = binding.certificate().source().leafInputs().get(0);
        var primitive = DependentTypeDag.fromRelationFamilyType(DependentChainTheory.relationViewFromStoredType(GraphType.INT));
        require(leaf.typeRule() == DependentChainTheory.LeafTypeRule.PRIMITIVE_SET_SINGLETON
                && same(leaf.outputTypeDag(), primitive), "different builtin lift");
        record(name,"ordinary-parse-and-adapt","MATCHED",parserOp.name()+"/"+tree+"/Int->Rel(Int)/PRIMITIVE_SET_SINGLETON");
    }
    private void mixedFixed(String name, String expression) throws Exception {
        Input in = parse(expression);
        var result = adapt(in);
        require(result.dependentChainSourceBindings().values().stream().noneMatch(b -> b.sourceOccurrencePath().equals(ROOT)),
                "mixed operand used an unvalidated outer chain");
        var artifact = result.semanticArtifact();
        require(artifact.guardedJoinConstructions().isEmpty(), "unexpected guarded source");
        var fixed = artifact.classes().values().stream().flatMap(c -> c.shapeWitnesses().keySet().stream()).map(CanonicalShape::node)
                .filter(n -> n.operator().operator().equals("ALLOY/ARROW") && n.ports().size()==2).toList();
        require(fixed.size() == 1 && fixed.get(0).ports().stream().allMatch(OnePort.class::isInstance), "expected fixed ARROW");
        record(name,"ordinary-parse-and-adapt","FIXED_BINARY","mixed-primitive-and-nominal-source/two-One-ports/no-outer-dependent-authority");
    }
    private void hardDisagreement() throws Exception {
        Input in = parse("((A+B)&P)->Q");
        try {
            adapt(in);
            throw new AssertionError("expected concrete parser/derived mismatch");
        } catch (IllegalStateException correct) {
            require(correct.getMessage().startsWith("A concrete set operator disagrees with its independently derived dependent type DAG: parser=")
                    && correct.getMessage().contains(", derived="), "incorrect rejection " + correct);
        }
        record("concrete-disagreement", "ordinary-parse-and-adapt", "HARD_REJECTION", "IllegalStateException/set-type-DAG");
    }
    private void cycleBoundary() throws Exception {
        Input in = parse("((f+g)&h)->Q");
        EGraphNode leaf = children(outer(in)).get(0);
        var cl = Class.forName("is.fivefivefive.CanDis.theory.TheoryAlloyAdapter$Builder");
        var constructor = cl.getDeclaredConstructor(List.class, SemanticProfile.class, CertificateTraceSink.class, CertificateProvenance.class);
        constructor.setAccessible(true);
        var builder = constructor.newInstance(List.of(), in.compiled().semanticProfile(), NoOpCertificateTraceSink.instance(), null);
        var visit = cl.getDeclaredMethod("dependentTypeDagForSource", EGraphNode.class, Set.class);
        visit.setAccessible(true);
        var seen = new HashSet<Integer>();
        var first = (DependentTypeDag) visit.invoke(builder, leaf, seen);
        require(seen.isEmpty() && same(first, parserDag(in, in.expression().left.deNOP())), "active stack leaked");
        int id = leaf.getEClass().getId();
        seen.add(id);
        try {
            visit.invoke(builder, leaf, seen);
            throw new AssertionError("expected recursive-set-eclass rejection");
        } catch (InvocationTargetException err) {
            require(err.getCause() instanceof IllegalStateException
                    && err.getCause().getMessage().equals("A dependent set-type DAG contains a recursive e-class"), "cycle error");
        }
        require(seen.equals(Set.of(id)), "caller stack changed");
        record("active-ancestor", "unit/private-type-walk", "HARD_REJECTION", "real-set-node/reentered-eclass");
        record("completed-sibling", "unit/private-type-walk", "MATCHED", "no-leaked-active-classes");
    }
    private void fallback(boolean guarded) throws Exception {
        Input in = parse(guarded ? "f.A.(P->Q)" : "((A->A)+(B->B)).A.(A->Q)");
        var result = adapt(in);
        require(result.dependentChainSourceBindings().values().stream().noneMatch(b -> b.sourceOccurrencePath().equals(ROOT)),
                "unlicensed outer dependent reassociation");
        var artifact = result.semanticArtifact();
        if (guarded) {
            require(artifact.guardedJoinConstructions().size() == 1 && artifact.constructionSources().guardedJoinSources().size() == 1,
                    "expected distinct guarded authority");
            record("separate-guarded", "ordinary-parse-and-adapt", "GUARDED_JOIN", "outer-dependent=0/guarded=1");
        } else {
            require(artifact.guardedJoinConstructions().isEmpty() && artifact.constructionSources().guardedJoinSources().isEmpty(),
                    "unexpected outer guarded certificate");
            var matches = artifact.classes().values().stream().flatMap(c -> c.shapeWitnesses().keySet().stream())
                    .map(CanonicalShape::node).filter(n -> n.operator().operator().equals("ALLOY/JOIN") && n.ports().size() == 2).toList();
            require(matches.size() == 1 && matches.get(0).ports().stream().allMatch(OnePort.class::isInstance),
                    "missing fixed binary one-port shape");
            require(result.dependentChainSourceBindings().values().stream().anyMatch(b -> b.sourceOccurrencePath().equals(ROOT + "/child/0")),
                    "independent child chain authority was lost");
            record("fixed-correlated-unary-interior", "ordinary-parse-and-adapt", "FIXED_BINARY",
                    "two-One-ports/outer-dependent=0/guarded=0/inner-dependent=1");
        }
    }
    public static void main(String[] args) throws Exception {
        if (args.length != 1) throw new IllegalArgumentException("A226SourceAgreementTest NEW_TSV");
        var test = new A226SourceAgreementTest();
        test.leaf("union", "(f+g)->Q", "PLUS(.,.)", 2, 1);
        test.leaf("intersection", "(f&g)->Q", "INTERSECT(.,.)", 2, 1);
        test.leaf("recursive-plus-under-intersect", "((f+g)&h)->Q", "INTERSECT(.,PLUS(.,.))", 2, 1);
        test.leaf("recursive-intersect-under-plus", "((f&g)+h)->Q", "PLUS(.,INTERSECT(.,.))", 2, 1);
        test.leaf("correlated-union", "((A->A)+(B->B))->Q", "PLUS(.,.)", 2, 2);
        test.leaf("field-union", "(fa+fb)->Q", "PLUS(.,.)", 2, 2);
        test.leaf("positive-empty-unary", "(A&B)->Q", "INTERSECT(.,.)", 1, 0);
        test.leaf("positive-empty-binary", "(fa&fb)->Q", "INTERSECT(.,.)", 2, 0);
        test.leaf(THREE_SIBLINGS, "all-empty-union-unary", "((A&B)+(C&Q))->Q", "PLUS(INTERSECT(.,.),INTERSECT(.,.))", 1, 0);
        test.leaf(THREE_SIBLINGS, "all-empty-union-binary", "((fa&fb)+(fc&fd))->Q", "PLUS(INTERSECT(.,.),INTERSECT(.,.))", 2, 0);
        test.intLeaf("integer-union", "(1+2)->Q", ExprBinary.Op.PLUS, "PLUS(.,.)");
        test.intLeaf("integer-intersection", "(1&2)->Q", ExprBinary.Op.INTERSECT, "INTERSECT(.,.)");
        test.intLeaf("integer-nested", "((1+2)&3)->Q", ExprBinary.Op.INTERSECT, "INTERSECT(.,PLUS(.,.))");
        test.mixedFixed("mixed-relation-result", "(A+1)->Q");
        test.mixedFixed("mixed-integer-result", "((A+1)&Int)->Q");
        test.mixedFixed("mixed-empty-integer-result", "((A&B)+1)->Q");
        test.hardDisagreement();
        test.cycleBoundary();
        test.fallback(false);
        test.fallback(true);
        Files.write(Path.of(args[0]), test.rows, StandardOpenOption.CREATE_NEW);
        System.out.println("A226 source agreement passed: " + (test.rows.size() - 1) + " observations");
    }
}
