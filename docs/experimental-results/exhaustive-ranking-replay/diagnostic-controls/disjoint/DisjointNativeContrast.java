package is.fivefivefive.CanDis;
import java.util.*;import java.nio.file.*;import edu.mit.csail.sdg.parser.CompUtil;import edu.mit.csail.sdg.alloy4.A4Reporter;import is.fivefivefive.ACGN.visitor.MASGVisitor;import is.fivefivefive.ACGN.util.GlobalVariables;import parser.ast.nodes.ModelUnit;import org.json.*;
public class DisjointNativeContrast {
  public static void main(String[] args)throws Exception {String text=Files.readString(Path.of(args[0]));var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,text);var endpoints=new ArrayList<Canonical.Prepared>();for(var name:List.of("disjoint","ordinary")){var visitor=new MASGVisitor(new GlobalVariables(),Set.of(name),module);visitor.visit(new ModelUnit(null,module),null);endpoints.add(Canonical.prepare(visitor.getForest().get(visitor.getForestId(name))));}
  var results=new JSONArray();
  for(int i=0;i<2;i++){var a=endpoints.get(i);var b=endpoints.get(1-i);var ca=CanonicalAlloyPipeline.prepare(a);var cb=CanonicalAlloyPipeline.prepare(b);var comp=NativeOperationComparison.compare(a,b,ca,cb);var e=comp.evidence();var paid=new JSONArray();if(e.has("fastActions"))for(var action:e.getJSONArray("fastActions")){var obj=(JSONObject)action;if(obj.getInt("cost")!=0)paid.put(obj);}
   var result=new JSONObject().put("order",i==0?"disjoint-to-ordinary":"ordinary-to-disjoint").put("fast",Canonical.distance(a,b)).put("certified",CanonicalAlloyPipeline.distance(ca,cb)).put("status",comp.status()).put("reason",comp.reason()).put("paidActions",paid);
   results.put(result);System.err.println("RESULT "+result);}
  Files.writeString(Path.of(args[1]),results.toString(2)+"\n");
  }
}
