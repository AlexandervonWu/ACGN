package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;

final class ClassifierPoolTest {
    static void need(boolean ok,Object message) {if(!ok) throw new AssertionError(message);}
    static String op(ExprBinary.Op op) {return switch(op) {
        case LT -> "lt"; case LTE -> "le"; case GT -> "gt"; case GTE -> "ge";
        case EQUALS -> "eq"; case NOT_EQUALS -> "ne"; default -> throw new AssertionError(op);
    };}
    static String term(ScopedClassifier.Read r,int w) {
        return "key "+w+" "+r.complemented()+" ⟨."+op(r.operandFirstOp())+", "+r.sourceLiteral()+"⟩";
    }
    static String head(Expr expr) {
        Expr e=expr.deNOP();
        if(e instanceof ExprQt q) return q.op.name();
        if(e instanceof ExprBinary b) return b.op.name();
        if(e instanceof ExprList l) return l.op.name();
        if(e instanceof ExprUnary u) return u.op.name();
        return e.getClass().getSimpleName();
    }
    static String shape(Expr e) {
        e=e.deNOP();
        if(e instanceof ExprQt q) return q.op.name()+"."+shape(q.sub);
        if(e instanceof ExprBinary b) return b.op.name()+"("+head(b.left)+","+head(b.right)+")";
        return head(e);
    }
    static void proofs(Set<String> out,ScopedClassifier.Match m,Func a,Func b) {
        var all=new ArrayList<>(m.arms().get(a)); all.addAll(m.arms().get(b));
        for(int i=0;i<all.size();i++) for(int j=0;j<i;j++)
            proofPair(out,m,all.get(i).read(),all.get(j).read());
    }
    static void proofPair(Set<String> out,ScopedClassifier.Match m,ScopedClassifier.Read l,ScopedClassifier.Read r) {
        String canonical="(⟨."+op(m.key().op())+", "+m.key().literal()+"⟩ : Threshold)";
        for(var v:List.of(l,r)) out.add("example : "+term(v,m.width())+" = "+canonical+" := by decide");
        for(var v:List.of(l,r)) v.witness().ifPresent(proof->{
            if(proof.form()==FiberWitness.Form.GROUPED) {
                var seq=proof.needs().stream().map(n->"."+n.name().toLowerCase(Locale.ROOT)).toList();
                out.add("example : AdaptiveFiberWitness.complete "+seq+" := by simp [AdaptiveFiberWitness.complete]");
            }
        });
        for(var v:List.of(l,r)) if(!v.excluded().isEmpty())
            out.add("example : AdaptiveFiberWitness.covers "+v.excluded()+" "+v.sourceLiteral()+
                    " := by intro j; simp <;> omega");
        if(l.observation()!=r.observation() && (!l.excluded().isEmpty() || !r.excluded().isEmpty())) {
            boolean signed=l.observation()==ScopedClassifier.Observation.SIGNED || r.observation()==ScopedClassifier.Observation.SIGNED;
            out.add("example : "+(signed?"2*":"")+m.cap()+" < 2^"+m.width()+" := by decide");
        } else if(l.multiplicity().isPresent()!=r.multiplicity().isPresent()) {
            String mult=switch(l.multiplicity().or(r::multiplicity).orElseThrow()) {
                case NO -> "eqZero"; case SOME -> "gtZero"; case LONE -> "leOne"; case ONE -> "eqOne";
                default -> throw new AssertionError();
            };
            out.add("example : safeAt ."+mult+" "+m.width()+" "+m.cap()+" := by simp [safeAt]");
        }
    }
    static String inspect(String raw,Set<String> lean) throws Exception {
        var module=CompUtil.parseEverything_fromString(null,raw+"""

                check eightAudit {inv5 iff inv5c} for 8 but exactly 8 Track, 4 Int
                run wrapAudit {succs=Track->Track and Junction=Track and inv5c and not inv5} for 8 but exactly 8 Track, 4 Int
                check widerAudit {inv5 iff inv5c} for 8 but exactly 8 Track, 5 Int
                run residueAlias {succs=Track->Track and Junction=Track and inv5c and not inv5} for 16 but exactly 16 Track, 4 Int
                """);
        var a=ScopedFiberRun.predicate(module,"inv5"); var b=ScopedFiberRun.predicate(module,"inv5c");
        int idx=-1;
        for(int i=0;i<module.getAllCommands().size();i++) {
            var c=module.getAllCommands().get(i);
            if(c.check && c.label.equals("correct")) {need(idx<0,"duplicate correct");idx=i;}
        }
        need(idx>=0,"no correct");
        var run=ScopedFiberRun.execute(module,idx); var m=ScopedClassifier.match(run,a,b);
        need(m.equals(ScopedClassifier.match(run,b,a)),"direction changed");
        String nativeResult=run.solution().satisfiable()?"SAT":"UNSAT";
        if(m.isEmpty()) return "NO_RULE\t"+nativeResult+"\t"+shape(a.getBody());
        var v=m.get(); var k=v.key();
        need(!run.solution().satisfiable() && v.command()==module.getAllCommands().get(idx) &&
                k.column() && k.domain().label.equals("this/Track") && k.selected().label.equals("this/Junction") &&
                k.field().label.equals("succs") && v.varying()==k.domain() && v.width()==4 && v.cap()==3 &&
                k.op()==ExprBinary.Op.GTE && k.literal()==2,v);
        proofs(lean,v,a,b);
        var left=v.first(a); var arms=v.arms().get(a); boolean split=arms.size()>1;
        boolean signed=arms.stream().anyMatch(p->p.read().observation()==ScopedClassifier.Observation.SIGNED);
        int size=module.getAllCommands().size()-1;
        var wrap=ScopedFiberRun.execute(module,size-2); var wider=ScopedFiberRun.execute(module,size-1);
        var tight=ScopedClassifier.match(wrap,a,b); var wide=ScopedClassifier.match(wider,a,b).orElseThrow();
        need(wrap.solution().satisfiable()==signed && tight.isEmpty()==signed &&
                tight.equals(ScopedClassifier.match(wrap,b,a)) && !wider.solution().satisfiable() &&
                wide.equals(ScopedClassifier.match(wider,b,a).orElseThrow()) && wide.width()==5 && wide.cap()==8 &&
                wide.command()==module.getAllCommands().get(size-1),v);
        proofs(lean,wide,a,b);
        boolean residue=!left.excluded().isEmpty();
        var form=arms.get(0).shape(); boolean set=form!=SplitClassifier.Shape.DIRECT;
        String kind=set?form.name():split?"SPLIT":left.witness().map(p->p.form().name()).orElse(residue?"RESIDUE":signed?"MACHINE":"TUPLE");
        var all=ScopedFiberRun.execute(module,size-3);
        need(all.solution().satisfiable()==signed && ScopedClassifier.match(all,a,b).isEmpty()==signed &&
                ScopedClassifier.match(all,b,a).isEmpty()==signed,"full equivalence at 8 tracks / 4 bits");
        if(residue) {
            var alias=ScopedFiberRun.execute(module,size);
            need(alias.solution().satisfiable() && ScopedClassifier.match(alias,a,b).isEmpty() &&
                    ScopedClassifier.match(alias,b,a).isEmpty(),"alias at the full modulus");
            proofs(lean,tight.orElseThrow(),a,b);
        }
        return kind+"\t"+nativeResult+"\t"+shape(a.getBody())+
                "\t"+term(left,v.width())+"\t"+term(v.first(b),v.width())+"\tTrack/Junction/succs/column/4/3"+
                "\twrap="+(signed?"SAT/refused":"UNSAT/matched")+"\twide=UNSAT/matched"+
                (set?"\t"+form+"\teightAudit="+(signed?"SAT/refused":"UNSAT/matched"):"")+
                (split?"\t"+arms.stream().map(arm->arm.role()+":"+arm.read().observation()+":"+term(arm.read(),v.width())+
                            arm.read().witness().map(p->":"+p.needs()).orElse("")).toList()+
                        "\teightAudit="+(signed?"SAT/refused":"UNSAT/matched"):
                    left.witness().map(p->"\t"+p.form()+":"+p.needs()+"\teightAudit=UNSAT/matched").orElse(""))+
                (residue?"\texcluded="+left.excluded()+"\teightAudit=UNSAT/matched\talias16=SAT/refused":"");
    }
    public static void main(String[] args) throws Exception {
        var lean=new TreeSet<String>(); var counts=new TreeMap<String,Integer>(); var cache=new HashMap<String,String>();
        for(String line:Files.readAllLines(Path.of(args[0]))) {
            String[] p=line.split("  ",2); byte[] bytes=Files.readAllBytes(Path.of(p[1]));
            need(HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes)).equals(p[0]),p[1]);
            String row=cache.get(p[0]);
            if(row==null) {row=inspect(new String(bytes,StandardCharsets.UTF_8),lean);cache.put(p[0],row);}
            counts.merge(row.split("\t")[0],1,Integer::sum);
            System.out.println("ROW\t"+p[1]+"\t"+p[0]+"\t"+row);
        }
        need(counts.equals(Map.of("MACHINE",87,"TUPLE",22,"GROUPED",16,"SOME_NOT_ONE",4,"RESIDUE",1,"SPLIT",16,"PROJECTION",5,"DIFFERENCE",1)) && cache.size()==80,counts);
        Files.writeString(Path.of(args[1]),"import AdaptiveClassifierProjection\nopen AdaptiveClassifier AdaptiveCardinality\n"+
                String.join("\n",lean)+"\n");
        System.out.println("POOL "+counts+" distinctModules="+cache.size()+" instantiatedPremises="+lean.size());
    }
}
