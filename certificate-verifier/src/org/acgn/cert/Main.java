package org.acgn.cert;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

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
        IndependentVerifier verifier = new IndependentVerifier();
        VerificationPolicy policy = VerificationPolicy.trust(parsed.theoryDigest);
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

        private Arguments(Profile profile, String theoryDigest, List<Path> files) {
            this.profile = profile;
            this.theoryDigest = theoryDigest;
            this.files = files;
        }

        private static Arguments parse(String[] args) {
            Profile profile = Profile.FULL;
            String digest = null;
            List<Path> files = new ArrayList<>();
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
                    default -> files.add(Path.of(args[index]));
                }
            }
            if (digest == null || digest.isEmpty()) {
                throw new IllegalArgumentException("--theory-digest is required");
            }
            int expectedFiles = profile == Profile.PAIR ? 2 : 1;
            if (files.size() != expectedFiles) {
                throw new IllegalArgumentException(
                        profile + " requires " + expectedFiles + " bundle file(s)");
            }
            return new Arguments(profile, digest, List.copyOf(files));
        }
    }
}
