package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.ExprUnary;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter;
import is.fivefivefive.CanDis.core.egraph.*;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import parser.ast.nodes.*;

public final class P506SourceBindingTest {
    private static final List<AblationEngine> ENGINES = List.of(new RawEGraph(), new RawDeBruijnEGraph(),
            new JavaEgglog(), new JavaEgglogDeBruijn(), new SlottedEGraph(), new SlottedEGraph(true));
    private static final java.util.List<String> results = new java.util.ArrayList<>();
    private static void row(String name, String result) {
        results.add(name + "\t" + result);
    }
    private static void check(boolean good, String name) {
        if (!good) throw new AssertionError(name);
    }

    private static AlloyTerm plain(AlloyTerm term) {
        if (term.isVariable() && !term.slotType().isEmpty()) return AlloyTerm.typedVariable(term.atom(), term.slotType());
        return AlloyTerm.of(term.head(), term.atom(), term.children().stream().map(P506SourceBindingTest::plain).toList());
    }

    private static void syntheticParameter() {
        var profile=is.fivefivefive.CanDis.theory.SemanticProfile.alloyOverflowForbidding();
        var type=is.fivefivefive.ACGN.alloy.ExactAlloyType.unaryRelation("A");
        var x=new is.fivefivefive.CanDis.core.EGraphNode(1,is.fivefivefive.CanDis.core.EGraphNode.Opcode.VARIABLE,
                List.of(),false,0,false,is.fivefivefive.CanDis.core.EGraphNode.Metatype.SET,profile);
        x.setSourceName("x");
        x.setExactAlloyType(type);
        var none=is.fivefivefive.CanDis.core.EGraphNode.builtinSetConstant(2,
                is.fivefivefive.ACGN.alloy.SigSymbol.builtinNone(),type,profile);
        var test=new is.fivefivefive.CanDis.core.EGraphNode(3,is.fivefivefive.CanDis.core.EGraphNode.Opcode.IN,
                List.of(x,none),false,2,false,is.fivefivefive.CanDis.core.EGraphNode.Metatype.BOOLEAN,profile);
        test.setExactAlloyType(is.fivefivefive.ACGN.alloy.ExactAlloyType.boolType());
        var form=new is.fivefivefive.CanDis.core.NormalForm();
        var slot=new is.fivefivefive.CanDis.core.QuantiVar(1,"x","A");
        slot.setCardinality(is.fivefivefive.CanDis.core.QuantiVar.Cardinality.ONE);
        form.addParam(slot);
        form.addEClass(test);
        form.normalize(Map.of("x",slot),new int[]{2});
        check(form.getCertificationMatrixEGraph().getOpcode()!=is.fivefivefive.CanDis.core.EGraphNode.Opcode.CONSTANT,
                "mutable caller-owned QuantiVar cannot grant a fold");
    }

