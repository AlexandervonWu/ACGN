package is.fivefivefive.CanDis.augmentation;

import static is.fivefivefive.CanDis.augmentation.ClassifierControls.*;

final class ClassifiedSetControls {
    public static void main(String[] args) throws Exception {
        String p="J=N.{w:N,t:N | w->t in f and not lone f.t}";
        check(BASE,p,B,EIGHT,true,false);
        check(BASE,"{t:N,w:N | not lone f.t and t->w in ~f}.N=J",B,EIGHT,true,false);
        check(BASE,p.replace("w->t","t->w"),B,SMALL,false,true);
        check(BASE,p.replace("w->t","w->w"),B,SMALL,false,true);
        check(BASE,p.replace("in f and","in g and"),B,SMALL,false,true);
        check(BASE,p.replace("not lone f.t","not lone f.w"),B,SMALL,false,true);
        check(BASE,p.replace("=N.","=K."),B,SMALL,false,true);
        check(BASE,p.replace("w:N","w:K"),B,SMALL,false,true);
        check(BASE,p.replace("t:N","t:K"),B,SMALL,false,true);
        check(BASE,p.replace("in f and","in f' and"),B,SMALL,false,true);
        check(BASE,p.replace("and not","and some g and not"),B,SMALL,false,true);
        check(BASE,p.replace("not lone","lone"),B.replace("not in","in"),SMALL,false,true);
        check(BASE,p.replace("not lone f.t","#f.t>1"),A,EIGHT,true,false);
        check(BASE,p.replace("not lone f.t","#f.t>1"),B,EIGHT,false,true);
        check(BASE,p.replace("not lone f.t","#f.t=0"),A.replace(">=2","=0"),SMALL,false,true);
        check(BASE,"always after ("+p+")","after always ("+B+")",SMALL,true,false);
        String diff="J=N-{t:N | lone f.t}";
        check(BASE,diff,B,EIGHT,true,false);
        check(BASE,diff.replace("=N-","=K-"),B,SMALL,false,true);
        check(BASE,diff.replace("t:N","t:K"),B,SMALL,false,true);
        check(BASE,diff.replace("lone f.t","not lone f.t"),B,SMALL,false,true);
        String src="sig U {f: set V} sig V {} sig J in V {}";
        check(src,"J=U.{w:U,t:V | w->t in f and #f.t>1}","all t:V | t not in J iff lone f.t",
                " for 8 but exactly 8 U, exactly 1 V, 4 Int",false,true);
        check(src,"J=U.{w:U,t:V | w->t in f and #f.t>1}","all t:V | t not in J iff lone f.t",
                " for 8 but exactly 1 U, exactly 8 V, 4 Int",true,false);
    }
}
