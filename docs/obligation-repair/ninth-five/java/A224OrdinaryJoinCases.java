package org.acgn.cert;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.CompUtil;
import edu.mit.csail.sdg.translator.A4Options;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.CanonicalAlloyPipeline;
import is.fivefivefive.CanDis.theory.AlloySemanticProfileFactory;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.concurrent.TimeUnit;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;

/** Exports real parser-command source, then checks unmodified artifacts through the standalone FULL CLI. */
public final class A224OrdinaryJoinCases {
    private static final String THEORY = "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";
    private static final String HIERARCHY = "Subtype JOIN ancestry is internally consistent but lacks an independently pinned source-hierarchy authority";
    private static final String LEFT = "0,0/JOIN_OVERLAP/LEFT_SUBTYPE_OF_RIGHT";
    private static final String DISJOINT = "0,0/JOIN_DISJOINT/DISJOINT_BRANCHES";
    private static final String MORE_DISJOINT = ";1,0/JOIN_DISJOINT/DISJOINT_BRANCHES";
    private static final String RIGHT = "0,0/JOIN_OVERLAP/RIGHT_SUBTYPE_OF_LEFT";

    private record Case(String module, String declarations, String expression, String decisions, int arity, int products) {
        byte[] source() {
            return ("module " + module + "\n" + declarations + " pred selected { some " + expression
                    + " }\nrun selected for 4\n").getBytes(StandardCharsets.UTF_8);
        }
        String selector() { return module + "/selected"; }
    }
    private static final List<Case> CASES = List.of(
            new Case("sub", "sig Q {} sig P { r: set Q } sig C extends P {}", "C.r", LEFT, 1, 1),
            new Case("fields", "sig Q {} sig P { r: set Q } sig C extends P {} sig X { s: set C }", "s.r", LEFT, 2, 1),
            new Case("dis", "sig Q {} sig P {} sig A extends P { r: set Q } sig B extends P {}", "B.r", DISJOINT, 1, 0),
            new Case("pair", "sig T {} sig A,B extends T {} sig X { s: (T + X) } sig Q {} sig U { r: set Q }",
                    "s.r", DISJOINT + MORE_DISJOINT, 2, 0),
            new Case("multi", "sig P {} sig A,B extends P {} sig X { f: (A->B)+(B->A) } sig U {} sig H extends B { r: set U }",
                    "f.r", RIGHT + MORE_DISJOINT, 3, 1),
            new Case("ordering", "sig P {} sig AA,Z extends P {} sig X { f: (AA->Z)+(Z->AA) } sig U {} sig H extends Z { r: set U }",
                    "f.r", RIGHT + MORE_DISJOINT, 3, 1),
            new Case("equal", "sig Q {} sig P { r: set Q }", "P.r", "0,0/JOIN_OVERLAP/EXACT", 1, 1));

