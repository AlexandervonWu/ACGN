package is.fivefivefive.CanDis.theory;

import com.sun.source.tree.MethodTree;
import java.util.*;

/** Recognizes the admission and source-sequence stages inside the independently
 * bound methods. Unrecognized method shapes fail the contract. */
final class A223AdmissionCode {
    private A223AdmissionCode() {}
    private static String body(Map<String,MethodTree> methods,String key) {
        return Objects.requireNonNull(methods.get(key),key).getBody().toString().replaceAll("\\s+","");
    }
    private static void ordered(String body,String... operations) {
        int start=0;
        for(String op:operations) {
            int at=body.indexOf(op,start);
            if(at<0)throw new IllegalArgumentException("unrecognized compiled admission stage "+op);
            start=at+op.length();
        }
    }
    static List<String> read(Map<String,MethodTree> methods) {
        var stages=new ArrayList<String>();
        var n=body(methods,"DependentTypeDag#normalize/1");
        ordered(n,"for(List<DependentColumnEvidence>source:sourceAlternatives)",
                "product.isEmpty()","arity=product.size()","product.size()!=arity","copied.add(product)",
                "requireCompatibleAuthority(copied)","DependentChainTheory.requireConsistentHierarchy(copied)");
        stages.add("admission:positive-uniform-width-and-compatible-authority");
        ordered(n,"newLinkedHashMap<>()","for(List<DependentColumnEvidence>product:copied)","type=productType(product)",
                "previous=unique.get(type)","previous==null","unique.put(type,product)","continue;",
                "!previous.equals(product)","unique.put(type,preferAuthenticated(previous,product))","newArrayList<>(unique.values())");
        ordered(body(methods,"DependentTypeDag#preferAuthenticated/2"),
                "index=0;index<left.size();index++",
                "!left.get(index).hasParserModuleAuthority()&&right.get(index).hasParserModuleAuthority()",
                "merged==null","merged=newArrayList<>(left)","merged.set(index,right.get(index))",
                "returnmerged==null?left:List.copyOf(merged)");
        stages.add("group:exact-product-key-prefer-authenticated-columns");
        ordered(n,"candidateIndex=0;candidateIndex<candidates.size();candidateIndex++","candidate=candidates.get(candidateIndex)",
                "otherIndex=0;otherIndex<candidates.size();otherIndex++","candidateIndex==otherIndex","continue;",
                "productSubtypeOrEqual(candidate,candidates.get(otherIndex))","absorbed=true;","break;","if(!absorbed)","antichain.add(candidate)");
        ordered(body(methods,"DependentTypeDag#productSubtypeOrEqual/2"),"specific.size()!=general.size()",
                "strict=false","index=0;index<specific.size();index++","left=specific.get(index)","right=general.get(index)",
                "left.exactColumn().equals(right.exactColumn())","continue;","DependentBoundaryCorrespondence.derive(left,right)",
                "proof.rule()!=DependentBoundaryCorrespondence.Rule.LEFT_SUBTYPE_OF_RIGHT","strict=true","returnstrict;");
        stages.add("prune:all-other-products-strict-coordinate-subtype");
        if(n.contains("antichain.sort(Comparator.comparing(DependentTypeDag::productType))")) stages.add("sort:by-structural-product-type");
        else if(n.contains("Collections.reverse(antichain)"))stages.add("sort:reverse");
        else throw new IllegalArgumentException("unrecognized sort");
        ordered(body(methods,"DependentTypeDag#productType/1"),
                "GraphType.relation(product.stream().map(DependentColumnEvidence::exactColumn).toList())");
        ordered(body(methods,"GraphType#compareTo/1"),"Integer.compare(kind.ordinal(),other.kind.ordinal())","returncompared",
                "compareNullable(symbol,other.symbol)","returncompared","Math.min(arguments.size(),other.arguments.size())",
                "i=0;i<shared;i++","arguments.get(i).compareTo(other.arguments.get(i))","returncompared","Integer.compare(arguments.size(),other.arguments.size())");
        ordered(body(methods,"GraphType#compareNullable/2"),"left==null","right==null?0:-1","right==null?1:left.compareTo(right)");
        ordered(body(methods,"DependentColumnEvidence#isAdmittedAtomicColumn/1"),
                "type.kind()==GraphType.Kind.INT","returntrue","type.kind()!=GraphType.Kind.CONSTRUCTOR",
                "!type.arguments().isEmpty()","!type.symbol().startsWith(\"AlloySig:\")");
        if(GraphType.Kind.INT.ordinal()>=GraphType.Kind.CONSTRUCTOR.ordinal())throw new IllegalArgumentException("atomic kind order");
        stages.add("type-order:int-before-nominal-UTF16-then-lex-columns");
        ordered(n,"for(List<DependentColumnEvidence>product:antichain)","frozen.add(Collections.unmodifiableList(newArrayList<>(product)))",
                "returnCollections.unmodifiableList(frozen)");
        stages.add("freeze:rows-and-ordered-column-evidence");
        ordered(body(methods,"DependentTypeDag#combine/3"),"Math.addExact(left.arity(),right.arity())",
                "products.isEmpty()?empty(resultArity):newDependentTypeDag(products)","cases,left.alternatives.size(),right.alternatives.size()");
        stages.add("return:typed-empty-or-normalized-products-and-cases");
        ordered(body(methods,"DependentChainApplication#<init>/3"),"DependentTypeDag.combine(kind,left.outputTypeDag(),right.outputTypeDag())",
                "ordered.addAll(left.leaves())","ordered.addAll(right.leaves())","this.leaves=Collections.unmodifiableList(ordered)");
        stages.add("source:append-left-leaves-then-right-leaves");
        return List.copyOf(stages);
    }
}
