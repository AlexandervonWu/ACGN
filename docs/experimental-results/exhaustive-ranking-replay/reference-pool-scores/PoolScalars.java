package is.fivefivefive.CanDis;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.*;
import java.util.*;
import parser.ast.nodes.ModelUnit;

/** Both production scalar entry points on the exact released source and selected predicate. */
public final class PoolScalars {
    private record Reference(int id, String file, String predicate, String sha) {}
    private record Prepared(Canonical.Prepared fast, CanonicalAlloyPipeline.Prepared certified) {}
    private final Map<Integer, Reference> catalog = new HashMap<>();
    private final Map<Integer, Prepared> cache = new LinkedHashMap<>(64, .75f, true) {
        protected boolean removeEldestEntry(Map.Entry<Integer, Prepared> entry) { return size() > Integer.getInteger("acgn.pool.cache", 32); }
    };
    private final Path corpus;
    private PoolScalars(Path root, Path catalogs) throws Exception {
        corpus = root.toRealPath();
        try (var input = Files.newBufferedReader(catalogs)) {
            String header = input.readLine();
            if (!header.equals("referenceId\tquestionSet\tinvariantId\tname\tkind\tsource\tpredicate\tsourceSha256")) throw new IOException("Wrong catalog");
            for (String line; (line = input.readLine()) != null;) {
                String[] f = line.split("\t", -1);
                int id = Integer.parseInt(f[0]);
                if (catalog.put(id,new Reference(id, f[5], f[6], f[7])) != null) throw new IOException("Duplicate reference");
            }
        }
    }
    private Prepared prepared(int id) throws Exception {
        Prepared found = cache.get(id);
        if (found != null) return found;
        Reference ref = Objects.requireNonNull(catalog.get(id));
        Path source = corpus.resolve(ref.file).toRealPath();
        String sha = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(Files.readAllBytes(source)));
        if (!source.startsWith(corpus) || !source.getParent().endsWith("correct") || !ref.sha.equals(sha)) throw new IOException("Wrong source: " + ref);
        var module = CompUtil.parseEverything_fromFile(A4Reporter.NOP, new HashMap<>(), source.toString());
        var visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null,module), null);
        var tree = visitor.getForestId(ref.predicate);
        if (tree == null || visitor.getForest().get(tree) == null) throw new IOException("Missing selected predicate: " + ref);
        var fast = Canonical.prepare(visitor.getForest().get(tree));
        var output = new Prepared(fast, CanonicalAlloyPipeline.prepare(fast));
        cache.put(id, output);
        return output;
    }
    public static void main(String[] args) throws Exception {
        var ack = System.out;
        System.setOut(new PrintStream(OutputStream.nullOutputStream()));
        var engine = new PoolScalars(Path.of(args[0]), Path.of(args[1]));
        try (var control = new BufferedReader(new InputStreamReader(System.in, StandardCharsets.UTF_8))) {
            for (String command; (command = control.readLine()) != null;) {
                var fields = command.split("\t", -1);
                int rows = 0;
                try (var input = Files.newBufferedReader(Path.of(fields[0]));
                     var out = Files.newBufferedWriter(Path.of(fields[1]), StandardOpenOption.CREATE_NEW)) {
                    for (String line; (line = input.readLine()) != null;) {
                        var cells = line.split("\t", -1);
                        var a = engine.prepared(Integer.parseInt(cells[0]));
                        var b = engine.prepared(Integer.parseInt(cells[1]));
                        int f = Canonical.distance(a.fast, b.fast);
                        int c = CanonicalAlloyPipeline.distance(a.certified, b.certified);
                        out.write(line + "\t" + f + "\t" + c);
                        out.newLine();
                        rows++;
                    }
                }
                ack.println(rows);
                ack.flush();
            }
        }
    }
}
