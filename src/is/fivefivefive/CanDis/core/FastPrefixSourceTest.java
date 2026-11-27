package is.fivefivefive.CanDis.core;

import java.util.*;
import java.lang.reflect.Field;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.ir.IRAgent;
import is.fivefivefive.CanDis.theory.TheoryAlloyAdapter;
import is.fivefivefive.CanDis.metric.RepairProjection;
import is.fivefivefive.CanDis.theory.CanonicalizationDomainException;
import parser.ast.nodes.ModelUnit;

public final class FastPrefixSourceTest {
    private static int checks;
    private static final String SOURCE = "sig A {r:set A} pred p {all x:A | all y:A | y->x in r}";
    private record Endpoint(NormalForm source, NormalForm comparison) { }
    private static void check(boolean ok,String why) {
        checks++; if(!ok) throw new AssertionError(why);
    }
    private static Endpoint endpoint() throws Exception {
        var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,
                SOURCE);
        var visitor=new MASGVisitor(new GlobalVariables(),Set.of("p"),module);
        visitor.visit(new ModelUnit(null,module),null);
        return endpoint(visitor,"p");
    }
    private static Endpoint endpoint(MASGVisitor visitor, String name) {
        var agent=new IRAgent(visitor.getForest().get(visitor.getForestId(name)));
        agent.computeNormalForm();
        var forms=agent.normalForms();
        var prepared=CanonicalDistance.prepare(forms);
        return new Endpoint(forms.get(0),prepared.comparisonForms().get(0));
    }

    private static void countingPriorControls() throws Exception {
        String model = """
                sig A { r,s: set B } sig B {}
                pred earlier { one a:A | all b:B | a->b in r }
                pred later { all b:B | one a:A | a->b in r }
                pred atMost { all b:B | lone a:A | a->b in r }
                pred dependent { all a:A | one b:a.r | a->b in s }
                pred rangeR { one b:A.r | some s.b }
                pred rangeS { one b:A.s | some s.b }
                pred retained { some a:A | (one b:B | a->b in r) iff some a.s }
                pred comprehension { some { a:A | one b:B | a->b in r } }
                pred shadow { one x:A | some x.r and (one x:B | some r.x) }
                """;
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, model);
        var visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null,module), null);
        var first = endpoint(visitor,"earlier");
        var second = endpoint(visitor,"later");
        var a = first.source.getMatrixQuantiVars().get(0);
        var b = second.source.getMatrixQuantiVars().get(1);
        var firstPrior = FastPrefixSource.countingPrior(first.source,first.comparison);
        var ca = firstPrior.get(a);
        var cb = FastPrefixSource.countingPrior(second.source,second.comparison).get(b);
        check(!a.getBindingPath().equals(b.getBindingPath()) && ca != null && ca.licenses(a,b,cb),
                "Differently presented independent ONE occurrences carry authentic source coordinates");
        // Probe the two private search inputs on genuine prepared endpoints.
        // Ordinary alpha search still sees lexical paths; only the paid prior
        // supplies the source-issued coordinates exercised by the native test.
        var ordinary = CanonicalDistance.class.getDeclaredMethod("variableBindings",NormalForm.class);
        ordinary.setAccessible(true);
        var ordinaryA = ((Map<?,?>)ordinary.invoke(null,first.comparison)).get(a.getName());
        var ordinaryB = ((Map<?,?>)ordinary.invoke(null,second.comparison)).get(b.getName());
        var compatible = ordinaryA.getClass().getDeclaredMethod("compatibleWith",ordinaryA.getClass());
        compatible.setAccessible(true);
        check(!(boolean)compatible.invoke(ordinaryA,ordinaryB) && (boolean)compatible.invoke(ordinaryA,ordinaryA),
                "Ordinary residual alpha matching preserves lexical scope");
        var paid = CanonicalDistance.class.getDeclaredMethod("variableBindings",NormalForm.class,Map.class);
        paid.setAccessible(true);
        var paidA = ((Map<?,?>)paid.invoke(null,first.comparison,firstPrior)).get(a.getName());
        var paidB = ((Map<?,?>)paid.invoke(null,second.comparison,
                FastPrefixSource.countingPrior(second.source,second.comparison))).get(b.getName());
        check((boolean)compatible.invoke(paidA,paidB) && !(boolean)compatible.invoke(paidA,ordinaryB),
                "Paid prior matching requires coordinates for both endpoints");
        check(!ca.licenses(a,b,null) && FastPrefixSource.countingPrior(second.source,first.comparison).isEmpty(),
                "A missing or foreign endpoint cannot erase a lexical path");
        var foreign = endpoint(visitor,"earlier").source.getMatrixQuantiVars().get(0);
        check(foreign != a && foreign.equals(a) && firstPrior.get(foreign) == null && !ca.licenses(foreign,b,cb),
                "A matching numeric ID from a new preparation cannot borrow authority");

        var atMost = endpoint(visitor,"atMost");
        var lone = atMost.source.getMatrixQuantiVars().get(1);
        var loneCoordinate = FastPrefixSource.countingPrior(atMost.source,atMost.comparison).get(lone);
        check(loneCoordinate != null && !ca.licenses(a,lone,loneCoordinate),
                "ONE and LONE preserve separate multiplicity");
        var dependent = endpoint(visitor,"dependent");
        var child = dependent.source.getMatrixQuantiVars().get(1);
        check(!child.getDeclarationFrames().get(0).dependencies().isEmpty()
                && !FastPrefixSource.countingPrior(dependent.source,dependent.comparison).containsKey(child),
                "The original dependent domain blocks path erasure even after lowering to a carrier");

        var rangeR = endpoint(visitor,"rangeR");
        var rangeS = endpoint(visitor,"rangeS");
        var r = rangeR.source.getMatrixQuantiVars().get(0);
        var s = rangeS.source.getMatrixQuantiVars().get(0);
        var cr = FastPrefixSource.countingPrior(rangeR.source,rangeR.comparison).get(r);
        var cs = FastPrefixSource.countingPrior(rangeS.source,rangeS.comparison).get(s);
        check(r.getCarrierTypeName().equals(s.getCarrierTypeName()) && cr != null && cs != null
                && !cr.licenses(r,s,cs), "Distinct original domains with the same carrier remain distinct");

        for (String name : List.of("retained","comprehension","shadow")) {
            var scope = endpoint(visitor,name);
            var local = scope.comparison.getLocalQuantiVars().stream()
                    .filter(FastPrefixSource::countingBinder).findFirst().orElseThrow();
            var prior = FastPrefixSource.countingPrior(scope.source,scope.comparison);
            check(!prior.containsKey(local), "Nested and local occurrences cannot use prefix authority: "+name);
            if (name.equals("shadow")) {
                var outer = scope.source.getMatrixQuantiVars().get(0);
                check(outer != local && outer.getOriginalName().equals(local.getOriginalName())
                        && !ca.licenses(a,local,prior.get(outer)), "A shadowed spelling is a different occurrence");
            }
        }
    }
    private static void reject(Runnable work,String why) {
        checks++;
        try {work.run();} catch(IllegalArgumentException|IllegalStateException expected) {return;}
        throw new AssertionError(why);
    }
    private static void rejectExactly(Runnable work,Class<? extends RuntimeException> type,String message) {
        checks++;
        try {work.run();} catch(RuntimeException expected) {
            if(expected.getClass()==type && message.equals(expected.getMessage())) return;
            throw new AssertionError("Wrong rejection: "+expected,expected);
        }
        throw new AssertionError("Expected "+message);
    }
    private static EGraphNode field(EGraphNode n) {
        if(n.getChildren().isEmpty() && n.getExactAlloyType()!=null
                && n.getExactAlloyType().kind()==ExactAlloyType.Kind.RELATION
                && n.getExactAlloyType().relationArity()==2)return n;
        for(var c:n.getChildren()){var found=field(c);if(found!=null)return found;}
        return null;
    }
    private static EGraphNode booleanOperand(EGraphNode n) {
        for(var c:n.getChildren()){var found=booleanOperand(c);if(found!=null)return found;}
        return n.getMetatype()==EGraphNode.Metatype.BOOLEAN ? n : null;
    }
    private static void corrupt(Object target,String name,Object value,Runnable check) throws Exception {
        Field field=target.getClass().getDeclaredField(name);field.setAccessible(true);
        Object original=field.get(target);
        try {field.set(target,value);check.run();} finally {field.set(target,original);}
    }
    private static EGraphNode variable(EGraphNode n,String name) {
        if(n.getOpcode()==EGraphNode.Opcode.VARIABLE && name.equals(n.getAlphaName()))return n;
        for(var c:n.getChildren()){var found=variable(c,name);if(found!=null)return found;}
        return null;
    }
    public static void main(String[] args) throws Exception {
        countingPriorControls();
        var e=endpoint();var foreign=endpoint();
        var full=TheoryAlloyAdapter.adapt(List.of(e.source));
        RepairProjection.project(full,List.of(e.source));
        var prefix=FastPrefixSource.checkedPlan(e.source,e.comparison);
        check(prefix.descriptor().structuralKey().equals(full.phaseBinderDescriptors().get(0).structuralKey()),
                "exact old descriptor, not carrier spelling");
        check(prefix.sourceToCoordinate().equals(full.phaseSourceCoordinates().get(0)),"same occurrence coordinates");
        check(FastGroupedDeclarationOrbit.orders(e.source,e.comparison,e.source.getMatrixQuantiVars()).size()==2,
                "separate singleton source declarations retain exchange");
        var qs=e.source.getMatrixQuantiVars();
        check(prefix.sourceToCoordinate().equals(List.of(0,1)),"Lean source coordinate instance");
        check(qs.stream().allMatch(v->v.getQuantifier()==QuantiVar.Quantifier.ALL
                && v.getCardinality()==QuantiVar.Cardinality.ONE && v.getTypeName().equals("A")
                && v.getExactAlloyType().hasParserAuthenticatedAncestry()),"Lean typed independent ALL instance");
        check(!qs.get(0).getBindingPath().equals(qs.get(1).getBindingPath()),"distinct source owners retained");
        check(prefix.descriptor().coordinates().stream().allMatch(c->c.dependencies().isEmpty()),
                "Lean independent domains");
        var swap=FastGroupedDeclarationOrbit.orders(e.source,e.comparison,qs).get(1);
        check(Arrays.equals(swap,new int[]{1,0}),"Lean permutation instance");
        var paid=Map.of(qs.get(0).getName(),qs.get(0).getName(),qs.get(1).getName(),qs.get(1).getName());
        var transported=FastGroupedDeclarationOrbit.transport(qs,qs,paid,swap,new int[]{0,1});
        check(transported.equals(Map.of(qs.get(1).getName(),qs.get(0).getName(),
                qs.get(0).getName(),qs.get(1).getName())),"actual Java occurrence transport equals Lean swap");
        check(FastGroupedDeclarationOrbit.transport(qs,qs,transported,swap,new int[]{0,1}).equals(paid),
                "both-direction transport restores original owners");
        var receipt=new org.json.JSONObject().put("source",SOURCE)
                .put("sourceSha256",java.util.HexFormat.of().formatHex(java.security.MessageDigest.getInstance("SHA-256")
                        .digest(SOURCE.getBytes(java.nio.charset.StandardCharsets.UTF_8))))
                .put("phase",0).put("sourceCoordinates",prefix.sourceToCoordinate()).put("swap",swap)
                .put("ownerPaths",qs.stream().map(QuantiVar::getBindingPath).toList())
                .put("typedSlots",qs.stream().map(QuantiVar::getDeBruijnKey).toList())
                .put("transport",transported).put("oldRejection","canon_G work exceeds configured bound 1");
        check(receipt.getString("sourceSha256").equals("44416ad3f03c8e9d3c5fd76d080f6adc683fc2e04c57bb696e03791f503317d0"),
                "Lean exact source hash");
        check(qs.stream().map(QuantiVar::getBindingPath).toList().equals(List.of(
                "root/predicate[0]/decl[0]@pos","root/predicate[0]/body[1]/decl[0]@pos")),"Lean concrete owners");
        check(qs.stream().map(QuantiVar::getDeBruijnKey).toList().equals(List.of(
                "root/predicate[0]/decl[0]@pos#0:ONE:A","root/predicate[0]/body[1]/decl[0]@pos#0:ONE:A")),
                "Lean concrete typed slots");
        reject(()->FastGroupedDeclarationOrbit.transport(qs,qs,paid,new int[]{0,0},swap),
                "non-bijective transport rejected");
        System.out.println("correspondence="+receipt);
        reject(()->FastPrefixSource.checkedPlan(e.source,foreign.comparison),"foreign source rejected");
        var q=e.source.getMatrixQuantiVars().get(0);
        var n=Objects.requireNonNull(variable(e.source.getCertificationMatrixEGraph(),q.getName()));
        corrupt(n,"exactAlloyType",ExactAlloyType.unaryRelation(q.getTypeName()),
                ()->reject(()->FastPrefixSource.checkedPlan(e.source,e.comparison),"unauthenticated singleton type"));
        corrupt(n,"semanticIdentity","foreign-owner",
                ()->reject(()->FastPrefixSource.checkedPlan(e.source,e.comparison),"foreign singleton alias"));
        var current=Objects.requireNonNull(variable(e.comparison.getMatrixEGraph(),q.getName()));
        corrupt(current,"alphaName",e.source.getMatrixQuantiVars().get(1).getName(),
                ()->reject(()->FastPrefixSource.checkedPlan(e.source,e.comparison),"capturing outer occurrence"));
        var relation=Objects.requireNonNull(field(e.source.getCertificationMatrixEGraph()));
        corrupt(relation,"exactAlloyType",null,()->{
            String message="Theory-faithful adaptation requires an exact occurrence type for "+relation.getOpcode();
            rejectExactly(()->TheoryAlloyAdapter.adapt(List.of(e.source)),IllegalStateException.class,message);
            rejectExactly(()->FastPrefixSource.checkedPlan(e.source,e.comparison),IllegalStateException.class,message);
        });
        corrupt(Objects.requireNonNull(booleanOperand(e.source.getCertificationMatrixEGraph())),
                "exactAlloyType",qs.get(0).getExactAlloyType(),()->{
            String message="Boolean IR node carries a non-Boolean exact Alloy type";
            rejectExactly(()->TheoryAlloyAdapter.adapt(List.of(e.source)),IllegalStateException.class,message);
            rejectExactly(()->FastPrefixSource.checkedPlan(e.source,e.comparison),IllegalStateException.class,message);
        });
        var orphan=Objects.requireNonNull(booleanOperand(e.source.getCertificationMatrixEGraph()));
        corrupt(orphan,"opcode",EGraphNode.Opcode.GENERICRELDECL,()->{
            orphan.requireAdmittedArity();
            check(FastPaidDeclarationAlignment.supports(List.of(e.source)),
                    "ordinary no-local eligibility is not declaration owner authority");
            rejectExactly(()->FastPrefixSource.checkedPlan(e.source,e.comparison),IllegalArgumentException.class,
                    "Unowned prefix declaration");
        });
        String prior=System.getProperty("acgn.maxCanonicalWorkItems");
        try {
            System.setProperty("acgn.maxCanonicalWorkItems","1");
            rejectExactly(()->TheoryAlloyAdapter.adapt(List.of(e.source)),CanonicalizationDomainException.class,
                    "canon_G work exceeds configured bound 1");
            check(FastGroupedDeclarationOrbit.orders(e.source,e.comparison,e.source.getMatrixQuantiVars()).size()==2,
                    "prefix exchange needs no full graph construction");
        } finally {
            if(prior==null)System.clearProperty("acgn.maxCanonicalWorkItems");
            else System.setProperty("acgn.maxCanonicalWorkItems",prior);
        }
        check(FastPrefixSource.checkedPlan(e.source,e.comparison).descriptor().structuralKey()
                .equals(prefix.descriptor().structuralKey()),"negative controls leave original source intact");
        System.out.println("FastPrefixSourceTest: "+checks+" checks passed");
    }
}
