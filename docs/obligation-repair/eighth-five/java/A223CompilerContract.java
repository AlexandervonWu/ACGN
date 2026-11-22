package is.fivefivefive.CanDis.theory;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.net.URI;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.concurrent.TimeUnit;
import javax.lang.model.element.*;
import javax.tools.*;

/** Frozen javac method-body and resolved-call boundary of the ARROW model.
 * Also reads the operations of the actual ARROW branch through javac trees. */
final class A223CompilerContract {
    private static final String PKG="is.fivefivefive.CanDis.theory.";
    private static final List<String> TYPES=List.of("DependentTypeDag","DependentChainApplication","GraphType","DependentColumnEvidence");
    private static final Set<String> SELECT=Set.of(
            "DependentTypeDag#combine/3","DependentTypeDag#normalize/1","DependentTypeDag#productType/1",
            "DependentTypeDag#productSubtypeOrEqual/2","DependentTypeDag#preferAuthenticated/2",
            "DependentTypeDag#relationFamilyType/1","DependentTypeDag#<init>/2","DependentTypeDag#empty/1",
            "DependentTypeDag#requireCompatibleAuthority/2","DependentTypeDag.ChainCombination#<init>/4",
            "DependentTypeDag.CombinationCase#<init>/5","DependentChainApplication#<init>/3",
            "GraphType#compareTo/1","GraphType#compareNullable/2","DependentColumnEvidence#isAdmittedAtomicColumn/1",
            "DependentColumnEvidence#requireAtomicColumn/2","DependentColumnEvidence#<init>/3");
    private static final String PIN="0c6606038ea16d82893c9238d83de3e80e09cbb111e99f94611a9acaefb16a50";
    private static final List<String> PROGRAM=List.of("outer:left:ascending-index","lookup:left:outer",
            "inner:right:ascending-index","lookup:right:inner","guard:ARROW","addAll:leftProduct","addAll:rightProduct","add:product",
            "new:CombinationCase:leftIndex:rightIndex:CombinationDecision.ARROW_PRODUCT:null:product","add:case","continue",
            "admission:positive-uniform-width-and-compatible-authority","group:exact-product-key-prefer-authenticated-duplicate",
            "prune:all-other-products-strict-coordinate-subtype","sort:by-structural-product-type",
            "type-order:int-before-nominal-UTF16-then-lex-columns","freeze:rows-and-ordered-column-evidence",
            "return:typed-empty-or-normalized-products-and-cases","source:append-left-leaves-then-right-leaves");

