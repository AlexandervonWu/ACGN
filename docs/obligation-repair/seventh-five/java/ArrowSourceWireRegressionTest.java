package org.acgn.cert;

import is.fivefivefive.CanDis.RawArrowOccurrenceAuthority;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.theory.RecordingCertificateTraceSink;
import is.fivefivefive.CanDis.theory.CertificateProvenance;
import is.fivefivefive.CanDis.theory.CertificateTracePayload;
import is.fivefivefive.CanDis.theory.TheoryAlloyAdapter;
import is.fivefivefive.CanDis.theory.StructuralKey;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.TimeUnit;
import org.json.JSONObject;

/** Exercises the externally selected source, one live transfer/export, and the independent public CLI. */
public final class ArrowSourceWireRegressionTest {
    private static final byte[] SOURCE = """
            module origin
            abstract sig Parent {}
            sig A,B,C extends Parent {}
            pred left { some ((A -> B) -> C) }
            pred right { some (A -> (B -> C)) }
            pred reversed { some ((B -> A) -> C) }
            """.getBytes(StandardCharsets.UTF_8);
    private static final String THEORY = "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";
    private final Path tmp, jar;
    private final List<String> rows = new ArrayList<>(List.of("case\toutcome\tcode"));
    private ArrowSourceWireRegressionTest(Path tmp, Path jar) { this.tmp = tmp; this.jar = jar; }

    private static void check(boolean ok, String message) {
        if (!ok) throw new AssertionError(message);
    }

    private record Export(Path path, Bundle bundle, CallOccurrenceCommitment calls, String foreignDagProof) {}

    private Export export(RawArrowSourcePin.Authority source, String label) throws Exception {
        var raw = source.raw();
        var produced = RawArrowOccurrenceAuthority.produce(SOURCE, raw.root());
        var result = produced.forVerification(CertificateProvenance.capture(raw.root(), SOURCE, "g08-arrow-source-wire"));
        raw.verifyRetained(produced.prepared(), result);
        var binding = result.dependentChainSourceBindings().entrySet().iterator().next();
        check(binding.getKey().getSourceOccurrenceLineage() > 0, "missing producer transfer lineage");
        binding.getValue().requireMatches(binding.getKey());
        var certificate = binding.getValue().certificate();
        var session = result.certificateExportSession();
        Path path = tmp.resolve(label + ".acgncert");
        session.write(path);
        Bundle bundle = Bundle.parse(Codec.decode(Files.readAllBytes(path), Limits.defaults()));
        Wire.Node section = bundle.semanticEvidence().child(1);
        check(section.children().size() == 1, "expected one wire source construction");
        Wire.Node record = section.child(0).requireShape("dependent-chain-construction", 11, 1);
        check(record.scalar(0).equals(certificate.structuralKey().stableString())
                && record.scalar(4).equals(certificate.leftEndpoint().structuralKey().stableString())
                && record.scalar(5).equals(certificate.rightEndpoint().structuralKey().stableString())
                && record.scalar(9).equals(certificate.theoryIndex().stableString())
                && record.scalar(10).equals(binding.getValue().sourceOccurrenceCommitment().stableString()),
                "wire evidence differs from the transferred source");
        List<String> owners = new ArrayList<>();
        for (var event : session.events()) {
            if (event.payload() instanceof CertificateTracePayload.Insertion i
                    && i.result().canonicalization().sourceConstruction()
                        .filter(c -> c.structuralKey().equals(certificate.structuralKey())).isPresent()) {
                owners.add("source-owner/" + Wire.contentId(Wire.node("construction-source-owner-v1",
                        List.of(raw.root(), raw.sourceHash(), Long.toString(event.sequence()),
                                i.result().insertedClass().id().toString()), List.of())));
            }
        }
        check(owners.equals(List.of(record.scalar(6))), "wire owner differs from live insertion");
        rows.add(label + "-transfer\tMATCHED\tSOURCE_WIRE_OWNER");
        var leafInputs = certificate.source().leafInputs();
        var original = leafInputs.get(0).typeProof();
        var foreignDag = leafInputs.get(1).typeProof().children().get(1);
        String transplanted = StructuralKey.of(original.tag(), original.scalars(),
                List.of(original.children().get(0), foreignDag)).stableString();
        check(raw.root().equals(bundle.metadata().inputIdentifier())
                && raw.sourceHash().equals(bundle.metadata().inputSha256()), "different source or predicate");
        return new Export(path, bundle, source.calls(), transplanted);
    }

