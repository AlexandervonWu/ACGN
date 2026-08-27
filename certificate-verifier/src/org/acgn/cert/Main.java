package org.acgn.cert;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Minimal command-line interface for the standalone verifier jar. */
public final class Main {
    private Main() {
    }

    public static void main(String[] args) {
        int status;
        try {
            status = run(args);
        } catch (IllegalArgumentException | IOException exception) {
            System.err.println("usage error: " + exception.getMessage());
            status = 64;
        }
        if (status != 0) {
            System.exit(status);
        }
    }

    static int run(String[] args) throws IOException {
        Arguments parsed = Arguments.parse(args);
        if (parsed.inspectBundle != null) {
            CallOccurrenceCommitment commitment = CallOccurrenceCommitment.inspect(
                    Files.readAllBytes(parsed.inspectBundle), Limits.defaults());
            System.out.println(commitment.assignment());
            return 0;
        }
        IndependentVerifier verifier = new IndependentVerifier();
        VerificationPolicy policy = new VerificationPolicy(
                java.util.Set.of(parsed.theoryDigest),
                Limits.defaults(),
                parsed.callOccurrenceCommitments);
        VerificationResult result;
        if (parsed.profile == Profile.PAIR) {
            result = verifier.verifyPair(
                    Files.readAllBytes(parsed.files.get(0)),
                    Files.readAllBytes(parsed.files.get(1)),
                    policy);
        } else {
            result = verifier.verify(
                    Files.readAllBytes(parsed.files.get(0)), parsed.profile, policy);
        }
        System.out.println("{\"outcome\":\"" + result.outcome()
                + "\",\"code\":\"" + result.code()
                + "\",\"detail\":\"" + escape(result.detail()) + "\"}");
        return switch (result.outcome()) {
            case VERIFIED -> 0;
            case REJECTED -> 2;
            case UNCHECKABLE -> 3;
        };
    }

    private static String escape(String value) {
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private static final class Arguments {
        private final Profile profile;
        private final String theoryDigest;
        private final List<Path> files;
        private final Map<String, String> callOccurrenceCommitments;
        private final Path inspectBundle;

        private Arguments(
                Profile profile,
                String theoryDigest,
                List<Path> files,
                Map<String, String> callOccurrenceCommitments,
                Path inspectBundle) {
            this.profile = profile;
            this.theoryDigest = theoryDigest;
            this.files = files;
            this.callOccurrenceCommitments = callOccurrenceCommitments;
            this.inspectBundle = inspectBundle;
        }

        private static Arguments parse(String[] args) {
            Profile profile = Profile.FULL;
            String digest = null;
            List<Path> files = new ArrayList<>();
            Map<String, String> commitments = new LinkedHashMap<>();
            Path inspectBundle = null;
            for (int index = 0; index < args.length; index++) {
                switch (args[index]) {
                    case "--profile" -> {
                        if (++index >= args.length) {
                            throw new IllegalArgumentException("--profile needs a value");
                        }
                        profile = Profile.valueOf(args[index].toUpperCase());
                    }
                    case "--theory-digest" -> {
                        if (++index >= args.length) {
                            throw new IllegalArgumentException(
                                    "--theory-digest needs a value");
                        }
                        digest = args[index];
                    }
                    case "--call-occurrence-commitment" -> {
                        if (++index >= args.length) {
                            throw new IllegalArgumentException(
                                    "--call-occurrence-commitment needs a value");
                        }
                        CallOccurrenceCommitment commitment =
                                CallOccurrenceCommitment.parseAssignment(args[index]);
                        String prior = commitments.putIfAbsent(
                                commitment.subjectDigest(),
                                commitment.occurrenceDigest());
                        if (prior != null
                                && !prior.equals(commitment.occurrenceDigest())) {
                            throw new IllegalArgumentException(
                                    "conflicting CALL occurrence commitments");
                        }
                    }
                    case "--inspect-call-occurrences" -> {
                        if (++index >= args.length || inspectBundle != null) {
                            throw new IllegalArgumentException(
                                    "--inspect-call-occurrences needs one bundle");
                        }
                        inspectBundle = Path.of(args[index]);
                    }
                    default -> files.add(Path.of(args[index]));
                }
            }
            if (inspectBundle != null) {
                if (digest != null || !files.isEmpty() || !commitments.isEmpty()) {
                    throw new IllegalArgumentException(
                            "CALL occurrence inspection cannot be combined with verification");
                }
                return new Arguments(
                        profile, null, List.of(), Map.of(), inspectBundle);
            }
            if (digest == null || digest.isEmpty()) {
                throw new IllegalArgumentException("--theory-digest is required");
            }
            int expectedFiles = profile == Profile.PAIR ? 2 : 1;
            if (files.size() != expectedFiles) {
                throw new IllegalArgumentException(
                        profile + " requires " + expectedFiles + " bundle file(s)");
            }
            return new Arguments(
                    profile,
                    digest,
                    List.copyOf(files),
                    Map.copyOf(commitments),
                    null);
        }
    }
}
