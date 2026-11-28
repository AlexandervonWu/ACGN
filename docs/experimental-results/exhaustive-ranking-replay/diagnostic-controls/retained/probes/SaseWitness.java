package is.fivefivefive.CanDis.core;
import java.nio.file.*;
import java.util.*;
import org.json.*;
import is.fivefivefive.CanDis.*;
public class SaseWitness {
    @SuppressWarnings("unchecked")
    public static void main(String[] args) throws Exception {
        var k=RetainedPaidCompletionTest.class;
        var p=k.getDeclaredMethod("prepare",String.class,String[].class);p.setAccessible(true);
        var f=k.getDeclaredMethod("forms",Canonical.Prepared.class);f.setAccessible(true);
        var guards=k.getDeclaredMethod("guards",List.class);guards.setAccessible(true);
        Path output=Path.of(args[0]);
        var source=Files.readString(DeclarationOrbitShorterReplayTest.SOURCE);
        List<Canonical.Prepared> pair=(List<Canonical.Prepared>)p.invoke(null,source,new String[]{"inv14","inv14c"});
        try {guards.invoke(null,pair);System.out.println("ALL GUARDS PASSED");}
        catch(java.lang.reflect.InvocationTargetException e){System.out.println("GUARD FAILURE "+e.getCause());e.getCause().printStackTrace();}
        for(int i=0;i<2;i++){
            var a=pair.get(i);var b=pair.get(1-i);
            List<NormalForm> aa=(List<NormalForm>)f.invoke(null,a);List<NormalForm> bb=(List<NormalForm>)f.invoke(null,b);
            var av=aa.get(0); var bv=bb.get(0);
            System.out.printf("%d direct=%s supplemental=%s owners=%d/%d seeds=%d/%d%n",i,FastPaidDeclarationAlignment.supportsPair(aa,bb),FastPaidDeclarationAlignment.supportsSupplementalPair(aa,bb),FastNestedPaidScope.retainedExistentialOwners(av).size(),FastNestedPaidScope.retainedExistentialOwners(bv).size(),av.getLocalQuantiVars().size(),bv.getLocalQuantiVars().size());
            var method=NativeOperationComparison.class.getDeclaredMethod("compare",Canonical.Prepared.class,Canonical.Prepared.class,CanonicalAlloyPipeline.Prepared.class,CanonicalAlloyPipeline.Prepared.class);method.setAccessible(true);
            var cmp=(NativeOperationComparison.Result)method.invoke(null,a,b,CanonicalAlloyPipeline.prepare(a),CanonicalAlloyPipeline.prepare(b));
            Files.writeString(output.resolve("sase-"+i+".json"),cmp.evidence().toString());
        }
    }
}
