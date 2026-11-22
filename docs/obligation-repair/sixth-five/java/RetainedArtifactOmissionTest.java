package org.acgn.cert;

import is.fivefivefive.CanDis.theory.CertificateBundleWriterTest;
import is.fivefivefive.CanDis.theory.CertificateExportSession;
import is.fivefivefive.CanDis.theory.CertifiedSemanticArtifact;
import is.fivefivefive.CanDis.theory.FlatConstructionCertificate;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.metric.RepairProjection;
import is.fivefivefive.CanDis.theory.SemanticProfile;
import is.fivefivefive.CanDis.theory.SourceOccurrenceBindingsRegressionTest;
import is.fivefivefive.CanDis.theory.TheoryAlloyAdapter;
import is.fivefivefive.CanDis.theory.ContainerLawDeclaration;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.file.*;
import java.util.*;

/** Mutate one real occurrence at its immutable producer boundary and after export. */
public final class RetainedArtifactOmissionTest {
    private static final List<String> checks = new ArrayList<>(List.of("consumer\tcase\toutcome"));

    private static CertificateExportSession fixture(boolean alternate) throws Exception {
        // Instantiate the writer's existing real graph/ledger fixture. No duplication of issuer logic.
        Method make = CertificateBundleWriterTest.class.getDeclaredMethod("certifiedFlatAndFixture", boolean.class);
        make.setAccessible(true);
        return (CertificateExportSession) make.invoke(null, alternate);
    }

    private static void producerReject(CertifiedSemanticArtifact artifact,
            List<FlatConstructionCertificate> payload, String label) {
        try {
            artifact.withFlatConstructions(payload);
        } catch (IllegalArgumentException e) {
            if (!e.getMessage().startsWith("Flat source occurrences and concrete evidence differ:")) throw e;
            checks.add("producer\t" + label + "\tSOURCE_OCCURRENCES_DIFFER");
            return;
        }
        throw new AssertionError("Producer admitted " + label);
    }

    private static void projection(CertifiedSemanticArtifact unrelated) throws Exception {
        Class<?> fixture = SourceOccurrenceBindingsRegressionTest.class;
        Method chain = fixture.getDeclaredMethod("chain", Opcode.class, String.class);
        Method node = fixture.getDeclaredMethod("node", Opcode.class, EGraphNode[].class);
        Method form = fixture.getDeclaredMethod("form", EGraphNode.class);
        for (Method build : List.of(chain, node, form)) build.setAccessible(true);

        EGraphNode.beginGraph();
        try {
            EGraphNode arrow = (EGraphNode) chain.invoke(null, Opcode.ARROW, "left");
            EGraphNode some = (EGraphNode) node.invoke(null, Opcode.SOME, new EGraphNode[] {arrow});
            NormalForm source = (NormalForm) form.invoke(null, some);
            source.normalize();
            var forms = List.of(source);
            var result = TheoryAlloyAdapter.adapt(forms, SemanticProfile.alloyOverflowForbidding());
            if (result.dependentChainSourceBindings().size() != 1
                    || !unrelated.dependentChainConstructions().isEmpty())
                throw new AssertionError("Projection control must detach one required ARROW certificate");
            RepairProjection.project(result, forms);
            checks.add("layer3\toriginal\tACCEPTED");

            // The public Result is sealed. Call the actual Layer 3 consumer with a different
            // valid, immutable artifact at its boundary, keeping its genuine source bindings.
            Method consume = Class.forName(RepairProjection.class.getName() + "$CertifiedDependentChains")
                    .getDeclaredMethod("from", CertifiedSemanticArtifact.class, Map.class, List.class);
            consume.setAccessible(true);
            try {
                consume.invoke(null, unrelated, result.dependentChainSourceBindings(), forms);
            } catch (InvocationTargetException ex) {
                if (!(ex.getCause() instanceof IllegalArgumentException failure)
                        || !"Repair projection received a chain certificate outside its artifact".equals(failure.getMessage()))
                    throw ex;
                checks.add("layer3\tdetached-artifact\tCHAIN_OUTSIDE_ARTIFACT");
                return;
            }
            throw new AssertionError("Layer 3 admitted a chain detached from the artifact");
        } finally {
            EGraphNode.endGraph();
        }
    }

    private static void writerReject(Path target) throws Exception {
        Method make = CertificateBundleWriterTest.class.getDeclaredMethod(
                "containerRegistryFixture", ContainerLawDeclaration.Kind.class);
        make.setAccessible(true);
        var session = (CertificateExportSession) make.invoke(null, ContainerLawDeclaration.Kind.SET);
        if (session.containerLaws().isEmpty() || !session.artifact().containerLaws().isEmpty())
            throw new AssertionError("Writer fixture must omit the session's laws from the retained artifact");
        try {
            session.write(target);
        } catch (IOException e) {
            if (!"UNCHECKABLE: session and artifact container-law registries differ".equals(e.getMessage())
                    || Files.exists(target)) throw e;
            checks.add("writer\tomitted-law-registry\tUNCHECKABLE/REGISTRIES_DIFFER");
            return;
        }
        throw new AssertionError("Writer published a session detached from its law registry");
    }

