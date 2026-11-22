package is.fivefivefive.CanDis.core.egraph;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.Func;
import edu.mit.csail.sdg.parser.*;
import is.fivefivefive.CanDis.EGraphAblationStudy;
import is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter;
import parser.ast.nodes.*;
import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;

public final class P511LexicalTransportTest {
    private record Example(String name,String params,String test,String oracle,boolean fold) {
        String source() {
            return "pred "+name+params+" { "+test+" }\npred "+name+"C"+params+" { "+oracle+" }\n";
        }
    }
    private record Arm(String name, String cli, boolean typed, AblationEngine engine) {}
    private static void check(boolean test,String why) { if (!test) throw new AssertionError(why); }

    private static List<Example> examples() {
        var rows = new ArrayList<Example>();
        for (String syntax : List.of("bare","one","some","set","lone")) {
            String params = "[x: "+(syntax.equals("bare") ? "A" : syntax+" A")+"]";
            boolean positive = List.of("bare","one","some").contains(syntax);
            rows.add(new Example("in"+syntax,params,"x in none","some none",positive));
            rows.add(new Example("notin"+syntax,params,"x not in none","no none",positive));
        }
        rows.add(new Example("overshadow","[x: one A]","all x: set A | x in none","all x: set A | some none",false));
        rows.add(new Example("inshadow","[x: set A]","all x: one A | x in none","all x: one A | some none",true));
        rows.add(new Example("retainsouter","[x: some A]","all y: set A | x not in none","all y: set A | no none",true));
        rows.add(new Example("letalias","[x: one A]","let alias = x | alias in none","some none",true));
        rows.add(new Example("letshadow","[x: one A, y: set A]","let x = y | x in none","some none",false));
        rows.add(new Example("block","[x: set A]","all a,b: one A | all c: one A | a in none or c in none",
                "all a,b: one A | all c: one A | some none",true));
        rows.add(new Example("dependent","[x: one A]","all y: one x | y in none","all y: one x | some none",true));
        return rows;
    }

    private static List<Arm> arms() throws Exception {
        Class<?> cls = Class.forName(EGraphAblationStudy.class.getName()+"$Engine");
        Method factory = cls.getDeclaredMethod("newEngine");
        Field id = cls.getDeclaredField("id");
        factory.setAccessible(true); id.setAccessible(true);
        Map<String,Class<?>> raw = Map.of("RAW",RawEGraph.class,"RAW_DEBRUIJN",RawDeBruijnEGraph.class,
                "EGGLOG",JavaEgglog.class,"EGGLOG_DEBRUIJN",JavaEgglogDeBruijn.class,
                "SLOTTED",SlottedEGraph.class,"SLOTTED_TYPED",SlottedEGraph.class);
        var results = new ArrayList<Arm>();
        var other = new TreeSet<String>();
        for (Object value : cls.getEnumConstants()) {
            String name = ((Enum<?>)value).name();
            if (!raw.containsKey(name)) { other.add(name); continue; }
            AblationEngine actual = (AblationEngine)factory.invoke(value);
            check(actual.getClass()==raw.get(name),"Production dispatch "+name);
            results.add(new Arm(name,(String)id.get(value),name.equals("SLOTTED_TYPED"),actual));
        }
        check(results.size()==6 && other.equals(Set.of("CANONICAL","TYPED_SLOTTED_PORT")),"Engine census changed");
        return results;
    }

    private static boolean productionFile(Arm arm, Path file) throws Exception {
        Class<?> opts = Class.forName(EGraphAblationStudy.class.getName()+"$Options");
        Method parse = opts.getDeclaredMethod("parse",String[].class);
        parse.setAccessible(true);
        Object options = parse.invoke(null,(Object)new String[]{"--engine",arm.cli,"--input",file.getParent().toString(),"--threads","1"});
        Method evaluate = EGraphAblationStudy.class.getDeclaredMethod("processFile",opts,Path.class);
        evaluate.setAccessible(true);
        Object result = evaluate.invoke(null,options,file);
        for (String field : List.of("skipped","error","equivalent")) {
            Field attr = result.getClass().getDeclaredField(field); attr.setAccessible(true);
            Object value = attr.get(result);
            if (field.equals("equivalent")) return (Boolean)value;
            check(field.equals("error") ? value==null || value.equals("") : Boolean.FALSE.equals(value),
                    file+" "+arm.name+" "+field+"="+value);
        }
        throw new AssertionError("missing comparison");
    }

