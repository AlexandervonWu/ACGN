package org.acgn.cert;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Validates the static fixture authorities against complete producer theories. */
public final class TrustedTheoryPinsTest {
    private static final String EMPTY_PIN = "fixture-empty-theory-v1";
    private static final String PARENT_PIN = "fixture-parent-path-theory-v1";
    private static final int FIELD_COUNT = 19;
    private static int checks;

    private TrustedTheoryPinsTest() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 4) {
            throw new IllegalArgumentException(
                    "usage: TrustedTheoryPinsTest <pins.tsv> <nullary> <slot> <parent>");
        }
        Map<String, Pin> pins = readPins(Path.of(args[0]));
        check(pins.keySet().equals(java.util.Set.of(EMPTY_PIN, PARENT_PIN)),
                "the fixture authority contains exactly the two declared theory shapes");

        Pin empty = pins.get(EMPTY_PIN);
        Pin parent = pins.get(PARENT_PIN);
        check(empty.authority.equals("TEST_ONLY")
                        && parent.authority.equals("TEST_ONLY_INPUT_SPECIFIC"),
                "both authorities are explicitly test-only");
        check(empty.reviewStatus.equals("PENDING_AUTHOR_REVIEW")
                        && parent.reviewStatus.equals("PENDING_AUTHOR_REVIEW"),
                "both fixture pins retain pending author status");
        check(!empty.digest.equals(parent.digest),
                "the empty and input-specific ground theories have separate pins");
        assertRenderingCollision();

        byte[] nullaryBytes = Files.readAllBytes(Path.of(args[1]));
        byte[] slotBytes = Files.readAllBytes(Path.of(args[2]));
        byte[] parentBytes = Files.readAllBytes(Path.of(args[3]));
        assertTheory(decode(nullaryBytes), empty, "nullary");
        assertTheory(decode(slotBytes), empty, "slot-only");
        assertTheory(decode(parentBytes), parent, "parent-path");

        IndependentVerifier verifier = new IndependentVerifier();
        VerificationResult wrongPin = verifier.verify(
                nullaryBytes, Profile.FULL, VerificationPolicy.trust(parent.digest));
        check(wrongPin.outcome() == Outcome.REJECTED
                        && wrongPin.code() == FailureCode.UNTRUSTED_THEORY,
                "the wrong static pin is REJECTED / UNTRUSTED_THEORY");

        System.out.println("TrustedTheoryPinsTest: " + checks + " checks passed");
    }

    private static void assertTheory(Bundle bundle, Pin pin, String label) {
        check(bundle.theoryDigest().equals(pin.digest),
                label + " bundle matches its statically selected digest");
        check(bundle.theory().scalars().equals(List.of(
                        pin.theoryId, pin.ruleSet, pin.vocabularyPolicy)),
                label + " bundle matches the pinned theory identity");
        Wire.Node axioms = bundle.theory().child(0).requireTag("axioms");
        check(axioms.children().size() == pin.axiomCount,
                label + " bundle has the complete pinned axiom count");
        if (pin.axiomCount == 0) {
            check(pin.axiomId.equals("-")
                            && pin.originKind.equals("-")
                            && pin.leftEndpointCodecBase64.equals("-")
                            && pin.rightEndpointCodecBase64.equals("-"),
                    label + " empty theory ledger contains no hidden axiom fields");
            return;
        }
        check(pin.axiomCount == 1,
                "the current fixture ledger represents its one admitted ground axiom");
        Wire.Node axiom = axioms.child(0).requireShape("axiom", 1, 5);
        check(axiom.scalar(0).equals(pin.axiomId),
                label + " axiom ID matches the ledger");
        String originBoundId = "axiom/" + Wire.contentId(Wire.node(
                "origin-derived-axiom-id",
                List.of(pin.originKind, pin.originSource,
                        pin.originDeclaration, pin.originOrdinal),
                List.of()));
        check(originBoundId.equals(pin.axiomId),
                label + " stable origin cryptographically determines the axiom ID");
        check(Arrays.equals(
                        Codec.encodeNode(axiom.child(0)),
                        decodeEndpoint(pin.leftEndpointCodecBase64, "left"))
                        && Arrays.equals(
                        Codec.encodeNode(axiom.child(1)),
                        decodeEndpoint(pin.rightEndpointCodecBase64, "right")),
                label + " axiom endpoints match the canonical byte ledger");
        check(axiom.child(2).children().isEmpty()
                        && axiom.child(3).children().isEmpty()
                        && axiom.child(4).children().isEmpty(),
                label + " axiom has no unlisted variables or side conditions");
        check(pin.typeVariables.equals("[]")
                        && pin.termVariables.equals("[]")
                        && pin.sideConditions.equals("[]"),
                label + " ledger exposes all empty variable and condition sections");
    }

    private static Bundle decode(byte[] bytes) {
        return Bundle.parse(Codec.decode(bytes, Limits.defaults()));
    }

    private static byte[] decodeEndpoint(String encoded, String side) {
        try {
            return Base64.getDecoder().decode(encoded);
        } catch (IllegalArgumentException exception) {
            throw new AssertionError(side + " endpoint is not canonical Base64", exception);
        }
    }

    private static void assertRenderingCollision() {
        Wire.Node oneScalar = Wire.node("collision", List.of("left, right"), List.of());
        Wire.Node twoScalars = Wire.node("collision", List.of("left", "right"), List.of());
        check(!oneScalar.equals(twoScalars),
                "the rendering-collision fixtures are distinct valid nodes");
        check(oneScalar.toString().equals(twoScalars.toString()),
                "distinct nodes can share the legacy human rendering");
        check(!Arrays.equals(
                        Codec.encodeNode(oneScalar), Codec.encodeNode(twoScalars)),
                "canonical node encodings preserve scalar-array boundaries");
    }

    private static Map<String, Pin> readPins(Path path) throws Exception {
        List<String> lines = Files.readAllLines(path, StandardCharsets.UTF_8);
        check(!lines.isEmpty(), "the static theory-pin manifest is nonempty");
        String expectedHeader = String.join("\t", List.of(
                "pin_id", "authority", "review_status", "fixture_scope",
                "theory_id", "rule_set", "vocabulary_policy", "theory_digest",
                "axiom_count", "axiom_id", "origin_kind", "origin_source",
                "origin_declaration", "origin_ordinal",
                "left_endpoint_codec_base64", "right_endpoint_codec_base64",
                "type_variables", "term_variables",
                "side_conditions"));
        check(lines.get(0).equals(expectedHeader),
                "the static theory-pin manifest has the exact ledger schema");
        Map<String, Pin> result = new LinkedHashMap<>();
        for (int index = 1; index < lines.size(); index++) {
            if (lines.get(index).isBlank()) {
                continue;
            }
            String[] fields = lines.get(index).split("\t", -1);
            check(fields.length == FIELD_COUNT,
                    "theory-pin row " + index + " has every ledger field");
            Pin pin = new Pin(
                    fields[0], fields[1], fields[2], fields[3], fields[4],
                    fields[5], fields[6], fields[7], Integer.parseInt(fields[8]),
                    fields[9], fields[10], fields[11], fields[12], fields[13],
                    fields[14], fields[15], fields[16], fields[17], fields[18]);
            check(result.put(pin.id, pin) == null,
                    "theory-pin IDs are unique");
        }
        return Map.copyOf(result);
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private record Pin(
            String id,
            String authority,
            String reviewStatus,
            String fixtureScope,
            String theoryId,
            String ruleSet,
            String vocabularyPolicy,
            String digest,
            int axiomCount,
            String axiomId,
            String originKind,
            String originSource,
            String originDeclaration,
            String originOrdinal,
            String leftEndpointCodecBase64,
            String rightEndpointCodecBase64,
            String typeVariables,
            String termVariables,
            String sideConditions) {
    }
}