    private static Wire.Node replaceChild(Wire.Node parent, int index, Wire.Node value) {
        List<Wire.Node> children = new ArrayList<>(parent.children());
        children.set(index, value);
        return Wire.node(parent.tag(), parent.scalars(), children);
    }

    private static byte[] replaceFlat(Wire.Node root, List<Wire.Node> records) {
        Wire.Node manifest = root.child(1);
        Wire.Node vocabulary = manifest.child(1);
        Wire.Node evidence = vocabulary.child(3);
        Wire.Node flat = evidence.child(1).requireTag("flat-constructions");
        Wire.Node changed = replaceChild(evidence, 1, Wire.node(flat.tag(), flat.scalars(), records));
        Wire.Node changedVocabulary = replaceChild(vocabulary, 3, changed);
        Wire.Node changedManifest = Wire.node(manifest.tag(),
                List.of(manifest.scalar(0), Wire.contentId(changedVocabulary)),
                List.of(manifest.child(0), changedVocabulary));
        return Codec.encode(replaceChild(root, 1, changedManifest));
    }

    private static void verify(byte[] bytes, VerificationPolicy policy,
            Outcome outcome, FailureCode code, String label) {
        VerificationResult actual = new IndependentVerifier().verify(bytes, Profile.FULL, policy);
        if (actual.outcome() != outcome || actual.code() != code)
            throw new AssertionError(label + " => " + actual);
        checks.add("standalone-FULL\t" + label + "\t" + outcome + "/" + code);
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("SCRATCH_DIR OUTPUT.tsv");
        Path scratch = Path.of(args[0]);
        CertificateExportSession source = fixture(false);
        CertificateExportSession alternate = fixture(true);
        CertifiedSemanticArtifact artifact = source.artifact();
        List<FlatConstructionCertificate> flat = artifact.flatConstructions();
        List<FlatConstructionCertificate> other = alternate.artifact().flatConstructions();
        if (flat.size() != 1 || other.size() != 1
                || artifact.constructionSources().flatSources().size() != 1
                || artifact.constructionSources().flatSources().equals(alternate.artifact().constructionSources().flatSources()))
            throw new AssertionError("Fixtures must contain one occurrence with distinct source groupings");
        artifact.withFlatConstructions(flat);
        checks.add("producer\toriginal\tACCEPTED");
        producerReject(artifact, List.of(), "omission");
        producerReject(artifact, List.of(flat.get(0), flat.get(0)), "duplicate");
        producerReject(artifact, other, "detached-source");

        projection(artifact);

        Path validFile = scratch.resolve("source.acgncert");
        Path alternateFile = scratch.resolve("alternate.acgncert");
        source.write(validFile);
        alternate.write(alternateFile);
        checks.add("writer\tmatched-law-registry\tEXPORTED");
        writerReject(scratch.resolve("missing-laws.acgncert"));
        byte[] valid = Files.readAllBytes(validFile);
        byte[] alternateBytes = Files.readAllBytes(alternateFile);
        Wire.Node root = Codec.decode(valid, Limits.defaults());
        Wire.Node alternateRoot = Codec.decode(alternateBytes, Limits.defaults());
        // Out-of-band TEST_ONLY fixture pins. Both fixed source strings have an empty CALL set.
        VerificationPolicy base = VerificationPolicy.trust(
                "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c");
        VerificationPolicy policy = base.withCallOccurrenceCommitment(new CallOccurrenceCommitment(
                "173ca261b831ba0c3c906926af9f531a8452d2a3a14147272834c061c9b207ce",
                "c257cd48cdcfd8a01a6eb4ddb4099f1cf2aa4b7e300fbaef5a4d2796dc0cc80a"));
        VerificationPolicy alternatePolicy = base.withCallOccurrenceCommitment(new CallOccurrenceCommitment(
                "475741483bbeebf8828137b4b511b7ee62147e0b9942bf236af2d95407ff4da2",
                "ff731f53e6efacde32837ae2335893bfc8958fa13407b2af5cb6027c82cf775c"));
        verify(valid, policy, Outcome.VERIFIED, FailureCode.NONE, "original");
        verify(alternateBytes, alternatePolicy, Outcome.VERIFIED, FailureCode.NONE, "alternate-source");
        List<Wire.Node> originalRecords = Bundle.parse(root).semanticEvidence().child(1).children();
        List<Wire.Node> alternateRecords = Bundle.parse(alternateRoot).semanticEvidence().child(1).children();
        if (originalRecords.size() != 1 || alternateRecords.size() != 1
                || Wire.contentId(originalRecords.get(0)).equals(Wire.contentId(alternateRecords.get(0))))
            throw new AssertionError("Export must preserve distinct source records");
        verify(replaceFlat(root, List.of()), policy, Outcome.REJECTED, FailureCode.MISSING_EVIDENCE, "omission");
        verify(replaceFlat(root, alternateRecords), policy, Outcome.REJECTED, FailureCode.MISSING_EVIDENCE,
                "detached-source");
        Files.write(Path.of(args[1]), checks, StandardOpenOption.CREATE_NEW);
    }
}