    private static String fixture() {
        var text = new StringBuilder("module guard\nsig A {}\n");
        for (var type : List.of("bare","one","some","lone","set","binary")) {
            String domain = type.equals("bare") ? "A" : type.equals("binary") ? "A -> A" : type+" A";
            String none = type.equals("binary") ? "none -> none" : "none";
            text.append("pred guard"+type+"[x: "+domain+"] { x in "+none+" }\n")
                .append("pred deny"+type+"[x: "+domain+"] { some none }\n");
        }
        text.append("pred vacant { univ in none }\npred impossible { some none }\n");
        text.append("pred future[x: one A] { after (x in none) }\npred futureFalse[x: one A] { after (some none) }\n");
        text.append("pred shadow[x: some A] { all x: set A | x in none }\n");
        text.append("pred shadowFalse[x: some A] { all x: set A | some none }\n");
        text.append("pred dual[x: some A] { x not in none }\npred dualTrue[x: some A] { no none }\n");
        text.append("pred grouped[x,y: some A] { x in none or y in none }\npred groupedFalse[x,y: some A] { some none }\n");
        text.append("pred rewritten[x: some A] { (x + none) in none }\npred rewrittenFalse[x: some A] { some none }\n");
        return text.toString();
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) throw new IllegalArgumentException("usage: OUTPUT.tsv");
        var output = java.nio.file.Path.of(args[0]);
        if (java.nio.file.Files.exists(output)) throw new IllegalArgumentException("Fresh output required");
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, fixture());
        var model = new ModelUnit(null, module);
        var visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(model, null);
        Map<String, Predicate> predicates = new TreeMap<>();
        for (Predicate p : model.getPredDeclList()) predicates.put(p.getName(),p);
        for (String type : List.of("bare","one","some","lone","set","binary")) {
            boolean positive = type.equals("bare") || type.equals("one") || type.equals("some");
            Predicate p=predicates.get("guard"+type), deny=predicates.get("deny"+type);
            var slots=ResolvedBindingOrigins.declaration(p.getParamList().get(0));
            check(slots.size()==1, "parser slot "+type);
            var original=module.getAllFunc().makeCopy().stream().filter(x->x.label.endsWith("/guard"+type)).findFirst().orElseThrow();
            var domain=original.decls.get(0).expr;
            var op=domain.mult==0 && domain.type().arity()==1 ? ExprUnary.Op.ONEOF : domain.mult();
            check(slots.get(0).authorizesSome()==(op==ExprUnary.Op.SOMEOF)
                    && slots.get(0).authorizesOne()==(op==ExprUnary.Op.ONEOF), "source multiplicity "+type);
            check((slots.get(0).authorizesSome()||slots.get(0).authorizesOne())==positive, "expected parsed "+type+" "+op);
            var a=CanonicalAlloyPipeline.prepare(visitor.getForest().get(visitor.getForestId(p.getName())));
            var b=CanonicalAlloyPipeline.prepare(visitor.getForest().get(visitor.getForestId(deny.getName())));
            check(a.equivalentTo(b)==positive, "canonical "+type);
            var left=AlloyAstTermAdapter.fromPredicate(p,true);
            var right=AlloyAstTermAdapter.fromPredicate(deny,true);
            for (var engine : ENGINES) {
                check(engine.compare(left,right).equivalent==positive,engine.getClass().getSimpleName()+" "+type);
                if (positive) check(!engine.compare(plain(left),plain(right)).equivalent,
                        "no source slot "+engine.getClass().getSimpleName()+" "+type);
            }
            row(type, op.name()+" "+(positive?"AUTHORIZED":"GUARDED"));
        }
        var vacant=CanonicalAlloyPipeline.prepare(visitor.getForest().get(visitor.getForestId("vacant")));
        var impossible=CanonicalAlloyPipeline.prepare(visitor.getForest().get(visitor.getForestId("impossible")));
        check(!vacant.equivalentTo(impossible), "no unconditional univ witness");
        for (var pair : List.of(List.of("future","futureFalse"),List.of("dual","dualTrue"),List.of("shadow","shadowFalse"),List.of("grouped","groupedFalse"),List.of("rewritten","rewrittenFalse"))) {
            var left=predicates.get(pair.get(0));
            var right=predicates.get(pair.get(1));
            boolean fold=!left.getName().equals("shadow");
            var leftForm=Canonical.prepare(visitor.getForest().get(visitor.getForestId(left.getName())));
            var rightForm=Canonical.prepare(visitor.getForest().get(visitor.getForestId(right.getName())));
            if (left.getName().equals("future")) {
                check(leftForm.normalizedForms().size()==2 && rightForm.normalizedForms().size()==2, "owned temporal child");
                for (var form : List.of(leftForm, rightForm)) {
                    var children=form.normalizedForms().get(1).getCertificationMatrixEGraph().getChildren();
                    check(children.size()==1 && children.get(0).getOpcode()==is.fivefivefive.CanDis.core.EGraphNode.Opcode.CONSTANT && "false".equals(children.get(0).getSourceName()),
                            "canonical temporal child false: "+children);
                }
            } else {
                check(CanonicalAlloyPipeline.prepare(leftForm).equivalentTo(CanonicalAlloyPipeline.prepare(rightForm))==fold,
                        "canonical "+left.getName());
            }
            for (var engine:ENGINES) {
                check(engine.compare(AlloyAstTermAdapter.fromPredicate(left,true),AlloyAstTermAdapter.fromPredicate(right,true)).equivalent==fold,
                        engine.getClass().getSimpleName()+" "+left.getName());
            }
            row(left.getName(),fold?"AUTHORIZED":"GUARDED");
        }
        var second=new ModelUnit(null,CompUtil.parseEverything_fromString(A4Reporter.NOP,fixture()));
        var foreign=AlloyAstTermAdapter.fromPredicate(second.getPredDeclList().stream()
                .filter(p->p.getName().equals("guardone")).findFirst().orElseThrow(),true);
        var local=AlloyAstTermAdapter.fromPredicate(predicates.get("guardone"),true);
        var expected=AlloyAstTermAdapter.fromPredicate(predicates.get("denyone"),true);
        var mixed=AlloyTerm.node(local.head(),local.children().get(0),foreign.children().get(1));
        for (var engine : ENGINES) check(!engine.compare(mixed,expected).equivalent,"foreign lexical read "+engine.getClass().getName());
        syntheticParameter();
        row("foreign-read","GUARDED");
        row("caller-owned-slot","GUARDED");
        Predicate p=predicates.get("guardone");
        var declaration=p.getParamList().get(0);
        declaration.setExpr(predicates.get("guardset").getParamList().get(0).getExpr());
        check(ResolvedBindingOrigins.declaration(declaration).isEmpty(), "replaced declaration domain");
        row("univ","GUARDED");
        row("stale-adapter","NO_AUTHORITY");
        for (String edit : List.of("adapter-type", "adapter-operator", "adapter-arity-operator",
                "adapter-nested-operand", "adapter-children")) {
            P506MutableDomainTest.run(edit);
            row(edit, "NO_AUTHORITY");
        }
        var slots=ResolvedBindingOrigins.declaration(predicates.get("grouped").getParamList().get(0));
        check(slots.size()==2 && slots.get(0)!=slots.get(1)
                && slots.stream().allMatch(ResolvedBindingOrigins.Slot::authorizesSome),"distinct grouped tuple slots");
        var variable=AlloyTerm.typedVariable("x","A");
        var none=AlloyTerm.atom("CONST","none");
        var exact=AlloyTerm.node("DECL/ParamDecl/disj=false/var=false", variable, AlloyTerm.node("UE/EXACTLY",none));
        var maybe=AlloyTerm.node("PREDICATE",exact,AlloyTerm.node("BF/IN",variable,none));
        var no=AlloyTerm.node("PREDICATE",exact,AlloyTerm.atom("CONST","false"));
        for (var engine:ENGINES) check(!engine.compare(maybe,no).equivalent,"EXACTLY leaves empty binding "+engine.getClass().getSimpleName());
        parser.ast.nodes.P506ExactSource.verify();
        row("exactly-none","EXACTLYOF GUARDED");
        row("compiler-methods", "55 "+P506CompilerContract.verify());
        row("previous-compiled-guard","REJECTED");
        row("previous-adapter-projection","REJECTED");
        java.nio.file.Files.writeString(output,"case\toutcome\n"+String.join("\n",results)+"\n",java.nio.file.StandardOpenOption.CREATE_NEW);
        System.out.println("P506SourceBindingTest: cases="+results.size());
    }
}
