package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.Expr;
import edu.mit.csail.sdg.ast.ExprBinary;
import edu.mit.csail.sdg.ast.ExprUnary;
import edu.mit.csail.sdg.ast.Sig;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.theory.*;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.Set;
import parser.ast.nodes.ModelUnit;

/** Source-derived census of maximal plain ARROW trees in a selected, closed Alloy predicate. */
public final class RawArrowOccurrenceAuthority {
    public record Leaf(String path, String kind, String owner, String name, List<String> columns) {
        public Leaf { columns = List.copyOf(columns); }

        String operator() {
            return "ALLOY/GLOBALBINDING/" + (kind.equals("signature") ? "alloy/signature/" : "") + name;
        }
    }

    public record Occurrence(String path, List<Leaf> leaves) {
        public Occurrence { leaves = List.copyOf(leaves); }
    }

    private static final String BODY = "phase/0/matrix/child/0";
    private final String root, sourceHash;
    private final boolean inclusion;
    private final List<Occurrence> occurrences;

    private RawArrowOccurrenceAuthority(String root, String sourceHash, boolean inclusion,
            List<Occurrence> occurrences) {
        this.root = root;
        this.sourceHash = sourceHash;
        this.inclusion = inclusion;
        this.occurrences = List.copyOf(occurrences);
    }

    public String root() { return root; }
    public String sourceHash() { return sourceHash; }
    public List<Occurrence> occurrences() { return occurrences; }

    public static byte[] fixtureBytes() {
        return """
                module arrows
                sig A {r,s: set A}
                pred selected { r->s in s->r }
                pred reversed { s->r in r->s }
                """.getBytes(StandardCharsets.UTF_8);
    }

    private static void require(boolean ok, String reason) {
        if (!ok) throw new IllegalArgumentException(reason);
    }

    private static String local(String label) {
        require(label.matches("this/[A-Za-z_][A-Za-z0-9_]*"), "nonlocal name");
        return label.substring(5);
    }

    private static String child(String path, int index) { return path + "/child/" + index; }

    public static RawArrowOccurrenceAuthority parse(byte[] bytes, String selected) throws Exception {
        require(bytes.length <= 65536, "source exceeds bounded fragment");
        bytes = bytes.clone();
        String text = StandardCharsets.UTF_8.newDecoder().decode(ByteBuffer.wrap(bytes)).toString();
        CompModule module = CompUtil.parseEverything_fromString(A4Reporter.NOP, text);
        for (var open : module.getOpens()) {
            require(open.filename.equals("util/integer") && open.pos == null, "external open");
        }
        require(module.getAllMacros().size() == 0, "source macros unsupported");
        String name = module.getModuleName();
        require(name.matches("[A-Za-z_][A-Za-z0-9_]*"), "local named module required");
        String prefix = name + "/";
        require(selected.startsWith(prefix) && selected.substring(prefix.length())
                .matches("[A-Za-z_][A-Za-z0-9_]*"), "missing or ambiguous selected predicate");
        String label = "this/" + selected.substring(prefix.length());
        var predicates = module.getAllFunc().makeCopy().stream().filter(f -> f.label.equals(label)).toList();
        require(predicates.size() == 1, "missing or ambiguous selected predicate");
        var predicate = predicates.get(0);
        require(predicate.isPred && predicate.count() == 0, "nullary predicate required");
        Expr body = predicate.getBody().deNOP();
        List<Expr> operands;
        boolean inclusion = body instanceof ExprBinary b && b.op == ExprBinary.Op.IN;
        if (inclusion) {
            ExprBinary relation = (ExprBinary) body;
            operands = List.of(relation.left, relation.right);
        } else {
            require(body instanceof ExprUnary u && u.op == ExprUnary.Op.SOME, "unsupported predicate body");
            operands = List.of(((ExprUnary) body).sub);
        }
        List<Occurrence> rows = new ArrayList<>();
        for (int i = 0; i < operands.size(); i++) {
            Expr operand = operands.get(i).deNOP();
            require(operand instanceof ExprBinary b && b.op == ExprBinary.Op.ARROW, "plain ARROW required");
            String path = child(BODY, i);
            List<Leaf> leaves = new ArrayList<>();
            collect(module, operand, path, leaves, 0);
            rows.add(new Occurrence(path, leaves));
        }
        return new RawArrowOccurrenceAuthority(selected, digest(bytes), inclusion, rows);
    }

    private static List<String> columns(CompModule module, Expr term) {
        var products = term.type().fold();
        require(products.size() == 1 && !products.get(0).isEmpty(), "single resolved product required");
        return products.get(0).stream().map(sig -> {
            require(module.getAllSigs().makeCopy().contains(sig) && sig.isVariable == null,
                    "static local column required");
            return local(sig.label);
        }).toList();
    }

