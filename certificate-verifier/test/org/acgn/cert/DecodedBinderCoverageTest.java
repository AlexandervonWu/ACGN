package org.acgn.cert;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Diagnostic projection of ordinary, accepted public bundles. No producer objects. */
public final class DecodedBinderCoverageTest {
    private record Occurrence(String root, String source, List<Integer> path, List<Integer> generator) {}
    private record Coordinate(String type, String domain, String quantifier, String multiplicity,
            String disjointClass, String exchangeClass, List<String> dependencies) {}

    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    // Derive adjacent transpositions of equal payloads, independently of both the
    // automorphism IDs in evidence and the generator references in the binder table.
    private static void collect(KernelModel model, String root, KernelModel.Term term,
            List<Integer> path, Set<Occurrence> out) {
        if (term.kind() == KernelModel.TermKind.BIND_BLOCK) {
            var coordinates = model.binder(model.schema(term.sort().value()).value()).coordinates();
            Map<Coordinate, Integer> previous = new HashMap<>();
            for (int i = 0; i < coordinates.size(); i++) {
                var c = coordinates.get(i);
                Integer j = previous.put(new Coordinate(c.type(), c.domain(), c.quantifier(),
                        c.multiplicity(), c.disjointClass(), c.exchangeClass(), c.dependencies()), i);
                if (j == null) continue;
                List<Integer> generator = new ArrayList<>();
                for (int k = 0; k < coordinates.size(); k++) generator.add(k);
                java.util.Collections.swap(generator, j, i);
                require(out.add(new Occurrence(root, term.id(), path, List.copyOf(generator))),
                        "duplicate derived occurrence");
            }
        }
        for (int i = 0; i < term.children().size(); i++) {
            List<Integer> next = new ArrayList<>(path);
            next.add(i);
            collect(model, root, model.term(term.children().get(i)), List.copyOf(next), out);
        }
    }

    private static Map<String, Occurrence> records(Bundle bundle, KernelModel model) {
        Map<String, Occurrence> result = new HashMap<>();
        for (var row : bundle.semanticEvidence().child(3).requireTag("binder-occurrences").children()) {
            row.requireShape("binder-occurrence", 9, 0);
            var source = model.term(row.scalar(1));
            var schema = model.schema(source.sort().value());
            var coords = model.binder(schema.value()).coordinates();
            List<String> names = coords.stream().map(KernelModel.BinderCoordinate::slotName).toList();
            var embedding = model.embedding(row.scalar(4));
            var permutation = names.stream().map(slot -> names.indexOf(embedding.apply(slot))).toList();
            require(!permutation.contains(-1), "foreign generator image");
            List<Integer> path = java.util.Arrays.stream(row.scalar(3).split("/", -1))
                    .map(Integer::valueOf).toList();
            require(result.put(row.scalar(0), new Occurrence(row.scalar(8), row.scalar(1),
                    path, permutation)) == null, "duplicate record key");
        }
        return result;
    }

    private static Bundle verifiedFixture(Path dir, String fixture) throws Exception {
        byte[] bytes = Files.readAllBytes(dir.resolve(fixture + "-a.acgncert"));
        Bundle bundle = Bundle.parse(Codec.decode(bytes, Limits.defaults()));
        // These five test fixtures contain no theory axioms or CALLs.
        String emptyTheory = Wire.contentId(Wire.node("theory",
                List.of(Bundle.THEORY_ID, Bundle.RULE_SET, Bundle.VOCABULARY_POLICY),
                List.of(Wire.node("axioms", List.of(), List.of()))));
        String subject = CallOccurrenceCommitment.subjectDigest(bundle.metadata());
        var policy = VerificationPolicy.trust(emptyTheory).withCallOccurrenceCommitment(
                new CallOccurrenceCommitment(subject, CallOccurrenceCommitment.digest(subject, List.of())));
        var result = new IndependentVerifier().verify(bytes, Profile.FULL, policy);
        require(result.outcome() == Outcome.VERIFIED, fixture + " " + result);
        return bundle;
    }

    private static void checkFile(Path dir, String fixture, int expectedOwners, List<String> paths)
            throws Exception {
        var bundle = verifiedFixture(dir, fixture);
        var model = new KernelModel(bundle, Limits.defaults());
        var byKey = records(bundle, model);
        Set<Occurrence> allDerived = new HashSet<>();
        for (var proof : bundle.proofs().values()) {
            if (!proof.scalar(1).equals("CANONICAL_ORBIT")) continue;
            var payload = proof.child(1).requireShape("canonical-orbit", 6, 4);
            var root = model.term(payload.scalar(1));
            Set<Occurrence> required = new HashSet<>();
            collect(model, root.id(), root, List.of(), required);

            Set<Occurrence> supplied = new HashSet<>();
            for (var ref : payload.child(3).requireTag("binder-occurrence-refs").children()) {
                var key = ref.requireShape("binder-occurrence-ref", 1, 0).scalar(0);
                var occurrence = byKey.get(key);
                require(occurrence != null, "missing referenced record");
                require(supplied.add(occurrence), "duplicate fixture reference");
            }
            require(supplied.equals(required), "local orbit coverage");
            allDerived.addAll(required);
        }
        require(new HashSet<>(byKey.values()).equals(allDerived) && byKey.size() == allDerived.size(),
                "global record coverage");
        long owners = allDerived.stream().map(Occurrence::root).distinct().count();
        List<String> seenPaths = allDerived.stream().map(o -> o.path().toString()).sorted().toList();
        require(owners == expectedOwners && seenPaths.equals(paths), "unexpected fixture structure " + seenPaths);
        System.out.println(fixture + "\tVERIFIED\t" + owners + "\t" + allDerived.size()
                + "\t" + String.join(";", seenPaths));
    }