    private static void storageReads(AlloyTerm node,List<String> output) {
        if (node.head().equals("BF/IN") || node.head().equals("BF/NOT_IN")) {
            AlloyTerm read = node.children().get(0);
            while (read.head().equals("UE/NOOP")) read = read.children().get(0);
            check(read.isVariable() && read.binding()==null,"De Bruijn storage gained a declaration token");
            output.add(read.atom());
        }
        for (AlloyTerm child : node.children()) storageReads(child,output);
    }

    private static AlloyTerm synthetic(AlloyTerm x) {
        if (x.isVariable() && !x.slotType().isEmpty()) return AlloyTerm.typedVariable(x.atom(), x.slotType());
        return AlloyTerm.of(x.head(),x.atom(),x.children().stream().map(P511LexicalTransportTest::synthetic).toList());
    }

    private static Map<String,Predicate> predicates(CompModule mod) {
        var result = new TreeMap<String,Predicate>();
        for (var p : new ModelUnit(null,mod).getPredDeclList()) result.put(p.getName(),p);
        return result;
    }

    private static boolean contains(AlloyTerm term,String head) {
        return term.head().equals(head) || term.children().stream().anyMatch(child -> contains(child,head));
    }

    /** The uncapped API only admits synthetic experiments under an external process deadline. */
    private static void syntheticRepresentations() {
        var x = AlloyTerm.typedVariable("x","A");
        var domain = AlloyTerm.node("UE/ONE",AlloyTerm.atom("SIG","A"));
        var declaration = AlloyTerm.node("DECL/ParamDecl/disj=false/var=false",x,domain);
        for (boolean typed : List.of(false,true)) {
            for (String head : List.of("BF/IN","BF/NOT_IN")) {
                var membership = AlloyTerm.node(head,x,AlloyTerm.atom("CONST","none"));
                var input = AlloyTerm.node("PREDICATE",declaration,membership);
                var result = new SlottedEGraph(typed).representUnbounded(input);
                check(contains(result.frontier(),head),"Synthetic uncapped frontier "+head+" typed="+typed);
            }
        }
        System.out.println("P511 synthetic uncapped frontiers=4 guarded=4");
    }

    private static void checkSyntheticWorker() throws Exception {
        String executable = Path.of(System.getProperty("java.home"),"bin","java").toString();
        var p = new ProcessBuilder(executable,"-Xmx96m","-cp",System.getProperty("java.class.path"),
                P511LexicalTransportTest.class.getName(),"--synthetic-uncapped").redirectErrorStream(true).start();
        try {
            if (!p.waitFor(15,java.util.concurrent.TimeUnit.SECONDS)) throw new AssertionError("Uncapped deadline");
            String messages = new String(p.getInputStream().readAllBytes(),java.nio.charset.StandardCharsets.UTF_8);
            check(p.exitValue()==0 && messages.lines().toList().equals(List.of("P511 synthetic uncapped frontiers=4 guarded=4")),
                    "Synthetic uncapped helper "+messages);
        } finally { if (p.isAlive()) p.destroyForcibly(); }
    }

