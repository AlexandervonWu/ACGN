package org.acgn.cert;

import java.util.Objects;

/** One fail-closed verification result. */
public record VerificationResult(Outcome outcome, FailureCode code, String detail) {
    public VerificationResult {
        Objects.requireNonNull(outcome, "outcome");
        Objects.requireNonNull(code, "code");
        Objects.requireNonNull(detail, "detail");
        if ((outcome == Outcome.VERIFIED) != (code == FailureCode.NONE)) {
            throw new IllegalArgumentException(
                    "Only VERIFIED may use NONE, and VERIFIED must use NONE");
        }
    }

    public static VerificationResult verified(String detail) {
        return new VerificationResult(Outcome.VERIFIED, FailureCode.NONE, detail);
    }

    public static VerificationResult rejected(FailureCode code, String detail) {
        return new VerificationResult(Outcome.REJECTED, code, detail);
    }

    public static VerificationResult uncheckable(FailureCode code, String detail) {
        return new VerificationResult(Outcome.UNCHECKABLE, code, detail);
    }
}
