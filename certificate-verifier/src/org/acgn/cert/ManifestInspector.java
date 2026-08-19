package org.acgn.cert;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

/** Strictly decodes a bundle and prints its untrusted pinned-theory digest. */
public final class ManifestInspector {
    private ManifestInspector() {
    }

    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            throw new IllegalArgumentException(
                    "usage: ManifestInspector <bundle.acgncert>");
        }
        byte[] encoded = Files.readAllBytes(Path.of(args[0]));
        Wire.Node root = Codec.decode(encoded, Limits.defaults());
        System.out.println(Bundle.parse(root).theoryDigest());
    }
}
