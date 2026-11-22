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

/** Ordinary Alloy dispatch plus a repeat read of the real per-builder memo. */
public final class A216SourceCases {
    private static final String ROOT = "phase/0/matrix/child/0/child/0";
    private static final String PREAMBLE = "module leaves\nabstract sig P {}\nsig A,B extends P {}\nsig Q {}\n"
            + "sig X { f,g,h: set P, fa: set A, fb: set B }\n";
    private record Input(CompModule module, Canonical.Prepared compiled, ExprBinary expression) {}
    private static final List<String> rows = new ArrayList<>(List.of("case\tentry\tobservation\tdetail"));
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
        var matrix = in.compiled().normalizedForms().get(0).getCertificationMatrixEGraph();
        var some = children(matrix).get(0);
        require(some.getOpcode() == EGraphNode.Opcode.SOME, "normalized root");
        return children(some).get(0);
    }
    private static void row(String name,String entry,String verdict,String detail) {
        rows.add(String.join("\t",name,entry,verdict,detail));
    }

    private static List<TypedENode> nodes(CertifiedSemanticArtifact a, OnePort p) {
        require(p.leaf() instanceof InvocationPortLeaf, "expected operator target");
        var inv = (InvocationPortLeaf) p.leaf();
        return a.classes().get(inv.invocation().eclass().id()).shapeWitnesses().keySet()
                .stream().map(s -> s.node()).toList();
    }

    private static TypedENode selectFixed(CertifiedSemanticArtifact a, String op) {
        var some = a.classes().values().stream().flatMap(c -> c.shapeWitnesses().keySet().stream())
                .map(s -> s.node()).filter(n -> n.operator().operator().equals("ALLOY/SOME")).toList();
        require(some.size() == 1, "ambiguous SOME root " + some.size());
        var candidates = nodes(a, (OnePort) some.get(0).ports().get(0)).stream()
                .filter(n -> n.operator().operator().equals("ALLOY/"+op)).toList();
        require(candidates.size() == 1, "plain binary result " + op);
        return candidates.get(0);
    }

    private static List<String> heads(CertifiedSemanticArtifact a, OnePort p) {
        return nodes(a,p).stream().map(n -> n.operator().operator()).distinct().sorted().toList();
    }

    private static GraphType parserType(Input in,Expr e) {
        return AlloyTypeBridge.graphType(ExactAlloyType.fromParser(e.type(), in.module()));
    }

    private static List<String> intTerms(CertifiedSemanticArtifact a, OnePort p) {
        var result = new ArrayList<String>();
        for (TypedENode n : nodes(a,p)) {
            require(n.operator().operator().equals("ALLOY/PLUS") && n.ports().size()==1, "expected PLUS");
            PortValue port = n.ports().get(0);
            require(port instanceof SetPort, "expected the real set port");
            for (PortValue child : ((SetPort) port).elements()) {
                for (TypedENode coercion : nodes(a,(OnePort)child)) {
                    require(coercion.operator().operator().startsWith("ALLOY/RELATIONAL-COERCION/")
                            && coercion.ports().size() == 1, "unexpected PLUS coercion");
                    result.addAll(heads(a,(OnePort)coercion.ports().get(0)).stream()
                            .filter(x -> x.startsWith("ALLOY/CONSTANT/")).toList());
                }
            }
        }
        return result.stream().distinct().sorted().toList();
    }

    private static int memoSize(Object owner,String field) throws Exception {
        var f = owner.getClass().getDeclaredField(field);
        f.setAccessible(true);
        Object x = f.get(owner);
        if (x instanceof Map<?,?> m) return m.size();
        return ((Collection<?>) x).size();
    }

    private static List<Integer> sizes(Object owner) throws Exception {
        return List.of(memoSize(owner,"memo"), memoSize(owner,"dependentChainConstructions"),
            memoSize(owner,"dependentChainSourceBindings"), memoSize(owner,"guardedJoinConstructions"));
    }

    private static void cached(Input in,String name) throws Exception {
        var c = Class.forName("is.fivefivefive.CanDis.theory.TheoryAlloyAdapter$Builder");
        var ctor = c.getDeclaredConstructor(List.class, SemanticProfile.class, CertificateTraceSink.class,
            CertificateProvenance.class);
        ctor.setAccessible(true);
        var b = ctor.newInstance(in.compiled().normalizedForms(),in.compiled().semanticProfile(),
                NoOpCertificateTraceSink.instance(),null);
        var build = c.getDeclaredMethod("buildOperand",EGraphNode.class,Map.class,TypedSlotContext.class,Map.class,Map.class);
        build.setAccessible(true);
        var site = outer(in);
        Object[] args = {site,Map.of(),TypedSlotContext.empty(),Map.of(),Map.of()};
        require(memoSize(b,"memo") == 0,"fresh builder memo");
        var first = (OnePort) build.invoke(b,args);
        var before = sizes(b);
        var second = (OnePort) build.invoke(b,args);
        require(first.equals(second) && before.get(0)>0 && before.equals(sizes(b)),"memo repeat changed result/evidence");
        row(name+"-warm","per-builder buildOperand","same-invocation","memo/dependent/bindings/guarded="+before);
    }

    private static void fixed(String name,String expr,String lh,String rh,String[] literals,boolean checkMemo) throws Exception {
        var in = parse(expr);
        var res = adapt(in);
        var a = res.semanticArtifact();
        String op = in.expression().op == ExprBinary.Op.JOIN ? "JOIN" : "ARROW";
        require(in.expression().op == ExprBinary.Op.JOIN || in.expression().op == ExprBinary.Op.ARROW,"chain syntax");
        var n = selectFixed(a,op);
        require(n.ports().size()==2 && n.ports().stream().allMatch(OnePort.class::isInstance),"exact binary");
        require(n.operator().containerLaws().isEmpty() && !n.operator().usesFlatConstruction(),"fixed root law");
        require(res.dependentChainSourceBindings().values().stream().noneMatch(v -> v.sourceOccurrencePath().equals(ROOT)),
                "unexpected outer dependent binding");
        require(a.guardedJoinConstructions().stream().noneMatch(v -> v.sourceOccurrencePath().equals(ROOT)),
                "unexpected outer guarded authority");
        var l = (OnePort)n.ports().get(0);
        var r = (OnePort)n.ports().get(1);
        require(n.operator().portSchemas().equals(List.of(l.schema(),r.schema())),"schema order");
        require(l.leaf().type().equals(parserType(in,in.expression().left)) &&
                r.leaf().type().equals(parserType(in,in.expression().right)), "raw ordered child carrier " + name);
        require(heads(a,l).contains(lh) && heads(a,r).contains(rh), "ordered child heads "+heads(a,l)+" / "+heads(a,r));
        String details = lh+" | "+rh+"; dependent-children="+
            res.dependentChainSourceBindings().values().stream().map(v->v.sourceOccurrencePath()).distinct().count();
        var view=is.fivefivefive.CanDis.metric.RepairProjection.project(res,in.compiled().normalizedForms());
        var body=view.phases().get(0).matrix();
        require(body.operator().equals("PREDICATE") && body.children().size()==1, "unexpected phase matrix");
        var some=body.children().get(0);
        require(some.operator().equals("SOME") && some.children().size()==1,"qualified repair parent");
        var repaired=some.children().get(0);
        require(repaired.operator().equals(op) && !repaired.orderInsensitive() && repaired.children().size()==2
                && repaired.containerKind()==is.fivefivefive.CanDis.metric.RepairView.ContainerKind.SEQUENCE,
                "unlicensed repair root lost its original arity/order");
        var lc=repaired.children().get(0);
        var rc=repaired.children().get(1);
        require(lc.operator().equals(children(outer(in)).get(0).getOpcode().name())
                && rc.operator().equals(children(outer(in)).get(1).getOpcode().name()), "projected child order "+name);
        details += "; projected="+lc.operator()+","+rc.operator();
        if (name.equals("join-ordered-typed-empty")) {
            require(Integer.valueOf(1).equals(AlloyTypeBridge.emptyRelationArity(n.operator().outputType())),
                "fixed JOIN output must be unary empty");
            details += "; empty-arity=1";
        }
        if(literals != null) {
            require(l.leaf().type().equals(r.leaf().type()),"same-type challenge");
            var il=intTerms(a,l);
            var ir=intTerms(a,r);
            require(il.equals(List.of("ALLOY/CONSTANT/"+literals[0])) && ir.equals(List.of("ALLOY/CONSTANT/"+literals[1])),
                    "integer occurrence order " + il+" / "+ir);
            require(lc.children().stream().filter(x->x.operator().equals("CONSTANT")).map(x->x.payload()).toList().equals(List.of(literals[0])) &&
                    rc.children().stream().filter(x->x.operator().equals("CONSTANT")).map(x->x.payload()).toList().equals(List.of(literals[1])),
                    "projection changed equal-typed occurrence order");
            details += "; literals="+literals[0]+","+literals[1];
        }
        row(name,"ordinary prepared adapter","fixed-"+op,details);
        if(checkMemo) cached(in,name);
    }

    private static void licensed(String name,String expr,boolean guarded) throws Exception {
        var in=parse(expr);
        var res=adapt(in);
        var gs=res.semanticArtifact().guardedJoinConstructions().stream().filter(v->v.sourceOccurrencePath().equals(ROOT)).toList();
        var ds=res.dependentChainSourceBindings().values().stream().filter(v->v.sourceOccurrencePath().equals(ROOT)).toList();
        require(guarded ? gs.size()==1 && ds.isEmpty() : gs.isEmpty() && !ds.isEmpty(),"incorrect root license "+name);
        if(guarded) gs.get(0).requireOriginalMatches(outer(in),ROOT);
        String kind=guarded ? "GUARDED-JOIN" : ds.get(0).certificate().source().kind().name();
        row(name,"ordinary prepared adapter",kind,ROOT);
        cached(in,name);
    }

    private static void hard(String name,String expr) throws Exception {
        var source=parse(expr);
        try { adapt(source); }
        catch (IllegalStateException ex) {
            require(ex.getMessage().startsWith("A concrete set operator disagrees with its independently derived dependent type DAG"),
                "unexpected rejection "+ex);
            row(name,"ordinary prepared adapter","hard disagreement","no returned artifact");return;
        }
        throw new AssertionError("expected source disagreement "+name);
    }

    private static void binder() throws Exception {
        String src="module historical\nsig S {r,q: set S}\npred binderAll { all x:S | x in x.*r }\nrun binderAll for 4\n";
        var parsed=CompUtil.parseEverything_fromString(A4Reporter.NOP,src);
        var profile=AlloySemanticProfileFactory.fromExactlyOne(parsed,parsed.getAllCommands(),new A4Options());
        var visitor=new MASGVisitor(new GlobalVariables(),Set.of("binderAll"),parsed);
        visitor.visit(new ModelUnit(null,parsed),null);
        var prepared=Canonical.prepare(visitor.getForest().get(visitor.getForestId("binderAll")),profile);
        var res=TheoryAlloyAdapter.adapt(prepared.normalizedForms(),prepared.semanticProfile());
        var ds=res.dependentChainSourceBindings().values().stream().map(x -> x.sourceOccurrencePath()+"/"+x.certificate().source().kind()).distinct().sorted().toList();
        long fixed=res.semanticArtifact().classes().values().stream().flatMap(c->c.shapeWitnesses().keySet().stream())
                .filter(x->x.node().operator().operator().equals("ALLOY/JOIN")).count();
        require(ds.size()==1 && ds.get(0).endsWith("/JOIN") && fixed==0,"historical closure "+ds+" / fixed="+fixed);
        var application=res.dependentChainSourceBindings().values().iterator().next().certificate().source();
        require(application.leafInputs().size()==2,"historical JOIN arity");
        var proofs=application.leafInputs().stream().map(x->x.typeRule()+"@"+x.port().leaf().type()).toList();
        require(proofs.equals(List.of("PRIMITIVE_SET_SINGLETON@AlloyCarrier(S)",
                "EXACT_RELATION@Rel(AlloySig:univ,AlloySig:univ)")), "closure leaf rules "+proofs);
        var selected=parsed.getAllFunc().makeCopy().stream().filter(f->f.label.equals("this/binderAll")).findFirst().orElseThrow();
        var member=(ExprBinary)((ExprQt)selected.getBody().deNOP()).sub.deNOP();
        var join=(ExprBinary)member.right.deNOP();
        require(member.op==ExprBinary.Op.IN && join.op==ExprBinary.Op.JOIN, "original binder expression");
        var raw=AlloyTypeBridge.dependentTypeDag(ExactAlloyType.fromParser(join.type(),parsed));
        require(raw.relationType().equals(application.outputTypeDag().relationType()), "historical JOIN result");
        row("exact-historical-binder","ordinary parsed binderAll","dependent-JOIN",ds.get(0)+"; leaves="+proofs+"; result="+raw.relationType()+"; boundary="+application.boundaryCorrespondence().rule());
    }

    public static void main(String[] args) throws Exception {
        if(args.length!=1) throw new IllegalArgumentException("A216SourceCases OUTPUT");
        String plus="ALLOY/PLUS",q="ALLOY/GLOBALBINDING/alloy/signature/Q",a="ALLOY/GLOBALBINDING/alloy/signature/A";
        String depJ="ALLOY/DEPENDENT-CHAIN/JOIN",depA="ALLOY/DEPENDENT-CHAIN/ARROW";
        fixed("left-union","(A+1)->Q",plus,q,null,true);
        fixed("right-union","Q->(A+1)",q,plus,null,false);
        fixed("equal-type-left-first","(A+1)->(A+2)",plus,plus,new String[]{"1","2"},false);
        fixed("equal-type-right-first","(A+2)->(A+1)",plus,plus,new String[]{"2","1"},false);
        fixed("equal-type-repeated","(A+1)->(A+1)",plus,plus,new String[]{"1","1"},false);
        fixed("nested-arrow-left","((A+1)->Q)->A","ALLOY/ARROW",a,null,false);
        fixed("nested-arrow-right","Q->((A+1)->Q)",q,"ALLOY/ARROW",null,false);
        fixed("join-ordered-dependent-children","((A->A)+(B->B)).A.(A->Q)",depJ,depA,null,true);
        fixed("join-ordered-typed-empty","(Q->A).A.((A->A)+(B->B))",depJ,plus,null,false);
        licensed("separate-guard","f.A.(P->Q)",true);
        licensed("licensed-arrow","A->Q",false);
        licensed("licensed-join","f.A",false);
        hard("hard-arrow","((A+B)&P)->Q");
        hard("hard-join","(((A+B)&P)->Q).Q");
        binder();
        for(var op : List.of(EGraphNode.Opcode.JOIN,EGraphNode.Opcode.ARROW)) {
            var policy = is.fivefivefive.CanDis.core.AlloyOperatorPolicy.defaultForShape(op,2,false).arityPolicy();
            for(int n : List.of(0,1,2,3)) {
                boolean accepted=true;
                try {policy.requireAdmitted(n,op.name());} catch(IllegalStateException ex){accepted=false;}
                require(accepted==(n==2),"shape policy");
                row(op+"-arity-"+n,"production arity guard",accepted ? "admitted":"refused","children="+n);
            }
        }
        Files.write(Path.of(args[0]),rows,StandardOpenOption.CREATE_NEW);
        System.out.println("A216 source observations passed: "+(rows.size()-1));
    }
}
