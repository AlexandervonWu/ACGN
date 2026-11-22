package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.metric.QuotientRepairDistance;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.concurrent.TimeUnit;
import org.json.*;
import parser.ast.nodes.ModelUnit;

/** A raw Alloy pair with one charged edit among seven complete partial assignments. */
public final class BoundedAssignmentMinimumTest {
    private static final Path MODEL = Path.of("docs/obligation-repair/seventh-five/bounded-assignment.als");
    private static final String THEORY = "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";
    private final List<String> rows = new ArrayList<>(List.of("case\toutcome\tvalue"));
    private final byte[] raw;
    private final Path temp, verifier;
    private BoundedAssignmentMinimumTest(byte[] raw, Path temp, Path verifier) {
        this.raw=raw; this.temp=temp; this.verifier=verifier;
    }

    record Endpoint(String name, Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified,
                    Path bundle, String emptyCalls) {}
    private static String framed(String... values) throws Exception {
        var digest = MessageDigest.getInstance("SHA-256");
        for (String value : values) {
            byte[] bytes = value.getBytes(StandardCharsets.UTF_8);
            digest.update(ByteBuffer.allocate(4).putInt(bytes.length).array());
            digest.update(bytes);
        }
        return HexFormat.of().formatHex(digest.digest());
    }
    private Endpoint endpoint(String name) throws Exception {
        var module=CompUtil.parseEverything_fromString(A4Reporter.NOP,new String(raw,StandardCharsets.UTF_8));
        var visitor=new MASGVisitor(new GlobalVariables(),Set.of(name),module);
        visitor.visit(new ModelUnit(null,module),null);
        var graph=visitor.getForest().get(visitor.getForestId(name));
        String id=module.getModuleName()+"/"+name;
        var fast=Canonical.prepare(graph);
        var exact=CanonicalAlloyPipeline.prepareCompatibilityForVerification(graph,id,raw);
        // Full raw grammar check authorizes the empty CALL occurrence list for this selected root.
        BoundedAssignmentMinimum.owner(raw,name,exact);
        String version="call-occurrence-commitment-v1";
        String subject=framed(version+"/subject",id,BoundedAssignmentMinimum.sha(raw));
        String pin=subject+"="+framed(version,subject);
        Path bundle=temp.resolve(name+".acgncert");
        exact.certificateExportSession().write(bundle);
        return new Endpoint(name,fast,exact,bundle,pin);
    }
    private void standalone(String label,String profile,List<Endpoint> endpoints,int code,String state,String failure) throws Exception {
        var argv=new ArrayList<>(List.of(Path.of(System.getProperty("java.home"),"bin/java").toString(),
                "-Xmx384m","-jar",verifier.toString(),"--profile",profile,"--theory-digest",THEORY));
        for (var e:endpoints) argv.addAll(List.of("--call-occurrence-commitment",e.emptyCalls()));
        for (var e:endpoints) argv.add(e.bundle().toString());
        Path log=temp.resolve(label+".log");
        var proc=new ProcessBuilder(argv).redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if (!proc.waitFor(60,TimeUnit.SECONDS)) { proc.destroyForcibly(); proc.waitFor(); throw new AssertionError(label+" timeout"); }
        String text=Files.readString(log);
        var report=new JSONObject(text);
        check(proc.exitValue()==code && state.equals(report.getString("outcome")) && failure.equals(report.getString("code")),label+" "+text);
        rows.add(label+"\t"+state+"\t"+failure);
    }
    private static void check(boolean v,String why) { if (!v) throw new AssertionError(why); }
    @FunctionalInterface
    interface RejectionCheck { void run() throws Exception; }
    private void rejects(String label,String code,RejectionCheck check) throws Exception {
        try { check.run(); }
        catch (IllegalArgumentException e) {
            if (!code.equals(e.getMessage())) throw e;
            rows.add(label+"\tREJECTED\t"+code); return;
        }
        throw new AssertionError(label+" accepted");
    }
    private static JSONArray cloneArray(JSONArray a) { return new JSONArray(a.toString()); }

