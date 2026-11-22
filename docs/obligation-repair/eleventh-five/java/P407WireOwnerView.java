package org.acgn.cert;

import org.acgn.cert.Bundle;
import org.acgn.cert.Codec;
import org.acgn.cert.Limits;
import org.acgn.cert.Wire;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.concurrent.TimeUnit;

public final class P407WireOwnerView {
    private static void require(boolean ok,String message){if(!ok)throw new AssertionError(message);}
    static final String THEORY="0901e1ee21d8f82c128ebc93f0e5f1e0b421f7a6833ec16cf5473df3b222b147";
    record Key(String owner,String term) {}
    record Use(String child,String qualifiedShape) {}
    record View(Wire.Node tree,Set<String> referenced) {}

    private static View inspect(String id,Bundle bundle,Set<String> active) {
        if(!active.add(id))throw new AssertionError("cyclic wire term");
        var term=Objects.requireNonNull(bundle.terms().get(id));
        var children=new ArrayList<Wire.Node>(); var refs=new TreeSet<String>();
        for(var entry:term.children()) {
            entry.requireShape("term-ref",1,0);
            var child=inspect(entry.scalar(0),bundle,active);
            children.add(child.tree);refs.addAll(child.referenced);
        }
        if(term.scalar(1).equals("INVOKE")) {
            var witness=Objects.requireNonNull(bundle.witnesses().get(term.scalar(5)));
            refs.add(witness.scalar(2));
        }
        active.remove(id);
        return new View(Wire.node("term-key/"+term.scalar(1),term.scalars().subList(2,term.scalars().size()),children),refs);
    }

    public static List<String> verify(Path fixtures,Path jar) throws Exception {
        var fixture=fixtures.resolve("parent-path-a.acgncert");
        // This existing public writer fixture has two nullary terms, a parent edge, and a wrapper, with no source CALL.
        var source="parent-path-fixture".getBytes(java.nio.charset.StandardCharsets.UTF_8);
        var hash=HexFormat.of().formatHex(java.security.MessageDigest.getInstance("SHA-256").digest(source));
        var subject=CallOccurrenceCommitment.subjectDigest("fixture/parent-path",hash);
        var pin=subject+"="+CallOccurrenceCommitment.digest(subject,List.of());
        var policy=new ProcessBuilder(Path.of(System.getProperty("java.home"),"bin","java").toString(),
                "-Xmx256m","-XX:ActiveProcessorCount=1","-jar",jar.toString(),
                "--profile","FULL","--theory-digest",THEORY,"--call-occurrence-commitment",pin,fixture.toString()).redirectErrorStream(true).start();
        if(!policy.waitFor(30,TimeUnit.SECONDS)){policy.destroyForcibly().waitFor();throw new AssertionError("standalone FULL timeout");}
        String receipt=new String(policy.getInputStream().readAllBytes(),java.nio.charset.StandardCharsets.UTF_8);
        require(policy.exitValue()==0 && receipt.contains("\"outcome\":\"VERIFIED\""),"parent FULL "+receipt);
        var bundle=Bundle.parse(Codec.decode(Files.readAllBytes(fixture),Limits.defaults()));
        var seen=new HashMap<Key,String>();var byTerm=new HashMap<String,Set<String>>();
        int useCount=0, snapshots=0, quiescent=0;
        for(var snapshot:bundle.snapshots().values()) {
            var wanted=new HashSet<Use>();var owners=new TreeMap<String,Set<String>>();
            for(var row:snapshot.child(2).children()) {
                String owner=row.scalar(1),term=row.scalar(2);
                String expected="shape/"+Wire.contentId(Wire.leaf("producer-shape-id",owner,term));
                require(expected.equals(row.scalar(0)),"owner and term wire identity");
                var prior=seen.putIfAbsent(new Key(owner,term),expected);
                require(prior==null || prior.equals(expected),"stable wire identity");
                byTerm.computeIfAbsent(term,ignored->new TreeSet<>()).add(owner);
                var derived=inspect(term,bundle,new HashSet<>());
                owners.computeIfAbsent(Wire.contentId(derived.tree),ignored->new TreeSet<>()).add(owner);
                for(var child:derived.referenced)wanted.add(new Use(child,expected));
            }
            var actualUses=new HashSet<Use>();
            for(var use:snapshot.child(4).children())
                require(actualUses.add(new Use(use.scalar(0),use.scalar(1))),"duplicate wire reverse use");
            require(actualUses.equals(wanted),"wire term-derived reverse-use census");
            var actualHash=new TreeMap<String,Set<String>>();
            for(var h:snapshot.child(3).children())
                require(actualHash.computeIfAbsent(h.scalar(0),ignored->new TreeSet<>()).add(h.scalar(1)),"duplicate wire owner");
            if (snapshot.scalar(2).equals("QUIESCENT")) {
                require(owners.equals(actualHash), "wire hash owner census");
                quiescent++;
            }
            useCount+=wanted.size();snapshots++;
        }
        long shared=byTerm.values().stream().filter(owners->owners.size()>1).count();
        require(quiescent>0 && shared>0 && useCount>0 && seen.size()==new HashSet<>(seen.values()).size(),"real across-owner wire observations");
        return List.of("wire-full\tVERIFIED","wire-snapshots\t"+snapshots,"wire-quiescent-snapshots\t"+quiescent,
                "wire-owner-pairs\t"+seen.size(),
                "wire-shared-terms-across-history\t"+shared,"wire-reverse-uses\t"+useCount);
    }
}
