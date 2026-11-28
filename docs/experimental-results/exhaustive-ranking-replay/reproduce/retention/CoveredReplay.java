package is.fivefivefive.CanDis;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.*;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.augmentation.*;
import is.fivefivefive.CanDis.metric.NativeRepairTrace;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.Predicate;
import parser.util.AlloyUtil;
import org.json.*;
import java.io.*;
import java.lang.reflect.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.*;
import java.util.*;
import java.util.zip.GZIPOutputStream;

/** Replay paired native scans and reference witnesses on the current engine, plus authentic original fixed commands. */
public final class CoveredReplay {
    private record Prepared(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared exact) {}
    private static final class Window<K,V> extends LinkedHashMap<K,V> {
        Window(){super(16,.75f,true);}
        protected boolean removeEldestEntry(Map.Entry<K,V> e){return size()>12;}
    }
    private final Path corpus, artifacts;
    private final Window<String,Prepared> references=new Window<>();
    private final Window<String,ScopedPoolEndpoint.Endpoint> scopes=new Window<>();
    private final Method findPair,focus,bindCommitments,verdict;
    private final Field leftName,rightName,leftPredicate,rightPredicate;
    private CoveredReplay(Path corpus,Path artifacts) throws Exception {
        this.corpus=corpus.toRealPath();this.artifacts=artifacts.toRealPath();
        var pair=Class.forName("is.fivefivefive.CanDis.CanonicalBatchTest$PredicatePair");
        findPair=method(CanonicalBatchTest.class,"findPredicatePair",Path.class,ModelUnit.class);
        focus=method(CanonicalBatchTest.class,"focusedVisitor",CompModule.class,ModelUnit.class,pair);
        leftName=field(pair,"leftName");rightName=field(pair,"rightName");leftPredicate=field(pair,"left");rightPredicate=field(pair,"right");
        bindCommitments=method(ExhaustiveNativeReplay.class,"compareSequences",JSONObject.class,JSONObject.class);
        verdict=method(ExhaustiveNativeReplay.class,"checked",JSONObject.class);
    }
    private static Method method(Class<?> c,String name,Class<?>...args) throws Exception {var m=c.getDeclaredMethod(name,args);m.setAccessible(true);return m;}
    private static Field field(Class<?> c,String name) throws Exception {var f=c.getDeclaredField(name);f.setAccessible(true);return f;}
    private static String sha(byte[] bytes) throws Exception {return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));}
    private Path source(JSONArray key) throws Exception {
        var p=corpus.resolve(key.getString(0)).toRealPath();
        if(!p.startsWith(corpus)||!sha(Files.readAllBytes(p)).equals(key.getString(2)))throw new IOException("Changed corpus endpoint "+key);
        return p;
    }
    private static Prepared prep(MASGVisitor v,String name) {
        var id=v.getForestId(name);
        if(id==null||v.getForest().get(id)==null)throw new IllegalArgumentException("Missing original selector "+name);
        var p=Canonical.prepare(v.getForest().get(id));return new Prepared(p,CanonicalAlloyPipeline.prepare(p));
    }
    private Prepared ref(JSONArray key) throws Exception {
        String cacheKey=key.toString();var stored=references.get(cacheKey);if(stored!=null)return stored;
        var p=source(key);
        var m=p.getParent().endsWith("correct")?CompUtil.parseEverything_fromFile(A4Reporter.NOP,new HashMap<>(),p.toString()):AlloyUtil.compileAlloyModule(p.toString());
        var visitor=new MASGVisitor(new GlobalVariables(),m);visitor.visit(new ModelUnit(null,m),null);
        var result=prep(visitor,key.getString(1));references.put(cacheKey,result);return result;
    }
    private ScopedPoolEndpoint.Endpoint scoped(JSONArray key) throws Exception {
        String cacheKey=key.toString();if(scopes.containsKey(cacheKey))return scopes.get(cacheKey);
        var p=source(key);var loaded=new HashMap<String,String>();
        CompUtil.parseEverything_fromFile(A4Reporter.NOP,loaded,p.toString());
        var ep=ScopedPoolEndpoint.read(p,key.getString(1),key.getString(3),key.getInt(4),ScopedPoolEndpoint.closureDigest(loaded));
        scopes.put(cacheKey,ep);return ep;
    }
    private static void copy(JSONObject from,JSONObject to,String...keys){for(String k:keys)if(from.has(k))to.put(k,from.get(k));}
    private static int[] vector(NativeRepairTrace t){return new int[]{t.distance(),t.temporalDistance(),t.quantifierDistance(),t.matrixDistance()};}
    private NativeOperationComparison.Result paired(JSONObject input,JSONObject row) throws Exception {
        var a=input.getJSONArray("a");var b=input.getJSONArray("b");var p=source(a);
        if(!a.getString(0).equals(b.getString(0)) || !a.getString(2).equals(b.getString(2)))throw new IOException("Not one original student/oracle file");
        var module=AlloyUtil.compileAlloyModule(p.toString());var unit=new ModelUnit(null,module);
        Object pair=findPair.invoke(null,p,unit);
        if(pair==null || !a.getString(1).equals(leftName.get(pair)) || !b.getString(1).equals(rightName.get(pair)))throw new IllegalStateException("Original producer chose different predicates");
        if(DatasetConventions.sameRawAst(((Predicate)leftPredicate.get(pair)).getBody(),((Predicate)rightPredicate.get(pair)).getBody()))throw new IllegalStateException("Original AST identity exclusion");
        var visitor=(MASGVisitor)focus.invoke(null,module,unit,pair);
        var left=prep(visitor,a.getString(1));var right=prep(visitor,b.getString(1));
        var fast=Canonical.evaluateWithTrace(left.fast(),right.fast());var certified=CanonicalRepairTraces.certified(left.exact(),right.exact());
        var fv=vector(fast);var cv=vector(certified);
        var result=NativeOperationComparison.compare(left.fast(),right.fast(),fast,certified).bindScanCosts(fv,cv);
        var commands=new JSONArray();
        for(var d:CanonicalAlloyPipeline.compareSourceCommands(module,a.getString(1),b.getString(1)))commands.put(d.json(certified.distance()));
        row.put("commands",commands).put("scanFast",new JSONArray(fv)).put("scanCertified",new JSONArray(cv));
        return result;
    }
    private void scopes(JSONObject j,JSONObject row) throws Exception {
        var a=j.getJSONArray("a");var b=j.getJSONArray("b");
        var d=ScopedPoolEndpoint.compare(scoped(a),scoped(b));
        var actual=new JSONObject().put("scopeStatus",d.isEmpty()?"NO_COMMON_COMMAND":d.get().matched()?"FIXED_COMMAND_RULE":"NO_RULE_MATCH");
        if(d.isPresent()){var decision=d.get();actual.put("rules",decision.rules()).put("bitwidth",decision.bitwidth()).put("traceMin",decision.traceMin()).put("traceMax",decision.traceMax()).put("carrierBounds",decision.carrierBounds());actual.put("native",decision.matched()?"UNSAT":"NOT_RUN");}
        row.put("scope",actual);
        if(j.getString("kind").equals("sat-control")){
            var x=ref(a);var y=ref(b);row.put("fastDistance",Canonical.distance(x.fast,y.fast)).put("certifiedDistance",CanonicalAlloyPipeline.distance(x.exact,y.exact));
        }
    }
    private void saveIncident(JSONObject j,JSONObject row,JSONObject evidence,String shard) throws Exception {
        String name=shard+"-"+row.getInt("ordinal")+"-"+UUID.randomUUID()+".json.gz";var out=artifacts.resolve("incidents").resolve(name);
        try(var gz=new GZIPOutputStream(Files.newOutputStream(out,StandardOpenOption.CREATE_NEW));var writer=new OutputStreamWriter(gz,StandardCharsets.UTF_8)){
            new JSONObject().put("job",j).put("originalObservation",new JSONObject(row.toString())).put("comparator",evidence==null?JSONObject.NULL:evidence).write(writer);
        }
        row.put("incident","incidents/"+name).put("incidentSha256",sha(Files.readAllBytes(out)));
    }
    private JSONObject compare(String line,String shard,int ordinal) throws Exception {
        var j=new JSONObject(line);String kind=j.getString("kind");
        var a=j.getJSONArray("a");var b=j.getJSONArray("b");
        var row=new JSONObject().put("kind",kind).put("a",a).put("b",b).put("ordinal",ordinal).put("inputSha256",sha((line+"\n").getBytes(StandardCharsets.UTF_8)));
        JSONObject evidence=null; boolean accepted=false;
        try {
            if(kind.equals("paired")||kind.equals("zero")) {
                row.put("expected",j.getInt("expected"));NativeOperationComparison.Result result;
                if(kind.equals("paired"))result=paired(j,row);else {
                    var l=ref(a);var r=ref(b);result=NativeOperationComparison.compare(l.fast,r.fast,l.exact,r.exact);
                }
                evidence=result.evidence();row.put("status",result.status().name()).put("reason",result.reason());bindCommitments.invoke(null,evidence,row);
                copy(evidence,row,"endpointCorrespondenceChecked","fixedChoiceReplaysChecked","sourceCertificatesChecked","fastActionCount","certifiedActionCount","orderedBlockEffectsEqual","firstDifference","fastFirst","certifiedFirst","scanCostBindingChecked","error","errorType");
                for(String arm:List.of("fast","certified")){
                    var diag=evidence.optJSONObject("diagnostic");
                    if(diag!=null&&diag.optJSONObject(arm)!=null&&diag.getJSONObject(arm).has("distance"))row.put(arm+"Distance",diag.getJSONObject(arm).getInt("distance"));
                    var blocks=evidence.optJSONArray(arm+"Blocks");if(blocks!=null)row.put(arm+"BlockCount",blocks.length());
                }
                accepted=(boolean)verdict.invoke(null,row);
                if(kind.equals("paired"))accepted&=row.optBoolean("scanCostBindingChecked") && row.getJSONArray("scanFast").similar(row.getJSONArray("scanCertified")) && row.getJSONArray("commands").similar(j.getJSONArray("commands"));
            } else {
                scopes(j,row);var actual=new JSONObject(row.getJSONObject("scope").toString());actual.remove("native");
                var expected=new JSONObject(j.getJSONObject("scoped").toString());for(String k:new HashSet<>(expected.keySet()))if(expected.isNull(k))expected.remove(k);
                accepted=actual.similar(expected) && (!kind.equals("sat-control") || row.getInt("fastDistance")>0 && row.getInt("fastDistance")==row.getInt("certifiedDistance"));
                row.put("status",accepted?"SCOPE_RETAINED":"SCOPE_DISAGREEMENT");
            }
        } catch(Exception failure){row.put("status","WORKER_ERROR").put("error",failure.toString());}
        row.put("accepted",accepted);
        if(!accepted)saveIncident(j,row,evidence,shard);
        return row;
    }
    public static void main(String[] args) throws Exception {
        var control=System.out;System.setOut(new PrintStream(OutputStream.nullOutputStream()));
        var root=Path.of(args[1]);var driver=new CoveredReplay(Path.of(args[0]),root);
        var r=new BufferedReader(new InputStreamReader(System.in,StandardCharsets.UTF_8));
        for(String request;(request=r.readLine())!=null;){
            var fields=request.split("\t");String shard=fields[0];int start=Integer.parseInt(fields[2]);int index=0;
            try(var jobs=Files.newBufferedReader(Path.of(fields[1]));var out=Files.newBufferedWriter(root.resolve(shard+".jsonl"),StandardOpenOption.CREATE,StandardOpenOption.APPEND)){
                for(String line;(line=jobs.readLine())!=null;index++)if(index>=start){out.write(driver.compare(line,shard,index).toString());out.newLine();out.flush();}
            }
            control.println(new JSONObject().put("shard",shard).put("rows",index));control.flush();
        }
    }
}