    private void full(String name, Path path, CallOccurrenceCommitment calls, ArrowSourceCommitment source,
            int status, String outcome, String code, String reason) throws Exception {
        var command = new ArrayList<>(List.of(Path.of(System.getProperty("java.home"), "bin", "java").toString(),
                "-Xmx256m", "-jar", jar.toString(), "--profile", "full", "--theory-digest", THEORY));
        if (calls != null) command.addAll(List.of("--call-occurrence-commitment", calls.assignment()));
        if (source != null) command.addAll(List.of("--arrow-source-commitment", source.assignment()));
        command.add(path.toString());
        Path log = tmp.resolve(name + ".log");
        var proc = new ProcessBuilder(command).redirectErrorStream(true).redirectOutput(log.toFile()).start();
        if (!proc.waitFor(60, TimeUnit.SECONDS)) {
            proc.destroyForcibly(); proc.waitFor(); throw new AssertionError("verifier timed out");
        }
        String output = Files.readString(log);
        var json = new JSONObject(output);
        check(proc.exitValue() == status && json.getString("outcome").equals(outcome)
                && json.getString("code").equals(code) && json.getString("detail").contains(reason), name + ": " + output);
        rows.add(name + "\t" + outcome + "\t" + code);
    }

    private static Wire.Node withChild(Wire.Node node, int index, Wire.Node child) {
        var children = new ArrayList<>(node.children()); children.set(index, child);
        return Wire.node(node.tag(), node.scalars(), children);
    }

    private static Wire.Node withScalar(Wire.Node node, int index, String scalar) {
        var scalars = new ArrayList<>(node.scalars()); scalars.set(index, scalar);
        return Wire.node(node.tag(), scalars, node.children());
    }

    private Path badProof(Export export, boolean foreign) throws Exception {
        Wire.Node root = export.bundle().root(), manifest = root.child(1), vocab = manifest.child(1);
        Wire.Node evidence = vocab.child(3), constructions = evidence.child(1), record = constructions.child(0);
        Wire.Node binary = record.child(0), nested = binary.child(0), first = nested.child(0);
        String proof = first.scalar(4);
        String changed = foreign ? export.foreignDagProof() : proof.replace("RELATION[1:A]", "RELATION[1:Z]");
        check(!changed.equals(proof), "leaf mutation made no change");
        Wire.Node replacement = withChild(nested, 0, withScalar(first, 4, changed));
        Wire.Node newRecord = withChild(record, 0, withChild(binary, 0, replacement));
        Wire.Node newVocab = withChild(vocab, 3, withChild(evidence, 1, withChild(constructions, 0, newRecord)));
        Wire.Node newManifest = withScalar(withChild(manifest, 1, newVocab), 1, Wire.contentId(newVocab));
        Path path = tmp.resolve(foreign ? "foreign-proof.acgncert" : "invented-parser-type.acgncert");
        Files.write(path, Codec.encode(withChild(root, 1, newManifest)));
        return path;
    }

    /** This synthetic IR intentionally has no parser ancestry beyond the column itself. */
    private void unpinnedSingletonAncestry() throws Exception {
        EGraphNode.beginGraph();
        try {
            EGraphNode a = syntheticNode(1, EGraphNode.Opcode.GLOBALBINDING, ExactAlloyType.unaryRelation("A"));
            EGraphNode b = syntheticNode(2, EGraphNode.Opcode.GLOBALBINDING, ExactAlloyType.unaryRelation("B"));
            a.setSourceName("A"); b.setSourceName("B");
            EGraphNode arrow = syntheticNode(3, EGraphNode.Opcode.ARROW, ExactAlloyType.relation(List.of("A", "B")), a, b);
            EGraphNode some = syntheticNode(4, EGraphNode.Opcode.SOME, ExactAlloyType.boolType(), arrow);
            var form = new NormalForm();
            form.addEClass(some);
            var provenance = CertificateProvenance.capture("synthetic/singleton", new byte[0], "g08-no-source");
            var result = TheoryAlloyAdapter.adaptForVerification(List.of(form),
                    new RecordingCertificateTraceSink(), provenance);
            Path path = tmp.resolve("synthetic-singleton.acgncert");
            result.certificateExportSession().write(path);
            Bundle bundle = Bundle.parse(Codec.decode(Files.readAllBytes(path), Limits.defaults()));
            Wire.Node app = bundle.semanticEvidence().child(1).child(0).child(0);
            for (int index = 0; index < 2; index++) {
                Wire.Node leaf = app.child(index).requireShape("dependent-chain-leaf", 5, 1);
                check(leaf.scalar(4).contains("dependent-chain-leaf-type-proof-v2")
                        && leaf.child(0).child(0).child(0).children().size() == 1,
                        "control requires exact v2, singleton ancestry");
            }
            String subject = CallOccurrenceCommitment.subjectDigest(provenance.inputIdentifier(), provenance.inputSha256());
            var emptyCalls = new CallOccurrenceCommitment(subject, CallOccurrenceCommitment.digest(subject, List.of()));
            full("singleton-unpinned", path, emptyCalls, null, 3, "UNCHECKABLE", "MISSING_EVIDENCE",
                    "caller-pinned ARROW source commitment");
        } finally {
            EGraphNode.endGraph();
        }
    }

