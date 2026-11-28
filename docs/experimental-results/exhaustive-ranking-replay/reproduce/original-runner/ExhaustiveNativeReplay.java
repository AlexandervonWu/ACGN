package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.*;
import java.util.*;
import java.util.zip.GZIPOutputStream;
import org.json.JSONArray;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Run the measured comparator on original prepared endpoints. Only endpoint preparation is reused. */
public final class ExhaustiveNativeReplay {
    private record Key(String path, String predicate, String hash) {}
    private record Prepared(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified) {}
    private static final class Endpoints {
        private final Path dataset;
        private final int limit;
        private String group;
        private final Map<Key, Prepared> references = new HashMap<>();
        private Key studentKey;
        private Prepared student;
        long hits;
        long misses;
        Endpoints(Path dataset, int limit) { this.dataset=dataset;this.limit=limit; }
        Prepared get(Key key, boolean reference) throws Exception {
            if (reference && references.containsKey(key)) {hits++;return references.get(key);}
            if (!reference && key.equals(studentKey)) {hits++;return student;}
            misses++;
            Path file=dataset.resolve(key.path()).toRealPath();
            if (!file.startsWith(dataset) || !digest(file).equals(key.hash())) throw new IOException("Changed endpoint "+key);
            var module=file.getParent().endsWith("correct")?CompUtil.parseEverything_fromFile(A4Reporter.NOP,new HashMap<>(),file.toString())
                                :AlloyUtil.compileAlloyModule(file.toString());
            var visitor=new MASGVisitor(new GlobalVariables(),module);
            visitor.visit(new ModelUnit(null,module),null);
            var id=visitor.getForestId(key.predicate());
            if(id==null || visitor.getForest().get(id)==null) throw new IOException("Unresolved predicate "+key);
            var fast=Canonical.prepare(visitor.getForest().get(id));
            var result=new Prepared(fast,CanonicalAlloyPipeline.prepare(fast));
            if(reference) {
                String nextGroup=key.path().split("/",2)[0]+"/"+key.predicate().replaceFirst("[cC]$","");
                if(!nextGroup.equals(group)) {references.clear();group=nextGroup;}
                // Keep a stable bounded working set even for pools wider than the cache.
                if(references.size()<limit) references.put(key,result);
            } else {studentKey=key;student=result;}
            return result;
        }
    }
    private static String digest(Path p) throws Exception {
        var hash=MessageDigest.getInstance("SHA-256");
        try(var input=Files.newInputStream(p)) {byte[] b=new byte[65536];int n;while((n=input.read(b))!=-1)hash.update(b,0,n);}
        return HexFormat.of().formatHex(hash.digest());
    }
    private static void copy(JSONObject from, JSONObject to, String... fields) {
        for(var key:fields) if(from.has(key)) to.put(key,from.get(key));
    }
    // Encoded as compact UTF-8 JSON with sorted object keys; array order is significant.
    private static void canonical(Object val,StringBuilder out) {
        if(val instanceof JSONObject obj) {
            out.append('{');boolean comma=false;
            for(String k:new TreeSet<>(obj.keySet())) {
                if(comma)out.append(',');comma=true;out.append(JSONObject.quote(k)).append(':');canonical(obj.get(k),out);
            }
            out.append('}');
        } else if(val instanceof JSONArray array) {
            out.append('[');for(int i=0;i<array.length();i++){if(i>0)out.append(',');canonical(array.get(i),out);}out.append(']');
        } else if(val instanceof String value)out.append(JSONObject.quote(value));
        else if(val instanceof Number number)out.append(JSONObject.numberToString(number));
        else if(val==JSONObject.NULL || val instanceof Boolean)out.append(val);
        else throw new IllegalArgumentException("Unexpected native JSON type");
    }
    private static String sequence(JSONObject evidence,String arm,boolean temporal) {
        var array=evidence.getJSONArray(arm+(temporal?"Blocks":"Actions"));
        if(temporal) {
            var projected=new JSONArray();
            for(Object item:array){var block=(JSONObject)item;projected.put(new JSONArray().put(block.get("component")).put(block.get("effect")));}
            array=projected;
        }
        var out=new StringBuilder();canonical(array,out);return out.toString();
    }
    private static void compareSequences(JSONObject evidence,JSONObject row) throws Exception {
        boolean temporal=evidence.has("fastBlocks") || evidence.has("certifiedBlocks");
        if(!evidence.has(temporal?"fastBlocks":"fastActions") || !evidence.has(temporal?"certifiedBlocks":"certifiedActions"))return;
        String fast=sequence(evidence,"fast",temporal), certified=sequence(evidence,"certified",temporal);
        var hash=MessageDigest.getInstance("SHA-256");
        row.put("sequenceKind",temporal?"TEMPORAL_BLOCK_EFFECTS":"FLAT_ACTIONS")
                .put("nativeSequencesEqual",fast.equals(certified))
                .put("fastSequenceSha256",HexFormat.of().formatHex(hash.digest(fast.getBytes(StandardCharsets.UTF_8))))
                .put("certifiedSequenceSha256",HexFormat.of().formatHex(hash.digest(certified.getBytes(StandardCharsets.UTF_8))));
    }
    private static boolean checked(JSONObject row) {
        if(!row.optString("status").equals("MATCHED") || !row.optString("reason").equals("CHECKED_NATIVE_ACTIONS_EQUAL")
                || row.optInt("fastDistance",-1)!=row.getInt("expected") || row.optInt("certifiedDistance",-1)!=row.getInt("expected")
                || !row.optBoolean("endpointCorrespondenceChecked") || !row.optBoolean("sourceCertificatesChecked")
                || !row.optBoolean("fixedChoiceReplaysChecked") || !row.optBoolean("nativeSequencesEqual")) return false;
        if(row.has("orderedBlockEffectsEqual"))
            return row.getBoolean("orderedBlockEffectsEqual") && row.has("fastBlockCount") && row.has("certifiedBlockCount")
                    && row.getInt("fastBlockCount")==row.getInt("certifiedBlockCount");
        return row.has("fastActionCount") && row.has("certifiedActionCount") && row.getInt("fastActionCount")==row.getInt("certifiedActionCount");
    }
    private static JSONObject observe(String[] r,String shard,int ordinal,Endpoints endpoints,Path results) throws Exception {
        var row=new JSONObject().put("kind",r[0]).put("left",r[1]).put("leftPredicate",r[2]).put("right",r[4])
                .put("rightPredicate",r[5]).put("expected",Integer.parseInt(r[7])).put("ordinal",ordinal);
        JSONObject evidence=null;
        Prepared left=null,right=null;
        try {
            if(!r[0].equals("paid") || row.getInt("expected")<=0) throw new IllegalArgumentException("Invalid input");
            left=endpoints.get(new Key(r[1],r[2],r[3]),false);
            right=endpoints.get(new Key(r[4],r[5],r[6]),true);
            var actual=NativeOperationComparison.compare(left.fast(),right.fast(),left.certified(),right.certified());
            evidence=actual.evidence();
            row.put("status",actual.status().name()).put("reason",actual.reason());
            compareSequences(evidence,row);
            copy(evidence,row,"endpointCorrespondenceChecked","sourceCertificatesChecked","fixedChoiceReplaysChecked",
                    "fastActionCount","certifiedActionCount","orderedBlockEffectsEqual","firstDifference","fastFirst",
                    "certifiedFirst","error","errorType","resourceOrigin","receiptOmitted");
            for(String arm:List.of("fast","certified")) {
                var diag=evidence.optJSONObject("diagnostic");
                if(diag!=null && diag.optJSONObject(arm)!=null && diag.getJSONObject(arm).has("distance"))
                    row.put(arm+"Distance",diag.getJSONObject(arm).getInt("distance"));
                if(evidence.has(arm+"Blocks")) row.put(arm+"BlockCount",evidence.getJSONArray(arm+"Blocks").length());
            }
        } catch(Exception e) {
            row.put("status","WORKER_ERROR").put("reason","ORIGINAL_ENDPOINT_OR_COMPARATOR_ERROR").put("error",e.toString());
        }
        boolean success=checked(row);row.put("checked",success);
        if(!success) {
            String obj=shard+"-"+ordinal+"-"+UUID.randomUUID()+".json.gz";
            Path dest=results.resolve("incidents").resolve(obj),temp=dest.resolveSibling(obj+".tmp");
            var archive=new JSONObject().put("identity",new JSONObject(row.toString())).put("leftSha256",r[3]).put("rightSha256",r[6])
                    .put("nativeComparatorEvidence",evidence==null?JSONObject.NULL:evidence);
            if(left!=null && right!=null && (evidence==null || evidence.optJSONObject("diagnostic")==null)) {
                try {archive.put("supplementaryRecapture",DistanceReplayDiagnostics.captureOutcome(
                        left.fast(),right.fast(),left.certified(),right.certified()).report());}
                catch(Exception failure) {archive.put("supplementaryRecaptureError",failure.toString());}
            }
            try(var gzip=new GZIPOutputStream(Files.newOutputStream(temp,StandardOpenOption.CREATE_NEW));
                    var out=new OutputStreamWriter(gzip,StandardCharsets.UTF_8)){archive.write(out);}
            Files.move(temp,dest,StandardCopyOption.ATOMIC_MOVE);
            row.put("incidentPath","incidents/"+obj).put("incidentSha256",digest(dest));
            Path event=Files.createTempFile(results,"incident-",".tmp");
            Files.writeString(event,new JSONObject(row.toString()).put("shard",shard).toString()+"\n");
            try {Files.createLink(results.resolve("first-incident.json"),event);}
            catch(FileAlreadyExistsException earlierIncident) { /* First receipt is retained. */ }
            Files.delete(event);
        }
        return row;
    }
    public static void main(String[] args) throws Exception {
        Path dataset=Path.of(args[0]).toRealPath(), results=Path.of(args[1]).toRealPath();
        var endpoints=new Endpoints(dataset,Integer.parseInt(args[2]));
        var control=System.out;
        System.setOut(new PrintStream(OutputStream.nullOutputStream()));
        var reader=new BufferedReader(new InputStreamReader(System.in,StandardCharsets.UTF_8));
        for(String command;(command=reader.readLine())!=null;) {
            String[] cmd=command.split("\t",-1);String shard=cmd[0];int start=Integer.parseInt(cmd[2]);
            int n=0; long begin=System.nanoTime(),hits=endpoints.hits,miss=endpoints.misses;
            try(var input=Files.newBufferedReader(Path.of(cmd[1]));
                var ledger=Files.newBufferedWriter(results.resolve(shard+".jsonl"),StandardOpenOption.CREATE,StandardOpenOption.APPEND)) {
                for(String line;(line=input.readLine())!=null;n++) {
                    if(n<start)continue;
                    String[] cells=line.split("\t",-1);
                    if(cells.length!=8)throw new IOException("Expected eight fields at "+shard+" "+n);
                    var row=observe(cells,shard,n,endpoints,results);
                    ledger.write(row.toString());ledger.newLine();
                    if(n%8==0 || !row.getBoolean("checked"))ledger.flush();
                }
            }
            control.println(new JSONObject().put("shard",shard).put("rows",n).put("newRows",n-start)
                    .put("elapsedSeconds",(System.nanoTime()-begin)/1e9).put("cacheHits",endpoints.hits-hits)
                    .put("cacheMisses",endpoints.misses-miss));
            control.flush();
        }
    }
}
