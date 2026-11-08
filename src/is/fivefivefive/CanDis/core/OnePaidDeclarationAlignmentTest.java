package is.fivefivefive.CanDis.core;

import java.nio.file.*;
import java.util.*;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.ir.IRAgent;
import parser.ast.nodes.ModelUnit;

/** ONE barriers, exact paid occurrences and unsupported-scope controls. */
public final class OnePaidDeclarationAlignmentTest {
    private static int checks;
    private static void check(boolean value,String why) { checks++; if(!value) throw new AssertionError(why); }
    private static List<NormalForm> prepare(edu.mit.csail.sdg.parser.CompModule m,String name) {
        var v=new MASGVisitor(new GlobalVariables(),Set.of(name),m);v.visit(new ModelUnit(null,m),null);
        var a=new IRAgent(v.getForest().get(v.getForestId(name)));a.computeNormalForm();
        var forms=List.copyOf(a.normalForms());forms.forEach(NormalForm::freezeForCertification);return forms;
    }
    private static QuantiVar variable(String name,int code) {
        var q=new QuantiVar(name.hashCode(),name,code%2==0?"A":"Z");
        q.setCardinality(QuantiVar.Cardinality.ONE);
        q.setQuantifier(List.of(QuantiVar.Quantifier.ONE,QuantiVar.Quantifier.ALL,QuantiVar.Quantifier.SOME).get(code/2));
        return q;
    }
    private static int update(QuantiVar a,QuantiVar b) {
        return a.getQuantifier()==b.getQuantifier() && a.getTypeName().equals(b.getTypeName())?0:1;
    }
    private static int[][] dp(List<QuantiVar> a,List<QuantiVar> b) {
        int[][] d=new int[a.size()+1][b.size()+1];
        for(int i=0;i<=a.size();i++) d[i][0]=i;
        for(int j=0;j<=b.size();j++) d[0][j]=j;
        for(int i=1;i<=a.size();i++) for(int j=1;j<=b.size();j++)
            d[i][j]=Math.min(d[i-1][j-1]+update(a.get(i-1),b.get(j-1)),Math.min(d[i-1][j]+1,d[i][j-1]+1));
        return d;
    }
    private static void brute(List<QuantiVar> a,List<QuantiVar> b,int i,int j,int cost,int minimum,
            Map<String,String> links,Set<Map<String,String>> out) {
        if(cost>minimum) return;
        if(i==a.size() && j==b.size()) { if(cost==minimum) out.add(Map.copyOf(links)); return; }
        if(i<a.size()) brute(a,b,i+1,j,cost+1,minimum,links,out);
        if(j<b.size()) brute(a,b,i,j+1,cost+1,minimum,links,out);
        if(i<a.size() && j<b.size()) {
            int charge=update(a.get(i),b.get(j));
            if(charge!=0) links.put(a.get(i).getName(),b.get(j).getName());
            brute(a,b,i+1,j+1,cost+charge,minimum,links,out);
            if(charge!=0) links.remove(a.get(i).getName());
        }
    }
    public static void main(String[] args) throws Exception {
        var original=List.of(variable("0",1),variable("1",0),variable("2",5),variable("3",4),
                variable("4",0),variable("5",3),variable("6",2));
        var method=CanonicalDistance.class.getDeclaredMethod("canonicalQuantifierOrder",List.class);
        method.setAccessible(true);
        @SuppressWarnings("unchecked") var ordered=(List<QuantiVar>)method.invoke(null,original);
        check(ordered.stream().map(QuantiVar::getName).toList().equals(List.of("0","1","3","2","4","6","5")),
                "each ONE is a fixed barrier, only inner ALL/SOME runs sort");
        check(original.stream().map(QuantiVar::getName).toList().equals(List.of("0","1","2","3","4","5","6")),
                "source occurrence order remains immutable");
        for(int n=0;n<=2;n++) for(int m=0;m<=2;m++) {
            int limit=1;for(int i=0;i<n+m;i++) limit*=6;
            for(int code=0;code<limit;code++) {
                int value=code; var a=new ArrayList<QuantiVar>();var b=new ArrayList<QuantiVar>();
                for(int i=0;i<n;i++) { a.add(variable("a"+i,value%6));value/=6; }
                for(int i=0;i<m;i++) { b.add(variable("b"+i,value%6));value/=6; }
                var d=dp(a,b);Set<Map<String,String>> actual=new HashSet<>(),expected=new HashSet<>();
                FastPaidDeclarationAlignment.enumerate(a,b,d,OnePaidDeclarationAlignmentTest::update,actual::add);
                brute(a,b,0,0,0,d[n][m],new HashMap<>(),expected);
                check(actual.equals(expected),"all minimum charged paths over ALL/SOME/ONE and two carriers");
                for(var links:actual) check(new HashSet<>(links.values()).size()==links.size(),"paid links remain injective");
            }
        }
        String natural=Files.readString(Path.of("classified-data/classroom_fol/both/TA943B2hFMmbp96Pj_inv8.als"));
        var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,natural);
        var left=prepare(module,"inv8"); var right=prepare(module,"inv8c");
        check(FastPaidDeclarationAlignment.supportsPair(left,right) && FastPaidDeclarationAlignment.supportsPair(right,left),
                "original pair in both directions");
        check(left.get(0).getMatrixQuantiVars().stream().map(q->q.getQuantifier().name()).toList()
                .equals(List.of("ALL","ONE")),"ONE cannot cross the outer ALL");
        for(String replacement:List.of("one t:set Teacher","one disj t,u:Teacher","one t,u:Teacher")) {
            var changed=CompUtil.parseEverything_fromString(A4Reporter.NOP,natural.replace("one t:Teacher",replacement));
            check(!FastPaidDeclarationAlignment.supports(prepare(changed,"inv8")),"unsupported grouped/multiplicity declaration "+replacement);
        }
        var local=CompUtil.parseEverything_fromString(A4Reporter.NOP,
                Files.readString(Path.of("classified-data/classroom_fol/both/7TYSDPnXqtud3bjku_inv12.als"))
                    .replace("some c:Class","one c:Class"));
        var localForms=prepare(local,"inv12");
        check(!localForms.get(0).getLocalQuantiVars().isEmpty(),"negative control retains a local binder");
        check(!FastPaidDeclarationAlignment.supports(localForms),"ONE plus local binder remains excluded");
        var controls=CompUtil.parseEverything_fromString(A4Reporter.NOP,"""
                sig A { r:set A }
                pred temporal { one x:A | always x in x.r }
                pred parameter[p:A] { one x:A | p in x.r }
                pred oneFirst { one x:A | some y:A | x in y.r }
                pred someFirst { some y:A | one x:A | x in y.r }
                pred rowUnique { one x:A | one y:A | x->y in r }
                pred columnUnique { one y:A | one x:A | x->y in r }
                """);
        for(String name:List.of("temporal","parameter"))
            check(!FastPaidDeclarationAlignment.supports(prepare(controls,name)),"excluded scope "+name);
        var oneFirst=prepare(controls,"oneFirst"); var someFirst=prepare(controls,"someFirst");
        check(!CanonicalDistance.sourceIrTemporalFol(oneFirst).equals(CanonicalDistance.sourceIrTemporalFol(someFirst)),
                "ONE/SOME source order is retained");
        var rows=CanonicalDistance.prepare(prepare(controls,"rowUnique"));
        var columns=CanonicalDistance.prepare(prepare(controls,"columnUnique"));
        check(CanonicalDistance.distance(rows,columns)>0
                && CanonicalDistance.distance(rows,columns)==CanonicalDistance.distance(columns,rows),
                "equal-carrier ONE owners cannot be freely exchanged by alpha alignment");
        System.out.println("OnePaidDeclarationAlignmentTest: "+checks+" checks passed; fixed prefix, no free ONE exchange");
    }
}
