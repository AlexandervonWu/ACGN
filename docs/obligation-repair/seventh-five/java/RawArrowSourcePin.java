package org.acgn.cert;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.Sig;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.CanDis.RawArrowOccurrenceAuthority;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

/** Caller-side authority. Its only inputs are source bytes and a selected qualified predicate. */
public final class RawArrowSourcePin {
    private static final int MAX_SOURCE_BYTES = 65536;
    public record Authority(RawArrowOccurrenceAuthority raw, List<ArrowSourceCommitment.Leaf> leaves,
            Map<String,List<String>> ancestry) {
        public ArrowSourceCommitment pin() {
            return ArrowSourceCommitment.from(raw.root(), raw.sourceHash(), leaves, ancestry);
        }
        public CallOccurrenceCommitment calls() {
            // The complete admitted predicate consists of SOME, ARROWs and primitive signature leaves.
            String subject = CallOccurrenceCommitment.subjectDigest(raw.root(), raw.sourceHash());
            return new CallOccurrenceCommitment(subject, CallOccurrenceCommitment.digest(subject, List.of()));
        }
    }

    public static Authority read(byte[] bytes, String selected) throws Exception {
        if (bytes.length > MAX_SOURCE_BYTES) throw new IllegalArgumentException("source exceeds bounded fragment");
        bytes = bytes.clone();
        var raw = RawArrowOccurrenceAuthority.parse(bytes, selected);
        if (raw.occurrences().size() != 1) throw new IllegalArgumentException("one SOME ARROW root required");
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP,
                StandardCharsets.UTF_8.newDecoder().decode(ByteBuffer.wrap(bytes)).toString());
        var leaves = new ArrayList<ArrowSourceCommitment.Leaf>();
        var chains = new HashMap<String,List<String>>();
        for (var leaf : raw.occurrences().get(0).leaves()) {
            if (!leaf.kind().equals("signature") || !leaf.columns().equals(List.of(leaf.name()))) {
                throw new IllegalArgumentException("primitive signature leaf required");
            }
            var matches = module.getAllSigs().makeCopy().stream()
                    .filter(s -> s.label.equals("this/" + leaf.name())).toList();
            if (matches.size() != 1 || !(matches.get(0) instanceof Sig.PrimSig s)) {
                throw new IllegalArgumentException("unique resolved signature required");
            }
            var chain = new ArrayList<String>();
            var seen = new HashSet<Sig.PrimSig>();
            for (Sig.PrimSig n = s; n != Sig.UNIV; n = n.parent) {
                if (n == null || !seen.add(n) || n.isVariable != null
                        || !module.getAllSigs().makeCopy().contains(n)
                        || !n.label.matches("this/[A-Za-z_][A-Za-z0-9_]*")) {
                    throw new IllegalArgumentException("unsupported primitive signature ancestry");
                }
                chain.add(n.label.substring("this/".length()));
            }
            chain.add("univ");
            chains.put(leaf.name(), List.copyOf(chain));
            leaves.add(new ArrowSourceCommitment.Leaf(leaf.path(), leaf.name()));
        }
        return new Authority(raw, List.copyOf(leaves), Map.copyOf(chains));
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("usage: RawArrowSourcePin SOURCE MODULE/PREDICATE");
        byte[] bytes;
        try (var input = Files.newInputStream(Path.of(args[0]))) {
            bytes = input.readNBytes(MAX_SOURCE_BYTES);
            if (input.read() != -1) throw new IllegalArgumentException("source exceeds bounded fragment");
        }
        Authority authority = read(bytes, args[1]);
        System.out.println("--arrow-source-commitment " + authority.pin().assignment());
        System.out.println("--call-occurrence-commitment " + authority.calls().assignment());
    }
}
