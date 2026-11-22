package is.fivefivefive.CanDis.theory;

import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import java.nio.file.*;
import java.util.*;

/** An independent, fixture-specific ancestry oracle for genuine parsed operands. */
public final class A224JoinCases {
    private static final String SOURCE = "abstract sig P {} sig A,B extends P {} sig U,V,W,X,Y,Z {}";
    private static final List<String> ROWS = new ArrayList<>(List.of("case\tdecisions\texact\tleftSubtype\trightSubtype\tdisjoint\tdistinctResultRows\twidth"));
    private static final Map<String,String> PARENT = Map.ofEntries(Map.entry("A","P"),Map.entry("B","P"),Map.entry("P","univ"),
            Map.entry("U","univ"),Map.entry("V","univ"),Map.entry("W","univ"),Map.entry("X","univ"),Map.entry("Y","univ"),Map.entry("Z","univ"));

    private static void check(boolean value, String message) {
        if (!value) throw new AssertionError(message);
    }
    private static DependentTypeDag parse(CompModule module, String expression) throws Exception {
        return AlloyTypeBridge.dependentTypeDag(ExactAlloyType.fromParser(
                CompUtil.parseOneExpression_fromString(module,expression).type(),module));
    }
    private static DependentTypeDag choices(CompModule module, String... expressions) throws Exception {
        var terms = new ArrayList<DependentTypeDag>();
        for (String expression: expressions) terms.add(parse(module,expression));
        return DependentTypeDag.union(terms);
    }
    private static String word(GraphType column) {
        return column.symbol().substring("AlloySig:".length());
    }
    private static List<String> word(List<DependentColumnEvidence> row) {
        return row.stream().map(e -> word(e.exactColumn())).toList();
    }
    private static List<String> chain(String column) {
        var path = new ArrayList<String>();
        while(column!=null) {path.add(column);column=PARENT.get(column);}
        return path;
    }
    private static boolean covered(List<String> smaller,List<String> larger) {
        if(smaller.size()!=larger.size())return false;
        for(int i=0;i<smaller.size();i++)if(!chain(smaller.get(i)).contains(larger.get(i)))return false;
        return true;
    }
    private static List<String> through(List<String> path,String top) {
        return path.subList(0,path.indexOf(top)+1);
    }
    private static void verify(String name, DependentTypeDag left, DependentTypeDag right, int... expected) {
        var actual = DependentTypeDag.combine(DependentChainKind.JOIN,left,right);
        int n = right.alternatives().size(), width=left.arity()+right.arity()-2;
        check(actual.cases().size()==left.alternatives().size()*n && actual.result().arity()==width,"dimensions "+name);
        var survivors = new LinkedHashSet<List<String>>();
        int[] counts=new int[4];
        for (int k=0;k<actual.cases().size();k++) {
            int i=k/n,j=k%n;
            var lhs=left.alternatives().get(i);var rhs=right.alternatives().get(j);
            var lc=lhs.get(lhs.size()-1);var rc=rhs.get(0);
            var lp=chain(word(lc.exactColumn()));var rp=chain(word(rc.exactColumn()));
            int decision=lp.get(0).equals(rp.get(0)) ? 0 : lp.contains(rp.get(0)) ? 1 : rp.contains(lp.get(0)) ? 2 : 3;
            counts[decision]++;
            String common=lp.stream().filter(rp::contains).findFirst().orElseThrow();
            var cell=actual.cases().get(k);var boundary=cell.boundary().orElseThrow();
            check(cell.leftAlternative()==i && cell.rightAlternative()==j, "index "+name);
            check(boundary.rule().name().equals(List.of("EXACT","LEFT_SUBTYPE_OF_RIGHT","RIGHT_SUBTYPE_OF_LEFT","DISJOINT_BRANCHES").get(decision))
                    && boundary.leftBoundary().equals(lc.exactColumn()) && boundary.rightBoundary().equals(rc.exactColumn())
                    && word(boundary.commonAncestor()).equals(common),"boundary endpoints "+name);
            check(boundary.leftWitnessPath().stream().map(A224JoinCases::word).toList().equals(through(lp,common))
                    && boundary.rightWitnessPath().stream().map(A224JoinCases::word).toList().equals(through(rp,common)),"witness ancestry "+name);
            if(decision==3) {
                check(cell.decision()==DependentTypeDag.CombinationDecision.JOIN_DISJOINT
                        && cell.resultAlternative().isEmpty() && !boundary.overlaps(),"false omission "+name);
            } else {
                check(cell.decision()==DependentTypeDag.CombinationDecision.JOIN_OVERLAP && boundary.overlaps(),"missing overlap "+name);
                var product=cell.resultAlternative().orElseThrow();
                check(product.size()==width,"survivor width "+name);
                for(int t=0;t<width;t++) {
                    var owner = t<lhs.size()-1 ? lhs.get(t) : rhs.get(t-(lhs.size()-1)+1);
                    check(product.get(t)==owner,"column occurrence ownership "+name);
                }
                survivors.add(word(product));
            }
        }
        var maximal=survivors.stream().filter(a->survivors.stream().noneMatch(b->!a.equals(b)&&covered(a,b))).toList();
        var output=actual.result().alternatives().stream().map(A224JoinCases::word).toList();
        check(output.size()==maximal.size() && new HashSet<>(output).equals(new HashSet<>(maximal)),"normalized family "+name);
        if(maximal.isEmpty()) check(Objects.equals(AlloyTypeBridge.emptyRelationArity(actual.result().relationType()),width),"lost typed empty "+name);
        check(Arrays.equals(counts,Arrays.copyOf(expected,4)) && output.size()==expected[4],name+" "+Arrays.toString(counts)+" result "+output);
        ROWS.add(String.join("\t",name,Integer.toString(actual.cases().size()),Integer.toString(counts[0]),Integer.toString(counts[1]),
                Integer.toString(counts[2]),Integer.toString(counts[3]),Integer.toString(output.size()),Integer.toString(width)));
    }
    private static void rejected(String name,Runnable guard,Class<? extends RuntimeException> type,String fragment) {
        try {guard.run();} catch (RuntimeException error) {
            check(type.isInstance(error) && error.getMessage().contains(fragment),name+" "+error);
            ROWS.add(name+"\tGUARD\t"+type.getSimpleName()+"\t-\t-\t-\t-\t-");return;
        }
        throw new AssertionError("accepted invalid producer input "+name);
    }
    public static void main(String[] args) throws Exception {
        if(args.length!=1)throw new IllegalArgumentException("A224JoinCases NEW_OUTPUT_TSV");
        var m=CompUtil.parseEverything_fromString(null,SOURCE);
        var matrix=choices(m,"X->A","Y->P","Z->B");var right=choices(m,"A->U","B->V","P->W");
        verify("mixed-matrix",matrix,right,3,2,2,2,7);
        verify("two-projected-equal-results",choices(m,"X->A","X->B"),choices(m,"A->U","B->U"),2,0,0,2,1);
        verify("projected-subtype-absorption",choices(m,"A->U","P->V"),choices(m,"U->X","V->X"),2,0,0,2,1);
        verify("correlated-repeated-columns",parse(m,"X->X->A"),parse(m,"A->U->U"),1,0,0,0,1);
        verify("all-disjoint-common-P",parse(m,"X->A"),parse(m,"B->Y"),0,0,0,1,0);
        verify("all-disjoint-common-univ",parse(m,"X->A"),parse(m,"W->Y"),0,0,0,1,0);
        verify("explicit-univ-left",parse(m,"X->univ"),parse(m,"P->Y"),0,0,1,0,1);
        verify("explicit-univ-right",parse(m,"X->P"),parse(m,"univ->Y"),0,1,0,0,1);
        verify("empty-left",DependentTypeDag.empty(4),right,0,0,0,0,0);
        verify("empty-right",matrix,DependentTypeDag.empty(3),0,0,0,0,0);
        verify("empty-both",DependentTypeDag.empty(1),DependentTypeDag.empty(2),0,0,0,0,0);
        verify("left-unary",parse(m,"A"),parse(m,"P->U"),0,1,0,0,1);
        verify("right-unary",parse(m,"X->P"),parse(m,"A"),0,0,1,0,1);
        var a=parse(m,"A");var b=parse(m,"B");
        rejected("nullary-result",()->DependentTypeDag.combine(DependentChainKind.JOIN,a,b),
                DependentChainTheory.UnsupportedFlattening.class,"nullary");
        rejected("checked-arity-overflow",()->DependentTypeDag.combine(DependentChainKind.JOIN,DependentTypeDag.empty(Integer.MAX_VALUE),b),
                ArithmeticException.class,"overflow");
        var foreign=parse(CompUtil.parseEverything_fromString(null,SOURCE),"A->U");
        rejected("different-live-modules",()->DependentTypeDag.combine(DependentChainKind.JOIN,matrix,foreign),
                IllegalArgumentException.class,"mixes parser-module");
        var raw=DependentTypeDag.exactRelation(GraphType.relation(GraphType.constructor("AlloySig:B"),GraphType.constructor("AlloySig:U")));
        var narrow=parse(m,"X->A");
        rejected("unsupported-boundary-is-not-omitted",()->DependentTypeDag.combine(DependentChainKind.JOIN,narrow,raw),
                DependentBoundaryCorrespondence.UnsupportedCorrespondence.class,"one live parser module");
        Files.write(Path.of(args[0]),ROWS,StandardOpenOption.CREATE_NEW);
        System.out.println("A224 producer cases passed: "+(ROWS.size()-1));
    }
}
