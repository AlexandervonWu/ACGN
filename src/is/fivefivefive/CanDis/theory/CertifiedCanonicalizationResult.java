package is.fivefivefive.CanDis.theory;

import java.util.Arrays;
import java.util.Objects;

/** Complete coherent-prefix result {@code (K,p,sigma,iota,omega,xi,d^w)}. */
public final class CertifiedCanonicalizationResult {
    private final CanonicalizationResult structural;
    private final KernelReplayCertificate kernelCertificate;
    private final StructuralKey structuralKey;

    CertifiedCanonicalizationResult(
            CanonicalizationResult structural,
            KernelReplayCertificate kernelCertificate) {
        this.structural = Objects.requireNonNull(structural, "structural");
        this.kernelCertificate = Objects.requireNonNull(
                kernelCertificate, "kernelCertificate");
        if (!structural.leaderKernel().equals(kernelCertificate.leaderKernel())) {
            throw new IllegalArgumentException(
                    "The structural and dependent canonicalization records disagree");
        }
        CertificateVerifier.verify(kernelCertificate);
        this.structuralKey = StructuralKey.branch(
                "certified-canonicalization-result",
                Arrays.asList(
                        structural.structuralKey(),
                        kernelCertificate.structuralKey()));
    }

    public CanonicalizationResult structural() {
        return structural;
    }

    public TypedENode kernel() {
        return structural.kernel();
    }

    public CanonicalShape shape() {
        return structural.shape();
    }

    public TypedRenaming sigma() {
        return structural.sigma();
    }

    public TypedEmbedding iota() {
        return structural.iota();
    }

    public TypedEmbedding omega() {
        return structural.omega();
    }

    public LeaderKernelTrace xi() {
        return structural.xi();
    }

    public KernelReplayCertificate d() {
        return kernelCertificate;
    }

    public StructuralKey structuralKey() {
        return structuralKey;
    }

    @Override
    public String toString() {
        return structural + " with " + kernelCertificate;
    }
}
