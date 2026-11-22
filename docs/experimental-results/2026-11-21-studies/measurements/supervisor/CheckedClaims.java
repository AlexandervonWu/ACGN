import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.function.Function;
import org.json.JSONObject;

// Operational adapter: the tagged implementation still selects, solves, and reports every claim.
public class CheckedClaims {
    static final Class<?> CHECK = type("is.fivefivefive.CanDis.EGraphSemanticSoundnessCheck");
    static Class<?> type(String name) {
        try { return Class.forName(name); } catch (Exception e) { throw new IllegalStateException(e); }
    }
    static Class<?> nested(String name) { return type(CHECK.getName()+"$"+name); }
    static Object call(Class<?> c,Object self,String name,Class<?>[] types,Object... args) throws Exception {
        Method m=c.getDeclaredMethod(name,types); m.setAccessible(true); return m.invoke(self,args);
    }
    static Object field(Class<?> c,Object self,String name) throws Exception {
        Field f=c.getDeclaredField(name); f.setAccessible(true); return f.get(self);
    }
    record Job(String id, Callable<Object> solve) {}
    record Active(String id,long start) {}
    @FunctionalInterface interface Inspect { String failure(Object result) throws Exception; }

    static List<Object> window(List<Job> jobs,int workers,Inspect inspect,Path incident,String phase,int later) throws Exception {
        ExecutorService pool=Executors.newFixedThreadPool(workers);
        CompletionService<Object> queue=new ExecutorCompletionService<>(pool);
        Map<Future<Object>,Active> active=new LinkedHashMap<>();
        Map<String,Object> accepted=new HashMap<>();
        int submitted=0;
        String selected="";
        try {
            while(accepted.size()<jobs.size()){
                while(submitted<jobs.size() && active.size()<workers){
                    Job j=jobs.get(submitted++); long start=System.nanoTime();
                    active.put(queue.submit(j.solve()),new Active(j.id(),start));
                }
                Future<Object> f=queue.poll(100,TimeUnit.MILLISECONDS);
                for(var a:active.values()) if(System.nanoTime()-a.start()>60_000_000_000L){
                    selected=a.id(); throw new IllegalStateException("FILE_OVER_60_SECONDS");
                }
                if(f==null)continue;
                selected=active.get(f).id(); Object result=f.get();String problem=inspect.failure(result);
                if(problem!=null)throw new IllegalStateException(problem);
                if(accepted.put(selected,result)!=null)throw new IllegalStateException("DUPLICATE_JOB");
                active.remove(f);
            }
        } catch(Throwable failure) {
            var report=new JSONObject().put("phase",phase).put("id",selected).put("error",failure.toString())
                .put("total",jobs.size()).put("submitted",submitted).put("accepted",accepted.size())
                .put("neverSubmitted",jobs.size()-submitted).put("laterPhaseUnattempted",later)
                .put("outstandingAtStop",active.values().stream().map(Active::id).toList());
            Files.writeString(incident,report.toString(2),StandardOpenOption.CREATE_NEW);
            throw failure;
        } finally {active.keySet().forEach(f->f.cancel(true));pool.shutdownNow();}
        return jobs.stream().map(j->accepted.get(j.id())).toList();
    }
    static void execute(String[] args) throws Exception {
        Class<?> opt=nested("Options"),claim=nested("Claim"),task=nested("VerifyTask"),probe=nested("ProbeResult");
        Object o=call(opt,null,"parse",new Class[]{String[].class},(Object)args);
        Path input=(Path)field(opt,o,"inputRoot"),out=(Path)field(opt,o,"resultsRoot");
        var map=(Map<?,?>)call(CHECK,null,"loadClaims",new Class[]{opt},o);
        Constructor<?> make=task.getDeclaredConstructor(Path.class,claim);make.setAccessible(true);
        List<Job> jobs=new ArrayList<>(),probes=new ArrayList<>();
        for(Object obj:map.values()){
            String id=field(claim,obj,"relativePath").toString();
            jobs.add(new Job(id,()->((Callable<?>)make.newInstance(input,obj)).call()));
        }
        jobs.sort(Comparator.comparing(Job::id));
        try(var paths=Files.list((Path)field(CHECK,null,"PROBE_ROOT"))){
            for(Path file:paths.filter(p->p.getFileName().toString().endsWith(".als")).sorted().toList())
                probes.add(new Job(file.toString(),()->call(CHECK,null,"runProbe",new Class[]{Path.class},file)));
        }
        Path incident=out.resolve("incident.json");
        var rows=window(jobs,(int)field(opt,o,"threads"),r->{
            Object outcome=field(r.getClass(),r,"outcome");
            return outcome.toString().equals("NO_COUNTEREXAMPLE")?null:call(r.getClass(),r,"toJson",new Class[]{}).toString();
        },incident,"claims",probes.size());
        var controls=window(probes,1,r->(boolean)call(CHECK,null,"isProbeViolation",new Class[]{probe},r)
            ?call(probe,r,"toJson",new Class[]{}).toString():null,incident,"targeted probes",0);
        for(String n:List.of("semantic_soundness.json","semantic_counterexamples.csv","semantic_soundness.md"))
            if(Files.exists(out.resolve(n)))throw new FileAlreadyExistsException(out.resolve(n).toString());
        call(CHECK,null,"writeJson",new Class[]{Path.class,opt,List.class,List.class},out.resolve("semantic_soundness.json"),o,rows,controls);
        call(CHECK,null,"writeCounterexamples",new Class[]{Path.class,List.class},out.resolve("semantic_counterexamples.csv"),rows);
        call(CHECK,null,"writeMarkdown",new Class[]{Path.class,opt,List.class,List.class},out.resolve("semantic_soundness.md"),o,rows,controls);
    }
    public static void main(String[] args){
        try {execute(args);} catch(Throwable e){e.printStackTrace();System.exit(1);}
    }
}