    private record Operand(String name, String wireOperator, String relationSpelling) {}
    private static void require(boolean ok, String detail) {
        if (!ok) throw new AssertionError(detail);
    }
    private static Operand operand(Expr expression) {
        Expr value = expression.deNOP();
        String name;
        String wire;
        if (value instanceof Sig.Field field) {
            name = "field/" + field.sig.label + "." + field.label;
            wire = "ALLOY/GLOBALBINDING/" + field.label;
        } else if (value instanceof Sig.PrimSig sig && !sig.builtin && sig.label.startsWith("this/")) {
            name = "sig/" + sig.label;
            wire = "ALLOY/GLOBALBINDING/alloy/signature/" + sig.label.substring(5);
        } else {
            throw new AssertionError("operand is outside the two direct-field/signature fixture declarations");
        }
        // The independent caller starts with resolved Alloy primitive signatures, without consulting the issuer or wire.
        var tuples = new TreeSet<String>();
        for (var product : value.type()) {
            require(!product.isEmpty() && product.arity() > 0, "expected nonempty nominal operand");
            StringBuilder tuple = new StringBuilder();
            for (int i = 0; i < product.arity(); i++) {
                String column = product.get(i).label;
                require(column.startsWith("this/"), "nonlocal column");
                String label = column.substring(5);
                tuple.append(label.length()).append(':').append(label);
            }
            require(tuples.add(tuple.toString()), "duplicate raw tuple");
        }
        require(!tuples.isEmpty(), "empty operand");
        return new Operand(name, wire, "RELATION[" + String.join("][", tuples) + "]");
    }
    private static List<Operand> independentOperands(Case example, byte[] bytes) throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, new String(bytes, StandardCharsets.UTF_8));
        require(module.getModuleName().equals(example.module()) && module.getAllMacros().size() == 0, "nonlocal selector");
        for (var open : module.getOpens()) require(open.filename.equals("util/integer") && open.pos == null, "source import");
        var matches = module.getAllFunc().makeCopy().stream()
                .filter(f -> f.label.equals("this/selected") && f.isPred && f.count() == 0).toList();
        require(matches.size() == 1, "ambiguous selected predicate");
        var body = matches.get(0).getBody().deNOP();
        require(body instanceof ExprUnary u && u.op == ExprUnary.Op.SOME, "expected some");
        var relation = ((ExprUnary) body).sub.deNOP();
        require(relation instanceof ExprBinary b && b.op == ExprBinary.Op.JOIN, "expected binary join");
        var join = (ExprBinary) relation;
        return List.of(operand(join.left), operand(join.right));
    }
    private static void export(Case example, byte[] bytes, Path out) throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, new String(bytes, StandardCharsets.UTF_8));
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of("selected"), module);
        visitor.visit(new ModelUnit(null, module), null);
        var graph = visitor.getForest().get(visitor.getForestId("selected"));
        var profile = AlloySemanticProfileFactory.fromExactlyOne(module, module.getAllCommands(), new A4Options());
        require(profile.isAuthorizedAlloyProfile(), "expected independent parser-command authority");
        CanonicalAlloyPipeline.prepareForVerification(graph, profile, example.selector(), bytes)
                .certificateExportSession().write(out);
    }
    private static void checkLeaf(Wire.Node leaf, KernelModel model, Operand operand) {
        leaf.requireShape("dependent-chain-leaf", 5, 1);
        require(leaf.scalar(2).equals("EXACT_RELATION"), "wrong leaf typing rule");
        String source = operand.relationSpelling();
        String prefix = "34:dependent-chain-leaf-type-proof-v2[2:14:EXACT_RELATION" + source.length() + ":" + source + "]{2:";
        require(leaf.scalar(4).startsWith(prefix), "wire parser spelling differs for " + operand.name());
        var port = model.term(leaf.scalar(0));
        var invocation = model.term(port.children().get(0));
        var definition = model.witness(invocation.symbol()).definition();
        require(model.operator(definition.symbol()).semanticIdentity().equals(operand.wireOperator()), "leaf operator differs");
    }
    private static String run(Case example, Path jar, Path file, Path log) throws Exception {
        byte[] source = example.source();
        String hash = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(source));
        var operands = independentOperands(example, source);
        String subject = CallOccurrenceCommitment.subjectDigest(example.selector(), hash);
        // The whole selected predicate was inspected above. Its only operators are SOME, JOIN and direct leaves.
        var pin = new CallOccurrenceCommitment(subject, CallOccurrenceCommitment.digest(subject, List.of()));
        export(example, source, file);
        Bundle bundle = Bundle.parse(Codec.decode(Files.readAllBytes(file), Limits.defaults()));
        require(bundle.metadata().inputSha256().equals(hash) && bundle.metadata().inputIdentifier().equals(example.selector())
                && bundle.metadata().mode().equals("TEST_ONLY"), "unexpected provenance");
        Wire.Node section = bundle.semanticEvidence().child(1);
        require(section.children().size() == 1 && section.child(0).scalar(2).equals("JOIN"), "wrong dependent root");
        Wire.Node application = section.child(0).child(0).requireShape("dependent-chain-application", 4, 4);
        KernelModel model = new KernelModel(bundle, Limits.defaults());
        for (int i = 0; i < 2; i++) checkLeaf(application.child(i), model, operands.get(i));
        String decisions = String.join(";", application.child(3).children().stream().map(d ->
                d.scalar(0) + "," + d.scalar(1) + "/" + d.scalar(2) + "/" + d.child(0).scalar(0)).toList());
        require(decisions.equals(example.decisions()), "different decision matrix for " + example.selector());
        Wire.Node result = application.child(2);
        require(result.scalar(2).equals(Integer.toString(example.arity())) && result.children().size() == example.products(),
                "wrong result type for " + example.selector());
        if (example.module().equals("ordering"))
            require(operands.get(0).relationSpelling().equals("RELATION[1:X1:Z2:AA][1:X2:AA1:Z]"), "parser tuple sort");
        var command = List.of(Path.of(System.getProperty("java.home"), "bin", "java").toString(), "-Xmx144m", "-jar",
                jar.toString(), "--profile", "FULL", "--theory-digest", THEORY, "--call-occurrence-commitment",
                pin.assignment(), file.toString());
        var process = new ProcessBuilder(command).redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if (!process.waitFor(25, TimeUnit.SECONDS)) {
            process.destroyForcibly().waitFor();
            throw new AssertionError("CLI timeout");
        }
        var verdict = new JSONObject(Files.readString(log));
        require(process.exitValue() == 3 && verdict.getString("outcome").equals("UNCHECKABLE")
                && verdict.getString("code").equals("MISSING_EVIDENCE") && verdict.getString("detail").equals(HIERARCHY),
                example.selector() + " " + verdict);
        return String.join("\t", example.selector(), hash, "PARSED_SOURCE_COMMAND", bundle.metadata().mode(),
                operands.get(0).name(), operands.get(1).name(), operands.get(0).relationSpelling(), operands.get(1).relationSpelling(),
                decisions, result.scalar(2), Integer.toString(result.children().size()), "3", "UNCHECKABLE", "MISSING_EVIDENCE", HIERARCHY);
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("A224OrdinaryJoinCases VERIFIER_JAR NEW_OUTPUT_TSV");
        var rows = new ArrayList<>(List.of("root\tsource-sha256\tprofile\tprovenance\tleft\tright\tleft-parser-type\tright-parser-type\tmatrix\tresult-arity\tresult-products\texit\toutcome\tcode\tdetail"));
        var tmp = Files.createTempDirectory("a224-source-joins-");
        try {
            for (var example : CASES) {
                Path certificate = tmp.resolve(example.module() + ".acgncert");
                Path log = tmp.resolve(example.module() + ".log");
                try { rows.add(run(example, Path.of(args[0]), certificate, log)); }
                finally { Files.deleteIfExists(log); Files.deleteIfExists(certificate); }
            }
        } finally { Files.delete(tmp); }
        Files.write(Path.of(args[1]), rows, StandardOpenOption.CREATE_NEW);
        System.out.println("A224 ordinary JOIN source cases passed: " + CASES.size());
    }
}
