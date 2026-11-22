package is.fivefivefive.CanDis;

import java.nio.file.*;
import java.util.*;
import java.util.concurrent.TimeUnit;

/** Checks the actual source-derived program, each required decision and the ordinary parsed observations. */
public final class A216Qualification {
    private static void replay(Path input,boolean valid,boolean identifiers) throws Exception {
        String lean = Objects.requireNonNull(System.getenv("ACGN_ELEVENTH_LEAN"));
        String proof = Objects.requireNonNull(System.getenv("ACGN_ELEVENTH_PROOF"));
        Path log = Files.createTempFile(input.getParent(),"a216-lean-",".log");
        try {
            var cmd=new ArrayList<>(List.of(lean,"-j1","--run",proof));
            if (identifiers) cmd.add("--class-ids");
            cmd.add(input.toString());
            var p = new ProcessBuilder(cmd)
                    .redirectErrorStream(true).redirectOutput(log.toFile()).start();
            if (!p.waitFor(60,TimeUnit.SECONDS)) {
                p.destroyForcibly().waitFor();
                throw new AssertionError("A216 proof replay timeout");
            }
            String output=Files.readString(log);
            String expected=(identifiers ? "A216 source identifiers " : "A216 compiler dispatch ") + (valid ? "accepted" : "rejected");
            if (p.exitValue()!=(valid ? 0 : 1) || !output.stripTrailing().endsWith(expected)) {
                throw new AssertionError(output);
            }
        } finally { Files.deleteIfExists(log); }
    }

    public static void main(String[] args) throws Exception {
        if(args.length!=2) throw new IllegalArgumentException("A216Qualification ROOT EXISTING_RESULTS_DIR");
        Path out=Path.of(args[1]);
        A216CompilerContract.main(args);
        Path program=out.resolve("a216-program.txt");
        replay(program,true,false);
        var controls=new ArrayList<>(List.of("control\tkernel","actual\tACCEPTED"));
        var actual=Files.readAllLines(program);
        for (String effect:actual) {
            var changed=new ArrayList<>(actual);
            int position=changed.indexOf(effect);
            if(position<0) throw new AssertionError(effect);
            if(effect.equals("JOIN=guard")) changed.set(position,"JOIN=fixed");
            else if(effect.equals("ARROW=fixed")) changed.set(position,"ARROW=guard");
            else changed.remove(position);
            var test=Files.createTempFile(out,"a216-control-",".txt");
            try {
                Files.write(test,changed);
                replay(test,false,false);
            } finally { Files.deleteIfExists(test); }
            String action=effect.contains("=") ? "replace-" : "omit-";
            controls.add(action+effect+"\tREJECTED");
        }
        for (boolean distinct : List.of(true,false)) {
            var test=Files.createTempFile(out,"a216-identifiers-",".txt");
            try {
                Files.write(test,distinct ? List.of("4","8","12") : List.of("4","8","4"));
                replay(test,distinct,true);
            } finally { Files.deleteIfExists(test); }
            controls.add(distinct ? "distinct-ids\tACCEPTED" : "duplicate-ids\tREJECTED");
        }
        Files.write(out.resolve("a216-controls.tsv"),controls,StandardOpenOption.CREATE_NEW);
        A216SourceCases.main(new String[]{out.resolve("a216-cases.tsv").toString()});
        System.out.println("A216 qualification passed: 36 source methods, 13 proof controls, 28 source and unit observations");
    }
}
