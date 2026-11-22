package is.fivefivefive.CanDis;

import com.sun.source.tree.*;
import com.sun.source.util.*;
import javax.lang.model.element.*;
import javax.tools.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;

/** Attribute the production methods and interpret their membership branch expressions. */
public final class MembershipInstructions {
    private static final String PIN = "9e02bc0537cf72f2c0b9ae90159b514375b1c5b2be88dd231abfb1805c35bdc7";
    private static final String CORE="is.fivefivefive.CanDis.core.";
    private static final Map<String,Set<String>> METHODS=Map.of(
        CORE+"NormalForm",Set.of("normalizeGuardedSourceRules","isStaticallyNonemptySet","sourceNonemptySlots","guardedBindingFacts","isNone","isUniv"),
        CORE+"EGraphNode",Set.of("saturateOnce","parserCertifiedEmptyRightSubsetExpansion","parserCertifiedSubsetLatticeExpansion",
            "parserCertifiedStructuralSubsetComparison","parserCertifiedReflexiveComparison","parserCertifiedSubsetComparisonNegated",
            "parserCertifiedStructuralSubset","buildDerivedSubsetComparison","buildDerivedRelationCardinality","sameParserSetArity",
            "isSetConstant","hasCompatibleRelationArity"),
        CORE+"egraph.AlloyRewriteSystem",Set.of("rewriteNode","isConstant","isStaticallyNonempty","atomicNegationDual","addDeclarationBindings","isPositiveBindingDomain"),
        "is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter",Set.of("fromAst"),
        "parser.ast.nodes.ResolvedBindingOrigins",Set.of("declaration","read"));
    private final Map<String,MethodTree> methods = new TreeMap<>();
    private final Map<String,List<String>> observations = new TreeMap<>();
    private static void need(boolean ok,String m) { if(!ok) throw new IllegalArgumentException(m); }
    private static String text(Tree t) { return t.toString().replaceAll("\\s+",""); }
    private static String symbol(Element e) {
        if(e==null) throw new IllegalArgumentException("missing compiler binding");
        return e.getEnclosingElement()+"#"+e.getSimpleName()+":"+e.asType();
    }
    private String examine(Path root) throws Exception {
        var compiler=ToolProvider.getSystemJavaCompiler(); var diagnostics=new DiagnosticCollector<JavaFileObject>();
        try(var files=compiler.getStandardFileManager(diagnostics,Locale.ROOT,StandardCharsets.UTF_8)) {
            var src=METHODS.keySet().stream().sorted().map(k->root.resolve("src/"+k.replace('.','/')+".java")).toList();
            var task=(JavacTask)compiler.getTask(null,files,diagnostics,List.of("--release","17","-proc:none","-sourcepath","",
                "-classpath",System.getProperty("java.class.path")),null,files.getJavaFileObjectsFromPaths(src));
            List<CompilationUnitTree> units=new ArrayList<>();task.parse().forEach(units::add); task.analyze();
            for(var diag:diagnostics.getDiagnostics()) need(diag.getKind()!=Diagnostic.Kind.ERROR,diag.toString());
            var trees=Trees.instance(task);
            for(var unit:units) new TreePathScanner<Void,Void>() {
                @Override public Void visitMethod(MethodTree t,Void unused) {
                    var e=(ExecutableElement)trees.getElement(getCurrentPath());String owner=e.getEnclosingElement().toString(),name=e.getSimpleName().toString();
                    if(!METHODS.getOrDefault(owner,Set.of()).contains(name) || (name.equals("fromAst")&&e.getParameters().size()!=2))
                        return super.visitMethod(t,unused);
                    String k=owner+"#"+name;need(methods.put(k,t)==null,"ambiguous method "+k);
                    var obs=new ArrayList<String>(); observations.put(k,obs);obs.add(symbol(e));obs.add(t.getBody().toString());
                    new TreePathScanner<Void,Void>() {
                        private void ref(){obs.add(symbol(trees.getElement(getCurrentPath())));}
                        @Override public Void visitMethodInvocation(MethodInvocationTree n,Void v){ref();return super.visitMethodInvocation(n,v);}
                        @Override public Void visitNewClass(NewClassTree n,Void v){ref();return super.visitNewClass(n,v);}
                        @Override public Void visitMemberReference(MemberReferenceTree n,Void v){ref();return super.visitMemberReference(n,v);}
                        @Override public Void visitMemberSelect(MemberSelectTree n,Void v){var x=trees.getElement(getCurrentPath());if(x!=null && x.getKind().isField())ref();return super.visitMemberSelect(n,v);}
                    }.scan(new TreePath(getCurrentPath(),t.getBody()),null);return null;
                }
            }.scan(unit,null);
        }
        need(methods.size()==METHODS.values().stream().mapToInt(Set::size).sum(),"method census: "+methods.keySet());
        var digest=MessageDigest.getInstance("SHA-256");
        for(var entry:observations.entrySet()) for(String s:entry.getValue()) {
            byte[] bytes=s.getBytes(StandardCharsets.UTF_8);digest.update(java.nio.ByteBuffer.allocate(4).putInt(bytes.length).array());digest.update(bytes);
        }
        return HexFormat.of().formatHex(digest.digest());
    }
    /** Facts represent the current two operands at the selected node on one source path. */
    private record Facts(int left,int right,boolean width,boolean positive,boolean negative) {}
    private static boolean eval(ExpressionTree e,Facts f,Map<String,Boolean> vars) {
        if(e instanceof ParenthesizedTree t)return eval(t.getExpression(),f,vars);
        if(e instanceof BinaryTree t) {
            if(t.getKind()==Tree.Kind.CONDITIONAL_AND)return eval(t.getLeftOperand(),f,vars)&&eval(t.getRightOperand(),f,vars);
            if(t.getKind()==Tree.Kind.CONDITIONAL_OR)return eval(t.getLeftOperand(),f,vars)||eval(t.getRightOperand(),f,vars);
        }
        String key=text(e);
        if(key.startsWith("isStaticallyNonemptySet(") || key.startsWith("isStaticallyNonempty(")) {
            need(Set.of("isStaticallyNonemptySet(rewritten.get(0),bindings)","isStaticallyNonemptySet(lhs,bindings)","isStaticallyNonempty(value,positiveBindings)").contains(key),"authority target "+key);
            return f.positive;
        }
        return switch(key) {
            case "isNone(lhs)","isConstant(value,\"none\")" -> f.left==0;
            case "isNone(rhs)","isNone(rewritten.get(1))","isConstant(domain,\"none\")" -> f.right==0;
            case "isUniv(rhs)","isConstant(domain,\"univ\")" -> f.right==1;
            case "hasCompatibleRelationArity(lhs,rhs)","EGraphNode.hasCompatibleRelationArity(lhs,rhs)" -> f.width;
            case "node.getOpcode()==Opcode.NOT_IN" -> f.negative;
            case "node.getOpcode()==Opcode.IN" -> !f.negative;
            case "rewritten.size()==2" -> true;
            case "true" -> true;
            case "false" -> false;
            case "subset!=null","notSubset!=null" -> vars.containsKey(key.substring(0,key.indexOf('!')));
            case "subset","notSubset" -> Objects.requireNonNull(vars.get(key));
            default -> throw new IllegalArgumentException("Unmodeled selected guard "+key);
        };
    }
    private static String run(StatementTree s,Facts facts,Map<String,Boolean> vars) {
        if(s==null)return null;
        if(s instanceof BlockTree b){for(var step:b.getStatements()){String r=run(step,facts,vars);if(r!=null)return r;}return null;}
        if(s instanceof IfTree i)return run(eval(i.getCondition(),facts,vars)?i.getThenStatement():i.getElseStatement(),facts,vars);
        if(s instanceof VariableTree v) {
            String init=text(v.getInitializer());String name=v.getName().toString();
            need(Set.of("lhs=rewritten.get(0)","rhs=rewritten.get(1)","value=current.children().get(0)","domain=current.children().get(1)",
                "lhs=childClasses.get(0).getEClass().getRepresentative()","rhs=childClasses.get(1).getEClass().getRepresentative()",
                "subset=null","notSubset=null").contains(name+"="+init),"selected assignment "+name+"="+init);
            return null;
        }
        if(s instanceof ExpressionStatementTree x) {
            if(x.getExpression() instanceof AssignmentTree a) {
                String name=text(a.getVariable());need(name.equals("subset")||name.equals("notSubset"),name);
                vars.put(name,eval(a.getExpression(),facts,vars));return null;
            }
            if(x.getExpression() instanceof MethodInvocationTree m && text(m.getMethodSelect()).equals("collapseToBooleanConstant"))
                return eval(m.getArguments().get(0),facts,vars)?"T":"F";
            need(text(x).equals("eClass.preserveSnapshot(snapshot());"),"unexpected side effect "+x);return null;
        }
        if(s instanceof ReturnTree r && r.getExpression() instanceof MethodInvocationTree m) {
            var args=m.getArguments();String fun=text(m.getMethodSelect());
            need((fun.equals("bool")&&args.size()==1) || (fun.equals("booleanConstant")&&args.size()==2&&text(args.get(0)).equals("node")),"selected return "+m);
            return eval(args.get(args.size()-1),facts,vars)?"T":"F";
        }
        throw new IllegalArgumentException("Unmodeled membership statement "+s);
    }
    /** Read the opcode selector from the very return that builds cardinality. */
    private String cardinality(boolean negative) {
        MethodTree method=methods.get(CORE+"EGraphNode#parserCertifiedEmptyRightSubsetExpansion");
        List<String> selected=new ArrayList<>();
        new TreeScanner<Void,Void>() {
            @Override public Void visitReturn(ReturnTree ret,Void p) {
                if(ret.getExpression() instanceof MethodInvocationTree call && text(call.getMethodSelect()).equals("buildDerivedRelationCardinality")) {
                    var a=call.getArguments();
                    need(a.size()==3&&text(a.get(0)).equals("owner")&&text(a.get(2)).equals("left"),"wrong cardinality operand");
                    var selector=(ConditionalExpressionTree)a.get(1);
                    need(text(selector.getCondition()).equals("negated"),"wrong polarity selector");
                    selected.add(text(negative?selector.getTrueExpression():selector.getFalseExpression()));
                }
                return super.visitReturn(ret,p);
            }
        }.scan(method.getBody(),null);
        need(selected.size()==1,"expected one cardinality return");return selected.get(0).replace("Opcode.","");
    }
    private List<String> derive(String source,String engine) {
        MethodTree t=methods.get(source);
        Map<String,IfTree> branches=new HashMap<>(); IfTree early=null; int earlyIdx=-1,expandIdx=-1,index=0;
        for(var stmt:t.getBody().getStatements()) {
            index++;
            if(stmt instanceof VariableTree v && v.getName().contentEquals("emptyRightSubset")) {
                String init=text(v.getInitializer());
                need(init.equals("parserCertifiedEmptyRightSubsetExpansion(this,childClasses)")||
                    init.equals("awaitingBindingFacts?null:EGraphNode.parserCertifiedEmptyRightSubsetExpansion(node,node.getChildClasses())"),"unexpected expansion "+init);
                expandIdx=index;
            }
            if(!(stmt instanceof IfTree i))continue;
            String cond=text(i.getCondition());
            if(cond.equals("((node.getOpcode()==Opcode.IN||node.getOpcode()==Opcode.NOT_IN)&&rewritten.size()==2&&isNone(rewritten.get(1))&&isStaticallyNonemptySet(rewritten.get(0),bindings))")){
                early=i;earlyIdx=index;continue;
            }
            for(String pol:List.of("IN","NOT_IN")) {
                String match=switch(engine){
                    case "R" -> "(\"BF/"+pol+"\".equals(current.head())&&current.children().size()==2)";
                    case "N" -> "(node.getOpcode()==Opcode."+pol+"&&rewritten.size()==2)";
                    case "S" -> "(opcode==Opcode."+pol+"&&childClasses.size()==2)";
                    default -> throw new AssertionError();
                };
                if(cond.equals(match)) {need(branches.put(pol,i)==null && (engine.equals("R")||expandIdx>0),"branch order "+engine);}
            }
        }
        need(branches.size()==2&&(!engine.equals("N")||(early!=null&&earlyIdx<expandIdx)),"incomplete branch sequence "+engine);
        var result=new ArrayList<String>();
        for(String pol:List.of("IN","NOT_IN"))for(int l=0;l<3;l++)for(int r=0;r<3;r++)for(int w=0;w<=1;w++)for(int a=0;a<=1;a++)for(int x=0;x<=1;x++) {
            Facts facts=new Facts(l,r,w==1,a==1,pol.equals("NOT_IN"));var vars=new HashMap<String,Boolean>();String answer=null;
            if(early!=null&&eval(early.getCondition(),facts,vars))answer=run(early.getThenStatement(),facts,vars);
            if(answer==null&&expandIdx>0&&r==0&&x==1)answer=cardinality(facts.negative);
            if(answer==null)answer=run(branches.get(pol).getThenStatement(),facts,vars);
            result.add(String.join("\t",engine,pol,""+l,""+r,""+w,""+a,""+x,answer==null?"K":answer));
        }
        return result;
    }
    public static void main(String[] args) throws Exception {
        if(args.length!=2)throw new IllegalArgumentException("checkout new-table");
        var model=new MembershipInstructions();
        String pin=model.examine(Path.of(args[0]));System.out.println("membership methods="+model.methods.size()+" sha256="+pin);
        need(PIN.equals(pin),"unregistered compiler instruction stream "+pin);
        var rows=new ArrayList<String>(); rows.add("engine\tpolarity\tleft\tright\tsame-width\tauthority\tcan-expand\tresult");
        rows.addAll(model.derive(CORE+"egraph.AlloyRewriteSystem#rewriteNode","R"));
        rows.addAll(model.derive(CORE+"NormalForm#normalizeGuardedSourceRules","N"));
        rows.addAll(model.derive(CORE+"EGraphNode#saturateOnce","S"));
        Files.write(Path.of(args[1]),rows,StandardCharsets.UTF_8,StandardOpenOption.CREATE_NEW);
        System.out.println("membership instruction decisions="+(rows.size()-1));
    }
}
