package org.acgn.cert;

import is.fivefivefive.CanDis.theory.BinderOccurrenceAutomorphismCertificate;
import is.fivefivefive.CanDis.theory.P609BinderFixture;
import is.fivefivefive.CanDis.theory.PortValue;
import is.fivefivefive.CanDis.theory.StructuralKey;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

/** Check rooted identity in producer bytes, derived orbit addresses, and exact-empty fixture gates. */
public final class P609RootedBinderTest {
    private static final String THEORY = "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";
    private final List<String> rows = new ArrayList<>(List.of("case\tobservation\tvalue"));

    private static void require(boolean ok, String detail) {
        if (!ok) throw new AssertionError(detail);
    }

    /** Independent Java UTF-16 framing observation, with no call to either production parser. */
    private record Frame(String tag, List<String> scalars, List<String> children) {
        static Frame parse(String text) {
            var in = new Cursor(text);
            String tag = in.field();
            in.delimiter('[');
            List<String> scalars = in.fields();
            in.delimiter(']'); in.delimiter('{');
            List<String> children = in.fields();
            in.delimiter('}');
            require(in.position == text.length() && !tag.isEmpty(), "incomplete structural frame");
            return new Frame(tag, scalars, children);
        }
    }

    private static final class Cursor {
        final String text;
        int position;
        Cursor(String text) { this.text = text; }
        void delimiter(char ch) {
            require(position < text.length() && text.charAt(position++) == ch, "delimiter " + ch);
        }
        int count() {
            int end = text.indexOf(':', position);
            require(end > position, "empty length");
            String digits = text.substring(position, end);
            require(digits.matches("0|[1-9][0-9]*"), "noncanonical decimal");
            position = end + 1;
            return Integer.parseInt(digits);
        }
        String field() {
            int size = count(), start = position;
            position = Math.addExact(start, size);
            return text.substring(start, position);
        }
        List<String> fields() {
            int n = count();
            List<String> values = new ArrayList<>();
            for (int i = 0; i < n; i++) values.add(field());
            return List.copyOf(values);
        }
    }

    private void observe(String name, String what, Object value) { rows.add(name + "\t" + what + "\t" + value); }

    private record Address(String root, String path, String term, List<Integer> permutation) {}

    private static Address address(KernelModel model, KernelModel.Term root, KernelModel.Term block,
            String path, KernelModel.Embedding automorphism) {
        var descriptor = model.binder(model.schema(block.sort().value()).value());
        List<String> slots = descriptor.coordinates().stream().map(KernelModel.BinderCoordinate::slotName).toList();
        return new Address(root.id(), path, block.id(),
                slots.stream().map(s -> slots.indexOf(automorphism.apply(s))).toList());
    }

    private static void census(KernelModel model, KernelModel.Term root, KernelModel.Term term,
            String path, Set<Address> expected) {
        if (term.kind() == KernelModel.TermKind.BIND_BLOCK) {
            var descriptor = model.binder(model.schema(term.sort().value()).value());
            for (var g : descriptor.generators())
                expected.add(new Address(root.id(), path, term.id(), g));
        }
        for (int i = 0; i < term.children().size(); i++)
            census(model, root, model.term(term.children().get(i)), path.isEmpty() ? "" + i : path + "/" + i, expected);
    }