    public static void main(String[] args) throws Exception {
        if (Arrays.equals(args,new String[]{"--synthetic-uncapped"})) {
            syntheticRepresentations();
            return;
        }
        if (args.length!=2) throw new IllegalArgumentException("sourceRoot freshOutput.tsv");
        Path root = Path.of(args[0]), output = Path.of(args[1]).toAbsolutePath();
        if (Files.exists(output)) throw new IllegalArgumentException("Fresh output required: "+output);
        var examples = examples();
        var source = new StringBuilder("module scope\nsig A {}\n");
        for (Example e : examples) source.append(e.source());
        var mod = CompUtil.parseEverything_fromString(A4Reporter.NOP,source.toString());
        Map<String,P511SourceScope> facts = new HashMap<>();
        for (Func f : mod.getAllFunc())
            for (Example e : examples) if (f.label.equals("this/"+e.name)) facts.put(e.name,P511SourceScope.resolve(f));
        check(facts.size()==examples.size(),"Source roots");
        var selected = predicates(mod);
        var foreign = predicates(CompUtil.parseEverything_fromString(A4Reporter.NOP, source.toString()));
        var out = new ArrayList<String>();
        out.add("case\tmethod\tfrontier\toriginal-coordinates\tresult");
        var traces = new ArrayList<String>();
        traces.add("case\tengine\toperation\tdomains\tread-slot\tbefore-key\tbefore-scope\tafter-key\tafter-scope\tsource-guard");
        var methods = arms();
        Path tmp = Files.createTempDirectory(output.getParent(),"p511-input-");
        try {
            for (Arm arm : methods) {
                for (Example e : examples) {
                    AlloyTerm left = AlloyAstTermAdapter.fromPredicate(selected.get(e.name),arm.typed);
                    AlloyTerm right = AlloyAstTermAdapter.fromPredicate(selected.get(e.name+"C"),arm.typed);
                    P511SourceScope original = facts.get(e.name);
                    var slots = original.bind(left);
                    original.frontier(left,slots);
                    boolean slotted = arm.engine instanceof SlottedEGraph;
                    AlloyTerm frontier = slotted ? SlottedEGraph.alphaRepresentative(arm.typed?left:left.eraseSlotTypes()) : left;
                    var reads = original.frontier(frontier,slots);
                    P511Coordinates.pair(traces,e.name,arm.name,original,slots,left,frontier);
                    if (e.name.equals("letalias") || e.name.equals("letshadow")) {
                        var mode = arm.name.startsWith("RAW") ? AlloyRewriteSystem.ArityMode.FIXED
                                : AlloyRewriteSystem.ArityMode.VARIADIC;
                        var first = slotted ? AlloyRewriteSystem.rewriteSlottedOnce(frontier)
                                : AlloyRewriteSystem.rewriteOnce(frontier,mode);
                        P511Coordinates.substitutedRhs(original,slots,first.term);
                    }
                    boolean result = arm.engine.compare(left,right).equivalent;
                    check(result==e.fold,"Public compare "+arm.name+" "+e);
                    if (List.of("inone","notinlone","overshadow").contains(e.name)) {
                        if (arm.name.equals("EGGLOG"))
                            check(JavaEgglog.normalForm(left).equals(JavaEgglog.normalForm(right))==e.fold,
                                    "Egglog public fixed point "+e.name);
                        if (arm.name.equals("SLOTTED"))
                            check(SlottedEGraph.normalForm(left).equals(SlottedEGraph.normalForm(right))==e.fold,
                                    "Slotted public fixed point "+e.name);
                    }
                    String representation = slotted ? "RENAMED" : "NAMED";
                    out.add(e.name+"\t"+arm.name+"\t"+representation+"\t"+String.join(",",reads)+"\t"+(result?"FOLD":"GUARDED"));
                    if (arm.name.endsWith("DEBRUIJN") && List.of("inone","retainsouter","overshadow").contains(e.name)) {
                        List<String> stored = new ArrayList<>();
                        storageReads(DeBruijnVariables.encode(left),stored);
                        String index = e.name.equals("retainsouter") ? "@db:1" : "@db:0";
                        check(stored.equals(List.of(index)),"Stored lexical distance "+arm.name+" "+e.name);
                        out.add(e.name+"-stored\t"+arm.name+"\tDE_BRUIJN\t"+index+"\tNO_TOKEN");
                    }
                    if (e.name.equals("inone") || e.name.equals("overshadow")) {
                        Path file = tmp.resolve(e.name+".als");
                        Files.writeString(file,"module "+e.name+"\nsig A {}\n"+e.source());
                        check(productionFile(arm,file)==e.fold,"production file "+arm.name+" "+e.name);
                        Files.delete(file);
                        out.add(e.name+"-file\t"+arm.name+"\tSTUDY\t-\t"+(e.fold?"FOLD":"GUARDED"));
                    }
                    if (e.name.equals("inone") || e.name.equals("notinsome")) {
                        check(!arm.engine.compare(synthetic(left),synthetic(right)).equivalent,"source-free "+arm.name+" "+e.name);
                        AlloyTerm other = AlloyAstTermAdapter.fromPredicate(foreign.get(e.name),arm.typed);
                        AlloyTerm mixed = AlloyTerm.node(left.head(),left.children().get(0),other.children().get(1));
                        check(!arm.engine.compare(mixed,right).equivalent,"wrong root "+arm.name+" "+e.name);
                        out.add(e.name+"-label\t"+arm.name+"\tSYNTHETIC\t-\tGUARDED");
                        out.add(e.name+"-owner\t"+arm.name+"\tFOREIGN\t-\tGUARDED");
                    }
                }
            }
        } finally {
            try (var paths=Files.list(tmp)) { for (Path p: paths.toList()) Files.delete(p); }
            Files.delete(tmp);
        }
        checkSyntheticWorker();
        var census = P511Entrypoints.inspect(root);
        out.add("source\tJAVAC\t"+census.methods()+"\t"+census.symbols()+"\t"+census.hash());
        Files.write(output.resolveSibling("p511-frontiers.tsv"),traces,java.nio.charset.StandardCharsets.UTF_8,StandardOpenOption.CREATE_NEW);
        Files.write(output,out,java.nio.charset.StandardCharsets.UTF_8,StandardOpenOption.CREATE_NEW);
        System.out.println("P511LexicalTransportTest PASS methods="+methods.size()+" cases="+examples.size()+" rows="+(out.size()-1));
    }
}
