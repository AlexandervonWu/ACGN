package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/** Retained proof object for one deterministic {@code canon_G} rebuild step. */
public final class RebuildCongruenceCertificate extends TypedEqualityCertificate {
    private final CanonicalizationResult result;

    private RebuildCongruenceCertificate(
            CanonicalizationResult result,
            List<? extends TypedEqualityCertificate> premises) {
        super(
                CertificateCategory.FORWARD_CONGRUENCE,
                TypedCertificateEndpoint.node(result.source()),
                TypedCertificateEndpoint.node(result.shape().node().act(
                        result.ambientTransport())),
                premises,
                Collections.singletonList(result.structuralKey()));
        this.result = result;
        verifyLocal();
    }

    static TypedEqualityCertificate create(
            TypedSlottedPortEGraph graph,
            CanonicalizationResult result) {
        Objects.requireNonNull(graph, "graph");
        Objects.requireNonNull(result, "result");
        if (!result.verifyWitness(graph)) {
            throw new IllegalArgumentException(
                    "A rebuild certificate requires a replayable canonicalization witness");
        }
        TypedCertificateEndpoint left = TypedCertificateEndpoint.node(result.source());
        TypedCertificateEndpoint right = TypedCertificateEndpoint.node(
                result.shape().node().act(result.ambientTransport()));
        if (left.equals(right)) {
            return EqualityCertificates.reflexive(left);
        }

        List<TypedEqualityCertificate> premises = new ArrayList<>();
        for (TypedFindResult find : result.trace().findResults()) {
            premises.add(find.parentCertificate());
            TypedSymmetryGroup group = graph.eclass(
                    find.leaderInvocation().eclass().id()).symmetryGroup();
            premises.addAll(group.generatorCertificates());
        }
        for (ContainerLawDeclaration declaration
                : result.source().operator().containerLaws().values()) {
            premises.addAll(declaration.certificates().values());
        }
        collectBinderCertificates(result.source().ports(), premises);
        RebuildCongruenceCertificate certificate =
                new RebuildCongruenceCertificate(result, premises);
        CertificateVerifier.verify(certificate);
        return certificate;
    }

    private static void collectBinderCertificates(
            List<? extends PortValue> ports,
            List<TypedEqualityCertificate> target) {
        for (PortValue port : ports) {
            if (port instanceof BindBlockPort) {
                BinderBlockDescriptor descriptor = ((BindBlockPort) port)
                        .schema().descriptor();
                target.addAll(descriptor.automorphisms().generatorCertificates());
                collectBinderCertificates(
                        Collections.singletonList(((BindBlockPort) port).body()), target);
            } else if (port instanceof BindPort) {
                collectBinderCertificates(
                        Collections.singletonList(((BindPort) port).body()), target);
            } else if (port instanceof SeqPort) {
                collectBinderCertificates(((SeqPort) port).elements(), target);
            } else if (port instanceof BagPort) {
                collectBinderCertificates(((BagPort) port).occurrences(), target);
            } else if (port instanceof SetPort) {
                collectBinderCertificates(((SetPort) port).elements(), target);
            }
        }
    }

    public CanonicalizationResult result() {
        return result;
    }

    @Override
    void verifyLocal() {
        if (!leftEndpoint().equals(TypedCertificateEndpoint.node(result.source()))
                || !rightEndpoint().equals(TypedCertificateEndpoint.node(
                        result.shape().node().act(result.ambientTransport())))
                || leftEndpoint().equals(rightEndpoint())) {
            throw new IllegalStateException("Malformed rebuild-congruence certificate");
        }
    }
}
