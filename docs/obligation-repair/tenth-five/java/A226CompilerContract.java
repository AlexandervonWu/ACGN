package is.fivefivefive.CanDis;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import javax.lang.model.element.ExecutableElement;
import javax.tools.*;

/** Exact source effects and resolved callees from the parser, adapter, DAG and independent equality gates. */
public final class A226CompilerContract {
    private static final String PIN = "1cf3422585bab93741d15f539e991a93b147aeeae46c11df000a753cf4e85dcf";
    private static final String THEORY = "is.fivefivefive.CanDis.theory.";
    private static final String BUILDER = THEORY + "TheoryAlloyAdapter.Builder#";
    private static final String DAG = THEORY + "DependentTypeDag#";
    private static final String COL = THEORY + "DependentColumnEvidence#";
    private static final String EXACT = "is.fivefivefive.ACGN.alloy.ExactAlloyType#";
    private static final Map<String,List<String>> REQUIRED = Map.ofEntries(
        Map.entry(BUILDER + "dependentTypeDagForSource/2", List.of(
            "source.getExactAlloyType()", "ExactAlloyType.Kind.RELATION", "ExactAlloyType.Kind.EMPTY_RELATION",
            "ExactAlloyType.Kind.INT", "thrownewDependentChainTheory.UnsupportedFlattening(", "DependentChainTheory.relationViewFromStoredType(GraphType.INT)", "AlloyTypeBridge.dependentTypeDag(exactType)",
            "source.getOpcode()!=Opcode.PLUS&&source.getOpcode()!=Opcode.INTERSECT", "returnparserDag;",
            "source.getEClass().getId()", "if(!activeTypeClasses.add(classId))", "thrownewIllegalStateException(",
            "for(EClassRefchildRef:source.getChildClasses())", "childRef.canonical().getEClass().getRepresentative()",
            "(exactType.kind()==ExactAlloyType.Kind.INT)!=(operandType.kind()==ExactAlloyType.Kind.INT)", "thrownewDependentChainTheory.UnsupportedFlattening(",
            "operands.add(dependentTypeDagForSource(child,activeTypeClasses))", "if(operands.isEmpty())",
            "thrownewDependentChainTheory.UnsupportedFlattening(", "operands.size()==1?operands.get(0)",
            "source.getOpcode()==Opcode.PLUS?DependentTypeDag.union(operands):DependentTypeDag.intersection(operands)",
            "if(!derived.sameOccurrenceEvidenceAs(parserDag))", "thrownewIllegalStateException(", "returnderived;", "finally{activeTypeClasses.remove(classId);}")),
        Map.entry(BUILDER + "dependentChainInput/7", List.of("buildOperand(", "child.getExactAlloyType()", "sourceSetOperation=child.getOpcode()==Opcode.PLUS||child.getOpcode()==Opcode.INTERSECT", "ExactAlloyType.Kind.RELATION",
            "ExactAlloyType.Kind.EMPTY_RELATION", "sourceSetOperation||relationFamily?dependentTypeDagForSource(child,newHashSet<>())",
            "DependentTypeDag.fromRelationFamilyType(relationType)", "newDependentChainLeaf(leaf,typeDag,exactType)",
            "catch(DependentChainTheory.UnsupportedFlattening|DependentBoundaryCorrespondence.UnsupportedCorrespondenceexception)",
            "thrownewUnsupportedDependentChain(exception)")),
        Map.entry(BUILDER + "constructDependentChainOperand/5", List.of("dependentChainApplication(",
            "catch(UnsupportedDependentChain|DependentChainTheory.UnsupportedFlatteningexception)", "if(kind==DependentChainKind.JOIN)",
            "returnconstructGuardedJoin(", "returnnull;", "requireDependentResultProof(", "constructionSources.recordDependentChain(",
            "TypedENode.constructDependentChainCertified(", "dependentChainConstructions.add(")),
        Map.entry(BUILDER + "constructGuardedJoin/5", List.of("guardedJoinTree(", "GuardedJoinCertificate.normalized(tree)",
            "catch(IllegalArgumentExceptionunsupported)", "returnnull;", "realizeGuardedJoin(normalized)", "GuardedJoinCertificate.create(",
            "constructionSources.recordGuardedJoin(", "guardedJoinConstructions.add(")),
        Map.entry(BUILDER + "buildOperand/5", List.of("node.getOpcode()==Opcode.JOIN", "node.getOpcode()==Opcode.ARROW",
            "constructDependentChainOperand(", "if(result!=null)", "returnresult;", "node.hasFlatLicense()", "constructNode(node,context,operands)")),
        Map.entry(BUILDER + "constructNode/3", List.of("outputType(source)", "source.requireAdmittedArity()", "for(OnePortoperand:typedOperands)",
            "schemas.add(operand.schema())", "ports.add(operand)", "OperatorDeclaration.monomorphic(", "TypedENode.construct(")),
        Map.entry(THEORY + "TheoryAlloyAdapter#outputType/1", List.of("node.getExactAlloyType()!=null", "AlloyTypeBridge.graphType(node.getExactAlloyType())", "thrownewIllegalStateException(")),
        Map.entry(DAG + "sameOccurrenceEvidenceAs/1", List.of("alternatives.size()!=other.alternatives.size()",
            "!relationType.equals(other.relationType)", "!Objects.equals(commonAncestorType,other.commonAncestorType)", "left.size()!=right.size()",
            "!left.get(column).sameOccurrenceEvidenceAs(right.get(column))", "returntrue;")),
        Map.entry(COL + "sameOccurrenceEvidenceAs/1", List.of("other==null||!equals(other)", "returnfalse;",
            "returnparserAuthoritySource==other.parserAuthoritySource;", "parserAuthoritySource.sharesParserModuleAuthorityWith(other.parserAuthoritySource)")),
        Map.entry(EXACT + "sharesParserModuleAuthorityWith/1", List.of("parserModuleAuthority!=null", "parserModuleAuthority==other.parserModuleAuthority")),
        Map.entry(DAG + "empty/1", List.of("newDependentTypeDag(List.of(),arity)")),
        Map.entry(DAG + "union/1", List.of("operands.size()<2", "arity!=checked.arity()", "alternatives.addAll(checked.alternatives())",
            "alternatives.isEmpty()?empty(arity):newDependentTypeDag(alternatives)")),
        Map.entry(DAG + "intersection/1", List.of("operands.size()<2", "operands.get(0)", "for(intindex=1;index<operands.size();index++)",
            "result=intersectPair(", "returnresult;")),
        Map.entry(DAG + "intersectPair/2", List.of("left.arity()!=right.arity()", "requireCompatibleAuthority(",
            "if(left.alternatives.isEmpty()||right.alternatives.isEmpty())", "returnempty(left.arity())",
            "DependentBoundaryCorrespondence.derive(", "products.isEmpty()?empty(left.arity()):newDependentTypeDag(products)")),
        Map.entry(THEORY + "AlloyTypeBridge#dependentTypeDag/1", List.of("DependentTypeDag.")));

