package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.CanDis.metric.RepairView;
import is.fivefivefive.CanDis.theory.GraphType;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Source-linked sequence checker for two distinct, local binary fields under
 * an unordered Boolean AND. No metric solver or native diagnostic is used to
 * enumerate edits or assign their charges. The sealed views supply occurrence
 * addresses; each address is reconciled against an independently parsed operand.
 */
public final class BoundedAssignmentMinimum {
    public record Operand(String op, String name, GraphType type) {}
    record Owner(String sourceHash, String predicate, String observation, List<Operand> operands) {
        public Owner { operands = List.copyOf(operands); }
        JSONObject binding() {
            return new JSONObject().put("sourceSHA256", sourceHash)
                    .put("predicate", predicate).put("observation", observation);
        }
    }
    record Mapping(int first, int second) {}
    record Candidate(Mapping mapping, int cost, JSONArray actions) {}
    private final Owner left, right;
    private final List<Candidate> candidates;

    BoundedAssignmentMinimum(Owner left, Owner right) {
        this.left = left;
        this.right = right;
        var found = new ArrayList<Candidate>();
        // -1 denotes deletion. Any unused target is inserted exactly once.
        for (int a = -1; a < 2; a++) for (int b = -1; b < 2; b++)
            if (a == -1 || a != b) found.add(candidate(new Mapping(a,b)));
        candidates = List.copyOf(found);
    }

    static void require(boolean truth, String reason) {
        if (!truth) throw new IllegalArgumentException(reason);
    }

