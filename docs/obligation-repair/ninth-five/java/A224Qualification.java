package org.acgn.cert;

import is.fivefivefive.CanDis.theory.A224JoinCases;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.TimeUnit;

/** One entry point for the ninth driver's already compiled producer, verifier and Lean modules. */
public final class A224Qualification {
    private static void kernel(Path program, boolean accepted) throws Exception {
        String lean=Objects.requireNonNull(System.getenv("ACGN_NINTH_LEAN"));
        String proof=Objects.requireNonNull(System.getenv("ACGN_NINTH_PROOF"));
        Path log=Files.createTempFile("a224-kernel-", ".log");
        try {
            var p=new ProcessBuilder(lean,"--run",proof,program.toString()).redirectErrorStream(true)
                    .redirectOutput(log.toFile()).start();
            if(!p.waitFor(40,TimeUnit.SECONDS)){p.destroyForcibly().waitFor();throw new AssertionError("JOIN proof timeout");}
            String message=Files.readString(log).stripTrailing();
            String marker="A224 compiler program "+(accepted?"accepted":"rejected");
            if(p.exitValue()!=(accepted?0:1)||!message.endsWith(marker))throw new AssertionError(message);
        } finally {Files.delete(log);}
    }
    private static void abstractControl(List<String> program, String from, String to) throws Exception {
        var words=new ArrayList<>(program);
        int pos=words.indexOf(from);
        if(pos<0||Collections.frequency(words,from)!=1)throw new AssertionError(from);
        if(to==null)words.remove(pos);else words.set(pos,to);
        Path temp=Files.createTempFile("a224-abstract-", ".txt");
        try {Files.write(temp,words);kernel(temp,false);}finally{Files.delete(temp);}
    }
    public static void main(String[] args)throws Exception {
        if(args.length!=4)throw new IllegalArgumentException("A224Qualification ROOT COVERAGE VERIFIER_JAR EXISTING_OUTPUT_DIRECTORY");
        Path out=Path.of(args[3]);
        A224SourceContract.main(new String[]{args[0],out.toString()});
        Path instructions=out.resolve("join-program.txt");kernel(instructions,true);
        List<String> words=Files.readAllLines(instructions,StandardCharsets.UTF_8);
        abstractControl(words,"disjoint:record:skip",null);
        abstractControl(words,"overlap:init-left:tail-right","overlap:tail-right:init-left");
        Files.write(out.resolve("join-controls.tsv"),List.of("instruction-stream\tkernel-outcome",
                "source-attributed\tACCEPTED","missing-disjoint-record\tREJECTED","reversed-surviving-columns\tREJECTED"),StandardOpenOption.CREATE_NEW);
        A224JoinCases.main(new String[]{out.resolve("producer.tsv").toString()});
        A224PublicCases.main(new String[]{args[1],out.resolve("public.tsv").toString()});
        A224OrdinaryJoinCases.main(new String[]{args[2],out.resolve("source-joins.tsv").toString()});
        System.out.println("A224 JOIN qualification passed: 18 source methods, 3 program controls, 17 producer cases, 5 public FULL cases, 7 ordinary source JOIN cases");
    }
}
