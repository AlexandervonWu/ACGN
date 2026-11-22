package org.acgn.cert;

/** Direct scalar checks independent of any certificate or verifier policy. */
public final class A225UnsignedDecimalTest {
    static int run() {
        for (long value : new long[] {0, 1, 10, Integer.MAX_VALUE, Long.MAX_VALUE}) {
            if (Bundle.parseUnsignedLong(Long.toString(value), "count") != value)
                throw new AssertionError(value);
        }
        for (String value : new String[] {"", "00", "01", "+1", "-0", "\u0661", "\uff11"}) {
            check(value, FailureCode.NONCANONICAL_ENCODING);
        }
        for (String value : new String[] {"-1", "x", " 1", "9223372036854775808"}) {
            check(value, FailureCode.INTEGER_OVERFLOW);
        }
        return 16;
    }

    private static void check(String text, FailureCode expected) {
        try {
            Bundle.parseUnsignedLong(text, "count");
        } catch (FormatException e) {
            if (e.code() == expected) return;
            throw new AssertionError("Wrong failure code for " + text, e);
        }
        throw new AssertionError("Accepted noncanonical or invalid count " + text);
    }

    public static void main(String[] args) {
        System.out.println("A225UnsignedDecimalTest passed: " + run() + " scalar checks");
    }
}
