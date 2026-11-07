package is.fivefivefive.CanDis.core;

import java.nio.file.*;
import java.util.*;
import java.util.function.Consumer;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.ir.IRAgent;
import parser.ast.nodes.ModelUnit;

/** Guards for the new grouped-owner slice; no source equality is inferred from a paid edit. */
public final class GroupedPaidDeclarationAlignmentTest {
    private static int checks;
    private static void check(boolean value,String why) {
        checks++; if(!value) throw new AssertionError(why);
    }
    private static void reject(Runnable action,String why) {
        checks++;
        try { action.run(); } catch(IllegalArgumentException | IllegalStateException expected) { return; }
        throw new AssertionError(why);
    }
    private static List<NormalForm> prepare(String source,String predicate) throws Exception {
        var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,source);
        var visitor=new MASGVisitor(new GlobalVariables(),Set.of(predicate),module);
        visitor.visit(new ModelUnit(null,module),null);
        var agent=new IRAgent(visitor.getForest().get(visitor.getForestId(predicate)));
        agent.computeNormalForm();
        var forms=List.copyOf(agent.normalForms());
        forms.forEach(NormalForm::freezeForCertification);
        return forms;
    }
    private static NormalForm changed(NormalForm source,boolean aliases,Consumer<List<QuantiVar>> edit) {
        List<QuantiVar> vars=new ArrayList<>();
        for(var q:source.getMatrixQuantiVars()) {
            var copy=new QuantiVar(q.getId(),q.getName(),q.getOriginalName(),q.getTypeName());
            if(aliases) q.getOriginalNames().forEach(copy::addOriginalName);
            copy.setCarrierTypeName(q.getCarrierTypeName()); copy.setBindingPath(q.getBindingPath());
            copy.setDeBruijnKey(q.getDeBruijnKey()); copy.setQuantifier(q.getQuantifier());
            copy.setCardinality(q.getCardinality()); copy.setDisjointnessClass(q.getDisjointnessClass());
            copy.mergeExactAlloyType(q.getExactAlloyType()); vars.add(copy);
        }
        edit.accept(vars);
        var result=new NormalForm(); result.addEClass(source.getCertificationMatrixEGraph());
        vars.forEach(result::addMatrixQuantiVar); result.freezeForCertification(); return result;
    }
    private static void unsupported(NormalForm source,Consumer<List<QuantiVar>> edit,String why) {
        check(!FastPaidDeclarationAlignment.supports(List.of(changed(source,true,edit))),why);
    }
    public static void main(String[] args) throws Exception {
        String original=Files.readString(Path.of("classified-data/classroom_fol/both/8dTfKqTs26w6fL87K_inv15.als"));
        var forms=prepare(original,"inv15"); var form=forms.get(0);
        var before=CanonicalDistance.sourceIrTemporalFol(forms);
        check(FastPaidDeclarationAlignment.supports(forms),"actual grouped declaration admitted");
        check(form.getMatrixQuantiVars().size()==3,"three slots retained, not owner-deduplicated");
        check(form.getMatrixQuantiVars().stream().map(QuantiVar::getBindingPath).distinct().count()==1,
                "one actual owner");
        check(form.getMatrixQuantiVars().stream().map(QuantiVar::getDeBruijnKey).distinct().count()==3,
                "three source slot identities");
        check(FastPaidDeclarationAlignment.supports(List.of(changed(form,true,ignored -> {}))),
                "exact frozen source evidence retained");
        check(!FastPaidDeclarationAlignment.supports(List.of(changed(form,false,ignored -> {}))),
                "names without original semantic occurrence aliases rejected");
        unsupported(form,qs -> qs.get(1).setDeBruijnKey(qs.get(0).getDeBruijnKey()),"duplicate slot key");
        unsupported(form,qs -> qs.get(1).setDeBruijnKey("foreign#1:ONE:Person"),"foreign declaration owner");
        unsupported(form,qs -> qs.get(1).setDeBruijnKey(qs.get(1).getBindingPath()+"#-1:ONE:Person"),"negative slot");
        unsupported(form,qs -> qs.get(1).setDeBruijnKey(qs.get(1).getBindingPath()+"#3:ONE:Person"),"missing slot");
        unsupported(form,qs -> Collections.swap(qs,0,1),"metadata order cannot substitute slot order");
        unsupported(form,qs -> qs.get(1).addOriginalName(qs.get(0).getOriginalName()),"overlapping occurrence aliases");
        unsupported(form,qs -> qs.get(1).setCarrierTypeName("Teacher"),"literal carrier substitution");
        unsupported(form,qs -> qs.get(1).setCardinality(QuantiVar.Cardinality.SET),"multiplicity substitution");
        unsupported(form,qs -> qs.get(1).setDisjointnessClass(1),"disjoint group unsupported");
        unsupported(form,qs -> qs.get(1).setQuantifier(QuantiVar.Quantifier.ALL),"mixed owner kind");
        unsupported(form,qs -> qs.forEach(q -> q.setQuantifier(QuantiVar.Quantifier.LONE)),"grouped LONE not admitted");
        unsupported(form,qs -> qs.forEach(q -> q.setQuantifier(QuantiVar.Quantifier.ONE)),"grouped ONE not admitted");
        var foreign=prepare(original,"inv15").get(0);
        unsupported(form,qs -> qs.set(1,foreign.getMatrixQuantiVars().get(1)),"foreign parser-module evidence");
        var foreignMatrix=new NormalForm(); foreignMatrix.addEClass(foreign.getCertificationMatrixEGraph());
        form.getMatrixQuantiVars().forEach(foreignMatrix::addMatrixQuantiVar); foreignMatrix.freezeForCertification();
        check(!FastPaidDeclarationAlignment.supports(List.of(foreignMatrix)),
                "same-spelled leaves from another source module cannot authenticate grouped slots");
        reject(() -> form.getMatrixQuantiVars().get(1).setDeBruijnKey("forged"),"frozen slot cannot mutate");
        check(before.equals(CanonicalDistance.sourceIrTemporalFol(forms)),"all guards preserve source authority");

        String model="""
                sig A { r:set A }
                sig B {}
                pred groupedSome { some x,y:A | x->y in r }
                pred groupedAll { all x,y:A | x->y in r }
                pred repeated { some x,y:A | x->x in r and x->y in r }
                pred separate { some x:A | some y:A | x->y in r }
                pred mixed { all x:A | some y:A | x->y in r }
                pred parameter[z:A] { some x,y:A | x->y in r and y->z in r }
                pred temporal { some x,y:A | always x->y in r }
                pred local { some x,y:A | x->y in r and (one z:B | some z) }
                pred disjoint { some disj x,y:A | x->y in r }
                pred sets { some x,y:set A | x->y in r }
                pred unused { some x,y:A | x->x in r }
                """;
        for(String name:List.of("groupedSome","groupedAll","repeated","separate","mixed"))
            check(FastPaidDeclarationAlignment.supports(prepare(model,name)),"supported original "+name);
        for(String name:List.of("parameter","temporal","local","disjoint","sets","unused"))
            check(!FastPaidDeclarationAlignment.supports(prepare(model,name)),"unsupported scope "+name);

        var separate=prepare(model,"separate").get(0);
        unsupported(separate,qs -> qs.get(1).setBindingPath(qs.get(0).getBindingPath()),
                "same-spelled owner without source slot evidence rejected");
        // A bare synthetic tree cannot stand in for an admitted source graph.
        var huge=new EGraphNode(0,EGraphNode.Opcode.AND,new ArrayList<>(),true,5000,true,EGraphNode.Metatype.BOOLEAN);
        for(int i=0;i<4097;i++) huge.addChild(new EGraphNode(i+1,EGraphNode.Opcode.AND,
                new ArrayList<>(),true,0,true,EGraphNode.Metatype.BOOLEAN));
        var bounded=new NormalForm(); bounded.addEClass(huge);
        form.getMatrixQuantiVars().forEach(bounded::addMatrixQuantiVar);
        reject(() -> { bounded.freezeForCertification(); FastPaidDeclarationAlignment.supports(List.of(bounded)); },
                "unadmitted source graph fails closed");
        System.out.println("GroupedPaidDeclarationAlignmentTest: "+checks+" checks passed");
    }
}
