package is.fivefivefive.CanDis;
import java.nio.file.*;import java.util.*;
import org.json.*;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import parser.ast.nodes.ModelUnit;
public class ArchivedCoordinates {
 public static void main(String[] args)throws Exception {
  Path root=Path.of(args[0]),out=Path.of(args[1]);
  for(String name:List.of("classroom_fol/both/YKy8LYsKdapW3xqbn_inv14.als","coursesOld/both/xJnitBpFv9K74WNvf_inv14.als")){
   String text=Files.readString(root.resolve("classified-data").resolve(name));var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,text);
   var pp=new ArrayList<Canonical.Prepared>();
   for(String sel:List.of("inv14","inv14c")){
    var v=new MASGVisitor(new GlobalVariables(),Set.of(sel),module);v.visit(new ModelUnit(null,module),null);pp.add(Canonical.prepare(v.getForest().get(v.getForestId(sel))));
   }
   for(int i=0;i<2;i++){
    var a=pp.get(i);var b=pp.get(1-i);
    var e=NativeOperationComparison.compare(a,b,CanonicalAlloyPipeline.prepare(a),CanonicalAlloyPipeline.prepare(b)).evidence();
    var data=new JSONObject().put("native",e).put("source",name).put("left",i==0?"inv14":"inv14c").put("right",i==0?"inv14c":"inv14")
        .put("sourceIr",new JSONArray(Canonical.irTemporalFol(a))).put("targetIr",new JSONArray(Canonical.irTemporalFol(b))).put("publicFast",Canonical.distance(a,b))
        .put("publicCertified",CanonicalAlloyPipeline.distance(CanonicalAlloyPipeline.prepare(a),CanonicalAlloyPipeline.prepare(b)));
    if(!e.has("diagnostic"))data.put("diagnostic",DistanceReplayDiagnostics.capture(a,b));
    Files.writeString(out.resolve(Path.of(name).getFileName()+"-"+i+".json"),data.toString());
   }
  }
 }
}
