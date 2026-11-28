package is.fivefivefive.CanDis;

import java.io.OutputStream;
import java.io.PrintStream;

/** Rebuild and compare the same original endpoints twice inside one fresh JVM. */
public final class WarmNativePrograms {
    public static void main(String[] args) throws Exception {
        PrintStream output = System.out;
        try (PrintStream discard = new PrintStream(OutputStream.nullOutputStream())) {
            System.setOut(discard);
            EmitNativePrograms.main(args);
            System.setOut(output);
            EmitNativePrograms.main(args);
        } finally {
            System.setOut(output);
        }
    }
}
