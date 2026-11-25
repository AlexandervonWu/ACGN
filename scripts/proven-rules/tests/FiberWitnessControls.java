package is.fivefivefive.CanDis.augmentation;

import static is.fivefivefive.CanDis.augmentation.ClassifierControls.*;

final class FiberWitnessControls {
    static final String PREFIX="all x:N | x in J iff ";
    static final String GROUP="some disj p,q:N | (p+q) in f.x";
    static void compare(String body,boolean accept,boolean counterexample) throws Exception {
        check(BASE,PREFIX+"("+body+")",B,SMALL,accept,counterexample);
    }
    public static void main(String[] args) throws Exception {
        compare(GROUP,true,false);
        compare(GROUP.replace("disj ",""),false,true);
        compare(GROUP.replace("p+q","p+p"),false,true);
        compare(GROUP.replace("f.x","x.f"),false,true);
        compare(GROUP.replace("p,q:N","p,q:K"),false,true);
        compare("some p:N,q:f.x | x in p.f and q!=p",true,false);
        compare("some p:f.x,q:f.p | q!=p",false,true);
        compare("some disj p,q:N | x in p.f and x in q.g",false,true);
        compare("some disj p,q:N | x in p.f and after x in q.f",false,true);
        compare("some disj p,q:N | x in p.f and x in q.f and no g",false,true);
        compare("some p,q:f.x | p!=q and p=q",false,true);
        compare("some p,q:f.x | not (q=p)",true,false);
        compare("some p,q:N | p->x in f and q->x in f and p!=q",true,false);
        compare("some p,q:N | p->x in f and x->q in f and p!=q",false,true);
        compare("some f.x and not one f.x",true,false);
        compare("not one x.~f and some f.x",true,false);
        compare("some g.x and not one f.x",false,true);
        compare("not one f.x",false,true);
        compare("some f.x and not one f.x and some g",false,true);
        check(BASE,"all x:N | x in J iff not ("+GROUP+")","all x:N | x in J iff lone f.x",SMALL,true,false);
        check(BASE,"always after ("+PREFIX+GROUP+")","after always ("+B+")",SMALL,true,false);
        check(BASE,"after ("+PREFIX+GROUP+")",B,SMALL,false,true);
        check(BASE,PREFIX+GROUP,A,SMALL,true,false);
        check(BASE,PREFIX+GROUP,A,EIGHT,false,true);
        check(BASE,PREFIX+GROUP,B,EIGHT,true,false);
        String types="sig S {f:set T} sig T {} sig J in S {}";
        String row="all s:S | s in J iff some disj a,b:T | s->a in f and b in s.f";
        String m="all s:S | s in J iff #(s.f)>=2", tup="all s:S | s not in J iff lone (~f).s";
        var v=check(types,row,tup," for 3 but exactly 1 S, exactly 3 T",true,false).orElseThrow();
        ClassifierPoolTest.need(!v.key().column() && v.varying().label.equals("this/T") && v.cap()==3,v);
        check(types,row,m," for 8 but exactly 8 S, exactly 1 T, 4 Int",true,false);
        check(types,row,m," for 8 but exactly 1 S, exactly 8 T, 4 Int",false,true);
        String excludes="(#f.x!=1 and 0!=#x.~f)";
        check(BASE,PREFIX+excludes,A,SMALL,true,false);
        check(BASE,PREFIX+excludes,A,EIGHT,false,true);
        check(BASE,PREFIX+excludes,B,EIGHT,true,false);
        check(BASE,PREFIX+excludes,PREFIX+"(not (#f.x=0) and #f.x!=1 and #f.x!=1)",EIGHT,true,false);
        check(BASE,PREFIX+excludes.replace("0!=","2!="),B,SMALL,false,true);
        check(BASE,PREFIX+excludes.replace("~f","~g"),B,SMALL,false,true);
        check(BASE,PREFIX+excludes.replace("~f","~(f')"),B,SMALL,false,true);
        check(BASE,PREFIX+"(#f.x!=2 and #f.x!=0 and #f.x!=1)",A.replace(">=2",">=3"),SMALL,true,false);
        String out="all s:S | s in J iff (#s.f!=0 and #s.f!=1)";
        check(types,out,tup," for 15 but exactly 1 S, exactly 15 T, 4 Int",true,false);
        check(types,out,tup," for 16 but exactly 1 S, exactly 16 T, 4 Int",false,true);
        check(types,out,out.replace("#s.f!=0 and #s.f!=1","1!=#s.f and 0!=#s.f"),
                " for 16 but exactly 1 S, exactly 16 T, 4 Int",true,false);
    }
}
