package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.zip.GZIPInputStream;
import org.json.JSONObject;

/** Replay original sources, not archived rewritten modules or suggested rules. */
public final class DefaultPoolReplay {
    private static BufferedReader open(Path p) throws IOException {
        return new BufferedReader(new InputStreamReader(new GZIPInputStream(Files.newInputStream(p)),StandardCharsets.UTF_8));
    }
    public static void main(String[] args) throws Exception {
        var data=Path.of("docs/experimental-results/2026-11-25");
        var refs=new ArrayList<ScopedPoolEndpoint.Endpoint>();
        try(var f=open(data.resolve("references.jsonl.gz"))) {
            for(String s;(s=f.readLine())!=null;) {
                var r=new JSONObject(s);
                var p=Path.of("classified-data").resolve(r.getString("source")).toRealPath();
                var loaded=new HashMap<String,String>();
                var m=CompUtil.parseEverything_fromFile(A4Reporter.NOP,loaded,p.toString());
                var sha=HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(
                        loaded.get(p.toString()).getBytes(StandardCharsets.UTF_8)));
                if(!sha.equals(r.getString("sha")) || refs.size()!=r.getInt("id")) throw new AssertionError(p);
                String name=r.getString("operator"), peer=null;
                for(var c:m.getAllCommands()) {
                    var pair=CommandComparison.assertionPair(m,c);
                    if(pair!=null && c.label.equals("correct")) {
                        var x=pair[0].label.substring(5); var y=pair[1].label.substring(5);
                        peer=name.equals(x)?y:name.equals(y)?x:null;
                    }
                }
                if(peer==null) throw new AssertionError("Unbound reference: "+p);
                refs.add(ScopedPoolEndpoint.read(p,name,peer,refs.size(),ScopedPoolEndpoint.closureDigest(loaded)));
            }
        }
        int seen=0, hits=0, newEdges=0, sat=0;
        try(var f=open(data.resolve("pairs.csv.gz"))) {
            if(!f.readLine().equals("left,right,baseline_zero,native,forward,reverse,root_sha256"))
                throw new AssertionError("pair schema");
            for(String s;(s=f.readLine())!=null;) {
                var row=s.split(",",-1);
                var decision=ScopedPoolEndpoint.compare(refs.get(Integer.parseInt(row[0])),refs.get(Integer.parseInt(row[1])))
                        .orElseThrow(()->new AssertionError("No common scope: "+row[0]+","+row[1]));
                var rule=String.join("|",new TreeSet<>(decision.rules()));
                if(!rule.equals(row[4]) || !rule.equals(row[5]) || decision.matched() && !row[3].equals("UNSAT"))
                    throw new AssertionError("Decision mismatch: "+s+" actual="+rule);
                if(decision.matched()) { hits++; if(row[2].equals("0")) newEdges++; }
                if(row[3].equals("SAT")) sat++;
                seen++;
            }
        }
        if(refs.size()!=4496 || seen!=132032 || hits!=1234 || newEdges!=1107 || sat!=105)
            throw new AssertionError("Incomplete cohort");
        System.out.printf("Default source replay: %d pairs; %d matches; %d non-baseline edges; %d SAT controls refused.%n",
                seen,hits,newEdges,sat);
    }
}
