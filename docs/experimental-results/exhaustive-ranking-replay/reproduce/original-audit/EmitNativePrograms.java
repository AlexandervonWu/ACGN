package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import java.io.OutputStream;
import java.io.PrintStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.HexFormat;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Emit both complete native repair programs for one independently hash-checked original selection. */
public final class EmitNativePrograms {
    private record Endpoint(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified) {}

    private static Endpoint prepare(Path corpus, String file, String predicate, String expectedHash) throws Exception {
        Path path = corpus.resolve(file).toRealPath();
        if (!path.startsWith(corpus)) throw new IllegalArgumentException("Source outside corpus");
        String actualHash = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(Files.readAllBytes(path)));
        if (!actualHash.equals(expectedHash)) throw new IllegalArgumentException("Source has changed");
        var module = path.getParent().endsWith("correct")
                ? CompUtil.parseEverything_fromFile(A4Reporter.NOP, new HashMap<>(), path.toString())
                : AlloyUtil.compileAlloyModule(path.toString());
        var visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null, module), null);
        var id = visitor.getForestId(predicate);
        if (id == null) throw new IllegalArgumentException("Unresolved original predicate " + predicate);
        var graph = visitor.getForest().get(id);
        if (graph == null) throw new IllegalArgumentException("Missing original predicate graph " + predicate);
        var fast = Canonical.prepare(graph);
        return new Endpoint(fast, CanonicalAlloyPipeline.prepare(fast));
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 7) throw new IllegalArgumentException("Expected corpus and two path/predicate/SHA-256 triples");
        Path corpus = Path.of(args[0]).toRealPath();
        PrintStream output = System.out;
        System.setOut(new PrintStream(OutputStream.nullOutputStream()));
        Endpoint left = prepare(corpus, args[1], args[2], args[3]);
        Endpoint right = prepare(corpus, args[4], args[5], args[6]);
        var result = NativeOperationComparison.compare(left.fast, right.fast, left.certified, right.certified);
        output.println(result.evidence().toString());
    }
}
