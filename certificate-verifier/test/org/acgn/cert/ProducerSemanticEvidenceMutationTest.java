package org.acgn.cert;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.function.UnaryOperator;

/** Adversarial mutations over producer-generated semantic evidence. */
public final class ProducerSemanticEvidenceMutationTest {
    private static final java.util.Set<Integer> CONTENT_TABLES =
            java.util.Set.of(2, 3, 4, 5, 7, 9, 10);
    private static int checks;

    private ProducerSemanticEvidenceMutationTest() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 9 && args.length != 10) {
            throw new IllegalArgumentException(
                    "usage: ProducerSemanticEvidenceMutationTest "
                            + "<flat-bundle> <flat-alternate-bundle> "
                            + "<container-bundle> <single-binder-occurrence-bundle> "
                            + "<dual-binder-occurrence-bundle> "
                            + "<nested-binder-occurrence-bundle> <relation-bundle> "
                            + "<call-occurrence-bundle> <repeated-free-slot-bundle> "
                            + "[<parent-path-bundle>]");
        }
        IndependentVerifier verifier = new IndependentVerifier();
        byte[] flat = Files.readAllBytes(Path.of(args[0]));
        byte[] flatAlternate = Files.readAllBytes(Path.of(args[1]));
        byte[] container = Files.readAllBytes(Path.of(args[2]));
        byte[] binder = Files.readAllBytes(Path.of(args[3]));
        byte[] dualBinder = Files.readAllBytes(Path.of(args[4]));
        byte[] nestedBinder = Files.readAllBytes(Path.of(args[5]));
        byte[] relation = Files.readAllBytes(Path.of(args[6]));
        byte[] call = Files.readAllBytes(Path.of(args[7]));
        byte[] repeatedFreeSlots = Files.readAllBytes(Path.of(args[8]));
        Path siblingParentPath = Path.of(args[0]).resolveSibling(
                "parent-path-a.acgncert");
        Path parentPathInput = args.length == 10
                ? Path.of(args[9]) : siblingParentPath;
        if (!Files.isRegularFile(parentPathInput)) {
            throw new AssertionError(
                    "parent-path source-replay fixture is required: " + parentPathInput);
        }
        byte[] parentPath = Files.readAllBytes(parentPathInput);

        assertVerified(verifier, flat, "flat producer evidence");
        assertVerified(verifier, flatAlternate, "alternate flat producer evidence");
        assertVerified(verifier, container, "container producer evidence");
        assertVerified(verifier, binder, "binder producer evidence");
        assertVerified(verifier, dualBinder, "dual binder producer evidence");
        assertVerified(verifier, nestedBinder, "nested binder producer evidence");
        assertVerified(verifier, relation, "ordered relation-type evidence");
        assertVerified(verifier, call, "CALL occurrence evidence");
        assertVerified(
                verifier,
                repeatedFreeSlots,
                "semantic orbit order with repeated same-type free slots");
        assertVerified(verifier, parentPath, "parent-path source replay");
        assertRelationColumns(relation, "AlloySig:S", "AlloySig:T");
        assertDependentChainShape(relation);
        assertDistinctBinderOwners(dualBinder);
        assertNestedSameDescriptorOccurrences(nestedBinder);

        for (int scalar = 1; scalar <= 7; scalar++) {
            final int field = scalar;
            assertRejected(
                    verifier,
                    mutateRecord(call, 5, record -> {
                        List<String> scalars = new ArrayList<>(record.scalars());
                        scalars.set(field, switch (field) {
                            case 1 -> "18";
                            case 2 -> "phase/0/other";
                            case 3 -> "other";
                            case 4 -> "fixture/other";
                            case 5 -> "call/expression";
                            case 6 -> "1";
                            case 7 -> "TYPECHECKED_IMPORT";
                            default -> throw new AssertionError();
                        });
                        return Wire.node(record.tag(), scalars, record.children());
                    }),
                    FailureCode.THEORY_MISMATCH,
                    "CALL occurrence scalar mutation " + field);
        }
        assertRejected(
                verifier,
                mutateRecord(call, 5, record -> {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(8, record.child(0).scalar(1));
                    return Wire.node(record.tag(), scalars, record.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "CALL source endpoint mutation");
        assertRejected(
                verifier,
                mutateRecord(call, 5, record -> {
                    Wire.Node argument = record.child(0);
                    return replaceChild(record, 0, Wire.leaf(
                            "call-argument", "1", argument.scalar(1)));
                }),
                FailureCode.THEORY_MISMATCH,
                "CALL argument-role mutation");
        assertRejected(
                verifier,
                mutateRecord(call, 5, record -> {
                    Wire.Node first = record.child(0);
                    Wire.Node second = record.child(1);
                    return replaceChild(record, 0, Wire.leaf(
                            "call-argument", "0", second.scalar(1)));
                }),
                FailureCode.THEORY_MISMATCH,
                "CALL ordered-argument endpoint mutation");

        assertRejected(
                verifier,
                mutateRecord(flat, 1, record -> {
                    Wire.Node source = record.child(0);
                    List<String> scalars = new ArrayList<>(source.scalars());
                    scalars.set(3, record.scalar(6));
                    return replaceChild(record, 0, Wire.node(
                            source.tag(), scalars, source.children()));
                }),
                FailureCode.THEORY_MISMATCH,
                "flat source structural key mutation");

        assertRejected(
                verifier,
                mutateRecord(container, 2, record -> {
                    Wire.Node trace = record.child(1);
                    int inputCount = Integer.parseInt(trace.scalar(2));
                    Wire.Node output = trace.child(inputCount);
                    List<String> scalars = new ArrayList<>(output.scalars());
                    if (scalars.size() < 2) {
                        throw new AssertionError("producer trace has no quotient fiber");
                    }
                    scalars.set(1, "99");
                    return replaceChild(record, 1, replaceChild(
                            trace,
                            inputCount,
                            Wire.node(output.tag(), scalars, output.children())));
                }),
                FailureCode.THEORY_MISMATCH,
                "container quotient-fiber mutation");

        assertRejected(
                verifier,
                mutateRecord(binder, 3, record -> {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(6, record.scalar(7));
                    return Wire.node(record.tag(), scalars, record.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "binder source-endpoint mutation");

        assertRejected(
                verifier,
                withoutSemanticRecords(flat, 1),
                FailureCode.MISSING_EVIDENCE,
                "flat construction omission");
        assertRejected(
                verifier,
                withoutSemanticRecords(container, 2),
                FailureCode.MISSING_EVIDENCE,
                "container construction omission");
        assertRejected(
                verifier,
                withoutSemanticRecords(binder, 3),
                FailureCode.MISSING_EVIDENCE,
                "binder occurrence omission");
        assertRejected(
                verifier,
                mutateRecord(binder, 3, record -> {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(8, record.scalar(2));
                    return Wire.node(record.tag(), scalars, record.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "binder occurrence root mutation");
        assertRejected(
                verifier,
                pairedOmission(flat, 1, "KERNEL_REPLAY", "FLAT"),
                FailureCode.MISSING_EVIDENCE,
                "flat record-plus-reference paired omission");
        assertRejected(
                verifier,
                pairedOmission(container, 2, "KERNEL_REPLAY", "CONTAINER"),
                FailureCode.MISSING_EVIDENCE,
                "container record-plus-reference paired omission");
        assertRejected(
                verifier,
                pairedOmission(binder, 3, "CANONICAL_ORBIT", "BINDER"),
                FailureCode.MISSING_EVIDENCE,
                "binder record-plus-reference paired omission");
        assertRejected(
                verifier,
                crossReplaySwap(flat, "KERNEL_REPLAY", "FLAT"),
                FailureCode.MISSING_EVIDENCE,
                "flat construction cross-replay substitution");
        assertRejected(
                verifier,
                crossReplaySwap(container, "KERNEL_REPLAY", "CONTAINER"),
                FailureCode.MISSING_EVIDENCE,
                "container construction cross-replay substitution");
        assertRejected(
                verifier,
                mutateConstructionReference(flat, "FLAT", reference -> {
                    List<String> scalars = new ArrayList<>(reference.scalars());
                    scalars.set(0, "NONE");
                    return Wire.node(reference.tag(), scalars, reference.children());
                }),
                FailureCode.MISSING_EVIDENCE,
                "source-construction kind mutation");
        assertRejected(
                verifier,
                mutateConstructionReference(flat, "FLAT", reference -> {
                    List<String> scalars = new ArrayList<>(reference.scalars());
                    scalars.set(1, reference.scalar(2));
                    return Wire.node(reference.tag(), scalars, reference.children());
                }),
                FailureCode.MISSING_EVIDENCE,
                "source-construction evidence-key mutation");
        assertRejected(
                verifier,
                mutateConstructionReference(flat, "FLAT", reference -> {
                    List<String> scalars = new ArrayList<>(reference.scalars());
                    scalars.set(2, reference.scalar(1));
                    return Wire.node(reference.tag(), scalars, reference.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "source-construction endpoint mutation");
        assertRejected(
                verifier,
                mutateConstructionReference(flat, "FLAT", reference -> {
                    List<String> scalars = new ArrayList<>(reference.scalars());
                    scalars.set(3, reference.scalar(2));
                    return Wire.node(reference.tag(), scalars, reference.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "source-construction owner mutation");
        assertRejected(
                verifier,
                mutateReplaySourceClaim(flat, "FLAT"),
                FailureCode.THEORY_MISMATCH,
                "construction replay source-claim mutation");
        assertRejected(
                verifier,
                mutateReplayRight(flat, "FLAT"),
                FailureCode.THEORY_MISMATCH,
                "construction replay right-endpoint mutation");
        assertRejected(
                verifier,
                mutateOrbitBase(flat, "FLAT"),
                FailureCode.THEORY_MISMATCH,
                "construction orbit-base mutation");
        assertRejected(
                verifier,
                crossSourceConstructionSubstitution(
                        flat, flatAlternate, false),
                FailureCode.THEORY_MISMATCH,
                "same-target different-source construction substitution");
        assertRejected(
                verifier,
                crossSourceConstructionSubstitution(
                        flat, flatAlternate, true),
                FailureCode.THEORY_MISMATCH,
                "complete cross-source construction substitution");
        assertRejected(
                verifier,
                crossOrbitBinderReferenceSwap(dualBinder),
                FailureCode.MISSING_EVIDENCE,
                "cross-orbit binder-reference substitution");

        assertRejected(
                verifier,
                mutateRecord(relation, 1, record -> {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(8, "0".repeat(64));
                    return Wire.node(record.tag(), scalars, record.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "dependent-chain source-theory digest mutation");
        assertRejected(
                verifier,
                mutateRecord(relation, 1, record -> {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(10, record.scalar(9));
                    return Wire.node(record.tag(), scalars, record.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "dependent-chain source-occurrence commitment substitution");
        assertRejected(
                verifier,
                mutateRecord(relation, 1, record -> {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(2, "ARROW");
                    return Wire.node(record.tag(), scalars, record.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "dependent-chain operator-family mutation");
        assertRejected(
                verifier,
                mutateRecord(relation, 1, record -> {
                    Wire.Node source = record.child(0);
                    return replaceChild(record, 0, Wire.node(
                            source.tag(),
                            source.scalars(),
                            List.of(source.child(1), source.child(0))));
                }),
                FailureCode.THEORY_MISMATCH,
                "dependent-chain role-order mutation");
        assertRejected(
                verifier,
                mutateRecord(relation, 1, record -> {
                    Wire.Node source = record.child(0);
                    Wire.Node left = source.child(0);
                    Wire.Node firstLeaf = left.child(0);
                    Wire.Node secondLeaf = left.child(1);
                    List<String> scalars = new ArrayList<>(secondLeaf.scalars());
                    scalars.set(0, firstLeaf.scalar(0));
                    Wire.Node changedLeft = replaceChild(
                            left,
                            1,
                            Wire.node(secondLeaf.tag(), scalars, secondLeaf.children()));
                    return replaceChild(
                            record, 0, replaceChild(source, 0, changedLeft));
                }),
                FailureCode.THEORY_MISMATCH,
                "dependent-chain duplicate-substitution mutation");
        assertRejected(
                verifier,
                mutateRecord(relation, 1, record -> {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(9, record.scalar(4));
                    return Wire.node(record.tag(), scalars, record.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "dependent-chain theory-index mutation");
        assertRejected(
                verifier,
                mutateRecord(relation, 1, record -> {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(4, record.scalar(5));
                    return Wire.node(record.tag(), scalars, record.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "dependent-chain endpoint mutation");
        assertRejected(
                verifier,
                mutateRecord(relation, 1, record -> {
                    List<String> scalars = new ArrayList<>(record.scalars());
                    scalars.set(6, "source-owner/forged");
                    return Wire.node(record.tag(), scalars, record.children());
                }),
                FailureCode.THEORY_MISMATCH,
                "dependent-chain source-owner mutation");
        assertRejected(
                verifier,
                withoutSemanticRecords(relation, 1),
                FailureCode.MISSING_EVIDENCE,
                "dependent-chain construction omission");
        assertRejected(
                verifier,
                pairedOmission(relation, 1, "KERNEL_REPLAY", "CHAIN"),
                FailureCode.MISSING_EVIDENCE,
                "dependent-chain record-plus-reference paired omission");
        assertRejected(
                verifier,
                crossReplaySwap(relation, "KERNEL_REPLAY", "CHAIN"),
                FailureCode.MISSING_EVIDENCE,
                "dependent-chain cross-replay substitution");
        assertRejected(
                verifier,
                mutateDependentSchema(relation, schema -> {
                    List<String> scalars = new ArrayList<>(schema.scalars());
                    scalars.set(2, "AlloySig:univ");
                    return Wire.node(schema.tag(), scalars, schema.children());
                }),
                FailureCode.INVALID_RECORD_SHAPE,
                "dependent Seq forged scalar payload");
        assertRejected(
                verifier,
                mutateDependentSchema(relation, schema -> Wire.node(
                        schema.tag(),
                        schema.scalars(),
                        schema.children().subList(0, schema.children().size() - 1))),
                FailureCode.INVALID_RECORD_SHAPE,
                "dependent Seq positional-arity mismatch");

        List<byte[]> nonConstructionCandidates = new ArrayList<>();
        nonConstructionCandidates.add(parentPath);
        nonConstructionCandidates.addAll(List.of(
                flat,
                container,
                binder,
                dualBinder,
                nestedBinder,
                relation,
                call,
                repeatedFreeSlots));
        byte[] nonConstructionReplay = findNonConstructionReplayWithDistinctSource(
                nonConstructionCandidates.toArray(byte[][]::new));
        if (nonConstructionReplay == null) {
            throw new AssertionError(
                    "parent-path fixtures omit a distinct NONE replay source");
        }
        assertRejected(
                verifier,
                mutateReplayRight(nonConstructionReplay, "NONE"),
                FailureCode.THEORY_MISMATCH,
                "non-construction replay right-endpoint mutation");
        assertRejected(
                verifier,
                mutateOrbitBaseToReplayLeft(nonConstructionReplay),
                FailureCode.THEORY_MISMATCH,
                "non-construction replay left endpoint cannot replace orbit base");

        System.out.println("ProducerSemanticEvidenceMutationTest: " + checks
                + " checks passed");
    }

    private static void assertRelationColumns(
            byte[] bytes,
            String expectedFirst,
            String expectedSecond) {
        Wire.Node root = Codec.decode(bytes, Limits.defaults());
        Wire.Node exactTypes = root.child(1).child(1).child(3).child(4);
        java.util.Map<String, Wire.Node> records = new java.util.LinkedHashMap<>();
        for (Wire.Node record : exactTypes.children()) {
            records.put(record.scalar(0), record);
        }
        Wire.Node relation = exactTypes.children().stream()
                .filter(record -> "RELATION".equals(record.scalar(1))
                        && record.children().size() == 2)
                .filter(record -> {
                    Wire.Node first = records.get(record.child(0).scalar(0));
                    Wire.Node second = records.get(record.child(1).scalar(0));
                    return first != null && second != null
                            && "CONSTRUCTOR".equals(first.scalar(1))
                            && expectedFirst.equals(first.scalar(2))
                            && "CONSTRUCTOR".equals(second.scalar(1))
                            && expectedSecond.equals(second.scalar(2));
                })
                .findFirst()
                .orElseThrow(() -> new AssertionError(
                        "relation fixture has no requested ordered RELATION record"));
        check(relation.children().size() == 2,
                "relation fixture must retain exactly two ordered columns");
        Wire.Node first = records.get(relation.child(0).scalar(0));
        Wire.Node second = records.get(relation.child(1).scalar(0));
        check(first != null && "CONSTRUCTOR".equals(first.scalar(1))
                        && expectedFirst.equals(first.scalar(2)),
                "first serialized relation column changed");
        check(second != null && "CONSTRUCTOR".equals(second.scalar(1))
                        && expectedSecond.equals(second.scalar(2)),
                "second serialized relation column changed");
    }

    private static void assertDistinctBinderOwners(byte[] bytes) {
        Wire.Node root = Codec.decode(bytes, Limits.defaults());
        Wire.Node section = root.child(1).child(1).child(3).child(3);
        check(section.children().size() == 2,
                "dual binder fixture must contain two occurrence certificates");
        Wire.Node first = section.child(0);
        Wire.Node second = section.child(1);
        check(!first.scalar(8).equals(second.scalar(8)),
                "dual binder fixture roots must differ");
        check(first.scalar(3).equals(second.scalar(3)),
                "root-qualified binder fixture must reuse the same local occurrence path");
        check(!first.scalar(0).equals(second.scalar(0)),
                "distinct enclosing roots must produce distinct binder evidence keys");
    }

    private static void assertDependentChainShape(byte[] bytes) {
        Wire.Node root = Codec.decode(bytes, Limits.defaults());
        Wire.Node evidence = root.child(1).child(1).child(3).child(1);
        check(evidence.children().size() == 1
                        && evidence.child(0).tag().equals(
                                "dependent-chain-construction"),
                "relation fixture must carry one dependent-chain certificate");
        Wire.Node record = evidence.child(0);
        check(record.scalars().size() == 11
                        && record.scalar(2).equals("JOIN")
                        && record.scalar(7).equals(
                                "alloy-dependent-chain-theory-v4")
                        && record.scalar(8).matches("[0-9a-f]{64}")
                        && record.scalar(10).contains(
                                "alloy-dependent-chain-source-occurrence-v1"),
                "dependent-chain record must bind kind, version, digest, and source occurrence");
        check(dependentLeaves(record.child(0)) == 3,
                "dependent-chain source tree must retain all three leaves");
        Wire.Node schemas = root.child(1).child(1).child(0);
        Wire.Node dependent = schemas.children().stream()
                .filter(schema -> schema.scalar(1).equals("DEPENDENT_SEQ"))
                .findFirst()
                .orElseThrow(() -> new AssertionError(
                        "dependent-chain bundle has no positional Seq schema"));
        check(dependent.children().size() == 3
                        && dependent.scalar(3).equals("FINITE:3")
                        && dependent.scalar(4).equals("ORDERED_SEQUENCE"),
                "dependent Seq must expose three ordered positional schemas");
    }

    private static int dependentLeaves(Wire.Node input) {
        if (input.tag().equals("dependent-chain-leaf")) {
            input.requireShape("dependent-chain-leaf", 5, 0);
            return 1;
        }
        input.requireShape("dependent-chain-application", 4, 2);
        return dependentLeaves(input.child(0)) + dependentLeaves(input.child(1));
    }

    private static void assertNestedSameDescriptorOccurrences(byte[] bytes) {
        Wire.Node root = Codec.decode(bytes, Limits.defaults());
        Wire.Node section = root.child(1).child(1).child(3).child(3);
        check(section.children().size() == 2,
                "nested binder fixture must contain both descriptor occurrences");
        Wire.Node first = section.child(0);
        Wire.Node second = section.child(1);
        check(first.scalar(8).equals(second.scalar(8)),
                "nested descriptor occurrences must share one enclosing root");
        check(!first.scalar(3).equals(second.scalar(3)),
                "nested descriptor occurrences must retain distinct source paths");
        check(!first.scalar(0).equals(second.scalar(0))
                        && !first.scalar(6).equals(second.scalar(6))
                        && !first.scalar(7).equals(second.scalar(7)),
                "nested descriptor occurrences must retain distinct evidence and endpoints");
    }

    private static void assertVerified(
            IndependentVerifier verifier,
            byte[] bytes,
            String label) {
        Bundle bundle = decode(bytes);
        VerificationResult result = verifier.verify(
                bytes,
                Profile.FULL,
                VerificationPolicy.trust(bundle.theoryDigest()));
        check(result.outcome() == Outcome.VERIFIED, label + ": " + result);
    }

    private static void assertRejected(
            IndependentVerifier verifier,
            byte[] bytes,
            FailureCode expected,
            String label) {
        Bundle bundle = decode(bytes);
        VerificationResult result = verifier.verify(
                bytes,
                Profile.FULL,
                VerificationPolicy.trust(bundle.theoryDigest()));
        check(result.outcome() == Outcome.REJECTED
                        && result.code() == expected,
                label + ": " + result);
    }

    private static byte[] mutateRecord(
            byte[] source,
            int sectionIndex,
            UnaryOperator<Wire.Node> mutation) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        Wire.Node manifest = root.child(1);
        Wire.Node vocabulary = manifest.child(1);
        Wire.Node evidence = vocabulary.child(3);
        Wire.Node section = evidence.child(sectionIndex);
        if (section.children().size() != 1) {
            throw new AssertionError(
                    "fixture section " + section.tag()
                            + " must contain exactly one semantic-evidence record; found "
                            + section.children().size());
        }
        Wire.Node changedRecord = mutation.apply(section.child(0));
        Wire.Node changedSection = Wire.node(
                section.tag(), section.scalars(), List.of(changedRecord));
        Wire.Node changedEvidence = replaceChild(
                evidence, sectionIndex, changedSection);
        Wire.Node changedVocabulary = replaceChild(
                vocabulary, 3, changedEvidence);
        Wire.Node changedManifest = Wire.node(
                manifest.tag(),
                List.of(manifest.scalar(0), Wire.contentId(changedVocabulary)),
                List.of(manifest.child(0), changedVocabulary));
        return Codec.encode(replaceChild(root, 1, changedManifest));
    }

    private static byte[] mutateDependentSchema(
            byte[] source,
            UnaryOperator<Wire.Node> mutation) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        Wire.Node manifest = root.child(1);
        Wire.Node vocabulary = manifest.child(1);
        Wire.Node schemas = vocabulary.child(0);
        List<Wire.Node> changedSchemas = new ArrayList<>();
        boolean changed = false;
        for (Wire.Node schema : schemas.children()) {
            if (schema.scalar(1).equals("DEPENDENT_SEQ")) {
                if (changed) {
                    throw new AssertionError(
                            "relation fixture has multiple dependent Seq schemas");
                }
                changedSchemas.add(mutation.apply(schema));
                changed = true;
            } else {
                changedSchemas.add(schema);
            }
        }
        if (!changed) {
            throw new AssertionError("relation fixture has no dependent Seq schema");
        }
        Wire.Node changedVocabulary = replaceChild(
                vocabulary,
                0,
                Wire.node(schemas.tag(), schemas.scalars(), changedSchemas));
        Wire.Node changedManifest = Wire.node(
                manifest.tag(),
                List.of(manifest.scalar(0), Wire.contentId(changedVocabulary)),
                List.of(manifest.child(0), changedVocabulary));
        return Codec.encode(replaceChild(root, 1, changedManifest));
    }

    private static byte[] withoutSemanticRecords(
            byte[] source,
            int sectionIndex) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        Wire.Node manifest = root.child(1);
        Wire.Node vocabulary = manifest.child(1);
        Wire.Node evidence = vocabulary.child(3);
        Wire.Node section = evidence.child(sectionIndex);
        Wire.Node changedEvidence = replaceChild(
                evidence,
                sectionIndex,
                Wire.node(section.tag(), section.scalars(), List.of()));
        Wire.Node changedVocabulary = replaceChild(
                vocabulary, 3, changedEvidence);
        Wire.Node changedManifest = Wire.node(
                manifest.tag(),
                List.of(manifest.scalar(0), Wire.contentId(changedVocabulary)),
                List.of(manifest.child(0), changedVocabulary));
        return Codec.encode(replaceChild(root, 1, changedManifest));
    }

    private static byte[] pairedOmission(
            byte[] source,
            int evidenceIndex,
            String variant,
            String kind) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        Wire.Node manifest = root.child(1);
        Wire.Node vocabulary = manifest.child(1);
        Wire.Node evidence = vocabulary.child(3);
        Wire.Node section = evidence.child(evidenceIndex);
        Wire.Node changedEvidence = replaceChild(
                evidence,
                evidenceIndex,
                Wire.node(section.tag(), section.scalars(), List.of()));
        Wire.Node changedVocabulary = replaceChild(vocabulary, 3, changedEvidence);
        Wire.Node changedManifest = Wire.node(
                "manifest",
                List.of(manifest.scalar(0), Wire.contentId(changedVocabulary)),
                List.of(manifest.child(0), changedVocabulary));
        root = replaceChild(root, 1, changedManifest);

        List<Wire.Node> proofs = new ArrayList<>();
        boolean changed = false;
        for (Wire.Node proof : root.child(5).children()) {
            Wire.Node next = proof;
            if (variant.equals(proof.scalar(1))) {
                Wire.Node payload = proof.child(1);
                if ("BINDER".equals(kind)) {
                    Wire.Node references = payload.child(3);
                    if (!references.children().isEmpty()) {
                        next = replaceChild(
                                proof,
                                1,
                                replaceChild(payload, 3, Wire.node(
                                        "binder-occurrence-refs", List.of())));
                        changed = true;
                    }
                } else {
                    Wire.Node reference = payload.child(4);
                    if (kind.equals(reference.scalar(0))) {
                        next = replaceChild(
                                proof,
                                1,
                                replaceChild(payload, 4, Wire.leaf(
                                        "source-construction", "NONE", "", "", "")));
                        changed = true;
                    }
                }
            }
            proofs.add(next);
        }
        if (!changed) {
            throw new AssertionError(kind + " fixture has no paired omission target");
        }
        root = replaceChild(root, 5, Wire.node("proofs", sorted(proofs)));
        return Codec.encode(closeContentIds(root));
    }

    private static byte[] crossReplaySwap(
            byte[] source,
            String variant,
            String kind) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        List<Wire.Node> proofs = new ArrayList<>(root.child(5).children());
        int populated = -1;
        int empty = -1;
        Wire.Node retained = null;
        for (int index = 0; index < proofs.size(); index++) {
            Wire.Node proof = proofs.get(index);
            if (!variant.equals(proof.scalar(1))) {
                continue;
            }
            Wire.Node reference = proof.child(1).child(4);
            if (kind.equals(reference.scalar(0)) && populated < 0) {
                populated = index;
                retained = reference;
            } else if ("NONE".equals(reference.scalar(0)) && empty < 0) {
                empty = index;
            }
        }
        if (populated < 0 || empty < 0) {
            throw new AssertionError(kind + " fixture has no cross-replay target");
        }
        Wire.Node populatedProof = proofs.get(populated);
        Wire.Node emptyProof = proofs.get(empty);
        proofs.set(populated, replaceChild(
                populatedProof,
                1,
                replaceChild(populatedProof.child(1), 4, Wire.leaf(
                        "source-construction", "NONE", "", "", ""))));
        proofs.set(empty, replaceChild(
                emptyProof,
                1,
                replaceChild(emptyProof.child(1), 4, retained)));
        root = replaceChild(root, 5, Wire.node("proofs", sorted(proofs)));
        return Codec.encode(closeContentIds(root));
    }

    private static byte[] mutateConstructionReference(
            byte[] source,
            String kind,
            UnaryOperator<Wire.Node> mutation) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        List<Wire.Node> proofs = new ArrayList<>();
        int changed = 0;
        for (Wire.Node proof : root.child(5).children()) {
            Wire.Node next = proof;
            if ("KERNEL_REPLAY".equals(proof.scalar(1))) {
                Wire.Node payload = proof.child(1);
                Wire.Node reference = payload.child(4);
                if (kind.equals(reference.scalar(0))) {
                    next = replaceChild(
                            proof,
                            1,
                            replaceChild(payload, 4, mutation.apply(reference)));
                    changed++;
                }
            }
            proofs.add(next);
        }
        if (changed != 1) {
            throw new AssertionError(
                    kind + " fixture must have exactly one populated construction "
                            + "reference; found " + changed);
        }
        root = replaceChild(root, 5, Wire.node("proofs", sorted(proofs)));
        return Codec.encode(closeContentIds(root));
    }

    private static byte[] mutateReplaySourceClaim(
            byte[] source,
            String constructionKind) {
        return mutateReplayProof(source, constructionKind, (proof, payload) -> {
            List<String> scalars = new ArrayList<>(proof.scalars());
            scalars.set(5, differentTermId(source, proof.scalar(5)));
            return Wire.node(proof.tag(), scalars, proof.children());
        });
    }

    private static byte[] mutateReplayRight(
            byte[] source,
            String constructionKind) {
        return mutateReplayProof(source, constructionKind, (proof, payload) -> {
            List<String> scalars = new ArrayList<>(proof.scalars());
            scalars.set(6, differentTermId(source, proof.scalar(6)));
            return Wire.node(proof.tag(), scalars, proof.children());
        });
    }

    private static byte[] mutateOrbitBase(
            byte[] source,
            String constructionKind) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        String replayId = replayIdForConstruction(root, constructionKind);
        String orbitId = canonicalOrbitForReplay(root, replayId);
        List<Wire.Node> proofs = new ArrayList<>();
        int changed = 0;
        for (Wire.Node proof : root.child(5).children()) {
            Wire.Node next = proof;
            if (proof.scalar(0).equals(orbitId)) {
                Wire.Node payload = proof.child(1).requireShape(
                        "canonical-orbit", 6, 4);
                List<String> scalars = new ArrayList<>(payload.scalars());
                scalars.set(1, differentTermId(source, payload.scalar(1)));
                next = replaceChild(
                        proof,
                        1,
                        Wire.node(payload.tag(), scalars, payload.children()));
                changed++;
            }
            proofs.add(next);
        }
        check(changed == 1, "construction fixture has one referenced orbit");
        root = replaceChild(root, 5, Wire.node("proofs", sorted(proofs)));
        return Codec.encode(closeContentIds(root));
    }

    private static byte[] mutateOrbitBaseToReplayLeft(byte[] source) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        String replayId = replayIdForDistinctNoneSource(root);
        Wire.Node replay = proof(root, replayId);
        String orbitId = canonicalOrbitForReplay(root, replayId);
        List<Wire.Node> proofs = new ArrayList<>();
        int changed = 0;
        for (Wire.Node candidate : root.child(5).children()) {
            Wire.Node next = candidate;
            if (candidate.scalar(0).equals(orbitId)) {
                Wire.Node payload = candidate.child(1).requireShape(
                        "canonical-orbit", 6, 4);
                check(!payload.scalar(1).equals(replay.scalar(5)),
                        "non-construction replay source differs from orbit base");
                List<String> scalars = new ArrayList<>(payload.scalars());
                scalars.set(1, replay.scalar(5));
                next = replaceChild(
                        candidate,
                        1,
                        Wire.node(payload.tag(), scalars, payload.children()));
                changed++;
            }
            proofs.add(next);
        }
        check(changed == 1, "non-construction fixture has one referenced orbit");
        root = replaceChild(root, 5, Wire.node("proofs", sorted(proofs)));
        return Codec.encode(closeContentIds(root));
    }

    private static byte[] mutateReplayProof(
            byte[] source,
            String constructionKind,
            ReplayMutation mutation) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        String replayId = constructionKind.equals("NONE")
                ? replayIdForDistinctNoneSource(root)
                : replayIdForConstruction(root, constructionKind);
        List<Wire.Node> proofs = new ArrayList<>();
        int changed = 0;
        for (Wire.Node proof : root.child(5).children()) {
            if (proof.scalar(0).equals(replayId)) {
                Wire.Node payload = proof.child(1).requireShape(
                        "kernel-replay", 7, 5);
                proofs.add(mutation.apply(proof, payload));
                changed++;
            } else {
                proofs.add(proof);
            }
        }
        check(changed == 1, "fixture has one selected replay proof");
        root = replaceChild(root, 5, Wire.node("proofs", sorted(proofs)));
        return Codec.encode(closeContentIds(root));
    }

    private static byte[] findNonConstructionReplayWithDistinctSource(
            byte[]... candidates) {
        for (byte[] candidate : candidates) {
            Wire.Node root = Codec.decode(candidate, Limits.defaults());
            if (hasDistinctNoneReplay(root)) {
                return candidate;
            }
        }
        return null;
    }

    private static boolean hasDistinctNoneReplay(Wire.Node root) {
        for (Wire.Node canonical : root.child(9).children()) {
            String replayId = canonical.child(0).requireShape(
                    "source-replay-ref", 1, 0).scalar(0);
            Wire.Node replay = proof(root, replayId);
            Wire.Node reference = replay.child(1).requireShape(
                    "kernel-replay", 7, 5).child(4).requireShape(
                            "source-construction", 4, 0);
            if (reference.scalar(0).equals("NONE")
                    && reference.scalar(1).isEmpty()
                    && !replay.scalar(5).equals(replay.scalar(6))) {
                return true;
            }
        }
        return false;
    }

    private static String replayIdForDistinctNoneSource(Wire.Node root) {
        for (Wire.Node canonical : root.child(9).children()) {
            String replayId = canonical.child(0).requireShape(
                    "source-replay-ref", 1, 0).scalar(0);
            Wire.Node replay = proof(root, replayId);
            Wire.Node reference = replay.child(1).requireShape(
                    "kernel-replay", 7, 5).child(4).requireShape(
                            "source-construction", 4, 0);
            if (reference.scalar(0).equals("NONE")
                    && reference.scalar(1).isEmpty()
                    && !replay.scalar(5).equals(replay.scalar(6))) {
                return replayId;
            }
        }
        throw new AssertionError("fixture has no distinct NONE replay source");
    }

    private static String replayIdForConstruction(
            Wire.Node root,
            String constructionKind) {
        for (Wire.Node proof : root.child(5).children()) {
            if (!proof.scalar(1).equals("KERNEL_REPLAY")) {
                continue;
            }
            Wire.Node reference = proof.child(1).requireShape(
                    "kernel-replay", 7, 5).child(4).requireShape(
                            "source-construction", 4, 0);
            if (reference.scalar(0).equals(constructionKind)) {
                return proof.scalar(0);
            }
        }
        throw new AssertionError(
                "fixture has no " + constructionKind + " replay reference");
    }

    private static String canonicalOrbitForReplay(
            Wire.Node root,
            String replayId) {
        for (Wire.Node canonical : root.child(9).children()) {
            if (canonical.child(0).requireShape(
                    "source-replay-ref", 1, 0).scalar(0).equals(replayId)) {
                return canonical.scalar(1);
            }
        }
        throw new AssertionError("replay has no canonical record");
    }

    private static Wire.Node proof(Wire.Node root, String proofId) {
        for (Wire.Node proof : root.child(5).children()) {
            if (proof.scalar(0).equals(proofId)) {
                return proof;
            }
        }
        throw new AssertionError("unknown proof " + proofId);
    }

    private static String differentTermId(byte[] source, String excluded) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        for (Wire.Node term : root.child(4).children()) {
            if (!term.scalar(0).equals(excluded)) {
                return term.scalar(0);
            }
        }
        throw new AssertionError("fixture has no alternate term");
    }

    @FunctionalInterface
    private interface ReplayMutation {
        Wire.Node apply(Wire.Node proof, Wire.Node payload);
    }

    private static byte[] crossSourceConstructionSubstitution(
            byte[] source,
            byte[] alternate,
            boolean copyAlternateReference) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        Wire.Node alternateRoot = Codec.decode(alternate, Limits.defaults());
        Wire.Node originalRecord = semanticRecord(root, 1);
        Wire.Node alternateRecord = semanticRecord(alternateRoot, 1);
        check(originalRecord.scalar(5).equals(alternateRecord.scalar(5)),
                "cross-source fixture targets must be identical");
        check(originalRecord.scalar(2).equals(alternateRecord.scalar(2))
                        && originalRecord.scalar(3).equals(alternateRecord.scalar(3)),
                "cross-source fixture operator and path must be identical");
        check(!originalRecord.scalar(0).equals(alternateRecord.scalar(0)),
                "cross-source fixture certificate keys must differ");
        check(!originalRecord.scalar(6).equals(alternateRecord.scalar(6)),
                "cross-source fixture left endpoints must differ");
        check(!originalRecord.scalar(8).equals(alternateRecord.scalar(8)),
                "cross-source fixture occurrence owners must differ");
        Wire.Node alternateReference = constructionReference(
                alternateRoot, alternateRecord.scalar(0));

        Wire.Node manifest = root.child(1);
        Wire.Node vocabulary = manifest.child(1);
        Wire.Node evidence = vocabulary.child(3);
        Wire.Node section = evidence.child(1);
        Wire.Node changedEvidence = replaceChild(
                evidence,
                1,
                Wire.node(section.tag(), section.scalars(), List.of(alternateRecord)));
        Wire.Node changedVocabulary = replaceChild(vocabulary, 3, changedEvidence);
        Wire.Node changedManifest = Wire.node(
                manifest.tag(),
                List.of(manifest.scalar(0), Wire.contentId(changedVocabulary)),
                List.of(manifest.child(0), changedVocabulary));
        root = replaceChild(root, 1, changedManifest);

        List<Wire.Node> proofs = new ArrayList<>();
        boolean changed = false;
        for (Wire.Node proof : root.child(5).children()) {
            Wire.Node next = proof;
            if ("KERNEL_REPLAY".equals(proof.scalar(1))) {
                Wire.Node payload = proof.child(1);
                Wire.Node reference = payload.child(4);
                if ("FLAT".equals(reference.scalar(0))
                        && originalRecord.scalar(0).equals(reference.scalar(1))) {
                    Wire.Node substituted = copyAlternateReference
                            ? alternateReference
                            : Wire.leaf(
                                    "source-construction",
                                    "FLAT",
                                    alternateRecord.scalar(0),
                                    reference.scalar(2),
                                    reference.scalar(3));
                    next = replaceChild(
                            proof, 1, replaceChild(payload, 4, substituted));
                    changed = true;
                }
            }
            proofs.add(next);
        }
        if (!changed) {
            throw new AssertionError(
                    "flat fixture has no populated construction reference");
        }
        root = replaceChild(root, 5, Wire.node("proofs", sorted(proofs)));
        return Codec.encode(closeContentIds(root));
    }

    private static Wire.Node constructionReference(
            Wire.Node root,
            String evidenceKey) {
        for (Wire.Node proof : root.child(5).children()) {
            if (!"KERNEL_REPLAY".equals(proof.scalar(1))) {
                continue;
            }
            Wire.Node reference = proof.child(1).child(4);
            if (evidenceKey.equals(reference.scalar(1))) {
                return reference;
            }
        }
        throw new AssertionError("bundle has no matching construction reference");
    }

    private static byte[] crossOrbitBinderReferenceSwap(byte[] source) {
        Wire.Node root = Codec.decode(source, Limits.defaults());
        List<Wire.Node> proofs = new ArrayList<>(root.child(5).children());
        List<Integer> owners = new ArrayList<>();
        List<Wire.Node> references = new ArrayList<>();
        for (int index = 0; index < proofs.size(); index++) {
            Wire.Node proof = proofs.get(index);
            if (!"CANONICAL_ORBIT".equals(proof.scalar(1))) {
                continue;
            }
            Wire.Node local = proof.child(1).child(3);
            if (local.children().size() == 1) {
                owners.add(index);
                references.add(local.child(0));
            }
        }
        if (owners.size() != 2
                || references.get(0).scalar(0).equals(references.get(1).scalar(0))) {
            throw new AssertionError(
                    "dual binder fixture must expose two distinct orbit references");
        }
        for (int index = 0; index < 2; index++) {
            Wire.Node proof = proofs.get(owners.get(index));
            Wire.Node payload = proof.child(1);
            Wire.Node swapped = Wire.node(
                    "binder-occurrence-refs",
                    List.of(references.get(1 - index)));
            proofs.set(
                    owners.get(index),
                    replaceChild(proof, 1, replaceChild(payload, 3, swapped)));
        }
        root = replaceChild(root, 5, Wire.node("proofs", sorted(proofs)));
        return Codec.encode(closeContentIds(root));
    }

    private static Wire.Node semanticRecord(Wire.Node root, int sectionIndex) {
        Wire.Node section = root.child(1).child(1).child(3).child(sectionIndex);
        if (section.children().size() != 1) {
            throw new AssertionError(
                    "fixture section " + section.tag()
                            + " must contain exactly one semantic-evidence record; found "
                            + section.children().size());
        }
        return section.child(0);
    }

    private static Wire.Node closeContentIds(Wire.Node root) {
        for (int pass = 0; pass < 32; pass++) {
            java.util.Map<String, String> ids = new java.util.HashMap<>();
            List<Wire.Node> sections = new ArrayList<>(root.children());
            for (int index : CONTENT_TABLES) {
                Wire.Node section = sections.get(index);
                List<Wire.Node> records = new ArrayList<>();
                for (Wire.Node record : section.children()) {
                    Wire.Node rewritten = rewriteIds(record, ids);
                    Wire.Node identified = Bundle.withContentId(
                            rewritten.tag(),
                            rewritten.scalars().subList(1, rewritten.scalars().size()),
                            rewritten.children());
                    ids.put(record.scalar(0), identified.scalar(0));
                    records.add(identified);
                }
                sections.set(index, Wire.node(section.tag(), sorted(records)));
            }
            Wire.Node next = rewriteIds(
                    Wire.node(root.tag(), root.scalars(), sections), ids);
            List<Wire.Node> finalSections = new ArrayList<>(next.children());
            Wire.Node vocabulary = finalSections.get(1).child(1);
            finalSections.set(1, Wire.node(
                    "manifest",
                    List.of(finalSections.get(1).scalar(0), Wire.contentId(vocabulary)),
                    List.of(finalSections.get(1).child(0), vocabulary)));
            next = Wire.node(next.tag(), next.scalars(), finalSections);
            if (java.util.Arrays.equals(Codec.encode(next), Codec.encode(root))) {
                return next;
            }
            root = next;
        }
        throw new AssertionError("content-ID closure did not converge");
    }

    private static Wire.Node rewriteIds(
            Wire.Node node,
            java.util.Map<String, String> ids) {
        return Wire.node(
                node.tag(),
                node.scalars().stream()
                        .map(value -> ids.getOrDefault(value, value)).toList(),
                node.children().stream()
                        .map(child -> rewriteIds(child, ids)).toList());
    }

    private static List<Wire.Node> sorted(List<Wire.Node> nodes) {
        nodes.sort(java.util.Comparator.comparing(node -> node.scalar(0)));
        return nodes;
    }

    private static Wire.Node replaceChild(
            Wire.Node parent,
            int index,
            Wire.Node replacement) {
        List<Wire.Node> children = new ArrayList<>(parent.children());
        children.set(index, replacement);
        return Wire.node(parent.tag(), parent.scalars(), children);
    }

    private static Bundle decode(byte[] bytes) {
        return Bundle.parse(Codec.decode(bytes, Limits.defaults()));
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
