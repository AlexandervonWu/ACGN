package is.fivefivefive.CanDis;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import javax.lang.model.element.ExecutableElement;
import javax.tools.*;

/** Compiler-attributed source contracts for the ordinary chain dispatch, source census, guards, and fixed-node builder. */
public final class A216CompilerContract {
    private static final String PIN = "34934e2eac3c90ac41c8e193ff5ebad49e1e9c8d717bc2f38f2a9c86e079cf47";
    private static final String T = "is.fivefivefive.CanDis.theory.";
    private static final String B = T+"TheoryAlloyAdapter.Builder#";
    private static final String K = T+"TheoryAlloyAdapter.InvocationKey#";
    private static final String R = "is.fivefivefive.CanDis.metric.RepairProjection";
    private static final String E = "is.fivefivefive.CanDis.core.EGraphNode#";
    private static final String P = "is.fivefivefive.CanDis.core.AlloyOperatorPolicy#";
    private static final Map<String,List<String>> REQUIRED = Map.ofEntries(
        Map.entry(B+"<init>/4", List.of("freezeForCertification()", "requirePristineCertificationSources(this.normalForms)", "indexSourceOccurrencePaths(this.normalForms)")),
        Map.entry(R+"#project/2",List.of("RepairView.fromCertifiedProjection(projectComponents(evidence,normalForms))")),
        Map.entry(R+"#projectComponents/2",List.of("evidence.dependentChainSourceBindings()","CertifiedDependentChains.from(artifact,dependentChainSourceBindings,normalForms)","projectPhase(")),
        Map.entry(R+".CertifiedDependentChains#from/3",List.of("admitted.addAll(artifact.dependentChainConstructions())","binding.requireMatches(source)","!admitted.contains(certificate)","!used.add(certificate)","checked.put(source,certificate)","GuardedJoinSourceFiber.bindWithEvidence(artifact,normalForms)")),
        Map.entry(R+".CertifiedDependentChains#certificateFor/1",List.of("returncertificates.get(source)")),
        Map.entry(R+"#projectOrdinaryNode/11",List.of("chains.rotations.get(source)","rotation.requireMatches(source)","returnprojectGuardedJoin(","chains.certificateFor(source)","if(dependentChain!=null)","returnprojectDependentChain(","containerKind(source)","containers.childFibers(","source.getChildren().get(childIndex)","children.add(projected)","newNode(")),
        Map.entry(R+"#containerKind/1",List.of("node.getSiblingQuotient()","COMMUTATIVE_IDEMPOTENT_SET","COMMUTATIVE_BAG","returnContainerKind.ONE","returnContainerKind.SEQUENCE")),
        Map.entry(R+".CertifiedContainers#childFibers/2",List.of("kind==ContainerKind.SET?setPartitions.get(source):null","List<List<Integer>>all=","for(intindex=0;index<source.getChildren().size();index++)","all.add(Collections.singletonList(index))","returnall")),
        Map.entry(E+"<init>/10",List.of("this.childClasses=newArrayList<>()","if(createEClass)","this.eClass=newEClass(NEXT_ECLASS_ID.getAndIncrement(),this)")),
        Map.entry("is.fivefivefive.CanDis.core.EGraphNode.EClass#<init>/2",List.of("this.id=id","nodes.add(head)")),
        Map.entry("is.fivefivefive.CanDis.core.EGraphNode.EClass#getRepresentative/0",List.of("requireLive()","returnnodes.get(0)")),
        Map.entry(B+"buildFlatApplication/8",List.of("intclassId=source.getEClass().getId()","if(!activeFlatClasses.add(classId))","thrownewIllegalStateException(","activeFlatClasses.remove(classId)")),
        Map.entry(B+"buildPhase/3",List.of("bodyBindings=newLinkedHashMap<>(inheritedBindings)","registerBinding(","buildTemporalReferences(","phase.getCertificationMatrixEGraph()","buildMatrixOperand(")),
        Map.entry(B+"buildMatrixOperand/5",List.of("identitySlotNames(matrix)","returnbuildChildOperand(","returnbuildOperand(")),
        Map.entry(B+"requirePristineCertificationSources/1",List.of("Set<Integer>classIds=newHashSet<>()","getCertificationMatrixEGraph()","if(!visited.add(node))","node.requirePristineCertificationSource()","if(!classIds.add(node.getEClass().getId()))","thrownewIllegalStateException(","pending.addAll(node.getChildren())")),
        Map.entry(B+"indexSourceOccurrencePaths/4",List.of("if(!active.add(node))","paths.putIfAbsent(node,path)","if(!prior.equals(path))","indexSourceOccurrencePaths(","active.remove(node)")),
        Map.entry(E+"requirePristineCertificationSource/0",List.of("eClass.getNodes().size()!=1","eClass.getRepresentative()!=this","canonical.getEClass()!=original.getEClass()","!canonical.getSlotMap().equals(original.getSlotMap())")),
        Map.entry(K+"<init>/4",List.of("this.eclass=eclass","newTreeMap<>(slots)","this.context=context","this.head=head")),
        Map.entry(K+"equals/1",List.of("eclass==key.eclass","slots.equals(key.slots)","context.equals(key.context)","head.equals(key.head)")),
        Map.entry(B+"buildOperand/5",List.of("node.requireAdmittedArity()", "newInvocationKey(node.getEClass().getId(),slotNames,context,semanticHead(node))","memo.get(key)","returnOnePort.invocation(context,remembered)","if(!active.add(key))","Opcode.JOIN","Opcode.ARROW","constructDependentChainOperand(","memo.put(key,","returnresult;","if(node.hasFlatLicense())","for(EClassRefchild:node.getChildClasses())","operands.add(buildChildOperand(child,slotNames,context,bindings,temporalReferences))","constructNode(node,context,operands)","insert(typed)","memo.put(key,invocation)","returnOnePort.invocation(context,invocation)","active.remove(key)")),
        Map.entry(B+"buildChildOperand/5",List.of("child.canonical()","returnbuildOperand(","canonical.getEClass().getRepresentative()","composeSlotNames(canonical.getSlotMap(),outerNames)","context,bindings,temporalReferences")),
        Map.entry(B+"constructDependentChainOperand/5",List.of("dependentChainApplication(","returnnull;","requireDependentResultProof(source,application)","recordDependentChain(","constructDependentChainCertified(","dependentChainConstructions.add(","dependentChainSourceBindings.putIfAbsent(","graph.insertNodeConstructed(")),
        Map.entry(B+"dependentChainApplication/7",List.of("source.requireAdmittedArity()","source.getChildren().size()!=2","intclassId=source.getEClass().getId()","activeChainClasses.add(classId)","source.getChildClasses().get(0)","source.getChildClasses().get(1)","newDependentChainApplication(kind,left,right)","thrownewIllegalStateException(","requireDependentResultProof(source,application)","activeChainClasses.remove(classId)")),
        Map.entry(B+"dependentChainInput/7",List.of("Opcode.JOIN","Opcode.ARROW","dependentChainApplication(","buildOperand(","Opcode.PLUS","Opcode.INTERSECT","dependentTypeDagForSource(")),
        Map.entry(B+"dependentTypeDagForSource/2",List.of("intclassId=source.getEClass().getId()","activeTypeClasses.add(classId)","operands.add(dependentTypeDagForSource(","derived.sameOccurrenceEvidenceAs(parserDag)","thrownewIllegalStateException(","returnderived;","activeTypeClasses.remove(classId)")),
        Map.entry(B+"requireDependentResultProof/2",List.of("requireLeafTypeProof(","leafTypeProof(")),
        Map.entry(B+"constructGuardedJoin/5",List.of("guardedJoinTree(","GuardedJoinCertificate.normalized(tree)","catch(IllegalArgumentExceptionunsupported)","returnnull;","realizeGuardedJoin(normalized)","GuardedJoinCertificate.create(","recordGuardedJoin(","guardedJoinConstructions.add(","graph.insertNodeConstructed(")),
        Map.entry(B+"guardedJoinTree/7",List.of("depth>64","dependentTypeDagForSource(","requireAdmittedJoinType(","source.getChildClasses().size()!=2","for(EClassRefchild:source.getChildClasses())","GuardedJoinTree.join(children.get(0),children.get(1))")),
        Map.entry(B+"constructNode/3",List.of("source.requireAdmittedArity()","List<OnePort>typedOperands=operands","source.isOrderInsensitive()","for(OnePortoperand:typedOperands)","schemas.add(operand.schema())","ports.add(operand)","semanticHead(source),schemas,output,Collections.emptyMap(),null","NodeConstruction.plain(TypedENode.construct(","context,ports)")),
        Map.entry(B+"mirrorCertifiedSourcePlansToRepairMatrices/0",List.of("chainsByLineage.putIfAbsent(","!prior.sameTransferPlanAs(","chainsByLineage.get(lineage)","binding.transferTo(candidate)")),
        Map.entry(P+"forShape/4",List.of("isFixedBinaryTypedChainOperator(opcode)","nonflat(ArityPolicy.exact(2),SiblingQuotient.ORDERED_SEQUENCE)")),
        Map.entry(P+"isFixedBinaryTypedChainOperator/1",List.of("caseJOIN:","caseARROW:","returntrue;","returnfalse;")),
        Map.entry(P+"nonflat/2",List.of("FlatLicense.none()","UnitLicense.ABSENT")),
        Map.entry(E+"requireAdmittedArity/0",List.of("getArityPolicy().requireAdmitted(childClasses.size(),opcode.toString())")),
        Map.entry(T+"ArityPolicy#requireAdmitted/2",List.of("if(!admits(arity))","thrownewIllegalStateException(")),
        Map.entry(T+"TypedENode#construct/3",List.of("newTypedENode(")));
    private static String branch(StatementTree stmt) {
        if (stmt instanceof BlockTree block && block.getStatements().size()==1)
            return branch(block.getStatements().get(0));
        if (stmt instanceof ReturnTree ret) {
            if (ret.getExpression().getKind()==Tree.Kind.NULL_LITERAL) return "fixed";
            if (ret.getExpression() instanceof MethodInvocationTree call
                    && call.getMethodSelect().toString().equals("constructGuardedJoin")) return "guard";
        }
        throw new IllegalStateException("Unregistered catch successor "+stmt);
    }
    private static List<String> branches(MethodTree method) {
        var tries=method.getBody().getStatements().stream().filter(TryTree.class::isInstance).map(TryTree.class::cast).toList();
        require(tries.size()==1 && tries.get(0).getCatches().size()==1,"unexpected dependent catch");
        var handler=tries.get(0).getCatches().get(0);
        require(handler.getParameter().getType() instanceof UnionTypeTree types &&
            types.getTypeAlternatives().stream().map(Object::toString).toList().equals(List.of(
            "UnsupportedDependentChain","DependentChainTheory.UnsupportedFlattening")), "hard failure caught");
        var statements=handler.getBlock().getStatements();
        require(statements.size()==2 && statements.get(0) instanceof IfTree,"missing JOIN-only guard");
        var iff=(IfTree)statements.get(0);
        require(iff.getCondition().toString().replaceAll("\\s+","").equals("(kind==DependentChainKind.JOIN)") && iff.getElseStatement()==null,"wrong catch discrimination");
        return List.of("JOIN="+branch(iff.getThenStatement()),"ARROW="+branch(statements.get(1)));
    }
    private static void require(boolean ok, String message) { if (!ok) throw new IllegalStateException(message); }
    private static String digest(String text) {
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(text.getBytes(StandardCharsets.UTF_8))); }
        catch (java.security.NoSuchAlgorithmException e) { throw new AssertionError(e); }
    }
    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("A216CompilerContract SOURCE EXISTING_RESULTS_DIR");
        Path root = Path.of(args[0]);
        String src = "src/is/fivefivefive/";
        var units = List.of("CanDis/theory/TheoryAlloyAdapter","CanDis/theory/TypedENode","CanDis/theory/ArityPolicy",
                "CanDis/core/EGraphNode","CanDis/core/AlloyOperatorPolicy","CanDis/metric/RepairProjection").stream().map(x -> root.resolve(src+x+".java")).toList();
        var compiler = ToolProvider.getSystemJavaCompiler();
        var diag = new DiagnosticCollector<JavaFileObject>();
        var rows = new TreeMap<String,String>();
        var routes = new ArrayList<String>();
        var effects = new LinkedHashSet<String>();
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

                    for(String marker : REQUIRED.get(id)) {
                        int at = compact.indexOf(marker,position);
                        require(at >= 0, id + " missing ordered effect " + marker);
                        position = at + marker.length();

                    }
                    if(id.equals(B+"requirePristineCertificationSources/1")) effects.add("reject-repeated-pristine-class-id");
                    if(id.equals(B+"indexSourceOccurrencePaths/4")) effects.add("one-pristine-source-per-key");
                    if(id.equals(B+"buildOperand/5")) {
                        effects.add("arity-before-cache");
                        effects.add("cache-before-attempt");
                    }
                    if(id.equals(B+"constructDependentChainOperand/5")) {
                        routes.addAll(branches(method));
                        effects.add("hard-before-fallback");
                    }
                    if(id.equals(B+"constructNode/3")) {
                        effects.add("for-child-append;for-port-append");
                        effects.add("fixed-empty-laws");
                    }
                    if(id.equals(R+"#projectOrdinaryNode/11")) effects.add("project-only-occurrence-bound-authority");
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
        require(sha.equals(PIN),"A216 method/binding digest "+sha);
        Files.write(Path.of(args[1],"a216-methods.tsv"),lines,StandardOpenOption.CREATE_NEW);
        var lowered = new ArrayList<>(List.of("reject-repeated-pristine-class-id","one-pristine-source-per-key","arity-before-cache","cache-before-attempt"));
        lowered.addAll(routes);
        lowered.addAll(List.of("hard-before-fallback","for-child-append;for-port-append","fixed-empty-laws","project-only-occurrence-bound-authority"));
        require(lowered.stream().filter(x -> !x.contains("=")).allMatch(effects::contains),"missing observed dispatch effect");
        Files.write(Path.of(args[1],"a216-program.txt"),lowered,StandardOpenOption.CREATE_NEW);
        System.out.println("A216 compiler correspondence passed: "+lines.size()+" methods");
    }
}
