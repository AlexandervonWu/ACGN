package org.acgn.cert;

import is.fivefivefive.CanDis.RawArrowOccurrenceAuthority;
import is.fivefivefive.CanDis.theory.CertificateProvenance;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.json.JSONArray;

/** Compares actual v10 wire records with the executable Lean field decoder. */
public final class A225WireCommitmentTest {
    private static final String THEORY = "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";

    private static void require(boolean ok, String message) {
        if (!ok) throw new AssertionError(message);
    }

    private static JSONArray encode(Wire.Node n) {
        var children = new JSONArray();
        for (var child : n.children()) children.put(encode(child));
        return new JSONArray().put(n.tag()).put(new JSONArray(n.scalars())).put(children);
    }

    private static Wire.Node outputDag(Wire.Node operand) {
        return switch (operand.tag()) {
            case "dependent-chain-leaf" -> operand.child(0);
            case "dependent-chain-application" -> operand.child(2);
            default -> throw new AssertionError(operand.tag());
        };
    }

    private static final class Census {
        int dags, matrices, pairs, disjoint, typedEmpty, arrow;
    }

    private static void walk(Wire.Node node, Census c, BufferedWriter wire) throws IOException {
        if (node.tag().equals("dependent-type-dag")) {
            c.dags++;
            if (node.children().isEmpty()) c.typedEmpty++;
            wire.write(encode(node).toString()); wire.newLine();
        } else if (node.tag().equals("dependent-chain-application")) {
            var left = outputDag(node.child(0)).children();
            var right = outputDag(node.child(1)).children();
            var matrix = node.child(3);
            int size = Math.multiplyExact(left.size(), right.size());
            matrix.requireShape("dependent-chain-combination-cases", 1, size);
            require(matrix.scalar(0).equals(Integer.toString(size)), "matrix size");
            for (int i = 0; i < left.size(); i++) {
                for (int j = 0; j < right.size(); j++) {
                    var pair = matrix.child(i * right.size() + j);
                    pair.requireShape("dependent-chain-combination-case", 4, 2);
                    require(pair.scalar(0).equals(Integer.toString(i))
                            && pair.scalar(1).equals(Integer.toString(j)), "row-major pair");
                    switch (pair.scalar(2)) {
                        case "ARROW_PRODUCT" -> {
                            pair.child(0).requireShape("dependent-chain-no-boundary", 1, 0);
                            require(pair.child(0).scalar(0).equals("ARROW")
                                    && pair.child(1).tag().equals("dependent-type-product"), "ARROW sentinel");
                            c.arrow++;
                        }
                        case "JOIN_DISJOINT" -> {
                            pair.child(0).requireShape("dependent-chain-boundary", 6, 2);
                            require(pair.child(0).scalar(3).equals("NONE"), "disjoint meet");
                            pair.child(1).requireShape("dependent-chain-no-result", 1, 0);
                            require(pair.child(1).scalar(0).equals("DISJOINT"), "disjoint sentinel");
                            c.disjoint++;
                        }
                        case "JOIN_OVERLAP" -> require(pair.child(0).tag().equals("dependent-chain-boundary")
                                && pair.child(1).tag().equals("dependent-type-product"), "overlap result");
                        default -> throw new AssertionError("unexpected decision " + pair.scalar(2));
                    }
                    c.pairs++;
                }
            }
            c.matrices++;
            wire.write(encode(matrix).toString()); wire.newLine();
        }
        for (var child : node.children()) walk(child, c, wire);
    }

    private static String fixture(String name, Path file, BufferedWriter wire, RawArrowSourcePin.Authority arrowSource) throws Exception {
        var bytes = Files.readAllBytes(file);
        var root = Codec.decode(bytes, Limits.defaults());
        require(Arrays.equals(bytes, Codec.encode(root)), "binary codec round trip");
        var bundle = Bundle.parse(root);
        require(root.scalar(0).equals("acgncert-schema-v10") && bundle.theoryDigest().equals(THEORY), "schema and known fixture theory");
        var subject = CallOccurrenceCommitment.subjectDigest(bundle.metadata());
        var emptyCalls = new CallOccurrenceCommitment(subject, CallOccurrenceCommitment.digest(subject, List.of()));
        var policy = VerificationPolicy.trust(THEORY).withCallOccurrenceCommitment(emptyCalls);
        if (arrowSource != null) {
            var pin = arrowSource.pin();
            require(arrowSource.calls().equals(emptyCalls), "independent CALL subject");
            policy = new VerificationPolicy(Set.of(THEORY), Limits.defaults(), policy.trustedCallOccurrenceDigests(),
                    Map.of(pin.subject(), pin.digest()));
        }
        var result = new IndependentVerifier().verify(bytes, Profile.FULL, policy);
        var c = new Census();
        walk(bundle.semanticEvidence(), c, wire);
        require(c.dags > 0 && c.matrices > 0, "fixture contains no DAG or matrix");
        if (arrowSource != null) {
            require(c.arrow == c.pairs && c.arrow > 0 && result.outcome() == Outcome.VERIFIED, result.toString());
        } else if (name.equals("relation-empty-interior")) {
            require(result.outcome() == Outcome.VERIFIED && result.code() == FailureCode.NONE, result.toString());
            require(c.typedEmpty > 0, "missing typed-empty DAG");
        } else {
            require(result.outcome() == Outcome.UNCHECKABLE && result.code() == FailureCode.MISSING_EVIDENCE,
                    result.toString());
        }
        if (name.equals("relation-family")) require(c.disjoint > 0 && c.pairs > c.disjoint, "need mixed correlated result");
        return String.join("\t", name, result.outcome().name(), result.code().name(), String.valueOf(c.dags),
                String.valueOf(c.matrices), String.valueOf(c.pairs), String.valueOf(c.disjoint),
                String.valueOf(c.typedEmpty), String.valueOf(c.arrow));
    }

