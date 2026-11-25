package is.fivefivefive.CanDis.augmentation;

import static is.fivefivefive.CanDis.augmentation.ClassifierControls.*;

final class SplitClassifierControls {
    static String both(String a,String b) {return "("+a+") and ("+b+")";}
    public static void main(String[] args) throws Exception {
        String n="all j:J | #f.j>1", s="all x:N | #f.x>1 implies x in J";
        String wt="all x:N | all disj p,q:N | p+q in f.x implies x in J";
        String tuple="all j:J | not lone f.j", mixed=both(n,wt), pure=both(tuple,wt);
        check(BASE,mixed,B,SMALL,true,false);
        check(BASE,both(wt,n),B,SMALL,true,false);
        check(BASE,mixed,B,EIGHT,false,true);
        check(BASE,pure,B,EIGHT,true,false);
        check(BASE,both(tuple,s),B,EIGHT,false,true); // overflow on the other implication
        check(BASE,both(n,s),A,EIGHT,true,false);
        check(BASE,both(n,s),B,EIGHT,false,true);
        check(BASE,"always after ("+mixed+")","after always ("+B+")",SMALL,true,false);
        check(BASE,both(n,"after ("+wt+")"),B,SMALL,false,true);
        check(BASE,n,B,SMALL,false,true);
        check(BASE,s,B,SMALL,false,true);
        check(BASE,both(n,n),B,SMALL,false,true);
        check(BASE,both(wt,wt),B,SMALL,false,true);
        check(BASE,both(n,wt.replace("p,q:N","p,q:K")),B,SMALL,false,true);
        check(BASE,both(n,wt.replace("all x:N | all disj p,q:N","all disj x,p,q:N")),B,SMALL,false,true);
        check(BASE,both(n,wt.replace("f.x","g.x")),B,SMALL,false,true);
        check(BASE,both(n,wt.replace("f.x","x.f")),B,SMALL,false,true);
        check(BASE,both(n,wt.replace("x in J","p in J")),B,SMALL,false,true);
        check(BASE,both(n,wt.replace("p+q","p+p")),B,SMALL,false,true);
        check(BASE,both(n,wt.replace("p+q in f.x","p+q in f.x and some g")),B,SMALL,false,true);
        check(BASE,both(n.replace("j:J","j:K"),s),B,SMALL,false,true);
        check(BASE,both(n,s.replace(">1",">2")),B,SMALL,false,true);
        check(BASE,both(A,B),B,SMALL,true,false);
        check(BASE,both(A,B),B,EIGHT,false,true);
        check(BASE,both(A,A.replace("f.x","g.x")),B,SMALL,false,true);
        check(BASE,both(mixed,"some g"),B,SMALL,false,true);
        String nonfirst="all p,x,q:N | p!=q and x in p.f & q.f implies x in J";
        check(BASE,both(tuple,nonfirst),B,EIGHT,true,false);
        check(BASE,both(tuple,nonfirst.replace("q.f","q.g")),B,SMALL,false,true);
        check(BASE,both(tuple,nonfirst.replace("q.f","p.f")),B,SMALL,false,true);
        String shared="all t:N | (t in J implies #f.t>1) and (#f.t>1 implies t in J)";
        check(BASE,shared,both(n,s),EIGHT,true,false);
        check(BASE,shared.replace("#f.t>1 implies t in J","#f.t>1 implies t in K"),B,SMALL,false,true);
        String typed="sig U {f:set V} sig V {} sig J in V {}";
        String m=both("all j:J | #f.j>1","all v:V | all disj p,q:U | v in p.f & q.f implies v in J");
        String ref="all v:V | v not in J iff lone f.v";
        check(typed,m,ref," for 8 but exactly 8 V, exactly 1 U, 4 Int",true,false);
        check(typed,m,ref," for 8 but exactly 1 V, exactly 8 U, 4 Int",false,true);
    }
}
