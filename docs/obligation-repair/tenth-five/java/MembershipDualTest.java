package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.alloy4.Err;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter;
import is.fivefivefive.CanDis.core.egraph.*;
import java.nio.file.*;
import java.util.*;
import parser.ast.nodes.*;

public final class MembershipDualTest {
    private record Case(String id, String params, String lhs, String rhs, String prefix, String canonical, String raw) {}
    private static final List<Case> CASES = List.of(
        c("implicit","x: A","x","none","false","false"),
        c("explicitOne","x: one A","x","none","false","false"),
        c("positive","x: some A","x","none","false","false"),
        c("nullable","x: lone A","x","none","open","open"),
        c("unknown","x: set A","x","none","open","open"),
        c("vacant","","univ","none","open","open"),
        c("bothEmpty","","none","none","true","true"),
        c("rightUniv","x: set A","x","univ","true","true"),
        c("bothUniv","","univ","univ","true","true"),
        c("leftEmpty","x: set A","none","x","true","open"),
        c("ordinary","x,y: set A","x","y","open","open"),
        c("self","x: set A","x","x","true","open"),
        c("structural","x,y: set A","(x & y)","x","true","open"),
        c("lattice","x,y,z: set A","(x+y)","(x&z)","open","open"),
        c("capitalized","x: set A","x","None","open","open"),
        c("capitalizedLeft","","None","none","open","open"),
        c("capitalizedUniv","x: set A","x","Univ","open","open"),
        c("binary","x: A -> A","x","(none -> none)","open","open"),
        new Case("shadow","x: some A","x","none","all x: set A | ","open","open"),
        new Case("innerPositive","x: set A","x","none","all x: some A | ","false","false")
    );
    private static Case c(String id, String params, String l, String r, String can, String raw) {
        return new Case(id,params,l,r,"",can,raw);
    }
    private static final List<AblationEngine> ENGINES = List.of(new RawEGraph(),new RawDeBruijnEGraph(),
        new JavaEgglog(),new JavaEgglogDeBruijn(),new SlottedEGraph(),new SlottedEGraph(true));
    private static void check(boolean ok, String message) { if (!ok) throw new AssertionError(message); }
    private static String source(Case c) {
        StringBuilder s = new StringBuilder("module guarded_duals\nsig A, None, Univ {}\n");
        var bodies = List.of(c.lhs+" in "+c.rhs, c.lhs+" not in "+c.rhs, "not ("+c.lhs+" in "+c.rhs+")",
            "not ("+c.lhs+" not in "+c.rhs+")", "no none", "some none");
        var names=List.of("pos","neg","notPos","notNeg","truth","falsehood");
        for (int i=0;i<names.size();i++) s.append("pred ").append(names.get(i)).append("[").append(c.params)
            .append("] { ").append(c.prefix).append(bodies.get(i)).append(" }\n");
        for (String k: List.of("plainTrue","plainFalse","inhabited","emptyA")) {
            String body=switch(k) { case "plainTrue" -> "no none"; case "plainFalse" -> "some none"; case "inhabited" -> "some A"; default -> "no A"; };
            s.append("pred ").append(k).append("[").append(c.params).append("] { ").append(body).append(" }\n");
        }
        return s.toString();
    }
    private static String outcome(boolean yes, boolean no) {
        check(!(yes && no),"both Boolean constants recognized");
        return yes?"true":no?"false":"open";
    }
    private static String dual(String result) {
        return switch(result) { case "true" -> "false"; case "false" -> "true"; default -> "open"; };
    }
    private static is.fivefivefive.CanDis.core.EGraphNode predicateMatrix(is.fivefivefive.CanDis.core.EGraphNode root) {
        var stack = new ArrayDeque<is.fivefivefive.CanDis.core.EGraphNode>(); stack.push(root);
        while(!stack.isEmpty()) {
            var node=stack.pop();if(node.getOpcode().name().equals("PREDICATE")) return node;
            for(var child:node.getChildren()) stack.push(child);
        }
        throw new AssertionError("missing predicate body");
    }
    private static void run(Case c, List<String> rows) throws Exception {
        var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,source(c));
        var tree=new ModelUnit(null,module);
        var visitor=new MASGVisitor(new GlobalVariables(),module);
        visitor.visit(tree,null);
        Map<String,Predicate> p=new HashMap<>(); tree.getPredDeclList().forEach(x->p.put(x.getName(),x));
        var names=List.of("pos","neg","notPos","notNeg","truth","falsehood");
        var canonical=names.stream().map(k->CanonicalAlloyPipeline.prepare(visitor.getForest().get(visitor.getForestId(k)))).toList();
        String canP=outcome(canonical.get(0).equivalentTo(canonical.get(4)),canonical.get(0).equivalentTo(canonical.get(5)));
        String canN=outcome(canonical.get(1).equivalentTo(canonical.get(4)),canonical.get(1).equivalentTo(canonical.get(5)));
        boolean canDual=canonical.get(1).equivalentTo(canonical.get(2)) && canonical.get(0).equivalentTo(canonical.get(3));
        if (List.of("nullable","unknown","binary").contains(c.id)) {
            var shapes=new ArrayList<String>();
            for (String k:names.subList(0,4)) {
                var form=Canonical.prepare(visitor.getForest().get(visitor.getForestId(k))).normalizedForms().get(0);
                var pred=predicateMatrix(form.getCertificationMatrixEGraph());
                check(pred.getChildren().size()==1,"single matrix formula");
                var body=pred.getChildren().get(0); shapes.add(body.getOpcode().name());
                check(body.getChildren().get(0).getOpcode().name().equals("VARIABLE"),"retained original relation");
            }
            check(shapes.equals(List.of("NO","SOME","NOT_IN","IN")), "nullable dual representations "+shapes);
        } else if (c.id.equals("shadow") || c.id.equals("innerPositive")) {
            var noA=CanonicalAlloyPipeline.prepare(visitor.getForest().get(visitor.getForestId("emptyA")));
            String expectNegative=c.id.equals("shadow")?"plainFalse":"plainTrue";
            var answer=CanonicalAlloyPipeline.prepare(visitor.getForest().get(visitor.getForestId(expectNegative)));
            check(canonical.get(0).equivalentTo(noA) && canonical.get(1).equivalentTo(answer),
                "quantifier's actual domain in "+c.id);
        } else {
            check(canDual,"ordinary negated source must agree in "+c.id);
        }
        check(canP.equals(c.canonical)&&canN.equals(c.id.equals("shadow")?"false":dual(c.canonical)),"canonical "+c.id+" "+canP+" "+canN);
        var terms=names.stream().map(k->AlloyAstTermAdapter.fromPredicate(p.get(k),true)).toList();
        for (var engine:ENGINES) {
            String rp=outcome(engine.compare(terms.get(0),terms.get(4)).equivalent,engine.compare(terms.get(0),terms.get(5)).equivalent);
            String rn=outcome(engine.compare(terms.get(1),terms.get(4)).equivalent,engine.compare(terms.get(1),terms.get(5)).equivalent);
            boolean rawDual=engine.compare(terms.get(1),terms.get(2)).equivalent && engine.compare(terms.get(0),terms.get(3)).equivalent;
            check(rp.equals(c.raw)&&rn.equals(dual(c.raw))&&rawDual,"raw "+c.id+" "+engine.getClass().getSimpleName()+" "+rp+" "+rn+" dual="+rawDual);
        }
        rows.add(c.id+"\t"+canP+"/"+canN+"\t"+c.raw+"/"+dual(c.raw)+"\t"+canDual);
    }
    private static void staleAndForeign(List<String> rows) throws Exception {
        var model=CompUtil.parseEverything_fromString(A4Reporter.NOP, "module saved\nsig A,B {}\n"
            +"pred positive[x:(A+B)&(B+A)] {x in none}\npred negative[x:(A+B)&(B+A)] {x not in none}\n"
            +"pred zero[x:(A+B)&(B+A)] {some none}\npred oneRef[x:(A+B)&(B+A)] {no none}\n");
        var local=new ModelUnit(null,model); var copy=new ModelUnit(null,model);
        var byName = new TreeMap<String,Predicate>(); local.getPredDeclList().forEach(p->byName.put(p.getName(),p));
        for(String key:List.of("positive","negative")) {
            var p=byName.get(key); var decl=p.getParamList().get(0);
            var slot=ResolvedBindingOrigins.declaration(decl).get(0);
            var foreign=copy.getPredDeclList().stream().filter(q->q.getName().equals(key)).findFirst().orElseThrow();
            var body=AlloyAstTermAdapter.fromPredicate(foreign,true).children().get(1);
            var expect=AlloyAstTermAdapter.fromPredicate(byName.get(key.equals("positive")?"zero":"oneRef"),true).children().get(1);
            var parsed=AlloyAstTermAdapter.fromPredicate(p,true);
            var reference=AlloyTerm.node("PREDICATE",parsed.children().get(0),expect);
            var mixed=AlloyTerm.node("PREDICATE",parsed.children().get(0),body);
            for(var engine:ENGINES) {
                check(engine.compare(parsed,reference).equivalent,"missing authentic fold");
                check(!engine.compare(mixed,reference).equivalent,"foreign read "+key);
            }
            var sum=nestedUnion(decl.getExpr());
            sum.setOp(BinaryExpr.BinaryOp.INTERSECT);
            try {
                check(ResolvedBindingOrigins.declaration(decl).isEmpty(),"stale projection");
                var modified=AlloyAstTermAdapter.fromPredicate(p,true);
                var currentReference=AlloyTerm.node("PREDICATE",modified.children().get(0),expect);
                for(var engine:ENGINES) check(!engine.compare(modified,currentReference).equivalent,"stale domain "+key);
                var visitor=new MASGVisitor(new GlobalVariables(),model);visitor.visit(local,null);
                var form=Canonical.prepare(visitor.getForest().get(visitor.getForestId(key))).normalizedForms().get(0);
                var result=predicateMatrix(form.getCertificationMatrixEGraph()).getChildren().get(0);
                check(!result.getOpcode().name().equals("CONSTANT"),"stale canonical "+key);
            } finally { sum.setOp(BinaryExpr.BinaryOp.PLUS); }
            check(ResolvedBindingOrigins.declaration(decl).get(0)==slot,"restored source");
            rows.add("foreign-"+key+"\tNOT_APPLICABLE\tGUARDED\tN/A");
            rows.add("stale-"+key+"\tGUARDED\tGUARDED\tN/A");
        }
    }
    private static BinaryExpr nestedUnion(Node root) {
        var queue=new ArrayDeque<Node>();queue.add(root);
        while(!queue.isEmpty()){
            Node n=queue.remove();if(n instanceof BinaryExpr b && b.getOp()==BinaryExpr.BinaryOp.PLUS) return b;
            for(Node child:n.getChildren())if(child!=null)queue.add(child);
        }
        throw new AssertionError("missing parsed union");
    }
    public static void main(String[] args) throws Exception {
        if (args.length!=3 || !Set.of("P5-05","P5-07").contains(args[0])) {
            throw new IllegalArgumentException("P5-05|P5-07 CHECKOUT FRESH_RESULTS_DIR");
        }
        String parent=args[0];
        Path out=Path.of(args[2]).toAbsolutePath();
        check(Files.isDirectory(out),"result directory required");
        Path table=out.resolve("instructions.tsv");
        MembershipInstructions.main(new String[]{args[1],table.toString()});
        String lean=Objects.requireNonNull(System.getenv("ACGN_TENTH_LEAN"),"private Lean binary");
        String proof=Objects.requireNonNull(System.getenv("ACGN_TENTH_PROOF"),"registered executable Lean checker");
        var process=new ProcessBuilder(lean,"--run",proof,table.toString()).inheritIO().start();
        try {
            check(process.waitFor(60,java.util.concurrent.TimeUnit.SECONDS) && process.exitValue()==0,"Lean rejected membership instructions");
        } finally { if(process.isAlive()) process.destroyForcibly(); }

        var rows=new ArrayList<String>(); rows.add("case\tcanonical-IN/NOT_IN\traw-IN/NOT_IN\tcanonical-negation-equivalent");
        for(var c:CASES) run(c,rows);
        staleAndForeign(rows);
        for(String invalid:List.of("(A->A) in univ","(some A) in none","A not in (A->A)")) {
            try { CompUtil.parseEverything_fromString(A4Reporter.NOP,"sig A {} pred p { "+invalid+" }"); }
            catch(Err e) { check(e instanceof edu.mit.csail.sdg.alloy4.ErrorType, "non-type rejection "+e); rows.add("type-error "+invalid+"\tPARSER_REJECTED\tNOT_CONVERTED\tN/A");continue; }
            throw new AssertionError("Expected Alloy type rejection "+invalid);
        }
        List<String> report = new ArrayList<>();
        if (parent.equals("P5-07")) {
            report.addAll(rows);
        } else {
            report.add("case\tcanonical-IN\traw-IN");
            for (String line:rows.subList(1,rows.size())) {
                String[] values=line.split("\t",-1);
                if (values[0].contains("negative") || values[0].contains("not in")) continue;
                report.add(String.join("\t",values[0],values[1].split("/",2)[0],values[2].split("/",2)[0]));
            }
        }
        Files.write(out.resolve("cases.tsv"),report,java.nio.charset.StandardCharsets.UTF_8,StandardOpenOption.CREATE_NEW);
        System.out.println(parent+" membership verified: "+(report.size()-1)+" observations, six raw configurations");
    }
}
