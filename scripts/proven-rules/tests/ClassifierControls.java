package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.*;
import java.util.*;

final class ClassifierControls {
    static final String BASE="sig N {var f,g:set N} var sig J,K in N {}\n";
    static final String A="all x:N | x in J iff #(f.x)>=2", B="all y:N | y not in J iff lone y.~f";
    static final String SMALL=" for 3 but 4 Int, 1..3 steps", EIGHT=" for 8 but exactly 8 N, 4 Int, 1..2 steps";
    static Optional<ScopedClassifier.Match> check(String base,String a,String b,String scope,boolean accept,boolean sat) throws Exception {
        var m=CompUtil.parseEverything_fromString(null,base+"pred a {"+a+"}\npred b {"+b+"}\ncheck {a iff b}"+scope);
        var x=ScopedFiberRun.predicate(m,"a");var y=ScopedFiberRun.predicate(m,"b");var run=ScopedFiberRun.execute(m,0);
        var res=ScopedClassifier.match(run,x,y);
        ClassifierPoolTest.need(res.isPresent()==accept && res.equals(ScopedClassifier.match(run,y,x)) &&
                run.solution().satisfiable()==sat,a+" / "+b+" "+scope+" "+res);
        if(res.isPresent()){
            var foreign=CompUtil.parseEverything_fromString(null,base+"pred b {"+b+"}");
            ClassifierPoolTest.need(ScopedClassifier.match(run,x,ScopedFiberRun.predicate(foreign,"b")).isEmpty(),"foreign");
            x.setBody(y.getBody());
            ClassifierPoolTest.need(ScopedClassifier.match(run,x,y).isEmpty(),"stale");
        }
        System.out.println("CONTROL "+a+" / "+b+" => "+accept+" counterexample="+sat);
        return res;
    }
    public static void main(String[] args) throws Exception {
        check(BASE,A,B,SMALL,true,false);
        check(BASE,A,B,EIGHT,false,true);
        check(BASE,A,B,EIGHT.replace("4 Int","5 Int"),true,false);
        check(BASE,A,"all t:N | 1 < #(t.~f) iff t in J",EIGHT,true,false);
        check(BASE,B,"J = {t:N | not lone f.t}",EIGHT,true,false);
        check(BASE,A,"{t:N | not lone f.t} = J",SMALL,true,false);
        check(BASE,A,A.replace(">=2",">=3"),SMALL,false,true);
        check(BASE,A,B.replace("y.~f","y.f"),SMALL,false,true);
        check(BASE,A,B.replace("y.~f","y.~g"),SMALL,false,true);
        check(BASE,A,B.replace("in J","in K"),SMALL,false,true);
        check(BASE,A,B.replace("not in","in"),SMALL,false,true);
        check(BASE,A,B.replace("y:N","y:K"),SMALL,false,true);
        check(BASE,A,B.replace("~f","~(f')"),SMALL,false,true);
        check(BASE,"always after ("+A+")","after always ("+B+")",SMALL,true,false);
        check(BASE,"after ("+A+")",B,SMALL,false,true);
        check(BASE,"J={x:K | not lone f.x}",B.replace("y:N","y:K"),SMALL,false,true);
        String src="sig S {f:set T} sig T {} sig J in T {}\n";
        String a=A.replace("x:N","x:T"),b=B.replace("y:N","y:T");
        check(src,a,b," for 8 but exactly 1 T, exactly 8 S, 4 Int",false,true);
        check(src,a,b," for 8 but exactly 8 T, exactly 1 S, 4 Int",true,false);
        String outgoing="sig S {f:set T} sig T {} sig J in S {}";
        String row="all x:S | x in J iff #(x.f)>=2", converse="all y:S | y not in J iff lone (~f).y";
        var ordinary=check(outgoing,row,converse," for 3 but exactly 1 S, exactly 3 T, 4 Int",true,false).orElseThrow();
        var small=check(outgoing,row,converse," for 8 but exactly 8 S, exactly 1 T, 4 Int",true,false).orElseThrow();
        ClassifierPoolTest.need(!ordinary.key().column() && ordinary.cap()==3 && ordinary.varying().label.equals("this/T") &&
                !small.key().column() && small.cap()==1 && small.varying().label.equals("this/T"),ordinary);
        check(outgoing,row,converse," for 8 but exactly 1 S, exactly 8 T, 4 Int",false,true);
        check(BASE,"all x:N | x in J iff after (some y:N | y in J and #(f.y)>=2)",B,SMALL,false,true);
        for(String mult:List.of("no","one","some")) {
            String cmp=switch(mult){case "no"->"=0";case "one"->"=1";default->">0";};
            check(BASE,A.replace(">=2",cmp),B.replace("not in","in").replace("lone",mult),SMALL,true,false);
        }
        for(String mult:List.of("no","one")) {
            String count=a.replace(">=2",mult.equals("no")?"=0":"=1");
            String tuples=b.replace("not in","in").replace("lone",mult);
            int edge=mult.equals("no")?16:17;
            for(int n:List.of(edge-1,edge))
                check(src,count,tuples," for "+n+" but exactly "+n+" S, exactly 1 T, 4 Int",n<edge,n==edge);
        }
    }
}
