package is.fivefivefive.CanDis.core;

import java.nio.file.*;
import java.util.*;
import org.json.*;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.Canonical;
import is.fivefivefive.CanDis.DistanceReplayDiagnostics;
import is.fivefivefive.CanDis.ir.IRAgent;
import is.fivefivefive.CanDis.metric.*;
import is.fivefivefive.CanDis.theory.AlloyTypeBridge;
import is.fivefivefive.CanDis.theory.GraphType;
import parser.ast.nodes.ModelUnit;

/** Source-linked paid declaration paths and independently replayed native endpoints. */
public final class DeclarationOrbitShorterReplayTest {
    public static final Path SOURCE=Path.of("classified-data/classroom_fol/both/SASEHD8jPo2HgsuoJ_inv14.als");
    private static int checks;
    private static void check(boolean value,String why) { checks++; if(!value) throw new AssertionError(why); }
    private static void reject(Runnable action,String why) {
        checks++; try { action.run(); } catch(IllegalArgumentException | IllegalStateException expected) { return; }
        throw new AssertionError(why);
    }
    private static String variable(EGraphNode n) { return n.getAlphaName()==null?n.getSourceName():n.getAlphaName(); }
    private static GraphType type(EGraphNode n) {
        if(n.getOpcode()==EGraphNode.Opcode.VARIABLE || n.getOpcode()==EGraphNode.Opcode.GENERICRELDECL) return null;
        if(n.getMetatype()==EGraphNode.Metatype.BOOLEAN) return GraphType.BOOL;
        return AlloyTypeBridge.graphType(Objects.requireNonNull(n.getExactAlloyType()));
    }
    private static String atom(EGraphNode n) {
        if(n.getOpcode()==EGraphNode.Opcode.CALL) throw new IllegalArgumentException("Call outside incident slice");
        if(n.getSemanticIdentity()==null && n.getOpcode()==EGraphNode.Opcode.GLOBALBINDING
                && n.getSourceType()!=null && n.getSourceType().startsWith("FieldRelation")) {
            String name=Objects.requireNonNull(n.getSourceName());
            return "alloy/field/"+name.length()+":"+name+"/"+n.getExactAlloyType().stableString();
        }
        return n.getSemanticIdentity()==null?n.getSourceName():n.getSemanticIdentity();
    }
    private static MatrixReplay<EGraphNode> checker(Map<String,String> labelMapping,Map<String,String> mapping) {
        Map<String,String> reverse=new HashMap<>();
        for(var entry:mapping.entrySet()) if(reverse.put(entry.getValue(),entry.getKey())!=null)
            throw new IllegalArgumentException("Noninjective selected mapping");
        return new MatrixReplay<>(new MatrixReplay.NativeCost<EGraphNode>() {
            public String label(EGraphNode n) {
                return new JSONArray().put(n.getOpcode().name()).put(String.valueOf(type(n)))
                        .put(String.valueOf(n.getSourceName())).put(String.valueOf(atom(n))).put("")
                        .put(n.getFlexibleArityKind().name()).put(n.isOrderInsensitive())
                        .put(new TreeMap<>(labelMapping).toString()).toString();
            }
            public List<EGraphNode> children(EGraphNode n) { return FastChainGeometry.children(n); }
            public List<EGraphNode> alternatives(EGraphNode n) { return List.of(); }
            public boolean unordered(EGraphNode a,EGraphNode b) { return a.getOpcode()==b.getOpcode() && a.isOrderInsensitive() && b.isOrderInsensitive(); }
            public int size(EGraphNode n) {
                if(n==null) return 0;
                int sum=1; for(var child:children(n)) sum=Math.addExact(sum,size(child)); return sum;
            }
            public int update(EGraphNode a,EGraphNode b) {
                if(a.getOpcode()!=b.getOpcode()) return 1;
                if(a.getOpcode()==EGraphNode.Opcode.VARIABLE) {
                    String x=variable(a),y=variable(b);
                    if(mapping.containsKey(x)) return mapping.get(x).equals(y)?0:1;
                    if(reverse.containsKey(y)) return 1;
                    return x.equals(y)?0:1;
                }
                if(!Objects.equals(type(a),type(b))) return 1;
                return switch(a.getOpcode()) {
                    case GLOBALBINDING,CONSTANT,REF -> Objects.equals(atom(a),atom(b))?0:1;
                    default -> 0;
                };
            }
            public int distance(EGraphNode a,EGraphNode b) { throw new AssertionError("Replay cannot search distance"); }
        });
    }
    private static List<DeclarationReplay.Atom> declarations(NormalForm form) {
        List<QuantiVar> qs=form.getMatrixQuantiVars();
        List<Integer> order=new ArrayList<>(); for(int i=0;i<qs.size();i++) order.add(i);
        for(int start=0;start<order.size();) {
            int end=start+1;
            var kind=qs.get(start).getQuantifier();
            if(kind==QuantiVar.Quantifier.ALL || kind==QuantiVar.Quantifier.SOME) {
                while(end<order.size() && qs.get(end).getQuantifier()==kind) end++;
                order.subList(start,end).sort(Comparator.comparing(i -> qs.get(i).getCarrierTypeName()));
            }
            start=end;
        }
        List<DeclarationReplay.Atom> result=new ArrayList<>();
        for(int i:order) {
            QuantiVar q=qs.get(i);
            String admission=new JSONArray().put(q.getName()).put(q.getOriginalName()).put(q.getBindingPath())
                    .put(q.getCarrierTypeName()).put(String.valueOf(q.getExactAlloyType())).toString();
            result.add(new DeclarationReplay.Atom("phase/0/declaration/"+i,List.of(q.getQuantifier().name(),
                    q.getCarrierTypeName(),q.getCardinality().name(),Integer.toString(q.getDisjointnessClass())),admission));
        }
        return result;
    }