    private static String ordinaryArrow(Path directory, BufferedWriter wire) throws Exception {
        byte[] source = """
                module origin
                abstract sig Parent {}
                sig A,B,C extends Parent {}
                pred left { some ((A -> B) -> C) }
                """.getBytes(StandardCharsets.UTF_8);
        var authority = RawArrowSourcePin.read(source, "origin/left");
        var produced = RawArrowOccurrenceAuthority.produce(source, "origin/left");
        var certified = produced.forVerification(CertificateProvenance.capture("origin/left", source, "a225-arrow-wire"));
        authority.raw().verifyRetained(produced.prepared(), certified);
        Path file = Files.createTempFile(directory, "a225-arrow-", ".acgncert");
        try {
            certified.certificateExportSession().write(file);
            return fixture("source-arrow", file, wire, authority);
        } finally {
            Files.deleteIfExists(file);
        }
    }

    private static List<String> schemaControls() {
        var observed = new ArrayList<String>();
        var unusedSections = java.util.Collections.nCopies(12, Wire.leaf("unused"));
        for (int version = 0; version <= 9; version++) {
            String token = "acgncert-schema-v" + version;
            // This is an isolated, decoded header. The body is never interpreted.
            var header = Wire.node("acgncert-bundle", List.of(token), unusedSections);
            try {
                Bundle.parse(header);
                throw new AssertionError("accepted outdated header " + token);
            } catch (FormatException e) {
                require(e.code() == FailureCode.UNSUPPORTED_FORMAT_VERSION, token + " " + e.code());
                observed.add(token + "\t" + e.code().name());
            }
        }
        return observed;
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 6) throw new IllegalArgumentException(
                "SOURCE METHOD_INVENTORY COVERAGE LEAN LEAN_WITNESS OUTPUT_TSV");
        int methods = A225SourceContract.check(Path.of(args[0]), Path.of(args[1]));
        int decimals = A225UnsignedDecimalTest.run();
        System.out.println("A225SourceContract passed: " + methods + " method and field observations");
        System.out.println("A225UnsignedDecimalTest passed: " + decimals + " scalar checks");
        Path coverage = Path.of(args[2]), output = Path.of(args[5]).toAbsolutePath();
        var rows = new ArrayList<>(List.of("fixture\toutcome\tcode\tdags\tmatrices\tpairs\tdisjoint\temptyDags\tarrow"));
        var controls = new ArrayList<>(List.of("control\tresult",
                "compiler-resolved-methods-and-fields\t" + methods, "unsigned-decimal-controls\t" + decimals));
        controls.addAll(schemaControls());
        Path input = Files.createTempFile(output.getParent(), "a225-wire-", ".jsonl");
        try {
            try (var writer = Files.newBufferedWriter(input, StandardCharsets.UTF_8)) {
                for (String name : List.of("relation-columns", "relation-family", "relation-empty", "relation-empty-interior"))
                    rows.add(fixture(name, coverage.resolve(name + "-a.acgncert"), writer, null));
                rows.add(ordinaryArrow(output.getParent(), writer));
            }
            var p = new ProcessBuilder(args[3], "--run", args[4], input.toString()).inheritIO().start();
            require(p.waitFor() == 0, "Lean field round trip failed");
            Files.write(output, rows, StandardCharsets.UTF_8);
            Files.write(output.resolveSibling("controls.tsv"), controls, StandardCharsets.UTF_8);
        } finally {
            Files.deleteIfExists(input);
        }
        System.out.println("A225 schema headers: v0 through v9 rejected");
        System.out.println("A225WireCommitmentTest passed: " + (rows.size() - 1) + " producer fixtures");
    }
}