    private record Construction(String kind, String owner, String term, String operator, String path) {}

    private static String kind(KernelModel model, Bundle bundle, KernelModel.Term source) {
        if (source.kind() != KernelModel.TermKind.APP) return "NONE";
        var op = model.operator(source.symbol());
        if (!op.flatPath().equals("none")) return "FLAT";
        if (op.schemas().size() != 1) return "NONE";
        var schema = model.schema(op.schemas().get(0));
        if (schema.isDependentSequence() && Set.of("ALLOY/DEPENDENT-CHAIN/JOIN",
                "ALLOY/DEPENDENT-CHAIN/ARROW").contains(op.semanticIdentity())) return "CHAIN";
        // FULL has already validated the entire law table against the exact operator vocabulary.
        boolean hasRootLaw = bundle.semanticEvidence().child(0).children().stream().anyMatch(law ->
                law.scalar(2).equals(op.semanticIdentity()) && law.scalar(3).equals(op.outputType())
                && law.scalar(5).equals("0/0") && law.scalar(8).equals(schema.id()));
        return switch (schema.kind()) {
            case SEQ, DEPENDENT_SEQ, SET, BAG -> hasRootLaw ? "CONTAINER" : "NONE";
            default -> "NONE";
        };
    }

    private static void checkKernel(Path dir, String fixture, String expectedKind) throws Exception {
        var bundle = verifiedFixture(dir, fixture);
        var model = new KernelModel(bundle, Limits.defaults());
        Map<String, String> owners = new HashMap<>();
        for (var event : bundle.events()) {
            if (!Set.of("INSERT_FRESH", "INSERT_COLLISION").contains(event.scalar(1))) continue;
            var payload = event.child(0);
            var metadata = bundle.metadata();
            String owner = "source-owner/" + Wire.contentId(Wire.node("construction-source-owner-v1",
                    List.of(metadata.inputIdentifier(), metadata.inputSha256(), event.scalar(0),
                            payload.scalar(0)), List.of()));
            String prior = owners.putIfAbsent(payload.scalar(2), owner);
            require(prior == null || prior.equals(owner), "conflicting insertion owners");
        }
        Map<String, Construction> actual = new HashMap<>();
        for (int table : List.of(1, 2)) {
            for (var row : bundle.semanticEvidence().child(table).children()) {
                Construction observed = switch (row.tag()) {
                    case "flat-construction" -> new Construction("FLAT", row.scalar(8), row.scalar(5),
                            row.scalar(2), row.scalar(3));
                    case "container-construction" -> new Construction("CONTAINER", row.scalar(7),
                            row.scalar(4), row.scalar(2), row.scalar(3));
                    case "dependent-chain-construction" -> new Construction("CHAIN", row.scalar(6),
                            row.scalar(3), model.term(row.scalar(3)).symbol(), "0/0");
                    default -> throw new AssertionError("unexpected construction tag");
                };
                require(actual.put(row.scalar(0), observed) == null, "duplicate construction key");
            }
        }
        Set<Construction> expected = new HashSet<>();
        for (var proof : bundle.proofs().values()) {
            if (!proof.scalar(1).equals("KERNEL_REPLAY")) continue;
            var payload = proof.child(1);
            var source = model.term(payload.scalar(0));
            String required = kind(model, bundle, source);
            var reference = payload.child(4);
            require(reference.scalar(0).equals(required), "source and referenced kind differ");
            if (required.equals("NONE")) continue;
            var op = model.operator(source.symbol());
            String owner = owners.get(proof.scalar(0));
            require(owner != null, "missing insertion owner");
            var need = new Construction(required, owner, source.id(), op.id(),
                    required.equals("FLAT") ? op.flatPath() : "0/0");
            expected.add(need);
            require(need.equals(actual.get(reference.scalar(1))) && owner.equals(reference.scalar(3)),
                    "reference and derived replay obligation differ");
        }
        require(expected.equals(new HashSet<>(actual.values())) && expected.size() == 1
                && actual.size() == 1 && expected.iterator().next().kind().equals(expectedKind),
                "unexpected projected construction obligations " + expected);
        System.out.println(fixture + "\tVERIFIED\t" + expectedKind + "\t" + expected.size());
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) throw new IllegalArgumentException("expected schema-v8-coverage directory");
        Path dir = Path.of(args[0]);
        checkKernel(dir, "flat-and", "FLAT");
        checkKernel(dir, "container-equals", "CONTAINER");
        checkKernel(dir, "relation-empty-interior", "CHAIN");
        checkFile(dir, "bind-block-dual", 2, List.of("[0]", "[0]"));
        checkFile(dir, "bind-block-nested-same-descriptor", 1, List.of("[0, 0]", "[0]"));
    }
}