    private static int[][] dp(List<DeclarationReplay.Atom> a,List<DeclarationReplay.Atom> b) {
        int[][] d=new int[a.size()+1][b.size()+1];
        for(int i=0;i<=a.size();i++) d[i][0]=i;
        for(int j=0;j<=b.size();j++) d[0][j]=j;
        for(int i=1;i<=a.size();i++) for(int j=1;j<=b.size();j++)
            d[i][j]=Math.min(d[i-1][j-1]+(a.get(i-1).tuple().equals(b.get(j-1).tuple())?0:1),
                    Math.min(d[i-1][j]+1,d[i][j-1]+1));
        return d;
    }
    public static void main(String[] args) throws Exception {
        if(args.length>2) throw new IllegalArgumentException("[ARCHIVED_RECEIPT [NEW_SUPPLEMENT_JSON]]");
        byte[] bytes=Files.readAllBytes(SOURCE);
        var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,new String(bytes,java.nio.charset.StandardCharsets.UTF_8));
        var forms=new ArrayList<NormalForm>(); var prepared=new ArrayList<Canonical.Prepared>();
        for(String name:List.of("inv14","inv14c")) {
            var visitor=new MASGVisitor(new GlobalVariables(),Set.of(name),module);
            visitor.visit(new ModelUnit(null,module),null);
            var graph=visitor.getForest().get(visitor.getForestId(name));
            var agent=new IRAgent(graph); agent.computeNormalForm();
            check(agent.normalForms().size()==1,"single original phase");
            var form=agent.normalForms().get(0); form.freezeForCertification(); forms.add(form);
            prepared.add(Canonical.prepare(graph));
        }
        var report=args.length==0?DistanceReplayDiagnostics.capture(prepared.get(0),prepared.get(1)):
                new JSONObject(Files.readString(Path.of(args[0])));
        boolean reverse=args.length!=0 && report.getString("leftPredicate").equals("inv14c");
        if(reverse) Collections.reverse(forms);
        if(args.length!=0) check(report.getString("sourceSha256").equals(HexFormat.of().formatHex(
                java.security.MessageDigest.getInstance("SHA-256").digest(bytes))),"frozen original source hash");
        var left=forms.get(0); var right=forms.get(1);
        for(var f:forms) check(f.getTemporalChildren().isEmpty() && f.getParams().isEmpty()
                && f.getInheritedQuantiVars().isEmpty() && f.getPhaseLocalBindingImports().isEmpty(),"owner boundary");
        var original=reverse?right:left;
        check(original.getLocalQuantiVars().size()>=2,"nested local binders not hoisted");
        for(var q:original.getMatrixQuantiVars()) check(q.getQuantifier()==QuantiVar.Quantifier.ALL
                && q.getCarrierTypeName().equals("Person") && q.isFrozenForCertification()
                && q.getExactAlloyType().hasParserAuthenticatedAncestry(),"typed original ALL Person");
        var arm=report.getJSONObject("fast"); var phase=arm.getJSONArray("phases").getJSONObject(0);
        var raw=phase.getJSONObject("alphaMapping"); var selected=new HashMap<String,String>();
        for(String key:raw.keySet()) selected.put(key,raw.getString(key));
        check(selected.equals(reverse?Map.of("_q1","_q0"):Map.of("_q0","_q1")),"native shorter alpha choice");
        var completed=Map.of("_q0","_q1","_q1","_q0");
        var l=NormalForm.fastComparisonViews(List.of(left)).get(0).getMatrixEGraph();
        var r=NormalForm.fastComparisonViews(List.of(right)).get(0).getMatrixEGraph();
        var receipt=phase.getJSONObject("receipt");
        check(checker(selected,selected).verify(l,r,receipt)==26,"native matrix26 independently replayed");
        check(checker(selected,completed).verify(l,r,receipt)==26,
                "same matrix operations admit the paid complement after certified outer exchange");
        reject(() -> checker(selected,completed).verify(r,l,receipt),"endpoint substitution");
        reject(() -> checker(selected,completed).verify(l,r,new JSONObject(receipt.toString()).put("cost",25)),"cost corruption");
        var decl=arm.getJSONObject("declarationSlice").getJSONArray("components").getJSONObject(0).getJSONObject("receipt");
        var a=declarations(left); var b=declarations(right);
        check(DeclarationReplay.verify(a,b,decl)==1,"old standalone declaration receipt");
        int conflicts=0;
        for(Object item:decl.getJSONArray("operations")) {
            var op=(JSONObject)item;
            if(op.getInt("cost")==1 && op.getString("kind").equals("update")) {
                String x=new JSONArray(op.getJSONObject("source").getString("admission")).getString(0);
                String y=new JSONArray(op.getJSONObject("target").getString("admission")).getString(0);
                if(!y.equals(completed.get(x))) conflicts++;
            }
        }
        check(conflicts==1,"raw archived slices are not one coherent public plan");
        if(reverse) Collections.swap(b,0,1); else Collections.swap(a,0,1);
        var supplement=DeclarationReplay.capture(a,b,dp(a,b),(i,j)->true);
        check(DeclarationReplay.verify(a,b,supplement)==1,"source-permuted declaration path independently replayed");
        for(Object item:supplement.getJSONArray("operations")) {
            var op=(JSONObject)item;
            check(op.getInt("leftIndex")>=0 && op.getInt("rightIndex")>=0,"diagonal witness");
            String x=new JSONArray(op.getJSONObject("source").getString("admission")).getString(0);
            String y=new JSONArray(op.getJSONObject("target").getString("admission")).getString(0);
            check(y.equals(completed.get(x)),"every diagonal links to completed matrix choice");
        }
        var forged=new JSONObject(supplement.toString());
        forged.getJSONArray("source").getJSONObject(0).put("admission","foreign owner");
        reject(()->DeclarationReplay.verify(a,b,forged),"forged source admission");
        check(arm.getInt("distance")==27 && !report.getBoolean("complete")
                && !report.getBoolean("publicSequenceLinked"),"native27, full alignment blocked");
        if(args.length==2) Files.writeString(Path.of(args[1]),new JSONObject()
                .put("complete",false).put("certificationStatus","BLOCKED")
                .put("sourceSha256",HexFormat.of().formatHex(java.security.MessageDigest.getInstance("SHA-256").digest(bytes)))
                .put("rawDeclarationLinkage",false).put("sourcePermutation",reverse?"right:[1,0]":"left:[1,0]")
                .put("certificateTest","DeclarationOrbitSourceTest")
                .put("completedMapping",new JSONObject(completed)).put("matrixCost",26).put("declarationCost",1)
                .put("supplementalDeclarationReceipt",supplement).toString(2),StandardOpenOption.CREATE_NEW);
        System.out.println("DeclarationOrbitShorterReplayTest: "+checks+" checks passed; scoped27 completion, full alignment BLOCKED");
    }
}