    static String sha(byte[] bytes) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
    }

    private static String local(String name) {
        require(name.startsWith("this/") && name.indexOf('/', 5) == -1, "NONLOCAL_DECLARATION");
        return name.substring(5);
    }

    private static List<Operand> rawOperands(CompModule module, String predicate) {
        for (var open : module.getOpens())
            require("util/integer".equals(open.filename) && open.pos == null, "UNSUPPORTED_IMPORT");
        require(module.getAllMacros().size() == 0, "UNSUPPORTED_MACRO");
        var funcs = module.getAllFunc().makeCopy().stream()
                .filter(f -> f.label.equals("this/" + predicate)).toList();
        require(funcs.size() == 1 && funcs.get(0).isPred && funcs.get(0).count() == 0, "ROOT");
        var body = funcs.get(0).getBody().deNOP();
        require(body instanceof ExprList e && e.op == ExprList.Op.AND && e.args.size() == 2, "AND_FRAGMENT");
        var result = new ArrayList<Operand>();
        for (Expr expr : ((ExprList) body).args) {
            Expr bare = expr.deNOP();
            require(bare instanceof ExprUnary u && (u.op == ExprUnary.Op.NO || u.op == ExprUnary.Op.SOME),
                    "QUANTIFIER_FRAGMENT");
            var unary = (ExprUnary) bare;
            require(unary.sub.deNOP() instanceof Sig.Field, "FIELD_FRAGMENT");
            var field = (Sig.Field) unary.sub.deNOP();
            require(field.sig instanceof Sig.PrimSig && module.getAllSigs().makeCopy().contains(field.sig)
                    && field.sig.isVariable == null && field.isVariable == null && !field.defined
                    && field.sig.getFields().makeCopy().contains(field) && field.type().fold().size() == 1,
                    "LOCAL_BINARY_FIELD");
            long declarations = module.getAllSigs().makeCopy().stream()
                    .flatMap(sig -> sig.getFields().makeCopy().stream()).filter(f -> f.label.equals(field.label)).count();
            require(declarations == 1, "AMBIGUOUS_FIELD");
            var columns = field.type().fold().get(0);
            require(columns.size() == 2 && columns.get(0) == field.sig && columns.get(1) == field.sig,
                    "LOCAL_BINARY_FIELD");
            var type = GraphType.constructor("AlloySig:" + local(field.sig.label));
            result.add(new Operand(unary.op == ExprUnary.Op.NO ? "NO" : "SOME",
                    field.label, GraphType.relation(type,type)));
        }
        require(!result.get(0).name().equals(result.get(1).name()) &&
                result.get(0).type().equals(result.get(1).type()), "TWO_DISTINCT_SAME_TYPE_FIELDS");
        return result;
    }

    private static void node(RepairView.Node n, String op, GraphType ty, int arity, boolean unordered) {
        require(n.operator().equals(op) && ty.equals(n.observationType()) && n.children().size() == arity
                && n.certifiedAlternatives().isEmpty() && n.orderInsensitive() == unordered, "PROJECTION_SHAPE");
    }

    static Owner owner(byte[] raw, String predicate, CanonicalAlloyPipeline.Prepared prepared) throws Exception {
        var text = StandardCharsets.UTF_8.newDecoder().decode(ByteBuffer.wrap(raw)).toString();
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, text);
        String selected = module.getModuleName() + "/" + predicate;
        String digest = sha(raw);
        require(prepared.retainsCertificateExportSession(), "MISSING_EXPORT_OWNER");
        var provenance = prepared.certificateExportSession().provenance();
        require(selected.equals(provenance.inputIdentifier()) && digest.equals(provenance.inputSha256()), "FOREIGN_EXPORT_OWNER");
        var source = rawOperands(module,predicate);
        var view = prepared.repairView();
        require(view.phases().size() == 1 && view.phases().get(0).quantifiers().isEmpty()
                && view.phases().get(0).bindings().isEmpty(), "EXTRA_PHASE_OR_BINDER");
        var root = view.phases().get(0).matrix();
        node(root,"PREDICATE",GraphType.BOOL,1,false);
        var and = root.children().get(0);
        node(and,"AND",GraphType.BOOL,2,true);
        String boolPayload = "identity=;type=" + GraphType.BOOL;
        require(and.containerKind().name().equals("SET") && root.containerKind().name().equals("ONE")
                && root.payload() == null && and.payload() == null
                && boolPayload.equals(root.semanticPayload()) && boolPayload.equals(and.semanticPayload()),
                "CERTIFIED_SET_REQUIRED");
        var remaining = new ArrayList<>(source);
        var ordered = new ArrayList<Operand>();
        for (var child : and.children()) {
            require(!child.children().isEmpty(), "UNOWNED_OPERAND");
            var field = child.children().get(0);
            var operand = remaining.stream().filter(o -> o.op().equals(child.operator())
                    && o.name().equals(field.payload()) && o.type().equals(field.observationType()))
                    .findFirst().orElseThrow(() -> new IllegalArgumentException("UNOWNED_OPERAND"));
            node(child,operand.op(),GraphType.BOOL,1,false);
            node(field,"GLOBALBINDING",operand.type(),0,false);
            require(child.payload() == null && boolPayload.equals(child.semanticPayload())
                    && child.containerKind().name().equals("ONE") && field.containerKind().name().equals("SEQUENCE")
                    && field.semanticPayload().equals("identity=" + operand.name() + ";type=" + operand.type())
                    && child.size() == 2 && field.size() == 1, "PROJECTION_SHAPE");
            remaining.remove(operand);
            ordered.add(operand);
        }
        require(remaining.isEmpty() && view.producerObservationDigest().equals(prepared.canonicalObservation().digest()),
                "INCOMPLETE_OWNER");
        return new Owner(digest,selected,view.producerObservationDigest(),ordered);
    }

    private static JSONObject action(String kind, String a, String b, int cost) {
        return new JSONObject().put("stage","matrix").put("kind",kind).put("cost",cost)
                .put("source", a == null ? JSONObject.NULL : a).put("target", b == null ? JSONObject.NULL : b);
    }

    private Candidate candidate(Mapping map) {
        var actions = new JSONArray().put(new JSONObject().put("stage","declarationPermutation")
                .put("cost",0).put("source",new JSONArray()).put("target",new JSONArray()));
        actions.put(action("node","$","$",0)).put(action("node","$/0","$/0",0));
        int sum = 0;
        int[] targets = {map.first(),map.second()};
        for (int i=0;i<2;i++) {
            int j = targets[i];
            String a = "$/0/"+i;
            if (j < 0) {
                actions.put(action("delete",a,null,2)); sum += 2;
            } else {
                String b = "$/0/"+j;
                var x = left.operands().get(i); var y = right.operands().get(j);
                int op = x.op().equals(y.op()) ? 0 : 1;
                int field = x.name().equals(y.name()) && x.type().equals(y.type()) ? 0 : 1;
                actions.put(action("node",a,b,op)).put(action("node",a+"/0",b+"/0",field));
                sum += op + field;
            }
        }
        for (int j=0;j<2;j++) if (j!=targets[0] && j!=targets[1]) {
            actions.put(action("insert",null,"$/0/"+j,2)); sum += 2;
        }
        return new Candidate(map,sum,actions);
    }

    /** Build a source-bound checker from the two actual production projections. */
    public static BoundedAssignmentMinimum fromSource(byte[] raw, String sourcePredicate,
            CanonicalAlloyPipeline.Prepared sourceProjection, String targetPredicate,
            CanonicalAlloyPipeline.Prepared targetProjection) throws Exception {
        raw = raw.clone();
        return new BoundedAssignmentMinimum(owner(raw,sourcePredicate,sourceProjection),
                owner(raw,targetPredicate,targetProjection));
    }

    public int minimum() { return candidates.stream().mapToInt(Candidate::cost).min().orElseThrow(); }
    List<Integer> scores() { return candidates.stream().map(Candidate::cost).sorted().toList(); }
    JSONArray crossedExample() {
        return new JSONArray(candidate(new Mapping(1,0)).actions().toString());
    }
    JSONArray directExample() {
        return new JSONArray(candidate(new Mapping(0,1)).actions().toString());
    }

    public JSONObject bind(JSONArray actions) {
        return new JSONObject().put("source",left.binding()).put("target",right.binding()).put("actions",actions);
    }

    /** Checks untrusted input, including every zero-cost owner and subtree charge. */
    public int verify(JSONObject receipt) {
        require(receipt.keySet().equals(Set.of("source","target","actions")) && left.binding().similar(receipt.opt("source"))
                && right.binding().similar(receipt.opt("target")), "FOREIGN_OWNER");
        var sequence = receipt.optJSONArray("actions");
        require(sequence != null, "INCOMPLETE_OR_FOREIGN_ACTION");
        for (var possible : candidates) if (possible.actions().similar(sequence)) {
            require(possible.cost() == minimum(), "NONMINIMUM_ALIGNMENT");
            return possible.cost();
        }
        throw new IllegalArgumentException("INCOMPLETE_OR_FOREIGN_ACTION");
    }
}
