package org.acgn.cert;

/** Required evidence is absent or an explicit exhaustive limit was reached. */
final class UncheckableException extends RuntimeException {
    private static final long serialVersionUID = 1L;

    private final FailureCode code;

    UncheckableException(FailureCode code, String message) {
        super(message);
        this.code = code;
    }

    FailureCode code() {
        return code;
    }
}
