package org.acgn.cert;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import javax.lang.model.element.*;
import javax.tools.*;

/** Closed extract of the Java JOIN case loops and the independent wire admission routes. */
public final class A224SourceContract {
    private static final String P="is.fivefivefive.CanDis.theory.";
    private static final String PARSER_TYPE="is.fivefivefive.ACGN.alloy.ExactAlloyType";
    private static final String V="org.acgn.cert.SemanticEvidenceVerifier.SemanticReplay";
    private static final String PIN="91b8e60a360d2afe7a0192cf8300d66c2f10afc4b4c8644ec4294b117dc6e6fd";
    private static final Set<String> SELECTED=Set.of(
            PARSER_TYPE+"#<init>/5", PARSER_TYPE+"#tupleKey", PARSER_TYPE+"#buildStableString",
            P+"DependentChainTheory#leafTypeProof/4", P+"DependentTypeDag#combine", P+"DependentTypeDag.ChainCombination#<init>",
            P+"DependentTypeDag.CombinationCase#validate",P+"DependentTypeDag#normalize",
            P+"DependentBoundaryCorrespondence#derive",P+"DependentBoundaryCorrespondence#overlaps",
            P+"CertificateBundleWriter.Assembler#dependentCombinationCases",P+"CertificateBundleWriter.Assembler#dependentCombinationCase",
            V+"#dependentChainInput", V+"#verify", V+"#requireChainCombination",V+"#deriveBoundary",V+"#requireCombinationCasesWire",V+"#requireBoundaryWire");
    private final Map<String,String> hashes=new TreeMap<>();
    private final Map<String,List<String>> programs=new TreeMap<>();
    private static void check(boolean ok,String detail) { if(!ok)throw new IllegalArgumentException("A224 source: "+detail); }
    private static String sha(String s)throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(s.getBytes(StandardCharsets.UTF_8)));
    }
    private static String compact(Tree n) { return n.toString().replaceAll("\\s+",""); }
    private static void exact(Tree tree,String text) { check(compact(tree).equals(text),compact(tree)+" expected "+text); }
    private static List<? extends StatementTree> loop(ForLoopTree tree,String side,boolean verifier) {
        String index=side+"Index";
        check(tree.getInitializer().size()==1 && tree.getUpdate().size()==1,"strict counted loop");
        exact(tree.getInitializer().get(0),"int"+index+"=0");
        exact(tree.getCondition(),index+"<"+side+".alternatives"+(verifier?"()":"")+".size()");
        exact(tree.getUpdate().get(0),index+"++;");
        return ((BlockTree)tree.getStatement()).getStatements();
    }
    private static void ordered(String haystack,String... claims) {
        int next=0;
        for(String c:claims) { int i=haystack.indexOf(c,next);check(i>=0,"unmodeled expression "+c);next=i+c.length();}
    }
    private static List<String> decode(MethodTree method,boolean verifier) {
        String code=compact(method.getBody());
        ordered(code,"Math.subtractExact(Math.addExact(",",","),2)","if(resultArity<=0)","throw");
        var loops=method.getBody().getStatements().stream().filter(ForLoopTree.class::isInstance).toList();
        check(loops.size()==1,"top-level loops");
        var outer=loop((ForLoopTree)loops.get(0),"left",verifier);
        check(outer.size()==2,"outer body");
        String alts=verifier ? ".alternatives()" : ".alternatives";
        ordered(compact(outer.get(0)),"leftProduct=left"+alts+".get(leftIndex)");
        var inner=loop((ForLoopTree)outer.get(1),"right",verifier);
        ordered(compact(inner.get(0)),"rightProduct=right"+alts+".get(rightIndex)");
        var arrow=(IfTree)inner.get(1);
        check(compact(arrow.getCondition()).contains("==")&&compact(arrow.getCondition()).endsWith(".ARROW)"),"sibling ARROW branch");
        var arrowBlock=((BlockTree)arrow.getThenStatement()).getStatements();
        check(arrowBlock.get(arrowBlock.size()-1) instanceof ContinueTree && arrow.getElseStatement()==null,"ARROW termination");
        ordered(compact(inner.get(2)),"boundary="+(verifier?"deriveBoundary(":"DependentBoundaryCorrespondence.derive("),
                "leftProduct.get(leftProduct.size()-1),rightProduct.get(0))");
        var dis=(IfTree)inner.get(3);
        exact(dis.getCondition(),verifier?"(boundary.rule()==BoundaryRule.DISJOINT_BRANCHES)":"(!boundary.overlaps())");
        var omission=((BlockTree)dis.getThenStatement()).getStatements();
        check(dis.getElseStatement()==null && omission.size()==2 && omission.get(1) instanceof ContinueTree,"checked omission");
        ordered(compact(omission.get(0)),"cases.add(","leftIndex,rightIndex,CombinationDecision.JOIN_DISJOINT,boundary,null)");
        ordered(compact(inner.get(4)),verifier?"result=newArrayList<":"product=newArrayList<","(");
        String word = String.join("\n",inner.stream().skip(5).map(A224SourceContract::compact).toList());
        if(verifier) {
            ordered(word,"result.addAll(leftProduct.subList(0,leftProduct.size()-1));","result.addAll(rightProduct.subList(1,rightProduct.size()));",
                    "if(result.isEmpty())","throw","frozen=List.copyOf(result)","products.add(frozen);","cases.add(combinationCase(leftIndex,rightIndex,CombinationDecision.JOIN_OVERLAP,boundary,frozen));");
            ordered(code,"products.isEmpty()?emptyChainDag(resultArity):chainDagFromAlternatives(normalizeAlternatives(products))","returnnewChainCombination(output,List.copyOf(cases));");
        } else {
            ordered(word,"product.addAll(leftProduct.subList(0,leftProduct.size()-1));","product.addAll(rightProduct.subList(1,rightProduct.size()));",
                    "if(product.isEmpty())","throw","products.add(product);","cases.add(newCombinationCase(leftIndex,rightIndex,CombinationDecision.JOIN_OVERLAP,boundary,product));");
            ordered(code,"returnnewChainCombination(products.isEmpty()?empty(resultArity):newDependentTypeDag(products),cases,left.alternatives.size(),right.alternatives.size());");
        }
        return List.of("positive-width:checked-sum-minus-two","left-ascending","right-ascending","boundary:last-left:first-right",
                "disjoint:record:skip","overlap:init-left:tail-right","overlap:record:retain","empty:typed-width","nonempty:normalize");
    }
    private void inspect(String owner,MethodTree method,String digest) {
        String code=compact(method.getBody());
        if(owner.endsWith(".DependentTypeDag#combine"))programs.put("producer",decode(method,false));
        if(owner.endsWith(".SemanticReplay#requireChainCombination"))programs.put("verifier",decode(method,true));
        if(owner.endsWith(".ChainCombination#<init>"))ordered(code,"Math.multiplyExact(leftAlternatives,rightAlternatives)","this.cases.size()!=expected",
                "for(intleft=0;left<leftAlternatives;left++)","for(intright=0;right<rightAlternatives;right++)",
                "this.cases.get(offset++)","proof.leftAlternative()!=left","proof.rightAlternative()!=right","throw");
        if(owner.equals(PARSER_TYPE+"#<init>/5"))
            ordered(code, "columns.add(normalizeColumn(column))", "shapes.sort(Comparator.comparing((shape)->tupleKey(shape.columns)))",
                    "copied.add(shape.columns)", "this.alternatives=Collections.unmodifiableList(copied)", "this.stableString=buildStableString()");
        if(owner.equals(PARSER_TYPE+"#tupleKey"))
            ordered(code, "for(Stringcolumn:tuple)", "result.append(column.length()).append(':').append(column)", "returnresult.toString()");
        if(owner.equals(PARSER_TYPE+"#buildStableString"))
            ordered(code, "newStringBuilder(kind.name())", "for(List<String>tuple:alternatives)", "result.append('[')",
                    "for(Stringcolumn:tuple)", "result.append(column.length()).append(':').append(column)", "result.append(']')");
        if(owner.endsWith("#leafTypeProof/4"))
            ordered(code, "requireLeafTypeProof(storedType,relationDag,sourceAuthority)", "if(rule!=checked)", "throw",
                    "dependent-chain-leaf-type-proof-v2", "rule.name()", "sourceAuthority.stableString()", "TheoryKeys.type(storedType)", "relationDag.structuralKey()");
        if(owner.equals(V+"#dependentChainInput"))
            ordered(code, "dependentTypeDag(node.child(0),output)", "requireLeafTypeRule(stored,output)", "dependent-chain-leaf-type-proof-v1",
                    "dependent-chain-leaf-type-proof-v2", "rule==LeafTypeRule.EXACT_RELATION", "!dag.alternatives().isEmpty()",
                    "expectedKind==ChainKind.JOIN||dag.alternatives().size()==1", "requiresJoinSourceForExactV2=true",
                    "requiresArrowSourceForExactV2=true", "for(List<ChainColumn>product:dag.alternatives())", "for(ChainColumncolumn:product)",
                    "tuple.append(label.length()).append(':').append(label)", "products.add(tuple.toString())", "products.sort(String::compareTo)",
                    "String.join(", "List.of(rule.name(),source)", "List.of(stored.key(),dag.key())", "if(!typeProof.equals(expectedProof))", "throw");
        if(owner.endsWith("#dependentChainInput"))ordered(code,"dependentChainInput(node.child(0),expectedKind,context)",
                "dependentChainInput(node.child(1),expectedKind,context)","requireChainCombination(expectedKind,left.outputDag(),right.outputDag())",
                "dependentTypeDag(node.child(2),output)","if(!outputDag.equals(combination.outputDag()))","throw",
                "requireCombinationCasesWire(node.child(3),combination.cases());");
        if(owner.equals(V+"#verify"))ordered(code,"dependent-chain-construction","verifyDependentChain(record);",
                "if(hasUntrustedSubtypeHierarchy||(hasNontrivialAncestry&&expectedArrowDigest==null))","thrownewUncheckableException(FailureCode.MISSING_EVIDENCE,");
        if(owner.endsWith("#requireCombinationCasesWire"))ordered(code,"expected.size()","Integer.toString(expected.size())","for(intindex=0;index<expected.size();index++)",
                "expected.get(index)","node.child(index)","proof.leftAlternative()","proof.rightAlternative()","proof.decision().name()","requireBoundaryWire(encoded.child(0),proof.boundary())",
                "if(proof.resultAlternative()==null)","dependent-chain-no-result","DISJOINT","dependentTypeProduct(encoded.child(1),-1,resultType)","!parsed.equals(proof.resultAlternative())","requireKey(");
        if(owner.endsWith("#dependentCombinationCases"))ordered(code,"Integer.toString(cases.size())","cases.stream().map(this::dependentCombinationCase).toList()");
        if(owner.endsWith("#dependentCombinationCase"))ordered(code,"proof.boundary()","proof.resultAlternative()","DISJOINT","proof.leftAlternative()","proof.rightAlternative()",
                "proof.decision().name()","proof.structuralKey().stableString()","List.of(boundary,result)");
        if(owner.endsWith("#overlaps"))ordered(code,"returnrule!=Rule.DISJOINT_BRANCHES;");
        check(hashes.put(owner,digest)==null,"overloaded route "+owner);
    }
    private void run(Path repo,Path output)throws Exception {
        var src=repo.resolve("src/is/fivefivefive/CanDis/theory");
        List<Path> units=List.of(repo.resolve("src/is/fivefivefive/ACGN/alloy/ExactAlloyType.java"),
                src.resolve("DependentChainTheory.java"),src.resolve("DependentTypeDag.java"),src.resolve("DependentBoundaryCorrespondence.java"),src.resolve("CertificateBundleWriter.java"),
                repo.resolve("certificate-verifier/src/org/acgn/cert/SemanticEvidenceVerifier.java"));
        var compiler=ToolProvider.getSystemJavaCompiler();var diagnostics=new DiagnosticCollector<JavaFileObject>();
        try(var manager=compiler.getStandardFileManager(diagnostics,Locale.ROOT,StandardCharsets.UTF_8)) {
            var task=(JavacTask)compiler.getTask(null,manager,diagnostics,List.of("--release","17","-proc:none","-implicit:none","-sourcepath","",
                    "-classpath",System.getProperty("java.class.path")),null,manager.getJavaFileObjectsFromPaths(units));
            var trees=new ArrayList<CompilationUnitTree>();task.parse().forEach(trees::add);task.analyze();
            for(var d:diagnostics.getDiagnostics())check(d.getKind()!=Diagnostic.Kind.ERROR,d.toString());
            var symbols=Trees.instance(task);
            for(var unit:trees)new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree m,Void arg) {
                    var caller=(ExecutableElement)symbols.getElement(getCurrentPath());
                    String key=caller.getEnclosingElement()+"#"+caller.getSimpleName();
                    if (key.equals(PARSER_TYPE+"#<init>") || key.equals(P+"DependentChainTheory#leafTypeProof"))
                        key += "/" + caller.getParameters().size();
                    if(SELECTED.contains(key)) {
                        final String selectedKey=key;
                        var bindings=new ArrayList<String>();
                        new TreePathScanner<Void,Void>() {
                            private void bind() {
                                var element=symbols.getElement(getCurrentPath());
                                check(element!=null,"unattributed method in "+selectedKey);
                                bindings.add(element.getEnclosingElement()+"#"+element+"|"+element.asType());
                            }
                            @Override public Void visitMethodInvocation(MethodInvocationTree n,Void a){bind();return super.visitMethodInvocation(n,a);}
                            @Override public Void visitNewClass(NewClassTree n,Void a){bind();return super.visitNewClass(n,a);}
                            @Override public Void visitMemberReference(MemberReferenceTree n,Void a){bind();return super.visitMemberReference(n,a);}
                        }.scan(getCurrentPath(),null);
                        try {inspect(key,m,sha(m+"\n"+String.join("\n",bindings)));}catch(RuntimeException e){throw e;}catch(Exception e){throw new IllegalStateException(e);}
                    }
                    return super.visitMethod(m,arg);
                }
            }.scan(unit,null);
        }
        check(hashes.keySet().equals(SELECTED), "route census "+hashes.keySet());
        check(programs.size()==2 && programs.get("producer").equals(programs.get("verifier")),"independent extraction disagreement");
        String pin=sha(String.join("\n",hashes.entrySet().stream().map(e->e.getKey()+"\t"+e.getValue()).toList()));
        check(pin.equals(PIN),"method/binding pin "+pin);
        Files.write(output.resolve("join-source.tsv"),hashes.entrySet().stream().map(e->e.getKey()+"\t"+e.getValue()).toList(),StandardOpenOption.CREATE_NEW);
        Files.write(output.resolve("join-program.txt"),programs.get("producer"),StandardOpenOption.CREATE_NEW);
        System.out.println("A224 source correspondence passed: "+hashes.size()+" attributed methods");
    }
    public static void main(String[] args)throws Exception {
        if(args.length!=2)throw new IllegalArgumentException("A224SourceContract REPO EXISTING_OUTPUT_DIRECTORY");
        new A224SourceContract().run(Path.of(args[0]),Path.of(args[1]));
    }
}
