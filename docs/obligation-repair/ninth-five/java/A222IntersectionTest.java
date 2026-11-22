package is.fivefivefive.CanDis.theory;

import edu.mit.csail.sdg.ast.Sig;
import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import java.nio.file.*;
import java.util.*;

/** Public-entry comparison with the actual parser's PrimSig objects and explicit parent pointers. */
public final class A222IntersectionTest {
    private static final String SOURCE = "sig Root {} sig Mid extends Root {} sig Leaf, Sibling extends Mid {} sig Other extends Root {} sig Apart {}";
    private final CompModule module;
    private final Map<String,Sig.PrimSig> names = new TreeMap<>();
    private final List<String> ordered;
    private final List<String> data = new ArrayList<>();

    private A222IntersectionTest() throws Exception {
        module=CompUtil.parseEverything_fromString(null,SOURCE);
        for (var sig:module.getAllReachableSigs()) {
            if (sig instanceof Sig.PrimSig p) names.put(name(p),p);
        }
        names.put("univ",Sig.UNIV);
        names.put("Int",Sig.SIGINT);
        names.put("String",Sig.STRING);
        names.put("seq/Int",Sig.SEQIDX);
        ordered=List.copyOf(names.keySet());
    }
    private static void check(boolean ok,String detail) {
        if(!ok) throw new AssertionError(detail);
    }
    private static String name(Sig.PrimSig p) {
        return p.label.startsWith("this/") ? p.label.substring(5) : p.label;
    }
    private static List<String> ancestry(Sig.PrimSig p) {
        var result=new ArrayList<String>();
        for (;p!=null;p=p.parent) result.add(name(p));
        return result;
    }
    private static String name(GraphType t) {
        return t.equals(GraphType.INT) ? "Int" : t.symbol().substring("AlloySig:".length());
    }
    private static List<String> observedPath(List<GraphType> path) {
        return path.stream().map(A222IntersectionTest::name).toList();
    }
    private static ExactAlloyType type(CompModule m,String e) throws Exception {
        return ExactAlloyType.fromParser(CompUtil.parseOneExpression_fromString(m,e).type(),m);
    }
    private static DependentTypeDag dag(CompModule m,String e) throws Exception {
        return AlloyTypeBridge.dependentTypeDag(type(m,e));
    }
    private static void reject(Runnable run,String text) {
        try { run.run(); }
        catch(IllegalArgumentException ex) {
            check(ex.getMessage().contains(text),"Unexpected input rejection "+ex);
            return;
        }
        throw new AssertionError("Missing input rejection "+text);
    }
    private String ids(List<String> path) {
        var list=path.stream().map(ordered::indexOf).toList();
        check(list.stream().allMatch(i -> i>=0),"Unregistered picker "+path);
        return String.join(",",list.stream().map(String::valueOf).toList());
    }
    private static List<String> through(List<String> path,String common) {
        return path.subList(0,path.indexOf(common)+1);
    }
    private void boundaries() throws Exception {
        var carriers=List.of("Root","Mid","Leaf","Sibling","Other","Apart","univ","Int","String","seq/Int");
        var cols=new LinkedHashMap<String,DependentColumnEvidence>();
        // Binary parser types expose the unary Int carrier without selecting the separate scalar-INT API.
        for (String n:carriers) {
            var c=dag(module,n+" -> univ").alternatives().get(0).get(0);
            check(observedPath(c.ancestry()).equals(ancestry(names.get(n))),"Raw parser path "+n);
            cols.put(n,c);
        }
        var counts=new TreeMap<String,Integer>();
        for(String a:carriers) for(String b:carriers) {
            var left=ancestry(names.get(a)); var right=ancestry(names.get(b));
            String common=left.stream().filter(right::contains).findFirst().orElseThrow();
            String kind=a.equals(b)?"EXACT":left.contains(b)?"LEFT_SUBTYPE_OF_RIGHT":
                    right.contains(a)?"RIGHT_SUBTYPE_OF_LEFT":"DISJOINT_BRANCHES";
            var proof=DependentBoundaryCorrespondence.derive(cols.get(a),cols.get(b));
            check(proof.rule().name().equals(kind) && name(proof.commonAncestor()).equals(common),"Boundary "+a+","+b);
            check(observedPath(proof.leftWitnessPath()).equals(through(left,common))
                    && observedPath(proof.rightWitnessPath()).equals(through(right,common)),"Witness prefixes");
            int meet=-1;
            if(!kind.equals("DISJOINT_BRANCHES")) {
                String wanted=kind.equals("RIGHT_SUBTYPE_OF_LEFT")?b:a;
                check(proof.overlaps() && name(proof.meetBoundary()).equals(wanted),"Concrete meet");
                meet=ordered.indexOf(wanted);
            } else {
                check(!proof.overlaps(),"Divergent branches overlapped");
            }
            data.add("C\t"+ids(left)+"\t"+ids(right)+"\t"+kind+"\t"+ordered.indexOf(common)+"\t"+meet+
                    "\t"+ids(observedPath(proof.leftWitnessPath()))+"\t"+ids(observedPath(proof.rightWitnessPath())));
            counts.merge(kind,1,Integer::sum);
        }
        System.out.println("A222 parser coordinate decisions="+counts);
    }
    private Set<List<String>> rows(DependentTypeDag family) {
        var result=new HashSet<List<String>>();
        for(var row:family.alternatives()) {
            check(result.add(row.stream().map(c -> name(c.exactColumn())).toList()),"Duplicate output");
        }
        return result;
    }
    private void family(String label,List<String> operands,Set<List<String>> expected,int width) throws Exception {
        var arguments=new ArrayList<DependentTypeDag>();
        var exact=new ArrayList<ExactAlloyType>();
        for(String e:operands) {
            exact.add(type(module,e));
            arguments.add(dag(module,e));
        }
        var got=DependentTypeDag.intersection(arguments);
        check(got.arity()==width && rows(got).equals(expected),"Unexpected "+label+" "+rows(got));
        var independentlyDerived=AlloyTypeBridge.dependentTypeDag(ExactAlloyType.parserCertifiedRelationIntersection(exact));
        check(got.sameOccurrenceEvidenceAs(independentlyDerived),"Producer source-DAG cross-check "+label);
        for(var row:got.alternatives()) for (var c:row) {
            check(c.hasParserModuleAuthority() && observedPath(c.ancestry()).equals(ancestry(names.get(name(c.exactColumn())))),
                    "Lost result authority or path in "+label);
        }
        System.out.println("A222 "+label+" width="+width+" alternatives="+expected.size());
    }
    private void families() throws Exception {
        family("correlated cartesian pruning",List.of("(Mid -> Apart) + (Other -> Root)","(Root -> Apart) + (Other -> Leaf)"),
                Set.of(List.of("Mid","Apart"),List.of("Other","Leaf")),2);
        family("nary fold",List.of("Mid + Apart","Root","Leaf + Apart","univ"),Set.of(List.of("Leaf")),1);
        family("common univ only",List.of("Leaf","Apart"),Set.of(),1);
        family("non-univ common only",List.of("Leaf","Sibling"),Set.of(),1);
        family("empty intermediate",List.of("Leaf","Apart","Root"),Set.of(),1);
        for(int width:List.of(1,2,3,5,8)) {
            var l=new ArrayList<String>(); var r=new ArrayList<String>(); var result=new ArrayList<String>();
            for(int i=0;i<width;i++) {
                l.add(i%2==0?"Leaf":"univ"); r.add(i%2==0?"Root":"Apart"); result.add(i%2==0?"Leaf":"Apart");
            }
            family("alternating specificity",List.of(String.join(" -> ",l),String.join(" -> ",r)),Set.of(result),width);
            r.set(width-1,width%2==1?"Apart":"Leaf");
            if(width%2==0) l.set(width-1,"Apart");
            family("last coordinate disjoint",List.of(String.join(" -> ",l),String.join(" -> ",r)),Set.of(),width);
        }
        var foreign=dag(CompUtil.parseEverything_fromString(null,SOURCE),"Leaf");
        var leaf=dag(module,"Leaf");
        var binary=dag(module,"Leaf -> Root");
        var raw1=DependentTypeDag.exactRelation(GraphType.relation(List.of(GraphType.constructor("AlloySig:X"))));
        var raw2=DependentTypeDag.exactRelation(GraphType.relation(List.of(GraphType.constructor("AlloySig:Y"))));
        check(DependentTypeDag.intersection(List.of(raw1,raw1)).equals(raw1),"Exact-only identity");
        reject(()->DependentTypeDag.intersection(List.of(leaf,foreign)),"mixes parser-module authorities");
        reject(()->DependentTypeDag.intersection(List.of(raw1,raw2)),"one live parser module");
        reject(()->DependentTypeDag.intersection(List.of(leaf,binary)),"equal relation arities");
        reject(()->DependentTypeDag.intersection(List.of(leaf)),"at least two operands");
        System.out.println("A222 admission=exact-only identity,foreign module,unattested inequality,mixed width,operand minimum");
    }
    public static void main(String[] args) throws Exception {
        if(args.length!=2) throw new IllegalArgumentException("Expected checkout and fresh interchange path");
        var check=new A222IntersectionTest();
        check.boundaries();
        check.families();
        var program=A222Javac.inspect(Path.of(args[0]));
        var output=new ArrayList<String>();
        for(String op:program) output.add("P\t"+op);
        output.addAll(check.data);
        Files.write(Path.of(args[1]),output,StandardOpenOption.CREATE_NEW);
        System.out.println("A222IntersectionTest passed: coordinates="+check.data.size()+" families=15 input-controls=5");
    }
}