    private static void collect(CompModule module, Expr source, String path, List<Leaf> out, int depth) {
        require(depth <= 64, "ARROW depth exceeds bounded fragment");
        Expr term = source.deNOP();
        if (term instanceof ExprBinary b && b.op == ExprBinary.Op.ARROW) {
            collect(module, b.left, child(path, 0), out, depth + 1);
            collect(module, b.right, child(path, 1), out, depth + 1);
            return;
        }
        List<String> types = columns(module, term);
        if (term instanceof Sig.PrimSig sig) {
            String name = local(sig.label);
            require(module.getAllSigs().makeCopy().contains(sig) && sig.isVariable == null
                    && types.equals(List.of(name)), "local primitive signature required");
            out.add(new Leaf(path, "signature", module.getModuleName(), name, types));
            return;
        }
        require(term instanceof Sig.Field, "non-declaration ARROW leaf");
        Sig.Field field = (Sig.Field) term;
        require(field.sig instanceof Sig.PrimSig && module.getAllSigs().makeCopy().contains(field.sig)
                && field.sig.isVariable == null && field.isVariable == null && !field.defined
                && field.sig.getFields().makeCopy().contains(field), "static local field required");
        long matches = module.getAllSigs().makeCopy().stream()
                .flatMap(sig -> sig.getFields().makeCopy().stream())
                .filter(f -> f.label.equals(field.label)).count();
        String owner = local(field.sig.label);
        require(matches == 1 && types.get(0).equals(owner), "ambiguous field owner");
        out.add(new Leaf(path, "field", owner, field.label, types));
    }