    private static Wire.Node check(String name, byte[] bytes, String sourceHash, int count,
            List<BinderOccurrenceAutomorphismCertificate> live, Outcome status, FailureCode code) {
        var b = Bundle.parse(Codec.decode(bytes, Limits.defaults()));
        require(b.metadata().inputSha256().equals(sourceHash), name + " typed-source hash");
        String subject = CallOccurrenceCommitment.subjectDigest(b.metadata());
        var pin = new CallOccurrenceCommitment(subject, CallOccurrenceCommitment.digest(subject, List.of()));
        var result = new IndependentVerifier().verify(bytes, Profile.FULL,
                VerificationPolicy.trust(THEORY).withCallOccurrenceCommitment(pin));
        require(result.outcome() == status && result.code() == code, name + " " + result);
        if (status != Outcome.VERIFIED) require(result.detail().startsWith("No exact laws for "), result.detail());
        var model = new KernelModel(b, Limits.defaults());
        var records = b.semanticEvidence().child(3).children();
        require(records.size() == count, name + " binder record count");
        Set<Address> present = new HashSet<>(), expected = new HashSet<>();
        Set<String> keys = new HashSet<>(), references = new HashSet<>(), roots = new HashSet<>();
        Set<String> paths = new HashSet<>();
        Wire.Node example = null;
        for (var proof : b.proofs().values()) {
            if (!proof.scalar(1).equals("CANONICAL_ORBIT")) continue;
            var orbit = proof.child(1);
            var base = model.term(orbit.scalar(1));
            census(model, base, base, "", expected);
            for (var ref : orbit.child(3).children()) references.add(ref.scalar(0));
            if (!orbit.child(3).children().isEmpty()) example = proof;
        }
        for (var row : records) {
            row.requireShape("binder-occurrence", 9, 0);
            var root = model.term(row.scalar(8));
            var term = root;
            for (var coordinate : row.scalar(3).split("/"))
                term = model.term(term.children().get(Integer.parseInt(coordinate)));
            require(root.kind() == KernelModel.TermKind.APP && term.kind() == KernelModel.TermKind.BIND_BLOCK
                    && term.id().equals(row.scalar(1)), "root path does not locate block");
            var addr = address(model, root, term, row.scalar(3), model.embedding(row.scalar(4)));
            require(present.add(addr) && keys.add(row.scalar(0)), "duplicate binder key or address");
            paths.add(addr.path()); roots.add(addr.root());
            var key = Frame.parse(row.scalar(0));
            List<String> f = key.children();
            require(key.tag().equals("typed-equality-certificate")
                    && key.scalars().equals(List.of("BINDER_AUTOMORPHISM")) && f.size() == 13,
                    "complete typed certificate");
            require(f.get(0).equals(row.scalar(6)) && f.get(1).equals(row.scalar(7)), "endpoint projections");
            var path = Frame.parse(f.get(9));
            require(path.tag().equals("binder-occurrence-source-path-v1") && path.children().isEmpty()
                    && path.scalars().equals(List.of(row.scalar(3).split("/"))), "complete path preimage");
            var source = Frame.parse(f.get(10));
            var target = Frame.parse(f.get(11));
            require(Frame.parse(f.get(3)).tag().equals("e-node") && source.tag().equals("port/bind-block")
                    && target.tag().equals("port/bind-block") && source.children().size() == 4
                    && source.children().subList(0, 3).equals(target.children().subList(0, 3))
                    && f.get(4).equals(Frame.parse(source.children().get(0)).children().get(0))
                    && f.get(5).equals(source.children().get(1)) && f.get(6).equals(source.children().get(2))
                    && Frame.parse(f.get(12)).tag().equals("certificate-premise"), "binder descriptor/map/context");
            if (live != null) {
                var matches = live.stream().filter(c -> c.structuralKey().stableString().equals(row.scalar(0))).toList();
                require(matches.size() == 1, "exact producer key and exported record");
                var c = matches.get(0);
                require(f.get(3).equals(c.enclosingRoot().structuralKey().stableString())
                        && f.get(4).equals(c.source().schema().descriptor().structuralKey().stableString())
                        && f.get(10).equals(c.source().structuralKey().stableString())
                        && f.get(11).equals(c.target().structuralKey().stableString()),
                        "live producer fields and code-unit frame");
            }
        }
        require(keys.equals(references) && present.equals(expected) && example != null, "independent occurrence census");
        if (name.equals("dual")) require(roots.size() == 2 && paths.size() == 1, "two owners, one path");
        if (name.equals("nested")) require(roots.size() == 1 && paths.size() == 2, "one owner, two paths");
        if (name.equals("BIND")) require(records.get(0).scalar(0).contains("\uD83E\uDDED:[{}]")
                && paths.equals(Set.of("0/0")), "supplementary-plane root and ordinary BIND");
        return example;
    }

    private void emptyGuards(Bundle bundle, Wire.Node proof) {
        var model = new KernelModel(bundle, Limits.defaults());
        // Isolate one authentic orbit and its decoded model. Neither check emits a bundle.
        refusal("empty-reference", () -> SemanticEvidenceVerifier.requireNoEmptyFixtureBinderClaims(List.of(proof), model),
                "Empty test fixture cannot supply a referenced binder occurrence");
        var orbit = proof.child(1);
        var pieces = new ArrayList<>(orbit.children());
        pieces.set(3, Wire.node("binder-occurrence-refs", List.of()));
        var node = Wire.node(orbit.tag(), orbit.scalars(), pieces);
        var refs = Wire.node(proof.tag(), proof.scalars(), List.of(proof.child(0), node));
        refusal("empty-needs-binder", () -> SemanticEvidenceVerifier.requireNoEmptyFixtureBinderClaims(List.of(refs), model),
                "Empty test fixture lacks a binder occurrence required by an orbit base");
    }

    private void refusal(String label, Runnable operation, String detail) {
        try {
            operation.run(); throw new AssertionError(label + " accepted");
        } catch (FormatException e) {
            require(e.code() == FailureCode.MISSING_EVIDENCE && e.getMessage().equals(detail), label + " " + e);
            observe(label, "decoded-only-rejection", e.code());
        }
    }

