import java.nio.file.*;import java.util.*;import org.json.*;
import edu.mit.csail.sdg.alloy4.A4Reporter;import edu.mit.csail.sdg.parser.CompUtil;import edu.mit.csail.sdg.ast.Command;import edu.mit.csail.sdg.translator.*;
public class UnusedDomains {
 public static void main(String[] args)throws Exception {
  var m=CompUtil.parseEverything_fromString(A4Reporter.NOP,Files.readString(Path.of(args[0]))+"""
    pred active { all s:Student, t:Teacher | t->s in Tutors and t->t in Tutors }
    pred reduced { no Class or no Group or active }
    """);var options=new A4Options();var receipt=new JSONArray();
  for(var spec:List.of(new String[]{"not (inv14 iff reduced)","false"},
       new String[]{"no Class and some Group and inv14 and not (no Group or active)","true"},
       new String[]{"some Class and no Group and inv14 and not (no Class or active)","true"})){
   var expr=CompUtil.parseOneExpression_fromString(m,spec[0]);var cmd=new Command(false,3,4,4,null,expr);
   var ans=TranslateAlloyToKodkod.execute_command(A4Reporter.NOP,m.getAllReachableSigs(),cmd,options);
   if(ans.satisfiable()!=Boolean.parseBoolean(spec[1]))throw new AssertionError(spec[0]);
   receipt.put(new JSONObject().put("formula",spec[0]).put("overallScope",3).put("bitwidth",4).put("satisfiable",ans.satisfiable()).put("model",ans.toString()));
  } Files.writeString(Path.of(args[1]),receipt.toString());
 }
}
