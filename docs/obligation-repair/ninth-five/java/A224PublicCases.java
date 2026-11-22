package org.acgn.cert;

import is.fivefivefive.CanDis.theory.A224ExactFixture;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;

/** Ordinary public verifier API, with intact bundles from CertificateBundleWriterTest. */
public final class A224PublicCases {
    private record Fixture(String filename,String id,String content,boolean needsHierarchy) {}
    private static final String THEORY = "9acf2f195da2b489ddf1537bc42c933b569f35390e248682802240a713334f6c";
    public static void main(String[] args) throws Exception {
        if(args.length!=2)throw new IllegalArgumentException("A224PublicCases COVERAGE_DIR NEW_OUTPUT_TSV");
        var rows=new ArrayList<>(List.of("fixture\tcomparison\toutcome\tcode"));
        for(var f : List.of(
                new Fixture("fresh-exact",A224ExactFixture.IDENTIFIER,A224ExactFixture.CONTENT,false),
                new Fixture("relation-columns","fixture/dependent-join","(s.u).v",true),
                new Fixture("relation-family","fixture/dependent-family-join","((A->A)+(B->B)).((A->C)+(B->C))",true),
                new Fixture("relation-empty","fixture/dependent-empty-join","Owner.f.(B->C)",true),
                new Fixture("relation-empty-interior","fixture/dependent-empty-interior-join","(A->B).none.(C->D)",false))) {
            byte[] bytes=f.filename().equals("fresh-exact") ? A224ExactFixture.export() : Files.readAllBytes(Path.of(args[0]).resolve(f.filename()+"-a.acgncert"));
            String hash=HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(f.content().getBytes(StandardCharsets.UTF_8)));
            String subject=CallOccurrenceCommitment.subjectDigest(f.id(),hash);
            var pin=new CallOccurrenceCommitment(subject,CallOccurrenceCommitment.digest(subject,List.of()));
            var bundle=Bundle.parse(Codec.decode(bytes,Limits.defaults()));
            if(!bundle.metadata().inputSha256().equals(hash)||!bundle.metadata().inputIdentifier().equals(f.id()))
                throw new AssertionError("different fixture "+f.filename());
            var result=new IndependentVerifier().verify(bytes,Profile.FULL,VerificationPolicy.trust(THEORY).withCallOccurrenceCommitment(pin));
            if(f.needsHierarchy() ? result.outcome()!=Outcome.UNCHECKABLE || result.code()!=FailureCode.MISSING_EVIDENCE
                    || !result.detail().contains("independently pinned source-hierarchy authority")
                    : result.outcome()!=Outcome.VERIFIED || result.code()!=FailureCode.NONE)
                throw new AssertionError(f.filename()+" "+result);
            rows.add(String.join("\t",f.filename(),"ordinary-FULL",result.outcome().name(),result.code().name()));
        }
        Files.write(Path.of(args[1]),rows,StandardOpenOption.CREATE_NEW);
        System.out.println("A224 public cases passed: "+(rows.size()-1));
    }
}
