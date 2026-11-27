package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;
import org.json.*;
import java.io.*;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.*;

public class ReferenceTrace {
    record Prepared(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified) {}
    static Prepared prepare(Path root, String source, String name, String sha256) throws Exception {
        var path=root.resolve(source);
        if (!sha256.isBlank() && !HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(Files.readAllBytes(path))).equals(sha256))
            throw new IllegalArgumentException("Source drift: "+source);
        var module=path.getParent().endsWith("correct")
            ? CompUtil.parseEverything_fromFile(A4Reporter.NOP,new HashMap<>(),path.toRealPath().toString())
            : AlloyUtil.compileAlloyModule(path.toString());
        var unit=new ModelUnit(null,module);
        var ids=new HashMap<String,Integer>(); int id=1;
        for (var pred:unit.getPredDeclList()) ids.put(pred.getName(),id++);
        var visitor=new MASGVisitor(new GlobalVariables(),module);
        visitor.visit(unit,null);
        var graph=visitor.getForest().get(ids.get(name));
        if(graph==null) throw new IllegalArgumentException("Missing predicate "+source+"#"+name);
        var fast=Canonical.prepare(graph);
        return new Prepared(fast,CanonicalAlloyPipeline.prepare(fast));
    }
    static JSONObject check(Prepared left,Prepared right) {
        var result=NativeOperationComparison.compare(left.fast,right.fast,left.certified,right.certified);
        var e=result.evidence(); var row=new JSONObject().put("status",result.status().name()).put("reason",result.reason());
        for(var name:List.of("endpointCorrespondenceChecked","sourceCertificatesChecked","fixedChoiceReplaysChecked","fastActionCount","certifiedActionCount","orderedBlockEffectsEqual","firstDifference","fastFirst","certifiedFirst","error","errorType"))
            if(e.has(name))row.put(name,e.get(name));
        for(var arm:List.of("fast","certified")){
            var diag=e.optJSONObject("diagnostic");
            if(diag!=null && diag.has(arm)) row.put(arm+"Distance",diag.getJSONObject(arm).optInt("distance",-1));
            var blocks=e.optJSONArray(arm+"Blocks"); if(blocks!=null) row.put(arm+"BlockCount",blocks.length());
        }
        return row;
    }
    public static void main(String[] args) throws Exception {
        var root=Path.of(args[0]);var jobs=Path.of(args[1]);var out=Path.of(args[2]);
        var resultStream=System.out;var log=System.err;
        System.setOut(new PrintStream(OutputStream.nullOutputStream()));
        System.setErr(new PrintStream(OutputStream.nullOutputStream()));
        var cache=new LinkedHashMap<String,Prepared>(130,0.75f,true){
          protected boolean removeEldestEntry(Map.Entry<String,Prepared> e){return size()>3;}
        };
        try(var writer=args[2].equals("-")?new BufferedWriter(new OutputStreamWriter(resultStream,java.nio.charset.StandardCharsets.UTF_8)):Files.newBufferedWriter(out, StandardOpenOption.CREATE_NEW);
            var reader=args[1].equals("-")?new BufferedReader(new InputStreamReader(System.in,java.nio.charset.StandardCharsets.UTF_8)):Files.newBufferedReader(jobs)){
            String line; int n=0;
            while((line=reader.readLine())!=null){
                String[] r=line.split("\t",-1);
                var result=new JSONObject().put("kind",r[0]).put("left",r[1]).put("leftPredicate",r[2])
                        .put("right",r[4]).put("rightPredicate",r[5]).put("expected",Integer.parseInt(r[7]));
                try{
                    var sides=new Prepared[2];
                    for(int i=0;i<2;i++){
                        int j=1+3*i; String key=r[j]+"#"+r[j+1];
                        sides[i]=cache.get(key);
                        if(sides[i]==null){sides[i]=prepare(root,r[j],r[j+1],r[j+2]);cache.put(key,sides[i]);}
                    }
                    var outcome=check(sides[0],sides[1]);
                    for(String k:outcome.keySet())result.put(k,outcome.get(k));
                } catch(Exception failure){
                    result.put("status","WORKER_ERROR").put("error",failure.toString());
                }
                writer.write(result.toString());writer.newLine();
                writer.flush();
                if(++n%500==0)log.println(n+" "+jobs+" "+java.time.Instant.now());
            }
        }
    }
}
