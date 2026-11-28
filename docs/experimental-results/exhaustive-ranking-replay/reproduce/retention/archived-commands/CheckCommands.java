import is.fivefivefive.CanDis.augmentation.ProvenRulesCommand;
import java.nio.file.*;
import org.json.JSONObject;
import java.util.*;
public final class CheckCommands {
    public static void main(String[] args) throws Exception {
        var target=Path.of(args[1]).toAbsolutePath();
        try(var input=Files.newBufferedReader(Path.of(args[0]));var out=Files.newBufferedWriter(Path.of(args[2]),StandardOpenOption.CREATE_NEW)){
            for(String line;(line=input.readLine())!=null;){
                var j=new JSONObject(line);var r=new JSONObject().put("pair",j.getJSONArray("pair")).put("sha256",j.getString("sha256"));
                Files.writeString(target,j.getString("source"));
                try{
                    var checked=ProvenRulesCommand.check(target,"correct");
                    r.put("decision",checked).put("parsedSourceSha256",checked.getJSONObject("parsedSourceHashes").getString(target.toRealPath().toString()));
                }catch(Exception e){r.put("error",e.toString());}
                out.write(r.toString());out.newLine();out.flush();
            }
        }
    }
}
