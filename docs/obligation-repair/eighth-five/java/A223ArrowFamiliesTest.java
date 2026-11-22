package is.fivefivefive.CanDis.theory;

import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

/** Independent ordered word oracle for the public dependent ARROW entry points. */
public final class A223ArrowFamiliesTest {
    private static final String INT = "#Int";
    private final List<String> rows = new ArrayList<>(List.of("case\toutcome\tvalue"));
    private static void check(boolean ok, String reason) {
        if (!ok) throw new AssertionError(reason);
    }
    private void row(String name, Object value) { rows.add(name+"\tCHECKED\t"+value); }
    private static GraphType atom(String token) {
        return token.equals(INT) ? GraphType.INT : GraphType.constructor("AlloySig:"+token);
    }
    private static String symbol(DependentColumnEvidence c) {
        var type=c.exactColumn();
        if (type.equals(GraphType.INT)) return INT;
        check(type.symbol().startsWith("AlloySig:"), "column constructor");
        return type.symbol().substring("AlloySig:".length());
    }
    private static int compareAtom(String a,String b) {
        if (a.equals(INT) || b.equals(INT)) return a.equals(b) ? 0 : a.equals(INT) ? -1 : 1;
        return a.compareTo(b);
    }
    private static int compareProduct(List<String> a,List<String> b) {
        int stop=Math.min(a.size(),b.size());
        for (int i=0;i<stop;i++) {
            int c=compareAtom(a.get(i),b.get(i));
            if (c!=0) return c;
        }
        return Integer.compare(a.size(),b.size());
    }
    private static List<List<String>> exactNormal(List<List<String>> raw) {
        return raw.stream().distinct().sorted(A223ArrowFamiliesTest::compareProduct).toList();
    }
    private static List<List<String>> observed(DependentTypeDag d) {
        return d.alternatives().stream().map(p -> p.stream().map(A223ArrowFamiliesTest::symbol).toList()).toList();
    }
    private static DependentTypeDag family(int arity,List<List<String>> raw) {
        var dags=raw.stream().map(p -> DependentTypeDag.exactRelation(
                GraphType.relation(p.stream().map(A223ArrowFamiliesTest::atom).toList()))).toList();
        if (dags.isEmpty()) return DependentTypeDag.empty(arity);
        return dags.size()==1 ? dags.get(0) : DependentTypeDag.union(dags);
    }
    private static List<List<String>> matrix(List<List<String>> left,List<List<String>> right) {
        var rows=new ArrayList<List<String>>();
        for (var x:left) for (var y:right) {
            var z=new ArrayList<>(x);z.addAll(y);rows.add(List.copyOf(z));
        }
        return List.copyOf(rows);
    }
    private static int verify(DependentTypeDag left,DependentTypeDag right,List<List<String>> l,List<List<String>> r) {
        check(observed(left).equals(l) && observed(right).equals(r),"independent operand inventory");
        var wanted=matrix(l,r);
        var actual=DependentTypeDag.combine(DependentChainKind.ARROW,left,right);
        A223ArrowCases.verify(left,right,actual);
        check(observed(actual.result()).equals(wanted),"independent normalized product keys");
        return wanted.size();
    }
    private static List<List<String>> subset(List<List<String>> words,int mask) {
        var res=new ArrayList<List<String>>();
        for (int i=0;i<words.size();i++) if ((mask & (1<<i))!=0) {res.add(words.get(i));res.add(words.get(i));}
        return res;
    }
    private void exhaustive() {
        var left=List.of(List.of("Z","A"),List.of("B","B"),List.of("B","A"),List.of(INT,"Z"));
        var right=List.of(List.of("Z"),List.of(INT),List.of("B"));
        int cases=0,rows=0,empty=0;
        for (int i=0;i<16;i++) for (int j=0;j<8;j++) {
            var l=subset(left,i);var r=subset(right,j);
            int n=verify(family(2,l),family(1,r),exactNormal(l),exactNormal(r));
            cases++;rows+=n;if (n==0) empty++;
        }
        row("powerset-family-pairs",cases);row("exact-case-and-result-products",rows);row("typed-empty-pairs",empty);
        check(!GraphType.INT.toString().startsWith("AlloySig:") && "AlloySig:A".compareTo("Int")<0
                && observed(family(1,List.of(List.of("A"),List.of(INT)))).equals(List.of(List.of(INT),List.of("A"))),"structural sort");
        row("structural-int-before-nominal","Int,A");
    }
    private static DependentTypeDag parser(CompModule module,String expression) throws Exception {
        return AlloyTypeBridge.dependentTypeDag(ExactAlloyType.fromParser(
                CompUtil.parseOneExpression_fromString(module,expression).type(),module));
    }
    private static DependentChainLeaf leaf(TypedSlotContext ctx,TypedSlot slot,DependentTypeDag d) {
        return new DependentChainLeaf(OnePort.slot(ctx,slot),d);
    }
    private static void reject(Runnable run,Class<? extends RuntimeException> kind,String detail) {
        try { run.run(); }
        catch (RuntimeException e) {
            check(kind.isInstance(e) && e.getMessage().contains(detail),"unexpected rejection "+e);
            return;
        }
        throw new AssertionError("accepted invalid input "+detail);
    }
    private void parserAndChains() throws Exception {
        String source="abstract sig P {} sig B, A extends P {} sig Z {}";
        var m=CompUtil.parseEverything_fromString(null,source);
        var narrow=parser(m,"A->A");var wide=parser(m,"P->P");
        var siblings=parser(m,"(B->B)+(A->A)");
        var r=parser(m,"B + A");
        var left=List.of(List.of("A","A"),List.of("B","B"));var right=List.of(List.of("A"),List.of("B"));
        check(verify(siblings,r,left,right)==4,"parser matrix");
        check(DependentTypeDag.union(List.of(narrow,wide,narrow)).equals(wide),"strict coordinate absorption");
        check(!observed(siblings).contains(List.of("A","B")),"no column-wise widening");
        row("parser-correlated-products",4);row("input-subtype-absorption","P,P");
        var nativeUniv=parser(m,"univ");
        var rawUniv=family(1,List.of(List.of("univ")));
        var authority=nativeUniv.alternatives().get(0).get(0);
        check(authority.hasParserModuleAuthority() && !rawUniv.alternatives().get(0).get(0).hasParserModuleAuthority(),"authority setup");
        for(var inputs:List.of(List.of(rawUniv,nativeUniv),List.of(nativeUniv,rawUniv))) {
            var normalized=DependentTypeDag.union(inputs);
            check(normalized.alternatives().get(0).get(0)==authority,"authenticated duplicate representative");
            verify(normalized,r,List.of(List.of("univ")),right);
        }
        row("duplicate-representative","authenticated in both orders");
        var weaker=family(2,List.of(List.of("A","A")));
        reject(()->DependentTypeDag.union(List.of(weaker,narrow)),IllegalArgumentException.class,"conflicting subtype stacks");
        row("conflicting-duplicate-evidence","rejected");
        var other=parser(m,"(A->A)+(B->B)");
        var actual=DependentTypeDag.combine(DependentChainKind.ARROW,siblings,r);
        reject(()->A223ArrowCases.verify(other,r,actual),IllegalArgumentException.class,"foreign column occurrence");
        row("same-key-foreign-case-owner","rejected");
        var z=parser(m,"Z");
        var s=TypedSlot.source(siblings.relationType(),810);var t=TypedSlot.source(r.relationType(),811);var u=TypedSlot.source(z.relationType(),812);
        var ctx=TypedSlotContext.of(s,t,u);var a=leaf(ctx,s,siblings);var b=leaf(ctx,t,r);var c=leaf(ctx,u,z);
        var ab=new DependentChainApplication(DependentChainKind.ARROW,a,b);
        var repeated=new DependentChainApplication(DependentChainKind.ARROW,ab,a);
        var reassociated=new DependentChainApplication(DependentChainKind.ARROW,a,new DependentChainApplication(DependentChainKind.ARROW,b,a));
        var expected=matrix(matrix(left,right),left);
        check(observed(repeated.outputTypeDag()).equals(expected) && observed(reassociated.outputTypeDag()).equals(expected)
                && repeated.leaves().equals(List.of(a.port(),b.port(),a.port())) && reassociated.leaves().equals(repeated.leaves()),
                "binary associations and duplicate source slots");
        check(verify(ab.outputTypeDag(),z,matrix(left,right),List.of(List.of("Z")))==4 && c.port().equals(OnePort.slot(ctx,u)),"nested result as left operand");
        row("both-associated-repeated-source",expected.size());
        var foreign=parser(CompUtil.parseEverything_fromString(null,source),"A");
        reject(()->DependentTypeDag.combine(DependentChainKind.ARROW,r,foreign),IllegalArgumentException.class,"mixes parser-module");
        reject(()->DependentTypeDag.union(List.of(r,siblings)),IllegalArgumentException.class,"equal relation arities");
        reject(()->DependentTypeDag.empty(0),IllegalArgumentException.class,"positive arity");
        reject(()->DependentTypeDag.combine(DependentChainKind.ARROW,DependentTypeDag.empty(Integer.MAX_VALUE),
                DependentTypeDag.empty(1)),ArithmeticException.class,"overflow");
        row("foreign-module","rejected");row("mixed-width-input","rejected");row("nullary-empty","rejected");row("checked-arity-overflow","rejected");
    }
    public static void main(String[] args) throws Exception {
        if(args.length!=1) throw new IllegalArgumentException("Expected output TSV path");
        var t=new A223ArrowFamiliesTest();t.exhaustive();t.parserAndChains();
        t.row("compiler-contract",A223CompilerContract.verify(Path.of(args[0]).resolveSibling("arrow-program.txt")));
        Files.write(Path.of(args[0]),t.rows);
        System.out.println("A223ArrowFamiliesTest passed: rows="+(t.rows.size()-1));
    }
}
