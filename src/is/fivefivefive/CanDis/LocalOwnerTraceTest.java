package is.fivefivefive.CanDis;

import java.nio.file.*;
import java.security.*;
import java.util.*;
import java.util.function.Consumer;
import org.json.*;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.*;
import is.fivefivefive.CanDis.metric.*;
import parser.ast.nodes.ModelUnit;

/** Frozen same-identity baseline/candidate test; no existing test main calls. */
public final class LocalOwnerTraceTest {
    private static int checks;
    private static void check(boolean ok,String why){checks++;if(!ok)throw new AssertionError(why);}
    private static void reject(Runnable action,String why){checks++;try{action.run();}catch(IllegalArgumentException|IllegalStateException expected){return;}throw new AssertionError("Accepted "+why);}
    private static String hash(String text)throws Exception{return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(text.getBytes(java.nio.charset.StandardCharsets.UTF_8)));}
    private static List<Canonical.Prepared> prepare(JSONObject row)throws Exception {
        var text=Files.readString(Path.of(row.getString("source")));check(hash(text).equals(row.getString("sha256")),"Frozen source hash");
        var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,text);var ps=new ArrayList<Canonical.Prepared>();
        for(String name:List.of(row.getString("left"),row.getString("right"))){var v=new MASGVisitor(new GlobalVariables(),Set.of(name),module);v.visit(new ModelUnit(null,module),null);ps.add(Canonical.prepare(v.getForest().get(v.getForestId(name))));}return ps;
    }
    private static void add(JSONArray rows,String id,Path source,String left,String right)throws Exception {
        rows.put(new JSONObject().put("id",id).put("source",source.toAbsolutePath().toString()).put("sha256",hash(Files.readString(source))).put("left",left).put("right",right));
    }
    private static JSONObject family(Path out)throws Exception {
        Files.createDirectories(out);var rows=new JSONArray();var source=Path.of("classified-data/classroom_fol/both/2vEm4FQHNpQECkJwp_inv12.als");var text=Files.readString(source);
        check(hash(text).equals("9f00099c6f1ed752d021cffd77581cef82607524e827402db074d82faf10d88f"),"Actual incident source");add(rows,"original",source,"inv12","inv12c");
        var variants=new LinkedHashMap<String,String>();
        variants.put("renamed",text.replace("g:Group, c:Class, s:Student","h:Group, k:Class, u:Student").replace("t->c in Teaches  implies c->s->g in Groups","t->k in Teaches  implies k->u->h in Groups"));
        variants.put("ordered",text.replace("g:Group, c:Class, s:Student","s:Student, g:Group, c:Class"));
        variants.put("grouped",text.replace("g:Group, c:Class, s:Student","g,h:Group, c:Class, s:Student"));
        variants.put("dependent",text.replace("g:Group, c:Class, s:Student","g:Group, c:Class, s:Student & c.Groups.g"));
        variants.put("identical",text.replace("all x:Teacher | some x.Teaches.Groups","all t: Teacher | some g:Group, c:Class, s:Student | t->c in Teaches implies c->s->g in Groups"));
        for(var e:variants.entrySet()){var p=out.resolve(e.getKey()+".als");Files.writeString(p,e.getValue(),StandardOpenOption.CREATE_NEW);add(rows,e.getKey(),p,"inv12","inv12c");}
        for(var r:List.of(new String[]{"coursesOld/both/7XiqRnyXeoftBf2No_inv15","inv15"},new String[]{"coursesNew/both/5vxYh7NCpEPMmC47p_inv14","inv14"},new String[]{"coursesNew/under/dcxEP6ZgQAktuDbeT_inv10","inv10"},new String[]{"classroom_fol/both/JoNXaXfKNJzGh3BFa_inv12","inv12"},new String[]{"classroom_fol/both/SASEHD8jPo2HgsuoJ_inv14","inv14"},new String[]{"coursesOld/both/xJnitBpFv9K74WNvf_inv14","inv14"},new String[]{"coursesNew/correct/wnqMPtpNxnPYzru3g_inv14","inv14"},new String[]{"coursesNew/both/LJrfWwJdKiTdyytci_inv14","inv14"}))add(rows,r[0],Path.of("classified-data",r[0]+".als"),r[1],r[1]+"c");
        var result=new JSONObject().put("cases",rows);Files.writeString(out.resolve("family.json"),result.toString(2),StandardOpenOption.CREATE_NEW);return result;
    }
    private static List<EGraphNode> nodes(EGraphNode root,EGraphNode.Opcode opcode){var out=new ArrayList<EGraphNode>();var q=new ArrayDeque<EGraphNode>();q.add(root);while(!q.isEmpty()){var n=q.remove();if(n.getOpcode()==opcode)out.add(n);q.addAll(n.getChildren());}return out;}
    private static void field(Object o,String name,Object value){try{var f=o.getClass().getDeclaredField(name);f.setAccessible(true);f.set(o,value);}catch(ReflectiveOperationException e){throw new AssertionError(e);}}
    private static String path(String nativePath){return nativePath.replaceAll("/alternative/[0-9]+","").replace("root","$").replace("/child/","/");}
    private static JSONArray crud(JSONObject trace,JSONObject bridge,boolean fast) {
        var paths=new ArrayList<Map<String,String>>();var heads=new ArrayList<Map<String,String>>();
        for(Object e:bridge.getJSONArray("constructionEndpoints")){var map=new HashMap<String,String>();var labels=new HashMap<String,String>();for(Object v:((JSONObject)e).getJSONArray("matrixEndpoints")){var n=(JSONObject)v;map.put(fast?n.getString("fastPath"):n.getString("certifiedPath"),n.getString("certifiedPath"));labels.put(n.getString("certifiedPath"),n.getString("typedCoordinateHead"));}paths.add(map);heads.add(labels);}
        var result=new JSONArray();
        for(Object p:trace.getJSONArray("phases"))for(Object item:((JSONObject)p).getJSONObject("program").getJSONArray("operations")) {
            var op=(JSONObject)item;String a=op.isNull("source")?null:paths.get(0).get(path(op.getString("source")));String b=op.isNull("target")?null:paths.get(1).get(path(op.getString("target")));
            check(op.isNull("source")||a!=null,"CRUD source occurrence has checked typed bridge");check(op.isNull("target")||b!=null,"CRUD target occurrence has checked typed bridge");
            // Raw READ versus coordinate-alignment labels differ because the two
            // native payload formats retain different provenance. Preserve both
            // raw programs and compare their checked typed endpoints, not strings.
            String kind=a==null?"insert":b==null?"delete":op.getInt("cost")==0?"zero-transport":"update";
            result.put(new JSONObject().put("kind",kind).put("source",a==null?JSONObject.NULL:a).put("target",b==null?JSONObject.NULL:b)
                    .put("before",a==null?JSONObject.NULL:heads.get(0).get(a)).put("after",b==null?JSONObject.NULL:heads.get(1).get(b)).put("cost",op.getInt("cost")));
        }
        return result;
    }
    private static JSONObject sameExecution(JSONObject before,JSONObject after) {
        var a=new JSONObject(before.toString());var b=new JSONObject(after.toString());
        var forward=new HashMap<Long,Long>();var inverse=new HashMap<Long,Long>();
        var transport=new JSONArray();
        var ap=a.getJSONArray("phases");var bp=b.getJSONArray("phases");check(ap.length()==bp.length(),"same native phase count");
        for(int phase=0;phase<ap.length();phase++) {
            var ao=ap.getJSONObject(phase).getJSONObject("program").getJSONArray("operations");var bo=bp.getJSONObject(phase).getJSONObject("program").getJSONArray("operations");check(ao.length()==bo.length(),"same CRUD count");
            for(int i=0;i<ao.length();i++)for(String side:List.of("before","after")) {
                var x=ao.getJSONObject(i);var y=bo.getJSONObject(i);check(x.isNull(side)==y.isNull(side),"same insertion/deletion endpoints");if(x.isNull(side))continue;
                var xe=new JSONObject(x.getJSONObject(side).getString("nativeEvidence"));var ye=new JSONObject(y.getJSONObject(side).getString("nativeEvidence"));
                for(String key:List.of("sourceOccurrenceLineage","certificationOccurrenceLineage","callOccurrence"))if(xe.has(key)) {
                    long old=xe.getLong(key),now=ye.getLong(key);
                    if(old<0){check(old==now,"negative occurrence sentinel unchanged");continue;}
                    var prior=forward.putIfAbsent(old,now);var back=inverse.putIfAbsent(now,old);
                    check((prior==null||prior==now)&&(back==null||back==old),"fresh-run occurrence transport is bijective");
                    if(prior==null)transport.put(new JSONObject().put("old",old).put("current",now).put("phase",phase).put("operation",i).put("side",side));
                    xe.put(key,now);
                }
                check(xe.similar(ye),"source/type/owner/call payload unchanged under occurrence transport");
                x.getJSONObject(side).put("nativeEvidence",xe.toString());
            }
        }
        // Construction DAGs retain each parse's actual occurrence identities;
        // each is checked independently. They are not repair operations.
        a.remove("constructionDerivations");b.remove("constructionDerivations");
        check(a.similar(b),"all selected numeric/phase/declaration/matrix operations unchanged under checked fresh-run occurrence bijection");
        return new JSONObject().put("occurrenceBijection",transport).put("independentConstructionEvidenceRetained",after.has("constructionDerivations"));
    }
    private static void corrupt(Canonical.Prepared a,Canonical.Prepared b,NativeRepairTrace ft,NativeRepairTrace ct,JSONObject bridge) {
        var source=a.normalizedForms().get(0);
        for(var change:List.<Consumer<EGraphNode>>of(
                r->field(nodes(r,EGraphNode.Opcode.EXISTS).get(0),"sourceOccurrenceLineage",-1L),
                r->field(nodes(r,EGraphNode.Opcode.GENERICRELDECL).get(0),"sourceOccurrenceLineage",-1L),
                r->field(nodes(r,EGraphNode.Opcode.GENERICRELDECL).get(0).getChildren().get(0),"sourceOccurrenceLineage",-1L),
                r->field(nodes(r,EGraphNode.Opcode.GENERICRELDECL).get(0).getChildren().get(1),"alphaName","@fast-local:9:9"),
                r->field(nodes(r,EGraphNode.Opcode.GENERICRELDECL).get(0).getChildren().get(1),"exactAlloyType",ExactAlloyType.unaryRelation("Group")),
                r->{var n=nodes(r,EGraphNode.Opcode.EXISTS).get(0);var cs=new ArrayList<>(n.getChildClasses());Collections.swap(cs,0,1);field(n,"childClasses",cs);})) {
            var root=CanonicalDistance.prepare(a.normalizedForms()).comparisonForms().get(0).getMatrixEGraph();change.accept(root);reject(()->LocalOwnerCorrespondence.check(source,root),"owner/declaration/domain/tuple/type/order corruption");
        }
        for(var trace:List.of(ft,ct)) {
            for(String mode:List.of("cost","source","payload","premise","order")) {
                var bad=trace.json();var op=bad.getJSONArray("phases").getJSONObject(0).getJSONObject("program").getJSONArray("operations").getJSONObject(0);
                switch(mode){case "cost"->op.put("cost",99);case "source"->op.put("source","foreign");case "payload"->op.getJSONObject("before").put("nativeEvidence","foreign owner/type/call");case "premise"->op.put("premise","foreign");case "order"->bad.getJSONArray("orderedNativeOperations").getJSONObject(0).put("payloadPath","foreign");}
                reject(()->trace.replay(bad),"immutable selected program "+mode);
            }
            check(trace.replay(trace.json())==30,"mutated copies do not alter native authority");
        }
        var bad=new JSONObject(bridge.getJSONObject("diagnostic").toString());bad.getJSONArray("nativeOperationEndpoints").put(0,"foreign");check(NativeOperationComparison.compareCaptured(a,b,bad).status()==NativeOperationComparison.Status.INVALID_REPLAY,"foreign endpoint source rejected");
    }
    private static void corruptCall(NativeRepairTrace fast,NativeRepairTrace certified) {
        var bad=fast.json();boolean found=false;
        for(Object p:bad.getJSONArray("phases"))for(Object value:((JSONObject)p).getJSONObject("program").getJSONArray("operations")) {
            var op=(JSONObject)value;
            if(!op.isNull("before")&&new JSONArray(op.getJSONObject("before").getString("head")).getString(0).equals("CALL")) {
                var evidence=new JSONObject(op.getJSONObject("before").getString("nativeEvidence"));evidence.put("callOccurrence",-99).put("semanticIdentity","foreign/module/call");op.getJSONObject("before").put("nativeEvidence",evidence.toString());found=true;break;
            }
        }
        check(found,"actual retained call operation present");reject(()->fast.replay(bad),"call occurrence/callee substitution");
        var proof=certified.json();var calls=proof.getJSONObject("constructionDerivations").getJSONObject("source").getJSONArray("callPremises");
        check(!calls.isEmpty(),"actual retained call construction premise");calls.getJSONObject(0).put("callee","foreign/module/call");reject(()->certified.replay(proof),"immutable construction call-premise substitution");
    }
    public static void main(String[] args)throws Exception {
        var out=Path.of(args[0]);Files.createDirectories(out);boolean baseline=args.length>1&&args[1].equals("baseline");
        var family=args.length>2?new JSONObject(Files.readString(Path.of(args[2]))):family(out.resolve("inputs"));var results=new JSONArray();int index=0;
        for(Object value:family.getJSONArray("cases")){var row=(JSONObject)value;var ps=prepare(row);
            for(int direction=0;direction<2;direction++){var a=ps.get(direction);var b=ps.get(1-direction);var ft=CanonicalRepairTraces.fast(a,b);var ct=CanonicalRepairTraces.certified(CanonicalAlloyPipeline.prepare(a),CanonicalAlloyPipeline.prepare(b));
                check(ft.replay(ft.json())==ft.distance()&&ct.replay(ct.json())==ct.distance(),"both actual native endpoint executions");
                var result=NativeOperationComparison.compare(a,b,ft,ct);var e=result.evidence();var record=new JSONObject().put("identity",row).put("direction",direction).put("fast",ft.json()).put("certified",ct.json()).put("comparison",e);
                String name="row-"+index+"-"+direction+".json";
                if(!baseline) {
                    // Preserve actual first failure before assertions, never hide
                    // new shape/operation disagreement behind a total comparison.
                    Files.writeString(out.resolve(name),record.toString(),StandardOpenOption.CREATE_NEW);
                    if(row.getString("id").equals("dependent")) {
                        // A separate measured preexisting metric difference is
                        // retained as an obligation, not a successful match.
                        check(ft.distance()==40&&ct.distance()==41,"dependent control's existing 40/41 discrepancy retained");
                        check(result.status()==NativeOperationComparison.Status.UNCHECKABLE
                                &&result.reason().equals("ENDPOINT_REPRESENTATION_UNSUPPORTED"),"dependent control advances beyond layout guard; cross-path repair still outstanding");
                        var f=ps.get(0).normalizedForms().get(0);
                        var links=LocalOwnerCorrespondence.check(f,CanonicalDistance.prepare(ps.get(0).normalizedForms()).comparisonForms().get(0).getMatrixEGraph()).json();
                        check(links.getJSONArray("owners").getJSONObject(0).getJSONArray("orderedDeclarations").length()==3,"dependent declaration ownership and previous-slot dependencies checked");
                        Files.writeString(out.resolve("outstanding-"+direction+".json"),new JSONObject().put("identity",row).put("ownerCorrespondence",links).put("comparison",e).put("status","BLOCKED").put("notSuccessfulCoverage",true).toString(),StandardOpenOption.CREATE_NEW);
                    } else {
                        check(result.status()==NativeOperationComparison.Status.MATCHED,row.getString("id")+" "+direction+" "+result.reason()+" "+e.opt("error"));
                        var fa=crud(ft.json(),e,true);var ca=crud(ct.json(),e,false);
                        Files.writeString(out.resolve("crud-"+index+"-"+direction+".json"),new JSONObject().put("fast",fa).put("certified",ca).toString(),StandardOpenOption.CREATE_NEW);
                        check(fa.similar(ca),"expanded ordered native CRUD correspondence "+row.getString("id"));
                        check(e.getJSONArray("fastActions").similar(e.getJSONArray("certifiedActions")),"paid/zero declaration and matrix action ordering");
                    }
                    if(args.length>3){var old=new JSONObject(Files.readString(Path.of(args[3]).resolve(name)));check(old.getJSONObject("identity").similar(row),"same-identity family transition");var transport=new JSONObject();for(String arm:List.of("fast","certified"))transport.put(arm,sameExecution(old.getJSONObject(arm),record.getJSONObject(arm)));Files.writeString(out.resolve("transport-"+index+"-"+direction+".json"),transport.toString(),StandardOpenOption.CREATE_NEW);}
                    if(index==0){check(ft.distance()==30&&ct.distance()==30,"actual30 unchanged");if(direction==0){var groups=e.getJSONArray("constructionEndpoints").getJSONObject(0).getJSONObject("localOwnerCorrespondence").getJSONArray("owners").getJSONObject(0).getJSONArray("orderedDeclarations");check(groups.length()==3,"three original declaration groups, not a grouped tuple surrogate");corrupt(a,b,ft,ct,e);}}
                    if(row.getString("id").contains("7Xiq")&&direction==0){check(ft.distance()==51&&ct.distance()==51,"7Xiq51 preserved");corruptCall(ft,ct);}
                    check(!e.getBoolean("complete")&&!e.getBoolean("javaLeanCorrespondenceChecked"),"public boundary remains blocked");
                }else Files.writeString(out.resolve(name),record.toString(),StandardOpenOption.CREATE_NEW);
                results.put(new JSONObject().put("id",row.getString("id")).put("direction",direction).put("status",result.status()).put("reason",result.reason()).put("fast",ft.distance()).put("certified",ct.distance()));
                System.out.println(row.getString("id")+" "+direction+" "+result.status()+" "+ft.distance()+"/"+ct.distance());
            }index++;
        }
        Files.writeString(out.resolve("summary.json"),new JSONObject().put("checks",checks).put("baseline",baseline).put("rows",results).put("certificationStatus","BLOCKED").toString(2),StandardOpenOption.CREATE_NEW);System.out.println("LocalOwnerTraceTest: "+checks+" checks");
    }
}
