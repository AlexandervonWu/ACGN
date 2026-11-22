package org.acgn.cert;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.Expr;
import edu.mit.csail.sdg.ast.ExprCall;
import edu.mit.csail.sdg.ast.ExprUnary;
import edu.mit.csail.sdg.ast.Func;
import edu.mit.csail.sdg.ast.Sig;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.CanDis.theory.StructuralKey;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;

/**
 * External CALL authority for a bounded source fragment. The caller selects a
 * local nullary predicate whose body is SOME over a tree of local functions
 * and primitive signature leaves. The parser and source-to-retained path
 * correspondence for these two fixed wrappers are explicit trust boundaries.
 * No candidate occurrence rows or anchors supply the expected inventory.
 */
public final class RawCallSourceAuthority {
    private record Term(String name, String type, boolean signature, List<Term> arguments) {
        Term { arguments = List.copyOf(arguments); }
    }

    private final String root, sourceHash, moduleName;
    private final Term body;

    private RawCallSourceAuthority(String root, String sourceHash, String moduleName, Term body) {
        this.root = root;
        this.sourceHash = sourceHash;
        this.moduleName = moduleName;
        this.body = body;
    }

    private static void require(boolean ok, String reason) {
        if (!ok) throw new IllegalArgumentException(reason);
    }

    private static String local(String label) {
        require(label.matches("this/[A-Za-z_][A-Za-z0-9_]*"), "unsupported nonlocal declaration");
        return label.substring(5);
    }

    public static RawCallSourceAuthority fromSource(byte[] bytes, String selected) throws Exception {
        require(bytes.length <= 65536, "source exceeds bounded fragment");
        String source = StandardCharsets.UTF_8.newDecoder().decode(ByteBuffer.wrap(bytes)).toString();
        CompModule module = CompUtil.parseEverything_fromString(A4Reporter.NOP, source);
        for (var open : module.getOpens()) {
            require(open.filename.equals("util/integer") && open.pos == null,
                    "unsupported imported source");
        }
        require(module.getAllMacros().size() == 0, "source macros unsupported");
        String name = module.getModuleName();
        require(name.matches("[A-Za-z_][A-Za-z0-9_]*"), "named local module required");
        var matching = module.getAllFunc().makeCopy().stream()
                .filter(f -> (name + "/" + f.label.substring(f.label.lastIndexOf('/') + 1)).equals(selected)).toList();
        require(matching.size() == 1, "missing or ambiguous selected source root");
        Func declaration = matching.get(0);
        require(declaration.isPred && declaration.count() == 0, "nullary predicate root required");
        Expr expression = declaration.getBody().deNOP();
        require(expression instanceof ExprUnary u && u.op == ExprUnary.Op.SOME, "unsupported root body");
        Term body = read(((ExprUnary) expression).sub, module, 0);
        require(!body.signature, "selected body must contain a local CALL");
        return new RawCallSourceAuthority(selected, HexFormat.of().formatHex(
                MessageDigest.getInstance("SHA-256").digest(bytes)), name, body);
    }

    private static String type(Expr value) {
        var alternatives = value.type().fold();
        require(alternatives.size() == 1 && alternatives.get(0).size() == 1, "local unary type required");
        return "Rel(AlloySig:" + local(alternatives.get(0).get(0).label) + ")";
    }

    private static Term read(Expr expression, CompModule module, int depth) {
        require(depth <= 16, "CALL nesting bound");
        Expr e = expression.deNOP();
        if (e instanceof Sig.PrimSig sig && module.getAllSigs().makeCopy().contains(sig)) {
            require(sig.isVariable == null, "mutable signature unsupported");
            return new Term(local(sig.label), type(sig), true, List.of());
        }
        require(e instanceof ExprCall, "unsupported CALL argument");
        ExprCall call = (ExprCall) e;
        Func f = call.fun;
        require(module.getAllFunc().makeCopy().contains(f) && !f.isPred && f.count() == call.args.size(),
                "local function declaration and exact arity required");
        long declarations = module.getAllFunc().makeCopy().stream()
                .filter(other -> other.label.equals(f.label)).count();
        require(declarations == 1, "overloaded function unsupported");
        String resultType = type(e);
        require(resultType.equals(type(f.returnDecl)), "instantiated function result unsupported");
        List<Term> args = new ArrayList<>();
        for (int i = 0; i < f.count(); i++) {
            Term arg = read(call.args.get(i), module, depth + 1);
            require(arg.type.equals(type(f.get(i))), "argument must have the exact declared type");
            args.add(arg);
        }
        return new Term(local(f.label), resultType, false, args);
    }