    private static EGraphNode syntheticNode(int id, EGraphNode.Opcode opcode, ExactAlloyType type,
            EGraphNode... children) {
        var node = new EGraphNode(id, opcode, new ArrayList<>(), false, children.length, false,
                opcode == EGraphNode.Opcode.SOME ? EGraphNode.Metatype.BOOLEAN : EGraphNode.Metatype.SET);
        node.setExactAlloyType(type);
        for (EGraphNode child : children) node.addChild(child);
        return node;
    }

    private void run() throws Exception {
        var left = RawArrowSourcePin.read(SOURCE, "origin/left");
        var right = RawArrowSourcePin.read(SOURCE, "origin/right");
        var reversed = RawArrowSourcePin.read(SOURCE, "origin/reversed");
        var first = export(left, "left");
        var second = export(right, "right");
        full("left-full", first.path(), first.calls(), left.pin(), 0, "VERIFIED", "NONE", "full profile");
        full("right-full", second.path(), second.calls(), right.pin(), 0, "VERIFIED", "NONE", "full profile");
        full("missing-arrow-pin", first.path(), first.calls(), null, 3, "UNCHECKABLE", "MISSING_EVIDENCE", "caller-pinned ARROW source commitment");
        full("different-root", first.path(), first.calls(), right.pin(), 3, "UNCHECKABLE", "MISSING_EVIDENCE", "this input scope");
        full("missing-call-pin", first.path(), null, left.pin(), 3, "UNCHECKABLE", "MISSING_EVIDENCE", "CALL occurrence completeness");
        String root = left.raw().root(), hash = left.raw().sourceHash();
        full("association-swap", first.path(), first.calls(), ArrowSourceCommitment.from(root, hash, right.leaves(), right.ancestry()),
                2, "REJECTED", "MISSING_EVIDENCE", "roles or complete ancestry");
        full("operand-swap", first.path(), first.calls(), ArrowSourceCommitment.from(root, hash, reversed.leaves(), left.ancestry()),
                2, "REJECTED", "MISSING_EVIDENCE", "roles or complete ancestry");
        var stale = new HashMap<>(left.ancestry());
        check(stale.get("A").equals(List.of("A", "Parent", "univ")), "resolved raw hierarchy");
        stale.put("A", List.of("A", "univ"));
        full("skipped-parent", first.path(), first.calls(), ArrowSourceCommitment.from(root, hash, left.leaves(), stale),
                2, "REJECTED", "MISSING_EVIDENCE", "roles or complete ancestry");
        full("fabricated-parser-type", badProof(first, false), first.calls(), left.pin(),
                2, "REJECTED", "THEORY_MISMATCH", "leaf type proof does not independently reconstruct");
        full("foreign-leaf-dag", badProof(first, true), first.calls(), left.pin(),
                2, "REJECTED", "THEORY_MISMATCH", "leaf type proof does not independently reconstruct");
        unpinnedSingletonAncestry();
        byte[] repeated = RawArrowOccurrenceAuthority.fixtureBytes();
        String selected = "arrows/selected";
        var raw = RawArrowOccurrenceAuthority.parse(repeated, selected);
        var produced = RawArrowOccurrenceAuthority.produce(repeated, selected);
        TheoryAlloyAdapter.Result result = produced.forVerification(CertificateProvenance.capture(selected, repeated, "g08-collision"));
        raw.verifyRetained(produced.prepared(), result);
        Path absent = tmp.resolve("retired.acgncert");
        try {
            result.certificateExportSession().write(absent);
            throw new AssertionError("retired collision exported unexpectedly");
        } catch (IOException e) {
            check(e.getMessage().equals("UNCHECKABLE: retired collision records are not exportable")
                    && !Files.exists(absent), "unexpected export refusal " + e);
            rows.add("retired-collision\tUNCHECKABLE\tPRODUCER_NO_EXPORT");
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) throw new IllegalArgumentException("usage: ArrowSourceWireRegressionTest OUTPUT.tsv");
        Path jar = Path.of(System.getenv().getOrDefault("ACGN_SEVENTH_VERIFIER_JAR",
                "certificate-verifier/build/acgn-certificate-verifier.jar")).toAbsolutePath();
        if (!Files.isRegularFile(jar)) throw new IllegalArgumentException("missing standalone verifier");
        Path tmp = Files.createTempDirectory("acgn-seventh-arrow-wire-");
        try {
            var test = new ArrowSourceWireRegressionTest(tmp, jar);
            test.run();
            Files.write(Path.of(args[0]), test.rows);
            System.out.println("ArrowSourceWireRegressionTest passed: cases=" + (test.rows.size() - 1));
        } finally {
            try (var paths = Files.walk(tmp)) {
                for (var file : paths.sorted(Comparator.reverseOrder()).toList()) Files.delete(file);
            }
        }
    }
}
