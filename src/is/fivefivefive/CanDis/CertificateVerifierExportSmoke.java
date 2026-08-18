package is.fivefivefive.CanDis;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import is.fivefivefive.CanDis.adapter.TheoryAlloyAdapter;
import is.fivefivefive.CanDis.theory.CertificateExportSession;
import is.fivefivefive.CanDis.theory.RecordingCertificateTraceSink;

/** Generates small exact producer bundles for independent-verifier smoke tests. */
public final class CertificateVerifierExportSmoke {
    private CertificateVerifierExportSmoke() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 1 || args.length > 2) {
            throw new IllegalArgumentException(
                    "usage: CertificateVerifierExportSmoke <output-dir> [count]");
        }
        Path output = Path.of(args[0]);
        int count = args.length == 2 ? Integer.parseInt(args[1]) : 100;
        if (count <= 0) {
            throw new IllegalArgumentException("count must be positive");
        }
        Files.createDirectories(output);
        String commit = System.getProperty(
                "acgn.producer.commit",
                "d2239b53783d874c6ce45f75f9c452b45acd214e");
        boolean dirty = Boolean.parseBoolean(
                System.getProperty("acgn.producer.dirty", "true"));
        for (int index = 0; index < count; index++) {
            RecordingCertificateTraceSink sink = new RecordingCertificateTraceSink();
            CertificateExportSession session = TheoryAlloyAdapter.adaptForVerification(
                    List.of(), sink, commit, dirty).certificateExportSession();
            session.write(output.resolve(String.format(
                    "preparation-%03d.acgncert", index)));
        }
        System.out.println("exported " + count + " exact preparations to " + output);
    }
}
