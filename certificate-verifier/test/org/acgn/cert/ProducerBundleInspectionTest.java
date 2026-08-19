package org.acgn.cert;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Set;

/** Strict parsed-bundle checks over producer-generated bridge fixtures. */
public final class ProducerBundleInspectionTest {
    private static int checks;

    private ProducerBundleInspectionTest() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 6) {
            throw new IllegalArgumentException(
                    "usage: ProducerBundleInspectionTest "
                            + "<nullary-a> <nullary-b> <slot-a> <slot-b> "
                            + "<parent-a> <parent-b>");
        }
        byte[] nullaryA = Files.readAllBytes(Path.of(args[0]));
        byte[] nullaryB = Files.readAllBytes(Path.of(args[1]));
        byte[] slotA = Files.readAllBytes(Path.of(args[2]));
        byte[] slotB = Files.readAllBytes(Path.of(args[3]));
        byte[] parentA = Files.readAllBytes(Path.of(args[4]));
        byte[] parentB = Files.readAllBytes(Path.of(args[5]));
        check(java.util.Arrays.equals(nullaryA, nullaryB),
                "nullary export is byte deterministic");
        check(java.util.Arrays.equals(slotA, slotB),
                "slot export is byte deterministic");
        check(java.util.Arrays.equals(parentA, parentB),
                "parent export is byte deterministic");

        IndependentVerifier verifier = new IndependentVerifier();
        Bundle nullary = decode(nullaryA);
        Bundle slot = decode(slotA);
        Bundle parent = decode(parentA);
        assertVerified(verifier.verify(
                nullaryA, Profile.FULL,
                VerificationPolicy.trust(nullary.theoryDigest())), "nullary FULL");
        assertVerified(verifier.verify(
                slotA, Profile.FULL,
                VerificationPolicy.trust(slot.theoryDigest())), "slot FULL");
        assertVerified(verifier.verify(
                parentA, Profile.FULL,
                VerificationPolicy.trust(parent.theoryDigest())), "parent FULL");
        assertVerified(verifier.verifyPair(
                nullaryA,
                nullaryB,
                VerificationPolicy.trust(nullary.theoryDigest())), "nullary PAIR");

        check(slot.contexts().values().stream()
                        .anyMatch(context -> context.children().size() == 1),
                "slot fixture contains a nonempty typed context");
        check(slot.terms().values().stream()
                        .anyMatch(term -> "ONE_SLOT".equals(term.scalar(1))),
                "slot fixture contains ONE_SLOT");

        Wire.Node schemaSection = parent.theory().child(0);
        check(schemaSection.children().stream().anyMatch(schema ->
                        "ONE".equals(schema.scalar(1))
                                && ("T".equals(schema.scalar(2))
                                || "Bool".equals(schema.scalar(2)))),
                "parent fixture declares verifier ONE schemas");
        java.util.Map<String, String> schemaTypes = schemaSection.children().stream()
                .collect(java.util.stream.Collectors.toMap(
                        schema -> schema.scalar(0), schema -> schema.scalar(2)));
        Wire.Node operatorSection = parent.theory().child(1);
        check(operatorSection.children().size() == 3,
                "parent fixture declares left, right, and wrap operators");
        List<String> operatorInputTypes = operatorSection.children().stream()
                .map(operator -> schemaTypes.get(operator.child(0).scalar(0)))
                .sorted()
                .toList();
        check(operatorInputTypes.equals(List.of("Bool", "T", "T")),
                "operator references are exactly One(Bool), One(T), One(T)");
        check(parent.theory().child(3).children().size() == 1,
                "parent fixture registers exactly one ground axiom");
        Set<String> termKinds = parent.terms().values().stream()
                .map(term -> term.scalar(1)).collect(java.util.stream.Collectors.toSet());
        check(termKinds.containsAll(Set.of("APP", "INVOKE", "ONE_SLOT", "ONE_TERM")),
                "parent fixture contains complete recursive APP/INVOKE/ONE terms");
        Set<String> proofKinds = parent.proofs().values().stream()
                .map(proof -> proof.scalar(1)).collect(java.util.stream.Collectors.toSet());
        check(proofKinds.containsAll(Set.of(
                        "AXIOM", "PARENT_EDGE", "CONGRUENCE", "TRANS",
                        "KERNEL_REPLAY", "CANONICAL_ORBIT", "FRESH_WITNESS")),
                "parent fixture contains ground, edge, lifted, and replay proofs");

        List<Wire.Node> nonemptyPaths = parent.proofs().values().stream()
                .filter(proof -> "KERNEL_REPLAY".equals(proof.scalar(1)))
                .map(proof -> proof.child(1).child(0))
                .filter(paths -> !paths.children().isEmpty())
                .toList();
        check(nonemptyPaths.size() == 1,
                "exactly one replay requires a parent path");
        Wire.Node path = nonemptyPaths.get(0).child(0);
        check("0/0".equals(path.scalar(0)) && path.children().size() >= 1,
                "wrapper path is 0/0 and contains a certified edge reference");
        check(!path.scalar(1).equals(path.scalar(2)),
                "wrapper path changes from nonleader to leader witness");
        Wire.Node finalInvocation = parent.terms().get(path.scalar(3));
        check(finalInvocation != null
                        && "INVOKE".equals(finalInvocation.scalar(1))
                        && path.scalar(2).equals(finalInvocation.scalar(5)),
                "parent path resolves to its declared leader invocation");

        List<String> events = parent.events().stream()
                .map(event -> event.scalar(1)).toList();
        check(events.equals(List.of(
                        "INSERT_FRESH",
                        "INSERT_FRESH",
                        "UNION",
                        "REBUILD_COMPLETE",
                        "INSERT_FRESH")),
                "parent fixture has the exact accepted event sequence");
        check(parent.snapshots().size() == 6,
                "five transitions retain all six exact snapshots");
        Wire.Node unfolding = parent.unfoldings().values().iterator().next();
        check("2".equals(unfolding.scalar(2)),
                "parent unfolding has exact height two");
        Wire.Node rootRep = unfolding.child(0);
        Wire.Node repChildren = rootRep.child(2);
        check(repChildren.children().size() == 1
                        && "0/0".equals(repChildren.child(0).scalar(0))
                        && "1".equals(repChildren.child(0).child(0).scalar(3)),
                "height-two unfolding contains the exact leaf representative");

        System.out.println("ProducerBundleInspectionTest: " + checks
                + " checks passed");
    }

    private static Bundle decode(byte[] bytes) {
        return Bundle.parse(Codec.decode(bytes, Limits.defaults()));
    }

    private static void assertVerified(VerificationResult result, String label) {
        check(result.outcome() == Outcome.VERIFIED,
                label + " expected VERIFIED but got " + result);
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