    private void compare(Endpoint a,Endpoint b,boolean controls) throws Exception {
        var oracle=BoundedAssignmentMinimum.fromSource(raw,a.name(),a.certified(),b.name(),b.certified());
        int minimum=oracle.minimum();
        var numeric=QuotientRepairDistance.distance(a.certified().repairView(),b.certified().repairView());
        check(minimum>0 && numeric==minimum && Canonical.distance(a.fast(),b.fast())==minimum,"minimum");
        var nativeResult=NativeOperationComparison.compare(a.fast(),b.fast(),a.certified(),b.certified());
        check(nativeResult.status()==NativeOperationComparison.Status.MATCHED,nativeResult.reason());
        var evidence=nativeResult.evidence();
        check(evidence.getBoolean("sourceCertificatesChecked") && evidence.getBoolean("fixedChoiceReplaysChecked")
                && evidence.getBoolean("endpointCorrespondenceChecked"),"native replay prerequisites");
        var fast=evidence.getJSONArray("fastActions"); var certified=evidence.getJSONArray("certifiedActions");
        check(oracle.verify(oracle.bind(fast))==numeric && oracle.verify(oracle.bind(certified))==numeric
                && fast.similar(certified),"both source-linked sequences");
        check(oracle.scores().size()==7 && !oracle.scores().get(1).equals(minimum),"unique minimum in seven assignments");
        String tag=a.name()+"-"+b.name();
        rows.add(tag+"-scores\tCHECKED\t"+oracle.scores());
        rows.add(tag+"-fast-certified\tCHECKED\t"+minimum);
        rows.add(tag+"-owner-actions\tCHECKED\t"+certified.length());
        boolean direct=certified.similar(oracle.directExample());
        check(direct || certified.similar(oracle.crossedExample()),"expected complete perfect matching");
        rows.add(tag+"-selected-map\tCHECKED\t"+(direct?"[0, 1]":"[1, 0]"));
        if (!controls) return;
        var suboptimal=direct?oracle.crossedExample():oracle.directExample();
        rejects("valid-suboptimal","NONMINIMUM_ALIGNMENT",()->oracle.verify(oracle.bind(suboptimal)));
        var omitted=cloneArray(certified); omitted.remove(0);
        rejects("missing-free-action","INCOMPLETE_OR_FOREIGN_ACTION",()->oracle.verify(oracle.bind(omitted)));
        var wrong=cloneArray(certified);
        int paid=wrong.length();
        for (int i=0;i<wrong.length();i++) if (wrong.getJSONObject(i).getInt("cost")>0) { paid=i;break; }
        check(paid<wrong.length(),"nonzero action");
        wrong.getJSONObject(paid).put("source","$/0/1/0");
        rejects("foreign-operation-address","INCOMPLETE_OR_FOREIGN_ACTION",()->oracle.verify(oracle.bind(wrong)));
        var changed=cloneArray(certified);changed.getJSONObject(paid).put("cost",0);
        changed.getJSONObject(1).put("cost",minimum);
        rejects("redistributed-charge","INCOMPLETE_OR_FOREIGN_ACTION",()->oracle.verify(oracle.bind(changed)));
        var owner=oracle.bind(certified);owner.getJSONObject("target").put("predicate","assignment/direct");
        rejects("foreign-target-owner","FOREIGN_OWNER",()->oracle.verify(owner));
    }
    private void run() throws Exception {
        var left=endpoint("left"); var right=endpoint("right"); var direct=endpoint("direct");
        for (var e:List.of(left,right,direct)) standalone(e.name()+"-full","full",List.of(e),0,"VERIFIED","NONE");
        standalone("nonzero-pair","pair",List.of(left,right),2,"REJECTED","THEORY_MISMATCH");
        compare(left,right,true); compare(left,direct,false); compare(right,left,false);
        rejects("foreign-export-selection","FOREIGN_EXPORT_OWNER",
                () -> BoundedAssignmentMinimum.fromSource(raw,"right",left.certified(),"direct",direct.certified()));
        byte[] changed=(new String(raw,StandardCharsets.UTF_8)+"\n").getBytes(StandardCharsets.UTF_8);
        rejects("foreign-export-bytes","FOREIGN_EXPORT_OWNER",
                () -> BoundedAssignmentMinimum.fromSource(changed,"left",left.certified(),"right",right.certified()));
    }
    public static void main(String[] args) throws Exception {
        if (args.length!=1) throw new IllegalArgumentException("Expected output TSV path");
        Path temp=Files.createTempDirectory("acgn-g07-");
        try {
            var test=new BoundedAssignmentMinimumTest(Files.readAllBytes(MODEL),temp,
                    Path.of(System.getenv("ACGN_SEVENTH_VERIFIER_JAR")).toAbsolutePath());
            test.run();
            Files.write(Path.of(args[0]),test.rows,StandardCharsets.UTF_8);
            System.out.println("BoundedAssignmentMinimumTest passed: cases="+(test.rows.size()-1));
        } finally {
            try (var paths=Files.walk(temp)) {
                for (var path:paths.sorted(Comparator.reverseOrder()).toList()) Files.delete(path);
            }
        }
    }
}
