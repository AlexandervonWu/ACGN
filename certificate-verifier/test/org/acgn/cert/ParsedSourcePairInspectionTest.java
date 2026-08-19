package org.acgn.cert;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.HexFormat;

/** Verifies that PAIR evidence came from two independently parsed source files. */
public final class ParsedSourcePairInspectionTest {
    private static int checks;

    private ParsedSourcePairInspectionTest() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 5) {
            throw new IllegalArgumentException(
                    "usage: ParsedSourcePairInspectionTest "
                            + "<left-bundle> <right-bundle> <left-source> "
                            + "<right-source> <trusted-theory-digest>");
        }
        byte[] leftBundleBytes = Files.readAllBytes(Path.of(args[0]));
        byte[] rightBundleBytes = Files.readAllBytes(Path.of(args[1]));
        Path leftSource = Path.of(args[2]);
        Path rightSource = Path.of(args[3]);
        String trustedDigest = args[4];

        String leftSourceHash = sha256(leftSource);
        String rightSourceHash = sha256(rightSource);
        check(!leftSourceHash.equals(rightSourceHash),
                "the parsed PAIR source files have distinct content hashes");
        check(!java.util.Arrays.equals(
                        Files.readAllBytes(leftSource), Files.readAllBytes(rightSource)),
                "the parsed PAIR source files have distinct bytes");

        Bundle left = decode(leftBundleBytes);
        Bundle right = decode(rightBundleBytes);
        check(left.metadata().inputIdentifier().equals(
                        "fixture/parsed-pair-left.als#left"),
                "left bundle binds the selected left source identity");
        check(right.metadata().inputIdentifier().equals(
                        "fixture/parsed-pair-right.als#right"),
                "right bundle binds the selected right source identity");
        check(!left.metadata().inputIdentifier().equals(
                        right.metadata().inputIdentifier()),
                "parsed PAIR bundles retain distinct source identities");
        check(left.metadata().inputSha256().equals(leftSourceHash),
                "left bundle binds the exact parsed source content hash");
        check(right.metadata().inputSha256().equals(rightSourceHash),
                "right bundle binds the exact parsed source content hash");
        check(!left.metadata().inputSha256().equals(right.metadata().inputSha256()),
                "parsed PAIR provenance is not fabricated by metadata-only renaming");
        check(left.theoryDigest().equals(trustedDigest)
                        && right.theoryDigest().equals(trustedDigest),
                "both parsed bundles match the externally selected theory pin");

        VerificationResult result = new IndependentVerifier().verifyPair(
                leftBundleBytes,
                rightBundleBytes,
                VerificationPolicy.trust(trustedDigest));
        check(result.outcome() == Outcome.VERIFIED
                        && result.code() == FailureCode.NONE,
                "the independently parsed source pair verifies under the static pin");

        System.out.println("ParsedSourcePairInspectionTest: " + checks
                + " checks passed; left=" + leftSourceHash
                + " right=" + rightSourceHash);
    }

    private static Bundle decode(byte[] bytes) {
        return Bundle.parse(Codec.decode(bytes, Limits.defaults()));
    }

    private static String sha256(Path path) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        try (InputStream input = Files.newInputStream(path)) {
            byte[] buffer = new byte[64 * 1024];
            int read;
            while ((read = input.read(buffer)) >= 0) {
                if (read > 0) {
                    digest.update(buffer, 0, read);
                }
            }
        }
        return HexFormat.of().formatHex(digest.digest());
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