    private void run(Path root, Path dual, Path nested, Path output) throws Exception {
        P609SourceContract.check(root);
        observe("java", "source-layouts", "matched");
        require(Arrays.stream(PortValue.class.getPermittedSubclasses()).map(Class::getSimpleName)
                .collect(java.util.stream.Collectors.toCollection(TreeSet::new))
                .equals(Set.of("OnePort", "SeqPort", "BagPort", "SetPort", "BindPort", "BindBlockPort")), "port census");
        require(Arrays.stream(KernelModel.TermKind.values()).map(Enum::name).collect(java.util.stream.Collectors.toSet())
                .equals(Set.of("SLOT","BOUND","APP","INVOKE","ONE_SLOT","ONE_TERM","SEQ","BAG","SET","BIND","BIND_BLOCK","META")),
                "decoded term census");
        observe("grammar", "producer-ports/decoded-term-kinds", "6/12");
        String sample = "\uD83E\uDDED:[{}]";
        String expected = "1:t[1:7:" + sample + "]{0:}";
        require(StructuralKey.leaf("t", sample).stableString().equals(expected)
                && Frame.parse(expected).scalars().equals(List.of(sample)), "UTF-16 field length");
        observe("utf16", "supplementary/delimiters", 7);
        byte[] dualBytes = Files.readAllBytes(dual);
        var example = check("dual", dualBytes, "cffafb5aa3cce466c1e187331e145b00d5bd904956ac67e4598443504b643729",
                2, null, Outcome.VERIFIED, FailureCode.NONE);
        observe("dual", "FULL/roots/paths", "VERIFIED/2/1");
        check("nested", Files.readAllBytes(nested), "488a5cfae4b2842db930dfea19c3202d88c4bd3fb1911b81a0a6bc4296a4eb5d",
                2, null, Outcome.VERIFIED, FailureCode.NONE);
        observe("nested", "FULL/roots/paths", "VERIFIED/1/2");
        emptyGuards(Bundle.parse(Codec.decode(dualBytes, Limits.defaults())), example);
        var bare = VerifierTest.fullFixture();
        var publicVerifier = new IndependentVerifier();
        for (var profile : List.of(Profile.KERNEL, Profile.FULL)) {
            var result = publicVerifier.verify(bare.bytes(), profile, VerificationPolicy.trust(bare.theoryDigest()));
            require(result.outcome() == Outcome.VERIFIED, "bare " + profile + " " + result);
            observe("empty-fixture", profile.name(), result.outcome());
        }
        Path temporary = Files.createTempDirectory("p609-typed-");
        try {
            for (String kind : List.of("BIND", "SEQ", "BAG", "SET")) {
                Path cert = temporary.resolve(kind + ".acgncert");
                if (kind.equals("BAG") || kind.equals("SET")) {
                    try {
                        P609BinderFixture.export(kind, List.of(1, 2, 3), cert);
                        throw new AssertionError(kind + " bypassed the source law registry");
                    } catch (IllegalStateException e) {
                        require(e.getMessage().equals("Container declaration certificate mismatch for COMMUTATIVITY")
                                && !Files.exists(cert), kind + " " + e);
                        observe(kind, "ordinary-source-construction", "REFUSED_NO_COMMUTATIVITY");
                    }
                } else {
                    var session = P609BinderFixture.export(kind, List.of(1, 2, 3), cert);
                    boolean bind = kind.equals("BIND");
                    check(kind, Files.readAllBytes(cert), bind
                            ? "4edeb7b2f047a7cb91371746f75381c49c5af44212ce875a99233180a3e534b1"
                            : "6a455b427f613bb012463b7543d6a26283119c466bfd9ee37157cf6149d84aeb", bind ? 1 : 3,
                            List.copyOf(session.artifact().binderOccurrenceCertificates()),
                            bind ? Outcome.VERIFIED : Outcome.REJECTED, bind ? FailureCode.NONE : FailureCode.MISSING_EVIDENCE);
                    observe(kind, "exported-occurrences/FULL", bind ? "1/VERIFIED" : "3/REJECTED_NO_EXACT_LAWS");
                }
            }
        } finally {
            try (var files = Files.list(temporary)) {
                for (var file : files.toList()) Files.delete(file);
            }
            Files.delete(temporary);
        }
        Files.write(output, rows, StandardCharsets.UTF_8);
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 4) throw new IllegalArgumentException("usage: SOURCE DUAL_BUNDLE NESTED_BUNDLE OUTPUT.tsv");
        var test = new P609RootedBinderTest();
        test.run(Path.of(args[0]), Path.of(args[1]), Path.of(args[2]), Path.of(args[3]));
        System.out.println("P609RootedBinderTest passed: observations=" + (test.rows.size() - 1));
    }
}
