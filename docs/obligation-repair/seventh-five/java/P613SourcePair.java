package org.acgn.cert;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.function.Supplier;
import org.json.JSONObject;

/** Source-bound front end for the public PAIR verifier and the sixth local-CALL source fragment. */
public final class P613SourcePair {
    private P613SourcePair() {}

    private static final int MAX_SOURCE_BYTES = 65536;

    private record BoundInput(byte[] bytes, CallOccurrenceCommitment pin) {}

    private static BoundInput bind(byte[] source, String selected, byte[] certificate) {
        if (source.length > MAX_SOURCE_BYTES || certificate.length > Limits.defaults().maxBundleBytes())
            throw new UncheckableException(FailureCode.RESOURCE_LIMIT, "input exceeds size limit");
        RawCallSourceAuthority authority;
        try {
            authority = RawCallSourceAuthority.fromSource(source.clone(), selected);
        } catch (Exception e) {
            throw new UncheckableException(FailureCode.MISSING_EVIDENCE,
                    "unable to establish local CALL source authority: " + e.getMessage());
        }
        // Bind and replay the same immutable snapshot, including for in-process callers.
        byte[] bytes = certificate.clone();
        return new BoundInput(bytes, authority.commitment(bytes));
    }

    private static VerificationPolicy policy(String theoryDigest) {
        if (theoryDigest == null || !theoryDigest.matches("[0-9a-f]{64}"))
            throw new IllegalArgumentException("expected explicit lowercase SHA-256 theory pin");
        return VerificationPolicy.trust(theoryDigest);
    }

    public static VerificationResult verifyFull(String theoryDigest, byte[] source, String selected,
            byte[] certificate) {
        VerificationPolicy policy = policy(theoryDigest);
        return checked(() -> {
            BoundInput input = bind(source, selected, certificate);
            return new IndependentVerifier().verify(input.bytes(), Profile.FULL,
                    policy.withCallOccurrenceCommitment(input.pin()));
        });
    }

    public static VerificationResult verify(String theoryDigest, byte[] leftSource, String leftRoot,
            byte[] leftCertificate, byte[] rightSource, String rightRoot, byte[] rightCertificate) {
        VerificationPolicy policy = policy(theoryDigest);
        return checked(() -> {
            BoundInput left = bind(leftSource, leftRoot, leftCertificate);
            BoundInput right = bind(rightSource, rightRoot, rightCertificate);
            if (left.pin().subjectDigest().equals(right.pin().subjectDigest())
                    && !left.pin().equals(right.pin())) {
                return VerificationResult.rejected(FailureCode.MISSING_EVIDENCE,
                        "conflicting CALL inventories for one source scope");
            }
            return new IndependentVerifier().verifyPair(left.bytes(), right.bytes(),
                    policy.withCallOccurrenceCommitment(left.pin()).withCallOccurrenceCommitment(right.pin()));
        });
    }

    private static VerificationResult checked(Supplier<VerificationResult> operation) {
        try {
            return operation.get();
        } catch (UncheckableException e) {
            return VerificationResult.uncheckable(e.code(), e.getMessage());
        } catch (TermOps.ResourceLimitException e) {
            return VerificationResult.uncheckable(FailureCode.RESOURCE_LIMIT, e.getMessage());
        } catch (FormatException e) {
            return e.code() == FailureCode.RESOURCE_LIMIT
                    ? VerificationResult.uncheckable(e.code(), e.getMessage())
                    : VerificationResult.rejected(e.code(), e.getMessage());
        } catch (IllegalArgumentException e) {
            return VerificationResult.rejected(FailureCode.ENDPOINT_CLAIM_MISMATCH,
                    "source-to-bundle binding failed: " + e.getMessage());
        } catch (RuntimeException e) {
            return VerificationResult.rejected(FailureCode.INTERNAL_ERROR, e.toString());
        }
    }

    private static byte[] boundedRead(String path, int limit) throws IOException {
        try (var input = Files.newInputStream(Path.of(path))) {
            byte[] bytes = input.readNBytes(limit + 1);
            if (bytes.length > limit) throw new UncheckableException(FailureCode.RESOURCE_LIMIT, "input exceeds size limit: " + path);
            return bytes;
        }
    }

    public static void main(String[] args) {
        if (args.length != 7) {
            System.err.println("usage: P613SourcePair THEORY_SHA256 LEFT_SOURCE LEFT_MODULE/PRED "
                    + "LEFT_CERT RIGHT_SOURCE RIGHT_MODULE/PRED RIGHT_CERT");
            System.exit(64);
        }
        VerificationResult result;
        try {
            int limit = Limits.defaults().maxBundleBytes();
            result = verify(args[0], boundedRead(args[1], MAX_SOURCE_BYTES), args[2], boundedRead(args[3], limit),
                    boundedRead(args[4], MAX_SOURCE_BYTES), args[5], boundedRead(args[6], limit));
        } catch (UncheckableException e) {
            result = VerificationResult.uncheckable(e.code(), e.getMessage());
        } catch (IOException e) {
            result = VerificationResult.uncheckable(FailureCode.IO_ERROR, e.getMessage());
        } catch (IllegalArgumentException e) {
            System.err.println(e.getMessage());
            System.exit(64);
            return;
        }
        System.out.println(new JSONObject().put("outcome", result.outcome().name())
                .put("code", result.code().name()).put("detail", result.detail()));
        System.exit(switch (result.outcome()) {
            case VERIFIED -> 0;
            case REJECTED -> 2;
            case UNCHECKABLE -> 3;
        });
    }
}
