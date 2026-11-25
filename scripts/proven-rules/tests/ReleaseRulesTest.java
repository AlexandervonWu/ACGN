package is.fivefivefive.CanDis.augmentation;

import java.nio.file.*;
import java.util.*;
import is.fivefivefive.CanDis.ProvenRewriteRule;

public final class ReleaseRulesTest {
    private static void need(boolean ok,String why) { if(!ok) throw new AssertionError(why); }
    public static void main(String[] args) throws Exception {
        var data=Path.of("classified-data");
        var expected=Map.of("classroom_rl/correct/6SaKTDtHbkfiD6pbh_inv8.als","fiber",
                "trainStationNew/correct/2j59AQ2mBXJ3HFHRu_inv5.als","classifier",
                "coursesNew/correct/YrQBtYjxRadc3HhJi_inv1.als","role",
                "socialMedia/correct/8PX5zdXt3Q226DThH_inv4.als","mixedRole",
                "graphs/correct/Xj8o4rH8bNcE7oZ5A_inv2.als","difference");
        for(var e:expected.entrySet()){
            var row=ProvenRulesCommand.check(data.resolve(e.getKey()),"correct");
            need(row.getString("native").equals("UNSAT") && row.getJSONArray("rules").toList().equals(List.of(e.getValue())),e.getKey());
        }
        var neg=ProvenRulesCommand.check(data.resolve("classroom_fol/both/4J8sS2Kr8KrhgsN6R_inv4.als"),"correct");
        need(neg.getString("native").equals("SAT") && neg.getString("result").equals("NO_RULE_MATCH") && neg.getInt("traceMax")>0,"call-aware temporal control");
        var file=Path.of(args[0]);
        Files.writeString(file,"sig A {} pred p { some A } pred q { not no A } check ok { p iff q } check wrong { p implies q }");
        need(ProvenRulesCommand.check(file,"ok").getString("result").equals("NO_RULE_MATCH"),"UNSAT alone must not admit an equality");
        for(var name:List.of("wrong","missing")){
            try { ProvenRulesCommand.check(file,name); throw new AssertionError("accepted "+name); }
            catch(IllegalArgumentException expectedError) { /* Unsupported command shape or absent check. */ }
        }
        var ids=new HashSet<String>();
        for(var rule:ProvenRewriteRule.values()){
            need(ids.add(rule.id()),"duplicate rule");
            for(var anchor:rule.proofAnchors()){
                var names=anchor.split("\\.",2);
                String source=Files.readString(Path.of("docs/section3-repair-audit/formal", names[0]+".lean"));
                need(source.contains("theorem "+names[1]+" "),"missing theorem: "+anchor);
            }
        }
        var trace=Files.readAllLines(Path.of("docs/section3-repair-audit/rewrite-rule-traceability.tsv"));
        need(trace.stream().anyMatch(l->l.startsWith(ProvenRewriteRule.STATIC_ALL_ALWAYS.id()+"\tPRODUCTION\t")
                && l.contains("NormalForm.java#moveStaticUniversals") && l.contains("changing_domain_blocks_all_always")),"missing production gate");
        System.out.println("PASS: five source-linked readers, temporal counterexample, no-match, command isolation and six catalog routes");
    }
}
