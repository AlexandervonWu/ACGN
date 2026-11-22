package org.acgn.cert;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.CanonicalAlloyPipeline;
import org.json.JSONObject;
import parser.ast.nodes.ModelUnit;

import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.jar.JarFile;

/** Original P6-11 schema prerequisite, with two real jar executions and source preflight. */
public final class P611SchemaAdmissionTest {
    private static final String THEORY = "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";
    private static final String ROOT = "schemacalls/selected";
    private static final String RAW = """
            module schemacalls
            sig A {}
            fun f[x:A]: A { x }
            pred selected { some f[A] }
            """;
    private static final Limits LIMITS = Limits.defaults();
    private static final List<String> LABELS = List.of("acgncert-schema-v10", "acgncert-schema-v5",
            "acgncert-schema-v6", "acgncert-schema-v7", "acgncert-schema-v8", "acgncert-schema-v9",
            "acgncert-schema-v11", "acgncert-schema-v010", "", "acgncert-schema-v１０");

    private final Path tmp, rawFile, goodFile;
    private final List<String> rows = new ArrayList<>(List.of("authority\troute\tcase\tobservation"));
    private final IndependentVerifier verifier = new IndependentVerifier();
    private final byte[] raw, good;
    private final RawCallSourceAuthority authority;
    private final CallOccurrenceCommitment pin;
    private final VerificationPolicy policy;
    private final Wire.Node root;