    public CallOccurrenceCommitment commitment(byte[] encoded) {
        Limits limits = Limits.defaults();
        Bundle bundle = Bundle.parse(Codec.decode(encoded, limits));
        require(bundle.metadata().inputIdentifier().equals(root)
                && bundle.metadata().inputSha256().equals(sourceHash), "different selected source or root");
        KernelModel model = new KernelModel(bundle, limits);
        KernelModel.Term some = model.term(bundle.publication().requireShape("publication", 5, 5).scalar(2));
        require(isApplication(model, some, "ALLOY/SOME", "Bool", 1), "different publication root");
        List<String> keys = new ArrayList<>();
        compare(body, model, argument(model, some, 0), "phase/0/matrix/child/0/child/0", keys);
        String subject = CallOccurrenceCommitment.subjectDigest(bundle.metadata());
        return new CallOccurrenceCommitment(subject, CallOccurrenceCommitment.digest(subject, keys));
    }

    private static boolean isApplication(KernelModel model, KernelModel.Term term,
            String operator, String type, int arity) {
        return term.kind() == KernelModel.TermKind.APP && term.context().slots().isEmpty()
                && model.operator(term.symbol()).semanticIdentity().equals(operator)
                && term.sort().kind() == KernelModel.SortKind.TERM && term.sort().value().equals(type)
                && term.children().size() == arity;
    }

    private static KernelModel.Term argument(KernelModel model, KernelModel.Term parent, int index) {
        var port = model.term(parent.children().get(index));
        require(port.kind() == KernelModel.TermKind.ONE_TERM && port.children().size() == 1
                && port.context().slots().isEmpty(), "ordered closed term port required");
        var invocation = model.term(port.children().get(0));
        require(invocation.kind() == KernelModel.TermKind.INVOKE && invocation.context().slots().isEmpty(),
                "closed source witness invocation required");
        return model.witness(invocation.symbol()).definition();
    }

    private void compare(Term expected, KernelModel model, KernelModel.Term observed,
            String path, List<String> keys) {
        if (expected.signature) {
            require(isApplication(model, observed, "ALLOY/GLOBALBINDING/alloy/signature/" + expected.name,
                    expected.type, 0), "different signature argument");
            return;
        }
        String qualified = moduleName + "/" + expected.name;
        int arity = expected.arguments.size();
        String operator = "ALLOY/CALL/" + qualified + "/" + arity + "/call/expression/DECLARATION";
        require(isApplication(model, observed, operator, expected.type, arity), "different typed CALL endpoint");
        List<StructuralKey> roles = new ArrayList<>();
        for (int i = 0; i < arity; i++) {
            roles.add(StructuralKey.leaf("alloy-call-wire-argument-v1", Integer.toString(i),
                    observed.children().get(i)));
        }
        keys.add(StructuralKey.of("alloy-call-wire-occurrence-v1", List.of(Integer.toString(keys.size()),
                path, expected.name, qualified, "call/expression", Integer.toString(arity), "DECLARATION"),
                List.of(StructuralKey.leaf("alloy-call-wire-source-term-v1", observed.id()),
                        StructuralKey.branch("alloy-call-wire-ordered-arguments-v1", roles))).stableString());
        for (int i = 0; i < arity; i++) {
            compare(expected.arguments.get(i), model, argument(model, observed, i), path + "/child/" + i, keys);
        }
    }

    public static void main(String[] args) throws Exception {
        require(args.length == 3, "usage: RawCallSourceAuthority SOURCE MODULE/PREDICATE BUNDLE");
        var authority = fromSource(Files.readAllBytes(Path.of(args[0])), args[1]);
        var pin = authority.commitment(Files.readAllBytes(Path.of(args[2])));
        System.out.println(pin.assignment());
    }
}