    private static final List<String> STREAM_ORDER=List.of(BUILDER+"dependentTypeDagForSource/2",BUILDER+"constructDependentChainOperand/5",BUILDER+"constructGuardedJoin/5",BUILDER+"constructNode/3");
    private static final Map<String,String> EFFECT = Map.ofEntries(
            Map.entry("thrownewDependentChainTheory.UnsupportedFlattening(","unsupported"),
            Map.entry("AlloyTypeBridge.dependentTypeDag(exactType)","read-parser-family"),
            Map.entry("DependentChainTheory.relationViewFromStoredType(GraphType.INT)","lift-builtin-int"),
            Map.entry("(exactType.kind()==ExactAlloyType.Kind.INT)!=(operandType.kind()==ExactAlloyType.Kind.INT)","primitive-domain-check"),
            Map.entry("returnparserDag;","atomic-return"),
            Map.entry("if(!activeTypeClasses.add(classId))","guard-active-class"),
            Map.entry("operands.add(dependentTypeDagForSource(child,activeTypeClasses))","visit-each-canonical-child"),
            Map.entry("operands.size()==1?operands.get(0)","singleton-identity"),
            Map.entry("source.getOpcode()==Opcode.PLUS?DependentTypeDag.union(operands):DependentTypeDag.intersection(operands)","choose-union-or-intersection"),
            Map.entry("if(!derived.sameOccurrenceEvidenceAs(parserDag))","compare-complete-occurrence-evidence"),
            Map.entry("thrownewIllegalStateException(","hard-error"), Map.entry("returnderived;","return-derived"),
            Map.entry("finally{activeTypeClasses.remove(classId);}","restore-path"),
            Map.entry("returnconstructGuardedJoin(","try-guarded-join"), Map.entry("returnnull;","no-optional-authority"),
            Map.entry("TypedENode.constructDependentChainCertified(","dependent-certificate"),
            Map.entry("GuardedJoinCertificate.create(","guarded-certificate"), Map.entry("TypedENode.construct(","fixed-node"));
    private static void require(boolean ok, String message) { if (!ok) throw new IllegalStateException(message); }
    private static String digest(String text) {
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(text.getBytes(StandardCharsets.UTF_8))); }
        catch (java.security.NoSuchAlgorithmException e) { throw new AssertionError(e); }
    }
    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("A226CompilerContract SOURCE EXISTING_RESULTS_DIR");
        Path root = Path.of(args[0]);
        String src = "src/is/fivefivefive/";
        var units = List.of("CanDis/theory/TheoryAlloyAdapter", "CanDis/theory/DependentTypeDag", "CanDis/theory/DependentColumnEvidence",
                "CanDis/theory/AlloyTypeBridge", "ACGN/alloy/ExactAlloyType").stream().map(x -> root.resolve(src + x + ".java")).toList();
        var compiler = ToolProvider.getSystemJavaCompiler();
        var diag = new DiagnosticCollector<JavaFileObject>();
        var rows = new TreeMap<String,String>();
        var streams = new HashMap<String,List<String>>();
        try(var files = compiler.getStandardFileManager(diag, Locale.ROOT, StandardCharsets.UTF_8)) {
            var task = (JavacTask) compiler.getTask(null, files, diag, List.of("--release","17","-proc:none","-implicit:none","-sourcepath","",
                    "-classpath",System.getProperty("java.class.path")),null,files.getJavaFileObjectsFromPaths(units));
            var asts = new ArrayList<CompilationUnitTree>(); task.parse().forEach(asts::add); task.analyze();
            for (var d : diag.getDiagnostics()) require(d.getKind()!=Diagnostic.Kind.ERROR, d.toString());
            var symbols = Trees.instance(task);
            for (var ast : asts) new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree method, Void unused) {
                    var e = (ExecutableElement) symbols.getElement(getCurrentPath());
                    String id = e.getEnclosingElement()+"#"+e.getSimpleName()+"/"+e.getParameters().size();
                    if (!REQUIRED.containsKey(id)) return super.visitMethod(method, unused);
                    String compact = method.getBody().toString().replaceAll("\\s+","");
                    int position = 0;
                    var stream = new ArrayList<String>();
                    for(String marker : REQUIRED.get(id)) {
                        int at = compact.indexOf(marker,position);
                        require(at >= 0, id + " missing ordered effect " + marker);
                        position = at + marker.length();
                        if (EFFECT.containsKey(marker)) stream.add(EFFECT.get(marker));
                    }
                    streams.put(id,stream);
                    var calls = new ArrayList<String>();
                    new TreePathScanner<Void,Void>() {
                        private void bind() {
                            var d = symbols.getElement(getCurrentPath());
                            require(d != null,"unresolved call in "+id);
                            calls.add(d.getEnclosingElement()+"#"+d+"|"+d.asType());
                        }
                        @Override public Void visitMethodInvocation(MethodInvocationTree n,Void unused) { bind();return super.visitMethodInvocation(n,unused); }
                        @Override public Void visitNewClass(NewClassTree n,Void unused) { bind();return super.visitNewClass(n,unused); }
                        @Override public Void visitMemberReference(MemberReferenceTree n,Void unused) { bind();return super.visitMemberReference(n,unused); }
                    }.scan(getCurrentPath(),null);
                    require(rows.put(id,digest(method+"\n"+String.join("\n",calls))) == null,"overloaded route "+id);
                    return super.visitMethod(method,unused);
                }
            }.scan(ast,null);
        }
        require(rows.keySet().equals(REQUIRED.keySet()),"missing compiler registration "+rows.keySet());
        var lines = rows.entrySet().stream().map(e -> e.getKey()+"\t"+e.getValue()).toList();
        var sha = digest(String.join("\n",lines));
        require(sha.equals(PIN),"A226 method/binding digest "+sha);
        Files.write(Path.of(args[1],"a226-methods.tsv"),lines,StandardOpenOption.CREATE_NEW);
        var lowered = STREAM_ORDER.stream().flatMap(id -> streams.get(id).stream()).toList();
        Files.write(Path.of(args[1],"a226-program.txt"),lowered,StandardOpenOption.CREATE_NEW);
        System.out.println("A226 compiler correspondence passed: "+lines.size()+" methods");
    }
}