    private static String digest(byte[] bytes) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
    }

    /** The producer independently parses its own bytes; both its actual selection and
     * its normal forms are captured at that boundary. The ordinary in-memory result
     * alone has no byte digest or qualified selected-declaration metadata. */
    public static final class Produced {
        private final String root, sourceHash;
        private final Canonical.Prepared prepared;
        private final TheoryAlloyAdapter.Result result;

        private Produced(String root, String sourceHash, Canonical.Prepared prepared) {
            this.root = root;
            this.sourceHash = sourceHash;
            this.prepared = prepared;
            this.result = TheoryAlloyAdapter.adapt(prepared.normalizedForms(), prepared.semanticProfile());
        }

        public Canonical.Prepared prepared() { return prepared; }
        public TheoryAlloyAdapter.Result result() { return result; }

        public TheoryAlloyAdapter.Result forVerification(CertificateProvenance provenance) {
            require(root.equals(provenance.inputIdentifier()) && sourceHash.equals(provenance.inputSha256()),
                    "foreign export provenance");
            return TheoryAlloyAdapter.adaptForVerification(prepared.normalizedForms(),
                    prepared.semanticProfile(), new RecordingCertificateTraceSink(), provenance);
        }
    }

    public static Produced produce(byte[] bytes, String selected) throws Exception {
        bytes = bytes.clone();
        String source = StandardCharsets.UTF_8.newDecoder().decode(ByteBuffer.wrap(bytes)).toString();
        CompModule module = CompUtil.parseEverything_fromString(A4Reporter.NOP, source);
        String prefix = module.getModuleName() + "/";
        require(selected.startsWith(prefix), "producer selected another module");
        String name = selected.substring(prefix.length());
        require(name.matches("[A-Za-z_][A-Za-z0-9_]*"), "producer predicate identity required");
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of(name), module);
        visitor.visit(new ModelUnit(null, module), null);
        var graph = visitor.getForest().get(visitor.getForestId(name));
        return new Produced(selected, digest(bytes), Canonical.prepare(graph));
    }

    public void verify(Produced candidate) {
        var artifact = candidate.result.semanticArtifact();
        verifyInventories(candidate, artifact.dependentChainConstructions().stream()
                .map(c -> c.leftEndpoint().structuralKey()).toList(),
                artifact.constructionSources().dependentChainSources());
    }

    /** Structural comparison for callers holding the actual proof-retaining result.
     * The caller must separately bind sourceHash() and root() to its export subject. */
    public void verifyRetained(Canonical.Prepared prepared, TheoryAlloyAdapter.Result result) {
        var artifact = result.semanticArtifact();
        verifyRetained(prepared, result, artifact.dependentChainConstructions().stream()
                .map(c -> c.leftEndpoint().structuralKey()).toList(),
                artifact.constructionSources().dependentChainSources());
    }

    /** The projections are injectable for regression controls. The source-side
     * matching and its expected multiplicities are recomputed on every invocation. */
    void verifyInventories(Produced candidate, List<StructuralKey> constructions,
            Map<StructuralKey, Integer> ledger) {
        require(root.equals(candidate.root) && sourceHash.equals(candidate.sourceHash),
                "different source bytes or selected predicate");
        verifyRetained(candidate.prepared, candidate.result, constructions, ledger);
    }

    /** Observe both the retained construction and its path-indexed certificate, then compare
     * their exact endpoint multiplicities to the producer ledger. Expected paths, association
     * and resolved declarations above never consult the builder, its ledger or its bindings. */
    private void verifyRetained(Canonical.Prepared prepared, TheoryAlloyAdapter.Result result,
            List<StructuralKey> constructions, Map<StructuralKey, Integer> ledger) {
        var forms = prepared.normalizedForms();
        result.requireRepairProjectionSources(forms);
        require(forms.size() == 1, "expected one retained phase");
        EGraphNode matrix = forms.get(0).getCertificationMatrixEGraph();
        require(matrix.getOpcode() == Opcode.PREDICATE && matrix.getChildren().size() == 1
                && matrix.getSourceName().equals(root.substring(root.indexOf('/') + 1)),
                "different selected predicate");
        EGraphNode body = matrix.getChildren().get(0);
        require(body.getOpcode() == (inclusion ? Opcode.IN : Opcode.SOME)
                && body.getChildren().size() == occurrences.size(), "different retained predicate body");
        var artifact = result.semanticArtifact();
        record Bound(EGraphNode repair, TheoryAlloyAdapter.DependentChainSourceBinding binding) {}
        Map<String, Bound> bindings = new HashMap<>();
        result.dependentChainSourceBindings().forEach((repair, binding) -> {
            binding.requireMatches(repair);
            require(bindings.put(binding.sourceOccurrencePath(), new Bound(repair, binding)) == null, "duplicate bound path");
        });

        List<StructuralKey> boundEndpoints = new ArrayList<>();
        for (int i = 0; i < occurrences.size(); i++) {
            Occurrence expected = occurrences.get(i);
            var bound = bindings.remove(expected.path());
            require(bound != null, "missing source ARROW binding");
            var binding = bound.binding();
            var certificate = binding.certificate();
            var retained = body.getChildren().get(i);
            require(retained.getSourceOccurrenceLineage() == bound.repair().getSourceOccurrenceLineage(),
                    "foreign retained occurrence lineage");
            var content = StructuralKey.of("alloy-dependent-chain-source-occurrence-v1",
                    List.of(expected.path()), List.of(
                    StructuralKey.branch("alloy-dependent-chain-typed-source-v1",
                            List.of(certificate.source().structuralKey())),
                    StructuralKey.leaf("alloy-dependent-chain-source-content-v1",
                            retained.dependentChainSourceContentCommitment())));
            require(content.equals(certificate.sourceOccurrenceCommitment()), "different retained commitment");
            List<ObservedLeaf> observed = new ArrayList<>();
            compareTrees(expected.path(), retained, certificate.source(), artifact, observed);
            var wanted = expected.leaves().stream().map(leaf ->
                    new ObservedLeaf(leaf.path(), leaf.name(), leaf.operator(), graphType(leaf.columns()))).toList();
            require(wanted.equals(observed), "different ordered typed ARROW leaves");
            require(certificate.operandTypes().equals(wanted.stream().map(ObservedLeaf::type).toList()),
                    "different certificate operand types");
            boundEndpoints.add(certificate.leftEndpoint().structuralKey());
        }
        require(bindings.isEmpty(), "extra bound ARROW path");
        Map<StructuralKey, Integer> expected = counts(boundEndpoints);
        require(expected.equals(counts(constructions)), "different retained construction multiset");
        require(expected.equals(ledger), "different construction ledger multiset");
    }

    private static Map<StructuralKey, Integer> counts(List<StructuralKey> values) {
        Map<StructuralKey, Integer> result = new HashMap<>();
        for (StructuralKey value : values) result.merge(value, 1, Math::addExact);
        return result;
    }

    private record ObservedLeaf(String path, String name, String operator, GraphType type) {}

    private static GraphType graphType(List<String> columns) {
        return GraphType.relation(columns.stream().map(c -> GraphType.constructor("AlloySig:" + c)).toList());
    }

    private static void compareTrees(String path, EGraphNode retained, DependentChainInput source,
            CertifiedSemanticArtifact artifact, List<ObservedLeaf> observed) {
        if (source instanceof DependentChainApplication app) {
            require(app.kind() == DependentChainKind.ARROW && retained.getOpcode() == Opcode.ARROW
                    && retained.getChildren().size() == 2, "different ARROW association");
            compareTrees(child(path, 0), retained.getChildren().get(0), app.left(), artifact, observed);
            compareTrees(child(path, 1), retained.getChildren().get(1), app.right(), artifact, observed);
            return;
        }
        var leaf = (DependentChainLeaf) source;
        require(retained.getOpcode() == Opcode.GLOBALBINDING && retained.getChildren().isEmpty()
                && leaf.port().leaf() instanceof InvocationPortLeaf, "different retained leaf");
        var invocation = ((InvocationPortLeaf) leaf.port().leaf()).invocation();
        var record = artifact.classes().get(invocation.eclass().id());
        require(record != null && record.shapeWitnesses().size() == 1, "ambiguous leaf witness");
        var node = record.shapeWitnesses().firstKey().node();
        require(node.ports().isEmpty() && node.outputType().equals(leaf.outputType())
                && leaf.outputType().equals(invocation.outputType())
                && leaf.outputType().equals(AlloyTypeBridge.graphType(retained.getExactAlloyType())),
                "different retained leaf type");
        observed.add(new ObservedLeaf(path, retained.getSourceName(), node.operator().operator(), leaf.outputType()));
    }
}
