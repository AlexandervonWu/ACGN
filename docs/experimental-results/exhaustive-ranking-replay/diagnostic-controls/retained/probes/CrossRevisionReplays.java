package is.fivefivefive.CanDis;
import java.nio.file.*;import java.util.*;import org.json.*;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import parser.ast.nodes.ModelUnit;
public class CrossRevisionReplays {
 public static void main(String[] args)throws Exception {
  Path repo=Path.of(args[0]),old=Path.of(args[1]),now=Path.of(args[2]);String file=args[3];var log=new JSONArray();
  for(int i=0;i<2;i++){
   String name=file+"-"+i+".json";var a=new JSONObject(Files.readString(old.resolve(name)));var b=new JSONObject(Files.readString(now.resolve(name)));
   if(!a.getString("source").equals(b.getString("source"))||!a.getString("left").equals(b.getString("left"))||!a.getString("right").equals(b.getString("right")))throw new AssertionError("Source selection differs");
   var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,Files.readString(repo.resolve("classified-data").resolve(b.getString("source"))));
   var pair=new ArrayList<Canonical.Prepared>();
   for(String sel:List.of("inv14","inv14c")){
    var v=new MASGVisitor(new GlobalVariables(),Set.of(sel),module);v.visit(new ModelUnit(null,module),null);pair.add(Canonical.prepare(v.getForest().get(v.getForestId(sel))));
   }
   for(var record:List.of(a,b)){
    var n=record.getJSONObject("native");var report=n.optJSONObject("diagnostic");if(report==null)report=record.getJSONObject("diagnostic");
    if(record==b){
     var left=pair.get(i);var right=pair.get(1-i);
     var genuine=NativeOperationComparison.compare(left,right,CanonicalAlloyPipeline.prepare(left),CanonicalAlloyPipeline.prepare(right));
     if(genuine.status()!=NativeOperationComparison.Status.MATCHED)throw new AssertionError(genuine.reason());
     report=genuine.evidence().getJSONObject("diagnostic");
    }
    var res=NativeOperationComparison.compareCaptured(pair.get(i),pair.get(1-i),report);
    log.put(new JSONObject().put("old",record==a).put("left",b.get("left")).put("status",res.status().name()).put("reason",res.reason()).put("evidence",res.evidence()));
   }
  }
  Files.writeString(now.resolve(file+"-recaptured-cross.json"),log.toString());
 }
}
