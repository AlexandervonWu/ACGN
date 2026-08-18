package org.acgn.cert;

/** Checked-format failure represented internally as an exception. */
public final class FormatException extends RuntimeException {
    private static final long serialVersionUID = 1L;

    private final FailureCode code;

    public FormatException(FailureCode code, String message) {
        super(message);
        this.code = code;
    }

    public FormatException(FailureCode code, String message, Throwable cause) {
        super(message, cause);
        this.code = code;
    }

    public FailureCode code() {
        return code;
    }
}
