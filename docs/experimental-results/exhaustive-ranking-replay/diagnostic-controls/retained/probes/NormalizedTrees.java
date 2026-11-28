package is.fivefivefive.CanDis;
import java.nio.file.*;import java.util.*;import org.json.*;
import edu.mit.csail.sdg.alloy4.A4Reporter;import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.EGraphNode;import parser.ast.nodes.ModelUnit;
public class NormalizedTrees {
 static String dump(EGraphNode n){
  if(n.getChildren().isEmpty())return n.getOpcode()+"/"+n.getSourceName()+"/"+n.getAlphaName();
  return "("+n.getOpcode()+" "+String.join(" ",n.getChildren().stream().map(NormalizedTrees::dump).toList())+")";
 }
 public static void main(String[] args)throws Exception {
  var file=Path.of(args[0]);var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,Files.readString(file));var log=new JSONObject();
  for(var op:List.of("inv14","inv14c")){
   var v=new MASGVisitor(new GlobalVariables(),Set.of(op),module);v.visit(new ModelUnit(null,module),null);
   var pp=Canonical.prepare(v.getForest().get(v.getForestId(op)));
   var form=pp.normalizedForms().get(0);
   var q=new JSONObject().put("prefix",new JSONArray(form.getMatrixQuantiVars().stream().map(a->a.getName()+"/"+a.getTypeName()).toList())).put("matrix",dump(form.getMatrixEGraph()));
   if(args.length>2){try{q.put("unused",form.getClass().getMethod("getUnusedBindingReductions").invoke(form).toString());}catch(NoSuchMethodException ignored){}}
   log.put(op,q);
  }
  Files.writeString(Path.of(args[1]),log.toString());
 }
}
