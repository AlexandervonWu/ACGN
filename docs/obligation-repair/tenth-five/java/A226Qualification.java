package is.fivefivefive.CanDis;

import java.nio.file.*;
import java.util.*;
import java.util.concurrent.TimeUnit;

/** Normal qualification entry for the registered compiler, Lean and source-agreement observations. */
public final class A226Qualification {
    private static void replay(Path program, boolean valid) throws Exception {
        String lean = Objects.requireNonNull(System.getenv("ACGN_TENTH_LEAN"));
        String proof = Objects.requireNonNull(System.getenv("ACGN_TENTH_PROOF"));
        Path log = Files.createTempFile("a226-lean-", ".log");
        try {
            var p = new ProcessBuilder(lean, "--run", proof, program.toString()).redirectErrorStream(true).redirectOutput(log.toFile()).start();
            if (!p.waitFor(40, TimeUnit.SECONDS)) { p.destroyForcibly().waitFor(); throw new AssertionError("Lean timeout"); }
            String expected = valid ? "A226 complete source program accepted" : "A226 incomplete source program rejected";
            if(p.exitValue() != (valid ? 0 : 1) || !Files.readString(log).stripTrailing().endsWith(expected))
                throw new AssertionError(Files.readString(log));
        } finally { Files.delete(log); }
    }
    public static void main(String[] args) throws Exception {
        if(args.length != 2) throw new IllegalArgumentException("A226Qualification ROOT EXISTING_RESULTS_DIR");
        Path out = Path.of(args[1]);
        A226CompilerContract.main(args);
        Path program = out.resolve("a226-program.txt");
        replay(program,true);
        var controls = new ArrayList<>(List.of("effect\tkernel", "actual\tACCEPTED"));
        for (String omit : List.of("guard-active-class","primitive-domain-check","compare-complete-occurrence-evidence","return-derived","no-optional-authority")) {
            var effects = new ArrayList<>(Files.readAllLines(program));
            if (!effects.remove(omit)) throw new AssertionError(omit);
            var changed = Files.createTempFile("a226-effects-", ".txt");
            try { Files.write(changed,effects);replay(changed,false); } finally { Files.delete(changed); }
            controls.add("omit-"+omit+"\tREJECTED");
        }
        Files.write(out.resolve("a226-controls.tsv"),controls,StandardOpenOption.CREATE_NEW);
        A226SourceAgreementTest.main(new String[]{out.resolve("a226-source.tsv").toString()});
        System.out.println("A226 qualification passed: 15 source methods, 6 compiler-program controls, 21 ordinary and unit observations");
    }
}