    private static void add(MessageDigest d,String s) {
        byte[] bytes=s.getBytes(StandardCharsets.UTF_8);
        d.update(ByteBuffer.allocate(4).putInt(bytes.length).array());d.update(bytes);
    }
    private static String symbol(Element e) {
        if(e instanceof ExecutableElement m && m.getEnclosingElement() instanceof TypeElement owner)
            return owner.getQualifiedName()+"#"+m.getSimpleName()+":"+m.asType();
        throw new IllegalArgumentException("unresolved production call");
    }
    private static String args(MethodInvocationTree call) {
        return call.getArguments().stream().map(Object::toString).reduce((a,b)->a+":"+b).orElse("");
    }
    private static List<String> arrowProgram(MethodTree combine) {
        var out=new ArrayList<String>();
        var loops=combine.getBody().getStatements().stream().filter(ForLoopTree.class::isInstance)
                .map(ForLoopTree.class::cast).toList();
        if(loops.size()!=1) throw new IllegalArgumentException("outer loop count");
        var outer=counted(loops.get(0),"left","outer",out);
        if(outer.size()!=2 || !(outer.get(1) instanceof ForLoopTree innerLoop))throw new IllegalArgumentException("loop nesting");
        var inner=counted(innerLoop,"right","inner",out);
        if(!(inner.get(1) instanceof IfTree branch) || !branch.getCondition().toString().equals("(kind == DependentChainKind.ARROW)")
                || branch.getElseStatement()!=null)throw new IllegalArgumentException("ARROW_BRANCH");
        out.add("guard:ARROW");
        for(var s:((BlockTree)branch.getThenStatement()).getStatements()) {
            if(s instanceof VariableTree v && v.getName().contentEquals("product")) continue;
            if(s instanceof ContinueTree c && c.getLabel()==null) {out.add("continue");continue;}
            if(!(s instanceof ExpressionStatementTree e && e.getExpression() instanceof MethodInvocationTree call))
                throw new IllegalArgumentException("ARROW_BRANCH");
            switch(call.getMethodSelect().toString()) {
                case "product.addAll" -> out.add("addAll:"+args(call));
                case "products.add" -> out.add("add:"+args(call));
                case "cases.add" -> {
                    if(!(call.getArguments().get(0) instanceof NewClassTree n)) throw new IllegalArgumentException("ARROW_CASE");
                    out.add("new:"+n.getIdentifier()+":"+String.join(":",n.getArguments().stream().map(Object::toString).toList()));
                    out.add("add:case");
                }
                default -> throw new IllegalArgumentException("ARROW_BRANCH");
            }
        }
        return out;
    }
    private static List<? extends StatementTree> counted(ForLoopTree loop,String side,String role,List<String> out) {
        String i=side+"Index";
        if(loop.getInitializer().size()!=1 || !(loop.getInitializer().get(0) instanceof VariableTree init)
                || !init.getName().contentEquals(i) || !init.getType().toString().equals("int")
                || !init.getInitializer().toString().equals("0")
                || !(loop.getCondition() instanceof BinaryTree bound) || bound.getKind()!=Tree.Kind.LESS_THAN
                || !bound.getLeftOperand().toString().equals(i)
                || !bound.getRightOperand().toString().equals(side+".alternatives.size()")
                || loop.getUpdate().size()!=1 || !loop.getUpdate().get(0).getExpression().toString().equals(i+"++"))
            throw new IllegalArgumentException("counted loop "+side);
        out.add(role+":"+side+":ascending-index");
        var body=((BlockTree)loop.getStatement()).getStatements();
        if(body.size()<2 || !(body.get(0) instanceof VariableTree read) || !read.getName().contentEquals(side+"Product")
                || !read.getInitializer().toString().equals(side+".alternatives.get("+i+")"))
            throw new IllegalArgumentException("row lookup "+side);
        out.add("lookup:"+side+":"+role);
        return body;
    }
    private record Unit(String stem,String text) {}
    private record Contract(String digest,List<String> program) {}
    private static Contract compile(List<Unit> units) throws Exception {
        var compiler=ToolProvider.getSystemJavaCompiler();
        var diagnostics=new DiagnosticCollector<JavaFileObject>();
        try(var manager=compiler.getStandardFileManager(diagnostics,Locale.ROOT,StandardCharsets.UTF_8)) {
            var sources=new ArrayList<JavaFileObject>();
            for(var unit:units) sources.add(new SimpleJavaFileObject(URI.create("string:///"+PKG.replace('.','/')+unit.stem()+".java"),JavaFileObject.Kind.SOURCE) {
                @Override public CharSequence getCharContent(boolean ignored) {return unit.text();}
            });
            var task=(JavacTask)compiler.getTask(null,manager,diagnostics,
                    List.of("--release","17","-proc:none","-classpath",System.getProperty("java.class.path")),null,sources);
            var classes=new ArrayList<CompilationUnitTree>();task.parse().forEach(classes::add);task.analyze();
            for(var d:diagnostics.getDiagnostics()) if(d.getKind()==Diagnostic.Kind.ERROR) throw new IllegalStateException(d.toString());
            var trees=Trees.instance(task);var bodies=new TreeMap<String,List<String>>();var methods=new TreeMap<String,MethodTree>();var program=new ArrayList<String>();
            for(var unit:classes) new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree method,Void nil) {
                    if(!(trees.getElement(getCurrentPath()) instanceof ExecutableElement m))return super.visitMethod(method,nil);
                    var owner=((TypeElement)m.getEnclosingElement()).getQualifiedName().toString();
                    String key=owner.substring(PKG.length())+"#"+m.getSimpleName()+"/"+m.getParameters().size();
                    if(!SELECT.contains(key))return super.visitMethod(method,nil);
                    var rows=new ArrayList<String>();rows.add(symbol(m));rows.add(method.getBody().toString());
                    methods.put(key,method);
                    if(bodies.put(key,rows)!=null)throw new IllegalArgumentException("ambiguous target "+key);
                    if(key.equals("DependentTypeDag#combine/3"))program.addAll(arrowProgram(method));
                    new TreePathScanner<Void,Void>() {
                        @Override public Void visitNewClass(NewClassTree n,Void u) {
                            rows.add("new "+symbol(trees.getElement(getCurrentPath())));return super.visitNewClass(n,u);
                        }
                        @Override public Void visitMethodInvocation(MethodInvocationTree n,Void u) {
                            rows.add("call "+symbol(trees.getElement(getCurrentPath())));return super.visitMethodInvocation(n,u);
                        }
                        @Override public Void visitMemberReference(MemberReferenceTree n,Void u) {
                            rows.add("ref "+symbol(trees.getElement(getCurrentPath())));return super.visitMemberReference(n,u);
                        }
                    }.scan(new TreePath(getCurrentPath(),method.getBody()),null);
                    return null;
                }
            }.scan(unit,null);
            if(!bodies.keySet().equals(SELECT))throw new IllegalArgumentException("incomplete method inventory "+bodies.keySet());
            program.addAll(A223AdmissionCode.read(methods));
            var hash=MessageDigest.getInstance("SHA-256");
            for(var entry:bodies.entrySet()) {add(hash,entry.getKey());for(String value:entry.getValue())add(hash,value);}
            return new Contract(HexFormat.of().formatHex(hash.digest()),List.copyOf(program));
        }
    }
    private static List<Unit> mutant(List<Unit> original,String target,String old,String replacement) {
        var copy=new ArrayList<Unit>();
        for(var u:original) {
            if(!target.equals(u.stem())) {copy.add(u);continue;}
            if(u.text().indexOf(old)<0 || u.text().indexOf(old)!=u.text().lastIndexOf(old))throw new AssertionError("nonunique mutation");
            copy.add(new Unit(u.stem(),u.text().replace(old,replacement)));
        }
        return copy;
    }
    private static void runLean(Path input,boolean accept) throws Exception {
        String lean=Objects.requireNonNull(System.getenv("ACGN_EIGHTH_LEAN"),"audited Lean executable");
        var log=Files.createTempFile("a223-lean-",".log");
        try {
            var proc=new ProcessBuilder(lean,"--run",System.getenv().getOrDefault("ACGN_EIGHTH_PROOF",
                    "docs/section3-repair-audit/formal/A223ArrowFamilies.lean"),input.toString())
                    .redirectErrorStream(true).redirectOutput(log.toFile()).start();
            if(!proc.waitFor(45,TimeUnit.SECONDS)) {proc.destroyForcibly();proc.waitFor();throw new AssertionError("Lean decoder timeout");}
            String got=Files.readString(log);
            String expected=accept?"A223 compiler program verified":"A223 compiler program rejected";
            if(proc.exitValue()!=(accept?0:1) || !got.stripTrailing().endsWith(expected))throw new AssertionError(got);
        } finally { Files.deleteIfExists(log); }
    }
    static String verify(Path output) throws Exception {
        var files=new ArrayList<Unit>();
        for(String name:TYPES) files.add(new Unit(name,Files.readString(Path.of("src",PKG.replace('.','/'),name+".java"))));
        var real=compile(files);
        if(!real.program().equals(PROGRAM))throw new AssertionError("unexpected ARROW instructions "+real.program());
        if(!real.digest().equals(PIN))throw new AssertionError("unregistered A2-23 compiler digest "+real.digest());
        var reversed=compile(mutant(files,"DependentTypeDag","product.addAll(leftProduct);\n                    product.addAll(rightProduct);",
                "product.addAll(rightProduct);\n                    product.addAll(leftProduct);"));
        var unsorted=compile(mutant(files,"DependentTypeDag","antichain.sort(Comparator.comparing(DependentTypeDag::productType));",
                "Collections.reverse(antichain);"));
        if(reversed.program().equals(PROGRAM) || reversed.digest().equals(PIN) || unsorted.digest().equals(PIN)
                || unsorted.program().equals(PROGRAM))throw new AssertionError("changed producer was accepted");
        Files.write(output,real.program());runLean(output,true);
        Path altered=Files.createTempFile("a223-reversed-",".txt");
        try { Files.write(altered,reversed.program());runLean(altered,false);
              Files.write(altered,unsorted.program());runLean(altered,false); }
        finally { Files.deleteIfExists(altered); }
        return SELECT.size()+" methods, 2 semantic mutations rejected";
    }
}