    private P611SchemaAdmissionTest(Path tmp) throws Exception {
        this.tmp = tmp;
        raw = RAW.getBytes(StandardCharsets.UTF_8);
        rawFile = Files.write(tmp.resolve("input.als"), raw);
        goodFile = tmp.resolve("input.acgncert");
        authority = RawCallSourceAuthority.fromSource(raw, ROOT);
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, RAW);
        var visitor = new MASGVisitor(new GlobalVariables(), Set.of("selected"), module);
        visitor.visit(new ModelUnit(null, module), null);
        var graph = visitor.getForest().get(visitor.getForestId("selected"));
        CanonicalAlloyPipeline.prepareCompatibilityForVerification(graph, ROOT, raw)
                .certificateExportSession().write(goodFile);
        good = Files.readAllBytes(goodFile);
        root = Codec.decode(good, LIMITS);
        pin = authority.commitment(good);
        policy = VerificationPolicy.trust(THEORY).withCallOccurrenceCommitment(pin);
        check(Bundle.parse(root).semanticEvidence().child(5).children().size() == 1, "positive source CALL inventory");
    }

    private static void check(boolean condition, String detail) {
        if (!condition) throw new AssertionError("P6-11 " + detail);
    }

    private void record(String owner, String route, String label, String value) {
        rows.add(String.join("\t", owner, route, label, value));
    }

    private static String labelName(String schema) {
        return schema.isEmpty() ? "empty" : schema.substring("acgncert-schema-".length());
    }

    private static String hash(byte[] bytes) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
    }

    private static byte[] relabel(Wire.Node root, String label) {
        byte[] encoded = Codec.encode(Wire.node(root.tag(), List.of(label), root.children()));
        var decoded = Codec.decode(encoded, LIMITS);
        check(decoded.scalars().equals(List.of(label)) && decoded.children().size() == 12, "envelope-valid mutation");
        return encoded;
    }

    private void result(String owner, String route, String label, VerificationResult result, FailureCode wanted) {
        Outcome expected = wanted == FailureCode.NONE ? Outcome.VERIFIED : Outcome.REJECTED;
        check(result.outcome() == expected && result.code() == wanted, route + " " + label + " " + result);
        record(owner, route, label, result.outcome() + "/" + result.code());
    }

    private void guard(String route, String label, boolean valid, Runnable operation) {
        try {
            operation.run();
            check(valid, route + " accepted " + label);
            record("api", route, label, "OK");
        } catch (FormatException e) {
            check(!valid && e.code() == FailureCode.UNSUPPORTED_FORMAT_VERSION
                    && e.getMessage().startsWith("Unsupported bundle schema "), route + " " + e);
            record("api", route, label, "THROW/" + e.code());
        }
    }

    private record Response(int exit, String out) {}
    private Response launch(List<String> args) throws Exception {
        var command = new ArrayList<>(List.of(Path.of(System.getProperty("java.home"), "bin", "java").toString(), "-Xmx128m"));
        command.addAll(args);
        Path log = tmp.resolve("subprocess.log");
        var p = new ProcessBuilder(command).redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if (!p.waitFor(30, TimeUnit.SECONDS)) {
            p.destroyForcibly().waitFor();
            throw new AssertionError("P6-11 timed out " + args.get(0));
        }
        return new Response(p.exitValue(), Files.readString(log).strip());
    }

    private void cliResult(String distribution, String route, String label, List<String> args, boolean valid) throws Exception {
        Response response = launch(args);
        var object = new JSONObject(response.out());
        String outcome = object.getString("outcome"), code = object.getString("code");
        check(response.exit() == (valid ? 0 : 2) && (valid ? "VERIFIED" : "REJECTED").equals(outcome)
                && (valid ? "NONE" : "UNSUPPORTED_FORMAT_VERSION").equals(code)
                && (valid || object.getString("detail").startsWith("Unsupported bundle schema ")),
                distribution + " " + route + " " + label + " " + response);
        record(distribution, route, label, "EXIT_" + response.exit() + "/" + outcome + "/" + code);
    }

    private void cliInspect(String owner, String route, String label, List<String> args, boolean valid,
            String expect) throws Exception {
        Response r = launch(args);
        check(valid ? r.exit() == 0 && r.out().equals(expect)
                    : r.exit() == 1 && r.out().contains("org.acgn.cert.FormatException: Unsupported bundle schema ")
                        && !r.out().contains("\"outcome\"") && !r.out().contains(expect),
                route + " " + label + " " + r);
        record(owner, route, label, valid ? "EXIT_0/VALUE" : "EXIT_1/UNCAUGHT_FORMAT_EXCEPTION");
    }

    private List<String> verifierArgs(Path jar, Profile profile, Path... files) {
        var args = new ArrayList<>(List.of("-jar", jar.toString(), "--profile", profile.name(), "--theory-digest",
                THEORY, "--call-occurrence-commitment", pin.assignment()));
        for (var path : files) args.add(path.toString());
        return args;
    }

    private void publicJar(String owner, Path jar, String name, Path file, boolean valid) throws Exception {
        for (var profile : Profile.values()) if (profile != Profile.PAIR) {
            cliResult(owner, profile.name(), name, verifierArgs(jar, profile, file), valid);
        }
        cliResult(owner, "PAIR-left", name, verifierArgs(jar, Profile.PAIR, file, goodFile), valid);
        cliResult(owner, "PAIR-right", name, verifierArgs(jar, Profile.PAIR, goodFile, file), valid);
        cliInspect(owner, "inspect-call", name, List.of("-jar", jar.toString(), "--inspect-call-occurrences",
                file.toString()), valid, pin.assignment());
        cliInspect(owner, "inspect-manifest", name, List.of("-cp", jar.toString(), ManifestInspector.class.getName(),
                file.toString()), valid, THEORY);
    }

    private void sourceHelpers(String name, Path file, byte[] encoded, boolean valid) throws Exception {
        FailureCode code = valid ? FailureCode.NONE : FailureCode.UNSUPPORTED_FORMAT_VERSION;
        guard("source-metadata", name, valid, () -> check(authority.commitment(encoded).equals(pin), "source pin"));
        result("api", "source-FULL", name, P613SourcePair.verifyFull(THEORY, raw, ROOT, encoded), code);
        result("api", "source-PAIR-left", name, P613SourcePair.verify(THEORY,raw,ROOT,encoded,raw,ROOT,good),code);
        result("api", "source-PAIR-right", name, P613SourcePair.verify(THEORY,raw,ROOT,good,raw,ROOT,encoded),code);
        String cp = System.getProperty("java.class.path");
        cliInspect("source-tool", "metadata", name, List.of("-cp", cp, RawCallSourceAuthority.class.getName(),
                rawFile.toString(), ROOT, file.toString()), valid, pin.assignment());
        for (boolean left : List.of(true,false)) {
            cliResult("source-tool", left ? "PAIR-left" : "PAIR-right", name,
                    List.of("-cp",cp,P613SourcePair.class.getName(),THEORY, rawFile.toString(),ROOT,
                            (left ? file : goodFile).toString(),rawFile.toString(),ROOT,(left ? goodFile : file).toString()), valid);
        }
    }

    private void cases(Path built, Path distribution) throws Exception {
        for (String schema : LABELS) {
            String name = labelName(schema);
            boolean valid = schema.equals("acgncert-schema-v10");
            byte[] encoded = relabel(root, schema);
            Path file = Files.write(tmp.resolve("relabeled.acgncert"), encoded);
            FailureCode code = valid ? FailureCode.NONE : FailureCode.UNSUPPORTED_FORMAT_VERSION;
            for (Profile p : Profile.values()) if (p != Profile.PAIR) {
                result("api", p.name(), name, verifier.verify(encoded,p,policy), code);
            }
            result("api", "PAIR-left", name, verifier.verifyPair(encoded,good,policy), code);
            result("api", "PAIR-right", name, verifier.verifyPair(good,encoded,policy), code);
            guard("bundle-metadata", name, valid, () -> check(Bundle.parse(Codec.decode(encoded,LIMITS))
                    .metadata().inputIdentifier().equals(ROOT), "selected source root"));
            guard("inspect-call", name, valid, () -> check(CallOccurrenceCommitment.inspect(encoded,LIMITS)
                    .equals(pin), "inspected pin differs from independently bound CALL"));
            sourceHelpers(name, file, encoded, valid);
            publicJar("built-jar", built, name, file, valid);
            publicJar("tracked-jar", distribution, name, file, valid);
        }
    }

    private void otherControls(Path fixtures, Path built, Path tracked) throws Exception {
        var dualRoot = Codec.decode(Files.readAllBytes(fixtures.resolve("schema-v8-coverage/bind-block-dual-a.acgncert")),LIMITS);
        var occurrences = Bundle.parse(dualRoot).semanticEvidence().child(3);
        check(occurrences.children().size() == 2 && !occurrences.child(0).scalar(8).equals(occurrences.child(1).scalar(8))
                && occurrences.child(0).scalar(3).equals(occurrences.child(1).scalar(3)), "dual rooted binder witness");
        record("api","two-root-binder","v10","TWO_OWNERS/SAME_LOCAL_PATH");
        guard("two-root-binder","v9",false,()->Bundle.parse(Codec.decode(relabel(dualRoot,"acgncert-schema-v9"),LIMITS)));
        // The fixture constructor supplies these exact input bytes, identifier and two binder nodes with zero CALLs.
        String dualSubject = CallOccurrenceCommitment.subjectDigest("fixture/bind-block-dual",
                hash("dual symmetric binder occurrences".getBytes(StandardCharsets.UTF_8)));
        var dualPin = new CallOccurrenceCommitment(dualSubject,CallOccurrenceCommitment.digest(dualSubject,List.of()));
        var dualPolicy = VerificationPolicy.trust(THEORY).withCallOccurrenceCommitment(dualPin);
        Path dualPath = tmp.resolve("two-roots.acgncert");
        for (int version=5; version<=10; version++) {
            String v="v"+version;
            boolean valid=version==10;
            byte[] encoded=relabel(dualRoot,"acgncert-schema-"+v);
            Files.write(dualPath,encoded);
            result("api","two-root-FULL",v,verifier.verify(encoded,Profile.FULL,dualPolicy),
                    valid ? FailureCode.NONE : FailureCode.UNSUPPORTED_FORMAT_VERSION);
            for (var jar : List.of(Map.entry("built-jar",built),Map.entry("tracked-jar",tracked))) {
                cliResult(jar.getKey(),"two-root-FULL",v,List.of("-jar",jar.getValue().toString(),
                        "--profile","FULL","--theory-digest",THEORY,"--call-occurrence-commitment",
                        dualPin.assignment(),dualPath.toString()),valid);
            }
        }
        result("api","single-PAIR","bad-magic",verifier.verify(new byte[0],Profile.PAIR,policy),FailureCode.INVALID_RECORD_SHAPE);
        for (Wire.Node malformed : List.of(Wire.node("other",root.scalars(),root.children()),
                Wire.node(root.tag(),List.of(),root.children()),Wire.node(root.tag(),List.of("v1","v2"),root.children()),
                Wire.node(root.tag(),root.scalars(),root.children().subList(0,11)))) {
            String shape = malformed.tag() + "/" + malformed.scalars().size() + "/" + malformed.children().size();
            result("api","root-shape",shape,verifier.verify(Codec.encode(malformed),Profile.FULL,policy),FailureCode.INVALID_RECORD_SHAPE);
        }
        byte[] bad = good.clone(); bad[0] ^= 1;
        result("api","envelope","bad-magic",verifier.verify(bad,Profile.FULL,policy),FailureCode.BAD_MAGIC);
        bad = good.clone(); bad[9] = 2;
        var envelope = verifier.verify(bad,Profile.FULL,policy);
        result("api","envelope","version-2",envelope,FailureCode.UNSUPPORTED_FORMAT_VERSION);
        check(envelope.detail().equals("Unsupported format version 2"),"envelope version precedence");
        bad = good.clone(); bad[bad.length-1] ^= 1;
        result("api","envelope","bad-digest",verifier.verify(bad,Profile.FULL,policy),FailureCode.DIGEST_MISMATCH);
        check(Codec.decode(relabel(root,"historical"),LIMITS).scalar(0).equals("historical"),"bare codec");
        record("boundary","Codec.decode","historical","DECODED_TREE_ONLY");
        check(VerificationResult.verified("caller-created").outcome()==Outcome.VERIFIED,"result DTO");
        record("boundary","VerificationResult.verified","factory","CALLER_CONSTRUCTED_DTO");
        String text = "independent DTO", digest = hash(text.getBytes(StandardCharsets.UTF_8));
        var metadata = new Bundle.Metadata(text,false,text,text,text,text,"TEST_ONLY",digest,digest,text,text,digest,
                digest,text,digest,digest,text,digest);
        check(metadata.inputIdentifier().equals(text),"standalone metadata DTO");
        record("boundary","Bundle.Metadata","constructor","CALLER_CONSTRUCTED_DTO");
    }

    private void distribution(Path built, Path tracked) throws Exception {
        check(Files.mismatch(built, tracked) == -1, "tracked verifier JAR is not byte-identical to the clean build");
        try (var a = new JarFile(tracked.toFile()); var b = new JarFile(built.toFile())) {
            check(a.getManifest().getMainAttributes().getValue("Main-Class").equals("org.acgn.cert.Main"),"manifest entry point");
            var classes = a.stream().filter(e->e.getName().endsWith(".class")).map(e->e.getName()).sorted().toList();
            check(!classes.isEmpty() && classes.equals(b.stream().filter(e->e.getName().endsWith(".class"))
                    .map(e->e.getName()).sorted().toList()),"distribution class census");
            var contents = new ArrayList<String>();
            for(String c : classes) {
                try(var x=a.getInputStream(a.getEntry(c));var y=b.getInputStream(b.getEntry(c))) {
                    byte[] bytes=x.readAllBytes();
                    check(Arrays.equals(bytes,y.readAllBytes()),"mismatched distribution class "+c);
                    contents.add(c+"\t"+hash(bytes));
                }
            }
            record("distribution","manifest","main-class","org.acgn.cert.Main");
            record("distribution","class-census",Integer.toString(classes.size()),hash(String.join("\n",contents).getBytes(StandardCharsets.UTF_8)));
            record("distribution","jar-bytes","clean-vs-tracked",hash(Files.readAllBytes(built)));
        }
    }

    public static void main(String[] args) throws Exception {
        if(args.length!=4) throw new IllegalArgumentException("P611SchemaAdmissionTest ROOT FIXTURES CLEAN_JAR FRESH_TSV");
        Path repo=Path.of(args[0]).toAbsolutePath(), fixtures=Path.of(args[1]), built=Path.of(args[2]);
        Path tracked=repo.resolve("certificate-verifier/build/acgn-certificate-verifier.jar");
        Path output=Path.of(args[3]).toAbsolutePath();
        Path tmp=Files.createTempDirectory(output.getParent(),"p611-work-");
        try {
            var test=new P611SchemaAdmissionTest(tmp);
            test.rows.addAll(P611SchemaRoutes.audit(repo));
            test.otherControls(fixtures,built,tracked);
            test.cases(built,tracked);
            test.distribution(built,tracked);
            Files.write(output,test.rows,StandardCharsets.UTF_8,StandardOpenOption.CREATE_NEW);
            System.out.println("P6-11 schema admission verified: "+(test.rows.size()-1)+" observations");
        } finally {
            try(var paths=Files.walk(tmp)) {
                for(Path p:paths.sorted(Comparator.reverseOrder()).toList()) Files.delete(p);
            }
        }
    }
}
